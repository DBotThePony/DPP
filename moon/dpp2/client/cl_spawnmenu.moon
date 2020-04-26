
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
			if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. @add_command_identifier)
				edit = -> @OpenMenu(classname)
				\AddOption('gui.dpp2.menu.edit_in_' .. @identifier .. '_restrictions', edit)\SetIcon(Menus.Icons.Edit)

			if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. @remove_command_identifier)
				remove = -> RunConsoleCommand('dpp2_' .. @remove_command_identifier, classname)
				submenu, button = \AddSubMenu('gui.dpp2.menu.remove_from_' .. @identifier .. '_restrictions')
				button\SetIcon(Menus.Icons.Remove)
				submenu\AddOption('gui.dpp2.menus.remove2', remove)\SetIcon(Menus.Icons.Remove)
		else
			if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. @add_command_identifier)
				add = -> @OpenMenu(classname)
				\AddOption('gui.dpp2.menu.add_to_' .. @identifier .. '_restrictions', add)\SetIcon(Menus.Icons.Add)

addBlacklistMenuOption = (classname, menu) =>
	with menu
		if @Has(classname)
			if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. @remove_command_identifier)
				remove = -> RunConsoleCommand('dpp2_' .. @remove_command_identifier, classname)
				submenu, button = \AddSubMenu('gui.dpp2.menu.remove_from_' .. @identifier .. '_' .. @@REGULAR_NAME)
				button\SetIcon(Menus.Icons.Remove)
				submenu\AddOption('gui.dpp2.menus.remove2', remove)\SetIcon(Menus.Icons.Remove)
		else
			if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. @add_command_identifier)
				add = -> RunConsoleCommand('dpp2_' .. @add_command_identifier, classname)
				\AddOption('gui.dpp2.menu.add_to_' .. @identifier .. '_' .. @@REGULAR_NAME, add)\SetIcon(Menus.Icons.AddPlain)

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

DPP2.ToolStuff = {}
local catchButtons

PatchToolPanel = =>
	@AddCategory_DPP2 = @AddCategory_DPP2 or @AddCategory
	@AddCategory = (name, label, items, ...) =>
		panels = {}
		catchButtons = panels
		a, b, c, d, e, f = @AddCategory_DPP2(name, label, items, ...)
		catchButtons = nil

		for button in *panels
			if IsValid(button)
				if isstring(button.Command) and button.Command\startsWith('gmod_tool ')
					toolname = button.Command\sub(11)
					with button
						.DoRightClick_DPP2 = .DoRightClick_DPP2 or .DoRightClick or () ->
						.DoRightClick = ->
							\DoRightClick_DPP2(button)
							local menu

							if lastMenu and lastMenuFrame == FrameNumber()
								menu = lastMenu
							else
								menu = DermaMenu()

							select_tool = ->
								\DoClickInternal()
								\DoClick()

							menu\AddOption('gui.dpp2.property.copyclassname', (-> SetClipboardText(toolname)))\SetIcon(Menus.Icons.Copy)
							menu\AddSpacer()
							menu\AddOption('gui.dpp2.toolmenu.select_tool2', (-> RunConsoleCommand(unpack(.Command\split(' ')))))\SetIcon(Menus.Icons.Wrench)
							menu\AddOption('gui.dpp2.toolmenu.select_tool', select_tool)\SetIcon(Menus.Icons.Wrench2)
							addRestrictionMenuOption(DPP2.ToolgunModeRestrictions, toolname, menu)
							addBlacklistMenuOption(DPP2.ToolgunModeExclusions, toolname, menu)
							menu\Open()

		return a, b, c, d, e, f

PatchSpawnIcon = =>
	@OpenMenu_DPP2 = @OpenMenu_DPP2 or @OpenMenu
	@OpenMenu = =>
		@OpenMenu_DPP2()

		if IsValid(lastMenu) and lastMenuFrame == FrameNumber()
			lastMenuFrame = FrameNumber() + 1
			lastMenu\AddSpacer()
			lower = @GetModelName()\lower()
			addBlacklistMenuOption(DPP2.ModelBlacklist, lower, lastMenu)
			addBlacklistMenuOption(DPP2.ModelExclusions, lower, lastMenu)

