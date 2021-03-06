
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

Menus.OpenShareMenu = (contraption) =>
	frame = vgui.Create('DLib_Window')
	frame\SetTitle('gui.dpp2.sharing.window_title')
	frame\SetSize(240, 400)
	frame\MakePopup()
	frame\Center()
	boxes = {}

	for obj in *DPP2.DEF.ProtectionDefinition.OBJECTS
		with checkbox = vgui.Create('DCheckBoxLabel', frame)
			table.insert(boxes, checkbox)
			\SetText('gui.dpp2.sharing.share_' .. obj.identifier)
			\SetChecked(obj\IsShared(@))
			._obj = obj
			\Dock(TOP)
			\DockMargin(5, 5, 5, 5)

	with vgui.Create('DButton', frame)
		\Dock(BOTTOM)
		\DockMargin(5, 2, 5, 2)
		\SetText('gui.misc.cancel')
		.DoClick = -> frame\Close()

	with vgui.Create('DButton', frame)
		\Dock(BOTTOM)
		\DockMargin(5, 2, 5, 2)
		\SetText('gui.misc.apply')
		.DoClick = ->
			if contraption
				for checkbox in *boxes
					RunConsoleCommand('dpp2_' .. (checkbox\GetChecked() and '' or 'un') .. 'share_contraption', contraption.id, checkbox._obj.identifier)
			else
				for checkbox in *boxes
					if checkbox._obj\IsShared(@) ~= checkbox\GetChecked()
						RunConsoleCommand('dpp2_' .. (checkbox\GetChecked() and '' or 'un') .. 'share', @EntIndex(), checkbox._obj.identifier)

			frame\Close()

properties.Add('dpp2_share', {
	MenuLabel: 'gui.dpp2.property.share'
	Order: 1660
	MenuIcon: Menus.Icons.Share

	Filter: (ent = NULL, ply = LocalPlayer()) =>
		@MenuIcon = Menus.Icons.Share
		return false if not ent\IsValid()
		return ent\DPP2GetOwner() == ply

	FilterUnShareAll: (ent = NULL, ply = LocalPlayer()) =>
		return ent\DPP2GetOwner() == ply and ent\DPP2IsShared()

	FilterShareAll: (ent = NULL, ply = LocalPlayer()) =>
		return false if ent\DPP2GetOwner() ~= ply

		for obj in *DPP2.DEF.ProtectionDefinition.OBJECTS
			if not obj\IsShared(ent)
				return true

		return false

	ActionUnShareAll: (ent = NULL) =>
		for obj in *DPP2.DEF.ProtectionDefinition.OBJECTS
			if obj\IsShared(ent)
				RunConsoleCommand('dpp2_unshare', ent\EntIndex(), obj.identifier)

	ActionShareAll: (ent = NULL) =>
		for obj in *DPP2.DEF.ProtectionDefinition.OBJECTS
			if not obj\IsShared(ent)
				RunConsoleCommand('dpp2_share', ent\EntIndex(), obj.identifier)

	Action: (ent = NULL) => Menus.OpenShareMenu(ent)

	MenuOpen: (option, ent, tr) =>
		with menu = option\AddSubMenu()
			menu\AddOption('gui.dpp2.property.share_all', (-> @ActionShareAll(ent)))\SetIcon(Menus.Icons.ShareAll) if @FilterShareAll(ent)
			menu\AddOption('gui.dpp2.property.un_share_all', (-> @ActionUnShareAll(ent)))\SetIcon(Menus.Icons.UnShare) if @FilterUnShareAll(ent)
})

properties.Add('dpp2_sharecontraption', {
	MenuLabel: 'gui.dpp2.property.share_contraption'
	Order: 1661
	MenuIcon: Menus.Icons.ShareContraption

	Filter: (ent = NULL, ply = LocalPlayer()) => IsValid(ent) and ent\DPP2HasContraption() and ent\DPP2GetContraption()\HasOwner(ply)

	FilterShareAll: (contraption, ply = LocalPlayer()) =>
		for ent in *contraption.ents
			if IsValid(ent)
				return true if not ent\DPP2IsShared()

		for ent in *contraption.ents
			if IsValid(ent)
				return true for obj in *DPP2.DEF.ProtectionDefinition.OBJECTS when not obj\IsShared(ent)

		return false

	FilterUnShareAll: (contraption, ply = LocalPlayer()) =>
		for ent in *contraption.ents
			return true if IsValid(ent) and ent\DPP2IsShared()

		return false

	Action: (ent, tr) => Menus.OpenShareMenu(ent, ent\DPP2GetContraption())

	ActionShareAll: (contraption) =>
		for obj in *DPP2.DEF.ProtectionDefinition.OBJECTS
			RunConsoleCommand('dpp2_share_contraption', contraption.id, obj.identifier)

	ActionUnShareAll: (contraption) =>
		for obj in *DPP2.DEF.ProtectionDefinition.OBJECTS
			RunConsoleCommand('dpp2_unshare_contraption', contraption.id, obj.identifier)

	MenuOpen: (option, ent, tr) =>
		contraption = ent\DPP2GetContraption()

		with menu = option\AddSubMenu()
			menu\AddOption('gui.dpp2.property.share_all', (-> @ActionShareAll(contraption)))\SetIcon(Menus.Icons.ShareAllContraption) if @FilterShareAll(contraption)
			menu\AddOption('gui.dpp2.property.un_share_all', (-> @ActionUnShareAll(contraption)))\SetIcon(Menus.Icons.UnShareContraption) if @FilterUnShareAll(contraption)
})
