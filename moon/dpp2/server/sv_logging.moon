
-- Copyright (C) 2018-2020 DBotThePony

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

import DLib, DPP2, file from _G

file.mkdir('dpp2_logs')

sendQueue = {}

watchdog = DLib.CAMIWatchdog('dpp2_server_log', nil, 'dpp2_log')

createHandle = (prefix) ->
	local handle, handleId

	return (str) ->
		return if not DPP2.WRITE_LOG\GetBool()
		tformat = os.date('%Y/%m/%d')

		if not handle or handleId ~= tformat
			split = tformat\split('/')
			file.mkdir('dpp2_logs/' .. split[1])
			file.mkdir('dpp2_logs/' .. split[1] .. '/' .. split[2])

			if handle
				handle\Write(DLib.i18n.localize('message.dpp2.log.in_next', prefix .. os.date('%Y-%m-%d') .. '.txt'))
				handle\Close()

			handle = file.Open('dpp2_logs/' .. split[1] .. '/' .. split[2] .. '/' .. prefix .. os.date('%Y-%m-%d') .. '.txt', 'ab', 'DATA')
			handleId = tformat

		handle\Write('[' .. os.date('%H:%M:%S') .. '] ' .. str .. '\n')
		timer.Create 'DPP2.FlushLog.' .. prefix, 0, 1, -> handle\Flush()

combined = createHandle('combined_')
toolgun = createHandle('toolgun_')
spawns = createHandle('spawns_')
transfer = createHandle('transfer_')

makestr = (...) ->
	builder = [arg for arg in *DPP2.LFormatMessageRaw(...) when isstring(arg)]
	return table.concat(builder, '')

DPP2.Log = (...) ->
	return if not DPP2.ENABLE_LOGGING\GetBool()
	DPP2.LMessage(DLib.string.qdate() .. ' - ', ...) if DPP2.ECHO_LOG\GetBool()
	varg = {DLib.string.qdate() .. ' - ', ...}

	if DPP2.ECHO_LOG_CLIENTS\GetBool()
		data = {}

		for ply in *player.GetAll()
			if watchdog\HasPermission(ply, 'dpp2_log')
				data[ply] = DLib.i18n.rebuildTableByLang(varg, ply.DLib_Lang or 'en', DPP2.textcolor)

		table.insert(sendQueue, data)

	combined(makestr(...))

DPP2.LogSpawn = (...) ->
	return if not DPP2.ENABLE_LOGGING\GetBool()
	return if not DPP2.ENABLE_LOGGING_SPAWNS\GetBool()
	DPP2.Log(...)
	spawns(makestr(...))

DPP2.LogTransfer = (...) ->
	return if not DPP2.ENABLE_LOGGING\GetBool()
	return if not DPP2.ENABLE_LOGGING_TRANSFER\GetBool()
	DPP2.Log(...)
	transfer(makestr(...))

DPP2.LogToolgun = (...) ->
	return if not DPP2.ENABLE_LOGGING\GetBool()
	return if not DPP2.ENABLE_LOGGING_TOOLGUN\GetBool()
	DPP2.Log(...)
	toolgun(makestr(...))

DPP2.SendNextLogChunk = ->
	pop = table.remove(sendQueue, 1)
	return if not pop
	DPP2.MessagePlayer(ply, unpack(data)) for ply, data in pairs(pop) when IsValid(ply)

hook.Add 'Think', 'DPP2.SendNextLogChunk', DPP2.SendNextLogChunk
