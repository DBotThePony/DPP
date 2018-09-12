
--[[
Copyright (C) 2016-2017 DBot


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

]]

local EmptyVector = Vector()

function DPP.CheckDroppedEntity(ply, ent)
	if not DPP.GetConVar('apropkill_enable') then return end
	if not DPP.GetConVar('prevent_player_stuck') then return end
	if ent:IsPlayer() then return end

	for k, v in pairs(player.GetAll()) do
		if v == ply then continue end
		if v:InVehicle() then continue end
		if not DPP.IsPlayerInEntity(v, ent) then continue end
		local can = hook.Run('DPP_A_StuckHit', ply, ent, v)
		if can == false then continue end

		timer.Simple(0, function()
			DPP.Notify(ply, '#prop_stuck_in_player')
			DPP.SetGhosted(ent, true)
		end)

		break
	end
end

local function CanTool(ply, tr, mode)
	--This hook must be runned after DPP protection module
	if not IsValid(tr.Entity) then return end

	local can = hook.Run('DPP_A_StuckCheck', ply, tr.Entity)
	if can == false then return end

	if not DPP.CanTool(ply, tr.Entity, mode) then return end

	DPP.CheckDroppedEntity(ply, tr.Entity)
end

local WhitelistProps = {
	['func_door'] = true,
	['prop_door_rotating'] = true,
	['prop_door'] = true,
}

local GRAY = Color(200, 200, 200)

local function ProceedCrush(ent, dmg)
	if not DPP.IsOwned(ent) then return end
	if ent == dmg:GetAttacker() then return end
	if ent:IsRagdoll() and not IsValid(dmg:GetAttacker()) then return end
	if not ent:IsRagdoll() and IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsRagdoll() then return end

	ent._DPP_LastPhysicsDamage = ent._DPP_LastPhysicsDamage or 0
	ent._DPP_LastPhysicsDamage_Counter = ent._DPP_LastPhysicsDamage_Counter or 0

	if ent._DPP_LastPhysicsDamage + 1 < CurTime() then
		ent._DPP_LastPhysicsDamage_Counter = 0
	end

	ent._DPP_LastPhysicsDamage = CurTime()

	ent._DPP_LastPhysicsDamage_Counter = ent._DPP_LastPhysicsDamage_Counter + 1

	if ent._DPP_LastPhysicsDamage_Counter > 5 then
		DPP.SimpleLog('#crazy_physics', color_white, tostring(ent), GRAY, '#crazy_physics2', DPP.GetOwner(ent), GRAY, '#crazy_physics3')
		DPP.SetGhosted(ent, true)
	end
end

local function ProceedCrushingChecks(ent, dmg)
	if ent:IsNPC() or ent:IsPlayer() or ent:IsVehicle() then return end
	if ent:GetClass():sub(1, 5) ~= 'prop_' then return end
	if dmg:GetDamageType() ~= DMG_CRUSH then return end
	local attacker, inflictor = dmg:GetAttacker(), dmg:GetInflictor()

	ProceedCrush(ent, dmg)

	if ent:GetClass() ~= 'prop_physics' or not IsValid(dmg:GetAttacker()) or not dmg:GetAttacker():IsRagdoll() then
		if IsValid(attacker) and attacker:GetClass():sub(1, 5) == 'prop_' and not attacker:IsNPC() and not attacker:IsPlayer() and not attacker:IsVehicle() then
			ProceedCrush(attacker, dmg)
		end

		if inflictor ~= attacker and IsValid(inflictor) and inflictor:GetClass():sub(1, 5) == 'prop_' and not inflictor:IsNPC() and not inflictor:IsPlayer() and not inflictor:IsVehicle() then
			ProceedCrush(inflictor, dmg)
		end
	end
end

