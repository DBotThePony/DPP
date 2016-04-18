
--Client

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
	
	DPP.Message('Friendlist refreshed')
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
end

function DPP.LoadFriends()
	local FILE = 'dpp/friends.txt'
	local content = file.Read(FILE, 'DATA')
	
	local out
	if not content or content == '' then
		out = {}
		file.Write(FILE, util.TableToJSON(out))
	else
		out = util.JSONToTable(content)
		if not out then --Corrupt
			out = {}
			file.Write(FILE, util.TableToJSON(out))
		end
	end
	
	DPP.ClientFriends = out
	
	for k, v in pairs(out) do
		DPP.CheckFriendArgs(v)
	end
	
	DPP.Message('Friendlist loaded...')
	timer.Simple(0, DPP.RefreshFriends)
end

timer.Simple(0, DPP.LoadFriends)

function DPP.SaveFriends()
	local FILE = 'dpp/friends.txt'
	local contents = util.TableToJSON(DPP.ClientFriends, true)
	file.Write(FILE, contents)
	DPP.Message('Friendlist saved...')
end

function DPP.SendFriends()
	DPP.RefreshFriends()
	DPP.Message('Sending Friendlist to server')
	net.Start('DPP.ReloadFiendList')
	net.WriteTable(DPP.ActiveFriends)
	net.SendToServer()
end

function DPP.AddFriend(ply, physgun, gravgun, toolgun, use, vehicle, damage)
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
			nick = ply:Nick(),
		}
	else
		DPP.ClientFriends[steamid] = {
			nick = ply:Nick(),
		}
		
		table.Merge(DPP.ClientFriends[steamid], physgun)
	end
	
	DPP.CheckFriendArgs(DPP.ClientFriends[steamid])
	
	DPP.Message('Friend added')
	
	DPP.RecalculateCPPIFriendTable(LocalPlayer())
	hook.Run('CPPIFriendsChanged', LocalPlayer(), DPP.FriendsCPPI)
	DPP.SaveFriends()
	DPP.SendFriends()
	
	hook.Run('DPP.FriendsChanged')
end

function DPP.AddFriendBySteamID(steamid, physgun, gravgun, toolgun, use, vehicle, damage)
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
			nick = ply and ply:Nick() or oldNick,
		}
	else
		DPP.ClientFriends[steamid] = {
			nick = ply and ply:Nick() or oldNick,
		}
		
		table.Merge(DPP.ClientFriends[steamid], physgun)
	end
	
	DPP.CheckFriendArgs(DPP.ClientFriends[steamid])
	
	DPP.Message('Friend added')
	
	DPP.RecalculateCPPIFriendTable(LocalPlayer())
	hook.Run('CPPIFriendsChanged', LocalPlayer(), DPP.FriendsCPPI)
	DPP.SaveFriends()
	DPP.SendFriends()
	
	hook.Run('DPP.FriendsChanged')
end

function DPP.RemoveFriend(ply)
	if ply == LocalPlayer() then return end
	local steamid = ply:SteamID()
	if not DPP.ClientFriends[steamid] then
		DPP.Message('There is no friend with id ' .. steamid .. '!')
		return
	end
	
	DPP.ClientFriends[steamid] = nil
	DPP.Message('Friend with id ' .. steamid .. ' removed')
	
	DPP.RecalculateCPPIFriendTable(LocalPlayer())
	hook.Run('CPPIFriendsChanged', LocalPlayer(), DPP.FriendsCPPI)
	DPP.SaveFriends()
	DPP.SendFriends()
	
	hook.Run('DPP.FriendsChanged')
end

function DPP.RemoveFriendBySteamID(steamid)
	if ply == LocalPlayer() then return end
	if not DPP.ClientFriends[steamid] then
		DPP.Message('There is no friend with id ' .. steamid .. '!')
		return
	end
	
	DPP.ClientFriends[steamid] = nil
	DPP.Message('Friend with id ' .. steamid .. ' removed')
	
	DPP.RecalculateCPPIFriendTable(LocalPlayer())
	hook.Run('CPPIFriendsChanged', LocalPlayer(), DPP.FriendsCPPI)
	DPP.SaveFriends()
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
		DPP.Message('Invalid argument')
		return
	end
	
	local ply = string.lower(args[1])
	
	if string.sub(ply, 1, 5) == 'steam' then
		ply = string.upper(args[1])
		DPP.AddFriendBySteamID(ply, ArgBool(args[2]), ArgBool(args[3]), ArgBool(args[4]), ArgBool(args[5]), ArgBool(args[6]), ArgBool(args[7]))
		return
	end
	
	local found
	
	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), ply) then
			found = v
		end
	end
	
	if not found then
		DPP.Message('Invalid argument')
		return
	end
	
	DPP.AddFriend(found, ArgBool(args[2]), ArgBool(args[3]), ArgBool(args[4]), ArgBool(args[5]), ArgBool(args[6]), ArgBool(args[7]))
