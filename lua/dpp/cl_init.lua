
--[[
Copyright (C) 2016-2017 DBot


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

]]

--Client

local DISPLAY_BACKGROUND_R = CreateConVar('dpp_color_background_r', 0, FCVAR_ARCHIVE, 'Red Channel for display info background')
local DISPLAY_BACKGROUND_G = CreateConVar('dpp_color_background_g', 0, FCVAR_ARCHIVE, 'Green Channel for display info background')
local DISPLAY_BACKGROUND_B = CreateConVar('dpp_color_background_b', 0, FCVAR_ARCHIVE, 'Blue Channel for display info background')
local DISPLAY_BACKGROUND_A = CreateConVar('dpp_color_background_a', 200, FCVAR_ARCHIVE, 'Alpha Channel for display info background')

local DISPLAY_TOUCH_CAN_R = CreateConVar('dpp_color_cantouch_r', 40, FCVAR_ARCHIVE, 'Red Channel for "can touch" text')
local DISPLAY_TOUCH_CAN_G = CreateConVar('dpp_color_cantouch_g', 255, FCVAR_ARCHIVE, 'Green Channel for "can touch" text')
local DISPLAY_TOUCH_CAN_B = CreateConVar('dpp_color_cantouch_b', 51, FCVAR_ARCHIVE, 'Blue Channel for "can touch" text')
local DISPLAY_TOUCH_CAN_A = CreateConVar('dpp_color_cantouch_a', 255, FCVAR_ARCHIVE, 'Alpha Channel for "can touch" text')

local DISPLAY_TOUCH_CANNOT_R = CreateConVar('dpp_color_cannottouch_r', 255, FCVAR_ARCHIVE, 'Red Channel for "can not touch" text')
local DISPLAY_TOUCH_CANNOT_G = CreateConVar('dpp_color_cannottouch_g', 51, FCVAR_ARCHIVE, 'Green Channel for "can not touch" text')
local DISPLAY_TOUCH_CANNOT_B = CreateConVar('dpp_color_cannottouch_b', 0, FCVAR_ARCHIVE, 'Blue Channel for "can not touch" text')
local DISPLAY_TOUCH_CANNOT_A = CreateConVar('dpp_color_cannottouch_a', 255, FCVAR_ARCHIVE, 'Alpha Channel for "can not touch" text')

local POSITION_X = CreateConVar('dpp_position_x', 0, FCVAR_ARCHIVE, 'X coordinate (percent) on screen for owner display')
local POSITION_Y = CreateConVar('dpp_position_Y', 50, FCVAR_ARCHIVE, 'Y coordinate (percent) on screen for owner display')

language.Add('Undo_TransferedProp', 'Undo DPP Transfered Entity')
language.Add('Undo_Owned_Prop', 'Undo DPP Owned Entity')

DLib.RegisterAddonName('DPP')

do
	local data = sql.Query('SELECT * FROM dpp_friends')

	if data then
		sql.Begin()

		for i, row in ipairs(data) do
			local steamid = row.STEAMID
			local nickname = row.NICKNAME
			local modes = util.JSONToTable(row.MODES)
			DLib.UpdateLastNick(steamid, nickname)

			if modes then
				local data2 = DLib.friends.LoadPlayer(steamid, true, true)

				for mode, status in pairs(modes) do
					DLib.friends.UpdateFriendType(steamid, 'dpp_' .. mode, status)
				end
			end
		end

		sql.Commit()

		DLib.friends.Flush()

		sql.Query('DROP TABLE dpp_friends')
	end
end

DPP.FriendsCPPI = {}

function DPP.ClientConVarChanged(var, old, new)
	var = string.sub(var, 5)

	if DPP.CSettings[var].nosend then return end

	net.Start('DPP.ConVarChanged')
	net.WriteString(var)
	net.SendToServer()
end

function DPP.GetFriendTableCPPI(ply)
	return ply:GetAllFriends()
end

function DPP.GetOwnerName(ent)
	local owner = DPP.GetOwner(ent)
	if not IsValid(owner) then return 'World' end
	if not owner:IsPlayer() then return owner:GetClass() end
	return owner:Nick()
end

local function ArgBool(val)
	if val == nil then return true end

	local n = tonumber(val)
	if not n then return true end

	if n <= 0 then return false end
	return true
end

