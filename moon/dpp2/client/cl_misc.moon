
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

net.receive 'dpp2_inspect', ->
	ent = NULL
	ent = net.ReadEntity() if net.ReadBool()

	DPP2.LMessagePlayer(LocalPlayer(), 'message.dpp2.inspect.clientside')
	DPP2.SpewEntityInspectionOutput(LocalPlayer(), ent)
	DPP2.LMessagePlayer(LocalPlayer(), 'message.dpp2.inspect.footer')

net.receive 'dpp2_cleargibs', -> SafeRemoveEntity(ent) for ent in *ents.FindByClass('class C_PhysPropClientside')

net.receive 'dpp2_cleardecals', ->
	ply = net.ReadEntity() if net.ReadBool()
	DPP2.NotifyCleanup(true, nil, 'command.dpp2.cleardecals', ply or NULL)
	RunConsoleCommand('r_cleardecals')
	game.RemoveRagdolls()

concommand.Add 'dpp2_import_fpp_friends', ->
	friends = sql.Query('SELECT * FROM `FPP_Buddies`')

	if not friends
		DPP2.Message('message.dpp2.import.no_fpp_table')
		return

	num = 0

	for row in *friends
		num += 1

		with DLib.friends
			.UpdateFriendType(row.steamid, 'dpp2_use', tobool(row.playeruse))
			.UpdateFriendType(row.steamid, 'dpp2_pickup', tobool(row.playeruse))
			.UpdateFriendType(row.steamid, 'dpp2_vehicle', tobool(row.playeruse))
			.UpdateFriendType(row.steamid, 'dpp2_toolgun', tobool(row.toolgun))
			.UpdateFriendType(row.steamid, 'dpp2_physgun', tobool(row.physgun))
			.UpdateFriendType(row.steamid, 'dpp2_drive', tobool(row.physgun))
			.UpdateFriendType(row.steamid, 'dpp2_gravgun', tobool(row.gravgun))
			.UpdateFriendType(row.steamid, 'dpp2_damage', tobool(row.entitydamage))

	DLib.friends.Flush()
	DPP2.Message('message.dpp2.import.fpp_friends', num)

do
	targets = {
		physgun: {'physgun', 'drive'}
		gravgun: 'gravgun'
		toolgun: 'toolgun'
		use: 'use'
		vehicle: 'vehicle'
		damage: 'damage'
		pickup: 'pickup'
	}

	concommand.Add 'dpp2_import_dpp_friends', ->
		num = 0

		do
			data = sql.Query('SELECT * FROM `dpp_friends`')

			if data then
				for row in *data
					steamid = row.STEAMID
					modes = util.JSONToTable(row.MODES)

					if modes
						for mode, status in pairs(modes)
							for target in *(istable(targets[mode]) and targets[mode] or {targets[mode]})
								DLib.friends.UpdateFriendType(steamid, 'dpp2_' .. target, status)
								num += 1

				sql.Query('DROP TABLE dpp_friends')


		for source, _target in pairs(targets)
			data = sql.EQuery('SELECT `steamid`, `status` FROM `dlib_friends` WHERE `friendid` = ' .. SQLStr('dpp_' .. source))

			if data
				for target in *(istable(_target) and _target or {_target})
					for row in *data
						DLib.friends.UpdateFriendType(row.steamid, 'dpp2_' .. target, tobool(row.status))
						num += 1

		DLib.friends.Flush()
		DPP2.Message('message.dpp2.import.dpp_friends', num)
