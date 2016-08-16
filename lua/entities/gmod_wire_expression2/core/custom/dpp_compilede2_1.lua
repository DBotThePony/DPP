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


e2function number entity:dppIsBlockedUse(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsEntityBlockedUse(class, this) and 1 or 0
end

e2function number dppIsBlockedUse(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsEntityBlockedUse(class, self.player) and 1 or 0
end

e2function number dppIsEvenBlockedUse(string class)
	return DPP.IsEvenBlockedUse(class) and 1 or 0
end

e2function number entity:dppIsBlockedUse(entity class)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedUse(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedUse(entity class)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedUse(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedUse(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedUse(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsBlockedUse(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedUse(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedUse(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedUse(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedUse(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedUse(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsBlockedPhysgun(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsEntityBlockedPhysgun(class, this) and 1 or 0
end

e2function number dppIsBlockedPhysgun(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsEntityBlockedPhysgun(class, self.player) and 1 or 0
end

e2function number dppIsEvenBlockedPhysgun(string class)
	return DPP.IsEvenBlockedPhysgun(class) and 1 or 0
end

e2function number entity:dppIsBlockedPhysgun(entity class)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedPhysgun(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedPhysgun(entity class)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedPhysgun(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedPhysgun(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedPhysgun(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsBlockedPhysgun(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedPhysgun(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedPhysgun(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedPhysgun(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedPhysgun(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedPhysgun(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsBlockedTool(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsEntityBlockedTool(class, this) and 1 or 0
end

e2function number dppIsBlockedTool(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsEntityBlockedTool(class, self.player) and 1 or 0
end

e2function number dppIsEvenBlockedTool(string class)
	return DPP.IsEvenBlockedTool(class) and 1 or 0
end

e2function number entity:dppIsBlockedTool(entity class)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedTool(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedTool(entity class)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedTool(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedTool(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedTool(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsBlockedTool(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedTool(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedTool(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedTool(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedTool(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedTool(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsBlockedToolgunWorld(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsEntityBlockedToolgunWorld(class, this) and 1 or 0
end

e2function number dppIsBlockedToolgunWorld(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsEntityBlockedToolgunWorld(class, self.player) and 1 or 0
end

e2function number dppIsEvenBlockedToolgunWorld(string class)
	return DPP.IsEvenBlockedToolgunWorld(class) and 1 or 0
end

e2function number entity:dppIsBlockedToolgunWorld(entity class)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedToolgunWorld(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedToolgunWorld(entity class)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedToolgunWorld(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedToolgunWorld(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedToolgunWorld(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsBlockedToolgunWorld(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedToolgunWorld(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedToolgunWorld(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedToolgunWorld(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedToolgunWorld(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedToolgunWorld(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsBlockedDamage(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsEntityBlockedDamage(class, this) and 1 or 0
end

e2function number dppIsBlockedDamage(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsEntityBlockedDamage(class, self.player) and 1 or 0
end

e2function number dppIsEvenBlockedDamage(string class)
	return DPP.IsEvenBlockedDamage(class) and 1 or 0
end

e2function number entity:dppIsBlockedDamage(entity class)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedDamage(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedDamage(entity class)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedDamage(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedDamage(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedDamage(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsBlockedDamage(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedDamage(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedDamage(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedDamage(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedDamage(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedDamage(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsBlockedPickup(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsEntityBlockedPickup(class, this) and 1 or 0
end

e2function number dppIsBlockedPickup(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsEntityBlockedPickup(class, self.player) and 1 or 0
end

e2function number dppIsEvenBlockedPickup(string class)
	return DPP.IsEvenBlockedPickup(class) and 1 or 0
end

e2function number entity:dppIsBlockedPickup(entity class)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedPickup(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedPickup(entity class)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedPickup(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedPickup(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedPickup(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsBlockedPickup(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedPickup(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedPickup(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedPickup(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedPickup(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedPickup(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsBlockedGravgun(string class)
	if not IsValid(this) then return 0 end
	return DPP.IsEntityBlockedGravgun(class, this) and 1 or 0
end

e2function number dppIsBlockedGravgun(string class)
	if not IsValid(self.player) then return 0 end
	return DPP.IsEntityBlockedGravgun(class, self.player) and 1 or 0
end

e2function number dppIsEvenBlockedGravgun(string class)
	return DPP.IsEvenBlockedGravgun(class) and 1 or 0
end

e2function number entity:dppIsBlockedGravgun(entity class)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedGravgun(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedGravgun(entity class)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedGravgun(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedGravgun(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedGravgun(class:GetClass()) and 1 or 0
end

e2function number entity:dppIsBlockedGravgun(number id)
	local class = Entity(id)
	if not IsValid(this) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedGravgun(class:GetClass(), this) and 1 or 0
end

e2function number dppIsBlockedGravgun(number id)
	local class = Entity(id)
	if not IsValid(self.player) then return 0 end
	if not IsValid(class) then return 0 end
	return DPP.IsEntityBlockedGravgun(class:GetClass(), self.player) and 1 or 0
end

e2function number dppIsEvenBlockedGravgun(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenBlockedGravgun(class:GetClass()) and 1 or 0
end
