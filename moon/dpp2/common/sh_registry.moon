
-- Copyright (C) 2015-2019 DBotThePony

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

import DPP2, type, table, DLib, string, net from _G

if SERVER
	net.pool('dpp2_list_entry_create')
	net.pool('dpp2_list_entry_remove')
	net.pool('dpp2_list_entry_modify')

	net.pool('dpp2_blist_add')
	net.pool('dpp2_blist_remove')
	net.pool('dpp2_blist_replicate')

DPP2.DEF = DPP2.DEF or {}

class DPP2.DEF.RestrictionListEntry
	@nextid = 0

	@ADD_GROUP = 0
	@REMOVE_GROUP = 2
	@UPDATE_WHITELIST_STATE = 1
	@FULL_REPLICATE = 3

	if CLIENT
		net.receive 'dpp2_list_entry_create', ->
			id, list = net.ReadUInt32(), net.ReadString()
			entry = @ReadPayload()
			entry\SetID(id)
			entry\SetParent(assert(DPP2.DEF.RestrictionList\GetByID(list), 'Invalid list received: ' .. list))
			entry.replicated = true

		net.receive 'dpp2_list_entry_remove', ->
			id = net.ReadUInt32()
			entry = assert(DPP2.DEF.RestrictionList\FindEntry(id), 'Unable to find restriction entry with id ' .. id .. ' (for remove)')
			entry.removed = true
			entry.replicated = false
			entry.parent\RemoveEntry(entry) if entry.parent

		net.receive 'dpp2_list_entry_modify', ->
			id = net.ReadUInt32()
			entry = assert(DPP2.DEF.RestrictionList\FindEntry(id), 'Unable to find restriction entry with id ' .. id .. ' (for modify)')
			modif = net.ReadUInt8()

			switch modif
				when @ADD_GROUP
					entry\AddGroup(net.ReadString())
				when @REMOVE_GROUP
					entry\RemoveGroup(net.ReadString())
				when @UPDATE_WHITELIST_STATE
					entry\SwitchIsWhitelist(net.ReadBool())
				when @FULL_REPLICATE
					entry\ReadPayload()
				else
					error('Unknown modify state: ' .. modif)

	new: (strClass, grouplist = {}, isWhitelist = false, parent) =>
		@class = strClass
		@groups = grouplist
		@isWhitelist = isWhitelist
		@id = @@nextid
		@@nextid += 1
		@parent = parent
		@replicated = false
		@locked = false
		@removed = false

		if SERVER
			@Replicate() if parent

	Remove: =>
		return false if @removed
		return false if SERVER and @replicated

		if SERVER and @replicated
			net.Start('dpp2_list_entry_remove')
			net.WriteUInt32(@id)
			net.Broadcast()

		@removed = true
		@replicated = false
		return true

	SwitchIsWhitelist: (isWhitelist = @isWhitelist) =>
		return false if isWhitelist == @isWhitelist
		@isWhitelist = isWhitelist

		if SERVER and @replicated and not @locked
			net.Start('dpp2_list_entry_modify')
			net.WriteUInt32(@id)
			net.WriteUInt8(@@UPDATE_WHITELIST_STATE)
			net.WriteBool(isWhitelist)
			net.Broadcast()

		return true

	AddGroup: (group) =>
		assert(type(group) == 'string', 'Group must be a string')
		return false if table.qhasValue(@groups, group)
		table.insert(@groups, group)

		if SERVER and @replicated and not @locked
			net.Start('dpp2_list_entry_modify')
			net.WriteUInt32(@id)
			net.WriteUInt8(@@ADD_GROUP)
			net.WriteString(group)
			net.Broadcast()

		return true

	RemoveGroup: (group) =>
		assert(type(group) == 'string', 'Group must be a string')
		return false if not table.qhasValue(@groups, group)

		for i, group2 in ipairs(@groups)
			if group == group2
				table.remove(@groups, i)
				break

		if SERVER and @replicated and not @locked
			net.Start('dpp2_list_entry_modify')
			net.WriteUInt32(@id)
			net.WriteUInt8(@@REMOVE_GROUP)
			net.WriteString(group)
			net.Broadcast()

		return true

	Lock: =>
		error('Invalid side') if CLIENT
		@locked = true
		return @

	UnLock: =>
		error('Invalid side') if CLIENT
		@locked = false
		return @

	WritePayload: =>
		net.WriteString(@class)
		net.WriteStringArray(@groups)
		net.WriteBool(@isWhitelist)

	ReadPayload: =>
		@class = net.ReadString()
		@groups = net.ReadStringArray()
		@isWhitelist = net.ReadBool()

	@ReadPayload: =>
		classname = net.ReadString()
		groups = net.ReadStringArray()
		isWhitelist = net.ReadBool()
		return DPP2.DEF.RestrictionListEntry(classname, groups, isWhitelist)

	SetParent: (parent) =>
		@parent = parent

	SetID: (id = @id) =>
		@id = id
		return @

	GetID: => @id

	Replicate: =>
		error('Invalid side') if CLIENT
		error('Removed') if @removed

		if not @replicated
			@replicated = true
			net.Start('dpp2_list_entry_create')
			net.WriteUInt32(@id)
			net.WriteString(@parent)
			@WritePayload()
			net.Broadcast()
		else
			net.Start('dpp2_list_entry_modify')
			net.WriteUInt32(@id)
			net.WriteUInt8(@@FULL_REPLICATE)
			@WritePayload()
			net.Broadcast()

	Is: (classname) => @class == classname
	Ask: (classname, group, isAdmin) =>
		return if classname ~= @
		return @isWhitelist if table.qhasValue(@groups, group)

