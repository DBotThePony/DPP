
local GhostColor = Color(255, 255, 255, 224)

function DPP.SetGhosted(ent, status)
	if status and DPP.GetGhosted(ent) then return end
	
	if status then
		ent:SetNWBool('DPP.IsGhosted', true)
		
		ent.__DPPColor = ent:GetColor()
		ent.DPP_oldCollision = ent:GetCollisionGroup()
		ent.DPP_OldRenderMode = ent:GetRenderMode()
		ent.DPP_OldMoveType = ent:GetMoveType()
		ent:SetRenderMode(RENDERMODE_TRANSALPHA)
		ent:SetColor(GhostColor)
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		ent:SetMoveType(MOVETYPE_NONE)
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then phys:EnableMotion(false) phys:Sleep() end
	else
		ent:SetNWBool('DPP.IsGhosted', false)
		
		if ent.DPP_OldRenderMode then ent:SetRenderMode(ent.DPP_OldRenderMode) end
		if ent.__DPPColor then ent:SetColor(ent.__DPPColor) end
		if ent.DPP_oldCollision then ent:SetCollisionGroup(ent.DPP_oldCollision) end
		if ent.DPP_OldMoveType then ent:SetMoveType(ent.DPP_OldMoveType) end
		
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then phys:EnableMotion(true) phys:Wake() end
	end
end

function DPP.SendConstrainedWith(ent)
	if not IsValid(ent) then return end
	timer.Create('DPP.SendConstrainedWith.' .. ent:EntIndex(), 0, 1, function()
		if not IsValid(ent) then return end
		DPP.UpdateConstrainedWith(ent)
		
		net.Start('DPP.SendConstrainedWith')
		net.WriteEntity(ent)
		net.WriteTable(ent.DPP_ConstrainedWith)
		net.Broadcast()
	end)
end

function DPP.SetConstrainedBetween(ent1, ent2, status)
	if not IsValid(ent1) or not IsValid(ent2) then return end
	
	ent1.DPP_ConstrainedWith = ent1.DPP_ConstrainedWith or {}
	ent2.DPP_ConstrainedWith = ent2.DPP_ConstrainedWith or {}
	
	if status then
		ent1.DPP_ConstrainedWith[ent2] = true
		ent2.DPP_ConstrainedWith[ent1] = true
	else
		ent1.DPP_ConstrainedWith[ent2] = nil
		ent2.DPP_ConstrainedWith[ent1] = nil
	end
end

function DPP.RecalculatePlayerList()
	DPP.RefreshPropList()
	local r = {}
	
	for ent, v in pairs(DPP.PropListing) do
		local Name, UID, SteamID = DPP.GetOwnerDetails(ent)
		r[UID] = r[UID] or {Name = Name, SteamID = SteamID, UID = UID}
	end
	
	local r2 = {}
	
	for k, v in pairs(r) do
		table.insert(r2, v)
	end
	
	DPP.PlayerList = r2
	return r2
end

function DPP.SendPlayerList()
	net.Start('DPP.PlayerList')
	net.WriteTable(DPP.PlayerList)
	net.Broadcast()
end

function DPP.CheckSizes(ent, ply)
	if not DPP.GetConVar('enable') then return end
	if not DPP.GetConVar('check_sizes') then return end
	if not IsValid(ent) then return end
	if ent:IsConstraint() then return end
	
	local solid = ent:GetSolid()
	local cgroup = ent:GetCollisionGroup()
	
	if solid == SOLID_NONE then return end
	if cgroup == COLLISION_GROUP_WORLD then return end
	
	local phys = ent:GetPhysicsObject()
	if not IsValid(phys) then return end
	local size = phys:GetVolume()
	if not size then return end
	
	if size / 1000 < DPP.GetConVar('max_size') then return end
	
	timer.Simple(0, function() --Give entity time to initialize
		DPP.SetGhosted(ent, true)
		if IsValid(ply) then
			DPP.Notify(ply, 'Prop is ghosted because it is too big.')
		end
	end)
end

