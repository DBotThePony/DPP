
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

local Gray = Color(200, 200, 200)

local function WrapFunction(func, id)
	local function ProceedFunc(ply, ...)
		local status, notify, notifyLevel = func(ply, ...)
		
		if status then return end
		if not notify then return end
		
		if IsValid(ply) then
			DPP.Notify(ply, notify, notifyLevel)
		else
			DPP.Message(unpack(notify))
		end
	end
	
	return function(ply, ...)
		DPP.CheckAccess(ply, id, ProceedFunc, ply, ...)
	end
end

DPP.Commands = {
	cleardecals = function(ply, cmd, args)
		for k, v in pairs(player.GetAll()) do
			v:ConCommand('r_cleardecals')
			v:SendLua('game.RemoveRagdolls()')
		end
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' cleared decals'}
	end,
	
	toggleplayerprotect = function(ply, cmd, args)
		if not args[1] then return false, {'Invalid target'}, NOTIFY_ERROR end
		if not args[2] then return false, {'Invalid mode'}, NOTIFY_ERROR end
		if not args[3] then return false, {'Invalid status'}, NOTIFY_ERROR end
		
		local target = Player(args[1])
		local mode = args[2]
		local status = tobool(args[3])
		
		if not IsValid(target) then return false, {'Invalid target'}, NOTIFY_ERROR end
		if not DPP.ProtectionModes[mode] then return false, {'Invalid protection mode'}, NOTIFY_ERROR end
		
		DPP.SetProtectionDisabled(target, mode, status)
		local f = {IsValid(ply) and ply or 'Console', Gray, (status and ' disabled ' or ' enabled '), 'protection mode ' .. mode .. ' for ', target}
		DPP.DoEcho(f)
		
		return true
	end,
	
	cleardisconnected = function(ply, cmd, args)
		DPP.ClearDisconnectedProps()
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' cleared all disconnected players entities'}
		
		return true
	end,
	
	clearmap = function(ply, cmd, args)
		for k, v in pairs(DPP.GetAllProps()) do
			SafeRemoveEntity(v)
		end
		
		DPP.RecalculatePlayerList()
		DPP.SendPlayerList()
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' cleaned up map'}
		
		return true
	end,
	
	clearbyuid = function(ply, cmd, args)
		local uid = args[1]
		if not tonumber(uid) then return false, {'Invalid player UID'}, NOTIFY_ERROR end
		
		DPP.ClearByUID(uid)
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' cleared all ', {type = 'UIDPlayer', uid = uid}, Gray, '\'s props'}
		
		return true
	end,
	
	freezeall = function(ply, cmd, args)
		for k, v in pairs(DPP.GetAllProps()) do
			local phys = v:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
		end
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' freezed all player\'s entities'}
		
		return true
	end,
	
	freezephys = function(ply, cmd, args)
		local i = DPP.FreezeAllPhysObjects()
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' freezed all physics objects. Total frozen: ' .. i}
		
		return true
	end,
	
	clearplayer = function(ply, cmd, args)
		if not args[1] or args[1] == '' or args[1] == ' ' then return false, {'Invalid player UserID/Nickname'}, NOTIFY_ERROR end
		
		if tonumber(args[1]) then
			local found = Player(tonumber(args[1]))
			if not found then return false, {'Invalid player UserID'}, NOTIFY_ERROR end
			DPP.ClearPlayerEntities(found)
			
			DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' cleared all ', found, Gray, '\'s entities'}
			return
		end
		
		local Ply = string.lower(args[1])
		local found
		
		for k, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()), Ply) then found = v end
		end
		
		if not found then return false, {'Invalid target'}, NOTIFY_ERROR end
		DPP.ClearPlayerEntities(found)
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' cleared all ', found, Gray, '\'s entities'}
		
		return true
	end,
	
	clearself = function(ply, cmd, args)
		if not IsValid(ply) then return false, {'You are console'} end
		
		DPP.ClearPlayerEntities(ply)
		
		DPP.NotifyLog{'(SILENT) ', ply, Gray, ' cleared his props'}
		
		return true
	end,
	
	transfertoworld = function(ply, cmd, args)
		local id = args[1]
		if not id then return false, {'Invalid Entity Network ID (#1)'}, NOTIFY_ERROR end
		local num = tonumber(id)
		if not num then return false, {'Invalid Entity Network ID (#1)'}, NOTIFY_ERROR end
		local ent = Entity(num)
		if not IsValid(ent) then return false, {'Entity is not valid (#2)'}, NOTIFY_ERROR end
		
		DPP.SetOwner(ent, NULL)
		DPP.DeleteEntityUndo(ent)
		DPP.RecalcConstraints(ent)
		
		return true
	end,
	
	transfertoworld_constrained = function(ply, cmd, args)
		local id = args[1]
		if not id then return false, {'Invalid Entity Network ID (#1)'}, NOTIFY_ERROR end
		local num = tonumber(id)
		if not num then return false, {'Invalid Entity Network ID (#1)'}, NOTIFY_ERROR end
		local ent = Entity(num)
		if not IsValid(ent) then return false, {'Entity is not valid (#2)'}, NOTIFY_ERROR end
		
		local Entities = DPP.GetAllConnectedEntities(ent)
		
		for k, v in pairs(Entities) do
			if not IsValid(v) then continue end --World
			DPP.SetOwner(v, NULL)
			DPP.DeleteEntityUndo(v)
		end
		
		DPP.RecalcConstraints(ent)
		
		return true
	end,
	
	freezeplayer = function(ply, cmd, args)
		if not args[1] then return false, {'Invalid UserID/Nickname'}, NOTIFY_ERROR end
		
		if tonumber(args[1]) then
			local found = Player(tonumber(args[1]))
			if not found then return false, {'Invalid UserID'}, NOTIFY_ERROR end
			DPP.FreezePlayerEntities(found)
			
			DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' freeze all ', found, Gray, '\'s entities'}
			return true
		end
		
		local Ply = string.lower(args[1])
		local found
		
		for k, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()), Ply) then found = v end
		end
		
		if not found then return false, {'No target found'}, NOTIFY_ERROR end
		DPP.FreezePlayerEntities(found)
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' freeze all ', found, Gray, '\'s entities'}
		
		return true
	end,
	
	freezebyuid = function(ply, cmd, args)
		local uid = args[1]
		
		if not tonumber(args[1]) then return false, {'Invalid Player UID'}, NOTIFY_ERROR end
		DPP.FreezeByUID(uid)
			
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' freeze all ', {type = 'UIDPlayer', uid = uid}, Gray, '\'s entities'}
		
		return true
	end,
	
	unfreezebyuid = function(ply, cmd, args)
		local uid = args[1]
		
		if not tonumber(args[1]) then return false, {'Invalid Player UID'}, NOTIFY_ERROR end
		
		DPP.UnFreezeByUID(uid)
			
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' unfreeze all ', {type = 'UIDPlayer', uid = uid}, Gray, '\'s entities'}
		
		return true
	end,
	
	unfreezeplayer = function(ply, cmd, args)
		if not args[1] then return false, {'Invalid UserID/Nickname'}, NOTIFY_ERROR end
		
		if tonumber(args[1]) then
			local found = Player(tonumber(args[1]))
			if not found then return false, {'Invalid UserID'}, NOTIFY_ERROR end
			DPP.UnFreezePlayerEntities(found)
			
			DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' unfreeze all ', found, Gray, '\'s entities'}
			return true
		end
		
		local Ply = string.lower(args[1])
		local found
		
		for k, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()), Ply) then found = v end
		end
		
		if not found then return false, {'No target found'}, NOTIFY_ERROR end
		DPP.UnFreezePlayerEntities(found)
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' unfreeze all ', found, Gray, '\'s entities'}
		
		return true
	end,
	
	share = function(ply, cmd, args)
		local num = tonumber(args[1])
		local type = args[2]
		local status = args[3]
		
		if not num then return false, {'Invalid Entity Network ID (#1)'}, NOTIFY_ERROR end
		if not type then return false, {'Invalid share type (#2)'}, NOTIFY_ERROR end
		if not status then return false, {'Invalid status'}, NOTIFY_ERROR end
		
		if not DPP.ShareTypes[type] then return false, {'Invalid share type (#2)'}, NOTIFY_ERROR end
		
		local ent = Entity(num)
		if not IsValid(ent) then return false, {'Entity does not exists or not valid'}, NOTIFY_ERROR end
		if IsValid(ply) and DPP.GetOwner(ent) ~= ply then return false, {'Not a owner'}, NOTIFY_ERROR end
		
		status = tobool(status)
		
		DPP.SetIsShared(ent, type, status)
		
		return true
	end,
	
	entcheck = function(ply, cmd, args)
		if IsValid(ply) then
			DPP.Notify(ply, 'Look into console')
		end
		
		DPP.SimpleLog(IsValid(ply) and ply or 'Console', Gray, ' requested entities report')
		DPP.ReportEntitiesPrint()
		
		return true
	end,
}

DPP.RawCommands = {}

for k, v in pairs(DPP.Commands) do
	DPP.RawCommands[k] = v
	DPP.Commands[k] = WrapFunction(v, k)
	concommand.Add('dpp_' .. k, DPP.Commands[k])
end

DPP.Commands.entreport = DPP.Commands.entcheck
