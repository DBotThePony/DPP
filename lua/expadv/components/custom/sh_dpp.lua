
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

local Component = EXPADV.AddComponent('dpp', true)
local Gray = Color(200, 200, 200)

Component.Author = 'DBot'
Component.Description = 'Adds DPP functions into Expression 2 Advanced'

local Funcs = {
	{
		name = 'setOwner',
		args = 'e:ply',
		returns = 'b',
		origin = 'server',
		myfunc = function(Context, ent, owner)
			if not IsValid(ent) then return false end
			if DPP.GetOwner(ent) ~= ply then return false end
			owner = owner or NULL
			
			DPP.DeleteEntityUndo(ent)
			DPP.SetOwner(ent, owner)
			
			if IsValid(owner) and owner:IsPlayer() then
				undo.Create('TransferedProp')
				undo.SetPlayer(owner)
				undo.AddEntity(ent)
				undo.Finish()
			end
			
			DPP.SimpleLog(ply, Gray, ' transfered ownership of ', ent, Gray, ' to ', IsValid(owner) and owner or 'world', Gray, ' using Expression2 Advanced')
			return true
		end,
		body = 'EXPADV.DPP_setOwner(Context.player, @value 1, @value 2)',
		help = 'Sets DPP entity owner if gate owner owned that entity. Returns true if successful, false otherwise'
	},
	
	{
		name = 'setOwner',
		args = 'e:',
		returns = 'b',
		origin = 'server',
		myfunc = function(Context, ent, owner)
			if not IsValid(ent) then return false end
			if DPP.GetOwner(ent) ~= ply then return false end
			DPP.DeleteEntityUndo(ent)
			DPP.SetOwner(ent, NULL)
			DPP.SimpleLog(ply, Gray, ' transfered ownership of ', ent, Gray, ' to ', 'world', Gray, ' using Expression2 Advanced')
			return true
		end,
		myfuncname = 'setOwner2',
		body = 'EXPADV.DPP_setOwner2(Context.player, @value 1)',
		help = 'Sets DPP entity owner to world if gate owner owned that entity. Returns true if successful, false otherwise'
	},
	
	{
		name = 'isGhosted',
		args = 'e:',
		returns = 'b',
		myfunc = function(Context, ent)
			return IsValid(ent) and DPP.IsGhosted(ent)
		end,
		help = 'Returns whatever entity is ghosted with DPP'
	},
	
	{
		name = 'isOwnedByLocalPlayer',
		args = 'e:',
		returns = 'b',
		myfunc = function(Context, ent)
			return IsValid(ent) and DPP.GetOwner(ent) == Context.player
		end,
		help = 'Returns whatever entity is owned by gate owner. In most cases this is equal to entity().owner() == owner()'
	},
	
	{
		name = 'isSingleOwner',
		args = 'e:',
		returns = 'b',
		myfunc = function(Context, ent)
			return IsValid(ent) and DPP.IsSingleOwner(ent, DPP.GetOwner(ent))
		end,
		help = 'Returns whatever entity have only one owner (not constrained)'
	},
	
	{
		name = 'isUpForGrabs',
		args = 'e:',
		returns = 'b',
		myfunc = function(Context, ent)
			return IsValid(ent) and DPP.IsUpForGrabs(ent)
		end,
		help = 'Returns whatever entity is up for grabs'
	},
	
	{
		name = 'isShared',
		args = 'e:',
		returns = 'b',
		myfunc = function(Context, ent)
			return IsValid(ent) and DPP.IsShared(ent)
		end,
		help = 'Returns whatever entity is shared'
	},
	
	{
		name = 'getOwner',
		args = 'e:',
		returns = 'e',
		myfunc = function(Context, ent)
			return DPP.GetOwner(ent)
		end,
		help = 'Returns DPP owner of entity. In most cases equals to entity().owner()'
	},
	
	{
		name = 'getEntityOwner',
		args = 'e',
		returns = 'e',
		myfunc = function(Context, ent)
			return DPP.GetOwner(ent)
		end,
		help = 'Returns DPP owner of entity. In most cases equals to entity().owner()'
	},
	
	{
		name = 'getEntityOwner',
		args = 'n',
		returns = 'e',
		myfuncname = 'getEntityOwnerNumber',
		myfunc = function(Context, ent)
			return DPP.GetOwner(Entity(ent))
		end,
		help = 'Returns DPP owner of entity. In most cases equals to entity().owner()'
	},
	
	{
		name = 'isOwned',
		args = 'e:',
		returns = 'b',
		myfunc = function(Context, ent)
			return DPP.IsOwned(ent)
		end,
		help = 'Is entity owned by someone (even by disconnected player)'
	},
	
	{
		name = 'isSharedType',
		args = 'e:s',
		returns = 'b',
		myfunc = function(Context, ent, arg)
			return IsValid(ent) and DPP.IsSharedType(ent, arg)
		end,
		body = 'EXPADV.DPP_isSharedType(Context, @value 1, @value 2)',
		help = 'Returns whatever entity is shared with given type'
	},
	
	{
		name = 'isModelBlocked',
		args = 's',
		returns = 'b',
		myfunc = function(Context, model)
			return DPP.IsModelBlocked(model, Context.player, true)
		end,
		help = 'Returns whatever model is blocked from gate owner'
	},
	
	{
		name = 'isModelEvenBlocked',
		args = 's',
		returns = 'b',
		myfunc = function(Context, model)
			return DPP.DPP.IsBlockedModel(model)
		end,
		help = 'Returns whatever model is blocked (ignores convars and etc.)'
	},
	
	{
		name = 'isModelBlocked',
		args = 'ply:s',
		returns = 'b',
		myfuncname = 'isModelBlockedPlayer',
		body = 'EXPADV.DPP_isModelBlockedPlayer(Context, @value 1, @value 2)',
		myfunc = function(Context, ply, model)
			return DPP.IsModelBlocked(model, ply, true)
		end,
		help = 'Returns whatever model is blocked from given player'
	},
	
	{
		name = 'dppIsModelBlocked',
		args = 's',
		returns = 'b',
		myfunc = function(Context, model)
			return DPP.IsModelBlocked(model, Context.player, true)
		end,
		help = 'Returns whatever model is blocked from gate owner'
	},
	
	{
		name = 'dppIsModelEvenBlocked',
		args = 's',
		returns = 'b',
		myfunc = function(Context, model)
			return DPP.DPP.IsBlockedModel(model)
		end,
		help = 'Returns whatever model is blocked (ignores convars and etc.)'
	},
	
	{
		name = 'dppIsModelBlocked',
		args = 'ply:s',
		returns = 'b',
		myfuncname = 'dppIsModelBlockedPlayer',
		myfunc = function(Context, ply, model)
			return DPP.IsModelBlocked(model, ply, true)
		end,
		argstr = ', @value 1, @value 2',
		help = 'Returns whatever model is blocked from given player'
	},
	
	{
		name = 'entityHasLimit',
		args = 's',
		returns = 'b',
		myfuncname = 'entityHasLimitString',
		myfunc = function(Context, class)
			return DPP.EntityHasLimit(class, ply)
		end,
		help = 'Returns whatever entity class have limit'
	},
	
	{
		name = 'entityHasLimit',
		args = 'e',
		returns = 'b',
		myfuncname = 'entityHasLimitEntity',
		myfunc = function(Context, class)
			return DPP.EntityHasLimit(class:GetClass(), ply)
		end,
		help = 'Returns whatever entity class have limit'
	},
	
	{
		name = 'sboxLimitExists',
		args = 's',
		returns = 'b',
		myfuncname = 'sboxLimitExists',
		myfunc = function(Context, lim)
			return DPP.EntityHasLimit(lim, ply)
		end,
		help = 'Returns whatever sandbox custom limit exists'
	},
	
	{
		name = 'getEntityLimit',
		args = 's',
		returns = 'n',
		myfuncname = 'getEntityLimitString',
		myfunc = function(Context, class)
			return DPP.GetEntityLimit(class, Context.player:GetUserGroup())
		end,
		help = 'Returns entity limit for gate owner'
	},
	
	{
		name = 'getEntityLimit',
		args = 'e',
		returns = 'n',
		myfuncname = 'getEntityLimitEntity',
		myfunc = function(Context, class)
			return DPP.GetEntityLimit(class:GetClass(), Context.player:GetUserGroup())
		end,
		help = 'Returns entity limit for gate owner'
	},
	
	{
		name = 'getEntityLimit',
		args = 'ply:s',
		returns = 'n',
		myfuncname = 'getEntityLimitStringPlayer',
		myfunc = function(Context, ply, class)
			return DPP.GetEntityLimit(class, ply:GetUserGroup())
		end,
		help = 'Returns entity limit for given player'
	},
	
	{
		name = 'getEntityLimit',
		args = 'ply:e',
		returns = 'n',
		myfuncname = 'getEntityLimitEntityPlayer',
		myfunc = function(Context, ply, class)
			return DPP.GetEntityLimit(class:GetClass(), ply:GetUserGroup())
		end,
		help = 'Returns entity limit for given player'
	},
	
	{
		name = 'getSBoxLimit',
		args = 's',
		returns = 'n',
		myfuncname = 'getSBoxLimit',
		myfunc = function(Context, var)
			return DPP.GetSBoxLimit(var, Context.player:GetUserGroup())
		end,
		help = 'Returns sbox limit for gate owner'
	},
	
	{
		name = 'getSBoxLimit',
		args = 'ply:s',
		returns = 'n',
		myfuncname = 'getSBoxLimitPlayer',
		myfunc = function(Context, ply, var)
			return DPP.GetSBoxLimit(var, ply:GetUserGroup())
		end,
		help = 'Returns sbox limit for given player'
	},
}

