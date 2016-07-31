
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

include('sv_mysql.lua')

function DPP.CreateTables()
	DPP.Query([[
		CREATE TABLE IF NOT EXISTS dpp_blockedmodels (
			MODEL VARCHAR(64) NOT NULL,
			PRIMARY KEY (MODEL)
		)
	]])
	
	DPP.Query([[
		CREATE TABLE IF NOT EXISTS dpp_cvars (
			CVAR VARCHAR(64) NOT NULL,
			`VALUE` VARCHAR(64) NOT NULL,
			PRIMARY KEY (CVAR)
		)
	]])
	
	DPP.Query([[
		CREATE TABLE IF NOT EXISTS dpp_entitylimits (
			CLASS VARCHAR(64) NOT NULL,
			UGROUP VARCHAR(64) NOT NULL,
			ULIMIT INT NOT NULL,
			PRIMARY KEY (CLASS, UGROUP)
		)
	]])
	
	DPP.Query([[
		CREATE TABLE IF NOT EXISTS dpp_sboxlimits (
			CLASS VARCHAR(64) NOT NULL,
			UGROUP VARCHAR(64) NOT NULL,
			ULIMIT INT NOT NULL,
			PRIMARY KEY (CLASS, UGROUP)
		)
	]])
	
	DPP.Query([[
		CREATE TABLE IF NOT EXISTS dpp_constlimits (
			CLASS VARCHAR(64) NOT NULL,
			UGROUP VARCHAR(64) NOT NULL,
			ULIMIT INT NOT NULL,
			PRIMARY KEY (CLASS, UGROUP)
		)
	]])
	
	for k, v in pairs(DPP.BlockTypes) do
		DPP.Query([[
			CREATE TABLE IF NOT EXISTS dpp_blockedentities]] .. k .. [[ (
				ENTITY VARCHAR(64) NOT NULL,
				PRIMARY KEY (ENTITY)
			)
		]])
	end
	
	for k, v in pairs(DPP.WhitelistTypes) do
		DPP.Query([[
			CREATE TABLE IF NOT EXISTS dpp_whitelistentities]] .. k .. [[ (
				ENTITY VARCHAR(64) NOT NULL,
				PRIMARY KEY (ENTITY)
			)
		]])
	end
	
	for k, v in pairs(DPP.RestrictTypes) do
		DPP.Query([[
			CREATE TABLE IF NOT EXISTS dpp_restricted]] .. k .. [[ (
				CLASS VARCHAR(64) NOT NULL,
				GROUPS VARCHAR(255) NOT NULL,
				IS_WHITE BOOL NOT NULL,
				PRIMARY KEY (CLASS)
			)
		]])
	end
end

--FPP is blocking that entities because they are logical
--And should be NEVER touched by player entity in any way
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
		if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		args[1] = args[1]:lower()
		DPP.AddBlockedModel(args[1])
		local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' added ' .. args[1] .. ' to model blacklist/whitelist'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
	end,

	removeblockedmodel = function(ply, cmd, args)
		if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		args[1] = args[1]:lower()
		DPP.RemoveBlockedModel(args[1])
		local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' removed ' .. args[1] .. ' from model blacklist/whitelist'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
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

for k, v in pairs(DPP.BlockTypes) do
	DPP['AddBlockedEntity' .. v] = function(ent)
		ent = string.lower(ent)
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
		ent = string.lower(ent)
		if blockedEnts[ent] then return end
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
		if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		if blockedEnts[args[1]] then DPP.Notify(ply, 'You can not add that entity to blacklist') return end
		DPP['AddBlockedEntity' .. v](args[1])
		local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' added ' .. args[1] .. ' to ' .. v .. ' blacklist/whitelist'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
	end
	
	DPP.ManipulateCommands['removeblockedentity' .. k] = function(ply, cmd, args)
		if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		if blockedEnts[args[1]] then DPP.Notify(ply, 'You can not remove that entity from blacklist') return end
		DPP['RemoveBlockedEntity' .. v](args[1])
		local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' removed ' .. args[1] .. ' from ' .. v .. ' blacklist/whitelist'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
	end
