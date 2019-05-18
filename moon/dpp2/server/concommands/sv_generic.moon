
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
	cleanup: (args = {}, message) =>
		str = table.concat(args, ' ')

		switch str\lower()
			when 'disconnected'
				return DPP2.cmd_remap.cleanupdisconnected(@)
			when 'npc'
				return DPP2.cmd_remap.cleanupallnpcs(@)
			when 'vehicles'
				return DPP2.cmd_remap.cleanupallvehicles(@)

		ply = DPP2.FindPlayerInCommand(str)
		return 'message.dpp2.concommand.generic.notarget' if not ply
		SafeRemoveEntity(ent) for ent in *ply\DPP2FindOwned()
		DPP2.Notify(true, nil, 'message.dpp2.concommand.cleanup', @, ply)

	cleanupnpcs: (args = {}, message) =>
		str = table.concat(args, ' ')
		ply = DPP2.FindPlayerInCommand(str)
		return 'message.dpp2.concommand.generic.notarget' if not ply
		SafeRemoveEntity(ent) for ent in *ply\DPP2FindOwned() when ent\IsNPC() or type(ent) == 'NextBot'
		DPP2.Notify(true, nil, 'message.dpp2.concommand.cleanupnpcs', @, ply)

	cleanupvehicles: (args = {}, message) =>
		str = table.concat(args, ' ')
		ply = DPP2.FindPlayerInCommand(str)
		return 'message.dpp2.concommand.generic.notarget' if not ply
		SafeRemoveEntity(ent) for ent in *ply\DPP2FindOwned() when ent\IsVehicle()
		DPP2.Notify(true, nil, 'message.dpp2.concommand.cleanupvehicles', @, ply)

	cleanupallnpcs: (args = {}, message) =>
		SafeRemoveEntity(ent) for ent in *DPP2.FindOwned() when ent\IsNPC() or type(ent) == 'NextBot'
		DPP2.Notify(true, nil, 'message.dpp2.concommand.cleanupallnpcs', @)

	cleanupallvehicles: (args = {}, message) =>
		SafeRemoveEntity(ent) for ent in *DPP2.FindOwned() when ent\IsVehicle()
		DPP2.Notify(true, nil, 'message.dpp2.concommand.cleanupallvehicles', @)

	cleanupdisconnected: (args = {}) =>
		SafeRemoveEntity(ent) for ent in *DPP2.FindOwned() when not ent\DPP2OwnerIsValid()
		DPP2.Notify(true, nil, 'message.dpp2.concommand.cleanupdisconnected', @)

	freezephys: (args = {}, message) =>
		str = table.concat(args, ' ')
		ply = DPP2.FindPlayerInCommand(str)
		return 'message.dpp2.concommand.generic.notarget' if not ply

		for ent in *ply\DPP2FindOwned()
			if phys = ent\DPP2GetPhys()
				if type(phys) == 'table'
					phys2\EnableMotion(false) for phys2 in *phys
				else
					phys\EnableMotion(false)

		DPP2.Notify(true, nil, 'message.dpp2.concommand.freezephys', @, ply)

	freezephysall: (args = {}, message) =>
		for ent in *DPP2.FindOwned()
			if phys = ent\DPP2GetPhys()
				if type(phys) == 'table'
					phys2\EnableMotion(false) for phys2 in *phys
				else
					phys\EnableMotion(false)

		DPP2.Notify(true, nil, 'message.dpp2.concommand.freezephysall', @)

	freezephyspanic: (args = {}, message) =>
		for ent in *ents.GetAll()
			if phys = ent\DPP2GetPhys()
				if type(phys) == 'table'
					phys2\EnableMotion(false) for phys2 in *phys
				else
					phys\EnableMotion(false)

		DPP2.Notify(true, nil, 'message.dpp2.concommand.freezephyspanic', @)
}

DPP2.cmd[k] = v for k, v in pairs(cmds)
