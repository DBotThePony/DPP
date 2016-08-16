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


e2function number dppIsExcludedUse(string class)
	return DPP.IsEntityWhitelistedUse(class) and 1 or 0
end

e2function number dppIsEvenExcludedUse(string class)
	return DPP.IsEvenWhitelistedUse(class) and 1 or 0
end

e2function number dppIsExcludedUse(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedUse(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedUse(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedUse(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedUse(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedUse(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedUse(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedUse(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedPhysgun(string class)
	return DPP.IsEntityWhitelistedPhysgun(class) and 1 or 0
end

e2function number dppIsEvenExcludedPhysgun(string class)
	return DPP.IsEvenWhitelistedPhysgun(class) and 1 or 0
end

e2function number dppIsExcludedPhysgun(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedPhysgun(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedPhysgun(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedPhysgun(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedPhysgun(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedPhysgun(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedPhysgun(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedPhysgun(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedTool(string class)
	return DPP.IsEntityWhitelistedTool(class) and 1 or 0
end

e2function number dppIsEvenExcludedTool(string class)
	return DPP.IsEvenWhitelistedTool(class) and 1 or 0
end

e2function number dppIsExcludedTool(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedTool(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedTool(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedTool(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedTool(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedTool(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedTool(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedTool(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedPickup(string class)
	return DPP.IsEntityWhitelistedPickup(class) and 1 or 0
end

e2function number dppIsEvenExcludedPickup(string class)
	return DPP.IsEvenWhitelistedPickup(class) and 1 or 0
end

e2function number dppIsExcludedPickup(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedPickup(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedPickup(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedPickup(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedPickup(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedPickup(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedPickup(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedPickup(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedProperty(string class)
	return DPP.IsEntityWhitelistedProperty(class) and 1 or 0
end

e2function number dppIsEvenExcludedProperty(string class)
	return DPP.IsEvenWhitelistedProperty(class) and 1 or 0
end

e2function number dppIsExcludedProperty(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedProperty(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedProperty(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedProperty(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedProperty(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedProperty(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedProperty(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedProperty(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedGravgun(string class)
	return DPP.IsEntityWhitelistedGravgun(class) and 1 or 0
end

e2function number dppIsEvenExcludedGravgun(string class)
	return DPP.IsEvenWhitelistedGravgun(class) and 1 or 0
end

e2function number dppIsExcludedGravgun(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedGravgun(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedGravgun(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedGravgun(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedGravgun(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedGravgun(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedGravgun(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedGravgun(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedPropertyType(string class)
	return DPP.IsEntityWhitelistedPropertyType(class) and 1 or 0
end

e2function number dppIsEvenExcludedPropertyType(string class)
	return DPP.IsEvenWhitelistedPropertyType(class) and 1 or 0
end

e2function number dppIsExcludedPropertyType(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedPropertyType(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedPropertyType(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedPropertyType(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedPropertyType(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedPropertyType(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedPropertyType(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedPropertyType(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedDamage(string class)
	return DPP.IsEntityWhitelistedDamage(class) and 1 or 0
end

e2function number dppIsEvenExcludedDamage(string class)
	return DPP.IsEvenWhitelistedDamage(class) and 1 or 0
end

e2function number dppIsExcludedDamage(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedDamage(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedDamage(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedDamage(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedDamage(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedDamage(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedDamage(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedDamage(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedToolMode(string class)
	return DPP.IsEntityWhitelistedToolMode(class) and 1 or 0
end

e2function number dppIsEvenExcludedToolMode(string class)
	return DPP.IsEvenWhitelistedToolMode(class) and 1 or 0
end

e2function number dppIsExcludedToolMode(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedToolMode(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedToolMode(entity class)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedToolMode(class:GetClass()) and 1 or 0
end

e2function number dppIsExcludedToolMode(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEntityWhitelistedToolMode(class:GetClass()) and 1 or 0
end

e2function number dppIsEvenExcludedToolMode(number id)
	local class = Entity(id)
	if not IsValid(class) then return 0 end
	return DPP.IsEvenWhitelistedToolMode(class:GetClass()) and 1 or 0
end
