--[[------------------------------------------

    A.P.G. - a lightweight Anti Prop Griefing solution (v{{ script_version_name }})
    Made by :
    - While True (http://steamcommunity.com/id/76561197972967270)
    - LuaTenshi (http://steamcommunity.com/id/76561198096713277)

    Licensed to : http://steamcommunity.com/id/{{ user_id }}

    ====================================================================================
                /!\ READ ME /!\    /!\ READ ME /!\    /!\ READ ME /!\
    ====================================================================================

    This file is the default config file.
    If you want to configure APG to fit your server needs, you can either modify this file
    or edit the config ingame ( using the chat command : !apg ).

 /!\ Be sure to have your server linked on ScriptEnforcer.net ( see the How to install part on addon page )

]]--------------------------------------------
APG.cfg = APG.cfg or {}
APG.modules = APG.modules or {}

--[[----------
    Your very own custom function
]]------------
function APG.customFunc( notify )
    -- Do something
end

--[[----------
    Avalaible premade functions - THIS IS INFORMATIVE PURPOSE ONLY !
]]------------
if CLIENT then
    APG_lagFuncs = { -- THIS IS INFORMATIVE PURPOSE ONLY !
        "cleanup_all", -- Cleanup every props/ents protected by APG (not worldprops nor vehicles)
        "cleanup_unfrozen", -- Cleanup only unfrozen stuff
        "ghost_unfrozen", -- Ghost unfrozen stuff
        "freeze_unfrozen", -- Freeze unfrozen stuff
        "custom_function" -- Your custom function (see APG.customFunc)
    } -- THIS IS INFORMATIVE PURPOSE ONLY !
end

--[[------------------------------------------
            DEFAULT SETTINGS -- You CAN edit this part
]]--------------------------------------------

local defaultSettings = {}
defaultSettings.modules = { -- Set to true of false to enable/disable module
    ["ghosting"] = true,
    ["stack_detection"] = true,
    ["lag_detection"] = true,
    ["misc"] = true,
    ["method0"] = false -- [In development]
}

defaultSettings.cfg = {
    --[[----------
        Ghosting module
    ]]------------
    ghost_color = { value = Color(34, 34, 34, 220) ,desc = "Color set on ghosted props" },

    bad_ents = {
        value = {
            ["prop_physics"] = true,
            ["wire_"] = false,
            ["gmod_"] = false },
        desc = "Entities to ghost/control/secure (true if exact name, false if it is a pattern"},

    alwaysFrozen = { value = false  , desc = "Set to true to auto freeze props on physgun drop (aka APA_FreezeOnDrop)" },

    --[[----------
        Stack detection module
    ]]------------
    stackMax = { value = 20, desc = "Max amount of entities stacked in a small area"},
    stackArea = { value = 15, desc = "Sphere radius for stack detection (gmod units)"},


    --[[----------
        Lag detection module
    ]]------------
    lagTrigger = { value = 75, desc = "[Default: 75%] Differential threshold between current lag and average lag."},
    lagsCount = { value = 8, desc = "Number of consectuives laggy frames in order to run a cleanup."},
    bigLag = { value = 2, desc = "Maximum time (seconds) between 2 frames to trigger a cleanup"},
    lagFunc = { value = "ghost_unfrozen", desc = "Function ran on lag detected, see APG_lagFuncs." },
    lagFuncTime = { value = 20, desc = "Time (seconds) between 2 anti lag function (avoid spam)"},
    lagFuncNotify = { value = 2, desc = "Notify : 0 - Disabled, 1 - Everyone, 2 - Admins only"}, -- Available soon


    --[[----------
        MISC
    ]]------------
    --[[ Vehicles ]]--
    vehDamage = { value = false, desc = "True to disable vehicles damages, false to enable." },
    vehNoCollide = { value = false, desc = "True to disable collisions between vehicles and players"},
    vehIncludeWAC = { value = true, desc = "Check for WAC vehicles."}

    --[[ Props related ]]--
    autoFreeze = { value = false, desc = "Freeze every unfrozen prop each X seconds" },
    autoFreezeTime = { value = 120, desc = "Auto freeze timer (seconds)"},
}

--[[------------------------------------------
        LOADING SAVED SETTINGS -- DO NOT EDIT THIS PART
]]--------------------------------------------
if SERVER and file.Exists( "apg/settings.txt", "DATA" ) then
    local settings = file.Read( "apg/settings.txt", "DATA" )
    settings = util.JSONToTable( settings )
    table.Merge( APG, settings )
else
    table.Merge( APG, defaultSettings )
end