
-- Copyright (C) 2015-2018 DBot

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

DPP2.PlayerSpawnedSomething = (ply, ent, advancedCheck = false) ->
	ent\DPP2SetOwner(ply)

PlayerSpawnedEffect = (ply = NULL, model = 'models/error.mdl', ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	DPP2.PlayerSpawnedSomething(ply, ent)

PlayerSpawnedProp = (ply = NULL, model = 'models/error.mdl', ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	DPP2.PlayerSpawnedSomething(ply, ent)

PlayerSpawnedRagdoll = (ply = NULL, model = 'models/error.mdl', ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	DPP2.PlayerSpawnedSomething(ply, ent)

PlayerSpawnedNPC = (ply = NULL, ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	DPP2.PlayerSpawnedSomething(ply, ent)

PlayerSpawnedSENT = (ply = NULL, ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	DPP2.PlayerSpawnedSomething(ply, ent)

PlayerSpawnedSWEP = (ply = NULL, ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	DPP2.PlayerSpawnedSomething(ply, ent)

PlayerSpawnedVehicle = (ply = NULL, ent = NULL) ->
	return unless ply\IsValid()
	return unless ent\IsValid()
	DPP2.PlayerSpawnedSomething(ply, ent)

PlayerSpawnEffect = (ply = NULL, model = 'models/error.mdl') ->
PlayerSpawnProp = (ply = NULL, model = 'models/error.mdl') ->
PlayerSpawnRagdoll = (ply = NULL, model = 'models/error.mdl') ->
PlayerSpawnObject = (ply = NULL, model = 'models/error.mdl', skin = 0) ->
PlayerSpawnVehicle = (ply = NULL, model = 'models/error.mdl', name = 'prop_vehicle_jeep', info = {}) ->
PlayerSpawnNPC = (ply = NULL, npcclassname = 'base_entity', weaponclass = 'base_entity') ->
PlayerSpawnSENT = (ply = NULL, classname = 'base_entity') ->
PlayerGiveSWEP = (ply = NULL, classname = 'base_entity', definition = {ClassName: 'base_entity', WorldModel: 'models/error.mdl', ViewModel: 'models/error.mdl'}) ->
PlayerSpawnSWEP = (ply = NULL, classname = 'base_entity', definition = {ClassName: 'base_entity', WorldModel: 'models/error.mdl', ViewModel: 'models/error.mdl'}) ->

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

DiveTableCheck = (tab, owner, checkedEnts, checkedTables) =>
	return if checkedTables[tab]
	checkedTables[tab] = true

	for key, value in pairs(tab)
		vtype = type(value)

		if vtype == 'table' and (type(key) ~= 'string' or not key\startsWith('__dpp2'))
			DiveTableCheck(@, value, owner, checkedEnts, checkedTables)
		elseif vtype == 'Entity' or vtype == 'NPC' or vtype == 'NextBot' or vtype == 'Vehicle'
			DiveEntityCheck(value, owner, checkedEnts, checkedTables)

DiveEntityCheck = (owner, checkedEnts, checkedTables) =>
	return if checkedEnts[@]
	return if @__dpp2_check_frame == CurTimeL()
	return if not @GetTable()
	checkedEnts[@] = true
	@__dpp2_check_frame = CurTimeL()
	DPP2.PlayerSpawnedSomething(owner, @, true) if @DPP2GetOwner() ~= owner and @__dpp2_spawn_frame == CurTimeL()
	DiveTableCheck(@, @GetTable(), owner, checkedEnts, checkedTables)

hook.Add 'Think', 'DPP2.CheckEntitiesOwnage', ->
	return if CheckFrame >= CurTimeL()
	return if #CheckEntities == 0
	copy = CheckEntities
	CheckEntities = {}

	for ent in *copy
		if ent\IsValid()
			ent.__dpp2_spawn_frame = CurTimeL()

	for ent in *copy
		if ent\IsValid() and ent\DPP2OwnerIsValid()
			DiveEntityCheck(ent, ent\DPP2GetOwner(), {}, {})

hook.Add 'OnEntityCreated', 'DPP2.CheckEntitiesOwnage', =>
	CheckFrame = CurTimeL()
	table.insert(CheckEntities, @)
	return
