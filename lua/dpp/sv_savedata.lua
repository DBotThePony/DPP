
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
			VALUE VARCHAR(64) NOT NULL,
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
	["ai_network"] = true,
	["ambient_generic"] = true,
	["beam"] = true,
	["bodyque"] = true,
	["env_soundscape"] = true,
	["env_sprite"] = true,
	["env_sun"] = true,
	["env_tonemap_controller"] = true,
	["func_useableladder"] = true,
	["info_ladder_dismount"] = true,
	["info_player_start"] = true,
	["info_player_terrorist"] = true,
	["light_environment"] = true,
	["light_spot"] = true,
	["physgun_beam"] = true,
	["player_manager"] = true,
	["point_spotlight"] = true,
	["predicted_viewmodel"] = true,
	["scene_manager"] = true,
	["shadow_control"] = true,
	["soundent"] = true,
	["spotlight_end"] = true,
	["water_lod_control"] = true,
	["gmod_gamerules"] = true,
	["bodyqueue"] = true,
	["phys_bone_follower"] = true,
	
	--Some DPP additions. This list is trying to predict entities like above
	["info_spawn"] = true,
	["info_spawnpoint"] = true,
	["info_light"] = true,
	["trigger_changelevel"] = true,
	["trigger_push"] = true,
	["trigger_secret"] = true,
	["trigger_hurt"] = true,
	["point_hurt"] = true,
	["trigger_impact"] = true,
	["trigger_gravity"] = true,
	["gmod_anchor"] = true,
}

function DPP.FindInfoEntities() --Add custom entities
	local list = scripted_ents.GetList()
	for k, v in pairs(list) do
		if string.find(k, 'info_') then
			if v.type ~= 'point' then continue end
			blockedEnts[k] = true
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

concommand.Add('dpp_addblockedmodel', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	DPP.AddBlockedModel(args[1])
	local f = (IsValid(ply) and ply:Nick() or 'Console') .. ' added ' .. args[1] .. ' to model blacklist/whitelist'
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
end)

concommand.Add('dpp_removeblockedmodel', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	DPP.RemoveBlockedModel(args[1])
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' removed ' .. args[1] .. ' to model blacklist/whitelist'}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
end)

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
	
	concommand.Add('dpp_addblockedentity' .. k, function(ply, cmd, args)
		if IsValid(ply) and not ply:IsSuperAdmin() then return end
		if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		if blockedEnts[args[1]] then DPP.Notify(ply, 'You can not add that entity to blacklist') return end
		DPP['AddBlockedEntity' .. v](args[1])
		local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' added ' .. args[1] .. ' to ' .. v .. ' blacklist/whitelist'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
	end)
	
	concommand.Add('dpp_removeblockedentity' .. k, function(ply, cmd, args)
		if IsValid(ply) and not ply:IsSuperAdmin() then return end
		if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		if blockedEnts[args[1]] then DPP.Notify(ply, 'You can not remove that entity from blacklist') return end
		DPP['RemoveBlockedEntity' .. v](args[1])
		local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' removed ' .. args[1] .. ' from ' .. v .. ' blacklist/whitelist'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
	end)
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
	
	DPP['UnRestrict' .. v] = function(class, groups, isWhite)
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
	
	concommand.Add('dpp_restrict' .. k, function(ply, cmd, args)
		if IsValid(ply) and not ply:IsSuperAdmin() then return end
		if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		if not args[2] then DPP.Notify(ply, 'Invalid argument') return end --No groups allowed
		if not args[3] or args[3] == '' or args[3] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		
		local class = args[1]
		local groups = string.Explode(',', args[2])
		local isWhite = tobool(args[3])
		local old = DPP.RestrictedTypes[k][class]
		
		DPP['Restrict' .. v](class, groups, isWhite)
		
		if not old then
			local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' added ' .. class .. ' to restrticted ' .. k .. ' blacklist/whitelist'}
			DPP.Notify(player.GetAll(), f)
			DPP.Message(f)
		else
			local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' updated restricts for ' .. class}
			DPP.DoEcho(f)
			if IsValid(ply) then
				DPP.Notify(ply, '(SILENT) You updated restricts for ' .. class)
			end
		end
	end)
	
	concommand.Add('dpp_unrestrict' .. k, function(ply, cmd, args)
		if IsValid(ply) and not ply:IsSuperAdmin() then return end
		if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		
		local class = args[1]
		
		DPP['UnRestrict' .. v](class)
		
		local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' removed ' .. args[1] .. ' from restrticted ' .. k .. ' blacklist/whitelist'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
	end)
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

