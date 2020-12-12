
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

import Entity, DPP2 from _G

entMeta = FindMetaTable('Entity')

local worldspawn

entMeta.DPP2GetPhys = =>
	return if @IsPlayer() or @IsNPC() or type(@) == 'NextBot'
	worldspawn = Entity(0)\GetPhysicsObject()

	switch @GetPhysicsObjectCount()
		when 0
			return
		when 1
			phys = @GetPhysicsObject()
			return if not IsValid(phys) or phys == worldspawn
			return phys

	local output

	for i = 0, @GetPhysicsObjectCount() - 1
		phys = @GetPhysicsObjectNum(i)

		if IsValid(phys) and phys ~= worldspawn
			output = output or {}
			table.insert(output, phys)

	return if not output
	return output[1] if #output == 1
	return output

plyMeta = FindMetaTable('Player')

DPP2.SplitArguments = (argstr = '') ->
	stack = {}
	backslash = false
	inQuotes = false
	current = ''

	for char in argstr\gmatch('.')
		if char == '\\'
			if backslash
				backslash = false
				current ..= '\\'
			else
				backslash = true
		elseif char == '"'
			if backslash
				backslash = false
				current ..= '"'
			elseif inQuotes
				inQuotes = false
				table.insert(stack, current\trim())
				current = ''
			else
				if current\trim() ~= ''
					table.insert(stack, current\trim())
					current = ''

				inQuotes = true
		elseif char == ' ' and not inQuotes
			if current\trim() ~= ''
				table.insert(stack, current\trim())

			current = ''
		else
			backslash = false
			current ..= char

	table.insert(stack, current\trim()) if current\trim() ~= ''
	return stack

DPP2.FindOwned = ->
	output = {}

	for ent in *ents.GetAll()
		if ent\DPP2IsOwned()
			table.insert(output, ent)

	return output

DPP2.FindPlayerInCommand = (str = '') ->
	str = str\trim()\lower()
	return false if str == ''
	return player.GetBySteamID(str\upper()) if str\startsWith('steam_')

	if num = str\tonumber()
		ply = Player(num)
		return ply if IsValid(ply)

	-- todo: better comparison
	findPly = false

	for ply in *player.GetAll()
		nick = ply\Nick()\lower()
		return ply if nick == str

		if nick\find(str)
			findPly = ply

		if ply.SteamName
			nick = ply\SteamName()\lower()
			return ply if nick == str

			if nick\find(str)
				findPly = ply

	return findPly

DPP2.FindPlayerUserIDInCommand = (str = '', allow_any = false) ->
	str = str\trim()\lower()
	return false if str == ''

	if str\startsWith('steam_')
		getplayer = player.GetBySteamID(str\upper())
		return getplayer\UserID() if getplayer
		return getplayer

	if num = str\tonumber()
		return num if allow_any
		return num if IsValid(Player(num))

	-- todo: better comparison
	findPly = false

	for ply in *player.GetAll()
		nick = ply\Nick()\lower()
		return ply\UserID() if nick == str

		if nick\find(str)
			findPly = ply

		if ply.SteamName
			nick = ply\SteamName()\lower()
			return ply\UserID() if nick == str

			if nick\find(str)
				findPly = ply

	return findPly\UserID() if findPly
	return findPly

