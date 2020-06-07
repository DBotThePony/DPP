
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
gui.dpp2.access.status.toolgun_mode_excluded = 'Toolgun mode excluded from protection'
gui.dpp2.access.status.lock_self = 'Your self lock'
gui.dpp2.access.status.lock_other = 'Owner others lock'
gui.dpp2.access.status.no_surf = 'Antisurf'

gui.dpp2.access.status.damage_allowed = 'Damage allowed'

message.dpp2.owning.owned = 'You now own this entity'
message.dpp2.owning.owned_contraption = 'You now own this contraption'
message.dpp2.notice.upforgrabs = ' props are now up for grabs!'
message.dpp2.notice.cleanup = ' props has been cleaned up.'
message.dpp2.warn.trap = 'Your entity seems to stuck in someone. Interact with it to unghost!'
message.dpp2.warn.collisions = 'Your entity seems to stuck in other prop. Interact with it to unghost!'
message.dpp2.restriction.spawn = '%q classname is restricted from your usergroup'
message.dpp2.restriction.e2fn = 'DPP/2: Expression 2 function %q is restricted from your usergroup'

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

gui.dpp2.cvars.no_def_cache = 'Disable CanTouch() cache. THIS IS PERFROMANCE HEAVY AND SHOULD BE UTILIZED FOR DEBUGGING PURPOSES.'

for {modeID, modeName} in *{{'physgun', 'Physgun'}, {'toolgun', 'Toolgun'}, {'drive', 'Prop Drive'}, {'damage', 'Damage'}, {'pickup', 'Pickups'}, {'use', '+use'}, {'vehicle', 'Vehicles'}, {'gravgun', 'Gravity Gun'}}
	gui.dpp2.cvars[modeID .. '_protection'] = string.format('Enable %s protection module', modeName)
	gui.dpp2.cvars[modeID .. '_touch_any'] = string.format('%s: Admins can touch anything', modeName)
	gui.dpp2.cvars[modeID .. '_no_world'] = string.format('%s: Players can not touch world owned props', modeName)
	gui.dpp2.cvars[modeID .. '_no_world_admin'] = string.format('%s: Admins can not touch world owned props', modeName)
	gui.dpp2.cvars[modeID .. '_no_map'] = string.format('%s: Players can not touch map owned props', modeName)
	gui.dpp2.cvars[modeID .. '_no_map_admin'] = string.format('%s: Admins can not touch map owned props', modeName)

	gui.dpp2.cvars['el_' .. modeID .. '_enable'] = string.format('%s exlusion list enabled', modeName)

	gui.dpp2.cvars['bl_' .. modeID .. '_enable'] = string.format('%s blacklist enabled', modeName)
	gui.dpp2.cvars['bl_' .. modeID .. '_whitelist'] = string.format('%s blacklist act as whitelist', modeName)
	gui.dpp2.cvars['bl_' .. modeID .. '_admin_bypass'] = string.format('%s blacklist can be bypassed by admins', modeName)

	gui.dpp2.cvars['rl_' .. modeID .. '_enable'] = string.format('%s restriction list enabled', modeName)
	gui.dpp2.cvars['rl_' .. modeID .. '_invert'] = string.format('%s restriction list is inverted', modeName)
	gui.dpp2.cvars['rl_' .. modeID .. '_invert_all'] = string.format('%s restriction list is fully inverted', modeName)

	gui.dpp2.cvars['cl_' .. modeID .. '_protection'] = string.format('Enable %s protection for me', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_other'] = string.format('%s: I don\'t want to touch other\'s props', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_world'] = string.format('%s: I don\'t want to touch world\'s props', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_map'] = string.format('%s: I don\'t want to touch maps\'s props', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_players'] = string.format('%s: I don\'t want to touch players', modeName)
	gui.dpp2.buddystatus[modeID] = 'Buddy in ' .. modeName

	gui.dpp2.toolmenu.restrictions[modeID] = modeName .. ' restrictions'
	gui.dpp2.toolmenu.blacklist[modeID] = modeName .. ' blacklist'
	gui.dpp2.toolmenu.exclusions[modeID] = modeName .. ' exclusions'
	gui.dpp2.toolmenu.names[modeID] = modeName

	gui.dpp2.property.lock_self[modeID] = 'Restrict ' .. modeName .. ' usage'
	gui.dpp2.property.unlock_self[modeID] = 'Allow ' .. modeName .. ' usage'
	gui.dpp2.property.lock_others[modeID] = gui.dpp2.property.lock_self[modeID]
	gui.dpp2.property.unlock_others[modeID] = gui.dpp2.property.unlock_self[modeID]

	command.dpp2.lock_self[modeID] = 'Restricted yourself from touch of #E in ' .. modeName .. ' protection module'
	command.dpp2.unlock_self[modeID] = 'Allowed yourself to touch #E in ' .. modeName .. ' protection module'
	command.dpp2.lock_others[modeID] = 'Restricted others from touch of #E in ' .. modeName .. ' protection module'
	command.dpp2.unlock_others[modeID] = 'Allowed others to touch #E in ' .. modeName .. ' protection module'

	command.dpp2.blacklist.added[modeID] = '#E added %s to ' .. modeName .. ' blacklist'
	command.dpp2.blacklist.removed[modeID] = '#E removed %s from ' .. modeName .. ' blacklist'

	command.dpp2.exclist.added[modeID] = '#E added %s to ' .. modeName .. ' exclusion list'
	command.dpp2.exclist.removed[modeID] = '#E removed %s from ' .. modeName .. ' exclusion list'

	gui.dpp2.menu['add_to_' .. modeID .. '_blacklist'] = 'Add to ' .. modeName .. ' blacklist'
	gui.dpp2.menu['remove_from_' .. modeID .. '_blacklist'] = 'Remove from ' .. modeName .. ' blacklist'

	gui.dpp2.menu['add_to_' .. modeID .. '_exclist'] = 'Add to ' .. modeName .. ' exclusion list'
	gui.dpp2.menu['remove_from_' .. modeID .. '_exclist'] = 'Remove from ' .. modeName .. ' exclusion list'

	gui.dpp2.menu['add_to_' .. modeID .. '_restrictions'] = 'Add to ' .. modeName .. ' restriction list...'
	gui.dpp2.menu['edit_in_' .. modeID .. '_restrictions'] = 'Edit in ' .. modeName .. ' restriction list'
	gui.dpp2.menu['remove_from_' .. modeID .. '_restrictions'] = 'Remove from ' .. modeName .. ' restriction list'

	gui.dpp2.menu['add_to_' .. modeID .. '_limits'] = 'Add to ' .. modeName .. ' limit list...'
	gui.dpp2.menu['edit_in_' .. modeID .. '_limits'] = 'Edit in ' .. modeName .. ' limit list'
	gui.dpp2.menu['remove_from_' .. modeID .. '_limits'] = 'Remove from ' .. modeName .. ' limit list'

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
	gui.dpp2.access.status[modeID .. '_exclusion'] = 'Entity classname is excluded from protection'

	gui.dpp2.sharing['share_' .. modeID] = 'Share as ' .. modeName

