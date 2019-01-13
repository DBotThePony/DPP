
-- Copyright (C) 2015-2018 DBot

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

export CPPI_NOTIMPLEMENTED
export CPPI_DEFER

CPPI_NOTIMPLEMENTED = 9092
CPPI_DEFER = 9093

CPPI =
	GetName: -> 'DBot Prop Protection'
	GetVersion: -> '2.0'
	GetInterfaceVersion: -> 1.3

plyMeta = FindMetaTable('Player')
entMeta = FindMetaTable('Entity')

import IsValid from entMeta
import util from _G

if SERVER
	entMeta.CPPISetOwner = (newOwner = NULL) => @DPP2SetOwner(assert(type(newOwner) == 'Player' or newOwner == NULL, 'Invalid new owner provided, typeof ' .. type(newOwner)))
	entMeta.CPPISetOwnerUID = (newUID = '-1') => @DPP2SetOwnerUID(assert(type(newUID) == 'string', 'Invalid new owner UID provided, typeof ' .. type(newUID)))

plyMeta.CPPIGetFriends = =>
	output = {}

	for ply in *player.GetAll()
		hit = false

		for def in *DPP2.DEF.ProtectionDefinition
			if def\AreFriends(@, ply)
				hit = true
				break

		if hit
			table.insert(output, ply)

	return output

entMeta.CPPIGetOwner = =>
	owner, steamid = @DPP2GetOwner()
	return owner, util.CRC('gm_' .. steamid .. '_gm') if not IsValid(owner)
	return owner, owner\UniqueID()

entMeta.CPPICanTool = (ply = NULL, toolMode = 'remover') => DPP2.ACCESS.CanToolgun(ply, @, toolMode)
entMeta.CPPICanPhysgun = (ply = NULL) => DPP2.ACCESS.CanPhysgun(ply, @)
entMeta.CPPICanPickup = (ply = NULL) => DPP2.ACCESS.CanGravgun(ply, @)
entMeta.CPPICanPunt = (ply = NULL) => DPP2.ACCESS.CanGravgunPunt(ply, @)
entMeta.CPPICanUse = (ply = NULL) => DPP2.ACCESS.CanUse(ply, @)
entMeta.CPPIDrive = (ply = NULL) => DPP2.ACCESS.CanDrive(ply, @)
entMeta.CPPICanProperty = (ply = NULL, toolMode = 'remover') => DPP2.ACCESS.CanToolgun(ply, @, toolMode)
entMeta.CPPICanEditVariable = (ply = NULL, key, val, editTable) => DPP2.ACCESS.CanToolgun(ply, @, 'edit')
