
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

if file.Exists('dpp_config.lua', 'LUA') then
	include('dpp_config.lua')
end

if DPP_MySQLConfig then
	DPP.Message('ATTENTION! DPP MySQL CONFIG THROUGH LUA IS DEPRECATED\nYOU SHOULD USE DATA FOLDER INSTEAD. LOOK INTO dmysql3/dpp.txt')
	DPP_MySQLConfig.User = DPP_MySQLConfig.Username
	DMySQL3.WriteConfig('dpp', DPP_MySQLConfig)
end

local LINK = DMySQL3.Connect('dpp')

local function SQError(err)
	print('DPP Query failed: ' .. err)
end

function DPP.Query(query, callback)
	LINK:Query(query, callback, SQError)
end

function DPP.QueryStack(tab)
	LINK:Begin()
	
	for k, v in ipairs(tab) do
		LINK:Add(v)
	end
	
	LINK:Commit()
end
