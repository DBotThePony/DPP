
--[[
Copyright (C) 2016-2017 DBot

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

include('sv_mysql.lua')

local RED = Color(200, 0, 0)

local function DBError(Message)
	DPP.SimpleLog(RED, '-----------------------------------------')
	DPP.SimpleLog(RED, 'FATAL: Failed to create SQL tables!\nError message was: ' .. Message)
	DPP.SimpleLog(RED, '-----------------------------------------')
end

function DPP.CreateTables()
	DPP.SQL_TABLES = {
		[[
			CREATE TABLE IF NOT EXISTS dpp_blockedmodels (
				MODEL VARCHAR(64) NOT NULL,
				PRIMARY KEY (MODEL)
			)
		]],

		[[
			CREATE TABLE IF NOT EXISTS dpp_cvars (
				CVAR VARCHAR(64) NOT NULL,
				`VALUE` VARCHAR(64) NOT NULL,
				PRIMARY KEY (CVAR)
			)
		]],

		[[
			CREATE TABLE IF NOT EXISTS dpp_entitylimits (
				CLASS VARCHAR(64) NOT NULL,
				UGROUP VARCHAR(64) NOT NULL,
				ULIMIT INT NOT NULL,
				PRIMARY KEY (CLASS, UGROUP)
			)
		]],

		[[
			CREATE TABLE IF NOT EXISTS dpp_modellimits (
				MODEL VARCHAR(64) NOT NULL,
				UGROUP VARCHAR(64) NOT NULL,
				ULIMIT INT NOT NULL,
				PRIMARY KEY (MODEL, UGROUP)
			)
		]],

		[[
			CREATE TABLE IF NOT EXISTS dpp_sboxlimits (
				CLASS VARCHAR(64) NOT NULL,
				UGROUP VARCHAR(64) NOT NULL,
				ULIMIT INT NOT NULL,
				PRIMARY KEY (CLASS, UGROUP)
			)
		]],

		[[
			CREATE TABLE IF NOT EXISTS dpp_constlimits (
				CLASS VARCHAR(64) NOT NULL,
				UGROUP VARCHAR(64) NOT NULL,
				ULIMIT INT NOT NULL,
				PRIMARY KEY (CLASS, UGROUP)
			)
		]],
	}

	for k, v in pairs(DPP.BlockTypes) do
		table.insert(DPP.SQL_TABLES, [[
			CREATE TABLE IF NOT EXISTS dpp_blockedentities]] .. k .. [[ (
				ENTITY VARCHAR(64) NOT NULL,
				PRIMARY KEY (ENTITY)
			)
		]])
	end

	for k, v in pairs(DPP.WhitelistTypes) do
		table.insert(DPP.SQL_TABLES, [[
			CREATE TABLE IF NOT EXISTS dpp_whitelistentities]] .. k .. [[ (
				ENTITY VARCHAR(64) NOT NULL,
				PRIMARY KEY (ENTITY)
			)
		]])
	end

	for k, v in pairs(DPP.RestrictTypes) do
		table.insert(DPP.SQL_TABLES, [[
			CREATE TABLE IF NOT EXISTS dpp_restricted]] .. k .. [[ (
				CLASS VARCHAR(64) NOT NULL,
				GROUPS VARCHAR(255) NOT NULL,
				IS_WHITE BOOL NOT NULL,
				PRIMARY KEY (CLASS)
			)
		]])
		
		table.insert(DPP.SQL_TABLES, [[
			CREATE TABLE IF NOT EXISTS dpp_restricted]] .. k .. [[_ply (
				STEAMID VARCHAR(32) NOT NULL,
				CLASS VARCHAR(64) NOT NULL,
				PRIMARY KEY (CLASS, STEAMID)
			)
		]])
	end

	DPP.Message('Initializing database tables')
	local Time = SysTime()

	local LINK = DPP.GetLink()
	LINK:Begin(true)

	for k, v in ipairs(DPP.SQL_TABLES) do
		LINK:Add(v, nil, DBError)
	end

	LINK:Commit(function()
		DPP.Message('Finished in ' .. math.floor((SysTime() - Time) * 100000) / 100 .. 'ms')
		DPP.ContinueDatabaseStartup()
	end)
end

local Gray = Color(200, 200, 200)
local ResetWarning = Color(215, 45, 45)

-- FPP is blocking that entities because they are logical
-- And should be NEVER touched by player entity in any way
local blockedEnts = {
	'ai_network',
	'ambient_generic',
	'beam',
	'bodyque',
	'env_soundscape',
	'env_sprite',
	'env_sun',
	'env_tonemap_controller',
	'func_useableladder',
	'info_ladder_dismount',
	'info_player_start',
	'info_player_terrorist',
	'light_environment',
	'light_spot',
	'physgun_beam',
	'player_manager',
	'point_spotlight',
	'predicted_viewmodel',
	'scene_manager',
	'shadow_control',
	'soundent',
	'spotlight_end',
	'water_lod_control',
	'gmod_gamerules',
	'bodyqueue',
	'phys_bone_follower',

	--Some DPP additions. This list is trying to predict entities like above
	'info_spawn',
	'info_spawnpoint',
	'info_light',
	'trigger_changelevel',
	'trigger_push',
	'trigger_secret',
	'trigger_hurt',
	'point_hurt',
	'trigger_impact',
	'trigger_gravity',
	'gmod_anchor',
	'bodyque',
	'soundent',
	'player_manager',
	'scene_manager',
	'env_shake',
}

function DPP.FindInfoEntities() --Add custom entities
	local list = scripted_ents.GetList()

	for k, v in pairs(list) do
		if string.find(k, 'info_') then
			if v.type ~= 'point' then continue end
			table.insert(blockedEnts, k)
		end
	end
end

function DPP.AddBlockedModel(model)
	DPP.BlockedModels[model] = true
	DPP.Query('REPLACE INTO dpp_blockedmodels (MODEL) VALUES ("' .. model .. '")')

	net.Start('DPP.ModelsInsert')
	net.WriteString(model)
	net.WriteBool(true)
	net.Broadcast()
end

function DPP.RemoveBlockedModel(model)
	DPP.BlockedModels[model] = nil
	DPP.Query('DELETE FROM dpp_blockedmodels WHERE MODEL = "' .. model .. '"')

	net.Start('DPP.ModelsInsert')
	net.WriteString(model)
	net.WriteBool(false)
	net.Broadcast()
end

DPP.ManipulateCommands = {
	addblockedmodel = function(ply, cmd, args)
		if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_model'}, NOTIFY_ERROR end
		args[1] = args[1]:lower():Trim()
		if DPP.BlockedModels[args[1]] then return false, {'#saveload_model_already_y'} end
		DPP.AddBlockedModel(args[1])
		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#saveload_added', color_white, args[1], Gray, '#saveload_to', '#saveload_bmodels'}
	end,

	removeblockedmodel = function(ply, cmd, args)
		if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_model'}, NOTIFY_ERROR end
		args[1] = args[1]:lower():Trim()
		if not DPP.BlockedModels[args[1]] then return false, {'#saveload_model_already_n'} end
		DPP.RemoveBlockedModel(args[1])
		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#saveload_removed', color_white, args[1], Gray, '#saveload_from', '#saveload_bmodels'}
	end,
}

function DPP.SaveAllBlockedModels()
	DPP.Query('REMOVE FROM dpp_blockedmodels', function()
		local t = {}

		for k, v in pairs(DPP.BlockedModels) do
			table.insert(t, 'INSERT INTO dpp_blockedmodels (MODEL) VALUES ("' .. k .. '")')
		end

		DPP.QueryStack(t)
	end)
end

function DPP.LoadBlockedModels()
	DPP.BlockedModels = {}
	DPP.Query('SELECT * FROM dpp_blockedmodels', function(data)
		if not data then return end

		for k, v in pairs(data) do
			DPP.BlockedModels[v.MODEL] = true
		end
	end)
end

function DPP.ResetBlockedModels()
	DPP.BlockedModels = {}
	DPP.Query('DELETE FROM dpp_blockedmodels')
	DPP.DoEcho(ResetWarning, '#reset_modellist')
	net.Start('DPP.ResetBlockedModels')
	net.Broadcast()
end

DPP.ManipulateCommands.freset_models = function(ply, cmd, args)
	DPP.NotifyLog{ResetWarning, ply, ResetWarning, '#reset_command_models'}
	DPP.ResetBlockedModels()
end

for k, v in pairs(DPP.BlockTypes) do
	DPP['AddBlockedEntity' .. v] = function(ent)
		ent = ent:lower():Trim()
		if DPP.HasValueLight(blockedEnts, ent) then return end
		timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)

		net.Start('DPP.ListsInsert')
		net.WriteString(k)
		net.WriteString(ent)
		net.WriteBool(true)
		net.Broadcast()

		DPP.BlockedEntities[k][ent] = true
		DPP.Query('REPLACE INTO dpp_blockedentities' .. k .. ' (ENTITY) VALUES ("' .. ent .. '")')
	end

	DPP['RemoveBlockedEntity' .. v] = function(ent)
		ent = ent:lower():Trim()
		if DPP.HasValueLight(blockedEnts, ent) then return end
		timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)

		net.Start('DPP.ListsInsert')
		net.WriteString(k)
		net.WriteString(ent)
		net.WriteBool(false)
		net.Broadcast()

		DPP.BlockedEntities[k][ent] = nil
		DPP.Query('DELETE FROM dpp_blockedentities' .. k .. ' WHERE ENTITY = "' .. ent .. '"')
	end

	DPP.ManipulateCommands['addblockedentity' .. k] = function(ply, cmd, args)
		if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_class'}, NOTIFY_ERROR end
		args[1] = args[1]:lower():Trim()
		if DPP.BlockedEntities[k][args[1]] then return false, {'#saveload_entity_already_y'} end
		if DPP.HasValueLight(blockedEnts, args[1]) then return false, {'#saveload_unable_to_add'}, NOTIFY_ERROR end
		DPP['AddBlockedEntity' .. v](args[1])
		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#saveload_added', color_white, args[1], Gray, '#saveload_to', color_white, '#block_' .. k, Gray, '#saveload_blackwhite'}
	end

	DPP.ManipulateCommands['removeblockedentity' .. k] = function(ply, cmd, args)
		if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_class'}, NOTIFY_ERROR end
		args[1] = args[1]:lower():Trim()
		if not DPP.BlockedEntities[k][args[1]] then return false, {'#saveload_entity_already_n'} end
		if DPP.HasValueLight(blockedEnts, args[1]) then return false, {'#saveload_unable_to_remove'}, NOTIFY_ERROR end
		DPP['RemoveBlockedEntity' .. v](args[1])
		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#saveload_removed', color_white, args[1], Gray, '#saveload_from', color_white, '#block_' .. k, Gray, '#saveload_blackwhite'}
	end
