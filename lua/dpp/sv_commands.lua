
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

local DisconnectedPlayer = Color(134, 255, 154)
local Gray = Color(200, 200, 200)

local function WrapFunction(func, id)
	return function(ply, ...)
		DPP.CheckAccess(ply, id, func, ply, ...)
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
		if not args[1] then DPP.Notify(ply, 'Invalid argument') return end
		if not args[2] then DPP.Notify(ply, 'Invalid argument') return end
		if not args[3] then DPP.Notify(ply, 'Invalid argument') return end
		
		local target = Player(args[1])
		local mode = args[2]
		local status = tobool(args[3])
		
		if not IsValid(target) then DPP.Notify(ply, 'Invalid argument') return end
		if not DPP.ProtectionModes[mode] then DPP.Notify(ply, 'Invalid argument') return end
		
		DPP.SetProtectionDisabled(target, mode, status)
		local f = {IsValid(ply) and ply or 'Console', Gray, (status and ' disabled ' or ' enabled '), 'protection mode ' .. mode .. ' for ', target}
		DPP.DoEcho(f)
	end,
	
	cleardisconnected = function(ply, cmd, args)
		DPP.ClearDisconnectedProps()
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' cleared all disconnected players entities'}
	end,
	
	clearmap = function(ply, cmd, args)
		for k, v in pairs(DPP.GetAllProps()) do
			SafeRemoveEntity(v)
		end
		
		DPP.RecalculatePlayerList()
		DPP.SendPlayerList()
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' cleaned up map'}
	end,
	
	clearbyuid = function(ply, cmd, args)
		local uid = args[1]
		if not tonumber(uid) then DPP.Notify(ply, 'Invalid argument') return end
		
		local Target = player.GetByUniqueID(uid)
		DPP.ClearByUID(uid)
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' cleared all ', Target or DisconnectedPlayer, Gray, '\'s props'}
	end,
	
	freezeall = function(ply, cmd, args)
		for k, v in pairs(DPP.GetAllProps()) do
			local phys = v:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
		end
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' freezed all player\'s entities'}
	end,
	
	freezephys = function(ply, cmd, args)
		local i = DPP.FreezeAllPhysObjects()
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' freezed all physics objects. Total frozen: ' .. i}
	end,
	
	clearplayer = function(ply, cmd, args)
		if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
		
		if tonumber(args[1]) then
			local found = Player(tonumber(args[1]))
			if not found then DPP.Notify(ply, 'Invalid argument') return end
			DPP.ClearPlayerEntities(found)
			
			DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' cleared all ', found, Gray, '\'s entities'}
			return
		end
		
		local Ply = string.lower(args[1])
		local found
		
		for k, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()), Ply) then found = v end
		end
		
		if not found then DPP.Notify(ply, 'Invalid argument') return end
		DPP.ClearPlayerEntities(found)
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' cleared all ', found, Gray, '\'s entities'}
	end,
	
	clearself = function(ply, cmd, args)
		if not IsValid(ply) then return end
		
		DPP.ClearPlayerEntities(ply)
		
		DPP.NotifyLog{'(SILENT) ', IsValid(ply) and ply or 'Console', Gray, ' cleared his props'}
	end,
	
	transfertoworld = function(ply, cmd, args)
		local id = args[1]
		if not id then DPP.Notify(ply, 'Invalid argument') return end
		local num = tonumber(id)
		if not num then DPP.Notify(ply, 'Invalid argument') return end
		local ent = Entity(num)
		if not IsValid(ent) then DPP.Notify(ply, 'Invalid argument') return end
		
		DPP.SetOwner(ent, NULL)
		DPP.DeleteEntityUndo(ent)
		DPP.RecalcConstraints(ent)
	end,
	
	transfertoworld_constrained = function(ply, cmd, args)
		local id = args[1]
		if not id then DPP.Notify(ply, 'Invalid argument') return end
		local num = tonumber(id)
		if not num then DPP.Notify(ply, 'Invalid argument') return end
		local ent = Entity(num)
		if not IsValid(ent) then DPP.Notify(ply, 'Invalid argument') return end
		
		local Entities = DPP.GetAllConnectedEntities(ent)
		
		for k, v in pairs(Entities) do
			DPP.SetOwner(v, NULL)
			DPP.DeleteEntityUndo(v)
		end
		
		DPP.RecalcConstraints(ent)
	end,
	
	freezeplayer = function(ply, cmd, args)
		if not args[1] then DPP.Notify(ply, 'Invalid argument') return end
		
		if tonumber(args[1]) then
			local found = Player(tonumber(args[1]))
			if not found then DPP.Notify(ply, 'Invalid argument') return end
			DPP.FreezePlayerEntities(found)
			
			DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' freeze all ', found, Gray, '\'s entities'}
			return
		end
		
		local Ply = string.lower(args[1])
		local found
		
		for k, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()), Ply) then found = v end
		end
		
		if not found then DPP.Notify(ply, 'Invalid argument') return end
		DPP.FreezePlayerEntities(found)
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' freeze all ', found, Gray, '\'s entities'}
	end,
	
	freezebyuid = function(ply, cmd, args)
		local uid = args[1]
		
		if not tonumber(args[1]) then DPP.Notify(ply, 'Invalid argument') return end
		
		local Target = player.GetByUniqueID(uid)
		DPP.FreezeByUID(uid)
			
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' freeze all ', Target or DisconnectedPlayer, Gray, '\'s entities'}
	end,
	
	unfreezebyuid = function(ply, cmd, args)
		local uid = args[1]
		
		if not tonumber(args[1]) then DPP.Notify(ply, 'Invalid argument') return end
		
		local Target = player.GetByUniqueID(uid)
		DPP.UnFreezeByUID(uid)
			
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' unfreeze all ', Target or DisconnectedPlayer, Gray, '\'s entities'}
	end,
	
	unfreezeplayer = function(ply, cmd, args)
		if not args[1] then DPP.Notify(ply, 'Invalid argument') return end
		
		if tonumber(args[1]) then
			local found = Player(tonumber(args[1]))
			if not found then DPP.Notify(ply, 'Invalid argument') return end
			DPP.UnFreezePlayerEntities(found)
			
			DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' unfreeze all ', found, Gray, '\'s entities'}
			return
		end
		
		local Ply = string.lower(args[1])
		local found
		
		for k, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()), Ply) then found = v end
		end
		
		if not found then DPP.Notify(ply, 'Invalid argument') return end
		DPP.UnFreezePlayerEntities(found)
		
		DPP.NotifyLog{IsValid(ply) and ply or 'Console', Gray, ' unfreeze all ', found, Gray, '\'s entities'}
	end,
	
	share = function(ply, cmd, args)
		local num = tonumber(args[1])
		local type = args[2]
		local status = args[3]
		
		if not num then DPP.Notify(ply, 'Invalid argument') return end
		if not type then DPP.Notify(ply, 'Invalid argument') return end
		if not status then DPP.Notify(ply, 'Invalid argument') return end
		
		if not DPP.ShareTypes[type] then DPP.Notify(ply, 'Invalid argument') return end
		
		local ent = Entity(num)
		if not IsValid(ent) then DPP.Notify(ply, 'Entity does not exists') return end
		if IsValid(ply) and DPP.GetOwner(ent) ~= ply then DPP.Notify(ply, 'Not a owner') return end
		
		status = tobool(status)
		
		DPP.SetIsShared(ent, type, status)
	end,
	
	entcheck = function(ply, cmd, args)
		DPP.Notify(ply, 'Look into console')
		DPP.SimpleLog(IsValid(ply) and ply or 'Console', Gray, ' requested entities report')
		DPP.ReportEntitiesPrint()
	end,
}

DPP.RawCommands = {}

for k, v in pairs(DPP.Commands) do
	DPP.RawCommands[k] = v
	DPP.Commands[k] = WrapFunction(v, k)
	concommand.Add('dpp_' .. k, DPP.Commands[k])
end

DPP.Commands.entreport = DPP.Commands.entcheck
