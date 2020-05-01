
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

_URSLimits = (dryrun = true, json) =>
	if json.prop
		json.props = json.prop
		json.prop = nil

	if dryrun
		for limittype, data in pairs(json)
			for group, limit in pairs(data)
				if DPP2.SBoxLimits\Has(limittype, group)
					DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.no_limit.' .. limittype, group, limit)
				else
					DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.limit.' .. limittype, group, limit)
	else
		for limittype, data in pairs(json)
			for group, limit in pairs(data)
				if not DPP2.SBoxLimits\Has(limittype, group)
					DPP2.SBoxLimits\CreateEntry(limittype, group, tonumber(limit))\Replicate()
					DPP2.Notify(true, nil, 'command.dpp2.limit_lists.added.' .. DPP2.SBoxLimits.identifier, @, limittype, group, limit)

URSLimits = (dryrun = true) =>
	return 'message.dpp2.import.no_file' if not file.Exists('ulx/limits.txt', 'DATA')
	read = file.Read('ulx/limits.txt', 'DATA')
	return 'message.dpp2.import.empty_file' if not read or read == ''
	json = util.JSONToTable(read)
	return 'message.dpp2.import.bad_file' if not json

	_URSLimits(@, dryrun, json)

	DPP2.LMessagePlayer(@, 'message.dpp2.import.done')
	DPP2.LMessagePlayer(@, 'message.dpp2.import.done_dryrun') if dryrun

	return

URMLimits = (dryrun = true) =>
	return 'message.dpp2.import.no_file' if not file.Exists('urm/limits.txt', 'DATA')
	read = file.Read('urm/limits.txt', 'DATA')
	return 'message.dpp2.import.empty_file' if not read or read == ''
	json = util.JSONToTable(read)
	return 'message.dpp2.import.bad_file' if not json

	if dryrun
		for group, data in pairs(json)
			for limittype, limit in pairs(data)
				if DPP2.SBoxLimits\Has(limittype, group)
					DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.no_limit.' .. limittype, group, limit)
				else
					DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.limit.' .. limittype, group, limit)
	else
		for group, data in pairs(json)
			for limittype, limit in pairs(data)
				if not DPP2.SBoxLimits\Has(limittype, group)
					DPP2.SBoxLimits\CreateEntry(limittype, group, tonumber(limit))\Replicate()
					DPP2.Notify(true, nil, 'command.dpp2.limit_lists.added.' .. DPP2.SBoxLimits.identifier, @, limittype, group, limit)

	DPP2.LMessagePlayer(@, 'message.dpp2.import.done')
	DPP2.LMessagePlayer(@, 'message.dpp2.import.done_dryrun') if dryrun

	return

maprestricts = {
	tool: DPP2.ToolgunModeRestrictions
	pickup: DPP2.PickupProtection.RestrictionList
	-- all: DPP2.SpawnRestrictions

	effect: DPP2.ModelRestrictions
	prop: DPP2.ModelRestrictions
	ragdoll: DPP2.ModelRestrictions

	vehicle: DPP2.VehicleProtection.RestrictionList
	use: DPP2.UseProtection.RestrictionList
	swep: DPP2.SpawnRestrictions
	sent: DPP2.SpawnRestrictions
	npc: DPP2.SpawnRestrictions
}

_URSRestricts = (dryrun, json) =>
	if dryrun
		for key, registry in pairs(maprestricts)
			if data = json[key]
				for identifier, grouplist in pairs(data)
					if #grouplist > 0
						if registry\Has(identifier)
							DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.no_restrict.' .. key, identifier, table.concat([string.format('%q', group) for group in *grouplist], ', '))
						else
							DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.restrict.' .. key, identifier, table.concat([string.format('%q', group) for group in *grouplist], ', '))
	else
		for key, registry in pairs(maprestricts)
			if data = json[key]
				for identifier, grouplist in pairs(data)
					if #grouplist > 0 and not registry\Has(identifier)
						registry\CreateEntry(identifier, grouplist, false)\Replicate()
						DPP2.Notify(true, nil, 'command.dpp2.rlists.added_ext.' .. registry.identifier, @, identifier, table.concat(grouplist, ', '), false)

URSRestricts = (dryrun = true) =>
	return 'message.dpp2.import.no_file' if not file.Exists('ulx/restrictions.txt', 'DATA')
	read = file.Read('ulx/restrictions.txt', 'DATA')
	return 'message.dpp2.import.empty_file' if not read or read == ''
	json = util.JSONToTable(read)
	return 'message.dpp2.import.bad_file' if not json

	_URSRestricts(@, dryrun, json)
	DPP2.LMessagePlayer(@, 'message.dpp2.import.done')
	DPP2.LMessagePlayer(@, 'message.dpp2.import.done_dryrun') if dryrun
	return

