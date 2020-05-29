
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

DPP2.CL_ENABLE_PROPERTIES = DPP2.CreateClientConVar('cl_properties', '1', DPP2.TYPE_BOOL)
DPP2.CL_ENABLE_PROPERTIES_REGULAR = DPP2.CreateClientConVar('cl_properties_regular', '1', DPP2.TYPE_BOOL)
DPP2.CL_ENABLE_PROPERTIES_ADMIN = DPP2.CreateClientConVar('cl_properties_admin', '1', DPP2.TYPE_BOOL)
DPP2.CL_ENABLE_PROPERTIES_RESTRICTIONS = DPP2.CreateClientConVar('cl_properties_restrictions', '1', DPP2.TYPE_BOOL)

lockmodes = {
	DPP2.PhysgunProtection
	DPP2.DriveProtection
	DPP2.ToolgunProtection
	DPP2.DamageProtection
	DPP2.PickupProtection
	DPP2.UseProtection
	DPP2.VehicleProtection
	DPP2.GravgunProtection
}

properties.Add('dpp2_lock_self', {
	MenuLabel: 'gui.dpp2.property.lock_self.top'
	Order: 401
	MenuIcon: Menus.Icons.LockTool

	Filter: (ent = NULL, ply = LocalPlayer()) =>
		return false if not DPP2.CL_ENABLE_PROPERTIES\GetBool()
		return false if not DPP2.CL_ENABLE_PROPERTIES_REGULAR\GetBool()
		@MenuIcon = Menus.Icons.LockTool
		return false if not ent\IsValid()
		-- return false if hook.Run('CanProperty', ply, 'dpp2_lock_self', ent) == false
		return false if ent\IsNPC() or ent\IsPlayer() or type(ent) == 'NextBot'

		for object in *lockmodes
			if not object\IsLockedSelf(ply, ent) and DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.lock_self_name)
				return true

		return false

	MenuOpen: (option, ent = NULL, tr, ply = LocalPlayer()) =>
		with menu = option\AddSubMenu()
			for object in *lockmodes
				if not object\IsLockedSelf(ply, ent) and DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.lock_self_name)
					menu\AddOption('gui.dpp2.property.lock_self.' .. object.identifier, -> RunConsoleCommand('dpp2_' .. object.lock_self_name, ent\EntIndex()))\SetIcon(Menus.Icons.LockTool)

	Action: (ent = NULL, tr, ply = LocalPlayer()) =>
		for object in *lockmodes
			if not object\IsLockedSelf(ply, ent) and DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.lock_self_name)
				RunConsoleCommand('dpp2_' .. object.lock_self_name, ent\EntIndex())
})

properties.Add('dpp2_unlock_self', {
	MenuLabel: 'gui.dpp2.property.unlock_self.top'
	Order: 402
	MenuIcon: Menus.Icons.UnLockTool

	Filter: (ent = NULL, ply = LocalPlayer()) =>
		return false if not DPP2.CL_ENABLE_PROPERTIES\GetBool()
		return false if not DPP2.CL_ENABLE_PROPERTIES_REGULAR\GetBool()
		@MenuIcon = Menus.Icons.UnLockTool
		return false if not ent\IsValid()
		-- return false if hook.Run('CanProperty', ply, 'dpp2_unlock_self', ent) == false
		return false if ent\IsNPC() or ent\IsPlayer() or type(ent) == 'NextBot'

		for object in *lockmodes
			if object\IsLockedSelf(ply, ent)
				return true

		return false

	MenuOpen: (option, ent = NULL, tr, ply = LocalPlayer()) =>
		with menu = option\AddSubMenu()
			for object in *lockmodes
				if object\IsLockedSelf(ply, ent)
					menu\AddOption('gui.dpp2.property.unlock_self.' .. object.identifier, -> RunConsoleCommand('dpp2_' .. object.unlock_self_name, ent\EntIndex()))\SetIcon(Menus.Icons.UnLockTool)

	Action: (ent = NULL, tr, ply = LocalPlayer()) =>
		for object in *lockmodes
			if object\IsLockedSelf(ply, ent)
				RunConsoleCommand('dpp2_' .. object.unlock_self_name, ent\EntIndex())
})

