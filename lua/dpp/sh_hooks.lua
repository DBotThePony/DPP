
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

local GRAY = Color(200, 200, 200)
local RED = Color(255, 0, 0)

function DPP.CanDamage(ply, ent, ignoreEnt)
	if not DPP.GetConVar('enable_damage') then return true end
	if DPP.IsEntityBlockedDamage(ent:GetClass()) then 
		return false, 'Damage blocked'
	end
	
	if DPP.IsEntityWhitelistedDamage(ent:GetClass()) then
		return true, 'Damage allowed (Excluded)'
	end
	
	local type = DPP.GetEntityType(ent)
	DPP.UpdateConstrainedWith(ent)
	local with = DPP.GetConstrainedWith(ent)
	
	local adv = DPP.GetConVar('allow_damage_vehicles')
	local ads = DPP.GetConVar('allow_damage_sent')
	local adn = DPP.GetConVar('allow_damage_npc')
	
	if type == 'vehicle' and adv then return nil, 'Damage allowed' end
	if type == 'sent' and DPP.IsOwned(ent) and ads then return nil, 'Damage allowed' end
	if type == 'npc' and adn then return nil, 'Damage allowed' end
	
	ignoreEnt = ignoreEnt or {}
	
	for k, v in pairs(with) do
		if k == ent then continue end
		if table.HasValue(ignoreEnt, k) then continue end
		
		table.insert(ignoreEnt, ent)
		local can, Reason = DPP.CanDamage(ply, k, ignoreEnt)
		
		if can ~= false then
			return nil, Reason
		end
	end
	
	return DPP.CanTouch(ply, ent, 'damage')
end

function DPP.PhysgunTouch(ply, ent)
	if SERVER then DPP.CheckUpForGrabs(ent, ply) end
	if DPP.PhysgunPickup(ply, ent) == false then return false end
	if SERVER and DPP.GetGhosted(ent) then DPP.SetGhosted(ent, false) end
end

function DPP.GravGunPuntTouch(ply, ent)
	if SERVER then DPP.CheckUpForGrabs(ent, ply) end
	
	if DPP.CanGravgunPunt(ply, ent) == false then return false end
	
	if SERVER and DPP.GetGhosted(ent) then DPP.SetGhosted(ent, false) end
end

function DPP.GravgunTouch(ply, ent)
	if DPP.CanGravgun(ply, ent) == false then return false end
	--[[if SERVER then 
		DPP.CheckUpForGrabs(ent, ply)
		if DPP.GetGhosted(ent) then DPP.SetGhosted(ent, false) end
	end]]
end

function DPP.PhysgunReloadTouch(phys, ply)
	local ent = ply:GetEyeTrace().Entity
	
	if SERVER then
		DPP.CheckUpForGrabs(ent, ply)
	end
	
	if DPP.OnPhysgunReload(phys, ply) == false then return false end
	
	if SERVER and DPP.GetGhosted(ent) then DPP.SetGhosted(ent, false) end
end

function DPP.ToolgunTouch(ply, tr, mode)
	if DPP.GetConVar('antispam_toolgun_enable') then
		local val = DPP.GetConVar('antispam_toolgun')
		ply._DPP_LastToolgunUse = ply._DPP_LastToolgunUse or 0
		
		local CTime = CurTime()
		local Should = false
		
		--Some addons (such as wiremod) calls CanTool after player toolgun it's entity (for example, Expression 2)
		for i = 3, 8 do
			local Name, Value = debug.getlocal(i, 1)
			if not Name then break end
			if not isentity(Value) then continue end
			if not IsValid(Value) then continue end
			if not Value:IsWeapon() then continue end
			Should = true
			break
		end
		
		if Should and CTime + val ~= ply._DPP_LastToolgunUse then
			if ply._DPP_LastToolgunUse > CTime then return false end
			ply._DPP_LastToolgunUse = CTime + val
		end
	end
	
	if SERVER then DPP.CheckUpForGrabs(tr.Entity, ply) end
	
	if DPP.CanTool(ply, tr.Entity, mode) == false then 
		if SERVER then
			ply._DPP_LastToolgunLog = ply._DPP_LastToolgunLog or 0
			if not DPP.GetConVar('no_tool_log') and not DPP.GetConVar('no_tool_fail_log') and ply._DPP_LastToolgunLog < CurTime() then
				ply._DPP_LastToolgunLog = CurTime() + 0.2
				local logFunc = not DPP.GetConVar('no_tool_log_echo') and DPP.SimpleLog or DPP.LogIntoFile
				logFunc(ply, DPP.SpawnFunctions.SPACE, RED, ' tried ', GRAY, 'to use tool ', DPP.SpawnFunctions.SPACE2, string.format('%s on %s', mode, tostring(tr.Entity)))
			end
		end
		
		return false 
	end
	
	if SERVER then
		if DPP.GetGhosted(tr.Entity) then DPP.SetGhosted(tr.Entity, false) end
		ply._DPP_LastToolgunLog = ply._DPP_LastToolgunLog or 0
		
		if not DPP.GetConVar('no_tool_log') and ply._DPP_LastToolgunLog < CurTime() then 
			ply._DPP_LastToolgunLog = CurTime() + 0.2
			local logFunc = not DPP.GetConVar('no_tool_log_echo') and DPP.SimpleLog or DPP.LogIntoFile
			logFunc(ply, DPP.SpawnFunctions.SPACE, GRAY, ' used/tried to use tool ', DPP.SpawnFunctions.SPACE2, color_white, mode, GRAY, ' on ', tostring(tr.Entity)) 
		end
	end
