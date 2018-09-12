
--[[
Copyright (C) 2016-2017 DBot


-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

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
