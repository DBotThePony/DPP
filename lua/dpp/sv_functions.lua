
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

local GhostColor = Color(255, 255, 255, 224)

function DPP.SetOwnerFull(ent, owner, knownOwner)
	knownOwner = knownOwner or DPP.GetOwner(ent)
	DPP.SetOwner(ent, owner)
	
	for k, ent2 in ipairs(ent.__DPP_BundledEntities) do
		if IsValid(ent2) then
			DPP.SetOwner(ent2, owner)
			DPP.TableRecursiveReplace(ent2:GetTable(), knownOwner, owner)
		end
	end
	
	DPP.TableRecursiveReplace(ent:GetTable(), knownOwner, owner)
end

DPP.SetOwnerRecursive = DPP.SetOwnerFull
DPP.SetOwnerTable = DPP.SetOwnerFull

function DPP.SetGhosted(ent, status)
	if not IsValid(ent) then return end
	if ent:IsPlayer() then return end
	if ent.IsConstraint and ent:IsConstraint() then return end
	if status and DPP.GetGhosted(ent) then return end

	local can = hook.Run('DPP_SetGhosted', ent, status)
	if can == false then return end

	local invalidPhys = Entity(0):GetPhysicsObject()
	local physObjects = {}

	for i = 0, ent:GetPhysicsObjectCount() - 1 do
		local phys = ent:GetPhysicsObjectNum(i)
		if phys ~= invalidPhys then
			table.insert(physObjects, phys)
		end
	end

	if status then
		ent:SetDPPVar('IsGhosted', true)

		ent.__DPPColor = ent:GetColor()
		ent.DPP_oldCollision = ent:GetCollisionGroup()
		ent.DPP_OldRenderMode = ent:GetRenderMode()
		ent:SetRenderMode(RENDERMODE_TRANSALPHA)
		ent:SetColor(GhostColor)
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)

		local phys = ent:GetPhysicsObject()
		ent.DPP_OldCollisions = {}

		for i, phys in pairs(physObjects) do
			phys:EnableMotion(false)
			ent.DPP_OldCollisions[i] = phys:IsCollisionEnabled()
			phys:Sleep()
			phys:EnableCollisions(false)
		end
	else
		ent:SetDPPVar('IsGhosted', false)

		if ent.DPP_OldRenderMode then ent:SetRenderMode(ent.DPP_OldRenderMode) end
		if ent.__DPPColor then ent:SetColor(ent.__DPPColor) end
		if ent.DPP_oldCollision then ent:SetCollisionGroup(ent.DPP_oldCollision) end

		local phys = ent:GetPhysicsObject()

		for i, phys in pairs(physObjects) do
			phys:EnableMotion(true)

			if ent.DPP_OldCollisions[i] ~= nil then
				phys:EnableCollisions(ent.DPP_OldCollisions[i])
			end

			phys:Wake()
		end
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

function DPP.ListModelCounts(ply)
	DPP.RefreshPropList()
	local reply = {}
	
	for k, ent in pairs(DPP.PropListing) do
		if DPP.GetOwner(ent) == ply then
			local m = ent:GetModel()
			
			if m then
				reply[m] = (reply[m] or 0) + 1
			end
		end
	end
	
	return reply
end

function DPP.SendPlayerList()
	net.Start('DPP.PlayerList')
	net.WriteTable(DPP.PlayerList)
	net.Broadcast()
end

function DPP.CheckSizes(ent, ply)
	if not DPP.GetConVar('enable') then return false end
	if not DPP.GetConVar('check_sizes') then return false end
	if not IsValid(ent) then return false end
	if ent:IsConstraint() then return false end

	local solid = ent:GetSolid()
	local cgroup = ent:GetCollisionGroup()

	if solid == SOLID_NONE then return false end
	if cgroup == COLLISION_GROUP_WORLD then return false end

	local phys = ent:GetPhysicsObject()
	if not IsValid(phys) then return false end
	local size = phys:GetVolume()
	if not size then return false end

	if size / 1000 < DPP.GetConVar('max_size') then return false end

	local can = hook.Run('DPP_G_SizesHit', ent, ply)
	if can == false then return false end

	timer.Simple(0, function() --Give entity time to initialize
		if not IsValid(ent) then return end
		DPP.SetGhosted(ent, true)
		if ply and IsValid(ply) then
			DPP.Notify(ply, DPP.PPhrase(ply, 'ghosted_big'))
		end
	end)

	return true
