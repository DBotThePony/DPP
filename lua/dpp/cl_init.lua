
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
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

DPP.FriendsSQLTable = [[
	CREATE TABLE IF NOT EXISTS dpp_friends
	(
		STEAMID VARCHAR(32) NOT NULL,
		NICKNAME VARCHAR(64) NOT NULL,
		MODES VARCHAR(255) NOT NULL,
		PRIMARY KEY (STEAMID)
	)
]]

sql.Query(DPP.FriendsSQLTable)

DPP.ClientFriends = {}
DPP.ActiveFriends = {}
DPP.FriendsCPPI = {}

function DPP.GetFriendTable(ply)
	LocalPlayer().DPP_Friends = DPP.ActiveFriends
	return ply.DPP_Friends or {}
end

function DPP.GetLocalFriends()
	return DPP.ClientFriends
end

function DPP.GetActiveFriends()
	return DPP.ActiveFriends
end

function DPP.ClientConVarChanged(var, old, new)
	var = string.sub(var, 5)

	if DPP.CSettings[var].nosend then return end

	net.Start('DPP.ConVarChanged')
	net.WriteString(var)
	net.SendToServer()
end

function DPP.RefreshFriends()
	if not IsValid(LocalPlayer()) then return end
	DPP.ActiveFriends = {}

	for k, v in pairs(DPP.ClientFriends) do
		local ply = player.GetBySteamID(k)
		if not ply then continue end
		DPP.ActiveFriends[ply] = {}
		table.Merge(DPP.ActiveFriends[ply], v)
		DPP.ActiveFriends[ply].steamid = k
		DPP.ActiveFriends[ply].nick = ply:Nick()
		DPP.ClientFriends[k].nick = ply:Nick()
	end

	LocalPlayer().DPP_Friends = DPP.ActiveFriends

	DPP.Message(DPP.GetPhrase('friends_refreshed'))
	return DPP.ActiveFriends
end

function DPP.RecalculateCPPIFriendTable(ply)
	ply.DPP_Friends = ply.DPP_Friends or {}
	local tab = ply.DPP_Friends
	tab = tab or {}
	local reply = {}
	for k, v in pairs(tab) do
		table.insert(reply, k)
	end
	ply.DPP_FriendsCPPI = reply
	if ply == LocalPlayer() then
		DPP.FriendsCPPI = reply
	end
	return reply
end

function DPP.GetFriendTableCPPI(ply)
	return ply.DPP_FriendsCPPI or {}
end

function DPP.GetOwnerName(ent)
	local owner = DPP.GetOwner(ent)
	if not IsValid(owner) then return 'World' end
	if not owner:IsPlayer() then return owner:GetClass() end
	return owner:Nick()
end

function DPP.CheckFriendArgs(t)
	if t.physgun == nil then t.physgun = true end
	if t.gravgun == nil then t.gravgun = true end
	if t.toolgun == nil then t.toolgun = true end
	if t.use == nil then t.use = true end
	if t.vehicle == nil then t.vehicle = true end
	if t.damage == nil then t.damage = true end
	if t.pickup == nil then t.pickup = true end
end

function DPP.LoadFriends()
	local FILE = 'dpp/friends.txt'
	local out = {}
	
	if file.Exists(FILE, 'DATA') then
		local content = file.Read(FILE, 'DATA')
		local parse = util.JSONToTable(content)
		
		if parse then
			for k, v in pairs(parse) do
				DPP.SaveFriendData(k, v)
			end
		end
		
		file.Delete(FILE)
	end
	
	local reply = sql.Query('SELECT * FROM dpp_friends')
	
	for i, row in ipairs(reply or {}) do
		out[row.STEAMID] = {
			nick = row.NICKNAME,
		}
		
		local decode = util.JSONToTable(row.MODES)
		
		if decode then
			table.Merge(out[row.STEAMID], decode)
		end
	end
	
	DPP.ClientFriends = out
	
	for k, v in pairs(out) do
		DPP.CheckFriendArgs(v)
	end
	
	DPP.Message(DPP.GetPhrase('friends_loaded'))
	timer.Simple(0, DPP.RefreshFriends)
	
	return out
end

timer.Simple(0, DPP.LoadFriends)

function DPP.SaveFriends()
	sql.Query('DELETE FROM dpp_friends')
	
	for k, v in pairs(DPP.ClientFriends) do
		DPP.SaveFriendData(k, v)
	end