command.dpp2.rlists.added.model = '#E added %q to model restriction list with whitelist status set to %s'
command.dpp2.rlists.added_ext.model = '#E added %q to model restriction list with %q groups in it and whitelist status set to %s'
command.dpp2.rlists.updated.model = '#E updated %q in model restriction list with %q groups in it and whitelist status set to %s'
command.dpp2.rlists.removed.model = '#E removed %q from model restriction list'

command.dpp2.rlists.added.e2fn = '#E added %q to Expression 2 Function restriction list with whitelist status set to %s'
command.dpp2.rlists.added_ext.e2fn = '#E added %q to Expression 2 Function restriction list with %q groups in it and whitelist status set to %s'
command.dpp2.rlists.updated.e2fn = '#E updated %q in Expression 2 Function restriction list with %q groups in it and whitelist status set to %s'
command.dpp2.rlists.removed.e2fn = '#E removed %q from Expression 2 Function restriction list'

gui.dpp2.cvars.rl_e2fn_enable = 'Enable Expression 2 restrictions'
gui.dpp2.cvars.rl_e2fn_invert = 'Enable Expression 2 restriction list is inverted'
gui.dpp2.cvars.rl_e2fn_invert_all = 'Enable Expression 2 restriction list is fully inverted'

do
	modeID = 'model'
	modeName = 'Model'
	gui.dpp2.menu['add_to_' .. modeID .. '_limits'] = 'Add to ' .. modeName .. ' limit list...'
	gui.dpp2.menu['edit_in_' .. modeID .. '_limits'] = 'Edit in ' .. modeName .. ' limit list'
	gui.dpp2.menu['remove_from_' .. modeID .. '_limits'] = 'Remove from ' .. modeName .. ' limit list'

