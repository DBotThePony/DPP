
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

DPP2.cmd.share = (args = {}, message) =>
	return 'command.dpp2.generic.invalid_side' if not IsValid(@)
	return 'command.dpp2.sharing.no_target' if not args[1]
	return 'command.dpp2.sharing.no_mode' if not args[2]
	def = DPP2.DEF.ProtectionDefinition\Get(args[2])
	return 'command.dpp2.sharing.invalid_mode' if not def
	ent = DPP2.FindEntityFromArg(table.remove(args, 1), @)
	return 'command.dpp2.sharing.invalid_entity' if not IsValid(ent)
	return 'command.dpp2.sharing.not_owner' if ent\DPP2GetOwner() ~= @
	return 'command.dpp2.sharing.already_shared' if def\IsShared(ent)
	def\SetIsShared(ent, true)
	DPP2.Notify(@, nil, 'command.dpp2.sharing.shared', ent, def.identifier)

DPP2.cmd.share_contraption = (args = {}, message) =>
	return 'command.dpp2.generic.invalid_side' if not IsValid(@)
	return 'command.dpp2.sharing.no_target' if not args[1]
	return 'command.dpp2.sharing.no_mode' if not args[2]
	def = DPP2.DEF.ProtectionDefinition\Get(args[2])
	return 'command.dpp2.sharing.invalid_mode' if not def
	cstr = '_dpp2_share_' .. def.identifier
	return 'command.dpp2.sharing.cooldown', @[cstr] - RealTime() if @[cstr] and @[cstr] > RealTime()
	DPP2.ContraptionHolder\Invalidate()
	contraption = DPP2.ContraptionHolder\GetByID(tonumber(table.remove(args, 1) or -1) or -1)
	return 'command.dpp2.sharing.invalid_contraption' if not IsValid(contraption)
	return 'command.dpp2.sharing.not_owner_contraption' if not contraption\HasOwner(@)

	for ent in *contraption.ents
		if IsValid(ent) and ent\DPP2GetOwner() == @
			def\SetIsShared(ent, true)

	@[cstr] = RealTime() + #contraption.ents / 60

	DPP2.Notify(@, nil, 'command.dpp2.sharing.shared_contraption', contraption.id, def.identifier)

DPP2.cmd.unshare = (args = {}, message) =>
	return 'command.dpp2.generic.invalid_side' if not IsValid(@)
	return 'command.dpp2.sharing.no_target' if not args[1]
	return 'command.dpp2.sharing.no_mode' if not args[2]
	def = DPP2.DEF.ProtectionDefinition\Get(args[2])
	return 'command.dpp2.sharing.invalid_mode' if not def
	ent = DPP2.FindEntityFromArg(table.remove(args, 1), @)
	return 'command.dpp2.sharing.invalid_entity' if not IsValid(ent)
	return 'command.dpp2.sharing.not_owner' if ent\DPP2GetOwner() ~= @
	return 'command.dpp2.sharing.already_not_shared' if not def\IsShared(ent)
	def\SetIsShared(ent, false)
	DPP2.Notify(@, nil, 'command.dpp2.sharing.un_shared', ent, def.identifier)

DPP2.cmd.unshare_contraption = (args = {}, message) =>
	return 'command.dpp2.generic.invalid_side' if not IsValid(@)
	return 'command.dpp2.sharing.no_target' if not args[1]
	return 'command.dpp2.sharing.no_mode' if not args[2]
	def = DPP2.DEF.ProtectionDefinition\Get(args[2])
	return 'command.dpp2.sharing.invalid_mode' if not def
	cstr = '_dpp2_share_' .. def.identifier
	return 'command.dpp2.sharing.cooldown', @[cstr] - RealTime() if @[cstr] and @[cstr] > RealTime()
	DPP2.ContraptionHolder\Invalidate()
	contraption = DPP2.ContraptionHolder\GetByID(tonumber(table.remove(args, 1) or -1) or -1)
	return 'command.dpp2.sharing.invalid_contraption' if not IsValid(contraption)
	return 'command.dpp2.sharing.not_owner_contraption' if not contraption\HasOwner(@)

	for ent in *contraption.ents
		if IsValid(ent) and ent\DPP2GetOwner() == @
			def\SetIsShared(ent, false)

	@[cstr] = RealTime() + #contraption.ents / 60

	DPP2.Notify(@, nil, 'command.dpp2.sharing.un_shared_contraption', contraption.id, def.identifier)