end

function DPP.SaveFriendData(steamid, tab)
	local validModes = table.Copy(tab)
	validModes.nick = nil
	
	sql.Query(string.format('REPLACE INTO dpp_friends (STEAMID, NICKNAME, MODES) VALUES (%s, %s, %s)', SQLStr(steamid), SQLStr(tab.nick or 'unknown'), SQLStr(util.TableToJSON(validModes))))
end

function DPP.SaveFriend(steamid)
	DPP.SaveFriendData(steamid, DPP.ClientFriends[steamid])
end

function DPP.SendFriends()
	DPP.RefreshFriends()
	DPP.Message(DPP.GetPhrase('friends_sended'))
	net.Start('DPP.ReloadFiendList')
	net.WriteTable(DPP.ActiveFriends)
	net.SendToServer()
end

function DPP.AddFriend(ply, physgun, gravgun, toolgun, use, vehicle, damage, pickup)
	if ply == LocalPlayer() then return end

	local steamid = ply:SteamID()

	if not istable(physgun) then
		DPP.ClientFriends[steamid] = {
			physgun = physgun,
			gravgun = gravgun,
			toolgun = toolgun,
			use = use,
			vehicle = vehicle,
			damage = damage,
			pickup = pickup,
			nick = ply:Nick(),
		}
	else
		DPP.ClientFriends[steamid] = {
			nick = ply:Nick(),
		}

		table.Merge(DPP.ClientFriends[steamid], physgun)
	end

	DPP.CheckFriendArgs(DPP.ClientFriends[steamid])

	DPP.Message(DPP.GetPhrase('friend_added'))

	DPP.RecalculateCPPIFriendTable(LocalPlayer())
	hook.Run('CPPIFriendsChanged', LocalPlayer(), DPP.FriendsCPPI)
	DPP.SaveFriend(steamid)
	DPP.SendFriends()

	hook.Run('DPP.FriendsChanged')
end

function DPP.AddFriendBySteamID(steamid, physgun, gravgun, toolgun, use, vehicle, damage, pickup)
	steamid = string.upper(steamid)

	local ply = player.GetBySteamID(steamid)
	local oldNick = DPP.ClientFriends[steamid] and DPP.ClientFriends[steamid].nick or ''

	if not istable(physgun) then
		DPP.ClientFriends[steamid] = {
			physgun = physgun,
			gravgun = gravgun,
			toolgun = toolgun,
			use = use,
			vehicle = vehicle,
			damage = damage,
			pickup = pickup,
			nick = ply and ply:Nick() or oldNick,
		}
	else
		DPP.ClientFriends[steamid] = {
			nick = ply and ply:Nick() or oldNick,
		}

		table.Merge(DPP.ClientFriends[steamid], physgun)
	end

	DPP.CheckFriendArgs(DPP.ClientFriends[steamid])

	DPP.Message(DPP.GetPhrase('friend_added'))

	DPP.RecalculateCPPIFriendTable(LocalPlayer())
	hook.Run('CPPIFriendsChanged', LocalPlayer(), DPP.FriendsCPPI)
	DPP.SaveFriend(steamid)
	DPP.SendFriends()

	hook.Run('DPP.FriendsChanged')
end

function DPP.RemoveFriend(ply)
	if ply == LocalPlayer() then return end
	local steamid = ply:SteamID()
	if not DPP.ClientFriends[steamid] then
		DPP.Message(DPP.GetPhrase('no_friend_with_steamid', steamid))
		return
	end

	DPP.ClientFriends[steamid] = nil
	DPP.Message(DPP.GetPhrase('friend_removed', steamid))

	DPP.RecalculateCPPIFriendTable(LocalPlayer())
	hook.Run('CPPIFriendsChanged', LocalPlayer(), DPP.FriendsCPPI)
	sql.Query(string.format('DELETE FROM dpp_friends WHERE STEAMID = %s', SQLStr(steamid)))
	DPP.SendFriends()

	hook.Run('DPP.FriendsChanged')
end

