
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

fixme_init = {
	'/advdupe2/'
	'duplicator.lua'
}

DPP2.FIXME_HookSpawns = DPP2.FIXME_HookSpawns or fixme_init

for init in *fixme_init
	if not table.qhasValue(DPP2.FIXME_HookSpawns, init)
		table.insert(DPP2.FIXME_HookSpawns, init)

log_blacklist = {
	'logic_collision_pair'
	'phys_constraint'
	'phys_hinge'
	'phys_constraintsystem'
	'phys_lengthconstraint'
}

DPP2.PlayerSpawnedSomething = (ply, ent, advancedCheck = false) ->
	return if ent.__dpp2_hit
	ent.__dpp2_hit = true
	ent.__dpp2_dupe_fix = nil

	return false if ent\GetEFlags()\band(EFL_KILLME) ~= 0

	if ply\DPP2IsBanned()
		SafeRemoveEntity(ent)
		return false

	classname = ent\GetClass()

	if not DPP2.SpawnRestrictions\Ask(classname, ply)
		hook.Run('DPP_SpawnRestrictionHit', ply, ent)
		DPP2.NotifyError(ply, 5, 'message.dpp2.restriction.spawn', classname)
		DPP2.LogSpawn('message.dpp2.log.spawn.tried_generic', ply, color_red, DPP2.textcolor, ent)
		SafeRemoveEntity(ent)
		return false

	if DPP2.PerEntityLimits.IS_INCLUSIVE\GetBool()
		check = false

		if entry = DPP2.PerEntityLimits\Get(classname, ply\GetUserGroup())
			check = not entry.limit or entry.limit >= #ply\DPP2GetAllEntsByClass(classname)

		if not check
			hook.Run('DPP_SpawnLimitHit', ply, ent)
			DPP2.NotifyError(ply, 5, 'message.dpp2.limit.spawn', classname)
			DPP2.LogSpawn('message.dpp2.log.spawn.tried_generic', ply, color_red, DPP2.textcolor, ent)
			SafeRemoveEntity(ent)
			return false
	else
		if entry = DPP2.PerEntityLimits\Get(classname, ply\GetUserGroup())
			if entry.limit and entry.limit <= #ply\DPP2GetAllEntsByClass(classname)
				hook.Run('DPP_SpawnLimitHit', ply, ent)
				DPP2.NotifyError(ply, 5, 'message.dpp2.limit.spawn', classname)
				DPP2.LogSpawn('message.dpp2.log.spawn.tried_generic', ply, color_red, DPP2.textcolor, ent)
				SafeRemoveEntity(ent)
				return false

	fixme = false

	i = 1
	info = debug.getinfo(i)
	while info
		for fix in *DPP2.FIXME_HookSpawns
			if string.find(info.src or info.short_src, fix)
				fixme = true
				break

		i += 1
		info = debug.getinfo(i)

	if not fixme
		return if not advancedCheck and not DPP2.QueueAntispam(ply, ent)
		if not advancedCheck and DPP2.ENABLE_ANTISPAM\GetBool() and DPP2.ANTISPAM_COLLISIONS\GetBool() and ent\GetSolid() ~= SOLID_NONE
			-- TODO: Point position calculation near plane, for accurate results
			-- using OBBMins and OBBMaxs

			timer.Simple 0, ->
				return if not IsValid(ply) or not IsValid(ent)
				mins, maxs = ent\WorldSpaceAABB()
				if mins and maxs and mins ~= vector_origin and maxs ~= vector_origin
					for ent2 in *ents.FindInBox(mins, maxs)
						if ent2 ~= ent and not ent2\IsPlayer() and not ent2\IsNPC() and (not ent2\IsWeapon() or not ent2\GetOwner()\IsValid()) and ent2\GetSolid() ~= SOLID_NONE
							ent\DPP2Ghost()
							DPP2.NotifyHint(ply, 5, 'message.dpp2.warn.collisions')
							break
	else
		return if not DPP2.AntispamCheck(ply, true, ent, nil, true)
		ent.__dpp2_dupe_fix = engine.TickCount() + 5

	if DPP2.ENABLE_ANTIPROPKILL\GetBool() and DPP2.ANTIPROPKILL_TRAP\GetBool() and ent\GetSolid() ~= SOLID_NONE
		timer.Simple 0, -> DPP2.APKTriggerPhysgunDrop(ply, ent) if IsValid(ply) and IsValid(ent)

	ent\DPP2SetOwner(ply)

	eclass = ent\GetClass()

	if DPP2.NO_ROPE_WORLD\GetBool() and eclass == 'keyframe_rope'
		start, endpoint = ent\GetInternalVariable('m_hStartPoint'), ent\GetInternalVariable('m_hEndPoint')

		if start == endpoint and not IsValid(start)
			ent\Remove()
			DPP2.LogSpawn('message.dpp2.log.spawn.tried_plain', ply, color_red, DPP2.textcolor, 'keyframe_rope')
			return false

	if not eclass or not table.qhasValue(log_blacklist, eclass)
		if not eclass or not eclass\startsWith('prop_')
			DPP2.LogSpawn('message.dpp2.log.spawn.generic', ply, ent)
		else
			DPP2.LogSpawn('message.dpp2.log.spawn.prop', ply, ent, ent\GetModel() or '<unknown>')

	hook.Run('DPP_PlayerSpawn', ply, ent)
	return true

