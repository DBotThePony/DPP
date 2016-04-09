
--[[
Copyright (C) 2016 DBot

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

DPP = DPP or {}

file.CreateDir('dpp')

MsgC([[
Welcome to...
DPP - DBot Prop Protection

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
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

DPP.Settings = {
	['enable'] = {
		type = 'bool',
		value = '1',
		desc = 'Main power switch',
	},
	
	['clear_disconnected'] = {
		type = 'bool',
		value = '1',
		desc = 'Clear disconnected players props',
	},
	
	['clear_disconnected_admin'] = {
		type = 'bool',
		value = '1',
		desc = 'Clear disconnected admins props',
	},
	
	['clear_timer'] = {
		type = 'int',
		value = '120',
		desc = 'Clear time in seconds',
		min = '1',
		max = '600',
	},
	
	['grabs_disconnected'] = {
		type = 'bool',
		value = '1',
		desc = 'Up for grabs enable for disconnected players props',
	},
	
	['grabs_disconnected_admin'] = {
		type = 'bool',
		value = '1',
		desc = 'Up for grabs enable for disconnected admins props',
	},
	
	['grabs_timer'] = {
		type = 'int',
		value = '60',
		desc = 'Up for grabs enable timer in seconds',
		min = '1',
		max = '600',
	},
	
	['disconnect_freeze'] = {
		type = 'bool',
		value = '1',
		desc = 'Freeze player props on disconnect',
	},
	
	['can_touch_world'] = {
		type = 'bool',
		value = '0',
		desc = 'Can player touch world entites',
	},
	
	['log_spawns'] = {
		type = 'bool',
		value = '1',
		desc = 'Log spawns',
	},
	
	['can_admin_touch_world'] = {
		type = 'bool',
		value = '1',
		desc = 'Can admins touch world props',
	},
	
	['can_admin_physblocked'] = {
		type = 'bool',
		value = '1',
		desc = 'Can admins physgun blocked entites',
	},
	
	['admin_can_everything'] = {
		type = 'bool',
		value = '1',
		desc = 'Admin can touch everything',
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
		desc = 'Enable "Pickup" protection',
	},
	
	--Misc
	['player_cant_punt'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent players from punting props',
	},
	
	['prevent_player_stuck'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent players from propblocking others by placing props into them',
	},
	
	['prevent_explosions_crash'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent server crashing by saying no to many explosions on one game frame (experemental! Can work or not. Some addons may mess up)',
	},
	
	['prevent_explosions_crash_num'] = {
		type = 'int',
		value = '50',
		desc = 'Max explosion count on one frame. Change with care!!',
	},
	
	['prevent_prop_throw'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent players from throwing props',
	},
	
	['toolgun_player'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent players from toolgun other players',
	},
	
	['toolgun_player_admin'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent admins from toolgun other players',
	},
	
	['no_rope_world'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent players from placing ropes on map',
	},
	
	['experemental_spawn_checks'] = {
		type = 'bool',
		value = '1',
		desc = 'Experemental spawn checks (DISABLE THIS IF IF YOU THINK THIS IS CAUSING PROBLEMS; Replaces GetPlayer and SetPlayer functions for entites)',
	},
	
	['allow_damage_vehicles'] = {
		type = 'bool',
		value = '1',
		desc = 'Allow players to damage any vehicles even if damage protection is enabled',
	},
	
	['allow_damage_sent'] = {
		type = 'bool',
		value = '0',
		desc = 'Allow players to damage other player\'s SENTs even if damage protection is enabled',
	},
	
	['allow_damage_npc'] = {
		type = 'bool',
		value = '1',
		desc = 'Allow players to damage NPCs even if damage protection is enabled',
	},
	
	['advanced_spawn_checks'] = {
		type = 'bool',
		value = '1',
		desc = 'Advanced spawn checks (for WAC Aircraft, SCars, etc.)',
	},
	
	['verbose_logging'] = {
		type = 'bool',
		value = '0',
		desc = 'Log entirely all things (in the main when spawn detected through advanced spawn check)',
	},
	
	--Antispam
	['check_sizes'] = {
		type = 'bool',
		value = '1',
		desc = 'Check sizes of entites',
	},
	
	['max_size'] = {
		type = 'float',
		value = '1000',
		desc = 'Sizes of big prop',
		min = '200',
		max = '4000',
	},
	
	['antispam'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent spamming',
	},
	
	['antispam_delay'] = {
		type = 'float',
		value = '0.6',
		desc = 'Minimum delay between entity spawning',
	},
	
	['antispam_remove'] = {
		type = 'int',
		value = '10',
		desc = 'Remove thresold',
	},
	
	['antispam_ghost'] = {
		type = 'int',
		value = '2',
		desc = 'Ghost thresold',
	},
	
	['antispam_cooldown_divider'] = {
		type = 'float',
		value = '1',
		desc = 'Lower means faster cooldown',
	},
	
	['antispam_max'] = {
		type = 'int',
		value = '30',
		desc = 'Max amount of counted entites (max cooldown in spawned count)',
	},
	
	['check_stuck'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent spawning prop in prop',
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
		desc = 'Enable SBox limits list'
	},
}

DPP.BlockedEntites = DPP.BlockedEntites or {}
DPP.EntsLimits = DPP.EntsLimits or {}
DPP.SBoxLimits = DPP.SBoxLimits or {}
DPP.RestrictedTypes = DPP.RestrictedTypes or {}
DPP.BlockedModels = DPP.BlockedModels or {}

DPP.BlockTypes = {
	tool = 'Tool',
	physgun = 'Physgun',
	use = 'Use',
	damage = 'Damage',
	gravgun = 'Gravgun',
	pickup = 'Pickup',
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
	
	['font'] = {
		type = 'int',
		value = '1',
		desc = 'Font (1 for default)',
	},
}

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

function DPP.PlayerConVar(ply, var, ifUndefined)
	local t = DPP.CSettings[var]
	if not t then return ifUndefined end
	local type = t.type
	
	if CLIENT then 
		local val = DPP.CVars[var]
		
		if type == 'bool' then
			return val:GetBool()
		elseif type == 'int' then
			return val:GetInt()
		elseif type == 'float' then
			return val:GetFloat()
		end
	else
		local val = ply:GetInfo('dpp_' .. var)
		if not val and val ~= false then return ifUndefined end
		
		if type == 'bool' then
			return tobool(val)
		elseif type == 'int' then
			return math.floor(tonumber(val))
		elseif type == 'float' then
			return tonumber(val)
		end
	end
end

function DPP.GetConVar(cvar)
	if not DPP.Settings[cvar] then return end
	local t = DPP.Settings[cvar]
	
	if SERVER then
		local var = DPP.SVars[cvar]
		if t.bool then return  var:GetBool() end
		return t.int and var:GetInt() or t.float and var:GetFloat() or var:GetString()
	else
		local var = GetGlobalString('DPP.' .. cvar)
		if t.bool then return tobool(var) end
		return t.int and math.floor(tonumber(var)) or t.float and tonumber(var) or var
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
	DPP.BlockedEntites[k] = DPP.BlockedEntites[k] or {}
	
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
		if not DPP.GetConVar('blacklist_' .. k) then return false end
		
		if isentity(ent) then
			ent = ent:GetClass()
		end
		
		if not ply then
			local status = DPP.BlockedEntites[k][ent]
			if not status then return false else return true end
		else
			local isAdmin = ply:IsAdmin()
			local c, cA = DPP.GetConVar('blacklist_' .. k .. '_player_can'), DPP.GetConVar('blacklist_' .. k .. '_admin_can')
			local status = DPP.BlockedEntites[k][ent] or false
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
end

DPP.AdminGroups = {
	['admin'] = true,
	['superadmin'] = true
}

for k, v in pairs(DPP.RestrictTypes) do
	DPP.RestrictedTypes[k] = DPP.RestrictedTypes[k] or {}
	
	DPP.AddConVar('restrict_' .. k .. '_white_bypass', {
		desc = 'Admins can bypass ' .. v .. ' whitelist (spawn unlisted things)',
		value = '0',
		type = 'bool',
	})
	
	DPP.AddConVar('restrict_' .. k .. '_white', {
		desc = v .. ' restrict list is a white list.',
		value = '0',
		type = 'bool',
	})
	
	DPP.AddConVar('restrict_' .. k, {
		desc = 'Enable ' .. v .. ' restrict list',
		value = '1',
		type = 'bool',
	})
	
	DPP['IsRestricted' .. v] = function(class, group)
		if not DPP.GetConVar('enable') then return false end
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

for k, v in pairs(DPP.Settings) do
	if SERVER then
		DPP.SVars[k] = CreateConVar('dpp_' .. k, v.value, {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE})
		cvars.AddChangeCallback('dpp_' .. k, DPP.ConVarChanged, 'DPP')
	end
end

if CLIENT then
	for k, v in pairs(DPP.CSettings) do
		DPP.CVars[k] = CreateClientConVar('dpp_' .. k, v.value, true, true, v.desc)
	end
end

function DPP.CanTouchWorld(ply, ent)
	local canAdmin = DPP.GetConVar('can_admin_touch_world')
	local can = DPP.GetConVar('can_touch_world')
	
	if not ply:IsAdmin() then
		return can
	else
		if can then return true end
		return canAdmin
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

function DPP.CanTouch(ply, ent)
	if not DPP.GetConVar('enable') then return true end
	if not IsValid(ply) then return true end
	if not IsValid(ent) then return false end
	if ent:IsPlayer() then return end
	
	local owner = DPP.GetOwner(ent)
	local constrained = DPP.GetConstrainedTable(ent)
	local INDEX = table.insert(constrained, owner)
	
	local can = true
	local reason
	
	local admin, adminEverything = ply:IsAdmin(), DPP.GetConVar('admin_can_everything')
	
	local isOwned = DPP.IsOwned(ent)
	
	for k, owner in pairs(constrained) do
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
			if not isOwned and not DPP.CanTouchWorld(ply, ent) then 
				can = false 
				reason = 'Belong/Constrained to world'
				break
			elseif isOwned then
				if admin and adminEverything then
					continue
				else
					can = false
					break
				end
			end
		end
		
		local friend = DPP.IsFriend(ply, owner)
		
		if admin then
			if adminEverything then
				continue
			elseif not friend then
				can = false
				break
			end
		end
		
		if owner:IsPlayer() then
			if not friend then 
				can = false 
				break
			end
		end
	end
	
	constrained[INDEX] = nil
	
	return can, reason
end

include('sh_hooks.lua')
if SERVER then
	include('sv_savedata.lua')
else
	include('cl_settings.lua')
end
