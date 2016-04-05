
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

function DPP.IsFriend(ply, ply2)
	if ply == ply2 then return true end
	local t = DPP.GetFriendTable(ply2)
	if t[ply] then return true else return false end
end

function DPP.IsPlayerInEntity(ply, ent) --From DLib
	local pos = ply:GetPos()
	
	local hit = false
	local function fn(E)
		if E == ent then hit = true end
		if E == ent then return false else return true end
	end

	local tr = util.TraceHull{
		start = pos + Vector(0,0,3),
		endpos = pos + Vector(0,0,80),
		mins = Vector(-15, -15, -15),
		maxs = Vector(15, 15, 15),
		ignoreworld = true,
		filter = fn,
	}
	
	local tr2 = util.TraceLine{
		start = pos,
		endpos = pos,
		ignoreworld = true,
		filter = fn,
	}
	
	return hit
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
