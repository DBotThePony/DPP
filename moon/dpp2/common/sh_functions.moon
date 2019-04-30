
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

import Entity from _G

entMeta = FindMetaTable('Entity')

local worldspawn

entMeta.DPP2GetPhys = =>
	return if @IsPlayer() or @IsNPC()
	worldspawn = Entity(0)\GetPhysicsObject()

	switch @GetPhysicsObjectCount()
		when 0
			return
		when 1
			phys = @GetPhysicsObject()
			return if not phys\IsValid() or phys == worldspawn
			return phys

	local output

	for i = 0, @GetPhysicsObjectCount()
		phys = @GetPhysicsObjectNum(i)

		if phys\IsValid() and phys ~= worldspawn
			output = output or {}
			table.insert(output, output)

	return if not output
	return output[1] if #output == 1
	return output
