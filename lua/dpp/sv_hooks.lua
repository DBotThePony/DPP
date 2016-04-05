
--HOOKS
local SpawnFunctions = {}
DPP.SpawnFunctions = SpawnFunctions

local function Spawned(ply, ent)
	DPP.SetOwner(ent, ply)
end

local IgnoreSpawn = {
	['env_spritetrail'] = true, --Using E2 to spawn prop with effect, it just fills up console
}

local GRAY = Color(200, 200, 200)
local RED = Color(255, 0, 0)

local function LogSpawn(ply, ent, type)
	if not DPP.GetConVar('log_spawns') then return end
	if IgnoreSpawn[ent:GetClass()] then return end
	DPP.DoEcho(team.GetColor(ply:Team()), ply:Nick(), color_white, '<' .. ply:SteamID() .. '>', GRAY, ' spawned ', color_white, ent:GetClass(), GRAY, string.format(' <%s | %s> (%s)', tostring(ent), ent:GetModel(), type or 'N/A'))
end

local function LogSpawnC(ply, class, type, model)
	if not DPP.GetConVar('log_spawns') then return end
	if IgnoreSpawn[class] then return end
	DPP.DoEcho(team.GetColor(ply:Team()), ply:Nick(), color_white, '<' .. ply:SteamID() .. '>', GRAY, ' spawned ', color_white, class, GRAY, string.format(' <%s | %s> (%s)', class, model or 'N/A', type or 'N/A'))
end

local function LogTry(ply, type, model, class)
	if not DPP.GetConVar('log_spawns') then return end
	if IgnoreSpawn[class] then return end
	DPP.DoEcho(team.GetColor(ply:Team()), ply:Nick(), color_white, '<' .. ply:SteamID() .. '>', RED, ' tried ', GRAY, string.format('to spawn %s <%s | %s> (%s)', class or 'N/A', class or 'N/A', model or 'N/A', type or 'N/A'))
end

local function LogTryPost(ply, type, ent)
	if not DPP.GetConVar('log_spawns') then return end
	if IgnoreSpawn[ent:GetClass()] then return end
	DPP.DoEcho(team.GetColor(ply:Team()), ply:Nick(), color_white, '<' .. ply:SteamID() .. '>', RED, ' tried ', GRAY, string.format('to spawn %s <%s | %s> (%s)', ent:GetClass(), tostring(ent), ent:GetModel(), type or 'N/A'))
end

local function CheckEntityLimit(ply, class)
	if not DPP.IsEnabled() then return end
	local limit = DPP.GetEntityLimit(class, ply:GetUserGroup())
	if limit <= 0 then return false end

	local count = #DPP.FindEntitesByClass(ply,	class)
	local status = count + 1 > limit
	if status then
		DPP.Notify(ply, 'You hit ' .. class .. ' limit!', 1)
	end
	
	return status
end

local function CheckBlocked(ply, ent)
	local model = ent:GetModel()
	if DPP.BlockedModels[model] then
		SafeRemoveEntity(ent)
		if ply then
			DPP.Notify(ply, 'Model of that entity is in the blacklist!', 1)
		end
	end
end

local function CheckBlocked2(ply, model)
	if DPP.BlockedModels[model] then
		if ply then
			DPP.Notify(ply, 'Model of that entity is in the blacklist!', 1)
		end
		
		return false
	end
	
	return true
end

function SpawnFunctions.PlayerSpawnedNPC(ply, ent, shouldHideLog)
	if DPP.IsRestrictedNPC(ent:GetClass(), ply) then 
		LogTryPost(ply, 'NPC', ent)
		DPP.Notify(ply, 'That entity is restricted', 1)
		SafeRemoveEntity(ent)
		return false
	end
	
	if CheckEntityLimit(ply, ent:GetClass()) then 
		LogTryPost(ply, 'NPC', ent)
		SafeRemoveEntity(ent)
		return false
	end
	
	Spawned(ply, ent)
	if not shouldHideLog then LogSpawn(ply, ent, 'NPC') end
	
	DPP.CheckAntispam(ply, ent)
	DPP.CheckDroppedEntity(ply, ent)
	CheckBlocked(ply, ent)
end

function SpawnFunctions.PlayerSpawnedEffect(ply, model, ent, shouldHideLog)
	Spawned(ply, ent)
	if not shouldHideLog then LogSpawn(ply, ent, 'Effect') end
	
	DPP.CheckAntispam(ply, ent)
	CheckBlocked(ply, ent)
end

