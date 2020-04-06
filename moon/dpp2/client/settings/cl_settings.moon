
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

import DPP2 from _G
import Menus from DPP2

Menus._Icons = {
	Add: 'icon16/pencil_add.png'
	Wrench: 'icon16/wrench.png'
	Wrench2: 'icon16/wrench_orange.png'
	AddPlain: 'icon16/add.png'
	Edit: 'icon16/pencil.png'
	Copy: ['icon16/tag_' .. tag .. '.png' for tag in *{'blue', 'green', 'orange', 'pink', 'purple', 'red', 'yellow'}]
	Remove: 'icon16/delete.png'
	Angle: {'icon16/arrow_rotate_anticlockwise.png', 'icon16/arrow_rotate_clockwise.png'}
	Vector: 'icon16/arrow_in.png'
	Share: 'icon16/key_add.png'
	ShareAll: 'icon16/key_go.png'
	UnShare: 'icon16/key_delete.png'
	ShareContraption: 'icon16/lock_add.png'
	ShareAllContraption: 'icon16/lock_go.png'
	UnShareContraption: 'icon16/lock_delete.png'
}

Menus.Icons = setmetatable({}, {
	__index: (key) => istable(Menus._Icons[key]) and table.Random(Menus._Icons[key]) or Menus._Icons[key]
})

Menus.OpenModelBlacklistFrame = ->
	self = vgui.Create('DLib_Window')
	@SetSize(ScrW() - 100, ScrH() - 100)
	@SetTitle('gui.dpp2.model_blacklist.window_title')
	@Center()
	@MakePopup()

	scroll = vgui.Create('DScrollPanel', @)
	scroll\DockMargin(5, 5, 5, 5)
	scroll\Dock(FILL)
	canvas = scroll\GetCanvas()

	buttons = {}
	spacing = 6

	rearrangeButtons = (w = canvas\GetWide(), h = canvas\GetTall()) ->
		w -= ScreenSize(6)

		x = 0
		y = 0
		rowy = 0

		for _, icon in SortedPairs(buttons)
			iw, ih = icon\GetSize()

			if x + iw + spacing >= w
				y += rowy + spacing
				rowy = 0
				x = 0

			icon\SetPos(x, y)
			x += iw + spacing
			rowy = rowy\max(ih)

	canvas._PerformLayout = canvas._PerformLayout
	canvas.PerformLayout = (_, w, h) ->
		@_PerformLayout(w, h) if @_PerformLayout
		rearrangeButtons(w, h)

	rebuildList = ->
		button._mark = true for _, button in pairs(buttons)

		for model in *DPP2.ModelBlacklist.listing.values
			if not buttons[model]
				button = vgui.Create('SpawnIcon', canvas)
				--canvas\Add(button)
				button\SetSize(64, 64)
				button\SetModel(model)
				button\SetTooltip(model)

				button.DoClick = ->
					with menu = DermaMenu()
						\AddOption('gui.dpp2.property.copyclassname', (-> SetClipboardText(model)))\SetIcon(Menus.Icons.Copy)
						\AddSpacer()

						if DPP2.cmd_perm_watchdog\HasPermission('dpp2_remove_' .. DPP2.ModelBlacklist.identifier .. '_blacklist')
							remove = -> RunConsoleCommand('dpp2_remove_' .. DPP2.ModelBlacklist.identifier .. '_blacklist', model)
							submenu, button = \AddSubMenu('gui.dpp2.menu.remove_from_' .. DPP2.ModelBlacklist.identifier .. '_blacklist')
							button\SetIcon(Menus.Icons.Remove)
							submenu\AddOption('gui.dpp2.menus.remove2', remove)\SetIcon(Menus.Icons.Remove)

						\Open()

				button.DoRightClick = button.DoClick
				button.OpenMenu = button.DoClick

				buttons[model] = button
			else
				buttons[model]._mark = false

		button\Remove() for _, button in pairs(buttons) when button._mark
		buttons = {_, button for _, button in pairs(buttons) when not button._mark}
		rearrangeButtons()

	rebuildList()

	hook.Add 'DPP2_BL_' .. DPP2.ModelBlacklist.identifier .. '_EntryAdded', @, rebuildList
	hook.Add 'DPP2_BL_' .. DPP2.ModelBlacklist.identifier .. '_EntryRemoved', @, rebuildList

