
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

import DPP2 from _G
import Menus from DPP2
import i18n from DLib

_protectionmodes = {
	DPP2.PhysgunProtection,
	DPP2.ToolgunProtection,
	DPP2.DriveProtection,
	DPP2.DamageProtection,
	DPP2.PickupProtection,
	DPP2.UseProtection,
	DPP2.VehicleProtection,
	DPP2.GravgunProtection,
}

Menus.BuildPlyerModeRow = (ply) =>
	return if not IsValid(@)

	for def in *_protectionmodes
		with checkbox = vgui.Create('DCheckBoxLabel', @)
			\Dock(TOP)
			\DockMargin(5, 5, 5, 5)
			\SetChecked(def\IsDisabledForPlayerByAdmin(ply))
			\SetText('gui.dpp2.disable_protection.' .. def.identifier)
			.Button.DoClick = -> RunConsoleCommand('dpp2_switchpmode_' .. def.identifier, ply\UserID())
			.Button.Think = -> .Button\SetChecked(def\IsDisabledForPlayerByAdmin(ply))

Menus.BuildPlayerModePanel = =>
	return if not IsValid(@)

	panels = {}

	Update = ->
		panel\Remove() for panel in *panels when IsValid(panel)
		panels = {}

		for ply in *player.GetAll()
			with spoiler = vgui.Create('DCollapsibleCategory', @)
				table.insert(panels, spoiler)
				\Dock(TOP)
				\DockMargin(5, 5, 5, 5)
				\SetLabel(ply\Nick())
				\SetExpanded(false)
				Menus.BuildPlyerModeRow(spoiler, ply)

	Update()
	hook.Add 'OnEntityCreated', @, (ent) =>
		if ent\IsPlayer()
			timer.Simple 0, Update

	hook.Add 'EntityRemoved', @, (ent) =>
		if ent\IsPlayer()
			timer.Simple 0, Update

Menus.BuildUtilsPanel = =>
	@Button('gui.dpp2.toolmenu.util.cleardecals', 'dpp2_cleardecals')
	@Button('gui.dpp2.toolmenu.util.cleanupgibs', 'dpp2_cleanupgibs')

Menus.BuildCleanupPanel = =>
	return if not IsValid(@)

	@Button('gui.dpp2.toolmenu.playerutil.freezephysall', 'dpp2_freezephysall')\DockMargin(5, 5, 5, 5)
	@Button('gui.dpp2.toolmenu.util.cleanupgibs', 'dpp2_cleanupgibs')\DockMargin(5, 5, 5, 5)
	@Button('gui.dpp2.toolmenu.playerutil.freezephyspanic', 'dpp2_freezephyspanic')\DockMargin(5, 5, 5, 5)
	@Button('gui.dpp2.toolmenu.playerutil.clear_all', 'dpp2_cleanupall')\DockMargin(5, 5, 5, 5)
	@Button('gui.dpp2.toolmenu.playerutil.clear_npcs', 'dpp2_cleanupnpcs')\DockMargin(5, 5, 5, 5)
	@Button('gui.dpp2.toolmenu.playerutil.clear_vehicles', 'dpp2_cleanupvehicles')\DockMargin(5, 5, 5, 5)
	@Button('gui.dpp2.toolmenu.playerutil.clear_disconnected', 'dpp2_cleanupdisconnected')\DockMargin(5, 5, 5, 5)

	panels = {}

	Update = ->
		panel\Remove() for panel in *panels when IsValid(panel)
		panels = {}

		for ply in *player.GetAll()
			with row = vgui.Create('EditablePanel', @)
				table.insert(panels, row)
				\Dock(TOP)
				\DockPadding(5, 5, 5, 5)
				\SetTall(32)

				with vgui.Create('DLib_Avatar', row)
					\Dock(LEFT)
					\DockMargin(0, 0, 5, 0)
					\SetSteamID(ply\SteamID())
					timer.Simple 0, -> \SetWide(\GetTall())

				with vgui.Create('DButton', row)
					\Dock(FILL)
					\DockMargin(0, 0, 0, 0)
					\SetText('gui.dpp2.toolmenu.playerutil.clear', ply\Nick())
					.DoClick = -> RunConsoleCommand('dpp2_cleanup', ply\UserID())

				with vgui.Create('DButton', row)
					\Dock(LEFT)
					\DockMargin(0, 0, 5, 0)
					\SetText('gui.dpp2.toolmenu.playerutil.freezephys')
					\SetTooltip(DLib.i18n.localize('gui.dpp2.toolmenu.playerutil.freezephys_tip'))
					.DoClick = -> RunConsoleCommand('dpp2_freezephys', ply\UserID())
					\SizeToContents()
					\SetWide(\GetWide()\max(32))

	Update()
	hook.Add 'OnEntityCreated', @, (ent) =>
		if ent\IsPlayer()
			timer.Simple 0, Update

	hook.Add 'EntityRemoved', @, (ent) =>
		if ent\IsPlayer()
			timer.Simple 0, Update