end

function DPP.UseTouch(ply, ent)
	if SERVER then DPP.CheckUpForGrabs(ent, ply) end
	
	if DPP.PlayerUse(ply, ent) == false then return false end
	
	if SERVER and DPP.GetGhosted(ent) then DPP.SetGhosted(ent, false) end
end

function DPP.PropertyTouch(ply, str, ent)
	if SERVER then DPP.CheckUpForGrabs(ent, ply) end
	
	if DPP.CanProperty(ply, str, ent) == false then return false end
	
	if SERVER and DPP.GetGhosted(ent) then DPP.SetGhosted(ent, false) end
end

function DPP.CanPhysgun(ply, ent)
	if not DPP.GetConVar('enable_physgun') then return true end
	
	if DPP.IsEntityBlockedPhysgun(ent:GetClass(), ply) then 
		return false, 'Entity is blacklisted'
	end
	
	if DPP.IsEntityWhitelistedPhysgun(ent:GetClass()) then
		return true, 'Entity is excluded'
	end
	
	return DPP.CanTouch(ply, ent, 'physgun')
end

function DPP.PhysgunPickup(ply, ent)
	if ent:IsPlayer() then 
		if DPP.PlayerConVar(ply, 'no_player_touch', false) then return false end
		return
	end
	
	return DPP.CanPhysgun(ply, ent)
end

function DPP.CanGravgun(ply, ent)
	if not DPP.GetConVar('enable_gravgun') then return true end
	
	if DPP.IsEntityBlockedGravgun(ent:GetClass(), ply) then
		return false
	end
	
	if DPP.IsEntityWhitelistedGravgun(ent:GetClass()) then
		return true, 'Entity is excluded'
	end
	
	if DPP.GetConVar('disable_gravgun_world') and not DPP.IsOwned(ent) then
		return true
	end
	
	return DPP.CanTouch(ply, ent, 'gravgun')
end

function DPP.CanGravgunPunt(ply, ent)
	if DPP.GetConVar('player_cant_punt') then return false end
	return DPP.CanGravgun(ply, ent)
end

function DPP.OnPhysgunReload(phys, ply, ignoreConnected, ent)
	if not DPP.GetConVar('enable_physgun') then return end
	ent = ent or ply:GetEyeTrace().Entity
	
	local can, reason = DPP.CanTouch(ply, ent, 'physgun')
	if not can then return can, reason end
	
	if SERVER then
		if not ignoreConnected then
			local Connected = DPP.GetAllConnectedEntities(ent)
			
			for k, v in pairs(Connected) do
				DPP.OnPhysgunReload(phys, ply, true, v)
			end
		end
	end
end

local ropeModes = {
	['rope'] = true,
	['pulley'] = true,
	['slider'] = true,
	['weld'] = true,
	['hydraulic'] = true,
	['elastic'] = true,
	['muscle'] = true,
}

