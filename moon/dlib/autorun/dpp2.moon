
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

import DLib, notification, net, DLib from _G

export DPP2
_G.DPP2 = DPP2 or {}

DLib.CMessageChat(DPP2, 'DPP2')

DPP2.TYPE_BOOL = 0
DPP2.TYPE_INT = 1
DPP2.TYPE_FLOAT = 2

DPP2.CVarsRegistry = {}

DPP2.CreateConVar = (cvarName, cvarDef, cvarType) ->
	cvarDesc = 'gui.dpp2.cvars.' .. cvarName
	DPP2.Message('Missing langstring for: ' .. cvarName .. '; unlocalized name: ' .. cvarDesc) if DLib.i18n.localize(cvarDesc) == cvarDesc
	obj = DLib.util.CreateSharedConvar('dpp2_' .. cvarName, cvarDef, DLib.i18n.localize(cvarDesc))
	table.insert(DPP2.CVarsRegistry, {cvar: obj, :cvarName, :cvarDef, :cvarDesc, :cvarType})
	return obj

if CLIENT
	DPP2.ClientCVarsRegistry = {}

	DPP2.CreateClientConVar = (cvarName, cvarDef, cvarType, userinfo = true) ->
		cvarDesc = 'gui.dpp2.cvars.' .. cvarName
		DPP2.Message('Missing langstring for: ' .. cvarName .. '; unlocalized name: ' .. cvarDesc) if DLib.i18n.localize(cvarDesc) == cvarDesc
		obj = CreateConVar('dpp2_' .. cvarName, cvarDef, userinfo and {FCVAR_USERINFO, FCVAR_ARCHIVE} or {FCVAR_ARCHIVE}, DLib.i18n.localize(cvarDesc))
		table.insert(DPP2.ClientCVarsRegistry, {cvar: obj, :cvarName, :cvarDef, :cvarDesc, :cvarType, :userinfo})
		return obj


DPP2.ENABLE_PROTECTION = DPP2.CreateConVar('protection', '1', 'gui.dpp2.cvars.protection', DPP2.TYPE_BOOL)

AddCSLuaFile('dpp2/common/sh_logic.lua')
AddCSLuaFile('dpp2/common/sh_owning.lua')
AddCSLuaFile('dpp2/common/sh_hooks.lua')
AddCSLuaFile('dpp2/common/sh_cppi.lua')
AddCSLuaFile('dpp2/common/sh_registry.lua')
AddCSLuaFile('dpp2/client/cl_logic.lua')
AddCSLuaFile('dpp2/client/cl_owning.lua')

include('dpp2/common/sh_definition.lua')
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
include('dpp2/common/sh_cppi.lua')

if SERVER
	net.pool('dpp2_notify')

	DPP2.NotifyAll = (...) -> DPP2.Notify(player.GetAll(), ...)
	DPP2.NotifyCleanupAll = (...) -> DPP2.NotifyCleanup(player.GetAll(), ...)
	DPP2.NotifyHintAll = (...) -> DPP2.NotifyHint(player.GetAll(), ...)
	DPP2.NotifyUndoAll = (...) -> DPP2.NotifyUndo(player.GetAll(), ...)
	DPP2.NotifyErrorAll = (...) -> DPP2.NotifyError(player.GetAll(), ...)

	DPP2.Notify = (length = 5, ...) =>
		if type(@) ~= 'table' and not IsValid(@)
			DPP2.LMessage(...)
			return

		net.Start('dpp2_notify')
		net.WriteUInt8(NOTIFY_GENERIC)
		net.WriteUint16(length)
		net.WriteArray({...})
		net.Send(@)

	DPP2.NotifyError = (length = 5, ...) =>
		if type(@) ~= 'table' and not IsValid(@)
			DPP2.LMessageError(...)
			return

		net.Start('dpp2_notify')
		net.WriteUInt8(NOTIFY_ERROR)
		net.WriteUint16(length)
		net.WriteArray({...})
		net.Send(@)

	DPP2.NotifyHint = (length = 5, ...) =>
		if type(@) ~= 'table' and not IsValid(@)
			DPP2.LMessage('[HINT] ', ...)
			return

		net.Start('dpp2_notify')
		net.WriteUInt8(NOTIFY_HINT)
		net.WriteUint16(length)
		net.WriteArray({...})
		net.Send(@)

	DPP2.NotifyUndo = (length = 5, ...) =>
		if type(@) ~= 'table' and not IsValid(@)
			DPP2.LMessage(...)
			return

		net.Start('dpp2_notify')
		net.WriteUInt8(NOTIFY_UNDO)
		net.WriteUint16(length)
		net.WriteArray({...})
		net.Send(@)

	DPP2.NotifyCleanup = (length = 5, ...) =>
		if type(@) ~= 'table' and not IsValid(@)
			DPP2.LMessage(...)
			return

		net.Start('dpp2_notify')
		net.WriteUInt8(NOTIFY_CLEANUP)
		net.WriteUint16(length)
		net.WriteArray({...})
		net.Send(@)
else
	DPP2.Notify = (length = 5, ...) =>
		strings = [arg for arg in *DPP2.LMessage(...) when type(arg) == 'string']
		notification.AddLegacy(table.concat(strings, ' '), NOTIFY_GENERIC, length)

	DPP2.NotifyError = (length = 5, ...) =>
		strings = [arg for arg in *DPP2.LMessageError(...) when type(arg) == 'string']
		notification.AddLegacy(table.concat(strings, ' '), NOTIFY_ERROR, length)

	DPP2.NotifyUndo = (length = 5, ...) =>
		strings = [arg for arg in *DPP2.LMessage(...) when type(arg) == 'string']
		notification.AddLegacy(table.concat(strings, ' '), NOTIFY_UNDO, length)

	DPP2.NotifyCleanup = (length = 5, ...) =>
		strings = [arg for arg in *DPP2.LMessage(...) when type(arg) == 'string']
		notification.AddLegacy(table.concat(strings, ' '), NOTIFY_CLEANUP, length)

	DPP2.NotifyHint = (length = 5, ...) =>
		DPP2.LMessage('[HINT]', ...)
		strings = [arg for arg in *DPP2.LFormatMessageRaw(...) when type(arg) == 'string']
		notification.AddLegacy(table.concat(strings, ' '), NOTIFY_HINT, length)

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

DPP2.PhysgunProtection = DPP2.DEF.ProtectionDefinition('physgun')
DPP2.ToolgunProtection = DPP2.DEF.ProtectionDefinition('toolgun')

with DrivePrefab = DPP2.DEF.DefinitionConVarsPrefab()
	\SetNoWorldTouch(true)
	\SetNoWorldTouchAdmin(true)
	DPP2.DriveProtection = DPP2.DEF.ProtectionDefinition('drive', DrivePrefab)

with AllowMapPrefab = DPP2.DEF.DefinitionConVarsPrefab()
	\SetNoMapTouch(false)
	\SetNoMapTouchAdmin(false)
	\SetNoWorldTouch(false)
	\SetNoWorldTouchAdmin(false)
	DPP2.DamageProtection = DPP2.DEF.ProtectionDefinition('damage', AllowMapPrefab)
	DPP2.PickupProtection = DPP2.DEF.ProtectionDefinition('pickup', AllowMapPrefab)
	DPP2.UseProtection = DPP2.DEF.ProtectionDefinition('use', AllowMapPrefab)
	DPP2.VehicleProtection = DPP2.DEF.ProtectionDefinition('vehicle', AllowMapPrefab)
	DPP2.GravgunProtection = DPP2.DEF.ProtectionDefinition('gravgun', AllowMapPrefab)
