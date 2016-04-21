
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

DPP = DPP or {}

file.CreateDir('dpp')

MsgC([[
Welcome to...
DPP - DBot Prop Protection

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]])

if SERVER then
	include('sv_init.lua')
	include('sv_fpp_comp.lua')
	AddCSLuaFile('sh_init.lua')
	AddCSLuaFile('sh_cppi.lua')
	AddCSLuaFile('sh_functions.lua')
	AddCSLuaFile('sh_hooks.lua')
	AddCSLuaFile('cl_init.lua')
	AddCSLuaFile('cl_settings.lua')
else
	include('cl_init.lua')
end

include('sh_cppi.lua')
include('sh_functions.lua')

DPP.PlayerList = DPP.PlayerList or {}

DPP.Settings = {
	['enable'] = {
		type = 'bool',
		value = '1',
		desc = 'Main power switch (Enable Protection)',
	},
	
	['enable_lists'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable restrictions',
	},
	
	['enable_blocked'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable blacklists',
	},
	
	['enable_whitelisted'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable whitelists',
	},
	
	['apropkill_enable'] = {
		type = 'bool',
		value = '1',
		desc = 'Anti-Propkill Master Toggle',
	},
	
	['apropkill_damage'] = {
		type = 'bool',
		value = '1',
		desc = 'Anti-Propkill',
	},
	
	['apropkill_clampspeed'] = {
		type = 'bool',
		value = '0',
		desc = 'Clamp the maximal speed of prop move using physgun',
	},
	
	['apropkill_clampspeed_val'] = {
		type = 'int',
		value = '15',
		desc = 'Clamp value. Change with caution!',
		min = 1,
		max = 50,
	},
	
	['apropkill_damage_vehicle'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent players from killing others using vehicles',
	},
	
	['apropkill_vehicle'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable vehicle collisions',
	},
	
	['apropkill_nopush'] = {
		type = 'bool',
		value = '1',
		desc = 'Anti-Proppush',
	},
	
	['clear_disconnected'] = {
		type = 'bool',
		value = '1',
		desc = 'Clear disconnected player entities',
	},
	
	['clear_disconnected_admin'] = {
		type = 'bool',
		value = '1',
		desc = 'Clear disconnected admin entities',
	},
	
	['clear_timer'] = {
		type = 'int',
		value = '120',
		desc = 'Clear time in seconds',
		min = 1,
		max = 600,
	},
	
	['grabs_disconnected'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Up for grabs" for disconnected player entities',
	},
	
	['grabs_disconnected_admin'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Up for grabs" for disconnected admin entities',
	},
	
	['grabs_timer'] = {
		type = 'int',
		value = '60',
		desc = 'Up for grabs enable timer in seconds',
		min = 1,
		max = 600,
	},
	
	['disconnect_freeze'] = {
		type = 'bool',
		value = '1',
		desc = 'Freeze player props on disconnect',
	},
	
	['can_touch_world'] = {
		type = 'bool',
		value = '0',
		desc = 'Players can touch world entites',
	},
	
	['log_spawns'] = {
		type = 'bool',
		value = '1',
		desc = 'Log spawns',
	},
	
	['can_admin_touch_world'] = {
		type = 'bool',
		value = '1',
		desc = 'Admins can touch world entities',
	},
	
	['can_admin_physblocked'] = {
		type = 'bool',
		value = '1',
		desc = 'Can admins physgun blocked entities',
	},
	
	['admin_can_everything'] = {
		type = 'bool',
		value = '1',
		desc = 'Admins can touch everything',
	},
	
	['strict_property'] = {
		type = 'bool',
		value = '0',
		desc = '[Experimental!] Enable strict property protection',
	},
	
	--Protection Modules
	['enable_tool'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Tool" protection',
	},
	
	['enable_physgun'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Physgun" protection',
	},
	
	['enable_gravgun'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Gravgun" protection',
	},
	
	['enable_veh'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Vehicle" protection',
	},
	
	['enable_use'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Use" protection',
	},
	
	['enable_damage'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Damage" protection',
	},
	
	['enable_drive'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Drive" protection',
	},
	
	['enable_pickup'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Pickups" protection',
	},
	
	--Misc
	['player_cant_punt'] = {
		type = 'bool',
		value = '1',
		desc = 'Disable Gravgun punting',
	},
	
	['prevent_player_stuck'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent prop-trapping',
	},
	
	['prevent_explosions_crash'] = {
		type = 'bool',
		value = '1',
		desc = '[Experimental!] Prevent the server from crashing from too many explosions in one instance (May not work, some addons may break.)',
	},
	
	['prevent_explosions_crash_num'] = {
		type = 'int',
		value = '50',
		desc = 'Max explosion count on one frame. Change with care!!',
		min = 1,
		max = 300,
	},
	
	['prevent_prop_throw'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent players from throwing props',
	},
	
	['toolgun_player'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent toolgun usage on players',
	},
	
	['toolgun_player_admin'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent admin toolgun usage on players',
	},
	
	['no_rope_world'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent players from placing ropes on the map',
	},
	
	['experemental_spawn_checks'] = {
		type = 'bool',
		value = '1',
		desc = 'Experimental spawn checks (May cause problems; Replaces GetPlayer and SetPlayer functions for entities)',
	},
	
	['allow_damage_vehicles'] = {
		type = 'bool',
		value = '1',
		desc = 'Allow damage of vehicles even if damage protection is enabled',
	},
	
	['allow_damage_sent'] = {
		type = 'bool',
		value = '0',
		desc = 'Allow damage of other player\'s SENTs even if damage protection is enabled',
	},
	
	['allow_damage_npc'] = {
		type = 'bool',
		value = '1',
		desc = 'Allow damage NPCs even if damage protection is enabled',
	},
	
	['advanced_spawn_checks'] = {
		type = 'bool',
		value = '1',
		desc = 'Advanced spawn checks (for WAC Aircraft, SCars, etc.)',
	},
	
	['verbose_logging'] = {
		type = 'bool',
		value = '0',
		desc = 'Log everything (Any spawn detected through the advanced check)',
	},
	
	--Antispam
	['check_sizes'] = {
		type = 'bool',
		value = '1',
		desc = 'Check the sizes of entities',
	},
	
	['max_size'] = {
		type = 'float',
		value = '1000',
		desc = 'Sizes of big prop',
		min = 50,
		max = 8000,
	},
	
	['antispam'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent spamming',
	},
	
	['antispam_delay'] = {
		type = 'float',
		value = '1',
		desc = 'Minimum delay between entity spawning',
		min = 0.1,
		max = 3,
	},
	
	['antispam_remove'] = {
		type = 'int',
		value = '10',
		desc = 'Remove thresold',
		min = 2,
		max = 30,
	},
	
	['antispam_ghost'] = {
		type = 'int',
		value = '2',
		desc = 'Ghost thresold',
		min = 2,
		max = 30,
	},
	
	['antispam_cooldown_divider'] = {
		type = 'float',
		value = '1',
		desc = 'Lower means faster cooldown',
		min = 0.1,
		max = 6,
	},
	
	['antispam_max'] = {
		type = 'int',
		value = '30',
		desc = 'Max amount of counted entities (max cooldown in spawned count)',
		min = 3,
		max = 100,
	},
	
	['antispam_toolgun_enable'] = {
		type = 'bool',
		value = '0',
		desc = 'Enable toolgun antispam',
	},
	
	['antispam_toolgun'] = {
		type = 'float',
		value = '1',
		desc = 'Delay in seconds between toolgun use',
		min = 0,
		max = 6,
	},
	
	['check_stuck'] = {
		type = 'bool',
		value = '1',
		desc = ' Prevent props from getting stuck in each other',
	},
	
	['stuck_ignore_frozen'] = {
		type = 'bool',
		value = '0',
		desc = 'Ignore frozen entities when doing "stuck check"',
	},
	
	--Block switches
	['model_blacklist'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable model blacklist',
	},
	
	['model_whitelist'] = {
		type = 'bool',
		value = '0',
		desc = 'Model blacklist is a whitelist',
	},
	
	['ent_limits_enable'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable entity limits list'
	},
	
	['sbox_limits_enable'] = {
		type = 'bool',
		value = '1',
		desc = 'Sandbox limits toggle'
	},
	
	['const_limits_enable'] = {
		type = 'bool',
		value = '1',
		desc = 'Constrains limits toggle'
	},
	
	['log_constraints'] = {
		type = 'bool',
		value = '0',
		desc = 'Should constraints spawn be logged'
	},
	
	['no_tool_log'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable toolgun log'
	},
	
	['no_tool_fail_log'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable toolgun "tries" log'
	},
}