PreventModelSpawn = (ply, model = ent and ent\GetModel() or 'wtf', ent = NULL, nonotify = false) ->
	if ply\DPP2IsBanned()
		value = ply\DPP2BanTimeLeft()

		if value == math.huge
			DPP2.NotifyError(ply, nil, 'message.dpp2.spawn.banned')
		else
			DPP2.NotifyError(ply, nil, 'message.dpp2.spawn.banned_for', DLib.I18n.FormatTimeForPlayer(ply, value\ceil()))

		SafeRemoveEntity(ent)
		return false

	model = model\lower()

	if DPP2.IsModelBlacklisted(IsValid(ent) and ent or model, ply)
		DPP2.NotifyError(ply, nil, 'message.dpp2.blacklist.model_blocked', model) if not nonotify
		SafeRemoveEntity(ent)
		return false

	if DPP2.IsModelRestricted(IsValid(ent) and ent or model, ply)
		DPP2.NotifyError(ply, nil, 'message.dpp2.blacklist.model_restricted', model) if not nonotify
		SafeRemoveEntity(ent)
		return false

	if DPP2.PerModelLimits.IS_INCLUSIVE\GetBool()
		check = false

		if entry = DPP2.PerModelLimits\Get(model, ply\GetUserGroup())
			if entry.limit
				count = 0

				for ent2 in *ply\DPP2GetAllEnts()
						if ent2\GetModel() == model
							count += 1
							break if entry.limit < count

				check = entry.limit >= count

		if not check
			hook.Run('DPP_ModelLimitHit', ply, model, ent)
			DPP2.NotifyError(ply, 5, 'message.dpp2.limit.spawn', model) if not nonotify
			DPP2.LogSpawn('message.dpp2.log.spawn.tried_generic', ply, color_red, DPP2.textcolor, ent) if IsValid(ent)
			SafeRemoveEntity(ent)
			return false
	else
		if entry = DPP2.PerModelLimits\Get(model, ply\GetUserGroup())
			if entry.limit
				count = 0
				for ent2 in *ply\DPP2GetAllEnts()
					if ent2\GetModel() == model
						count += 1
						break if entry.limit < count

				if entry.limit < count
					hook.Run('DPP_ModelLimitHit', ply, model, ent)
					DPP2.NotifyError(ply, 5, 'message.dpp2.limit.spawn', model) if not nonotify
					DPP2.LogSpawn('message.dpp2.log.spawn.tried_generic', ply, color_red, DPP2.textcolor, ent) if IsValid(ent)
					SafeRemoveEntity(ent)
					return false

	if DPP2.ENABLE_ANTISPAM\GetBool() and IsValid(ent)
		hit = false

		if DPP2.AUTO_BLACKLIST_BY_SIZE\GetBool()
			volume1 = DPP2.AUTO_BLACKLIST_SIZE\GetFloat()
			volume2 = 0
			phys = ent\GetPhysicsObject()
			volume2 = phys\GetVolume() if IsValid(phys)

			if volume1 <= volume2 and not DPP2.ModelBlacklist\Has(model)
				DPP2.ModelBlacklist\Add(model)
				DPP2.Notify(true, nil, 'message.dpp2.autoblacklist.added_volume', model)
				hit = true

				if not DPP2.ModelBlacklist\Ask(model, ply)
					DPP2.NotifyError(ply, nil, 'message.dpp2.blacklist.model_blocked', model) if not nonotify
					SafeRemoveEntity(ent)
					return false

		if DPP2.AUTO_BLACKLIST_BY_AABB\GetBool() and not hit
			volume1 = DPP2.AUTO_BLACKLIST_AABB_SIZE\GetFloat()
			volume2 = DPP2._ComputeVolume2(ent)

			if volume1 <= volume2 and not DPP2.ModelBlacklist\Has(model)
				DPP2.ModelBlacklist\Add(model)
				DPP2.Notify(true, nil, 'message.dpp2.autoblacklist.added_aabb', model)

				if not DPP2.ModelBlacklist\Ask(model, ply)
					DPP2.NotifyError(ply, nil, 'message.dpp2.blacklist.model_blocked', model) if not nonotify
					SafeRemoveEntity(ent)
					return false

	return true