end

for k, v in pairs(DPP.WhitelistTypes) do
	DPP['AddWhitelistedEntity' .. v] = function(ent)
		ent = string.lower(ent)
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
		ent = string.lower(ent)
		if blockedEnts[ent] then return end
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
		if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		DPP['AddWhitelistedEntity' .. v](args[1])
		local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' added ' .. args[1] .. ' to ' .. v .. ' excluded entities'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
	end
	
	DPP.ManipulateCommands['removewhitelistedentity' .. k] = function(ply, cmd, args)
		if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		DPP['RemoveWhitelistedEntity' .. v](args[1])
		local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' removed ' .. args[1] .. ' from ' .. v .. ' excluded entities'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
	end
end

for k, v in pairs(DPP.RestrictTypes) do
	DPP['Restrict' .. v] = function(class, groups, isWhite)
		class = string.lower(class)
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
	
	DPP['UnRestrict' .. v] = function(class, groups)
		class = string.lower(class)
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
		if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		if not args[2] then DPP.Notify(ply, 'Invalid argument') return end --No groups allowed
		if not args[3] or args[3] == '' or args[3] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		
		local class = args[1]
		local groups = string.Explode(',', args[2])
		local isWhite = tobool(args[3])
		local old = DPP.RestrictedTypes[k][class]
		
		DPP['Restrict' .. v](class, groups, isWhite)
		
		if not old then
			local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' added ' .. class .. ' to restrticted ' .. k .. ' blacklist/whitelist'}
			DPP.Notify(player.GetAll(), f)
			DPP.Message(f)
		else
			local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' updated restricts for ' .. class}
			DPP.DoEcho(f)
			if IsValid(ply) then
				DPP.Notify(ply, '(SILENT) You updated restricts for ' .. class)
			end
		end
	end
	
	DPP.ManipulateCommands['unrestrict' .. k] = function(ply, cmd, args)
		if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		
		local class = args[1]
		
		DPP['UnRestrict' .. v](class)
		
		local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' removed ' .. args[1] .. ' from restrticted ' .. k .. ' blacklist/whitelist'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
	end
end

function DPP.AddEntityLimit(class, group, val)
	if not val then return end
	class = string.lower(class)
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
	class = string.lower(class)
	
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

function DPP.AddSBoxLimit(class, group, val)
	if not val then return end
	
	class = string.lower(class)
	
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
	
	class = string.lower(class)
	
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
	class = string.lower(class)
	
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
	class = string.lower(class)
	
	if group then
		DPP.ConstrainsLimits[class] = DPP.ConstrainsLimits[class] or {}
		DPP.ConstrainsLimits[class][group] = nil
		
		DPP.Query(string.format('DELETE FROM dpp_sboxlimits WHERE CLASS = %q AND UGROUP = %q', class, group))
	else
		DPP.ConstrainsLimits[class] = nil
		DPP.Query(string.format('DELETE FROM dpp_sboxlimits WHERE CLASS = %q', class))
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

local Last = 0

DPP.ManipulateCommands.addentitylimit = function(ply, cmd, args)
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[2] or args[2] == '' or args[2] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[3] or args[3] == '' or args[3] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	local class = args[1]
	local group = args[2]
	local num = tonumber(args[3])
	
	if not num then DPP.Notify(ply, 'Invalid argument') return end
	
	DPP.AddEntityLimit(class, group, num)
	
	if Last < CurTime() then
		local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' added/updated ' .. class .. ' limits'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
		Last = CurTime() + 0.5
	end
end

DPP.ManipulateCommands.removeentitylimit = function(ply, cmd, args)
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[2] or args[2] == '' or args[2] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	local class = args[1]
	local group = args[2]
	if not DPP.EntsLimits[class] then return end
	if not DPP.EntsLimits[class][group] then return end
	
	DPP.RemoveEntityLimit(class, group)
	
	if Last < CurTime() then
		local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' removed ' .. class .. ' from limits list'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
		Last = CurTime() + 0.5
	end