gui.dpp2.cvars.rl_enable = 'Enable restriction lists'
gui.dpp2.cvars.bl_enable = 'Enable blacklists'
gui.dpp2.cvars.excl_enable = 'Enable exclude lists'

gui.dpp2.model_blacklist.window_title = 'Model blacklist visual menu'
gui.dpp2.model_exclusions.window_title = 'Model exclusion list visual menu'
gui.dpp2.model_restrictions.window_title = 'Model restriction list visual menu'
gui.dpp2.model_limits.window_title = 'Model limit list visual menu'

gui.dpp2.access.status.model_exclusion = 'Model is excluded from protection'

for {modeID, modeName} in *{{'model', 'Model'}, {'toolgun_mode', 'Toolgun mode'}, {'class_spawn', 'Spawn'}}
	gui.dpp2.cvars['el_' .. modeID .. '_enable'] = string.format('%s explusion list enabled', modeName)

	gui.dpp2.cvars['bl_' .. modeID .. '_enable'] = string.format('%s blacklist enabled', modeName)
	gui.dpp2.cvars['bl_' .. modeID .. '_whitelist'] = string.format('%s blacklist act as whitelist', modeName)
	gui.dpp2.cvars['bl_' .. modeID .. '_admin_bypass'] = string.format('%s blacklist can be bypassed by admins', modeName)

	gui.dpp2.cvars['rl_' .. modeID .. '_enable'] = string.format('%s restriction list enabled', modeName)
	gui.dpp2.cvars['rl_' .. modeID .. '_invert'] = string.format('%s restriction list is inverted', modeName)
	gui.dpp2.cvars['rl_' .. modeID .. '_invert_all'] = string.format('%s restriction list is fully inverted', modeName)

	gui.dpp2.menu['add_to_' .. modeID .. '_blacklist'] = 'Add to ' .. modeName .. ' blacklist'
	gui.dpp2.menu['remove_from_' .. modeID .. '_blacklist'] = 'Remove from ' .. modeName .. ' blacklist'

	gui.dpp2.menu['add_to_' .. modeID .. '_exclist'] = 'Add to ' .. modeName .. ' exclusion list'
	gui.dpp2.menu['remove_from_' .. modeID .. '_exclist'] = 'Remove from ' .. modeName .. ' exclusion list'

	gui.dpp2.menu['add_to_' .. modeID .. '_restrictions'] = 'Add to ' .. modeName .. ' restriction list...'
	gui.dpp2.menu['edit_in_' .. modeID .. '_restrictions'] = 'Edit in ' .. modeName .. ' restriction list'
	gui.dpp2.menu['remove_from_' .. modeID .. '_restrictions'] = 'Remove from ' .. modeName .. ' restriction list'

gui.dpp2.cvars.no_rope_world = 'No rope world'

gui.dpp2.cvars.log = 'Main power switch'
gui.dpp2.cvars.log_echo = 'Echo logs in server console'
gui.dpp2.cvars.log_echo_clients = 'Echo logs in admin console'
gui.dpp2.cvars.log_spawns = 'Log entity spawns'
gui.dpp2.cvars.log_toolgun = 'Log toolgun usage'
gui.dpp2.cvars.log_tranfer = 'Log transfers'
gui.dpp2.cvars.log_write = 'Write log to disk'

gui.dpp2.cvars.physgun_undo = 'Allow physgun undo'
gui.dpp2.cvars.cl_physgun_undo = 'Enable physgun undo'
gui.dpp2.cvars.cl_physgun_undo_custom = 'Use separate undo history for physgun'

gui.dpp2.cvars.allow_damage_npc = 'Always allow to damage NPCs'
gui.dpp2.cvars.allow_damage_vehicle = 'Always allow to damage Vehicles'

gui.dpp2.cvars.cl_protection = 'Main power switch'