local PENDING, PENDING_PLY
DPP.oldCleanupAdd = DPP.oldCleanupAdd or cleanup.Add
DPP.oldUndoAddEntity = DPP.oldUndoAddEntity or undo.AddEntity
DPP.oldUndoFinish = DPP.oldUndoFinish or undo.Finish

local function CheckBefore(ply, ent, forceVerbose)
	local hide = not forceVerbose and not DPP.GetConVar('verbose_logging')
	if not ent then return end
	if IsValid(ent) and not DPP.IsOwned(ent) or not IsValid(DPP.GetOwner(ent)) then --Wow, we spawned entity without calling spawning hook!
		if ent:GetClass() == 'prop_physics' then
			SpawnFunctions.PlayerSpawnedProp(ply, ent:GetModel(), ent, hide)
		elseif ent:IsNPC() then
			SpawnFunctions.PlayerSpawnedNPC(ply, ent, hide)
		elseif ent:IsRagdoll() then
			SpawnFunctions.PlayerSpawnedRagdoll(ply, ent:GetModel(), ent, hide)
		elseif ent:IsVehicle() then
			SpawnFunctions.PlayerSpawnedVehicle(ply, ent, hide)
		elseif ent:IsWeapon() then
			SpawnFunctions.PlayerSpawnedSWEP(ply, ent, hide)
		elseif not ent:IsConstraint() then
			SpawnFunctions.PlayerSpawnedSENT(ply, ent, hide)
		end
	end
end

local function undo_Finish(name)
	local name, val = debug.getupvalue(DPP.oldUndoFinish, 1)
	
	if name == 'Current_Undo' and val then
		local owner = val.Owner
		if IsValid(owner) then
			for k, v in pairs(val.Entities) do
				if not IsValid(v) then continue end
				if DPP.IsOwned(v) then continue end
				
				CheckBefore(owner, v, true) --HOLY FUCK
			end
		end
	end
	
	return DPP.oldUndoFinish(name)
end

local function cleanup_Add(ply, type, ent)
	if PENDING ~= ent then
		if IsValid(PENDING_PLY) then DPP.CheckAntispam(PENDING_PLY, PENDING) end
		PENDING = nil
		PENDING_PLY = nil
	end
	
	local check = true
	
	if DPP.DTypes[type] then
		check = false
	end
	
	if PENDING == ent then
		if check then
			if IsValid(PENDING_PLY) then DPP.CheckAntispam(PENDING_PLY, PENDING) end
		end
		
		PENDING = nil
		PENDING_PLY = nil
	end
	
	CheckBefore(ply, ent)
	
	if IsValid(ent) then
		DPP.SetOwner(ent, ply)
	end
	
	return DPP.oldCleanupAdd(ply, type, ent)
end

function SpawnFunctions.PlayerSpawnedProp(ply, model, ent, shouldHideLog)
	if CheckEntityLimit(ply, ent:GetClass()) then 
		LogTryPost(ply, 'Prop', ent)
		SafeRemoveEntity(ent)
		return false
	end
	
	Spawned(ply, ent)
	DPP.CheckSizes(ent, ply)
	if DPP.GetConVar('check_stuck') then
		local c = CurTime()
		for k, v in pairs(ents.FindInSphere(ent:GetPos(), 32)) do
			--if v.__DPP_LastStuckCheck == c then continue end
			--v.__DPP_LastStuckCheck = c
			if DPP.GetGhosted(v) then continue end
			if DPP.CheckStuck(ply, ent, v) then break end
		end
	end
	if not shouldHideLog then LogSpawn(ply, ent, 'Prop') end
	
	PENDING = ent
	PENDING_PLY = ply
	
	DPP.CheckDroppedEntity(ply, ent)
	CheckBlocked(ply, ent)
end

function SpawnFunctions.PlayerSpawnedRagdoll(ply, model, ent, shouldHideLog)
	if CheckEntityLimit(ply, ent:GetClass()) then 
		LogTryPost(ply, 'Ragdoll', ent)
		SafeRemoveEntity(ent)
		return false
	end
	
	Spawned(ply, ent)
	DPP.CheckSizes(ent, ply)
	if not shouldHideLog then LogSpawn(ply, ent, 'Ragdoll') end
	DPP.CheckAntispam(ply, ent)
	CheckBlocked(ply, ent)
end

