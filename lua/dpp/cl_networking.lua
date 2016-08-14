
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
			local value = net.ReadUInt(16)
			
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
		DPP.BlockedEntities[str] = ReadRestrictions()
		
		hook.Run('DPP.BlockedEntitiesReloaded', str, DPP.BlockedEntities[str])
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
}

for k, v in pairs(DPP.ClientReceiveFuncs) do
	net.Receive('DPP.' .. k, v)
end

net.Receive('DPP.NetworkedEntityVars', NetworkedEntityVars)
net.Receive('DPP.NetworkedVar', NetworkedVar)
net.Receive('DPP.NetworkedRemove', NetworkedRemove)
hook.Add('KeyPress', 'DPP.Networking', KeyPress)
