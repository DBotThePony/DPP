
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

import DPP2, type, table from _G
import i18n from DLib

DPP2.DEF = DPP2.DEF or {}

class DPP2.DEF.DefinitionConVarsPrefab
	new: =>
		@enabled = true
		@adminTouchAny = true
		@noWorldTouch = false
		@noWorldTouchAdmin = false
		@noMapTouch = true
		@noMapTouchAdmin = true

	SetEnabled: (enabled = @enabled) => @enabled = enabled
	SetAdminTouchAny: (adminTouchAny = @adminTouchAny) => @adminTouchAny = adminTouchAny
	SetNoWorldTouch: (noWorldTouch = @noWorldTouch) => @noWorldTouch = noWorldTouch
	SetNoWorldTouchAdmin: (noWorldTouchAdmin = @noWorldTouchAdmin) => @noWorldTouchAdmin = noWorldTouchAdmin
	SetNoMapTouch: (noMapTouch = @noMapTouch) => @noMapTouch = noMapTouch
	SetNoMapTouchAdmin: (noMapTouchAdmin = @noMapTouchAdmin) => @noMapTouchAdmin = noMapTouchAdmin

	GetEnabled: => @enabled and '1' or '0'
	GetAdminTouchAny: => @adminTouchAny and '1' or '0'
	GetNoWorldTouch: => @noWorldTouch and '1' or '0'
	GetNoWorldTouchAdmin: => @noWorldTouchAdmin and '1' or '0'
	GetNoMapTouch: => @noMapTouch and '1' or '0'
	GetNoMapTouchAdmin: => @noMapTouchAdmin and '1' or '0'

