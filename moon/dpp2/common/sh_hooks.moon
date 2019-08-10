
-- Copyright (C) 2015-2019 DBotThePony

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

import DPP2, type, table, hook from _G
import IsValid from FindMetaTable('Entity')

CheckupEntity = (ent, field, ...) ->

CanPlayerEnterVehicle = (ply = NULL, vehicle = NULL, role = 0) ->
	return if not IsValid(ply)
	return if not IsValid(vehicle)
	vehicle\DPP2CheckUpForGrabs(ply) if SERVER
	status = DPP2.ACCESS.CanUseVehicle(ply, vehicle)
	return status if not status
	vehicle\DPP2UnGhost(true) if SERVER
	return

CanDrive = (ply = NULL, ent = NULL) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	ent\DPP2CheckUpForGrabs(ply) if SERVER
	status = DPP2.ACCESS.CanDrive(ply, ent)
	return status if not status
	if SERVER
		ent\DPP2UnGhost(true)
		DPP2.APKTriggerPhysgunDrop(ply, ent)
		return

GravGunPunt = (ply = NULL, ent = NULL) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	ent\DPP2CheckUpForGrabs(ply) if SERVER
	status = DPP2.ACCESS.CanGravgun(ply, ent)
	return status if not status
	if SERVER
		ent\DPP2UnGhost(true)
		DPP2.APKTriggerPhysgunDrop(ply, ent)
		return

AllowPlayerPickup = (ply = NULL, ent = NULL) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	ent\DPP2CheckUpForGrabs(ply) if SERVER
	status = DPP2.ACCESS.CanPickup(ply, ent)
	return status if not status

GravGunPickupAllowed = (ply = NULL, ent = NULL) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	status = DPP2.ACCESS.CanGravgunPunt(ply, ent)
	return status if not status

PhysgunPickup = (ply = NULL, ent = NULL) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	ent\DPP2CheckUpForGrabs(ply) if SERVER
	status = DPP2.ACCESS.CanPhysgun(ply, ent)
	return status if not status
	ent\DPP2UnGhost(true) if SERVER
	return

OnPhysgunReload = (physgun = NULL, ply = NULL) ->
	return if not IsValid(ply)
	tr = ply\GetEyeTrace()
	return if not IsValid(tr.Entity)
	status = DPP2.ACCESS.CanPhysgun(ply, tr.Entity)
	return status if not status
	if SERVER
		tr.Entity\DPP2UnGhost(true)
		DPP2.APKTriggerPhysgunDrop(ply, tr.Entity)
		return

CanProperty = (ply = NULL, property, ent = NULL) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	ent\DPP2CheckUpForGrabs(ply) if SERVER
	error('Invalid property type. It must be a string! typeof' .. type(property)) if type(property) ~= 'string'
	status = DPP2.ACCESS.CanToolgun(ply, ent, property)
	return status if not status
	if SERVER
		ent\DPP2UnGhost(true)
		DPP2.APKTriggerPhysgunDrop(ply, ent)
		return

CanTool = (ply = NULL, tr = {HitPos: Vector(), Entity: NULL, HitNormal: Vector()}, mode) ->
	return if not IsValid(ply)
	return if not IsValid(tr.Entity)
	tr.Entity\DPP2CheckUpForGrabs(ply) if SERVER
	status = DPP2.ACCESS.CanToolgun(ply, tr.Entity, mode)
	return status if not status
	if SERVER
		tr.Entity\DPP2UnGhost(true)
		DPP2.APKTriggerPhysgunDrop(ply, tr.Entity)
		return

CanEditVariable = (ent = NULL, ply = NULL, key, val, editor = {}) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	ent\DPP2CheckUpForGrabs(ply) if SERVER
	status = DPP2.ACCESS.CanToolgun(ply, ent, 'edit')
	return status if not status

EntityTakeDamage = (dmginfo) =>
	return if @IsVehicle() or @IsNPC() or type(@) == 'NextBot' or @IsPlayer()
	attacker = dmginfo\GetAttacker()
	return if not IsValid(attacker)

	local owner

	if attacker\IsPlayer()
		owner = attacker
	else
		owner = attacker\DPP2GetOwner()

	if IsValid(owner)
		status = DPP2.ACCESS.CanDamage(owner, @)

		if not status
			@Extinguish()
			dmginfo\SetDamage(0)
			dmginfo\SetDamageCustom(0)
			dmginfo\SetDamageBonus(0)
			dmginfo\SetDamageType(0)
			dmginfo\SetDamageForce(vector_origin)
			dmginfo\SetReportedPosition(vector_origin)
			return status

hooksToReg = {
	:CanPlayerEnterVehicle, :CanDrive, :GravGunPunt
	:AllowPlayerPickup, :GravGunPickupAllowed, :PhysgunPickup
	:OnPhysgunReload, :CanProperty, :CanTool
	:CanEditVariable, :EntityTakeDamage
}

hook.Add(name, 'DPP2.ProtectionHooks', func, -4) for name, func in pairs(hooksToReg)