end

function DPP.CheckAutoBlock(ent, ply)
	if not DPP.GetConVar('prop_auto_ban') then return true end
	if not IsValid(ent) then return true end
	if ent:IsConstraint() then return true end

	local model = ent:GetModel()
	if not model then return true end
	local phys = ent:GetPhysicsObject()
	if not IsValid(phys) then return true end
	local size = phys:GetVolume()
	if not size then return true end
	
	local mins, maxs = phys:GetAABB()

	local cond = size / 1000 < DPP.GetConVar('prop_auto_ban_size') and
		(not DPP.GetConVar('prop_auto_ban_check_aabb') or DPP.GetConVar('prop_auto_ban_minsmaxs') >= mins:Distance(maxs))
	
	if cond then return true end

	local can = hook.Run('DPP_G_AutoBlockHit', ent, ply)
	if can == false then return true end

	SafeRemoveEntity(ent)
	DPP.ManipulateCommands.addblockedmodel(Entity(0), '', {model})
	if ply and IsValid(ply) then
		DPP.Notify(ply, DPP.PPhrase(ply, 'prop_autoban'))
	end

	return false
end

function DPP.CheckSizesDelay(ent, ply)
	if not IsValid(ent) then return false end

	timer.Simple(0, function()
		if not IsValid(ent) then return end
		DPP.CheckSizes(ent, ply)
	end)
end

function DPP.CheckStuck(ply, ent1, ent2)
	if not DPP.GetConVar('enable') then return false end
	if not DPP.GetConVar('check_stuck') then return false end
	if ply:InVehicle() then return false end
	if ent1 == ent2 then return false end

	if ent1:IsPlayer() then return false end
	if ent2:IsPlayer() then return false end

	if ent1:GetSolid() == SOLID_NONE then return false end
	if ent1:GetMoveType() == MOVETYPE_NONE then return false end
	if ent2:GetSolid() == SOLID_NONE then return false end
	if ent2:GetMoveType() == MOVETYPE_NONE then return false end

	if ent1:IsWeapon() and IsValid(ent1:GetOwner()) then return false end
	if ent2:IsWeapon() and IsValid(ent2:GetOwner()) then return false end

	local parent1, parent2 = ent1:GetParent(), ent2:GetParent()

	if parent1 == ent2 or parent2 == ent1 then return false end

	local phys1, phys2 = ent1:GetPhysicsObject(), ent2:GetPhysicsObject()

	if DPP.GetConVar('stuck_ignore_frozen') then
		if IsValid(phys1) and not phys1:IsMotionEnabled() then return false end
		if IsValid(phys2) and not phys2:IsMotionEnabled() then return false end
	end

	if IsValid(phys1) and not phys1:IsCollisionEnabled() then return false end
	if IsValid(phys2) and not phys2:IsCollisionEnabled() then return false end

	local const1 = constraint.FindConstraint(ent1, 'NoCollide')
	local const2 = constraint.FindConstraint(ent2, 'NoCollide')

	if const1 then
		if const1.Ent1 == ent2 or const1.Ent2 == ent2 then return false end
	end

	if const2 then
		if const2.Ent1 == ent1 or const2.Ent2 == ent1 then return false end
	end

	local pos1, pos2 = ent1:GetPos(), ent2:GetPos()

	local min1, max1 = ent1:WorldSpaceAABB()
	local min2, max2 = ent2:WorldSpaceAABB()

	local cond = max1:Distance(max2) < 10 and min1:Distance(min2) < 10 or
		pos1:Distance(pos2) < 10

	if not cond then return false end

	local can = hook.Run('DPP_G_StuckHit', ply, ent1, ent2)
	if can == false then return false end

	DPP.SetGhosted(ent1, true)
	DPP.SetGhosted(ent2, true)
	if IsValid(ply) then
		DPP.Notify(ply, DPP.PPhrase(ply, 'stuck_hit'))
	end

	return true
