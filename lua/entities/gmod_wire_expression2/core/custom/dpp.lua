
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

__e2setcost(10)

e2function entity entity:getOwner()
	if not IsValid(this) then return NULL end
	return DPP.GetOwner(this)
end

e2function number entity:setOwner(entity owner)
	if not IsValid(this) then return 0 end
	if DPP.GetOwner(this) ~= self.player then return 0 end --Not a owner
	
	DPP.DeleteEntityUndo(this)
	DPP.SetOwner(this, owner or NULL)
	
	if IsValid(owner) and owner:IsPlayer() then
		undo.Create('TransferedProp')
		undo.SetPlayer(owner)
		undo.AddEntity(this)
		undo.Finish()
	end
	
	DPP.SimpleLog(self.player, Gray, ' transfered ownership of ', this, Gray, ' to ', owner or 'world', Gray, ' using Expression2')
	
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

__e2setcost(50)

e2function array getOwnedProps()
	if not IsValid(self.player) then return {} end
	return DPP.GetPropsByUID(self.player:UniqueID())
end