DPP.BlockedEntities = DPP.BlockedEntities or {}
DPP.WhitelistedEntities = DPP.WhitelistedEntities or {}
DPP.EntsLimits = DPP.EntsLimits or {}
DPP.SBoxLimits = DPP.SBoxLimits or {}
DPP.ConstrainsLimits = DPP.ConstrainsLimits or {}
DPP.RestrictedTypes = DPP.RestrictedTypes or {}
DPP.BlockedModels = DPP.BlockedModels or {}

DPP.BlockTypes = {
	tool = 'Tool',
	physgun = 'Physgun',
	use = 'Use',
	damage = 'Damage',
	gravgun = 'Gravgun',
	pickup = 'Pickup',
	toolworld = 'ToolgunWorld',
}

DPP.WhitelistTypes = table.Copy(DPP.BlockTypes) --Heh
DPP.WhitelistTypes.toolworld = nil
DPP.WhitelistTypes.property = 'Property'
DPP.WhitelistTypes.propertyt = 'PropertyType'
DPP.WhitelistTypes.toolmode = 'ToolMode'

DPP.ShareTypes = {
	use = 'Use',
	toolgun = 'Toolgun',
	physgun = 'Physgun',
	gravgun = 'Gravgun',
	damage = 'Damage',
}

DPP.RestrictTypes = {
	tool = 'Tool',
	sent = 'SENT',
	vehicle = 'Vehicle',
	swep = 'SWEP',
	model = 'Model',
	npc = 'NPC',
	property = 'Property',
	pickup = 'Pickup',
	e2function = 'E2Function',
	e2afunction = 'E2AFunction',
}

