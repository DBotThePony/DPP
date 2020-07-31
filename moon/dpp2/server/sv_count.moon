
-- Copyright (C) 2018-2020 DBotThePony

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

import DPP2, DLib from _G
import net from DLib

net.pool('dpp2_limithit')
net.pool('dpp2_limitlist_replicate')
net.pool('dpp2_limitlist_clear')
net.pool('dpp2_limitentry_create')
net.pool('dpp2_limitentry_remove')
net.pool('dpp2_limitentry_change')

net.receive 'dpp2_limitlist_replicate', (len, ply) ->
	identifier = net.ReadString()
	obj = DPP2.DEF.LimitRegistry\GetByID(identifier)
	return if not obj
	return if (ply['dpp2_last_full_request_limit_' .. obj.identifier] or 0) > RealTime()
	ply['dpp2_last_full_request_limit_' .. obj.identifier] = RealTime() + 30
	obj\FullReplicate(ply)

PlayerDisconnected = =>
	DPP2.PlayerCounts[@UniqueID()] = nil if @IsBot()

	local mark

	for steamid, data in pairs(DPP2.PlayerCounts)
		for ent in *data
			if not IsValid(ent)
				DPP2.PlayerCounts[steamid] = [ent2 for ent2 in *data when IsValid(ent2)]
				if #DPP2.PlayerCounts[steamid] == 0
					mark = mark or {}
					table.insert(mark, steamid)

	if mark
		DPP2.PlayerCounts[steamid] = nil for steamid in *mark

hook.Add 'PlayerDisconnected', 'DPP2.PlayerCounts', PlayerDisconnected