concommand.Add('dpp_importfppbuddies', function(ply)
	local friends = sql.Query('SELECT * FROM `FPP_Buddies`')
	if not friends then return end

	for k, row in ipairs(friends) do
		local steamid = row.steamid

		DLib.friends.UpdateFriendType(steamid, 'dpp_use', tobool(row.playeruse))
		DLib.friends.UpdateFriendType(steamid, 'dpp_toolgun', tobool(row.toolgun))
		DLib.friends.UpdateFriendType(steamid, 'dpp_physgun', tobool(row.physgun))
		DLib.friends.UpdateFriendType(steamid, 'dpp_gravgun', tobool(row.gravgun))
		DLib.friends.UpdateFriendType(steamid, 'dpp_damage', tobool(row.entitydamage))

		if row.name then
			DLib.UpdateLastNick(steamid, row.name)
		end

		DPP.Message(DPP.GetPhrase('friend_added_fpp', row.name or steamid))
	end

	DLib.friends.Flush()

	DPP.Message(DPP.GetPhrase('friend_added'))
	hook.Run('CPPIFriendsChanged', LocalPlayer(), LocalPlayer():GetAllFriends())
end)

local DEFAULT_FONT = 'DPP.FONT'
local DEFAULT_FONT_SMALL = 'DPP.FONT_small'

DPP.FontsData = {
	[DEFAULT_FONT] = {
		font = 'Roboto',
		size = 18,
		weight = 500,
		extended = true,
	},

	['DPP.Arial'] = {
		font = 'Arial',
		size = 16,
		weight = 1000,
		extended = true,
	},

	['DPP.Terminal'] = {
		font = 'Terminal',
		size = 16,
		weight = 1000,
	},

	['DPP.Time'] = {
		font = 'Time',
		size = 18,
		weight = 1200,
	},

	['DPP.System'] = {
		font = 'System',
		size = 16,
		weight = 1000,
	},

	['DPP.OpenSans'] = {
		font = 'Open Sans',
		size = 18,
		weight = 400,
		extended = true,
	},

	['DPP.MSSans'] = {
		font = 'Microsoft Sans',
		size = 16,
		weight = 1000,
		extended = true,
	},

	['DPP.LBiolinumG'] = {
		font = 'Linux Biolinum G',
		size = 16,
		weight = 600,
		extended = true,
	},

	['DPP.ComicSans'] = {
		font = 'Comic Sans MS',
		size = 20,
		weight = 1000,
		extended = true,
	},

	['DPP.Impact'] = {
		font = 'Impact',
		size = 20,
		weight = 500,
		extended = true,
	},

	['DPP.TNR'] = {
		font = 'Times New Roman',
		size = 20,
		weight = 500,
		extended = true,
	},

	['DPP.UbuntuLight'] = {
		font = 'Ubuntu Light',
		size = 20,
		weight = 500,
		extended = true,
	},
}

local Roboto = {
	['RobotoLight'] = 'Roboto Light',
	['RobotoItalic'] = 'Roboto Italic',
	['RobotoBold'] = 'Roboto Bold',
	['RobotoBoldI'] = 'Roboto Bold Italic',
	['RobotoThin'] = 'Roboto Thin',
	['RobotoThinI'] = 'Roboto Thin Italic',
	['RobotoLI'] = 'Roboto Light Italic',
}

DPP.Fonts = {
	{id = DEFAULT_FONT, name = 'Roboto (DPP Default)'},
	{id = 'DPP.Arial', name = 'Arial'},

	--Default fonts
	{id = 'DebugFixed', name = 'Default: DebugFixed'},
	{id = 'DebugFixedSmall', name = 'Default: DebugFixedSmall'},
	{id = 'Default', name = 'Default: Default'},
	{id = 'Trebuchet18', name = 'Default: Trebuchet18'},
	{id = 'Trebuchet24', name = 'Default: Trebuchet24'},
	{id = 'HudHintTextLarge', name = 'Default: HudHintTextLarge'},
	{id = 'HudHintTextSmall', name = 'Default: HudHintTextSmall'},
	{id = 'CenterPrintText', name = 'Default: CenterPrintText'},
	{id = 'HudSelectionText', name = 'Default: HudSelectionText'},
	{id = 'CloseCaption_Normal', name = 'Default: CloseCaption_Normal'},
	{id = 'CloseCaption_Bold', name = 'Default: CloseCaption_Bold'},
	{id = 'CloseCaption_BoldItalic', name = 'Default: CloseCaption_BoldItalic'},
	{id = 'ChatFont', name = 'Default: ChatFont'},
	{id = 'TargetID', name = 'Default: TargetID'},
	{id = 'TargetIDSmall', name = 'Default: TargetIDSmall'},
	{id = 'BudgetLabel', name = 'Default: BudgetLabel'},

	{id = 'DPP.Terminal', name = 'Terminal (Windows Only)'},
	{id = 'DPP.Time', name = 'Time (Windows Only)'},
	{id = 'DPP.System', name = 'System (Windows Only)'},
	{id = 'DPP.OpenSans', name = 'Open Sans'},
	{id = 'DPP.MSSans', name = 'Microsoft Sans (Windows Only)'},
	{id = 'DPP.LBiolinumG', name = 'Linux Biolinum G'},
	{id = 'DPP.ComicSans', name = 'Comic Sans (Mustdie Only)'},
	{id = 'DPP.Impact', name = 'Impact (Mustdie Only)'},
	{id = 'DPP.TNR', name = 'Times New Roman'},
}

