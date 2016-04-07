
--Server

include('sv_functions.lua')

DPP.PropListing = DPP.PropListing or {}

util.AddNetworkString('DPP.Log')
util.AddNetworkString('DPP.Lists')
util.AddNetworkString('DPP.RLists')
util.AddNetworkString('DPP.LLists')
util.AddNetworkString('DPP.SLists')
util.AddNetworkString('DPP.ListsInsert')
util.AddNetworkString('DPP.RListsInsert')
util.AddNetworkString('DPP.LListsInsert')
util.AddNetworkString('DPP.SListsInsert')
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

--[[
--They are useless because we replicate
function DPP.BroadcastCVars()
	for var in pairs(DPP.Settings) do
		DPP.BroadcastCVar(var)
	end
end

--They are useless because we replicate
function DPP.BroadcastCVar(var)
	local v = DPP.Settings[var]
	local Var = DPP.SVars[var]
	if not v then return end
	
	if v.type == 'bool' then
		SetGlobalBool('DPP.Vars.' .. var, Var:GetBool())
	elseif v.type == 'int' then
		SetGlobalInt('DPP.Vars.' .. var, Var:GetInt())
	elseif v.type == 'float' then
		SetGlobalFloat('DPP.Vars.' .. var, Var:GetFloat())
	end
end
]]

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
	
	DPP.SaveCVars()
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

function DPP.SetOwner(ent, ply)
	if ent:IsConstraint() then return end --Constraint can't have an owner
	local old = DPP.GetOwner(ent)
	ent:SetNWEntity('DPP.Owner', ply)
	
	if IsValid(ply) then
		ply.DPP_Ents = ply.DPP_Ents or {}
		
		ply.DPP_Ents[ent] = true
		
		ent:SetNWBool('DPP.IsOwned', true)
		ent:SetNWString('DPP.OwnerString', ply:Nick())
		ent:SetNWInt('DPP.OwnerUID', ply:UniqueID())
		ent:SetNWString('DPP.OwnerSteamID', ply:SteamID())
		DPP.PropListing[ent] = true
	else
		ent:SetNWBool('DPP.IsOwned', false)
		ent:SetNWString('DPP.OwnerString', 'World')
		ent:SetNWInt('DPP.OwnerUID', 0)
		ent:SetNWString('DPP.OwnerSteamID', '')
		DPP.PropListing[ent] = nil
	end
	
	if IsValid(old) then
		old.DPP_Ents = old.DPP_Ents or {}
		old.DPP_Ents[ent] = true
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

function DPP.DoEcho(...)
	DPP.Message(...)
	local admins = {}
	
	for k, v in pairs(player.GetAll()) do
		if v:IsAdmin() then
			table.insert(admins, v)
		end
	end
	
	net.Start('DPP.Log')
	net.WriteTable({...})
	net.Send(admins)
end

local function PlayerInitialSpawn(ply)
	timer.Simple(2, function()
		if not IsValid(ply) then return end
		DPP.FindPlayerProps(ply)
		net.Start('DPP.ReloadFiendList')
		net.Broadcast()
		
		net.Start('DPP.RefreshPlayerList')
		net.Broadcast()
	end)
	
	timer.Simple(10, function()
		DPP.BroadcastLists()
		--DPP.BroadcastCVars()
		DPP.ReBroadcastCVars()
	end)
end

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
	
	local Ents = table.Copy(DPP.GetPlayerEntities(ply))
	
	if clear then
		if isAdmin and clearAdmin or not isAdmin then
			timer.Create('DPP.ClearPlayer.' .. uid, DPP.GetConVar('clear_timer'), 1, function()
				local ply = player.GetByUniqueID(uid)
				if ply then return end
				
				for k, v in pairs(Ents) do
					if not IsValid(v) then continue end
					if IsValid(DPP.GetOwner(v)) then continue end
					SafeRemoveEntity(v)
				end
				
				DPP.Notify(player.GetAll(), name .. '\'s props has been cleaned up', 2)
				DPP.Message(name .. '\'s props has been cleaned up')
			end)
		end
	end
	
	if grab then
		if isAdmin and grabAdmin or not isAdmin then
			timer.Create('DPP.GrabsPlayer.' .. uid, DPP.GetConVar('grabs_timer'), 1, function()
				local ply = player.GetByUniqueID(uid)
				if ply then return end
				
				for k, v in pairs(Ents) do
					if not IsValid(v) then continue end
					if IsValid(DPP.GetOwner(v)) then continue end
					DPP.SetUpForGrabs(v, true)
				end
				
				DPP.Notify(player.GetAll(), name .. '\'s props is now up for grabs!')
				DPP.Message(name .. '\'s props is now up for grabs!')
			end)
		end
	end
	
	timer.Simple(2, function()
		net.Start('DPP.RefreshPlayerList')
		net.Broadcast()
	end)
end

local EmptyVector = Vector(0, 0, 0)

function DPP.HandleTakeDamage(ent, dmg)
	if ent:IsPlayer() then return end
	local a = dmg:GetAttacker()
	if not a:IsPlayer() then return end
	
	local reply = DPP.CanDamage(a, ent)
	
	if reply == false then
		dmg:SetDamage(0)
		dmg:SetDamageForce(EmptyVector)
		dmg:SetDamageBonus(0)
		dmg:SetDamageType(0)
		local isOnFire = ent:IsOnFire()
		
		timer.Simple(0.5, function()
			if IsValid(ent) and not isOnFire then
				ent:Extinguish() --Prevent burning weapons
			end
		end)
		
		return false
	end
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
hook.Add('EntityTakeDamage', 'DPP.Hooks', DPP.HandleTakeDamage, -2)

include('sv_hooks.lua')
include('sv_misc.lua')
