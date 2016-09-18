
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
	addconstlimit = 'superadmin',
	removesboxlimit = 'superadmin',
	removeconstlimit = 'superadmin',
}

local default_desc = {
	--Core access
	touchother = 'Whatever player can touch other players props',
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
	addconstlimit = 'Can add constraints limit',
	removesboxlimit = 'Can remove sandbox limit',
	removeconstlimit = 'Can remove constraints limit',
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
	default['unrestrict' .. k] = 'superadmin'
	default_desc['restrict' .. k] = 'Can add entities to ' .. k .. ' restrict list'
	default_desc['unrestrict' .. k] = 'Can remove entities from ' .. k .. ' restrict list'
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