for k, v in pairs(Roboto) do
	DPP.FontsData['DPP.' .. k] = {
		font = v,
		size = 18,
		weight = 500,
		extended = true,
	}

	table.insert(DPP.Fonts, {id = 'DPP.' .. k, name = v})
end

DPP.FontsDataSmall = {}

for k, v in pairs(DPP.FontsData) do
	DPP.FontsDataSmall[k] = table.Copy(v)
	DPP.FontsDataSmall[k].size = DPP.FontsDataSmall[k].size - 4

	surface.CreateFont(k, v)
	surface.CreateFont(k .. '_small', DPP.FontsDataSmall[k])

	for i, data in ipairs(DPP.Fonts) do
		if data.id == k then
			data.sid = k .. '_small'
		end
	end
end

function DPP.GetFont(name)
	local var = DPP.PlayerConVar(LocalPlayer(), 'font')

	local Smaller = DPP.LocalConVar('smaller_fonts')

	if not DPP.Fonts[var] then
		return not Smaller and DEFAULT_FONT or DEFAULT_FONT_SMALL
	end

	if not name then
		local d = DPP.Fonts[var]
		return not Smaller and d.id or d.sid
	else
		return DPP.Fonts[var].name
	end
end

--Keep these to be safe
local X, Y = 0, ScrH() / 2
local traceEntity

local function pointInsideBox(point, mins, maxs)
	return
		mins.x < point.x and point.x < maxs.x and
		mins.y < point.y and point.y < maxs.y and
		mins.z < point.z and point.z < maxs.z
end

local lastCalcView

hook.AddPostModifier('CalcView', 'DPP.checkCalcView', function(newData)
	lastCalcView = newData
	return newData
end)

-- DHUD/2 Code
local function SelectPlayer()
	local ply = LocalPlayer()
	if not IsValid(ply) then return ply end
	local obs = ply:GetObserverTarget()

	if IsValid(obs) and obs:IsPlayer() then
		return obs
	else
		return ply
	end
end

local HUDPaint

if IsValid(DPP.HUDPanelHidden) then
	DPP.HUDPanelHidden:Remove()
end

local function HUDThink()
	if DPP.PlayerConVar(nil, 'hide_hud') then return end
	if DPP.GetConVar('disable_huds') and DPP.LocalConVar('hud_obey_server') then return end

	if IsValid(DPP.HUDPanelHidden) then
		DPP.HUDPanelHidden:SetPos(0, 0)
		DPP.HUDPanelHidden:SetSize(ScrWL(), ScrHL())
	else
		DPP.HUDPanelHidden = vgui.Create('EditablePanel')
		if IsValid(DPP.HUDPanelHidden) then
			DPP.HUDPanelHidden:SetPos(0, 0)
			DPP.HUDPanelHidden:SetSize(ScrWL(), ScrHL())
			DPP.HUDPanelHidden:SetMouseInputEnabled(false)
			DPP.HUDPanelHidden:SetKeyboardInputEnabled(false)
			DPP.HUDPanelHidden:SetRenderInScreenshots(false)

			DPP.HUDPanelHidden.Paint = function(pnl, w, h)
				surface.DisableClipping(true)
				HUDPaint()
				surface.DisableClipping(false)
			end
		end
	end

	local epos, eang
	local ignoreNearest = false
	local ply = SelectPlayer()

	if ply:ShouldDrawLocalPlayer() then
		lastCalcView = lastCalcView or {}
		epos = lastCalcView.origin or ply:EyePos()
		eang = lastCalcView.angles or ply:EyeAngles()
		ignoreNearest = true
	else
		epos = ply:EyePos()
		eang = ply:EyeAngles()

		if ply:InVehicle() then
			eang = eang + ply:GetVehicle():GetAngles()
		end
	end

	hitPos = epos
	hitAngle = eang
	local vehicleValid, vehicle = ply:InVehicle(), ply:GetVehicle()
	local vehicleParent

	if vehicleValid then
		vehicleParent = vehicle:GetParent()
	end

	local tr = util.TraceLine{
		mask = MASK_ALL,
		filter = function(hitEntity)
			if not hitEntity:IsValid() then return true end
			if not ignoreNearest and hitEntity == ply then return false end
			if ignoreNearest and (pointInsideBox(epos, hitEntity:WorldSpaceAABB()) or epos:DistToSqr(hitEntity:GetPos()) < 400) then return false end
			if vehicleValid and (hitEntity == vehicle or hitEntity == vehicleParent) then return false end

			return true
		end,
		start = epos,
		endpos = epos + eang:Forward() * 16000
	}

	traceEntity = tr.Entity
