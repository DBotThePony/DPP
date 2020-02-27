
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

	return false if ent\GetEFlags()\band(EFL_KILLME) ~= 0

	if not DPP2.SpawnRestrictions\Ask(ent\GetClass(), ply)
		hook.Run('DPP_SpawnRestrictionHit', ply, ent)
		DPP2.NotifyError(ply, 5, 'message.dpp2.restriction.spawn', ent\GetClass())
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

	if DPP2.ENABLE_ANTIPROPKILL\GetBool() and DPP2.ANTIPROPKILL_TRAP\GetBool() and ent\GetSolid() ~= SOLID_NONE
		timer.Simple 0, -> DPP2.APKTriggerPhysgunDrop(ply, ent) if IsValid(ply) and IsValid(ent)

	ent\DPP2SetOwner(ply)

	eclass = ent\GetClass()

	if not eclass or not table.qhasValue(log_blacklist, eclass)
		if not eclass or not eclass\startsWith('prop_')
			DPP2.LogSpawn('message.dpp2.log.spawn.generic', ply, ent)
		else
			DPP2.LogSpawn('message.dpp2.log.spawn.prop', ply, ent, ent\GetModel() or '<unknown>')

	hook.Run('DPP_PlayerSpawn', ply, ent)
	return true

PreventModelSpawn = (ply, model = ent and ent\GetModel() or 'wtf', ent, nonotify) ->
	if DPP2.ModelBlacklist\Has(model\lower())
		DPP2.NotifyError(ply, nil, 'message.dpp2.blacklist.model_blocked', model) if not nonotify
		SafeRemoveEntity(ent) if IsValid(ent)
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

PlayerSpawnedRagdoll = (ply = NULL, model = 'models/error.mdl', ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	return false if not PreventModelSpawn(ply, model, ent)
	DPP2.PlayerSpawnedSomething(ply, ent)

PlayerSpawnedNPC = (ply = NULL, ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	return false if not PreventModelSpawn(ply, model, ent)
	DPP2.PlayerSpawnedSomething(ply, ent)

PlayerSpawnedSENT = (ply = NULL, ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	-- return false if not PreventModelSpawn(ply, model, ent)
	DPP2.PlayerSpawnedSomething(ply, ent)

PlayerSpawnedSWEP = (ply = NULL, ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	return false if not PreventModelSpawn(ply, model, ent)
	DPP2.PlayerSpawnedSomething(ply, ent)

PlayerSpawnedVehicle = (ply = NULL, ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	return false if not PreventModelSpawn(ply, model, ent)
	DPP2.PlayerSpawnedSomething(ply, ent)

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

PlayerSpawnSWEP = (ply = NULL, classname = 'base_entity', definition = {ClassName: 'base_entity', WorldModel: 'models/error.mdl', ViewModel: 'models/error.mdl'}) ->
	return unless ply\IsValid()
	return false if not PreventModelSpawn(ply, definition.WorldModel)
	return false if not DPP2.AntispamCheck(ply)
	if not DPP2.SpawnRestrictions\Ask(classname, ply)
		DPP2.LogSpawn('message.dpp2.log.spawn.tried_plain', ply, color_red, DPP2.textcolor, classname)
		return false

hooksToReg = {
	:PlayerSpawnedEffect, :PlayerSpawnedProp, :PlayerSpawnedRagdoll
	:PlayerSpawnedNPC, :PlayerSpawnedSENT, :PlayerSpawnedSWEP
	:PlayerSpawnedVehicle, :PlayerSpawnEffect, :PlayerSpawnProp
	:PlayerSpawnRagdoll, :PlayerSpawnObject, :PlayerSpawnVehicle
	:PlayerSpawnNPC, :PlayerSpawnSENT, :PlayerGiveSWEP, :PlayerSpawnSWEP
}

hook.Add(name, 'DPP2.SpawnHooks', func, -4) for name, func in pairs(hooksToReg)

import CurTimeL, table, type from _G

CheckEntities = {}
CheckFrame = 0

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
	return if CheckFrame >= CurTimeL()
	return if #CheckEntities == 0
	copy = CheckEntities
	CheckEntities = {}

	for ent in *copy
		if ent\IsValid()
			ent.__dpp2_spawn_frame = CurTimeL()

	while #copy ~= 0
		ent = table.remove(copy, 1)

		if ent\IsValid() and ent\DPP2OwnerIsValid()
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
					DPP2.QueueAntispam(ply, ent, found)
				else
					SafeRemoveEntity(ent)
					SafeRemoveEntity(ent2) for ent2 in *found
					DPP2.NotifyError(ply, nil, 'message.dpp2.blacklist.models_blocked', #found + 1)

hook.Add 'OnEntityCreated', 'DPP2.CheckEntitiesOwnage', =>
	CheckFrame = CurTimeL()
	table.insert(CheckEntities, @)
	return