--Protection functions

local funcs = {
	'CanDamage',
	'CanGravgun',
	'CanGravgunPunt',
	'CanPlayerEnterVehicle',
	'CanEditVariable',
	'PlayerUse',
	'CanDrive',
	'CanPickupItem',
}

for k, func in ipairs(funcs) do
	table.insert(Funcs, {
		name = 'dpp' .. func,
		args = 'e:',
		returns = 'b',
		myfuncname = 'dpp' .. func .. 'Generic',
		myfunc = CompileString([[return function(Context, ent)
			if not IsValid(ent) then return false end
			local can = DPP.]] .. func .. [[(Context.player, ent)
			
			if can == nil then can = true end --WHAT
			return can
		end]], 'DPP')(),
		help = 'Returns whatever gate owner can touch entity with given module'
	})
	
	table.insert(Funcs, {
		name = 'dpp' .. func,
		args = 'ply:e',
		returns = 'b',
		myfuncname = 'dpp' .. func .. 'Player',
		myfunc = CompileString([[return function(Context, ply, ent)
			if not IsValid(ent) then return false end
			local can = DPP.]] .. func .. [[(ply, ent)
			
			if can == nil then can = true end --WHAT
			return can
		end]], 'DPP')(),
		body = 'EXPADV.DPP_dpp' .. func .. 'Player(Context, @value 1, @value 2)',
		help = 'Returns whatever given player can touch entity with given module'
	})