end

local function PostDrawHUDDefault(x, y)
	x = x or X
	y = y or Y

	local Green = Color(DISPLAY_TOUCH_CAN_R:GetInt(), DISPLAY_TOUCH_CAN_G:GetInt(), DISPLAY_TOUCH_CAN_B:GetInt(), DISPLAY_TOUCH_CAN_A:GetInt())
	local Red = Color(DISPLAY_TOUCH_CANNOT_R:GetInt(), DISPLAY_TOUCH_CANNOT_G:GetInt(), DISPLAY_TOUCH_CANNOT_B:GetInt(), DISPLAY_TOUCH_CANNOT_A:GetInt())

	local ent = traceEntity
	if not IsValid(ent) then return end

	local curWeapon = LocalPlayer():GetActiveWeapon()
	local CanTouch, reason
	local name = DPP.GetOwnerName(ent)

	local isPly = false
	local Owner, Owned, Nick, UID, SteamID
	local disconnected = false

	if not ent:IsPlayer() then
		Owned = DPP.IsOwned(ent)
		Owner = DPP.GetOwner(ent)
		disconnected = false

		if Owned and not IsValid(Owner) then
			Nick, UID, SteamID = DPP.GetOwnerDetails(ent)
			name = Nick
			disconnected = true
		end
	else
		Owned = false
		Owner = ent
		name = ent:Nick()
		isPly = true
	end

	local f = DPP.LocalConVar('display_owner')

	if not f then
		name = ''
	end

	if DPP.LocalConVar('display_entityclass') then
		if f then
			name = name .. '\n'
			f = false
		end

		name = name .. ent:GetClass()
	end

	if DPP.LocalConVar('display_entityclass2') then
		if f then
			name = name .. '\n'
			f = false
		end

		name = name .. '<' .. tostring(ent) .. '>'
	end

	if not isPly and DPP.LocalConVar('display_entityname') then
		local str = ent:IsPlayer() and ent:Nick() or ent:IsWeapon() and ent:GetPrintName() or ent.PrintName or ''

		if str ~= '' then
			name = name .. '\n' .. str
		end
	end

	local DisplayReason = DPP.LocalConVar('display_reason')

	if IsValid(curWeapon) and DPP.GetConVar('enable') then
		local class = curWeapon:GetClass()
		local hit = false

		if class == 'gmod_tool' then
			local mode = curWeapon:GetMode()
			if not mode then return 0, 0 end --Eh
			local CanTouch1, reason = DPP.CanTool(LocalPlayer(), ent, mode)
			CanTouch = CanTouch1 ~= false

			if reason and DisplayReason then
				name = name .. '\n' .. reason
			end

			hit = true
		end

		if class == 'weapon_physgun' then
			CanTouch, reason = DPP.CanPhysgun(LocalPlayer(), ent)
			CanTouch = CanTouch ~= false

			if DPP.GetConVar('enable_physgun') then
				if status and DisplayReason then
					name = name .. '\n' .. reason
				end
			else
				CanTouch = true
			end

			if reason and DisplayReason then
				name = name .. '\n' .. reason
			end

			hit = true
		end

		if class == 'weapon_physcannon' then
			CanTouch, reason = DPP.CanGravgun(LocalPlayer(), ent)

			CanTouch = CanTouch ~= false

			if DPP.GetConVar('enable_gravgun') then
				if status and DisplayReason then
					name = name .. '\n' .. reason
				end
			else
				CanTouch = true
			end

			if reason and DisplayReason then
				name = name .. '\n' .. reason
			end

			hit = true
		end

		if not hit then
			if ent:IsPlayer() then
				CanTouch = true
			else
				CanTouch = DPP.CanTouch(LocalPlayer(), ent)
			end
		end
	else
		if ent:IsPlayer() then
			CanTouch = true
		else
			CanTouch = DPP.CanTouch(LocalPlayer(), ent)
		end
	end

	local CanDamage, dreason = DPP.CanDamage(LocalPlayer(), ent)

	if dreason and dreason ~= reason and DisplayReason then
		name = name .. '\n' .. dreason
	end

	if DPP.LocalConVar('display_disconnected') and disconnected then
		name = name .. '\n' .. DPP.GetPhrase('disconnected_player')
	end

	if DPP.LocalConVar('display_grabs') and DPP.IsUpForGrabs(ent) then
		name = name .. '\n' .. DPP.GetPhrase('up_for_grabs')
	end

	local get = DPP.GetFont()
	surface.SetFont(get)
	local W, H = surface.GetTextSize(name)
	surface.SetDrawColor(DISPLAY_BACKGROUND_R:GetInt(), DISPLAY_BACKGROUND_G:GetInt(), DISPLAY_BACKGROUND_B:GetInt(), DISPLAY_BACKGROUND_A:GetInt())
	surface.DrawRect(x, y, W + 8, H + 4)

	draw.DrawText(name, get, x + 4, y + 3, CanTouch and Green or Red)

	return W, H
