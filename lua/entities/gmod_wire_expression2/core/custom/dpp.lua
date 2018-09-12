
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

local Gray = Color(200, 200, 200)

__e2setcost(10)

e2function entity entity:getOwner()
	if not IsValid(this) then return NULL end
	return DPP.GetOwner(this)
end

e2function number entity:setOwner(entity owner)
	if not IsValid(this) then return 0 end
	if DPP.GetOwner(this) ~= self.player then return 0 end --Not a owner
	if IsValid(owner) and not owner:IsPlayer() then return 0 end

	DPP.DeleteEntityUndo(this)
	DPP.SetOwner(this, owner or NULL)

	if IsValid(owner) then
		undo.Create('TransferedProp')
		undo.SetPlayer(owner)
		undo.AddEntity(this)
		undo.Finish()
	end

	DPP.SimpleLog(self.player, Gray, ' transfered ownership of ', this, Gray, ' to ', owner or 'world', Gray, ' using Expression2')

	return 1
end

e2function number entity:setOwner()
	if not IsValid(this) then return 0 end
	if DPP.GetOwner(this) ~= self.player then return 0 end --Not a owner

	DPP.DeleteEntityUndo(this)
	DPP.SetOwner(this, NULL)

	DPP.SimpleLog(self.player, Gray, ' transfered ownership of ', this, Gray, ' to ', 'world', Gray, ' using Expression2')

	return 1
end

e2function number entity:isGhosted()
	if not IsValid(this) then return 0 end
	return DPP.IsGhosted(this) and 1 or 0
end

e2function number entity:isOwnedByLocalPlayer()
	if not IsValid(this) then return 0 end
	return DPP.GetOwner(this) == self.player and 1 or 0
end

e2function number entity:isSingleOwner()
	if not IsValid(this) then return 0 end
	return DPP.IsSingleOwner(this, DPP.GetOwner(this)) and 1 or 0
end

e2function number entity:isUpForGrabs()
	if not IsValid(this) then return 0 end
	return DPP.IsUpForGrabs(this) and 1 or 0
end

e2function number entity:isShared()
	if not IsValid(this) then return 0 end
	return DPP.IsShared(this) and 1 or 0
end

e2function number entity:isSharedType(string type)
	if not IsValid(this) then return 0 end
	return DPP.IsSharedType(this, type) and 1 or 0
end

e2function number isModelBlocked(string model)
	if not IsValid(self.player) then return 1 end
	return DPP.IsModelBlocked(model, self.player, true) and 1 or 0
end

--Protection functions

e2function number entity:dppCanDamage()
	if not IsValid(this) then return 0 end
	if not IsValid(self.player) then return 1 end
	return DPP.CanDamage(self.player, this) and 1 or 0
end

e2function number entity:dppCanGravgun()
	if not IsValid(this) then return 0 end
	if not IsValid(self.player) then return 1 end
	return DPP.CanGravgun(self.player, this) and 1 or 0
end

e2function number entity:dppCanGravgunPunt()
	if not IsValid(this) then return 0 end
	if not IsValid(self.player) then return 1 end
	return DPP.CanGravgunPunt(self.player, this) and 1 or 0
end

e2function number entity:dppCanTool(string mode)
	if not IsValid(this) then return 0 end
	if not IsValid(self.player) then return 1 end
	return DPP.CanTool(self.player, this, mode) and 1 or 0
end

e2function number entity:dppCanTool()
	if not IsValid(this) then return 0 end
	if not IsValid(self.player) then return 1 end
	return DPP.CanTool(self.player, this, '') and 1 or 0
end

e2function number entity:dppCanEnterVehicle()
	if not IsValid(this) then return 0 end
	if not IsValid(self.player) then return 1 end
	return DPP.CanPlayerEnterVehicle(self.player, this) and 1 or 0
end

e2function number entity:dppCanEditVariable(string key)
	if not IsValid(this) then return 0 end
	if not IsValid(self.player) then return 1 end
	return DPP.CanEditVariable(self.player, this, key) and 1 or 0
end

e2function number entity:dppCanProperty(string property)
	if not IsValid(this) then return 0 end
	if not IsValid(self.player) then return 1 end
	return DPP.CanProperty(self.player, property, this) and 1 or 0
end

e2function number entity:dppCanProperty()
	if not IsValid(this) then return 0 end
	if not IsValid(self.player) then return 1 end
	return DPP.CanProperty(self.player, '', this) and 1 or 0
end

e2function number entity:dppCanUse()
	if not IsValid(this) then return 0 end
	if not IsValid(self.player) then return 1 end
	return DPP.PlayerUse(self.player, this) and 1 or 0
end

e2function number entity:dppCanDrive()
	if not IsValid(this) then return 0 end
	if not IsValid(self.player) then return 1 end
	return DPP.CanDrive(self.player, this) and 1 or 0
end

--Player orentiated

--Using entity number
e2function number entity:dppCanDamage(number targetID)
	local target = Entity(targetID)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanDamage(this, target) and 1 or 0