URMRestricts = (dryrun = true) =>
	return 'message.dpp2.import.no_file' if not file.Exists('urm/restrictions.txt', 'DATA')
	read = file.Read('urm/restrictions.txt', 'DATA')
	return 'message.dpp2.import.empty_file' if not read or read == ''
	json = util.JSONToTable(read)
	return 'message.dpp2.import.bad_file' if not json

	json2 = json
	json = {}

	for group, data in pairs(json2)
		for restricttype, listing in pairs(data)
			json[restricttype] = json[restricttype] or {}
			for object in pairs(listing)
				json[restricttype][object] = json[restricttype][object] or {}
				table.insert(json[restricttype][object], group)

	_URSRestricts(@, dryrun, json)
	DPP2.LMessagePlayer(@, 'message.dpp2.import.done')
	DPP2.LMessagePlayer(@, 'message.dpp2.import.done_dryrun') if dryrun
	return

WUMALimits = (dryrun = true) =>
	return 'message.dpp2.import.no_file' if not file.Exists('wuma/limits.txt', 'DATA')
	read = file.Read('wuma/limits.txt', 'DATA')
	return 'message.dpp2.import.empty_file' if not read or read == ''
	json = util.JSONToTable(read)
	return 'message.dpp2.import.bad_file' if not json

	DPP2.LMessageWarningPlayer(@, 'message.dpp2.import.wuma_warning')
	DPP2.LMessageWarningPlayer(@, 'message.dpp2.import.wuma_warning2')

	sboxlim = {}
	entlim = {}

	for auto_index, entry_data in pairs(json)
		if entry_data._id == 'WUMA_Limit'
			target = entlim
			target = sboxlim if ConVar('sbox_max' .. entry_data.string)
			print(entry_data.string)
			target[entry_data.string] = target[entry_data.string] or {}
			target[entry_data.string][entry_data.usergroup] = entry_data.limit

	_URSLimits(@, dryrun, sboxlim)

	if dryrun
		for limittype, data in pairs(entlim)
			for group, limit in pairs(data)
				if not DPP2.PerEntityLimits\Has(limittype, group)
					DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.entlimit', limittype, group, limit)
				else
					DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.no_entlimit', limittype, group, limit)
	else
		for limittype, data in pairs(entlim)
			for group, limit in pairs(data)
				if not DPP2.PerEntityLimits\Has(limittype, group)
					DPP2.PerEntityLimits\CreateEntry(limittype, group, tonumber(limit))\Replicate()
					DPP2.Notify(true, nil, 'command.dpp2.limit_lists.added.' .. DPP2.PerEntityLimits.identifier, @, limittype, group, limit)

	DPP2.LMessagePlayer(@, 'message.dpp2.import.done')
	DPP2.LMessagePlayer(@, 'message.dpp2.import.done_dryrun') if dryrun

	return

mapwumarestricts = {
	tool: DPP2.ToolgunModeRestrictions
	property: DPP2.ToolgunModeRestrictions
	pickup: DPP2.PickupProtection.RestrictionList
	-- all: DPP2.SpawnRestrictions

	effect: DPP2.ModelRestrictions
	prop: DPP2.ModelRestrictions
	ragdoll: DPP2.ModelRestrictions

	vehicle: DPP2.VehicleProtection.RestrictionList
	use: DPP2.UseProtection.RestrictionList
	swep: DPP2.SpawnRestrictions
	entity: DPP2.SpawnRestrictions
	sent: DPP2.SpawnRestrictions
	npc: DPP2.SpawnRestrictions
}

WUMARestricts = (dryrun = true) =>
	return 'message.dpp2.import.no_file' if not file.Exists('wuma/restrictions.txt', 'DATA')
	read = file.Read('wuma/restrictions.txt', 'DATA')
	return 'message.dpp2.import.empty_file' if not read or read == ''
	json = util.JSONToTable(read)
	return 'message.dpp2.import.bad_file' if not json

	DPP2.LMessageWarningPlayer(@, 'message.dpp2.import.wuma_warning_restr')

	target = {}

	for auto_index, entry_data in pairs(json)
		if registry = mapwumarestricts[entry_data.type]
			target[registry] = target[registry] or {}
			target[registry][entry_data.string] = target[registry][entry_data.string] or {}
			table.insert(target[registry][entry_data.string], entry_data.usergroup)

	if dryrun
		for registry, data in pairs(target)
			for identifier, groups in pairs(data)
				if registry\Has(identifier)
					DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.restrict.' .. registry.identifier, identifier, table.concat([string.format('%q', group) for group in *groups], ', '))
				else
					DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.no_restrict.' .. registry.identifier, identifier, table.concat([string.format('%q', group) for group in *groups], ', '))
	else
		for registry, data in pairs(target)
			for identifier, groups in pairs(data)
				if not registry\Has(identifier)
					registry\CreateEntry(identifier, grouplist, false)\Replicate()
					DPP2.Notify(true, nil, 'command.dpp2.rlists.added_ext.' .. registry.identifier, @, identifier, table.concat(groups, ', '), false)

	DPP2.LMessagePlayer(@, 'message.dpp2.import.done')
	DPP2.LMessagePlayer(@, 'message.dpp2.import.done_dryrun') if dryrun
	return

