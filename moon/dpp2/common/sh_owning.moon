
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

import NULL, type, ents, player, DLib, DPP2, select, ipairs from _G

DPP2.ENABLE_CLEANUP = DPP2.CreateConVar('autocleanup', '1', DPP2.TYPE_BOOL)
DPP2.ENABLE_AUTOFREEZE = DPP2.CreateConVar('autofreeze', '0', DPP2.TYPE_BOOL)
DPP2.ENABLE_AUTOGHOST = DPP2.CreateConVar('autoghost', '1', DPP2.TYPE_BOOL)
DPP2.CLEANUP_TIMER = DPP2.CreateConVar('autocleanup_timer', '480', DPP2.TYPE_FLOAT)
DPP2.ENABLE_UP_FOR_GRABS = DPP2.CreateConVar('upforgrabs', '1', DPP2.TYPE_BOOL)
DPP2.UP_FOR_GRABS_TIMER = DPP2.CreateConVar('upforgrabs_timer', '360', DPP2.TYPE_FLOAT)

entMeta = FindMetaTable('Entity')
plyMeta = FindMetaTable('Player')

entMeta.DPP2IsOwned = => @GetNWString('dpp2_owner_uid', '-1') ~= '-1'
entMeta.DPP2IsUpForGrabs = => @GetNWBool('dpp2_ufg', false)
entMeta.DPP2GetIsUpForGrabs = => @GetNWBool('dpp2_ufg', false)
entMeta.DPP2OwnerIsValid = => @GetNWEntity('dpp2_ownerent', NULL)\IsValid()
entMeta.DPP2IsOwnerValid = => @GetNWEntity('dpp2_ownerent', NULL)\IsValid()
entMeta.DPP2IsOwnerTrackedByUID = => @GetNWBool('dpp2_owner_uid_track', false)
entMeta.DPP2GetOwnerSteamID = (def = '') => @GetNWString('dpp2_owner_steamid', def)
entMeta.DPP2GetOwnerUID = (def = 'world') => @GetNWString('dpp2_owner_uid', def)
entMeta.DPP2GetOwnerName = => select(3, @DPP2GetOwner())
entMeta.DPP2GetOwnerPID = (def = -1) => @GetNWInt('dpp2_owner_pid', def)

plyMeta.DPP2GetAllEnts = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @]
plyMeta.DPP2FindOwned = plyMeta.DPP2GetAllEnts
plyMeta.DPP2GetAllNPC = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @ and type(ent) == 'NPC']
plyMeta.DPP2GetAllWeapons = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @ and type(ent) == 'Weapon']
plyMeta.DPP2GetAllProps = => @DPP2GetAllEntsByClass('prop_physics')
plyMeta.DPP2GetAllEntsByClass = (classname) => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwner() == @ and ent\GetClass() == classname]
plyMeta.DPP2GetAllRagdolls = => @DPP2GetAllEntsByClass('prop_ragdoll')

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

DPP2.GetAllKnownPlayersInfo = (plyID) ->
	if plyID
		for i, ent in ipairs(ents.GetAll())
			owner, steamid, name, uid, pid = ent\DPP2GetOwner()

			if pid == plyID
				return {
					ent: owner
					steamid: steamid
					:name
					:uid
					:pid
				}

		return false

	output = {}

	for i, ent in ipairs(ents.GetAll())
		owner, steamid, name, uid, pid = ent\DPP2GetOwner()

		if pid ~= -1 and not output[pid]
			output[pid] = {
				ent: owner
				steamid: steamid
				:name
				:uid
				:pid
			}

	return output

DPP2.GetAllEntsBySteamID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID(false) == @]
DPP2.GetAllEntitiesBySteamID = DPP2.GetAllEntsBySteamID
DPP2.GetAllNPCBySteamID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID(false) == @ and type(ent) == 'NPC']
DPP2.GetAllWeaponsBySteamID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID(false) == @ and type(ent) == 'Weapon']
DPP2.GetAllPropsBySteamID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID(false) == @ and ent\GetClass() == 'prop_physics']
DPP2.GetAllRagdollsBySteamID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID(false) == @ and ent\GetClass() == 'prop_ragdoll']

DPP2.GetAllEntsByPID = =>
	assert(isnumber(@), 'assert(isnumber(self))')
	return [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerPID(false) == @]

DPP2.GetAllEntitiesByPID = DPP2.GetAllEntsByUID
DPP2.GetAllNPCByPID = =>
	assert(isnumber(@), 'assert(isnumber(self))')
	return [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerPID(false) == @ and type(ent) == 'NPC']

