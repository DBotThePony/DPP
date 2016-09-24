
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

local Gray = Color(200, 200, 200)

local function WrapFunction(func, id)
	local function ProceedFunc(ply, ...)
		local status, notify, notifyLevel = func(ply, ...)

		if status then return end
		if not notify then return end

		if IsValid(ply) then
			DPP.Notify(ply, notify, notifyLevel)
		else
			DPP.Message(unpack(notify))
		end
	end

	return function(ply, ...)
		DPP.CheckAccess(ply, id, ProceedFunc, ply, ...)
	end
end

DPP.Commands = {
	cleardecals = function(ply, cmd, args)
		for k, v in pairs(player.GetAll()) do
			v:ConCommand('r_cleardecals')
			v:SendLua('game.RemoveRagdolls()')
		end
		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#com_decals'}
	end,

	toggleplayerprotect = function(ply, cmd, args)
		if not args[1] then return false, {'#com_invalid_target'}, NOTIFY_ERROR end
		if not args[2] then return false, {'#com_invalid_mode'}, NOTIFY_ERROR end
		if not args[3] then return false, {'#com_invalid_status'}, NOTIFY_ERROR end

		local target = Player(args[1])
		local mode = args[2]
		local status = tobool(args[3])

		if not IsValid(target) then return false, {'#com_invalid_target'}, NOTIFY_ERROR end
		if not DPP.ProtectionModes[mode] then return false, {'#com_invalid_pmode'}, NOTIFY_ERROR end

		DPP.SetProtectionDisabled(target, mode, status)
		local f = {IsValid(ply) and ply or '#Console', Gray, (status and ' disabled ' or ' enabled '), 'protection mode ' .. mode .. ' for ', target}
		DPP.DoEcho(f)

		return true
	end,

	cleardisconnected = function(ply, cmd, args)
		DPP.ClearDisconnectedProps()
		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#com_cleared_disconnected'}

		return true
	end,

	clearmap = function(ply, cmd, args)
		for k, v in pairs(DPP.GetAllProps()) do
			SafeRemoveEntity(v)
		end

		DPP.RecalculatePlayerList()
		DPP.SendPlayerList()

		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#com_cleared_map'}

		return true
	end,

	clearbyuid = function(ply, cmd, args)
		local uid = args[1]
		if not tonumber(uid) then return false, {'#com_invalid_uid'}, NOTIFY_ERROR end

		DPP.ClearByUID(uid)

		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#com_cleared_ply_1', {type = 'UIDPlayer', uid = uid}, Gray, '#com_cleared_ply_2'}

		return true
	end,

	freezeall = function(ply, cmd, args)
		for k, v in pairs(DPP.GetAllProps()) do
			local phys = v:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
		end

		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#com_freezed_players'}

		return true
	end,

	freezephys = function(ply, cmd, args)
		local i = DPP.FreezeAllPhysObjects()

		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#com_freezed||' .. i}

		return true
	end,

	clearplayer = function(ply, cmd, args)
		if not args[1] or args[1] == '' or args[1] == ' ' then return false, {'#com_invalid_ply_c'}, NOTIFY_ERROR end

		if tonumber(args[1]) then
			local found = Player(tonumber(args[1]))
			if not found then return false, {'#com_invalid_ply_userid'}, NOTIFY_ERROR end
			DPP.ClearPlayerEntities(found)

			DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, ' cleared all ', found, Gray, '#com_ply_ents'}
			return
		end

		local Ply = string.lower(args[1])
		local found

		for k, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()), Ply) then found = v end
		end

		if not found then return false, {'#com_invalid_target'}, NOTIFY_ERROR end
		DPP.ClearPlayerEntities(found)

		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#com_cleared_ply_1', found, Gray, '#com_cleared_ply_2'}

		return true
	end,

	clearself = function(ply, cmd, args)
		if not IsValid(ply) then return false, {'You are console'} end

		DPP.ClearPlayerEntities(ply)

		DPP.DoEcho(ply, Gray, '#com_clear_success_c')
		DPP.Notify(ply, DPP.PPhrase('com_clear_success'))

		return true
	end,

	transfertoworld = function(ply, cmd, args)
		local id = args[1]
		if not id then return false, {'#com_invalid_eid', ' (#1)'}, NOTIFY_ERROR end
		local num = tonumber(id)
		if not num then return false, {'#com_invalid_eid', ' (#1)'}, NOTIFY_ERROR end
		local ent = Entity(num)
		if not IsValid(ent) then return false, {'#not_valid', ' (#2)'}, NOTIFY_ERROR end

		DPP.SetOwner(ent, NULL)
		DPP.DeleteEntityUndo(ent)
		DPP.RecalcConstraints(ent)

		DPP.SimpleLog(ply, Gray, '#com_transfer', ent, Gray, '#com_transfer_world')
		DPP.Notify(ply, DPP.PPhrase('com_transfer_s'))

		return true
	end,

	transfertoworld_constrained = function(ply, cmd, args)
		local id = args[1]
		if not id then return false, {'#com_invalid_eid', ' (#1)'}, NOTIFY_ERROR end
		local num = tonumber(id)
		if not num then return false, {'#com_invalid_eid', ' (#1)'}, NOTIFY_ERROR end
		local ent = Entity(num)
		if not IsValid(ent) then return false, {'#not_valid', ' (#2)'}, NOTIFY_ERROR end

		local Entities = DPP.GetAllConnectedEntities(ent)

		for k, v in pairs(Entities) do
			if not IsValid(v) then continue end --World
			DPP.SetOwner(v, NULL)
			DPP.DeleteEntityUndo(v)
		end

		DPP.SimpleLog(ply, Gray, '#com_transfer', ent, Gray, '#com_transfer_world_c')
		DPP.Notify(ply, DPP.Format(DPP.PPhrase('com_transfer_s_c'))) --Format?

		DPP.RecalcConstraints(ent)

		return true
	end,

	freezeplayer = function(ply, cmd, args)
		if not args[1] then return false, {'#com_invalid_ply_c'}, NOTIFY_ERROR end

		if tonumber(args[1]) then
			local found = Player(tonumber(args[1]))
			if not found then return false, {'#com_invalid_ply_userid'}, NOTIFY_ERROR end
			DPP.FreezePlayerEntities(found)

			DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#com_freezed_all', found, Gray, '#com_ply_ents'}
			return true
		end

		local Ply = string.lower(args[1])
		local found

		for k, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()), Ply) then found = v end
		end

		if not found then return false, {'#com_no_target'}, NOTIFY_ERROR end
		DPP.FreezePlayerEntities(found)

		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#com_freezed_all', found, Gray, '#com_ply_ents'}

		return true
	end,

	freezebyuid = function(ply, cmd, args)
		local uid = args[1]

		if not tonumber(args[1]) then return false, {'#com_invalid_uid'}, NOTIFY_ERROR end
		DPP.FreezeByUID(uid)

		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#com_freezed_all', {type = 'UIDPlayer', uid = uid}, Gray, '#com_ply_ents'}

		return true
	end,

	unfreezebyuid = function(ply, cmd, args)
		local uid = args[1]

		if not tonumber(args[1]) then return false, {'#com_invalid_uid'}, NOTIFY_ERROR end

		DPP.UnFreezeByUID(uid)

		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#com_unfreezed_all', {type = 'UIDPlayer', uid = uid}, Gray, '#com_ply_ents'}

		return true
	end,

	unfreezeplayer = function(ply, cmd, args)
		if not args[1] then return false, {'#com_invalid_ply_c'}, NOTIFY_ERROR end

		if tonumber(args[1]) then
			local found = Player(tonumber(args[1]))
			if not found then return false, {'#com_invalid_ply_userid'}, NOTIFY_ERROR end
			DPP.UnFreezePlayerEntities(found)

			DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#com_unfreezed_all', found, Gray, '#com_ply_ents'}
			return true
		end

		local Ply = string.lower(args[1])
		local found

		for k, v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()), Ply) then found = v end
		end

		if not found then return false, {'#com_no_target'}, NOTIFY_ERROR end
		DPP.UnFreezePlayerEntities(found)

		DPP.NotifyLog{IsValid(ply) and ply or '#Console', Gray, '#com_unfreezed_all', found, Gray, '#com_ply_ents'}

		return true
	end,

	share = function(ply, cmd, args)
		local num = tonumber(args[1])
		local type = args[2]
		local status = args[3]

		if not num then return false, {'#com_invalid_eid', ' (#1)'}, NOTIFY_ERROR end
		if not type then return false, {'#com_invalid_share', ' (#2)'}, NOTIFY_ERROR end
		if not status then return false, {'#com_invalid_status', ' (#3)'}, NOTIFY_ERROR end

		if not DPP.ShareTypes[type] then return false, {'#com_invalid_share', ' (#2)'}, NOTIFY_ERROR end

		local ent = Entity(num)
		if not IsValid(ent) then return false, {'#not_valid'}, NOTIFY_ERROR end
		if IsValid(ply) and DPP.GetOwner(ent) ~= ply then return false, {'#not_a_owner'}, NOTIFY_ERROR end

		status = tobool(status)

		DPP.SetIsShared(ent, type, status)

		return true
	end,

	entcheck = function(ply, cmd, args)
		if IsValid(ply) then
			DPP.Notify(ply, '#look_into_console')
		end

		DPP.SimpleLog(IsValid(ply) and ply or '#Console', Gray, '#com_report_req')
		DPP.ReportEntitiesPrint()

		return true
	end,

	fallbackto = function(ply, cmd, args)
		if not IsValid(ply) then return false, {'You are console'} end
		if not args[1] then return false, {'#com_invalid_target'}, NOTIFY_ERROR end

		local found

		if tonumber(args[1]) then
			found = Player(tonumber(args[1]))
			if not IsValid(found) then
				found = nil
			end
		else
			local Ply = string.lower(args[1])

			for k, v in ipairs(player.GetAll()) do
				if string.find(string.lower(v:Nick()), Ply) then
					found = v
				end
			end
		end

		if not found or found == ply then return false, {'#com_no_target'}, NOTIFY_ERROR end

		DPP.SimpleLog(ply, Gray, '#com_target', found, Gray, '#com_owning_fallback')
		DPP.Notify(ply, DPP.Format('#com_success', found, Gray, '#com_owning_fallback_m'))

		ply:SetDPPVar('fallback', found)

		return true
	end,

	transfertoplayer = function(ply, cmd, args)
		if not IsValid(ply) then return false, {'You are console'} end
		if not args[1] then return false, {'#com_invalid_ply_c', ' (#1)'}, NOTIFY_ERROR end

		local found

		if tonumber(args[1]) then
			found = Player(tonumber(args[1]))
			if not IsValid(found) then
				found = nil
			end
		else
			local Ply = string.lower(args[1])

			for k, v in ipairs(player.GetAll()) do
				if string.find(string.lower(v:Nick()), Ply) then
					found = v
				end
			end
		end

		if not found or found == ply then return false, {'#com_no_target', ' (#1)'}, NOTIFY_ERROR end

		local id = args[2]
		if not id then return false, {'#com_invalid_eid', ' (#2)'}, NOTIFY_ERROR end
		local num = tonumber(id)
		if not num then return false, {'#com_invalid_eid', ' (#2)'}, NOTIFY_ERROR end
		local ent = Entity(num)
		if not IsValid(ent) then return false, {'#not_valid', ' (#2)'}, NOTIFY_ERROR end

		if DPP.GetOwner(ent) ~= ply then return false, {'#not_a_owner'}, NOTIFY_ERROR end

		DPP.DeleteEntityUndo(ent)
		DPP.SetOwner(ent, found)

		undo.Create('TransferedProp')
		undo.SetPlayer(found)
		undo.AddEntity(ent)

		DPP.SimpleLog(ply, Gray, '#com_transfer', color_white, ent, Gray, '#com_to', found)
		local verbose_logging = DPP.GetConVar('verbose_logging')
		
		local toRemove = {}
		
		for k, ent2 in ipairs(ent.__DPP_BundledEntities) do
			if IsValid(ent2) and DPP.GetOwner(ent2) == ply then
				DPP.SetOwner(ent2, found)
				DPP.TableRecursiveReplace(ent2:GetTable(), ply, found)
				undo.AddEntity(ent2)
				table.insert(toRemove, ent2)
				
				if verbose_logging then
					DPP.SimpleLog(ply, Gray, '#com_transfer', color_white, ent2, Gray, '#com_to', found)
				end
			end
		end
		
		DPP.DeleteEntityUndoByTable(toRemove)
		
		undo.Finish()
		
		DPP.TableRecursiveReplace(ent:GetTable(), ply, found)
		
		DPP.Notify(ply, DPP.Format('#com_owning_transfer', found))

		return true
	end,

	transfertoplayer_all = function(ply, cmd, args)
		if not IsValid(ply) then return false, {'You are console'} end
		if not args[1] then return false, {'#com_invalid_target'}, NOTIFY_ERROR end

		local found

		if tonumber(args[1]) then
			found = Player(tonumber(args[1]))
			if not IsValid(found) then
				found = nil
			end
		else
			local Ply = string.lower(args[1])

			for k, v in ipairs(player.GetAll()) do
				if string.find(string.lower(v:Nick()), Ply) then
					found = v
				end
			end
		end

		if not found or found == ply then return false, {'#com_no_target'}, NOTIFY_ERROR end

		local props = DPP.GetPropsByUID(ply:UniqueID())
		if #props == 0 then return false, {'#com_no_props_to_transfer'} end

		for k, v in ipairs(props) do
			DPP.SetOwner(v, found)
			DPP.TableRecursiveReplace(v:GetTable(), ply, found)
		end

		DPP.TransferUndoTo(ply, found)

		DPP.SimpleLog(ply, Gray, '#com_transfer_all', found)
		DPP.Notify(ply, DPP.Format('#com_owning_transfer_all', found))

		return true
	end,

	removefallbackto = function(ply, cmd, args)
		if not IsValid(ply) then return false, {'You are console'} end
		if not IsValid(ply:DPPVar('fallback')) then return false, {'#com_owning_no'}, NOTIFY_ERROR end

		DPP.SimpleLog(ply, Gray, '#com_owning_removed')
		DPP.Notify(ply, '#com_owning_removed_n')

		ply:SetDPPVar('fallback', NULL)

		return true
	end,

	inspect = function(ply, cmd, args)
		if not IsValid(ply) then return false, {'You are console'} end
		
		local tr = util.TraceLine{
			start = ply:EyePos(),
			endpos = ply:EyePos() + ply:EyeAngles():Forward() * 32000,
			mask = MASK_ALL,
			filter = ply
		}
		
		net.Start('DPP.InspectEntity')
		net.Send(ply)
		
		DPP.Echo(ply, '#inspect_server')
		local ent = tr.Entity
		
		if not IsValid(ent) then
			DPP.Echo(ply, '#inspect_noentity')
		else
			DPP.Echo(ply, '#inspect_class', color_white, ent:GetClass())
			DPP.Echo(ply, '#inspect_pos', color_white, DPP.ToString(ent:GetPos()))
			DPP.Echo(ply, '#inspect_ang', color_white, DPP.ToString(ent:GetAngles()))
			DPP.Echo(ply, '#inspect_table', color_white, DPP.ToString(table.Count(ent:GetTable())))
			DPP.Echo(ply, '#inspect_hp', color_white, DPP.ToString(ent:Health()))
			DPP.Echo(ply, '#inspect_mhp', color_white, DPP.ToString(ent:GetMaxHealth()))
			DPP.Echo(ply, '#inspect_owner', color_white, DPP.ToString(DPP.GetOwner(ent)))
			
			DPP.Echo(ply, '#inspect_model', color_white, DPP.ToString(ent:GetModel()))
			DPP.Echo(ply, '#inspect_skin', color_white, DPP.ToString(ent:GetSkin()))
			DPP.Echo(ply, '#inspect_bodygroups', color_white, DPP.ToString(table.Count(ent:GetBodyGroups() or {})))
		end

		return true
	end,
}

DPP.RawCommands = {}

for k, v in pairs(DPP.Commands) do
	DPP.RawCommands[k] = v
	DPP.Commands[k] = WrapFunction(v, k)
	concommand.Add('dpp_' .. k, DPP.Commands[k])
end

DPP.Commands.entreport = DPP.Commands.entcheck