function DPP.CanTool(ply, ent, mode)
	if not DPP.GetConVar('enable_tool') then return end
	DPP.AssertArguments('DPP.CanTool', {{ply, 'Player'}, {ent, 'AnyEntity'}, {mode, 'string'}})
	
	if DPP.IsRestrictedTool(mode, ply) then 
		return false, 'Restricted Tool' 
	end
	
	if not IsValid(ent) then 
		if DPP.GetConVar('no_rope_world') then
			if (mode and ropeModes[mode]) and not (not DPP.GetConVar('no_rope_world_weld') and mode == 'weld') then
				return false, 'No rope world'
			end
		end
		
		if mode and DPP.IsEntityBlockedToolgunWorld(mode, ply) then
			return false, 'Toolgun on world is blocked'
		end
		
		return true
	end
	
	if DPP.IsEntityBlockedTool(ent:GetClass(), ply) then
		return false, 'Toolgun blocked'
	end
	
	if mode ~= 'remover' and DPP.IsEntityWhitelistedTool(ent:GetClass()) then
		return true, 'Entity is excluded'
	end
	
	if mode and DPP.IsEntityWhitelistedToolMode(mode) then
		return true, 'Tool mode is excluded'
	end
	
	if ent:IsPlayer() then
		local can1 = DPP.GetConVar('toolgun_player')
		local can2 = DPP.GetConVar('toolgun_player_admin')
		
		if ply:IsAdmin() then
			if can2 then return false, 'Cannot toolgun player' end
		else
			if can1 then return false, 'Cannot toolgun player' end
		end
	end
	
	return DPP.CanTouch(ply, ent, 'toolgun')
end

function DPP.CanPlayerEnterVehicle(ply, ent)
	if not DPP.GetConVar('enable_veh') then return end
	DPP.AssertArguments('DPP.CanPlayerEnterVehicle', {{ply, 'Player'}, {ent, 'AnyEntity'}})
	if ent.IgnoreVehicleProtection then return end
	if not DPP.IsOwned(ent) then return end
	
	local reply = DPP.CanTouch(ply, ent, 'vehicle')
	if not reply then return false end
end

function DPP.CanEditVariable(ent, ply, key, val, editor)
	if not DPP.GetConVar('enable_tool') then return end
	DPP.AssertArguments('DPP.CanEditVariable', {{ent, 'AnyEntity'}, {ply, 'Player'}})
	local reply = DPP.CanTool(ply, ent, '')
	if not reply then return false end
end

function DPP.CanProperty(ply, str, ent)
	if string.sub(str, 1, 4) == 'dpp.' then return true end
	if not DPP.GetConVar('enable_tool') then return true end
	DPP.AssertArguments('DPP.CanProperty', {{ply, 'Player'}, {str, 'string'}, {ent, 'AnyEntity'}})
	
	--Make check before
	if DPP.IsEntityBlockedTool(ent:GetClass(), ply) then
		return false
	end
	
	if DPP.IsRestrictedProperty(str, ply) then 
		return false 
	end
	
	if DPP.IsEntityWhitelistedPropertyType(str) then
		return true
	end
	
	if str ~= 'remover' and DPP.IsEntityWhitelistedProperty(ent:GetClass()) then
		return true
	end
	
	local reply = DPP.CanTool(ply, ent, '')
	if not reply then return false end
end

function DPP.PlayerUse(ply, ent)
	if not DPP.GetConVar('enable_use') then return true end
	if not DPP.IsOwned(ent) then return true end
	DPP.AssertArguments('DPP.PlayerUse', {{ply, 'Player'}, {ent, 'AnyEntity'}})
	
	if DPP.IsEntityBlockedUse(ent:GetClass(), ply) then
		return false
	end
	
	if DPP.IsEntityWhitelistedUse(ent:GetClass()) then
		return true
	end
	
	return DPP.CanTouch(ply, ent, 'use')
end

function DPP.CanDrive(ply, ent)
	if not DPP.GetConVar('enable_drive') then return end
	DPP.AssertArguments('DPP.CanDrive', {{ply, 'Player'}, {ent, 'AnyEntity'}})
	local reply = DPP.CanPhysgun(ply, ent) --I will mean Drive as Physgun
	if reply == false then return false end
end

