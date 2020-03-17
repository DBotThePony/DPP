
-- Copyright (C) 2018-2019 DBotThePony

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

import DPP2, DLib from _G
import i18n from DLib

findDef = (str, ent, wanted) ->
	str = str\lower()
	output = {}

	for obj in *DPP2.DEF.ProtectionDefinition.OBJECTS
		if obj.identifier == str
			if obj\IsShared(ent) == wanted
				return {wanted and ('<' .. i18n.localize('command.dpp2.sharing.already_shared') .. '>') or ('<' .. i18n.localize('command.dpp2.sharing.already_not_shared') .. '>')}

			return {str}

		if obj.identifier\startsWith(str) and obj\IsShared(ent) ~= wanted
			table.insert(output, obj.identifier)

	return output

closure = (args = '', margs = '', unshare) =>
	return if not IsValid(@)
	args = DPP2.SplitArguments(args)

	return [string.format('%q', tostring(ent)) for ent in *@DPP2FindOwned()] if not args[1] and not unshare
	return [string.format('%q', tostring(ent)) for ent in *@DPP2FindOwned() when ent\DPP2IsShared()] if not args[1] and unshare

	local ents

	if unshare
		filter = (ent) -> ent\DPP2IsShared()
		ents = DPP2.AutocompleteOwnedEntityArgument(args[1], nil, nil, filter)
	else
		ents = DPP2.AutocompleteOwnedEntityArgument(args[1])

	return [string.format('%q', ent) for ent in *ents] if margs[#margs] ~= ' ' and not args[2]
	return {} if #ents == 0
	ent = DPP2.FindEntityFromArg(ents[1], @)
	return if not IsValid(ent)
	return {'<not an owner!>'} if ent\DPP2GetOwner() ~= @

	defitions = findDef(args[2] or '', ent, not unshare)
	return [string.format('%q %q', tostring(ent), def) for def in *defitions]

DPP2.cmd_autocomplete.share = (args, margs) => closure(@, args, margs, false)
DPP2.cmd_autocomplete.unshare = (args = '', margs = '') => closure(@, args, margs, true)