function DPP.RemoveFriendBySteamID(steamid)
	if ply == LocalPlayer() then return end
	if not DPP.ClientFriends[steamid] then
		DPP.Message(DPP.GetPhrase('no_friend_with_steamid', steamid))
		return
	end

	DPP.ClientFriends[steamid] = nil
	DPP.Message(DPP.GetPhrase('friend_removed', steamid))

	DPP.RecalculateCPPIFriendTable(LocalPlayer())
	hook.Run('CPPIFriendsChanged', LocalPlayer(), DPP.FriendsCPPI)
	sql.Query(string.format('DELETE FROM dpp_friends WHERE STEAMID = %s', SQLStr(steamid)))
	DPP.SendFriends()

	hook.Run('DPP.FriendsChanged')
end

local function ArgBool(val)
	if val == nil then return true end

	local n = tonumber(val)
	if not n then return true end

	if n <= 0 then return false end
	return true
end

concommand.Add('dpp_addfriend', function(ply, cmd, args)
	if not args[1] then
		DPP.Message(DPP.GetPhrase('com_invalid_target'))
		return
	end

	local ply = string.lower(args[1])

	if string.sub(ply, 1, 5) == 'steam' then
		ply = string.upper(args[1])
		DPP.AddFriendBySteamID(ply, ArgBool(args[2]), ArgBool(args[3]), ArgBool(args[4]), ArgBool(args[5]), ArgBool(args[6]), ArgBool(args[7]), ArgBool(args[8]))
		return
	end

	local found

	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), ply) then
			found = v
		end
	end

	if not found then
		DPP.Message(DPP.GetPhrase('com_no_target'))
		return
	end

	DPP.AddFriend(found, ArgBool(args[2]), ArgBool(args[3]), ArgBool(args[4]), ArgBool(args[5]), ArgBool(args[6]), ArgBool(args[7]), ArgBool(args[8]))
end)

concommand.Add('dpp_remfriend', function(ply, cmd, args)
	if not args[1] then
		DPP.Message(DPP.GetPhrase('com_invalid_target'))
		return
	end

	local ply = string.lower(args[1])

	if string.sub(ply, 1, 5) == 'steam' then
		ply = string.upper(args[1])
		DPP.RemoveFriendBySteamID(ply)
		return
	end

	local found

	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), ply) then
			found = v
		end
	end

	if not found then
		DPP.Message(DPP.GetPhrase('com_no_target'))
		return
	end

	DPP.RemoveFriend(found)
end)

