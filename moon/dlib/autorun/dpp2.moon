
-- Copyright (C) 2018-2019 DBotThePony

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

import DLib, notification, net, DLib from _G

export DPP2
_G.DPP2 = DPP2 or {}

startup = SysTime()

DLib.CMessageChat(DPP2, 'DPP2')

if SERVER
	file.mkdir('dpp2')
	file.mkdir('dpp2/backup')

DPP2.TYPE_BOOL = 0
DPP2.TYPE_INT = 1
DPP2.TYPE_FLOAT = 2
DPP2.TYPE_UINT = 3
DPP2.TYPE_UFLOAT = 4

DPP2.CVarsRegistry = {}

DPP2.CreateConVar = (cvarName, cvarDef, cvarType) ->
	cvarDesc = 'gui.dpp2.cvars.' .. cvarName
	DPP2.Message('Missing langstring for: ' .. cvarName .. '; unlocalized name: ' .. cvarDesc) if not DLib.i18n.exists(cvarDesc)
	obj = DLib.util.CreateSharedConvar('dpp2_' .. cvarName, cvarDef, DLib.i18n.localize(cvarDesc))
	table.insert(DPP2.CVarsRegistry, {cvar: obj, :cvarName, :cvarDef, :cvarDesc, :cvarType})
	return obj

if CLIENT
	DPP2.ClientCVarsRegistry = {}

	DPP2.CreateClientConVar = (cvarName, cvarDef, cvarType, userinfo = true) ->
		cvarDesc = 'gui.dpp2.cvars.' .. cvarName
		DPP2.Message('Missing langstring for: ' .. cvarName .. '; unlocalized name: ' .. cvarDesc) if not DLib.i18n.exists(cvarDesc)
		obj = CreateConVar('dpp2_' .. cvarName, cvarDef, userinfo and {FCVAR_USERINFO, FCVAR_ARCHIVE} or {FCVAR_ARCHIVE}, DLib.i18n.localize(cvarDesc))
		table.insert(DPP2.ClientCVarsRegistry, {cvar: obj, :cvarName, :cvarDef, :cvarDesc, :cvarType, :userinfo})
		return obj

DLib.i18n.reload('dpp2')

DPP2.CheckPhrase = (name) -> DPP2.Message('Missing langstring for: ' .. name) if not DLib.i18n.exists(name)

DPP2.ENABLE_PROTECTION = DPP2.CreateConVar('protection', '1', DPP2.TYPE_BOOL)
DPP2.CL_ENABLE_PROTECTION = DPP2.CreateClientConVar('cl_protection', '1', DPP2.TYPE_BOOL) if CLIENT
DPP2.NO_TOOLGUN_PLAYER = DPP2.CreateConVar('no_tool_player', '1', DPP2.TYPE_BOOL)
DPP2.NO_TOOLGUN_PLAYER_ADMIN = DPP2.CreateConVar('no_tool_player_admin', '0', DPP2.TYPE_BOOL)

CAMI.RegisterPrivilege({
	Name: 'dpp2_log'
	MinAccess: 'admin'
	Description: 'Viewing DPP/2 logs'
})

CAMI.RegisterPrivilege({
	Name: 'dpp2_setvar'
	MinAccess: 'superadmin'
	Description: 'Change DPP/2 ConVars'
})