DPP.CSettings = {
	['no_touch'] = {
		type = 'bool',
		value = '0',
		desc = 'I don\'t want to touch my own entities',
	},
	
	['no_player_touch'] = {
		type = 'bool',
		value = '0',
		desc = 'I don\'t want to touch other players (if admin)',
	},
	
	['simple_hud'] = {
		type = 'bool',
		value = '0',
		desc = 'Simple DPP HUD panel',
	},
	
	['font'] = {
		type = 'int',
		value = '1',
		desc = 'Font (1 for default)',
	},
	
	['no_scrambling_text'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable scrambling text',
	},
	
	['hide_hud'] = {
		type = 'bool',
		value = '0',
		desc = 'Hide owner display',
	},
	
	['no_touch_world'] = {
		type = 'bool',
		value = '0',
		desc = 'I don\'t want to touch world entities',
	},
	
	['no_touch_other'] = {
		type = 'bool',
		value = '0',
		desc = 'I don\'t want to touch other player\'s entities',
	},
	
	['no_hud_in_vehicle'] = {
		type = 'bool',
		value = '1',
		desc = 'Disable HUD while in vehicle',
	},
	
	['no_restrict_options'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable "fast restrict" options in property menus',
	},
	
	['no_block_options'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable "fast block" options in property menus',
	},
	
	['no_load_messages'] = {
		type = 'bool',
		value = '0',
		desc = 'I con\'t want to see "list reloaded" in my console',
	},
}

DPP.ProtectionModes = {
	['toolgun'] = true, 
	['vehicle'] = true, 
	['use'] = true, 
	['physgun'] = true, 
	['damage'] = true, 
	['gravgun'] = true
}

for k, v in pairs(DPP.ProtectionModes) do
	DPP.CSettings['disable_' .. k .. '_protection'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable "' .. k .. '" protection for my entities',
	}
end

for k, v in pairs(DPP.Settings) do
	v.bool = v.type == 'bool'
	v.int = v.type == 'int'
	v.float = v.type == 'float'
end

for k, v in pairs(DPP.CSettings) do
	v.bool = v.type == 'bool'
	v.int = v.type == 'int'
	v.float = v.type == 'float'
end

DPP.CVars = {}
DPP.SVars = {}

if CLIENT then
	function DPP.PlayerConVar(ply, var, ifUndefined)
		local t = DPP.CSettings[var]
		if not t then return ifUndefined end
		local type = t.type
		local val
		
		if not ply or ply == LocalPlayer() then
			val = DPP.CVars[var]:GetString()
		else
			val = ply:GetNWString('dpp.cvar_' .. var, '')
			if not val or (val == '' and not t.blank) then return ifUndefined end
		end
		
		if type == 'bool' then
			return tobool(val)
		elseif type == 'int' then
			return math.floor(tonumber(val))
		elseif type == 'float' then
			return tonumber(val)
		else
			return val
		end
	end
