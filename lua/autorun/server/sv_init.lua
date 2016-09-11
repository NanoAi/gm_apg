--[[------------------------------------------
            INITIALIZE APG
]]--------------------------------------------
APG = {}
APG.modules =  APG.modules or {}

--[[------------------------------------------
            CLIENT related
]]--------------------------------------------
AddCSLuaFile("apg/sh_config.lua")
AddCSLuaFile("apg/cl_utils.lua")
AddCSLuaFile("apg/cl_menu.lua")

--[[------------------------------------------
            REGISTER Modules
]]--------------------------------------------
local modules, _ = file.Find("apg/modules/*.lua","LUA")
for _,v in next, modules do
    if v then
        niceName = string.gsub(tostring(v),"%.lua","")
        APG.modules[ niceName ] = false
        APG[ niceName ] = {}
        APG[ niceName ][ "hooks"] = {}
        APG[ niceName ][ "timers"] = {}
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
    APG.unLoad( module )
    APG.modules[ module ] = true
    APG[ module ] = {}
    APG[ module ][ "hooks"] = {}
    APG[ module ][ "timers"] = {}
    include( "apg/modules/" .. module .. ".lua" )
end

function APG.unLoad( module )
    APG.modules[ module ] = false
    local hooks = APG[ module ]["hooks"]
    if hooks then
        for k, v in next, hooks do
            hook.Remove(k, v)
        end
        table.Empty(APG[ module ][ "hooks"])
    end
    local timers = APG[ module ]["timers"]
    if timers then
        for k, v in next, timers do
            timer.Remove(v)
        end
        table.Empty(APG[ module ][ "timers"])
    end
end

function APG.reload( )
    for k, v in next, APG.modules do
        if APG.modules[k] == true then
            APG.load( k )
        else
            APG.unLoad( k )
        end
    end
end
--[[------------------------------------------
            LOADING
]]--------------------------------------------
-- Loading config first
include( "apg/sh_config.lua" )
-- Loading APG main functions
include( "apg/sv_apg.lua") -- Modules loaded at the bottom
-- Loading APG menu
include( "apg/sv_menu.lua" )
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
                APG.log( "[APG] Module " .. args[2] .. " disabled.", ply)
            else
                APG.load( args[2] )
                APG.log( "[APG] Module " .. args[2] .. " enabled.", ply)
            end
        else
            APG.log( "[APG] This module does not exist", ply)
        end

    elseif args[1] == "help" then
        local cfg = APG.cfg[ args[2] ]
        if cfg then
            APG.log( cfg.desc, ply)
        else
            APG.log( "[APG] Help : This setting does not exist", ply)
        end
    else
        APG.log( ply, "Error : unknown setting")
    end
end)