end

table.insert(Funcs, {
	name = 'dppCanTool',
	args = 'e:s',
	returns = 'b',
	myfunc = function(Context, ent, mode)
		return DPP.CanTool(Context.player, ent, mode)
	end,
	myfuncname = 'dppCanTool1',
	body = 'EXPADV.DPP_dppCanTool1(Context, @value 1, @value 2)',
	help = 'Returns whatever gate owner can toolgun entity with given mode'
})

table.insert(Funcs, {
	name = 'dppCanTool',
	args = 'e:',
	returns = 'b',
	myfuncname = 'dppCanTool2',
	myfunc = function(Context, ent)
		return DPP.CanTool(Context.player, ent, '')
	end,
	help = 'Returns whatever gate owner can toolgun entity with given mode'
})

table.insert(Funcs, {
	name = 'dppCanTool',
	args = 'ply:e,s',
	returns = 'b',
	myfunc = function(Context, ply, ent, mode)
		return DPP.CanTool(ply, ent, mode)
	end,
	myfuncname = 'dppCanTool1Player',
	body = 'EXPADV.DPP_dppCanTool1Player(Context, @value 1, @value 2, @value 3)',
	help = 'Returns whatever given player can toolgun entity with given mode'
})

table.insert(Funcs, {
	name = 'dppCanTool',
	args = 'ply:e',
	returns = 'b',
	myfunc = function(Context, ply, ent)
		return DPP.CanTool(ply, ent, '')
	end,
	myfuncname = 'dppCanTool2Player',
	body = 'EXPADV.DPP_dppCanTool2Player(Context, @value 1, @value 2)',
	help = 'Returns whatever given player can toolgun entity'
})

table.insert(Funcs, {
	name = 'dppCanProperty',
	args = 'e:s',
	returns = 'b',
	myfuncname = 'dppCanProperty1',
	myfunc = function(Context, ent, property)
		return DPP.CanProperty(Context.player, property, ent)
	end,
	body = 'EXPADV.DPP_dppCanProperty1(Context, @value 1, @value 2)',
	help = 'Returns whatever gate owner can property entity with given mode'
})

table.insert(Funcs, {
	name = 'dppCanProperty',
	args = 'e:',
	returns = 'b',
	myfuncname = 'dppCanProperty2',
	myfunc = function(Context, ent)
		return DPP.CanProperty(Context.player, '', ent)
	end,
	help = 'Returns whatever gate owner can property entity'
})

