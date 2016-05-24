
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

concommand.Add('dpp_cleardecals', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	for k, v in pairs(player.GetAll()) do
		v:ConCommand('r_cleardecals')
		v:SendLua('game.RemoveRagdolls()')
	end
	DPP.NotifyLog{IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' cleared decals'}
end)

concommand.Add('dpp_cleardisconnected', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	DPP.ClearDisconnectedProps()
	DPP.NotifyLog{IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' cleared all disconnected players entities'}
end)

concommand.Add('dpp_clearmap', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	for k, v in pairs(DPP.GetAllProps()) do
		SafeRemoveEntity(v)
	end
	
	DPP.RecalculatePlayerList()
	DPP.SendPlayerList()
	
	DPP.NotifyLog{IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' cleaned up map'}
end)

local DisconnectedPlayer = Color(134, 255, 154)

concommand.Add('dpp_clearbyuid', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	local uid = args[1]
	if not tonumber(uid) then DPP.Notify(ply, 'Invalid argument') return end
	
	local Target = player.GetByUniqueID(uid)
	DPP.ClearByUID(uid)
	
	DPP.NotifyLog{IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' cleared all ', Target and team.GetColor(Target:Team()) or DisconnectedPlayer, Target and Target:Nick() or DPP.DisconnectedPlayerNick(uid), Color(200, 200, 200), '\' props'}
end)

concommand.Add('dpp_freezeall', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	
	for k, v in pairs(DPP.GetAllProps()) do
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
	
	DPP.NotifyLog{IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' freezed all player\'s entities'}
end)

concommand.Add('dpp_clearplayer', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	
	if tonumber(args[1]) then
		local found = Player(tonumber(args[1]))
		if not found then DPP.Notify(ply, 'Invalid argument') return end
		DPP.ClearPlayerEntities(found)
		
		DPP.NotifyLog{IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' cleared all ', team.GetColor(found:Team()), found:Nick(), Color(200, 200, 200), '\'s entities'}
		return
	end
	
	local Ply = string.lower(args[1])
	local found
	
	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), Ply) then found = v end
	end
	
	if not found then DPP.Notify(ply, 'Invalid argument') return end
	DPP.ClearPlayerEntities(found)
	
	DPP.NotifyLog{IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' cleared all ', team.GetColor(found:Team()), found:Nick(), Color(200, 200, 200), '\'s entities'}
end)

concommand.Add('dpp_clearself', function(ply, cmd, args)
	if not IsValid(ply) then return end
	
	DPP.ClearPlayerEntities(ply)
	
	DPP.NotifyLog{'(SILENT) ', IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' cleared his props'}
end)

concommand.Add('dpp_transfertoworld', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	
	local id = args[1]
	if not id then DPP.Notify(ply, 'Invalid argument') return end
	local num = tonumber(id)
	if not num then DPP.Notify(ply, 'Invalid argument') return end
	local ent = Entity(num)
	if not IsValid(ent) then DPP.Notify(ply, 'Invalid argument') return end
	
	DPP.SetOwner(ent, NULL)
	DPP.DeleteEntityUndo(ent)
	DPP.RecalcConstraints(ent)
end)

concommand.Add('dpp_transfertoworld_constrained', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	
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
end)

concommand.Add('dpp_freezeplayer', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	if not args[1] then DPP.Notify(ply, 'Invalid argument') return end
	
	if tonumber(args[1]) then
		local found = Player(tonumber(args[1]))
		if not found then DPP.Notify(ply, 'Invalid argument') return end
		DPP.FreezePlayerEntities(found)
		
		DPP.NotifyLog{IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' freeze all ', team.GetColor(found:Team()), found:Nick(), Color(200, 200, 200), '\'s entities'}
		return
	end
	
	local Ply = string.lower(args[1])
	local found
	
	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), Ply) then found = v end
	end
	
	if not found then DPP.Notify(ply, 'Invalid argument') return end
	DPP.FreezePlayerEntities(found)
	
	DPP.NotifyLog{IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' freeze all ', team.GetColor(found:Team()), found:Nick(), Color(200, 200, 200), '\'s entities'}
end)

concommand.Add('dpp_freezebyuid', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	
	local uid = args[1]
	
	if not tonumber(args[1]) then DPP.Notify(ply, 'Invalid argument') return end
	
	local Target = player.GetByUniqueID(uid)
	DPP.FreezeByUID(uid)
		
	DPP.NotifyLog{IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' freeze all ', Target and team.GetColor(Target:Team()) or DisconnectedPlayer, Target and Target:Nick() or DPP.DisconnectedPlayerNick(uid), Color(200, 200, 200), '\'s entities'}
end)

concommand.Add('dpp_unfreezebyuid', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	
	local uid = args[1]
	
	if not tonumber(args[1]) then DPP.Notify(ply, 'Invalid argument') return end
	
	local Target = player.GetByUniqueID(uid)
	DPP.UnFreezeByUID(uid)
		
	DPP.NotifyLog{IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' unfreeze all ', Target and team.GetColor(Target:Team()) or DisconnectedPlayer, Target and Target:Nick() or DPP.DisconnectedPlayerNick(uid), Color(200, 200, 200), '\'s entities'}
end)

concommand.Add('dpp_unfreezeplayer', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	if not args[1] then DPP.Notify(ply, 'Invalid argument') return end
	
	if tonumber(args[1]) then
		local found = Player(tonumber(args[1]))
		if not found then DPP.Notify(ply, 'Invalid argument') return end
		DPP.UnFreezePlayerEntities(found)
		
		DPP.NotifyLog{IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' unfreeze all ', team.GetColor(found:Team()), found:Nick(), Color(200, 200, 200), '\'s entities'}
		return
	end
	
	local Ply = string.lower(args[1])
	local found
	
	for k, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), Ply) then found = v end
	end
	
	if not found then DPP.Notify(ply, 'Invalid argument') return end
	DPP.UnFreezePlayerEntities(found)
	
	DPP.NotifyLog{IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' unfreeze all ', team.GetColor(found:Team()), found:Nick(), Color(200, 200, 200), '\'s entities'}
end)

concommand.Add('dpp_share', function(ply, cmd, args)
	local num = tonumber(args[1])
	local type = args[2]
	local status = args[3]
	
	if not num then DPP.Notify(ply, 'Invalid argument') return end
	if not type then DPP.Notify(ply, 'Invalid argument') return end
	if not status then DPP.Notify(ply, 'Invalid argument') return end
	
	local ent = Entity(num)
	if not IsValid(ent) then DPP.Notify(ply, 'Entity does not exists') return end
	if IsValid(ply) and DPP.GetOwner(ent) ~= ply then DPP.Notify(ply, 'Not a owner') return end
	
	status = tobool(status)
	
	DPP.SetIsShared(ent, type, status)
end)
