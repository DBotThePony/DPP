
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

import hook, DPP2, DLib from _G
import Menus from DPP2

local lastMenu
lastMenuFrame = 0

_entlist = {
	DPP2.PhysgunProtection.RestrictionList, DPP2.DriveProtection.RestrictionList, DPP2.PickupProtection.RestrictionList
	DPP2.UseProtection.RestrictionList, DPP2.VehicleProtection.RestrictionList, DPP2.GravgunProtection.RestrictionList
	DPP2.ToolgunProtection.RestrictionList, DPP2.DamageProtection.RestrictionList, DPP2.SpawnRestrictions
}

addRestrictionMenuOption = (classname, menu) =>
	with menu
		if @Has(classname)
			if DPP2.cmd_perm_watchdog\HasPermission('dpp2_add_' .. @identifier .. '_restriction')
				edit = -> @OpenMenu(classname)
				\AddOption('gui.dpp2.menu.edit_in_' .. @identifier .. '_restrictions', edit)\SetIcon(Menus.Icons.Edit)

			if DPP2.cmd_perm_watchdog\HasPermission('dpp2_remove_' .. @identifier .. '_restriction')
				remove = -> RunConsoleCommand('dpp2_remove_' .. @identifier .. '_restriction', classname)
				submenu, button = \AddSubMenu('gui.dpp2.menu.remove_from_' .. @identifier .. '_restrictions')
				button\SetIcon(Menus.Icons.Remove)
				submenu\AddOption('gui.dpp2.menus.remove2', remove)\SetIcon(Menus.Icons.Remove)
		else
			if DPP2.cmd_perm_watchdog\HasPermission('dpp2_add_' .. @identifier .. '_restriction')
				add = -> @OpenMenu(classname)
				\AddOption('gui.dpp2.menu.add_to_' .. @identifier .. '_restrictions', add)\SetIcon(Menus.Icons.Add)

addBlacklistMenuOption = (classname, menu) =>
	with menu
		if @Has(classname)
			if DPP2.cmd_perm_watchdog\HasPermission('dpp2_remove_' .. @identifier .. '_blacklist')
				remove = -> RunConsoleCommand('dpp2_remove_' .. @identifier .. '_blacklist', classname)
				submenu, button = \AddSubMenu('gui.dpp2.menu.remove_from_' .. @identifier .. '_blacklist')
				button\SetIcon(Menus.Icons.Remove)
				submenu\AddOption('gui.dpp2.menus.remove2', remove)\SetIcon(Menus.Icons.Remove)
		else
			if DPP2.cmd_perm_watchdog\HasPermission('dpp2_add_' .. @identifier .. '_blacklist')
				add = -> RunConsoleCommand('dpp2_add_' .. @identifier .. '_blacklist', classname)
				\AddOption('gui.dpp2.menu.add_to_' .. @identifier .. '_blacklist', add)\SetIcon(Menus.Icons.AddPlain)

SpawnlistOpenGenericMenu = =>
	selected = @GetSelectedChildren()
	return if #selected == 0
	--models = [panel\GetModelName()\lower() for panel in *selected when panel\GetName() == 'SpawnIcon' and panel.GetModelName and panel\GetModelName()]
	models = [panel\GetModelName()\lower() for panel in *selected when panel.GetModelName and panel\GetModelName()]
	return if #models == 0

	hitRemove = false
	hitAdd = false

	for model in *models
		if DPP2.ModelBlacklist\Has(model)
			hitRemove = true
		else
			hitAdd = true

		break if hitRemove and hitAdd

	return if not hitRemove and not hitAdd

	local menu

	if lastMenu and lastMenuFrame == FrameNumber()
		menu = lastMenu
	else
		menu = DermaMenu()

	menu\AddSpacer()

	if hitRemove and DPP2.cmd_perm_watchdog\HasPermission('dpp2_remove_model_blacklist')
		lastMenuFrame = FrameNumber() + 1
		remove = ->
			for model in *models
				if DPP2.ModelBlacklist\Has(model)
					RunConsoleCommand('dpp2_remove_model_blacklist', model)
		submenu, button = menu\AddSubMenu('gui.dpp2.menu.remove_from_model_blacklist')
		button\SetIcon(Menus.Icons.Remove)
		submenu\AddOption('gui.dpp2.menus.remove2', remove)\SetIcon(Menus.Icons.Remove)

	if hitAdd and DPP2.cmd_perm_watchdog\HasPermission('dpp2_add_model_blacklist')
		add = ->
			for model in *models
				if not DPP2.ModelBlacklist\Has(model)
					RunConsoleCommand('dpp2_add_model_blacklist', model)
		menu\AddOption('gui.dpp2.menu.add_to_model_blacklist', add)\SetIcon(Menus.Icons.AddPlain)