properties.Add('dpp2_lock_others', {
	MenuLabel: 'gui.dpp2.property.lock_others.top'
	Order: 403
	MenuIcon: Menus.Icons.LockTool

	Filter: (ent = NULL, ply = LocalPlayer()) =>
		return false if not DPP2.CL_ENABLE_PROPERTIES\GetBool()
		return false if not DPP2.CL_ENABLE_PROPERTIES_REGULAR\GetBool()
		@MenuIcon = Menus.Icons.LockTool
		return false if not ent\IsValid() or ent\DPP2GetOwner() ~= ply
		-- return false if hook.Run('CanProperty', ply, 'dpp2_lock_others', ent) == false
		return false if ent\IsNPC() or ent\IsPlayer() or type(ent) == 'NextBot'

		for object in *lockmodes
			if not object\IsLockedOthers(ent) and DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.lock_others_name)
				return true

		return false

	MenuOpen: (option, ent = NULL, tr, ply = LocalPlayer()) =>
		with menu = option\AddSubMenu()
			for object in *lockmodes
				if not object\IsLockedOthers(ent) and DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.lock_others_name)
					menu\AddOption('gui.dpp2.property.lock_others.' .. object.identifier, -> RunConsoleCommand('dpp2_' .. object.lock_others_name, ent\EntIndex()))\SetIcon(Menus.Icons.LockTool)

	Action: (ent = NULL, tr, ply = LocalPlayer()) =>
		for object in *lockmodes
			if not object\IsLockedOthers(ent) and DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.lock_others_name)
				RunConsoleCommand('dpp2_' .. object.lock_others_name, ent\EntIndex())
})

properties.Add('dpp2_unlock_others', {
	MenuLabel: 'gui.dpp2.property.unlock_others.top'
	Order: 404
	MenuIcon: Menus.Icons.LockTool

	Filter: (ent = NULL, ply = LocalPlayer()) =>
		return false if not DPP2.CL_ENABLE_PROPERTIES\GetBool()
		return false if not DPP2.CL_ENABLE_PROPERTIES_REGULAR\GetBool()
		@MenuIcon = Menus.Icons.LockTool
		return false if not ent\IsValid() or ent\DPP2GetOwner() ~= ply
		-- return false if hook.Run('CanProperty', ply, 'dpp2_unlock_others', ent) == false
		return false if ent\IsNPC() or ent\IsPlayer() or type(ent) == 'NextBot'

		for object in *lockmodes
			if object\IsLockedOthers(ent)
				return true

		return false

	MenuOpen: (option, ent = NULL, tr, ply = LocalPlayer()) =>
		with menu = option\AddSubMenu()
			for object in *lockmodes
				if object\IsLockedOthers(ent)
					menu\AddOption('gui.dpp2.property.unlock_others.' .. object.identifier, -> RunConsoleCommand('dpp2_' .. object.unlock_others_name, ent\EntIndex()))\SetIcon(Menus.Icons.LockTool)

	Action: (ent = NULL, tr, ply = LocalPlayer()) =>
		for object in *lockmodes
			if object\IsLockedOthers(ent)
				RunConsoleCommand('dpp2_' .. object.unlock_others_name, ent\EntIndex())
})

do
	SENT = '0'
	VEHICLE = '1'
	NPC = '2'
	WEAPON = '3'
	PROP = '4'

	properties.Add('dpp2_arm_creator', {
		MenuLabel: 'gui.dpp2.property.arm_creator'
		Order: 878
		MenuIcon: Menus.Icons.Wrench2
		CreatorType: 0
		-- CreatorArg: 'none'
		CreatorName: ''

		Filter: (ent = NULL, ply = LocalPlayer()) =>
			return false if not DPP2.CL_ENABLE_PROPERTIES\GetBool()
			return false if not DPP2.CL_ENABLE_PROPERTIES_REGULAR\GetBool()
			@MenuIcon = Menus.Icons.Wrench2
			return false if not ent\IsValid()
			return false if not IsValid(ply\GetWeapon('gmod_tool'))
			-- return false if hook.Run('CanProperty', ply, 'dpp2_arm_creator', ent) == false
			return false if ent\IsPlayer() or ent\GetClass()\startsWith('prop_door') or ent\GetClass()\startsWith('func_') or ent\GetClass()\startsWith('prop_dynamic')

			gtype = type(ent)

			if gtype == 'Weapon'
				@CreatorName = ent\GetClass()
				@CreatorArg = nil
				@CreatorType = WEAPON
			elseif gtype == 'NPC'
				@CreatorName = ent\GetClass()
				@CreatorArg = IsValid(ent\GetActiveWeapon()) and ent\GetActiveWeapon()\GetClass() or 'none'
				@CreatorType = NPC
			elseif gtype == 'Vehicle'
				@CreatorArg = nil
				@CreatorType = VEHICLE
				@CreatorName = ent.VehicleName or ent\GetPrintNameDLib() or 'Jeep'
			elseif gtype == 'Entity'
				gclass = ent\GetClass()

				if gclass == 'prop_physics'
					@CreatorArg = nil
					@CreatorType = PROP
					@CreatorName = ent\GetModel()
				elseif gclass == 'prop_effect'
					@CreatorArg = nil
					@CreatorType = PROP
					@CreatorName = ent\GetChildren()[1] and ent\GetChildren()[1]\GetModel() or ent\GetModel() -- ???
				else
					@CreatorArg = nil
					@CreatorType = SENT
					@CreatorName = ent\GetClass()

			return true

		Action: (ent = NULL, tr, ply = LocalPlayer()) =>
			RunConsoleCommand('creator_type', @CreatorType)
			RunConsoleCommand('creator_arg', @CreatorArg) if @CreatorArg
			RunConsoleCommand('creator_name', @CreatorName)
			input.SelectWeapon(ply\GetWeapon('gmod_tool'))
	})

