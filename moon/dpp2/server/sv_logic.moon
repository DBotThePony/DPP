
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

import DPP2, type, table, player from _G
import IsValid from FindMetaTable('Entity')

net.pool('dpp2_contraption_create')
net.pool('dpp2_contraption_delete')
net.pool('dpp2_contraption_diff')

hook.Add 'Think', 'DPP2.CheckOwnedByMap', ->
	ent\SetNWBool('dpp2_cbm', true) for ent in *ents.GetAll() when ent\CreatedByMap()
	hook.Remove 'Think', 'DPP2.CheckOwnedByMap'

WalkConstraint = =>
	if not @__dpp2_contraption
		@__dpp2_contraption = DPP2.ContraptionHolder()
		@__dpp2_contraption\Walk(@)
	elseif @__dpp2_contraption.lastWalk < RealTime()
		@__dpp2_contraption\Walk(@)

hook.Add 'Think', 'DPP2.Contraptions', ->
	for ply in *player.GetAll()
		tr = ply\GetEyeTrace()
		if tr.Entity\IsValid() and tr.Entity.__dpp2_contraption
			tr.Entity.__dpp2_contraption\NetworkToPlayer(ply)

hook.Add 'OnEntityCreated', 'DPP2.Contraptions', =>
	timer.Simple 0, ->
		return if not IsValid(@)
		return if not @IsConstraint()
		ent1, ent2 = @GetConstrainedEntities()
		return if not IsValid(ent1) or not IsValid(ent2)
		WalkConstraint(ent1)
		WalkConstraint(ent2)
	return

hook.Add 'EntityRemoved', 'DPP2.Contraptions', =>
	return if not @IsConstraint()
	ent1, ent2 = @GetConstrainedEntities()
	return if not IsValid(ent1) or not IsValid(ent2)

	timer.Simple 0, ->
		return if not IsValid(ent1) or not IsValid(ent2)
		WalkConstraint(ent1)
		WalkConstraint(ent2)

	return