
--CPPI

CPPI_NOTIMPLEMENTED = 9020
CPPI_DEFER = 9030

CPPI = {}

function CPPI.GetName()
	return 'DBots Prop Protection'
end

function CPPI.GetVersion()
	return 'Universal'
end

function CPPI.GetInterfaceVersion()
	return 1.3, 'modified'
end

local entMeta = FindMetaTable('Entity')
local plyMeta = FindMetaTable('Player')

function plyMeta:CPPIGetFriends()
	return DPP.GetFriendTableCPPI(self)
end

function entMeta:CPPIGetOwner()
	local o = DPP.GetOwner(self)
	if not IsValid(o) then return nil, nil end
	
	return o, o:UniqueID()
end

if SERVER then
	function entMeta:CPPISetOwner(ply)
		DPP.SetOwner(self, ply)
	end
	
	function entMeta:CPPISetOwnerUID(uid)
		local ply = player.GetByUniqueID(uid)
		if not ply then
			DPP.SetOwner(self, NULL)
		else
			DPP.SetOwner(self, ply)
		end
	end
end

function entMeta:CPPICanDamage(ply)
	return DPP.CanDamage(ply, self) ~= false
end

function entMeta:CPPICanTool(ply, mode)
	return DPP.CanTool(ply, self, mode) ~= false
end

function entMeta:CPPIDrive(ply)
	return DPP.CanDrive(ply, self) ~= false
end

function entMeta:CPPICanEditVariable(ply, key, val, editor)
	return DPP.CanEditVariable(self, ply, key, val, editor) ~= false
end

function entMeta:CPPICanProperty(ply, str)
	return DPP.CanProperty(ply, str, ent) ~= false
end

function entMeta:CPPICanPhysgun(ply)
	return DPP.CanPhysgun(ply, self) ~= false
end

function entMeta:CPPICanPickup(ply)
	return DPP.CanGravgun(ply, self) ~= false
end

function entMeta:CPPICanPunt(ply)
	return DPP.CanGravgunPunt(ply, self) ~= false
end

function entMeta:CPPICanUse(ply)
	return DPP.PlayerUse(ply, self) ~= false
end

function entMeta:CPPIIsOwned()
	return DPP.IsOwned(self)
end
