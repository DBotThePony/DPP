
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

util.AddNetworkString('DPP.Lists')
util.AddNetworkString('DPP.RLists')
util.AddNetworkString('DPP.RLists_Player')
util.AddNetworkString('DPP.LLists')
util.AddNetworkString('DPP.MLLists')
util.AddNetworkString('DPP.SLists')
util.AddNetworkString('DPP.CLists')
util.AddNetworkString('DPP.WLists')
util.AddNetworkString('DPP.ListsInsert')
util.AddNetworkString('DPP.RListsInsert')
util.AddNetworkString('DPP.RListsInsert_Player')
util.AddNetworkString('DPP.LListsInsert')
util.AddNetworkString('DPP.MLListsInsert')
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
util.AddNetworkString('DPP.Echo')
util.AddNetworkString('DPP.Notify')
util.AddNetworkString('DPP.SetConVar')
util.AddNetworkString('DPP.PlayerList')
util.AddNetworkString('DPP.ConVarChanged')
util.AddNetworkString('properties_dpp')
util.AddNetworkString('DPP.LimitHit')

util.AddNetworkString('DPP.NetworkedConVar')
util.AddNetworkString('DPP.NetworkedConVarFull')

util.AddNetworkString('DPP.InspectEntity')

util.AddNetworkString('DPP.UpdateLang')

util.AddNetworkString('DPP.ResetBlockedModels')
util.AddNetworkString('DPP.ResetLimits')
util.AddNetworkString('DPP.ResetMLimits')
util.AddNetworkString('DPP.ResetSLimits')
util.AddNetworkString('DPP.ResetCLimits')
util.AddNetworkString('DPP.ResetBlockedList')
util.AddNetworkString('DPP.ResetExcludedList')
util.AddNetworkString('DPP.ResetRestrictions')

local Gray = Color(200, 200, 200)

hook.Add('DLib.NetworkedVarFull', 'DPP', function(ply, auto)
	DPP.BroadcastLists(ply)
	DPP.SendConVarsTo(ply)

	if not auto then
		DLib.SimpleLog(ply, Gray, '#net_auto')
	end
end)

hook.Add('DLib.PreNWSendVars', 'DPP', function(ply, data)
	data._DPP_Constrained = data._DPP_Constrained or {}
	net.WriteArray(data._DPP_Constrained)
end)

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

	for k, v in SortedPairs(DPP.Settings) do
		WriteEasy(v, DPP.GetConVar(k))
	end

	net.Send(ply)
end

function DPP.SendConstrained(ent)
	net.Start('DPP.ConstrainedTable')
	net.WriteTable({ent})
	net.WriteTable(DPP.GetConstrainedTable(ent))
	net.Broadcast()
end

