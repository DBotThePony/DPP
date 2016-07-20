
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

--Server

AddCSLuaFile('sh_init.lua')
AddCSLuaFile('sh_cppi.lua')
AddCSLuaFile('sh_functions.lua')
AddCSLuaFile('sh_hooks.lua')
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('cl_settings.lua')

include('sv_fpp_comp.lua')
include('sv_functions.lua')

DPP.PropListing = DPP.PropListing or {}
DPP.ConstraintsListing = DPP.ConstraintsListing or {}

util.AddNetworkString('DPP.Log')
util.AddNetworkString('DPP.Lists')
util.AddNetworkString('DPP.RLists')
util.AddNetworkString('DPP.LLists')
util.AddNetworkString('DPP.SLists')
util.AddNetworkString('DPP.CLists')
util.AddNetworkString('DPP.WLists')
util.AddNetworkString('DPP.ListsInsert')
util.AddNetworkString('DPP.RListsInsert')
util.AddNetworkString('DPP.LListsInsert')
util.AddNetworkString('DPP.SListsInsert')
util.AddNetworkString('DPP.CListsInsert')
util.AddNetworkString('DPP.WListsInsert')
util.AddNetworkString('DPP.ModelsInsert')
util.AddNetworkString('DPP.ModelLists')
util.AddNetworkString('DPP.Notify')
util.AddNetworkString('DPP.ReloadFiendList')
util.AddNetworkString('DPP.RefreshConVarList')
util.AddNetworkString('DPP.RefreshPlayerList')
util.AddNetworkString('DPP.SetConVar')
util.AddNetworkString('DPP.ConstrainedTable')
util.AddNetworkString('DPP.ReceiveFriendList')
util.AddNetworkString('DPP.SendConstrainedWith')
util.AddNetworkString('DPP.PlayerList')

util.AddNetworkString('DPP.ConVarChanged')
util.AddNetworkString('properties_dpp')

resource.AddWorkshop('659044893')

function DPP.Notify(ply, message, type)
	if istable(ply) or IsValid(ply) then
		net.Start('DPP.Notify')
		net.WriteTable(istable(message) and message or {message})
		net.WriteUInt(type or 0, 6)
		net.Send(ply)
	else
		DPP.Message(message)
	end
end

function DPP.ReBroadcastCVars()
	for k, v in pairs(DPP.SVars) do
		SetGlobalString('DPP.' .. k, v:GetString())
	end
end

timer.Create('DPP.ReBroadcastCVars', 30, 0, DPP.ReBroadcastCVars)

function DPP.ConVarChanged(var, old, new)
	net.Start('DPP.RefreshConVarList')
	net.WriteString(var)
	net.Broadcast()
	
	--local var = string.sub(var, 5)
	--DPP.BroadcastCVar(var)
	
	if not DPP.IGNORE_CVAR_SAVE then
		DPP.SaveCVars()
	end
	
	DPP.ReBroadcastCVars()
end

function DPP.RefreshPropList()
	for k, v in pairs(DPP.PropListing) do
		if not IsValid(k) then
			DPP.PropListing[k] = nil
			continue
		end
		
		if not DPP.IsOwned(k) then
			DPP.PropListing[k] = nil
			continue
		end
	end
end

local Constraints = {
	gmod_winch_controller = true,
	phys_torque = true,
	phys_spring = true,
	logic_collision_pair = true,
	keyframe_rope = true, --ugh
}

function DPP.IsConstraint(ent)
	return ent:IsConstraint() or Constraints[ent:GetClass()]
end

function DPP.GetConstrainedEntities(ent)
	if ent.GetConstrainedEntities then
		local a, b = ent:GetConstrainedEntities()
		if a or b then return a, b end
	end
	
	return ent.Ent1 or NULL, ent.Ent2 or NULL
end

local ConstraintTypes = {
	phys_constraint = 'weld',
	phys_slideconstraint = 'slider',
	phys_spring = 'elastic',
	phys_lengthconstraint = 'rope',
	keyframe_rope = 'vrope', --ugh
	phys_hinge = 'axis',
	phys_torque = 'motor',
	phys_ballsocket = 'ballsocket',
}

function DPP.GetContstrainType(ent)
	local class = ent:GetClass()
	
	if class == 'gmod_winch_controller' then
		return ent.type == TYPE_NORMAL and 'winch' or 'muscule'
	end
	
	return ConstraintTypes[class] or '<unknown>'
end

