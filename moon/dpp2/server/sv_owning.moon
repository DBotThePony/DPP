
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

import NULL, type, player from _G

entMeta = FindMetaTable('Entity')

entMeta.DPP2SetIsUpForGrabs = (val) =>
	@SetNWBool('dpp2_ufg', val)

entMeta.DPP2SetUpForGrabs = (val) =>
	@SetNWBool('dpp2_ufg', val)

entMeta.DPP2GetOwner = =>
	if @GetNWString('dpp2_owner_steamid', '-1') == '-1'
		return NULL, 'world', 'World', 'world'
	else
		return @GetNWEntity('dpp2_ownerent', NULL), @GetNWString('dpp2_owner_steamid'), @_dpp2_last_nick, @GetNWString('dpp2_owner_uid', 'world')

entMeta.DPP2SetOwner = (newOwner = NULL) =>
	return false if type(@) == 'Player'

	switch type(newOwner)
		when 'number'
			newOwner = player.GetByUniqueID(newOwner)
			newOwner = NULL if not newOwner
		when 'string'
			newOwner = player.GetBySteamID(newOwner)
			newOwner = player.GetBySteamID64(newOwner) if not newOwner
			newOwner = NULL if not newOwner
		else
			error('Invalid new owner provided. typeof ' .. type(newOwner)) if type(newOwner) ~= 'Player' and newOwner ~= NULL

	return false if newOwner == @GetNWEntity('dpp2_ownerent', NULL)

	hookStatus = hook.Run('CPPIAssignOwnership', newOwner\IsValid() and newOwner or nil, @, newOwner\IsValid() and newOwner\UniqueID() or nil)
	return false if hookStatus ~= nil and hookStatus ~= false

	@DPP2SetIsUpForGrabs(false)
	@SetNWBool('dpp2_owner_uid_track', false)

	if @GetNWString('dpp2_owner_steamid', '-1') ~= (newOwner\IsValid() and newOwner\SteamID() or '-1')
		hook.Run('DPP2.NotifyOwnerChange', @, @GetNWEntity('dpp2_ownerent', NULL), newOwner)
		hook.Run('DPP2.NotifySteamIDOwnerChange', @, @GetNWString('dpp2_owner_steamid', '-1'), newOwner\IsValid() and newOwner\SteamID() or '-1')
		hook.Run('DPP2.NotifyUIDOwnerChange', @, @GetNWString('dpp2_owner_uid', '-1'), newOwner\IsValid() and newOwner\UniqueID() or '-1')

	if newOwner == NULL
		@SetNWEntity('dpp2_ownerent', NULL)
		@SetNWString('dpp2_owner_steamid', '-1')
		@SetNWString('dpp2_owner_uid', '-1')
		@_dpp2_last_nick = nil
	else
		@SetNWEntity('dpp2_ownerent', newOwner)
		@SetNWString('dpp2_owner_steamid', newOwner\SteamID())
		@SetNWString('dpp2_owner_uid', newOwner\UniqueID())
		@_dpp2_last_nick = newOwner\Nick()
		@_dpp2_last_nick = @_dpp2_last_nick .. ' (' .. newOwner\SteamName() .. ')' if newOwner.SteamName and newOwner\SteamName() ~= newOwner\Nick()

	@DPP2InvalidateContraption()

	return true

entMeta.DPP2SetOwnerSteamID = (newOwner = '-1') =>
	error('Invalid new owner type, typeof ' .. type(newOwner) .. '. It must be a string!') if type(newOwner) ~= 'string'
	return false if type(@) == 'Player'
	return false if newOwner == @GetNWString('dpp2_owner_steamid', '-1')

	getPly = player.GetBySteamID(newOwner)
	return @DPP2SetOwner(getPly) if getPly

	hookStatus = hook.Run('CPPIAssignOwnership', nil, @, newOwner ~= '-1' and util.CRC('gm_' .. newOwner .. '_gm') or nil)
	return false if hookStatus ~= nil and hookStatus ~= false

	@DPP2SetIsUpForGrabs(false)
	@SetNWBool('dpp2_owner_uid_track', false)

	hook.Run('DPP2.NotifySteamIDOwnerChange', @, @GetNWString('dpp2_owner_steamid', '-1'), newOwner)
	hook.Run('DPP2.NotifyUIDOwnerChange', @, @GetNWString('dpp2_owner_uid', '-1'), newOwner ~= '-1' and util.CRC('gm_' .. newOwner .. '_gm') or '-1')

	@SetNWEntity('dpp2_ownerent', '-1')

	if newOwner == '-1'
		@SetNWString('dpp2_owner_steamid', '-1')
		@SetNWString('dpp2_owner_uid', '-1')
		@_dpp2_last_nick = nil
	else
		@SetNWString('dpp2_owner_steamid', newOwner)
		@SetNWString('dpp2_owner_uid', util.CRC('gm_' .. newOwner .. '_gm'))
		@_dpp2_last_nick = 'Unknown one #' .. util.CRC(newOwner)\sub(1, 4)

	@DPP2InvalidateContraption()

	return true