end

e2function number entity:dppCanGravgun(number targetID)
	local target = Entity(targetID)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanGravgun(this, target) and 1 or 0
end

e2function number entity:dppCanGravgunPunt(number targetID)
	local target = Entity(targetID)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanGravgunPunt(this, target) and 1 or 0
end

e2function number entity:dppCanTool(number targetID, string mode)
	local target = Entity(targetID)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanTool(this, target, mode) and 1 or 0
end

e2function number entity:dppCanTool(number targetID)
	local target = Entity(targetID)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanTool(this, target, '') and 1 or 0
end

e2function number entity:dppCanEnterVehicle(number targetID)
	local target = Entity(targetID)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanPlayerEnterVehicle(this, target) and 1 or 0
end

e2function number entity:dppCanEditVariable(number targetID, string key)
	local target = Entity(targetID)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanEditVariable(this, target, key) and 1 or 0
end

e2function number entity:dppCanProperty(number targetID, string property)
	local target = Entity(targetID)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanProperty(this, property, target) and 1 or 0
end

e2function number entity:dppCanProperty(number targetID)
	local target = Entity(targetID)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanProperty(this, '', target) and 1 or 0
end

e2function number entity:dppCanUse(number targetID)
	local target = Entity(targetID)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.PlayerUse(this, target) and 1 or 0
end

e2function number entity:dppCanDrive(number targetID)
	local target = Entity(targetID)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanDrive(this, target) and 1 or 0
end

---------

--Using entity directly
e2function number entity:dppCanDamage(entity target)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanDamage(this, target) and 1 or 0
end

e2function number entity:dppCanGravgun(entity target)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanGravgun(this, target) and 1 or 0
end

e2function number entity:dppCanGravgunPunt(entity target)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanGravgunPunt(this, target) and 1 or 0
end

e2function number entity:dppCanTool(entity target, string mode)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanTool(this, target, mode) and 1 or 0
end

e2function number entity:dppCanTool(entity target)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanTool(this, target, '') and 1 or 0
end

e2function number entity:dppCanEnterVehicle(entity target)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanPlayerEnterVehicle(this, target) and 1 or 0
end

e2function number entity:dppCanEditVariable(entity target, string key)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanEditVariable(this, target, key) and 1 or 0
end

e2function number entity:dppCanProperty(entity target, string property)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanProperty(this, property, target) and 1 or 0
end

e2function number entity:dppCanProperty(entity target)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanProperty(this, '', target) and 1 or 0
end

e2function number entity:dppCanUse(entity target)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.PlayerUse(this, target) and 1 or 0
end

e2function number entity:dppCanDrive(entity target)
	if not IsValid(target) then return 0 end
	if not IsValid(this) then return 1 end
	if not this:IsPlayer() then return 0 end
	return DPP.CanDrive(this, target) and 1 or 0
end

--Limits

e2function number dppEntityHasLimit(entity arg)
	if not IsValid(arg) then return 0 end
	return DPP.EntityHasLimit(arg:GetClass()) and 1 or 0
end

e2function number dppEntityHasLimit(string arg)
	return DPP.EntityHasLimit(arg) and 1 or 0
end

e2function number dppSBoxLimitExists(entity arg)
	if not IsValid(arg) then return 0 end
	return DPP.SBoxLimitExists(arg:GetClass()) and 1 or 0
end

e2function number dppSBoxLimitExists(string arg)
	return DPP.SBoxLimitExists(arg) and 1 or 0
end

--Getting limits

e2function number dppGetSBoxLimit(string arg)
	if not IsValid(self.player) then return 0 end
	return DPP.GetSBoxLimit(arg, self.player:GetUserGroup())
end

e2function number entity:dppGetSBoxLimit(string arg)
	if not IsValid(this) then return 0 end
	if not this:IsPlayer() then return 0 end
	return DPP.GetSBoxLimit(arg, this:GetUserGroup())
end

e2function number dppGetEntityLimit(string arg)
	if not IsValid(self.player) then return 0 end
	return DPP.GetEntityLimit(arg, self.player:GetUserGroup())
end

e2function number entity:dppGetEntityLimit(string arg)
	if not IsValid(this) then return 0 end
	if not this:IsPlayer() then return 0 end
	return DPP.GetEntityLimit(arg, this:GetUserGroup())
end

e2function number dppGetEntityLimit(entity arg)
	if not IsValid(self.player) then return 0 end
	if not IsValid(arg) then return 0 end
	return DPP.GetEntityLimit(arg:GetClass(), self.player:GetUserGroup())
end

e2function number entity:dppGetEntityLimit(entity arg)
	if not IsValid(this) then return 0 end
	if not IsValid(arg) then return 0 end
	if not this:IsPlayer() then return 0 end
	return DPP.GetEntityLimit(arg:GetClass(), this:GetUserGroup())
end

__e2setcost(50)

e2function array getOwnedProps()
	if not IsValid(self.player) then return {} end
	return DPP.GetPropsByUID(self.player:UniqueID())
end
