util.AddNetworkString("apg_settings_c2s")
util.AddNetworkString("apg_menu_s2c")

local function saveSettings( json )
    if not file.Exists("apg", "DATA") then file.CreateDir( "apg" ) end
    file.Write("apg/settings.txt", json)
end
local function recSettings( len, ply)
    if not ply:IsSuperAdmin() then return end

    len = net.ReadUInt( 32 )
    if len == 0 then return end

    local settings = net.ReadData( len )
    settings = util.Decompress( settings )

    saveSettings( settings )

    settings = util.JSONToTable( settings )
    table.Merge(APG, settings)
    APG.reload()
end
net.Receive( "apg_settings_c2s", recSettings)

local function sendToClient( ply )
    local settings = {}
    settings.cfg = APG.cfg or {}
    settings.modules = APG.modules or {}

    settings = util.TableToJSON( settings )
    settings = util.Compress( settings )
    net.Start("apg_menu_s2c")
        net.WriteUInt( settings:len(), 32 ) -- Write the length of the data
        net.WriteData( settings, settings:len() ) -- Write the data
    net.Send(ply)
end

hook.Add( "PlayerSay", "openAPGmenu", function( ply, text, public )
    text = string.lower( text )
    if ply:IsSuperAdmin() and text == "!apg" then
        sendToClient( ply )
        return ""
    end
end)