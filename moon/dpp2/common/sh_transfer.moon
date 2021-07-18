
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

import DPP, DLib from _G
import i18n from DLib

DPP2.cmd_autocomplete.transfer = (args = '') =>
	return if not IsValid(@)
	[string.format('%q', ply) for ply in *DPP2.FindPlayersInArgument(args, true, true)]

DPP2.cmd_autocomplete.transferfallback = (args = '') =>
	return if not IsValid(@)
	[string.format('%q', ply) for ply in *DPP2.FindPlayersInArgument(args, {LocalPlayer(), @DLibGetNWEntity('dpp2_transfer_fallback', NULL)}, true)]

DPP2.cmd_autocomplete.transferent = (args = '', margs = '') =>
	return if not IsValid(@)
	args = DPP2.SplitArguments(args)
	return [string.format('%q', tostring(ent)) for ent in *@DPP2FindOwned()] if not args[1]

	ace = DPP2.AutocompleteOwnedEntityArgument(args[1])
	return [string.format('%q', ent) for ent in *ace] if margs[#margs] ~= ' ' and not args[2]
	phint = '%q ' .. i18n.localize('command.dpp2.hint.player')
	return [string.format(phint, ent) for ent in *ace] if not args[2]

	table.remove(args, 1)
	return [string.format('%q %q', ent, ply) for ent in *ace for ply in *DPP2.FindPlayersInArgument(table.concat(args, ' ')\trim(), true, true)]

DPP2.cmd_autocomplete.transfertoworldent = (args = '', margs = '') =>
	return if not IsValid(@)
	return [string.format('%q', tostring(ent)) for ent in *@DPP2FindOwned()] if args == ''
	return DPP2.AutocompleteOwnedEntityArgument(args, true, true)

DPP2.cmd_autocomplete.transfercontraption = (args = '', margs = '') =>
	return if not IsValid(@)
	args = DPP2.SplitArguments(args)
	return [string.format('%q', contraption\GetID()) for contraption in *DPP2.ContraptionHolder\GetAll() when contraption\HasOwner(@)] if not args[1]

	local ace
	args[1] = args[1]\lower()

	if num = tonumber(args[1])
		if contraption = DPP2.ContraptionHolder\GetByID(num)
			if contraption\HasOwner(@)
				ace = {'"' .. args[1] .. '"'}
			else
				ace = {i18n.localize('command.dpp2.hint.share.not_own_contraption')}
		else
			ace = [string.format('%q', contraption\GetID()) for contraption in *DPP2.ContraptionHolder\GetAll() when contraption\HasOwner(@) and contraption\GetID()\tostring()\startsWith(args[1])]
			ace[1] = i18n.localize('command.dpp2.hint.none') if not ace[1]
	else
		ace = {'???'}

	table.sort(ace)
	return ace if margs[#margs] ~= ' ' and not args[2]
	phint = '%s ' .. i18n.localize('command.dpp2.hint.player')
	return [string.format(phint, ent) for ent in *ace] if not args[2]

	table.remove(args, 1)
	return [string.format('%s %q', ent, ply) for ent in *ace for ply in *DPP2.FindPlayersInArgument(table.concat(args, ' ')\trim(), true, true)]

DPP2.cmd_autocomplete.transfertoworldcontraption = (args = '', margs = '') =>
	return if not IsValid(@)
	args = DPP2.SplitArguments(args)
	return [string.format('%q', contraption\GetID()) for contraption in *DPP2.ContraptionHolder\GetAll() when contraption\HasOwner(@)] if not args[1]

	local ace
	args[1] = args[1]\lower()

	if num = tonumber(args[1])
		if contraption = DPP2.ContraptionHolder\GetByID(num)
			if contraption\HasOwner(@)
				ace = {'"' .. args[1] .. '"'}
			else
				ace = {i18n.localize('command.dpp2.autocomplete.share.not_own_contraption')}
		else
			ace = [string.format('%q', contraption\GetID()) for contraption in *DPP2.ContraptionHolder\GetAll() when contraption\HasOwner(@) and contraption\GetID()\tostring()\startsWith(args[1])]
			ace[1] = i18n.localize('command.dpp2.hint.none') if not ace[1]
	else
		ace = {'???'}

	table.sort(ace)
	return ace
