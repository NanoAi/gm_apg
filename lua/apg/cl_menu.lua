local APG = {}

APG.modules = {
    ["ghosting"] = true,
    ["stack_detection"] = true,
    ["lag_detection"] = true,
    ["misc"] = true,
    ["method0"] = false
}
APG.cfg = {
    ghost_color = { value = Color(34, 34, 34, 220), desc = "Color set on ghosted props" },
    bad_ents = {
        value = {
            ["prop_physics"] = true,
            ["wire_"] = false,
            ["gmod_"] = false },
        desc = "Entities to ghost/control/secure"
    },
    alwaysFrozen = { value = false, desc = "Props stay frozen on physgun drop"}
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

surface.CreateFont( "APG_element_font", {
    font = "Arial",
    size = 17,
    weight = 1300,
} )

surface.CreateFont( "APG_element2_font", {
    font = "Arial",
    size = 17,
    weight = 2900,
} )

local function addBadEntity( class )
    local found = false
    for k, v in pairs ( ents.GetAll() ) do
        if class == v:GetClass() then
            found = true
            break
        end
    end
    if not found then
        for k in pairs (scripted_ents.GetList()) do
            if class == k then
                found = true
                break
            end
        end
    end
    APG.cfg["bad_ents"].value[ class ] = found
end
local function getNiceName( str )
    local nName = string.gsub(str,"^%l",string.upper)
    nName = string.gsub(nName,"_", " " )
    return nName
end

function draw.APGCheckB( x, y, on )
    draw.RoundedBox(10,x,y,45,18,Color( 58, 58, 58, 255))
    if on then
        draw.RoundedBox(10,x+1,y+1,45-2,18-2,Color( 11,70,30, 255))
        draw.DrawText( "ON", "APG_title_font",x+8, y+2, Color( 189, 189, 189 ), 3 )
        draw.RoundedBox(10,x+27,y,18,18,Color( 88, 88, 88, 255))
    else
        --draw.RoundedBox(10,x,y,45,18,Color( 110, 28, 38, 255))
        draw.RoundedBox(10,x+1,y+1,43,16,Color( 34, 34, 34, 255))
        draw.DrawText( "OFF", "APG_title_font",x+21, y+2, Color( 189, 189, 189), 3 )
        draw.RoundedBox(10,x,y,18,18,Color( 88, 88, 88, 255))
    end
    --draw.RoundedBox(0,x+20,y,1,18,Color( 88, 88, 88, 255))
end

function APG_Button( panel, x, y, w, h, text, var )
    local button = vgui.Create("DButton",panel)
        button:SetPos(x,y)
        button:SetSize(w,h)
        button:SetText("")
        button.Paint = function(slf, w , h )
            local enabled = APG.cfg[ var ].value
                draw.RoundedBox(0,0,h * 0.95,w-5,1, Color(250, 250, 250,1))
                draw.DrawText( text, "APG_element2_font",0, 0, Color( 189, 189, 189), 3 )
                draw.APGCheckB( w-45, 0, enabled )
        end
        button.DoClick = function()
            APG.cfg[ var ].value = not APG.cfg[ var ].value
        end
end

local function APGBuildGhostPanel()
    local panel = APG.panels["ghosting"]
        panel.Paint = function( i, w, h)
            draw.RoundedBox(0,0,37,170,135,Color( 38, 38, 38, 255))
            draw.DrawText( "Ghosting color :", "APG_element_font",5, 37, Color( 189, 189, 189), 3 )
            draw.RoundedBox(0,175,37,250,250,Color( 38, 38, 38, 255))
            draw.DrawText( "Bad entities :", "APG_element_font",180, 37, Color( 189, 189, 189), 3 )
        end
    APG_Button( panel, 0, 180, 170, 20, "Always frozen", "alwaysFrozen" )

    local Mixer = vgui.Create( "CtrlColor", panel )
    Mixer:SetPos(5,55)
    Mixer:SetSize(160,110)
    Mixer.Mixer.ValueChanged = function(self,color)
        APG.cfg["ghost_color"].value = Color( color.r, color.g, color.b, color.a)
    end

    local dList = vgui.Create("DListView", panel)
        dList:Clear()
        dList:SetPos( 180, 55 )
        dList:SetSize(panel:GetWide() - 185, panel:GetTall() - 60)
        dList:SetMultiSelect(false)
        dList:SetHideHeaders(false)
        dList:AddColumn("Class")
        dList:AddColumn("Exact")

        local function updtTab()
            dList:Clear()
            for class,complete in pairs(APG.cfg["bad_ents"].value) do
                dList:AddLine(class, complete)
            end
        end
        updtTab()
        dList.Paint = function(i,w,h)
            draw.RoundedBox(0,0,0,w,h,Color(150, 150, 150, 255))
        end
        dList.VBar.Paint = function(i,w,h)
            surface.SetDrawColor(88, 110, 110, 240)
            surface.DrawRect(0,0,w,h)
        end
        dList.VBar.btnGrip.Paint = function(i,w,h)
            surface.SetDrawColor(255, 83, 13,50)
            surface.DrawRect(0,0,w,h)
            draw.RoundedBox( 0, 1,1,w-2,h-2, Color( 72, 89, 89, 255 ) )
        end
        dList.VBar.btnUp.Paint = function(i,w,h)
            draw.RoundedBox( 0, 0,0,w,h, Color( 72, 89, 89, 240 ) )
        end
        dList.VBar.btnDown.Paint = function(i,w,h)
            draw.RoundedBox( 0, 0,0,w,h, Color( 72, 89, 89, 240 ) )
        end
    local TextEntry = vgui.Create( "DTextEntry", panel )
        TextEntry:SetPos( 180, 240 )
        TextEntry:SetSize( 150,20 )
        TextEntry:SetText( "Entity class" )
        TextEntry.OnEnter = function( self )
            chat.AddText( self:GetValue() )
        end
    local Add = vgui.Create( "DButton" , panel)
        Add:SetPos( 320, 240 )
        Add:SetSize( 75,20 )
        Add:SetText( "Add" )
        Add.DoClick = function()
            if TextEntry:GetValue() == "Entity class" then return end
            addBadEntity( TextEntry:GetValue() )
            updtTab()
        end
        Add:SetTextColor(Color(255,255,255))
        Add.Paint = function(i,w,h)
            draw.RoundedBox(0,0,0,w,h,Color(44, 55, 55, 240))
            draw.RoundedBox(0,1,1,w-2,h-2,Color( 58, 58, 58, 255))
        end
    local Remove = vgui.Create( "DButton" , panel)
        Remove:SetPos( 180, 260 )
        Remove:SetSize( 215,20 )
        Remove:SetText( "Remove selected" )
        Remove.DoClick = function()
            for k,v in pairs(dList:GetSelected()) do
                local key = v:GetValue(1)
                APG.cfg["bad_ents"].value[key] = nil
                updtTab()
            end
        end
        Remove:SetTextColor(Color(255,255,255))
        Remove.Paint = function(i,w,h)
            draw.RoundedBox(0,0,0,w,h,Color( 58, 58, 58, 255))
            draw.RoundedBox(0,0,0,w,1,Color(30, 30, 30, 125))
        end
end


local main_color = Color(32, 255, 0,255)
local function openMenu( )
    local APG_Main = vgui.Create( "DFrame" )
        APG_Main:SetSize( 550 , 320)
        APG_Main:SetPos( ScrW()/2- APG_Main:GetWide()/2, ScrH()/2 - APG_Main:GetTall()/2)
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
            draw.RoundedBox(0,0,0,w,h,Color(255, 255, 255,3))
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
            draw.RoundedBox(0,0,0,w,h,Color(255, 255, 255,3))
            draw.DrawText( "Save settings", "APG_title2_font",w/2, 1, Color( 189, 189, 189), 1 )
        end
    -- Side bar
    local sidebar = vgui.Create("DPanel",APG_Main)
        sidebar:SetSize( APG_Main:GetWide() / 4 , APG_Main:GetTall() - 35)
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

                draw.RoundedBox(0,0,h*0.85,w-5,1, Color(0, 96, 0,255))
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
                draw.RoundedBox(0,w*0.15,h*0.72,w*0.7,1, Color(0, 96, 0,255))
            end

            draw.DrawText( name, "APG_sideBar_font",(size - name:len())/2, h*0.35, Color( 189, 189, 189), 1)
        end
        i = i + 1
    end
    APGBuildGhostPanel()
end
