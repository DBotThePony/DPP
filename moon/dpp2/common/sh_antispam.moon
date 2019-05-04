
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

import DPP2 from _G

DPP2.ENABLE_ANTISPAM = DPP2.CreateConVar('antispam', '1', DPP2.TYPE_BOOL)
DPP2.ANTISPAM_COLLISIONS = DPP2.CreateConVar('antispam_collisions', '0', DPP2.TYPE_BOOL)
-- DPP2.ANTISPAM_MAX_EXPLOSIONS = DPP2.CreateConVar('antispam_explosions', '1', DPP2.TYPE_BOOL)

DPP2.ANTISPAM_SPAM = DPP2.CreateConVar('antispam_spam', '1', DPP2.TYPE_BOOL)
DPP2.ANTISPAM_THRESHOLD = DPP2.CreateConVar('antispam_spam_threshold', '4', DPP2.TYPE_UFLOAT)
DPP2.ANTISPAM_THRESHOLD2 = DPP2.CreateConVar('antispam_spam_threshold2', '8', DPP2.TYPE_UFLOAT)
DPP2.ANTISPAM_COOLDOWN = DPP2.CreateConVar('antispam_spam_cooldown', '1', DPP2.TYPE_UFLOAT)

DPP2.ANTISPAM_VOLUME_AABB_DIV = DPP2.CreateConVar('antispam_vol_aabb_div', '100', DPP2.TYPE_UFLOAT)

DPP2.ANTISPAM_VOLUME_SPAM = DPP2.CreateConVar('antispam_spam_vol', '1', DPP2.TYPE_BOOL)
DPP2.ANTISPAM_VOLUME_AABB = DPP2.CreateConVar('antispam_spam_vol_aabb', '0', DPP2.TYPE_BOOL)
DPP2.ANTISPAM_VOLUME_THRESHOLD = DPP2.CreateConVar('antispam_spam_vol_threshold', '600000', DPP2.TYPE_UINT)
DPP2.ANTISPAM_VOLUME_THRESHOLD2 = DPP2.CreateConVar('antispam_spam_vol_threshold2', '1200000', DPP2.TYPE_UINT)
DPP2.ANTISPAM_VOLUME_COOLDOWN = DPP2.CreateConVar('antispam_spam_vol_cooldown', '60000', DPP2.TYPE_UINT)

DPP2.AUTO_GHOST_BY_SIZE = DPP2.CreateConVar('antispam_ghost_by_size', '1', DPP2.TYPE_BOOL)
DPP2.AUTO_GHOST_SIZE = DPP2.CreateConVar('antispam_ghost_size', '300000', DPP2.TYPE_UINT)

DPP2.AUTO_GHOST_BY_AABB = DPP2.CreateConVar('antispam_ghost_aabb', '0', DPP2.TYPE_BOOL)
DPP2.AUTO_GHOST_AABB_SIZE = DPP2.CreateConVar('antispam_ghost_aabb_size', '400000', DPP2.TYPE_UINT)
