
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

Menus.Slider = (name, convar, min = 0, max = 1, decimals = 0) =>
	convar = 'dpp2_' .. convar
	_obj = ConVar(convar)
	panel = @NumSlider(name, convar, min, max, decimals)

	panel.OnValueChanged = (newValue) =>
		return if newValue == _obj\GetBool()
		timer.Create 'DPP2_ConVarChange_' .. convar, 0.2, 1, -> RunConsoleCommand('dpp2_setvar', convar, newValue)

	return panel

Menus.CheckBox = (name, convar) =>
	convar = 'dpp2_' .. convar
	panel = @CheckBox(name, convar)
	_obj = ConVar(convar)

	panel.Button.OnChange = (newValue) =>
		return if newValue == _obj\GetBool()
		timer.Create 'DPP2_ConVarChange_' .. convar, 0.2, 1, -> RunConsoleCommand('dpp2_setvar', convar, newValue and '1' or '0')

	return panel

Menus.QCheckBox = (convar) => Menus.CheckBox(@, 'gui.dpp2.cvars.' .. convar, convar)
Menus.QSlider = (convar, ...) => Menus.Slider(@, 'gui.dpp2.cvars.' .. convar, convar, ...)

class Menus.MultiChooseItem
	new: (label, value, ...) =>
		@label = label
		@value = value
		@labelValue = {...}

	FriendlyLabel: =>
		if @_labelCache or i18n.exists(@label)
			@_labelCache = i18n.format(@label, unpack(@labelValue)) if not @_labelCache
			return @_labelCache

		return @label

