
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

import DPP2, DLib from _G
import i18n from DLib
import Menus from DPP2
import net from DLib

net.receive 'dpp2_limitlist_clear', ->
	identifier = net.ReadString()
	obj = assert(DPP2.DEF.LimitRegistry\GetByID(identifier), 'Unknown limit list ' .. identifier .. '!')
	entry\Remove() for entry in *[entry2 for entry2 in *obj.listing]

net.receive 'dpp2_limitentry_change', ->
	id = net.ReadUInt32()
	assert(DPP2.DEF.LimitEntry\GetByID(id), 'Unknown limit entry with id ' .. id .. '!')\ReadPayload()

net.receive 'dpp2_limitentry_remove', ->
	id = net.ReadUInt32()
	assert(DPP2.DEF.LimitEntry\GetByID(id), 'Unknown limit entry with id ' .. id .. '!')\Remove()

net.receive 'dpp2_limitentry_create', ->
	identifier = net.ReadString()
	obj = assert(DPP2.DEF.LimitRegistry\GetByID(identifier), 'Unknown limit list ' .. identifier .. '!')
	id = net.ReadUInt32()
	entry = DPP2.DEF.LimitEntry\ReadPayload()
	entry\Bind(obj)
	entry.replicated = true
	entry.id = id
	obj\AddEntry(entry)

net.receive 'dpp2_limitlist_replicate', ->
	identifier = net.ReadString()
	obj = assert(DPP2.DEF.LimitRegistry\GetByID(identifier), 'Unknown limit list ' .. identifier .. '!')

	entry\Remove() for entry in *[entry2 for entry2 in *obj.listing]

	for i = 1, net.ReadUInt16()
		id = net.ReadUInt32()
		entry = DPP2.DEF.LimitEntry\ReadPayload()
		entry\Bind(obj)
		entry.replicated = true
		entry.id = id
		obj\AddEntry(entry)

net.receive 'dpp2_limithit', -> hook.Run('LimitHit', net.ReadString())

DPP2.DEF.LimitRegistry.__base.RebuildListView = =>
	return if not IsValid(@listView)

	@listView\Clear()

	sorted = [e for e in *@listing]
	table.sort sorted, (a, b) ->
		if a.class == b.class
			return a.group < b.group

		return a.class < b.class

	for entry in *sorted
		@listView\AddLine(entry.class, entry.group, entry.limit)._entry = entry

DPP2.DEF.LimitRegistry.__base.OpenMenu = (classname) =>
	frame = vgui.Create('DLib_Window')
	frame\SetSize(ScreenSize(200), ScreenSize(300))
	frame\Center()
	frame\MakePopup()
	frame\SetTitle('gui.dpp2.limit.edit_title', classname)

	entries = {}

	with close = vgui.Create('DButton', frame)
		\Dock(BOTTOM)
		\Dock(5, 5, 5, 5)
		\SetText('gui.misc.cancel')
		.DoClick = -> frame\Close()

	with apply = vgui.Create('DButton', frame)
		\Dock(BOTTOM)
		\Dock(5, 5, 5, 5)
		\SetText('gui.misc.apply')
		.DoClick = ->
			for group, entry in pairs(entries)
				entry2 = @Get(classname, group)

				if value = tonumber(entry\GetValue())
					if not entry2 or value ~= entry2.limit
						RunConsoleCommand('dpp2_' .. @add_command_identifier, classname, group, entry\GetValue())
				elseif entry2
					RunConsoleCommand('dpp2_' .. @remove_command_identifier, classname, group)

			frame\Close()

	scroll = vgui.Create('DScrollPanel', frame)
	scroll\Dock(FILL)
	canvas = scroll\GetCanvas()

	groups = [group for group in pairs(CAMI.GetUsergroups())]

	for entry in *@listing
		if entry\Is(classname) and not table.qhasValue(groups, entry.group)
			table.insert(groups, entry.group)

	for group in *groups
		with row = vgui.Create('EditablePanel', canvas)
			\Dock(TOP)
			\DockMargin(5, 2, 5, 2)
			entry = @Get(classname, group)

			with label = vgui.Create('DLabel', row)
				\Dock(LEFT)
				\DockMargin(0, 0, 2, 0)
				\SetText(group)
				\SetWide(ScreenSize(140))

			with text = vgui.Create('DTextEntry', row)
				\Dock(RIGHT)
				\DockMargin(2, 0, 0, 0)
				\SetValue(entry and entry.limit or '')
				\SetWide(ScreenSize(140))
				entries[group] = text