hook.Add 'PopulateToolMenu', 'DPP2.Menus', ->
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.client', 'gui.dpp2.toolmenu.client_protection', 'gui.dpp2.toolmenu.client_protection', '', '', Menus.ClientProtectionModulesMenu
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.client', 'gui.dpp2.toolmenu.client_settings', 'gui.dpp2.toolmenu.client_settings', '', '', Menus.ClientMenu

	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.main', 'gui.dpp2.toolmenu.primary', 'gui.dpp2.toolmenu.primary', '', '', Menus.PrimaryMenu
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.main', 'gui.dpp2.toolmenu.secondary', 'gui.dpp2.toolmenu.secondary', '', '', Menus.SecondaryMenu
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.main', 'gui.dpp2.toolmenu.logging', 'gui.dpp2.toolmenu.logging', '', '', Menus.LoggingMenu
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.main', 'gui.dpp2.toolmenu.antispam', 'gui.dpp2.toolmenu.antispam', '', '', Menus.AntispamMenu
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.main', 'gui.dpp2.toolmenu.antipropkill', 'gui.dpp2.toolmenu.antipropkill', '', '', Menus.AntipropkillMenu

	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.player', 'gui.dpp2.toolmenu.playermode', 'gui.dpp2.toolmenu.playermode', '', '', Menus.BuildPlayerModePanel
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.player', 'gui.dpp2.toolmenu.cleanup', 'gui.dpp2.toolmenu.cleanup', '', '', Menus.BuildCleanupPanel
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.player', 'gui.dpp2.toolmenu.utils', 'gui.dpp2.toolmenu.utils', '', '', Menus.BuildUtilsPanel

	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.limits', 'gui.dpp2.toolmenu.limits.sbox', 'gui.dpp2.toolmenu.limits.sbox', '', '', => DPP2.SBoxLimits\BuildCPanel(@)

	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.restriction', 'gui.dpp2.toolmenu.restrictions.physgun', 'gui.dpp2.toolmenu.restrictions.physgun', '', '', => DPP2.PhysgunProtection.RestrictionList\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.restriction', 'gui.dpp2.toolmenu.restrictions.drive', 'gui.dpp2.toolmenu.restrictions.drive', '', '', => DPP2.DriveProtection.RestrictionList\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.restriction', 'gui.dpp2.toolmenu.restrictions.pickup', 'gui.dpp2.toolmenu.restrictions.pickup', '', '', => DPP2.PickupProtection.RestrictionList\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.restriction', 'gui.dpp2.toolmenu.restrictions.use', 'gui.dpp2.toolmenu.restrictions.use', '', '', => DPP2.UseProtection.RestrictionList\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.restriction', 'gui.dpp2.toolmenu.restrictions.vehicle', 'gui.dpp2.toolmenu.restrictions.vehicle', '', '', => DPP2.VehicleProtection.RestrictionList\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.restriction', 'gui.dpp2.toolmenu.restrictions.gravgun', 'gui.dpp2.toolmenu.restrictions.gravgun', '', '', => DPP2.GravgunProtection.RestrictionList\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.restriction', 'gui.dpp2.toolmenu.restrictions.toolgun', 'gui.dpp2.toolmenu.restrictions.toolgun', '', '', => DPP2.ToolgunProtection.RestrictionList\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.restriction', 'gui.dpp2.toolmenu.restrictions.toolgun_mode', 'gui.dpp2.toolmenu.restrictions.toolgun_mode', '', '', => DPP2.ToolgunModeRestrictions\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.restriction', 'gui.dpp2.toolmenu.restrictions.damage', 'gui.dpp2.toolmenu.restrictions.damage', '', '', => DPP2.DamageProtection.RestrictionList\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.restriction', 'gui.dpp2.toolmenu.restrictions.class_spawn', 'gui.dpp2.toolmenu.restrictions.class_spawn', '', '', => DPP2.SpawnRestrictions\BuildCPanel(@)

	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.blacklist', 'gui.dpp2.toolmenu.blacklist.model', 'gui.dpp2.toolmenu.blacklist.model', '', '', Menus.ModelBlacklistMenu
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.blacklist', 'gui.dpp2.toolmenu.blacklist.physgun', 'gui.dpp2.toolmenu.blacklist.physgun', '', '', => DPP2.PhysgunProtection.Blacklist\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.blacklist', 'gui.dpp2.toolmenu.blacklist.drive', 'gui.dpp2.toolmenu.blacklist.drive', '', '', => DPP2.DriveProtection.Blacklist\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.blacklist', 'gui.dpp2.toolmenu.blacklist.pickup', 'gui.dpp2.toolmenu.blacklist.pickup', '', '', => DPP2.PickupProtection.Blacklist\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.blacklist', 'gui.dpp2.toolmenu.blacklist.use', 'gui.dpp2.toolmenu.blacklist.use', '', '', => DPP2.UseProtection.Blacklist\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.blacklist', 'gui.dpp2.toolmenu.blacklist.vehicle', 'gui.dpp2.toolmenu.blacklist.vehicle', '', '', => DPP2.VehicleProtection.Blacklist\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.blacklist', 'gui.dpp2.toolmenu.blacklist.gravgun', 'gui.dpp2.toolmenu.blacklist.gravgun', '', '', => DPP2.GravgunProtection.Blacklist\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.blacklist', 'gui.dpp2.toolmenu.blacklist.toolgun', 'gui.dpp2.toolmenu.blacklist.toolgun', '', '', => DPP2.ToolgunProtection.Blacklist\BuildCPanel(@)
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.blacklist', 'gui.dpp2.toolmenu.blacklist.damage', 'gui.dpp2.toolmenu.blacklist.damage', '', '', => DPP2.DamageProtection.Blacklist\BuildCPanel(@)
