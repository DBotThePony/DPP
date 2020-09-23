
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

import DPP2 from _G

QUEUE = {}

watchdog = DLib.CAMIWatchdog('dpp2_antispam')
watchdog\Track('dpp2_ignore_antispam')

OnPhysgunReload = (physgun, ply) ->
	return if not DPP2.ENABLE_ANTISPAM\GetBool()
	return if not DPP2.ANTISPAM_UNFREEZE\GetBool()

	ent = ply\GetEyeTrace().Entity
	return if not IsValid(ent)

	if (ply.__dpp2_unfreeze or 0) > RealTime()
		DPP2.NotifyError(ply, nil, 'message.dpp2.antispam.hint_unfreeze_antispam', ply.__dpp2_unfreeze - RealTime())
		return false

	if contraption = ent\DPP2GetContraption()
		ply.__dpp2_unfreeze = RealTime() + #contraption.ents / (20 * DPP2.ANTISPAM_DIVIDER\GetFloat())
	else
		ply.__dpp2_unfreeze = RealTime() + 1 / (20 * DPP2.ANTISPAM_DIVIDER\GetFloat())

_SafeRemoveEntity = SafeRemoveEntity
SafeRemoveEntity = (ent) ->
	ent.__dpp2_killme = true
	_SafeRemoveEntity(ent)

LAST_CHECK = 0
recomputeAntispamValues = ->
	delta = RealTime() - LAST_CHECK
	LAST_CHECK = RealTime()

	ANTISPAM_COOLDOWN = DPP2.ANTISPAM_COOLDOWN\GetFloat()
	ANTISPAM_VOLUME_COOLDOWN = DPP2.ANTISPAM_VOLUME_COOLDOWN\GetFloat()

	for ply in *player.GetAll()
		ply.__dpp2_antispam_volume = math.max(0, (ply.__dpp2_antispam_volume or 0) - delta * ANTISPAM_VOLUME_COOLDOWN)
		ply.__dpp2_antispam = math.max(0, (ply.__dpp2_antispam or 0) - delta * ANTISPAM_COOLDOWN)

ComputeVolume = =>
	switch @GetPhysicsObjectCount()
		when 0
			return 0
		when 1
			phys = @GetPhysicsObject()
			return 0 if not IsValid(phys)
			return phys\GetVolume() or 0
		else
			num = 0

			for physID = 0, @GetPhysicsObjectCount() - 1
				phys = @GetPhysicsObjectNum(physID)
				num += phys\GetVolume() if IsValid(phys)

			return num

	return 0

DPP2._ComputeVolume2 = =>
	mins, maxs = @OBBMins(), @OBBMaxs()
	square = (maxs.x - mins.x)\abs() * (maxs.y - mins.y)\abs()
	cubic = square * (maxs.z - mins.z)\abs()
	return square * cubic

ComputeVolume2 = DPP2._ComputeVolume2

-- returns false if we need to disallow spawn in-place
DPP2.AntispamCheck = (ply = NULL, doNotify = true, ent, constrained, autoGhost = false) ->
	return true if not DPP2.ENABLE_ANTISPAM\GetBool()
	return true if not DPP2.ANTISPAM_SPAM\GetBool() and not DPP2.ANTISPAM_VOLUME_SPAM\GetBool()
	return true if DPP2.ANTISPAM_IGNORE_ADMINS\GetBool() and watchdog\HasPermission(ply, 'dpp2_ignore_antispam')

	if ply.__dpp2_antispam_volume and ply.__dpp2_antispam_volume >= DPP2.ANTISPAM_VOLUME_THRESHOLD2\GetFloat()
		recomputeAntispamValues()

		if ply.__dpp2_antispam_volume >= DPP2.ANTISPAM_VOLUME_THRESHOLD2\GetFloat()
			return false if ent and ent.__dpp2_killme
			SafeRemoveEntity(ent) if ent
			if constrained
				SafeRemoveEntity(ent) for ent in *constrained
			DPP2.NotifyError(ply, nil, 'message.dpp2.antispam.hint_disallowed') if doNotify
			return false

	if ply.__dpp2_antispam and ply.__dpp2_antispam >= DPP2.ANTISPAM_THRESHOLD2\GetFloat()
		recomputeAntispamValues()

		if ply.__dpp2_antispam >= DPP2.ANTISPAM_THRESHOLD2\GetFloat()
			return false if ent and ent.__dpp2_killme
			SafeRemoveEntity(ent) if ent
			if constrained
				SafeRemoveEntity(ent) for ent in *constrained
			DPP2.NotifyError(ply, nil, 'message.dpp2.antispam.hint_disallowed') if doNotify
			return false

	if ent and autoGhost
		if DPP2.AUTO_GHOST_BY_SIZE\GetBool() and ComputeVolume(ent) >= DPP2.AUTO_GHOST_SIZE\GetFloat()
			DPP2.NotifyHint(ply, nil, 'message.dpp2.antispam.hint_ghosted_big_single') if doNotify
			ent\DPP2Ghost()
		elseif DPP2.AUTO_GHOST_BY_AABB\GetBool() and ComputeVolume2(ent) >= DPP2.AUTO_GHOST_AABB_SIZE\GetFloat() / DPP2.ANTISPAM_VOLUME_AABB_DIV\GetFloat()
			DPP2.NotifyHint(ply, nil, 'message.dpp2.antispam.hint_ghosted_big_single') if doNotify
			ent\DPP2Ghost()

	return true

