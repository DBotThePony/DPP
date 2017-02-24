
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

local function FlippedFunc(func, arg)
	return function(arg1)
		return func(arg1, arg)
	end
end

DPP.NETWORK_DB = DPP.NETWORK_DB or {}
DPP.NetworkVars = {
	['owner'] = {
		send = function(val)
			if val == NULL then
				net.WriteBool(false)
			else
				net.WriteBool(true)
				net.WriteUInt(val:EntIndex(), 8)
			end
		end,

		receive = function()
			if net.ReadBool() then
				return Entity(net.ReadUInt(8))
			else
				return NULL
			end
		end,

		type = 'Entity',
		default = NULL,
	},

	['isowned'] = {
		send = function(val) net.WriteBool(val) end,
		receive = function() return net.ReadBool() end,
		type = 'boolean',
		default = false,
	},

	['ownerstring'] = {
		send = function(val) net.WriteString(val) end,
		receive = function() return net.ReadString() end,
		type = 'string',
		default = '',
	},

	['ownersteamid'] = {
		send = net.WriteString,
		receive = net.ReadString,
		type = 'string',
		default = '',
	},

	['owneruid'] = {
		send = function(val) net.WriteUInt(tonumber(val), 32) end,
		receive = function() return tostring(net.ReadUInt(32)) end,
		type = 'string', --Actually needs to be number
		default = '',
	},

	['isghosted'] = {
		send = net.WriteBool,
		receive = net.ReadBool,
		type = 'boolean',
	},

	['isupforgraps'] = {
		send = net.WriteBool,
		receive = net.ReadBool,
		type = 'boolean',
		default = false,
	},

	['isshared'] = {
		send = net.WriteBool,
		receive = net.ReadBool,
		type = 'boolean',
		default = false,
	},
}

DPP.NetworkVars.fallback = table.Copy(DPP.NetworkVars.owner)

local nextId = 1

for k, v in pairs(DPP.NetworkVars) do
	local nk = k:lower()
	v.ID = k
	v.NetworkID = nextId
	nextId = nextId + 1

	DPP.NetworkVars[k] = nil
	DPP.NetworkVars[nk] = v
end

function DPP.RegisterNetworkVar(id, send, receive, type, default)
	id = id:lower()
	DPP.NetworkVars[id] = {
		send = send,
		receive = receive,
		type = type,
		default = default,
		ID = id,
		NetworkID = nextId,
	}

	nextId = nextId + 1

	DPP.Assert(nextId < 64, 'Maximal of DPP networked vars reached!', 1, true)
end

local entMeta = FindMetaTable('Entity')

function entMeta:DPPVar(var, ifNothing)
	var = var:lower()
	local uid = self:EntIndex()

	if uid > 0 then
		local data = DPP.NETWORK_DB[uid]

		if not data or data[var] == nil then
			if ifNothing ~= nil then
				return ifNothing
			else
				return DPP.NetworkVars[var].default
			end
		end

		return data[var]
	else
		self.DPPVars = self.DPPVars or {}

		if self.DPPVars[var] == nil then
			if ifNothing ~= nil then
				return ifNothing
			else
				return DPP.NetworkVars[var].default
			end
		end

		return self.DPPVars[var]
	end
end

function DPP.GetNetworkDataTable(self)
	local uid = self:EntIndex()
	
	if uid > 0 then
		DPP.NETWORK_DB[uid] = DPP.NETWORK_DB[uid] or {}
		return DPP.NETWORK_DB[uid], true
	else
		self.DPPVars = self.DPPVars or {}
		return self.DPPVars, false
	end
end

function DPP.GetConstrainedTable(ent)
	local data = DPP.GetNetworkDataTable(ent)
	data._DPP_Constrained = data._DPP_Constrained or {}
	return data._DPP_Constrained
end

local function OnEntityCreated(ent)
	local uid = ent:EntIndex()
	if uid <= 0 then return end

	timer.Simple(0, function()
		timer.Simple(0, function() --Skip two frames
			if not ent.__DPP_Vars_Save then return end
			DPP.NETWORK_DB[uid] = DPP.NETWORK_DB[uid] or {}
			local data = DPP.NETWORK_DB[uid]

			local rep = ent.__DPP_Vars_Save --Store

			for k, v in pairs(rep) do
				if data[k] ~= nil then continue end
				if not DPP.NetworkVars[k:lower()] then continue end --Old network variable
				ent:SetDPPVar(k, v)
			end
		end)
	end)
end

