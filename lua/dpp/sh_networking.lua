
-- Copyright (C) 2016-2017 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local entMeta = FindMetaTable('Entity')

function entMeta:DPPVar(var, ifNothing)
	return self:DLibVar('dpp_' .. var, ifNothing)
end

function entMeta:SetDPPVar(var, val)
	return self:SetDLibVar('dpp_' .. var, val)
end

local function FlippedFunc(func, arg)
	return function(arg1)
		return func(arg1, arg)
	end
end

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

	['createdbymap'] = {
		send = net.WriteBool,
		receive = net.ReadBool,
		type = 'boolean',
		default = false,
	},
}

DPP.NetworkVars.fallback = table.Copy(DPP.NetworkVars.owner)

function DPP.RegisterNetworkVar(id, send, receive, type, default)
	return DLib.nw.RegisterNetworkVar(id, send, receive, type, default)
end

for k, v in pairs(DPP.NetworkVars) do
	DLib.nw.pool(k, v.send, v.receive, v.type, v.default)
end

function DPP.GetConstrainedTable(ent)
	local data = DLib.nw.GetNetworkDataTable(ent)
	data._DPP_Constrained = data._DPP_Constrained or {}
	return data._DPP_Constrained
end

DPP.WriteStringList = net.WriteStringArray
DPP.ReadStringList = net.ReadStringArray
DPP.WriteVarchar = net.WriteString
DPP.ReadVarchar = net.ReadString
DPP.WriteBigInt = net.WriteBigint
DPP.ReadBigInt = net.ReadBigint
DPP.WriteEntityArray = net.WriteEntityArray
DPP.ReadEntityArray = net.ReadEntityArray
DPP.WriteArray = net.WriteArray
DPP.ReadArray = net.ReadArray

function DPP.AssignConVarNetworkIDs()
	local nextID = 1

	for k, v in SortedPairs(DPP.Settings) do
		DPP.Settings[k].NetworkID = nextID
		nextID = nextID + 1
	end
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

hook.Add('DLib.EntityVarsChanges', 'DPP', function(self, var, val)
	if var:sub(1, 4) == 'dpp_' then
		return hook.Run('DPP_EntityVarsChanges', self, var:sub(5), val)
	end
end)

hook.Add('DPP_ConVarRegistered', function()
	timer.Create('DPP.OnConVarRegisteredNetworkUpdate', 0, 1, DPP.AssignConVarNetworkIDs)
end)

if CLIENT then
	include('cl_networking.lua')
else
	include('sv_networking.lua')
end
