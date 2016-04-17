
--If you want to use MySQL, go to dpp_config_example.lua in Lua root folder

if file.Exists('dpp_config.lua', 'LUA') then
	include('dpp_config.lua')
end

if DPP_MySQLConfig then
	DPP.UseMySQL = DPP_MySQLConfig.UseMySQL
	DPP.Username = DPP_MySQLConfig.Username
	DPP.Password = DPP_MySQLConfig.Password
	DPP.Database = DPP_MySQLConfig.Database
	DPP.Host = DPP_MySQLConfig.Host
	DPP.Port = DPP_MySQLConfig.Port
else
	DPP.UseMySQL = false
	DPP.Username = 'dpp'
	DPP.Password = ''
	DPP.Database = 'dpp'
	DPP.Host = 'localhost'
	DPP.Port = 3306
end

DPP.UseTMySQL4 = false

local tmsql, moo = file.Exists("bin/gmsv_tmysql4_*", "LUA"), file.Exists("bin/gmsv_mysqloo_*", "LUA")

local function Connect()
	if not DPP.UseMySQL then
		DPP.IsMySQL = false
	else
		if not tmsql and not moo then
			MsgC('No TMySQL4 module installed!\nGet latest at https://facepunch.com/showthread.php?t=1442438\n')
			DPP.IsMySQL = false
		elseif not tmsql and moo then
			MsgC('DPP recommends to use TMySQL4!\n')
			
			xpcall(function()
				require("mysqloo") 
				local Link = mysqloo.connect(DPP.Host, DPP.Username, DPP.Password, DPP.Database, DPP.Port)
				Link:connect()
				Link:wait()
				
				local Status = Link:status()
				
				if Status == mysqloo.DATABASE_CONNECTED then
					DPP.IsMySQL = true
					DPP.LINK = Link
				else
					MsgC('DPP MySQL failed: \nInvalid username or password, wrong hostname or port, database does not exists, or given user can\'t access it.\n')
					print(Link:hostInfo())
				end
			end, function(err)
				MsgC('DPP MySQL failed:\nCannot make a connection (internal error). Are you sure that your installed module for your OS? (linux/windows)\n' .. err .. '\n')
				DPP.IsMySQL = false
			end)
		elseif tmysql then
			xpcall(function()
				require("tmysql4")
				local Link, Error = tmysql.initialize(DPP.Host, DPP.Username, DPP.Password, DPP.Database, DPP.Port)
				
				if not Link then
					MsgC('DPP MySQL failed: \nInvalid username or password, wrong hostname or port, database does not exists, or given user can\'t access it.\n' .. Error .. '\n')
					DPP.IsMySQL = false
				else
					DPP.LINK = Link
					DPP.IsMySQL = true
					DPP.UseTMySQL4 = true
				end
			end, function(err)
				MsgC('DPP MySQL failed:\nCannot make a connection (internal error). Are you sure that your installed module for your OS? (linux/windows)\n' .. err .. '\n')
				DPP.IsMySQL = false
			end)
		end
	end
end

Connect()

local EMPTY_FUNC = function() end

function DPP.Query(query, callback)
	callback = callback or EMPTY_FUNC
	if DPP.IsMySQL then
		if DPP.UseTMySQL4 then
			if not DPP.LINK then
				Connect()
			end
			
			if not DPP.LINK then
				MsgC('DPP: Can\'t connect to Database!\n')
			end
			
			DPP.LINK:Query(query, function(data)
				callback(data[1].data)
			end)
		else
			local obj = DPP.LINK:query(query)
			
			function obj.onSuccess(q, data)
				callback(data)
			end
			
			function obj.onError()
				if DPP.LINK:status() == mysqloo.DATABASE_NOT_CONNECTED then
					Connect()
					timer.Simple(3, function() DPP.Query(query, callback) end)
					return
				end
				
				callback()
			end
			
			obj:start()
		end
	else
		callback(sql.Query(query))
	end
end

function DPP.QueryStack(tab)
	DPP.Query('BEGIN', function()
		local c = 0
		local d = 0
		
		local Done = function()
			d = d + 1
			if d >= c then
				DPP.Query('COMMIT')
			end
		end
		
		for k, v in pairs(tab) do
			c = c + 1
			DPP.Query(v, Done)
		end
	end)
end
