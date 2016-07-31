
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

local CAMIFailed = false
DPP.Access = DPP.Access or {}

function DPP.RegisterAccess(id, default)
	DPP.Access[id] = default
	
	if not CAMI or CAMIFailed then return end
	
	CAMI.RegisterPrivilege{
		Name = 'dpp_' .. id,
		MinAccess = default,
	}
end

function DPP.DefaultAccessCheck(ply, id, callback)
	local access = DPP.Access[id]
	
	if access == 'user' then
		callback(true, 'user rights')
	elseif access == 'admin' then
		callback(ply:IsAdmin(), 'admin rights')
	elseif access == 'superadmin' then
		callback(ply:IsSuperAdmin(), 'superadmin rights')
	end
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

function DPP.HaveAccess(ply, id, callback)
	if not IsValid(ply) then
		callback(true, 'console')
		return
	end
	
	if CAMI and not CAMIFailed then
		local access = DPP.Access[id]
		
		local function callbackWrapper(result, reason)
			if result == nil then --Admin mod got confused
				result = DPP.DefaultAccessCheckLight(ply, id)
			end
			
			if reason == 'Fallback.' then
				reason = access .. ' rights'
			end
			
			callback(result, reason)
		end
		
		--If i do not specify target as nil, it would be C "no value"
		
		CAMI.PlayerHasAccess(ply, 'dpp_' .. id, callbackWrapper, nil, {
			Fallback = access,
		})
		
		return
	end
	
	DPP.DefaultAccessCheck(ply, id, callback)
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
	entcheck = 'admin',
	
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

for k, v in pairs(DPP.BlockTypes) do
	default['addblockedentity' .. k] = 'superadmin'
	default['removeblockedentity' .. k] = 'superadmin'
end

for k, v in pairs(DPP.WhitelistTypes) do
	default['addwhitelistedentity' .. k] = 'superadmin'
	default['removewhitelistedentity' .. k] = 'superadmin'
end

for k, v in pairs(DPP.RestrictTypes) do
	default['restrict' .. k] = 'superadmin'
	default['unrestrict' .. k] = 'superadmin'
end

function DPP.RegisterRights()
	for k, v in pairs(default) do
		local trace, reason
		local status = xpcall(DPP.RegisterAccess, function(err) reason = err trace = debug.traceback() end, k, v)
		
		if not status and SERVER then
			CAMIFailed = true
			DPP.DoEcho(Color(255, 0, 0), 'ERROR: CAMI Failed. You are unable to use CAMI Privileges for now. Contact your admin mod developer!\nThe Error: ' .. (reason or '<unknown>'))
			DPP.DoEcho(Color(255, 0, 0), trace)
		end
	end
end

timer.Simple(0, DPP.RegisterRights)