gui.dpp2.cvars.cl_draw_contraption_aabb = 'Draw contraption\'s AABB (can drastically reduce performance)'
gui.dpp2.cvars.cl_draw_owner = 'Draw ownership'
gui.dpp2.cvars.cl_simple_owner = 'Simple owner display (FPP Style)'
gui.dpp2.cvars.cl_entity_name = 'Show entity print name'
gui.dpp2.cvars.cl_entity_info = 'Show entity info'
gui.dpp2.cvars.cl_no_contraptions = 'Don\'t fully process contraptions. Can improve framerate with huge contraptions.'
gui.dpp2.cvars.cl_no_players = 'Don\'t show ownership status when looking at players.'
gui.dpp2.cvars.cl_no_func = 'Don\'t show ownership status when looking at func_* or doors'
gui.dpp2.cvars.cl_no_map = 'Don\'t show ownership status when looking at map created entities'
gui.dpp2.cvars.cl_no_world = 'Don\'t show ownership status when looking at world owned entities'
gui.dpp2.cvars.cl_ownership_in_vehicle = 'Display ownership while in vehicle'
gui.dpp2.cvars.cl_ownership_in_vehicle_always = 'Always display ownership while in vehicle'

gui.dpp2.cvars.cl_notify = 'Display notifications on screen'
gui.dpp2.cvars.cl_notify_generic = 'Display generic notifications on screen'
gui.dpp2.cvars.cl_notify_error = 'Display error notifications on screen'
gui.dpp2.cvars.cl_notify_hint = 'Display hint notifications on screen'
gui.dpp2.cvars.cl_notify_undo = 'Display undo notifications on screen'
gui.dpp2.cvars.cl_notify_cleanup = 'Display cleanup notifications on screen'
gui.dpp2.cvars.cl_notify_sound = 'Enable notification sounds'
gui.dpp2.cvars.cl_notify_timemul = 'Notification time multiplier'

gui.dpp2.cvars.cl_properties = 'Enable DPP/2 prop properties'
gui.dpp2.cvars.cl_properties_regular = 'Enable regular properties'
gui.dpp2.cvars.cl_properties_admin = 'Enable admin properties'
gui.dpp2.cvars.cl_properties_restrictions = 'Enable restriction properties'

gui.dpp2.cvars.draw_owner = 'Serverside override: Draw ownership'
gui.dpp2.cvars.simple_owner = 'Serverside override: Simple owner display (FPP Style)'
gui.dpp2.cvars.entity_name = 'Serverside override: Show entity print name'
gui.dpp2.cvars.entity_info = 'Serverside override: Show entity info'

gui.dpp2.cvars.apropkill = 'Antipropkill'
gui.dpp2.cvars.apropkill_damage = 'Block prop push damage'
gui.dpp2.cvars.apropkill_damage_nworld = 'Don\'t block push damage from world props'
gui.dpp2.cvars.apropkill_damage_nveh = 'Don\'t block push damage from world vehicles'
gui.dpp2.cvars.apropkill_trap = 'Prevent prop trapping'
gui.dpp2.cvars.apropkill_push = 'Prevent prop pushing'
gui.dpp2.cvars.apropkill_throw = 'Prevent prop throwing'
gui.dpp2.cvars.apropkill_punt = 'Prevent gravgun punt'
gui.dpp2.cvars.apropkill_surf = 'Prevent prop surf\n(depends on antiproppush and\nsitting mod like DSit)'

gui.dpp2.cvars.antispam = 'Antispam main switch'
gui.dpp2.cvars.antispam_ignore_admins = 'Antispam ignores administration'
gui.dpp2.help.antispam_ignore_admins = 'Keep in mind that turning\nantispam_ignore_admins on might make you forget\nto tune antispam settngs properly\nfor regular players\n(and make them feel insulted by antispam)'
gui.dpp2.cvars.antispam_unfreeze = 'Unfreeze antispam'
gui.dpp2.cvars.antispam_unfreeze_div = 'Unfreeze antispam time multiplier'
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

gui.dpp2.cvars.antispam_ghost_aabb = 'Ghost props based on AABB'
gui.dpp2.cvars.antispam_ghost_aabb_size = 'AABB size limit'

gui.dpp2.cvars.antispam_block_by_size = 'Auto blacklist models based on volume'
gui.dpp2.cvars.antispam_block_size = 'Volume limit'

gui.dpp2.cvars.antispam_block_aabb = 'Auto blacklist models based on AABB'
gui.dpp2.cvars.antispam_block_aabb_size = 'AABB size limit'

