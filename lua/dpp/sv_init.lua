
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

--Server

AddCSLuaFile('sh_init.lua')
AddCSLuaFile('sh_cppi.lua')
AddCSLuaFile('sh_functions.lua')
AddCSLuaFile('sh_access.lua')
AddCSLuaFile('sh_hooks.lua')
AddCSLuaFile('sh_lang.lua')
AddCSLuaFile('sh_networking.lua')
AddCSLuaFile('cl_networking.lua')
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('cl_settings.lua')

include('sv_fpp_comp.lua')
include('sv_functions.lua')

DPP.PropListing = DPP.PropListing or {}
DPP.ConstraintsListing = DPP.ConstraintsListing or {}

resource.AddWorkshop('659044893')

function DPP.Notify(ply, message, type)
	if istable(ply) or IsValid(ply) then
		net.Start('DPP.Notify')
		DPP.WriteMessageTable(istable(message) and message or {message})
		net.WriteUInt(type or 0, 6)
		net.Send(ply)
	else
		DPP.Message(message)
	end
end

function DPP.ConVarChanged(var, old, new)
	if not DPP.IGNORE_CVAR_SAVE then
		timer.Create('DPP.SaveCVars', 1, 1, DPP.SaveCVars)
	end

	local can = hook.Run('DPP_SuppressConVarBroadcast', var, old, new)
	if can ~= true then DPP.NetworkConVarToClient(player.GetAll(), var:sub(5)) end
	hook.Run('DPP_ConVarChanges', var, old, new)
end

function DPP.RefreshPropList()
	for k, v in pairs(DPP.PropListing) do
		if not IsValid(k) then
			DPP.PropListing[k] = nil
			continue
		end

		if not DPP.IsOwned(k) then
			DPP.PropListing[k] = nil
			continue
		end
	end
end

local Constraints = {
	gmod_winch_controller = true,
	phys_torque = true,
	phys_spring = true,
	logic_collision_pair = true,
	keyframe_rope = true, --ugh
}

function DPP.IsConstraint(ent)
	return ent:IsConstraint() or Constraints[ent:GetClass()]
end

function DPP.GetConstrainedEntities(ent)
	if ent.GetConstrainedEntities then
		local a, b = ent:GetConstrainedEntities()
		if a or b then return a, b end
	end

	return ent.Ent1 or NULL, ent.Ent2 or NULL
end

local ConstraintTypes = {
	phys_constraint = 'weld',
	phys_slideconstraint = 'slider',
	phys_spring = 'elastic',
	phys_lengthconstraint = 'rope',
	keyframe_rope = 'vrope', --ugh
	phys_hinge = 'axis',
	phys_torque = 'motor',
	phys_ballsocket = 'ballsocket',
}

function DPP.GetContstrainType(ent)
	local class = ent:GetClass()

	if class == 'gmod_winch_controller' then
		return ent.type == TYPE_NORMAL and 'winch' or 'muscule'
	end

	return ConstraintTypes[class] or '<unknown>'
end

function DPP.SetOwner(ent, ply)
	--if ent:IsConstraint() then return end --Constraint can't have an owner
	local old = DPP.GetOwner(ent)
	ent:SetDPPVar('Owner', ply)

	local isConst = DPP.IsConstraint(ent)

	if IsValid(ply) then
		ply.DPP_Ents = ply.DPP_Ents or {}

		ply.DPP_Ents[ent] = true

		ent:SetDPPVar('IsOwned', true)
		ent:SetDPPVar('OwnerString', ply:Nick())
		ent:SetDPPVar('OwnerUID', ply:UniqueID())
		ent:SetDPPVar('OwnerSteamID', ply:SteamID())
		if isConst then
			DPP.ConstraintsListing[ent] = true
		end
		DPP.PropListing[ent] = true
	else
		ent:SetDPPVar('IsOwned', false)
		ent:SetDPPVar('OwnerString', 'World')
		ent:SetDPPVar('OwnerUID', 0)
		ent:SetDPPVar('OwnerSteamID', '')
		DPP.PropListing[ent] = nil
		DPP.ConstraintsListing[ent] = nil
	end

	if IsValid(old) then
		old.DPP_Ents = old.DPP_Ents or {}
		old.DPP_Ents[ent] = nil
	end

	--Running AssignOwnership after we done default behaviour
	hook.Run('DPP.AssignOwnership', ply, ent)
end

function DPP.GetFriendTable(ply)
	return ply.DPP_Friends or {}
end

function DPP.RecalculateCPPIFriendTable(ply)
	local tab = DPP.GetFriendTable(ply)
	local reply = {}
	for k, v in pairs(tab) do
		table.insert(reply, k)
	end
	ply.DPP_FriendsCPPI = reply
	return reply
end

function DPP.GetFriendTableCPPI(ply)
	return ply.DPP_FriendsCPPI or {}
end

--Don't overflow net channel when player pastes a big dupe
local Queued = {}
local AccessCache = {}