concommand.Add('dpp_importfppbuddies', function(ply)
	local friends = sql.Query('SELECT * FROM `FPP_Buddies`')
	
	if not friends then return end
	
	for k, row in ipairs(friends) do
		local steamid = row.steamid
		
		if DPP.ClientFriends[steamid] then
			continue
		end
		
		DPP.ClientFriends[steamid] = {
			use = tobool(row.playeruse),
			toolgun = tobool(row.toolgun),
			physgun = tobool(row.physgun),
			gravgun = tobool(row.gravgun),
			damage = tobool(row.entitydamage),
			nick = row.name or '<FPP Buddy>',
		}
		
		DPP.CheckFriendArgs(DPP.ClientFriends[steamid])
		
		DPP.SaveFriend(steamid)
		DPP.Message(DPP.GetPhrase('friend_added_fpp', row.name or steamid))
	end
	
	DPP.Message(DPP.GetPhrase('friend_added'))

	DPP.RecalculateCPPIFriendTable(LocalPlayer())
	hook.Run('CPPIFriendsChanged', LocalPlayer(), DPP.FriendsCPPI)
	DPP.SendFriends()

	hook.Run('DPP.FriendsChanged')
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

local fov, zfar, znear

hook.Add('CalcView', 'DPP.checkCalcView', function(ply, _, _, fov2, zfar2, znear2)
	fov, zfar, znear = fov2, zfar2, znear2
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

local function HUDThink()
	local epos, eang
	local ignoreNearest = false
	local ply = SelectPlayer()
	
	if ply:ShouldDrawLocalPlayer() then
		local view = hook.Run('CalcView', ply, ply:EyePos(), ply:EyeAngles(), fov, zfar, znear)
		epos = view.origin or ply:EyePos()
		eang = view.angles or ply:EyeAngles()
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
	
	local tr = util.TraceLine{
		mask = MASK_ALL,
		filter = function(hitEntity)
			if not hitEntity:IsValid() then return true end
			if not ignoreNearest and hitEntity == ply then return false end
			if ignoreNearest and (pointInsideBox(epos, hitEntity:WorldSpaceAABB()) or epos:DistToSqr(hitEntity:GetPos()) < 400) then return false end
			
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

	local Owned
	local isPly = false
	local Owne
	local Nick, UID, SteamID
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

	local Owned
	local Owne
	local Nick, UID, SteamID
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

	if not attach or attach == 0 then return end

	local Data = model:GetAttachment(attach)
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

	if not attach or attach == 0 then return end

	local Data = model:GetAttachment(attach)
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

local LastRenderFrame = 0

if IsValid(DPP.ScreenshotPanelHack) then
	DPP.ScreenshotPanelHack:Remove()
end

local function HUDPaint()
	local can = hook.Run('CanDrawDPPHUD')
	if can == false then return end

	if DPP.PlayerConVar(nil, 'hide_hud') then return end
	if DPP.GetConVar('disable_huds') and DPP.LocalConVar('hud_obey_server') then return end
	if LocalPlayer():InVehicle() and DPP.PlayerConVar(nil, 'no_hud_in_vehicle') then return end

	local AWeapon = LocalPlayer():GetActiveWeapon()

	if IsValid(AWeapon) then
		if not DPP.PlayerConVar(nil, 'no_physgun_display') and (AWeapon:GetClass() == 'weapon_physgun' or AWeapon:GetClass() == 'weapon_physcannon') then
			DrawNearWeapon()
			return
		end

		if not DPP.PlayerConVar(nil, 'no_toolgun_display') and AWeapon:GetClass() == 'gmod_tool' then
			DrawNearToolgun()
			return
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

local function CreateFix()
	if IsValid(DPP.ScreenshotPanelHack) then
		if LastPanelUpdate > CurTime() then return end
		LastPanelUpdate = CurTime() + 1
		DPP.ScreenshotPanelHack:SetSize(ScrW(), ScrH())
		DPP.ScreenshotPanelHack:SetPos(0, 0)
		DPP.ScreenshotPanelHack:SetRenderInScreenshots(DPP.LocalConVar('draw_in_screenshots', false))
		return
	end
	
	local newPnl = vgui.Create('EditablePanel')
	DPP.ScreenshotPanelHack = newPnl
	newPnl:SetRenderInScreenshots(false)
	newPnl:SetSize(ScrW(), ScrH())
	newPnl:SetPos(0, 0)
	newPnl:SetMouseInputEnabled(false)
	newPnl:SetKeyboardInputEnabled(false)
	newPnl:KillFocus()
	newPnl:SetVisible(true)
	newPnl.Paint = HUDPaint
end

hook.Add('Think', 'DPP.HUDThink', HUDThink)

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
				if v:sub(1, 6) == '<STEAM' then
					continue
				end
				
				str = str .. v
			end
		end

		notification.AddLegacy(str, Type, 5)
	else
		DPP.Message(message)
		notification.AddLegacy(message, Type, 5)
	end
end

net.Receive('DPP.ReloadFiendList', function()
	DPP.SendFriends()
	hook.Run('DPP.FriendsChanged')
end)

net.Receive('DPP.Notify', function()
	DPP.Notify(DPP.PreprocessPhrases(unpack(DPP.ReadMessageTable())), net.ReadUInt(6))
end)

net.Receive('DPP.Echo', function()
	DPP.Message(unpack(DPP.ReadMessageTable()))
end)

net.Receive('DPP.PlayerList', function()
	DPP.PlayerList = net.ReadTable()

	hook.Run('DPP.PlayerListChanged', DPP.PlayerList)
	if not DPP.PlayerConVar(_, 'no_load_messages') then DPP.Message('Player list changed, reloading') end
end)

net.Receive('DPP.ConstrainedTable', function()
	local Ents = net.ReadTable()
	local Owners = net.ReadTable()

	for k, v in pairs(Ents) do
		if IsValid(v) then
			v._DPP_Constrained = Owners
		end
	end
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

net.Receive('DPP.ReceiveFriendList', function()
	local ply = net.ReadEntity()
	if ply == LocalPlayer() then return end
	ply.DPP_Friends = net.ReadTable()

	DPP.RecalculateCPPIFriendTable(ply)
	hook.Run('CPPIFriendsChanged', ply, DPP.GetFriendTableCPPI(ply))
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

hook.Add('HUDPaint', 'DPP.Hooks', CreateFix)

concommand.Add('dpp_printmissingphrases', function(_, _, args)
	DPP.PrintMissingPhrases(args[1] or DPP.CURRENT_LANG)
end)