class Menus.MultChooseMenu
	new: =>
		@options = {}
		@availableOptions = {}
		@chosenOptions = {}
		@canAddChoices = false

	SetCanAddChoices: (can) => @canAddChoices = can

	Has: (value) =>
		return true for option in *@options when option.value == value
		return false

	Add: (label, value, isChosen = false, ...) =>
		return false if @Has(value)
		choice = Menus.MultiChooseItem(label, value, ...)
		return @AddItem(choice, isChosen)

	AddItem: (item, isChosen = false) =>
		return false if @Has(item.value)
		table.insert(@options, item)

		if isChosen
			table.insert(@chosenOptions, item)
		else
			table.insert(@availableOptions, item)

		return true

	_RebuildLines: =>
		@listViewAvailable\Clear()
		@listViewChosen\Clear()

		for option in *@availableOptions
			line = @listViewAvailable\AddLine(option\FriendlyLabel())
			line._pickobj = option
			option._line = line

		for option in *@chosenOptions
			line = @listViewChosen\AddLine(option\FriendlyLabel())
			line._pickobj = option
			option._line = line

	_DoMove: (objects, mtype) =>
		targetNew = mtype and @chosenOptions or @availableOptions
		table.insert(targetNew, object) for object in *objects
		@[mtype and 'availableOptions' or 'chosenOptions'] = [object for object in *@options when not table.qhasValue(targetNew, object)]
		@_RebuildLines()

	GetChosen: => @chosenOptions
	GetChosenValues: => [object.value for object in *@chosenOptions]

	AddCallback: (callback) => @applyCallback = callback

	OnApply: =>
		@applyCallback(@) if @applyCallback

	BuildOntoCanvas: (canvas) =>
		@buttonsCanvas = vgui.Create('EditablePanel', canvas)
		@listViewAvailable = vgui.Create('DListView', canvas)
		@listViewChosen = vgui.Create('DListView', canvas)
		@middleCanvas = vgui.Create('EditablePanel', canvas)

		@listViewAvailable\AddColumn('gui.dpp2.chosepnl.column.available')
		@listViewChosen\AddColumn('gui.dpp2.chosepnl.column.chosen')
		@listViewAvailable\SetMultiSelect(true)
		@listViewChosen\SetMultiSelect(true)

		@middleCanvas\SetWidth(45)
		@buttonsCanvas\SetHeight(30)

		@buttonsCanvas\Dock(BOTTOM)
		@listViewAvailable\Dock(LEFT)
		@listViewChosen\Dock(RIGHT)
		@middleCanvas\Dock(FILL)
		@buttonsCanvas\DockMargin(0, 5, 0, 2)

		canvas.PerformLayout = (_, width, height) ->
			@listViewAvailable\SetWidth(width / 2 - 45)
			@listViewChosen\SetWidth(width / 2 - 45)
			@addInput\SetWide(width - @addButton\GetWide() - @applyButton\GetWide() - @cancelButton\GetWide()) if IsValid(@addInput)
			@moveToChosenButton\DockMargin(2, @middleCanvas\GetTall() / 2 - @moveToChosenButton\GetTall() / 2 - @moveToAvailableButton\GetTall() / 2 - 2, 2, 2)

		@moveToChosenButton = vgui.Create('DButton', @middleCanvas)
		@moveToAvailableButton = vgui.Create('DButton', @middleCanvas)

		@moveToChosenButton\Dock(TOP)
		@moveToChosenButton\SetText('gui.dpp2.chosepnl.buttons.to_chosen')
		@moveToAvailableButton\Dock(TOP)
		@moveToAvailableButton\SetText('gui.dpp2.chosepnl.buttons.to_available')

		@moveToChosenButton\DockMargin(2, 2, 2, 2)
		@moveToAvailableButton\DockMargin(2, 2, 2, 2)

		if @canAddChoices
			@addInput = vgui.Create('DTextEntry', @buttonsCanvas)
			@addButton = vgui.Create('DButton', @buttonsCanvas)

			@addInput\Dock(LEFT)
			@addButton\Dock(LEFT)

			@addInput\SetPlaceholderText(i18n.localize('gui.dpp2.chosepnl.add.entry'))
			@addButton\SetText('gui.dpp2.chosepnl.add.add')
			@addButton\SizeToContents()
			@addButton\SetWide(@addButton\GetWide() + 6)

			@addInput.OnEnter = -> @addButton\DoClick()
			@addButton.DoClick = ->
				text = @addInput\GetText()
				return if not text
				text = text\trim()
				return if text == ''
				@Add(text, text)
				@addInput\SetText('')
				@_RebuildLines()
				-- @addInput\KillFocus()

		@_RebuildLines()

		@moveToChosenButton.DoClick = ->
			lines = @listViewAvailable\GetSelected()
			return if #lines == 0
			@_DoMove([line._pickobj for line in *lines], true)

		@moveToAvailableButton.DoClick = ->
			lines = @listViewChosen\GetSelected()
			return if #lines == 0
			@_DoMove([line._pickobj for line in *lines], false)

		return canvas

	AddButtonsTo: (canvas = @buttonsCanvas, frame = @frame, callback = (-> @OnApply())) =>
		@cancelButton = vgui.Create('DButton', canvas)
		@applyButton = vgui.Create('DButton', canvas)
		@applyButton\SetText('gui.misc.apply')
		@cancelButton\SetText('gui.misc.cancel')

		@applyButton\Dock(RIGHT)
		@cancelButton\Dock(RIGHT)

		@applyButton\SizeToContents()
		@applyButton\SetWide(@addButton\GetWide() + 12)
		@cancelButton\SizeToContents()
		@cancelButton\SetWide(@addButton\GetWide() + 12)

		@cancelButton.DoClick = ->
			frame\Close()

		@applyButton.DoClick = ->
			callback()
			frame\Close()

	BuildFrame: =>
		@frame\Remove() if IsValid(@frame)
		@frame = vgui.Create('DLib_Window')
		@frame\SetSize(ScreenSize(150), ScreenSize(400))
		@frame\Center()
		@frame\MakePopup()

		@BuildOntoCanvas(@frame)
		@AddButtonsTo()

		return @frame

