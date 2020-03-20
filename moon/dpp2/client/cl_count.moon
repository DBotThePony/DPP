
-- Copyright (C) 2018-2019 DBotThePony

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

net.receive 'dpp2_limitlist_clear', ->
	identifier = net.ReadString()
	obj = assert(DPP2.DEF.LimitRegistry\GetByID(identifier), 'Unknown limit list ' .. identifier .. '!')
	entry\Remove() for entry in *[entry2 for entry2 in *obj.listing]

net.receive 'dpp2_limitentry_change', ->
	id = net.ReadUInt32()
	assert(DPP2.DEF.LimitEntry\GetByID(), 'Unknown limit entry with id ' .. id .. '!')\ReadPayload()

net.receive 'dpp2_limitentry_remove', ->
	id = net.ReadUInt32()
	assert(DPP2.DEF.LimitEntry\GetByID(), 'Unknown limit entry with id ' .. id .. '!')\Remove()

net.receive 'dpp2_limitentry_create', ->
	identifier = net.ReadString()
	obj = assert(DPP2.DEF.LimitRegistry\GetByID(identifier), 'Unknown limit list ' .. identifier .. '!')
	id = net.ReadUInt32()
	entry = DPP2.DEF.LimitEntry\ReadPayload()
	entry\Bind(obj)
	entry.replicated = true
	entry.id = id
	obj\AddEntry(entry)

net.receive 'dpp2_limitlist_replicate', ->
	identifier = net.ReadString()
	obj = assert(DPP2.DEF.LimitRegistry\GetByID(identifier), 'Unknown limit list ' .. identifier .. '!')

	entry\Remove() for entry in *[entry2 for entry2 in *obj.listing]

	for i = 1, net.ReadUInt16()
		id = net.ReadUInt32()
		entry = DPP2.DEF.LimitEntry\ReadPayload()
		entry\Bind(obj)
		entry.replicated = true
		entry.id = id
		obj\AddEntry(entry)

net.receive 'dpp2_limithit', -> hook.Run('LimitHit', net.ReadString())
