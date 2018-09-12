
--[[
Copyright (C) 2016-2017 DBot


-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

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

util.AddNetworkString('DPP.RefreshPlayerList')

util.AddNetworkString('DPP.ConstrainedTable')
util.AddNetworkString('DPP.SendConstrainedWith')

util.AddNetworkString('DPP.Log')
util.AddNetworkString('DPP.Echo')
util.AddNetworkString('DPP.Notify')
util.AddNetworkString('DPP.SetConVar')
util.AddNetworkString('DPP.PlayerList')
util.AddNetworkString('DPP.ConVarChanged')
util.AddNetworkString('properties_dpp')

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

util.AddNetworkString('DPP.CleanupTimer')

local Gray = Color(200, 200, 200)

hook.Add('DLib.NetworkedVarFull', 'DPP', function(ply, auto)
	DPP.BroadcastLists(ply)
	DPP.SendConVarsTo(ply)

	if not auto then
		DPP.SimpleLog(ply, Gray, '#net_auto')
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

