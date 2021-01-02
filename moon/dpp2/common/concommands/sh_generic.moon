
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

import DPP2 from _G

cmds = {
	freezephys: (args = '') => [string.format('%q', ply) for ply in *DPP2.FindPlayersInArgument(args)]
	unban: (args = '') => [string.format('%q', ply) for ply in *DPP2.FindPlayersInArgument(args, [ply2 for ply2 in *player.GetHumans() when not ply2\DPP2IsBanned()], true)]
	permanent_ban: (args = '') => [string.format('%q', ply) for ply in *DPP2.FindPlayersInArgument(args, [ply2 for ply2 in *player.GetHumans() when ply2\DPP2IsPermanentlyBanned()], true)]
	ban: (args = '') =>
		split = DPP2.SplitArguments(args)
		return [string.format('%q %s', ply, split[2] or '') for ply in *DPP2.FindPlayersInArgument(split[1], [ply2 for ply2 in *player.GetHumans() when ply2\DPP2IsPermanentlyBanned()], true)]

	cleanup: (args = '') =>
		args = args\trim()
		return {'disconnected'} if args == 'disconnected'
		return {'npcs'} if args == 'npcs'
		return {'vehicles'} if args == 'vehicles'
		output = [string.format('%q', ply) for ply in *DPP2.FindPlayersInArgument(args)]
		if args == ''
			table.insert(output, 'disconnected')
			table.insert(output, 'npcs')
			table.insert(output, 'vehicles')
		return output
}

cmds.cleanupnpcs = cmds.freezephys
cmds.cleanupvehicles = cmds.freezephys

DPP2.cmd_autocomplete[k] = v for k, v in pairs(cmds)
