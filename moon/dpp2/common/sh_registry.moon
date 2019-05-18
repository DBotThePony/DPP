
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

import DPP2, type, table from _G

DPP2.DEF = DPP2.DEF or {}

class DPP2.DEF.BlacklistEntry
	new: (data) =>
		error('Invalid data type provided. Must be either not present or be a table.') if data and type(data) ~= 'table'

class DPP2.DEF.Blactlist
	new: (fname, dbtable) =>
		@dbtable = assert(type(dbtable) == 'string' and dbtable, 'Invalid blacklist dbtable')\lower()
		@loadedFromDatabase = false
		@list = {}

	LoadFromDatabase: =>
		return if @loadedFromDatabase

	Check: (ply = NULL, checkFor) =>
		return true if not ply\IsValid()
