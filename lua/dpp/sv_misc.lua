
--Misc Functions

local URS_Import = {
	npc = 'NPC',
	pickup = 'Pickup',
	sent = 'SENT',
	swep = 'SWEP',
	tool = 'Tool',
	vehicle = 'Vehicle',
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
	if not R or table.Count(R) < 1 then DPP.Notify(ply, 'Nothing to import.') return end
	
	local isTest = not tobool(args[1])
	
	local Props = R.prop
	local Ragdolls = R.ragdoll
	
	local imported = 0
	
	for k, v in pairs(URS_Import) do
		local tab = R[k]
		if not tab then continue end
		
		for class, groups in pairs(tab) do
			if not istable(groups) then continue end
			if table.Count(groups) == 0 then continue end
			
			if not isTest then
				DPP['Restrict' .. v](class, groups, false)
			else
				FakePrint(ply, string.format('[DPP] Restrict: %s from %s', class, table.concat(groups, ',')))
			end
			imported = imported + 1
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
	
	if not isTest then
		DPP.DoEcho({IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' Imported Restrictions from URS. Total items imported: ' .. imported})
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
			DPP.DoEcho({IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' Imported FPP blocked models. Total items imported: ' .. count})
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
			DPP.DoEcho({IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' Imported FPP blocked entities. Total items imported: ' .. count})
		end
	end)
end)