end

for k, v in pairs(DPP.WhitelistTypes) do
	DPP['AddWhitelistedEntity' .. v] = function(ent)
		ent = ent:lower():Trim()
		if DPP.HasValueLight(blockedEnts, ent) then return end
		timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)

		net.Start('DPP.WListsInsert')
		net.WriteString(k)
		net.WriteString(ent)
		net.WriteBool(true)
		net.Broadcast()

		DPP.WhitelistedEntities[k][ent] = true
		DPP.Query('REPLACE INTO dpp_whitelistentities' .. k .. ' (ENTITY) VALUES ("' .. ent .. '")')
	end

	DPP['RemoveWhitelistedEntity' .. v] = function(ent)
		ent = ent:lower():Trim()
		if DPP.HasValueLight(blockedEnts, ent) then return end
		timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)

		net.Start('DPP.WListsInsert')
		net.WriteString(k)
		net.WriteString(ent)
		net.WriteBool(false)
		net.Broadcast()

		DPP.WhitelistedEntities[k][ent] = nil
		DPP.Query('DELETE FROM dpp_whitelistentities' .. k .. ' WHERE ENTITY = "' .. ent .. '"')
	end

	DPP.ManipulateCommands['addwhitelistedentity' .. k] = function(ply, cmd, args)
		if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_class'}, NOTIFY_ERROR end
		args[1] = args[1]:lower():Trim()
		if DPP.WhitelistedEntities[k][args[1]] then return false, {'#saveload_eentity_already_y'} end
		if DPP.HasValueLight(blockedEnts, args[1]) then return false, {'You can not add that entity to exclude list'}, NOTIFY_ERROR end
		DPP['AddWhitelistedEntity' .. v](args[1])
		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#saveload_added', color_white, args[1], Gray, '#saveload_to', '#exclude_' .. k, '#saveload_excludedents'}
	end

	DPP.ManipulateCommands['removewhitelistedentity' .. k] = function(ply, cmd, args)
		if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_class'}, NOTIFY_ERROR end
		args[1] = args[1]:lower():Trim()
		if not DPP.WhitelistedEntities[k][args[1]] then return false, {'#saveload_eentity_already_n'} end
		DPP['RemoveWhitelistedEntity' .. v](args[1])
		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#saveload_removed', color_white, args[1], Gray, '#saveload_from', color_white, '#exclude_' .. k, Gray, '#saveload_excludedents'}
	end
