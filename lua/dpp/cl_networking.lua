
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

local entMeta = FindMetaTable('Entity')

function entMeta:SetDPPVar(var, val)
	var = var:lower()
	local uid = self:EntIndex()

	if uid > 0 then
		DPP.NETWORK_DB[uid] = DPP.NETWORK_DB[uid] or {}
		if val == nil then val = DPP.NetworkVars[var].default end
		DPP.NETWORK_DB[uid][var] = val

		self.__DPP_Vars_Save = DPP.NETWORK_DB[uid]
	else
		self.DPPVars = self.DPPVars or {}
		self.DPPVars[var] = val
	end

	hook.Run('DPP_EntityVarsChanges', self, var, val)
end

local function NetworkedVar()
	local id = net.ReadUInt(6)

	local data, var

	for k, v in pairs(DPP.NetworkVars) do
		if v.NetworkID ~= id then continue end
		data = v
		var = k
		break
	end

	if not data then return end

	local uid = net.ReadUInt(12)
	DPP.NETWORK_DB[uid] = DPP.NETWORK_DB[uid] or {}
	DPP.NETWORK_DB[uid][var] = data.receive()

	local Ent = Entity(uid)
	if IsValid(Ent) then
		hook.Run('DPP_EntityVarsChanges', Ent, var, Ent:DPPVar(var))
	else
		hook.Run('DPP_EntityVarsChangesRaw', uid, var, DPP.NETWORK_DB[uid][var])
	end
end

local function NetworkedEntityVars()
	local uid = net.ReadUInt(12)
	local count = net.ReadUInt(6)

	DPP.NETWORK_DB[uid] = DPP.NETWORK_DB[uid] or {}

	for i = 1, count do
		local id = net.ReadUInt(6)

		local data, var

		for k, v in pairs(DPP.NetworkVars) do
			if v.NetworkID ~= id then continue end
			data = v
			var = k
			break
		end

		if not data then continue end

		DPP.NETWORK_DB[uid][var] = data.receive()
	end
end

local function NetworkedRemove()
	local uid = net.ReadUInt(12)
	DPP.NETWORK_DB[uid] = nil
end

local Initialize = false

local function KeyPress()
	Initialize = true
	hook.Remove('KeyPress', 'DPP.Networking')
	net.Start('DPP.NetworkedVarFull')
	net.SendToServer()
end

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
	--Full update functions

	Lists = function()
		local str = net.ReadString()
		DPP.BlockedEntities[str] = ReadInvertedTable()

		hook.Run('DPP.BlockedEntitiesReloaded', str, DPP.BlockedEntities[str])
		if not DPP.PlayerConVar(_, 'no_load_messages') then DPP.Message('Blacklist "' .. str .. '" received from server, reloading') end
	end,

	RLists = function()
		local str = net.ReadString()
		DPP.RestrictedTypes[str] = ReadRestrictions()

		hook.Run('DPP.BlockedEntitiesReloaded', str, DPP.RestrictedTypes[str])
		if not DPP.PlayerConVar(_, 'no_load_messages') then DPP.Message('Restrict list "' .. str .. '" received from server, reloading') end
	end,

	WLists = function()
		local str = net.ReadString()
		DPP.WhitelistedEntities[str] = ReadInvertedTable()

		hook.Run('DPP.WhitelistedEntitiesReloaded', str, DPP.WhitelistedEntities[str])
		if not DPP.PlayerConVar(_, 'no_load_messages') then DPP.Message('Whitelist "' .. str .. '" received from server, reloading') end
	end,

	ModelLists = function()
		DPP.BlockedModels = ReadInvertedTable()

		hook.Run('DPP.BlockedModelListReloaded', DPP.BlockedModels)
		if not DPP.PlayerConVar(_, 'no_load_messages') then DPP.Message('Blacklisted models received from server, reloading') end
	end,

	LLists = function()
		DPP.EntsLimits = ReadGenericLimits()

		hook.Run('DPP.EntsLimitsReloaded', DPP.EntsLimits)
		if not DPP.PlayerConVar(_, 'no_load_messages') then DPP.Message('Entity limit list received from server, reloading') end
	end,

	SLists = function()
		DPP.SBoxLimits = ReadGenericLimits()

		hook.Run('DPP.EntsLimitsReloaded', DPP.SBoxLimits)
		if not DPP.PlayerConVar(_, 'no_load_messages') then DPP.Message('SBox limit list received from server, reloading') end
	end,

	CLists = function()
		DPP.ConstrainsLimits = ReadGenericLimits()

		hook.Run('DPP.ConstrainsLimitsReloaded', DPP.ConstrainsLimits)
		if not DPP.PlayerConVar(_, 'no_load_messages') then DPP.Message('Constrains limit list received from server, reloading') end
	end,

	--Insert receive functions

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
	
	LimitHit = function()
		hook.Run('LimitHit', net.ReadString())
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
}

for k, v in pairs(DPP.ClientReceiveFuncs) do
	net.Receive('DPP.' .. k, v)
end

net.Receive('DPP.NetworkedConVarFull', ConVarReceivedFull)
net.Receive('DPP.NetworkedConVar', ConVarReceived)
net.Receive('DPP.NetworkedEntityVars', NetworkedEntityVars)
net.Receive('DPP.NetworkedVar', NetworkedVar)
net.Receive('DPP.NetworkedRemove', NetworkedRemove)
hook.Add('KeyPress', 'DPP.Networking', KeyPress)
