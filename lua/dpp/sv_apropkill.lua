
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local EmptyVector = Vector()

function DPP.CheckDroppedEntity(ply, ent)
	if not DPP.GetConVar('apropkill_enable') then return end
	if not DPP.GetConVar('prevent_player_stuck') then return end
	if ent:IsPlayer() then return end
	
	for k, v in pairs(player.GetAll()) do
		if v == ply then continue end
		if v:InVehicle() then continue end
		if DPP.IsPlayerInEntity(v, ent) then
			local can = hook.Run('DPP_A_StuckHit', ply, ent, v)
			if can == false then continue end
			
			DPP.Notify(ply, 'Your prop is stuck in other player')
			DPP.SetGhosted(ent, true)
			break
		end
	end
end

local function CanTool(ply, tr)
	--This hook must be runned after DPP protection module
	if not IsValid(tr.Entity) then return end
	
	local can = hook.Run('DPP_A_StuckCheck', ply, tr.Entity)
	if can == false then return end
	
	DPP.CheckDroppedEntity(ply, tr.Entity)
end

local WhitelistProps = {
	['func_door'] = true,
	['prop_door_rotating'] = true,
}

local function EntityTakeDamage(ent, dmg)
	if not DPP.GetConVar('apropkill_enable') then return end
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
			end
		end
		
		if IsValid(inflictor) and inflictor:IsVehicle() then
			if inflictor:GetSolid() ~= SOLID_NONE and (inflictor:GetCollisionGroup() == COLLISION_GROUP_NONE or inflictor:GetCollisionGroup() == COLLISION_GROUP_VEHICLE) then
				inflictor:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
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
	
	if cond then
		dmg:SetDamage(0)
		dmg:SetDamageForce(EmptyVector)
		dmg:SetDamageType(DMG_GENERIC)
	end
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

hook.Add('EntityTakeDamage', '!DPP.APropKill', EntityTakeDamage, -1)
hook.Add('Think', 'DPP.APropKill', Think)
hook.Add('PhysgunDrop', 'DPP.APropKill', PhysgunDrop)
hook.Add('PhysgunPickup', 'DPP.APropKill', PhysgunPickup)
hook.Add('PlayerSpawnedVehicle', 'DPP.APropKill', PlayerSpawnedVehicle)
hook.Add('PlayerEnteredVehicle', 'DPP.APropKill', PlayerEnteredVehicle)
hook.Add('CanTool', 'DPP.APropKill', CanTool, 2) --Extra low priority if we have UHook (ULib's Hook)/DHook installed
hook.Add('PhysgunDrop', 'DPP.PreventPlayerStuck', DPP.CheckDroppedEntity)
