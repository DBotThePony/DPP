
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

restrictions = {
	DPP2.PhysgunProtection.RestrictionList
	DPP2.DriveProtection.RestrictionList
	DPP2.PickupProtection.RestrictionList
	DPP2.UseProtection.RestrictionList
	DPP2.VehicleProtection.RestrictionList
	DPP2.GravgunProtection.RestrictionList
	DPP2.ToolgunProtection.RestrictionList
	DPP2.DamageProtection.RestrictionList
	DPP2.SpawnRestrictions
}

blacklists = {
	DPP2.PhysgunProtection.Blacklist
	DPP2.DriveProtection.Blacklist
	DPP2.PickupProtection.Blacklist
	DPP2.UseProtection.Blacklist
	DPP2.VehicleProtection.Blacklist
	DPP2.GravgunProtection.Blacklist
	DPP2.ToolgunProtection.Blacklist
	DPP2.DamageProtection.Blacklist
}

properties.Add('dpp2_copyvector', {
	MenuLabel: 'gui.dpp2.property.restrictions'
	Order: 1680
	MenuIcon: Menus.Icons.Restrict

	Filter: (ent = NULL, ply = LocalPlayer()) =>
		return false if not ent\IsValid()
		classname = ent\GetClass()

		if model = ent\GetModel()
			if DPP2.ModelBlacklist\Has(model)
				return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. DPP2.ModelBlacklist.remove_command_identifier)
			else
				return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. DPP2.ModelBlacklist.add_command_identifier)

		for object in *blacklists
			if object\Has(classname)
				return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.remove_command_identifier)
			else
				return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.add_command_identifier)

		for object in *restrictions
			if object\Has(classname)
				return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.remove_command_identifier)
			else
				return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.add_command_identifier)

		return false

	Action: (ent = NULL) =>

	MenuOpen: (option, ent, tr) =>
		classname = ent\GetClass()

		with menu = option\AddSubMenu()
			if model = ent\GetModel()
				if DPP2.ModelBlacklist\Has(model)
					if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. DPP2.ModelBlacklist.remove_command_identifier)
						submenu, button = \AddSubMenu('gui.dpp2.menu.remove_from_model_blacklist')
						button\SetIcon(Menus.Icons.Remove)
						submenu\AddOption('gui.dpp2.menus.remove2', (-> RunConsoleCommand('dpp2_' .. DPP2.ModelBlacklist.remove_command_identifier, model)))\SetIcon(Menus.Icons.Remove)
				elseif DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. DPP2.ModelBlacklist.add_command_identifier)
					\AddOption('gui.dpp2.menu.add_to_model_blacklist', (-> RunConsoleCommand('dpp2_' .. DPP2.ModelBlacklist.add_command_identifier, model)))\SetIcon(Menus.Icons.AddPlain)

			\AddSpacer()

			for object in *blacklists
				if object\Has(classname)
					if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.remove_command_identifier)
						submenu, button = \AddSubMenu('gui.dpp2.menu.remove_from_' .. object.identifier .. '_blacklist')
						button\SetIcon(Menus.Icons.Remove)
						submenu\AddOption('gui.dpp2.menus.remove2', (-> RunConsoleCommand('dpp2_' .. object.remove_command_identifier, model)))\SetIcon(Menus.Icons.Remove)
				elseif DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.add_command_identifier)
					\AddOption('gui.dpp2.menu.add_to_' .. object.identifier .. '_blacklist', (-> RunConsoleCommand('dpp2_' .. object.add_command_identifier, model)))\SetIcon(Menus.Icons.AddPlain)

			\AddSpacer()

			for object in *restrictions
				if object\Has(classname)
					if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.add_command_identifier)
						\AddOption('gui.dpp2.menu.edit_in_' .. object.identifier .. '_restrictions', (-> object\OpenMenu(classname)))\SetIcon(Menus.Icons.Add)

					if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.remove_command_identifier)
						submenu, button = \AddSubMenu('gui.dpp2.menu.remove_from_' .. object.identifier .. '_restrictions')
						button\SetIcon(Menus.Icons.Remove)
						submenu\AddOption('gui.dpp2.menus.remove2', (-> RunConsoleCommand('dpp2_' .. object.remove_command_identifier, model)))\SetIcon(Menus.Icons.Remove)
				elseif DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.add_command_identifier)
					\AddOption('gui.dpp2.menu.add_to_' .. object.identifier .. '_restrictions', (-> object\OpenMenu(classname)))\SetIcon(Menus.Icons.AddPlain)
})
