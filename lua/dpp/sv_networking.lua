
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
util.AddNetworkString('DPP.RefreshConVarList')
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

util.AddNetworkString('DPP.NetworkedVar')
util.AddNetworkString('DPP.NetworkedEntityVars')
util.AddNetworkString('DPP.NetworkedVarFull')

local entMeta = FindMetaTable('Entity')

function entMeta:SetDPPVar(var, val)
	var = var:lower()
	local uid = self:EntIndex()
	DPP.NETWORK_DB[uid] = DPP.NETWORK_DB[uid] or {}
	if val == nil then val = DPP.NetworkVars[var].default end
	DPP.NETWORK_DB[uid][var] = val
	
	net.Start('DPP.NetworkedVar')
	net.WriteUInt(DPP.NetworkVars[var].NetworkID, 5)
	net.WriteUInt(uid, 12) --4096 should be enough
	DPP.NetworkVars[var].send(val)
	net.Broadcast()
end

local Clients = {}

local function SendTimer()
	for ply, tosend in pairs(Clients) do
		if not IsValid(ply) then
			Clients[ply] = nil
			continue
		end
		
		local uid = table.remove(tosend)
		
		local data = DPP.NETWORK_DB[uid]
		if not data then return end --???
		
		net.Start('DPP.NetworkedEntityVars')
		net.WriteUInt(uid, 12) --4096 should be enough
		net.WriteUInt(table.Count(data), 6) --Quite bigger than max number of vars
		
		for var, val in pairs(data) do
			net.WriteUInt(DPP.NetworkVars[var].NetworkID, 5)
			DPP.NetworkVars[var].send(val)
		end
		
		net.Send(ply)
	end
end

local function NetworkedVarFull(len, ply)
	ply.DPP_NetowrkingFullLast = ply.DPP_NetowrkingFullLast or 0
	if ply.DPP_NetowrkingFullLast > CurTime() then return end
	ply.DPP_NetowrkingFullLast = CurTime() + 60
	
	local reply = {}
	
	for uid, data in pairs(DPP.NETWORK_DB) do
		table.insert(reply, uid)
	end
	
	Clients[ply] = reply
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
end

hook.Add('EntityRemoved', 'DPP.NetworkedVarFull', EntityRemoved)
net.Receive('DPP.NetworkedVarFull', NetworkedVarFull)
timer.Create('DPP.NetworkedVarFull', 0.1, 0, SendTimer)
