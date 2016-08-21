
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

local header = [==[
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

]==]

local output1 = {header}
local output2 = {header}
local output3 = {header}

for k, v in pairs(DPP.BlockTypes) do
	--String
	table.insert(output1, 'e2function number entity:dppIsBlocked' .. v .. '(string class)')
	table.insert(output1, '	if not IsValid(this) then return 0 end')
	table.insert(output1, '	return DPP.IsEntityBlocked' .. v .. '(class, this) and 1 or 0')
	table.insert(output1, 'end\n')

	table.insert(output1, 'e2function number dppIsBlocked' .. v .. '(string class)')
	table.insert(output1, '	if not IsValid(self.player) then return 0 end')
	table.insert(output1, '	return DPP.IsEntityBlocked' .. v .. '(class, self.player) and 1 or 0')
	table.insert(output1, 'end\n')

	table.insert(output1, 'e2function number dppIsEvenBlocked' .. v .. '(string class)')
	table.insert(output1, '	return DPP.IsEvenBlocked' .. v .. '(class) and 1 or 0')
	table.insert(output1, 'end\n')

	--Entity
	table.insert(output1, 'e2function number entity:dppIsBlocked' .. v .. '(entity class)')
	table.insert(output1, '	if not IsValid(this) then return 0 end')
	table.insert(output1, '	if not IsValid(class) then return 0 end')
	table.insert(output1, '	return DPP.IsEntityBlocked' .. v .. '(class:GetClass(), this) and 1 or 0')
	table.insert(output1, 'end\n')

	table.insert(output1, 'e2function number dppIsBlocked' .. v .. '(entity class)')
	table.insert(output1, '	if not IsValid(self.player) then return 0 end')
	table.insert(output1, '	if not IsValid(class) then return 0 end')
	table.insert(output1, '	return DPP.IsEntityBlocked' .. v .. '(class:GetClass(), self.player) and 1 or 0')
	table.insert(output1, 'end\n')

	table.insert(output1, 'e2function number dppIsEvenBlocked' .. v .. '(entity class)')
	table.insert(output1, '	if not IsValid(class) then return 0 end')
	table.insert(output1, '	return DPP.IsEvenBlocked' .. v .. '(class:GetClass()) and 1 or 0')
	table.insert(output1, 'end\n')

	--Entity network ID
	table.insert(output1, 'e2function number entity:dppIsBlocked' .. v .. '(number id)')
	table.insert(output1, '	local class = Entity(id)')
	table.insert(output1, '	if not IsValid(this) then return 0 end')
	table.insert(output1, '	if not IsValid(class) then return 0 end')
	table.insert(output1, '	return DPP.IsEntityBlocked' .. v .. '(class:GetClass(), this) and 1 or 0')
	table.insert(output1, 'end\n')

	table.insert(output1, 'e2function number dppIsBlocked' .. v .. '(number id)')
	table.insert(output1, '	local class = Entity(id)')
	table.insert(output1, '	if not IsValid(self.player) then return 0 end')
	table.insert(output1, '	if not IsValid(class) then return 0 end')
	table.insert(output1, '	return DPP.IsEntityBlocked' .. v .. '(class:GetClass(), self.player) and 1 or 0')
	table.insert(output1, 'end\n')

	table.insert(output1, 'e2function number dppIsEvenBlocked' .. v .. '(number id)')
	table.insert(output1, '	local class = Entity(id)')
	table.insert(output1, '	if not IsValid(class) then return 0 end')
	table.insert(output1, '	return DPP.IsEvenBlocked' .. v .. '(class:GetClass()) and 1 or 0')
	table.insert(output1, 'end\n')
end