end

function DPP.GetPlayerEntities(ply)
	DPP.RefreshPropList()
	local reply = {}

	for ent, v in pairs(DPP.PropListing) do
		if DPP.GetOwner(ent) == ply then table.insert(reply, ent) end
	end

	return reply
end

DPP.GetPlayerEnts = DPP.GetPlayerEntities

function DPP.FindEntitiesByClass(ply, class)
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
	ent:SetDPPVar('IsUpForGraps', status)
end

function DPP.DeleteEntityUndo(ent)
	local tab = undo.GetTable()

	for uid, data in pairs(tab) do
		for index, udata in pairs(data) do
			udata.Entities = udata.Entities or {}

			for k, v in pairs(udata.Entities) do
				if v == ent then
					udata.Entities[k] = NULL
				end
			end
		end
	end
end

function DPP.DeleteEntityUndoByTable(target)
	local tab = undo.GetTable()

	for uid, data in pairs(tab) do
		for index, udata in pairs(data) do
			udata.Entities = udata.Entities or {}

			for k, v in pairs(udata.Entities) do
				if DPP.HasValueLight(target, v) then
					udata.Entities[k] = NULL
				end
			end
		end
	end
end

function DPP.TransferUndoTo(source, target)
	local tab = undo.GetTable()

	local uidS = source:UniqueID()
	local uidT = target:UniqueID()

	if not tab[uidS] then return end

	for i, data in ipairs(tab[uidS]) do
		data.Entities = data.Entities or {}
		data.Functions = data.Functions or {}

		undo.Create(data.Name)
		undo.SetPlayer(target)

		for k, ent in ipairs(data.Entities) do
			undo.AddEntity(ent)
		end

		for k, funcTab in ipairs(data.Functions) do
			undo.AddFunction(funcTab[1], unpack(funcTab[2]))
		end

		undo.Finish()

		data.Entities = {}
		data.Functions = {}
	end
end

function DPP.ClearPlayerEntities(ply)
	local Ents = DPP.GetPlayerEntities(ply)

	for k, v in ipairs(Ents) do
		SafeRemoveEntity(v)
	end

	DPP.RecalculatePlayerList()
	DPP.SendPlayerList()
end

function DPP.FreezePlayerEntities(ply)
	local Ents = DPP.GetPlayerEntities(ply)

	local reply = {}

	for k, v in ipairs(Ents) do
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
			table.insert(reply, v)
		end
	end

	return reply
end

function DPP.UnFreezePlayerEntities(ply)
	local Ents = DPP.GetPlayerEntities(ply)

	local reply = {}

	for k, v in ipairs(Ents) do
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(true)
			table.insert(reply, v)
		end
	end

	return reply
end

function DPP.FindPlayerProps(ply)
	local uid = ply:UniqueID()

	local find = DPP.GetPropsByUID(uid)

	for k, ent in pairs(find) do
		DPP.SetOwner(ent, ply)
		DPP.SetUpForGrabs(ent, false)
	end

	for k, ent in pairs(find) do
		DPP.RecalcConstraints(ent)
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

	--Recalculate after props is removed
	timer.Simple(1, function()
		DPP.RecalculatePlayerList()
		DPP.SendPlayerList()
	end)
end

function DPP.ClearByUID(uid)
	for k, v in ipairs(DPP.GetPropsByUID(uid)) do
		SafeRemoveEntity(v)
	end

	--Recalculate after props is removed
	timer.Simple(1, function()
		DPP.RecalculatePlayerList()
		DPP.SendPlayerList()
	end)
end

function DPP.FreezeByUID(uid)
	local Ents = DPP.GetPropsByUID(uid)

	for k, v in ipairs(Ents) do
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
end

function DPP.UnFreezeByUID(uid)
	local Ents = DPP.GetPropsByUID(uid)

	local reply = {}

	for k, v in ipairs(Ents) do
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(true)
			table.insert(reply, v)
		end
	end

	return reply
end

function DPP.RecalculateShare(ent)
	local hit = false

	for k, v in pairs(DPP.ShareTypes) do
		if DPP.IsSharedType(ent, k) then
			hit = true
			break
		end
	end

	ent:SetDPPVar('IsShared', hit)