function SpawnFunctions.PlayerSpawnedSENT(ply, ent, shouldHideLog)
	if DPP.IsRestrictedSENT(ent:GetClass(), ply) then 
		LogTryPost(ply, 'SENT', ent)
		DPP.Notify(ply, 'That entity is restricted', 1)
		SafeRemoveEntity(ent)
		return false
	end
	
	if CheckEntityLimit(ply, ent:GetClass()) then 
		LogTryPost(ply, 'SENT', ent)
		SafeRemoveEntity(ent)
		return false
	end
	
	Spawned(ply, ent)
	DPP.CheckSizes(ent, ply)
	if not shouldHideLog then LogSpawn(ply, ent, 'SENT') end
	DPP.CheckAntispam(ply, ent)
	CheckBlocked(ply, ent)
end

function SpawnFunctions.PlayerSpawnedSWEP(ply, ent, shouldHideLog)
	if DPP.IsRestrictedSWEP(ent:GetClass(), ply) then 
		LogTryPost(ply, 'SWEP', ent)
		DPP.Notify(ply, 'That SWEP is restricted', 1)
		SafeRemoveEntity(ent)
		return false
	end
	
	if CheckEntityLimit(ply, ent:GetClass()) then 
		LogTryPost(ply, 'SWEP', ent)
		SafeRemoveEntity(ent)
		return false
	end
	
	Spawned(ply, ent)
	if not shouldHideLog then LogSpawn(ply, ent, 'SWEP') end
	DPP.CheckAntispam(ply, ent)
	CheckBlocked(ply, ent)
end

function SpawnFunctions.PlayerSpawnedVehicle(ply, ent, shouldHideLog)
	if DPP.IsRestrictedVehicle(ent:GetClass(), ply) then 
		LogTryPost(ply, 'Vehicle', ent)
		DPP.Notify(ply, 'That vehicle is restricted', 1)
		SafeRemoveEntity(ent)
		return false
	end
	
	if CheckEntityLimit(ply, ent:GetClass()) then 
		LogTryPost(ply, 'Vehicle', ent)
		SafeRemoveEntity(ent)
		return false
	end
	
	Spawned(ply, ent)
	if not shouldHideLog then LogSpawn(ply, ent, 'Vehicle') end
	DPP.CheckAntispam(ply, ent)
	CheckBlocked(ply, ent)
end

function SpawnFunctions.PlayerSpawnProp(ply, model)
	if DPP.IsModelBlocked(model, ply) then 
		LogTry(ply, 'Prop', model)
		return false 
	end
	
	if CheckEntityLimit(ply, 'prop_physics') then 
		LogTry(ply, 'Prop', model)
		return false 
	end
	
	if DPP.CheckAntispam_NoEnt(ply, false, true) == DPP.ANTISPAM_INVALID then 
		LogTry(ply, 'Object/Generic', model)
		DPP.Notify(ply, 'Entity is removed due to spam', 1)
		return false 
	end
	
	if not CheckBlocked2(ply, model) then 
		LogTry(ply, 'Object/Generic', model)
		return false 
	end
end

function SpawnFunctions.PlayerSpawnObject(ply, model)
	if DPP.IsModelBlocked(model, ply) then 
		LogTry(ply, 'Object/Generic', model)
		return false 
	end
	
	if DPP.CheckAntispam_NoEnt(ply, false, true) == DPP.ANTISPAM_INVALID then 
		LogTry(ply, 'Object/Generic', model)
		DPP.Notify(ply, 'Entity is removed due to spam', 1)
		return false 
	end
	
	if not CheckBlocked2(ply, model) then 
		LogTry(ply, 'Object/Generic', model)
		return false 
	end
end

function SpawnFunctions.PlayerSpawnRagdoll(ply, model)
	if DPP.IsModelBlocked(model, ply) then 
		LogTry(ply, 'Ragdoll', model)
		return false 
	end
	
	if DPP.CheckAntispam_NoEnt(ply, false, true) == DPP.ANTISPAM_INVALID then 
		LogTry(ply, 'Object/Generic', model)
		DPP.Notify(ply, 'Entity is removed due to spam', 1)
		return false 
	end
	
	if not CheckBlocked2(ply, model) then 
		LogTry(ply, 'Object/Generic', model)
		return false 
	end
end