end

local function HUDPaintSimple(x, y)
	x = x or X
	y = y or Y

	local Green = Color(DISPLAY_TOUCH_CAN_R:GetInt(), DISPLAY_TOUCH_CAN_G:GetInt(), DISPLAY_TOUCH_CAN_B:GetInt(), DISPLAY_TOUCH_CAN_A:GetInt())
	local Red = Color(DISPLAY_TOUCH_CANNOT_R:GetInt(), DISPLAY_TOUCH_CANNOT_G:GetInt(), DISPLAY_TOUCH_CANNOT_B:GetInt(), DISPLAY_TOUCH_CANNOT_A:GetInt())

	local ent = traceEntity
	if not IsValid(ent) then return end

	local curWeapon = LocalPlayer():GetActiveWeapon()

	local CanTouch, reason

	local name = DPP.GetOwnerName(ent)

	local Owned, Owner, Nick, UID, SteamID
	local disconnected = false

	if not ent:IsPlayer() then
		Owned = DPP.IsOwned(ent)
		Owner = DPP.GetOwner(ent)
		disconnected = false

		if Owned and not IsValid(Owner) then
			Nick, UID, SteamID = DPP.GetOwnerDetails(ent)
			name = Nick
			disconnected = true
		end
	else
		Owned = false
		Owner = ent
		name = ent:Nick()
	end

	if IsValid(curWeapon) and DPP.GetConVar('enable') then
		local class = curWeapon:GetClass()
		local hit = false

		if class == 'gmod_tool' then
			local mode = curWeapon:GetMode()
			if not mode then return 0, 0 end --Eh
			local CanTouch1, reason = DPP.CanTool(LocalPlayer(), ent, mode)
			CanTouch = CanTouch1 ~= false

			hit = true
		end

		if class == 'weapon_physgun' then
			CanTouch, reason = DPP.CanPhysgun(LocalPlayer(), ent)
			CanTouch = CanTouch ~= false

			hit = true
		end

		if class == 'weapon_physcannon' then
			local status = DPP.IsEntityBlockedGravgun(ent:GetClass(), LocalPlayer())
			CanTouch, reason = DPP.CanGravgun(LocalPlayer(), ent) ~= false and not status

			hit = true
		end

		if not hit then
			if ent:IsPlayer() then
				CanTouch = true
			else
				CanTouch = DPP.CanTouch(LocalPlayer(), ent)
			end
		end
	else
		if ent:IsPlayer() then
			CanTouch = true
		else
			CanTouch = DPP.CanTouch(LocalPlayer(), ent)
		end
	end

	if disconnected then
		name = name .. '\n' .. DPP.GetPhrase('disconnected_player')
	end

	if DPP.IsUpForGrabs(ent) then
		name = name .. '\n' .. DPP.GetPhrase('up_for_grabs')
	end

	local get = DPP.GetFont()
	surface.SetFont(get)
	local W, H = surface.GetTextSize(name)
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(x, y, W + 8, H + 4)

	draw.DrawText(name, get, x + 4, y + 3, CanTouch and Green or Red)

	return W, H
end

local NearWeaponLastW = 0
local NearToolgunLastW = 0