DPP2.DEF.LimitRegistry.__base.OpenEmptyListViewMenu = =>
	with menu = DermaMenu()
		add = ->
			callback = (text) -> RunConsoleCommand('dpp2_' .. @add_command_identifier, text)
			Derma_StringRequest 'gui.dpp2.menus.query.title', 'gui.dpp2.menus.query.subtitle', '', callback, nil, 'gui.misc.ok', 'gui.misc.cancel'

		\AddOption('gui.dpp2.menus.add', add)\SetIcon(Menus.Icons.Add)
		\Open()

DPP2.DEF.LimitRegistry.__base.OpenEntryMenu = (entry) =>
	remove = -> RunConsoleCommand('dpp2_' .. @remove_command_identifier, entry.class, entry.group)
	edit = -> @OpenMenu(entry.class)
	copy_classname = -> SetClipboardText(entry.class)
	copy_group = -> SetClipboardText(entry.group)
	copy_limit = -> SetClipboardText(entry.limit\tostring())

	with menu = DermaMenu()
		submenu, button = \AddSubMenu('gui.dpp2.menus.remove')
		button\SetIcon(Menus.Icons.Remove)
		submenu\AddOption('gui.dpp2.menus.remove2', remove)\SetIcon(Menus.Icons.Remove)

		\AddOption('gui.dpp2.menus.edit', edit)\SetIcon(Menus.Icons.Edit)
		\AddOption('gui.dpp2.menus.copy_classname', copy_classname)\SetIcon(Menus.Icons.Copy)
		\AddOption('gui.dpp2.menus.copy_group', copy_group)\SetIcon(Menus.Icons.Copy) if entry.group
		\AddOption('gui.dpp2.menus.copy_limit', copy_limit)\SetIcon(Menus.Icons.Copy)

		\Open()

DPP2.DEF.LimitRegistry.__base.BuildCPanel = (panel) =>
	return if not IsValid(panel)

	@listView = vgui.Create('DListView', panel)
	@listView\Dock(TOP)
	@listView\SetTall(ScreenSize(350))

	@listView\AddColumn('gui.dpp2.limit_lists.view.classname')
	@listView\AddColumn('gui.dpp2.limit_lists.view.group')
	@listView\AddColumn('gui.dpp2.limit_lists.view.limit')
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

	@newItemInput\SetPlaceholderText(i18n.localize('gui.dpp2.limit_lists.view.classname'))
	@newItemButton\SetText('gui.dpp2.restriction_lists.add_new')
	@newItemButton\SetIcon(Menus.Icons.Add)

	@newItemInput.OnEnter = -> @newItemButton\DoClick()

	Menus.QCheckBox(panel, @identifier .. '_limits_enabled')
	Menus.QCheckBox(panel, @identifier .. '_limits_inclusive')

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

	hook.Add 'DPP2_Limits_' .. @identifier .. '_EntryAdded', panel, -> timer.Create 'DPP2_RebuildLineMenu_Limits_' .. @identifier, 0.2, 1, -> @RebuildListView()
	hook.Add 'DPP2_Limits_' .. @identifier .. '_EntryRemoved', panel, -> timer.Create 'DPP2_RebuildLineMenu_Limits_' .. @identifier, 0.2, 1, -> @RebuildListView()
	hook.Add 'DPP2_Limits_' .. @identifier .. '_EntryChanged', panel, -> timer.Create 'DPP2_RebuildLineMenu_Limits_' .. @identifier, 0.2, 1, -> @RebuildListView()