function DPP.CheckStuck(ply, ent1, ent2)
	if not DPP.GetConVar('enable') then return end
	if not DPP.GetConVar('check_stuck') then return end
	if ply:InVehicle() then return end
	if ent1 == ent2 then return end
	
	local parent1, parent2 = ent1:GetParent(), ent2:GetParent()
	
	if parent1 == ent2 or parent2 == ent1 then return end
	
	local pos1, pos2 = ent1:GetPos(), ent2:GetPos()
	
	local min1, max1 = ent1:WorldSpaceAABB()
	local min2, max2 = ent2:WorldSpaceAABB()
	
	local cond = max1:Distance(max2) < 10 and min1:Distance(min2) < 10 or
		pos1:Distance(pos2) < 10
	
	if cond then 
		DPP.SetGhosted(ent1, true)
		DPP.SetGhosted(ent2, true)
		if IsValid(ply) then
			DPP.Notify(ply, 'It seems that prop is stucked in each other.')
		end
		
		return true
	end
end

function DPP.GetPlayerEntities(ply)
	ply.DPP_Ents = ply.DPP_Ents or {}
	
	for k, v in pairs(ply.DPP_Ents) do
		if not IsValid(k) then
			ply.DPP_Ents[k] = nil
			continue
		end
		
		if DPP.GetOwner(k) ~= ply then
			ply.DPP_Ents[k] = nil
			continue
		end
	end
	
	local reply = {}
	
	for k, v in pairs(ply.DPP_Ents) do
		table.insert(reply, k)
	end
	
	return reply
end

function DPP.FindEntitesByClass(ply, class)
	local Ents = DPP.GetPlayerEntities(ply)
	local reply = {}
	
	for k, v in pairs(Ents) do
		if v:GetClass() == class then
			table.insert(reply, v)
		end
	end
	
	return reply
end

function DPP.SetUpForGrabs(ent, status)
	ent:SetNWBool('DPP.IsUpForGraps', status)
end

function DPP.CheckUpForGrabs(ent, ply)
	if not DPP.IsUpForGrabs(ent) then return end
	DPP.SetOwner(ent, ply) 
	DPP.SetUpForGrabs(ent, false) 
	DPP.Notify(ply, 'You now own this prop')
	undo.Create('Owned_Prop')
	undo.AddEntity(ent)
	undo.SetPlayer(ply)
	undo.Finish()
end

function DPP.ClearPlayerEntites(ply)
	local Ents = DPP.GetPlayerEntities(ply)
	
	for k, v in pairs(Ents) do
		SafeRemoveEntity(v)
	end
	
	DPP.RecalculatePlayerList()
	DPP.SendPlayerList()
end

function DPP.FreezePlayerEntites(ply)
	local Ents = DPP.GetPlayerEntities(ply)
	
	for k, v in pairs(Ents) do
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
end

function DPP.UnFreezePlayerEntites(ply)
	local Ents = DPP.GetPlayerEntities(ply)
	
	for k, v in pairs(Ents) do
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(true)
		end
	end
end

function DPP.FindPlayerProps(ply)
	local uid = tonumber(ply:UniqueID())
	
	DPP.RefreshPropList()
	
	for k, v in pairs(DPP.PropListing) do
		if IsValid(DPP.GetOwner(k)) then continue end
		local name, uid2 = DPP.GetOwnerDetails(k)
		if uid2 == uid then
			DPP.SetOwner(k, ply)
		end
	end
end

function DPP.GetUnownedProps()
	DPP.RefreshPropList()
	
	local reply = {}
	for k, v in pairs(DPP.PropListing) do
		if not IsValid(DPP.GetOwner(k)) then
			table.insert(reply, k)
		end
	end
	
	return reply
end

function DPP.GetAllProps()
	DPP.RefreshPropList()
	
	local reply = {}
	for k, v in pairs(DPP.PropListing) do
		table.insert(reply, k)
	end
	
	return reply
end

function DPP.ClearDisconnectedProps()
	for k, v in pairs(DPP.GetUnownedProps()) do
		SafeRemoveEntity(v)
	end
	
	DPP.RecalculatePlayerList()
	DPP.SendPlayerList()
end

function DPP.GetPropsByUID(uid)
	DPP.RefreshPropList()
	local t = {}
	
	for k, v in pairs(DPP.PropListing) do
		local Name, UID, SteamID = DPP.GetOwnerDetails(k)
		if UID == uid then
			table.insert(t, k)
		end
	end
	
	return t
