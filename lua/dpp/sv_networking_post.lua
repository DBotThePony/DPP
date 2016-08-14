
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

DPP.NetworkSendFuncs = {}

local function Repack(tab)
	local reply = {}
	
	for k, v in pairs(tab) do
		table.insert(reply, k)
	end
	
	return reply
end

for k, v in pairs(DPP.BlockedEntities) do
	local function sendfunc()
		net.Start('DPP.Lists')
		net.WriteString(k)
		DPP.WriteStringList(Repack(v))
		net.Broadcast()
	end
	
	table.insert(DPP.NetworkSendFuncs, sendfunc)
end

for k, v in pairs(DPP.WhitelistedEntities) do
	local function sendfunc()
		net.Start('DPP.WLists')
		net.WriteString(k)
		DPP.WriteStringList(Repack(v))
		net.Broadcast()
	end
	
	table.insert(DPP.NetworkSendFuncs, sendfunc)
end

local function WriteGenericLimits(tab)
	local count = table.Count(tab)
	
	net.WriteUInt(count, 16)
	
	for k, v in pairs(tab) do
		net.WriteString(k)
		net.WriteUInt(table.Count(v), 8)
		
		for group, value in pairs(v) do
			net.WriteString(group)
			net.WriteUInt(tonumber(value), 16) --to be safe
		end
	end
end

for k, v in pairs(DPP.RestrictedTypes) do
	local function sendfunc()
		net.Start('DPP.RLists')
		net.WriteString(k)
		
		local count = table.Count(v)
		
		net.WriteUInt(count, 16)
		
		for class, data in pairs(v) do
			net.WriteString(class)
			net.WriteUInt(#data.groups, 8)
			
			for k, group in ipairs(data.groups) do
				net.WriteString(group)
			end
			
			net.WriteBool(data.iswhite)
		end
		
		net.Broadcast()
	end
	
	table.insert(DPP.NetworkSendFuncs, sendfunc)
end

do
	local function sendfunc()
		net.Start('DPP.ModelLists')
		DPP.WriteStringList(Repack(DPP.BlockedModels))
		net.Broadcast()
	end
	
	table.insert(DPP.NetworkSendFuncs, sendfunc)
	
	function sendfunc()
		net.Start('DPP.LLists')
		WriteGenericLimits(DPP.EntsLimits)
		net.Broadcast()
	end
	
	table.insert(DPP.NetworkSendFuncs, sendfunc)
	
	function sendfunc()
		net.Start('DPP.SLists')
		WriteGenericLimits(DPP.SBoxLimits)
		net.Broadcast()
	end
	
	table.insert(DPP.NetworkSendFuncs, sendfunc)
	
	function sendfunc()
		net.Start('DPP.CLists')
		WriteGenericLimits(DPP.ConstrainsLimits)
		net.Broadcast()
	end
	
	table.insert(DPP.NetworkSendFuncs, sendfunc)
end

function DPP.BroadcastLists()
	for i, func in ipairs(DPP.NetworkSendFuncs) do
		timer.Create('DPP.SendQueue' .. i, i * .3, 1, func)
	end
end
