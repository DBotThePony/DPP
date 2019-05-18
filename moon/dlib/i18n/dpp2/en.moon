
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

gui.dpp2.access.status.contraption = 'Contraption'
gui.dpp2.access.status.map = 'Owned by map'
gui.dpp2.access.status.world = 'Owned by world'
gui.dpp2.access.status.friend = 'Not a friend of owner'
gui.dpp2.access.status.invalident = 'Invalid Entity'
gui.dpp2.access.status.disabled = 'Protection is disabled'
gui.dpp2.access.status.ownerdisabled = 'Protection for owner is disabled'
gui.dpp2.access.status.yoursettings = 'Your settings'
gui.dpp2.access.status.toolgun_player = 'Cannot toolgun a player'

message.dpp2.owning.owned = 'You now own this entity'
message.dpp2.notice.upforgrabs = ' props are now up for grabs!'
message.dpp2.notice.cleanup = ' props has been cleaned up.'
message.dpp2.warn.trap = 'Your entity seems to stuck in someone. Interact with it to unghost!'
message.dpp2.warn.collisions = 'Your entity seems to stuck in other prop. Interact with it to unghost!'

gui.dpp2.cvars.protection = 'Main power switch for all protection modules'
gui.dpp2.cvars.cleanup = 'Cleanup props of disconnected players'

gui.dpp2.cvars.cleanup_timer = 'Cleanup timer'
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
	gui.dpp2.cvars['cl_' .. modeID .. '_protection'] = string.format('Disable %s protection for me', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_other'] = string.format('%s: I don\'t want to touch other\'s props', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_world'] = string.format('%s: I don\'t want to touch world\'s props', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_map'] = string.format('%s: I don\'t want to touch maps\'s props', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_players'] = string.format('%s: I don\'t want to touch players', modeName)
	gui.dpp2.buddystatus[modeID] = 'Buddy in ' .. modeName

message.dpp2.antispam.hint_ghosted = '%d entities were ghosted because of spam'
message.dpp2.antispam.hint_removed = '%d entities were removed because of spam'
message.dpp2.antispam.hint_disallowed = 'Action is not allowed due to spam'

message.dpp2.antispam.hint_ghosted_single = 'Entity were ghosted because of spam'
message.dpp2.antispam.hint_removed_single = 'Entity were removed because of spam'

message.dpp2.antispam.hint_ghosted_big = '%d entities were ghosted because they are too big. Interact with them to unghost!'
message.dpp2.antispam.hint_ghosted_big_single = 'Entity were ghosted because it is too big. Interact with it to unghost!'

message.dpp2.concommand.generic.notarget = 'Invalid target!'
message.dpp2.concommand.generic.noaccess = 'You can not execute this command (reason: %s)'
message.dpp2.concommand.generic.noaccess_check = 'You can not execute this command on target player (reason: %s)'

message.dpp2.concommand.cleanup = '#E cleaned all #E\'s entities'
message.dpp2.concommand.cleanupnpcs = '#E cleaned all #E\'s NPCs'
message.dpp2.concommand.cleanupallnpcs = '#E cleaned all owned NPCs'
message.dpp2.concommand.cleanupvehicles = '#E cleaned all #E\'s Vehicles'
message.dpp2.concommand.cleanupallvehicles = '#E cleaned all owned vehicles'
message.dpp2.concommand.freezephys = '#E froze all #E\'s entities'
message.dpp2.concommand.freezephysall = '#E froze all owned entities'
message.dpp2.concommand.freezephyspanic = '#E froze everything'
message.dpp2.concommand.cleanupdisconnected = '#E cleaned disconnected player\'s entities'

message.dpp2.concommand.hint.none = '<none>'
message.dpp2.concommand.hint.player = '<player>'
