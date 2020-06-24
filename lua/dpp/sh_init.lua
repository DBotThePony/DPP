
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

DPP = DPP or {}

file.CreateDir('dpp')

MsgC([[
Welcome to...
DPP - DBot Prop Protection

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]])

MsgC([[
DPP IS OUTDATED !!!
DPP IS OUTDATED !!!
DPP IS OUTDATED !!!
DPP IS OUTDATED !!!

UPGRADE TO DPP/2 FROM https://steamcommunity.com/sharedfiles/filedetails/?id=2122489895
UPGRADE TO DPP/2 FROM https://steamcommunity.com/sharedfiles/filedetails/?id=2122489895
UPGRADE TO DPP/2 FROM https://steamcommunity.com/sharedfiles/filedetails/?id=2122489895
UPGRADE TO DPP/2 FROM https://steamcommunity.com/sharedfiles/filedetails/?id=2122489895
]])

timer.Simple(0, MsgC:Wrap([[
DPP IS OUTDATED !!!
DPP IS OUTDATED !!!
DPP IS OUTDATED !!!
DPP IS OUTDATED !!!

UPGRADE TO DPP/2 FROM https://steamcommunity.com/sharedfiles/filedetails/?id=2122489895
UPGRADE TO DPP/2 FROM https://steamcommunity.com/sharedfiles/filedetails/?id=2122489895
UPGRADE TO DPP/2 FROM https://steamcommunity.com/sharedfiles/filedetails/?id=2122489895
UPGRADE TO DPP/2 FROM https://steamcommunity.com/sharedfiles/filedetails/?id=2122489895
]]))

function DPP.FindBestLevel()
	local last
	local current = 1

	while true do
		local info = debug.getinfo(current)
		if not info then break end
		last = info
		last.L = current
		current = current + 1

		if not string.find(info.short_src, 'dpp') and not string.find(info.short_src, 'hook') then
			break
		end
	end

	return last.L
end

function DPP.AssertPlayer(obj)
	DPP.Assert(DPP.IsPlayer(obj), 'Argument is not a player! Argument is ' .. type(obj), DPP.FindBestLevel())
end

function DPP.AssertEntity(obj)
	DPP.Assert(isentity(obj) and IsValid(obj), 'Argument is not a valid entity! Argument is ' .. type(obj) .. ' (' .. tostring(obj) .. ')', DPP.FindBestLevel())
end

function DPP.PrintFancyError(err)
	MsgC(err, '\n')
	MsgC(debug.traceback())
end

local EntityTypes = {
	['Entity'] = true,
	['Player'] = true,
	['Vehicle'] = true,
	['Weapon'] = true,
	['NextBot'] = true,
	['NPC'] = true,
}

DPP.ENTITY_TYPES = EntityTypes

function DPP.AssertArguments(funcName, ...)
	local pos = 0

	while true do
		pos = pos + 2

		local val = select(pos - 1, ...)
		local expected = select(pos, ...)
		if not expected then return end

		local valtype = type(val)

		if valtype == expected then goto CONTINUE end
		if valtype == 'Vehicle' and expected == 'Entity' then goto CONTINUE end
		if expected == 'AnyEntity' and EntityTypes[valtype] then goto CONTINUE end

		local valname = valtype
		local expectedname = expected

		if val == NULL then
			valname = 'NULL Entity'
		end

		if expected == 'AnyEntity' then
			expectedname = 'Any Entity'
		end

		DPP.ThrowError(string.format('Bad argument #%s to %s (%s expected, got %s)', k, funcName, expectedname, valname), DPP.FindBestLevel())
		::CONTINUE::
	end
end

function DPP.ToString(obj)
	if type(obj) == 'no value' then
		return 'nil'
	elseif type(obj) == 'nil' then
		return nil
	end

	return tostring(obj)
end

function DPP.IsEntity(obj)
	return EntityTypes[type(obj)] ~= nil
end

function DPP.IsNextBot(obj)
	return obj.Type == 'nextbot' or type(obj) == 'NextBot'
end

local RED = Color(255, 0, 0)

function DPP.ThrowError(str, level, notabug)
	if not notabug then
		local info = debug.getinfo(level or 3)
		if SERVER then DPP.DoEcho(RED, 'ERROR: ' .. str .. '\nTO USERS: THIS IS A BUG IN ' .. info.short_src .. ':' .. info.currentline) end
	else
		if SERVER then DPP.DoEcho(RED, 'ERROR: ' .. str) end
	end

	error(str, level or 3)