end

DPP.ManipulateCommands.addsboxlimit = function(ply, cmd, args)
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[2] or args[2] == '' or args[2] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[3] or args[3] == '' or args[3] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	local class = args[1]
	local group = args[2]
	local num = tonumber(args[3])
	
	if not num then DPP.Notify(ply, 'Invalid argument') return end
	
	DPP.AddSBoxLimit(class, group, num)
	
	local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' added/updated ' .. class .. ' sbox limits list for ' .. group}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
	Last = CurTime() + 0.5
end

DPP.ManipulateCommands.addconstlimit = function(ply, cmd, args)
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[2] or args[2] == '' or args[2] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[3] or args[3] == '' or args[3] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	local class = args[1]
	local group = args[2]
	local num = tonumber(args[3])
	
	if not num then DPP.Notify(ply, 'Invalid argument') return end
	
	DPP.AddConstLimit(class, group, num)
	
	local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' added/updated ' .. class .. ' constaints limit list for ' .. group}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
	Last = CurTime() + 0.5
end

DPP.ManipulateCommands.removesboxlimit = function(ply, cmd, args)
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[2] or args[2] == '' or args[2] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	local class = args[1]
	local group = args[2]
	if not DPP.SBoxLimits[class] then return end
	if not DPP.SBoxLimits[class][group] then return end
	
	DPP.RemoveSBoxLimit(class, group)
	
	local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' removed ' .. class .. ' from sbox limits list for ' .. group}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
	Last = CurTime() + 0.5
end

DPP.ManipulateCommands.removeconstlimit = function(ply, cmd, args)
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[2] or args[2] == '' or args[2] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	local class = args[1]
	local group = args[2]
	if not DPP.ConstrainsLimits[class] then return end
	if not DPP.ConstrainsLimits[class][group] then return end
	
	DPP.RemoveConstLimit(class, group)
	
	local f = {IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' removed ' .. class .. ' from constaints limit list for ' .. group}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
	Last = CurTime() + 0.5
end

function DPP.SaveCVars()
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

local function WrapFunction(func, id)
	return function(ply, ...)
		DPP.CheckAccess(ply, id, func, ply, ...)
	end
end

for k, v in pairs(DPP.ManipulateCommands) do
	DPP.ManipulateCommands[k] = WrapFunction(v, k)
	concommand.Add('dpp_' .. k, DPP.ManipulateCommands[k])
end

local function Load()
	DPP.CreateTables()
	DPP.LoadBlockedModels()
	DPP.LoadLimits()
	DPP.LoadSLimits()
	DPP.LoadCLimits()
	DPP.LoadCVars()
	
	for k, v in pairs(DPP.BlockTypes) do
		DPP.BlockedEntities[k] = {}
		local data = DPP.Query('SELECT * FROM dpp_blockedentities' .. k, function(data)
			if not data then return end
			for a, b in pairs(data) do
				DPP.BlockedEntities[k][b.ENTITY] = true
			end
		end)
	end
	
	for k, v in pairs(DPP.WhitelistTypes) do
		DPP.WhitelistedEntities[k] = {}
		local data = DPP.Query('SELECT * FROM dpp_whitelistentities' .. k, function(data)
			if not data then return end
			for a, b in pairs(data) do
				DPP.WhitelistedEntities[k][b.ENTITY] = true
			end
		end)
	end
	
	for k, v in pairs(DPP.RestrictTypes) do
		DPP.RestrictedTypes[k] = {}
		local data = DPP.Query('SELECT * FROM dpp_restricted' .. k, function(data)
			if not data then return end
			
			for a, b in pairs(data) do
				DPP.RestrictedTypes[k][b.CLASS] = {
					groups = util.JSONToTable(b.GROUPS),
					iswhite = tobool(b.IS_WHITE)
				}
			end
		end)
	end
	
	DPP.FindInfoEntities()
	DPP.InitializeDefaultBlock()
	
	DPP.BroadcastLists()
end

timer.Simple(0, Load)