end

function DPP.SetIsShared(ent, mode, status)
	if status then
		ent:SetDPPVar('IsShared', true)
	end

	ent:SetDPPVar('share' .. mode, status)

	timer.Create('DPP.RecalculateShared.' .. ent:EntIndex(), 0, 0, function()
		if IsValid(ent) then DPP.RecalculateShare(ent) end
	end)
end

DPP.ANTISPAM_VALID = 0
DPP.ANTISPAM_GHOSTED = 1
DPP.ANTISPAM_INVALID = 2

function DPP.CheckAntispam_NoEnt(ply, updatecount, updatetime)
	if not DPP.GetConVar('antispam') then return DPP.ANTISPAM_VALID end

	local can = hook.Run('DPP_AntiSpam', ply, updatecount, updatetime)
	if can == false then return DPP.ANTISPAM_VALID end

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
		dec = delta / (DPP.GetConVar('antispam_cooldown_divider') * 1.5) --Sorry about that
	end

	I.Count = math.Clamp(I.Count + dec, 0, DPP.GetConVar('antispam_max'))

	if updatetime then
		I.LastSpawn = CurTime()
	end

	if I.Count > DPP.GetConVar('antispam_remove') then
		return hook.Run('DPP_AntiSpam_Hit', ply, updatecount, updatetime, DPP.ANTISPAM_INVALID) or DPP.ANTISPAM_INVALID
	end

	if I.Count > DPP.GetConVar('antispam_ghost') then
		return hook.Run('DPP_AntiSpam_Hit', ply, updatecount, updatetime, DPP.ANTISPAM_GHOSTED) or DPP.ANTISPAM_GHOSTED
	end

	return hook.Run('DPP_AntiSpam_Miss', ply, updatecount, updatetime) or DPP.ANTISPAM_VALID
end

function DPP.CheckAntispamDelay(ply, ent)
	timer.Create('DPP.CheckAntispamDelay[' .. ply:EntIndex() .. '][' .. ent:EntIndex() .. ']', 0, 1, function()
		if IsValid(ply) and IsValid(ent) then DPP.CheckAntispam(ply, ent) end
	end)
end

function DPP.CheckAntispam(ply, ent, force)
	if not DPP.GetConVar('antispam') then return DPP.ANTISPAM_VALID end
	if not IsValid(ent) then return DPP.ANTISPAM_VALID end
	if ent.IsConstraint and ent:IsConstraint() then return DPP.ANTISPAM_VALID end

	if not force and ent:GetSolid() == SOLID_NONE then return DPP.ANTISPAM_VALID end
	if not force and ent:GetMoveType() == MOVETYPE_NONE then return DPP.ANTISPAM_VALID end

	local can = hook.Run('DPP_AntiSpamEnt', ply, ent)
	if can == false then return DPP.ANTISPAM_VALID end

	local reply = DPP.CheckAntispam_NoEnt(ply, true, true)

	if reply == DPP.ANTISPAM_INVALID then
		local can = hook.Run('DPP_AntiSpamEnt_Hit', ply, ent, DPP.ANTISPAM_INVALID)
		if can == false then return DPP.ANTISPAM_VALID end

		SafeRemoveEntity(ent)
		DPP.Notify(ply, DPP.PPhrase(ply, 'spam_removed'), 1)
		return DPP.ANTISPAM_INVALID
	elseif reply == DPP.ANTISPAM_GHOSTED then
		local can = hook.Run('DPP_AntiSpamEnt_Hit', ply, ent, DPP.ANTISPAM_GHOSTED)
		if can == false then return DPP.ANTISPAM_VALID end

		DPP.SetGhosted(ent, true)
		DPP.Notify(ply, DPP.PPhrase(ply, 'spam_ghosted'), 0)
		return DPP.ANTISPAM_GHOSTED
	end
end

function DPP.IsChekedByAntispam(ent)
	if not DPP.GetConVar('antispam') then return false end
	if not IsValid(ent) then return false end

	if ent:GetSolid() == SOLID_NONE then return false end
	if ent:GetMoveType() == MOVETYPE_NONE then return false end

	return true
end

