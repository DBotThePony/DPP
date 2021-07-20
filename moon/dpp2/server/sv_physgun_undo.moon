
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

savedata = (ent) ->
	objects = [ent\GetPhysicsObjectNum(i) for i = 0, ent\GetPhysicsObjectCount() - 1]

	{
		ent, ent\GetPos(), ent\GetAngles()
		[obj\GetVelocity() for obj in *objects]
		[obj\GetPos() for obj in *objects]
		[obj\GetAngles() for obj in *objects]
		[obj\IsAsleep() for obj in *objects]
		[obj\IsMotionEnabled() for obj in *objects]
	}

loaddata = (data) ->
	{ent, pos, angles, velt, post, angt, asleept, motiont} = data
	return if not IsValid(ent)
	objects = [ent\GetPhysicsObjectNum(i) for i = 0, ent\GetPhysicsObjectCount() - 1]
	ent\SetPos(pos)
	ent\SetAngles(angles)

	for i, obj in ipairs(objects)
		obj\SetVelocity(velt[i]) if velt[i]
		obj\SetPos(post[i]) if post[i]
		obj\SetAngles(angt[i]) if angt[i]

		if asleept[i] == true
			obj\Sleep()
		elseif asleept[i] == false
			obj\Wake()

		obj\EnableMotion(motiont[i]) if motiont[i] ~= nil

snapshot = (ply, ent) ->
	if ply\GetInfoBool('dpp2_cl_physgun_undo_custom', true)
		ply.__dpp2_physgun_undo = ply.__dpp2_physgun_undo or {}

		if contraption = ent\DPP2GetContraption()
			table.insert(ply.__dpp2_physgun_undo, [savedata(ent) for ent in *contraption.ents when ent\IsValid()])
		else
			table.insert(ply.__dpp2_physgun_undo, {savedata(ent)})
	else
		if contraption = ent\DPP2GetContraption()
			data2 = [savedata(ent) for ent in *contraption.ents when ent\IsValid()]

			data = savedata(ent)
			undo.Create('Physgun')
			undo.SetPlayer(ply)
			undo.AddFunction(-> loaddata(data) for data in *data2)
			undo.Finish()
		else
			data = savedata(ent)
			undo.Create('Physgun')
			undo.SetPlayer(ply)
			undo.AddFunction(-> loaddata(data))
			undo.Finish()

PhysgunPickup = (ply = NULL, ent = NULL) ->
	return if not DPP2.PHYSGUN_UNDO\GetBool()
	return if not ply\GetInfoBool('dpp2_cl_physgun_undo', true)
	return if ent\IsPlayer()
	snapshot(ply, ent)
	return

IsValid = FindMetaTable('Entity').IsValid

EntityRemoved = (ent) ->
	for ply in *player.GetAll()
		if history = ply.__dpp2_physgun_undo
			for histroy_index = #history, 1, -1
				history_entry = history[histroy_index]

				if #history_entry == 0
					table.remove(history, histroy_index)
				else
					for entry_index = #history_entry, 1, -1
						if not IsValid(history_entry[entry_index][1])
							table.remove(history_entry, entry_index)

					if #history_entry == 0
						table.remove(history, histroy_index)

OnPhysgunReload = (physgun = NULL, ply = NULL) ->
	return if not DPP2.PHYSGUN_UNDO\GetBool()
	return if not ply\GetInfoBool('dpp2_cl_physgun_undo', true)
	return if not IsValid(ply)
	tr = ply\GetEyeTrace()
	return if not IsValid(tr.Entity) or tr.Entity\IsPlayer()
	ent = tr.Entity
	snapshot(ply, ent)
	return

hook.Add 'PhysgunPickup', 'DPP2.PhysgunHistory', PhysgunPickup, 3
hook.Add 'OnPhysgunReload', 'DPP2.PhysgunHistory', OnPhysgunReload, 3
hook.Add 'EntityRemoved', 'DPP2.PhysgunHistory', EntityRemoved

DPP2.cmd.undo_physgun = (args = {}) =>
	if not @__dpp2_physgun_undo
		DPP2.LMessagePlayer(@, 'gui.dpp2.undo.physgun_nothing')
		return

	last = table.remove(@__dpp2_physgun_undo, #@__dpp2_physgun_undo)
	hit = false

	while last
		for entry in *last
			if IsValid(entry[1])
				hit = true
				loaddata(entry)

		break if hit
		last = table.remove(@__dpp2_physgun_undo, #@__dpp2_physgun_undo)

	if hit
		DPP2.NotifyUndo(@, nil, 'gui.dpp2.undo.physgun')
	else
		DPP2.LMessagePlayer(@, 'gui.dpp2.undo.physgun_nothing')

