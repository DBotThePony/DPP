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

--This file was generated using e2simplefcompiler.lua in DPP directory

--Costs for each call
__e2setcost(10)


e2function number entity:dppIsRestrictedSWEP(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedSWEP(class, this) and 1 or 0
end

e2function number dppIsRestrictedSWEP(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedSWEP(class, self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedSWEP(string class)
	return DPP.IsEvenRestrictedSWEP(class) and 1 or 0
end

e2function number entity:dppIsRestrictedSWEP(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedSWEP(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedSWEP(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedSWEP(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedSWEP(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedSWEP(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedSWEP(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedSWEP(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedSWEP(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedSWEP(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedSWEP(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedSWEP(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedTool(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedTool(class, this) and 1 or 0
end

e2function number dppIsRestrictedTool(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedTool(class, self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedTool(string class)
	return DPP.IsEvenRestrictedTool(class) and 1 or 0
end

e2function number entity:dppIsRestrictedTool(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedTool(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedTool(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedTool(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedTool(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedTool(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedTool(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedTool(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedTool(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedTool(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedTool(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedTool(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedPickup(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedPickup(class, this) and 1 or 0
end

e2function number dppIsRestrictedPickup(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedPickup(class, self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedPickup(string class)
	return DPP.IsEvenRestrictedPickup(class) and 1 or 0
end

e2function number entity:dppIsRestrictedPickup(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedPickup(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedPickup(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedPickup(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedPickup(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedPickup(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedPickup(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedPickup(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedPickup(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedPickup(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedPickup(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedPickup(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedVehicle(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedVehicle(class, this) and 1 or 0
end

e2function number dppIsRestrictedVehicle(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedVehicle(class, self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedVehicle(string class)
	return DPP.IsEvenRestrictedVehicle(class) and 1 or 0
end

e2function number entity:dppIsRestrictedVehicle(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedVehicle(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedVehicle(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedVehicle(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedVehicle(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedVehicle(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedVehicle(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedVehicle(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedVehicle(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedVehicle(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedVehicle(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedVehicle(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedProperty(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedProperty(class, this) and 1 or 0
end

e2function number dppIsRestrictedProperty(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedProperty(class, self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedProperty(string class)
	return DPP.IsEvenRestrictedProperty(class) and 1 or 0
end

e2function number entity:dppIsRestrictedProperty(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedProperty(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedProperty(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedProperty(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedProperty(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedProperty(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedProperty(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedProperty(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedProperty(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedProperty(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedProperty(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedProperty(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedE2AFunction(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedE2AFunction(class, this) and 1 or 0
end

e2function number dppIsRestrictedE2AFunction(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedE2AFunction(class, self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedE2AFunction(string class)
	return DPP.IsEvenRestrictedE2AFunction(class) and 1 or 0
end

e2function number entity:dppIsRestrictedE2AFunction(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedE2AFunction(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedE2AFunction(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedE2AFunction(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedE2AFunction(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedE2AFunction(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedE2AFunction(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedE2AFunction(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedE2AFunction(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedE2AFunction(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedE2AFunction(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedE2AFunction(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedNPC(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedNPC(class, this) and 1 or 0
end

e2function number dppIsRestrictedNPC(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedNPC(class, self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedNPC(string class)
	return DPP.IsEvenRestrictedNPC(class) and 1 or 0
end

e2function number entity:dppIsRestrictedNPC(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedNPC(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedNPC(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedNPC(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedNPC(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedNPC(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedNPC(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedNPC(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedNPC(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedNPC(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedNPC(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedNPC(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedSENT(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedSENT(class, this) and 1 or 0
end

e2function number dppIsRestrictedSENT(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedSENT(class, self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedSENT(string class)
	return DPP.IsEvenRestrictedSENT(class) and 1 or 0
end

e2function number entity:dppIsRestrictedSENT(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedSENT(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedSENT(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedSENT(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedSENT(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedSENT(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedSENT(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedSENT(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedSENT(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedSENT(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedSENT(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedSENT(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedE2Function(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedE2Function(class, this) and 1 or 0
end

e2function number dppIsRestrictedE2Function(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedE2Function(class, self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedE2Function(string class)
	return DPP.IsEvenRestrictedE2Function(class) and 1 or 0
end

e2function number entity:dppIsRestrictedE2Function(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedE2Function(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedE2Function(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedE2Function(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedE2Function(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedE2Function(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedE2Function(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedE2Function(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedE2Function(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedE2Function(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedE2Function(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedE2Function(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedModel(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedModel(class, this) and 1 or 0
end

e2function number dppIsRestrictedModel(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedModel(class, self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedModel(string class)
	return DPP.IsEvenRestrictedModel(class) and 1 or 0
end

e2function number entity:dppIsRestrictedModel(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(this) then return 0 end
	return DPP.IsRestrictedModel(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedModel(entity class)
	if not IsValid(class) then return 0 end
	if not IsValid(self.player) then return 0 end
	return DPP.IsRestrictedModel(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedModel(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedModel(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsRestrictedModel(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedModel(class:GetClass(), this) and 1 or 0
end

e2function number dppIsRestrictedModel(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsRestrictedModel(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenRestrictedModel(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenRestrictedModel(class:GetClass()) and 1 or 0
end