function SpawnFunctions.PlayerSpawnVehicle(ply, model, class)
	if DPP.IsModelBlocked(model, ply) then 
		LogTry(ply, 'Vehicle', model)
		return false 
	end
	
	if CheckEntityLimit(ply, class) then 
		LogTry(ply, 'Vehicle', model)
		return false 
	end
	
	if DPP.CheckAntispam_NoEnt(ply, false, true) == DPP.ANTISPAM_INVALID then 
		LogTry(ply, 'Vehicle', model)
		DPP.Notify(ply, 'Entity is removed due to spam', 1)
		return false 
	end
	
	if not CheckBlocked2(ply, model) then 
		LogTry(ply, 'Vehicle', model)
		return false 
	end
	
	if DPP.IsRestrictedVehicle(class, ply) then 
		LogTry(ply, 'Vehicle', class)
		DPP.Notify(ply, 'That vehicle is restricted', 1)
		return false 
	end
end

function SpawnFunctions.PlayerSpawnSENT(ply, ent)
	if DPP.IsRestrictedSENT(ent, ply) then 
		LogTry(ply, 'SENT', 'N/A', ent)
		DPP.Notify(ply, 'That entity is restricted', 1)
		return false 
	end
	
	if CheckEntityLimit(ply, ent) then 
		LogTry(ply, 'SENT', model)
		return false 
	end
end

function SpawnFunctions.PlayerSpawnSWEP(ply, ent)
	if DPP.IsRestrictedSWEP(ent, ply) then 
		LogTry(ply, 'SWEP', 'N/A', ent)
		DPP.Notify(ply, 'That swep is restricted', 1)
		return false 
	end
	
	if CheckEntityLimit(ply, ent) then 
		LogTry(ply, 'SWEP', model)
		return false 
	end
end

function SpawnFunctions.PlayerGiveSWEP(ply, class, tab)
	local can = SpawnFunctions.PlayerSpawnSWEP(ply, class)
	if can == false then return false end
	LogSpawnC(ply, class, 'SWEP', tab.Model)
end

function SpawnFunctions.PlayerSpawnNPC(ply, ent)
	if DPP.IsRestrictedNPC(ent, ply) then 
		LogTry(ply, 'NPC', 'N/A', ent)
		DPP.Notify(ply, 'That entity is restricted', 1)
		return false 
	end
	
	if CheckEntityLimit(ply, ent) then 
		LogTry(ply, 'NPC', model)
		return false 
	end
end

for k, v in pairs(SpawnFunctions) do
	hook.Add(k, 'DPP.SpawnHooks', v)
end

local function CanPickup(ply, ent)
	if not DPP.GetConVar('enable_pickup') then return end
	if DPP.IsEntityBlockedPickup(ent:GetClass()) then return false end
	if DPP.IsRestrictedPickup(ent:GetClass(), ply) then return false end
	if not DPP.IsOwned(ent) then return end
	local can = DPP.CanTouch(ply, ent)
	if not can then return can end
end

hook.Add('PlayerCanPickupItem', 'DPP.ProtectionHooks', CanPickup)
hook.Add('PlayerCanPickupWeapon', 'DPP.ProtectionHooks', CanPickup)

local function EntityRemoved(ent)
	if ent.IsConstraint and ent:IsConstraint() then
		local ent1, ent2 = ent:GetConstrainedEntities()
		
		timer.Simple(0, function()
			if IsValid(ent1) and IsValid(ent2) then
				local o1 = DPP.GetOwner(ent1)
				local o2 = DPP.GetOwner(ent2)
				
				if o1 ~= o2 or not DPP.IsSingleOwner(ent1, o2) or not DPP.IsSingleOwner(ent2, o1) then
					DPP.RecalcConstraints(ent1)
					DPP.RecalcConstraints(ent2)
				end
			end
			
			if IsValid(ent1) then
				ent1.DPP_ConstrainedWith = ent1.DPP_ConstrainedWith or {}
				ent1.DPP_ConstrainedWith[ent2] = nil
				DPP.SendConstrainedWith(ent1)
			end
			
			if IsValid(ent2) then
				ent2.DPP_ConstrainedWith = ent2.DPP_ConstrainedWith or {}
				ent2.DPP_ConstrainedWith[ent1] = nil
				DPP.SendConstrainedWith(ent2)
			end
		end)
	end
end

local Timestamps = {}

timer.Create('DPP.ClearTimestamps', 30, 0, function()
	for k, v in pairs(Timestamps) do
		if IsValid(k) then continue end
		Timestamps[k] = nil
	end
end)

local function DPP_ReplacedSetPlayer(self, ply)
	DPP.SetOwner(self, ply)
	return self.__DPP_OldSetPlayer(self, ply)
end

local PostEntityCreated