end

for k, v in pairs(DPP.RestrictTypes) do
	DPP['AppendRestrict' .. v] = function(class, group)
		class = class:lower():Trim()
		
		if not DPP.RestrictedTypes[k][class] then
			DPP['Restrict' .. v](class, {group}, false)
			return
		end
		
		local myGroups = DPP.RestrictedTypes[k][class].groups
		if DPP.HasValueLight(myGroups, group) then return end
		table.insert(myGroups, group)
		
		timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)

		net.Start('DPP.RListsInsert')
		net.WriteString(k)
		net.WriteString(class)
		net.WriteBool(true)
		net.WriteTable(myGroups)
		net.WriteBool(DPP.RestrictedTypes[k][class].iswhite)
		net.Broadcast()
		
		DPP.Query(string.format('REPLACE INTO dpp_restricted' .. k .. ' (CLASS, GROUPS, IS_WHITE) VALUES (%q, \'%s\', %q)', class, util.TableToJSON(myGroups), DPP.RestrictedTypes[k][class].iswhite and '1' or '0'))
	end
	
	DPP['Restrict' .. v] = function(class, groups, isWhite)
		class = class:lower():Trim()
		timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)

		net.Start('DPP.RListsInsert')
		net.WriteString(k)
		net.WriteString(class)
		net.WriteBool(true)
		net.WriteTable(groups)
		net.WriteBool(isWhite)
		net.Broadcast()

		DPP.RestrictedTypes[k][class] = {
			groups = groups,
			iswhite = isWhite
		}

		DPP.Query(string.format('REPLACE INTO dpp_restricted' .. k .. ' (CLASS, GROUPS, IS_WHITE) VALUES (%q, \'%s\', %q)', class, util.TableToJSON(groups), isWhite and '1' or '0'))
	end
	
	DPP['Restrict' .. v .. 'Player'] = function(ply, class)
		class = class:lower():Trim()
		local steamid = DPP.IsEntity(ply) and ply:SteamID() or ply
		
		DPP.RestrictedTypes_SteamID[k][steamid] = DPP.RestrictedTypes_SteamID[k][steamid] or {}
		if DPP.HasValueLight(DPP.RestrictedTypes_SteamID[k][steamid], class) then return end
		
		timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)

		net.Start('DPP.RListsInsert_Player')
		net.WriteString(k)
		net.WriteString(steamid)
		net.WriteString(class)
		net.WriteBool(true)
		net.Broadcast()

		table.insert(DPP.RestrictedTypes_SteamID[k][steamid], class)

		DPP.Query(string.format('REPLACE INTO dpp_restricted' .. k .. '_ply (STEAMID, CLASS) VALUES (%q, %q)', steamid, class))
	end
	
	DPP['UnRestrict' .. v .. 'Player'] = function(ply, class)
		class = class:lower():Trim()
		local steamid = DPP.IsEntity(ply) and ply:SteamID() or ply
		
		DPP.RestrictedTypes_SteamID[k][steamid] = DPP.RestrictedTypes_SteamID[k][steamid] or {}
		if not DPP.HasValueLight(DPP.RestrictedTypes_SteamID[k][steamid], class) then return end
		
		timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)

		net.Start('DPP.RListsInsert_Player')
		net.WriteString(k)
		net.WriteString(steamid)
		net.WriteString(class)
		net.WriteBool(false)
		net.Broadcast()

		DPP.PopFromArray(DPP.RestrictedTypes_SteamID[k][steamid], class)

		DPP.Query(string.format('DELETE FROM dpp_restricted' .. k .. '_ply WHERE STEAMID = %q AND CLASS = %q', steamid, class))
	end

	DPP['UnRestrict' .. v] = function(class, groups)
		class = class:lower():Trim()
		timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)

		net.Start('DPP.RListsInsert')
		net.WriteString(k)
		net.WriteString(class)
		net.WriteBool(false)
		net.Broadcast()

		DPP.RestrictedTypes[k][class] = nil
		DPP.Query('DELETE FROM dpp_restricted' .. k .. ' WHERE CLASS = "' .. class .. '"')
	end

	DPP.ManipulateCommands['restrict' .. k] = function(ply, cmd, args)
		if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_command_message_1'}, NOTIFY_ERROR end
		if not args[2] then return false, {'#saveload_command_message_2'}, NOTIFY_ERROR end --No groups allowed
		if not args[3] or args[3]:Trim() == '' then return false, {'#saveload_command_message_3'}, NOTIFY_ERROR end

		local class = args[1]:lower():Trim()
		local groups = string.Explode(',', args[2])
		local isWhite = tobool(args[3])
		local old = DPP.RestrictedTypes[k][class]

		DPP['Restrict' .. v](class, groups, isWhite)

		if not old then
			DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#saveload_added', color_white, class, Gray, '#saveload_to', '#saveload_restricted', color_white, '#restricted_' .. k, Gray, '#saveload_blackwhite'}
		else
			DPP.DoEcho(IsValid(ply) and ply or '#Console', Gray, ' updated restricts for ', color_white, class)
			if IsValid(ply) then
				DPP.Notify(ply, '#restricts_updated||' .. class)
			end
		end
	end

	DPP.ManipulateCommands['unrestrict' .. k] = function(ply, cmd, args)
		if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_command_message_4'}, NOTIFY_ERROR end

		local class = args[1]:lower():Trim()

		DPP['UnRestrict' .. v](class)

		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#saveload_removed', color_white, args[1], Gray, '#saveload_from', '#saveload_restricted', color_white, '#restricted_' .. k, Gray, '#saveload_blackwhite'}
	end
	
	DPP.ManipulateCommands['restrict' .. k .. '_ply'] = function(ply, cmd, args)
		if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_command_message_1ply'}, NOTIFY_ERROR end
		if not args[2] or args[2]:Trim() == '' then return false, {'#saveload_command_message_2ply'}, NOTIFY_ERROR end

		local class = args[2]:lower():Trim()
		local steamid = args[1]:Trim()
		
		DPP.RestrictedTypes_SteamID[k][steamid] = DPP.RestrictedTypes_SteamID[k][steamid] or {}
		if DPP.HasValueLight(DPP.RestrictedTypes_SteamID[k][steamid], class) then return false, {'#plyrestrict_already_restricted'}, NOTIFY_ERROR end
		
		DPP['Restrict' .. v .. 'Player'](steamid, class)

		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#saveload_added', color_white, class, Gray, '#saveload_to', '#saveload_restricted', color_white, '#restricted_' .. k .. '_mode', Gray, '#plyrestrict_from', player.GetBySteamID(steamid) or steamid}
	end
	
	DPP.ManipulateCommands['unrestrict' .. k .. '_ply'] = function(ply, cmd, args)
		if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_command_message_1ply'}, NOTIFY_ERROR end
		if not args[2] or args[2]:Trim() == '' then return false, {'#saveload_command_message_2ply'}, NOTIFY_ERROR end

		local class = args[2]:lower():Trim()
		local steamid = args[1]:Trim()
		
		DPP.RestrictedTypes_SteamID[k][steamid] = DPP.RestrictedTypes_SteamID[k][steamid] or {}
		if not DPP.HasValueLight(DPP.RestrictedTypes_SteamID[k][steamid], class) then return false, {'#plyrestrict_already_not_restricted'}, NOTIFY_ERROR end
		
		DPP['UnRestrict' .. v .. 'Player'](steamid, class)

		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#saveload_removed', color_white, class, Gray, '#saveload_from', '#saveload_restricted', color_white, '#restricted_' .. k .. '_mode', Gray, '#plyrestrict_from', player.GetBySteamID(steamid) or steamid}
	end
