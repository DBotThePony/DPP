
--[[
Copyright (C) 2016-2017 DBot

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

include('sh_cami.lua')

DPP.Access = DPP.Access or {}
DPP.CAMIPrivTable = DPP.CAMIPrivTable or {}

function DPP.RegisterAccess(id, default, desc, phraseid)
	DPP.Access[id] = default

	DPP.CAMIPrivTable[id] = CAMI.RegisterPrivilege{
		Name = 'dpp_' .. id,
		MinAccess = default,
		Description = desc,
		DPP_PHRASEID = phraseid,
	}
end

function DPP.DefaultAccessCheckLight(ply, id)
	local access = DPP.Access[id]

	if access == 'user' then
		return true, 'user rights'
	elseif access == 'admin' then
		return ply:IsAdmin(), 'admin rights'
	elseif access == 'superadmin' then
		return ply:IsSuperAdmin(), 'superadmin rights'
	end
end

function DPP.HaveAccess(ply, id, callback, ...)
	if not IsValid(ply) then
		callback(true, 'console', ...)
		return
	end

	local args = {...}

	local access = DPP.Access[id]
	
	if not access then
		DPP.ThrowError('Invalid access ID: ' .. id, 1, true)
	end

	local function callbackWrapper(result, reason)
		if result == nil then --Admin mod got confused
			result = DPP.DefaultAccessCheckLight(ply, id)
		end

		if reason == 'Fallback.' then
			reason = access .. ' rights'
		end

		callback(result, reason, unpack(args))
	end

	CAMI.PlayerHasAccess(ply, 'dpp_' .. id, callbackWrapper, nil, {
		Fallback = access,
	})
end

function DPP.CheckAccess(ply, id, call, ...)
	local args = {...}

	DPP.HaveAccess(ply, id, function(result, reason)
		if not result then
			DPP.Notify(ply, {'DPP: You need "' .. id .. '" access to do that' .. (reason and (' (' .. reason .. ')') or '')}, NOTIFY_ERROR)
		else
			call(unpack(args))
		end
	end)
end

local default = {
	--Core access
	touchother = 'admin',
	touchworld = 'admin',
	seelogs = 'admin',
	setvar = 'superadmin',

	--Usual Commands
	cleardecals = 'admin',
	toggleplayerprotect = 'admin',
	cleardisconnected = 'admin',
	clearmap = 'admin',
	clearbyuid = 'admin',
	freezeall = 'admin',
	clearplayer = 'admin',
	clearself = 'user',
	transfertoworld = 'admin',
	transfertoworld_constrained = 'admin',
	freezeplayer = 'admin',
	freezebyuid = 'admin',
	unfreezebyuid = 'admin',
	unfreezeplayer = 'admin',
	share = 'user',
	fallbackto = 'user',
	removefallbackto = 'user',
	transfertoplayer = 'user',
	transfertoplayer_all = 'user',
	entcheck = 'admin',
	inspect = 'admin',
	freezephys = 'admin',

	--Database manipulate commands
	addblockedmodel = 'superadmin',
	removeblockedmodel = 'superadmin',
	addentitylimit = 'superadmin',
	removeentitylimit = 'superadmin',
	addsboxlimit = 'superadmin',
	addmodellimit = 'superadmin',
	addconstlimit = 'superadmin',
	removesboxlimit = 'superadmin',
	removemodellimit = 'superadmin',
	removeconstlimit = 'superadmin',
	
	-- Factory reset
	factoryreset = 'superadmin',
	freset_exclude = 'superadmin',
	freset_restrictions = 'superadmin',
	freset_blocked = 'superadmin',
	freset_models = 'superadmin',
	freset_limits = 'superadmin',
	freset_mlimits = 'superadmin',
	freset_slimits = 'superadmin',
	freset_climits = 'superadmin',
	
	freset_blocked_use = 'superadmin',
	freset_blocked_physgun = 'superadmin',
	freset_blocked_tool = 'superadmin',
	freset_blocked_toolworld = 'superadmin',
	freset_blocked_damage = 'superadmin',
	freset_blocked_pickup = 'superadmin',
	freset_blocked_gravgun = 'superadmin',
	freset_exclude_use = 'superadmin',
	freset_exclude_physgun = 'superadmin',
	freset_exclude_tool = 'superadmin',
	freset_exclude_pickup = 'superadmin',
	freset_exclude_property = 'superadmin',
	freset_exclude_gravgun = 'superadmin',
	freset_exclude_propertyt = 'superadmin',
	freset_exclude_damage = 'superadmin',
	freset_exclude_toolmode = 'superadmin',
	freset_restrictions_swep = 'superadmin',
	freset_restrictions_tool = 'superadmin',
	freset_restrictions_pickup = 'superadmin',
	freset_restrictions_vehicle = 'superadmin',
	freset_restrictions_property = 'superadmin',
	freset_restrictions_e2afunction = 'superadmin',
	freset_restrictions_npc = 'superadmin',
	freset_restrictions_sent = 'superadmin',
	freset_restrictions_e2function = 'superadmin',
	freset_restrictions_model = 'superadmin',
}

local default_desc = {
	--Core access
	touchother = 'Whatever player can touch other players props',
	touchworld = 'Whatever player can touch world props',
	seelogs = 'Whatever player can see logs',
	setvar = 'Whatever player can change DPP convars',

	--Usual Commands
	cleardecals = 'Can clear decals',
	toggleplayerprotect = 'Can disable or enable protection for players',
	cleardisconnected = 'Can clear all disconnected player props',
	clearmap = 'Can clean up map',
	clearbyuid = 'Can freeze player entities',
	freezeall = 'Can freeze all entities',
	clearplayer = 'Can remove other player entities',
	clearself = 'Can clear his own entities',
	transfertoworld = 'Can transfer ownership to world',
	transfertoworld_constrained = 'Can transfer ownership to world with constrained',
	freezeplayer = 'Can freeze player entities',
	freezebyuid = 'Can freeze player entities using UniqueID',
	unfreezebyuid = 'Can unfreeze player entities',
	unfreezeplayer = 'Can unfreeze player entities using UniqueID',
	share = 'Can share props',
	fallbackto = 'Can set fallback',
	removefallbackto = 'Can remove fallback',
	transfertoplayer = 'Can transfer props to other players',
	transfertoplayer_all = 'Can transfer all props to other players',
	entcheck = 'Can request entity report',
	inspect = 'Can player "inspect" entity',
	freezephys = 'Can freeze all valid physics objects',

	--Database manipulate commands
	addblockedmodel = 'Can add blocked model',
	removeblockedmodel = 'Can remove blocked model',
	addentitylimit = 'Can add entity limit',
	removeentitylimit = 'Can remove entity limit',
	addsboxlimit = 'Can add sandbox limit',
	addmodellimit = 'Can add model limit',
	addconstlimit = 'Can add constraints limit',
	removesboxlimit = 'Can remove sandbox limit',
	removemodellimit = 'Can remove model limit',
	removeconstlimit = 'Can remove constraints limit',
	
	-- Factory reset
	factoryreset = 'Can do full factory reset',
	freset_exclude = 'Can reset excludes list',
	freset_restrictions = 'Can reset restrictions list',
	freset_blocked = 'Can reset blocks list',
	freset_models = 'Can reset blocked models list',
	freset_limits = 'Can reset entity limits list',
	freset_mlimits = 'Can reset model limits list',
	freset_slimits = 'Can reset sandbox limits list',
	freset_climits = 'Can reset constraints limits list',
	
	freset_blocked_use = 'Can reset blocked use list',
	freset_blocked_physgun = 'Can reset blocked physgun list',
	freset_blocked_tool = 'Can reset blocked tool list',
	freset_blocked_toolworld = 'Can reset blocked tool world mode list',
	freset_blocked_damage = 'Can reset blocked damage list',
	freset_blocked_pickup = 'Can reset blocked pickups list',
	freset_blocked_gravgun = 'Can reset blocked gavity gun list',
	freset_exclude_use = 'Can reset excluded use list',
	freset_exclude_physgun = 'Can reset excluded physgun list',
	freset_exclude_tool = 'Can reset excluded tool list',
	freset_exclude_pickup = 'Can reset excluded pickups list',
	freset_exclude_property = 'Can reset excluded property list',
	freset_exclude_gravgun = 'Can reset excluded gravity gun list',
	freset_exclude_propertyt = 'Can reset excluded property type list',
	freset_exclude_damage = 'Can reset excluded damage list',
	freset_exclude_toolmode = 'Can reset excluded tool mode list',
	freset_restrictions_swep = 'Can reset swep restrictions list',
	freset_restrictions_tool = 'Can reset tool restrictions list',
	freset_restrictions_pickup = 'Can reset pickups restrictions list',
	freset_restrictions_vehicle = 'Can reset vehicle restrictions list',
	freset_restrictions_property = 'Can reset property restrictions list',
	freset_restrictions_e2afunction = 'Can reset E2 Advanced Function restrictions list',
	freset_restrictions_npc = 'Can reset NPC restrictions list',
	freset_restrictions_sent = 'Can reset SENT restrictions list',
	freset_restrictions_e2function = 'Can reset E2 Functions restrictions list',
	freset_restrictions_model = 'Can reset models restrictions list',
}

for k, v in pairs(DPP.BlockTypes) do
	default['addblockedentity' .. k] = 'superadmin'
	default['removeblockedentity' .. k] = 'superadmin'
	default_desc['addblockedentity' .. k] = 'Can add entities to ' .. k .. ' blacklist'
	default_desc['removeblockedentity' .. k] = 'Can remove entities from ' .. k .. ' blacklist'
end

for k, v in pairs(DPP.WhitelistTypes) do
	default['addwhitelistedentity' .. k] = 'superadmin'
	default['removewhitelistedentity' .. k] = 'superadmin'
	default_desc['addwhitelistedentity' .. k] = 'Can add entities to ' .. k .. ' exclude list'
	default_desc['removewhitelistedentity' .. k] = 'Can remove entities from ' .. k .. ' exclude list'
end

for k, v in pairs(DPP.RestrictTypes) do
	default['restrict' .. k] = 'superadmin'
	default['restrict' .. k .. '_ply'] = 'superadmin'
	default['unrestrict' .. k] = 'superadmin'
	default['unrestrict' .. k .. '_ply'] = 'superadmin'
	default_desc['restrict' .. k] = 'Can add entities to ' .. k .. ' restrict list'
	default_desc['restrict' .. k .. '_ply'] = 'Can add entities to ' .. k .. ' restrict list by SteamID'
	default_desc['unrestrict' .. k] = 'Can remove entities from ' .. k .. ' restrict list'
	default_desc['unrestrict' .. k .. '_ply'] = 'Can remove entities from ' .. k .. ' restrict list by SteamID'
end

local function UpdateLang()
	for k, v in pairs(DPP.CAMIPrivTable) do
		if not v.DPP_PHRASEID then continue end
		v.Description = DPP.GetPhrase(v.DPP_PHRASEID)
	end
end

for k, v in pairs(default_desc) do
	DPP.RegisterPhrase('en', 'priv_' .. k, v)
end

function DPP.RegisterRights()
	for k, v in pairs(default) do
		DPP.RegisterAccess(k, v, DPP.GetPhrase('priv_' .. k), 'priv_' .. k)
	end
	
	UpdateLang()
end

hook.Add('DPP.LanguageChanged', 'DPP.Access', UpdateLang)

timer.Simple(0, DPP.RegisterRights)