local function OnEntityCreated(ent)
	local Timestamp = CurTime()
	Timestamps[ent] = Timestamp
	
	timer.Simple(0, function()
		PostEntityCreated(ent, Timestamp)
	end)
end

function PostEntityCreated(ent, Timestamp)
	if not IsValid(ent) then return end
	local Timestamp2 = CurTime()
	
	if ent.IsConstraint and ent:IsConstraint() then
		local ent1, ent2 = ent:GetConstrainedEntities()
		
		if IsValid(ent1) and IsValid(ent2) then
			local o1, o2 = DPP.GetOwner(ent1), DPP.GetOwner(ent2)
			
			--ent1.DPP_CreationTimestamp = ent1.DPP_CreationTimestamp or Timestamp --FUCK the police
			--ent2.DPP_CreationTimestamp = ent2.DPP_CreationTimestamp or Timestamp --FUCK the police
			
			if DPP.GetConVar('advanced_spawn_checks') then
				local t1 = Timestamps[ent1]
				local t2 = Timestamps[ent2]
				
				if t1 == Timestamp and not IsValid(o1) and IsValid(o2) then --Because we are running on next frame
					o1 = o2
					CheckBefore(o2, ent1)
					--DPP.SetOwner(ent1, o2)
				end
				
				if t2 == Timestamp and not IsValid(o2) and IsValid(o1) then
					o2 = o1
					CheckBefore(o1, ent2)
					--DPP.SetOwner(ent2, o1)
				end
			end
			
			if o1 ~= o2 or not DPP.IsSingleOwner(ent1, o2) or not DPP.IsSingleOwner(ent2, o1) then
				DPP.RecalcConstraints(ent1) --Recalculating only for one entity, because second is constrained with first
			end
		end
		
		if IsValid(ent1) then
			ent1.DPP_ConstrainedWith = ent1.DPP_ConstrainedWith or {}
			ent1.DPP_ConstrainedWith[ent2] = true
			DPP.SendConstrainedWith(ent1)
		end
		
		if IsValid(ent2) then
			ent2.DPP_ConstrainedWith = ent2.DPP_ConstrainedWith or {}
			ent2.DPP_ConstrainedWith[ent1] = true
			DPP.SendConstrainedWith(ent2)
		end
	end
	
	if DPP.GetConVar('experemental_spawn_checks') then
		if ent.EntOwner and isentity(ent.EntOwner) then
			local nent = ent.EntOwner
			local owner = not nent:IsPlayer() and DPP.GetOwner(nent) or nent
			
			if isentity(nent) and not nent:IsPlayer() then
				DPP.SetConstrainedBetween(ent, nent, true)
				
				DPP.SendConstrainedWith(ent)
				DPP.SendConstrainedWith(nent)
			end
			
			if IsValid(owner) and owner:IsPlayer() then
				CheckBefore(owner, ent)
				--DPP.SetOwner(ent, owner)
			end
		end
		
		if ent.SpawnedBy and isentity(ent.SpawnedBy) then
			local nent = ent.SpawnedBy
			local owner = not nent:IsPlayer() and DPP.GetOwner(nent) or nent
			
			if isentity(nent) and not nent:IsPlayer() then
				DPP.SetConstrainedBetween(ent, nent, true)
				
				DPP.SendConstrainedWith(ent)
				DPP.SendConstrainedWith(nent)
			end
			
			if IsValid(owner) and owner:IsPlayer() then
				CheckBefore(owner, ent)
				--DPP.SetOwner(ent, owner)
			end
		end
		
		if ent.GetPlayer and ent.SetPlayer ~= DPP.SetPlayerMeta then --Wee, entity have player tracking!
			ent.__DPP_OldSetPlayer = ent.SetPlayer
			
			local owner = ent:GetPlayer()
			if IsValid(owner) then
				CheckBefore(owner, ent)
			end
			
			ent.SetPlayer = DPP_ReplacedSetPlayer
		end
	end
end

hook.Add('OnEntityCreated', 'DPP.OnEntityCreated', OnEntityCreated)
hook.Add('EntityRemoved', 'DPP.EntityRemoved', EntityRemoved)