end

function DPP.AddEntityLimit(class, group, val)
	if not val then return end
	class = class:lower():Trim()
	val = math.max(val, 1)
	DPP.EntsLimits[class] = DPP.EntsLimits[class] or {}
	DPP.EntsLimits[class][group] = val

	net.Start('DPP.LListsInsert')
	net.WriteString(class)
	net.WriteTable(DPP.EntsLimits[class])
	net.Broadcast()

	DPP.Query(string.format('REPLACE INTO dpp_entitylimits (CLASS, UGROUP, ULIMIT) VALUES (%q, %q, %q)', class, group, val))

	timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)
end

function DPP.RemoveEntityLimit(class, group)
	class = class:lower():Trim()

	if group then
		DPP.EntsLimits[class] = DPP.EntsLimits[class] or {}
		DPP.EntsLimits[class][group] = nil

		DPP.Query(string.format('DELETE FROM dpp_entitylimits WHERE CLASS = %q AND UGROUP = %q', class, group))
	else
		DPP.EntsLimits[class] = nil
		DPP.Query(string.format('DELETE FROM dpp_entitylimits WHERE CLASS = %q', class))
	end

	net.Start('DPP.LListsInsert')
	net.WriteString(class)
	net.WriteTable(DPP.EntsLimits[class])
	net.Broadcast()

	timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)
end

function DPP.AddModelLimit(model, group, val)
	if not val then return end
	model = model:lower():Trim()
	val = math.max(val, 1)
	DPP.ModelsLimits[model] = DPP.ModelsLimits[model] or {}
	DPP.ModelsLimits[model][group] = val

	net.Start('DPP.MLListsInsert')
	net.WriteString(model)
	net.WriteTable(DPP.ModelsLimits[model])
	net.Broadcast()

	DPP.Query(string.format('REPLACE INTO dpp_modellimits (MODEL, UGROUP, ULIMIT) VALUES (%q, %q, %q)', model, group, val))

	timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)
end

function DPP.RemoveModelLimit(model, group)
	model = model:lower():Trim()

	if group then
		DPP.ModelsLimits[model] = DPP.ModelsLimits[model] or {}
		DPP.ModelsLimits[model][group] = nil

		DPP.Query(string.format('DELETE FROM dpp_modellimits WHERE MODEL = %q AND UGROUP = %q', model, group))
	else
		DPP.ModelsLimits[model] = nil
		DPP.Query(string.format('DELETE FROM dpp_modellimits WHERE MODEL = %q', model))
	end

	net.Start('DPP.MLListsInsert')
	net.WriteString(model)
	net.WriteTable(DPP.ModelsLimits[model])
	net.Broadcast()

	timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)
end

