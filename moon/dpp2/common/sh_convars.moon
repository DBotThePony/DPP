
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

DPP2.DRAW_OWNER = DPP2.CreateConVar('draw_owner', '1', DPP2.TYPE_BOOL)
DPP2.SIMPLE_OWNER = DPP2.CreateConVar('simple_owner', '0', DPP2.TYPE_BOOL)
DPP2.SHOW_ENTITY_NAME = DPP2.CreateConVar('entity_name', '1', DPP2.TYPE_BOOL)
DPP2.SHOW_ENTITY_INFO = DPP2.CreateConVar('entity_info', '1', DPP2.TYPE_BOOL)

DPP2.NO_ROPE_WORLD = DPP2.CreateConVar('no_rope_world', '1', DPP2.TYPE_BOOL)

-- Antipropkill
DPP2.ENABLE_ANTIPROPKILL = DPP2.CreateConVar('apropkill', '1', DPP2.TYPE_BOOL)
DPP2.ANTIPROPKILL_DAMAGE = DPP2.CreateConVar('apropkill_damage', '1', DPP2.TYPE_BOOL)
DPP2.ANTIPROPKILL_DAMAGE_NO_WORLD = DPP2.CreateConVar('apropkill_damage_nworld', '1', DPP2.TYPE_BOOL)
DPP2.ANTIPROPKILL_DAMAGE_NO_VEHICLES = DPP2.CreateConVar('apropkill_damage_nveh', '1', DPP2.TYPE_BOOL)
DPP2.ANTIPROPKILL_TRAP = DPP2.CreateConVar('apropkill_trap', '1', DPP2.TYPE_BOOL)
DPP2.ANTIPROPKILL_PUSH = DPP2.CreateConVar('apropkill_push', '1', DPP2.TYPE_BOOL)
DPP2.ANTIPROPKILL_THROW = DPP2.CreateConVar('apropkill_throw', '1', DPP2.TYPE_BOOL)
DPP2.ANTIPROPKILL_PUNT = DPP2.CreateConVar('apropkill_punt', '1', DPP2.TYPE_BOOL)

GravGunPunt = (ply = NULL, wep = NULL) ->
	return if not DPP2.ENABLE_ANTIPROPKILL\GetBool()
	return false if DPP2.ANTIPROPKILL_PUNT\GetBool()

hook.Add 'GravGunPunt', 'DPP2.AntiPropkill', GravGunPunt, 6


CAMI.RegisterPrivilege({
	Name: 'dpp2_ignore_antispam'
	MinAccess: 'admin'
	Description: 'DPP/2 threat this player as target of antispam ignore logic'
})

-- Antispam
DPP2.ENABLE_ANTISPAM = DPP2.CreateConVar('antispam', '1', DPP2.TYPE_BOOL)
DPP2.ANTISPAM_IGNORE_ADMINS = DPP2.CreateConVar('antispam_ignore_admins', '0', DPP2.TYPE_BOOL)
DPP2.ANTISPAM_COLLISIONS = DPP2.CreateConVar('antispam_collisions', '0', DPP2.TYPE_BOOL)
-- DPP2.ANTISPAM_MAX_EXPLOSIONS = DPP2.CreateConVar('antispam_explosions', '1', DPP2.TYPE_BOOL)

DPP2.ANTISPAM_UNFREEZE = DPP2.CreateConVar('antispam_unfreeze', '1', DPP2.TYPE_BOOL)
DPP2.ANTISPAM_DIVIDER = DPP2.CreateConVar('antispam_unfreeze_div', '1', DPP2.TYPE_UFLOAT)

DPP2.ANTISPAM_SPAM = DPP2.CreateConVar('antispam_spam', '1', DPP2.TYPE_BOOL)
DPP2.ANTISPAM_THRESHOLD = DPP2.CreateConVar('antispam_spam_threshold', '4', DPP2.TYPE_UFLOAT)
DPP2.ANTISPAM_THRESHOLD2 = DPP2.CreateConVar('antispam_spam_threshold2', '8', DPP2.TYPE_UFLOAT)
DPP2.ANTISPAM_COOLDOWN = DPP2.CreateConVar('antispam_spam_cooldown', '1', DPP2.TYPE_UFLOAT)

DPP2.ANTISPAM_VOLUME_AABB_DIV = DPP2.CreateConVar('antispam_vol_aabb_div', '100', DPP2.TYPE_UFLOAT)

DPP2.ANTISPAM_VOLUME_SPAM = DPP2.CreateConVar('antispam_spam_vol', '1', DPP2.TYPE_BOOL)
DPP2.ANTISPAM_VOLUME_AABB = DPP2.CreateConVar('antispam_spam_aabb', '0', DPP2.TYPE_BOOL)
DPP2.ANTISPAM_VOLUME_THRESHOLD = DPP2.CreateConVar('antispam_spam_vol_threshold', '600000', DPP2.TYPE_UINT)
DPP2.ANTISPAM_VOLUME_THRESHOLD2 = DPP2.CreateConVar('antispam_spam_vol_threshold2', '1200000', DPP2.TYPE_UINT)
DPP2.ANTISPAM_VOLUME_COOLDOWN = DPP2.CreateConVar('antispam_spam_vol_cooldown', '60000', DPP2.TYPE_UINT)

DPP2.AUTO_GHOST_BY_SIZE = DPP2.CreateConVar('antispam_ghost_by_size', '1', DPP2.TYPE_BOOL)
DPP2.AUTO_GHOST_SIZE = DPP2.CreateConVar('antispam_ghost_size', '300000', DPP2.TYPE_UINT)

DPP2.AUTO_GHOST_BY_AABB = DPP2.CreateConVar('antispam_ghost_aabb', '0', DPP2.TYPE_BOOL)
DPP2.AUTO_GHOST_AABB_SIZE = DPP2.CreateConVar('antispam_ghost_aabb_size', '400000', DPP2.TYPE_UINT)

DPP2.AUTO_BLACKLIST_BY_SIZE = DPP2.CreateConVar('antispam_block_by_size', '0', DPP2.TYPE_BOOL)
DPP2.AUTO_BLACKLIST_SIZE = DPP2.CreateConVar('antispam_block_size', '300000', DPP2.TYPE_UINT)

DPP2.AUTO_BLACKLIST_BY_AABB = DPP2.CreateConVar('antispam_block_aabb', '0', DPP2.TYPE_BOOL)
DPP2.AUTO_BLACKLIST_AABB_SIZE = DPP2.CreateConVar('antispam_block_aabb_size', '400000', DPP2.TYPE_UINT)

-- Logging
DPP2.ENABLE_LOGGING = DPP2.CreateConVar('log', '1', DPP2.TYPE_BOOL)
DPP2.ECHO_LOG = DPP2.CreateConVar('log_echo', '1', DPP2.TYPE_BOOL)
DPP2.ECHO_LOG_CLIENTS = DPP2.CreateConVar('log_echo_clients', '1', DPP2.TYPE_BOOL)
DPP2.WRITE_LOG = DPP2.CreateConVar('log_write', '1', DPP2.TYPE_BOOL)
DPP2.ENABLE_LOGGING_SPAWNS = DPP2.CreateConVar('log_spawns', '1', DPP2.TYPE_BOOL)
DPP2.ENABLE_LOGGING_TOOLGUN = DPP2.CreateConVar('log_toolgun', '1', DPP2.TYPE_BOOL)
DPP2.ENABLE_LOGGING_TRANSFER = DPP2.CreateConVar('log_tranfer', '1', DPP2.TYPE_BOOL)
