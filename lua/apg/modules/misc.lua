--[[------------------------------------------

    A.P.G. - a lightweight Anti Prop Griefing solution (v{{ script_version_name }})
    Made by :
    - While True (http://steamcommunity.com/id/76561197972967270)
    - LuaTenshi (http://steamcommunity.com/id/76561198096713277)

    Licensed to : http://steamcommunity.com/id/{{ user_id }}

    ============================
        MISCELLANEOUS MODULE
    ============================

    Developper informations :
    ---------------------------------
    Used variables :
        vehDamage = { value = true, desc = "True to enable vehicles damages, false to disable." }
        vehNoCollide = { value = false, desc = "True to disable collisions between vehicles and players"}
        autoFreeze = { value = false, desc = "Freeze every unfrozen prop each X seconds" }
        autoFreezeTime = { value = 120, desc = "Auto freeze timer (seconds)"}

]]--------------------------------------------

local mod = "misc"
RunString( APG.dRM[mod])
