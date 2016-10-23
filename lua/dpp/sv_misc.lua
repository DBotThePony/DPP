
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

--Misc Functions

local URS_Import = {
	npc = 'NPC',
	pickup = 'Pickup',
	sent = 'SENT',
	swep = 'SWEP',
	tool = 'Tool',
	vehicle = 'Vehicle',
}

local URS_Limits = {
	prop = 'props',
	vehicle = 'vehicles',
	ragdoll = 'ragdolls',
	npc = 'npcs',
	sent = 'sents',
	effect = 'effects',
}

local function FakePrint(ply, message)
	if not IsValid(ply) then
		print(message)
	else
		ply:ChatPrint(message)
	end
end

concommand.Add('dpp_importurs', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not URS then DPP.Notify(ply, 'There is no URS installed! Nothing to import.') return end
	local R = URS.restrictions
	local L = URS.limits
	if (not R or table.Count(R) < 1) and (not L or table.Count(L) < 1) then DPP.Notify(ply, 'Nothing to import.') return end

	local isTest = not tobool(args[1])

	R = R or {}
	L = L or {}
	local Props = R.prop
	local Ragdolls = R.ragdoll

	local imported = 0

	for k, v in pairs(URS_Import) do
		local tab = R[k]
		if not tab then
			for class, groups in pairs(tab) do
				if not istable(groups) then continue end
				if type(class) ~= 'string' then continue end
				if table.Count(groups) == 0 then continue end

				if not isTest then
					DPP['Restrict' .. v](class, groups, false)
				else
					FakePrint(ply, string.format('[DPP] Restrict: %s from %s', class, table.concat(groups, ',')))
				end
				imported = imported + 1
			end
		end
	end

	if Props then
		for model, groups in pairs(Props) do
			if not istable(groups) then continue end
			if not isstring(model) then continue end
			if table.Count(groups) == 0 then continue end

			if not isTest then
				DPP.RestrictModel(model, groups, false)
			else
				FakePrint(ply, string.format('[DPP] Restrict: %s from %s', model, table.concat(groups, ',')))
			end
			imported = imported + 1
		end
	end

	if Ragdolls then
		for model, groups in pairs(Ragdolls) do
			if not istable(groups) then continue end
			if not isstring(model) then continue end
			if table.Count(groups) == 0 then continue end

			if not isTest then
				DPP.RestrictModel(model, groups, false)
			else
				FakePrint(ply, string.format('[DPP] Restrict: %s from %s', model, table.concat(groups, ',')))
			end
			
			imported = imported + 1
		end
	end
	
	for toFix, fixed in pairs(URS_Limits) do
		if L[toFix] then
			for group, limit in pairs(L[toFix]) do
				local num = tonumber(limit)
				
				if num then
					if not isTest then
						DPP.AddSBoxLimit(fixed, group, num)
					else
						FakePrint(ply, string.format('[DPP] Limit: %s from %s at %s amount', fixed, group, num))
					end
					
					imported = imported + 1
				end
			end
		end
	end

	if not isTest then
		DPP.SimpleLog(IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' Imported Restrictions and Limits from URS. Total items imported: ' .. imported)
	else
		FakePrint(ply, 'Total items: ' .. imported)
		FakePrint(ply, 'This was a test-print, changes does not applied')
		FakePrint(ply, 'To apply, write dpp_importurs 1')
	end
end)

local FPP_Blocked = {
	Gravgun1 = 'Gravgun',
	Physgun1 = 'Physgun',
	Toolgun1 = 'Tool',
	EntityDamage1 = 'Damage',
}

concommand.Add('dpp_importfpp', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end

	FakePrint(ply, '[DPP] NOTE: DPP imports FPP lists from database, where DPP is running on!')

	local isTest = not tobool(args[1])

	DPP.Query('SELECT * FROM fpp_blockedmodels1', function(data)
		if not data then return end

		local count = 0

		for k, row in pairs(data) do
			local model = row.model

			count = count + 1

			if isTest then
				FakePrint(ply, string.format('[DPP] Block model: %s', model))
			else
				DPP.AddBlockedModel(model)
			end
		end

		if isTest then
			FakePrint(ply, '[DPP] ----------------- End of model list test. Total: ' .. count)
			FakePrint(ply, '[DPP] Note: This is a test, to commit changes type dpp_importfpp 1')
		else
			DPP.SimpleLog(IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' Imported FPP blocked models. Total items imported: ' .. count)
		end
	end)

	DPP.Query('SELECT * FROM fpp_blocked1', function(data)
		if not data then return end

		local count = 0

		for k, row in pairs(data) do
			local Type = FPP_Blocked[row.var]
			if not Type then continue end

			count = count + 1

			if isTest then
				FakePrint(ply, string.format('[DPP] Block entity %s from %s touch', row.setting, Type))
			else
				DPP['AddBlockedEntity' .. Type](row.setting)
			end
		end

		if isTest then
			FakePrint(ply, '[DPP] ----------------- End of entity list test Total: ' .. count)
			FakePrint(ply, '[DPP] Note: This is a test, to commit changes type dpp_importfpp 1')
		else
			DPP.SimpleLog(IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' Imported FPP blocked entities. Total items imported: ' .. count)
		end
	end)

	DPP.Query('SELECT * FROM fpp_tooladminonly', function(data)
		if not data then return end

		local count = 0

		for k, row in pairs(data) do
			local tool = row.toolname
			local status = row.adminonly

			if tonumber(status) == 0 then continue end

			local admins
			if tonumber(status) == 1 then
				admins = {'admin', 'superadmin'}
			elseif tonumber(status) == 2 then
				admins = {'superadmin'}
			end

			count = count + 1

			if isTest then
				FakePrint(ply, string.format('[DPP] Restrict tool %s from %s', tool, table.concat(admins, ',')))
			else
				DPP.RestrictTool(tool, admins, true)
			end
		end

		if isTest then
			FakePrint(ply, '[DPP] ----------------- End of tool list test Total: ' .. count)
			FakePrint(ply, '[DPP] Note: This is a test, to commit changes type dpp_importfpp 1')
		else
			DPP.SimpleLog(IsValid(ply) and ply or 'Console', Color(200, 200, 200), ' Imported FPP restricted tools. Total tools imported: ' .. count)
		end
	end)
end)

local function KillAPAnti()
	if not APA then return end

	if not DPP.GetConVar('apanti_disable') then return end
	if not DPP.GetConVar('apropkill_enable') then return end
	if not DPP.GetConVar('apropkill_nopush') then return end

	DPP.Message('----------------------------------------')
	DPP.Message('APAnti has been detected!')
	DPP.Message('Forcing bugging CVars to be disabled')
	DPP.Message('The reason of that: CONFLICT. Props get ghosted')
	DPP.Message('Forever. If you want to use APAnti ghosting, you MUST')
	DPP.Message('disable Anti prop push in DPP, or set')
	DPP.Message('dpp_apanti_disable to 0 at your own risk')
	DPP.Message('----------------------------------------')

	RunConsoleCommand('apa_GhostPickup', '0')
	RunConsoleCommand('apa_GhostSpawn', '0')
	RunConsoleCommand('apa_GhostFreeze', '0')
	RunConsoleCommand('apa_UnGhostPassive', '0')
	RunConsoleCommand('apa_GhostsNoCollide', '0')
end

timer.Simple(4, KillAPAnti)
