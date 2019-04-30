
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

import DPP2 from _G

DPP2.APKTriggerPhysgunDrop = (ply = NULL, ent = NULL) ->
	return if not DPP2.ENABLE_ANTIPROPKILL\GetBool()
	return if not DPP2.ANTIPROPKILL_TRAP\GetBool()
	return if not ply\IsValid() or not ent\IsValid()
	return if ent\IsPlayer()
	return if ent\DPP2IsGhosted()

	for ent2 in *ents.FindInBox(ent\WorldSpaceAABB())
		if ent2\IsPlayer()
			ent\DPP2Ghost()
			DPP2.NotifyHint(ply, 5, 'message.dpp2.warn.trap')
			return

PhysgunDrop2 = (ply = NULL, ent = NULL) ->
	return if not DPP2.ENABLE_ANTIPROPKILL\GetBool()
	return if not DPP2.ANTIPROPKILL_PUSH\GetBool()
	ent.__dpp2_pushing = (ent.__dpp2_pushing or 0) - 1
	return if ent.__dpp2_pushing > 0
	ent\SetCustomCollisionCheck(ent.__dpp2_prev_col_check)
	ent\CollisionRulesChanged()
	return

PhysgunDrop3 = (ply = NULL, ent = NULL) ->
	return if not DPP2.ENABLE_ANTIPROPKILL\GetBool()
	return if not DPP2.ANTIPROPKILL_THROW\GetBool()
	for physID = 0, ent\GetPhysicsObjectCount() - 1
		phys = ent\GetPhysicsObjectNum(physID)
		phys\SetVelocity(vector_origin) if IsValid(phys)

PhysgunPickup = (ply = NULL, ent = NULL) ->
	return if not DPP2.ENABLE_ANTIPROPKILL\GetBool()
	return if not DPP2.ANTIPROPKILL_PUSH\GetBool()
	ent.__dpp2_pushing = (ent.__dpp2_pushing or 0) + 1
	return if ent.__dpp2_pushing > 1
	ent\CollisionRulesChanged()
	ent.__dpp2_prev_col_check = ent\GetCustomCollisionCheck()
	ent\SetCustomCollisionCheck(true)
	return

ShouldCollide = (ent1, ent2) ->
	return if (not ent1.__dpp2_pushing or ent1.__dpp2_pushing < 1) and (not ent2.__dpp2_pushing or ent2.__dpp2_pushing < 1)
	return if not ent1\IsPlayer() and not ent2\IsPlayer()
	return false

GravGunPunt = (ply = NULL, wep = NULL) ->
	return if not DPP2.ENABLE_ANTIPROPKILL\GetBool()
	return false if not DPP2.ANTIPROPKILL_PUNT\GetBool()

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
hook.Add 'ShouldCollide', 'DPP2.Antipush', ShouldCollide, 6

hook.Add 'GravGunPunt', 'DPP2.AntiPropkill', GravGunPunt, 6
hook.Add 'EntityTakeDamage', 'DPP2.AntiPropkill', EntityTakeDamage, 6
hook.Add 'EntityTakeDamage', 'DPP2.AntiPropkill2', EntityTakeDamage, -6