end

function DPP.ClearByUID(uid)
	for k, v in pairs(DPP.GetPropsByUID(uid)) do
		SafeRemoveEntity(v)
	end
	
	DPP.RecalculatePlayerList()
	DPP.SendPlayerList()
end

function DPP.FreezeByUID(uid)
	local Ents = DPP.GetPropsByUID(uid)
	
	for k, v in pairs(Ents) do
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
end

function DPP.UnFreezeByUID(uid)
	local Ents = DPP.GetPropsByUID(uid)
	
	for k, v in pairs(Ents) do
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(true)
		end
	end
end

concommand.Add('dpp_cleardisconnected', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	DPP.ClearDisconnectedProps()
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' cleared all disconnected players entites'}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
end)

concommand.Add('dpp_clearmap', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	for k, v in pairs(DPP.GetAllProps()) do
		SafeRemoveEntity(v)
	end
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' cleaned up map'}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
end)

concommand.Add('dpp_clearbyuid', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	local uid = args[1]
	if not tonumber(uid) then DPP.Notify(ply, 'Invalid argument') return end
	
	local Target = player.GetByUniqueID(uid)
	DPP.ClearByUID(uid)
	
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' cleared all ' .. (Target and Target:Nick() or DPP.DisconnectedPlayerNick(uid)) .. '\' props'}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
end)

concommand.Add('dpp_freezeall', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	
	for k, v in pairs(DPP.GetAllProps()) do
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
	
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' freezed all player\'s entites'}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
end)

concommand.Add('dpp_clearplayer', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	if tonumber(args[1]) then
		local found = Player(tonumber(args[1]))
		if not found then DPP.Notify(ply, 'Invalid argument') return end
		DPP.ClearPlayerEntites(found)
		
		local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' cleared all ' .. found:Nick() .. '\'s entites'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
		return
	end
	
	local Ply = string.lower(args[1])
	local found
	
	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), Ply) then found = v end
	end
	
	if not found then DPP.Notify(ply, 'Invalid argument') return end
	DPP.ClearPlayerEntites(found)
	
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' cleared all ' .. found:Nick() .. '\'s entites'}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
end)

concommand.Add('dpp_freezeplayer', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	if not args[1] then DPP.Notify(ply, 'Invalid argument') return end
	
	if tonumber(args[1]) then
		local found = Player(tonumber(args[1]))
		if not found then DPP.Notify(ply, 'Invalid argument') return end
		DPP.FreezePlayerEntites(found)
		
		local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' freeze all ' .. found:Nick() .. '\'s entites'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
		return
	end
	
	local Ply = string.lower(args[1])
	local found
	
	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), Ply) then found = v end
	end
	
	if not found then DPP.Notify(ply, 'Invalid argument') return end
	DPP.FreezePlayerEntites(found)
	
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' freeze all ' .. found:Nick() .. '\'s entites'}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
end)

concommand.Add('dpp_freezebyuid', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	
	local uid = args[1]
	
	if not tonumber(args[1]) then DPP.Notify(ply, 'Invalid argument') return end
	
	local Target = player.GetByUniqueID(uid)
	DPP.FreezeByUID(uid)
		
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' freeze all ' .. (Target and Target:Nick() or DPP.DisconnectedPlayerNick(uid)) .. '\'s entites'}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
end)

concommand.Add('dpp_unfreezebyuid', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	
	local uid = args[1]
	
	if not tonumber(args[1]) then DPP.Notify(ply, 'Invalid argument') return end
	
	local Target = player.GetByUniqueID(uid)
	DPP.UnFreezeByUID(uid)
		
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' unfreeze all ' .. (Target and Target:Nick() or DPP.DisconnectedPlayerNick(uid)) .. '\'s entites'}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
end)

concommand.Add('dpp_unfreezeplayer', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	if not args[1] then DPP.Notify(ply, 'Invalid argument') return end
	
	if tonumber(args[1]) then
		local found = Player(tonumber(args[1]))
		if not found then DPP.Notify(ply, 'Invalid argument') return end
		DPP.UnFreezePlayerEntites(found)
		
		local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' unfreeze all ' .. found:Nick() .. '\'s entites'}
		DPP.Notify(player.GetAll(), f)
		DPP.Message(f)
		return
	end
	
	local Ply = string.lower(args[1])
	local found
	
	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), Ply) then found = v end
	end
	
	if not found then DPP.Notify(ply, 'Invalid argument') return end
	DPP.UnFreezePlayerEntites(found)
	
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' unfreeze all ' .. found:Nick() .. '\'s entites'}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
end)

