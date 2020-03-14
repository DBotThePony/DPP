
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

gui.dpp2.access.status.contraption = 'Contraption'
gui.dpp2.access.status.contraption_ext = 'Contraption <%d>'
gui.dpp2.access.status.map = 'Owned by map'
gui.dpp2.access.status.world = 'Owned by world'
gui.dpp2.access.status.friend = 'Not a friend of owner'
gui.dpp2.access.status.invalident = 'Invalid Entity'
gui.dpp2.access.status.disabled = 'Protection is disabled'
gui.dpp2.access.status.ownerdisabled = 'Protection for owner is disabled'
gui.dpp2.access.status.yoursettings = 'Your settings'
gui.dpp2.access.status.toolgun_player = 'Cannot toolgun a player'
gui.dpp2.access.status.model_blacklist = 'Model is blacklisted'
gui.dpp2.access.status.toolgun_mode_blocked = 'Toolgun mode restricted'

message.dpp2.owning.owned = 'You now own this entity'
message.dpp2.owning.owned_contraption = 'You now own this contraption'
message.dpp2.notice.upforgrabs = ' props are now up for grabs!'
message.dpp2.notice.cleanup = ' props has been cleaned up.'
message.dpp2.warn.trap = 'Your entity seems to stuck in someone. Interact with it to unghost!'
message.dpp2.warn.collisions = 'Your entity seems to stuck in other prop. Interact with it to unghost!'
message.dpp2.restriction.spawn = '%q classname is restricted from you'

gui.dpp2.chosepnl.buttons.to_chosen = 'Pick >'
gui.dpp2.chosepnl.buttons.to_available = '< Move back'
gui.dpp2.chosepnl.column.available = 'Available'
gui.dpp2.chosepnl.column.chosen = 'Selected'
gui.dpp2.chosepnl.add.add = 'Add'
gui.dpp2.chosepnl.add.entry = 'Add custom choice'
gui.dpp2.restriction.is_whitelist = 'Group list act as whitelist'
gui.dpp2.restriction.edit_title = 'Editing %q restriction'

gui.dpp2.cvars.protection = 'Main power switch for all protection modules'

gui.dpp2.cvars.autocleanup = 'Cleanup disconnected players props on timer'
gui.dpp2.cvars.autocleanup_timer = 'Cleanup timer'

gui.dpp2.cvars.upforgrabs = 'Enable Up For Grabs timer'
gui.dpp2.cvars.upforgrabs_timer = 'Up for grabs timeout'

gui.dpp2.cvars.no_tool_player = 'Disallow to toolgun players'
gui.dpp2.cvars.no_tool_player_admin = 'Disallow to toolgun players as admin'

for {modeID, modeName} in *{{'physgun', 'Physgun'}, {'toolgun', 'Toolgun'}, {'drive', 'Prop Drive'}, {'damage', 'Damage'}, {'pickup', 'Pickups'}, {'use', '+use'}, {'vehicle', 'Vehicles'}, {'gravgun', 'Gravity Gun'}}
	gui.dpp2.cvars[modeID .. '_protection'] = string.format('Enable %s protection module', modeName)
	gui.dpp2.cvars[modeID .. '_touch_any'] = string.format('%s: Admins can touch anything', modeName)
	gui.dpp2.cvars[modeID .. '_no_world'] = string.format('%s: Players can not touch world owned props', modeName)
	gui.dpp2.cvars[modeID .. '_no_world_admin'] = string.format('%s: Admins can not touch world owned props', modeName)
	gui.dpp2.cvars[modeID .. '_no_map'] = string.format('%s: Players can not touch map owned props', modeName)
	gui.dpp2.cvars[modeID .. '_no_map_admin'] = string.format('%s: Admins can not touch map owned props', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_protection'] = string.format('Enable %s protection for me', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_other'] = string.format('%s: I don\'t want to touch other\'s props', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_world'] = string.format('%s: I don\'t want to touch world\'s props', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_map'] = string.format('%s: I don\'t want to touch maps\'s props', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_players'] = string.format('%s: I don\'t want to touch players', modeName)
	gui.dpp2.buddystatus[modeID] = 'Buddy in ' .. modeName

	gui.dpp2.disable_protection[modeID] = 'Disable ' .. modeName .. ' protection'

	command.dpp2.rlists.added[modeID] = '#E added %q to ' .. modeName .. ' restriction list with whitelist status set to %s'
	command.dpp2.rlists.added_ext[modeID] = '#E added %q to ' .. modeName .. ' restriction list with %q groups in it and whitelist status set to %s'
	command.dpp2.rlists.updated[modeID] = '#E updated %q in ' .. modeName .. ' restriction list with %q groups in it and whitelist status set to %s'
	command.dpp2.rlists.removed[modeID] = '#E removed %q from ' .. modeName .. ' restriction list'

	command.dpp2.enabled_for[modeID] = '#E enabled ' .. modeName .. ' protection for #E'
	command.dpp2.disabled_for[modeID] = '#E disabled ' .. modeName .. ' protection for #E'
	command.dpp2.already_disabled_for[modeID] = '#E already has ' .. modeName .. ' protection disabled for them!'
	command.dpp2.already_enabled_for[modeID] = '#E already has ' .. modeName .. ' protection enabled for them!'
	gui.dpp2.access.status['ownerdisabled_' .. modeID] = modeName .. ' protection for owner is disabled'

