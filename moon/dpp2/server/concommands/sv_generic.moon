
-- Copyright (C) 2015-2018 DBot

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
	cleanup: (args = {}, message) =>
		str = table.concat(args, ' ')
		return DPP2.cmd.cleanupdisconnected(@) if str\lower() == 'disconnected'
		ply = DPP2.FindPlayerInCommand(str)
		return 'message.dpp2.concommand.generic.notarget' if not ply

		cb = (hasAccess = false, reason = '<unknown reason>') ->
			return message('message.dpp2.concommand.generic.noaccess_check', reason) if not hasAccess
			return message('message.dpp2.concommand.generic.notarget') if not IsValid(ply)
			SafeRemoveEntity(ent) for ent in *ply\DPP2FindOwned()
			DPP2.Notify(true, nil, 'message.dpp2.concommand.cleanup', @, ply)

		CAMI.PlayerHasAccess @, 'dpp2_cleanup', cb, ply

	cleanupdisconnected: (args = {}) =>
		SafeRemoveEntity(ent) for ent in *DPP2.FindOwned() when not ent\DPP2OwnerIsValid()
		DPP2.Notify(true, nil, 'message.dpp2.concommand.cleanupdisconnected', @)
}

DPP2.cmd[k] = v for k, v in pairs(cmds)