hook.Add 'SpawnlistOpenGenericMenu', 'DPP2.ContextMenuCatch', SpawnlistOpenGenericMenu, 8
hook.Add 'VGUIPanelCreated', 'DPP2.ContextMenuCatch', =>
	name = @GetName()

	if catchButtons and name == 'DButton'
		table.insert(catchButtons, @)
		return

	if name == 'DMenu' and lastMenuFrame < FrameNumber()
		lastMenu = @
		lastMenuFrame = FrameNumber()
		return

	if name == 'SpawnIcon'
		timer.Simple 0, -> PatchSpawnIcon(@) if IsValid(@)
		return

	if name == 'ToolPanel'
		PatchToolPanel(@)
		return

	return if name ~= 'ContentIcon'
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

					lastMenu\AddSpacer()

					addBlacklistMenuOption(DPP2.PhysgunProtection.Blacklist, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.DriveProtection.Blacklist, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.PickupProtection.Blacklist, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.UseProtection.Blacklist, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.GravgunProtection.Blacklist, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.ToolgunProtection.Blacklist, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.DamageProtection.Blacklist, @GetSpawnName(), lastMenu)

					lastMenu\AddSpacer()

					addBlacklistMenuOption(DPP2.PhysgunProtection.Exclusions, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.DriveProtection.Exclusions, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.PickupProtection.Exclusions, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.UseProtection.Exclusions, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.GravgunProtection.Exclusions, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.ToolgunProtection.Exclusions, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.DamageProtection.Exclusions, @GetSpawnName(), lastMenu)

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

					lastMenu\AddSpacer()

					addBlacklistMenuOption(DPP2.PickupProtection.Blacklist, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.UseProtection.Blacklist, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.GravgunProtection.Blacklist, @GetSpawnName(), lastMenu)

					lastMenu\AddSpacer()

					addBlacklistMenuOption(DPP2.PickupProtection.Exclusions, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.UseProtection.Exclusions, @GetSpawnName(), lastMenu)
					addBlacklistMenuOption(DPP2.GravgunProtection.Exclusions, @GetSpawnName(), lastMenu)

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

					lastMenu\AddSpacer()

					addBlacklistMenuOption(DPP2.PhysgunProtection.Blacklist, classname, lastMenu)
					addBlacklistMenuOption(DPP2.ToolgunProtection.Blacklist, classname, lastMenu)
					addBlacklistMenuOption(DPP2.UseProtection.Blacklist, classname, lastMenu)
					addBlacklistMenuOption(DPP2.GravgunProtection.Blacklist, classname, lastMenu)
					addBlacklistMenuOption(DPP2.DamageProtection.Blacklist, classname, lastMenu)

					lastMenu\AddSpacer()

					addBlacklistMenuOption(DPP2.PhysgunProtection.Exclusions, classname, lastMenu)
					addBlacklistMenuOption(DPP2.ToolgunProtection.Exclusions, classname, lastMenu)
					addBlacklistMenuOption(DPP2.UseProtection.Exclusions, classname, lastMenu)
					addBlacklistMenuOption(DPP2.GravgunProtection.Exclusions, classname, lastMenu)
					addBlacklistMenuOption(DPP2.DamageProtection.Exclusions, classname, lastMenu)

					lastMenu\Open()
		elseif contentType == 'vehicle'
			@OpenMenu_DPP2 = @OpenMenu_DPP2 or @OpenMenu

			@OpenMenu = =>
				@OpenMenu_DPP2()

				if IsValid(lastMenu) and lastMenuFrame == FrameNumber()
					if getdata = list.GetForEdit('Vehicles')[@GetSpawnName()]
						lastMenuFrame = FrameNumber() + 1
						lastMenu\AddSpacer()

						if getdata.Model
							addBlacklistMenuOption(DPP2.ModelBlacklist, getdata.Model, lastMenu)
							addBlacklistMenuOption(DPP2.ModelExclusions, getdata.Model, lastMenu)

						addRestrictionMenuOption(DPP2.SpawnRestrictions, getdata.Class, lastMenu)

						lastMenu\AddSpacer()

						addRestrictionMenuOption(DPP2.PhysgunProtection.RestrictionList, getdata.Class, lastMenu)
						addRestrictionMenuOption(DPP2.ToolgunProtection.RestrictionList, getdata.Class, lastMenu)
						addRestrictionMenuOption(DPP2.UseProtection.RestrictionList, getdata.Class, lastMenu)
						addRestrictionMenuOption(DPP2.VehicleProtection.RestrictionList, getdata.Class, lastMenu)
						addRestrictionMenuOption(DPP2.GravgunProtection.RestrictionList, getdata.Class, lastMenu)
						addRestrictionMenuOption(DPP2.DamageProtection.RestrictionList, getdata.Class, lastMenu)

						lastMenu\AddSpacer()

						addBlacklistMenuOption(DPP2.PhysgunProtection.Blacklist, getdata.Class, lastMenu)
						addBlacklistMenuOption(DPP2.ToolgunProtection.Blacklist, getdata.Class, lastMenu)
						addBlacklistMenuOption(DPP2.UseProtection.Blacklist, getdata.Class, lastMenu)
						addBlacklistMenuOption(DPP2.VehicleProtection.Blacklist, getdata.Class, lastMenu)
						addBlacklistMenuOption(DPP2.GravgunProtection.Blacklist, getdata.Class, lastMenu)
						addBlacklistMenuOption(DPP2.DamageProtection.Blacklist, getdata.Class, lastMenu)

						lastMenu\AddSpacer()

						addBlacklistMenuOption(DPP2.PhysgunProtection.Exclusions, getdata.Class, lastMenu)
						addBlacklistMenuOption(DPP2.ToolgunProtection.Exclusions, getdata.Class, lastMenu)
						addBlacklistMenuOption(DPP2.UseProtection.Exclusions, getdata.Class, lastMenu)
						addBlacklistMenuOption(DPP2.VehicleProtection.Exclusions, getdata.Class, lastMenu)
						addBlacklistMenuOption(DPP2.GravgunProtection.Exclusions, getdata.Class, lastMenu)
						addBlacklistMenuOption(DPP2.DamageProtection.Exclusions, getdata.Class, lastMenu)

						lastMenu\Open()
		elseif contentType == 'model'
			@OpenMenu_DPP2 = @OpenMenu_DPP2 or @OpenMenu

			@OpenMenu = =>
				@OpenMenu_DPP2()

				if IsValid(lastMenu) and lastMenuFrame == FrameNumber()
					lastMenuFrame = FrameNumber() + 1
					lastMenu\AddSpacer()
					lower = @GetModelName()\lower()
					addBlacklistMenuOption(DPP2.ModelBlacklist, lower, lastMenu)
					addBlacklistMenuOption(DPP2.ModelExclusions, lower, lastMenu)

