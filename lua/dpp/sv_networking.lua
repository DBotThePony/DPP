
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

util.AddNetworkString('DPP.ReloadFiendList')
util.AddNetworkString('DPP.RefreshPlayerList')

util.AddNetworkString('DPP.ConstrainedTable')
util.AddNetworkString('DPP.ReceiveFriendList')
util.AddNetworkString('DPP.SendConstrainedWith')

util.AddNetworkString('DPP.Log')
util.AddNetworkString('DPP.Notify')
util.AddNetworkString('DPP.SetConVar')
util.AddNetworkString('DPP.PlayerList')
util.AddNetworkString('DPP.ConVarChanged')
util.AddNetworkString('properties_dpp')

util.AddNetworkString('DPP.NetworkedConVar')
util.AddNetworkString('DPP.NetworkedConVarFull')
util.AddNetworkString('DPP.NetworkedVar')
util.AddNetworkString('DPP.NetworkedEntityVars')
util.AddNetworkString('DPP.NetworkedVarFull')
util.AddNetworkString('DPP.NetworkedRemove')

local entMeta = FindMetaTable('Entity')

function entMeta:SetDPPVar(var, val)
	var = var:lower()
	local uid = self:EntIndex()
	
	if uid > 0 then
		DPP.NETWORK_DB[uid] = DPP.NETWORK_DB[uid] or {}
		if val == nil then val = DPP.NetworkVars[var].default end
		DPP.NETWORK_DB[uid][var] = val
		
		net.Start('DPP.NetworkedVar')
		net.WriteUInt(DPP.NetworkVars[var].NetworkID, 6)
		net.WriteUInt(uid, 12) --4096 should be enough
		DPP.NetworkVars[var].send(val)
		net.Broadcast()
		
		self.__DPP_Vars_Save = DPP.NETWORK_DB[uid]
	else
		self.DPPVars = self.DPPVars or {}
		self.DPPVars[var] = val
	end
	
	hook.Run('DPP_EntityVarsChanges', self, var, val)
end

local Clients = {}

local function SendTo(ply, tosend)
	if not IsValid(ply) then
		Clients[ply] = nil
		return
	end
	
	local uid = table.remove(tosend)
	if not uid then
		Clients[ply] = nil
		return
	end
	
	local data = DPP.NETWORK_DB[uid]
	if not data then return end --???
	
	net.Start('DPP.NetworkedEntityVars')
	net.WriteUInt(uid, 12) --4096 should be enough
	net.WriteUInt(table.Count(data), 6) --Quite bigger than max number of vars
	
	for var, val in pairs(data) do
		net.WriteUInt(DPP.NetworkVars[var].NetworkID, 6)
		DPP.NetworkVars[var].send(val)
	end
	
	net.Send(ply)
end

local RED = Color(200, 100, 100)

local function NetworkError(Message)
	DPP.SimpleLog(RED, 'Oh no! Something went terribly wrong! i am unable to send data to client. The error message follows:')
	DPP.SimpleLog(RED, Message)
	DPP.SimpleLog(RED, debug.traceback())
	DPP.SimpleLog(RED, 'If you thinks this is DPP problem, report on BitBucket and tell how did you got this.')
end

local function SendTimer()
	for ply, tosend in pairs(Clients) do
		xpcall(SendTo, NetworkError, ply, tosend)
	end
end

local Gray = Color(200, 200, 200)

local function NetworkedVarFull(len, ply, auto)
	ply.DPP_NetowrkingFullLast = ply.DPP_NetowrkingFullLast or 0
	if ply.DPP_NetowrkingFullLast > CurTime() then return false end
	ply.DPP_NetowrkingFullLast = CurTime() + 60
	
	DPP.BroadcastLists(ply)
	DPP.SendConVarsTo(ply)
	
	if not auto then
		DPP.SimpleLog(ply, Gray, ' Requested full network update automatically')
	end
	
	local reply = {}
	
	for uid, data in pairs(DPP.NETWORK_DB) do
		table.insert(reply, uid)
	end
	
	Clients[ply] = reply
	return true
end

local function EntityRemoved(ent)
	local euid = ent:EntIndex()
	
	for ply, tosend in pairs(Clients) do
		for i, uid in pairs(tosend) do
			if uid == euid then
				tosend[i] = nil
				break
			end
		end
	end
	
	DPP.NETWORK_DB[euid] = nil
	net.Start('DPP.NetworkedRemove')
	net.WriteUInt(euid, 12) --4096 should be enough
	net.Broadcast()
end

local function command(ply)
	if not IsValid(ply) then DPP.Message('Are you serious?') return end
	
	local reply = NetworkedVarFull(nil, ply, true)
	
	if not reply then
		DPP.Notify(ply, 'You must wait before requesting full network pocket again!')
	else
		DPP.Notify(ply, 'Accepted.')
		DPP.SimpleLog(ply, Gray, ' Requested full network update manually')
	end
end

local function WriteEasy(data, val)
	if data.bool then
		net.WriteBool(val)
	elseif data.int then
		net.WriteInt(val, 32)
	elseif data.float then
		net.WriteFloat(val)
	else
		net.WriteString(val)
	end
end

function DPP.NetworkConVarToClient(ply, var)
	local val = DPP.GetConVar(var)
	local data = DPP.Settings[var]
	
	net.Start('DPP.NetworkedConVar')
	net.WriteUInt(data.NetworkID, 12)
	
	WriteEasy(data, val)
	
	net.Send(ply)
end

function DPP.SendConVarsTo(ply)
	ply = ply or player.GetAll()
	
	net.Start('DPP.NetworkedConVarFull')
	
	for k, v in pairs(DPP.Settings) do
		WriteEasy(v, DPP.GetConVar(k))
	end
	
	net.Send(ply)
end

hook.Add('EntityRemoved', 'DPP.Networking', EntityRemoved)
net.Receive('DPP.NetworkedVarFull', NetworkedVarFull)
timer.Create('DPP.NetworkedVarFull', 0.1, 0, SendTimer)
concommand.Add('dpp_requestnetupdate', command)