message.dpp2.antispam.hint_ghosted = '%d entities were ghosted because of spam'
message.dpp2.antispam.hint_removed = '%d entities were removed because of spam'
message.dpp2.antispam.hint_unfreeze_antispam = 'Unfreeze antispam. Try again after #.2f seconds'
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
command.dpp2.cleardecals = '#E cleaned up decals'
command.dpp2.cleanupgibs = '#E cleaned up gibs. #d gibs were removed'
command.dpp2.cleanupnpcs = '#E cleaned all #E\'s NPCs'
command.dpp2.cleanupallnpcs = '#E cleaned all owned NPCs'
command.dpp2.cleanupall = '#E cleaned all owned entities'
command.dpp2.cleanupvehicles = '#E cleaned all #E\'s Vehicles'
command.dpp2.cleanupallvehicles = '#E cleaned all owned vehicles'
command.dpp2.freezephys = '#E froze all #E\'s entities'
command.dpp2.freezephysall = '#E froze all owned entities'
command.dpp2.freezephyspanic = '#E froze everything'
command.dpp2.cleanupdisconnected = '#E cleaned disconnected player\'s entities'

command.dpp2.hint.none = '<none>'
command.dpp2.hint.player = '<player>'
command.dpp2.hint.share.not_own_contraption = '<you own none of entities inside this contraption>'
command.dpp2.hint.share.nothing_shared = '<nothing shared>'
command.dpp2.hint.share.nothing_to_share = '<nothing to share>'
command.dpp2.hint.share.not_owned = '<not an owner>'

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

gui.dpp2.property.restrictions = 'DPP/2 Restrictions'
gui.dpp2.property.lock_self.top = 'Restrict myself...'
gui.dpp2.property.unlock_self.top = 'Allow myself...'
gui.dpp2.property.lock_others.top = 'Restrict others...'
gui.dpp2.property.unlock_others.top = 'Allow others...'

message.dpp2.property.transferent.nolongervalid = 'Entity is no longer valid'
message.dpp2.property.transferent.noplayer = 'Target player has left the server'
message.dpp2.property.transfercontraption.nolongervalid = 'Contraption is no longer valid'

message.dpp2.blacklist.model_blocked = 'Model %s is in blacklist'
message.dpp2.blacklist.model_restricted = 'Model %s is restricted from your usergroup'
message.dpp2.blacklist.models_blocked = '#d entities were removed since some of them had blacklisted/restricted model'

command.dpp2.lists.arg_empty = 'You provided empty argument'
command.dpp2.lists.group_empty = 'Missing group name!'
command.dpp2.lists.limit_empty = 'Invalid limit provided'
command.dpp2.lists.already_in = 'Target list already has that element!'
command.dpp2.lists.already_not = 'Target list already has no that element!'

command.dpp2.blacklist.added.model = '#E added %s to model blacklist'
command.dpp2.blacklist.removed.model = '#E removed %s from model blacklist'

command.dpp2.exclist.added.model = '#E added %s to model exclusion list'
command.dpp2.exclist.removed.model = '#E removed %s from model exclusion list'
command.dpp2.exclist.added.toolgun_mode = '#E added %s to toolgun mode exclusion list'
command.dpp2.exclist.removed.toolgun_mode = '#E removed %s from toolgun mode exclusion list'

message.dpp2.log.spawn.generic = '#E spawned #E'
message.dpp2.log.spawn.tried_generic = '#E #C tried #C to spawn #E'
message.dpp2.log.spawn.tried_plain = '#E #C tried #C to spawn %q'
message.dpp2.log.spawn.giveswep = '#E gave themselves swep #C%s'
message.dpp2.log.spawn.giveswep_valid = '#E gave themselves swep #E'
message.dpp2.log.spawn.prop = '#E spawned #E [%s]'
message.dpp2.log.in_next = 'Logging continues in %s'

message.dpp2.log.transfer.world = '#E transfered ownership of #E to world'
message.dpp2.log.transfer.other = '#E transfered ownership of #E to #E'

message.dpp2.log.toolgun.regular = '#E shot toolgun %s on #E'
message.dpp2.log.toolgun.property = '#E used property %s on #E'
message.dpp2.log.toolgun.world = '#E shot toolgun %s on world'

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
gui.dpp2.toolcategory.limits = 'Limits'
gui.dpp2.toolcategory.exclusions = 'Exclusions'

gui.dpp2.toolmenu.select_tool = 'Select this tool'
gui.dpp2.toolmenu.select_tool2 = 'Deploy this tool'