do
	local EntMem = {}

	local function DoSearch(ent)
		if EntMem[ent] then return end

		local all = constraint.GetTable(ent)

		EntMem[ent] = true

		if ent.GetChildren then
			local Ents = ent:GetChildren()

			for k, v in pairs(Ents) do
				if IsValid(v) then
					DoSearch(v)
				end
			end
		end
		
		for k, ent in ipairs(ent.__DPP_BundledEntities or {}) do
			if IsValid(ent) then
				DoSearch(ent)
			end
		end

		for k = 1, #all do
			local ent1, ent2 = all[k].Ent1, all[k].Ent2
			local const = all[k].Constraint

			local o1, o2, o3
			if isentity(const) then
				o3 = DPP.GetOwner(const)
			end

			if isentity(ent1) then
				o1 = DPP.GetOwner(ent1)
				DoSearch(ent1)
			end

			if isentity(ent2) then
				o2 = DPP.GetOwner(ent2)
				DoSearch(ent2)
			end

			if o1 == o2 and o1 ~= o3 then
				DPP.DeleteEntityUndo(const)
				DPP.SetOwner(const, o1)
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
	
	local toCheck = {}
	
	function DPP.RecalcConstraintsDelay(ent)
		if ent._DPP_LastRecalc == CurTime() then return end
		table.insert(toCheck, {ent, CurTime()})
	end
	
	hook.Add('Tick', 'DPP.RecalcConstraintsDelay', function()
		local toRemove = {}
		local cTime = CurTime()
		
		for k, data in ipairs(toCheck) do
			if data[2] ~= cTime then
				table.insert(toRemove, k)
				DPP.RecalcConstraints(data[1])
			end
		end
		
		for i = #toRemove, 1, -1 do
			table.remove(toCheck, toRemove[i])
		end
	end)

	--Really slow for now
	function DPP.RecalcConstraints(ent)
		if not DPP.GetConVar('enable') then return {} end
		if not IsValid(ent) then return {} end

		if ent._DPP_LastRecalc == CurTime() then return ent._DPP_RecalcLastResult or {} end
		local result = DPP.GetAllConnectedEntities(ent)

		local worldspawn = Entity(0)
		local owners = {}
		local touched = {}

		for i, ent in ipairs(result) do
			if not IsValid(ent) then continue end
			if ent:GetClass() == 'gmod_anchor' then continue end
			if ent:GetClass():sub(1, 5) == 'phys_' then continue end -- No constraints
			local o = DPP.GetOwner(ent)
			local isOwned = DPP.IsOwned(ent)
			table.insert(touched, ent)

			if IsValid(o) then
				owners[o] = true
			elseif not IsValid(o) and isOwned then
				local Name, UID, SteamID = DPP.GetOwnerDetails(ent)

				owners['disconnected_' .. UID] = true
			else
				owners[worldspawn] = true
			end
		end

		local owners2 = {}

		for k, v in pairs(owners) do
			table.insert(owners2, k)
		end

		local c = CurTime()
		
		for i, ent in ipairs(touched) do
			DPP.GetNetworkDataTable(ent)._DPP_Constrained = owners2
			ent._DPP_LastRecalc = c
			ent._DPP_RecalcLastResult = result
		end

		timer.Simple(1, function()
			net.Start('DPP.ConstrainedTable')
			net.WriteTable(touched)
			net.WriteTable(owners2)
			net.Broadcast()
		end)

		return result
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

function DPP.RefreshConstrainsList()
	for ent, v in pairs(DPP.ConstraintsListing) do
		if not IsValid(ent) then
			DPP.ConstraintsListing[ent] = nil
		end
	end
end

function DPP.ConstraintCount(ply, type)
	DPP.RefreshConstrainsList()
	local c = 0

	for ent, v in pairs(DPP.ConstraintsListing) do
		if DPP.GetOwner(ent) == ply and DPP.GetContstrainType(ent) == type then
			c = c + 1
		end
	end

	return c
end

function DPP.IsConstraintLimitReached(ply, type)
	local count = DPP.GetConstLimit(type, ply:GetUserGroup())
	if count <= 0 then return false end
	local total = DPP.ConstraintCount(ply, type)
	return total >= count
