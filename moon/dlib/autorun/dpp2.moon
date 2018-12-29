
-- Copyright (C) 2015-2018 DBot

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

export DPP2
_G.DPP2 = DPP2 or {}

DLib.CMessageChat(DPP2, 'DPP2')

DPP2.ENABLE_PROTECTION = DLib.util.CreateSharedConvar('dpp2_protection', '1', 'Main power switch for all protection modules')

AddCSLuaFile('dpp2/sh_logic.lua')
AddCSLuaFile('dpp2/sh_owning.lua')
AddCSLuaFile('dpp2/sh_hooks.lua')
AddCSLuaFile('dpp2/sh_registry.lua')
AddCSLuaFile('dpp2/cl_logic.lua')
AddCSLuaFile('dpp2/cl_owning.lua')

include('dpp2/sh_definition.lua')
include('dpp2/sh_owning.lua')
include('dpp2/cl_owning.lua') if CLIENT
include('dpp2/sv_owning.lua') if SERVER
include('dpp2/sh_registry.lua')
include('dpp2/sh_logic.lua')
include('dpp2/sh_hooks.lua')
include('dpp2/cl_logic.lua') if CLIENT
include('dpp2/sv_logic.lua') if SERVER
include('dpp2/sv_owning.lua') if SERVER
include('dpp2/sv_hooks.lua') if SERVER
include('dpp2/sv_patches.lua') if SERVER

DPP2.PhysgunProtection = DPP2.DEF.ProtectionDefinition('physgun')
DPP2.ToolgunProtection = DPP2.DEF.ProtectionDefinition('toolgun')

with DrivePrefab = DPP2.DEF.DefinitionConVarsPrefab()
	\SetNoWorldTouch(true)
	\SetNoWorldTouchAdmin(true)
	DPP2.DriveProtection = DPP2.DEF.ProtectionDefinition('drive', DrivePrefab)

with AllowMapPrefab = DPP2.DEF.DefinitionConVarsPrefab()
	\SetNoMapTouch(false)
	\SetNoMapTouchAdmin(false)
	\SetNoWorldTouch(false)
	\SetNoWorldTouchAdmin(false)
	DPP2.DamageProtection = DPP2.DEF.ProtectionDefinition('damage', AllowMapPrefab)
	DPP2.PickupProtection = DPP2.DEF.ProtectionDefinition('pickup', AllowMapPrefab)
	DPP2.UseProtection = DPP2.DEF.ProtectionDefinition('use', AllowMapPrefab)
	DPP2.VehicleProtection = DPP2.DEF.ProtectionDefinition('vehicle', AllowMapPrefab)
	DPP2.GravgunProtection = DPP2.DEF.ProtectionDefinition('gravgun', AllowMapPrefab)