function DPP.RecalculateShare(ent)
	local hit = false
	
	for k, v in pairs(DPP.ShareTypes) do
		if DPP.IsSharedType(ent, k) then
			hit = true
			break
		end
	end
	
	ent:SetNWBool('DPP.IsShared', hit)
end

function DPP.SetIsShared(ent, mode, status)
	if status then
		ent:SetNWBool('DPP.IsShared', true)
	end
	
	ent:SetNWBool('DPP.Share' .. mode, status)
	
	timer.Create('DPP.RecalculateShared.' .. ent:EntIndex(), 0, 0, function()
		if IsValid(ent) then DPP.RecalculateShare(ent) end
	end)
end

concommand.Add('dpp_share', function(ply, cmd, args)
	local num = tonumber(args[1])
	local type = args[2]
	local status = args[3]
	
	if not num then DPP.Notify(ply, 'Invalid argument') return end
	if not type then DPP.Notify(ply, 'Invalid argument') return end
	if not status then DPP.Notify(ply, 'Invalid argument') return end
	
	local ent = Entity(num)
	if not IsValid(ent) then DPP.Notify(ply, 'Entity does not exists') return end
	if IsValid(ply) and DPP.GetOwner(ent) ~= ply then DPP.Notify(ply, 'Not a owner') return end
	
	status = tobool(status)
	
	DPP.SetIsShared(ent, type, status)
end)

DPP.ANTISPAM_VALID = 0
DPP.ANTISPAM_GHOSTED = 1
DPP.ANTISPAM_INVALID = 2

function DPP.CheckAntispam_NoEnt(ply, updatecount, updatetime)
	if not DPP.GetConVar('antispam') then return DPP.ANTISPAM_VALID end
	ply.DPP_AntiSpam = ply.DPP_AntiSpam or {}
	local I = ply.DPP_AntiSpam
	I.GhostCooldown = I.GhostCooldown or 0
	I.RemoveCooldown = I.RemoveCooldown or 0
	I.LastSpawn = I.LastSpawn or 0
	I.Count = I.Count or 0
	
	local delta = I.LastSpawn - CurTime()
	
	local dec = 0
	if delta + DPP.GetConVar('antispam_delay') > 0 then
		if updatecount then
			I.Count = I.Count + 1
		end
	else
		dec = math.floor(delta / 1)
	end
	
	I.Count = math.Clamp(I.Count + dec, 0, DPP.GetConVar('antispam_max'))
	
	if updatetime then
		I.LastSpawn = CurTime()
	end
	
	if I.Count > DPP.GetConVar('antispam_remove') then
		return DPP.ANTISPAM_INVALID
	end
	
	if I.Count > DPP.GetConVar('antispam_ghost') then
		return DPP.ANTISPAM_GHOSTED
	end
	
	return DPP.ANTISPAM_VALID
end

function DPP.CheckAntispam(ply, ent)
	if not DPP.GetConVar('antispam') then return end
	
	local reply = DPP.CheckAntispam_NoEnt(ply, true, true)
	
	if reply == DPP.ANTISPAM_INVALID then
		SafeRemoveEntity(ent)
		DPP.Notify(ply, 'Prop is removed due to spam', 1)
	elseif reply == DPP.ANTISPAM_GHOSTED then
		DPP.SetGhosted(ent, true)
		DPP.Notify(ply, 'Prop is ghosted due to spam', 0)
	end
end

function DPP.IsModelBlocked(model, ply)
	if not DPP.GetConVar('model_blacklist') then return end
	local white = DPP.GetConVar('model_whitelist')
	local status = DPP.BlockedModels[model] or false
	
	if white then status = not status end
	
	if status and IsValid(ply) then
		DPP.Notify(ply, 'Model of that entity is in the black list!', 1)
	end
	
	return status
end