properties.Add('dpp2_copymodel', {
	MenuLabel: 'gui.dpp2.property.copymodel'
	Order: 1650
	MenuIcon: Menus.Icons.Copy

	Filter: (ent = NULL, ply = LocalPlayer()) =>
		return false if not DPP2.CL_ENABLE_PROPERTIES\GetBool()
		return false if not DPP2.CL_ENABLE_PROPERTIES_REGULAR\GetBool()
		@MenuIcon = Menus.Icons.Copy
		return false if not ent\IsValid()
		return false if not ent\GetModel() or ent\GetModel()\trim() == ''
		return true

	Action: (ent = NULL) =>
		SetClipboardText(ent\GetModel())
})

properties.Add('dpp2_copyclassname', {
	MenuLabel: 'gui.dpp2.property.copyclassname'
	Order: 1651
	MenuIcon: Menus.Icons.Copy

	Filter: (ent = NULL, ply = LocalPlayer()) =>
		return false if not DPP2.CL_ENABLE_PROPERTIES\GetBool()
		return false if not DPP2.CL_ENABLE_PROPERTIES_REGULAR\GetBool()
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
		return false if not DPP2.CL_ENABLE_PROPERTIES\GetBool()
		return false if not DPP2.CL_ENABLE_PROPERTIES_REGULAR\GetBool()
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
		return false if not DPP2.CL_ENABLE_PROPERTIES\GetBool()
		return false if not DPP2.CL_ENABLE_PROPERTIES_REGULAR\GetBool()
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
	'a'
	DPP2.PhysgunProtection.Exclusions
	DPP2.DriveProtection.Exclusions
	DPP2.PickupProtection.Exclusions
	DPP2.UseProtection.Exclusions
	DPP2.VehicleProtection.Exclusions
	DPP2.GravgunProtection.Exclusions
	DPP2.ToolgunProtection.Exclusions
	DPP2.DamageProtection.Exclusions
}

modelstuff = {
	DPP2.ModelBlacklist
	DPP2.ModelExclusions
	DPP2.ModelRestrictions
	DPP2.PerModelLimits
}

properties.Add('dpp2_copyvector', {
	MenuLabel: 'gui.dpp2.property.restrictions'
	Order: 1680
	MenuIcon: Menus.Icons.Restrict

	Filter: (ent = NULL, ply = LocalPlayer()) =>
		return false if not DPP2.CL_ENABLE_PROPERTIES\GetBool()
		return false if not DPP2.CL_ENABLE_PROPERTIES_RESTRICTIONS\GetBool()
		return false if not ent\IsValid()
		classname = ent\GetClass()

		if model = ent\GetModel()
			for object in *modelstuff
				if object\Has(model)
					return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.remove_command_identifier)
				else
					return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.add_command_identifier)

		for object in *blacklists
			if not isstring(object)
				if object\Has(classname)
					return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.remove_command_identifier)
				else
					return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.add_command_identifier)

		for object in *restrictions
			if object\Has(classname)
				return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.remove_command_identifier)
			else
				return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.add_command_identifier)

		do
			object = DPP2.PerEntityLimits
			if object\Has(classname)
				return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.remove_command_identifier)
			else
				return true if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.add_command_identifier)

		return false

	Action: (ent = NULL) =>

	MenuOpen: (option, ent, tr) =>
		classname = ent\GetClass()

		with menu = option\AddSubMenu()
			addrestriction = (object, classname) ->
				if object\Has(classname)
					if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.add_command_identifier)
						\AddOption('gui.dpp2.menu.edit_in_' .. object.identifier .. '_restrictions', (-> object\OpenMenu(classname)))\SetIcon(Menus.Icons.Add)

					if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.remove_command_identifier)
						submenu, button = \AddSubMenu('gui.dpp2.menu.remove_from_' .. object.identifier .. '_restrictions')
						button\SetIcon(Menus.Icons.Remove)
						submenu\AddOption('gui.dpp2.menus.remove2', (-> RunConsoleCommand('dpp2_' .. object.remove_command_identifier, classname)))\SetIcon(Menus.Icons.Remove)
				elseif DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.add_command_identifier)
					\AddOption('gui.dpp2.menu.add_to_' .. object.identifier .. '_restrictions', (-> object\OpenMenu(classname)))\SetIcon(Menus.Icons.Add)

			if model = ent\GetModel()
				if DPP2.ModelBlacklist\Has(model)
					if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. DPP2.ModelBlacklist.remove_command_identifier)
						submenu, button = \AddSubMenu('gui.dpp2.menu.remove_from_model_blacklist')
						button\SetIcon(Menus.Icons.Remove)
						submenu\AddOption('gui.dpp2.menus.remove2', (-> RunConsoleCommand('dpp2_' .. DPP2.ModelBlacklist.remove_command_identifier, model)))\SetIcon(Menus.Icons.Remove)
				elseif DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. DPP2.ModelBlacklist.add_command_identifier)
					\AddOption('gui.dpp2.menu.add_to_model_blacklist', (-> RunConsoleCommand('dpp2_' .. DPP2.ModelBlacklist.add_command_identifier, model)))\SetIcon(Menus.Icons.AddPlain)

				if DPP2.ModelExclusions\Has(model)
					if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. DPP2.ModelExclusions.remove_command_identifier)
						submenu, button = \AddSubMenu('gui.dpp2.menu.remove_from_model_exclist')
						button\SetIcon(Menus.Icons.Remove)
						submenu\AddOption('gui.dpp2.menus.remove2', (-> RunConsoleCommand('dpp2_' .. DPP2.ModelExclusions.remove_command_identifier, model)))\SetIcon(Menus.Icons.Remove)
				elseif DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. DPP2.ModelExclusions.add_command_identifier)
					\AddOption('gui.dpp2.menu.add_to_model_exclist', (-> RunConsoleCommand('dpp2_' .. DPP2.ModelExclusions.add_command_identifier, model)))\SetIcon(Menus.Icons.AddPlain)

				if DPP2.PerModelLimits\Has(model)
					if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. DPP2.PerModelLimits.add_command_identifier)
						edit = -> DPP2.PerModelLimits\OpenMenu(model)
						\AddOption('gui.dpp2.menu.edit_in_' .. DPP2.PerModelLimits.identifier .. '_limits', edit)\SetIcon(Menus.Icons.Edit)

					if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. DPP2.PerModelLimits.remove_command_identifier)
						remove = -> RunConsoleCommand('dpp2_' .. DPP2.PerModelLimits.remove_command_identifier, model, entry.group) for entry in *DPP2.PerModelLimits\GetByClass(model)
						submenu, button = \AddSubMenu('gui.dpp2.menu.remove_from_' .. DPP2.PerModelLimits.identifier .. '_limits')
						button\SetIcon(Menus.Icons.Remove)
						submenu\AddOption('gui.dpp2.menus.remove2', remove)\SetIcon(Menus.Icons.Remove)
				else
					if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. DPP2.PerModelLimits.add_command_identifier)
						add = -> DPP2.PerModelLimits\OpenMenu(model)
						\AddOption('gui.dpp2.menu.add_to_' .. DPP2.PerModelLimits.identifier .. '_limits', add)\SetIcon(Menus.Icons.Add)

				addrestriction(DPP2.ModelRestrictions, model)

			\AddSpacer()

			for object in *blacklists
				if isstring(object)
					\AddSpacer()
				else
					if object\Has(classname)
						if DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.remove_command_identifier)
							submenu, button = \AddSubMenu('gui.dpp2.menu.remove_from_' .. object.identifier .. '_' .. object.__class.REGULAR_NAME)
							button\SetIcon(Menus.Icons.Remove)
							submenu\AddOption('gui.dpp2.menus.remove2', (-> RunConsoleCommand('dpp2_' .. object.remove_command_identifier, classname)))\SetIcon(Menus.Icons.Remove)
					elseif DPP2.cmd_perm_watchdog\HasPermission('dpp2_' .. object.add_command_identifier)
						\AddOption('gui.dpp2.menu.add_to_' .. object.identifier .. '_' .. object.__class.REGULAR_NAME, (-> RunConsoleCommand('dpp2_' .. object.add_command_identifier, model)))\SetIcon(Menus.Icons.AddPlain)

			\AddSpacer()

			for object in *restrictions
				addrestriction(object, classname)
})
