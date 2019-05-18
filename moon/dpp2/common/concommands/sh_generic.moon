
-- Copyright (C) 2015-2019 DBotThePony

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
	freezephys: (args = '') -> [string.format('%q', ply) for ply in *DPP2.FindPlayersInArgument(args)]

	cleanup: (args = '') ->
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

if CLIENT
	DPP2.cmd_existing.cleanupdisconnected = true
	DPP2.cmd_existing.freezephysall = true
	DPP2.cmd_existing.freezephyspanic = true
	DPP2.cmd_existing.cleanupallnpcs = true
	DPP2.cmd_existing.cleanupallvehicles = true