AddCSLuaFile('dpp2/common/sh_logic.lua')
AddCSLuaFile('dpp2/common/sh_owning.lua')
AddCSLuaFile('dpp2/common/sh_hooks.lua')
AddCSLuaFile('dpp2/common/sh_cppi.lua')
AddCSLuaFile('dpp2/common/sh_functions.lua')
AddCSLuaFile('dpp2/common/sh_registry.lua')
AddCSLuaFile('dpp2/common/sh_transfer.lua')
AddCSLuaFile('dpp2/common/sh_count.lua')
AddCSLuaFile('dpp2/client/cl_logic.lua')
AddCSLuaFile('dpp2/client/cl_owning.lua')
AddCSLuaFile('dpp2/client/cl_transfer.lua')
AddCSLuaFile('dpp2/client/cl_properties.lua')
AddCSLuaFile('dpp2/client/cl_sharing.lua')
AddCSLuaFile('dpp2/client/settings/cl_convars.lua')
AddCSLuaFile('dpp2/client/settings/cl_menus.lua')
AddCSLuaFile('dpp2/client/settings/cl_registry_menus.lua')
AddCSLuaFile('dpp2/client/settings/cl_settings.lua')
AddCSLuaFile('dpp2/client/settings/cl_playerutil.lua')
AddCSLuaFile('dpp2/client/cl_spawnmenu.lua')
AddCSLuaFile('dpp2/common/concommands/sh_cmdlogic.lua')
AddCSLuaFile('dpp2/common/concommands/sh_generic.lua')
AddCSLuaFile('dpp2/common/concommands/sh_registry.lua')
AddCSLuaFile('dpp2/common/concommands/sh_sharing.lua')

DPP2.Menus = {} if CLIENT
DPP2.cmd = {} if SERVER
DPP2.cmd_existing = {} if CLIENT
DPP2.cmd_autocomplete = {}
DPP2.cmd_perms = {}

include('dpp2/common/sh_convars.lua')
include('dpp2/server/sv_functions.lua') if SERVER
include('dpp2/common/sh_definition.lua')
include('dpp2/common/sh_functions.lua')
include('dpp2/common/sh_owning.lua')
include('dpp2/client/cl_owning.lua') if CLIENT
include('dpp2/server/sv_owning.lua') if SERVER
include('dpp2/common/sh_registry.lua')
include('dpp2/common/sh_logic.lua')
include('dpp2/common/sh_hooks.lua')
include('dpp2/client/cl_logic.lua') if CLIENT
include('dpp2/server/sv_logic.lua') if SERVER
include('dpp2/server/sv_owning.lua') if SERVER
include('dpp2/server/sv_hooks.lua') if SERVER
include('dpp2/server/sv_patches.lua') if SERVER
include('dpp2/server/sv_antipropkill.lua') if SERVER
include('dpp2/server/sv_antispam.lua') if SERVER
include('dpp2/common/sh_transfer.lua')
include('dpp2/server/sv_transfer.lua') if SERVER
include('dpp2/client/cl_transfer.lua') if CLIENT
include('dpp2/server/sv_count.lua') if SERVER
include('dpp2/common/sh_count.lua')
include('dpp2/client/cl_count.lua') if CLIENT
include('dpp2/common/sh_cppi.lua')
include('dpp2/server/sv_logging.lua') if SERVER