gui.dpp2.cvars.cl_protection = 'Main power switch'
gui.dpp2.cvars.apropkill = 'Antipropkill'
gui.dpp2.cvars.apropkill_damage = 'Block prop push damage'
gui.dpp2.cvars.apropkill_damage_nworld = 'Don\'t block push damage from world props'
gui.dpp2.cvars.apropkill_damage_nveh = 'Don\'t block push damage from world vehicles'
gui.dpp2.cvars.apropkill_trap = 'Prevent prop trapping'
gui.dpp2.cvars.apropkill_push = 'Prevent prop pushing'
gui.dpp2.cvars.apropkill_throw = 'Prevent prop throwing'
gui.dpp2.cvars.apropkill_punt = 'Prevent gravgun punt'

gui.dpp2.cvars.antispam = 'Antispam main switch'
gui.dpp2.cvars.antispam_collisions = 'Prevent spawning prop inside prop'
gui.dpp2.cvars.antispam_spam = 'Prevent spamming'
gui.dpp2.cvars.antispam_spam_threshold = 'Spam ghost limit'
gui.dpp2.cvars.antispam_spam_threshold2 = 'Spam remove limit'
gui.dpp2.cvars.antispam_spam_cooldown = 'Spam cooldown multiplier'
gui.dpp2.cvars.antispam_vol_aabb_div = 'AABB size divide number'
gui.dpp2.cvars.antispam_spam_vol = 'Antispam based on volume'
gui.dpp2.cvars.antispam_spam_aabb = 'Antispam based on AABB size'
gui.dpp2.cvars.antispam_spam_vol_threshold = 'Spam volume ghost limit'
gui.dpp2.cvars.antispam_spam_vol_threshold2 = 'Spam volume remove limit'
gui.dpp2.cvars.antispam_spam_vol_cooldown = 'Spam volume cooldown multiplier'

gui.dpp2.cvars.antispam_ghost_by_size = 'Ghost props based on volume'
gui.dpp2.cvars.antispam_ghost_size = 'Volume limit'

gui.dpp2.cvars.antispam_ghost_aabb = 'Ghost props based on volume'
gui.dpp2.cvars.antispam_ghost_aabb_size = 'AABB size limit'

message.dpp2.antispam.hint_ghosted = '%d entities were ghosted because of spam'
message.dpp2.antispam.hint_removed = '%d entities were removed because of spam'
message.dpp2.antispam.hint_disallowed = 'Action is not allowed due to spam'

message.dpp2.antispam.hint_ghosted_single = 'Entity were ghosted because of spam'
message.dpp2.antispam.hint_removed_single = 'Entity were removed because of spam'