local function DrawNearWeapon(ShiftX)
	ShiftX = ShiftX or (-NearWeaponLastW * 0.1 - 10)
	local model = LocalPlayer():GetViewModel(0)

	local attach = model:LookupAttachment('muzzle')

	if not attach or attach < 0 then return false end

	local Data = model:GetAttachment(attach)
	if not Data then return false end

	local Ang = Data.Ang
	local Pos = Data.Pos

	Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Forward(), -90)
	Ang:RotateAroundAxis(Ang:Up(), -180)

	local Add = Vector(ShiftX, 10, 0)
	Add:Rotate(Ang)

	cam.Start3D()
	cam.Start3D2D(Pos + Add, Ang, 0.1)

	if not DPP.PlayerConVar(nil, 'simple_hud') then
		NearWeaponLastW = PostDrawHUDDefault(0, 0) or NearWeaponLastW
	else
		NearWeaponLastW = HUDPaintSimple(0, 0) or NearWeaponLastW
	end

	cam.End3D2D()
	cam.End3D()
end

local function DrawNearToolgun()
	local model = LocalPlayer():GetViewModel(0)

	local attach = model:LookupAttachment('muzzle')

	if not attach or attach < 0 then return false end

	local Data = model:GetAttachment(attach)
	if not Data then return false end

	local Ang = Data.Ang
	local Pos = Data.Pos

	Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Forward(), -90)

	local Add = Vector(-NearToolgunLastW * 0.1 + 5, 0, -30)
	Add:Rotate(Ang)

	cam.Start3D()
	cam.Start3D2D(Pos + Add, Ang, 0.1)

	if not DPP.PlayerConVar(nil, 'simple_hud') then
		NearToolgunLastW = PostDrawHUDDefault(0, 0) or NearToolgunLastW
	else
		NearToolgunLastW = HUDPaintSimple(0, 0) or NearToolgunLastW
	end

	cam.End3D2D()
	cam.End3D()
end

function HUDPaint()
	local can = hook.Run('CanDrawDPPHUD')
	if can == false then return end

	if DPP.PlayerConVar(nil, 'hide_hud') then return end
	if DPP.GetConVar('disable_huds') and DPP.LocalConVar('hud_obey_server') then return end
	local ply = LocalPlayer()
	if ply:InVehicle() and DPP.PlayerConVar(nil, 'no_hud_in_vehicle') then return end

	if (not DPP.LocalConVar('fancy_hud_obey_server') or not DPP.GetConVar('disable_fancy_displays')) and not ply:ShouldDrawLocalPlayer() and not ply:InVehicle() then
		local AWeapon = ply:GetActiveWeapon()

		if IsValid(AWeapon) then
			if not DPP.PlayerConVar(nil, 'no_physgun_display') and (AWeapon:GetClass() == 'weapon_physgun' or AWeapon:GetClass() == 'weapon_physcannon') then
				if DrawNearWeapon() ~= false then return end
			end

			if not DPP.PlayerConVar(nil, 'no_toolgun_display') and AWeapon:GetClass() == 'gmod_tool' then
				if DrawNearToolgun() ~= false then return end
			end
		end
	end

	local x, y = ScrW() * POSITION_X:GetFloat() / 100, ScrH() * POSITION_Y:GetFloat() / 100

	if not DPP.PlayerConVar(nil, 'simple_hud') then
		PostDrawHUDDefault(x, y)
	else
		HUDPaintSimple(x, y)
	end
end

local LastPanelUpdate = 0

hook.Add('Think', 'DPP.HUDThink', HUDThink)