if SERVER
	net.pool('dpp2_notify')

	DPP2.NotifyAll = (...) -> DPP2.Notify(player.GetAll(), ...)
	DPP2.NotifyCleanupAll = (...) -> DPP2.NotifyCleanup(player.GetAll(), ...)
	DPP2.NotifyHintAll = (...) -> DPP2.NotifyHint(player.GetAll(), ...)
	DPP2.NotifyUndoAll = (...) -> DPP2.NotifyUndo(player.GetAll(), ...)
	DPP2.NotifyErrorAll = (...) -> DPP2.NotifyError(player.GetAll(), ...)

	DPP2.Notify = (length = 5, ...) =>
		if @ == false
			DPP2.LMessage(...)
			return

		if @ == true
			DPP2.LMessage(...)
			DPP2.Notify(player.GetAll(), length, ...)
			return

		if type(@) ~= 'table' and not IsValid(@)
			DPP2.LMessage(...)
			return

		net.Start('dpp2_notify')
		net.WriteUInt8(NOTIFY_GENERIC)
		net.WriteUInt16(length)
		net.WriteArray({...})
		net.Send(@)

	DPP2.NotifyError = (length = 5, ...) =>
		if @ == false
			DPP2.LMessageError(...)
			return

		if @ == true
			DPP2.LMessageError(...)
			DPP2.NotifyError(player.GetAll(), length, ...)
			return

		if type(@) ~= 'table' and not IsValid(@)
			DPP2.LMessageError(...)
			return

		net.Start('dpp2_notify')
		net.WriteUInt8(NOTIFY_ERROR)
		net.WriteUInt16(length)
		net.WriteArray({...})
		net.Send(@)

	DPP2.NotifyHint = (length = 5, ...) =>
		if @ == false
			DPP2.LMessage('[HINT] ', ...)
			return

		if @ == true
			DPP2.LMessage('[HINT] ', ...)
			DPP2.NotifyHint(player.GetAll(), length, ...)
			return

		if type(@) ~= 'table' and not IsValid(@)
			DPP2.LMessage('[HINT] ', ...)
			return

		net.Start('dpp2_notify')
		net.WriteUInt8(NOTIFY_HINT)
		net.WriteUInt16(length)
		net.WriteArray({...})
		net.Send(@)

	DPP2.NotifyUndo = (length = 5, ...) =>
		if @ == false
			DPP2.LMessage(...)
			return

		if @ == true
			DPP2.LMessage(...)
			DPP2.NotifyUndo(player.GetAll(), length, ...)
			return

		if type(@) ~= 'table' and not IsValid(@)
			DPP2.LMessage(...)
			return

		net.Start('dpp2_notify')
		net.WriteUInt8(NOTIFY_UNDO)
		net.WriteUInt16(length)
		net.WriteArray({...})
		net.Send(@)

	DPP2.NotifyCleanup = (length = 5, ...) =>
		if @ == false
			DPP2.LMessage(...)
			return

		if @ == true
			DPP2.LMessage(...)
			DPP2.NotifyCleanup(player.GetAll(), length, ...)
			return

		if type(@) ~= 'table' and not IsValid(@)
			DPP2.LMessage(...)
			return

		net.Start('dpp2_notify')
		net.WriteUInt8(NOTIFY_CLEANUP)
		net.WriteUInt16(length)
		net.WriteArray({...})
		net.Send(@)
else
	lastsound = 0

	playsound = (sound) ->
		return if lastsound > RealTime()
		surface.PlaySound(sound)
		lastsound = RealTime() + 0.1

	DPP2.Notify = (length = 5, ...) =>
		strings = [arg for arg in *DPP2.LMessage(...) when type(arg) == 'string']
		notification.AddLegacy(table.concat(strings, ' '), NOTIFY_GENERIC, length)
		playsound('buttons/lightswitch2.wav')

	DPP2.NotifyError = (length = 5, ...) =>
		strings = [arg for arg in *DPP2.LMessageError(...) when type(arg) == 'string']
		notification.AddLegacy(table.concat(strings, ' '), NOTIFY_ERROR, length)
		playsound('buttons/button10.wav')

	DPP2.NotifyUndo = (length = 5, ...) =>
		strings = [arg for arg in *DPP2.LMessage(...) when type(arg) == 'string']
		notification.AddLegacy(table.concat(strings, ' '), NOTIFY_UNDO, length)
		playsound('buttons/button15.wav')

	DPP2.NotifyCleanup = (length = 5, ...) =>
		strings = [arg for arg in *DPP2.LMessage(...) when type(arg) == 'string']
		notification.AddLegacy(table.concat(strings, ' '), NOTIFY_CLEANUP, length)
		playsound('buttons/button15.wav')

	DPP2.NotifyHint = (length = 5, ...) =>
		DPP2.LMessage('[HINT] ', ...)
		strings = [arg for arg in *DPP2.LFormatMessageRaw(...) when type(arg) == 'string']
		notification.AddLegacy(table.concat(strings, ' '), NOTIFY_HINT, length)
		playsound('buttons/combine_button1.wav')

	net.receive 'dpp2_notify', ->
		switch net.ReadUInt8()
			when NOTIFY_ERROR
				DPP2.NotifyError(nil, net.ReadUInt16(), unpack(net.ReadArray()))
			when NOTIFY_UNDO
				DPP2.NotifyUndo(nil, net.ReadUInt16(), unpack(net.ReadArray()))
			when NOTIFY_CLEANUP
				DPP2.NotifyCleanup(nil, net.ReadUInt16(), unpack(net.ReadArray()))
			when NOTIFY_HINT
				DPP2.NotifyHint(nil, net.ReadUInt16(), unpack(net.ReadArray()))
			when NOTIFY_GENERIC
				DPP2.Notify(nil, net.ReadUInt16(), unpack(net.ReadArray()))

