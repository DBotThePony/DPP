
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

import NULL, type, player, DPP2, string from _G
import HUDCommons, I18n from DLib

entMeta = FindMetaTable('Entity')

entMeta.DPP2GetOwner = =>
	if @GetNWString('dpp2_owner_steamid', '-1') == '-1'
		return NULL, 'world', I18n.Localize('gui.dpp2.access.status.world'), 'world', -1

	local ownerName

	owner, ownerSteamID = @GetNWEntity('dpp2_ownerent', NULL), @GetNWString('dpp2_owner_steamid')

	if IsValid(owner) and owner\IsPlayer()
		ownerName = owner\Nick()
		ownerName .. ' (' .. owner\SteamName() .. ')' if owner.SteamName and owner\SteamName() ~= ownerName
	else
		ownerName = DLib.LastNickFormatted(ownerSteamID)

	return owner, ownerSteamID, ownerName, @GetNWString('dpp2_owner_uid', 'world'), @GetNWInt('dpp2_owner_pid', -1)