end)

concommand.Add('dpp_remfriend', function(ply, cmd, args)
	if not args[1] then
		DPP.Message('Invalid argument')
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
		DPP.Message('Invalid argument')
		return
	end
	
	DPP.RemoveFriend(found)
end)

local X, Y = 0, ScrH() / 2
local DEFAULT_FONT = 'DPP.FONT'
local Green = Color(40, 255, 51)
local Red = Color(255, 51, 0)

surface.CreateFont(DEFAULT_FONT, {
	font = 'Roboto',
	size = 18,
	weight = 500,
})

surface.CreateFont('DPP.Arial', {
	font = 'Arial',
	size = 16,
	weight = 1000,
})

surface.CreateFont('DPP.Terminal', {
	font = 'Terminal',
	size = 16,
	weight = 1000,
})

surface.CreateFont('DPP.Time', {
	font = 'Time',
	size = 18,
	weight = 1200,
})

surface.CreateFont('DPP.System', {
	font = 'System',
	size = 16,
	weight = 1000,
})

surface.CreateFont('DPP.OpenSans', {
	font = 'Open Sans',
	size = 18,
	weight = 400,
})

surface.CreateFont('DPP.MSSans', {
	font = 'Microsoft Sans',
	size = 16,
	weight = 1000,
})

surface.CreateFont('DPP.LBiolinumG', {
	font = 'Linux Biolinum G',
	size = 16,
	weight = 600,
})

surface.CreateFont('DPP.ComicSans', {
	font = 'Comic Sans MS',
	size = 20,
	weight = 1000,
})

surface.CreateFont('DPP.Impact', {
	font = 'Impact',
	size = 20,
	weight = 500,
})

surface.CreateFont('DPP.TNR', {
	font = 'Times New Roman',
	size = 20,
	weight = 500,
})

surface.CreateFont('DPP.UbuntuLight', {
	font = 'Ubuntu Light',
	size = 20,
	weight = 500,
})

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
	surface.CreateFont('DPP.' .. k, {
		font = v,
		size = 18,
		weight = 500,
	})
	
	table.insert(DPP.Fonts, {id = 'DPP.' .. k, name = v})
end

function DPP.GetFont(name)
	local var = DPP.PlayerConVar(LocalPlayer(), 'font')
	
	if not DPP.Fonts[var] then return DEFAULT_FONT end
	
	if not name then
		return DPP.Fonts[var].id
	else
		return DPP.Fonts[var].name
	end
end

local function PostDrawHUDDefault()
	local ent = LocalPlayer():GetEyeTrace().Entity
	if not IsValid(ent) then return end
	--if ent:IsPlayer() then return end
	
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
	
	name = name .. '\n' .. string.format('%s<%s>\n%s', ent:GetClass(), tostring(ent), ent:IsPlayer() and ent:Nick() or ent:IsWeapon() and ent:GetPrintName() or ent.PrintName or '')
	
	if IsValid(curWeapon) and DPP.GetConVar('enable') then
		local class = curWeapon:GetClass()
		local hit = false
		
		if class == 'gmod_tool' then
			local CanTouch1, reason = DPP.CanTool(LocalPlayer(), ent, curWeapon:GetMode())
			CanTouch = CanTouch1 ~= false
			
			if reason and reason ~= 'Not a friend of owner/constrained' then
				name = name .. '\n' .. reason
			end
			
			hit = true
		end
		
		if class == 'weapon_physgun' then
			CanTouch, reason = DPP.CanPhysgun(LocalPlayer(), ent)
			CanTouch = CanTouch ~= false
			
			if DPP.GetConVar('enable_physgun') then
				if status then
					name = name .. '\nPhysgun blocked'
				end
			else
				CanTouch = true
			end
			
			if reason and reason ~= 'Not a friend of owner/constrained' then
				name = name .. '\n' .. reason
			end
			
			hit = true
		end
		
		if class == 'weapon_physcannon' then
			CanTouch, reason = DPP.CanGravgun(LocalPlayer(), ent)
			
			CanTouch = CanTouch ~= false
			
			if DPP.GetConVar('enable_gravgun') then
				if status then
					name = name .. '\nGravgun blocked'
				end
			else
				CanTouch = true
			end
			
			if reason and reason ~= 'Not a friend of owner/constrained' then
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
	
	if dreason and dreason ~= reason then
		name = name .. '\n' .. dreason
	end
	
	if disconnected then
		name = name .. '\nDisconnected Player'
	end
	
	if DPP.IsUpForGrabs(ent) then
		name = name .. '\nUp for grabs!'
	end
	
	local get = DPP.GetFont()
	surface.SetFont(get)
	local W, H = surface.GetTextSize(name)
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(X, Y, W + 8, H + 4)

	--surface.SetTextPos(X + 2, Y + 3)
	--surface.SetTextColor(CanTouch and Green or Red)
	--surface.DrawText(name)
	if CanTouch then
		draw.DrawText(name, get, X + 4, Y + 3, Green)
	else
		draw.DrawText(name, get, X + 4, Y + 3, Red)
	end
