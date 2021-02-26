
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

import DPP2, type, table, player, DLib from _G
import IsValid from FindMetaTable('Entity')
import net from DLib

DPP2.EntityCreationBans = DPP2.EntityCreationBans or {}

entMeta = FindMetaTable('Entity')
plyMeta = FindMetaTable('Player')

plyMeta.DPP2IsBanned = =>
	value = DPP2.EntityCreationBans[@SteamID()]
	return false if not value
	return true if value == true
	time = RealTime()

	if time > DPP2.EntityCreationBans[@SteamID()]
		@DPP2Unban()
		return false

	return true

plyMeta.DPP2BanTimeLeft = =>
	return 0 if not @DPP2IsBanned()
	return math.huge if DPP2.EntityCreationBans[@SteamID()] == true
	return DPP2.EntityCreationBans[@SteamID()] - RealTime()

plyMeta.DPP2IsPermanentlyBanned = => DPP2.EntityCreationBans[@SteamID()] == true

plyMeta.DPP2Ban = (time = math.huge) =>
	@DLibSetPDataBoolean('dpp2_ban', true)
	@DLibSetPDataBoolean('dpp2_ban_perma', time == math.huge)

	@SetNWInt('dpp2_ban', true)
	@SetNWInt('dpp2_ban_perma', time == math.huge)

	if time == math.huge
		DPP2.EntityCreationBans[@SteamID()] = true
		@DLibRemovePDataInt('dpp2_ban')
	else
		DPP2.EntityCreationBans[@SteamID()] = RealTime() + time
		@DLibSetPDataInt('dpp2_ban', os.time() + time)

plyMeta.DPP2Unban = =>
	@DLibRemovePDataBoolean('dpp2_ban')
	@DLibRemovePDataInt('dpp2_ban')
	@DLibRemovePDataBoolean('dpp2_ban_perma')
	DPP2.EntityCreationBans[@SteamID()] = nil

	@SetNWInt('dpp2_ban', false)
	@SetNWInt('dpp2_ban_perma', false)

PlayerInitialSpawn = =>
	return if not @SteamID()
	return if @IsBot()

	return if not @DLibGetPDataBoolean('dpp2_ban')

	@SetNWInt('dpp2_ban', true)

	if @DLibGetPDataBoolean('dpp2_ban_perma')
		@SetNWInt('dpp2_ban_perma', true)
		DPP2.EntityCreationBans[@SteamID()] = true
	else
		@SetNWInt('dpp2_ban_perma', false)
		time_left = @DLibGetPDataInt('dpp2_ban') - os.time()

		if time_left > 0
			DPP2.EntityCreationBans[@SteamID()] = RealTime() + time_left
		else
			@DPP2Unban()

hook.Add 'PlayerInitialSpawn', 'DPP2.Banning', PlayerInitialSpawn, -2

PlayerDisconnected = =>
	DPP2.EntityCreationBans[@SteamID()] = nil

hook.Add 'PlayerDisconnected', 'DPP2.Banning', PlayerDisconnected, -2

entMeta.DPP2CreatedByMap = => not @IsPlayer() and @CreatedByMap()
entMeta.__DPP2_SetParent = entMeta.__DPP2_SetParent or entMeta.SetParent
entMeta.__DPP2_SetMoveParent = entMeta.__DPP2_SetMoveParent or entMeta.SetMoveParent

entMeta.SetParent = (parent = NULL, ...) =>
	return @__DPP2_SetParent(parent, ...) if @IsPlayer() or parent\IsPlayer()

	oldParent = @GetParent()
	a, b, c, d, e, f, g, k = @__DPP2_SetParent(parent, ...)

	if oldParent ~= parent
		if not @__dpp2_contraption
			@__dpp2_contraption = DPP2.ContraptionHolder()
			@__dpp2_contraption\Walk(@)
		elseif @__dpp2_contraption.lastWalk < RealTime()
			@__dpp2_contraption\Walk(@)
		else
			timer.Create 'DPP2_WalkContraption_' .. @__dpp2_contraption.id, 0.25, 1, ->
				@__dpp2_contraption\Walk(@) if @IsValid() and @__dpp2_contraption and @__dpp2_contraption\IsValid() and @__dpp2_contraption.lastWalk < RealTime()

	return a, b, c, d, e, f, g, k

entMeta.SetMoveParent = (parent = NULL, ...) =>
	return @__DPP2_SetMoveParent(parent, ...) if @IsPlayer() or parent\IsPlayer()

	oldParent = @GetMoveParent()
	a, b, c, d, e, f, g, k = @__DPP2_SetMoveParent(parent, ...)

	if oldParent ~= parent
		if not @__dpp2_contraption
			@__dpp2_contraption = DPP2.ContraptionHolder()
			@__dpp2_contraption\Walk(@)
		elseif @__dpp2_contraption.lastWalk < RealTime()
			@__dpp2_contraption\Walk(@)
		else
			timer.Create 'DPP2_WalkContraption_' .. @__dpp2_contraption.id, 0.25, 1, ->
				@__dpp2_contraption\Walk(@) if @IsValid() and @__dpp2_contraption and @__dpp2_contraption\IsValid() and @__dpp2_contraption.lastWalk < RealTime()

	return a, b, c, d, e, f, g, k

net.pool('dpp2_contraption_create')
net.pool('dpp2_contraption_delete')
net.pool('dpp2_contraption_invalidate')
net.pool('dpp2_contraption_diff')

hook.Add 'Think', 'DPP2.CheckOwnedByMap', ->
	ent\SetNWBool('dpp2_cbm', true) for ent in *ents.GetAll() when ent\CreatedByMap()
	hook.Remove 'Think', 'DPP2.CheckOwnedByMap'

