
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

import DPP2 from _G

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