do
	local function AccessCallback(can, reason, ply)
		if can then
			table.insert(AccessCache, ply)
		end
	end

	local function Clear()
		AccessCache = {}

		for k, ply in ipairs(player.GetAll()) do
			DPP.HaveAccess(ply, 'seelogs', AccessCallback, ply)
		end
	end

	timer.Create('DPP.DoEchoAccessCacheClear', 10, 0, Clear)
	Clear()
end

local function Think()
	for k, v in pairs(Queued) do
		DPP.Message(unpack(v))
		local admins = {}

		for k, v in ipairs(AccessCache) do
			table.insert(admins, v)
		end

		net.Start('DPP.Log')
		DPP.WriteMessageTable(v)
		net.Send(admins)

		Queued[k] = nil

		break
	end
end

hook.Add('Think', 'DPP.NetEchoThink', Think)

function DPP.DoEcho(...)
	local repack = DPP.Format(...)

	if not DLog then
		table.insert(Queued, repack)
	else
		DLog.Log('DPP', 1, repack)
	end
end

function DPP.NotifyLog(t)
	t = DPP.Format(unpack(t))
	DPP.Notify(player.GetAll(), t)

	if not DLog then
		DPP.Message(t)
		DPP.LogIntoFile(unpack(t))
		return
	end
	DLog.Log('DPP', 1, t, {Private = false, PrintClient = false})
end

local File
local CurrentPatch

local function ConcatSafe(tab)
	local str = ''

	for k, v in ipairs(tab) do
		if type(v) == 'string' then str = str .. v end
	end

	return str
end

