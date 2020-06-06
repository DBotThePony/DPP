
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

import DPP2, DLib from _G

DPP2.APKTriggerPhysgunDrop = (ply = NULL, ent = NULL) ->
	return if not DPP2.ENABLE_ANTIPROPKILL\GetBool()
	return if not DPP2.ANTIPROPKILL_TRAP\GetBool()
	return if not ply\IsValid() or not ent\IsValid()
	return if ent\IsPlayer()

	contraption = ent\DPP2GetContraption()

	if contraption
		mins, maxs = contraption\CalculateWorldAABB()
		infmaxs = Vector(maxs.x, maxs.y, 0x7FFF)
		players = player.GetAll()
		check = {}

		hit = false

		for ply in *player.GetAll()
			mins_, maxs_ = ply\GetHull()
			pos = ply\GetPos()

			mins_\Add(pos)
			maxs_\Add(pos)

			cond_ = DLib.vector.IsPositionInsideBox(mins_, mins, maxs) or DLib.vector.IsPositionInsideBox(maxs_, mins, maxs) or (
				mins_.z < mins.z and DLib.vector.IsPositionInsideBox(maxs_, mins, infmaxs)
			)

			if cond_
				for ent in *contraption.ents
					if IsValid(ent) and ent\GetSolid() ~= SOLID_NONE and not ent\DPP2IsGhosted()
						mins__, maxs__ = ent\WorldSpaceAABB()
						cond = DLib.vector.IsPositionInsideBox(mins_, mins__, maxs__) or DLib.vector.IsPositionInsideBox(maxs_, mins__, maxs__)

						if not cond
							infmaxs__ = Vector(maxs__.x, maxs__.y, 0x7FFF)
							cond = mins_.z < mins__.z and DLib.vector.IsPositionInsideBox(maxs_, mins__, infmaxs__)

						if cond
							hit = true
							break

				break if hit

		if hit
			ent\DPP2Ghost() for ent in *contraption.ents when IsValid(ent) and not ent\DPP2IsGhosted()
			DPP2.NotifyHint(ply, 5, 'message.dpp2.warn.trap')
			return
	else
		return if ent\DPP2IsGhosted()
		return if ent\GetSolid() == SOLID_NONE

		for ent2 in *ents.FindInBox(ent\WorldSpaceAABB())
			if ent2\IsPlayer() and ent2 ~= ply and not ent2\InVehicle()
				ent\DPP2Ghost()
				DPP2.NotifyHint(ply, 5, 'message.dpp2.warn.trap')
				return

inc = (by_, ply) =>
	if contraption = @DPP2GetContraption()
		prev = contraption._pushing
		contraption._pushing = contraption._pushing + (by_ and 1 or -1)

		if not DPP2.ANTIPROPKILL_SURF\GetBool()
			if by_
				if ply and not table.qhasValue(contraption._pushing_r, ply)
					table.insert(contraption._pushing_r, ply)
					ent\CollisionRulesChanged() for ent in *contraption.ents
			else
				if ply and table.qhasValue(contraption._pushing_r, ply)
					table.RemoveByValue(contraption._pushing_r, ply)
					ent\CollisionRulesChanged() for ent in *contraption.ents

		if prev == 0 and by_
			for ent in *contraption.ents
				if not ent.__dpp2_pushing or ent.__dpp2_pushing == 0
					ent.__dpp2_prev_col_check = ent\GetCustomCollisionCheck()
					ent\SetCustomCollisionCheck(true)
					ent\CollisionRulesChanged()

				ent.__dpp2_contraption_pushing = true
		elseif prev > 0 and not by_ and contraption._pushing == 0
			for ent in *contraption.ents
				if ent.__dpp2_contraption_pushing
					ent\SetCustomCollisionCheck(ent.__dpp2_prev_col_check)
					ent\CollisionRulesChanged()
					ent.__dpp2_contraption_pushing = nil
					ent.__dpp2_prev_col_check = nil

		return

	prev = @__dpp2_pushing or 0
	@__dpp2_pushing = (@__dpp2_pushing or 0) + (by_ and 1 or -1)
	@__dpp2_pushing_r = @__dpp2_pushing_r or {}

	if not DPP2.ANTIPROPKILL_SURF\GetBool()
		if by_
			table.insert(@__dpp2_pushing_r, ply) if ply and not table.qhasValue(@__dpp2_pushing_r, ply)
			@CollisionRulesChanged()
		else
			table.RemoveByValue(@__dpp2_pushing_r, ply) if ply and table.qhasValue(@__dpp2_pushing_r, ply)
			@CollisionRulesChanged()

	if prev == 0 and by_
		@__dpp2_prev_col_check = @GetCustomCollisionCheck()
		@SetCustomCollisionCheck(true)
		@CollisionRulesChanged()
	elseif prev > 0 and not by_ and @__dpp2_pushing == 0
		@SetCustomCollisionCheck(@__dpp2_prev_col_check)
		@CollisionRulesChanged()
		@__dpp2_prev_col_check = nil

