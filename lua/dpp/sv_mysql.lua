
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

--If you want to use MySQL, go to dpp_config_example.lua in Lua root folder
if not DMySQL3 then include('autorun/server/sv_dmysql3.lua') end

local LINK = DMySQL3.Connect('dpp')

local function FindSuperAdmins()
	local reply = {}
	
	for k, v in ipairs(player.GetAll()) do
		if v:IsSuperAdmin() then table.insert(reply, v) end
	end
	
	return reply
end

local function SQError(err)
	DPP.Message('SQL QUERY FAILED!: ' .. err)
	DPP.Message('PLEASE SEND THIS ERROR MESSAGE TO DBot')
	DPP.Message('Usually SQL errors should never happen')
	
	local f = FindSuperAdmins()
	DPP.Notify(f, 'DPP SQL QUERY FAILED!: ' .. err .. '\nPLEASE SEND THIS ERROR MESSAGE TO DBot\nUsually SQL errors should never happen', NOTIFY_ERROR)
end

function DPP.Query(query, callback)
	LINK:Query(query, callback, SQError)
end

function DPP.IsMySQL()
	return LINK.IsMySQL
end

function DPP.GetLink()
	return LINK
end

function DPP.QueryStack(tab)
	LINK:Begin()
	
	for k, v in ipairs(tab) do
		LINK:Add(v)
	end
	
	LINK:Commit()
end
