
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

hook.Add('DLib.PreNWReceiveVars', 'DPP', function(uid, nwdata)
	nwdata._DPP_Constrained = net.ReadArray()
end)

local function GetConVarByNetworkID(id)
	for k, v in pairs(DPP.Settings) do
		if v.NetworkID == id then return v, k end
	end
end

local function ReadEasy(data)
	if data.bool then
		return net.ReadBool()
	elseif data.int then
		return net.ReadInt(32)
	elseif data.float then
		return net.ReadFloat()
	else
		return net.ReadString()
	end
end

local function ConVarReceived()
	local netID = net.ReadUInt(12)
	local var, key = GetConVarByNetworkID(netID)
	if not var then DPP.ThrowError('Unknown ConVar Network ID! ' .. netID, 1, true) end

	DPP.NetworkedConVarsDB[key] = ReadEasy(var)
end

local function ConVarReceivedFull()
	for k, v in SortedPairs(DPP.Settings) do
		DPP.NetworkedConVarsDB[k] = ReadEasy(v)
	end
end

local function ReadInvertedTable()
	local reply = {}
	local read = DPP.ReadStringList()

	for k, v in ipairs(read) do
		reply[v] = true
	end

	return reply
end

local function ReadGenericLimits()
	local reply = {}

	local count = net.ReadUInt(16)

	for i = 1, count do
		local name = net.ReadString()
		reply[name] = {}

		local groups = net.ReadUInt(8)

		for i2 = 1, groups do
			local group = net.ReadString()
			local isNegative = net.ReadBool()
			local value = net.ReadUInt(16)

			if isNegative then
				value = -value
			end

			reply[name][group] = value
		end
	end

	return reply
end

local function ReadRestrictions()
	local reply = {}

	local count = net.ReadUInt(16)

	for i = 1, count do
		local class = net.ReadString()
		reply[class] = {}
		reply[class].groups = {}

		local groups = net.ReadUInt(8)

		for i2 = 1, groups do
			table.insert(reply[class].groups, net.ReadString())
		end

		reply[class].iswhite = net.ReadBool()
	end

	return reply
end