class DPP2.DEF.ProtectionDefinition
	@OBJECTS = {}
	@OBJECTS_MAP = {}

	if SERVER
		hook.Add 'PlayerDisconnected', 'DPP2.DEF.ProtectionDefinition', (ply) -> @PlayerDisconnected(ply)
	else
		gameevent.Listen('player_disconnect')
		hook.Add 'player_disconnect', 'DPP2.DEF.ProtectionDefinition', (data) -> @PlayerDisconnected(Player(data.userid))

	@PlayerDisconnected = (ply) =>
		return if not ply\IsValid()
		return if ply\IsBot()
		return if not ply\DPP2HasEnts()

		obj\PlayerDisconnected(ply) for obj in *@OBJECTS

		timer.Create 'DPP2.FriendStatus.' .. steamid, 360, 0, ->
			return if DPP2.HasEntsBySteamID(steamid)
			obj\PruneFriendData(steamid) for obj in *@OBJECTS
			timer.Remove('DPP2.FriendStatus.' .. steamid)

	new: (classname, prefab = DPP2.DEF.DefinitionConVarsPrefab()) =>
		@friendsCache = {}
		@disabledCache = {}
		table.insert(@@OBJECTS, @)

		@name = assert(type(classname) == 'string' and classname, 'Invalid definition classname')\lower()

		@@OBJECTS_MAP[@name] = @

		@enabled =              DPP2.CreateConVar(@name .. '_protection', prefab\GetEnabled(),                  DPP2.TYPE_BOOL)
		@adminTouchAny =        DPP2.CreateConVar(@name .. '_touch_any', prefab\GetAdminTouchAny(),             DPP2.TYPE_BOOL)
		@noWorldTouch =         DPP2.CreateConVar(@name .. '_no_world', prefab\GetNoWorldTouch(),               DPP2.TYPE_BOOL)
		@noWorldTouchAdmin =    DPP2.CreateConVar(@name .. '_no_world_admin', prefab\GetNoWorldTouchAdmin(),    DPP2.TYPE_BOOL)
		@noMapTouch =           DPP2.CreateConVar(@name .. '_no_map', prefab\GetNoMapTouch(),                   DPP2.TYPE_BOOL)
		@noMapTouchAdmin =      DPP2.CreateConVar(@name .. '_no_map_admin', prefab\GetNoMapTouchAdmin(),        DPP2.TYPE_BOOL)

		@clEnabledName = 'dpp2_cl_' .. @name .. '_protection'
		@disableNWName = 'dpp2_' .. @name .. '_dp'

		@clientNoTouchOtherName = 'dpp2_cl_' .. @name .. '_no_other'
		@clientNoWorldName = 'dpp2_cl_' .. @name .. '_no_world'
		@clientNoMapName = 'dpp2_cl_' .. @name .. '_no_map'
		@clientNoPlayersName = 'dpp2_cl_' .. @name .. '_no_players'

		@sharingVarID = 'dpp2_s_' .. @name

		if CLIENT
			@enabledClient = DPP2.CreateClientConVar('cl_' .. @name .. '_protection', '1', DPP2.TYPE_BOOL)
			@clientNoTouchOther = DPP2.CreateClientConVar('cl_' .. @name .. '_no_other', '0', DPP2.TYPE_BOOL)
			@clientNoWorld = DPP2.CreateClientConVar('cl_' .. @name .. '_no_world', '0', DPP2.TYPE_BOOL)
			@clientNoMap = DPP2.CreateClientConVar('cl_' .. @name .. '_no_map', '0', DPP2.TYPE_BOOL)
			@clientNoPlayers = DPP2.CreateClientConVar('cl_' .. @name .. '_no_players', '0', DPP2.TYPE_BOOL)

		@camiwatchdog =         DLib.CAMIWatchdog('dpp2_' .. @name .. '_protection', 10)

		@friendID = 'dpp2_' .. @name
		DPP2.Message('Missing langstring for gui.dpp2.buddystatus.' .. @name) if DLib.i18n.localize('gui.dpp2.buddystatus.' .. @name) == 'gui.dpp2.buddystatus.' .. @name
		DLib.friends.Register(@friendID, 'gui.dpp2.buddystatus.' .. @name, true)

		CAMI.RegisterPrivilege({
			Name: 'dpp2_' .. @name .. '_admin'
			MinAccess: 'admin'
			Description: 'DPP/2 Module ' .. @name .. ' treats player as admin'
		})

		CAMI.RegisterPrivilege({
			Name: 'dpp2_' .. @name .. '_map_admin'
			MinAccess: 'superadminadmin'
			Description: 'DPP/2 Module ' .. @name .. ' treats player as map admin'
		})

		@otherPermString = 'dpp2_' .. @name .. '_admin'
		@otherPermStringMap = 'dpp2_' .. @name .. '_map_admin'

		@camiwatchdog\Track('dpp2_' .. @name .. '_admin')
		@camiwatchdog\Track('dpp2_' .. @name .. '_map_admin')

	IsEnabled: => @enabled\GetBool() and DPP2.ENABLE_PROTECTION\GetBool()

	SwitchProtectionDisableFor: (ply = NULL, status = false) =>
		error('Tried to use a NULL Entity!') if not ply\IsValid()
		error('Tried to use a ' .. type(ply) .. ' instead of Player') if not ply\IsPlayer()

		if status then @EnableProtectionFor(ply) else @DisableProtectionFor(ply)

	EnableProtectionFor: (ply) =>
		error('Invalid side') if CLIENT
		ply\SetNWBool(@disableNWName, nil)
		return @

	DisableProtectionFor: (ply) =>
		error('Invalid side') if CLIENT
		ply\SetNWBool(@disableNWName, true)
		return @

	IsDisabledForPlayer: (ply = NULL) =>
		return false if not ply\IsValid()
		return not ply\GetInfoBool(@clEnabledName, true) or ply\GetNWBool(@disableNWName, false)

	IsDisabledForSteamID: (steamid) =>
		return @disabledCache[steamid] if @disabledCache[steamid] ~= nil
		return false

	IsShared: (ent = NULL) =>
		return false if not ent\IsValid()
		return ent\GetNWBool(@sharingVarID, false)

	SetIsShared: (ent = NULL, newMode = false, flush = true) =>
		return false if not ent\IsValid()
		return false if ent\GetNWBool(@sharingVarID, false) == newMode

		if newMode
			ent\SetNWBool(@sharingVarID, true)
		else
			ent\SetNWBool(@sharingVarID, nil)

		if flush and not newMode
			hit = false

			for obj in *@@OBJECTS
				if obj\IsShared(ent)
					hit = true
					break

			if not hit
				ent\SetNWBool('dpp2_s', nil)
			else
				ent\SetNWBool('dpp2_s', true)
		elseif flush and newMode
			ent\SetNWBool('dpp2_s', true)

		return true

	ForcePruneFriends: =>
		toRemove = {}

		for steamid in pairs(@friendsCache)
			if not DPP2.HasEntsBySteamID(steamid)
				table.insert(toRemove, steamid)
				timer.Remove('DPP2.FriendStatus.' .. steamid)

		@friendsCache[k] = nil for k in *toRemove
		@disabledCache[k] = nil for k in *toRemove

	PruneFriendData: (steamid) =>
		@friendsCache[steamid] = nil
		@disabledCache[steamid] = nil

	PlayerDisconnected: (ply = NULL) =>
		@friendsCache[ply\SteamID()] = {ply2\SteamID(), ply2\CheckDLibFriendInOverride(ply, @friendID) for ply2 in *player.GetAll()}
		@disabledCache[ply\SteamID()] = @IsDisabledForPlayer(ply)

	CanTouchWorld: (ply = NULL) =>
		return true if not ply\IsValid()
		return false, i18n.localize('gui.dpp2.access.status.yoursettings') if ply\GetInfoBool(@clientNoWorldName, false)
		return true if not @IsEnabled()

		return not @noWorldTouch\GetBool() or not @noWorldTouchAdmin\GetBool() if @camiwatchdog\HasPermission(ply, @otherPermString)
		return not @noWorldTouch\GetBool()

	CanTouchMap: (ply = NULL) =>
		return true if not ply\IsValid()
		return false, i18n.localize('gui.dpp2.access.status.yoursettings') if ply\GetInfoBool(@clientNoMapName, false)
		return true if not @IsEnabled()

		return not @noMapTouch\GetBool() or not @noMapTouchAdmin\GetBool() if @camiwatchdog\HasPermission(ply, @otherPermStringMap)
		return not @noMapTouch\GetBool()

	CanTouchOther: (ply = NULL, other = NULL) =>
		return true if not ply\IsValid()
		return @CanTouchWorld(ply) if other == 'world'
		return @CanTouchMap(ply) if other == 'map'
		return false, i18n.localize('gui.dpp2.access.status.yoursettings') if ply\GetInfoBool(@clientNoTouchOtherName, false)
		return true if not @IsEnabled()

		return true if @camiwatchdog\HasPermission(ply, @otherPermString) and @adminTouchAny\GetBool()

		if type(other) == 'string'
			getply = player.GetBySteamID(other)

			if getply
				return true, i18n.localize('gui.dpp2.access.status.ownerdisabled') if @IsDisabledForPlayer(getply)
				return getply\CheckDLibFriendInOverride(ply, @friendID)

			return true, i18n.localize('gui.dpp2.access.status.ownerdisabled') if @IsDisabledForSteamID(other)

			steamid = ply\SteamID()
			return @friendsCache[other][steamid], i18n.localize('gui.dpp2.access.status.friend') if @friendsCache[other][steamid] ~= nil
		elseif IsValid(other)
			return true, i18n.localize('gui.dpp2.access.status.ownerdisabled') if @IsDisabledForPlayer(other)
			return other\CheckDLibFriendInOverride(ply, @friendID), i18n.localize('gui.dpp2.access.status.friend')

		return false, i18n.localize('gui.dpp2.access.status.friend')

	CanTouch: (ply = NULL, ent = NULL) =>
		return true if not ply\IsValid()
		return false if not ent\IsValid()
		return false, i18n.localize('gui.dpp2.access.status.yoursettings') if ent\IsPlayer() and ply\GetInfoBool(@clientNoPlayersName, false)
		return true, i18n.localize('gui.dpp2.access.status.disabled') if not @IsEnabled()
		contraption = ent\DPP2GetContraption()

		if not contraption
			owner, ownerSteamID, ownerNick = ent\DPP2GetOwner()
			return true if owner == ply
			return @CanTouchMap(ply), i18n.localize('gui.dpp2.access.status.map') if ownerSteamID == 'world' and ent\CreatedByMap()
			return @CanTouchWorld(ply), i18n.localize('gui.dpp2.access.status.world') if ownerSteamID == 'world'
			return @CanTouchOther(ply, ownerSteamID)

		steamid = ply\SteamID()

		for ownerSteamID in *contraption\GetOwnersPartial(@name)
			if steamid ~= ownerSteamID
				return false, i18n.localize('gui.dpp2.access.status.map'), i18n.localize('gui.dpp2.access.status.contraption') if ownerSteamID == 'world' and ent\CreatedByMap() and not @CanTouchMap(ply)
				return false, i18n.localize('gui.dpp2.access.status.world'), i18n.localize('gui.dpp2.access.status.contraption') if ownerSteamID == 'world' and not @CanTouchWorld(ply)
				return false, i18n.localize('gui.dpp2.access.status.friend'), i18n.localize('gui.dpp2.access.status.contraption') if ownerSteamID ~= 'world' and not @CanTouchOther(ply, ownerSteamID)

		return true, i18n.localize('gui.dpp2.access.status.contraption')

entMeta = FindMetaTable('Entity')

entMeta.DPP2IsShared = (mode) =>
	return false if @IsPlayer()
	return false if not @IsValid()
	return @GetNWBool('dpp2_s', false) if not mode
	return @GetNWBool('dpp2_s_' .. mode, false)

entMeta.DPP2SetIsShared = (mode, newMode, flush) =>
	return false if @IsPlayer()
	return false if not @IsValid()
	return false if not DPP2.DEF.ProtectionDefinition.OBJECTS_MAP[mode]
	return DPP2.DEF.ProtectionDefinition.OBJECTS_MAP[mode]\SetIsShared(@, newMode, flush)
