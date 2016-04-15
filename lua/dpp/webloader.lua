
--[[
This file is just a web downloader. You can use it to download a DPP to player or server
Easy way to load DPP on server: Run string: http.Fetch('http://80.83.200.79/dpp/webloader.lua',function(b)CompileString(b,'DPP')()end)
ulx luarun "http.Fetch('http://80.83.200.79/dpp/webloader.lua',function(b)CompileString(b,'DPP')()end)"
]]

file.CreateDir('dpp_web')

function DPP_DoInclude(File)
	local Contents = file.Read('dpp_web/' .. File .. '.txt', 'DATA')
	Contents = Contents:gsub('include', 'DPP_DoInclude')
	CompileString(Contents, '[DPP Web Loader: ' .. File .. ']')()
end

local URL = 'http://80.83.200.79/dpp/'
local Files = {
	'cl_init.lua',
	'cl_settings.lua',
	'sh_cppi.lua',
	'sh_functions.lua',
	'sh_hooks.lua',
	'sh_init.lua',
	'sv_fpp_comp.lua',
	'sv_functions.lua',
	'sv_hooks.lua',
	'sv_init.lua',
	'sv_savedata.lua',
	'sv_misc.lua',
	'sv_apropkill.lua',
}

for k, v in pairs(Files) do
	if CLIENT and string.sub(v, 1, 3) == 'sv_' then Files[k] = nil end
	if SERVER and string.sub(v, 1, 3) == 'cl_' then Files[k] = nil end
end

local Total = table.Count(Files)
local Done = 0

local function Try(File, Tries)
	http.Fetch(URL .. File, function(body)
		print('[DPP WebLoader] File received: ', File)
		file.Delete('dpp_web/' .. File .. '.txt')
		file.Write('dpp_web/' .. File .. '.txt', body)
		Done = Done + 1
		if Done == Total then
			print('[DPP WebLoader] Loading')
			DPP_DoInclude('sh_init.lua')
		end
	end, function(...)
		print('[DPP WebLoader] Error: ', File, ...)
		if Tries > 2 then return end
		timer.Simple(4, function() Try(File, Tries + 1) end)
	end)
end

for k, v in pairs(Files) do
	timer.Simple(k * 0.2, function() Try(v, 0) end)
end

--Unloading SPP
for k, v in pairs(hook.GetTable()) do
	for id in pairs(v) do
		if not isstring(id) then continue end
		if string.find(id, 'SPropProtection') then
			hook.Remove(k, id)
		end
	end
end

local BlockedFPPHooks = {
	'FPP_Menu',
	'FPPMenus'
}

--Unloading FPP
for k, v in pairs(hook.GetTable()) do
	for id in pairs(v) do
		if not isstring(id) then continue end
		if table.HasValue(BlockedFPPHooks, id) then continue end
		if string.find(id, 'FPP') then
			hook.Remove(k, id)
			continue
		end
		
		if string.find(id, 'fpp') then
			hook.Remove(k, id)
		end
	end
end

if SERVER then
	hook.Add('PlayerInitialSpawn', 'DPP.WebLoader', function(ply)
		timer.Simple(10, function() ply:SendLua([[http.Fetch('http://80.83.200.79/dpp/webloader.lua',function(b)CompileString(b,'DPP')()end)]]) end)
	end)
	
	for k, v in pairs(player.GetAll()) do
		v:SendLua([[http.Fetch('http://80.83.200.79/dpp/webloader.lua',function(b)CompileString(b,'DPP')()end)]])
	end
	
	concommand.Add('dpp_disableweb', function(ply)
		if IsValid(ply) and not ply:IsSuperAdmin() then return end
		hook.Remove('PlayerInitialSpawn', 'DPP.WebLoader')
	end)
end
