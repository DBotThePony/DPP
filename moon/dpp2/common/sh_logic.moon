
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

import IsValid, table, DPP2, type, error, assert, constraint, net, SERVER, CLIENT from _G

entMeta = FindMetaTable('Entity')

nextidP = 0
nextidP = DPP2.ContraptionHolder.NEXT_ID or 0 if DPP2.ContraptionHolder

class DPP2.ContraptionHolder
	@NEXT_ID = nextidP
	@OBJECTS = {}

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

	@GetNextID = =>
		error('ID must be specified on client realm') if CLIENT
		id = @NEXT_ID
		@NEXT_ID += 1
		return id

	new: (id = @@GetNextID()) =>
		@ents = {}
		@owners = {}
		@ownersFull = {}
		@ownersNoShare = {}
		@id = id
		@networked = {} if SERVER
		@lastWalk = 0
		table.insert(@@OBJECTS, @)

	IsValid: => #@ents > 1

	GetOwners: => @owners
	GetOwnersFull: => @ownersFull
	GetOwnersPartial: (mode) => @ownersNoShare[mode] or @ownersFull
	CopyOwners: => [v for v in *@owners]
	CopyOwnersFull: => [v for v in *@ownersFull]

	AddEntity: (ent = NULL) =>
		return false if not IsValid(ent)
		return false if ent.__dpp2_contraption == @
		return false if ent.IsConstraint and ent\IsConstraint()
		ent.__dpp2_contraption\RemoveEntity(ent) if ent.__dpp2_contraption
		table.insert(@ents, ent)
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

	MarkForDeath: =>
		for ent in *@ents
			if IsValid(ent)
				ent.__dpp2_contraption = nil

		for i, obj in ipairs(@@OBJECTS)
			if obj == @
				table.remove(@@OBJECTS, i)
				break

		@ents = {}
		@owners = {}
		@ownersFull = {}
		@ownersNoShare = {}

		if SERVER and #@networked ~= 0
			@networked = [ply for ply in *@networked when ply\IsValid()]
			net.Start('dpp2_contraption_delete')
			net.WriteUInt32(@id)
			net.Send(@networked)

		DPP2.ContraptionHolder\Invalidate()

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

	Walk: (frompoint = NULL) =>
		error('Invalid side') if CLIENT
		error('Tried to use a NULL entity!') if not IsValid(frompoint)

		oldEnts = @ents

		for ent in *@ents
			if IsValid(ent)
				ent.__dpp2_contraption = nil

		@owners = {}
		@ownersFull = {}
		@ownersNoShare = {}

		@ents = for ent in pairs(constraint.GetAllConstrainedEntities(frompoint))
			ent.__dpp2_contraption = @
			ent

		@lastWalk = RealTime() + 0.1

		if not @IsValid()
			@MarkForDeath()
		else
			@Invalidate()
			@NetworkDiff(oldEnts)

	From: (ents = @ents) =>
		for ent in *ents
			if IsValid(ent)
				ent.__dpp2_contraption\RemoveEntity(ent) if ent.__dpp2_contraption
				ent.__dpp2_contraption = @

		@ents = ents
		@Invalidate()
		return @

	Revalidate: =>
		return false if not @IsValid()

		for ent in *@ents
			if not entMeta.IsValid(ent)
				@Invalidate()
				return @IsValid()

		return @IsValid()

	Invalidate: (withMarkForDeath = false) =>
		prev = @ents
		@ents = [ent for ent in *@ents when IsValid(ent)]
		@NetworkDiff(prev) if SERVER and (#@ents > 0 or not withMarkForDeath)
		@owners = {}
		@ownersFull = {}
		@ownersNoShare = {}

		@ownersNoShare[def.name] = {} for def in *DPP2.DEF.ProtectionDefinition.OBJECTS

		for ent in *@ents
			owner, ownerSteamID = ent\DPP2GetOwner()
			table.insert(@owners, owner) if not table.qhasValue(@owners, owner)
			table.insert(@ownersFull, ownerSteamID) if not table.qhasValue(@ownersFull, ownerSteamID)

			if ownerSteamID ~= 'world' and ownerSteamID ~= 'map'
				for def in *DPP2.DEF.ProtectionDefinition.OBJECTS
					if not def\IsShared(ent)
						table.insert(@ownersNoShare[def.name], ownerSteamID) if not table.qhasValue(@ownersNoShare[def.name], ownerSteamID)
						break
			else
				for def in *DPP2.DEF.ProtectionDefinition.OBJECTS
					table.insert(@ownersNoShare[def.name], ownerSteamID) if not table.qhasValue(@ownersNoShare[def.name], ownerSteamID)

		if withMarkForDeath and not @IsValid()
			@MarkForDeath()

entMeta.DPP2GetContraption = => @__dpp2_contraption
entMeta.DPP2InvalidateContraption = =>
	@__dpp2_contraption\Invalidate() if @__dpp2_contraption
	return @

DPP2.ACCESS = DPP2.ACCESS or {}

import i18n from DLib

DPP2.ACCESS.CanPhysgun = (ply = NULL, ent = NULL) ->
	return true if not ply\IsValid()
	return false, i18n.localize('gui.dpp2.access.status.invalident') if not ent\IsValid()
	return DPP2.PhysgunProtection\CanTouch(ply, ent)

DPP2.ACCESS.CanDrive = (ply = NULL, ent = NULL) ->
	return true if not ply\IsValid()
	return false, i18n.localize('gui.dpp2.access.status.invalident') if not ent\IsValid()
	return DPP2.DriveProtection\CanTouch(ply, ent)

DPP2.ACCESS.CanToolgun = (ply = NULL, ent = NULL, toolgunMode) ->
	error('Invalid toolgun m ode type. It must be a string! typeof' .. type(toolgunMode)) if type(toolgunMode) ~= 'string'
	return true if not ply\IsValid()
	return false, i18n.localize('gui.dpp2.access.status.toolgun_player') if ent\IsPlayer() and DPP2.NO_TOOLGUN_PLAYER\GetBool() and (not DPP2.ToolgunProtection\IsAdmin(ply) or DPP2.NO_TOOLGUN_PLAYER_ADMIN\GetBool() and DPP2.ToolgunProtection\IsAdmin(ply))
	-- allow self tool
	return true if ply == ent
	return false, i18n.localize('gui.dpp2.access.status.invalident') if not ent\IsValid()
	return DPP2.ToolgunProtection\CanTouch(ply, ent)

DPP2.ACCESS.CanDamage = (ply = NULL, ent = NULL) ->
	return true if not ply\IsValid()
	return false, i18n.localize('gui.dpp2.access.status.invalident') if not ent\IsValid()
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