else
	function DPP.PlayerConVar(ply, var, ifUndefined)
		local t = DPP.CSettings[var]
		if not t then return ifUndefined end
		local type = t.type
		
		local val = ply:GetInfo('dpp_' .. var)
		if not val and val ~= false then return ifUndefined end
		
		if ply:GetNWString('dpp.cvar_' .. var, '') ~= val then
			ply:SetNWString('dpp.cvar_' .. var, val)
		end
		
		--Player can exploit the server by setting cvar to non it's specified type
		local toNum = tonumber(val)
		
		if type == 'bool' then
			return tobool(val)
		elseif type == 'int' then
			if not toNum then return ifUndefined end
			return math.floor(toNum)
		elseif type == 'float' then
			if not toNum then return ifUndefined end
			return toNum
		else
			return val
		end
	end
end

if CLIENT then
	function DPP.GetConVar(cvar)
		if not DPP.Settings[cvar] then return end
		local t = DPP.Settings[cvar]
		
		local var = GetGlobalString('DPP.' .. cvar) or t.value --Default value
		if var == '' and not t.blank then var  = t.value end
		if t.bool then return tobool(var) end
		return t.int and math.floor(tonumber(var) or tonumber(t.value)) or t.float and (tonumber(var) or tonumber(t.value)) or var
	end
else
	function DPP.GetConVar(cvar)
		if not DPP.Settings[cvar] then return end
		local t = DPP.Settings[cvar]
		
		local var = DPP.SVars[cvar]
		if t.bool then return  var:GetBool() end
		return t.int and var:GetInt() or t.float and var:GetFloat() or var:GetString()
	end
end


function DPP.Message(first, ...)
	if istable(first) and not first.a then
		MsgC(Color(0, 200, 0), '[DPP] ', Color(200, 200, 200), unpack(first))
	else
		MsgC(Color(0, 200, 0), '[DPP] ', Color(200, 200, 200), first, ...)
	end
	
	MsgC('\n')
end

function DPP.Wrap(func, retval)
	return function(...)
		if not DPP.GetConVar('enable') then return retval end
		return func(...)
	end
end

function DPP.GetOwner(ent)
	if not IsValid(ent) then return NULL end
	return ent:GetNWEntity('DPP.Owner')
end

function DPP.AddConVar(k, tab)
	DPP.Settings[k] = tab
	tab.bool = tab.type == 'bool'
	tab.int = tab.type == 'int'
	tab.float = tab.type == 'float'
	DPP.SVars[k] = CreateConVar('dpp_' .. k, tab.value, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED})
end

for k, v in pairs(DPP.BlockTypes) do
	DPP.BlockedEntities[k] = DPP.BlockedEntities[k] or {}
	
	DPP.AddConVar('blacklist_' .. k .. '_white', {
		desc = v .. ' blacklist is a white list.',
		value = '0',
		type = 'bool',
	})
	
	DPP.AddConVar('blacklist_' .. k, {
		desc = 'Enable ' .. v .. ' blacklist',
		value = '1',
		type = 'bool',
	})
	
	DPP.AddConVar('blacklist_' .. k .. '_player_can', {
		desc = 'Can players touch ents from ' .. v .. ' blacklist?',
		value = '0',
		type = 'bool',
	})
	
	DPP.AddConVar('blacklist_' .. k .. '_admin_can', {
		desc = 'Can admin touch ents from ' .. v .. ' blacklist?',
		value = '0',
		type = 'bool',
	})
	
	DPP['IsEntityBlocked' .. v] = function(ent, ply)
		if not DPP.GetConVar('enable') then return false end
		if not DPP.GetConVar('enable_blocked') then return false end
		if not DPP.GetConVar('blacklist_' .. k) then return false end
		
		if isentity(ent) then
			ent = ent:GetClass()
		end
		
		if not ply then
			local status = DPP.BlockedEntities[k][ent]
			if not status then return false else return true end
		else
			local isAdmin = ply:IsAdmin()
			local c, cA = DPP.GetConVar('blacklist_' .. k .. '_player_can'), DPP.GetConVar('blacklist_' .. k .. '_admin_can')
			local status = DPP.BlockedEntities[k][ent] or false
			if not status then return false end
			
			if c then 
				return false 
			else
				if cA and isAdmin then
					return false
				else
					return status
				end
			end
		end
	end
	
	DPP['IsEvenBlocked' .. v] = function(ent)
		if isentity(ent) then
			ent = ent:GetClass()
		end
		
		return DPP.BlockedEntities[k][ent] ~= nil
	end
end

