
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

import DPP2, type, table from _G
import i18n from DLib

DPP2.DEF = DPP2.DEF or {}

DPP2.NO_DEF_CACHE = DPP2.CreateConVar('no_def_cache', '0', DPP2.TYPE_BOOL)

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

	@Get = (name) => @OBJECTS_MAP[assert(isstring(name) and name\lower()\trim(), 'identifier must be a string! typeof ' .. type(name))] or false

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
		steamid = ply\SteamID()

		timer.Create 'DPP2.FriendStatus.' .. steamid, 360, 0, ->
			return if DPP2.HasEntsBySteamID(steamid)
			obj\PruneFriendData(steamid) for obj in *@OBJECTS
			timer.Remove('DPP2.FriendStatus.' .. steamid)

	new: (identifier, prefab = DPP2.DEF.DefinitionConVarsPrefab(), classnameRestriction = false, classnameBlacklist = false, classnameExclusionList = false) =>
		@identifier = assert(type(identifier) == 'string' and identifier, 'Invalid definition identifier')\lower()
		assert(not @@OBJECTS_MAP[identifier], 'cannot redefine already existing ProtectionDefinition[' .. identifier .. ']!')
		@friendsCache = {}
		@disabledCache = {}
		table.insert(@@OBJECTS, @)

		if classnameRestriction == true
			@classnameRestriction = DPP2.DEF.RestrictionList(identifier, DPP2.ClassnameAutocomplete)
		elseif classnameRestriction
			@classnameRestriction = classnameRestriction

		if classnameBlacklist == true
			@classnameBlacklist = DPP2.DEF.Blacklist(identifier, DPP2.ClassnameAutocomplete)
		elseif classnameBlacklist
			@classnameBlacklist = classnameBlacklist

		if classnameExclusionList == true
			@classnameExclusionList = DPP2.DEF.Exclusion(identifier, DPP2.ClassnameAutocomplete)
		elseif classnameExclusionList
			@classnameExclusionList = classnameExclusionList

		@RestrictionList = @classnameRestriction
		@Blacklist = @classnameBlacklist
		@Exclusions = @classnameExclusionList

		@@OBJECTS_MAP[@identifier] = @

		@enabled =              DPP2.CreateConVar(@identifier .. '_protection', prefab\GetEnabled(),                  DPP2.TYPE_BOOL)
		@adminTouchAny =        DPP2.CreateConVar(@identifier .. '_touch_any', prefab\GetAdminTouchAny(),             DPP2.TYPE_BOOL)
		@noWorldTouch =         DPP2.CreateConVar(@identifier .. '_no_world', prefab\GetNoWorldTouch(),               DPP2.TYPE_BOOL)
		@noWorldTouchAdmin =    DPP2.CreateConVar(@identifier .. '_no_world_admin', prefab\GetNoWorldTouchAdmin(),    DPP2.TYPE_BOOL)
		@noMapTouch =           DPP2.CreateConVar(@identifier .. '_no_map', prefab\GetNoMapTouch(),                   DPP2.TYPE_BOOL)
		@noMapTouchAdmin =      DPP2.CreateConVar(@identifier .. '_no_map_admin', prefab\GetNoMapTouchAdmin(),        DPP2.TYPE_BOOL)

		clearcachecallback = -> @ClearEntireCache()
		cvars.AddChangeCallback('dpp2_' .. @identifier .. '_protection', clearcachecallback, 'DPP2')
		cvars.AddChangeCallback('dpp2_' .. @identifier .. '_touch_any', clearcachecallback, 'DPP2')
		cvars.AddChangeCallback('dpp2_' .. @identifier .. '_no_world', clearcachecallback, 'DPP2')
		cvars.AddChangeCallback('dpp2_' .. @identifier .. '_no_world_admin', clearcachecallback, 'DPP2')
		cvars.AddChangeCallback('dpp2_' .. @identifier .. '_no_map', clearcachecallback, 'DPP2')
		cvars.AddChangeCallback('dpp2_' .. @identifier .. '_no_map_admin', clearcachecallback, 'DPP2')

		@clEnabledName = 'dpp2_cl_' .. @identifier .. '_protection'
		@disableNWName = 'dpp2_' .. @identifier .. '_dp'
		@lock_self_nwname = 'dpp2_' .. @identifier .. '_ls'
		@lock_others_nwname = 'dpp2_' .. @identifier .. '_lo'

		@clientNoTouchOtherName = 'dpp2_cl_' .. @identifier .. '_no_other'
		@clientNoWorldName = 'dpp2_cl_' .. @identifier .. '_no_world'
		@clientNoMapName = 'dpp2_cl_' .. @identifier .. '_no_map'
		@clientNoPlayersName = 'dpp2_cl_' .. @identifier .. '_no_players'

		@sharingVarID = 'dpp2_s_' .. @identifier

		if CLIENT
			@enabledClient = DPP2.CreateClientConVar('cl_' .. @identifier .. '_protection', '1', DPP2.TYPE_BOOL)
			@clientNoTouchOther = DPP2.CreateClientConVar('cl_' .. @identifier .. '_no_other', '0', DPP2.TYPE_BOOL)
			@clientNoWorld = DPP2.CreateClientConVar('cl_' .. @identifier .. '_no_world', '0', DPP2.TYPE_BOOL)
			@clientNoMap = DPP2.CreateClientConVar('cl_' .. @identifier .. '_no_map', '0', DPP2.TYPE_BOOL)
			@clientNoPlayers = DPP2.CreateClientConVar('cl_' .. @identifier .. '_no_players', '0', DPP2.TYPE_BOOL)

		@camiwatchdog =         DLib.CAMIWatchdog('dpp2_' .. @identifier .. '_protection', 10)

		@friendID = 'dpp2_' .. @identifier
		DPP2.Message('Missing langstring for gui.dpp2.buddystatus.' .. @identifier) if DLib.i18n.localize('gui.dpp2.buddystatus.' .. @identifier) == 'gui.dpp2.buddystatus.' .. @identifier
		DLib.friends.Register(@friendID, 'gui.dpp2.buddystatus.' .. @identifier, true)

		hook.Add 'DPP2_ContraptionUpdate', 'DPP2_Def' .. @identifier, (...) -> @ClearCache(...)
		hook.Add 'DPP2_ContraptionRemove', 'DPP2_Def' .. @identifier, (contraption) -> @ClearCache(contraption, contraption.rev, contraption.rev)
		@cache = {}

		CAMI.RegisterPrivilege({
			Name: 'dpp2_' .. @identifier .. '_admin'
			MinAccess: 'admin'
			Description: 'DPP/2 Module ' .. @identifier .. ' treats player as admin'
		})

		CAMI.RegisterPrivilege({
			Name: 'dpp2_' .. @identifier .. '_switchmode'
			MinAccess: 'admin'
			Description: 'DPP/2 Module ' .. @identifier .. ': Can switch protection status for others '
		})

		CAMI.RegisterPrivilege({
			Name: 'dpp2_' .. @identifier .. '_map_admin'
			MinAccess: 'superadmin'
			Description: 'DPP/2 Module ' .. @identifier .. ' treats player as map admin'
		})

		@otherPermString = 'dpp2_' .. @identifier .. '_admin'
		@otherPermStringMap = 'dpp2_' .. @identifier .. '_map_admin'

		@camiwatchdog\Track('dpp2_' .. @identifier .. '_admin')
		@camiwatchdog\Track('dpp2_' .. @identifier .. '_map_admin')

        @ownerDisabledStatusString = 'gui.dpp2.access.status.ownerdisabled_' .. @identifier

        self2 = @

		@lock_self_name = 'lock_self_' .. identifier
		@unlock_self_name = 'unlock_self_' .. identifier
		@lock_others_name = 'lock_others_' .. identifier
		@unlock_others_name = 'unlock_others_' .. identifier

		if SERVER
			DPP2.cmd['switchpmode_' .. identifier] = (args = {}) =>
				str = table.concat(args, ' ')
				ply = DPP2.FindPlayerInCommand(str)
				return 'command.dpp2.generic.notarget' if not ply
				self2\SwitchProtectionDisableFor(ply)

				if self2\IsDisabledForPlayer(ply)
					DPP2.Notify(true, nil, 'command.dpp2.disabled_for.' .. identifier, @, ply)
				else
					DPP2.Notify(true, nil, 'command.dpp2.enabled_for.' .. identifier, @, ply)

            DPP2.cmd['protection_disable_' .. identifier .. '_for'] = (args = {}) =>
				str = table.concat(args, ' ')
				ply = DPP2.FindPlayerInCommand(str)
				return 'command.dpp2.generic.notarget' if not ply
                return 'command.dpp2.already_disabled_for.' .. identifier, ply if self2\IsDisabledForPlayer(ply)
				self2\DisableProtectionFor(ply)
				DPP2.Notify(true, nil, 'command.dpp2.disabled_for.' .. identifier, @, ply)

            DPP2.cmd['protection_enable_' .. identifier .. '_for'] = (args = {}) =>
				str = table.concat(args, ' ')
				ply = DPP2.FindPlayerInCommand(str)
				return 'command.dpp2.generic.notarget' if not ply
                return 'command.dpp2.already_enabled_for.' .. identifier, ply if not self2\IsDisabledForPlayer(ply)
				self2\DisableProtectionFor(ply)
				DPP2.Notify(true, nil, 'command.dpp2.enabled_for.' .. identifier, @, ply)

            DPP2.cmd[@lock_self_name] = (args = {}) =>
				return 'command.dpp2.generic.invalid_side' if not IsValid(@)
				ent = DPP2.FindEntityFromArg(table.concat(args, ' '), @)
				return 'command.dpp2.generic.notarget' if not IsValid(ent) or ent\IsPlayer() or ent\IsNPC() or type(ent) == 'NextBot'
				self2\LockSelf(@, ent)
				DPP2.Notify(@, nil, 'command.dpp2.lock_self.' .. identifier, ent)

            DPP2.cmd[@unlock_self_name] = (args = {}) =>
				return 'command.dpp2.generic.invalid_side' if not IsValid(@)
				ent = DPP2.FindEntityFromArg(table.concat(args, ' '), @)
				return 'command.dpp2.generic.notarget' if not IsValid(ent) or ent\IsPlayer() or ent\IsNPC() or type(ent) == 'NextBot'
				self2\UnLockSelf(@, ent)
				DPP2.Notify(@, nil, 'command.dpp2.unlock_self.' .. identifier, ent)

            DPP2.cmd[@lock_others_name] = (args = {}) =>
				return 'command.dpp2.generic.invalid_side' if not IsValid(@)
				ent = DPP2.FindEntityFromArg(table.concat(args, ' '), @)
				return 'command.dpp2.generic.notarget' if not IsValid(ent) or ent\IsPlayer() or ent\IsNPC() or type(ent) == 'NextBot'
				return 'command.dpp2.transferent.not_owner' if ent\DPP2GetOwner() ~= @
				self2\LockOthers(ent)
				DPP2.Notify(@, nil, 'command.dpp2.lock_others.' .. identifier, ent)

            DPP2.cmd[@unlock_others_name] = (args = {}) =>
				return 'command.dpp2.generic.invalid_side' if not IsValid(@)
				ent = DPP2.FindEntityFromArg(table.concat(args, ' '), @)
				return 'command.dpp2.generic.notarget' if not IsValid(ent) or ent\IsPlayer() or ent\IsNPC() or type(ent) == 'NextBot'
				return 'command.dpp2.transferent.not_owner' if ent\DPP2GetOwner() ~= @
				self2\UnLockOthers(ent)
				DPP2.Notify(@, nil, 'command.dpp2.unlock_others.' .. identifier, ent)
		else
			DPP2.cmd_autocomplete[@lock_self_name] = (args, margs) => DPP2.AutocompleteOwnedEntityArgument(args, false, true, (ent) -> not self2\IsLockedSelf(@, ent))
			DPP2.cmd_autocomplete[@unlock_self_name] = (args, margs) => DPP2.AutocompleteOwnedEntityArgument(args, false, true, (ent) -> self2\IsLockedSelf(@, ent))
			DPP2.cmd_autocomplete[@lock_others_name] = (args, margs) => DPP2.AutocompleteOwnedEntityArgument(args, true, true, (ent) -> not self2\IsLockedOthers(ent))
			DPP2.cmd_autocomplete[@unlock_others_name] = (args, margs) => DPP2.AutocompleteOwnedEntityArgument(args, true, true, (ent) -> self2\IsLockedOthers(ent))

		DPP2.cmd_perms[@lock_self_name] = 'user'
		DPP2.cmd_perms[@lock_others_name] = 'user'
		DPP2.cmd_perms['switchpmode_' .. identifier] = 'CAMI_dpp2_' .. @identifier .. '_switchmode'
		DPP2.cmd_perms['protection_disable_' .. identifier .. '_for'] = 'CAMI_dpp2_' .. @identifier .. '_switchmode'
		DPP2.cmd_perms['protection_enable_' .. identifier .. '_for'] = 'CAMI_dpp2_' .. @identifier .. '_switchmode'

		DPP2.cmd_autocomplete['switchpmode_' .. identifier] = (args, margs) => [string.format('%q', ply) for ply in *DPP2.FindPlayersInArgument(args)]
		DPP2.cmd_autocomplete['protection_disable_' .. identifier .. '_for'] = (args, margs) => [string.format('%q', ply) for ply in *DPP2.FindPlayersInArgument(args, [ply2 for ply2 in *player.GetAll() when self2\IsDisabledForPlayer(ply2)])]
		DPP2.cmd_autocomplete['protection_enable_' .. identifier .. '_for'] = (args, margs) => [string.format('%q', ply) for ply in *DPP2.FindPlayersInArgument(args, [ply2 for ply2 in *player.GetAll() when not self2\IsDisabledForPlayer(ply2)])]

	IsEnabled: => @enabled\GetBool() and DPP2.ENABLE_PROTECTION\GetBool()

	IsAdmin: (ply = NULL) => ply\IsValid() and @camiwatchdog\HasPermission(ply, @otherPermString)
	IsMapAdmin: (ply = NULL) => ply\IsValid() and @camiwatchdog\HasPermission(ply, @otherPermStringMap)

	SwitchProtectionDisableFor: (ply = NULL, status = @IsDisabledForPlayer(ply)) =>
		error('Tried to use a NULL Entity!', 2) if not ply\IsValid()
		error('Tried to use a ' .. type(ply) .. ' instead of Player', 2) if not ply\IsPlayer()

		if status then @EnableProtectionFor(ply) else @DisableProtectionFor(ply)

	EnableProtectionFor: (ply) =>
		error('Invalid side') if CLIENT
		ply\SetNWBool(@disableNWName, false)
		return @

	DisableProtectionFor: (ply) =>
		error('Invalid side') if CLIENT
		ply\SetNWBool(@disableNWName, true)
		return @

	LockSelf: (ply, ent) =>
		error('Invalid side') if CLIENT
		--ent\SetNWBool(@lock_self_nwname, true)
		--ply[@lock_self_nwname] = ply[@lock_self_nwname] or {}
		--ply[@lock_self_nwname][ent] = true
		ent\SetNWBool(@lock_self_nwname .. '_' .. (game.SinglePlayer() and '0' or ply\SteamID64()), true)
		return @

	IsLockedSelf: (ply, ent) =>
		--return false if not ply[@lock_self_nwname]
		--return ply[@lock_self_nwname][ent] == true
		return ent\GetNWBool(@lock_self_nwname .. '_' .. (game.SinglePlayer() and '0' or ply\SteamID64()), false)

	UnLockSelf: (ply, ent) =>
		error('Invalid side') if CLIENT
		--ent\SetNWBool(@lock_self_nwname, false)
		--return @ if not ply[@lock_self_nwname]
		--ply[@lock_self_nwname][ent] = nil
		ent\SetNWBool(@lock_self_nwname .. '_' .. (game.SinglePlayer() and '0' or ply\SteamID64()), false)
		return @

	LockOthers: (ent) =>
		error('Invalid side') if CLIENT
		ent\SetNWBool(@lock_others_nwname, true)
		return @

	IsLockedOthers: (ent) =>
		return false if not ent\IsValid()
		return ent\GetNWBool(@lock_others_nwname, false)

	UnLockOthers: (ent) =>
		error('Invalid side') if CLIENT
		ent\SetNWBool(@lock_others_nwname, false)
		return @

	IsDisabledForPlayer: (ply = NULL) =>
		return false if not ply\IsValid()
		return not ply\GetInfoBool('dpp2_cl_protection', true) or not ply\GetInfoBool(@clEnabledName, true) or ply\GetNWBool(@disableNWName, false)

	IsDisabledForPlayerByAdmin: (ply = NULL) =>
		return false if not ply\IsValid()
		return ply\GetNWBool(@disableNWName, false)

	IsDisabledForSteamID: (steamid) =>
		return @disabledCache[steamid] if @disabledCache[steamid] ~= nil
		if ply = player.GetBySteamID(steamid)
			return @IsDisabledForPlayer(ply)
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
			ent\SetNWBool(@sharingVarID, false)

		if flush and not newMode
			hit = false

			for obj in *@@OBJECTS
				if obj\IsShared(ent)
					hit = true
					break

			if not hit
				ent\SetNWBool('dpp2_s', false)
			else
				ent\SetNWBool('dpp2_s', true)
		elseif flush and newMode
			ent\SetNWBool('dpp2_s', true)

		if contraption = ent\DPP2GetContraption()
			timer.Create 'DPP2_UpdateSharedContraption_' .. contraption.id, 0.2, 1, ->
				contraption\InvalidateClients()
				contraption\Invalidate()

		return true

	ForcePruneFriends: =>
		toRemove = {}

		for steamid in pairs(@friendsCache)
			if not DPP2.HasEntsBySteamID(steamid)
				table.insert(toRemove, steamid)
				timer.Remove('DPP2.FriendStatus.' .. steamid)

		@friendsCache[k] = nil for k in *toRemove
		@disabledCache[k] = nil for k in *toRemove

	AreFriends: (localPly, otherPly) => localPly\CheckDLibFriendInOverride(otherPly, @friendID)

	PruneFriendData: (steamid) =>
		@friendsCache[steamid] = nil
		@disabledCache[steamid] = nil

	ClearCache: (contraption, revNew, revOld) =>
		ending = '_' .. contraption.id .. '_' .. revOld
		removal = {}

		for key in pairs(@cache)
			if key\endsWith(ending)
				table.insert(removal, key)

		@cache[key] = nil for key in *removal

	PlayerDisconnected: (ply = NULL) =>
		steamid = ply\SteamID()
		@friendsCache[steamid] = {ply2\SteamID(), ply2\CheckDLibFriendInOverride(ply, @friendID) for ply2 in *player.GetAll()}
		@disabledCache[steamid] = @IsDisabledForPlayer(ply)

		@ClearPlayerCache(ply)

	ClearPlayerCache: (ply = NULL) =>
		steamid = ply\SteamID()
		removal = {}

		for key in pairs(@cache)
			if key\startsWith(steamid)
				table.insert(removal, key)

		@cache[key] = nil for key in *removal

	ClearEntireCache: => @cache = {}

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

		changed = ply\GetInfoBool(@clientNoTouchOtherName, false) ~= ply[@clientNoTouchOtherName]
		ply[@clientNoTouchOtherName] = ply\GetInfoBool(@clientNoTouchOtherName, false)
		@ClearPlayerCache(ply) if changed

		return false, i18n.localize('gui.dpp2.access.status.yoursettings') if ply\GetInfoBool(@clientNoTouchOtherName, false)
		return true if not @IsEnabled()

		if type(other) == 'string'
			getply = player.GetBySteamID(other)

			if getply
				return true, i18n.exists(@ownerDisabledStatusString) and i18n.localize(@ownerDisabledStatusString) or i18n.localize('gui.dpp2.access.status.ownerdisabled') if @IsDisabledForPlayer(getply)
                return true if @camiwatchdog\HasPermission(ply, @otherPermString) and @adminTouchAny\GetBool()
				return true if getply\CheckDLibFriendInOverride(ply, @friendID)
				return false, i18n.localize('gui.dpp2.access.status.friend')

			return true, i18n.localize('gui.dpp2.access.status.ownerdisabled') if @IsDisabledForSteamID(other)
			return true if @camiwatchdog\HasPermission(ply, @otherPermString) and @adminTouchAny\GetBool()

			steamid = ply\SteamID()

			if @friendsCache[other] and @friendsCache[other][steamid] ~= nil
				return false, i18n.localize('gui.dpp2.access.status.friend') if not @friendsCache[other][steamid]
				return true
		elseif IsValid(other)
			return true, i18n.exists(@ownerDisabledStatusString) and i18n.localize(@ownerDisabledStatusString) or i18n.localize('gui.dpp2.access.status.ownerdisabled') if @IsDisabledForPlayer(other)
            return true if @camiwatchdog\HasPermission(ply, @otherPermString) and @adminTouchAny\GetBool()
			return true if other\CheckDLibFriendInOverride(ply, @friendID)

		return false, i18n.localize('gui.dpp2.access.status.friend')

	CanGeneric: (ply = NULL, ent = NULL) =>
		return true if not ply\IsValid()
		return false if not ent\IsValid()
		return false, i18n.localize('gui.dpp2.access.status.yoursettings') if ent\IsPlayer() and ply\GetInfoBool(@clientNoPlayersName, false)
		return false, i18n.localize('gui.dpp2.access.status.lock_self') if @IsLockedSelf(ply, ent)
		return false, i18n.localize('gui.dpp2.access.status.lock_other') if ent\DPP2GetOwner() ~= ply and @IsLockedOthers(ent)
		return true if ent\IsPlayer()
		classname = ent\GetClass()
		return false, i18n.localize('gui.dpp2.access.status.model_blacklist') if not DPP2.ModelBlacklist\Ask(ent\GetModel(), ply)
		return false, i18n.localize('gui.dpp2.access.status.' .. @identifier .. '_restriction') if @classnameRestriction and not @classnameRestriction\Ask(classname, ply)
		return false, i18n.localize('gui.dpp2.access.status.' .. @identifier .. '_blacklist') if @classnameBlacklist and not @classnameBlacklist\Ask(classname, ply)
		return true, i18n.localize('gui.dpp2.access.status.disabled') if not @IsEnabled()

	CanTouch: (ply = NULL, ent = NULL, processContraptions = SERVER or not DPP2.CL_DONT_PROCESS_CONTRAPTIONS\GetBool()) =>
		cangeneric, tstatus = @CanGeneric(ply, ent)
		return cangeneric, tstatus if cangeneric ~= nil

		contraption = ent\DPP2GetContraption()
		return @_CanTouch(ply, ent, processContraptions) if not contraption
		steamid = ply\SteamID()
		cachekey = steamid .. '_' .. contraption.id .. '_' .. contraption.rev

		if contraption and @cache[cachekey] and not DPP2.NO_DEF_CACHE\GetBool()
			return unpack(@cache[cachekey], 1, 4)

		result, a, b, c = @_CanTouch(ply, ent, processContraptions)
		@cache[cachekey] = {result, a, b, c}

		return result, a, b, c

	_CanTouch: (ply = NULL, ent = NULL, processContraptions = SERVER or not DPP2.CL_DONT_PROCESS_CONTRAPTIONS\GetBool()) =>
		contraption = ent\DPP2GetContraption()

		if not contraption
			owner, ownerSteamID, ownerNick = ent\DPP2GetOwner()
			return true if owner == ply
			return true, i18n.localize('gui.dpp2.access.status.' .. @identifier .. '_exclusion') if @classnameExclusionList and @classnameExclusionList\Ask(ent\GetClass(), ply)
			return true, i18n.localize('gui.dpp2.access.status.model_exclusion') if DPP2.ModelExclusions\Ask(ent\GetModel(), ply)
			return @CanTouchMap(ply), i18n.localize('gui.dpp2.access.status.map') if ownerSteamID == 'world' and ent\DPP2CreatedByMap()
			return @CanTouchWorld(ply), i18n.localize('gui.dpp2.access.status.world') if ownerSteamID == 'world'
			return @CanTouchOther(ply, IsValid(owner) and owner or ownerSteamID)

		steamid = ply\SteamID()

		check = not processContraptions or not DPP2.ModelBlacklist\IsEnabled() and
			(not @classnameExclusionList or not @classnameExclusionList\IsEnabled()) and
			(not @classnameBlacklist or not @classnameBlacklist\IsEnabled()) and
			(not @classnameRestriction or not @classnameRestriction\IsEnabled())

		if check
			for ownerSteamID in *contraption\GetOwnersPartial(@identifier)
				if steamid ~= ownerSteamID
					return false, i18n.localize('gui.dpp2.access.status.map'), i18n.localize('gui.dpp2.access.status.contraption_ext', contraption\GetID()) if ownerSteamID == 'world' and ent\DPP2CreatedByMap() and not @CanTouchMap(ply)
					return false, i18n.localize('gui.dpp2.access.status.world'), i18n.localize('gui.dpp2.access.status.contraption_ext', contraption\GetID()) if ownerSteamID == 'world' and not @CanTouchWorld(ply)
					return false, i18n.localize('gui.dpp2.access.status.friend'), i18n.localize('gui.dpp2.access.status.contraption_ext', contraption\GetID()) if ownerSteamID ~= 'world' and not @CanTouchOther(ply, ownerSteamID)
		else
			for ent2 in *contraption.ents
				if IsValid(ent2)
					owner, ownerSteamID, ownerNick = ent2\DPP2GetOwner()
					classname2 = ent2\GetClass()
					mdl2 = ent2\GetModel()
					return false, i18n.localize('gui.dpp2.access.status.model_blacklist') if not DPP2.ModelBlacklist\Ask(mdl2, ply)

					if (not @classnameExclusionList or not @classnameExclusionList\Ask(classname2, ply)) and not DPP2.ModelExclusions\Ask(mdl2, ply)
						return false, i18n.localize('gui.dpp2.access.status.' .. @identifier .. '_restriction') if @classnameRestriction and not @classnameRestriction\Ask(classname2, ply)
						return false, i18n.localize('gui.dpp2.access.status.' .. @identifier .. '_blacklist') if @classnameBlacklist and not @classnameBlacklist\Ask(classname2, ply)

						if steamid ~= ownerSteamID
							return false, i18n.localize('gui.dpp2.access.status.map'), i18n.localize('gui.dpp2.access.status.contraption_ext', contraption\GetID()) if ownerSteamID == 'world' and ent\DPP2CreatedByMap() and not @CanTouchMap(ply)
							return false, i18n.localize('gui.dpp2.access.status.world'), i18n.localize('gui.dpp2.access.status.contraption_ext', contraption\GetID()) if ownerSteamID == 'world' and not @CanTouchWorld(ply)
							return false, i18n.localize('gui.dpp2.access.status.friend'), i18n.localize('gui.dpp2.access.status.contraption_ext', contraption\GetID()) if ownerSteamID ~= 'world' and not @CanTouchOther(ply, ownerSteamID)

		return true, i18n.localize('gui.dpp2.access.status.contraption_ext', contraption\GetID())

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
