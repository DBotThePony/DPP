
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

properties.Add('dpp2_copymodel', {
	MenuLabel: 'gui.dpp2.property.copymodel'
	Order: 1650
	MenuIcon: Menus.Icons.Copy

	Filter: (ent = NULL, ply = LocalPlayer()) =>
		@MenuIcon = Menus.Icons.Copy
		return if not ent\IsValid()
		return if not ent\GetModel() or ent\GetModel()\trim() == ''
		return true

	Action: (ent = NULL) =>
		SetClipboardText(ent\GetModel())
})

properties.Add('dpp2_copyclassname', {
	MenuLabel: 'gui.dpp2.property.copyclassname'
	Order: 1651
	MenuIcon: Menus.Icons.Copy

	Filter: (ent = NULL, ply = LocalPlayer()) =>
		@MenuIcon = Menus.Icons.Copy
		return false if not ent\IsValid()
		return false if not ent\GetClass() or ent\GetClass()\trim() == ''
		return true

	Action: (ent = NULL) =>
		SetClipboardText(ent\GetClass())
})

properties.Add('dpp2_copyangles', {
	MenuLabel: 'gui.dpp2.property.copyangles'
	Order: 1652
	MenuIcon: Menus.Icons.Angle

	Filter: (ent = NULL, ply = LocalPlayer()) =>
		@MenuIcon = Menus.Icons.Angle
		return ent\IsValid()

	Action: (ent = NULL) =>
		ang = ent\GetAngles()
		SetClipboardText(string.format('Angle(%.2f, %.2f, %.2f)', ang.p, ang.y, ang.r))
})

properties.Add('dpp2_copyvector', {
	MenuLabel: 'gui.dpp2.property.copyvector'
	Order: 1653
	MenuIcon: Menus.Icons.Vector

	Filter: (ent = NULL, ply = LocalPlayer()) =>
		return ent\IsValid()

	Action: (ent = NULL) =>
		vec = ent\GetPos()
		SetClipboardText(string.format('Vector(%.2f, %.2f, %.2f)', vec.p, vec.y, vec.r))
})
