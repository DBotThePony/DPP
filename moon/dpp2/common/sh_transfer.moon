
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

DPP2.cmd_autocomplete.transfer = (args = '') =>
	return if not IsValid(@)
	[string.format('%q', ply) for ply in *DPP2.FindPlayersInArgument(args, true, true)]

DPP2.cmd_autocomplete.transferfallback = (args = '') =>
	return if not IsValid(@)
	[string.format('%q', ply) for ply in *DPP2.FindPlayersInArgument(args, {LocalPlayer(), @GetNWEntity('dpp2_transfer_fallback', NULL)}, true)]

DPP2.cmd_autocomplete.transferent = (args = '', margs = '') =>
	return if not IsValid(@)
	args = DPP2.SplitArguments(args)
	return [string.format('%q', tostring(ent)) for ent in *@DPP2FindOwned()] if not args[1]

	ace = {}
	args[1] = args[1]\lower()

	if num = tonumber(args[1])
		entf = Entity(num)

		if IsValid(entf)
			if entf\DPP2GetOwner() == @
				table.insert(ace, tostring(entf))
			else
				table.insert(ace, '<not an owner!>')
		else
			for ent in *@DPP2FindOwned()
				if ent\EntIndex()\tostring()\startsWith(args[1])
					table.insert(ace, tostring(ent))
	else
		for ent in *@DPP2FindOwned()
			str = tostring(ent)

			if str == args[1]
				ace = {str}
				break

			if str\lower()\startsWith(args[1])
				table.insert(ace, str)

	table.sort(ace)
	return [string.format('%q', ent) for ent in *ace] if margs[#margs] ~= ' ' and not args[2]
	return [string.format('%q <player>', ent) for ent in *ace] if not args[2]

	table.remove(args, 1)
	return [string.format('%q %q', ent, ply) for ent in *ace for ply in *DPP2.FindPlayersInArgument(table.concat(args, ' ')\trim(), true, true)]

DPP2.cmd_autocomplete.transfertoworldent = (args = '', margs = '') =>
	return if not IsValid(@)
	return [string.format('%q', tostring(ent)) for ent in *@DPP2FindOwned()] if args == ''

	ace = {}
	args = args\lower()

	if num = tonumber(args)
		entf = Entity(num)

		if IsValid(entf)
			if entf\DPP2GetOwner() == @
				table.insert(ace, string.format('%q', tostring(entf)))
			else
				table.insert(ace, '<not an owner!>')
		else
			for ent in *@DPP2FindOwned()
				if ent\EntIndex()\tostring()\startsWith(args)
					table.insert(ace, string.format('%q', tostring(ent)))
	else
		for ent in *@DPP2FindOwned()
			str = tostring(ent)

			if str == args
				ace = {str}
				break

			if str\lower()\startsWith(args)
				table.insert(ace, string.format('%q', str))

	table.sort(ace)
	return ace