include('dpp2/common/concommands/sh_registry.lua')
include('dpp2/client/settings/cl_registry_menus.lua') if CLIENT

DPP2.PhysgunProtection = DPP2.DEF.ProtectionDefinition('physgun', nil, true, true, true)
DPP2.ToolgunProtection = DPP2.DEF.ProtectionDefinition('toolgun', nil, true, true, true)

with DrivePrefab = DPP2.DEF.DefinitionConVarsPrefab()
	\SetNoWorldTouch(true)
	\SetNoWorldTouchAdmin(true)
	DPP2.DriveProtection = DPP2.DEF.ProtectionDefinition('drive', DrivePrefab, true, true, true)

with AllowMapPrefab = DPP2.DEF.DefinitionConVarsPrefab()
	\SetNoMapTouch(false)
	\SetNoMapTouchAdmin(false)
	\SetNoWorldTouch(false)
	\SetNoWorldTouchAdmin(false)
	DPP2.DamageProtection = DPP2.DEF.ProtectionDefinition('damage', AllowMapPrefab, true, true, true)
	DPP2.PickupProtection = DPP2.DEF.ProtectionDefinition('pickup', AllowMapPrefab, true, true, true)
	DPP2.UseProtection = DPP2.DEF.ProtectionDefinition('use', AllowMapPrefab, true, true, true)
	DPP2.VehicleProtection = DPP2.DEF.ProtectionDefinition('vehicle', AllowMapPrefab, true, true, true)
	DPP2.GravgunProtection = DPP2.DEF.ProtectionDefinition('gravgun', AllowMapPrefab, true, true, true)

DPP2.ModelBlacklist = DPP2.DEF.Blacklist('model', DPP2.ModelAutocomplete)
DPP2.ModelExclusions = DPP2.DEF.Exclusion('model', DPP2.ModelAutocomplete)
DPP2.ToolgunModeExclusions = DPP2.DEF.Exclusion('toolgun_mode', DPP2.ToolgunModeAutocomplete)

DPP2.ToolgunModeRestrictions = DPP2.DEF.RestrictionList('toolgun_mode', DPP2.ToolgunModeAutocomplete)
DPP2.SpawnRestrictions = DPP2.DEF.RestrictionList('class_spawn', DPP2.ClassnameAutocomplete)

include('dpp2/server/concommands/sv_generic.lua') if SERVER
include('dpp2/common/concommands/sh_generic.lua')
include('dpp2/common/concommands/sh_sharing.lua')
include('dpp2/server/concommands/sv_sharing.lua') if SERVER
include('dpp2/common/concommands/sh_cmdlogic.lua')

if CLIENT
	include('dpp2/client/settings/cl_convars.lua')
	include('dpp2/client/settings/cl_menus.lua')
	include('dpp2/client/settings/cl_settings.lua')
	include('dpp2/client/settings/cl_playerutil.lua')

	include('dpp2/client/cl_properties.lua')
	include('dpp2/client/cl_sharing.lua')

	include('dpp2/client/cl_spawnmenu.lua')

DPP2.Message(string.format('DPP/2 Startup took %.2f ms', SysTime() - startup))

return