gui.dpp2.toolmenu.playermode = 'Player protection'

gui.dpp2.toolmenu.client_protection = 'Protection settings'
gui.dpp2.toolmenu.client_settings = 'General settings'
gui.dpp2.toolmenu.client_commands = 'Utilities'
gui.dpp2.toolmenu.primary = 'Primary settings'
gui.dpp2.toolmenu.secondary = 'Secondary settings'
gui.dpp2.toolmenu.antipropkill = 'Antipropkill settings'
gui.dpp2.toolmenu.antispam = 'Antispam settings'
gui.dpp2.toolmenu.cleanup = 'Cleanup'
gui.dpp2.toolmenu.utils = 'Utils'
gui.dpp2.toolmenu.logging = 'Logging settings'
gui.dpp2.toolmenu.restrictions.toolgun_mode = 'Toolgun mode restrictions'
gui.dpp2.toolmenu.restrictions.class_spawn = 'Entity restrictions'
gui.dpp2.toolmenu.restrictions.model = 'Model restrictions'
gui.dpp2.toolmenu.restrictions.e2fn = 'Expression 2 Restrictions'
gui.dpp2.toolmenu.exclusions.model = 'Model exclusions'
gui.dpp2.toolmenu.exclusions.toolgun_mode = 'Toolgun mode exclusions'

gui.dpp2.toolmenu.limits.sbox = 'Sandbox Limits'
gui.dpp2.toolmenu.limits.entity = 'Per Entity Limits'
gui.dpp2.toolmenu.limits.model = 'Per Model Limits'

gui.dpp2.toolmenu.playerutil.clear = '%s: Cleanup props'
gui.dpp2.toolmenu.playerutil.freezephys = 'F'
gui.dpp2.toolmenu.playerutil.freezephys_tip = 'Freeze this player\'s props'
gui.dpp2.toolmenu.playerutil.freezephysall = 'Freeze owned physics objects'
gui.dpp2.toolmenu.playerutil.freezephyspanic = 'Freeze ALL physics objects'
gui.dpp2.toolmenu.playerutil.clear_all = 'Cleanup all owned props'
gui.dpp2.toolmenu.playerutil.clear_npcs = 'Cleanup all owned NPCs'
gui.dpp2.toolmenu.playerutil.clear_vehicles = 'Cleanup all owned vehicles'
gui.dpp2.toolmenu.playerutil.clear_disconnected = 'Cleanup disconnected player\'s props'

gui.dpp2.toolmenu.blacklist.model = 'Model blacklist'
gui.dpp2.toolmenu.util.cleardecals = 'Clear decals'
gui.dpp2.toolmenu.util.cleanupgibs = 'Clean up gibs'

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
gui.dpp2.menus.copy_group = 'Copy group'
gui.dpp2.menus.copy_limit = 'Copy limit'

gui.dpp2.property.copymodel = 'Copy model'
gui.dpp2.property.copyangles = 'Copy angles'
gui.dpp2.property.copyvector = 'Copy position'
gui.dpp2.property.copyclassname = 'Copy classname'

command.dpp2.setvar.none = 'ConVar wasn\'t specified'
command.dpp2.setvar.invalid = 'ConVar is not DPP/2\'s ConVar or does not exist: %s'
command.dpp2.setvar.no_arg = 'No new value was specified'
command.dpp2.setvar.changed = '#E changed value of dpp2_%s ConVar'

gui.dpp2.sharing.window_title = 'Sharing'
gui.dpp2.property.share = 'Share...'
gui.dpp2.property.share_all = 'Share all'
gui.dpp2.property.un_share_all = 'Unshare all'
gui.dpp2.property.share_contraption = 'Share contraption...'
command.dpp2.sharing.no_target = 'No sharing target was specified'
command.dpp2.sharing.no_mode = 'No sharing mode was specified'
command.dpp2.sharing.invalid_mode = 'Invalid sharing mode was specified'
command.dpp2.sharing.invalid_entity = 'Invalid entity was specified'
command.dpp2.sharing.invalid_contraption = 'Invalid contraption was specified'
command.dpp2.sharing.not_owner = 'Cannot share not own entity'
command.dpp2.sharing.already_shared = 'Entity is already shared in this mode'
command.dpp2.sharing.shared = '#E is now shared in %s protection module'
command.dpp2.sharing.shared_contraption = 'Everything inside contraption with ID %d is now shared in %s protection module'
command.dpp2.sharing.already_not_shared = 'Entity is already not shared in this mode'
command.dpp2.sharing.un_shared = '#E is no longer shared in %s protection module'
command.dpp2.sharing.un_shared_contraption = 'Everything inside contraption with ID %d is no longer shared in %s protection module'
command.dpp2.sharing.cooldown = 'Command cooldown. Try again after #.2f seconds'

