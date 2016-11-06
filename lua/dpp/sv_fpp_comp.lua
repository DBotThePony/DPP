
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

-- FPP Funcs compability

if FPP then return end

FPP = {}
FPP.AntiSpam = {}
FPP.Protect = {}

function FPP.plyCanTouchEnt(ply, ent, type)
	if not type then --We are ignoring type
		return DPP.CanTouch(ply, ent)
	end

	if type == 'Physgun' then
		return DPP.CanPhysgun(ply, ent)
	elseif type == 'Gravgun' then
		return DPP.CanGravgun(ply, ent)
	elseif type == 'Toolgun' then
		return DPP.CanTool(ply, ent, '')
	elseif type == 'PlayerUse' then
		return DPP.PlayerUse(ply, ent)
	elseif type == 'EntityDamage' then
		return DPP.CanDamage(ply, ent)
	end

	return DPP.CanTouch(ply, ent)
end

concommand.Add('FPP_AddBlockedModel', function(ply, cmd, args)
	DPP.ManipulateCommands.addblockedmodel(ply, cmd, args)
end)

concommand.Add('FPP_RemoveBlockedModel', function(ply, cmd, args)
	DPP.ManipulateCommands.removeblockedmodel(ply, cmd, args)
end)

function FPP.AntiSpam.GhostFreeze(ent, phys) --phys arg is ignored
	DPP.SetGhosted(ent, true)
end

function FPP.UnGhost(ply, ent) --phys arg is ignored
	if DPP.GetGhosted(ent) then
		DPP.SetGhosted(ent, false)
	end
end

function FPP.AntiSpam.CreateEntity(ply, ent, IsDuplicate)
	DPP.SpawnFunctions.CheckAfter(ply, ent, nil, IsDuplicate)
	DPP.SetOwner(ent, ply)
end

function FPP.AntiSpam.DuplicatorSpam(ply)
	return true --ugh
end

--Protection

function FPP.Protect.PhysgunPickup(ply, ent)
	return DPP.PhysgunPickup(ply, ent)
end

function FPP.Protect.PhysgunReload(weapon, ply)
	return DPP.OnPhysgunReload(phys, ply)
end

function FPP.Protect.GravGunPickup(ply, ent)
	return DPP.CanGravgun(ply, ent)
end

function FPP.Protect.GravGunPunt(ply, ent)
	return DPP.CanGravgunPunt(ply, ent)
end

function FPP.Protect.PlayerUse(ply, ent)
	return DPP.PlayerUse(ply, ent)
end

function FPP.Protect.EntityDamage(ent, dmginfo)
	local ply = dmginfo:GetAttacker()
	if not IsValid(ply) then return end
	if not ply:IsPlayer() then return end
	return DPP.CanDamage(ply, ent)
end

function FPP.Protect.CanTool(ply, trace, tool, ENT)
	return DPP.CanTool(ply, trace.Entity, tool)
end

function FPP.Protect.CanProperty(ply, property, ent)
	return DPP.CanProperty(ply, property, ent)
end

function FPP.Protect.CanDrive(ply, ent)
	return DPP.CanDrive(ply, ent)
end

function FPP.PlayerDisconnect(ply)
	DPP.PlayerDisconnected(ply)
end

function FPP.PlayerInitialSpawn(ply)
	DPP.PlayerInitialSpawn(ply)
end
