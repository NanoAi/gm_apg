--[[------------------------------------------

    A.P.G. - a lightweight Anti Prop Griefing solution (v{{ script_version_name }})
    Made by :
    - While True (http://steamcommunity.com/id/76561197972967270)
    - LuaTenshi (http://steamcommunity.com/id/76561198096713277)

    Licensed to : http://steamcommunity.com/id/{{ user_id }}

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
    Avalaible premade functions
]]------------
if CLIENT then
    APG_lagFuncs = {
        "cleanup_all",
        "cleanup_unfrozen",
        "ghost_unfrozen",
        "freeze_unfrozen",
        "custom_function"
    }
end
--[[------------------------------------------
            DEFAULT SETTINGS
]]--------------------------------------------

local defaultSettings = {}
defaultSettings.modules = {
    ["ghosting"] = true,
    ["stack_detection"] = true,
    ["lag_detection"] = true,
    ["misc"] = true,
    ["method0"] = false
}

defaultSettings.cfg = {

    --[[----------
        Ghosting module
    ]]------------
    ghost_color = { value = Color(34, 34, 34, 220), desc = "Color set on ghosted props" },
    bad_ents = {
        value = {
            ["prop_physics"] = true,
            ["wire_"] = false,
            ["gmod_"] = false },
        desc = "Entities to ghost/control/secure"},
    alwaysFrozen = { value = false, desc = "Set to true to auto freeze props on physgun drop" },

    --[[----------
        Stack detection module
    ]]------------
    stackMax = { value = 20, desc = "Max amount of entities stacked on a small area"},
    stackArea = { value = 15, desc = "Sphere radius for stack detection (gmod units)"},


    --[[----------
        Lag detection module
    ]]------------

    lagTrigger = { value = 75, desc = "% difference between current lag and average lag."},
    lagsCount = { value = 8, desc = "Number of consectuives laggy frames in order to run a cleanup."},
    bigLag = { value = 2, desc = "Time (seconds) between 2 frames to trigger a cleanup"},
    lagFunc = { value = "ghost_unfrozen", desc = "Function ran on lag detected" },
    lagFuncTime = { value = 20, desc = "Time (seconds) between 2 anti lag function (avoid spam)"},
    lagFuncNotify = { value = 2, desc = "Notify : 0 - Disabled, 1 - Everyone, 2 - Admins only"},

    --[[----------
        MISC
    ]]------------
    --[[ Vehicles ]]--
    vehDamage = { value = true, desc = "True to enable vehicles damages, false to disable." },
    vehNoCollide = { value = false, desc = "True to disable collisions between vehicles and players"},

    --[[ Props related ]]--
    autoFreeze = { value = false, desc = "Freeze every unfrozen prop each X seconds" },
    autoFreezeTime = { value = 120, desc = "Auto freeze timer (seconds)"},
}
--[[------------------------------------------
            LOADING SAVED SETTINGS
]]--------------------------------------------

if SERVER and file.Exists( "apg/settings.txt", "DATA" ) then
    local settings = file.Read( "apg/settings.txt", "DATA" )
    settings = util.JSONToTable( settings )
    table.Merge( APG, settings )
else
    table.Merge( APG, defaultSettings )
end