gui.dpp2.cvars.no_host_limits = 'No limits for host player in singleplayer/on listen server'
gui.dpp2.cvars.sbox_limits_enabled = 'Enable sandbox limits overrides'
gui.dpp2.cvars.sbox_limits_inclusive = 'Sandbox limit list is inclusive'
gui.dpp2.cvars.entity_limits_enabled = 'Enable per entity limits'
gui.dpp2.cvars.entity_limits_inclusive = 'Per entity limit list is inclusive'
gui.dpp2.cvars.model_limits_enabled = 'Enable per model limits'
gui.dpp2.cvars.model_limits_inclusive = 'Per model limit list is inclusive'
gui.dpp2.cvars.limits_lists_enabled = 'Enable limits lists'

command.dpp2.limit_lists.added.sbox = '#E added %q sandbox limit for group %s as #d'
command.dpp2.limit_lists.removed.sbox = '#E removed %q sandbox limit for group %s'
command.dpp2.limit_lists.modified.sbox = '#E modified %q sandbox limit for group %s to #d'

command.dpp2.limit_lists.added.entity = '#E added %q entity limit for group %s as #d'
command.dpp2.limit_lists.removed.entity = '#E removed %q entity limit for group %s'
command.dpp2.limit_lists.modified.entity = '#E modified %q entity limit for group %s to #d'

command.dpp2.limit_lists.added.model = '#E added %q model limit for group %s as #d'
command.dpp2.limit_lists.removed.model = '#E removed %q model limit for group %s'
command.dpp2.limit_lists.modified.model = '#E modified %q model limit for group %s to #d'

gui.dpp2.limit_lists.view.classname = 'Identifier'
gui.dpp2.limit_lists.view.group = 'Usergroup'
gui.dpp2.limit_lists.view.limit = 'Limit'
gui.dpp2.limit.edit_title = 'Editing limits for %s'

message.dpp2.limit.spawn = 'You hit %s limit!'