local _DPPLink

DPPLink = =>
	_DPPLink = DMySQL3.Connect('dpp') if not _DPPLink
	return _DPPLink

FPP_Blocked = {
	Gravgun1: DPP2.GravgunProtection.Blacklist
	Physgun1: DPP2.PhysgunProtection.Blacklist
	Toolgun1: DPP2.ToolgunProtection.Blacklist
	EntityDamage1: DPP2.DamageProtection.Blacklist
}

ImportFPP = (dryrun = true) =>
	DPP2.LMessageWarningPlayer(@, 'message.dpp2.import.fpp_db')

	DPPLink!\Query 'SELECT * FROM fpp_blockedmodels1', (data) ->
		return if not data

		for row in *data
			model = row.model\lower()

			if not DPP2.ModelBlacklist\Has(model)
				if dryrun
					DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.block_model', model)
				else
					DPP2.ModelBlacklist\Add(model)
					DPP2.Notify(true, nil, 'command.dpp2.' .. DPP2.ModelBlacklist.__class.REGULAR_NAME .. '.added.' .. DPP2.ModelBlacklist.identifier, @, model)
			elseif dryrun
				DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.no_block_model', model)

		DPP2.LMessagePlayer(@, 'message.dpp2.import.done')
		DPP2.LMessagePlayer(@, 'message.dpp2.import.done_dryrun') if dryrun

	DPPLink!\Query 'SELECT * FROM fpp_blocked1', (data) ->
		return if not data

		for row in *data
			if registry = FPP_Blocked[row.var]
				classname = row.setting

				if not registry\Has(classname)
					if dryrun
						DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.block_thing_from.' .. registry.identifier, classname)
					else
						registry\Add(classname)
						DPP2.Notify(true, nil, 'command.dpp2.' .. registry.__class.REGULAR_NAME .. '.added.' .. registry.identifier, @, classname)
				elseif dryrun
					DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.no_block_thing_from.' .. registry.identifier, classname)

		DPP2.LMessagePlayer(@, 'message.dpp2.import.done')
		DPP2.LMessagePlayer(@, 'message.dpp2.import.done_dryrun') if dryrun

	DPPLink!\Query 'SELECT * FROM fpp_tooladminonly', (data) ->
		return if not data
		registry = DPP2.ToolgunModeRestrictions

		for row in *data
			identifier = row.toolname

			if status = tonumber(row.adminonly)
				if status ~= 0
					local admins

					if status == 1
						admins = {'admin', 'superadmin'}
					elseif status == 2
						admins = {'superadmin'}

					if dryrun then
						if registry\Has(identifier)
							DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.restrict.' .. registry.identifier, identifier, table.concat([string.format('%q', group) for group in *groups], ', '))
						else
							DPP2.LMessagePlayer(@, 'message.dpp2.import.dryrun.no_restrict.' .. registry.identifier, identifier, table.concat([string.format('%q', group) for group in *groups], ', '))
					else
						if not registry\Has(identifier)
							registry\CreateEntry(identifier, admins, false)\Replicate()
							DPP2.Notify(true, nil, 'command.dpp2.rlists.added_ext.' .. registry.identifier, @, identifier, table.concat(groups, ', '), false)

		DPP2.LMessagePlayer(@, 'message.dpp2.import.done')
		DPP2.LMessagePlayer(@, 'message.dpp2.import.done_dryrun') if dryrun

DPP2.cmd['import_urs_limits'] = (args = {}) => URSLimits(@, not tobool(args[1]))
DPP2.cmd['import_urm_limits'] = (args = {}) => URMLimits(@, not tobool(args[1]))
DPP2.cmd['import_urs_restricts'] = (args = {}) => URSRestricts(@, not tobool(args[1]))
DPP2.cmd['import_urm_restricts'] = (args = {}) => URMRestricts(@, not tobool(args[1]))
DPP2.cmd['import_wuma_limits'] = (args = {}) => WUMALimits(@, not tobool(args[1]))
DPP2.cmd['import_wuma_restricts'] = (args = {}) => WUMARestricts(@, not tobool(args[1]))
DPP2.cmd['import_fpp'] = (args = {}) => ImportFPP(@, not tobool(args[1]))
DPP2.cmd['import_fpp_reload'] = (args = {}) =>
	DPPLink!\ReloadConfig()
	DPP2.LMessagePlayer(@, 'message.dpp2.import.reloaded_sql_config')