function DPP.BroadcastLists()
	local count = 0
	
	for k, v in pairs(DPP.BlockedEntites) do
		timer.Create('DPP.SendBlockedEntities' .. k, count * 2, 1, function() --Prevent Spam
			net.Start('DPP.Lists')
			net.WriteString(k)
			net.WriteTable(v)
			net.Broadcast()
		end)
		count = count + 1
	end
	
	for k, v in pairs(DPP.RestrictedTypes) do
		timer.Create('DPP.SendRestricted' .. k, count * 2, 1, function() --Prevent Spam
			net.Start('DPP.RLists')
			net.WriteString(k)
			net.WriteTable(v)
			net.Broadcast()
		end)
		count = count + 1
	end
	
	timer.Create('DPP.SendModelList', count * 2, 1, function()
		net.Start('DPP.ModelLists')
		net.WriteTable(DPP.BlockedModels)
		net.Broadcast()
	end)
	
	count = count + 1
	
	timer.Create('DPP.SendLimitList', count * 2, 1, function()
		net.Start('DPP.LLists')
		net.WriteTable(DPP.EntsLimits)
		net.Broadcast()
	end)
	
	count = count + 1
	
	timer.Create('DPP.SendSLimitList', count * 2, 1, function()
		net.Start('DPP.SLists')
		net.WriteTable(DPP.SBoxLimits)
		net.Broadcast()
	end)
	
	count = count + 1
end

--[[timer.Remove('DPP.BroadcastCVars', 30, 0, function()
	DPP.BroadcastCVars()
end)]]

--Send constrained with is just half of protection
function DPP.SendConstrained(ent)
	ent._DPP_Constrained = ent._DPP_Constrained or {}
	
	net.Start('DPP.ConstrainedTable')
	net.WriteTable({ent})
	net.WriteTable(ent._DPP_Constrained)
	net.Broadcast()
end

do
	local EntMem = {}

	local function DoSearch(ent)
		if EntMem[ent] then return end
		local all = constraint.GetTable(ent)
		
		EntMem[ent] = true
		
		for k = 1, #all do
			local ent1, ent2 = all[k].Ent1, all[k].Ent2
			
			if isentity(ent1) then
				DoSearch(ent1)
			end
			
			if isentity(ent2) then
				DoSearch(ent2)
			end
		end
	end
	
	function DPP.GetAllConnectedEntities(ent)
		EntMem = {}
		
		DoSearch(ent)
		
		local result = {}
		
		for k, v in pairs(EntMem) do
			table.insert(result, k)
		end
		
		return result
	end
	
	--Really slow for now
	function DPP.RecalcConstraints(ent)
		if not DPP.GetConVar('enable') then return end
		if not IsValid(ent) then return end
		
		if ent._DPP_LastRecalc == CurTime() then return end
		EntMem = {}
		local result = {}
		DoSearch(ent)
		
		local worldspawn = Entity(0)
		local owners = {}
		local touched = {}
		
		for k, v in pairs(EntMem) do
			if not IsValid(k) then continue end
			if k:GetClass() == 'gmod_anchor' then continue end
			local o = DPP.GetOwner(k)
			table.insert(touched, k)
			if IsValid(o) then
				owners[o] = true
			else
				owners[worldspawn] = true
			end
		end
		
		local owners2 = {}
		
		for k, v in pairs(owners) do
			table.insert(owners2, k)
		end
		
		local c = CurTime()
		for k, v in pairs(EntMem) do
			k._DPP_Constrained = owners2
			k._DPP_LastRecalc = c
		end
		
		timer.Simple(1, function()
			net.Start('DPP.ConstrainedTable')
			net.WriteTable(touched)
			net.WriteTable(owners2)
			net.Broadcast()
		end)
	end
end

DPP.__oldBlastDamage = DPP.__oldBlastDamage or util.BlastDamage

do
	local LastCall = 0
	local TotalCalls = 0
	
	function util.BlastDamage(...)
		if DPP.GetConVar('prevent_explosions_crash') then
			if LastCall + 3 < CurTime() then
				TotalCalls = 0
			end
			
			if TotalCalls >= DPP.GetConVar('prevent_explosions_crash_num') then return end
			
			LastCall = CurTime()
			TotalCalls = TotalCalls + 1
		end
		
		return DPP.__oldBlastDamage(...)
	end
end
