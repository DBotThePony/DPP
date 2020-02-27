
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

import DPP2 from _G
import Menus from DPP2
import i18n from DLib

DPP2.DEF.RestrictionList.__base.RebuildListView = =>
	return if not IsValid(@listView)

	@listView\Clear()

	for i, entry in SortedPairsByMemberValue(@listing, 'class')
		line = @listView\AddLine(entry.class, table.concat(entry.groups, ','), entry.isWhitelist and 'gui.misc.yes' or 'gui.misc.no')
		line._entry = entry

DPP2.DEF.RestrictionList.__base.OpenEmptyListViewMenu = =>
	with menu = DermaMenu()
		add = ->
			callback = (text) -> @OpenMenu(text)
			Derma_StringRequest 'gui.dpp2.menus.query.title', 'gui.dpp2.menus.query.subtitle', '', callback, nil, 'gui.misc.ok', 'gui.misc.cancel'

		\AddOption('gui.dpp2.menus.add', add)\SetIcon(Menus.Icons.Add)

		\Open()

DPP2.DEF.RestrictionList.__base.OpenEntryMenu = (entry) =>
	edit = -> @OpenMenu(entry.class)
	remove = -> RunConsoleCommand('dpp2_remove_' .. @identifier .. '_restriction', entry.class)
	copy_classname = -> SetClipboardText(entry.class)
	copy_groups = -> SetClipboardText(table.concat(', ' , entry.groups))

	with menu = DermaMenu()
		\AddOption('gui.dpp2.menus.edit', edit)\SetIcon(Menus.Icons.Edit)

		submenu, button = \AddSubMenu('gui.dpp2.menus.remove')
		button\SetIcon(Menus.Icons.Remove)
		submenu\AddOption('gui.dpp2.menus.remove2', remove)\SetIcon(Menus.Icons.Remove)

		\AddOption('gui.dpp2.menus.copy_classname', copy_classname)\SetIcon(Menus.Icons.Copy)
		\AddOption('gui.dpp2.menus.copy_groups', copy_groups)\SetIcon(Menus.Icons.Copy)

		\Open()


DPP2.DEF.RestrictionList.__base.BuildCPanel = (panel) =>
	return if not IsValid(panel)

	@listView = vgui.Create('DListView', panel)
	@listView\Dock(TOP)
	@listView\SetTall(ScreenSize(350))

	@listView\AddColumn('gui.dpp2.toolmenu.lists.view.classname')
	@listView\AddColumn('gui.dpp2.toolmenu.lists.view.groups')
	@listView\AddColumn('gui.dpp2.toolmenu.lists.view.iswhitelist')
	@listView.OnRowRightClick = (_pnl, lineID, line) -> @OpenEntryMenu(line._entry) if line._entry
	OnMousePressed = @listView.OnMousePressed

	@listView.OnMousePressed = (_, code) ->
		@OpenEmptyListViewMenu() if code == MOUSE_RIGHT
		return OnMousePressed(_, code)

	@RebuildListView()

	@newItemButton = vgui.Create('DButton', panel)
	@newItemInput = vgui.Create('DTextEntry', panel)
	@newItemInput\Dock(TOP)
	@newItemButton\Dock(TOP)

	@newItemInput\DockMargin(5, 5, 5, 5)
	@newItemButton\DockMargin(5, 5, 5, 5)

	@newItemInput\SetPlaceholderText(i18n.localize('gui.dpp2.toolmenu.lists.view.classname'))
	@newItemButton\SetText('gui.dpp2.toolmenu.lists.add_new')
	@newItemButton\SetIcon(Menus.Icons.Add)

	@newItemInput.OnEnter = -> @newItemButton\DoClick()

	if @add_autocomplete
		@newItemInput.GetAutoComplete = (_, text) ->
			fcall = @add_autocomplete
			items = fcall(@, text, text, nil, false)
			return {'...'} if #items > 100
			return items

	@newItemButton.DoClick = ->
		text = @newItemInput\GetText()
		return if not text or text == ''
		text = text\trim()
		return if text == ''
		@newItemInput\SetText('')
		@OpenMenu(text)

	hook.Add 'DPP2_' .. @identifier .. '_EntryAdded', panel, -> timer.Create 'DPP2_RebuildLineMenu_' .. @identifier, 0.2, 1, -> @RebuildListView()
	hook.Add 'DPP2_' .. @identifier .. '_EntryRemoved', panel, -> timer.Create 'DPP2_RebuildLineMenu_' .. @identifier, 0.2, 1, -> @RebuildListView()
	hook.Add 'DPP2_' .. @identifier .. '_GroupAdded', panel, -> timer.Create 'DPP2_RebuildLineMenu_' .. @identifier, 0.2, 1, -> @RebuildListView()
	hook.Add 'DPP2_' .. @identifier .. '_GroupRemoved', panel, -> timer.Create 'DPP2_RebuildLineMenu_' .. @identifier, 0.2, 1, -> @RebuildListView()
	hook.Add 'DPP2_' .. @identifier .. '_WhitelistStatusUpdated', panel, -> timer.Create 'DPP2_RebuildLineMenu_' .. @identifier, 0.2, 1, -> @RebuildListView()

DPP2.DEF.RestrictionList.__base.OpenMenu = (classname) =>
	local isWhitelist
	local groupsAvailable
	local groupsChosen
	entry = @Get(classname)

	if entry
		isWhitelist = entry\IsWhitelist()
		groupsAvailable = [group for group in pairs(CAMI.GetUsergroups()) when not entry\HasGroup(group)]
		groupsChosen = [group for group in pairs(CAMI.GetUsergroups()) when entry\HasGroup(group)]
	else
		isWhitelist = false
		groupsAvailable = [group for group in pairs(CAMI.GetUsergroups())]
		groupsChosen = {}

	frame = vgui.Create('DLib_Window')
	frame\SetSize(ScreenSize(200), ScreenSize(300))
	frame\Center()
	frame\MakePopup()
	frame\SetTitle('gui.dpp2.restriction.edit_title', classname)

	whitelistcheckbox = vgui.Create('DCheckBoxLabel', frame)
	whitelistcheckbox\Dock(TOP)
	whitelistcheckbox\SetText('gui.dpp2.restriction.is_whitelist')
	whitelistcheckbox\SetChecked(isWhitelist)
	whitelistcheckbox\DockMargin(0, 5, 0, 5)

	canvas = vgui.Create('EditablePanel', frame)
	canvas\Dock(FILL)

	selectable = Menus.MultChooseMenu()
	selectable\SetCanAddChoices(true)
	selectable\Add(group, group, false) for group in *groupsAvailable
	selectable\Add(group, group, true) for group in *groupsChosen
	selectable\BuildOntoCanvas(canvas)

	finish = ->
		value = selectable\GetChosenValues()

		if #value == 0
			return if not entry
			RunConsoleCommand('dpp2_remove_' .. @identifier .. '_restriction', classname)
			return

		RunConsoleCommand('dpp2_add_' .. @identifier .. '_restriction', classname, table.concat(value, ','), whitelistcheckbox\GetChecked() and '1' or '0')

	selectable\AddButtonsTo(nil, frame, finish)

	return frame