concommand.Add('dpp_addentitylimit', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[2] or args[2] == '' or args[2] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[3] or args[3] == '' or args[3] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	local class = args[1]
	local group = args[2]
	local num = tonumber(args[3])
	
	if not num then DPP.Notify(ply, 'Invalid argument') return end
	
	DPP.AddEntityLimit(class, group, num)
	
	if Last < CurTime() then
		local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' added/updated ' .. class .. ' limits'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
		Last = CurTime() + 0.5
	end
end)

concommand.Add('dpp_removeentitylimit', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[2] or args[2] == '' or args[2] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	local class = args[1]
	local group = args[2]
	if not DPP.EntsLimits[class] then return end
	if not DPP.EntsLimits[class][group] then return end
	
	DPP.RemoveEntityLimit(class, group)
	
	if Last < CurTime() then
		local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' removed ' .. class .. ' from limits list'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
		Last = CurTime() + 0.5
	end
end)

concommand.Add('dpp_addsboxlimit', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[2] or args[2] == '' or args[2] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[3] or args[3] == '' or args[3] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	local class = args[1]
	local group = args[2]
	local num = tonumber(args[3])
	
	if not num then DPP.Notify(ply, 'Invalid argument') return end
	
	DPP.AddSBoxLimit(class, group, num)
	
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' added/updated ' .. class .. ' sbox limits list for ' .. group}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
	Last = CurTime() + 0.5
end)

concommand.Add('dpp_addconstlimit', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[2] or args[2] == '' or args[2] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[3] or args[3] == '' or args[3] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	local class = args[1]
	local group = args[2]
	local num = tonumber(args[3])
	
	if not num then DPP.Notify(ply, 'Invalid argument') return end
	
	DPP.AddConstLimit(class, group, num)
	
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' added/updated ' .. class .. ' constaints limit list for ' .. group}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
	Last = CurTime() + 0.5
end)

concommand.Add('dpp_removesboxlimit', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[2] or args[2] == '' or args[2] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	local class = args[1]
	local group = args[2]
	if not DPP.SBoxLimits[class] then return end
	if not DPP.SBoxLimits[class][group] then return end
	
	DPP.RemoveSBoxLimit(class, group)
	
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' removed ' .. class .. ' from sbox limits list for ' .. group}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
	Last = CurTime() + 0.5
end)

concommand.Add('dpp_removeconstlimit', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	if not args[2] or args[2] == '' or args[2] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	local class = args[1]
	local group = args[2]
	if not DPP.ConstrainsLimits[class] then return end
	if not DPP.ConstrainsLimits[class][group] then return end
	
	DPP.RemoveConstLimit(class, group)
	
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' removed ' .. class .. ' from constaints limit list for ' .. group}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
	Last = CurTime() + 0.5
end)

function DPP.SaveCVars()
	local t = {}
	
	for k, v in pairs(DPP.Settings) do
		local val = DPP.SVars[k]
		table.insert(t, string.format('REPLACE INTO dpp_cvars (CVAR, VALUE) VALUES (%q, %q)', k, val:GetString()))
	end
	
	DPP.QueryStack(t)
end

function DPP.LoadCVars()
	DPP.Query('SELECT * FROM dpp_cvars', function(data)
		if not data then return end
		
		for k, v in pairs(data) do
			RunConsoleCommand('dpp_' .. v.CVAR, v.VALUE)
		end
	end)
end

function DPP.InitializeDefaultBlock()
	for k, v in pairs(DPP.BlockTypes) do
		for a in pairs(blockedEnts) do
			DPP['AddBlockedEntity' .. v](a)
		end
	end
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
			if data then
				for a, b in pairs(data) do
					DPP.BlockedEntities[k][b.ENTITY] = true
				end
			end
		end)
		
		DPP.Query('SELECT * FROM dpp_blockedentites' .. k, function(data)
			if data then
				for a, b in pairs(data) do
					DPP['AddBlockedEntity' .. v](b.ENTITY)
				end
			end
			
			DPP.Query('DROP TABLE dpp_blockedentites')
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
	
	DPP.BroadcastLists()
	
	DPP.FindInfoEntities()
	DPP.InitializeDefaultBlock()
end

timer.Simple(0, Load)
