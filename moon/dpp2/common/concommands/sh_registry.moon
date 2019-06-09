
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

import DPP2, DLib from _G

empty = {}
stuffCache = {}

findStuff = (path) ->
	if not stuffCache[path]
		ffiles, fdirs = select(1, file.Find(path .. '/*.mdl', 'GAME')), select(2, file.Find(path .. '/*', 'GAME'))

		if not ffiles
			stuffCache[path] = {}
			return stuffCache[path]

		table.appendString(fdirs, '/')
		table.append(ffiles, fdirs)
		stuffCache[path] = ffiles

	return stuffCache[path]

DPP2.ModelAutocomplete = (args, margs, excludelist = empty) =>
	args = args\lower()\gsub('//', '/')
	return {'models/'} if (args == '' or #args < 7) and args ~= 'models/'

	findDir = args\split('/')
	filename = table.remove(findDir)
	dpath = table.concat(findDir, '/')
	findFiles = findStuff(dpath)

	output = {}

	for filename2 in *findFiles
		with lower = filename2\lower()
			if not table.qhasValue(excludelist, lower) and not table.qhasValue(excludelist, filename2)
				if lower == filename
					output = {string.format('%s/%s', dpath, filename2)}
					break

				if lower\startsWith(filename)
					table.insert(output, string.format('%s/%s', dpath, filename2))

	return output
