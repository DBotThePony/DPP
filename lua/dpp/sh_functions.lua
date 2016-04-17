
function DPP.GetGhosted(ent)
	return ent:GetNWBool('DPP.IsGhosted')
end

function DPP.IsOwned(ent)
	if not IsValid(ent) then return false end
	return ent:GetNWBool('DPP.IsOwned')
end

function DPP.IsUpForGrabs(ent)
	return ent:GetNWBool('DPP.IsUpForGraps')
end

function DPP.GetOwnerDetails(ent)
	return ent:GetNWString('DPP.OwnerString', 'World'),
		ent:GetNWInt('DPP.OwnerUID', 0),
		ent:GetNWString('DPP.OwnerSteamID', '')
end

function DPP.GetConstrainedTable(ent)
	ent._DPP_Constrained = ent._DPP_Constrained or {}
	return ent._DPP_Constrained
end

function DPP.IsShared(ent)
	return ent:GetNWBool('DPP.IsShared')
end

function DPP.IsSharedType(ent, mode)
	return ent:GetNWBool('DPP.Share' .. mode)
end

function DPP.GetSharedTable(ent)
	local t = {}
	
	for k, v in pairs(DPP.ShareTypes) do
		t[k] = DPP.IsSharedType(ent, k)
	end
	
	return t
end

function DPP.IsFriend(ply, ply2, mode)
	if ply == ply2 then return true end
	local t = DPP.GetFriendTable(ply2)
	
	if mode then
		if not t[ply] then return false end
		return t[ply][mode] ~= false --???, i would return true if mode does not exist or ply2 is a generic friend to ply
	end
	
	return t[ply] ~= nil
end

function DPP.IsPlayerInEntity(ply, ent) --From DLib
	local pos = ply:GetPos()
	local epos = ply:EyePos()
	
	pos.z = pos.z - 10
	epos.z = epos.z + 10
	
	local Mins, Maxs = ply:WorldSpaceAABB()
	Mins = (Mins - pos) * 1.3 --Make wider
	Maxs = (Maxs - pos) * 1.3
	
	local hit = false
	local function fn(E)
		if E == ent then return true end
		return false
	end

	local tr = util.TraceHull{
		start = pos,
		endpos = epos,
		mins = Mins,
		maxs = Maxs,
		ignoreworld = true,
		filter = fn,
	}
	
	local tr2 = util.TraceLine{
		start = pos,
		endpos = epos,
		ignoreworld = true,
		filter = fn,
	}
	
	return tr.Entity == ent or tr2.Entity == ent
end

local default = {'user', 'admin', 'superadmin'}

function DPP.GetGroups()
	local reply = {}
	
	if CAMI then
		local groups = CAMI.GetUsergroups()
		local reply = table.Copy(default)
		
		for k, v in pairs(groups) do
			if table.HasValue(reply, k) then continue end
			table.insert(reply, k)
		end
		
		return reply
	end
	
	--CAMI is so fresh, so many servers have ULib without CAMI installed
	if ULib then
		local g = ULib.ucl.groups
		
		for k, v in pairs(g) do
			if table.HasValue(reply, k) then continue end
			table.insert(reply, k)
		end
	end
	
	for k, v in pairs(default) do
		if table.HasValue(reply, v) then continue end
		table.insert(reply, v)
	end
	
	return reply
end

function DPP.IsBlockedModel(model)
	return DPP.BlockedModels[model] or false
end

function DPP.UpdateConstrainedWith(ent)
	ent.DPP_ConstrainedWith = ent.DPP_ConstrainedWith or {}
	for k, v in pairs(ent.DPP_ConstrainedWith) do
		if not IsValid(k) then
			ent.DPP_ConstrainedWith[k] = nil
			continue
		end
	end
end

function DPP.GetConstrainedWith(ent)
	ent.DPP_ConstrainedWith = ent.DPP_ConstrainedWith or {}
	return ent.DPP_ConstrainedWith
end

function DPP.IsConstrainedWith(ent, ent2)
	ent.DPP_ConstrainedWith = ent.DPP_ConstrainedWith or {}
	return ent.DPP_ConstrainedWith[ent2] or false
end

function DPP.IsSingleOwner(ent, owner)
	for k, v in pairs(DPP.GetConstrainedTable(ent)) do
		if v ~= owner then return false end
	end
	
	return true
end

function DPP.GetEntityType(ent)
	if ent:GetClass() == 'prop_physics' then
		return 'prop'
	elseif ent:IsNPC() then
		return 'npc'
	elseif ent:IsRagdoll() then
		return 'ragdoll'
	elseif ent:IsVehicle() then
		return 'vehicle'
	elseif ent:IsWeapon() then
		return 'weapon'
	elseif ent.IsConstraint and ent:IsConstraint() then
		return 'constraint'
	else
		return 'sent'
	end
end

function DPP.DisconnectedPlayerNick(uid)
	for k, v in pairs(DPP.PlayerList) do
		if v.UID == uid then return v.Name end
	end
	
	return uid
end

local function UIDTableHasValue(t, uid)
	for i = 1, #t do
		if t[i].UID == uid then return true end
	end
	
	return false
end

function DPP.GetPlayerList()
	local plys = player.GetAll()
	
	local r = {}
	
	for k, v in pairs(plys) do
		table.insert(r, {UID = v:UniqueID(), SteamID = v:SteamID(), Name = v:Nick()})
	end
	
	for k, v in pairs(DPP.PlayerList) do
		if UIDTableHasValue(r, v.UID) then continue end
		table.insert(r, v)
	end
	
	return r
end

function DPP.IsModelBlocked(model, ply)
	if not DPP.GetConVar('enable_blocked') then return false end
	if not DPP.GetConVar('model_blacklist') then return false end
	local white = DPP.GetConVar('model_whitelist')
	local status = DPP.BlockedModels[model] ~= nil
	
	if white then status = not status end
	
	if status and IsValid(ply) then
		DPP.Notify(ply, 'Model of that entity is in the black list!', 1)
	end
	
	return status
end

function DPP.IsModelEvenBlocked(model)
	return DPP.BlockedModels[model] ~= nil
end

function DPP.IsProtectionDisabledFor(ply, mode)
	return DPP.PlayerConVar(ply, 'disable_' .. mode .. '_protection')
end
