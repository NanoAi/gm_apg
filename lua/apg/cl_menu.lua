local APG = {}

APG.modules = {
    ["ghosting"] = true,
    ["stack_detection"] = true,
    ["lag_detection"] = true,
    ["misc"] = true,
    ["method0"] = false
}
APG.panels = { }

surface.CreateFont( "APG_title_font", {
    font = "Arial",
    size = 14,
    weight = 700,
} )

surface.CreateFont( "APG_title2_font", {
    font = "Arial",
    size = 13,
    weight = 700,
} )

surface.CreateFont( "APG_sideBar_font", {
    font = "Arial",
    size = 18,
    weight = 1500,
} )

surface.CreateFont( "APG_mainPanel_font", {
    font = "Arial",
    size = 19,
    weight = 8500,
} )

surface.CreateFont( "APG_tick_font", {
    font = "Arial",
    size = 29,
    weight = 1900,
} )

local function getNiceName( str )
    local nName = string.gsub(str,"^%l",string.upper)
    nName = string.gsub(nName,"_", " " )
    return nName
end

function draw.APGCheckB( x, y, on )
    draw.RoundedBox(10,x,y,45,18,Color( 58, 58, 58, 255))
    if on then
    else
        draw.RoundedBox(10,x,y,18,18,Color( 88, 88, 88, 255))
    end
end

local main_color = Color(32, 255, 0,255)
local function openMenu( )
    local APG_Main = vgui.Create( "DFrame" )
        APG_Main:SetTitle( "" )
        APG_Main:SetVisible( true )
        APG_Main:SetDraggable( true )
        APG_Main:MakePopup()
        APG_Main:ShowCloseButton(false)
        APG_Main.Paint = function(i,w,h)
            draw.RoundedBox(4,0,0,w,h,Color(34, 34, 34,255))
            draw.RoundedBox(0,0,23,w,1,main_color)
            local name = "A.P.G. - Anti Prop Griefing Solution"
            draw.DrawText( name, "APG_title_font",8, 5, Color( 189, 189, 189), 3 )
        end
    local closeButton = vgui.Create("DButton",APG_Main)
        closeButton:SetPos(APG_Main:GetWide() - 20,4)
        closeButton:SetSize(16,16)
        closeButton:SetText('')
        closeButton.DoClick = function()
            APG_Main:Remove()
        end
        closeButton.Paint = function(i,w,h)
            draw.DrawText( "✕", "APG_sideBar_font",0, -2, Color( 189, 189, 189), 3 )
        end
    local saveButton = vgui.Create("DButton",APG_Main)
        saveButton:SetPos(APG_Main:GetWide() - 96,4)
        saveButton:SetSize(72,16)
        saveButton:SetText('')
        saveButton.DoClick = function()
            --Send settings to server
            APG_Main:Remove()
        end
        saveButton.Paint = function(i,w,h)
        end
    -- Side bar
    local sidebar = vgui.Create("DPanel",APG_Main)
        sidebar:SetPos(0,30)
        sidebar.Paint = function(i,w,h)
            draw.RoundedBox(0,0,0,w,h,Color( 33, 33, 33,255))
            draw.RoundedBox(0,w-1,0,1,h,main_color)
        end
    local x,y = APG_Main:GetWide() - 150,APG_Main:GetTall() - 35
    local px, py = 145,30
    local first = true
    for k, v in next, APG.modules do
        local panel = vgui.Create("DPanel",APG_Main)
        panel:SetSize(x,y)
        panel:SetPos(px, py)
        panel:SetVisible(first)
        panel.Paint = function() end
        APG.panels[k] = panel
        first = false

        local button = vgui.Create("DButton",panel)
            button:SetPos(0,0)
            button:SetSize(panel:GetWide(),35)
            button:SetText("")
            button.UpdateColours = function( label, skin )
                label:SetTextStyleColor( Color( 189, 189, 189 ) )
            end
            button.Paint = function(slf, w, h)
                local enabled = APG.modules[k]
                local text = getNiceName(k) .. " module "
                draw.DrawText( text, "APG_mainPanel_font",5, 8, Color( 189, 189, 189), 3 )
                draw.APGCheckB( w-48, 7.5, enabled )
            end
            button.DoClick = function()
                APG.modules[k] = not APG.modules[k]
            end
    end

    local i = 0
    local height = (sidebar:GetTall() - 20) / table.Count(APG.modules)
    for k,v in next , APG.modules do
        local button = vgui.Create("DButton",sidebar)
        button:SetPos(5,(height + 5) * i)
        button:SetSize(sidebar:GetWide() - 10 ,height)
        button:SetText("")
        button.DoClick = function()
            for l,m in next, APG.panels do
                if k != l then
                    APG.panels[l]:SetVisible(false)
                else
                    APG.panels[l]:SetVisible(true)
                end
            end
        end
        local size = sidebar:GetWide()
        button.Paint = function(_,w,h)
            local name = getNiceName(k)
            if button.Hovered then
                draw.RoundedBox(5,0,0,w,h,Color(46, 46, 46,255))
                draw.RoundedBox(0,2,2,w-4,h-4,Color( 36, 36,36, 255))
            end
            if APG.panels[k]:IsVisible()  then
                draw.RoundedBox(0,0,0,w,h,Color( 36, 36,36, 255))
            end

        end
        i = i + 1
    end