function DPP.SetOwner(ent, ply)
	--if ent:IsConstraint() then return end --Constraint can't have an owner
	local old = DPP.GetOwner(ent)
	ent:SetNWEntity('DPP.Owner', ply)
	
	local isConst = DPP.IsConstraint(ent)
	
	if IsValid(ply) then
		ply.DPP_Ents = ply.DPP_Ents or {}
		
		ply.DPP_Ents[ent] = true
		
		ent:SetNWBool('DPP.IsOwned', true)
		ent:SetNWString('DPP.OwnerString', ply:Nick())
		ent:SetNWInt('DPP.OwnerUID', ply:UniqueID())
		ent:SetNWString('DPP.OwnerSteamID', ply:SteamID())
		if isConst then
			DPP.ConstraintsListing[ent] = true
		end
		DPP.PropListing[ent] = true
	else
		ent:SetNWBool('DPP.IsOwned', false)
		ent:SetNWString('DPP.OwnerString', 'World')
		ent:SetNWInt('DPP.OwnerUID', 0)
		ent:SetNWString('DPP.OwnerSteamID', '')
		DPP.PropListing[ent] = nil
		DPP.ConstraintsListing[ent] = nil
	end
	
	if IsValid(old) then
		old.DPP_Ents = old.DPP_Ents or {}
		old.DPP_Ents[ent] = nil
	end
end

concommand.Add('dpp_setvar', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] then DPP.Notify(ply, 'Invalid argument') return end
	if not args[2] then DPP.Notify(ply, 'Invalid argument') return end
	RunConsoleCommand('dpp_' .. args[1], args[2])
end)

function DPP.GetFriendTable(ply)
	return ply.DPP_Friends or {}
end

function DPP.RecalculateCPPIFriendTable(ply)
	local tab = DPP.GetFriendTable(ply)
	local reply = {}
	for k, v in pairs(tab) do
		table.insert(reply, k)
	end
	ply.DPP_FriendsCPPI = reply
	return reply
end

function DPP.GetFriendTableCPPI(ply)
	return ply.DPP_FriendsCPPI or {}
end

--Don't overflow net channel when player pastes a big dupe
local Queued = {}

local function Think()
	for k, v in pairs(Queued) do
		DPP.Message(unpack(v))
		local admins = {}
		
		for k, v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				table.insert(admins, v)
			end
		end
		
		net.Start('DPP.Log')
		net.WriteTable(v)
		net.Send(admins)
		
		Queued[k] = nil
		
		break
	end
end

hook.Add('Think', 'DPP.NetEchoThink', Think)

function DPP.DoEcho(...)
	local repack = DPP.Format(...)
	
	if not DLog then
		table.insert(Queued, repack)
	else
		DLog.Log('DPP', 1, repack)
	end
end

function DPP.NotifyLog(t)
	t = DPP.Format(unpack(t))
	DPP.Notify(player.GetAll(), t)
	
	if not DLog then
		DPP.Message(t)
		DPP.LogIntoFile(unpack(t))
		return
	end
	DLog.Log('DPP', 1, t, {Private = false, PrintClient = false})
end

local function PlayerInitialSpawn(ply)
	timer.Simple(2, function()
		if not IsValid(ply) then return end
		DPP.FindPlayerProps(ply)
		net.Start('DPP.ReloadFiendList')
		net.Broadcast()
		
		--Still would call twice rebuilding player list on client
		net.Start('DPP.RefreshPlayerList')
		net.Broadcast()
		
		DPP.RecalculatePlayerList()
		DPP.SendPlayerList()
	end)
	
	timer.Simple(10, function()
		DPP.BroadcastLists()
		DPP.ReBroadcastCVars()
	end)
end

local File
local CurrentPatch

local function ConcatSafe(tab)
	local str = ''
	
	for k, v in ipairs(tab) do
		if type(v) == 'string' then str = str .. v end
	end
	
	return str
end