end

local function HUDPaintSimple()
	local ent = LocalPlayer():GetEyeTrace().Entity
	if not IsValid(ent) then return end
	--if ent:IsPlayer() then return end
	
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
			local CanTouch1, reason = DPP.CanTool(LocalPlayer(), ent, curWeapon:GetMode())
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
		name = name .. '\nDisconnected Player'
	end
	
	if DPP.IsUpForGrabs(ent) then
		name = name .. '\nUp for grabs!'
	end
	
	local get = DPP.GetFont()
	surface.SetFont(get)
	local W, H = surface.GetTextSize(name)
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(X, Y, W + 8, H + 4)

	
	if CanTouch then
		draw.DrawText(name, get, X + 4, Y + 3, Green)
	else
		draw.DrawText(name, get, X + 4, Y + 3, Red)
	end
end

local function HUDPaint()
	if DPP.PlayerConVar(_, 'hide_hud') then return end
	if LocalPlayer():InVehicle() and DPP.PlayerConVar(_, 'no_hud_in_vehicle') then return end
	if not DPP.PlayerConVar(_, 'simple_hud') then
		PostDrawHUDDefault()
	else
		HUDPaintSimple()
	end
end

hook.Add('HUDPaint', 'DPP.Hooks', HUDPaint)

local LastSound = 0

function DPP.Notify(message, type)
	if LastSound < CurTime() then
		if type == NOTIFY_ERROR then
			surface.PlaySound("buttons/button10.wav")
		elseif type == NOTIFY_UNDO then
			surface.PlaySound("buttons/button15.wav")
		else
			surface.PlaySound("ambient/water/drip" .. math.random(1, 4) .. ".wav")
		end
		LastSound = CurTime() + 0.1
	end
	
	if istable(message) then
		DPP.Message(unpack(message))
	
		local str = ''
		for k, v in pairs(message) do
			if isstring(v) then str = str .. v end
		end
		notification.AddLegacy(str, type, 5)
	else
		DPP.Message(message)
		notification.AddLegacy(message, type, 5)
	end
end

net.Receive('DPP.ReloadFiendList', function()
	DPP.SendFriends()
	hook.Run('DPP.FriendsChanged')
end)

net.Receive('DPP.Notify', function()
	DPP.Notify(net.ReadTable(), net.ReadUInt(6))
end)

net.Receive('DPP.Lists', function()
	local str = net.ReadString()
	DPP.BlockedEntities[str] = net.ReadTable()
	
	hook.Run('DPP.BlockedEntitiesReloaded', str, DPP.BlockedEntities[str])
	DPP.Message('Blacklist "' .. str .. '" received from server, reloading')
end)

net.Receive('DPP.WLists', function()
	local str = net.ReadString()
	DPP.WhitelistedEntities[str] = net.ReadTable()
	
	hook.Run('DPP.WhitelistedEntitiesReloaded', str, DPP.WhitelistedEntities[str])
	DPP.Message('Whitelist "' .. str .. '" received from server, reloading')
end)

net.Receive('DPP.RLists', function()
	local str = net.ReadString()
	DPP.RestrictedTypes[str] = net.ReadTable()
	
	hook.Run('DPP.RestrictedTypesReloaded', str, DPP.RestrictedTypes[str])
	DPP.Message('Restricted list "' .. str .. '" received from server, reloading')
end)

