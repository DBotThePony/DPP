
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

import IsValid, table, DPP2, type, error, assert, constraint, net, SERVER, CLIENT from _G

entMeta = FindMetaTable('Entity')

nextidP = 0
nextidP = DPP2.ContraptionHolder.NEXT_ID or 0 if DPP2.ContraptionHolder

doWalkParent = (target, level) =>
	return target if not IsValid(@)
	return target if target[@] and level <= 0
	target[@] = @
	doWalkParent(children, target, level - 1) for _, children in pairs(@GetChildren())
	doWalkParent(@GetParent(), target, level - 1)
	return target

class DPP2.ContraptionHolder
	@NEXT_ID = nextidP
	@OBJECTS = {}

	@BLSTUFF = {}
	@RSSTUFF = {}

	@GetByID = (id) =>
		assert(type(id) == 'number', 'Invalid ID provided')

		for obj in *@OBJECTS
			if obj.id == id
				return obj

		return false

	for ent in *ents.GetAll()
		if ent.__dpp2_contraption and not table.qhasValue(@OBJECTS, ent.__dpp2_contraption)
			table.insert(@OBJECTS, ent.__dpp2_contraption)

	obj\Invalidate(true) for obj in *@OBJECTS
	@OBJECTS = [obj for obj in *@OBJECTS when obj\IsValid()]
	@Invalidate = => @OBJECTS = [obj for obj in *@OBJECTS when obj\Revalidate()]

	@GetAll = => @OBJECTS

	@GetNextID = =>
		error('ID must be specified on client realm') if CLIENT
		id = @NEXT_ID
		@NEXT_ID += 1
		return id

	new: (id = @@GetNextID()) =>
		@ents = {}
		@owners = {}
		@ownersFull = {}
		@ownersStateNotShared = {}
		@types = {}
		@id = id
		@networked = {} if SERVER
		@lastWalk = 0
		table.insert(@@OBJECTS, @)
		@rev = 0

		for object in *@@BLSTUFF
			hook.Add 'DPP2_' .. object.__class.__name .. '_' .. object.identifier .. '_EntryAdded', @, @TriggerUpdate
			hook.Add 'DPP2_' .. object.__class.__name .. '_' .. object.identifier .. '_EntryRemoved', @, @TriggerUpdate

		for object in *@@RSSTUFF
			hook.Add 'DPP2_' .. object.identifier .. '_EntryAdded', @, @TriggerUpdate
			hook.Add 'DPP2_' .. object.identifier .. '_EntryRemoved', @, @TriggerUpdate
			hook.Add 'DPP2_' .. object.identifier .. '_GroupAdded', @, @TriggerUpdate
			hook.Add 'DPP2_' .. object.identifier .. '_GroupRemoved', @, @TriggerUpdate
			hook.Add 'DPP2_' .. object.identifier .. '_WhitelistStatusUpdated', @, @TriggerUpdate

	GetID: => @id

	IsValid: => #@ents > 1

	GetOwners: => @owners
	GetOwnersFull: => @ownersFull
	GetOwnersPartial: (mode) => @ownersStateNotShared[mode] or @ownersFull
	HasOwner: (owner = NULL) => table.qhasValue(@owners, owner)
	CopyOwners: => [v for v in *@owners]
	CopyOwnersFull: => [v for v in *@ownersFull]

	EntitiesByOwner: (owner = NULL) => [ent for ent in *@ents when ent\DPP2GetOwner() == owner]
	EntitiesByStringOwner: (owner = '') => [ent for ent in *@ents when ent\DPP2GetOwnerSteamID() == owner]

	TriggerUpdate: =>
		@rev += 1
		hook.Run 'DPP2_ContraptionUpdate', @, @rev, @rev - 1

	AddEntity: (ent = NULL) =>
		return false if not IsValid(ent)
		return false if ent.__dpp2_contraption == @
		return false if ent.IsConstraint and ent\IsConstraint()
		ent.__dpp2_contraption\RemoveEntity(ent) if ent.__dpp2_contraption
		table.insert(@ents, ent)
		@TriggerUpdate()
		return true

	RemoveEntity: (ent = NULL, InvalidateNow = true) =>
		return false if not IsValid(ent)
		hit = false

		for i, ent2 in ipairs(@ents)
			if ent2 == ent
				table.remove(@ents, i)
				hit = true
				break

		return false if not hit
		ent.__dpp2_contraption = nil
		@Invalidate() if InvalidateNow

		return true

	MarkForDeath: (fromMerge = false) =>
		if not fromMerge
			ent.__dpp2_contraption = nil for ent in *@ents when IsValid(ent) and ent.__dpp2_contraption == @

		for i, obj in ipairs(@@OBJECTS)
			if obj == @
				table.remove(@@OBJECTS, i)
				break

		@ents = {}
		@owners = {}
		@ownersFull = {}
		@ownersStateNotShared = {}

		if SERVER and #@networked ~= 0
			@networked = [ply for ply in *@networked when ply\IsValid()]
			net.Start('dpp2_contraption_delete')
			net.WriteUInt32(@id)
			net.WriteBool(fromMerge)
			net.Send(@networked)

		DPP2.ContraptionHolder\Invalidate()

		hook.Run 'DPP2_ContraptionRemove', @

		return @

	NetworkToPlayer: (ply) =>
		error('Invalid side') if CLIENT
		return false if table.qhasValue(@networked, ply)
		@networked = [ply for ply in *@networked when ply\IsValid()]
		table.insert(@networked, ply)
		net.Start('dpp2_contraption_create')
		net.WriteUInt32(@id)
		net.WriteEntityArray(@ents)
		net.Send(ply)
		return true

	ReNetworkEverything: =>
		error('Invalid side') if CLIENT
		@networked = [ply for ply in *@networked when ply\IsValid()]
		net.Start('dpp2_contraption_create')
		net.WriteUInt32(@id)
		net.WriteEntityArray(@ents)
		net.Send(@networked)

	NetworkDiff: (previous) =>
		error('Invalid side') if CLIENT

		if #previous == 0
			@ReNetworkEverything()
			return true

		removed = {}
		added = {}

		for ent in *@ents
			if not table.qhasValue(previous, ent)
				table.insert(added, ent)

		for ent in *previous
			if ent\IsValid() and not table.qhasValue(@ents, ent)
				table.insert(removed, ent)

		-- diff is not effective
		if #removed + #added >= #@ents
			net.Start('dpp2_contraption_create')
			net.WriteUInt32(@id)
			net.WriteEntityArray(@ents)
			net.Send(@networked)
		else -- diff is effective
			net.Start('dpp2_contraption_diff')
			net.WriteUInt32(@id)
			net.WriteEntityArray(added)
			net.WriteEntityArray(removed)
			net.Send(@networked)

	Walk: (frompoint = NULL, ask, _find) =>
		error('Invalid side') if CLIENT
		error('Tried to use a NULL entity!') if not IsValid(frompoint)

		oldEnts = @ents
		ent.__dpp2_contraption = nil for ent in *@ents when IsValid(ent) and ent.__dpp2_contraption == @
		@lastWalk = RealTime() + 0.1
		@nextNetwork = RealTime() + 1

		@owners = {}
		@ownersFull = {}
		@ownersStateNotShared = {}

		find = _find or doWalkParent(frompoint, constraint.GetAllConstrainedEntities(frompoint), 1)
		find = {ent, ent for ent in pairs(find) when not ent\IsVehicle() or ent\DPP2IsOwned()} if not _find
		setup = {}

		for ent in pairs(find)
			if ent.__dpp2_contraption and ent.__dpp2_contraption ~= @ and #ent.__dpp2_contraption.ents >= #oldEnts and ent.__dpp2_contraption ~= ask
				ent.__dpp2_contraption\Walk(frompoint, @, find)
				@MarkForDeath(true)
				return false

			table.insert(setup, ent)

		@ents = setup
		ent.__dpp2_contraption = @ for ent in *setup

		if not @IsValid()
			@MarkForDeath()
		else
			oldEnts = [ent for ent in *oldEnts]
			@Invalidate()
			timer.Create 'DPP2_ContraptionDiff_' .. @id, 0.2, 1, -> @NetworkDiff(oldEnts) if @IsValid()

		return true

	From: (ents = @ents) =>
		for ent in *ents
			if IsValid(ent)
				ent.__dpp2_contraption\RemoveEntity(ent) if ent.__dpp2_contraption
				ent.__dpp2_contraption = @

		@ents = ents
		@Invalidate()
		return @

	CheckUpForGrabs: (newOwner = NULL) =>
		error('Invalid side CLIENT') if CLIENT
		return false if not newOwner\IsValid()
		fents = {}

		hit = false

		for ent in *@ents
			if ent\IsValid() and ent\DPP2IsUpForGrabs()
				hit = true
				table.insert(fents, ent)

		DPP2.Notify(newOwner, 'message.dpp2.owning.owned_contraption') if hit
		DPP2.DoTransfer(fents, newOwner)

		@TriggerUpdate()

		return hit

	Ghost: => ent\DPP2Ghost() for ent in *@ents when IsValid(ent)
	UnGhost: => ent\DPP2UnGhost() for ent in *@ents when IsValid(ent)

	Revalidate: =>
		return false if not @IsValid()

		@TriggerUpdate()

		for ent in *@ents
			if not entMeta.IsValid(ent)
				@Invalidate(false, true)
				return @IsValid()

		return @IsValid()

	InvalidateClients: =>
		error('Invalid side') if CLIENT
		return false if player.GetCount() == 0
		net.Start('dpp2_contraption_invalidate')
		net.WriteUInt32(@id)
		net.Broadcast()
		return true

	Invalidate: (withMarkForDeath = false, networkDiff = true) =>
		@TriggerUpdate()

		for ent in *@ents
			if not IsValid(ent)
				prev = @ents
				@ents = [ent for ent in *@ents when IsValid(ent)]
				@NetworkDiff(prev) if SERVER and networkDiff and (#@ents > 0 or not withMarkForDeath)
				break

		@owners = {}
		@ownersFull = {}
		@ownersStateNotShared = {def.identifier, {} for def in *DPP2.DEF.ProtectionDefinition.OBJECTS}
		@types = {}

		for ent in *@ents
			gtype = type(ent)
			ent.__dpp2_contraption = @
			owner, ownerSteamID = ent\DPP2GetOwner()
			table.insert(@owners, owner) if not table.qhasValue(@owners, owner)
			table.insert(@ownersFull, ownerSteamID) if not table.qhasValue(@ownersFull, ownerSteamID)
			table.insert(@types, gtype) if not table.qhasValue(@types, gtype)

			if ownerSteamID ~= 'world' and ownerSteamID ~= 'map'
				for def in *DPP2.DEF.ProtectionDefinition.OBJECTS
					if not def\IsShared(ent)
						table.insert(@ownersStateNotShared[def.identifier], ownerSteamID) if not table.qhasValue(@ownersStateNotShared[def.identifier], ownerSteamID)
						break
			else
				for def in *DPP2.DEF.ProtectionDefinition.OBJECTS
					table.insert(@ownersStateNotShared[def.identifier], ownerSteamID) if not table.qhasValue(@ownersStateNotShared[def.identifier], ownerSteamID)

		if withMarkForDeath and not @IsValid()
			@MarkForDeath()

	__tostring: => string.format('DPP2Contraption<%d>[%p]', @id, @)

entMeta.DPP2GetContraption = => @__dpp2_contraption
entMeta.DPP2HasContraption = => @__dpp2_contraption ~= nil
entMeta.DPP2InvalidateContraption = =>
	@__dpp2_contraption\Invalidate() if @__dpp2_contraption
	return @

entMeta.DPP2IsGhosted = => @GetNWBool('dpp2_ghost', false)

DPP2.ACCESS = DPP2.ACCESS or {}

import i18n from DLib

DPP2.ALLOW_DAMAGE_NPC = DPP2.CreateConVar('allow_damage_npc', '1', DPP2.TYPE_BOOL)
DPP2.ALLOW_DAMAGE_VEHICLE = DPP2.CreateConVar('allow_damage_vehicle', '1', DPP2.TYPE_BOOL)

DPP2.ACCESS.CanPhysgun = (ply = NULL, ent = NULL) ->
	return true if not ply\IsValid()
	return false, i18n.localize('gui.dpp2.access.status.invalident') if not ent\IsValid()
	return DPP2.PhysgunProtection\CanTouch(ply, ent)

DPP2.ACCESS.CanDrive = (ply = NULL, ent = NULL) ->
	return true if not ply\IsValid()
	return false, i18n.localize('gui.dpp2.access.status.invalident') if not ent\IsValid()
	return DPP2.DriveProtection\CanTouch(ply, ent)

DPP2.ACCESS.CanToolgun = (ply = NULL, ent = NULL, toolgunMode) ->
	error('Invalid toolgun mode type. It must be a string! typeof' .. type(toolgunMode)) if type(toolgunMode) ~= 'string'
	return true if not ply\IsValid()
	return false, i18n.localize('gui.dpp2.access.status.toolgun_mode_blocked') if not DPP2.ToolgunModeRestrictions\Ask(toolgunMode, ply)
	return false, i18n.localize('gui.dpp2.access.status.toolgun_player') if ent\IsPlayer() and DPP2.NO_TOOLGUN_PLAYER\GetBool() and (not DPP2.ToolgunProtection\IsAdmin(ply) or DPP2.NO_TOOLGUN_PLAYER_ADMIN\GetBool() and DPP2.ToolgunProtection\IsAdmin(ply))
	-- allow self tool
	return true if ply == ent
	return true, i18n.localize('gui.dpp2.access.status.invalident') if not ent\IsValid()

	if DPP2.ToolgunModeExclusions\Ask(toolgunMode, ply)
		cangeneric, tstatus = DPP2.ToolgunProtection\CanGeneric(ply, ent)
		return cangeneric, tstatus if not cangeneric
		return true, i18n.localize('gui.dpp2.access.status.toolgun_mode_excluded')

	return DPP2.ToolgunProtection\CanTouch(ply, ent)

DPP2.ACCESS.CanDamage = (ply = NULL, ent = NULL) ->
	return true if not ply\IsValid()
	return false, i18n.localize('gui.dpp2.access.status.invalident') if not ent\IsValid()

	ALLOW_DAMAGE_NPC = DPP2.ALLOW_DAMAGE_NPC\GetBool()
	ALLOW_DAMAGE_VEHICLE = DPP2.ALLOW_DAMAGE_VEHICLE\GetBool()

	if contraption = ent\DPP2GetContraption()
		for etype in *contraption.types
			if etype == 'Vehicle' and ALLOW_DAMAGE_VEHICLE
				return true, i18n.localize('gui.dpp2.access.status.damage_allowed'), i18n.localize('gui.dpp2.access.status.contraption_ext', contraption\GetID())

			if (etype == 'NPC' or etype == 'NextBot') and ALLOW_DAMAGE_NPC
				return true, i18n.localize('gui.dpp2.access.status.damage_allowed'), i18n.localize('gui.dpp2.access.status.contraption_ext', contraption\GetID())

	if ent\IsVehicle() and ALLOW_DAMAGE_VEHICLE
		return true, i18n.localize('gui.dpp2.access.status.damage_allowed')

	if (ent\IsNPC() or type(ent) == 'NextBot') and ALLOW_DAMAGE_VEHICLE
		return true, i18n.localize('gui.dpp2.access.status.damage_allowed')

	return DPP2.DamageProtection\CanTouch(ply, ent)

DPP2.ACCESS.CanPickup = (ply = NULL, ent = NULL) ->
	return true if not ply\IsValid()
	return false, i18n.localize('gui.dpp2.access.status.invalident') if not ent\IsValid()
	return DPP2.PickupProtection\CanTouch(ply, ent)

DPP2.ACCESS.CanUse = (ply = NULL, ent = NULL) ->
	return true if not ply\IsValid()
	return false, i18n.localize('gui.dpp2.access.status.invalident') if not ent\IsValid()
	return DPP2.UseProtection\CanTouch(ply, ent)

DPP2.ACCESS.CanUseVehicle = (ply = NULL, ent = NULL) ->
	return true if not ply\IsValid()
	return false, i18n.localize('gui.dpp2.access.status.invalident') if not ent\IsValid()
	return DPP2.VehicleProtection\CanTouch(ply, ent)

DPP2.ACCESS.CanGravgun = (ply = NULL, ent = NULL) ->
	return true if not ply\IsValid()
	return false, i18n.localize('gui.dpp2.access.status.invalident') if not ent\IsValid()
	return DPP2.GravgunProtection\CanTouch(ply, ent)

DPP2.ACCESS.CanGravgunPunt = (ply = NULL, ent = NULL) ->
	return true if not ply\IsValid()
	return false, i18n.localize('gui.dpp2.access.status.invalident') if not ent\IsValid()
	return DPP2.GravgunProtection\CanTouch(ply, ent)
