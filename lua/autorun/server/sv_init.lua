--[[------------------------------------------
            INITIALIZE APG
]]--------------------------------------------
APG = APG or {}
APG.modules =  APG.modules or {}
--[[------------------------------------------
            REGISTER Modules
]]--------------------------------------------
include( "apg/sv_apg.lua")
local modules, _ = file.Find("apg/modules/*.lua","LUA")
for _,v in next, modules do
    if v then
        niceName = string.gsub(tostring(v),"%.lua","")
        APG.modules[ niceName ] = false
    end
end

function APG.hookAdd( module, event, identifier, func )
    local eventTab = APG[ module ][ "hooks"][ event ] or {}
    table.insert( eventTab, identifier )
    APG[ module ][ "hooks"][ event ] = eventTab
    hook.Add( event, identifier, func )
end
function APG.timerCreate( module, identifier, delay, repetitions, func )
    table.insert( APG[ module ][ "timers"], identifier )
    timer.Create( identifier, delay, repetitions, func )
end

function APG.load( module )
    if not APG.modules[ module ] and APG.modules[ module ] == nil then return end
    APG.modules[ module ] = true
    APG[ module ] = {}
    APG[ module ][ "hooks"] = {}
    APG[ module ][ "timers"] = {}
    include( "apg/modules/" .. module .. ".lua" )
end

function APG.unLoad( module )
    if not APG.modules[ module ] then return end
    APG.modules[ module ] = false
    local hooks = APG[ module ]["hooks"]
    for k, v in next, hooks do
        hook.Remove(k, v)
    end
    local timers = APG[ module ]["timers"]
    for k, v in next, timers do
        timer.Remove(v)
    end
    table.Empty(APG[ module ][ "hooks"])
    table.Empty(APG[ module ][ "timers"])
end
--[[------------------------------------------
            LOADING Settings
]]--------------------------------------------
include( "apg/sv_config.lua" )

--[[------------------------------------------
            CVars INIT
]]--------------------------------------------

concommand.Add("apg", function( ply, cmd, args, argStr )
    if not ply:IsSuperAdmin() then return end

    if args[1] == "module" then
        local _module = APG.modules[ args[2] ]
        if _module != nil then
            if _module == true then
                APG.unLoad( args[2] )
                APG.log( ply, "[APG] Module " .. args[2] .. " disabled.")
            else
                APG.load( args[2] )
                APG.log( ply, "[APG] Module " .. args[2] .. " enabled.")
            end
        else
            APG.log( ply, "[APG] This module does not exists")
        end

    elseif args[1] == "help" then
        local cfg = APG.cfg[ args[2] ]
        if cfg then
            APG.log( ply, cfg.desc)
        else
            APG.log( ply, "[APG] Help : This setting does not exists")
        end
    else
        APG.notify(ply, "Error : unknown setting", NOTIFY_ERROR, 3.5, 1)
        APG.log( ply, "Error : unknown setting")
    end
end)
