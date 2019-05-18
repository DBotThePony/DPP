
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

import Entity, DPP2 from _G

entMeta = FindMetaTable('Entity')

local worldspawn

entMeta.DPP2GetPhys = =>
	return if @IsPlayer() or @IsNPC()
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

plyMeta.DPP2FindOwned = =>
	return error('Tried to use a NULL Entity!') if not @IsValid()

	output = {}

	for ent in *ents.GetAll()
		if ent\DPP2GetOwner() == @
			table.insert(output, ent)

	return output

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

	-- todo: better comprasion
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

DPP2.FindPlayersInArgument = (str = '') ->
	str = str\trim()\lower()
	return {DLib.i18n.localize('message.dpp2.concommand.hint.player')} if str == ''

	if str\startsWith('steam_')
		plyFind = player.GetBySteamID(str\upper())
		return plyFind\Nick() if plyFind
		output = [ply\SteamID() for ply in *player.GetAll() when ply\SteamID()\lower()\startsWith(str)]
		return #output ~= 0 and output or {DLib.i18n.localize('message.dpp2.concommand.hint.none')}

	if num = str\tonumber()
		ply = Player(num)
		return {ply\Nick()} if IsValid(ply)
		output = [ply\Nick() for ply in *player.GetAll() when ply\UserID()\tostring()\startsWith(str)]
		return #output ~= 0 and output or {DLib.i18n.localize('message.dpp2.concommand.hint.none')}

	findPly = {}

	for ply in *player.GetAll()
		nick = ply\Nick()\lower()
		if nick == str or nick\find(str)
			table.insert(findPly, ply\Nick())
		elseif ply.SteamName
			nick = ply\SteamName()\lower()
			if nick == str or nick\find(str)
				table.insert(findPly, ply\SteamName())

	return #findPly ~= 0 and findPly or {DLib.i18n.localize('message.dpp2.concommand.hint.none')}