DPP.CanDrive = DPP.Wrap(DPP.CanDrive)
DPP.CanDamage = DPP.Wrap(DPP.CanDamage, true)
DPP.CanPhysgun = DPP.Wrap(DPP.CanPhysgun, true)
DPP.CanProperty = DPP.Wrap(DPP.CanProperty, true)
DPP.CanGravgun = DPP.Wrap(DPP.CanGravgun, true)
DPP.CanGravgunPunt = DPP.Wrap(DPP.CanGravgunPunt, true)
DPP.OnPhysgunReload = DPP.Wrap(DPP.OnPhysgunReload, true)
DPP.CanTool = DPP.Wrap(DPP.CanTool, true)
DPP.CanEditVariable = DPP.Wrap(DPP.CanEditVariable)
DPP.CanPlayerEnterVehicle = DPP.Wrap(DPP.CanPlayerEnterVehicle)
DPP.PlayerUse = DPP.Wrap(DPP.PlayerUse, true)

--Maximal Priority
hook.Add('GravGunPunt', '!DPP.Hooks', DPP.GravGunPuntTouch, -1)
hook.Add('OnPhysgunReload', '!DPP.Hooks', DPP.PhysgunReloadTouch, -1)
hook.Add('GravGunPickupAllowed', '!DPP.Hooks', DPP.GravgunTouch, -1)
hook.Add('PhysgunPickup', '!DPP.Hooks', DPP.PhysgunTouch, -1)
hook.Add('CanProperty', '!DPP.Hooks', DPP.PropertyTouch, -1)
hook.Add('CanTool', '!DPP.Hooks', DPP.ToolgunTouch, -1)
hook.Add('PlayerUse', '!DPP.Hooks', DPP.UseTouch, -1)

hook.Add('CanDrive', '!DPP.Hooks', DPP.CanDrive, -1)
hook.Add('CanEditVariable', '!DPP.Hooks', DPP.CanEditVariable, -1)
hook.Add('CanPlayerEnterVehicle', '!DPP.Hooks', DPP.CanPlayerEnterVehicle, -1)

function DPP.OverrideE2Adv()
	if not EXPADV then return end
	local Compiler = EXPADV.Compiler
	if not Compiler then return end
	
	DPP.Message('Detected E2 Advanced, overriding.')
	--Hello E2 Advanced
	DPP.__EXPADV_CreateCompiler = DPP.__EXPADV_CreateCompiler or EXPADV.CreateCompiler
	DPP.__EXPADV_Compile_FUNC = DPP.__EXPADV_Compile_FUNC or Compiler.Compile_FUNC
	
	function EXPADV.CreateCompiler(Script, Files)
		local self = DPP.__EXPADV_CreateCompiler(Script, Files)
		local name, Ent = debug.getlocal(3, 1)
		
		if isentity(Ent) and IsValid(Ent) then
			self.DPly = DPP.GetOwner(Ent)
		end
		
		return self
	end
	
	function Compiler:Compile_FUNC(Trace, Variable, Expressions)
		if self.DPly then
			if DPP.IsRestrictedE2AFunction(Variable, self.DPly) then
				if SERVER then
					DPP.Notify(self.DPly, "(SERVERSIDE) DPP: Restricted Function: " .. Variable .. "()", 1)
				end
				
				self:TraceError(Trace, "DPP: Restricted Function: %s()", Variable)
			end
		end
		
		return DPP.__EXPADV_Compile_FUNC(self, Trace, Variable, Expressions)
	end
end

function DPP.OverrideCounts()
	local plyMeta = FindMetaTable('Player')
	if not plyMeta then return end
	if not plyMeta.CheckLimit then return end --Not sandbox
	
	DPP.Message('Overriding Player.GetCount Player.CheckLimit')
	DPP.oldCheckLimit = DPP.oldCheckLimit or plyMeta.CheckLimit
	
	function plyMeta:CheckLimit(str)
		local limit = DPP.GetSBoxLimit(str, self:GetUserGroup())
		if limit == 0 then return DPP.oldCheckLimit(self, str) end
		if limit < 0 then return true end
		
		local C = self:GetCount(str)
		if C >= limit then self:LimitHit(str) return false end
		
		return DPP.oldCheckLimit(self, str)
	end
end

function DPP.ReplaceSharedFunctions()
	DPP.Message('Overriding shared functions')
	DPP.OverrideE2Adv()
	DPP.OverrideCounts()
	
	if CLIENT then DPP.ReplacePropertyFuncs() end
end

timer.Simple(0, DPP.ReplaceSharedFunctions)
