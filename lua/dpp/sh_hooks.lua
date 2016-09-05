
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

local function GiveEntityChance(ent, funcToCall, ...)
	local func = ent[funcToCall]
	
	if type(func) ~= 'function' then
		if type(func) == 'boolean' then return func end
		return nil
	end
	
	local stuff = {pcall(func, ...)}
	local status = table.remove(stuff, 1)
	
	if not status then
		DPP.DoEcho(RED, 'PHRASE:givechance_error', GRAY, 'PHRASE:givechance_Entity', color_white, tostring(ent), GRAY, 'PHRASE:givechance_desc||' .. funcToCall, color_white, stuff[1])
		return nil
	end
	
	return unpack(stuff, 1, #stuff)
end

function DPP.CanDamage(ply, ent, ignoreEnt)
	if not DPP.GetConVar('enable_damage') then return true end
	if DPP.IsEntityBlockedDamage(ent:GetClass()) then 
		return false, DPP.GetPhrase('damage_blocked')
	end

	if DPP.IsEntityWhitelistedDamage(ent:GetClass()) then
		return true, DPP.GetPhrase('entity_excluded_d')
	end
	
	local can = GiveEntityChance(ent, 'CanDamage', ply)
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end

	local type = DPP.GetEntityType(ent)
	DPP.UpdateConstrainedWith(ent)
	local with = DPP.GetConstrainedWith(ent)

	local adv = DPP.GetConVar('allow_damage_vehicles')
	local ads = DPP.GetConVar('allow_damage_sent')
	local adn = DPP.GetConVar('allow_damage_npc')

	if type == 'vehicle' and adv then return true, DPP.GetPhrase('damage_allowed') end
	if type == 'sent' and DPP.IsOwned(ent) and ads then return true, DPP.GetPhrase('damage_allowed') end
	if type == 'npc' and adn then return true, DPP.GetPhrase('damage_allowed') end

	ignoreEnt = ignoreEnt or {}

	for k, v in pairs(with) do
		if k == ent then continue end
		if table.HasValue(ignoreEnt, k) then continue end

		table.insert(ignoreEnt, ent)
		local can, Reason = DPP.CanDamage(ply, k, ignoreEnt)

		if can ~= false then
			return true, Reason
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
			if ply._DPP_LastToolgunUse > CTime then return false, DPP.GetPhrase('toolgun_antispam') end
			ply._DPP_LastToolgunUse = CTime + val
		end
	end

	if SERVER then DPP.CheckUpForGrabs(tr.Entity, ply) end
	
	local CAN, Reason = DPP.CanTool(ply, tr.Entity, mode)
	if CAN == false then 
		if SERVER then
			ply._DPP_LastToolgunLog = ply._DPP_LastToolgunLog or 0
			if not DPP.GetConVar('no_tool_log') and not DPP.GetConVar('no_tool_fail_log') and ply._DPP_LastToolgunLog < CurTime() then
				ply._DPP_LastToolgunLog = CurTime() + 0.2
				local logFunc = not DPP.GetConVar('no_tool_log_echo') and DPP.SimpleLog or DPP.LogIntoFile
				logFunc(ply, DPP.SpawnFunctions.SPACE, RED, 'PHRASE:log_tried', GRAY, 'PHRASE:log_tried_t', DPP.SpawnFunctions.SPACE2, 'PHRASE:log_tool_on_f||' .. mode .. '||' .. tostring(tr.Entity))
			end
		end

		return false, Reason
	end

	if SERVER then
		if DPP.GetGhosted(tr.Entity) then DPP.SetGhosted(tr.Entity, false) end
		ply._DPP_LastToolgunLog = ply._DPP_LastToolgunLog or 0

		if not DPP.GetConVar('no_tool_log') and ply._DPP_LastToolgunLog < CurTime() then 
			ply._DPP_LastToolgunLog = CurTime() + 0.2
			local logFunc = not DPP.GetConVar('no_tool_log_echo') and DPP.SimpleLog or DPP.LogIntoFile
			logFunc(ply, DPP.SpawnFunctions.SPACE, GRAY, 'PHRASE:log_tool_used', DPP.SpawnFunctions.SPACE2, color_white, mode, GRAY, 'PHRASE:log_tool_on', tostring(tr.Entity)) 
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
		return false, DPP.GetPhrase('physgun_blocked')
	end

	if DPP.IsEntityWhitelistedPhysgun(ent:GetClass()) then
		return true, DPP.GetPhrase('entity_excluded')
	end

	local can = GiveEntityChance(ent, 'PhysgunPickup', ply)
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end

	local can = GiveEntityChance(ent, 'CanPhysgun', ply) --DPP Owned method
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end

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
		return false, DPP.GetPhrase('gravgun_blocked')
	end

	if DPP.IsEntityWhitelistedGravgun(ent:GetClass()) then
		return true, DPP.GetPhrase('entity_excluded')
	end

	if DPP.GetConVar('disable_gravgun_world') and not DPP.IsOwned(ent) then
		return true
	end

	local can = GiveEntityChance(ent, 'GravGunPickupAllowed', ply)
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end

	local can = GiveEntityChance(ent, 'CanGravgun', ply) --DPP Owned method
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end

	local can = GiveEntityChance(ent, 'GravGunPickup', ply) --FPP like
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end

	return DPP.CanTouch(ply, ent, 'gravgun')
end

function DPP.CanGravgunPunt(ply, ent)
	if DPP.GetConVar('player_cant_punt') then return false end
	
	local can = GiveEntityChance(ent, 'CanGravgunPunt', ply)
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end
	
	local can = GiveEntityChance(ent, 'GravGunPunt', ply) --FPP like
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end
	
	return DPP.CanGravgun(ply, ent)
end

function DPP.OnPhysgunReload(phys, ply, ignoreConnected, ent)
	if not DPP.GetConVar('enable_physgun') then return end
	ent = ent or ply:GetEyeTrace().Entity

	local can, reason = DPP.CanTouch(ply, ent, 'physgun')
	if not can then return can, reason end
	
	local can = GiveEntityChance(ent, 'OnPhysgunReload', ply)
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end

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
	if not DPP.GetConVar('enable_tool') then return true, DPP.GetPhrase('protection_disabled') end
	DPP.AssertArguments('DPP.CanTool', {{ply, 'Player'}, {ent, 'AnyEntity'}, {mode, 'string'}})

	if DPP.IsRestrictedTool(mode, ply) then 
		return false, DPP.GetPhrase('restricted_tool')
	end

	if not IsValid(ent) then 
		if DPP.GetConVar('no_rope_world') then
			if ropeModes[mode] and not (not DPP.GetConVar('no_rope_world_weld') and mode == 'weld') then
				return false, DPP.GetPhrase('no_rope_world')
			end
		end

		if DPP.IsEntityBlockedToolgunWorld(mode, ply) then
			return false, DPP.GetPhrase('toolmode_blocked_world')
		end

		return true
	end

	if DPP.IsEntityBlockedTool(ent:GetClass(), ply) then
		return false, DPP.GetPhrase('toolgun_blocked')
	end

	if mode ~= 'remover' and DPP.IsEntityWhitelistedTool(ent:GetClass()) then
		return true, DPP.GetPhrase('entity_excluded')
	end

	if DPP.IsEntityWhitelistedToolMode(mode) then
		return true, DPP.GetPhrase('toolmode_excluded')
	end

	if ent:IsPlayer() then
		local can1 = DPP.GetConVar('toolgun_player')
		local can2 = DPP.GetConVar('toolgun_player_admin')

		if ply:IsAdmin() then
			if can2 then return false, DPP.GetPhrase('no_toolgun_player') end
		else
			if can1 then return false, DPP.GetPhrase('no_toolgun_player') end
		end
	end
	
	local can = GiveEntityChance(ent, 'CanTool', ply, mode)
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end

	return DPP.CanTouch(ply, ent, 'toolgun')
end

function DPP.CanPlayerEnterVehicleTouch(ply, ent)
	if SERVER then DPP.CheckUpForGrabs(ent, ply) end

	local reply, r = DPP.CanPlayerEnterVehicle(ply, ent)
	if not reply then return false, r end

	if SERVER and DPP.GetGhosted(ent) then DPP.SetGhosted(ent, false) end
end

function DPP.CanPlayerEnterVehicle(ply, ent)
	if not DPP.GetConVar('enable_veh') then return true, DPP.GetPhrase('protection_disabled') end
	DPP.AssertArguments('DPP.CanPlayerEnterVehicle', {{ply, 'Player'}, {ent, 'AnyEntity'}})
	if ent.IgnoreVehicleProtection then return true, DPP.GetPhrase('vehicle_protection_ignored') end
	if DPP.GetConVar('disable_veh_world') and not DPP.IsOwned(ent) then return true, DPP.GetPhrase('owned_by_world') end
	
	local can = GiveEntityChance(ent, 'CanPlayerEnterVehicle', ply)
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end

	return DPP.CanTouch(ply, ent, 'vehicle')
end

function DPP.CanEditVariableTouch(ent, ply, key, val, editor)
	if SERVER then DPP.CheckUpForGrabs(ent, ply) end

	local reply, r = DPP.CanEditVariable(ent, ply, key, val, editor)
	if not reply then return false, r end

	if SERVER and DPP.GetGhosted(ent) then DPP.SetGhosted(ent, false) end
end

function DPP.CanEditVariable(ent, ply, key, val, editor)
	if not DPP.GetConVar('enable_tool') then return true, DPP.GetPhrase('protection_disabled') end
	DPP.AssertArguments('DPP.CanEditVariable', {{ent, 'AnyEntity'}, {ply, 'Player'}})
	
	local can = GiveEntityChance(ent, 'CanEditVariable', ply)
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end
	
	return DPP.CanTool(ply, ent, '')
end

function DPP.CanProperty(ply, str, ent)
	if string.sub(str, 1, 4) == 'dpp.' then return true, DPP.GetPhrase('dpp_property') end
	if not DPP.GetConVar('enable_tool') then return true, DPP.GetPhrase('protection_disabled') end
	DPP.AssertArguments('DPP.CanProperty', {{ply, 'Player'}, {str, 'string'}, {ent, 'AnyEntity'}})

	--Make check before
	if DPP.IsEntityBlockedTool(ent:GetClass(), ply) then
		return false, DPP.GetPhrase('toolgun_blocked')
	end

	if DPP.IsRestrictedProperty(str, ply) then 
		return false, DPP.GetPhrase('property_restricted')
	end

	if DPP.IsEntityWhitelistedPropertyType(str) then
		return true, DPP.GetPhrase('property_excluded')
	end

	if str ~= 'remover' and DPP.IsEntityWhitelistedProperty(ent:GetClass()) then
		return true, DPP.GetPhrase('entity_excluded')
	end
	
	local can = GiveEntityChance(ent, 'CanProperty', ply, str)
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end

	return DPP.CanTool(ply, ent, str)
end

function DPP.PlayerUse(ply, ent)
	if not DPP.GetConVar('enable_use') then return true, DPP.GetPhrase('protection_disabled') end
	if DPP.GetConVar('disable_use_world') and not DPP.IsOwned(ent) then return true, DPP.GetPhrase('owned_by_world') end
	DPP.AssertArguments('DPP.PlayerUse', {{ply, 'Player'}, {ent, 'AnyEntity'}})

	if DPP.IsEntityBlockedUse(ent:GetClass(), ply) then
		return false, DPP.GetPhrase('use_blocked')
	end

	if DPP.IsEntityWhitelistedUse(ent:GetClass()) then
		return true, DPP.GetPhrase('entity_excluded')
	end
	
	local can = GiveEntityChance(ent, 'PlayerUse', ply)
	if can ~= nil then return can, DPP.GetPhrase('givechance_returned') end

	return DPP.CanTouch(ply, ent, 'use')
end

function DPP.CanDriveTouch(ply, ent)
	if SERVER then DPP.CheckUpForGrabs(ent, ply) end

	local reply, r = DPP.CanDrive(ply, ent)
	if reply == false then return false, r end

	if SERVER and DPP.GetGhosted(ent) then DPP.SetGhosted(ent, false) end
end

function DPP.CanDrive(ply, ent)
	if not DPP.GetConVar('enable_drive') then return true, DPP.GetPhrase('protection_disabled') end
	DPP.AssertArguments('DPP.CanDrive', {{ply, 'Player'}, {ent, 'AnyEntity'}})
	return DPP.CanPhysgun(ply, ent)
end

DPP.CanDrive = DPP.Wrap(DPP.CanDrive, true, 'protection_disabled')
DPP.CanDamage = DPP.Wrap(DPP.CanDamage, true, 'protection_disabled')
DPP.CanPhysgun = DPP.Wrap(DPP.CanPhysgun, true, 'protection_disabled')
DPP.CanProperty = DPP.Wrap(DPP.CanProperty, true, 'protection_disabled')
DPP.CanGravgun = DPP.Wrap(DPP.CanGravgun, true, 'protection_disabled')
DPP.CanGravgunPunt = DPP.Wrap(DPP.CanGravgunPunt, true, 'protection_disabled')
DPP.OnPhysgunReload = DPP.Wrap(DPP.OnPhysgunReload, true, 'protection_disabled')
DPP.CanTool = DPP.Wrap(DPP.CanTool, true, 'protection_disabled')
DPP.CanEditVariable = DPP.Wrap(DPP.CanEditVariable, true, 'protection_disabled')
DPP.CanPlayerEnterVehicle = DPP.Wrap(DPP.CanPlayerEnterVehicle, true, 'protection_disabled')
DPP.PlayerUse = DPP.Wrap(DPP.PlayerUse, true, 'protection_disabled')

function DPP.CanPickupItem(ply, ent)
	if not DPP.GetConVar('enable') then return true, DPP.GetPhrase('protection_disabled') end
	if not DPP.GetConVar('enable_pickup') then return true, DPP.GetPhrase('protection_disabled') end

	DPP.AssertArguments('DPP.CanPickupItem', {{ply, 'Player'}, {ent, 'AnyEntity'}})

	local class = ent:GetClass()

	if DPP.IsEntityBlockedPickup(class) then return false, 'Blacklisted' end
	if DPP.IsRestrictedPickup(class, ply) then return false, 'Restricted' end
	if DPP.IsEntityWhitelistedPickup(class) then return true, 'Excluded' end

	if DPP.GetConVar('disable_pickup_world') and not DPP.IsOwned(ent) then return true, 'Not owned' end
	return DPP.CanTouch(ply, ent, 'pickup')
end

function DPP.CanPickupItemTouch(ply, ent)
	local can, r = DPP.CanPickupItem(ply, ent)

	if can == false then
		return can, r
	end
end

--I think this would be useful shared
hook.Add('PlayerCanPickupItem', '!DPP.Hooks', DPP.CanPickupItemTouch, -1)
hook.Add('PlayerCanPickupWeapon', '!DPP.Hooks', DPP.CanPickupItemTouch, -1)

--Maximal Priority
hook.Add('GravGunPunt', '!DPP.Hooks', DPP.GravGunPuntTouch, -1)
hook.Add('OnPhysgunReload', '!DPP.Hooks', DPP.PhysgunReloadTouch, -1)
hook.Add('GravGunPickupAllowed', '!DPP.Hooks', DPP.GravgunTouch, -1)
hook.Add('PhysgunPickup', '!DPP.Hooks', DPP.PhysgunTouch, -1)
hook.Add('CanProperty', '!DPP.Hooks', DPP.PropertyTouch, -1)
hook.Add('CanTool', '!DPP.Hooks', DPP.ToolgunTouch, -1)
hook.Add('PlayerUse', '!DPP.Hooks', DPP.UseTouch, -1)
hook.Add('CanDrive', '!DPP.Hooks', DPP.CanDriveTouch, -1)
hook.Add('CanEditVariable', '!DPP.Hooks', DPP.CanEditVariableTouch, -1)
hook.Add('CanPlayerEnterVehicle', '!DPP.Hooks', DPP.CanPlayerEnterVehicleTouch, -1)

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
					DPP.Notify(self.DPly, DPP.PlayerPhrase('e2adv_func_restricted_s', Variable), 1)
				end

				self:TraceError(Trace, DPP.GetPhrase('e2adv_func_restricted', Variable))
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