for k, v in pairs(DPP.WhitelistTypes) do
	DPP.WhitelistedEntities[k] = DPP.WhitelistedEntities[k] or {}
	
	DPP.AddConVar('whitelist_' .. k, {
		desc = 'Enable ' .. v .. ' whitelist',
		value = '1',
		type = 'bool',
	})
	
	DPP['IsEntityWhitelisted' .. v] = function(ent)
		if not DPP.GetConVar('enable') then return false end
		if not DPP.GetConVar('enable_whitelisted') then return false end
		if not DPP.GetConVar('whitelist_' .. k) then return false end
		
		if isentity(ent) then
			ent = ent:GetClass()
		end
		
		return DPP.WhitelistedEntities[k][ent] ~= nil
	end
	
	DPP['IsEvenWhitelisted' .. v] = function(ent)
		if isentity(ent) then
			ent = ent:GetClass()
		end
		
		return DPP.WhitelistedEntities[k][ent] ~= nil
	end
end

DPP.AdminGroups = {
	['admin'] = true,
	['superadmin'] = true
}

for k, v in pairs(DPP.RestrictTypes) do
	DPP.RestrictedTypes[k] = DPP.RestrictedTypes[k] or {}
	
	DPP.AddConVar('restrict_' .. k .. '_white_bypass', {
		desc = 'Admins can bypass ' .. v .. ' whitelist (spawn/use unlisted things)',
		value = '0',
		type = 'bool',
	})
	
	DPP.AddConVar('restrict_' .. k .. '_white', {
		desc = v .. ' restrictions acts as a whitelist',
		value = '0',
		type = 'bool',
	})
	
	DPP.AddConVar('restrict_' .. k, {
		desc = 'Enable ' .. v .. ' restrictions',
		value = '1',
		type = 'bool',
	})
	
	DPP['IsRestricted' .. v] = function(class, group)
		if not DPP.GetConVar('enable_lists') then return false end
		if not DPP.GetConVar('restrict_' .. k) then return false end
		local isWhite = DPP.GetConVar('restrict_' .. k .. '_white')
		local adminBypass = DPP.GetConVar('restrict_' .. k .. '_white_bypass')
		
		local reply = false
		local hit = false
		local isAdmin
		
		if isentity(group) then
			isAdmin = group:IsAdmin()
			group = group:GetUserGroup()
			if isAdmin then
				DPP.AdminGroups[group] = true
			end
		else
			isAdmin = DPP.AdminGroups[group]
		end
		
		local T = DPP.RestrictedTypes[k][class]
		
		if T then
			local white2 = T.iswhite
			if table.HasValue(T.groups, group) then
				reply = not white2
			else
				reply = white2
			end
		else
			if isWhite and isAdmin and adminBypass then
				reply = true
			else
				reply = false
			end
		end
		
		if isWhite then
			return not reply
		else
			return reply
		end
	end
	
	DPP['IsEvenRestricted' .. v] = function(class)
		local T = DPP.RestrictedTypes[k][class]
		
		if T then
			return true
		else
			return false
		end
	end
end

function DPP.EntityHasLimit(class)
	return DPP.EntsLimits[class] ~= nil or DPP.EntsLimits[class] and #DPP.EntsLimits[class] ~= 0
end

function DPP.SBoxLimitExists(class)
	return DPP.SBoxLimits[class] ~= nil or DPP.SBoxLimits[class] and #DPP.SBoxLimits[class] ~= 0
end

DPP_NO_LIMIT = 0
DPP_NO_LIMIT_DEFINED = -1

function DPP.IsAPKEnabled()
	return DPP.GetConVar('apropkill_enable')
end

function DPP.GetEntityLimit(class, group)
	if not DPP.GetConVar('ent_limits_enable') then return DPP_NO_LIMIT_DEFINED end
	local T = DPP.EntsLimits[class]
	
	if T then
		if not T[group] then
			return DPP_NO_LIMIT_DEFINED
		else
			return tonumber(T[group])
		end
	else
		return DPP_NO_LIMIT_DEFINED
	end
end

function DPP.GetSBoxLimit(class, group)
	if not DPP.GetConVar('sbox_limits_enable') then return DPP_NO_LIMIT end
	local T = DPP.SBoxLimits[class]
	
	if T then
		if not T[group] then
			return DPP_NO_LIMIT
		else
			return tonumber(T[group])
		end
	else
		return DPP_NO_LIMIT
	end
end