function DPP.WriteStringList(tab)
	net.WriteUInt(#tab, 16)

	for k, v in ipairs(tab) do
		net.WriteString(v)
	end
end

function DPP.ReadStringList()
	local count = net.ReadUInt(16)

	local reply = {}

	for i = 1, count do
		table.insert(reply, net.ReadString())
	end

	return reply
end

function DPP.AssignConVarNetworkIDs()
	local nextID = 1

	for k, v in SortedPairs(DPP.Settings) do
		DPP.Settings[k].NetworkID = nextID
		nextID = nextID + 1
	end
end

function DPP.WriteVarchar(str)
	local len = math.Clamp(#str, 0, 255)
	net.WriteUInt(len, 8)
	
	for k, v in ipairs{string.byte(str, 1, len)} do
		net.WriteUInt(v, 8)
	end
end

function DPP.ReadVarchar()
	local len = net.ReadUInt(8)
	
	local str = ''
	
	for i = 1, len do
		str = str .. string.char(net.ReadUInt(8))
	end
	
	return str
end

function DPP.WriteBigInt(num, base)
	base = base or 63
	local reply = {}
	local signed = num < 0
	num = math.abs(num)
	
	while num > 0 do
		local div = num % 2
		num = (num - div) / 2
		table.insert(reply, div)
	end
	
	for i = 1, base do
		net.WriteBit(reply[base - i + 1] or 0)
	end
	
	net.WriteBool(signed)
end

local preProcessed = {}

for i = 1, 127 do
	preProcessed[i] = 2 ^ (i - 1)
end

function DPP.ReadBigInt(base)
	base = base or 63
	local reply = {}
	local output = 0
	
	for i = 1, base do
		output = output + preProcessed[base - i + 1] * net.ReadBit()
	end
	
	local signed = net.ReadBool()
	
	return not signed and output or -output
end

DPP_NETTYPE_NUMBER = 1
DPP_NETTYPE_STRING = 2
DPP_NETTYPE_COLOR = 3
DPP_NETTYPE_BOOL = 4
DPP_NETTYPE_PLAYER = 5

function DPP.WriteMessageTable(tab)
	net.WriteUInt(#tab, 8)
	
	for k, v in ipairs(tab) do
		local T = type(v)
		
		if T == 'string' then
			net.WriteUInt(DPP_NETTYPE_STRING, 6)
			DPP.WriteVarchar(v)
		elseif T == 'Player' then
			net.WriteUInt(DPP_NETTYPE_PLAYER, 6)
			net.WriteUInt(v:EntIndex(), 8)
		elseif T == 'number' then
			net.WriteUInt(DPP_NETTYPE_NUMBER, 6)
			DPP.WriteBigInt(v)
		elseif T == 'boolean' then
			net.WriteUInt(DPP_NETTYPE_BOOL, 6)
			net.WriteBool(v)
		elseif T == 'table' and v.a and v.r and v.g and v.b then
			net.WriteUInt(DPP_NETTYPE_COLOR, 6)
			net.WriteColor(v)
		end
	end
end

function DPP.ReadMessageTable()
	local len = net.ReadUInt(8)
	local reply = {}
	
	for i = 1, len do
		local T = net.ReadUInt(6)
		
		if T == DPP_NETTYPE_STRING then
			table.insert(reply, DPP.ReadVarchar())
		elseif T == DPP_NETTYPE_NUMBER then
			table.insert(reply, DPP.ReadBigInt())
		elseif T == DPP_NETTYPE_BOOL then
			table.insert(reply, net.ReadBool())
		elseif T == DPP_NETTYPE_PLAYER then
			table.insert(reply, Entity(net.ReadUInt(8)))
		elseif T == DPP_NETTYPE_COLOR then
			table.insert(reply, net.ReadColor())
		end
	end
	
	return reply
end

hook.Add('OnEntityCreated', 'DPP.Networking', OnEntityCreated)
hook.Add('DPP_ConVarRegistered', function()
	timer.Create('DPP.OnConVarRegisteredNetworkUpdate', 0, 1, DPP.AssignConVarNetworkIDs)
end)

function DPP.WriteEntityArray(tab)
	net.WriteUInt(#tab, 16)
	
	for k, v in pairs(tab) do
		net.WriteBool(v:IsValid())
		net.WriteUInt(v:EntIndex(), 12)
	end
end

function DPP.ReadEntityArray()
	local count = net.ReadUInt(16)
	local read = {}
	
	for i = 1, count do
		local shouldValid = net.ReadBool()
		local get = Entity(net.ReadUInt(12))
		
		if (shouldValid and IsValid(get)) or (not shouldValid and not IsValid(get)) then
			table.insert(read, get)
		end
	end
	
	return read
end

function DPP.WriteArray(tab)
	net.WriteUInt(#tab, 16)
	
	for k, v in pairs(tab) do
		net.WriteType(v)
	end
end

function DPP.ReadArray()
	local count = net.ReadUInt(16)
	local read = {}
	
	for i = 1, count do
		table.insert(read, net.ReadType())
	end
	
	return read
end

if CLIENT then
	include('cl_networking.lua')
else
	include('sv_networking.lua')
end
