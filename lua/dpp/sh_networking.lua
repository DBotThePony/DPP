
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

	for k, v in pairs(DPP.Settings) do
		v.NetworkID = nextID
		nextID = nextID + 1
	end
end

hook.Add('OnEntityCreated', 'DPP.Networking', OnEntityCreated)

if CLIENT then
	include('cl_networking.lua')
else
	include('sv_networking.lua')
end