function DPP.GetConstLimit(class, group)
	if not DPP.GetConVar('const_limits_enable') then return DPP_NO_LIMIT end
	local T = DPP.ConstrainsLimits[class]
	
	if T then
		if not T[group] then
			return DPP_NO_LIMIT
		else
			return tonumber(T[group])
		end
	else
		return DPP_NO_LIMIT
	end
end

if SERVER then
	for k, v in pairs(DPP.Settings) do
		DPP.SVars[k] = CreateConVar('dpp_' .. k, v.value, {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE})
		cvars.AddChangeCallback('dpp_' .. k, DPP.ConVarChanged, 'DPP')
	end
else
	for k, v in pairs(DPP.CSettings) do
		DPP.CVars[k] = CreateClientConVar('dpp_' .. k, v.value, true, true, v.desc)
		cvars.AddChangeCallback('dpp_' .. k, DPP.ClientConVarChanged, 'DPP')
		timer.Simple(0, function()
			DPP.ClientConVarChanged('dpp_' .. k)
		end)
	end
end

function DPP.CanTouchWorld(ply, ent)
	local canAdmin = DPP.GetConVar('can_admin_touch_world')
	local can = DPP.GetConVar('can_touch_world')
	
	if not ply:IsAdmin() then
		return can
	else
		return can or canAdmin
	end
end

function DPP.IsEnabled()
	return DPP.GetConVar('enable')
end

DPP.DTypes = {
	duplicates = true,
	AdvDupe = true,
	AdvDupe2 = true,
}

function DPP.AddDuplicatorType(str)
	DPP.DTypes[str] = true
end

function DPP.CanTouch(ply, ent, mode)
	if not DPP.GetConVar('enable') then return true end
	if not IsValid(ply) then return true end
	if not IsValid(ent) then return false end
	if ent:IsPlayer() then return end
	
	local model = ent:GetModel()
	if model then
		if DPP.IsModelBlocked(model) then
			return false, 'Model is blacklisted'
		end
	end
	
	local owner = DPP.GetOwner(ent)
	local isOwned = DPP.IsOwned(ent)
	
	if not IsValid(owner) and isOwned then owner = 'disconnected' end
	
	local realOwner = owner
	local constrained = DPP.GetConstrainedTable(ent)
	local INDEX = table.insert(constrained, owner)
	
	local can = true
	local reason
	
	local admin, adminEverything = ply:IsAdmin(), DPP.GetConVar('admin_can_everything')
	
	local isShared = DPP.IsShared(ent)
	if mode and DPP.ShareTypes[mode] then
		isShared = DPP.IsSharedType(ent, mode)
	end
	
	for k, owner in pairs(constrained) do
		if owner == 'disconnected' then
			if admin then
				if adminEverything then
					continue
				else
					can = false
					reason = 'Not a friend of owner/constrained'
					break
				end
			end
		end
		
		if IsValid(owner) and owner:GetClass() == 'gmod_anchor' then continue end
		
		if owner == ply then
			if DPP.PlayerConVar(ply, 'no_touch') then 
				can = false 
				reason = 'dpp_no_touch is TRUE!'
				break 
			end
			continue
		end
		
		if not IsValid(owner) then
			if not DPP.CanTouchWorld(ply, ent) then
				can = false 
				reason = 'Belong/Constrained to world'
				break
			end
			
			if DPP.PlayerConVar(ply, 'no_touch_world', false) then
				can = false 
				reason = 'dpp_no_touch_world 1'
				break
			end
		else
			if mode and DPP.ProtectionModes[mode] and owner:IsPlayer() then
				if DPP.IsProtectionDisabledFor(owner, mode) then
					reason = 'Owner disabled ' .. mode .. ' protection'
				end
			end
			
			if not isShared or realOwner ~= owner then
				local friend = DPP.IsFriend(ply, owner, mode)
				
				if DPP.PlayerConVar(ply, 'no_touch_other', false) then
					can = false
					reason = 'dpp_no_touch_other 1'
					break
				end
				
				if admin then
					if adminEverything then
						continue
					elseif not friend then
						can = false
						reason = 'Not a friend of owner/constrained'
						break
					end
				end
				
				if owner:IsPlayer() then
					if not friend then 
						can = false 
						reason = 'Not a friend of owner/constrained'
						break
					end
				end
			else
				reason = 'Shared ' .. (mode and string.gsub(mode, '^.', string.upper) or '')
			end
		end
	end
	
	constrained[INDEX] = nil
	
	return can, reason
end

include('sh_hooks.lua')
if SERVER then
	include('sv_savedata.lua')
	include('sv_apropkill.lua')
else
	include('cl_settings.lua')
end
