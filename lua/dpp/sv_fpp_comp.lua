
--FPP Funcs compability

FPP = FPP or {}

function FPP.plyCanTouchEnt(ply, ent, type)
	if not type then --We are ignoring type
		return DPP.CanTouch(ply, ent)
	end
	
	if type == 'Physgun' then
		return DPP.CanPhysgun(ply, ent)
	elseif type == 'Gravgun' then
		return DPP.CanGravgun(ply, ent)
	elseif type == 'Toolgun' then
		return DPP.CanTool(ply, ent)
	elseif type == 'PlayerUse' then
		return DPP.PlayerUse(ply, ent)
	elseif type == 'EntityDamage' then
		return DPP.CanDamage(ply, ent)
	end
		
	return DPP.CanTouch(ply, ent)
end

concommand.Add('FPP_AddBlockedModel', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	DPP.AddBlockedModel(args[1])
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' added ' .. args[1] .. ' to model blacklist/whitelist'}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
end)

concommand.Add('FPP_RemoveBlockedModel', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] or args[1] == '' or args[1] == ' ' then DPP.Notify(ply, 'Invalid argument') return end
	DPP.RemoveBlockedModel(args[1])
	local f = {IsValid(ply) and team.GetColor(ply:Team()) or Color(196, 0, 255), (IsValid(ply) and ply:Nick() or 'Console'), Color(200, 200, 200), ' removed ' .. args[1] .. ' to model blacklist/whitelist'}
	DPP.Notify(player.GetAll(), f)
	DPP.Message(f)
end)
