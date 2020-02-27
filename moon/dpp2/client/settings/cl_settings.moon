
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

Menus._Icons = {
	Add: 'icon16/pencil_add.png'
	Edit: 'icon16/pencil.png'
	Copy: ['icon16/tag_' .. tag .. '.png' for tag in *{'blue', 'green', 'orange', 'pink', 'purple', 'red', 'yellow'}]
	Remove: 'icon16/delete.png'
}

Menus.Icons = setmetatable({}, {
	__index: (key) => istable(Menus._Icons[key]) and table.Random(Menus._Icons[key]) or Menus._Icons[key]
})

hook.Add 'PopulateToolMenu', 'DPP2.Menus', ->
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.client', 'gui.dpp2.toolmenu.client_protection', 'gui.dpp2.toolmenu.client_protection', '', '', Menus.ClientProtectionModulesMenu
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.main', 'gui.dpp2.toolmenu.primary', 'gui.dpp2.toolmenu.primary', '', '', Menus.PrimaryMenu
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.main', 'gui.dpp2.toolmenu.secondary', 'gui.dpp2.toolmenu.secondary', '', '', Menus.SecondaryMenu
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.main', 'gui.dpp2.toolmenu.antispam', 'gui.dpp2.toolmenu.antispam', '', '', Menus.AntispamMenu
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.main', 'gui.dpp2.toolmenu.antipropkill', 'gui.dpp2.toolmenu.antipropkill', '', '', Menus.AntipropkillMenu
	spawnmenu.AddToolMenuOption 'DPP/2', 'gui.dpp2.toolcategory.restriction', 'gui.dpp2.toolmenu.restrictions.toolgun_mode', 'gui.dpp2.toolmenu.restrictions.toolgun_mode', '', '', Menus.R.ToolgunMode