table.insert(Funcs, {
	name = 'dppCanProperty',
	args = 'ply:e,s',
	returns = 'b',
	myfuncname = 'dppCanProperty1Player',
	myfunc = function(Context, ply, ent, mode)
		return DPP.CanProperty(ply, mode, ent)
	end,
	body = 'EXPADV.DPP_dppCanProperty1Player(Context, @value 1, @value 2, @value 3)',
	help = 'Returns whatever given player can property entity with given mode'
})

table.insert(Funcs, {
	name = 'dppCanProperty',
	args = 'ply:e',
	returns = 'b',
	myfuncname = 'dppCanProperty2Player',
	myfunc = function(Context, ply, ent)
		return DPP.CanProperty(ply, '', ent)
	end,
	body = 'EXPADV.DPP_dppCanProperty2Player(Context, @value 1, @value 2)',
	help = 'Returns whatever given player can property entity'
})

for k, v in pairs(DPP.BlockTypes) do
	--Strings
	
	table.insert(Funcs, {
		name = 'dppIsBlacklisted' .. v,
		args = 's',
		returns = 'b',
		myfuncname = 'dppIsBlacklisted' .. v .. 'Generic',
		myfunc = function(Context, str)
			return DPP['IsEntityBlocked' .. v](str, Context.player)
		end,
		help = 'Returns whatever entity class is in ' .. v .. ' blacklist for gate owner'
	})
	
	table.insert(Funcs, {
		name = 'dppIsEvenBlacklisted' .. v,
		args = 's',
		returns = 'b',
		myfunc = function(Context, str)
			return DPP['IsEvenBlocked' .. v](str)
		end,
		help = 'Returns whatever entity class is in ' .. v .. ' blacklist (ignores convars that disables, etc.)'
	})
	
	table.insert(Funcs, {
		name = 'dppIsBlacklisted' .. v,
		args = 'ply:s',
		returns = 'b',
		myfuncname = 'dppIsBlacklisted' .. v .. 'Player',
		myfunc = function(Context, ply, str)
			return DPP['IsEntityBlocked' .. v](str, ply)
		end,
		argstr = ', @value 1, @value 2',
		help = 'Returns whatever entity class is in ' .. v .. ' blacklist for given player'
	})
	
	--Entities
	table.insert(Funcs, {
		name = 'dppIsBlacklisted' .. v,
		args = 'e',
		returns = 'b',
		myfuncname = 'dppIsBlacklisted' .. v .. 'GenericEntity',
		myfunc = function(Context, str)
			return DPP['IsEntityBlocked' .. v](str:GetClass(), Context.player)
		end,
		help = 'Returns whatever entity class is in ' .. v .. ' blacklist for gate owner'
	})
	
	table.insert(Funcs, {
		name = 'dppIsEvenBlacklisted' .. v,
		args = 'e',
		returns = 'b',
		myfuncname = 'dppIsBlacklisted' .. v .. 'Entity',
		myfunc = function(Context, str)
			return DPP['IsEvenBlocked' .. v](str:GetClass())
		end,
		help = 'Returns whatever entity class is in ' .. v .. ' blacklist (ignores convars that disables, etc.)'
	})
	
	table.insert(Funcs, {
		name = 'dppIsBlacklisted' .. v,
		args = 'ply:e',
		returns = 'b',
		myfuncname = 'dppIsBlacklisted' .. v .. 'PlayerEntity',
		myfunc = function(Context, ply, str)
			return DPP['IsEntityBlocked' .. v](str:GetClass(), ply)
		end,
		argstr = ', @value 1, @value 2',
		help = 'Returns whatever entity class is in ' .. v .. ' blacklist for given player'
	})
end

for k, v in pairs(DPP.WhitelistTypes) do
	--Strings

	table.insert(Funcs, {
		name = 'dppIsExcluded' .. v,
		args = 's',
		returns = 'b',
		myfunc = function(Context, str)
			return DPP['IsEntityWhitelisted' .. v](str)
		end,
		help = 'Returns whatever entity class is in ' .. v .. ' exclude list'
	})
	
	table.insert(Funcs, {
		name = 'dppIsEvenExcluded' .. v,
		args = 's',
		returns = 'b',
		myfunc = function(Context, str)
			return DPP['IsEvenWhitelisted' .. v](str)
		end,
		help = 'Returns whatever entity class is in ' .. v .. ' exclude list (ignores convars that disables, etc.)'
	})
	
	--Entities
	table.insert(Funcs, {
		name = 'dppIsExcluded' .. v,
		args = 'e',
		returns = 'b',
		myfuncname = 'dppIsExcluded' .. v .. 'Entity',
		myfunc = function(Context, str)
			return DPP['IsEntityWhitelisted' .. v](str:GetClass())
		end,
		help = 'Returns whatever entity class is in ' .. v .. ' exclude list'
	})
	
	table.insert(Funcs, {
		name = 'dppIsEvenExcluded' .. v,
		args = 'e',
		returns = 'b',
		myfuncname = 'dppIsEvenExcluded' .. v .. 'Entity',
		myfunc = function(Context, str)
			return DPP['IsEvenWhitelisted' .. v](str:GetClass())
		end,
		help = 'Returns whatever entity class is in ' .. v .. ' exclude list (ignores convars that disables, etc.)'
	})
