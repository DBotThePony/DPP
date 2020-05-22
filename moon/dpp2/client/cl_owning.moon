
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
import HUDCommons from DLib

entMeta = FindMetaTable('Entity')

DPP2.CL_DRAW_OWNER = DPP2.CreateClientConVar('cl_draw_owner', '1', DPP2.TYPE_BOOL)
DPP2.CL_SIMPLE_OWNER = DPP2.CreateClientConVar('cl_simple_owner', '0', DPP2.TYPE_BOOL)
DPP2.CL_SHOW_ENTITY_NAME = DPP2.CreateClientConVar('cl_entity_name', '1', DPP2.TYPE_BOOL)
DPP2.CL_SHOW_ENTITY_INFO = DPP2.CreateClientConVar('cl_entity_info', '1', DPP2.TYPE_BOOL)
DPP2.CL_DONT_PROCESS_CONTRAPTIONS = DPP2.CreateClientConVar('cl_no_contraptions', '0', DPP2.TYPE_BOOL)

DPP2.CL_DONT_SHOW_PLAYERS = DPP2.CreateClientConVar('cl_no_players', '1', DPP2.TYPE_BOOL)
DPP2.CL_DONT_SHOW_FUNC = DPP2.CreateClientConVar('cl_no_func', '1', DPP2.TYPE_BOOL)

entMeta.DPP2GetOwner = =>
	if @GetNWString('dpp2_owner_steamid', '-1') == '-1'
		return NULL, 'world', 'World', 'world'
	else
		owner, ownerSteamID, ownerName = @GetNWEntity('dpp2_ownerent', NULL), @GetNWString('dpp2_owner_steamid'), DLib.LastNickFormatted(@GetNWString('dpp2_owner_steamid')), @GetNWString('dpp2_owner_uid', 'world')

		if IsValid(owner) and owner\IsPlayer()
			ownerName = owner\Nick()
			ownerName .. ' (' .. owner\SteamName() .. ')' if owner.SteamName and owner\SteamName() ~= ownerName

		return owner, ownerSteamID, ownerName

DPP2.HUDPanel\Remove() if IsValid(DPP2.HUDPanel)

UpdateFont = ->
	surface.CreateFont('DPP2.OwnerFont', {
		font: 'Roboto'
		extended: true
		size: ScreenSize(10)
		weight: 500
	})

hook.Add 'ScreenResolutionChanged', 'DPP2.OwnerFont', UpdateFont
UpdateFont()

import EyePos, EyeAngles, Vector, Angle, hook, FrameNumber, util, MASK_ALL, surface, ScreenSize, tostring, draw, LocalPlayer, GetViewEntity from _G

lastUpdateFrame = 0
lastEyePos = Vector()
lastEyeAngles = Angle()
entfilter = {LocalPlayer()}

BACKGROUND = HUDCommons.CreateColor('dpp2_bg', 'DPP/2 Owner panel background', 0, 0, 0, 200)
CAN_TOUCH = HUDCommons.CreateColor('dpp2_can_touch', 'DPP/2 Can touch text', 66, 229, 70, 255)
CAN_NOT_TOUCH = HUDCommons.CreateColor('dpp2_cant_touch', 'DPP/2 Can\'t touch text', 213, 43, 43, 255)

