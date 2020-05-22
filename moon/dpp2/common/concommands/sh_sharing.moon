
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

closure = (args = '', margs = '', share) =>
	return if not IsValid(@)
	args = DPP2.SplitArguments(args)

	return [string.format('%q', tostring(ent)) for ent in *@DPP2FindOwned()] if not args[1] and share
	return [string.format('%q', tostring(ent)) for ent in *@DPP2FindOwned() when ent\DPP2IsShared()] if not args[1] and not share

	local ents

	if share
		ents = DPP2.AutocompleteOwnedEntityArgument(args[1])
	else
		filter = (ent) -> ent\DPP2IsShared()
		ents = DPP2.AutocompleteOwnedEntityArgument(args[1], nil, nil, filter)

	return [string.format('%q', ent) for ent in *ents] if margs[#margs] ~= ' ' and not args[2]
	return {} if #ents == 0
	ent = DPP2.FindEntityFromArg(ents[1], @)
	return if not IsValid(ent)
	return {i18n.localize('command.dpp2.hint.share.not_owned')} if ent\DPP2GetOwner() ~= @

	return [string.format('%q %q', tostring(ent), def) for def in *findDef(args[2] or '', ent, share)]

DPP2.cmd_autocomplete.share = (args, margs) => closure(@, args, margs, true)
DPP2.cmd_autocomplete.unshare = (args = '', margs = '') => closure(@, args, margs, false)

findDefContr = (str, contraption, wanted) ->
	str = str\lower()
	output = {}

	for obj in *DPP2.DEF.ProtectionDefinition.OBJECTS
		if obj.identifier == str
			for ent in *contraption.ents
				if not obj\IsShared(ent)
					return {obj.identifier}

			return {}

	if not hit
		for ent in *contraption.ents
			if IsValid(ent)
				for obj in *DPP2.DEF.ProtectionDefinition.OBJECTS
					if obj.identifier\startsWith(str) and obj\IsShared(ent) ~= wanted and not table.qhasValue(output, obj.identifier)
						table.insert(output, obj.identifier)

	return output

hasShare = (contraption) ->
	ply = LocalPlayer()

	for obj in *DPP2.DEF.ProtectionDefinition.OBJECTS
		for ent in *contraption.ents
			if IsValid(ent) and ent\DPP2GetOwner() == ply and obj\IsShared(ent)
				return true

	return false

hasAllShared = (contraption) ->
	ply = LocalPlayer()

	for obj in *DPP2.DEF.ProtectionDefinition.OBJECTS
		for ent in *contraption.ents
			if IsValid(ent) and ent\DPP2GetOwner() == ply and not obj\IsShared(ent)
				return false

	return true

closure_contraption = (args = '', margs = '', share) =>
	return if not IsValid(@)
	args = DPP2.SplitArguments(args)

	if not args[1]
		if share
			return [string.format('%q', tostring(contraption.id)) for contraption in *DPP2.ContraptionHolder.OBJECTS when contraption\HasOwner(@) and not hasAllShared(contraption)]
		else
			return [string.format('%q', tostring(contraption.id)) for contraption in *DPP2.ContraptionHolder.OBJECTS when contraption\HasOwner(@) and hasShare(contraption)]

	num = tonumber(args[1])

	if not args[2] and margs[#margs] ~= ' '
		if num
			for contraption in *DPP2.ContraptionHolder.OBJECTS
				if contraption.id == num
					if contraption\HasOwner(@)
						if share
							if hasAllShared(contraption)
								return {i18n.localize('command.dpp2.hint.share.nothing_to_share')}
							else
								return {string.format('%q', tostring(contraption.id))}
						else
							if hasShare(contraption)
								return {string.format('%q', tostring(contraption.id))}
							else
								return {i18n.localize('command.dpp2.hint.share.nothing_shared')}
					else
						return {i18n.localize('command.dpp2.hint.share.not_own_contraption')}

		if share
			return [string.format('%q', tostring(contraption.id)) for contraption in *DPP2.ContraptionHolder.OBJECTS when contraption\HasOwner(@) and contraption.id\tostring()\startsWith(args[1]) and not hasAllShared(contraption)]
		else
			return [string.format('%q', tostring(contraption.id)) for contraption in *DPP2.ContraptionHolder.OBJECTS when contraption\HasOwner(@) and contraption.id\tostring()\startsWith(args[1]) and hasShare(contraption)]

	contraption = DPP2.ContraptionHolder\GetByID(num) if num
	return {string.format('%q %q', args[1], args[2])} if not contraption
	return [string.format('%q %q', args[1], def) for def in *findDefContr(args[2] or '', contraption, share)]

DPP2.cmd_autocomplete.share_contraption = (args = '', margs = '') => closure_contraption(@, args, margs, true)
DPP2.cmd_autocomplete.unshare_contraption = (args = '', margs = '') => closure_contraption(@, args, margs, false)
