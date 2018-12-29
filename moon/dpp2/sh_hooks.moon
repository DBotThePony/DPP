
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

import DPP2, type, table, hook from _G
import IsValid from FindMetaTable('Entity')

CheckupEntity = (ent, field, ...) ->

CanPlayerEnterVehicle = (ply = NULL, vehicle = NULL, role = 0) ->
	return if not IsValid(ply)
	return if not IsValid(vehicle)
	status = DPP2.ACCESS.CanUseVehicle(ply, vehicle)
	return status if not status

CanDrive = (ply = NULL, ent = NULL) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	status = DPP2.ACCESS.CanDrive(ply, ent)
	return status if not status

GravGunPunt = (ply = NULL, ent = NULL) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	status = DPP2.ACCESS.CanGravgun(ply, ent)
	return status if not status

AllowPlayerPickup = (ply = NULL, ent = NULL) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	status = DPP2.ACCESS.CanPickup(ply, ent)
	return status if not status

GravGunPickupAllowed = (ply = NULL, ent = NULL) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	status = DPP2.ACCESS.CanGravgun(ply, ent)
	return status if not status

PhysgunPickup = (ply = NULL, ent = NULL) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	status = DPP2.ACCESS.CanPhysgun(ply, ent)
	return status if not status

OnPhysgunReload = (physgun = NULL, ply = NULL) ->
	return if not IsValid(ply)
	tr = ply\GetEyeTrace()
	return if not IsValid(tr.Entity)
	status = DPP2.ACCESS.CanPhysgun(ply, tr.Entity)
	return status if not status

CanProperty = (ply = NULL, property, ent = NULL) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	error('Invalid property type. It must be a string! typeof' .. type(property)) if type(property) ~= 'string'
	status = DPP2.ACCESS.CanToolgun(ply, ent, property)
	return status if not status

CanTool = (ply = NULL, tr = {HitPos: Vector(), Entity: NULL, HitNormal: Vector()}, mode) ->
	return if not IsValid(ply)
	return if not IsValid(tr.Entity)
	status = DPP2.ACCESS.CanToolgun(ply, tr.Entity, mode)
	return status if not status

CanEditVariable = (ent = NULL, ply = NULL, key, val, editor = {}) ->
	return if not IsValid(ply)
	return if not IsValid(ent)
	status = DPP2.ACCESS.CanToolgun(ply, ent, 'edit')
	return status if not status

hooksToReg = {
	:CanPlayerEnterVehicle, :CanDrive, :GravGunPunt
	:AllowPlayerPickup, :GravGunPickupAllowed, :PhysgunPickup
	:OnPhysgunReload, :CanProperty, :CanTool
	:CanEditVariable
}

hook.Add(name, 'DPP2.ProtectionHooks', func, -4) for name, func in pairs(hooksToReg)
