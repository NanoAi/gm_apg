local mod = "ghosting"

--[[------------------------------------------

    A.P.G. - a lightweight Anti Prop Griefing solution (v{{ script_version_name }})
    Made by While True (http://steamcommunity.com/id/while_true/) and LuaTenshi (http://steamcommunity.com/id/BoopYoureDead/)

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

]]--------------------------------------------

--[[------------------------------------------
        Override base functions
]]--------------------------------------------

local ENT = FindMetaTable( "Entity" )
APG.oSetColGroup = APG.oSetColGroup or ENT.SetCollisionGroup
function ENT:SetCollisionGroup( group )
    if APG.isBadEnt( self ) and APG.getOwner( self ) then
        if group == COLLISION_GROUP_NONE then
            if not self.APG_Frozen then
                group = COLLISION_GROUP_INTERACTIVE
            end
--[[        elseif group == COLLISION_GROUP_INTERACTIVE and APG.isTrap( self ) then
            group = COLLISION_GROUP_DEBRIS_TRIGGER --]]
        end
    end
    return APG.oSetColGroup( self, group )
end

local PhysObj = FindMetaTable("PhysObj")
APG.oEnableMotion = APG.oEnableMotion or PhysObj.EnableMotion
function PhysObj:EnableMotion( bool )
    local sent = self:GetEntity()
    if APG.isBadEnt( sent ) and APG.getOwner( sent ) then
        sent.APG_Frozen = not bool
        if not sent.APG_Frozen then
            sent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
        end
    end
    return APG.oEnableMotion( self, bool)
end

function APG.isTrap( ent )
    local check = false
    local center = ent:LocalToWorld(ent:OBBCenter())

    for _,v in next, ents.FindInSphere(center, ent:BoundingRadius()) do
        if v:IsPlayer() and v:Alive() then
            local pos = v:GetPos()
            local trace = { start = pos, endpos = pos, filter = v }
            local tr = util.TraceEntity( trace, v )

            if tr.Entity == ent then
                check = v
            end

            if check then break end
        end
    end

    return check or false
end

function APG.entGhost( ent )
    if not APG.modules[ mod ] or not APG.isBadEnt( ent ) then return end

    if not ent.APG_Ghosted then
        ent.APG_oColGroup = ent:GetCollisionGroup()
        ent.APG_Ghosted = true

        if not ent.APG_oldColor then
            ent.APG_oldColor = ent:GetColor()
        end

        ent:SetRenderMode(RENDERMODE_TRANSALPHA)
        ent:DrawShadow(false)
        ent:SetColor( APG.cfg["ghost_color"].value )
        ent:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
    end
end

function APG.entUnGhost( ent, ply )
    if not APG.modules[ mod ] or not APG.isBadEnt( ent ) then return end
    if ent.APG_Ghosted then
        ent.APG_isTrap = APG.isTrap(ent)
        if not ent.APG_isTrap then
            ent.APG_Ghosted  = false
            ent:DrawShadow(true)
            ent:SetColor( ent.APG_oldColor or Color(255,255,255,255))
            ent.APG_oldColor = false

            local newColGroup = COLLISION_GROUP_INTERACTIVE
            if ent.APG_oColGroup == COLLISION_GROUP_WORLD then
                newColGroup = ent.APG_oColGroup
            elseif ent.APG_Frozen then
                newColGroup = COLLISION_GROUP_NONE
            end
            ent:SetCollisionGroup( newColGroup )
        else
            APG.notify( "There is something in this prop !", { ply } )
            ent:SetCollisionGroup( COLLISION_GROUP_WORLD  )
        end
    end
end

function APG.ConstrainApply( ent, callback )
    local constrained = constraint.GetAllConstrainedEntities(ent)
    for _,v in next, constrained do
        if IsValid(v) and v != ent then
            callback( v )
        end
    end
end

--[[------------------------------------------
        Delayed unghost; spam protection
]]--------------------------------------------

local toUnGhost = {}
local processing = false
local delay, pLimit = 0, 1, 20

function APG_delayUnGhost()
    if processing then return end
    processing = true
    local total = #toUnGhost
    local count = math.Clamp(total,0,pLimit)
    for i = 1, count do
        local ent = toUnGhost[1]
        timer.Create( "delayUnGhost_" .. i , ( i - 1 ) * delay , 1, function()
            if not IsValid( ent ) then return end
            APG.entUnGhost( ent )
        end)
        table.remove(toUnGhost, 1)
    end
    if not timer.Exists( "dUnGhost_reload") then
        timer.Create("dUnGhost_reload", ( count * delay ) + 0.1, 1, function() if #toUnGhost > 0 then APG_delayUnGhost() end end)
    end
    timer.Create("dUnGhost_process", ( count * delay ), 1, function() processing = false end)
end


APG.hookAdd( mod, "PhysgunPickup","APG_makeGhost",function(ply, ent)
    if not APG.canPhysGun( ent, ply ) then return end
    if not APG.modules[ mod ] or not APG.isBadEnt( ent ) then return end
    if ent:IsPlayerHolding() and not ply:IsAdmin() then return false end -- Blocks two people from holding the same prop

    APG.entGhost(ent)

    APG.ConstrainApply( ent, function( _ent )
        if not _ent.APG_Frozen then
            APG.entGhost( _ent )
        end
    end) -- Apply ghost to all constrained ents

end)

APG.hookAdd( mod, "PlayerUnfrozeObject", "APG_unFreezeInteract", function (ply, ent, object)
    if not APG.canPhysGun( ent, ply ) then return end
    if not APG.modules[ mod ] or not APG.isBadEnt( ent ) then return end
    if ent:GetCollisionGroup( ) != COLLISION_GROUP_WORLD then
        ent:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
    end
end)

APG.hookAdd( mod, "PhysgunDrop", "APG_pGunDropUnghost", function( ply, ent )
    if not APG.modules[ mod ] or not APG.isBadEnt( ent ) then return end
    APG.entUnGhost( ent )
    APG.ConstrainApply( ent, function( _ent )
        table.insert( toUnGhost, _ent )
        APG_delayUnGhost()
    end) -- Apply unghost to all constrained ents
end)

APG.hookAdd( mod, "OnEntityCreated", "APG_noColOnCreate", function( ent )
    if not APG.modules[ mod ] or not APG.isBadEnt( ent ) then return end
    timer.Simple( 0 , function()
        if not IsValid( ent ) then return end
        local owner = APG.getOwner( ent )
        if IsValid( owner ) and owner:IsPlayer() then
            local pObj = ent:GetPhysicsObject()
            if IsValid(pObj) and pObj:IsMoveable() then
                ent.APG_Frozen = false
                ent:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
            else
                ent.APG_Frozen = true
                ent:SetCollisionGroup( COLLISION_GROUP_NONE )
            end
        end
    end)
end)