DPP2.FindPlayersInArgument = (str = '', filter, nobots = false, any_player = false) ->
	filter = LocalPlayer() if CLIENT and filter == true

	if nobots
		filter = {} if not filter
		filter = {filter} if type(filter) ~= 'table'
		table.insert(filter, ply) for ply in *player_list when ply\IsBot()

	filter = {} if not filter
	filter = {filter} if not istable(filter)
	filter = for ply in *filter
		if isnumber(ply)
			ply
		else
			ply\UserID()

	-- player_list = player.GetAll()
	player_list = DPP2.GetAllKnownPlayersInfo()

	str = str\trim()\lower()
	return {DLib.i18n.localize('command.dpp2.hint.player')} if str == ''

	if str\startsWith('steam_')
		plyFind = player.GetBySteamID(str\upper())
		return {DLib.i18n.localize('command.dpp2.hint.player')} if plyFind and table.qhasValue(filter, plyFind\UserID())
		return {plyFind\Nick()} if plyFind and not table.qhasValue(filter, plyFind\UserID())
		output = [ply.steamid for ply in *player_list when ply.steamid\lower()\startsWith(str) and not table.qhasValue(filter, ply.uid)]
		return #output ~= 0 and output or {DLib.i18n.localize('command.dpp2.hint.none')}

	if num = str\tonumber()
		ply = Player(num)
		return {DLib.i18n.localize('command.dpp2.hint.player')} if IsValid(ply) and table.qhasValue(filter, ply\UserID())
		getply = player_list[num] if not table.qhasValue(filter, num)
		return {getply.name} if getply
		return {ply\Nick()} if IsValid(ply) and not table.qhasValue(filter, ply\UserID())
		output = [ply.name for ply in *player_list when ply.uid\tostring()\startsWith(str) and not table.qhasValue(filter, ply.uid)]
		return #output ~= 0 and output or {DLib.i18n.localize('command.dpp2.hint.none')}

	findPly = {}

	for ply in *player_list
		if not table.qhasValue(filter, ply.uid)
			nick = ply.name\lower()

			if nick == str or nick\find(str)
				table.insert(findPly, ply.name)
			elseif IsValid(ply.ent) and ply.ent.SteamName
				nick = ply.ent\SteamName()\lower()

				if nick == str or nick\find(str)
					table.insert(findPly, ply.ent\SteamName())

	return #findPly ~= 0 and findPly or {DLib.i18n.localize('command.dpp2.hint.none')}

DPP2.AutocompleteOwnedEntityArgument = (str2, owned = CLIENT, format = false, filter) ->
	owned = nil if SERVER
	entsFind = [ent for ent in *ents.GetAll() when ent\DPP2IsOwned()] if owned == false
	searchEnts = owned and LocalPlayer()\DPP2FindOwned() or entsFind or ents.GetAll()
	output = {}
	str2 = str2\lower()

	if num = tonumber(str2)
		entf = Entity(num)

		if IsValid(entf)
			if (entf\DPP2GetOwner() == @ or not owned) and (not filter or filter(entf))
				table.insert(output, format and string.format('%q', tostring(entf)) or tostring(entf))
			else
				table.insert(output, '<cannot target!>')
		else
			for ent in *searchEnts
				if ent\EntIndex()\tostring()\startsWith(str) and (not filter or filter(ent))
					table.insert(output, format and string.format('%q', tostring(ent)) or tostring(ent))
	else
		for ent in *searchEnts
			str = tostring(ent)

			return {format and string.format('%q', str) or str} if str\lower() == str2

			if str\lower()\startsWith(str2) and (not filter or filter(ent))
				table.insert(output, format and string.format('%q', str) or str)

	table.sort(output)
	return output

DPP2.FindEntityFromArg = (str, ply = CLIENT and LocalPlayer() or error('You must provide player entity')) ->
	ent = Entity(tonumber(str or -1) or -1)
	return ent if IsValid(ent)
	return ent for ent in *ply\DPP2FindOwned() when tostring(ent) == str
	return NULL

DPP2.SpewEntityInspectionOutput = (ent = NULL) =>
	if not IsValid(ent)
		DPP2.LMessagePlayer(@, 'message.dpp2.inspect.invalid_entity')
	else
		DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.class', ent\GetClass() or 'undefined')

		pos = ent\GetPos()
		DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.position', pos.x, pos.y, pos.z) if pos

		ang = ent\GetAngles()
		DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.angles', ang.p, pos.y, pos.r) if ang

		ang = ent\EyeAngles()
		DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.eye_angles', ang.p, pos.y, pos.r) if ang

		DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.table_size', table.Count(ent\GetTable()))
		DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.health', ent\Health())
		DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.max_health', ent\GetMaxHealth())

		ownerEntity, ownerSteamID, ownerNickname, ownerUniqueID = ent\DPP2GetOwner()

		if ownerSteamID ~= 'world'
			DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.owner_entity', ownerEntity) if IsValid(ownerEntity)
			DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.owner_steamid', ownerSteamID)
			DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.owner_nickname', ownerNickname or '')
			DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.owner_uniqueid', ownerUniqueID)
		else
			DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.unowned')

		DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.model', ent\GetModel() or 'undefined')
		DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.skin', ent\GetSkin() or 'undefined')
		DPP2.LMessagePlayer(@, 'message.dpp2.inspect.result.bodygroup_count', table.Count(ent\GetBodyGroups() or {}))