PlayerSpawnedEffect = (ply = NULL, model = 'models/error.mdl', ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	DPP2.PlayerSpawnedSomething(ply, ent)
	return false if not PreventModelSpawn(ply, model, ent)

PlayerSpawnedProp = (ply = NULL, model = 'models/error.mdl', ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	return false if not PreventModelSpawn(ply, model, ent)
	DPP2.PlayerSpawnedSomething(ply, ent)
	return

PlayerSpawnedRagdoll = (ply = NULL, model = 'models/error.mdl', ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	return false if not PreventModelSpawn(ply, model, ent)
	DPP2.PlayerSpawnedSomething(ply, ent)
	return

PlayerSpawnedNPC = (ply = NULL, ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	return false if not PreventModelSpawn(ply, model, ent)
	DPP2.PlayerSpawnedSomething(ply, ent)
	return

PlayerSpawnedSENT = (ply = NULL, ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	return false if not PreventModelSpawn(ply, model, ent)
	DPP2.PlayerSpawnedSomething(ply, ent)
	return

PlayerSpawnedSWEP = (ply = NULL, ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	return false if not PreventModelSpawn(ply, model, ent)
	DPP2.PlayerSpawnedSomething(ply, ent)
	return

PlayerSpawnedVehicle = (ply = NULL, ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	return false if not PreventModelSpawn(ply, model, ent)
	DPP2.PlayerSpawnedSomething(ply, ent)
	return

PlayerSpawnEffect = (ply = NULL, model = 'models/error.mdl') ->
	return unless ply\IsValid()
	return false if not PreventModelSpawn(ply, model)
	return false if not DPP2.AntispamCheck(ply)

	if not DPP2.SpawnRestrictions\Ask('prop_effect', ply)
		DPP2.LogSpawn('message.dpp2.log.spawn.tried_plain', ply, color_red, DPP2.textcolor, 'prop_effect')
		return false

PlayerSpawnProp = (ply = NULL, model = 'models/error.mdl') ->
	return unless ply\IsValid()
	return false if not PreventModelSpawn(ply, model)
	return false if not DPP2.AntispamCheck(ply)

	if not DPP2.SpawnRestrictions\Ask('prop_physics', ply)
		DPP2.LogSpawn('message.dpp2.log.spawn.tried_plain', ply, color_red, DPP2.textcolor, 'prop_physics')
		return false

PlayerSpawnRagdoll = (ply = NULL, model = 'models/error.mdl') ->
	return unless ply\IsValid()
	return false if not PreventModelSpawn(ply, model)
	return false if not DPP2.AntispamCheck(ply)

	if not DPP2.SpawnRestrictions\Ask('prop_ragdoll', ply)
		DPP2.LogSpawn('message.dpp2.log.spawn.tried_plain', ply, color_red, DPP2.textcolor, 'prop_ragdoll')
		return false

PlayerSpawnObject = (ply = NULL, model = 'models/error.mdl', skin = 0) ->
	return unless ply\IsValid()
	return false if not PreventModelSpawn(ply, model)
	return false if not DPP2.AntispamCheck(ply)

PlayerSpawnVehicle = (ply = NULL, model = 'models/error.mdl', name = 'prop_vehicle_jeep', info = {}) ->
	return unless ply\IsValid()
	return false if not PreventModelSpawn(ply, model)
	return false if not DPP2.AntispamCheck(ply)

	if not DPP2.SpawnRestrictions\Ask(name, ply)
		DPP2.LogSpawn('message.dpp2.log.spawn.tried_plain', ply, color_red, DPP2.textcolor, name)
		return false

PlayerSpawnNPC = (ply = NULL, npcclassname = 'base_entity', weaponclass = 'base_entity') ->
	return unless ply\IsValid()
	return false if not DPP2.AntispamCheck(ply)

	if not DPP2.SpawnRestrictions\Ask(npcclassname, ply)
		DPP2.LogSpawn('message.dpp2.log.spawn.tried_plain', ply, color_red, DPP2.textcolor, npcclassname)
		return false

PlayerSpawnSENT = (ply = NULL, classname = 'base_entity') ->
	return unless ply\IsValid()
	return false if not DPP2.AntispamCheck(ply)

	if not DPP2.SpawnRestrictions\Ask(classname, ply)
		DPP2.LogSpawn('message.dpp2.log.spawn.tried_plain', ply, color_red, DPP2.textcolor, classname)
		return false

PlayerGiveSWEP = (ply = NULL, classname = 'base_entity', definition = {ClassName: 'base_entity', WorldModel: 'models/error.mdl', ViewModel: 'models/error.mdl'}) ->
	return unless ply\IsValid()
	return false if not PreventModelSpawn(ply, definition.WorldModel)
	return false if not DPP2.AntispamCheck(ply)

	if not DPP2.SpawnRestrictions\Ask(classname, ply)
		DPP2.LogSpawn('message.dpp2.log.spawn.tried_plain', ply, color_red, DPP2.textcolor, classname)
		return false

	if not IsValid(ply\GetWeapon(classname))
		timer.Simple 0, ->
			return if not IsValid(ply)
			wep = ply\GetWeapon(classname)

			if IsValid(wep)
				if DPP2.PlayerSpawnedSomething(ply, wep)
					DPP2.LogSpawn('message.dpp2.log.spawn.giveswep_valid', ply, wep)
			else
				DPP2.LogSpawn('message.dpp2.log.spawn.giveswep', ply, color_white, classname)

	return

PlayerSpawnSWEP = (ply = NULL, classname = 'base_entity', definition = {ClassName: 'base_entity', WorldModel: 'models/error.mdl', ViewModel: 'models/error.mdl'}) ->
	return unless ply\IsValid()
	return false if not PreventModelSpawn(ply, definition.WorldModel)
	return false if not DPP2.AntispamCheck(ply)
	if not DPP2.SpawnRestrictions\Ask(classname, ply)
		DPP2.LogSpawn('message.dpp2.log.spawn.tried_plain', ply, color_red, DPP2.textcolor, classname)
		return false

PlayerCanPickupItem = (ply = NULL, ent = NULL) ->
	return if not IsValid(ply) or not IsValid(ent)
	return false if not DPP2.PickupProtection.Blacklist\Ask(ent\GetClass(), ply)
	return false if not DPP2.PickupProtection.RestrictionList\Ask(ent\GetClass(), ply)

hooksToReg = {
	:PlayerSpawnedEffect, :PlayerSpawnedProp, :PlayerSpawnedRagdoll
	:PlayerSpawnedNPC, :PlayerSpawnedSENT, :PlayerSpawnedSWEP
	:PlayerSpawnedVehicle, :PlayerSpawnEffect, :PlayerSpawnProp
	:PlayerSpawnRagdoll, :PlayerSpawnObject, :PlayerSpawnVehicle
	:PlayerSpawnNPC, :PlayerSpawnSENT, :PlayerGiveSWEP, :PlayerSpawnSWEP
	:PlayerCanPickupItem, PlayerCanPickupWeapon: PlayerCanPickupItem
}

hook.Add(name, 'DPP2.SpawnHooks', func, -4) for name, func in pairs(hooksToReg)

import CurTimeL, table, type from _G

CheckEntities = {}
DPP2._Spawn_CheckFrame = 0

DPP2.HookedEntityCreation = => table.qhasValue(CheckEntities, @) or @__dpp2_spawn_frame == CurTimeL()

local DiveTableCheck
local DiveEntityCheck

DiveTableCheck = (tab, owner, checkedEnts, checkedTables, found) =>
	return if checkedTables[tab]
	checkedTables[tab] = true

	for key, value in pairs(tab)
		vtype = type(value)

		if vtype == 'table' and (type(key) ~= 'string' or not key\startsWith('__dpp2'))
			DiveTableCheck(@, value, owner, checkedEnts, checkedTables, found)
		elseif vtype == 'Entity' or vtype == 'NPC' or vtype == 'NextBot' or vtype == 'Vehicle' or vtype == 'Weapon'
			DiveEntityCheck(value, owner, checkedEnts, checkedTables, found)

DiveEntityCheck = (owner, checkedEnts, checkedTables, found) =>
	return found if checkedEnts[@]
	return found if @__dpp2_check_frame == CurTimeL()
	return found if not @GetTable()
	checkedEnts[@] = true
	@__dpp2_check_frame = CurTimeL()
	table.insert(found, @) if @DPP2GetOwner() ~= owner and @__dpp2_spawn_frame == CurTimeL()
	DiveTableCheck(@, @GetTable(), owner, checkedEnts, checkedTables, found)
	DiveTableCheck(@, @GetSaveTable(), owner, checkedEnts, checkedTables, found)
	return found

hook.Add 'Think', 'DPP2.CheckEntitiesOwnage', ->
	return if DPP2._Spawn_CheckFrame >= CurTimeL()
	return if #CheckEntities == 0
	copy = CheckEntities
	checkConstraints = {}
	CheckEntities = {}
	ctime = CurTimeL()

	for ent in *copy
		if ent\IsValid()
			ent.__dpp2_spawn_frame = ctime

	while #copy ~= 0
		ent = table.remove(copy, 1)

		if ent\IsValid()
			if ent\IsConstraint()
				table.insert(checkConstraints, ent)
			elseif ent\DPP2OwnerIsValid()
				ply = ent\DPP2GetOwner()
				found = DiveEntityCheck(ent, ply, {}, {}, {})

				if #found ~= 0
					DPP2.UnqueueAntispam(ent)
					local toremove

					for ent2 in *found
						DPP2.UnqueueAntispam(ent2)
						DPP2.PlayerSpawnedSomething(ply, ent2, true)

						for i, ent3 in ipairs(copy)
							if ent2 == ent3
								toremove = toremove or {}
								table.insert(toremove, i)
								break

					table.removeValues(copy, toremove) if toremove
					fail = not PreventModelSpawn(ply, nil, ent, true)

					if not fail
						for ent2 in *found
							fail = not PreventModelSpawn(ply, nil, ent2, true)
							break if fail

					if not fail
						should_queue = not ent.__dpp2_dupe_fix or engine.TickCount() >= ent.__dpp2_dupe_fix

						if should_queue
							for ent2 in *found
								if ent.__dpp2_dupe_fix and engine.TickCount() < ent.__dpp2_dupe_fix
									should_queue = false
									break

						DPP2.QueueAntispam(ply, ent, found) if should_queue
					else
						SafeRemoveEntity(ent)
						SafeRemoveEntity(ent2) for ent2 in *found
						DPP2.NotifyError(ply, nil, 'message.dpp2.blacklist.models_blocked', #found + 1)

	for constraint in *checkConstraints
		ent1, ent2 = constraint\GetConstrainedEntities()

		if IsValid(ent1) and IsValid(ent2)
			if ctime == ent1.__dpp2_spawn_frame and ctime == ent2.__dpp2_spawn_frame
				if ent1\DPP2IsOwned() and ent1\DPP2OwnerIsValid()
					DPP2.PlayerSpawnedSomething(ent1\DPP2GetOwner(), constraint, true)
				elseif ent2\DPP2IsOwned() and ent2\DPP2OwnerIsValid()
					DPP2.PlayerSpawnedSomething(ent2\DPP2GetOwner(), constraint, true)
		else
			DPP2.LMessageError('message.dpp2.error.empty_constraint', ' ', constraint, ' ', ent1, ' ', ent2)

hook.Add 'OnEntityCreated', 'DPP2.CheckEntitiesOwnage', =>
	DPP2._Spawn_CheckFrame = CurTimeL()
	table.insert(CheckEntities, @)
	return

hook.Add 'OnEntityCopyTableFinish', 'DPP2.ClearFields', (data) =>
	data.__dpp2_check_frame = nil
	data.__dpp2_hit = nil
	data.__dpp2_spawn_frame = nil
	data.__dpp2_contraption = nil
	data._dpp2_last_nick = nil
	data.__dpp2_pushing = nil
	data.__dpp2_unfreeze = nil
	data.__dpp2_old_collisions_group = nil
	data.__dpp2_old_movetype = nil
	data.__dpp2_old_color = nil
	data.__dpp2_ghost_callbacks = nil
	data.__dpp2_old_rendermode = nil