end

function DPP.Assert(check, str, level, notabug)
	if check then return end
	level = (level or 3) + 1
	DPP.ThrowError(str, level, notabug)
end

function DPP.IsPlayer(obj)
	return isentity(obj) and IsValid(obj) and obj:IsPlayer()
end

function DPP.HasValueLight(tab, val)
	for i = 1, #tab do
		if val == tab[i] then return true end
	end

	return false
end

function DPP.PopFromArray(arr, val)
	local i

	for k, v in ipairs(arr) do
		if v == val then i = k end
	end

	if i then
		table.remove(arr, i)
	end

	return arr
end

DPP.HaveValueLight = DPP.HasValueLight

if SERVER then
	include('sv_init.lua')
else
	include('cl_init.lua')
end

include('sh_cppi.lua')
include('sh_functions.lua')
include('sh_networking.lua')

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
		desc = 'Enable exclude lists',
	},

	['apropkill_enable'] = {
		type = 'bool',
		value = '1',
		desc = 'Anti-Propkill Master Toggle',
	},

	['apropkill_crash'] = {
		type = 'bool',
		value = '1',
		desc = 'Try to prevent server crash from colliding props',
	},

	['apropkill_damage'] = {
		type = 'bool',
		value = '1',
		desc = 'Anti-Propkill',
	},

	['apropkill_damage_noworld'] = {
		type = 'bool',
		value = '1',
		desc = 'World owned entities bypass damage check',
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

	['apropkill_nopush_mode'] = {
		type = 'bool',
		value = '0',
		desc = 'False - player only, True - ALL collisions',
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
		desc = 'Players can touch world **owned** entities',
	},

	['can_touch_world_created'] = {
		type = 'bool',
		value = '0',
		desc = 'Players can touch world **created** entities',
	},

	['log_spawns'] = {
		type = 'bool',
		value = '1',
		desc = 'Log spawns. Disables logging to files of spawns!',
	},

	['log_spawns_model'] = {
		type = 'bool',
		value = '1',
		desc = 'Log model of entity',
	},

	['log_spawns_nname'] = {
		type = 'bool',
		value = '1',
		desc = 'Log network name and ID of entity',
	},

	['log_spawns_type'] = {
		type = 'bool',
		value = '1',
		desc = 'Log type of entity',
	},

	['log_spawns_pmodel'] = {
		type = 'bool',
		value = '1',
		desc = 'Log only props models',
	},

	['echo_spawns'] = {
		type = 'bool',
		value = '1',
		desc = 'Echo spawns (server/admin console)',
	},

	['log_file'] = {
		type = 'bool',
		value = '1',
		desc = 'Log things into files',
	},

	['can_admin_touch_world'] = {
		type = 'bool',
		value = '1',
		desc = 'Admins can touch world **owned** entities',
	},

	['can_admin_touch_world_created'] = {
		type = 'bool',
		value = '0',
		desc = 'Admins can touch world **created** entities',
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

	['disable_gravgun_world'] = {
		type = 'bool',
		value = '1',
		desc = 'Disable "Gravgun" protection for world entities',
	},

	['enable_veh'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Vehicle" protection',
	},

	['disable_veh_world'] = {
		type = 'bool',
		value = '1',
		desc = 'Disable "Vehicle" protection for world entities',
	},

	['enable_use'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Use" protection',
	},

	['disable_use_world'] = {
		type = 'bool',
		value = '1',
		desc = 'Disable "Use" protection for world entities',
	},

	['enable_damage'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Damage" protection',
	},

	['disable_damage_world'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable "Damage" protection for world entities',
	},

	['enable_drive'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Drive" (property menu->Drive) protection',
	},

	['enable_pickup'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable "Pickups" protection',
	},

	['disable_pickup_world'] = {
		type = 'bool',
		value = '1',
		desc = 'Disable "Pickups" protection for world entities',
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

	['no_rope_world_weld'] = {
		type = 'bool',
		value = '1',
		desc = 'Mean weld as rope',
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

	['strict_spawn_checks'] = {
		type = 'bool',
		value = '1',
		desc = '[Beta] (Very) Strict spawn checks.\n85%% of spawned entities in unusual ways is detected\nby that option.\nCan decrease performance on pasting dupes.',
	},

	-- Too Hacky

	['strict_spawn_checks_atrack'] = {
		type = 'bool',
		value = '0',
		desc = '[MAGMATIC] Track entities tables for changes.\nThis is a top of entity spawn tracking\nThis is 15%% of unusual ways.\nENABLE WITH CAUTION. THIS BREAKS PROTECTION OF\nCONSTRAINED ENTITIES',
	},

	['spawn_checks_noaspam'] = {
		type = 'bool',
		value = '1',
		desc = 'Disable antispam check for connected entities on spawn',
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
		desc = 'Prevent props from getting stuck in each other',
	},

	['stuck_ignore_frozen'] = {
		type = 'bool',
		value = '1',
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

	['model_whitelist_bypass'] = {
		type = 'bool',
		value = '0',
		desc = 'Admins can bypass model whitelist',
	},

	['ent_limits_enable'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable entity limits list'
	},

	['model_limits_enable'] = {
		type = 'bool',
		value = '1',
		desc = 'Enable model limits list'
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
		desc = 'Disable toolgun log. Disables toolgun logging into files!'
	},

	['no_tool_fail_log'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable toolgun "tries" log'
	},

	['no_tool_log_echo'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable toolgun echo log (server/admin console messages)'
	},

	['no_clear_messages'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable cleanup messages for disconnected players'
	},

	['unfreeze_antispam'] = {
		type = 'bool',
		value = '1',
		desc = 'Prevent physgun unfreeze (Reload) spam'
	},

	['unfreeze_antispam_delay'] = {
		type = 'int',
		value = '5',
		desc = 'Delay between unfreezing in seconds'
	},

	['disable_unfreeze'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable physgun unfreeze (Reload)'
	},

	['unfreeze_restrict'] = {
		type = 'bool',
		value = '0',
		desc = 'Restrict physgun unfreeze (Reload)'
	},

	['unfreeze_restrict_num'] = {
		type = 'int',
		value = '50',
		min = 1,
		max = 300,
		desc = 'Maximum entities that are allowed to be unfreezed at once'
	},

	['freeze_on_disconnect'] = {
		type = 'bool',
		value = '1',
		desc = 'Freeze player entities on disconnect'
	},

	['apanti_disable'] = {
		type = 'bool',
		value = '1',
		desc = 'Disable APAnti ghosting'
	},

	['prop_auto_ban'] = {
		type = 'bool',
		value = '0',
		desc = 'Add huge models to blacklist by auto'
	},

	['prop_auto_ban_size'] = {
		type = 'int',
		value = '4000',
		min = 1,
		max = 10000,
		desc = 'Size limit'
	},

	['prop_auto_ban_check_aabb'] = {
		type = 'bool',
		value = '1',
		desc = 'Check AABB size too'
	},

	['prop_auto_ban_minsmaxs'] = {
		type = 'int',
		value = '350',
		min = 1,
		max = 1000,
		desc = 'Maximal distance between props maximals and minimals vectors (AABB size)'
	},

	['disable_huds'] = {
		type = 'bool',
		value = '0',
		desc = 'Tell clients that server preffers DPP HUD to be disabled'
	},

	['disable_fancy_displays'] = {
		type = 'bool',
		value = '0',
		desc = 'Tell clients that server preffers DPP Fancy Display to be disabled'
	},

	-- Transfer options

	['transfer_enable'] = {
		type = 'bool',
		value = '1',
		desc = 'Allow players to transfer anything'
	},

	['transfer_single'] = {
		type = 'bool',
		value = '1',
		desc = 'Allow players to transfer one entity'
	},

	['transfer_all'] = {
		type = 'bool',
		value = '1',
		desc = 'Allow players to transfer all his entities'
	},

	['transfer_buddies'] = {
		type = 'bool',
		value = '1',
		desc = 'Allow players to transfer stuff only to buddies (this does not affect admins)'
	},

	['transfer_all_disc'] = {
		type = 'bool',
		value = '1',
		desc = 'Allow players to use owner fallback'
	},
}

DPP.BlockedEntities = DPP.BlockedEntities or {}
DPP.WhitelistedEntities = DPP.WhitelistedEntities or {}
DPP.EntsLimits = DPP.EntsLimits or {}
DPP.ModelsLimits = DPP.ModelsLimits or {}
DPP.SBoxLimits = DPP.SBoxLimits or {}
DPP.ConstrainsLimits = DPP.ConstrainsLimits or {}
DPP.RestrictedTypes = DPP.RestrictedTypes or {}
DPP.RestrictedTypes_SteamID = DPP.RestrictedTypes_SteamID or {}
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
	vehicle = 'Vehicle',
	pickup = 'Pickup',
}

for k, v in pairs(DPP.ShareTypes) do
	DPP.RegisterNetworkVar('share' .. k, net.WriteBool, net.ReadBool, 'boolean', false)
end

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

DPP.CURRENT_LANG = DPP.CURRENT_LANG or 'en'
DPP.Phrases = DPP.Phrases or {}
DPP.Phrases.en = DPP.Phrases.en or {}
DPP.Phrases.ru = DPP.Phrases.ru or {}

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

	['no_physgun_display'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable physgun fancy owner display',
	},

	['no_toolgun_display'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable toolgun fancy owner display',
	},

	['display_entityclass'] = {
		type = 'bool',
		value = '1',
		nosend = true,
		desc = 'Display entity class',
	},

	['display_owner'] = {
		type = 'bool',
		value = '1',
		nosend = true,
		desc = 'Display entity owner',
	},

	['display_entityclass2'] = {
		type = 'bool',
		value = '1',
		nosend = true,
		desc = 'Display entity network ID and network class',
	},

	['display_entityname'] = {
		type = 'bool',
		value = '1',
		nosend = true,
		desc = 'Display entity name',
	},

	['display_reason'] = {
		type = 'bool',
		value = '1',
		nosend = true,
		desc = 'Display "can touch" touch reason',
	},

	['display_disconnected'] = {
		type = 'bool',
		value = '1',
		nosend = true,
		desc = 'Display whatever owner is disconnected',
	},

	['display_grabs'] = {
		type = 'bool',
		value = '1',
		nosend = true,
		desc = 'Display whatever prop is up for grabs',
	},

	['smaller_fonts'] = {
		type = 'bool',
		value = '0',
		nosend = true,
		desc = 'Use smaller fonts (works only with DPP fonts)',
	},

	['draw_in_screenshots'] = {
		type = 'bool',
		value = '0',
		nosend = true,
		desc = 'Draw owner display in screenshots',
	},

	['hud_obey_server'] = {
		type = 'bool',
		value = '1',
		desc = 'Disable DPP HUD if server wants so',
	},

	['fancy_hud_obey_server'] = {
		type = 'bool',
		value = '1',
		desc = 'Disable DPP Fancy Display if server wants so',
	},
}

DPP.ProtectionModes = {
	toolgun = 'Toolgun',
	vehicle = 'Vehicle',
	use = 'Use',
	physgun = 'Physgun',
	damage = 'Damage',
	pickup = 'Pickup',
	gravgun = 'Gravgun'
}

for k, v in pairs(DPP.ProtectionModes) do
	DPP.CSettings['disable_' .. k .. '_protection'] = {
		type = 'bool',
		value = '0',
		desc = 'Disable "' .. k .. '" protection for my entities',
	}

	DPP.RegisterNetworkVar('disablepp.' .. k, net.WriteBool, net.ReadBool, 'boolean')
end

for k, v in pairs(DPP.Settings) do
	v.bool = v.type == 'bool'
	v.int = v.type == 'int'
	v.float = v.type == 'float'

	hook.Run('DPP_ConVarRegistered', k, v)
end

for k, v in pairs(DPP.CSettings) do
	v.bool = v.type == 'bool'
	v.int = v.type == 'int'
	v.float = v.type == 'float'
end

DPP.CVars = {}
DPP.SVars = {}

do
	local friends = {
		'physgun',
		'gravgun',
		'toolgun',
		'use',
		'vehicle',
		'damage',
		'pickup',
	}

	for i, friend in ipairs(friends) do
		DLib.friends.Register('dpp_' .. friend, friend:sub(1, 1):upper() .. friend:sub(2) .. ' DPP buddy', true)
	end
end

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

	function DPP.LocalConVar(var, ifUndefined)
		local t = DPP.CSettings[var]
		if not t then return ifUndefined end
		local type = t.type
		local val = DPP.CVars[var]:GetString()

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
	DPP.NetworkedConVarsDB = DPP.NetworkedConVarsDB or {}

	for k, v in pairs(DPP.Settings) do
		if DPP.NetworkedConVarsDB[k] ~= nil then continue end --Lua Refresh
		if v.bool then
			DPP.NetworkedConVarsDB[k] = v.value == '1'
		elseif v.int then
			DPP.NetworkedConVarsDB[k] = math.floor(tonumber(v.value))
		elseif v.float then
			DPP.NetworkedConVarsDB[k] = tonumber(v.value)
		else
			DPP.NetworkedConVarsDB[k] = v.value
		end
	end

	function DPP.GetConVar(cvar)
		if not DPP.Settings[cvar] then return end
		return DPP.NetworkedConVarsDB[cvar]
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
		MsgC(Color(0, 200, 0), '[DPP] ', Color(200, 200, 200), unpack(DPP.PreprocessPhrases(unpack(first))))
	else
		MsgC(Color(0, 200, 0), '[DPP] ', Color(200, 200, 200), unpack(DPP.PreprocessPhrases(first, ...)))
	end

	MsgC('\n')
end

function DPP.Wrap(func, retval, arg)
	return function(...)
		if not DPP.GetConVar('enable') then return retval, (type(arg) == 'string' and DPP.GetPhrase(arg) or arg) end
		return func(...)
	end
end

function DPP.GetOwner(ent)
	if not IsValid(ent) then return NULL end
	return ent:DPPVar('Owner')
end

function DPP.AddConVar(k, tab)
	DPP.Settings[k] = tab
	tab.bool = tab.type == 'bool'
	tab.int = tab.type == 'int'
	tab.float = tab.type == 'float'

	if SERVER then
		DPP.SVars[k] = CreateConVar('dpp_' .. k, tab.value, {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE})
		cvars.AddChangeCallback('dpp_' .. k, DPP.ConVarChanged, 'DPP')
	end

	hook.Run('DPP_ConVarRegistered', k, tab)
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

		if DPP.IsEntity(ent) then
			ent = ent:GetClass():lower()
		else
			ent = ent:lower()
		end

		if not ply then
			return DPP.BlockedEntities[k][ent]
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
		if DPP.IsEntity(ent) then
			ent = ent:GetClass():lower()
		else
			ent = ent:lower()
		end

		return DPP.BlockedEntities[k][ent] ~= nil
	end
end

for k, v in pairs(DPP.WhitelistTypes) do
	DPP.WhitelistedEntities[k] = DPP.WhitelistedEntities[k] or {}

	DPP.AddConVar('whitelist_' .. k, {
		desc = 'Enable ' .. v .. ' exclude list',
		value = '1',
		type = 'bool',
	})

	DPP['IsEntityWhitelisted' .. v] = function(ent)
		if not DPP.GetConVar('enable') then return false end
		if not DPP.GetConVar('enable_whitelisted') then return false end
		if not DPP.GetConVar('whitelist_' .. k) then return false end

		if DPP.IsEntity(ent) then
			ent = ent:GetClass():lower()
		else
			ent = ent:lower()
		end

		return DPP.WhitelistedEntities[k][ent] ~= nil
	end

	DPP['IsEvenWhitelisted' .. v] = function(ent)
		if DPP.IsEntity(ent) then
			ent = ent:GetClass():lower()
		else
			ent = ent:lower()
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
	DPP.RestrictedTypes_SteamID[k] = DPP.RestrictedTypes_SteamID[k] or {}

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

	DPP.AddConVar('restrict_' .. k .. '_ply', {
		desc = 'Enable ' .. v .. ' restrictions for specific players',
		value = '1',
		type = 'bool',
	})

	local cvar1 = 'restrict_' .. k
	local cvar2 = 'restrict_' .. k .. '_white'
	local cvar3 = 'restrict_' .. k .. '_white_bypass'
	local cvar4 = 'restrict_' .. k .. '_ply'

	DPP['IsRestricted' .. v] = function(class, group)
		if not DPP.GetConVar('enable_lists') then return false end
		if not DPP.GetConVar(cvar1) then return false end
		local isWhite = DPP.GetConVar(cvar2)
		local adminBypass = DPP.GetConVar(cvar3)

		local reply = false
		local hit = false
		local isAdmin

		if DPP.IsEntity(class) then
			class = class:GetClass():lower()
		else
			class = class:lower()
		end

		if DPP.IsEntity(group) then
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

	DPP['IsRestricted' .. v .. 'Player'] = function(ply, class)
		if not DPP.GetConVar('enable_lists') then return false end
		if not DPP.GetConVar(cvar4) then return false end
		local steamid = DPP.IsEntity(ply) and ply:SteamID() or ply

		if not DPP.RestrictedTypes_SteamID[k][steamid] then return false end
		return DPP.HasValueLight(DPP.RestrictedTypes_SteamID[k][steamid], class)
	end

	DPP['IsEvenRestricted' .. v] = function(class)
		if DPP.IsEntity(class) then
			class = class:GetClass():lower()
		else
			class = class:lower()
		end

		local T = DPP.RestrictedTypes[k][class]

		if T then
			return true
		else
			return false
		end
	end

	DPP['IsEvenRestricted' .. v .. 'Player'] = function(ply, class)
		local steamid = DPP.IsEntity(ply) and ply:SteamID() or ply

		if not DPP.RestrictedTypes_SteamID[k][steamid] then return false end
		return DPP.HasValueLight(DPP.RestrictedTypes_SteamID[k][steamid], class)
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

function DPP.GetModelLimit(model, group)
	if not DPP.GetConVar('model_limits_enable') then return DPP_NO_LIMIT_DEFINED end
	local T = DPP.ModelsLimits[model]

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

DPP.langObject = DPP_lang.Create()

function DPP.PhraseByLang(lang, id, ...)
	return DPP.langObject:getByLang(lang, id, ...)
end

function DPP.PhraseByLangSafe(lang, id, ...)
	return DPP.langObject:getByLangSafe(lang, id, ...)
end

function DPP.GetPhrase(id, ...)
	return DPP.langObject:get(id, ...)
end

function DPP.GetPhraseSafe(id, ...)
	return DPP.langObject:getSafe(id, ...)
end

function DPP.PhraseExists(id)
	return DPP.langObject:exists(id)
end

local GetPhrase = DPP.GetPhrase

DPP.GetPhraseByLang = DPP.PhraseByLang

function DPP.RegisterPhrase(lang, id, str)
	return DPP.langObject:register(lang, id, str)
end

function DPP.RegisterPhraseList(lang, array)
	return DPP.langObject:registerArray(lang, array)
end

--For quickly looking for missing phrases
function DPP.MissingPhrases(lang)
	return DPP.langObject:missing(lang)
end

function DPP.PrintMissingPhrases(lang)
	return DPP.langObject:printMissing(lang)
end

for k, v in pairs(DPP.Settings) do
	DPP.RegisterPhrase('en', 'cvar_' .. k, v.desc)
end

for k, v in pairs(DPP.CSettings) do
	DPP.RegisterPhrase('en', 'ccvar_' .. k, v.desc)
end

for k, v in pairs(DPP.ProtectionModes) do
	DPP.RegisterPhrase('en', 'protmode_' .. k, v)
end

for k, v in pairs(DPP.BlockTypes) do
	DPP.RegisterPhrase('en', 'block_' .. k, v)
end

for k, v in pairs(DPP.RestrictTypes) do
	DPP.RegisterPhrase('en', 'restricted_' .. k, v)
	DPP.RegisterPhrase('en', 'restricted_' .. k .. '_mode', v)
end

for k, v in pairs(DPP.WhitelistTypes) do
	DPP.RegisterPhrase('en', 'exclude_' .. k, v)
end

include('sh_lang.lua')

if SERVER then
	for k, v in pairs(DPP.Settings) do
		DPP.SVars[k] = CreateConVar('dpp_' .. k, v.value, {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE})
		cvars.AddChangeCallback('dpp_' .. k, DPP.ConVarChanged, 'DPP')
	end
else
	for k, v in pairs(DPP.CSettings) do
		local flags = {FCVAR_ARCHIVE}

		if not v.nosend then
			table.insert(flags, FCVAR_USERINFO)
		end

		DPP.CVars[k] = CreateConVar('dpp_' .. k, v.value, flags, v.desc)

		cvars.AddChangeCallback('dpp_' .. k, DPP.ClientConVarChanged, 'DPP')

		timer.Simple(0, function()
			DPP.ClientConVarChanged('dpp_' .. k)
		end)
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

local PlayersTouchAccess = {}
local WorldTouchAccess = {}

local function GetTouchAccess1(ply)
	PlayersTouchAccess[ply] = {
		expires = math.huge,
		waiting = true,
	}

	DPP.HaveAccess(ply, 'touchother', function(result)
		PlayersTouchAccess[ply] = {
			result = result,
			expires = CurTime() + 10,
			waiting = false,
		}
	end)
end

local function GetTouchAccess2(ply)
	WorldTouchAccess[ply] = {
		expires = math.huge,
		waiting = true,
	}

	DPP.HaveAccess(ply, 'touchworld', function(result)
		WorldTouchAccess[ply] = {
			result = result,
			expires = CurTime() + 10,
			waiting = false,
		}
	end)
end

timer.Create('DPP.ClearPlayersTouchAccess', 1, 0, function()
	local ctime = CurTime()

	for k, v in pairs(PlayersTouchAccess) do
		if not IsValid(k) then
			PlayersTouchAccess[k] = nil
		else
			if v.expires < ctime and not v.waiting then
				GetTouchAccess1(k)
			end
		end
	end

	for k, v in pairs(WorldTouchAccess) do
		if not IsValid(k) then
			WorldTouchAccess[k] = nil
		else
			if v.expires < ctime and not v.waiting then
				GetTouchAccess2(k)
			end
		end
	end
end)

function DPP.CanTouchWorld(ply, ent)
	if WorldTouchAccess[ply] == nil then
		GetTouchAccess2(ply)
	end

	if not ent:DPPVar('createdbymap') then
		local canAdmin = DPP.GetConVar('can_admin_touch_world')
		local can = DPP.GetConVar('can_touch_world')

		if not WorldTouchAccess[ply].result then
			return can
		else
			return can or canAdmin
		end
	else
		local canAdmin = DPP.GetConVar('can_admin_touch_world_created')
		local can = DPP.GetConVar('can_touch_world_created')

		if not WorldTouchAccess[ply].result then
			return can
		else
			return can or canAdmin
		end
	end
end

function DPP.CanTouch(ply, ent, mode)
	if not IsValid(ply) then return true, GetPhrase('World') end
	if not IsValid(ent) then return false, GetPhrase('not_valid') end
	if not DPP.GetConVar('enable') then return true, GetPhrase('protection_disabled') end
	if ent:IsPlayer() then return nil end

	local model = ent:GetModel()
	if model then
		if DPP.IsModelBlocked(model, ply, true) then
			return false, GetPhrase('model_is_blacklisted')
		end
	end

	local can, reason = hook.Run('DPP.CanTouch', ply, ent, mode)

	if can == false then return false, reason end
	if can == true then return true, reason end
	--Otherwise, proceed default checks

	if PlayersTouchAccess[ply] == nil then
		GetTouchAccess1(ply)
	end

	local owner = DPP.GetOwner(ent)
	local isOwned = DPP.IsOwned(ent)
	local OwnerName, OwnerUID, OwnerSteamID = DPP.GetOwnerDetails(ent)
	local dString = 'disconnected_' .. OwnerUID

	if not IsValid(owner) and isOwned then owner = dString end

	local realOwner = owner
	local constrained = DPP.GetConstrainedTable(ent)
	local INDEX = table.insert(constrained, owner)

	local can = true
	local reason

	local admin, adminEverything = ply:IsAdmin(), DPP.GetConVar('admin_can_everything')
	local canTouchOther = adminEverything and PlayersTouchAccess[ply].result

	local isShared = DPP.IsShared(ent)
	if mode and DPP.ShareTypes[mode] then
		isShared = DPP.IsSharedType(ent, mode)
	end

	for k, owner in pairs(constrained) do
		if type(owner) == 'string' then
			if owner == dString then
				if isShared then
					if mode then
						reason = GetPhrase('is_shared', mode:gsub('^.', string.upper))
					else
						reason = GetPhrase('is_shared_e')
					end

					continue
				elseif canTouchOther then
					continue
				else
					can = false
					reason = GetPhrase('not_a_owner_pp')
					break
				end
			end

			if string.gsub(owner, 1, 12) == 'disconnected' then
				local UID = string.gsub(owner, 13)

				if canTouchOther then
					continue
				else
					can = false
					reason = GetPhrase('not_a_owner_pp')
					break
				end
			end
		end

		if not DPP.IsEntity(owner) then continue end --???

		if IsValid(owner) and owner:GetClass() == 'gmod_anchor' then continue end

		if owner == ply then
			if DPP.PlayerConVar(ply, 'no_touch') then
				can = false
				reason = GetPhrase('dpp_no_touch_true')
				break
			end

			continue
		end

		if not IsValid(owner) then
			if not DPP.CanTouchWorld(ply, ent) then
				can = false
				reason = GetPhrase('world_pp')
				break
			end

			if DPP.PlayerConVar(ply, 'no_touch_world', false) then
				can = false
				reason = GetPhrase('dpp_no_touch_world')
				break
			end
		else
			if mode and DPP.ProtectionModes[mode] and owner:IsPlayer() then
				if DPP.IsProtectionDisabledFor(owner, mode) then
					reason = GetPhrase('protection_disabled_owner', mode)
				end
			end

			if not isShared or realOwner ~= owner then
				local friend = DPP.IsFriend(owner, ply, mode)

				if DPP.PlayerConVar(ply, 'no_touch_other', false) then
					can = false
					reason = GetPhrase('dpp_no_touch_other')
					break
				end

				if canTouchOther then
					continue
				elseif not friend then
					can = false
					reason = GetPhrase('not_a_owner_pp')
					break
				end
			else
				if mode then
					reason = GetPhrase('is_shared', mode:gsub('^.', string.upper))
				else
					reason = GetPhrase('is_shared_e')
				end
			end
		end
	end

	constrained[INDEX] = nil

	return can, reason
end

local ConsoleColor = Color(196, 0, 255)
local DisconnectedPlayerColor = Color(134, 255, 154)

function DPP.FormatPlayer(ply)
	if not IsValid(ply) then
		return {color_white, '[NULL Player]'}
	end

	local t = {}

	table.insert(t, team.GetColor(ply:Team()))

	local nick = ply:Nick()
	table.insert(t, '!#' .. nick)

	if ply.SteamName and ply:SteamName() ~= nick then
		table.insert(t, ' (' .. ply:SteamName() .. ')')
	end

	table.insert(t, color_white)
	table.insert(t, '<' .. ply:SteamID() .. '>')

	return t
end

function DPP.TFormat(arg)
	local repack = {}

	for k, v in ipairs(arg) do
		local Type = type(v)
		local IsEntity = DPP.IsEntity(v)

		if Type == 'Player' then
			for a, b in ipairs(DPP.FormatPlayer(v)) do
				table.insert(repack, b)
			end

			continue
		end

		if IsEntity then
			table.insert(repack, tostring(v))
			continue
		end

		if Type == 'table' then
			if v.r and v.g and v.b and v.a then --Duck typing
				table.insert(repack, v)
				continue
			end

			if v.type then
				if v.type == 'UIDPlayer' then
					local ply = player.GetByUniqueID(v.uid)

					if ply then
						for a, b in ipairs(DPP.FormatPlayer(ply)) do
							table.insert(repack, b)
						end
					else
						table.insert(repack, DisconnectedPlayerColor)
						table.insert(repack, DPP.DisconnectedPlayerNick(v.uid))
					end

					continue
				end
			end

			continue
		end

		if Type == 'number' then
			table.insert(repack, tostring(v))
			continue
		end

		if Type == 'string' then
			if v == 'Console' or v == '#Console' then
				table.insert(repack, ConsoleColor)
				table.insert(repack, v)
			else
				table.insert(repack, v)
			end
		end
	end

	return repack
end

function DPP.ResetConVars()
	if CLIENT then return end

	for k, val in pairs(DPP.Settings) do
		RunConsoleCommand('dpp_' .. k, val.value)
	end

	DPP.DoEcho(Color(215, 45, 45), '#reset_cvars')
end

function DPP.Format(...)
	return DPP.TFormat{...}
end

function DPP.PreprocessPhrases(...)
	local repack = {}

	for k, v in ipairs{...} do
		if type(v) ~= 'string' then
			table.insert(repack, v)
			continue
		end

		if v:sub(1, 2) == '!#' then
			table.insert(repack, v:sub(3))
			continue
		end

		if v:sub(1, 1) ~= '#' then
			table.insert(repack, v)
			continue
		end

		local raw = v:sub(2)
		local args = string.Explode('||', raw)
		local id = table.remove(args, 1)

		if DPP.PhraseExists(id) then
			table.insert(repack, DPP.GetPhraseSafe(id, unpack(args)))
		else
			table.insert(repack, '<INVALID PHRASE - ' .. id .. '>')
		end
	end

	return repack
end

DPP.AssignConVarNetworkIDs()

concommand.Add('dpp_restart', function(ply)
	if SERVER and IsValid(ply) then return end
	include('sh_init.lua')
end)

include('sh_access.lua')
include('sh_hooks.lua')

if SERVER then
	include('sv_savedata.lua')
	include('sv_apropkill.lua')
	include('sv_networking_post.lua')
else
	include('cl_settings.lua')
end