DPP2.QueueAntispam = (ply = NULL, ent = NULL, constrained = {}, doNotify = true) ->
	return true if not DPP2.ENABLE_ANTISPAM\GetBool()
	return true if not DPP2.ANTISPAM_SPAM\GetBool() and not DPP2.ANTISPAM_VOLUME_SPAM\GetBool()
	return true if DPP2.ANTISPAM_IGNORE_ADMINS\GetBool() and watchdog\HasPermission(ply, 'dpp2_ignore_antispam')
	return false if not DPP2.AntispamCheck(ply, doNotify, ent, constrained)

	for i, {ent2} in ipairs(QUEUE)
		if ent2 == ent
			return true

	table.insert(QUEUE, {ent, ply, constrained, doNotify})
	return true

DPP2.UnqueueAntispam = (ent = NULL) ->
	return false if not DPP2.ENABLE_ANTISPAM\GetBool()
	return false if not DPP2.ANTISPAM_SPAM\GetBool() and not DPP2.ANTISPAM_VOLUME_SPAM\GetBool()

	for i, {ent2} in ipairs(QUEUE)
		if ent2 == ent
			table.remove(QUEUE, i)
			return true

	return false

ProcessQueue = ->
	return if #QUEUE == 0
	QUEUE2 = QUEUE
	QUEUE = {}

	notifications = {}
	notificationsG = {}
	notificationsAG = {}

	ANTISPAM_SPAM = DPP2.ANTISPAM_SPAM\GetBool()
	ANTISPAM_THRESHOLD = DPP2.ANTISPAM_THRESHOLD\GetFloat()
	ANTISPAM_THRESHOLD2 = DPP2.ANTISPAM_THRESHOLD2\GetFloat()

	ANTISPAM_VOLUME_SPAM = DPP2.ANTISPAM_VOLUME_SPAM\GetBool()
	ANTISPAM_VOLUME_AABB = DPP2.ANTISPAM_VOLUME_AABB\GetBool()
	ANTISPAM_VOLUME_THRESHOLD = DPP2.ANTISPAM_VOLUME_THRESHOLD\GetFloat()
	ANTISPAM_VOLUME_THRESHOLD2 = DPP2.ANTISPAM_VOLUME_THRESHOLD2\GetFloat()

	AUTO_GHOST_BY_SIZE = DPP2.AUTO_GHOST_BY_SIZE\GetBool()
	AUTO_GHOST_SIZE = DPP2.AUTO_GHOST_SIZE\GetFloat()

	AUTO_GHOST_BY_AABB = DPP2.AUTO_GHOST_BY_AABB\GetBool()
	AUTO_GHOST_AABB_SIZE = DPP2.AUTO_GHOST_AABB_SIZE\GetFloat()

	ANTISPAM_VOLUME_AABB_DIV = DPP2.ANTISPAM_VOLUME_AABB_DIV\GetFloat()

	markedForDeath = {}
	markedForGhost = {}

	recomputeAntispamValues()

	for i, {ent, ply, constrained, doNotify} in ipairs(QUEUE2)
		if IsValid(ent) and IsValid(ply)
			constrainedActuallyToGhost = 0
			constrainedActuallyToGhost += 1 for ent2 in *constrained when ent2\DPP2CanGhost()
			countThis = ent\DPP2CanGhost() and 1 or 0

			volumeDef = ComputeVolume(ent)
			volumeAABB = ComputeVolume2(ent) / ANTISPAM_VOLUME_AABB_DIV
			volume = volumeDef if ANTISPAM_VOLUME_SPAM and not ANTISPAM_VOLUME_AABB
			volume = volumeAABB / 1000 if ANTISPAM_VOLUME_SPAM and ANTISPAM_VOLUME_AABB

			hit = false
			shouldCheckSize = true
			shouldCheckAntispamSize = true

			if AUTO_GHOST_BY_SIZE and volumeDef > AUTO_GHOST_SIZE
				shouldCheckAntispamSize = false
				notificationsAG[ply] = (notificationsAG[ply] or 0) + countThis + constrainedActuallyToGhost if doNotify
				table.insert(markedForGhost, {ent, constrained})
			elseif AUTO_GHOST_BY_AABB and volumeAABB > AUTO_GHOST_AABB_SIZE
				shouldCheckAntispamSize = false
				notificationsAG[ply] = (notificationsAG[ply] or 0) + countThis + constrainedActuallyToGhost if doNotify
				table.insert(markedForGhost, {ent, constrained})

			if volume and shouldCheckAntispamSize
				pv = ply.__dpp2_antispam_volume
				ply.__dpp2_antispam_volume = (ply.__dpp2_antispam_volume + volume)\min(ANTISPAM_VOLUME_THRESHOLD2 * 2)

				if ply.__dpp2_antispam_volume >= ANTISPAM_VOLUME_THRESHOLD2 and pv > ANTISPAM_VOLUME_THRESHOLD
					notifications[ply] = (notifications[ply] or 0) + 1 + #constrained if doNotify
					table.insert(markedForDeath, ent)
					table.insert(markedForDeath, ent2) for ent2 in *constrained
					hit = true
				elseif ply.__dpp2_antispam_volume >= ANTISPAM_VOLUME_THRESHOLD
					notificationsG[ply] = (notificationsG[ply] or 0) + countThis + constrainedActuallyToGhost if doNotify
					table.insert(markedForGhost, {ent, constrained})

			if #constrained ~= 0 and ply.__dpp2_antispam_volume < ANTISPAM_VOLUME_THRESHOLD
				for ent2 in *constrained
					volume2 = ComputeVolume(ent2) if ANTISPAM_VOLUME_SPAM and not ANTISPAM_VOLUME_AABB
					volume2 = ComputeVolume2(ent2) / ANTISPAM_VOLUME_AABB_DIV / 1000 if ANTISPAM_VOLUME_SPAM and ANTISPAM_VOLUME_AABB
					ply.__dpp2_antispam_volume = (ply.__dpp2_antispam_volume + volume2)\min(ANTISPAM_VOLUME_THRESHOLD) if volume2

			if not hit and ANTISPAM_SPAM
				ply.__dpp2_antispam = (ply.__dpp2_antispam + 1)\min(ANTISPAM_THRESHOLD2 * 2)

				if ply.__dpp2_antispam >= ANTISPAM_THRESHOLD2
					notifications[ply] = (notifications[ply] or 0) + 1 + #constrained if doNotify
					table.insert(markedForDeath, ent)
					table.insert(markedForDeath, ent2) for ent2 in *constrained
				elseif ply.__dpp2_antispam >= ANTISPAM_THRESHOLD
					notificationsG[ply] = (notificationsG[ply] or 0) + countThis + constrainedActuallyToGhost if doNotify
					table.insert(markedForGhost, {ent, constrained})
				else
					ply.__dpp2_antispam = (ply.__dpp2_antispam + #constrained)\min(ANTISPAM_THRESHOLD)

	return if #markedForDeath == 0 and #markedForGhost == 0

	table.deduplicate(markedForDeath)
	table.deduplicate(markedForGhost)
	local toremove

	for i, ent in ipairs(markedForGhost)
		if table.qhasValue(markedForDeath, ent[1])
			toremove = toremove or {}
			table.insert(toremove, i)
			-- concurrent modification, but this one is safe
			table.append(markedForGhost, ent[2])
		else
			local toremove2

			for i2, ent2 in ipairs(ent[2])
				if table.qhasValue(markedForDeath, ent2)
					toremove2 = toremove2 or {}
					table.insert(toremove2, i)

			table.removeValues(ent[2], toremove2) if toremove2

	table.removeValues(markedForGhost, toremove) if toremove

	for {ent, constrained} in *markedForGhost
		table.insert(constrained, ent)
		DPP2.GhostGroup(constrained)

	SafeRemoveEntity(ent) for ent in *markedForDeath

	DPP2.NotifyError(ply, nil, count > 1 and 'message.dpp2.antispam.hint_removed' or 'message.dpp2.antispam.hint_removed_single', count > 1 and count or nil) for ply, count in pairs(notifications)
	DPP2.NotifyHint(ply, nil, count > 1 and 'message.dpp2.antispam.hint_ghosted' or 'message.dpp2.antispam.hint_ghosted_single', count > 1 and count or nil) for ply, count in pairs(notificationsG)
	DPP2.NotifyHint(ply, nil, count > 1 and 'message.dpp2.antispam.hint_ghosted_big' or 'message.dpp2.antispam.hint_ghosted_big_single', count > 1 and count or nil) for ply, count in pairs(notificationsAG)

hook.Add 'Tick', 'DPP2.Antispam', ProcessQueue, 2
hook.Add 'OnPhysgunReload', 'DPP2.Antispam', OnPhysgunReload, 1
