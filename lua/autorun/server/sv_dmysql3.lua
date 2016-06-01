
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

if file.Exists('dpp_config.lua', 'LUA') then
	include('dpp_config.lua')
end

if file.Exists('dmysql3_config.lua', 'LUA') then
	include('dmysql3_config.lua')
end

module('DMySQL3', package.seeall)

UseMySQL = false
IsMySQL = false
UseTMySQL4 = false
Host = 'localhost'
Database = 'test'
User = 'user'
Password = 'pass'
Port = 3306

local ConfigObject = DPP_MySQLConfig or DMySQL3_Config

if ConfigObject then
	UseMySQL = ConfigObject.UseMySQL
	Host = ConfigObject.Host
	Database = ConfigObject.Database
	User = ConfigObject.User
	Password = ConfigObject.Password
	Port = ConfigObject.Port
end

local tmsql, moo = file.Exists("bin/gmsv_tmysql4_*", "LUA"), file.Exists("bin/gmsv_mysqloo_*", "LUA")

function Connect()
	if not UseMySQL then 
		MsgC('DMySQL3: Using SQLite\n')
		IsMySQL = false
		return
	end
	
	if not tmsql and not moo then
		MsgC('DMySQL3: No TMySQL4 module installed!\nGet latest at https://facepunch.com/showthread.php?t=1442438\n')
		MsgC('DMySQL3: Using SQLite\n')
		IsMySQL = false
		return
	end

	if tmsql then
		local hit = false
		
		xpcall(function()
			require("tmysql4")
			
			MsgC('DMySQL3: Trying to connect to ' .. Host .. ' using driver TMySQL4\n')
			
			local Link, Error = tmysql.initialize(Host, User, Password, Database, Port)
			
			if not Link then
				MsgC('DMySQL3 connection failed: \nInvalid username or password, wrong hostname or port, database does not exists, or given user can\'t access it.\n' .. Error .. '\n')
				IsMySQL = false
			else
				MsgC('DMySQL3: Success\n')
				LINK = Link
				IsMySQL = true
				UseTMySQL4 = true
				hit = true
			end
		end, function(err)
			MsgC('DMySQL3 connection failed:\nCannot intialize a binary TMySQL4 module (internal error). Are you sure that your installed module for your OS? (linux/windows)\n' .. err .. '\n')
			IsMySQL = false
		end)
		
		if hit then return end
	end
	
	if moo then
		MsgC('DMySQL3 recommends to use TMySQL4!\n')
		
		xpcall(function()
			require("mysqloo")
			
			MsgC('DMySQL3: Trying to connect to ' .. Host .. ' using driver MySQLoo\n')
			local Link = mysqloo.connect(Host, User, Password, Database, Port)
			
			Link:connect()
			Link:wait()
			
			local Status = Link:status()
			
			if Status == mysqloo.DATABASE_CONNECTED then
				MsgC('DMySQL3: Success\n')
				IsMySQL = true
				LINK = Link
			else
				MsgC('DMySQL3 connection failed: \nInvalid username or password, wrong hostname or port, database does not exists, or given user can\'t access it.\n')
				print(Link:hostInfo())
			end
		end, function(err)
			MsgC('DMySQL3 connection failed:\nCannot intialize a binary MySQLoo module (internal error). Are you sure that your installed module for your OS? (linux/windows)\n' .. err .. '\n')
			IsMySQL = false
		end)
	end
end

local EMPTY = function() end

function Query(str, success, failed)
	success = success or EMPTY
	failed = failed or EMPTY
	
	if not IsMySQL then
		local data = sql.Query(str)
		
		if data == false then
			xpcall(failed, debug.traceback, sql.LastError())
		else
			xpcall(success, debug.traceback, data or {})
		end
		
		return
	end
	
	if UseTMySQL4 then
		if not LINK then
			Connect()
		end
		
		if not LINK then
			MsgC('DMySQL3: Connection to database lost while executing query!\n')
			return
		end
		
		LINK:Query(str, function(data)
			local data = data[1]
			
			if not data.status then
				xpcall(failed, debug.traceback, data.error)
			else
				xpcall(success, debug.traceback, data.data or {})
			end
		end)
		
		return
	end
	
	local obj = LINK:query(str)
	
	function obj.onSuccess(q, data)
		xpcall(success, debug.traceback, data or {})
	end
	
	function obj.onError(q, err)
		if LINK:status() == mysqloo.DATABASE_NOT_CONNECTED then
			Connect()
			MsgC('DMySQL3: Connection to database lost while executing query!\n')
			return
		end
		
		xpcall(failed, debug.traceback, err)
	end
	
	obj:start()
end

local TRX = {}

function Add(str, success, failed)
	success = success or EMPTY
	failed = failed or EMPTY
	
	table.insert(TRX, {str, success, failed})
end

function Begin()
	TRX = {}
	Add('BEGIN')
end

function Commit(finish)
	finish = finish or EMPTY
	
	if #TRX == 0 then return end
	
	Add('COMMIT')
	
	local TRX2 = TRX
	TRX = {}
	local TRX = TRX2
	
	local current = 1
	local total = #TRX
	
	local success, err
	
	function success(data)
		xpcall(TRX[current][2], debug.traceback, data)
		current = current + 1
		if current >= total then xpcall(finish, debug.traceback) return end
		Query(TRX[current][1], success, err)
	end
	
	function err(data)
		xpcall(TRX[current][3], debug.traceback, data)
		current = current + 1
		if current >= total then xpcall(finish, debug.traceback) return end
		Query(TRX[current][1], success, err)
	end
	
	Query(TRX[current][1], success, err)
end

Connect()
