
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

DPP.NetworkSendFuncs = {}

function DPP.NetRepack(tab)
	local reply = {}

	for k, v in pairs(tab) do
		table.insert(reply, k)
	end

	return reply
end

for k, v in pairs(DPP.BlockedEntities) do
	local function sendfunc(plys)
		net.Start('DPP.Lists')
		net.WriteString(k)
		DPP.WriteStringList(DPP.NetRepack(DPP.BlockedEntities[k]))
		net.Send(plys)
	end

	table.insert(DPP.NetworkSendFuncs, sendfunc)
end

for k, v in pairs(DPP.WhitelistedEntities) do
	local function sendfunc(plys)
		net.Start('DPP.WLists')
		net.WriteString(k)
		DPP.WriteStringList(DPP.NetRepack(DPP.WhitelistedEntities[k]))
		net.Send(plys)
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
			local num = tonumber(value)
			net.WriteBool(num < 0)
			net.WriteUInt(math.abs(num), 16) --to be safe
		end
	end
end

for k, v in pairs(DPP.RestrictedTypes) do
	local function sendfunc(plys)
		net.Start('DPP.RLists')

		local v = DPP.RestrictedTypes[k]
		net.WriteString(k)

		net.WriteUInt(table.Count(v), 16)

		for class, data in pairs(v) do
			net.WriteString(class)
			net.WriteUInt(#data.groups, 8)

			for k, group in ipairs(data.groups) do
				net.WriteString(group)
			end

			net.WriteBool(data.iswhite)
		end

		net.Send(plys)
	end

	table.insert(DPP.NetworkSendFuncs, sendfunc)

	local function sendfunc(plys)
		net.Start('DPP.RLists_Player')

		local v = DPP.RestrictedTypes_SteamID[k]
		net.WriteString(k)

		net.WriteUInt(table.Count(v), 16)

		for steamid, classes in pairs(v) do
			net.WriteString(steamid)

			net.WriteUInt(#classes, 8)

			for i2, class in ipairs(classes) do
				net.WriteString(class)
			end
		end

		net.Send(plys)
	end

	table.insert(DPP.NetworkSendFuncs, sendfunc)
end

do
	local function sendfunc(plys)
		net.Start('DPP.ModelLists')
		DPP.WriteStringList(DPP.NetRepack(DPP.BlockedModels))
		net.Send(plys)
	end

	table.insert(DPP.NetworkSendFuncs, sendfunc)

	function sendfunc(plys)
		net.Start('DPP.LLists')
		WriteGenericLimits(DPP.EntsLimits)
		net.Send(plys)
	end

	table.insert(DPP.NetworkSendFuncs, sendfunc)

	function sendfunc(plys)
		net.Start('DPP.MLLists')
		WriteGenericLimits(DPP.ModelsLimits)
		net.Send(plys)
	end

	table.insert(DPP.NetworkSendFuncs, sendfunc)

	function sendfunc(plys)
		net.Start('DPP.SLists')
		WriteGenericLimits(DPP.SBoxLimits)
		net.Send(plys)
	end

	table.insert(DPP.NetworkSendFuncs, sendfunc)

	function sendfunc(plys)
		net.Start('DPP.CLists')
		WriteGenericLimits(DPP.ConstrainsLimits)
		net.Send(plys)
	end

	table.insert(DPP.NetworkSendFuncs, sendfunc)
end

function DPP.BroadcastLists(plys)
	local isBroadcast = plys == nil
	plys = plys or player.GetAll()

	if type(plys) == 'table' and #plys == 0 then return end

	if istable(plys) then
		for i, func in ipairs(DPP.NetworkSendFuncs) do
			local str = 'DPP.SendQueue' .. (isBroadcast and i or (i .. '.' .. tostring(plys)))

			timer.Create(str, i * .3, 1, function()
				func(plys)
			end)
		end
	else
		for i, func in ipairs(DPP.NetworkSendFuncs) do
			timer.Create('DPP.SendQueue' .. i .. '.' .. plys:SteamID(), i * .3, 1, function()
				if not IsValid(plys) then return end
				func(plys)
			end)
		end
	end
end