for name in *{'vehicles', 'props', 'npcs', 'sents', 'effects', 'ragdolls'}
	message.dpp2.import.dryrun.limit[name] = 'Gonna import ' .. name .. ' sandbox limit as %s with limit of #d'
	message.dpp2.import.dryrun.limit[name\sub(1, #name - 1)] = message.dpp2.import.dryrun.limit[name]
	message.dpp2.import.dryrun.no_limit[name] = 'Not gonna import ' .. name .. ' sandbox limit as %s with limit of #d because such limit already exists'
	message.dpp2.import.dryrun.no_limit[name\sub(1, #name - 1)] = message.dpp2.import.dryrun.no_limit[name]

for name in *{'tool', 'pickup', 'prop', 'sent', 'effect', 'ragdoll', 'vehicle', 'swep', 'npc'}
	message.dpp2.import.dryrun.restrict[name] = 'Gonna import ' .. name .. ' restriction as %s with %s groups in it'
	message.dpp2.import.dryrun.no_restrict[name] = 'Not gonna import ' .. name .. ' restriction as %s with %s groups in it because such restriction already exists'

message.dpp2.import.dryrun.restrict.toolgun = message.dpp2.import.dryrun.restrict.tool
message.dpp2.import.dryrun.restrict.class_spawn = 'Gonna import classname spawn restriction as %s with %s groups in it'
message.dpp2.import.dryrun.no_restrict.class_spawn = 'Not gonna import classname restriction as %s with %s groups in it because such restriction already exists'
message.dpp2.import.dryrun.no_restrict.toolgun = message.dpp2.import.dryrun.no_restrict.tool

message.dpp2.import.dryrun.entlimit = 'Gonna import %s entity limit as %s with limit of #d'
message.dpp2.import.dryrun.no_entlimit = 'Not gonna import %s entity limit as %s with limit of #d because such limit already exists'

message.dpp2.import.wuma_warning = 'Since WUMA does not have difference between sandbox limits and entity limits, it is basically very hard to determine to which list each restriction belong to. Use with care!'
message.dpp2.import.wuma_warning2 = 'This is actually faulty design on WUMA\'s side. Perfect import is possible if everything in WUMA list is currently loaded on the server.'
message.dpp2.import.wuma_warning_restr = 'Importing WUMA restricts is not 100% accurate since DPP/2 treat some stuff more simple, than WUMA does (for less complexity of restriction system). Use with care!'
message.dpp2.import.done = 'Dry run/Import done.'
message.dpp2.import.done_dryrun = 'To apply changes, execute the same command, but with "1" as it\'s argument.'

message.dpp2.import.no_file = 'File to import does not exist.'
message.dpp2.import.empty_file = 'File to import is empty.'
message.dpp2.import.bad_file = 'File to import is broken.'

message.dpp2.import.dryrun.block_model = 'Gonna import model %s into blacklist'
message.dpp2.import.dryrun.block_model = 'Not gonna import model %s into blacklist since said model is already blocked'

for name in *{'gravgun', 'physgun', 'toolgun', 'damage'}
	message.dpp2.import.dryrun.block_thing_from[name] = 'Gonna import ' .. name .. ' blacklisted classname as %s'
	message.dpp2.import.dryrun.no_block_thing_from[name] = 'Not gonna import ' .. name .. ' blacklisted classname as %s because such entry already exists'

message.dpp2.import.fpp_db = 'Attention: FPP is being imported from `dpp` config file located in `data/dmysql3/dpp`'
message.dpp2.import.dpp_db = 'Attention: DPP is being imported from `dpp` config file located in `data/dmysql3/dpp`'
message.dpp2.import.reloaded_sql_config = 'Database connection config should be reloaded.'

message.dpp2.inspect.invalid_entity = 'Trace did not hit any entity'
message.dpp2.inspect.check_console = 'Check console for inspect results'

message.dpp2.inspect.clientside = '-- CLIENTSIDE OUTPUT'
message.dpp2.inspect.serverside = '-- SERVERSIDE OUTPUT'
message.dpp2.inspect.footer = '--------------------------------------'

message.dpp2.inspect.result.class = 'Inspecting classname: %s'
message.dpp2.inspect.result.position = 'Entity position: Vector(#f, #f, #f)'
message.dpp2.inspect.result.angles = 'Entity angles: Angle(#f, #f, #f)'
message.dpp2.inspect.result.eye_angles = 'Entity "eye" angles: Angle(#f, #f, #f)'
message.dpp2.inspect.result.table_size = 'Table size: #d'
message.dpp2.inspect.result.health = 'Health: #d'
message.dpp2.inspect.result.max_health = 'Max health: #d'

message.dpp2.inspect.result.owner_entity = 'Owner: #E'
message.dpp2.inspect.result.owner_steamid = 'Owner SteamID: %s'
message.dpp2.inspect.result.owner_nickname = 'Owner Nickname: %s'
message.dpp2.inspect.result.owner_uniqueid = 'Owner UniqueID: %s'

message.dpp2.inspect.result.unowned = 'Entity is not owned'
message.dpp2.inspect.result.model = 'Model: %s'
message.dpp2.inspect.result.skin = 'Skin: %s'
message.dpp2.inspect.result.bodygroup_count = 'Amount of bodygroups: #d'

gui.dpp2.property.arm_creator = 'Arm creator with this'

gui.dpp2.undo.physgun = 'Undo physgun movement'
gui.dpp2.undo.physgun_help = 'To undo a physgun move, use dpp2_undo_physgun concommand'
gui.dpp2.undo.physgun_nothing = 'Nothing to undo'

message.dpp2.autoblacklist.added_volume = 'Model %q were auto added to model blacklist based on phys volume'
message.dpp2.autoblacklist.added_aabb = 'Model %q were auto added to model blacklist based on AABB'

message.dpp2.import.dpp_friends = 'Imported #d entries found in DPP friends.'
message.dpp2.import.fpp_friends = 'Imported #d entries found in FPP friends.'
message.dpp2.import.no_fpp_table = 'FPP friend table does not exist, nothing to import'
message.dpp2.import.button_dpp_friends = 'Import DPP friends'
message.dpp2.import.button_fpp_friends = 'Import FPP friends'