end

for k, v in pairs(DPP.RestrictTypes) do
	--Strings
	
	table.insert(Funcs, {
		name = 'dppIsRestricted' .. v,
		args = 's',
		returns = 'b',
		myfuncname = 'dppIsRestricted' .. v .. 'Generic',
		myfunc = function(Context, str)
			return DPP['IsRestricted' .. v](str, Context.player)
		end,
		help = 'Returns whatever entity class is in ' .. v .. ' restrict list for gate owner'
	})
	
	table.insert(Funcs, {
		name = 'dppIsEvenRestricted' .. v,
		args = 's',
		returns = 'b',
		myfunc = function(Context, str)
			return DPP['IsEvenRestricted' .. v](str)
		end,
		help = 'Returns whatever entity class is in ' .. v .. ' restrict list (ignores convars that disables, etc.)'
	})
	
	table.insert(Funcs, {
		name = 'dppIsRestricted' .. v,
		args = 'ply:s',
		returns = 'b',
		myfuncname = 'dppIsRestricted' .. v .. 'Player',
		myfunc = function(Context, ply, str)
			return DPP['IsRestricted' .. v](str, ply)
		end,
		argstr = ', @value 1, @value 2',
		help = 'Returns whatever entity class is in ' .. v .. ' restrict list for given player'
	})
	
	--Entities
	table.insert(Funcs, {
		name = 'dppIsRestricted' .. v,
		args = 'e',
		returns = 'b',
		myfuncname = 'dppIsRestricted' .. v .. 'GenericEntity',
		myfunc = function(Context, str)
			return DPP['IsRestricted' .. v](str:GetClass(), Context.player)
		end,
		help = 'Returns whatever entity class is in ' .. v .. ' restrict list for gate owner'
	})
	
	table.insert(Funcs, {
		name = 'dppIsEvenRestricted' .. v,
		args = 'e',
		returns = 'b',
		myfuncname = 'dppIsRestricted' .. v .. 'Entity',
		myfunc = function(Context, str)
			return DPP['IsEvenRestricted' .. v](str:GetClass())
		end,
		help = 'Returns whatever entity class is in ' .. v .. ' restrict list (ignores convars that disables, etc.)'
	})
	
	table.insert(Funcs, {
		name = 'dppIsRestricted' .. v,
		args = 'ply:e',
		returns = 'b',
		myfuncname = 'dppIsRestricted' .. v .. 'PlayerEntity',
		myfunc = function(Context, ply, str)
			return DPP['IsRestricted' .. v](str:GetClass(), ply)
		end,
		argstr = ', @value 1, @value 2',
		help = 'Returns whatever entity class is in ' .. v .. ' restrict list for given player'
	})
end

DPP.Message('DPP Expression 2 Advanced functions getting registered')

local funcNameTest = {}

--Testing function names (debug)
for k, data in ipairs(Funcs) do
	data.origin = data.origin or 'shared'
	data.myfuncname = data.myfuncname or data.name
	
	if funcNameTest[data.myfuncname] then error('Oops! Function name ' .. data.myfuncname .. ' is not unique!') end
	funcNameTest[data.myfuncname] = true
end

funcNameTest = nil

for k, data in ipairs(Funcs) do
	data.argstr = data.argstr or ', @value 1'
	data.body = data.body or ('(EXPADV.DPP_' .. data.myfuncname .. '(Context' .. data.argstr .. ') or false)')
	
	EXPADV['DPP_' .. data.myfuncname] = data.myfunc
	
	if data.origin == 'shared' then
		EXPADV.SharedOperators()
	elseif data.origin == 'server' then
		EXPADV.ServerOperators()
	else
		EXPADV.ClientOperators()
	end
	
	Component:AddInlineFunction(data.name, data.args, data.returns, data.body)
	Component:AddFunctionHelper(data.name, data.args, data.help)
end

