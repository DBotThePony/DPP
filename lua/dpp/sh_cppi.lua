
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

--CPPI

CPPI_NOTIMPLEMENTED = 9020
CPPI_DEFER = 9030

CPPI = {}

function CPPI.GetName()
	return 'DBot Prop Protection'
end

function CPPI.GetVersion()
	return 'universal'
end

function CPPI.GetInterfaceVersion()
	return 1.5, 'unofficial'
end

local entMeta = FindMetaTable('Entity')
local plyMeta = FindMetaTable('Player')

--Object Oriented Model

plyMeta.CPPIGetFriends = DPP.GetFriendTableCPPI

function entMeta:CPPIGetOwner()
	local o = DPP.GetOwner(self)
	if not IsValid(o) then return nil, nil end

	return o, o:UniqueID()
end

if SERVER then
	entMeta.CPPISetOwner = DPP.SetOwner

	function entMeta:CPPISetOwnerUID(uid)
		local ply = player.GetByUniqueID(uid)
		if not ply then
			DPP.SetOwner(self, NULL)
		else
			DPP.SetOwner(self, ply)
		end
	end

	plyMeta.CPPIGetProps = DPP.GetPlayerEntities
	plyMeta.CPPIGetEntitites = DPP.GetPlayerEntities
	plyMeta.CPPIGetEnts = DPP.GetPlayerEntities
end

function entMeta:CPPICanDamage(ply)
	return DPP.CanDamage(ply, self) ~= false
end

function entMeta:CPPICanTool(ply, mode)
	return DPP.CanTool(ply, self, mode) ~= false
end

function entMeta:CPPIDrive(ply)
	return DPP.CanDrive(ply, self) ~= false
end

function entMeta:CPPICanEditVariable(ply, key, val, editor)
	return DPP.CanEditVariable(self, ply, key, val, editor) ~= false
end

function entMeta:CPPICanProperty(ply, str)
	return DPP.CanProperty(ply, str, ent) ~= false
end

function entMeta:CPPICanPhysgun(ply)
	return DPP.CanPhysgun(ply, self) ~= false
end

function entMeta:CPPICanPickup(ply)
	return DPP.CanGravgun(ply, self) ~= false
end

function entMeta:CPPICanPunt(ply)
	return DPP.CanGravgunPunt(ply, self) ~= false
end

function entMeta:CPPICanUse(ply)
	return DPP.PlayerUse(ply, self) ~= false
end

entMeta.CPPIIsOwned = DPP.IsOwned

--Generic check
entMeta.CPPICanTouch = DPP.CanTouch

hook.Add('DPP.AssignOwnership', 'DPP.CPPI', function(ply, ent)
	return hook.Run('CPPIAssignOwnership', ply, ent)
end)

hook.Add('DPP.CanTouch', 'DPP.CPPI', function(ply, ent)
	return hook.Run('CPPICanTouch', ply, ent)
end)

--Procedual model

CPPI.GetFriends = DPP.GetFriendTableCPPI

function CPPI.GetOwner(self)
	local o = DPP.GetOwner(self)
	if not IsValid(o) then return nil, nil end

	return o, o:UniqueID()
end

if SERVER then
	function CPPI.SetOwner(self, ply)
		DPP.SetOwner(self, ply)
	end

	function CPPI.SetOwnerUID(self, uid)
		local ply = player.GetByUniqueID(uid)
		if not ply then
			DPP.SetOwner(self, NULL)
		else
			DPP.SetOwner(self, ply)
		end
	end

	CPPI.GetProps = DPP.GetPlayerEntities
	CPPI.GetEntitites = DPP.GetPlayerEntities
	CPPI.GetEnts = DPP.GetPlayerEntities
end

function CPPI.CanDamage(self, ply)
	return DPP.CanDamage(ply, self) ~= false
end

function CPPI.CanTool(self, ply, mode)
	return DPP.CanTool(ply, self, mode) ~= false
end

function CPPI.Drive(self, ply)
	return DPP.CanDrive(ply, self) ~= false
end

function CPPI.CanEditVariable(self, ply, key, val, editor)
	return DPP.CanEditVariable(self, ply, key, val, editor) ~= false
end

function CPPI.CanProperty(self, ply, str)
	return DPP.CanProperty(ply, str, ent) ~= false
end

function CPPI.CanPhysgun(self, ply)
	return DPP.CanPhysgun(ply, self) ~= false
end

function CPPI.CanPickup(self, ply)
	return DPP.CanGravgun(ply, self) ~= false
end

function CPPI.CanPunt(self, ply)
	return DPP.CanGravgunPunt(ply, self) ~= false
end

function CPPI.CanUse(self, ply)
	return DPP.PlayerUse(ply, self) ~= false
end

CPPI.IsOwned = DPP.IsOwned

--Generic check
CPPI.CanTouch = DPP.CanTouch