message.dpp2.antispam.hint_ghosted_big = '%d entities were ghosted because they are too big. Interact with them to unghost!'
message.dpp2.antispam.hint_ghosted_big_single = 'Entity were ghosted because it is too big. Interact with it to unghost!'

command.dpp2.generic.invalid_side = 'This command can not be executed on this realm.'
command.dpp2.generic.notarget = 'Invalid target!'
command.dpp2.generic.no_bots = 'This command can not target bots'
command.dpp2.generic.noaccess = 'You can not execute this command (reason: %s)'
command.dpp2.generic.noaccess_check = 'You can not execute this command on target player (reason: %s)'

command.dpp2.cleanup = '#E cleaned all #E\'s entities'
command.dpp2.cleanupnpcs = '#E cleaned all #E\'s NPCs'
command.dpp2.cleanupallnpcs = '#E cleaned all owned NPCs'
command.dpp2.cleanupvehicles = '#E cleaned all #E\'s Vehicles'
command.dpp2.cleanupallvehicles = '#E cleaned all owned vehicles'
command.dpp2.freezephys = '#E froze all #E\'s entities'
command.dpp2.freezephysall = '#E froze all owned entities'
command.dpp2.freezephyspanic = '#E froze everything'
command.dpp2.cleanupdisconnected = '#E cleaned disconnected player\'s entities'

command.dpp2.hint.none = '<none>'
command.dpp2.hint.player = '<player>'

command.dpp2.transfer.none = 'There is none entities to transfer.'
command.dpp2.transfer.already_ply = 'You already set transfer fallback as #E!'
command.dpp2.transfer.none_ply = 'You already have none set as transfer fallback!'

command.dpp2.transfered = '#E transfered his entities to #E'
command.dpp2.transferfallback = 'Successfully set #E as transfer fallback'
command.dpp2.transferunfallback = 'Successfully removed transfer fallback'

message.dpp2.transfer.as_fallback = '%s<%s> transfered %d entities to #E as fallback'
message.dpp2.transfer.no_more_fallback = 'Your fallback player has left the server!'

command.dpp2.transferent.notarget = 'Invalid entity specified'
command.dpp2.transfercontraption.notarget = 'Invalid contraption specified'
command.dpp2.transferent.not_owner = 'You do not own this entity!'
command.dpp2.transfercontraption.not_owner = 'You own none of entities inside this contraption!'
command.dpp2.transferent.success = 'Successfully transfered #E to #E'
command.dpp2.transfertoworldent.success = 'Successfully transfered #E to World'
command.dpp2.transfercontraption.success = 'Successfully transfered #d entities to #E'
command.dpp2.transfertoworld.success = 'Successfully transfered #d entities to world'

gui.dpp2.property.transferent = 'Transfer this entity...'
gui.dpp2.property.transfertoworldent = 'Transfer this entity to world'
gui.dpp2.property.transfercontraption = 'Transfer this contraption...'
gui.dpp2.property.transfertoworldcontraption = 'Transfer this contraption to world'

message.dpp2.property.transferent.nolongervalid = 'Entity is no longer valid'
message.dpp2.property.transferent.noplayer = 'Target player has left the server'
message.dpp2.property.transfercontraption.nolongervalid = 'Contraption is no longer valid'

message.dpp2.blacklist.model_blocked = 'Model %s is in blacklist'
message.dpp2.blacklist.models_blocked = '#d entities were removed since some of them had blacklisted model'

command.dpp2.lists.arg_empty = 'You provided empty argument'
command.dpp2.lists.already_in = 'Target list already has that element!'
command.dpp2.lists.already_not = 'Target list already has no that element!'

command.dpp2.blists.added.model = '#e added %s to blacklist'
command.dpp2.blists.removed.model = '#e removed %s from blacklist'

message.dpp2.log.spawn.generic = '#E spawned #E'
message.dpp2.log.spawn.tried_generic = '#E #C tried #C to spawn #E'
message.dpp2.log.spawn.tried_plain = '#E #C tried #C to spawn %q'
message.dpp2.log.spawn.giveswep = '#E gave himself swep #C%s'
message.dpp2.log.spawn.giveswep_valid = '#E gave himself swep #E'
message.dpp2.log.spawn.prop = '#E spawned #E [%s]'
message.dpp2.log.in_next = 'Logging continues in %s'

