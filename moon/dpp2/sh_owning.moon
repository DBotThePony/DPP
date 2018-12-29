
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

import NULL, type, ents, player, DLib from _G

entMeta = FindMetaTable('Entity')
plyMeta = FindMetaTable('Player')

entMeta.DPP2IsOwned = => @GetNWString('dpp2_owner_steamid', '-1') ~= '-1'
entMeta.DPP2OwnerIsValid = => @GetNWEntity('dpp2_ownerent', NULL)\IsValid()

plyMeta.DPP2GetAllEnts = => [ent for ent in *ents.GetAll() when ent\DPP2GetOwner() == @]
plyMeta.DPP2GetAllEntities = => @DPP2GetAllEnts
plyMeta.DPP2GetAllNPC = => [ent for ent in *ents.GetAll() when ent\DPP2GetOwner() == @ and type(ent) == 'NPC']
plyMeta.DPP2GetAllWeapons = => [ent for ent in *ents.GetAll() when ent\DPP2GetOwner() == @ and type(ent) == 'Weapon']
plyMeta.DPP2GetAllProps = => [ent for ent in *ents.GetAll() when ent\DPP2GetOwner() == @ and ent\GetClass() == 'prop_physics']
plyMeta.DPP2GetAllRagdolls = => [ent for ent in *ents.GetAll() when ent\DPP2GetOwner() == @ and ent\GetClass() == 'prop_ragdoll']