function DPP.AddSBoxLimit(class, group, val)
	if not val then return end

	class = class:lower():Trim()

	DPP.SBoxLimits[class] = DPP.SBoxLimits[class] or {}
	DPP.SBoxLimits[class][group] = val

	net.Start('DPP.SListsInsert')
	net.WriteString(class)
	net.WriteTable(DPP.SBoxLimits[class])
	net.Broadcast()

	DPP.Query(string.format('REPLACE INTO dpp_sboxlimits (CLASS, UGROUP, ULIMIT) VALUES (%q, %q, %q)', class, group, val))

	timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)
end

function DPP.AddConstLimit(class, group, val)
	if not val then return end

	class = class:lower():Trim()

	DPP.ConstrainsLimits[class] = DPP.ConstrainsLimits[class] or {}
	DPP.ConstrainsLimits[class][group] = val

	net.Start('DPP.CListsInsert')
	net.WriteString(class)
	net.WriteTable(DPP.ConstrainsLimits[class])
	net.Broadcast()

	DPP.Query(string.format('REPLACE INTO dpp_constlimits (CLASS, UGROUP, ULIMIT) VALUES (%q, %q, %q)', class, group, val))

	timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)
end

function DPP.RemoveSBoxLimit(class, group)
	class = class:lower():Trim()

	if group then
		DPP.SBoxLimits[class] = DPP.SBoxLimits[class] or {}
		DPP.SBoxLimits[class][group] = nil

		DPP.Query(string.format('DELETE FROM dpp_sboxlimits WHERE CLASS = %q AND UGROUP = %q', class, group))
	else
		DPP.SBoxLimits[class] = nil
		DPP.Query(string.format('DELETE FROM dpp_sboxlimits WHERE CLASS = %q', class))
	end

	net.Start('DPP.SListsInsert')
	net.WriteString(class)
	net.WriteTable(DPP.SBoxLimits[class] or {})
	net.Broadcast()

	timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)
end

function DPP.RemoveConstLimit(class, group)
	class = class:lower():Trim()

	if group then
		DPP.ConstrainsLimits[class] = DPP.ConstrainsLimits[class] or {}
		DPP.ConstrainsLimits[class][group] = nil

		DPP.Query(string.format('DELETE FROM dpp_constlimits WHERE CLASS = %q AND UGROUP = %q', class, group))
	else
		DPP.ConstrainsLimits[class] = nil
		DPP.Query(string.format('DELETE FROM dpp_constlimits WHERE CLASS = %q', class))
	end

	net.Start('DPP.CListsInsert')
	net.WriteString(class)
	net.WriteTable(DPP.ConstrainsLimits[class] or {})
	net.Broadcast()

	timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)
end

function DPP.LoadLimits()
	DPP.EntsLimits = {}
	
	DPP.Query('SELECT * FROM dpp_entitylimits', function(data)
		if not data then return end

		for index, row in pairs(data) do
			DPP.EntsLimits[row.CLASS] = DPP.EntsLimits[row.CLASS] or {}
			DPP.EntsLimits[row.CLASS][row.UGROUP] = row.ULIMIT
		end
	end)
end

function DPP.ResetLimits()
	DPP.EntsLimits = {}
	DPP.Query('DELETE FROM dpp_entitylimits')
	DPP.DoEcho(ResetWarning, '#reset_limits')
	net.Start('DPP.ResetLimits')
	net.Broadcast()
end

DPP.ManipulateCommands.freset_limits = function(ply, cmd, args)
	DPP.NotifyLog{ResetWarning, ply, ResetWarning, '#reset_command_limits'}
	DPP.ResetLimits()
end

function DPP.LoadMLimits()
	DPP.ModelsLimits = {}
	
	DPP.Query('SELECT * FROM dpp_modellimits', function(data)
		if not data then return end

		for index, row in pairs(data) do
			DPP.ModelsLimits[row.MODEL] = DPP.ModelsLimits[row.MODEL] or {}
			DPP.ModelsLimits[row.MODEL][row.UGROUP] = row.ULIMIT
		end
	end)
end

function DPP.ResetMLimits()
	DPP.ModelsLimits = {}
	DPP.Query('DELETE FROM dpp_modellimits')
	DPP.DoEcho(ResetWarning, '#reset_modellimits')
	net.Start('DPP.ResetMLimits')
	net.Broadcast()
end

DPP.ManipulateCommands.freset_mlimits = function(ply, cmd, args)
	DPP.NotifyLog{ResetWarning, ply, ResetWarning, '#reset_command_mlimits'}
	DPP.ResetMLimits()
end

function DPP.LoadSLimits()
	DPP.SBoxLimits = {}
	DPP.Query('SELECT * FROM dpp_sboxlimits', function(data)
		if not data then return end

		for index, row in pairs(data) do
			DPP.SBoxLimits[row.CLASS] = DPP.SBoxLimits[row.CLASS] or {}
			DPP.SBoxLimits[row.CLASS][row.UGROUP] = row.ULIMIT
		end
	end)
end

function DPP.ResetSLimits()
	DPP.SBoxLimits = {}
	DPP.Query('DELETE FROM dpp_sboxlimits')
	DPP.DoEcho(ResetWarning, '#reset_sboxlimits')
	net.Start('DPP.ResetSLimits')
	net.Broadcast()
end

DPP.ManipulateCommands.freset_slimits = function(ply, cmd, args)
	DPP.NotifyLog{ResetWarning, ply, ResetWarning, '#reset_command_slimits'}
	DPP.ResetSLimits()
end

function DPP.LoadCLimits()
	DPP.ConstrainsLimits = {}
	DPP.Query('SELECT * FROM dpp_constlimits', function(data)
		if not data then return end

		for index, row in pairs(data) do
			DPP.ConstrainsLimits[row.CLASS] = DPP.ConstrainsLimits[row.CLASS] or {}
			DPP.ConstrainsLimits[row.CLASS][row.UGROUP] = row.ULIMIT
		end
	end)
end

function DPP.ResetCLimits()
	DPP.ConstrainsLimits = {}
	DPP.Query('DELETE FROM dpp_constlimits')
	DPP.DoEcho(ResetWarning, '#reset_constlimits')
	net.Start('DPP.ResetCLimits')
	net.Broadcast()
