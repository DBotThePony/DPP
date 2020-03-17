
-- Copyright (C) 2018-2019 DBotThePony

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

properties.Add('dpp2_transferent', {
	Type: 'simple'
	MenuLabel: 'gui.dpp2.property.transferent'
	Order: 1670
	MenuIcon: 'icon16/pencil_go.png'

	Filter: (ent, ply = LocalPlayer()) =>
		return false if not IsValid(ent)
		return #player.GetHumans() > 1 and ent\DPP2GetOwner() == ply and DPP2.cmd_perm_watchdog\HasPermission('dpp2_transferent')

	MenuOpen: (option, ent, tr) =>
		return if not IsValid(ent)
		lply = LocalPlayer()
		menu = option\AddSubMenu()

		for ply in *player.GetHumans()
			if ply ~= lply
				exec = ->
					return DPP2.NotifyError(nil, nil, 'message.dpp2.property.transferent.nolongervalid') if not IsValid(ent)
					return DPP2.NotifyError(nil, nil, 'message.dpp2.property.transferent.noplayer') if not IsValid(ply)
					RunConsoleCommand('dpp2_transferent', ent\EntIndex(), ply\UserID())

				menu\AddOption(ply\Nick(), exec)\SetIcon(not ply\IsAdmin() and 'icon16/user.png' or 'icon16/shield.png')
})

properties.Add('dpp2_transfercontraption', {
	Type: 'simple'
	MenuLabel: 'gui.dpp2.property.transfercontraption'
	Order: 1671
	MenuIcon: 'icon16/folder_go.png'

	Filter: (ent, ply = LocalPlayer()) =>
		return false if not IsValid(ent)
		return #player.GetHumans() > 1 and ent\DPP2HasContraption() and ent\DPP2GetContraption()\HasOwner(ply) and DPP2.cmd_perm_watchdog\HasPermission('dpp2_transferent')

	MenuOpen: (option, ent, tr) =>
		return if not IsValid(ent)
		lply = LocalPlayer()
		menu = option\AddSubMenu()

		for ply in *player.GetHumans()
			if ply ~= lply
				exec = ->
					return DPP2.NotifyError(nil, nil, 'message.dpp2.property.transferent.nolongervalid') if not IsValid(ent)
					return DPP2.NotifyError(nil, nil, 'message.dpp2.property.transferent.noplayer') if not IsValid(ply)
					return DPP2.NotifyError(nil, nil, 'message.dpp2.property.transfercontraption.nolongervalid') if not ent\DPP2HasContraption()
					RunConsoleCommand('dpp2_transfercontraption', ent\DPP2GetContraption()\GetID(), ply\UserID())

				menu\AddOption(ply\Nick(), exec)\SetIcon(not ply\IsAdmin() and 'icon16/user.png' or 'icon16/shield.png')
})

properties.Add('dpp2_transfertoworldent', {
	Type: 'simple'
	MenuLabel: 'gui.dpp2.property.transfertoworldent'
	Order: 1672
	MenuIcon: 'icon16/world_go.png'

	Filter: (ent, ply = LocalPlayer()) =>
		return false if not IsValid(ent)
		return ent\DPP2GetOwner() == ply and DPP2.cmd_perm_watchdog\HasPermission('dpp2_transfertoworldent')

	Action: (ent, tr) =>
		return DPP2.NotifyError(nil, nil, 'message.dpp2.property.transferent.nolongervalid') if not IsValid(ent)
		RunConsoleCommand('dpp2_transfertoworldent', ent\EntIndex())
})

properties.Add('dpp2_transfertoworldcontraption', {
	Type: 'simple'
	MenuLabel: 'gui.dpp2.property.transfertoworldcontraption'
	Order: 1673
	MenuIcon: 'icon16/world_link.png'

	Filter: (ent, ply = LocalPlayer()) =>
		return false if not IsValid(ent)
		return ent\DPP2HasContraption() and ent\DPP2GetContraption()\HasOwner(ply) and DPP2.cmd_perm_watchdog\HasPermission('dpp2_transfertoworldcontraption')

	Action: (ent, tr) =>
		return DPP2.NotifyError(nil, nil, 'message.dpp2.property.transferent.nolongervalid') if not IsValid(ent)
		return DPP2.NotifyError(nil, nil, 'message.dpp2.property.transfercontraption.nolongervalid') if not ent\DPP2HasContraption()
		RunConsoleCommand('dpp2_transfertoworldcontraption', ent\DPP2GetContraption()\GetID())
})

if CLIENT
	DPP2.cmd_existing.transfertoworld = true
	DPP2.cmd_existing.transferunfallback = true