do
	-- https://github.com/PAC3-Server/notagain/blob/master/lua/notagain/aowl/aowl.lua#L985
	local cleanupPopups = {
		"HURRY!", "FASTER!", "YOU WON'T MAKE IT!",
		"QUICKLY!", "GOD YOU'RE SLOW!", "DID YOU GET EVERYTHING?!",
		"ARE YOU SURE THAT'S EVERYTHING?!", "OH GOD!", "OH MAN!",
		"YOU FORGOT SOMETHING!", "SAVE SAVE SAVE"
	}

	local stressSounds = {
		Sound("vo/ravenholm/exit_hurry.wav"), Sound("vo/npc/Barney/ba_hurryup.wav"),
		Sound("vo/Citadel/al_hurrymossman02.wav"), Sound("vo/Streetwar/Alyx_gate/al_hurry.wav"),
		Sound("vo/ravenholm/monk_death07.wav"), Sound("vo/coast/odessa/male01/nlo_cubdeath02.wav")
	}

	local numberSounds = {
		Sound("npc/overwatch/radiovoice/one.wav"), Sound("npc/overwatch/radiovoice/two.wav"),
		Sound("npc/overwatch/radiovoice/three.wav"), Sound("npc/overwatch/radiovoice/four.wav"),
		Sound("npc/overwatch/radiovoice/five.wav"), Sound("npc/overwatch/radiovoice/six.wav"),
		Sound("npc/overwatch/radiovoice/seven.wav"), Sound("npc/overwatch/radiovoice/eight.wav"),
		Sound("npc/overwatch/radiovoice/nine.wav")
	}

	local popupsPos = {}
	local nextPopup = 0
	local nextStress = 0
	local lastNumber = 0
	local sound
	local popups = {}

	surface.CreateFont('DPP.CleanupPopup', {
		font = 'Roboto',
		size = ScreenSize(20),
		weight = 600
	})

	surface.CreateFont('DPP.CleanupTime', {
		font = 'Roboto',
		size = ScreenSize(15),
		weight = 600
	})

	DPP.CLEAN_UP = false
	DPP.CLEAN_UP_START = CurTime() - 30
	DPP.CLEAN_UP_END = CurTime() + 30

	local function HUDPaintCleanup()
		if not DPP.CLEAN_UP then return end
		local WIDTH = ScreenSize(140)
		local x, y = ScrW() / 2, ScreenSize(20)
		surface.SetDrawColor(140, 140, 140)
		surface.DrawRect(x - WIDTH / 2, y, WIDTH, ScreenSize(15))

		surface.SetDrawColor(240, 240, 240)
		local nw = WIDTH * (1 - CurTime():progression(DPP.CLEAN_UP_START, DPP.CLEAN_UP_END))
		surface.DrawRect(x - WIDTH / 2, y, nw, ScreenSize(15))

		local timeleft = DLib.string.tformat(DPP.CLEAN_UP_END - CurTime())
		surface.SetFont('DPP.CleanupTime')

		local w, h = surface.GetTextSize(DPP.GetPhrase('cleanup_initated'))
		surface.SetTextPos(x - w / 2, y - ScreenSize(16))
		surface.SetTextColor(230, 230, 230)
		surface.DrawText(DPP.GetPhrase('cleanup_initated'))

		w, h = surface.GetTextSize(timeleft)

		render.PushScissorRect(x - WIDTH / 2, y, x - WIDTH / 2 + nw, y + ScreenSize(15))
		surface.SetTextPos(x - w / 2, y)
		surface.SetTextColor(0, 0, 0)
		surface.DrawText(timeleft)
		render.PopScissorRect()

		render.PushScissorRect(x - WIDTH / 2 + nw, y, x + WIDTH, y + ScreenSize(15))
		surface.SetTextPos(x - w / 2, y)
		surface.SetTextColor(255, 255, 255)
		surface.DrawText(timeleft)
		render.PopScissorRect()

		surface.SetFont('DPP.CleanupPopup')
		surface.SetTextColor(255, 255, 255)

		for i = 1, 6 do
			if popupsPos[i] then
				surface.SetTextPos(popupsPos[i][1], popupsPos[i][2])
				surface.DrawText(popups[i])
			end
		end
	end

	local function CleanupThink()
		if not DPP.CLEAN_UP then
			if sound then
				sound:Stop()
				sound = nil
			end

			return
		end

		if not sound then
			sound = CreateSound(LocalPlayer(), Sound("ambient/alarms/siren.wav"))
		end

		local time = RealTime()

		if nextStress < time then
			nextStress = time + math.random(0.5, 1.25)
			LocalPlayer():EmitSound(stressSounds[math.random(1, #stressSounds)], 60, 100, 0.7)
		end

		if nextPopup < time then
			nextPopup = time + 0.5
			local w, h = ScrW() - ScreenSize(200), ScrH()

			for i = 1, 6 do
				popups[i] = cleanupPopups[math.random(1, #cleanupPopups)]
				popupsPos[i] = {math.random(0, w), math.random(0, h)}
			end
		end
	end

	hook.Add('HUDPaint', 'DPP.CleanupEffects', HUDPaintCleanup)
	hook.Add('Think', 'DPP.CleanupEffects', CleanupThink)
end

local LastSound = 0

function DPP.Notify(message, Type)
	if LastSound < CurTime() then
		if Type == NOTIFY_ERROR then
			surface.PlaySound('buttons/button10.wav')
		elseif Type == NOTIFY_UNDO then
			surface.PlaySound('buttons/button15.wav')
		else
			surface.PlaySound('npc/turret_floor/click1.wav')
		end
		LastSound = CurTime() + 0.1
	end

	if istable(message) then
		DPP.Message(unpack(message))

		local str = ''

		for k, v in pairs(message) do
			if type(v) == 'string' then
				if v:sub(1, 6) ~= '<STEAM' then
					str = str .. v
				end
			end
		end

		notification.AddLegacy(str, Type, 5)
	else
		DPP.Message(message)
		notification.AddLegacy(message, Type, 5)
	end
end

net.Receive('DPP.Notify', function()
	DPP.Notify(DPP.PreprocessPhrases(unpack(DPP.ReadMessageTable())), net.ReadUInt(6))
end)

net.Receive('DPP.Echo', function()
	DPP.Message(unpack(DPP.ReadMessageTable()))
end)

net.Receive('DPP.PlayerList', function()
	DPP.PlayerList = net.ReadTable()
	hook.Run('DPP.PlayerListChanged', DPP.PlayerList)
end)

net.Receive('DPP.Log', function()
	DPP.Message(unpack(DPP.ReadMessageTable()))
end)

net.Receive('DPP.SendConstrainedWith', function()
	local ent = net.ReadEntity()
	local tab = net.ReadTable()
	if not IsValid(ent) then
		timer.Simple(3, function()
			if not IsValid(ent) then return end
			ent.DPP_ConstrainedWith = tab
		end)
	else
		ent.DPP_ConstrainedWith = tab
	end
end)

net.Receive('DPP.InspectEntity', function()
	DPP.Notify(DPP.PreprocessPhrases('#look_into_console'), NOTIFY_GENERIC)

	local ply = LocalPlayer()
	local tr = util.TraceLine{
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:EyeAngles():Forward() * 32000,
		mask = MASK_ALL,
		filter = ply
	}

	DPP.Message('#inspect_client')

	local ent = tr.Entity

	if not IsValid(ent) then
		DPP.Message('#inspect_noentity')
	else
		DPP.Message('#inspect_class', color_white, ent:GetClass())
		DPP.Message('#inspect_pos', color_white, DPP.ToString(ent:GetPos()))
		DPP.Message('#inspect_ang', color_white, DPP.ToString(ent:GetAngles()))
		DPP.Message('#inspect_table', color_white, DPP.ToString(table.Count(ent:GetTable())))
		DPP.Message('#inspect_hp', color_white, DPP.ToString(ent:Health()))
		DPP.Message('#inspect_mhp', color_white, DPP.ToString(ent:GetMaxHealth()))
		DPP.Message('#inspect_owner', color_white, DPP.ToString(DPP.GetOwner(ent)))

		DPP.Message('#inspect_model', color_white, DPP.ToString(ent:GetModel()))
		DPP.Message('#inspect_skin', color_white, DPP.ToString(ent:GetSkin()))
		DPP.Message('#inspect_bodygroups', color_white, DPP.ToString(table.Count(ent:GetBodyGroups() or {})))
	end
end)

local SelectedEntity

local function PropMenu(ent, tr)
	local menu = DermaMenu()

	local ply = LocalPlayer()

	for k, v in SortedPairsByMemberValue(properties.List, "Order") do
		if not isfunction(v.Filter) then continue end

		if not v:Filter(ent, ply) then continue end

		if DPP.CanProperty(ply, k, ent) == false then continue end

		local option = DPP.PropertyMenuAddOption(v, menu, ent, ply, tr)
		SelectedEntity = ent
		if isfunction(v.OnCreate) then v:OnCreate(menu, option) end
	end

	menu:Open()
end

function DPP.ReplacePropertyFuncs()
	if not properties then return end
	DPP.Message('Overriding property functions')

	local Name, Value = debug.getupvalue(properties.OpenEntityMenu, 1)

	if Name == 'AddOption' and isfunction(Value) then
		DPP.PropertyMenuAddOption = Value
	end

	if DPP.PropertyMenuAddOption then
		DPP._OldPropertiesOpenEntityMenu = DPP._OldPropertiesOpenEntityMenu or properties.OpenEntityMenu
		properties.OpenEntityMenu = function(...)
			if DPP.GetConVar('strict_property') then
				PropMenu(...)
			else
				DPP._OldPropertiesOpenEntityMenu(...)
			end
		end

		local Name, Value = debug.getupvalue(properties.Add, 1)
		if Name == 'meta' and istable(Value) then
			DPP.__oldPropertyMsgStart = DPP.__oldPropertyMsgStart or Value.MsgStart
			Value.MsgStart = function(self)
				if DPP.GetConVar('strict_property') then
					local ent = SelectedEntity
					if not IsValid(ent) then return end

					net.Start("properties_dpp")
					net.WriteString(self.InternalName)
					net.WriteEntity(ent)
				else
					DPP.__oldPropertyMsgStart(self)
				end
			end
		end

		DPP.Message('Overrided property menu successfully')
	else
		DPP.Message('Failed to override property menu')
	end
end

concommand.Add('dpp_printmissingphrases', function(_, _, args)
	DPP.PrintMissingPhrases(args[1] or DPP.CURRENT_LANG)
end)