DPP.ClientReceiveFuncs = {
	-- Full update functions

	Lists = function()
		local str = net.ReadString()
		DPP.BlockedEntities[str] = ReadInvertedTable()
		hook.Run('DPP.BlockedEntitiesReloaded', str, DPP.BlockedEntities[str])
	end,

	ResetBlockedList = function()
		local str = net.ReadString()
		DPP.BlockedEntities[str] = {}
		hook.Run('DPP.BlockedEntitiesReloaded', str, DPP.BlockedEntities[str])
	end,

	RLists = function()
		local str = net.ReadString()
		DPP.RestrictedTypes[str] = ReadRestrictions()
		hook.Run('DPP.RestrictedTypesReloaded', str, DPP.RestrictedTypes[str])
	end,

	ResetRestrictions = function()
		local str = net.ReadString()
		DPP.RestrictedTypes[str] = {}
		hook.Run('DPP.RestrictedTypesReloaded', str, DPP.RestrictedTypes[str])
	end,

	WLists = function()
		local str = net.ReadString()
		DPP.WhitelistedEntities[str] = ReadInvertedTable()
		hook.Run('DPP.WhitelistedEntitiesReloaded', str, DPP.WhitelistedEntities[str])
	end,

	ResetExcludedList = function()
		local str = net.ReadString()
		DPP.WhitelistedEntities[str] = {}
		hook.Run('DPP.WhitelistedEntitiesReloaded', str, DPP.WhitelistedEntities[str])
	end,

	ModelLists = function()
		DPP.BlockedModels = ReadInvertedTable()
		hook.Run('DPP.BlockedModelListReloaded', DPP.BlockedModels)
	end,

	ResetBlockedModels = function()
		DPP.BlockedModels = {}
		hook.Run('DPP.BlockedModelListReloaded', DPP.BlockedModels)
	end,

	LLists = function()
		DPP.EntsLimits = ReadGenericLimits()
		hook.Run('DPP.EntsLimitsReloaded', DPP.EntsLimits)
	end,

	ResetLimits = function()
		DPP.EntsLimits = {}
		hook.Run('DPP.EntsLimitsReloaded', DPP.EntsLimits)
	end,

	MLLists = function()
		DPP.ModelsLimits = ReadGenericLimits()
		hook.Run('DPP.ModelsLimitsReloaded', DPP.EntsLimits)
	end,

	ResetMLimits = function()
		DPP.ModelsLimits = {}
		hook.Run('DPP.ModelsLimitsReloaded', DPP.EntsLimits)
	end,

	SLists = function()
		DPP.SBoxLimits = ReadGenericLimits()
		hook.Run('DPP.EntsLimitsReloaded', DPP.SBoxLimits)
	end,

	ResetSLimits = function()
		DPP.SBoxLimits = {}
		hook.Run('DPP.EntsLimitsReloaded', DPP.SBoxLimits)
	end,

	CLists = function()
		DPP.ConstrainsLimits = ReadGenericLimits()
		hook.Run('DPP.ConstrainsLimitsReloaded', DPP.ConstrainsLimits)
	end,

	ResetCLimits = function()
		DPP.ConstrainsLimits = {}
		hook.Run('DPP.ConstrainsLimitsReloaded', DPP.ConstrainsLimits)
	end,

	-- Insert receive functions

	ListsInsert = function()
		local s1, s2, b = net.ReadString(), net.ReadString(), net.ReadBool()

		if b then
			DPP.BlockedEntities[s1][s2] = b
		else
			DPP.BlockedEntities[s1][s2] = nil
		end

		hook.Run('DPP.BlockedEntitiesChanged', s1, s2, b)
	end,

	WListsInsert = function()
		local s1, s2, b = net.ReadString(), net.ReadString(), net.ReadBool()

		if b then
			DPP.WhitelistedEntities[s1][s2] = b
		else
			DPP.WhitelistedEntities[s1][s2] = nil
		end

		hook.Run('DPP.WhitelistedEntitiesChanged', s1, s2, b)
	end,

	RListsInsert = function()
		local s1, s2, b = net.ReadString(), net.ReadString(), net.ReadBool()

		if b then
			DPP.RestrictedTypes[s1][s2] = {
				groups = net.ReadTable(),
				iswhite = net.ReadBool()
			}
		else
			DPP.RestrictedTypes[s1][s2] = nil
		end

		hook.Run('DPP.RestrictedTypesUpdated', s1, s2, b)
	end,

	LListsInsert = function()
		local s1 = net.ReadString()
		DPP.EntsLimits[s1] = net.ReadTable()

		hook.Run('DPP.EntsLimitsUpdated', s1)
	end,

	MLListsInsert = function()
		local s1 = net.ReadString()
		DPP.ModelsLimits[s1] = net.ReadTable()

		hook.Run('DPP.ModelsLimitsUpdated', s1)
	end,

	SListsInsert = function()
		local s1 = net.ReadString()
		DPP.SBoxLimits[s1] = net.ReadTable()

		hook.Run('DPP.SBoxLimitsUpdated', s1)
	end,

	CListsInsert = function()
		local s1 = net.ReadString()
		DPP.ConstrainsLimits[s1] = net.ReadTable()

		hook.Run('DPP.ConstrainsLimitsUpdated', s1)
	end,

	ModelsInsert = function()
		local s, b = net.ReadString(), net.ReadBool()

		if b then
			DPP.BlockedModels[s] = b
		else
			DPP.BlockedModels[s] = nil
		end

		hook.Run('DPP.BlockedModelListChanged', s, b)
	end,

	RListsInsert_Player = function()
		local k = net.ReadString()
		local steamid = net.ReadString()
		local class = net.ReadString()
		local status = net.ReadBool()
		DPP.RestrictedTypes_SteamID[k][steamid] = DPP.RestrictedTypes_SteamID[k][steamid] or {}

		if status then
			table.insert(DPP.RestrictedTypes_SteamID[k][steamid], class)
		else
			DPP.PopFromArray(DPP.RestrictedTypes_SteamID[k][steamid], class)
		end

		hook.Run('DPP.RestrictedTypesUpdatedPlayer', k, steamid, class, status)
	end,

	RLists_Player = function()
		local k = net.ReadString()
		local count = net.ReadUInt(16)

		DPP.RestrictedTypes_SteamID[k] = {}

		for i = 1, count do
			local steamid = net.ReadString()
			local classes_count = net.ReadUInt(8)

			DPP.RestrictedTypes_SteamID[k][steamid] = DPP.RestrictedTypes_SteamID[k][steamid] or {}

			for i2 = 1, classes_count do
				local class = net.ReadString()
				table.insert(DPP.RestrictedTypes_SteamID[k][steamid], class)
			end
		end

		hook.Run('DPP.RestrictedTypesReloadedPlayer', k)
	end,

	ConstrainedTable = function()
		local Ents = net.ReadTable()
		local Owners = net.ReadTable()

		for k, v in pairs(Ents) do
			if IsValid(v) then
				DLib.nw.GetNetworkDataTable(v)._DPP_Constrained = Owners
			end
		end
	end,

	CleanupTimer = function()
		DPP.CLEAN_UP = net.ReadBool()

		if DPP.CLEAN_UP then
			DPP.CLEAN_UP_START = CurTime()
			DPP.CLEAN_UP_END = CurTime() + net.ReadUInt16()
		end
	end
}

for k, v in pairs(DPP.ClientReceiveFuncs) do
	net.Receive('DPP.' .. k, v)
end

net.Receive('DPP.NetworkedConVarFull', ConVarReceivedFull)
net.Receive('DPP.NetworkedConVar', ConVarReceived)