function DPP.SetPlayerMeta(self, ply)
	--Compability
	
	if not IsValid(ply) then 
		if not DPP.GetConVar('advanced_spawn_checks') then return end
		local name, Ent = debug.getlocal(2, 1)
		
		timer.Simple(0, function() --Wait before entity is initialized and owner is defined
			if IsValid(Ent) then
				local owner = DPP.GetOwner(Ent)
				DPP.DoEcho(RED, 'That should never happen: Entity:SetPlayer() is called without player argument! Entity: ' .. tostring(self) .. '. I detected real owner: ' .. (IsValid(owner) and owner:Nick() or 'World') .. '\nTO USERS: Yes, this is a BUG in ' .. tostring(self) .. ' and you should report it to author!')
				
				CheckBefore(owner, self)
				--DPP.SetOwner(self, owner)
			else
				DPP.DoEcho(RED, 'That should never happen: Entity:SetPlayer() is called without player argument! Entity: ' .. tostring(self) .. '.\nTO USERS: Yes, this is a BUG in ' .. tostring(self) .. ' and you should report it to author!')
			end
		end)
		
		return 
	end
	
	CheckBefore(ply, self)
	
	self:SetVar("Founder", ply)
	self:SetVar("FounderIndex", ply:UniqueID())
	self:SetNetworkedString("FounderName", ply:Nick())
	
	return DPP.SetOwner(self, ply)
end

function DPP.GetPlayerMeta(self, ply)
	return DPP.GetOwner(self, ply)
end

local entMeta = FindMetaTable('Entity')
DPP.oldSetOwnerFunc = DPP.oldSetOwnerFunc or entMeta.SetOwner

function DPP.OverrideE2()
	if not Compiler then return end
	DPP.Message('Detected E2, overriding.')
	--Hello, Wiremod
	
	DPP.__oldCompilerFunc = DPP.__oldCompilerFunc or Compiler.GetFunction
	
	function Compiler:GetFunction(instr, Name, Args)
		if self.DPly then
			if DPP.IsRestrictedE2Function(Name, self.DPly) then
				DPP.DoEcho(team.GetColor(self.DPly:Team()), self.DPly:Nick(), color_white, '<' .. self.DPly:SteamID() .. '>', RED, ' tried ', GRAY, string.format('to use E2 function %s', Name))
				self:Error('DPP: Restricted Function: ' .. Name, instr)
				return
			end
		end
		
		return DPP.__oldCompilerFunc(self, instr, Name, Args)
	end
	
	function Compiler.Execute(...)
		-- instantiate Compiler
		local instance = setmetatable({}, Compiler)
		
		local Name, Ent = debug.getlocal(2, 1) --Getting our entity
		
		if IsValid(Ent) then
			instance.DPly = DPP.GetOwner(Ent)
		end
		
		-- and pcall the new instance's Process method.
		return pcall(Compiler.Process, instance, ...)
	end
end

function DPP.OverrideGMODEntity()
	local ent = scripted_ents.Get('base_gmodentity')
	if not ent then return end
	
	DPP.Message('Detected base_gmodentity')
	
	ent.SetPlayer = DPP.SetPlayerMeta
	ent.GetPlayer = DPP.GetPlayerMeta
	scripted_ents.Register(ent, 'base_gmodentity')
	
	function entMeta:SetOwner(ent)
		timer.Simple(0, function()
			if not IsValid(self) then return end
			if not IsValid(ent) then return end
			local owner = DPP.GetOwner(ent)
			if IsValid(owner) then
				DPP.SetOwner(self, owner)
			end
		end)
		return DPP.oldSetOwnerFunc(self, ent)
	end
end

function DPP.ReplaceFunctions()
	DPP.Message('Overriding server functions.')
	
	DPP.OverrideGMODEntity()
	DPP.OverrideE2()
	
	cleanup.Add = cleanup_Add
	undo.Finish = undo_Finish
end

timer.Simple(0, DPP.ReplaceFunctions)

function DPP.CheckDroppedEntity(ply, ent)
	if not DPP.GetConVar('prevent_player_stuck') then return end
	if ent:IsPlayer() then return end
	
	for k, v in pairs(player.GetAll()) do
		if v == ply then continue end
		if v:InVehicle() then continue end
		if DPP.IsPlayerInEntity(v, ent) then
			DPP.Notify(ply, 'Your prop is stuck in other player')
			DPP.SetGhosted(ent, true)
			break
		end
	end
end

hook.Add('PhysgunDrop', 'DPP.PreventPlayerStuck', DPP.CheckDroppedEntity)

local function PhysgunDrop(ply, ent)
	if ent:IsPlayer() or ent:IsNPC() then return end
	if not DPP.GetConVar('prevent_prop_throw') then return end
	
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(Vector(0, 0, 0))
	end
end

hook.Add('PhysgunDrop', 'DPP.PreventPropThrow', PhysgunDrop)