hook.Add 'PostCleanupMap', 'DPP2.CheckOwnedByMap', -> timer.Simple 0, -> ent\SetNWBool('dpp2_cbm', true) for ent in *ents.GetAll() when ent\CreatedByMap()

WalkConstraint = =>
	if not @__dpp2_contraption
		@__dpp2_contraption = DPP2.ContraptionHolder()
		@__dpp2_contraption\Walk(@)
	elseif @__dpp2_contraption.lastWalk < RealTime()
		@__dpp2_contraption\Walk(@)
	else
		timer.Create 'DPP2_WalkContraption_' .. @__dpp2_contraption.id, 0.25, 1, ->
			@__dpp2_contraption\Walk(@) if @IsValid() and @__dpp2_contraption and @__dpp2_contraption\IsValid() and @__dpp2_contraption.lastWalk < RealTime()

hook.Add 'Think', 'DPP2.Contraptions', ->
	for ply in *player.GetAll()
		tr = ply\GetEyeTrace()
		if tr.Entity\IsValid() and tr.Entity.__dpp2_contraption and (not tr.Entity.__dpp2_contraption.nextNetwork or tr.Entity.__dpp2_contraption.nextNetwork < RealTime())
			tr.Entity.__dpp2_contraption\NetworkToPlayer(ply)

hook.Add 'OnEntityCreated', 'DPP2.Contraptions', =>
	timer.Simple 0, ->
		return if not IsValid(@)
		return if not @IsConstraint()
		ent1, ent2 = @GetConstrainedEntities()
		return if not IsValid(ent1) or not IsValid(ent2)
		WalkConstraint(ent1)
		WalkConstraint(ent2)

	return

hook.Add 'EntityRemoved', 'DPP2.Contraptions', =>
	if @__dpp2_contraption
		timer.Simple 0, -> DPP2.ContraptionHolder\Invalidate()

	return if not @IsConstraint()
	ent1, ent2 = @GetConstrainedEntities()
	return if not IsValid(ent1) or not IsValid(ent2)

	timer.Simple 0, ->
		return if not IsValid(ent1) or not IsValid(ent2)
		WalkConstraint(ent1)
		WalkConstraint(ent2)

	return

GhostPhysObj = (ent) =>
	isvehicle = ent\IsVehicle()
	motion = @IsMotionEnabled()
	gravity = @IsGravityEnabled()
	--mass = @GetMass()
	collisions = @IsCollisionEnabled() if not isvehicle
	angvel = @GetAngleVelocity() if not isvehicle
	vel = @GetVelocity() if not isvehicle

	@EnableMotion(false)
	@EnableGravity(false)
	@EnableCollisions(false) if not isvehicle
	--@SetMass(1)
	@Sleep()

	return ->
		return if not @IsValid()
		@EnableMotion(motion)
		@EnableGravity(gravity)
		@EnableCollisions(collisions) if not isvehicle
		--@SetMass(mass)
		@Wake()
		@AddAngleVelocity(angvel) if not isvehicle
		@SetVelocity(vel) if not isvehicle

entMeta.DPP2CanGhost = => not @IsConstraint() and not @DPP2IsGhosted() and @DPP2GetPhys()

entMeta.DPP2Ghost = (callback) =>
	return false if @DPP2IsGhosted()
	return false if @IsConstraint()
	phys = @DPP2GetPhys()
	return false if not phys
	@SetNWBool('dpp2_ghost', true)

	@__dpp2_old_collisions_group = @GetCollisionGroup()
	@__dpp2_old_movetype = @GetMoveType()
	@__dpp2_old_rendermode = @GetRenderMode()
	@__dpp2_old_color = Color(@GetColor())

	if callback
		if @__dpp2_ghost_callbacks
			table.insert(@__dpp2_ghost_callbacks, callback)
		else
			@__dpp2_ghost_callbacks = {callback}

	if type(phys) == 'table'
		@__dpp2_old_phys = [GhostPhysObj(phys2, @) for phys2 in *phys]
	else
		@__dpp2_old_phys = GhostPhysObj(phys, @)

	@SetMoveType(MOVETYPE_NONE)
	@SetCollisionGroup(COLLISION_GROUP_WORLD)
	@SetRenderMode(RENDERMODE_TRANSALPHA)
	@SetColor(@__dpp2_old_color\ModifyAlpha(100))

entMeta.DPP2UnGhost = (withConstraption) =>
	@__dpp2_contraption\UnGhost() if withConstraption and @__dpp2_contraption
	return if not @DPP2IsGhosted()
	@SetNWBool('dpp2_ghost', false)

	if type(@__dpp2_old_phys) == 'function'
		@__dpp2_old_phys()
	elseif type(@__dpp2_old_phys) == 'table'
		func() for func in *@__dpp2_old_phys

	@__dpp2_old_phys = nil

	@SetCollisionGroup(@__dpp2_old_collisions_group) if @__dpp2_old_collisions_group
	@SetMoveType(@__dpp2_old_movetype) if @__dpp2_old_movetype
	@SetRenderMode(@__dpp2_old_rendermode) if @__dpp2_old_rendermode
	@SetColor(@__dpp2_old_color) if @__dpp2_old_color

	@__dpp2_old_collisions_group = nil
	@__dpp2_old_movetype = nil
	@__dpp2_old_rendermode = nil
	@__dpp2_old_color = nil

	if @__dpp2_ghost_callbacks
		callback() for callback in *@__dpp2_ghost_callbacks
		@__dpp2_ghost_callbacks = nil

	return true

entMeta.DPP2SwitchGhost = => @DPP2SetGhost(not @DPP2IsGhosted())
entMeta.DPP2SetGhost = (status) =>
	return @DPP2Ghost() if status
	@DPP2UnGhost()