local function EntityTakeDamage(ent, dmg)
	if not DPP.GetConVar('apropkill_enable') then return end

	if DPP.GetConVar('apropkill_crash') then
		ProceedCrushingChecks(ent, dmg)
	end

	if not DPP.GetConVar('apropkill_damage') then return end
	if not ent:IsPlayer() then return end

	local can = hook.Run('DPP_A_EntityTakeDamage', ent, dmg)
	if can == false then return end

	local attacker = dmg:GetAttacker()
	local inflictor = dmg:GetInflictor()

	if DPP.GetConVar('apropkill_vehicle') then
		if IsValid(attacker) and attacker:IsVehicle() then
			if attacker:GetSolid() ~= SOLID_NONE and (attacker:GetCollisionGroup() == COLLISION_GROUP_NONE or attacker:GetCollisionGroup() == COLLISION_GROUP_VEHICLE) then
				attacker:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
				dmg:SetDamage(0)
			end
		end

		if IsValid(inflictor) and inflictor:IsVehicle() then
			if inflictor:GetSolid() ~= SOLID_NONE and (inflictor:GetCollisionGroup() == COLLISION_GROUP_NONE or inflictor:GetCollisionGroup() == COLLISION_GROUP_VEHICLE) then
				inflictor:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
				dmg:SetDamage(0)
			end
		end
	end

	local aValid = IsValid(attacker)
	local iValid = IsValid(inflictor)

	local Aclass = aValid and attacker:GetClass()
	local Iclass = iValid and inflictor:GetClass()

	local cond = dmg:GetDamageType() == DMG_CRUSH and ((not Aclass or not WhitelistProps[Aclass]) and (not Iclass or not WhitelistProps[Iclass])) or
		(dmg:GetDamageType() == DMG_VEHICLE and DPP.GetConVar('apropkill_damage_vehicle')) or
		(Aclass == 'prop_physics' or Aclass == 'prop_ragdoll' or Aclass == 'prop_physics_multiplayer') or
		(Iclass == 'prop_physics' or Iclass == 'prop_ragdoll' or Iclass == 'prop_physics_multiplayer')

	if DPP.GetConVar('apropkill_damage_noworld') then
		if not aValid and attacker ~= NULL and not dmg:IsFallDamage() then --Worldspawn, sometimes player getting hit from prop that's attacker and inflictor set to worldspawn
			cond = true
		end

		if aValid and not IsValid(DPP.GetOwner(attacker)) then --Logic or map entity
			if not iValid or not IsValid(DPP.GetOwner(inflictor)) then
				cond = false
			end
		end
	end

	if not cond then return end

	local can = hook.Run('DPP_A_EntityTakeDamage_Hit', ent, dmg)
	if can == false then return end

	dmg:SetDamage(0)
	dmg:SetDamageForce(EmptyVector)
	dmg:SetDamageType(DMG_GENERIC)
end

local function PlayerSpawnedVehicle(ply, ent)
	if not DPP.GetConVar('apropkill_enable') then return end
	if not DPP.GetConVar('apropkill_vehicle') then return end

	local can = hook.Run('DPP_A_PlayerSpawnedVehicle', ply, ent)
	if can == false then return end

	if ent:GetSolid() == SOLID_NONE then return end

	if ent:GetCollisionGroup() == COLLISION_GROUP_VEHICLE or ent:GetCollisionGroup() == COLLISION_GROUP_NONE then
		ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	end
end

local function PlayerEnteredVehicle(ply, ent)
	if not DPP.GetConVar('apropkill_enable') then return end
	if not DPP.GetConVar('apropkill_vehicle') then return end

	local can = hook.Run('DPP_A_PlayerEnteredVehicle', ply, ent)
	if can == false then return end

	if ent:GetSolid() == SOLID_NONE then return end

	if ent:GetCollisionGroup() == COLLISION_GROUP_VEHICLE or ent:GetCollisionGroup() == COLLISION_GROUP_NONE then
		ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	end
end

local HoldingEntities = {}

local Ignore = {
	COLLISION_GROUP_WORLD,
	COLLISION_GROUP_WEAPON,
	COLLISION_GROUP_DEBRIS,
	COLLISION_GROUP_DEBRIS_TRIGGER,
	COLLISION_GROUP_DISSOLVING,
	COLLISION_GROUP_IN_VEHICLE,
	COLLISION_GROUP_VEHICLE_CLIP,
}

local function PhysgunPickup(ply, ent)
	if not DPP.GetConVar('apropkill_enable') then return end
	if ent:IsPlayer() or ent:IsNPC() then return end

	local can = hook.Run('DPP_A_PhysgunPickup', ply, ent)
	if can == false then return end

	if not DPP.CanPhysgun(ply, ent) then return end --Feck

	HoldingEntities[ent] = HoldingEntities[ent] or ent:GetCollisionGroup()

	if DPP.GetConVar('apropkill_nopush') then
		if not DPP.GetConVar('apropkill_nopush_mode') then
			if not table.HasValue(Ignore, HoldingEntities[ent]) then
				ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			end
		else
			ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		end
	end