-- since CPPI requires this
entMeta.DPP2SetOwnerUID = (newOwner = '-1') =>
	error('Invalid new owner type, typeof ' .. type(newOwner) .. '. It must be a string!') if type(newOwner) ~= 'string'
	return false if type(@) == 'Player'
	return false if newOwner == @GetNWString('dpp2_owner_uid', '-1')

	getPly = player.GetByUniqueID(newOwner)
	return @DPP2SetOwner(getPly) if getPly

	hookStatus = hook.Run('CPPIAssignOwnership', nil, @, newOwner ~= '-1' and newOwner or nil)
	return false if hookStatus ~= nil and hookStatus ~= false

	@DPP2SetIsUpForGrabs(false)

	hook.Run('DPP2.NotifyUIDOwnerChange', @, @GetNWString('dpp2_owner_uid', '-1'), newOwner)

	@SetNWEntity('dpp2_ownerent', '-1')
	@SetNWString('dpp2_owner_steamid', '-1')

	if newOwner == '-1'
		@SetNWString('dpp2_owner_uid', '-1')
		@SetNWBool('dpp2_owner_uid_track', '-1')
		@_dpp2_last_nick = nil
	else
		@SetNWString('dpp2_owner_uid', newOwner)
		@SetNWBool('dpp2_owner_uid_track', true)
		@_dpp2_last_nick = 'Unknown one #' .. newOwner\sub(1, 4)

	@DPP2InvalidateContraption()

	return true

entMeta.DPP2CheckUpForGrabs = (newOwner = NULL) =>
	return false if not newOwner\IsValid()
	return false if type(@) == 'Player'
	return @__dpp2_contraption\CheckUpForGrabs() if @__dpp2_contraption
	return false if not @DPP2IsUpForGrabs()

	DPP2.Notify(newOwner, nil, 'message.dpp2.owning.owned')
	DPP2.DoTransfer({@}, newOwner)
	return true

PlayerInitialSpawn = =>
	return if not @SteamID()
	return if @IsBot()
	timer.Remove 'DPP2.UpForGrabs.' .. @SteamID()
	timer.Remove 'DPP2.Cleanup.' .. @SteamID()

	for ent in *DPP2.GetAllEntsBySteamID(@SteamID())
		ent\DPP2SetOwner(@)

	for ent in *DPP2.GetAllEntsByUIDStrict(@UniqueID())
		ent\DPP2SetOwner(@)

hook.Add 'PlayerInitialSpawn', 'DPP2.Owning', PlayerInitialSpawn, -2

PlayerDisconnected = =>
	return if not @SteamID()
	return if @IsBot()

	return if not @DPP2HasEnts()

	steamid = @SteamID()
	nick = @Nick()
	nick ..= ' (' .. @SteamName() .. ')' if @SteamName and @SteamName() ~= nick
	nick = string.format('%s<%s>', nick, @SteamID())

	if DPP2.ENABLE_UP_FOR_GRABS\GetBool() and not (DPP2.ENABLE_CLEANUP\GetBool() and DPP2.UP_FOR_GRABS_TIMER\GetFloat() >= DPP2.CLEANUP_TIMER\GetFloat())
		timer.Create 'DPP2.UpForGrabs.' .. steamid, DPP2.UP_FOR_GRABS_TIMER\GetFloat(), 1, ->
			return if @IsValid()
			find = DPP2.GetAllEntsBySteamID(steamid)
			return if #find == 0

			DPP2.NotifyUndoAll(6, nick, 'message.dpp2.notice.upforgrabs')
			ent\DPP2SetIsUpForGrabs(true) for ent in *find

	if DPP2.ENABLE_CLEANUP\GetBool()
		timer.Create 'DPP2.Cleanup.' .. steamid, DPP2.CLEANUP_TIMER\GetFloat(), 1, ->
			return if @IsValid()
			find = DPP2.GetAllEntsBySteamID(steamid)
			return if #find == 0

			DPP2.NotifyUndoAll(6, nick, 'message.dpp2.notice.cleanup')
			SafeRemoveEntity(ent) for ent in *find

hook.Add 'PlayerDisconnected', 'DPP2.Owning', PlayerDisconnected, -2
