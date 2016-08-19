--[[------------------------------------------

    A.P.G. - a lightweight Anti Prop Griefing solution (v{{ script_version_name }})
    Made by While true do end (http://steamcommunity.com/id/while_true/)

    The development of APG was focused around the ability to provide a lightweight
    and efficient security against griefers whilst ensuring enough freedom to friendly players.
    The main idea was to allow everyone to play with unfrozen props,
    thus every not frozen prop_physics will be set to collision group debris;
    that way, prop_physics won't collide with each other but can interact with world, players and static stuff.
    I often take as example players playing soccer ( ball = prop_physics),
    the ball will collide with players and goals (frozen stuff) but not with other unfrozen stuff (to avoid any exploit).

    It was originally built on DarkRP but it should be compatible with other Gamemodes
    as soon as you are using CPPI to handle prop protection.

]]--------------------------------------------
APG = APG or {}
APG.cfg = APG.cfg or {}
--[[------------------------------------------
            CONFIGURATION
]]--------------------------------------------

APG.cfg.ghosting = true        -- Wether or not enable ghosting (if you have another system but you want to keep security checks)
APG.cfg.cColor = Color(34, 34, 34, 220) -- Color set when ghosted : Color(Red, Green, Blue, Alpha)
APG.cfg.Entities = {
    ["prop_physics"] = true, -- Entities on which you want to apply ghosting/protection
    ["wire_"] = false,       -- If you want to add an entity : ["entityClass"] = true
    ["gmod_"] = false        -- Find many entities by using a simple pattern such as ["wire_"] then set the value to false
}

-- Vehicles :
APG.cfg.disableVehDamage = false    -- Disable or not vehicles damages (carkill)
APG.cfg.noCollideVeh = false    -- Disable or not vehicles collision (carkill)


-- Auto freeze :
-- These settings if enabled will decrease players freedom by freezing their props every X seconds, but do as you please :)
APG.cfg.autoFreeze = false
APG.cfg.autoFreezeTime =  15 -- delay in seconds between each auto freeze

--[[--------------------
    Security checks
]]----------------------
APG.cfg.checkStack = true       -- Wether or not check if props are stacked (more than X in an area of Y units)
APG.cfg.checkStackCount = 20     -- How many props in the area
APG.cfg.checkStackDist = 12      -- Sphere radius (GMod units)

--[[ SERVER LAG DETECTION :
The system retrieves itself the regular time frame and detects any irrugularity. (using math average)
APG.cfg.ratioLag correspond to the limit ratio in order to consider the frame as 'laggy'
Depending on your server performances, you will have to increase it if you experience false positives
APG.cfg.lagSensitivity = 1.2 means that the lag has to be greater than average + 20% in order to be detected.
Console command APG_showLag <time(default:30)> can help you find the good setting
]]--
APG.cfg.lagDetect = true      -- Enable(true)/Disable lag detection
APG.cfg.lagSensitivity = 1.35        -- Increase this value if you are experiencing false positives !
APG.cfg.lagCount = 5       -- How much consecutives laggy frames before running function ( increase if you have false positives)
APG.cfg.bigLag = 1         -- Maximum time(seconds) between 2 frames to trigger function (bypass lagCount check)
APG.cfg.lagSpamTime = 15    -- Time in seconds to wait after a cleanUp/freezeProps etc.
APG.cfg.lagFunc = "cleanUp_unfrozen"   -- Function ran when lag is detected.
--[[--------- Preset functions :-----------
"cleanUp_unfrozen"
"freezeProps"
"cleanUp"
-- You can also set your own function :
function()
-- your stuff
end
-----------------------------------------]]

