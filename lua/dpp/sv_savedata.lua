
function DPP.CreateTables()
	sql.Query([[
		CREATE TABLE IF NOT EXISTS dpp_blockedmodels (
			MODEL VARCHAR(64) NOT NULL,
			PRIMARY KEY (MODEL)
		)
	]])
	
	sql.Query([[
		CREATE TABLE IF NOT EXISTS dpp_cvars (
			CVAR VARCHAR(64) NOT NULL,
			VALUE VARCHAR(64) NOT NULL,
			PRIMARY KEY (CVAR)
		)
	]])
	
	sql.Query([[
		CREATE TABLE IF NOT EXISTS dpp_entitylimits (
			CLASS VARCHAR(64) NOT NULL,
			UGROUP VARCHAR(64) NOT NULL,
			ULIMIT INT NOT NULL,
			PRIMARY KEY (CLASS, UGROUP)
		)
	]])
	
	sql.Query([[
		CREATE TABLE IF NOT EXISTS dpp_sboxlimits (
			CLASS VARCHAR(64) NOT NULL,
			UGROUP VARCHAR(64) NOT NULL,
			ULIMIT INT NOT NULL,
			PRIMARY KEY (CLASS, UGROUP)
		)
	]])
	
	for k, v in pairs(DPP.BlockTypes) do
		sql.Query([[
			CREATE TABLE IF NOT EXISTS dpp_blockedentites]] .. k .. [[ (
				ENTITY VARCHAR(64) NOT NULL,
				PRIMARY KEY (ENTITY)
			)
		]])
	end
	
	for k, v in pairs(DPP.RestrictTypes) do
		sql.Query([[
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
	
	--Some DPP additions. This list is trying to predict entites like above
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

function DPP.FindInfoEntites() --Add custom entities
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
	sql.Query('REPLACE INTO dpp_blockedmodels (MODEL) VALUES ("' .. model .. '")')
	
	net.Start('DPP.ModelsInsert')
	net.WriteString(model)
	net.WriteBool(true)
	net.Broadcast()
end

function DPP.RemoveBlockedModel(model)
	DPP.BlockedModels[model] = nil
	sql.Query('DELETE FROM dpp_blockedmodels WHERE MODEL = "' .. model .. '"')
	
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
	sql.Begin()
	sql.Query('REMOVE FROM dpp_blockedmodels')
	for k, v in pairs(DPP.BlockedModels) do
		sql.Query('INSERT INTO dpp_blockedmodels (MODEL) VALUES ("' .. k .. '")')
	end
	sql.Commit()
end

function DPP.LoadBlockedModels()
	DPP.BlockedModels = {}
	local data = sql.Query('SELECT * FROM dpp_blockedmodels')
	
	if not data then return end
	
	for k, v in pairs(data) do
		DPP.BlockedModels[v.MODEL] = true
	end
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
		
		DPP.BlockedEntites[k][ent] = true
		sql.Query('REPLACE INTO dpp_blockedentites' .. k .. ' (ENTITY) VALUES ("' .. ent .. '")')
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
		
		DPP.BlockedEntites[k][ent] = nil
		sql.Query('DELETE FROM dpp_blockedentites' .. k .. ' WHERE ENTITY = "' .. ent .. '"')
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
		sql.Query(string.format('REPLACE INTO dpp_restricted' .. k .. ' (CLASS, GROUPS, IS_WHITE) VALUES (%q, \'%s\', %q)', class, util.TableToJSON(groups), isWhite and '1' or '0'))
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
		sql.Query('DELETE FROM dpp_restricted' .. k .. ' WHERE CLASS = "' .. class .. '"')
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
	
	sql.Query(string.format('REPLACE INTO dpp_entitylimits (CLASS, UGROUP, ULIMIT) VALUES (%q, %q, %q)', class, group, val))
	
	timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)
end

function DPP.RemoveEntityLimit(class, group)
	class = string.lower(class)
	
	if group then
		DPP.EntsLimits[class] = DPP.EntsLimits[class] or {}
		DPP.EntsLimits[class][group] = nil
		
		sql.Query(string.format('DELETE FROM dpp_entitylimits WHERE CLASS = %q AND UGROUP = %q', class, group))
	else
		DPP.EntsLimits[class] = nil
		sql.Query(string.format('DELETE FROM dpp_entitylimits WHERE CLASS = %q', class))
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
	
	sql.Query(string.format('REPLACE INTO dpp_sboxlimits (CLASS, UGROUP, ULIMIT) VALUES (%q, %q, %q)', class, group, val))
	
	timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)
end

function DPP.RemoveSBoxLimit(class, group)
	class = string.lower(class)
	
	if group then
		DPP.SBoxLimits[class] = DPP.SBoxLimits[class] or {}
		DPP.SBoxLimits[class][group] = nil
		
		sql.Query(string.format('DELETE FROM dpp_sboxlimits WHERE CLASS = %q AND UGROUP = %q', class, group))
	else
		DPP.SBoxLimits[class] = nil
		sql.Query(string.format('DELETE FROM dpp_sboxlimits WHERE CLASS = %q', class))
	end
	
	net.Start('DPP.SListsInsert')
	net.WriteString(class)
	net.WriteTable(DPP.SBoxLimits[class])
	net.Broadcast()
	
	timer.Create('DPP.BroadcastLists', 10, 1, DPP.BroadcastLists)
end

function DPP.LoadLimits()
	DPP.EntsLimits = {}
	local data = sql.Query('SELECT * FROM dpp_entitylimits')
	if not data then return end
	
	for index, row in pairs(data) do
		DPP.EntsLimits[row.CLASS] = DPP.EntsLimits[row.CLASS] or {}
		DPP.EntsLimits[row.CLASS][row.UGROUP] = row.ULIMIT
	end
end

function DPP.LoadSLimits()
	DPP.SBoxLimits = {}
	local data = sql.Query('SELECT * FROM dpp_sboxlimits')
	if not data then return end
	
	for index, row in pairs(data) do
		DPP.SBoxLimits[row.CLASS] = DPP.SBoxLimits[row.CLASS] or {}
		DPP.SBoxLimits[row.CLASS][row.UGROUP] = row.ULIMIT
	end
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

function DPP.SaveCVars()
	sql.Begin()
	for k, v in pairs(DPP.Settings) do
		local val = DPP.SVars[k]
		sql.Query(string.format('REPLACE INTO dpp_cvars (CVAR, VALUE) VALUES (%q, %q)', k, val:GetString()))
	end
	sql.Commit()
end

function DPP.LoadCVars()
	local data = sql.Query('SELECT * FROM dpp_cvars')
	if not data then return end
	
	for k, v in pairs(data) do
		RunConsoleCommand('dpp_' .. v.CVAR, v.VALUE)
	end
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
	DPP.LoadCVars()
	
	for k, v in pairs(DPP.BlockTypes) do
		DPP.BlockedEntites[k] = {}
		local data = sql.Query('SELECT * FROM dpp_blockedentites' .. k)
		if not data then continue end
		for a, b in pairs(data) do
			DPP.BlockedEntites[k][b.ENTITY] = true
		end
	end
	
	for k, v in pairs(DPP.RestrictTypes) do
		DPP.RestrictedTypes[k] = {}
		local data = sql.Query('SELECT * FROM dpp_restricted' .. k)
		if not data then continue end
		
		for a, b in pairs(data) do
			DPP.RestrictedTypes[k][b.CLASS] = {
				groups = util.JSONToTable(b.GROUPS),
				iswhite = tobool(b.IS_WHITE)
			}
		end
	end
	
	DPP.BroadcastLists()
	
	DPP.FindInfoEntites()
	DPP.InitializeDefaultBlock()
end

timer.Simple(0, Load)