net.Receive('DPP.LLists', function()
	DPP.EntsLimits = net.ReadTable()
	
	hook.Run('DPP.EntsLimitsReloaded', DPP.EntsLimits)
	DPP.Message('Entity limit list received from server, reloading')
end)

net.Receive('DPP.SLists', function()
	DPP.SBoxLimits = net.ReadTable()
	
	hook.Run('DPP.EntsLimitsReloaded', DPP.SBoxLimits)
	DPP.Message('SBox limit list received from server, reloading')
end)

net.Receive('DPP.CLists', function()
	DPP.ConstrainsLimits = net.ReadTable()
	
	hook.Run('DPP.ConstrainsLimitsReloaded', DPP.ConstrainsLimits)
	DPP.Message('Constrains limit list received from server, reloading')
end)

net.Receive('DPP.PlayerList', function()
	DPP.PlayerList = net.ReadTable()
	
	hook.Run('DPP.PlayerListChanged', DPP.PlayerList)
	DPP.Message('Player list changed, reloading')
end)

net.Receive('DPP.ModelLists', function()
	DPP.BlockedModels = net.ReadTable()
	hook.Run('DPP.BlockedModelListReloaded', DPP.BlockedModels)
	DPP.Message('Blacklisted models received from server, reloading')
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

net.Receive('DPP.ListsInsert', function()
	local s1, s2, b = net.ReadString(), net.ReadString(), net.ReadBool()
	
	if b then
		DPP.BlockedEntities[s1][s2] = b
	else
		DPP.BlockedEntities[s1][s2] = nil
	end
	
	hook.Run('DPP.BlockedEntitiesChanged', s1, s2, b)
end)

net.Receive('DPP.WListsInsert', function()
	local s1, s2, b = net.ReadString(), net.ReadString(), net.ReadBool()
	
	if b then
		DPP.WhitelistedEntities[s1][s2] = b
	else
		DPP.WhitelistedEntities[s1][s2] = nil
	end
	
	hook.Run('DPP.WhitelistedEntitiesChanged', s1, s2, b)
end)

net.Receive('DPP.RListsInsert', function()
	local s1, s2, b = net.ReadString(), net.ReadString(), net.ReadBool()
	
	if b then
		DPP.RestrictedTypes[s1][s2] = {
			groups = net.ReadTable(),
			iswhite = net.ReadBool()
		}
	else
		DPP.RestrictedTypes[s1][s2] = nil
	end
	
	hook.Run('DPP.RestrictedTypesUpdated', s1, s2, b)
end)

net.Receive('DPP.LListsInsert', function()
	local s1 = net.ReadString()
	DPP.EntsLimits[s1] = net.ReadTable()
	
	hook.Run('DPP.EntsLimitsUpdated', s1)
end)

net.Receive('DPP.SListsInsert', function()
	local s1 = net.ReadString()
	DPP.SBoxLimits[s1] = net.ReadTable()
	
	hook.Run('DPP.SBoxLimitsUpdated', s1)
end)

net.Receive('DPP.CListsInsert', function()
	local s1 = net.ReadString()
	DPP.ConstrainsLimits[s1] = net.ReadTable()
	
	hook.Run('DPP.ConstrainsLimitsUpdated', s1)
end)

net.Receive('DPP.ModelsInsert', function()
	local s, b = net.ReadString(), net.ReadBool()
	
	if b then
		DPP.BlockedModels[s] = b
	else
		DPP.BlockedModels[s] = nil
	end
	
	hook.Run('DPP.BlockedModelListChanged', s, b)
end)

net.Receive('DPP.Log', function()
	DPP.Message(unpack(net.ReadTable()))
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

local SelectedEntity

local function PropMenu(ent, tr)
	local menu = DermaMenu()
	
	local ply = LocalPlayer()
	
	for k, v in SortedPairsByMemberValue(properties.List, "Order") do
		if not isfunction(v.Filter) then continue end
		
		if DPP.PlayerConVar(ply, 'show_propery_classes', false) then
			print('[DPP] Class: ' .. k .. ', Name: ' .. tostring(v.MenuLabel))
		end
		
		if not v:Filter(ent, ply) then continue end
		
		if DPP.GetConVar('strict_property') then
			if DPP.CanProperty(ply, k, ent) == false then continue end
		end
		
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
		properties.OpenEntityMenu = PropMenu
		
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