Menus.BuildTransferFallbackPanel = =>
	return if not IsValid(@)

	lply = LocalPlayer()

	panels = {}

	Update = ->
		panel\Remove() for panel in *panels when IsValid(panel)
		panels = {}

		for ply in *player.GetAll()
			if ply ~= lply
				with row = vgui.Create('EditablePanel', @)
					table.insert(panels, row)
					\Dock(TOP)
					\DockPadding(5, 5, 5, 5)
					\SetTall(32)

					with vgui.Create('DLib_Avatar', row)
						\Dock(LEFT)
						\DockMargin(0, 0, 5, 0)
						\SetSteamID(ply\SteamID())
						timer.Simple 0, -> \SetWide(\GetTall())

					with vgui.Create('DCheckBoxLabel', row)
						\Dock(FILL)
						\DockMargin(0, 5, 0, 0)
						\SetText('gui.dpp2.toolmenu.playertransferfallback', ply\Nick())
						\SetChecked(lply\GetNWEntity('dpp2_transfer_fallback', NULL) == ply)

						ignore = false

						.Think = ->
							ignore = true

							if lply\GetNWEntity('dpp2_transfer_fallback', NULL) == ply
								\SetChecked(true)
							else
								\SetChecked(false)

							ignore = false

						.Button.OnChange = (newvalue) ->
							return if ignore

							if lply\GetNWEntity('dpp2_transfer_fallback', NULL) ~= ply
								RunConsoleCommand('dpp2_transferfallback', ply\UserID())
							else
								RunConsoleCommand('dpp2_transferunfallback')

	Update()
	hook.Add 'OnEntityCreated', @, (ent) =>
		if ent\IsPlayer()
			timer.Simple 0, Update

	hook.Add 'EntityRemoved', @, (ent) =>
		if ent\IsPlayer()
			timer.Simple 0, Update

Menus.BuildTransferPanel = =>
	return if not IsValid(@)

	lply = LocalPlayer()

	panels = {}

	Update = ->
		panel\Remove() for panel in *panels when IsValid(panel)
		panels = {}

		for ply in *player.GetAll()
			if ply ~= lply
				with row = vgui.Create('EditablePanel', @)
					table.insert(panels, row)
					\Dock(TOP)
					\DockPadding(5, 5, 5, 5)
					\SetTall(32)

					with vgui.Create('DLib_Avatar', row)
						\Dock(LEFT)
						\DockMargin(0, 0, 5, 0)
						\SetSteamID(ply\SteamID())
						timer.Simple 0, -> \SetWide(\GetTall())

					with vgui.Create('DButton', row)
						\Dock(FILL)
						\DockMargin(0, 0, 0, 0)
						\SetText('gui.dpp2.toolmenu.playertransfer', ply\Nick())
						.DoClick = -> RunConsoleCommand('dpp2_transfer', ply\UserID())
	Update()
	hook.Add 'OnEntityCreated', @, (ent) =>
		if ent\IsPlayer()
			timer.Simple 0, Update

	hook.Add 'EntityRemoved', @, (ent) =>
		if ent\IsPlayer()
			timer.Simple 0, Update