message.dpp2.log.transfer.world = '#E transfered ownership of #E to world'
message.dpp2.log.transfer.other = '#E transfered ownership of #E to #E'

command.dpp2.rlists.added.toolgun_mode = '#E added %q to toolgun modes restriction list with whitelist status set to %s'
command.dpp2.rlists.added_ext.toolgun_mode = '#E added %q to toolgun modes restriction list with %q groups in it and whitelist status set to %s'
command.dpp2.rlists.updated.toolgun_mode = '#E updated %q toolgun mode restriction with %q groups and whitelist status set to %s'
command.dpp2.rlists.removed.toolgun_mode = '#E removed %q from toolgun modes restriction list'

command.dpp2.rlists.added.class_spawn = '#E added %q to entity spawning restriction list with whitelist status set to %s'
command.dpp2.rlists.updated.class_spawn = '#E added %q to entity spawning restriction list with %q groups in it and whitelist status set to %s'
command.dpp2.rlists.added_ext.class_spawn = '#E added %q to entity spawning restriction list with %q groups in it and whitelist status set to %s'
command.dpp2.rlists.removed.class_spawn = '#E removed %q from entity spawning restriction list'

gui.dpp2.toolcategory.main = 'Main settings'
gui.dpp2.toolcategory.client = 'Client settings'
gui.dpp2.toolcategory.restriction = 'Restriction lists'
gui.dpp2.toolcategory.blacklist = 'Blacklists'
gui.dpp2.toolcategory.player = 'Player utils'

gui.dpp2.toolmenu.playermode = 'Player protection'

gui.dpp2.toolmenu.client_protection = 'Protection settings'
gui.dpp2.toolmenu.primary = 'Primary settings'
gui.dpp2.toolmenu.secondary = 'Secondary settings'
gui.dpp2.toolmenu.antipropkill = 'Antipropkill settings'
gui.dpp2.toolmenu.antispam = 'Antispam settings'
gui.dpp2.toolmenu.restrictions.toolgun_mode = 'Toolgun mode restrictions'
gui.dpp2.toolmenu.restrictions.physgun = 'Physgun restrictions'
gui.dpp2.toolmenu.restrictions.drive = 'Drive restrictions'
gui.dpp2.toolmenu.restrictions.pickup = 'Pickup restrictions'
gui.dpp2.toolmenu.restrictions.use = 'Use restrictions'
gui.dpp2.toolmenu.restrictions.vehicle = 'Vehicle restrictions'
gui.dpp2.toolmenu.restrictions.gravgun = 'Gravgun restrictions'
gui.dpp2.toolmenu.restrictions.toolgun = 'Toolgun restrictions'
gui.dpp2.toolmenu.restrictions.damage = 'Damage restrictions'
gui.dpp2.toolmenu.restrictions.class_spawn = 'Entity restrictions'

gui.dpp2.toolmenu.blacklist.model = 'Model blacklist'

gui.dpp2.restriction_lists.view.classname = 'Identifier'
gui.dpp2.restriction_lists.view.groups = 'Groups'
gui.dpp2.restriction_lists.view.iswhitelist = 'Is Whitelist'
gui.dpp2.restriction_lists.add_new = 'Add...'

gui.dpp2.menus.add = 'Add new...'
gui.dpp2.menus.query.title = 'Add new entry'
gui.dpp2.menus.query.subtitle = 'Please enter classname of new (or existing) restriction'

gui.dpp2.menus.edit = 'Edit...'
gui.dpp2.menus.remove = 'Remove'
gui.dpp2.menus.remove2 = 'Confirm'
gui.dpp2.menus.copy_classname = 'Copy classname'
gui.dpp2.menus.copy_groups = 'Copy groups'

gui.dpp2.property.copymodel = 'Copy model'
gui.dpp2.property.copyangles = 'Copy angles'
gui.dpp2.property.copyvector = 'Copy position'
gui.dpp2.property.copyclassname = 'Copy classname'
