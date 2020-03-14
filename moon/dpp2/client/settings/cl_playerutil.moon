
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

	for ply in *player.GetAll()
		with spoiler = vgui.Create('DCollapsibleCategory', @)
			\Dock(TOP)
			\DockMargin(5, 5, 5, 5)
			\SetLabel(ply\Nick())
			\SetExpanded(false)
			Menus.BuildPlyerModeRow(spoiler, ply)