end

local function PhysgunDrop(ply, ent)
	if not DPP.GetConVar('apropkill_enable') then return end
	if not IsValid(ent) then return end --Dropping deleted entity
	if ent:IsPlayer() or ent:IsNPC() then return end

	local can = hook.Run('DPP_A_PhysgunDrop', ply, ent)
	if can == false then return end

	if DPP.GetConVar('apropkill_nopush') then
		if HoldingEntities[ent] then
			ent:SetCollisionGroup(HoldingEntities[ent])
		end
	end

	HoldingEntities[ent] = nil
	ent._DPP_PhysGunLastPos = nil

	local phys = ent:GetPhysicsObject()

	if IsValid(phys) then
		if DPP.GetConVar('prevent_prop_throw') then
			phys:SetVelocity(EmptyVector)
		else
			if ent._DPP_PhysGunDropVelocity then
				phys:SetVelocity(ent._DPP_PhysGunDropVelocity)
				ent._DPP_PhysGunDropVelocity = nil
			end
		end
	end
end

local function Think()
	if not DPP.GetConVar('apropkill_enable') then return end

	local CLAMP_VALUE = DPP.GetConVar('apropkill_clampspeed_val') * FrameTime() * 33

	for ent, collision in pairs(HoldingEntities) do
		if not IsValid(ent) then
			HoldingEntities[ent] = nil
			continue
		end

		if DPP.GetConVar('apropkill_nopush') then
			local group = ent:GetCollisionGroup()

			if not DPP.GetConVar('apropkill_nopush_mode') then
				if not table.HasValue(Ignore, group) and group ~= COLLISION_GROUP_PASSABLE_DOOR then
					ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
				end
			else
				if group ~= COLLISION_GROUP_WORLD then
					ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
				end
			end
		end

		if DPP.GetConVar('apropkill_clampspeed') then
			local phys = ent:GetPhysicsObject()
			local spos = ent:GetPos()

			ent._DPP_PhysGunLastPos = ent._DPP_PhysGunLastPos or spos

			local Dist = spos:Distance(ent._DPP_PhysGunLastPos)

			if IsValid(phys) then
				ent._DPP_PhysGunDropVelocity = phys:GetVelocity()
			end

			if Dist > CLAMP_VALUE then
				ent:SetPos(LerpVector(CLAMP_VALUE/Dist, ent._DPP_PhysGunLastPos, spos))
			end

			ent._DPP_PhysGunLastPos = ent:GetPos()
		end
	end
end

local function DetectAPG()
	if not APG_DRM then return end
	DPP.Message('-------------------------')
	DPP.Message('I <3 Noize')
	DPP.Message('APG Detected!')
	DPP.Message('DPP Anti-Propkill is getting disabled!')
	DPP.Message('-------------------------')

	RunConsoleCommand('dpp_setvar', 'apropkill_clampspeed', '0')
	RunConsoleCommand('dpp_setvar', 'apropkill_nopush', '0')
	RunConsoleCommand('dpp_setvar', 'apropkill_vehicle', '0')
	RunConsoleCommand('dpp_setvar', 'prevent_player_stuck', '0')
	RunConsoleCommand('dpp_setvar', 'apropkill_crash', '0')
	RunConsoleCommand('dpp_setvar', 'apropkill_damage', '0')
end

hook.Add('EntityTakeDamage', '!DPP.APropKill', EntityTakeDamage, -1)
hook.Add('Think', 'DPP.APropKill', Think)
hook.Add('PhysgunDrop', 'DPP.APropKill', PhysgunDrop)
hook.Add('PhysgunPickup', 'DPP.APropKill', PhysgunPickup)
hook.Add('PlayerSpawnedVehicle', 'DPP.APropKill', PlayerSpawnedVehicle)
hook.Add('PlayerEnteredVehicle', 'DPP.APropKill', PlayerEnteredVehicle)
hook.Add('CanTool', 'DPP.APropKill', CanTool, 2) --Extra low priority if we have UHook (ULib's Hook)/DHook installed
hook.Add('PhysgunDrop', 'DPP.PreventPlayerStuck', DPP.CheckDroppedEntity)
timer.Simple(5, DetectAPG)
