
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

import DPP2, DLib, CAMI from _G
import net from DLib

cmd_perms = {
	cleanup: 'admin'
	cleardecals: 'admin'
	cleanupgibs: 'admin'
	cleanupnpcs: 'admin'
	cleanupallnpcs: 'admin'
	cleanupallvehicles: 'admin'
	cleanupvehicles: 'admin'
	cleanupdisconnected: 'admin'
	freezephys: 'admin'
	freezephysall: 'admin'
	freezephyspanic: 'superadmin'

	inspect: 'superadmin'

	transfertoworld: 'admin'
	transfertoworldent: 'admin'
	transfertoworldcontraption: 'admin'
	transfer: 'user'
	transferfallback: 'user'
	transferent: 'user'
	transfercontraption: 'user'

	setvar: 'superadmin'

	import_urs_limits: 'superadmin'
	import_urm_limits: 'superadmin'
	import_urs_restricts: 'superadmin'
	import_urm_restricts: 'superadmin'
	import_wuma_limits: 'superadmin'
	import_wuma_restricts: 'superadmin'
	import_dpp_exclusions: 'superadmin'
	import_dpp_blacklists: 'superadmin'
	import_dpp_restrictions: 'superadmin'
	import_dpp_limits: 'superadmin'
	import_fpp: 'superadmin'
	import_fpp_reload: 'superadmin'
	import_dpp_reload: 'superadmin'
}

local watchdog

if CLIENT
	watchdog = DLib.CAMIWatchdog('dpp2_client_cmd')
	DPP2.cmd_perm_watchdog = watchdog

DPP2.cmd_perms[k] = v for k, v in pairs(cmd_perms)

if CLIENT
	DPP2.cmd_existing[k] = true for k in pairs(DPP2.cmd_perms)

DPP2.cmd_remap = {}

for permName, permLevel in pairs(DPP2.cmd_perms)
	if not permLevel\startsWith('CAMI_')
		CAMI.RegisterPrivilege({
			Name: 'dpp2_' .. permName
			MinAccess: permLevel
			-- Description:
		})

if SERVER
	net.pool('dpp2_exec_concommand')

	net.receive 'dpp2_exec_concommand', (len, ply = NULL) ->
		return if not IsValid(ply)
		cmd = net.ReadString()
		return if not DPP2.cmd_remap[cmd]
		DPP2.cmd_remap[cmd](ply, net.ReadStringArray())

	for cmdName, cmdFunc in pairs(DPP2.cmd)
		if DPP2.cmd_perms[cmdName]
			choosePermName = DPP2.cmd_perms[cmdName]\startsWith('CAMI_') and DPP2.cmd_perms[cmdName]\sub(6) or ('dpp2_' .. cmdName)

			execute = (cmd = '', args = {}) =>
				if IsValid(@)
					CAMI.PlayerHasAccess @, choosePermName, (hasAccess = false, reason = '<unknown reason>') ->
						if not hasAccess
							DPP2.NotifyError(@, nil, 'command.dpp2.generic.noaccess_check', reason)
							return

						output = {cmdFunc(@, args, (...) -> DPP2.NotifyError(@, nil, ...))}
						return if #output == 0
						DPP2.NotifyError(@, nil, unpack(output, 1, #output))
				else
					output = {cmdFunc(@, args, DPP2.MessageError)}
					return if #output == 0
					DPP2.MessageError(unpack(output, 1, #output))

			if DPP2.cmd_autocomplete[cmdName]
				fcall = DPP2.cmd_autocomplete[cmdName]

				autocomplete = (cmd = '', args = '') ->
					ret = fcall(NULL, args\trim(), args)
					return {cmd} if not ret or #ret == 0
					output = [cmd .. ' ' .. val for val in *ret]
					return output

				concommand.Add 'dpp2_' .. cmdName, execute, autocomplete
			else
				concommand.Add 'dpp2_' .. cmdName, execute

			DPP2.cmd_remap[cmdName] = (ply, args) -> execute(ply, nil, args)
		else
			execute = (cmd = '', args = {}) =>
				if IsValid(@)
					output = {cmdFunc(@, args, (...) -> DPP2.NotifyError(@, nil, ...))}
					return if #output == 0
					DPP2.NotifyError(@, nil, unpack(output, 1, #output))
				else
					output = {cmdFunc(@, args, DPP2.MessageError)}
					return if #output == 0
					DPP2.MessageError(unpack(output, 1, #output))

			if DPP2.cmd_autocomplete[cmdName]
				fcall = DPP2.cmd_autocomplete[cmdName]

				autocomplete = (cmd = '', args = '') ->
					ret = fcall(NULL, args\trim(), args)
					return {cmd} if not ret or #ret == 0
					output = [cmd .. ' ' .. val for val in *ret]
					return output

				concommand.Add 'dpp2_' .. cmdName, execute, autocomplete
			else
				concommand.Add 'dpp2_' .. cmdName, execute

			DPP2.cmd_remap[cmdName] = (ply, args) -> execute(ply, nil, args)
elseif not game.SinglePlayer()
	DPP2.cmd_existing[cmd] = true for cmd in pairs(DPP2.cmd_autocomplete)

	for cmdName in pairs(DPP2.cmd_existing)
		execute = (cmd = '', args = {}) =>
			net.Start('dpp2_exec_concommand')
			net.WriteString(cmdName)
			net.WriteStringArray(args)
			net.SendToServer()

		DPP2.cmd_remap[cmdName] = (ply, args) -> execute(ply, nil, args)

		if DPP2.cmd_perms[cmdName]
			perm = DPP2.cmd_perms[cmdName]\startsWith('CAMI_') and DPP2.cmd_perms[cmdName]\sub(6) or ('dpp2_' .. cmdName)
			watchdog\Track(perm)

			local autocomplete

			if DPP2.cmd_autocomplete[cmdName]
				fcall = DPP2.cmd_autocomplete[cmdName]

				autocomplete = (cmd = '', args = '') ->
					return {cmd .. ' <No access!>'} if not watchdog\HasPermission(perm)
					ret = fcall(LocalPlayer(), args\trim(), args)
					return {cmd} if not ret or #ret == 0
					output = [cmd .. ' ' .. val for val in *ret]
					return output
			else
				autocomplete = (cmd = '', args = '') ->
					return {cmd} if watchdog\HasPermission(perm)
					return {cmd .. ' <No access!>'}

			concommand.Add 'dpp2_' .. cmdName, execute, autocomplete
		else
			if DPP2.cmd_autocomplete[cmdName]
				fcall = DPP2.cmd_autocomplete[cmdName]

				autocomplete = (cmd = '', args = '') ->
					ret = fcall(LocalPlayer(), args\trim(), args)
					return {cmd} if not ret or #ret == 0
					output = [cmd .. ' ' .. val for val in *ret]
					return output

				concommand.Add 'dpp2_' .. cmdName, execute, autocomplete
			else
				concommand.Add 'dpp2_' .. cmdName, execute

