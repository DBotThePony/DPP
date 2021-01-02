
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

cmds = {
	ban: (args = {}, message) =>
		str = args[1]
		time = tonumber(args[2])

		ply = DPP2.FindPlayerInCommand(str)
		return 'command.dpp2.generic.notarget' if not ply
		return 'command.dpp2.generic.invalid_time' if not time or time <= 0
		time = time\floor()
		return 'command.dpp2.generic.invalid_time' if time <= 0
		return 'command.dpp2.generic.no_bots' if ply\IsBot()

		ply\DPP2Ban(time)
		DPP2.Notify(true, nil, 'command.dpp2.ban', @, ply, DLib.I18n.FormatTime(time))

	permanent_ban: (args = {}, message) =>
		str = table.concat(args, ' ')

		ply = DPP2.FindPlayerInCommand(str)
		return 'command.dpp2.generic.notarget' if not ply
		return 'command.dpp2.generic.no_bots' if ply\IsBot()
		return 'command.dpp2.already_banned' if ply\DPP2IsPermanentlyBanned()

		ply\DPP2Ban(math.huge)
		DPP2.Notify(true, nil, 'command.dpp2.permanent_ban', @, ply)

	unban: (args = {}, message) =>
		str = table.concat(args, ' ')

		ply = DPP2.FindPlayerInCommand(str)
		return 'command.dpp2.generic.notarget' if not ply
		return 'command.dpp2.generic.no_bots' if ply\IsBot()
		return 'command.dpp2.unban.not_banned' if not ply\DPP2IsBanned()

		ply\DPP2Unban()
		DPP2.NotifyCleanup(true, nil, 'command.dpp2.unban.unbanned', @, ply)
}

DPP2.cmd[k] = v for k, v in pairs(cmds)
