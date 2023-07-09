
-- Copyright (C) 2018-2020 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

import debug, type, DPP2, DLib from _G
import i18n from DLib

-- Undo patch
if undo
	undo = undo
	undo._DPP2_Finish = undo._DPP2_Finish or undo.Finish
	DPP2.IN_TRANSFER = false

	findUndo = ->
		local Current_Undo

		for i = 1, 30
			varname, varvalue = debug.getupvalue(undo._DPP2_Finish, 1)
			break if not varname
			if varname == 'Current_Undo'
				Current_Undo = varvalue
				break

		return Current_Undo

	undo.Finish = (...) ->
		return undo._DPP2_Finish(...) if DPP2.IN_TRANSFER
		Current_Undo = findUndo()
		find = {}

		if Current_Undo and type(Current_Undo.Owner) == 'Player' and type(Current_Undo.Entities) == 'table'
			for ent in *Current_Undo.Entities
				if IsValid(ent) and DPP2.HookedEntityCreation(ent)
					DPP2.PlayerSpawnedSomething(Current_Undo.Owner, ent, true) if not ent.__dpp2_hit
					table.insert(find, ent)

		return undo._DPP2_Finish(...) if #find == 0

		DPP2.UnqueueAntispam(ent) for ent in *find
		DPP2.QueueAntispam(Current_Undo.Owner, table.remove(find, 1), find)

		return undo._DPP2_Finish(...)

-- cleanup patch
if cleanup
	cleanup = cleanup
	cleanup._DPP2_Add = cleanup._DPP2_Add or cleanup.Add

	cleanup.Add = (ply = NULL, mode = error('category was not specified'), ent = NULL, ...) ->
		error('NULL player specified') if not IsValid(ply)
		--error('NULL entity specified') if not IsValid(ent)
		DPP2.PlayerSpawnedSomething(ply, ent, true) if IsValid(ent) and not ent\DPP2IsOwned() and mode ~= 'duplicates'
		return cleanup._DPP2_Add(ply, mode, ent, ...)

if duplicator and duplicator.CopyEntTable
	duplicator._DPP2_CopyEntTable = duplicator._DPP2_CopyEntTable or duplicator.CopyEntTable
	duplicator.CopyEntTable = (ent, ...) ->
		ret = duplicator._DPP2_CopyEntTable(ent, ...)
		hook.Run('OnEntityCopyTableFinish', ent, ret) if IsValid(ent) and istable(ret)
		return ret


PatchE2 = ->
	Compiler = Compiler or E2Lib and E2Lib.Compiler
	return if not Compiler

	Compiler.DPP2_GetFunction = Compiler.DPP2_GetFunction or Compiler.GetFunction
	Compiler.DPP2_Execute = Compiler.DPP2_Execute or Compiler.Execute

	Compiler.GetFunction = (instr, Name, Args, ...) =>
		if IsValid(@__dpp2_owner)
			if not DPP2.E2FunctionRestrictions\Ask(Name, @__dpp2_owner)
				@Error(i18n.localize('message.dpp2.restriction.e2fn', Name), instr)
				return

		return Compiler.DPP2_GetFunction(@, instr, Name, Args, ...)

	Compiler.Execute = (...) ->
		instance = setmetatable({}, Compiler)
		varname, varvalue = debug.getlocal(2, 1)
		instance.__dpp2_owner = varvalue\DPP2GetOwner() if IsValid(varvalue) and varvalue\DPP2IsOwned()

		if E2Lib
			ok, script = xpcall(Compiler.Process, E2Lib.errorHandler, instance, ...)
			return ok, script, instance
		else
			return pcall(Compiler.Process, instance, ...)

if AreEntitiesAvailable()
	PatchE2()
else
	hook.Add 'InitPostEntity', 'DPP2.PatchE2Compiler', PatchE2, 2
