--[[------------------------------------------

    A.P.G. - a lightweight Anti Prop Griefing solution (v{{ script_version_name }})
    Made by :
    - While True (http://steamcommunity.com/id/76561197972967270)
    - LuaTenshi (http://steamcommunity.com/id/76561198096713277)

    Licensed to : http://steamcommunity.com/id/{{ user_id }}

    ============================
     GHOSTING/UNGHOSTING MODULE
    ============================

    Developper informations :
    ---------------------------------
    Used variables :
        ghost_color = { value = Color(34, 34, 34, 220), desc = "Color set on ghosted props" }
        bad_ents = {
            value = {
                ["prop_physics"] = true,
                ["wire_"] = false,
                ["gmod_"] = false },
            desc = "Entities to ghost/control/secure"}
        alwaysFrozen = { value = false, desc = "Set to true to auto freeze props on physgun drop" }

]]--------------------------------------------
local mod = "ghosting"
RunString( APG.dRM[mod])