DPP2.GetAllWeaponsByPID = =>
	assert(isnumber(@), 'assert(isnumber(self))')
	return [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerPID(false) == @ and type(ent) == 'Weapon']

DPP2.GetAllPropsByPID = =>
	assert(isnumber(@), 'assert(isnumber(self))')
	return [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerPID(false) == @ and ent\GetClass() == 'prop_physics']

DPP2.GetAllRagdollsByPID = =>
	assert(isnumber(@), 'assert(isnumber(self))')
	return [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerPID(false) == @ and ent\GetClass() == 'prop_ragdoll']

DPP2.GetAllEntsByUID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerUID(false) == @]
DPP2.GetAllEntitiesByUID = DPP2.GetAllEntsByUID
DPP2.GetAllNPCByUID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerUID(false) == @ and type(ent) == 'NPC']
DPP2.GetAllWeaponsByUID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerUID(false) == @ and type(ent) == 'Weapon']
DPP2.GetAllPropsByUID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerUID(false) == @ and ent\GetClass() == 'prop_physics']
DPP2.GetAllRagdollsByUID = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerUID(false) == @ and ent\GetClass() == 'prop_ragdoll']

DPP2.GetAllEntsByUIDStrict = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2IsOwnerTrackedByUID() and ent\DPP2GetOwnerUIDStrict() == @]
DPP2.GetAllEntitiesByUIDStrict = DPP2.GetAllEntsByUIDStrict
DPP2.GetAllNPCByUIDStrict = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2IsOwnerTrackedByUID() and ent\DPP2GetOwnerUIDStrict() == @ and type(ent) == 'NPC']
DPP2.GetAllWeaponsByUIDStrict = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2IsOwnerTrackedByUID() and ent\DPP2GetOwnerUIDStrict() == @ and type(ent) == 'Weapon']
DPP2.GetAllPropsByUIDStrict = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2IsOwnerTrackedByUID() and ent\DPP2GetOwnerUIDStrict() == @ and ent\GetClass() == 'prop_physics']
DPP2.GetAllRagdollsByUIDStrict = => [ent for i, ent in ipairs(ents.GetAll()) when ent\DPP2IsOwnerTrackedByUID() and ent\DPP2GetOwnerUIDStrict() == @ and ent\GetClass() == 'prop_ragdoll']

DPP2.HasEntsBySteamID = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @
	return false
DPP2.HasNPCBySteamID = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @ and type(ent) == 'NPC'
	return false
DPP2.HasWeaponsBySteamID = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @ and type(ent) == 'Weapon'
	return false
DPP2.HasPropsBySteamID = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @ and ent\GetClass() == 'prop_physics'
	return false
DPP2.HasRagdollsBySteamID = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerSteamID() == @ and ent\GetClass() == 'prop_ragdoll'
	return false

DPP2.HasEntsByUIDStrict = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2IsOwnerTrackedByUID() and ent\DPP2GetOwnerUIDStrict() == @
	return false
DPP2.HasNPCByUIDStrict = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2IsOwnerTrackedByUID() and ent\DPP2GetOwnerUIDStrict() == @ and type(ent) == 'NPC'
	return false
DPP2.HasWeaponsByUIDStrict = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2IsOwnerTrackedByUID() and ent\DPP2GetOwnerUIDStrict() == @ and type(ent) == 'Weapon'
	return false
DPP2.HasPropsByUIDStrict = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2IsOwnerTrackedByUID() and ent\DPP2GetOwnerUIDStrict() == @ and ent\GetClass() == 'prop_physics'
	return false
DPP2.HasRagdollsByUIDStrict = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2IsOwnerTrackedByUID() and ent\DPP2GetOwnerUIDStrict() == @ and ent\GetClass() == 'prop_ragdoll'
	return false

DPP2.HasEntsByUID = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerUID() == @
	return false
DPP2.HasNPCByUID = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerUID() == @ and type(ent) == 'NPC'
	return false
DPP2.HasWeaponsByUID = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerUID() == @ and type(ent) == 'Weapon'
	return false
DPP2.HasPropsByUID = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerUID() == @ and ent\GetClass() == 'prop_physics'
	return false
DPP2.HasRagdollsByUID = =>
	return true for i, ent in ipairs(ents.GetAll()) when ent\DPP2GetOwnerUID() == @ and ent\GetClass() == 'prop_ragdoll'
	return false

DPP2.HasEntitiesBySteamID = DPP2.HasEntsBySteamID
plyMeta.DPP2HasEntities = plyMeta.DPP2HasEnts
plyMeta.DPP2GetAllEntities = plyMeta.DPP2GetAllEnts