for k, v in pairs(DPP.RestrictTypes) do
	--String
	table.insert(output2, 'e2function number entity:dppIsRestricted' .. v .. '(string class)')
	table.insert(output2, '	if not IsValid(this) then return 0 end')
	table.insert(output2, '	return DPP.IsRestricted' .. v .. '(class, this) and 1 or 0')
	table.insert(output2, 'end\n')

	table.insert(output2, 'e2function number dppIsRestricted' .. v .. '(string class)')
	table.insert(output2, '	if not IsValid(self.player) then return 0 end')
	table.insert(output2, '	return DPP.IsRestricted' .. v .. '(class, self.player) and 1 or 0')
	table.insert(output2, 'end\n')

	table.insert(output2, 'e2function number dppIsEvenRestricted' .. v .. '(string class)')
	table.insert(output2, '	return DPP.IsEvenRestricted' .. v .. '(class) and 1 or 0')
	table.insert(output2, 'end\n')

	--Entity
	table.insert(output2, 'e2function number entity:dppIsRestricted' .. v .. '(entity class)')
	table.insert(output2, '	if not IsValid(class) then return 0 end')
	table.insert(output2, '	if not IsValid(this) then return 0 end')
	table.insert(output2, '	return DPP.IsRestricted' .. v .. '(class:GetClass(), this) and 1 or 0')
	table.insert(output2, 'end\n')

	table.insert(output2, 'e2function number dppIsRestricted' .. v .. '(entity class)')
	table.insert(output2, '	if not IsValid(class) then return 0 end')
	table.insert(output2, '	if not IsValid(self.player) then return 0 end')
	table.insert(output2, '	return DPP.IsRestricted' .. v .. '(class:GetClass(), self.player) and 1 or 0')
	table.insert(output2, 'end\n')

	table.insert(output2, 'e2function number dppIsEvenRestricted' .. v .. '(entity class)')
	table.insert(output2, '	if not IsValid(class) then return 0 end')
	table.insert(output2, '	return DPP.IsEvenRestricted' .. v .. '(class:GetClass()) and 1 or 0')
	table.insert(output2, 'end\n')

	--Entity network ID
	table.insert(output2, 'e2function number entity:dppIsRestricted' .. v .. '(number id)')
	table.insert(output2, '	local class = Entity(id)')
	table.insert(output2, '	if not IsValid(this) then return 0 end')
	table.insert(output2, '	if not IsValid(class) then return 0 end')
	table.insert(output2, '	return DPP.IsRestricted' .. v .. '(class:GetClass(), this) and 1 or 0')
	table.insert(output2, 'end\n')

	table.insert(output2, 'e2function number dppIsRestricted' .. v .. '(number id)')
	table.insert(output2, '	local class = Entity(id)')
	table.insert(output2, '	if not IsValid(self.player) then return 0 end')
	table.insert(output2, '	if not IsValid(class) then return 0 end')
	table.insert(output2, '	return DPP.IsRestricted' .. v .. '(class:GetClass(), self.player) and 1 or 0')
	table.insert(output2, 'end\n')

	table.insert(output2, 'e2function number dppIsEvenRestricted' .. v .. '(number id)')
	table.insert(output2, '	local class = Entity(id)')
	table.insert(output2, '	if not IsValid(class) then return 0 end')
	table.insert(output2, '	return DPP.IsEvenRestricted' .. v .. '(class:GetClass()) and 1 or 0')
	table.insert(output2, 'end\n')
end

for k, v in pairs(DPP.WhitelistTypes) do
	--String
	table.insert(output3, 'e2function number dppIsExcluded' .. v .. '(string class)')
	table.insert(output3, '	return DPP.IsEntityWhitelisted' .. v .. '(class) and 1 or 0')
	table.insert(output3, 'end\n')

	table.insert(output3, 'e2function number dppIsEvenExcluded' .. v .. '(string class)')
	table.insert(output3, '	return DPP.IsEvenWhitelisted' .. v .. '(class) and 1 or 0')
	table.insert(output3, 'end\n')

	--Entity
	table.insert(output3, 'e2function number dppIsExcluded' .. v .. '(entity class)')
	table.insert(output3, '	if not IsValid(class) then return 0 end')
	table.insert(output3, '	return DPP.IsEntityWhitelisted' .. v .. '(class:GetClass()) and 1 or 0')
	table.insert(output3, 'end\n')

	table.insert(output3, 'e2function number dppIsEvenExcluded' .. v .. '(entity class)')
	table.insert(output3, '	if not IsValid(class) then return 0 end')
	table.insert(output3, '	return DPP.IsEvenWhitelisted' .. v .. '(class:GetClass()) and 1 or 0')
	table.insert(output3, 'end\n')

	--Entity network ID
	table.insert(output3, 'e2function number dppIsExcluded' .. v .. '(number id)')
	table.insert(output3, '	local class = Entity(id)')
	table.insert(output3, '	if not IsValid(class) then return 0 end')
	table.insert(output3, '	return DPP.IsEntityWhitelisted' .. v .. '(class:GetClass()) and 1 or 0')
	table.insert(output3, 'end\n')

	table.insert(output3, 'e2function number dppIsEvenExcluded' .. v .. '(number id)')
	table.insert(output3, '	local class = Entity(id)')
	table.insert(output3, '	if not IsValid(class) then return 0 end')
	table.insert(output3, '	return DPP.IsEvenWhitelisted' .. v .. '(class:GetClass()) and 1 or 0')
	table.insert(output3, 'end\n')
end

function DPP.DumpCompiledE2()
	file.Write('dpp_compilede2_1.txt', table.concat(output1, '\n'))
	file.Write('dpp_compilede2_2.txt', table.concat(output2, '\n'))
	file.Write('dpp_compilede2_3.txt', table.concat(output3, '\n'))
end

return output1, output2, output3
