
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

import DPP2, type, table from _G
import i18n from DLib

DPP2.DEF = DPP2.DEF or {}

class DPP2.DEF.DefinitionConVarsPrefab
	new: =>
		@enabled = true
		@adminTouchAny = true
		@noWorldTouch = false
		@noWorldTouchAdmin = false
		@noMapTouch = true
		@noMapTouchAdmin = true

	SetEnabled: (enabled = @enabled) => @enabled = enabled
	SetAdminTouchAny: (adminTouchAny = @adminTouchAny) => @adminTouchAny = adminTouchAny
	SetNoWorldTouch: (noWorldTouch = @noWorldTouch) => @noWorldTouch = noWorldTouch
	SetNoWorldTouchAdmin: (noWorldTouchAdmin = @noWorldTouchAdmin) => @noWorldTouchAdmin = noWorldTouchAdmin
	SetNoMapTouch: (noMapTouch = @noMapTouch) => @noMapTouch = noMapTouch
	SetNoMapTouchAdmin: (noMapTouchAdmin = @noMapTouchAdmin) => @noMapTouchAdmin = noMapTouchAdmin

	GetEnabled: => @enabled and '1' or '0'
	GetAdminTouchAny: => @adminTouchAny and '1' or '0'
	GetNoWorldTouch: => @noWorldTouch and '1' or '0'
	GetNoWorldTouchAdmin: => @noWorldTouchAdmin and '1' or '0'
	GetNoMapTouch: => @noMapTouch and '1' or '0'
	GetNoMapTouchAdmin: => @noMapTouchAdmin and '1' or '0'

class DPP2.DEF.ProtectionDefinition
	new: (classname, prefab = DPP2.DEF.DefinitionConVarsPrefab()) =>
		@name = assert(type(classname) == 'string' and classname, 'Invalid definition classname')\lower()
		@enabled = DLib.util.CreateSharedConvar('dpp2_' .. @name .. '_protection', prefab\GetEnabled(), 'Enable ' .. @name .. ' protection module')
		@adminTouchAny = DLib.util.CreateSharedConvar('dpp2_' .. @name .. '_touch_any', prefab\GetAdminTouchAny(), 'Admins in ' .. @name .. ' protection module can touch anyones else props')
		@noWorldTouch = DLib.util.CreateSharedConvar('dpp2_' .. @name .. '_no_world', prefab\GetNoWorldTouch(), 'Players can not touch world owned props')
		@noWorldTouchAdmin = DLib.util.CreateSharedConvar('dpp2_' .. @name .. '_no_world_admin', prefab\GetNoWorldTouchAdmin(), 'REGULAR (the _admin CAMI privilege) Admins can not touch world owned props')
		@noMapTouch = DLib.util.CreateSharedConvar('dpp2_' .. @name .. '_no_map', prefab\GetNoMapTouch(), 'Players can not touch MAP owned props (entities which were created in hammer editor)')
		@noMapTouchAdmin = DLib.util.CreateSharedConvar('dpp2_' .. @name .. '_no_map_admin', prefab\GetNoMapTouchAdmin(), 'MAP (the _map_admin CAMI privilege) Admins can not touch MAP owned props (entities which were created in hammer editor)')
		@camiwatchdog = DLib.CAMIWatchdog('dpp2_' .. @name .. '_protection', 10)

		CAMI.RegisterPrivilege({
			Name: 'dpp2_' .. @name .. '_admin'
			MinAccess: 'admin'
			Description: 'DPP/2 Module ' .. @name .. ' treats player as admin'
		})

		CAMI.RegisterPrivilege({
			Name: 'dpp2_' .. @name .. '_map_admin'
			MinAccess: 'superadminadmin'
			Description: 'DPP/2 Module ' .. @name .. ' treats player as map admin'
		})

		@otherPermString = 'dpp2_' .. @name .. '_admin'
		@otherPermStringMap = 'dpp2_' .. @name .. '_map_admin'

		@camiwatchdog\Track('dpp2_' .. @name .. '_admin')
		@camiwatchdog\Track('dpp2_' .. @name .. '_map_admin')

	IsEnabled: => @enabled\GetBool() and DPP2.ENABLE_PROTECTION\GetBool()

	CanTouchWorld: (ply = NULL) =>
		return true if not ply\IsValid()
		return true if not @IsEnabled()

		return not @noWorldTouch\GetBool() or not @noWorldTouchAdmin\GetBool() if @camiwatchdog\HasPermission(ply, @otherPermString)
		return not @noWorldTouch\GetBool()

	CanTouchMap: (ply = NULL) =>
		return true if not ply\IsValid()
		return true if not @IsEnabled()

		return not @noMapTouch\GetBool() or not @noMapTouchAdmin\GetBool() if @camiwatchdog\HasPermission(ply, @otherPermStringMap)
		return not @noMapTouch\GetBool()

	CanTouchOther: (ply = NULL, other = NULL) =>
		return true if not ply\IsValid()
		return @CanTouchWorld(ply) if other == 'world'
		return true if not @IsEnabled()

		return true if @camiwatchdog\HasPermission(ply, @otherPermString) and @adminTouchAny\GetBool()
		return false

	CanTouch: (ply = NULL, ent = NULL) =>
		return true if not ply\IsValid()
		return false if not ent\IsValid()
		return true, i18n.localize('gui.dpp2.access.status.disabled') if not @IsEnabled()
		contraption = ent\DPP2GetContraption()

		if not contraption
			owner, ownerSteamID, ownerNick = ent\DPP2GetOwner()
			return true if owner == ply
			return @CanTouchMap(ply), i18n.localize('gui.dpp2.access.status.map') if ownerSteamID == 'world' and ent\CreatedByMap()
			return @CanTouchWorld(ply), i18n.localize('gui.dpp2.access.status.world') if ownerSteamID == 'world'
			return @CanTouchOther(ply, ownerSteamID), i18n.localize('gui.dpp2.access.status.friend')

		steamid = ply\SteamID()

		for ownerSteamID in *contraption\GetOwners()
			if steamid ~= ownerSteamID
				return false, i18n.localize('gui.dpp2.access.status.map'), i18n.localize('gui.dpp2.access.status.contraption') if ownerSteamID == 'world' and ent\CreatedByMap() and not @CanTouchMap(ply)
				return false, i18n.localize('gui.dpp2.access.status.world'), i18n.localize('gui.dpp2.access.status.contraption') if ownerSteamID == 'world' and not @CanTouchWorld(ply)
				return false, i18n.localize('gui.dpp2.access.status.friend'), i18n.localize('gui.dpp2.access.status.contraption') if ownerSteamID ~= 'world' and not @CanTouchOther(ply, ownerSteamID)

		return true, i18n.localize('gui.dpp2.access.status.contraption')
