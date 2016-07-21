
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
	},
	
	['isowned'] = {
		send = function(val) net.WriteBool(val) end,
		receive = function() return net.ReadBool() end,
		type = 'boolean',
	},
	
	['ownerstring'] = {
		send = function(val) net.WriteString(val) end,
		receive = function() return net.ReadString() end,
		type = 'string',
	},
	
	['ownersteamid'] = {
		send = function(val) net.WriteString(val) end,
		receive = function() return net.ReadString() end,
		type = 'string',
	},
	
	['owneruid'] = {
		send = function(val) net.WriteUInt(tonumber(val), 32) end,
		receive = function() return tostring(net.ReadUInt(32)) end,
		type = 'string', --Actually needs to be number
	},
	
	['isghosted'] = {
		send = function(val) net.WriteBool(val) end,
		receive = function() return net.ReadBool() end,
		type = 'boolean',
	},
	
	['isupforgraps'] = {
		send = function(val) net.WriteBool(val) end,
		receive = function() return net.ReadBool() end,
		type = 'boolean',
	},
	
	['isshared'] = {
		send = function(val) net.WriteBool(val) end,
		receive = function() return net.ReadBool() end,
		type = 'boolean',
	},
}

local nextId = 1

for k, v in pairs(DPP.NetworkVars) do
	v.ID = k
	v.NetworkID = nextId
	nextId = nextId + 1
end

function DPP.RegisterNetworkVar(id, send, receive, type)
	id = id:lower()
	DPP.NetworkVars[id] = {
		send = send,
		receive = receive,
		type = type,
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
	local data = DPP.NETWORK_DB[uid]
	if not data then return ifNothing end
	if data[var] == nil then return ifNothing end
	return data[var]
end

if CLIENT then
	include('cl_networking.lua')
else
	include('sv_networking.lua')
end