hook.Add 'SpawnlistOpenGenericMenu', 'DPP2.ContextMenuCatch', SpawnlistOpenGenericMenu, 8
hook.Add 'VGUIPanelCreated', 'DPP2.ContextMenuCatch', =>
	if @GetName() == 'DMenu' and lastMenuFrame < FrameNumber()
		lastMenu = @
		lastMenuFrame = FrameNumber()
		return

	if @GetName() == 'SpawnIcon'
		timer.Simple 0, ->
			return if not @IsValid()
			@OpenMenu_DPP2 = @OpenMenu_DPP2 or @OpenMenu
			@OpenMenu = =>
				@OpenMenu_DPP2()

				if IsValid(lastMenu) and lastMenuFrame == FrameNumber()
					lastMenuFrame = FrameNumber() + 1
					lastMenu\AddSpacer()
					addBlacklistMenuOption(DPP2.ModelBlacklist, @GetModelName()\lower(), lastMenu)

		return

	return if @GetName() ~= 'ContentIcon'
	timer.Simple 0, ->
		return if not @IsValid()
		contentType = @GetContentType()
		return if not contentType

		if contentType == 'entity'
			@OpenMenu_DPP2 = @OpenMenu_DPP2 or @OpenMenu

			@OpenMenu = =>
				@OpenMenu_DPP2()

				if IsValid(lastMenu) and lastMenuFrame == FrameNumber()
					lastMenuFrame = FrameNumber() + 1
					lastMenu\AddSpacer()
					addRestrictionMenuOption(DPP2.SpawnRestrictions, @GetSpawnName(), lastMenu)
					lastMenu\AddSpacer()
					addRestrictionMenuOption(DPP2.PhysgunProtection.RestrictionList, @GetSpawnName(), lastMenu)
					addRestrictionMenuOption(DPP2.DriveProtection.RestrictionList, @GetSpawnName(), lastMenu)
					addRestrictionMenuOption(DPP2.PickupProtection.RestrictionList, @GetSpawnName(), lastMenu)
					addRestrictionMenuOption(DPP2.UseProtection.RestrictionList, @GetSpawnName(), lastMenu)
					addRestrictionMenuOption(DPP2.GravgunProtection.RestrictionList, @GetSpawnName(), lastMenu)
					addRestrictionMenuOption(DPP2.ToolgunProtection.RestrictionList, @GetSpawnName(), lastMenu)
					addRestrictionMenuOption(DPP2.DamageProtection.RestrictionList, @GetSpawnName(), lastMenu)
					lastMenu\Open()
		elseif contentType == 'weapon'
			@OpenMenu_DPP2 = @OpenMenu_DPP2 or @OpenMenu

			@OpenMenu = =>
				@OpenMenu_DPP2()

				if IsValid(lastMenu) and lastMenuFrame == FrameNumber()
					lastMenuFrame = FrameNumber() + 1
					lastMenu\AddSpacer()
					addRestrictionMenuOption(DPP2.SpawnRestrictions, @GetSpawnName(), lastMenu)
					lastMenu\AddSpacer()
					addRestrictionMenuOption(DPP2.PickupProtection.RestrictionList, @GetSpawnName(), lastMenu)
					addRestrictionMenuOption(DPP2.UseProtection.RestrictionList, @GetSpawnName(), lastMenu)
					addRestrictionMenuOption(DPP2.GravgunProtection.RestrictionList, @GetSpawnName(), lastMenu)
					lastMenu\Open()
		elseif contentType == 'npc'
			@OpenMenu_DPP2 = @OpenMenu_DPP2 or @OpenMenu

			@OpenMenu = =>
				@OpenMenu_DPP2()

				if IsValid(lastMenu) and lastMenuFrame == FrameNumber()
					lastMenuFrame = FrameNumber() + 1
					classname = @GetSpawnName()
					classname = list.GetForEdit('NPC')[classname].Class or classname if list.GetForEdit('NPC')[classname]
					lastMenu\AddSpacer()
					addRestrictionMenuOption(DPP2.SpawnRestrictions, classname, lastMenu)
					lastMenu\AddSpacer()
					addRestrictionMenuOption(DPP2.PhysgunProtection.RestrictionList, classname, lastMenu)
					addRestrictionMenuOption(DPP2.ToolgunProtection.RestrictionList, classname, lastMenu)
					addRestrictionMenuOption(DPP2.UseProtection.RestrictionList, classname, lastMenu)
					addRestrictionMenuOption(DPP2.GravgunProtection.RestrictionList, classname, lastMenu)
					addRestrictionMenuOption(DPP2.DamageProtection.RestrictionList, classname, lastMenu)
					lastMenu\Open()
		elseif contentType == 'vehicle'
			@OpenMenu_DPP2 = @OpenMenu_DPP2 or @OpenMenu

			@OpenMenu = =>
				@OpenMenu_DPP2()

				if IsValid(lastMenu) and lastMenuFrame == FrameNumber()
					if getdata = list.GetForEdit('Vehicles')[@GetSpawnName()]
						lastMenuFrame = FrameNumber() + 1
						lastMenu\AddSpacer()
						addBlacklistMenuOption(DPP2.ModelBlacklist, getdata.Model, lastMenu) if getdata.Model
						addRestrictionMenuOption(DPP2.SpawnRestrictions, getdata.Class, lastMenu)
						lastMenu\AddSpacer()
						addRestrictionMenuOption(DPP2.PhysgunProtection.RestrictionList, getdata.Class, lastMenu)
						addRestrictionMenuOption(DPP2.ToolgunProtection.RestrictionList, getdata.Class, lastMenu)
						addRestrictionMenuOption(DPP2.UseProtection.RestrictionList, getdata.Class, lastMenu)
						addRestrictionMenuOption(DPP2.VehicleProtection.RestrictionList, getdata.Class, lastMenu)
						addRestrictionMenuOption(DPP2.GravgunProtection.RestrictionList, getdata.Class, lastMenu)
						addRestrictionMenuOption(DPP2.DamageProtection.RestrictionList, getdata.Class, lastMenu)
						lastMenu\Open()
		elseif contentType == 'model'
			@OpenMenu_DPP2 = @OpenMenu_DPP2 or @OpenMenu

			@OpenMenu = =>
				@OpenMenu_DPP2()

				if IsValid(lastMenu) and lastMenuFrame == FrameNumber()
					lastMenuFrame = FrameNumber() + 1
					lastMenu\AddSpacer()
					addBlacklistMenuOption(DPP2.ModelBlacklist, @GetModelName(), lastMenu)