end

function DPP.PlayerConstraints(ply)
	DPP.RefreshConstrainsList()
	local t = {}

	for ent, v in pairs(DPP.ConstraintsListing) do
		if DPP.GetOwner(ent) == ply then
			table.insert(t, ent)
		end
	end

	return t
end

function DPP.GetPropsByUID(uid)
	uid = tostring(uid)
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

DPP.GetEntitiesByUID = DPP.GetPropsByUID
DPP.GetEntsByUID = DPP.GetPropsByUID

function DPP.SetProtectionDisabled(ply, mode, status)
	ply:SetDPPVar('DisablePP.' .. mode, status)
end

function DPP.FreezeAllPhysObjects()
	local i = 0

	for k, ent in ipairs(ents.GetAll()) do
		local phys = ent:GetPhysicsObject()
		if not IsValid(phys) then continue end
		phys:Sleep()
		phys:EnableMotion(false)
		i = i + 1
	end

	return i
end

local function PositionsSorter(a, b)
	return a[2] > b[2]
end

local BlacklistEntities = {
	'func_',
	'filter_',
	'bodyque',
	'env_shake',
}

local Ignore = {
	'player',
	'hint',
	'info_',
	'trigger_',
	'gamerules',
	'soundent',
	'player_manager',
	'scene_manager',
	'network',
	'predicted_viewmodel',
	'phys_constraint',
}

--Looooooong spagetti code
function DPP.ReportEntities()
	local Ents = ents.GetAll()

	local skipped = 0
	local sbymap = 0
	local useless = 0
	local iowned = 0
	local iphys = 0
	local active = 0
	local vactive = 0
	local owners = {}
	local positions = {}
	local positions_solid = {}
	local classes = {}
	local classes_solid = {}

	local spositions = {}
	local spositions_solid = {}
	local sclasses = {}
	local sclasses_solid = {}

	for k, ent in ipairs(Ents) do
		local class = ent:GetClass()
		if not class then continue end

		local hit = false

		for i, str in ipairs(Ignore) do
			if class:find(str) then
				hit = true
				break
			end
		end

		if hit then
			skipped = skipped + 1
			continue
		end

		local owner = DPP.GetOwner(ent)

		if IsValid(owner) then
			owners[owner] = owners[owner] or {}
			table.insert(owners[owner], ent)
			iowned = iowned + 1
		end

		local solid = ent:GetSolid()
		local bymap = ent:CreatedByMap() 

		if not bymap then
			for i, str in ipairs(BlacklistEntities) do
				if class:find(str) then
					bymap = true
					break
				end
			end
		end

		if bymap then
			sbymap = sbymap + 1
		end

		if solid == SOLID_NONE then
			useless = useless + 1
		end

		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			iphys = iphys + 1

			if phys:IsMotionEnabled() then
				active = active + 1

				local vel = phys:GetVelocity()
				local sum = vel.x + vel.y + vel.z

				if sum ~= 0 then
					vactive = vactive + 1
				end
			end
		end

		local pos = ent:GetPos()

		--Non-Solid entites can have no valid position!
		if pos then
			local concat = math.floor(pos.x / 100) .. ' ' .. math.floor(pos.y / 100) .. ' ' .. math.floor(pos.z / 100)
			positions[concat] = (positions[concat] or 0) + 1

			if solid ~= SOLID_NONE then
				positions_solid[concat] = (positions_solid[concat] or 0) + 1
			end

			if not bymap then
				spositions[concat] = (spositions[concat] or 0) + 1

				if solid ~= SOLID_NONE then
					spositions_solid[concat] = (spositions_solid[concat] or 0) + 1
				end
			end
		end

		classes[class] = (classes[class] or 0) + 1
		if solid ~= SOLID_NONE then
			classes_solid[class] = (classes_solid[class] or 0) + 1
		end

		if not bymap then
			sclasses[class] = (sclasses[class] or 0) + 1
			if solid ~= SOLID_NONE then
				sclasses_solid[class] = (sclasses_solid[class] or 0) + 1
			end
		end
	end

	local positions2 = {}
	local positions_solid2 = {}
	local classes2 = {}
	local classes_solid2 = {}

	local spositions2 = {}
	local spositions_solid2 = {}
	local sclasses2 = {}
	local sclasses_solid2 = {}

	for k, v in pairs(positions) do
		table.insert(positions2, {k, v})
	end

	for k, v in pairs(classes) do
		table.insert(classes2, {k, v})
	end

	for k, v in pairs(positions_solid) do
		table.insert(positions_solid2, {k, v})
	end

	for k, v in pairs(classes_solid) do
		table.insert(classes_solid2, {k, v})
	end

	for k, v in pairs(spositions) do
		table.insert(spositions2, {k, v})
	end

	for k, v in pairs(sclasses) do
		table.insert(sclasses2, {k, v})
	end

	for k, v in pairs(spositions_solid) do
		table.insert(spositions_solid2, {k, v})
	end

	for k, v in pairs(sclasses_solid) do
		table.insert(sclasses_solid2, {k, v})
	end

	table.sort(positions2, PositionsSorter)
	table.sort(classes2, PositionsSorter)
	table.sort(positions_solid2, PositionsSorter)
	table.sort(classes_solid2, PositionsSorter)

	table.sort(spositions2, PositionsSorter)
	table.sort(sclasses2, PositionsSorter)
	table.sort(spositions_solid2, PositionsSorter)
	table.sort(sclasses_solid2, PositionsSorter)

	local data = {
		sbymap = sbymap,
		skipped = skipped,
		count = #Ents,
		iowned = iowned,
		unowned = #Ents - iowned,
		nosolid = useless,
		iphys = iphys,
		active = active,
		owners = owners,
		vactive = vactive,

		positions = positions,
		positions2 = positions2,
		classes2 = classes2,
		classes = classes,
		positions_solid2 = positions_solid2,
		positions_solid = positions_solid,
		classes_solid2 = classes_solid2,
		classes_solid = classes_solid,

		spositions = spositions,
		spositions2 = spositions2,
		sclasses2 = sclasses2,
		sclasses = sclasses,
		spositions_solid2 = spositions_solid2,
		spositions_solid = spositions_solid,
		sclasses_solid2 = sclasses_solid2,
		sclasses_solid = sclasses_solid,
	}

	return data