function DPP.LogIntoFile(...)
	if not DPP.GetConVar('log_file') then return end
	
	if not File then
		File = file.Open('dpp/' .. os.date('%d_%m_%y') .. '.txt', 'ab', 'DATA')
	end
	
	local str = ''
	
	for k, v in ipairs{...} do
		if type(v) == 'Player' then
			str = str .. ConcatSafe(DPP.FormatPlayer(v))
		end
		
		if type(v) == 'string' then
			str = str .. v
		end
		
		if type(v) == 'table' then
			if v.type == 'Spacing' then
				str = str .. string.rep(' ', v.length - #str)
			end
		end
	end
	
	File:Write(str .. '\n')
end

function DPP.SimpleLog(...)
	DPP.DoEcho(...)
	DPP.LogIntoFile(...)
end

function DPP.RefreshLogFile()
	local neededPath = 'dpp/log_' .. os.date('%d_%m_%y') .. '.txt'
	
	if neededPath ~= CurrentPatch then
		if File then
			File:Flush()
			File:Close()
		end
		
		CurrentPatch = neededPath
		File = file.Open(neededPath, 'ab', 'DATA')
	end
	
	if not File then return end
	File:Flush()
end

timer.Create('DPP.RefreshLogFile', 10, 0, DPP.RefreshLogFile)
timer.Simple(0, DPP.RefreshLogFile)

function DPP.PlayerDisconnected(ply)
	if DPP.GetConVar('disconnected_freeze') then
		for k, v in pairs(DPP.GetPlayerEntities(ply)) do
			local phys = v:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
		end
	end
	
	local clear, clearAdmin, isAdmin = DPP.GetConVar('clear_disconnected'), DPP.GetConVar('clear_disconnected_admin'), ply:IsAdmin()
	local grab, grabAdmin = DPP.GetConVar('grabs_disconnected'), DPP.GetConVar('grabs_disconnected_admin')
	
	local uid = ply:UniqueID()
	local name = ply:Nick()
	
	local props = DPP.GetPropsByUID(uid)
	if #props == 0 then return end
	
	timer.Simple(2, function()
		for k, v in pairs(DPP.GetPropsByUID(uid)) do
			DPP.RecalcConstraints(v)
		end
	end)
	
	if clear then
		if isAdmin and clearAdmin or not isAdmin then
			timer.Create('DPP.ClearPlayer.' .. uid, DPP.GetConVar('clear_timer'), 1, function()
				local ply = player.GetByUniqueID(uid)
				if ply then return end
				
				for k, v in pairs(DPP.GetPropsByUID(uid)) do
					SafeRemoveEntity(v)
				end
				
				if not DPP.GetConVar('no_clear_messages') then
					DPP.Notify(player.GetAll(), name .. '\'s props has been cleaned up', 2)
				end
				
				DPP.Message(name .. '\'s props has been cleaned up')
				
				DPP.RecalculatePlayerList()
				DPP.SendPlayerList()
			end)
		end
	end
	
	if grab then
		if isAdmin and grabAdmin or not isAdmin then
			timer.Create('DPP.GrabsPlayer.' .. uid, DPP.GetConVar('grabs_timer'), 1, function()
				local ply = player.GetByUniqueID(uid)
				if ply then return end
				
				for k, v in pairs(DPP.GetPropsByUID(uid)) do
					DPP.SetUpForGrabs(v, true)
				end
				
				if not DPP.GetConVar('no_clear_messages') then
					DPP.Notify(player.GetAll(), name .. '\'s props is now up for grabs!')
				end
				
				DPP.Message(name .. '\'s props is now up for grabs!')
				
				DPP.RecalculatePlayerList()
				DPP.SendPlayerList()
			end)
		end
	end
	
	if DPP.GetConVar('freeze_on_disconnect') then
		DPP.FreezePlayerEntities(ply)
	end
	
	timer.Simple(2, function()
		net.Start('DPP.RefreshPlayerList')
		net.Broadcast()
	end)
end

net.Receive('DPP.ReloadFiendList', function(len, ply)
	ply.DPP_Friends = net.ReadTable()
	DPP.RecalculateCPPIFriendTable(ply)
	hook.Run('CPPIFriendsChanged', ply, DPP.GetFriendTableCPPI(ply))
	
	net.Start('DPP.ReceiveFriendList')
	net.WriteEntity(ply)
	net.WriteTable(ply.DPP_Friends)
	net.Broadcast()
end)

net.Receive('DPP.SetConVar', function(len, ply)
	if not ply:IsSuperAdmin() then return end
	local c = net.ReadString()
	local new = net.ReadString()
	RunConsoleCommand('dpp_' .. c, new)
end)

hook.Add('PlayerInitialSpawn', 'DPP.Hooks', PlayerInitialSpawn)
hook.Add('PlayerDisconnected', 'DPP.Hooks', DPP.PlayerDisconnected)

net.Receive('DPP.ConVarChanged', function(len, ply)
	local var = net.ReadString()
	if not DPP.CSettings[var] then return end
	DPP.PlayerConVar(ply, var) --Enough to rebroadcast cvar
end)

include('sv_hooks.lua')
include('sv_commands.lua')
include('sv_misc.lua')