PhysgunDrop2 = (ply = NULL, ent = NULL) ->
	return if not DPP2.ENABLE_ANTIPROPKILL\GetBool()
	return if not DPP2.ANTIPROPKILL_PUSH\GetBool()
	return if ent\IsPlayer()
	inc(ent, false, ply)
	return

PhysgunDrop3 = (ply = NULL, ent = NULL) ->
	return if not DPP2.ENABLE_ANTIPROPKILL\GetBool()
	return if not DPP2.ANTIPROPKILL_THROW\GetBool()
	for physID = 0, ent\GetPhysicsObjectCount() - 1
		phys = ent\GetPhysicsObjectNum(physID)
		if IsValid(phys)
			phys\SetVelocity(vector_origin)
			phys\AddAngleVelocity(-phys\GetAngleVelocity())

PhysgunPickup = (ply = NULL, ent = NULL) ->
	return if not DPP2.ENABLE_ANTIPROPKILL\GetBool()
	return if not DPP2.ANTIPROPKILL_PUSH\GetBool()
	return if ent\IsPlayer()
	inc(ent, true, ply)
	return

ShouldCollide = (ent1, ent2) ->
	return if not DPP2.ENABLE_ANTIPROPKILL\GetBool()
	c1, c2 = ent1\DPP2GetContraption(), ent2\DPP2GetContraption()
	return if (not ent1.__dpp2_pushing or ent1.__dpp2_pushing < 1) and (not ent2.__dpp2_pushing or ent2.__dpp2_pushing < 1) and (not c1 or c1._pushing < 1) and (not c2 or c2._pushing < 1)
	return if not ent1\IsPlayer() and not ent2\IsPlayer()
	if DPP2.ANTIPROPKILL_SURF\GetBool()
		return false
	else
		ply = ent1\IsPlayer() and ent1 or ent2
		ent = ply == ent1 and ent2 or ent1
		contraption = ent == ent1 and c1 or ent == ent2 and c2
		return false if not table.qhasValue(contraption and contraption._pushing_r or ent.__dpp2_pushing_r, ply)

EntityTakeDamage = (dmg) =>
	return if not DPP2.ENABLE_ANTIPROPKILL\GetBool()
	return if not DPP2.ANTIPROPKILL_DAMAGE\GetBool()
	return if dmg\GetDamageType()\band(DMG_CRUSH) ~= DMG_CRUSH and dmg\GetDamageType()\band(DMG_VEHICLE) ~= DMG_VEHICLE
	return if not @IsPlayer()

	if DPP2.ANTIPROPKILL_DAMAGE_NO_WORLD\GetBool()
		return if (not IsValid(dmg\GetAttacker()) or not dmg\GetAttacker()\IsPlayer() and not dmg\GetAttacker()\DPP2IsOwned()) and (not IsValid(dmg\GetInflictor()) or not dmg\GetInflictor()\IsPlayer() and not dmg\GetInflictor()\DPP2IsOwned())

	if DPP2.ANTIPROPKILL_DAMAGE_NO_VEHICLES\GetBool()
		return if IsValid(dmg\GetAttacker()) and dmg\GetAttacker()\IsVehicle() or IsValid(dmg\GetInflictor()) and dmg\GetInflictor()\IsVehicle()

	dmg\SetDamage(0)
	dmg\SetDamageType(0)

hook.Add 'PhysgunDrop', 'DPP2.AntiPropkill', DPP2.APKTriggerPhysgunDrop, 6
hook.Add 'PhysgunDrop', 'DPP2.NoThrow', PhysgunDrop3, 8

hook.Add 'PhysgunDrop', 'DPP2.Antipush', PhysgunDrop2, 6
hook.Add 'PhysgunPickup', 'DPP2.Antipush', PhysgunPickup, 6
hook.Add 'ShouldCollide', 'DPP2.Antipush', ShouldCollide, -1

hook.Add 'EntityTakeDamage', 'DPP2.AntiPropkill', EntityTakeDamage, 6
hook.Add 'EntityTakeDamage', 'DPP2.AntiPropkill2', EntityTakeDamage, -6
