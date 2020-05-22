
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

-- this bridge is meant for very old/legacy addons
-- which are unaware of CPPI

-- since first DPP was very close to FPP in technical aspect
-- it is not the case with DPP/2
-- so bridge is going to be a bit inaccurate at some places

return if FPP

FPP = {}
FPP.AntiSpam = {}
FPP.Protect = {}

FPP.plyCanTouchEnt = (ply, ent, type) ->
	if type == 'Physgun'
		return DPP2.ACCESS.CanPhysgun(ply, ent)
	elseif type == 'Gravgun' then
		return DPP2.ACCESS.CanGravgun(ply, ent)
	elseif type == 'Toolgun' then
		return DPP2.ACCESS.CanToolgun(ply, ent, '')
	elseif type == 'PlayerUse' then
		return DPP2.ACCESS.CanUse(ply, ent)
	elseif type == 'EntityDamage' then
		return DPP2.ACCESS.CanDamage(ply, ent)

	return DPP2.ACCESS.CanPhysgun(ply, ent)

concommand.Add 'FPP_AddBlockedModel', (ply, cmd, args) -> concommand.GetTable().dpp2_add_model_blacklist(ply, cmd, args)
concommand.Add 'FPP_RemoveBlockedModel', (ply, cmd, args) -> concommand.GetTable().dpp2_remove_model_blacklist(ply, cmd, args)

FPP.AntiSpam.GhostFreeze = (ent, phys) -> ent\DPP2Ghost()
FPP.AntiSpam.UnGhost = (ply, ent) -> ent\DPP2UnGhost(true)

FPP.AntiSpam.CreateEntity = (ply, ent, IsDuplicate = false) -> DPP2.PlayerSpawnedSomething(ply, ent, true)

FPP.AntiSpam.DuplicatorSpam = (ply) -> DPP2.AntispamCheck(ply)

FPP.Protect.PhysgunPickup = (...) -> DPP2._PhysgunPickup(...)
FPP.Protect.PhysgunReload = (...) -> DPP2._OnPhysgunReload(...)
FPP.Protect.GravGunPickup = (...) -> DPP2._GravGunPickupAllowed(...)
FPP.Protect.GravGunPunt = (...) -> DPP2._GravGunPunt(...)
FPP.Protect.PlayerUse = (...) -> DPP2._AllowPlayerPickup(...)
FPP.Protect.EntityDamage = (ply, dmg) -> DPP2._EntityTakeDamage(ply, dmg)
FPP.Protect.CanTool = (ply, trace, tool, ENT) -> DPP2._CanTool(ply, trace, tool)
FPP.Protect.CanProperty = (...) -> DPP2._CanProperty(...)
FPP.Protect.CanDrive = (...) -> DPP2._CanDrive(...)

concommand.Add 'fpp_cleanup', (ply, cmd, args) -> concommand.GetTable().dpp2_cleanup(ply, cmd, args)
