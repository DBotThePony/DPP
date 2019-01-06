
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

import NULL, type, ents, player, DLib, DPP2, select, ipairs from _G

DPP2.ENABLE_CLEANUP = DPP2.CreateConVar('cleanup', '1', 'gui.dpp2.cvars.cleanup', DPP2.TYPE_BOOL)
DPP2.CLEANUP_TIMER = DPP2.CreateConVar('cleanup_timer', '480', 'gui.dpp2.cvars.cleanup_timer', DPP2.TYPE_FLOAT)
DPP2.ENABLE_UP_FOR_GRABS = DPP2.CreateConVar('upforgrabs', '1', 'gui.dpp2.cvars.upforgrabs', DPP2.TYPE_BOOL)
DPP2.UP_FOR_GRABS_TIMER = DPP2.CreateConVar('upforgrabs_timer', '360', 'gui.dpp2.cvars.upforgrabs_timer', DPP2.TYPE_FLOAT)

entMeta = FindMetaTable('Entity')
plyMeta = FindMetaTable('Player')

entMeta.DPP2IsOwned = => @GetNWString('dpp2_owner_steamid', '-1') ~= '-1'
entMeta.DPP2IsUpForGrabs = => @GetNWBool('dpp2_ufg', false)
entMeta.DPP2GetIsUpForGrabs = => @GetNWBool('dpp2_ufg', false)
entMeta.DPP2OwnerIsValid = => @GetNWEntity('dpp2_ownerent', NULL)\IsValid()
entMeta.DPP2GetOwnerSteamID = => select(2, @DPP2GetOwner())
entMeta.DPP2GetOwnerName = => select(3, @DPP2GetOwner())

plyMeta.DPP2GetAllEnts = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @]
plyMeta.DPP2GetAllNPC = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @ and type(ent) == 'NPC']
plyMeta.DPP2GetAllWeapons = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @ and type(ent) == 'Weapon']
plyMeta.DPP2GetAllProps = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @ and ent\GetClass() == 'prop_physics']
plyMeta.DPP2GetAllRagdolls = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @ and ent\GetClass() == 'prop_ragdoll']

plyMeta.DPP2HasEnts = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @
	return false
plyMeta.DPP2HasNPC = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @ and type(ent) == 'NPC'
	return false
plyMeta.DPP2HasWeapons = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @ and type(ent) == 'Weapon'
	return false
plyMeta.DPP2HasProps = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @ and ent\GetClass() == 'prop_physics'
	return false
plyMeta.DPP2HasRagdolls = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @ and ent\GetClass() == 'prop_ragdoll'
	return false

DPP2.GetAllEntsBySteamID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @]
DPP2.GetAllEntitiesBySteamID = DPP2.GetAllEntsBySteamID
DPP2.GetAllNPCBySteamID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @ and type(ent) == 'NPC']
DPP2.GetAllWeaponsBySteamID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @ and type(ent) == 'Weapon']
DPP2.GetAllPropsBySteamID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @ and ent\GetClass() == 'prop_physics']
DPP2.GetAllRagdollsBySteamID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @ and ent\GetClass() == 'prop_ragdoll']

DPP2.HasEntsBySteamID = =>
	return true ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @
	return false
DPP2.HasNPCBySteamID = =>
	return true ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @ and type(ent) == 'NPC'
	return false
DPP2.HasWeaponsBySteamID = =>
	return true ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @ and type(ent) == 'Weapon'
	return false
DPP2.HasPropsBySteamID = =>
	return true ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @ and ent\GetClass() == 'prop_physics'
	return false
DPP2.HasRagdollsBySteamID = =>
	return true ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @ and ent\GetClass() == 'prop_ragdoll'
	return false

DPP2.HasEntitiesBySteamID = DPP2.HasEntsBySteamID
plyMeta.DPP2HasEntities = plyMeta.DPP2HasEnts
plyMeta.DPP2GetAllEntities = plyMeta.DPP2GetAllEnts