class DPP2.DEF.RestrictionList
	@LISTS = {}
	@_LISTS = {}

	@GetByID: (id) => @LISTS[id] or false

	@FindEntry: (id) =>
		for list in *@_LISTS
			for entry in *list.listing
				if entry.id == id
					return entry

		return false

	new: (identifier) =>
		@identifier = identifier
		error('Restriction list ' .. identifier .. ' already exists! Can not redefine existing one.') if @@LISTS[identifier]
		@@LISTS[@identifier] = @
		@listing = {}
		@@_LISTS = [list for key, list in pairs(@LISTS)]

	AddEntry: (entry) =>
		return false if table.qhasValue(@listing, entry)
		table.insert(@listing, entry)
		return true

	RemoveEntry: (entry) =>
		for i, entry2 in ipairs(@listing)
			if entry == entry2
				table.remove(@listing, i)
				return true

		return false

	CreateEntry: (...) =>
		entry = DPP2.DEF.RestrictionListEntry(...)
		@AddEntry(entry)
		return entry

	Ask: (classname, ply) =>
		group, isAdmin = ply\GetUserGroup(), ply\IsAdmin()

		for entry in *@listing
			status = entry\Ask(classname, group, isAdmin)
			return status if status ~= nil

		return true

	Has: (classname) =>
		return true for entry in *@listing when entry\Is(classname)
		return false

class DPP2.DEF.Blacklist
	@REGISTRY = {}
	@REGISTRY_ = {}
	@nextid = 0

	if CLIENT
		net.receive 'dpp2_blist_add', ->
			list, entry = assert(@REGISTRY_[net.ReadUInt8()], 'Missing blacklist registry'), net.ReadString()
			list\Add(entry)

		net.receive 'dpp2_blist_remove', ->
			list, entry = assert(@REGISTRY_[net.ReadUInt8()], 'Missing blacklist registry'), net.ReadString()
			list\Remove(entry)

		net.receive 'dpp2_blist_replicate', ->
			list, listing = assert(@REGISTRY_[net.ReadUInt8()], 'Missing blacklist registry'), net.ReadStringArray()
			list.listing = DLib.Set()
			list\Add(val) for val in *listing

	new: (identifier, autocomplete) =>
		assert(identifier, 'Blacklist registry without identifier')
		error('Blacklist ' .. identifier .. ' already exists! Can not redefine existing one.') if @@REGISTRY[identifier]

		@@REGISTRY[identifier] = @
		@id = @@nextid
		@@nextid += 1
		@@REGISTRY_[@id] = @
		@identifier = identifier
		@listing = DLib.Set()
		@listingDef = DLib.Set()
		self2 = @

		if SERVER
			DPP2.cmd['add_' .. identifier .. '_blacklist'] = (args = {}) =>
				val = table.concat(args, ' ')\trim()
				return 'message.dpp2.concommand.lists.arg_empty' if val == ''
				return 'message.dpp2.concommand.lists.already_in' if self2\Has(val)
				self2\Add(val)
				DPP2.Notify(true, nil, 'message.dpp2.concommand.blists.added.' .. identifier, @, val)

			DPP2.cmd['remove_' .. identifier .. '_blacklist'] = (args = {}) =>
				val = table.concat(args, ' ')\trim()
				return 'message.dpp2.concommand.lists.arg_empty' if val == ''
				return 'message.dpp2.concommand.lists.already_not' if not self2\Has(val)
				self2\Remove(val)
				DPP2.Notify(true, nil, 'message.dpp2.concommand.blists.removed.' .. identifier, @, val)

		DPP2.cmd_perms['add_' .. identifier .. '_blacklist'] = 'superadmin'
		DPP2.cmd_perms['remove_' .. identifier .. '_blacklist'] = 'superadmin'

		if autocomplete
			DPP2.cmd_autocomplete['add_' .. identifier .. '_blacklist'] = (args, margs) => autocomplete(@, args, margs, self2.listing\GetValues())
		elseif CLIENT
			DPP2.cmd_existing['add_' .. identifier .. '_blacklist'] = true

		DPP2.cmd_autocomplete['remove_' .. identifier .. '_blacklist'] = (args, margs) =>
			return [string.format('%q', elem) for elem in *@listing\GetValues()] if args == ''
			args = args\lower()

			output = {}

			for elem in *@listing\GetValues()
				with lower = elem\lower()
					if lower == args
						output = {elem}
						break

					if \startsWith(args)
						table.insert(output, elem)

			return output

	Add: (entry) =>
		return false if @Has(entry)
		@listing\Add(entry)

		if SERVER
			net.Start('dpp2_blist_add')
			net.WriteUInt8(@id)
			net.WriteString(entry)
			net.Broadcast()

		return true

	AddDefault: (entry) => @listingDef\Add(entry)

	Remove: (entry) =>
		return false if not @Has(entry)

		if SERVER
			net.Start('dpp2_blist_remove')
			net.WriteUInt8(@id)
			net.WriteString(entry)
			net.Broadcast()

		@listing\Remove(entry)
		return true

	RemoveDefault: (entry) => @listingDef\Remove(entry) -- ???
	Has: (entry) => @listing\Has(entry)
	HasDefault: (entry) => @listingDef\Has(entry) -- ???

	FullReplicate: (who = player.GetAll()) =>
		error('Invalid side') if CLIENT
		net.Start('dpp2_blist_replicate')
		net.WriteUInt8(@id)
		net.WriteStringArray(@listing\GetValues())
		net.Send(who)