end

DPP.ManipulateCommands.freset_climits = function(ply, cmd, args)
	DPP.NotifyLog{ResetWarning, ply, ResetWarning, '#reset_command_climits'}
	DPP.ResetCLimits()
end

local Last = 0

DPP.ManipulateCommands.addentitylimit = function(ply, cmd, args)
	if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_class', ' (#1)'}, NOTIFY_ERROR end
	if not args[2] or args[2]:Trim() == '' then return false, {'#saveload_command_message_2'}, NOTIFY_ERROR end
	if not args[3] or args[3]:Trim() == '' then return false, {'#saveload_invalid_limit', ' (#3)'}, NOTIFY_ERROR end

	local class = args[1]:lower():Trim()
	local group = args[2]
	local num = tonumber(args[3])

	if not num then return false, {'#saveload_invalid_limit', ' (#3)'}, NOTIFY_ERROR end

	DPP.AddEntityLimit(class, group, num)

	if Last < CurTime() then
		local f = {IsValid(ply) and ply or '#Console', Gray, '#saveload_added_updated', color_white, class, Gray, '#saveload_limits', color_white, group}
		DPP.NotifyLog(f)
		Last = CurTime() + 0.5
	end
end

DPP.ManipulateCommands.removeentitylimit = function(ply, cmd, args)
	if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_class', ' (#1)'}, NOTIFY_ERROR end
	if not args[2] or args[2]:Trim() == '' then return false, {'#saveload_command_message_2'}, NOTIFY_ERROR end

	local class = args[1]:lower():Trim()
	local group = args[2]
	if not DPP.EntsLimits[class] then return false, {'#saveload_limit_not_exists'} end
	if not DPP.EntsLimits[class][group] then return false, {'#saveload_glimit_not_exists'} end

	DPP.RemoveEntityLimit(class, group)

	if Last < CurTime() then
		local f = {IsValid(ply) and ply or '#Console', Gray, '#saveload_removed', color_white, class, Gray, '#saveload_limit_removed', color_white, group}
		DPP.NotifyLog(f)
		Last = CurTime() + 0.5
	end
end

DPP.ManipulateCommands.addmodellimit = function(ply, cmd, args)
	if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_model', ' (#1)'}, NOTIFY_ERROR end
	if not args[2] or args[2]:Trim() == '' then return false, {'#saveload_command_message_2'}, NOTIFY_ERROR end
	if not args[3] or args[3]:Trim() == '' then return false, {'#saveload_invalid_limit', ' (#3)'}, NOTIFY_ERROR end

	local model = args[1]:lower():Trim()
	local group = args[2]
	local num = tonumber(args[3])

	if not num then return false, {'#saveload_invalid_limit', ' (#3)'}, NOTIFY_ERROR end

	DPP.AddModelLimit(model, group, num)

	if Last < CurTime() then
		local f = {IsValid(ply) and ply or '#Console', Gray, '#saveload_added_updated', color_white, model, Gray, '#saveload_limits_models', color_white, group}
		DPP.NotifyLog(f)
		Last = CurTime() + 0.5
	end
end

DPP.ManipulateCommands.removemodellimit = function(ply, cmd, args)
	if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_model', ' (#1)'}, NOTIFY_ERROR end
	if not args[2] or args[2]:Trim() == '' then return false, {'#saveload_command_message_2'}, NOTIFY_ERROR end

	local model = args[1]:lower():Trim()
	local group = args[2]
	if not DPP.ModelsLimits[model] then return false, {'#saveload_mlimit_not_exists'} end
	if not DPP.ModelsLimits[model][group] then return false, {'#saveload_glimit_not_exists'} end

	DPP.RemoveModelLimit(model, group)

	if Last < CurTime() then
		local f = {IsValid(ply) and ply or '#Console', Gray, '#saveload_removed', color_white, model, Gray, '#saveload_limits_models_removed', color_white, group}
		DPP.NotifyLog(f)
		Last = CurTime() + 0.5
	end
end

DPP.ManipulateCommands.addsboxlimit = function(ply, cmd, args)
	if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_slimit', ' (#1)'}, NOTIFY_ERROR end
	if not args[2] or args[2]:Trim() == '' then return false, {'#saveload_invalid_group', ' (#2)'}, NOTIFY_ERROR end
	if not args[3] or args[3]:Trim() == '' then return false, {'#saveload_invalid_limit', ' (#3)'}, NOTIFY_ERROR end

	local class = args[1]:lower():Trim()
	local group = args[2]
	local num = tonumber(args[3])

	if not num then return false, {'#saveload_invalid_limit', ' (#3)'}, NOTIFY_ERROR end

	DPP.AddSBoxLimit(class, group, num)

	local f = {IsValid(ply) and ply or '#Console', Gray, '#saveload_added_updated', color_white, class, Gray, '#saveload_slimits', color_white, group}
	DPP.NotifyLog(f)
	Last = CurTime() + 0.5
end

DPP.ManipulateCommands.addconstlimit = function(ply, cmd, args)
	if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_climit', ' (#1)'}, NOTIFY_ERROR end
	if not args[2] or args[2]:Trim() == '' then return false, {'#saveload_invalid_group', ' (#2)'}, NOTIFY_ERROR end
	if not args[3] or args[3]:Trim() == '' then return false, {'#saveload_invalid_limit', ' (#3)'}, NOTIFY_ERROR end

	local class = args[1]:lower():Trim()
	local group = args[2]
	local num = tonumber(args[3])

	if not num then return false, {'#saveload_invalid_limit', ' (#3)'}, NOTIFY_ERROR end

	DPP.AddConstLimit(class, group, num)

	local f = {IsValid(ply) and ply or '#Console', Gray, '#saveload_added_updated', color_white, class, Gray, '#saveload_climits', color_white, group}
	DPP.NotifyLog(f)
	Last = CurTime() + 0.5
end

DPP.ManipulateCommands.removesboxlimit = function(ply, cmd, args)
	if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_climit', ' (#1)'}, NOTIFY_ERROR end
	if not args[2] or args[2]:Trim() == '' then return false, {'#saveload_invalid_group', ' (#2)'}, NOTIFY_ERROR end

	local class = args[1]:lower():Trim()
	local group = args[2]
	if not DPP.SBoxLimits[class] then return false, {'#saveload_limit_not_exists'} end
	if not DPP.SBoxLimits[class][group] then return false, {'#saveload_limit_not_exists'} end

	DPP.RemoveSBoxLimit(class, group)

	local f = {IsValid(ply) and ply or '#Console', Gray, '#saveload_removed', color_white, class, Gray, '#saveload_from', '#saveload_slimits', color_white, group}
	DPP.NotifyLog(f)
	Last = CurTime() + 0.5
end

DPP.ManipulateCommands.removeconstlimit = function(ply, cmd, args)
	if not args[1] or args[1]:Trim() == '' then return false, {'#saveload_invalid_climit', ' (#1)'}, NOTIFY_ERROR end
	if not args[2] or args[2]:Trim() == '' then return false, {'#saveload_invalid_group', ' (#2)'}, NOTIFY_ERROR end

	local class = args[1]:lower():Trim()
	local group = args[2]
	if not DPP.ConstrainsLimits[class] then return false, {'#saveload_limit_not_exists'} end
	if not DPP.ConstrainsLimits[class][group] then return false, {'#saveload_limit_not_exists'} end

	DPP.RemoveConstLimit(class, group)

	local f = {IsValid(ply) and ply or '#Console', Gray, '#saveload_removed', color_white, class, Gray, '#saveload_from', '#saveload_climits', color_white, group}
	DPP.NotifyLog(f)
	Last = CurTime() + 0.5
end

function DPP.SaveCVars()
	DPP.Message('#saving_cvars')
	
	local t = {}

	for k, v in pairs(DPP.Settings) do
		local val = DPP.SVars[k]
		table.insert(t, {k, val:GetString()})
	end

	if DPP.IsMySQL() then
		DPP.Query(DMySQL3.Replace('dpp_cvars', {'CVAR', 'VALUE'}, unpack(t)))
	else
		local LINK = DPP.GetLink()
		LINK:Begin()

		for k, v in ipairs(t) do
			LINK:Add(DMySQL3.ReplaceEasy('dpp_cvars', {CVAR = v[1], VALUE = v[2]}))
		end

		LINK:Commit()
	end
end

function DPP.LoadCVars()
	DPP.Query('SELECT * FROM dpp_cvars', function(data)
		if not data then return end

		DPP.IGNORE_CVAR_SAVE = true

		for k, v in pairs(data) do
			RunConsoleCommand('dpp_' .. v.CVAR, v.VALUE)
		end

		DPP.IGNORE_CVAR_SAVE = false
	end)
end

function DPP.InitializeDefaultBlock()
	for k, v in pairs(DPP.BlockTypes) do
		for i, name in pairs(blockedEnts) do
			DPP['AddBlockedEntity' .. v](name)
		end
	end
end

function DPP.LoadBlockedLists()
	for k, v in pairs(DPP.BlockTypes) do
		DPP.BlockedEntities[k] = {}
		
		DPP.Query('SELECT * FROM dpp_blockedentities' .. k, function(data)
			if not data then return end
			for a, b in pairs(data) do
				DPP.BlockedEntities[k][b.ENTITY] = true
			end
		end)
	end
end

for k, v in pairs(DPP.BlockTypes) do
	DPP['Reset' .. v .. 'BlockedList'] = function(noCall)
		DPP.BlockedEntities[k] = {}
		DPP.Query('DELETE FROM dpp_blockedentities' .. k)
		timer.Create('DPP.BroadcastLists', 1, 1, DPP.BroadcastLists)
		timer.Create('DPP.InitializeDefaultBlock', 1, 1, DPP.InitializeDefaultBlock)
		DPP.DoEcho(ResetWarning, '#reset_blocklist_' .. k)
		
		net.Start('DPP.ResetBlockedList')
		net.WriteString(k)
		net.Broadcast()
	end
	
	DPP.ManipulateCommands['freset_blocked_' .. k] = function(ply, cmd, args)
		DPP.NotifyLog{ResetWarning, ply, ResetWarning, '#reset_command_blocked_' .. k}
		DPP['Reset' .. v .. 'BlockedList']()
	end
end

function DPP.ResetBlockedLists()
	for k, v in pairs(DPP.BlockTypes) do
		DPP['Reset' .. v .. 'BlockedList']()
	end
end

DPP.ManipulateCommands.freset_blocked = function(ply, cmd, args)
	DPP.NotifyLog{ResetWarning, ply, ResetWarning, '#reset_command_blocked'}
	DPP.ResetBlockedLists()
end

function DPP.LoadExcludedLists()
	for k, v in pairs(DPP.WhitelistTypes) do
		DPP.WhitelistedEntities[k] = {}
		
		DPP.Query('SELECT * FROM dpp_whitelistentities' .. k, function(data)
			if not data then return end
			for a, b in pairs(data) do
				DPP.WhitelistedEntities[k][b.ENTITY] = true
			end
		end)
	end
end

for k, v in pairs(DPP.WhitelistTypes) do
	DPP['Reset' .. v .. 'ExcludedList'] = function(noCall)
		DPP.WhitelistedEntities[k] = {}
		DPP.Query('DELETE FROM dpp_whitelistentities' .. k)
		timer.Create('DPP.BroadcastLists', 1, 1, DPP.BroadcastLists)
		DPP.DoEcho(ResetWarning, '#reset_excludelist_' .. k)
		
		net.Start('DPP.ResetExcludedList')
		net.WriteString(k)
		net.Broadcast()
	end
	
	DPP.ManipulateCommands['freset_exclude_' .. k] = function(ply, cmd, args)
		DPP.NotifyLog{ResetWarning, ply, ResetWarning, '#reset_command_exclude_' .. k}
		DPP['Reset' .. v .. 'ExcludedList']()
	end
end

function DPP.ResetExcludedLists()
	for k, v in pairs(DPP.WhitelistTypes) do
		DPP['Reset' .. v .. 'ExcludedList']()
	end
end

DPP.ManipulateCommands.freset_exclude = function(ply, cmd, args)
	DPP.NotifyLog{ResetWarning, ply, ResetWarning, '#reset_command_excluded'}
	DPP.ResetExcludedLists()
end

function DPP.LoadRestrictions()
	for k, v in pairs(DPP.RestrictTypes) do
		DPP.RestrictedTypes[k] = {}
		
		DPP.Query('SELECT * FROM dpp_restricted' .. k, function(data)
			if not data then return end

			for a, b in pairs(data) do
				DPP.RestrictedTypes[k][b.CLASS] = {
					groups = util.JSONToTable(b.GROUPS),
					iswhite = tobool(b.IS_WHITE)
				}
			end
		end)
		
		DPP.RestrictedTypes_SteamID[k] = {}
		
		DPP.Query('SELECT * FROM dpp_restricted' .. k .. '_ply', function(data)
			if not data then return end
			
			for i, row in ipairs(data) do
				DPP.RestrictedTypes_SteamID[k][row.STEAMID] = DPP.RestrictedTypes_SteamID[k][row.STEAMID] or {}
				table.insert(DPP.RestrictedTypes_SteamID[k][row.STEAMID], row.CLASS)
			end
		end)
	end
end

for k, v in pairs(DPP.RestrictTypes) do
	DPP['Reset' .. v .. 'Restrictions'] = function(noCall)
		DPP.RestrictedTypes[k] = {}
		DPP.RestrictedTypes_SteamID[k] = {}
		DPP.Query('DELETE FROM dpp_restricted' .. k)
		DPP.Query('DELETE FROM dpp_restricted' .. k .. '_ply')
		timer.Create('DPP.BroadcastLists', 1, 1, DPP.BroadcastLists)
		DPP.DoEcho(ResetWarning, '#reset_restrictlist_' .. k)
		
		net.Start('DPP.ResetRestrictions')
		net.WriteString(k)
		net.Broadcast()
	end
	
	DPP.ManipulateCommands['freset_restrictions_' .. k] = function(ply, cmd, args)
		DPP.NotifyLog{ResetWarning, ply, ResetWarning, '#reset_command_restrictions_' .. k}
		DPP['Reset' .. v .. 'Restrictions']()
	end
end

function DPP.ResetRestrictions()
	for k, v in pairs(DPP.RestrictTypes) do
		DPP['Reset' .. v .. 'Restrictions']()
	end
end

DPP.ManipulateCommands.freset_restrictions = function(ply, cmd, args)
	DPP.NotifyLog{ResetWarning, ply, ResetWarning, '#reset_command_restrictions'}
	DPP.ResetRestrictions()
end

function DPP.FactoryReset()
	DPP.Message(ResetWarning, '----------------------------------------')
	DPP.Message(ResetWarning, '#reset_1')
	DPP.Message(ResetWarning, '#reset_2')
	DPP.Message(ResetWarning, '#reset_3')
	DPP.Message(ResetWarning, '----------------------------------------')
	
	DPP.ResetRestrictions()
	DPP.ResetBlockedLists()
	DPP.ResetExcludedLists()
	DPP.ResetConVars()
	DPP.ResetCLimits()
	DPP.ResetSLimits()
	DPP.ResetMLimits()
	DPP.ResetLimits()
	DPP.ResetBlockedModels()
end

DPP.ManipulateCommands.freset_cvars = function(ply, cmd, args)
	DPP.NotifyLog{ResetWarning, ply, ResetWarning, '#reset_command_cvars'}
	DPP.ResetConVars()
end

DPP.ManipulateCommands.factoryreset = function(ply, cmd, args)
	DPP.NotifyLog{ResetWarning, ply, ResetWarning, '#reset_command_total'}
	DPP.FactoryReset()
end

local function WrapFunction(func, id)
	local function ProceedFunc(ply, ...)
		local status, notify, notifyLevel = func(ply, ...)

		if status then return end
		if not notify then return end

		if IsValid(ply) then
			DPP.Notify(ply, notify, notifyLevel)
		else
			DPP.Message(unpack(notify))
		end
	end

	return function(ply, ...)
		DPP.CheckAccess(ply, id, ProceedFunc, ply, ...)
	end
end

DPP.RawManipulateCommands = {}

for k, v in pairs(DPP.ManipulateCommands) do
	DPP.RawManipulateCommands[k] = v
	DPP.ManipulateCommands[k] = WrapFunction(v, k)
	concommand.Add('dpp_' .. k, DPP.ManipulateCommands[k])
end

function DPP.ContinueDatabaseStartup()
	hook.Run('DPP_SQLTablesInitialized')

	DPP.Message('Loading data from database')
	local Time = SysTime()

	DPP.LoadBlockedModels()
	DPP.LoadLimits()
	DPP.LoadMLimits()
	DPP.LoadSLimits()
	DPP.LoadCLimits()
	DPP.LoadCVars()
	
	DPP.LoadBlockedLists()
	DPP.LoadExcludedLists()
	DPP.LoadRestrictions()

	DPP.FindInfoEntities()
	DPP.InitializeDefaultBlock()

	if DPP.IsMySQL() then
		DPP.Message('Finished (queuing) SQL queries in ' .. math.floor((SysTime() - Time) * 100000) / 100 .. 'ms')
	else
		DPP.Message('Finished SQL queries in ' .. math.floor((SysTime() - Time) * 100000) / 100 .. 'ms')
	end

	DPP.BroadcastLists()

	hook.Run('DPP_SQLQueriesInitialized')
end

DPP.StartDatabase = DPP.CreateTables

timer.Simple(0, DPP.CreateTables)
