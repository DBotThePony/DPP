
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

import DPP2, type, table, net from _G

entMeta = FindMetaTable('Entity')

entMeta.DPP2CreatedByMap = => not @IsPlayer() and @GetNWBool('dpp2_cbm', false)

net.receive 'dpp2_contraption_create', ->
	id = net.ReadUInt32()
	entsRead = net.ReadEntityArray()

	obj = DPP2.ContraptionHolder\GetByID(id)

	if obj
		ent.__dpp2_contraption = nil for ent in *entsRead when ent.__dpp2_contraption == obj
		obj.ents = entsRead
		obj\Invalidate()
	else
		obj = DPP2.ContraptionHolder(id)\From(entsRead)

net.receive 'dpp2_contraption_delete', ->
	id = net.ReadUInt32()
	merge = net.ReadBool()
	DPP2.ContraptionHolder\Invalidate()
	obj = DPP2.ContraptionHolder\GetByID(id)
	return if not obj
	obj\MarkForDeath(merge)

net.receive 'dpp2_contraption_invalidate', ->
	id = net.ReadUInt32()
	DPP2.ContraptionHolder\Invalidate()
	obj = DPP2.ContraptionHolder\GetByID(id)
	return if not obj
	obj\Invalidate()

net.receive 'dpp2_contraption_diff', ->
	id = net.ReadUInt32()
	added = net.ReadEntityArray()
	removed = net.ReadEntityArray()
	obj = DPP2.ContraptionHolder\GetByID(id)
	return if not obj

	table.insert(obj.ents, ent) for ent in *added

	for ent in *removed
		for i, ent2 in ipairs(obj.ents)
			if ent == ent2
				ent.__dpp2_contraption = nil if ent.__dpp2_contraption == obj
				table.remove(obj.ents, i)
				break

	obj\Invalidate()