end

local Gray = Color(200, 200, 200)
local ClassColor = Color(200, 230, 200)
local NumColor = Color(200, 230, 230)

local ColStatus = false
local Col1 = Color(200, 170, 200)
local Col2 = Color(200, 200, 170)

local function StringColorWrap(...)
	ColStatus = not ColStatus

	if ColStatus then
		DPP.SimpleLog(Col1, ...)
	else
		DPP.SimpleLog(Col2, ...)
	end
end

local function CurColor()
	if not ColStatus then
		return Col1
	else
		return Col2
	end
end

function DPP.ReportEntitiesPrint()
	local t = SysTime()
	local data = DPP.ReportEntities()
	local nt = (SysTime() - t) * 1000

	DPP.SimpleLog(color_white, '--------------------------------')

	DPP.SimpleLog(color_white, '#report_summary')
	StringColorWrap('#report_1', ' ' .. data.count)
	StringColorWrap('#report_2', ' ' .. data.iowned)
	StringColorWrap('#report_3', ' ' .. data.unowned)
	StringColorWrap('#report_4', ' ' .. data.nosolid)
	StringColorWrap('#report_5', ' ' .. data.sbymap)
	StringColorWrap('#report_6', ' ' .. data.iphys)
	StringColorWrap('#report_7', ' ' .. data.active)
	StringColorWrap('#report_8', ' ' .. data.vactive)
	StringColorWrap('#report_9', ' ' .. data.skipped)

	DPP.SimpleLog(color_white, '#report_owners')
	local hit = false

	for k, v in pairs(data.owners) do
		hit = true
		StringColorWrap(k, CurColor(), '#report_spawned||' .. #v)
	end

	if not hit then
		StringColorWrap('#report_nodata')
	end

	DPP.SimpleLog(color_white, '#report_allents')
	DPP.SimpleLog(color_white, '#report_allpos')
	for i = 1, 4 do
		local row = data.positions2[i]
		if not row then StringColorWrap('#report_nodata') break end

		local spos = string.Explode(' ', row[1])
		local rpos = tonumber(spos[1]) * 100 .. ' ' .. tonumber(spos[2]) * 100 .. ' ' .. tonumber(spos[3]) * 100

		StringColorWrap('#report_near||' .. rpos, NumColor, row[2], CurColor(), '#report_entitites')
	end

	DPP.SimpleLog(color_white, '#report_solidpos')
	for i = 1, 4 do
		local row = data.positions_solid2[i]
		if not row then StringColorWrap('#report_nodata') break end

		local spos = string.Explode(' ', row[1])
		local rpos = tonumber(spos[1]) * 100 .. ' ' .. tonumber(spos[2]) * 100 .. ' ' .. tonumber(spos[3]) * 100

		StringColorWrap('#report_near||' .. rpos, NumColor, row[2], CurColor(), '#report_entitites')
	end

	DPP.SimpleLog(color_white, '#report_allclass')
	for i = 1, 4 do
		local row = data.classes2[i]
		if not row then StringColorWrap('#report_nodata') break end

		StringColorWrap('#Class', ClassColor, row[1], CurColor(), '#report_have', NumColor, row[2], CurColor(), '#report_espawned')
	end

	DPP.SimpleLog(color_white, '#report_solidclass')
	for i = 1, 4 do
		local row = data.classes_solid2[i]
		if not row then StringColorWrap('#report_nodata') break end

		StringColorWrap('#Class', ClassColor, row[1], CurColor(), '#report_have', NumColor, row[2], CurColor(), '#report_espawned')
	end

	DPP.SimpleLog(color_white, '#report_spawned_h')
	DPP.SimpleLog(color_white, '#report_allpos')

	for i = 1, 4 do
		local row = data.spositions2[i]
		if not row then StringColorWrap('#report_nodata') break end

		local spos = string.Explode(' ', row[1])
		local rpos = tonumber(spos[1]) * 100 .. ' ' .. tonumber(spos[2]) * 100 .. ' ' .. tonumber(spos[3]) * 100

		StringColorWrap('#report_near||' .. rpos, NumColor, row[2], CurColor(), '#report_entitites')
	end

	DPP.SimpleLog(color_white, '#report_solidpos')
	for i = 1, 4 do
		local row = data.spositions_solid2[i]
		if not row then StringColorWrap('#report_nodata') break end

		local spos = string.Explode(' ', row[1])
		local rpos = tonumber(spos[1]) * 100 .. ' ' .. tonumber(spos[2]) * 100 .. ' ' .. tonumber(spos[3]) * 100

		StringColorWrap('#report_near||' .. rpos, NumColor, row[2], CurColor(), '#report_entitites')
	end

	DPP.SimpleLog(color_white, '#report_allclass')
	for i = 1, 4 do
		local row = data.sclasses2[i]
		if not row then StringColorWrap('#report_nodata') break end

		StringColorWrap('#Class', ClassColor, row[1], CurColor(), '#report_have', NumColor, row[2], CurColor(), '#report_espawned')
	end

	DPP.SimpleLog(color_white, '#report_solidclass')
	for i = 1, 4 do
		local row = data.sclasses_solid2[i]
		if not row then StringColorWrap('#report_nodata') break end

		StringColorWrap('#Class', ClassColor, ' ' .. row[1], CurColor(), '#report_have', NumColor, row[2], CurColor(), '#report_espawned')
	end

	DPP.SimpleLog(color_white, '#report_misc')

	data.classes.env_shake = data.classes.env_shake or 0
	data.classes.npc_barnacle_tongue_tip = data.classes.npc_barnacle_tongue_tip or 0

	if data.classes.env_shake > 100 then
		StringColorWrap('#report_envshake||' .. data.classes.env_shake)
	end

	if data.classes.npc_barnacle_tongue_tip > 0 then
		StringColorWrap('There are ' .. data.classes.npc_barnacle_tongue_tip .. ' "barnacle tips" (tongue info entities).')
	end

	DPP.SimpleLog(color_white, '#report_generated||' .. math.floor(nt * 100) / 100)
	DPP.SimpleLog(color_white, '--------------------------------')
end
