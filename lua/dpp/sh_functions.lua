
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

function DPP.GetGhosted(ent)
	return ent:DPPVar('IsGhosted')
end

DPP.IsGhosted = DPP.GetGhosted

function DPP.IsOwned(ent)
	if not IsValid(ent) then return false end
	return ent:DPPVar('IsOwned')
end

function DPP.IsUpForGrabs(ent)
	return ent:DPPVar('IsUpForGraps')
end

function DPP.GetOwnerDetails(ent)
	return ent:DPPVar('OwnerString', 'World'),
		ent:DPPVar('OwnerUID', 0),
		ent:DPPVar('OwnerSteamID', '')
end

function DPP.GetConstrainedTable(ent)
	ent._DPP_Constrained = ent._DPP_Constrained or {}
	return ent._DPP_Constrained
end

function DPP.IsShared(ent)
	return ent:DPPVar('IsShared')
end

function DPP.IsSharedType(ent, mode)
	return ent:DPPVar('share' .. mode)
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

local function HasValueLight(arr, val)
	for k, v in ipairs(arr) do
		if v == val then return true end
	end
	
	return false
end

function DPP.GetGroups()
	local reply = {'user', 'admin', 'superadmin'}
	local groups = CAMI.GetUsergroups()

	for k, v in pairs(groups) do
		if HasValueLight(reply, k) then continue end
		table.insert(reply, k)
	end

	return reply
end

--I don't remember why i have IsBlockedModel and IsModelBlocked x.x
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

function DPP.IsModelBlocked(model, ply, nonotify)
	if not DPP.GetConVar('enable_blocked') then return false end
	if not DPP.GetConVar('model_blacklist') then return false end
	local white = DPP.GetConVar('model_whitelist')
	local status = DPP.BlockedModels[model] ~= nil

	if white then status = not status end

	if SERVER and not nonotify and status and IsValid(ply) then
		DPP.Notify(ply, 'Model of that entity is in the black list!', 1)
	end

	return status
end

function DPP.IsModelEvenBlocked(model)
	return DPP.BlockedModels[model] ~= nil
end

function DPP.GetIsProtectionDisabledByServer(ply, mode)
	return ply:DPPVar('DisablePP.' .. mode)
end

function DPP.GetIsProtectionDisabledByPlayer(ply, mode)
	return DPP.PlayerConVar(ply, 'disable_' .. mode .. '_protection')
end

function DPP.IsProtectionDisabledFor(ply, mode)
	return DPP.GetIsProtectionDisabledByPlayer(ply, mode) or DPP.GetIsProtectionDisabledByServer(ply, mode)
end

DPP.Helpers = DPP.Helpers or {}

function DPP.Helpers.CreateArrayFromLines(arr, id)
	local reply = {}
	
	for k, v in ipairs(arr) do
		table.insert(reply, v:GetValue(id))
	end
	
	return reply
end

function DPP.Helpers.ForEachCommand(arr, command)
	for k, v in ipairs(arr) do
		DPP.QueueCommand(command, v)
	end
end

function DPP.Helpers.ForEachExecute(arr, func)
	for k, v in ipairs(arr) do
		DPP.QueueFunction(func, v)
	end
end

function DPP.Helpers.ForEachExecuteNow(arr, func)
	for k, v in ipairs(arr) do
		func(v)
	end
end

function DPP.Helpers.CompactSelectedCommand(arr, id, command)
	DPP.Helpers.ForEachCommand(DPP.Helpers.CreateArrayFromLines(arr, id), command)
end

function DPP.Helpers.CompactSelectedExecute(arr, id, func)
	DPP.Helpers.ForEachExecute(DPP.Helpers.CreateArrayFromLines(arr, id), func)
end

DPP.QueuedCommands = DPP.QueuedCommands or {}
DPP.QueuedFuncs = DPP.QueuedFuncs or {}

function DPP.QueueCommand(command, ...)
	table.insert(DPP.QueuedCommands, {command, ...})
end

function DPP.QueueFunction(func, ...)
	table.insert(DPP.QueuedFuncs, {func, ...})
end

local function CommandTimer()
	local next = table.remove(DPP.QueuedCommands, 1)
	if not next then return end
	RunConsoleCommand('dpp_' .. next[1], unpack(next, 2, #next))
end

local function FuncTimer()
	local next = table.remove(DPP.QueuedFuncs, 1)
	if not next then return end
	pcall(next[1], unpack(next, 2, #next))
end

timer.Create('DPP.QueueCommand', 0.2, 0, CommandTimer)
timer.Create('DPP.QueueFunction', 0.2, 0, FuncTimer)