GetOwnerText = ->
	return if not DPP2.CL_DRAW_OWNER\GetBool() or not DPP2.DRAW_OWNER\GetBool()

	ply = DLib.HUDCommons.SelectPlayer()

	tr = util.TraceLine({
		start: lastEyePos
		endpos: lastEyePos + lastEyeAngles\Forward() * 16834
		filter: {GetViewEntity(), ply}
		mask: MASK_ALL
	})

	CL_SIMPLE_OWNER = DPP2.CL_SIMPLE_OWNER\GetBool() or DPP2.SIMPLE_OWNER\GetBool()

	return if not tr.Hit or not tr.Entity\IsValid()
	return if tr.Entity\IsPlayer() and DPP2.CL_DONT_SHOW_PLAYERS\GetBool()
	return if tr.Entity\GetClass() and (tr.Entity\GetClass()\startsWith('func_') or tr.Entity\GetClass()\startsWith('prop_door')) and DPP2.CL_DONT_SHOW_FUNC\GetBool()
	owner, ownerSteamID, ownerName = tr.Entity\DPP2GetOwner()
	--ownerName = tr.Entity\Nick() if tr.Entity\IsPlayer()
	ownerName = string.format('%s\n%s', ownerName, tostring(tr.Entity)) if not CL_SIMPLE_OWNER and not tr.Entity\IsPlayer() and DPP2.CL_SHOW_ENTITY_INFO\GetBool() and DPP2.SHOW_ENTITY_INFO\GetBool()

	canTouch = true

	if not CL_SIMPLE_OWNER and DPP2.CL_SHOW_ENTITY_NAME\GetBool() and DPP2.SHOW_ENTITY_NAME\GetBool()
		if tr.Entity.GetPrintName and tr.Entity\GetPrintName() ~= ''
			ownerName = string.format('%s\n%q', ownerName, tr.Entity\GetPrintName())
		elseif tr.Entity.PrintName and tr.Entity.PrintName ~= ''
			ownerName = string.format('%s\n%q', ownerName, tr.Entity.PrintName)

	switch ply\GetActiveWeaponClass()
		when 'weapon_physgun'
			status, text1, text2 = DPP2.ACCESS.CanPhysgun(ply, tr.Entity)
			canTouch = status

			if not CL_SIMPLE_OWNER
				ownerName = string.format('%s\n%s', ownerName, text1) if text1
				ownerName = string.format('%s\n%s', ownerName, text2) if text2

		when 'gmod_tool'
			status, text1, text2 = DPP2.ACCESS.CanToolgun(ply, tr.Entity, ply\GetActiveWeapon()\GetMode() or 'remover')
			canTouch = status

			if not CL_SIMPLE_OWNER
				ownerName = string.format('%s\n%s', ownerName, text1) if text1
				ownerName = string.format('%s\n%s', ownerName, text2) if text2

		when 'weapon_physcannon'
			status, text1, text2 = DPP2.ACCESS.CanGravgun(ply, tr.Entity)
			canTouch = status

			if not CL_SIMPLE_OWNER
				ownerName = string.format('%s\n%s', ownerName, text1) if text1
				ownerName = string.format('%s\n%s', ownerName, text2) if text2

		else
			status, text1, text2 = DPP2.ACCESS.CanDamage(ply, tr.Entity)
			canTouch = status

			if not CL_SIMPLE_OWNER
				ownerName = string.format('%s\n%s', ownerName, text1) if text1
				ownerName = string.format('%s\n%s', ownerName, text2) if text2

	if canTouch
		return ownerName, CAN_TOUCH()

	return ownerName, CAN_NOT_TOUCH()

POS_OWNING = HUDCommons.Position2.DefinePosition('dpp2_owner', 0.004, 0.5, false)

HUDPaint = (_, pw, ph) ->
	x, y = POS_OWNING()
	text, color = GetOwnerText()
	return if not text

	surface.SetFont('DPP2.OwnerFont')
	w, h = surface.GetTextSize(text)
	y -= h * 0.5
	padding = ScreenSize(2)\ceil()
	padding2 = ScreenSize(3)\ceil()

	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(x - padding2, y - padding, w + padding2 * 2, h + padding * 2)
	draw.DrawText(text, 'DPP2.OwnerFont', x, y, color)

UpdateFilter = ->
	entfilter = ents.FindInSphere(lastEyePos, 16)
	table.insert(entfilter, LocalPlayer()) if not LocalPlayer()\ShouldDrawLocalPlayer()

PostDrawTranslucentRenderables = (a, b) ->
	return if a or b
	return if lastUpdateFrame == FrameNumber()
	lastUpdateFrame = FrameNumber()
	lastEyeAngles = EyeAngles()
	lastEyePos = EyePos()
	--UpdateFilter()

CalcView = (data) ->
	return data if type(data) ~= 'table'
	return data if type(data.origin) ~= 'Vector'
	return data if type(data.angles) ~= 'Angle'
	lastUpdateFrame = FrameNumber()
	lastEyeAngles = data.angles
	lastEyePos = data.origin
	--UpdateFilter()
	return data

Think = =>
	ply = LocalPlayer()
	return if not IsValid(ply)

	if ply\GetActiveWeaponClass() == 'gmod_camera'
		@SetRenderInScreenshots(false)
	else
		@SetRenderInScreenshots(true)

timer.Simple 0, ->
	with DPP2.HUDPanel = vgui.Create('EditablePanel')
		\Dock(FILL)
		\SetKeyboardInputEnabled(false)
		\SetMouseInputEnabled(false)
		\SetRenderInScreenshots(false)
		.Paint = HUDPaint
		.Think = Think

hook.Add 'PostDrawTranslucentRenderables', 'DPP2.UpdateDisplay', PostDrawTranslucentRenderables
hook.AddPostModifier 'CalcView', 'DPP2.UpdateDisplay', CalcView
