
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
	DPP.NETWORK_DB[uid] = DPP.NETWORK_DB[uid] or {}
	if val == nil then val = DPP.NetworkVars[var].default end
	DPP.NETWORK_DB[uid][var] = val
end

local function NetworkedVar()
	local id = net.ReadUInt(5)
	
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
end

local function NetworkedEntityVars()
	local uid = net.ReadUInt(12)
	local count = net.ReadUInt(6)
	
	DPP.NETWORK_DB[uid] = DPP.NETWORK_DB[uid] or {}
	
	for i = 1, count do
		local id = net.ReadUInt(5)
		
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

local Initialize = false

local function KeyPress()
	Initialize = true
	hook.Remove('KeyPress', 'DPP.Networking')
	net.Start('DPP.NetworkedVarFull')
	net.SendToServer()
end

net.Receive('DPP.NetworkedEntityVars', NetworkedEntityVars)
net.Receive('DPP.NetworkedVar', NetworkedVar)
hook.Add('KeyPress', 'DPP.Networking', KeyPress)
