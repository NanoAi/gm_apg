local mod = "stack_detection"
--[[------------------------------------------

    A.P.G. - a lightweight Anti Prop Griefing solution (v{{ script_version_name }})
    Made by While True (http://steamcommunity.com/id/while_true/) and LuaTenshi (http://steamcommunity.com/id/BoopYoureDead/)

    ============================
       STACK DETECTION MODULE
    ============================

    Developper informations :
    ---------------------------------
    Used variables :
        stackMax = { value = 20, desc = "Max amount of entities stacked on a small area"}
        stackArea = { value = 15, desc = "Sphere radius for stack detection (gmod units)"}

]]--------------------------------------------

function APG.checkStack( ent, pcount )
    if not APG.isBadEnt( ent ) then return end

    local efound = ents.FindInSphere(self:GetPos(), APG.cfg.["stackArea"].value )
    local count = 0
    local max_count = APG.cfg.["stackMax"].value
    for k, v in pairs (efound) do
        if APG.isBadEnt( v ) and APG.getOwner( v ) then
            count = count + 1
        end
    end
    if count >= (pcount or max_count) then
        local owner, _ = self:CPPIGetOwner()
        self:Remove()
        if not owner.APG_CantPickup then
            APG.blockPickup( owner )
            APG.notify( "[APG] Do not try to crash the server !", { owner } )
            local msg = "[APG] Warning : " .. owner:Nick() .. " tried to unfreeze a stack of props !"
            local admins = {}
            for _, v in pairs( player.GetAll()) do
                if v:IsAdmin() then
                    table.insert( admins, v)
                end
            end
            APG.notify( msg, admins )
        end
    end
end

APG.hookAdd(mod, "PhysgunPickup","APG_stackCheck",function(ply, ent)
    if not APG.canPhysGun( ent, ply ) then return end
    if not APG.modules[ mod ] or not APG.isBadEnt( ent ) then return end
    APG.checkStack( ent )
end)