function DPP.LogIntoFile(...)
	if not DPP.GetConVar('log_file') then return end

	if not File then
		File = file.Open('dpp/' .. os.date('%d_%m_%y') .. '.txt', 'ab', 'DATA')
	end

	local str = ''

	for k, v in ipairs(DPP.PreprocessPhrases(...)) do
		if type(v) == 'Player' then
			str = str .. ConcatSafe(DPP.FormatPlayer(v))
		end

		if type(v) == 'string' then
			str = str .. v
		end

		if type(v) == 'table' then
			if v.type == 'Spacing' then
				str = str .. string.rep(' ', v.length - #str)
			end

			if v.type == 'UIDPlayer' then
				local ply = player.GetByUniqueID(v.uid)

				if ply then
					str = str .. ConcatSafe(DPP.FormatPlayer(ply))
				else
					str = str .. DPP.DisconnectedPlayerNick(v.uid)
				end
			end
		end
	end

	File:Write(str .. '\n')
end

function DPP.SimpleLog(...)
	DPP.DoEcho(...)
	DPP.LogIntoFile(...)
end

function DPP.RefreshLogFile()
	local neededPath = 'dpp/log_' .. os.date('%d_%m_%y') .. '.txt'

	if neededPath ~= CurrentPatch then
		if File then
			File:Flush()
			File:Close()
		end

		CurrentPatch = neededPath
		File = file.Open(neededPath, 'ab', 'DATA')
	end

	if not File then return end
	File:Flush()
end

timer.Create('DPP.RefreshLogFile', 10, 0, DPP.RefreshLogFile)
timer.Simple(0, DPP.RefreshLogFile)

function DPP.PlayerInitialSpawn(ply)
	timer.Simple(2, function()
		if not IsValid(ply) then return end
		DPP.FindPlayerProps(ply)
		net.Start('DPP.ReloadFiendList')
		net.Broadcast()

		--Still would call twice rebuilding player list on client
		net.Start('DPP.RefreshPlayerList')
		net.Broadcast()

		DPP.RecalculatePlayerList()
		DPP.SendPlayerList()
	end)
end

local Gray = Color(200, 200, 200)

function DPP.PlayerDisconnected(ply)
	if DPP.GetConVar('disconnected_freeze') then
		for k, v in pairs(DPP.GetPlayerEntities(ply)) do
			local phys = v:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
		end
	end

	local clear, clearAdmin, isAdmin = DPP.GetConVar('clear_disconnected'), DPP.GetConVar('clear_disconnected_admin'), ply:IsAdmin()
	local grab, grabAdmin = DPP.GetConVar('grabs_disconnected'), DPP.GetConVar('grabs_disconnected_admin')

	local uid = ply:UniqueID()
	local name = ply:Nick()

	local props = DPP.GetPropsByUID(uid)
	if #props == 0 then return end

	local userFallback = ply:DPPVar('fallback')

	if IsValid(userFallback) then
		for k, v in ipairs(props) do
			DPP.SetOwner(v, userFallback)
		end

		DPP.SimpleLog(Gray, 'PHRASE:com_fallback_triggered', ply, Gray, 'PHRASE:com_to', userFallback)
		DPP.Notify(userFallback, DPP.Format('PHRASE:com_fallback_triggered_1', ply, Gray, 'PHRASE:com_fallback_triggered_2'))
		DPP.TransferUndoTo(ply, userFallback)
	end

	timer.Simple(2, function()
		net.Start('DPP.RefreshPlayerList')
		net.Broadcast()

		for k, v in pairs(DPP.GetPropsByUID(uid)) do
			DPP.RecalcConstraints(v)
		end
	end)

	if IsValid(userFallback) then return end

	if clear then
		if isAdmin and clearAdmin or not isAdmin then
			timer.Create('DPP.ClearPlayer.' .. uid, DPP.GetConVar('clear_timer'), 1, function()
				local ply = player.GetByUniqueID(uid)
				if ply then return end

				for k, v in pairs(DPP.GetPropsByUID(uid)) do
					SafeRemoveEntity(v)
				end

				if not DPP.GetConVar('no_clear_messages') then
					DPP.Notify(player.GetAll(), 'PHRASE:props_cleared||' .. name, 2)
				end

				DPP.Message('PHRASE:props_cleared||' .. name)

				DPP.RecalculatePlayerList()
				DPP.SendPlayerList()
			end)
		end
	end

	if grab then
		if isAdmin and grabAdmin or not isAdmin then
			timer.Create('DPP.GrabsPlayer.' .. uid, DPP.GetConVar('grabs_timer'), 1, function()
				local ply = player.GetByUniqueID(uid)
				if ply then return end

				for k, v in pairs(DPP.GetPropsByUID(uid)) do
					DPP.SetUpForGrabs(v, true)
				end

				if not DPP.GetConVar('no_clear_messages') then
					DPP.Notify(player.GetAll(), 'PHRASE:props_up_for_grabs||' .. name)
				end

				DPP.Message('PHRASE:props_up_for_grabs||' .. name)

				DPP.RecalculatePlayerList()
				DPP.SendPlayerList()
			end)
		end
	end

	if DPP.GetConVar('freeze_on_disconnect') then
		DPP.FreezePlayerEntities(ply)
	end
end

function DPP.PlayerPhrase(ply, id, ...)
	ply._DPP_CURRENT_LANG = ply._DPP_CURRENT_LANG or 'en'
	return DPP.PhraseByLang(ply._DPP_CURRENT_LANG, id, ...)
end

DPP.PPhrase = DPP.PlayerPhrase

DPP.SetVarCommandRaw = function(ply, cmd, args)
	if not args[1] then return false, {'PHRASE:com_invalid_cvar'}, NOTIFY_ERROR end
	args[1] = args[1]:lower()
	if not DPP.Settings[args[1]] then return false, {'PHRASE:com_invalid_cvar'}, NOTIFY_ERROR end
	if not args[2] then return false, {'PHRASE:com_invalid_cvar_v'}, NOTIFY_ERROR end
	RunConsoleCommand('dpp_' .. args[1], args[2])
	DPP.SimpleLog(IsValid(ply) and ply or 'Console', Gray, 'PHRASE:com_cvar_set_1', color_white, args[1], Gray, 'PHRASE:com_to', color_white, args[2])
	return true
end

local function SetVarProceed(ply, cmd, args)
	local status, notify, notifyLevel = DPP.SetVarCommandRaw(ply, cmd, args)

	if status then return end
	if not notify then return end

	if IsValid(ply) then
		DPP.Notify(ply, notify, notifyLevel)
	else
		DPP.Message(unpack(notify))
	end
end

DPP.SetVarCommand = function(ply, cmd, args)
	DPP.CheckAccess(ply, 'setvar', SetVarProceed, ply, cmd, args)
end

net.Receive('DPP.ReloadFiendList', function(len, ply)
	ply.DPP_Friends = net.ReadTable()
	DPP.RecalculateCPPIFriendTable(ply)
	hook.Run('CPPIFriendsChanged', ply, DPP.GetFriendTableCPPI(ply))

	net.Start('DPP.ReceiveFriendList')
	net.WriteEntity(ply)
	net.WriteTable(ply.DPP_Friends)
	net.Broadcast()
end)

net.Receive('DPP.SetConVar', function(len, ply)
	local c = net.ReadString()
	local new = net.ReadString()
	DPP.CheckAccess(ply, 'setvar', SetVarProceed, ply, 'dpp_setvar ' .. c .. ' ' .. new, {c, new})
end)

concommand.Add('dpp_setvar', DPP.SetVarCommand)

hook.Add('PlayerInitialSpawn', 'DPP.Hooks', DPP.PlayerInitialSpawn)
hook.Add('PlayerDisconnected', 'DPP.Hooks', DPP.PlayerDisconnected)

net.Receive('DPP.ConVarChanged', function(len, ply)
	local var = net.ReadString()
	if not DPP.CSettings[var] then return end
	DPP.PlayerConVar(ply, var) --Enough to rebroadcast cvar
end)

net.Receive('DPP.UpdateLang', function(len, ply)
	ply._DPP_CURRENT_LANG = net.ReadString()
end)

include('sv_hooks.lua')
include('sv_commands.lua')
include('sv_misc.lua')
