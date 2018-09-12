
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

-- FPP Funcs compability

if FPP then return end

FPP = {}
FPP.AntiSpam = {}
FPP.Protect = {}

function FPP.plyCanTouchEnt(ply, ent, type)
	if not type then --We are ignoring type
		return DPP.CanTouch(ply, ent)
	end

	if type == 'Physgun' then
		return DPP.CanPhysgun(ply, ent)
	elseif type == 'Gravgun' then
		return DPP.CanGravgun(ply, ent)
	elseif type == 'Toolgun' then
		return DPP.CanTool(ply, ent, '')
	elseif type == 'PlayerUse' then
		return DPP.PlayerUse(ply, ent)
	elseif type == 'EntityDamage' then
		return DPP.CanDamage(ply, ent)
	end

	return DPP.CanTouch(ply, ent)
end

concommand.Add('FPP_AddBlockedModel', function(ply, cmd, args)
	DPP.ManipulateCommands.addblockedmodel(ply, cmd, args)
end)

concommand.Add('FPP_RemoveBlockedModel', function(ply, cmd, args)
	DPP.ManipulateCommands.removeblockedmodel(ply, cmd, args)
end)

function FPP.AntiSpam.GhostFreeze(ent, phys) --phys arg is ignored
	DPP.SetGhosted(ent, true)
end

function FPP.UnGhost(ply, ent) --phys arg is ignored
	if DPP.GetGhosted(ent) then
		DPP.SetGhosted(ent, false)
	end
end

function FPP.AntiSpam.CreateEntity(ply, ent, IsDuplicate)
	DPP.SpawnFunctions.CheckAfter(ply, ent, nil, IsDuplicate)
	DPP.SetOwner(ent, ply)
end

function FPP.AntiSpam.DuplicatorSpam(ply)
	return true --ugh
end

--Protection

function FPP.Protect.PhysgunPickup(ply, ent)
	return DPP.PhysgunPickup(ply, ent)
end

function FPP.Protect.PhysgunReload(weapon, ply)
	return DPP.OnPhysgunReload(phys, ply)
end

function FPP.Protect.GravGunPickup(ply, ent)
	return DPP.CanGravgun(ply, ent)
end

function FPP.Protect.GravGunPunt(ply, ent)
	return DPP.CanGravgunPunt(ply, ent)
end

function FPP.Protect.PlayerUse(ply, ent)
	return DPP.PlayerUse(ply, ent)
end

function FPP.Protect.EntityDamage(ent, dmginfo)
	local ply = dmginfo:GetAttacker()
	if not IsValid(ply) then return end
	if not ply:IsPlayer() then return end
	return DPP.CanDamage(ply, ent)
end

function FPP.Protect.CanTool(ply, trace, tool, ENT)
	return DPP.CanTool(ply, trace.Entity, tool)
end

function FPP.Protect.CanProperty(ply, property, ent)
	return DPP.CanProperty(ply, property, ent)
end

function FPP.Protect.CanDrive(ply, ent)
	return DPP.CanDrive(ply, ent)
end

function FPP.PlayerDisconnect(ply)
	DPP.PlayerDisconnected(ply)
end

function FPP.PlayerInitialSpawn(ply)
	DPP.PlayerInitialSpawn(ply)
end

local function WrapCommand(func, id)
	return function(ply, ...)
		local status, notify, notifyLevel = func(ply, ...)

		if status then return end
		if not notify then return end

		if IsValid(ply) then
			DPP.Notify(ply, notify, notifyLevel)
		else
			DPP.Message(unpack(notify))
		end
	end
end

local Gray = Color(200, 200, 200)

local commandsCoverage = {
	cleanup = function(ply, cmd, args)
		if not args[1] then return false, {'#com_invalid_target'}, NOTIFY_ERROR end

		if args[1]:Trim():lower() == 'disconnected' then
			return DPP.Commands.cleardisconnected(ply, cmd, args)
		end

		DPP.CheckAccess(ply, 'clearplayer', function()
			local num = tonumber(args[1])
			if not num then return false, {'#com_invalid_target'}, NOTIFY_ERROR end
			local target = Player(num)
			if not IsValid(target) then return false, {'#com_invalid_target'}, NOTIFY_ERROR end

			DPP.ClearPlayerEntities(target)
			DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, ' cleared all ', target, Gray, '#com_ply_ents'}
		end)
	end
}

DPP.FPPCommands = commandsCoverage

for k, v in pairs(commandsCoverage) do
	commandsCoverage[k] = WrapCommand(v)
	print(v, commandsCoverage[k])
	concommand.Add('fpp_' .. k, commandsCoverage[k])
end
