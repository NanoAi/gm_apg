--[[------------------------------------------

    A.P.G. - a lightweight Anti Prop Griefing solution (v{{ script_version_name }})
    Made by :
    - While True (http://steamcommunity.com/id/76561197972967270)
    - LuaTenshi (http://steamcommunity.com/id/76561198096713277)

    Licensed to : http://steamcommunity.com/id/{{ user_id }}


    ============================
        LAG DETECTION MODULE
    ============================

    Developper informations :
    ---------------------------------
    Used variables :
        lagTrigger = { value = 75, desc = "% difference between current lag and average lag."}
        lagsCount = { value = 8, desc = "Number of consectuives laggy frames in order to run a cleanup."}
        bigLag = { value = 2, desc = "Time (seconds) between 2 frames to trigger a cleanup"}
        lagFunc = { value = "cleanUp_unfrozen", desc = "Function ran on lag detected" }
        lagFuncTime = { value = 20, desc = "Time (seconds) between 2 cleanup (avoid spam)"}

    Ready to hook :
        APG_lagDetected = Ran on lag detected by the server.
        Example : hook.Add( "APG_lagDetected", "myLagDetectHook", function() print("[APG] Lag detected (printed from my very own hook)")  end)

]]--------------------------------------------
local mod = "lag_detection"
RunString( APG.dRM[mod])
