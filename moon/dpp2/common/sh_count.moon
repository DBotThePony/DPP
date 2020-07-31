
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

import DPP2, DLib from _G
import net from DLib

DPP2.NO_LIMIT_FOR_HOST = DPP2.CreateConVar('no_host_limits', '1', DPP2.TYPE_BOOL)
DPP2.LIMITS_LIST_ENABLED = DPP2.CreateConVar('limits_lists_enabled', '1', DPP2.TYPE_BOOL)

if not DPP2.g_SBoxObjects
	DPP2.g_SBoxObjects = setmetatable(g_SBoxObjects or {}, {
		__index: (key) =>
			return nil if not isstring(key)
	})

	_G.g_SBoxObjects = DPP2.g_SBoxObjects

DPP2.PlayerCounts = DPP2.PlayerCounts or {}
PlayerCounts = DPP2.PlayerCounts

plyMeta = FindMetaTable('Player')

plyMeta.GetCount = (mode, minus = 0) =>
	assert(isstring(mode), 'Mode should be a string')
	assert(isnumber(minus), 'Minus should be a number')

	return @GetNWUInt('dpp2_count_' .. mode, 0) if CLIENT
	steamid = @IsBot() and @UniqueID() or @SteamID()
	return 0 if not PlayerCounts[steamid]
	return 0 if not PlayerCounts[steamid][mode]

	for ent in *PlayerCounts[steamid][mode]
		if not IsValid(ent)
			PlayerCounts[steamid][mode] = [ent2 for ent2 in *PlayerCounts[steamid][mode] when IsValid(ent2)]
			break

	@SetNWUInt('dpp2_count_' .. mode, #PlayerCounts[steamid][mode])
	return #PlayerCounts[steamid][mode]

plyMeta.AddCount = (mode, ent) =>
	assert(isstring(mode), 'Mode should be a string')
	assert(IsValid(ent), 'Tried to use a NULL Entity!')
	return if CLIENT

	steamid = @IsBot() and @UniqueID() or @SteamID()
	PlayerCounts[steamid] = {} if not PlayerCounts[steamid]
	PlayerCounts[steamid][mode] = {} if not PlayerCounts[steamid][mode]

	return false if table.qhasValue(PlayerCounts[steamid][mode], ent)
	table.insert(PlayerCounts[steamid][mode], ent)
	@GetCount(mode)
	return true

plyMeta.LimitHit = (mode) =>
	assert(isstring(mode), 'Mode should be a string')

	if CLIENT
		hook.Run('LimitHit', mode)
	else
		net.Start('dpp2_limithit')
		net.WriteString(mode)
		net.Send(@)

	return

cache = {}

patch = ->
	plyMeta.CheckLimit = (mode, notify = SERVER) =>
		assert(isstring(mode), 'Mode should be a string')
		return true if game.SinglePlayer()
		return true if DPP2.NO_LIMIT_FOR_HOST\GetBool() and (not game.IsDedicated() or game.GetIPAddress() == 'loopback' or game.GetIPAddress() == '0.0.0.0:0') and @EntIndex() == 1

		mode = mode\lower()
		cache[mode] = cache[mode] or assert(ConVar('sbox_max' .. mode), 'No such ConVar: sbox_max' .. mode)

		entry = DPP2.SBoxLimits\Get(mode, @GetUserGroup()) if DPP2.SBoxLimits\IsEnabled()
		limit = entry and entry.limit or cache[mode]\GetInt()
		limit = 0 if not entry and DPP2.SBoxLimits\IsEnabled() and DPP2.SBoxLimits\IsInclusive()

		return true if limit < 0

		if limit <= @GetCount(mode)
			if notify
				if CLIENT
					hook.Run('LimitHit', mode)
				else
					net.Start('dpp2_limithit')
					net.WriteString(mode)
					net.Send(@)

			return false

		return true

patch()
hook.Add 'Initialize', 'DPP2.PatchCheckLimit', patch

nextid = DPP2.DEF.LimitEntry and DPP2.DEF.LimitEntry.NEXT_ID or 0

class DPP2.DEF.LimitEntry
	@REPLICATION_PAUSED = false
	@PauseReplication = =>	@REPLICATION_PAUSED = true
	@UnpauseReplication = => @REPLICATION_PAUSED = false

	@Deserialize = (data) => DPP2.DEF.LimitEntry(data.classname, data.group, data.limit)

	@NEXT_ID = nextid

	@GetByID: (id) =>
		for obj in *DPP2.DEF.LimitRegistry._OBJECTS
			entry = obj\GetByID(id)
			return entry if entry

		return false

	new: (classname, group, limit) =>
		assert(isstring(classname), 'Classname must be a string')
		assert(isstring(group), 'Group must be a string')
		assert(isnumber(limit), 'Group must be a number')
		@class = classname
		@group = group
		@limit = limit
		@id = @@NEXT_ID
		@@NEXT_ID += 1
		@removed = false
		@replicated = false

	Bind: (parent, doReplicate = SERVER) =>
		error('Already parented') if @parent
		error('Entry is removed') if @removed
		@parent = parent
		@Replicate() if doReplicate
		return @

	Replicate: =>
		error('Invalid side') if CLIENT
		error('Missing parent!') if not @parent
		return false if @replicated
		return false if @@REPLICATION_PAUSED

		net.Start('dpp2_limitentry_create')
		net.WriteString(@parent.identifier)
		net.WriteUInt32(@id)
		@WritePayload()
		net.Broadcast()

		@replicated = true
		return true

	Remove: =>
		return false if @removed
		@removed = true
		@parent\RemoveEntry(@) if @parent

		if SERVER and @replicated
			net.Start('dpp2_limitentry_remove')
			net.WriteUInt32(@id)
			net.Broadcast()

		return true

	SetLimit: (newLimit = @limit) =>
		return false if newLimit == @limit
		@limit = newLimit

		if SERVER
			net.Start('dpp2_limitentry_change')
			net.WriteUInt32(@id)
			@WritePayload()
			net.Broadcast()

		@parent\CallHook('EntryChanged', entry) if @parent

		return true

	IsValid: => not @removed
	Is: (classname, group = @group) => @class == classname and @group == group

	Serialize: =>
		return {
			classname: @class
			group: @group
			limit: @limit
		}

	WritePayload: =>
		net.WriteString(@class)
		net.WriteString(@group)
		net.WriteInt32(@limit)

	ReadPayload: =>
		@class = net.ReadString()
		@group = net.ReadString()
		@limit = net.ReadInt32()
		@parent\CallHook('EntryChanged', entry) if @parent

	@ReadPayload: =>
		classname = net.ReadString()
		group = net.ReadString()
		limit = net.ReadInt32()
		return DPP2.DEF.LimitEntry(classname, group, limit)

class DPP2.DEF.LimitRegistry
	@OBJECTS = {}
	@_OBJECTS = {}

	@GetByID = (id) => @OBJECTS[id] or false

	new: (identifier, autocomplete) =>
		@identifier = assert(isstring(identifier) and identifier, 'Identifier must be a string')
		assert(not @@OBJECTS[identifier], 'Cannot redefine LimitRegistry ' .. identifier .. '!')
		@@OBJECTS[@identifier] = @
		table.insert(@@_OBJECTS, @)
		@listing = {}
		self2 = @

		@ENABLED = DPP2.CreateConVar(identifier .. '_limits_enabled', '1', DPP2.TYPE_BOOL)
		@IS_INCLUSIVE = DPP2.CreateConVar(identifier .. '_limits_inclusive', '0', DPP2.TYPE_BOOL)

		@add_command_identifier = 'add_' .. identifier .. '_limit'
		@remove_command_identifier = 'remove_' .. identifier .. '_limit'

		@add_autocomplete = autocomplete

		if SERVER
			DPP2.cmd[@add_command_identifier] = (args = {}) =>
				prop = args[1]
				group = args[2]
				limit = tonumber(args[3])

				return 'command.dpp2.lists.arg_empty' if not prop
				prop = prop\trim()\lower()
				return 'command.dpp2.lists.arg_empty' if prop == ''

				return 'command.dpp2.lists.group_empty' if not group
				group = group\trim()\lower()
				return 'command.dpp2.lists.group_empty' if group == ''

				return 'command.dpp2.lists.limit_empty' if not limit

				if entry = self2\Get(prop, group)
					entry\SetLimit(limit)
					DPP2.Notify(true, nil, 'command.dpp2.limit_lists.modified.' .. identifier, @, prop, group, limit)
					return

				self2\CreateEntry(prop, group, limit)\Replicate()
				DPP2.Notify(true, nil, 'command.dpp2.limit_lists.added.' .. identifier, @, prop, group, limit)

			DPP2.cmd[@remove_command_identifier] = (args = {}) =>
				prop = args[1]
				group = args[2]

				return 'command.dpp2.lists.arg_empty' if not prop
				prop = prop\trim()\lower()
				return 'command.dpp2.lists.arg_empty' if prop == ''

				return 'command.dpp2.lists.group_empty' if not group
				group = group\trim()\lower()
				return 'command.dpp2.lists.group_empty' if group == ''

				entry = self2\Get(prop, group)
				return 'command.dpp2.lists.already_not' if not entry

				entry\Remove()
				DPP2.Notify(true, nil, 'command.dpp2.limit_lists.removed.' .. identifier, @, prop, group)

		DPP2.cmd_autocomplete[@add_command_identifier] = (args, margs) =>
			split = DPP2.SplitArguments(args)

			if not split[2]
				if autocomplete
					list = autocomplete(@, split[1] or '', margs, nil, false)

					return if not list

					for i, line in ipairs(list)
						if get = self2\Get(line)
							list[i] = string.format('%q', line) .. ' "' .. get.group .. '" ' .. tostring(get.limit)
						else
							list[i] = string.format('%q', line)

					return list

				return {string.format('%q', split[1])}

			str = string.format('%q', split[1])
			lastGroup = split[2]\trim()
			groups = {string.format('%q', lastGroup)}

			for group in pairs(CAMI.GetUsergroups())
				if group\startsWith(lastGroup)
					table.insert(groups, string.format('%q', group))

			if not split[3] and margs[#margs] ~= ' '
				return [str .. ' ' .. group for group in *groups]

			if not split[3]
				return {str .. ' ' .. groups[1] .. ' <number>'}

			return {str .. ' ' .. string.format('%q %q', lastGroup, split[3])}

		DPP2.cmd_autocomplete[@remove_command_identifier] = (args, margs) =>
			split = DPP2.SplitArguments(args)
			return [string.format('%q', elem.class) for elem in *self2.listing] if args == '' or not split[1]

			listing = {}

			for elem in *self2.listing
				listing[elem.class] = {} if not listing[elem.class]
				table.insert(listing[elem.class], elem)

			output = {}
			str = string.format('%q', split[1])
			local last

			for elem, list in pairs(listing)
				with lower = elem\lower()
					if lower == split[1]
						output = {string.format('%q', elem)}
						last = list
						break

					if \startsWith(split[1])
						table.insert(output, string.format('%q', elem))
						last = list

			if not last or #output > 1 and not split[2] and margs[#margs] ~= ' '
				return output

			if split[2]
				group = split[2]\lower()
				return [output[1] .. ' ' .. string.format('%q', elem.group) for elem in *last when elem.group\lower()\startsWith(group)]
			else
				return [output[1] .. ' ' .. string.format('%q', elem.group) for elem in *last]

		DPP2.cmd_perms[@add_command_identifier] = 'superadmin'
		DPP2.cmd_perms[@remove_command_identifier] = 'superadmin'

		@LoadFromDisk() if SERVER

		if CLIENT
			if IsValid(LocalPlayer())
				timer.Simple 1, -> @RequestFromServer()
			else
				frames = 0
				hook.Add 'Think', 'DPP2_Limits_' .. identifier .. '_request', ->
					ply = LocalPlayer()
					return if not IsValid(ply)

					if ply\GetVelocity()\Length() > 0
						frames += 1

					if frames > 400
						@RequestFromServer()
						hook.Remove 'Think', 'DPP2_Limits_' .. identifier .. '_request'

	GetByID: (id) =>
		return entry for entry in *@listing when entry.id == id
		return false

	Has: (classname, group) => @Get(classname, group) ~= false

	Get: (classname, group) =>
		return entry for entry in *@listing when entry\Is(classname, group)
		return false

	GetByClass: (classname) => [entry for entry in *@listing when entry\Is(classname)]

	AddEntry: (entry) =>
		return false if @Has(entry.classname, entry.group)
		table.insert(@listing, entry)
		@CallHook('EntryAdded', entry)
		@SaveTimer()
		return true

	IsEnabled: => DPP2.LIMITS_LIST_ENABLED\GetBool() and @ENABLED\GetBool()
	IsInclusive: => @IS_INCLUSIVE\GetBool()

	RemoveEntry: (entry) =>
		for i, entry2 in ipairs(@listing)
			if entry == entry2
				table.remove(@listing, i)
				@CallHook('EntryRemoved', entry2)
				@SaveTimer()
				return true

		return false

	CreateEntry: (...) =>
		entry = DPP2.DEF.LimitEntry(...)
		return false if not @AddEntry(entry)
		entry\Bind(@)
		return entry

	CallHook: (name, entry, ...) => hook.Run('DPP2_Limits_' .. @identifier .. '_' .. name, @, entry, ...)

	FullReplicate: (who = player.GetHumans()) =>
		error('Invalid side') if not SERVER

		net.Start('dpp2_limitlist_replicate')
		net.WriteString(@identifier)
		net.WriteUInt16(#@listing)

		for entry in *@listing
			net.WriteUInt32(entry.id)
			entry\WritePayload()
			entry.replicated = true

		net.Send(who)

	RequestFromServer: =>
		return if SERVER
		net.Start('dpp2_limitlist_replicate')
		net.WriteString(@identifier)
		net.SendToServer()

	SaveTimer: =>
		return if not SERVER
		timer.Create 'DPP2_Save_' .. @identifier .. '_Limits', 0.25, 1, ->
			@MakeBackup()
			@SaveToDisk()

	BuildSaveString: => SERVER and util.TableToJSON([entry\Serialize() for entry in *@listing], true) or error('Invalid side')
	DefaultSavePath: => 'dpp2/' .. @identifier .. '_limits.json'
	SaveToDisk: (path = @DefaultSavePath()) => file.Write(path, @BuildSaveString())
	LoadFrom: (str) =>
		error('Invalid side') if not SERVER
		@listing = {}
		rebuild = util.JSONToTable(str)

		if not rebuild
			net.Start('dpp2_limitlist_clear')
			net.WriteString(@identifier)
			net.Broadcast()
			return false

		DPP2.DEF.LimitEntry\PauseReplication()
		@AddEntry(DPP2.DEF.LimitEntry\Deserialize(object)\Bind(@)) for object in *rebuild
		DPP2.DEF.LimitEntry\UnpauseReplication()

		@FullReplicate() if player.GetCount() ~= 0

		timer.Remove('DPP2_Save_' .. @identifier .. '_Limits')
		return true

	MakeBackup: =>
		path = @DefaultSavePath()
		return false if not file.Exists(path, 'data')
		file.Write('dpp2/backup/' .. @identifier .. '_limits_' .. os.date('%Y-%m-%d-%H_%M_%S') .. '.json', file.Read(path, 'data'))
		return true

	LoadFromDisk: (path = @DefaultSavePath()) =>
		return false if not file.Exists(path, 'data')
		return @LoadFrom(file.Read(path, 'data'))

DPP2.SBoxLimits = DPP2.DEF.LimitRegistry('sbox')
DPP2.PerEntityLimits = DPP2.DEF.LimitRegistry('entity', DPP2.ClassnameAutocomplete)
DPP2.PerModelLimits = DPP2.DEF.LimitRegistry('model', DPP2.ModelAutocomplete)
