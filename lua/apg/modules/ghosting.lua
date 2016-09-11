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
        if (v:IsPlayer() and v:Alive()) then
            local pos = v:GetPos()
            local trace = { start = pos, endpos = pos, filter = v }
            local tr = util.TraceEntity( trace, v )

            if tr.Entity == ent then
                check = v
            end

            if check then break end
        elseif v:IsVehicle() then
            -- to do
        end
    end

    return check or false
end

function APG.entGhost( ent, enforce, noCollide )
    if not APG.modules[ mod ] or not APG.isBadEnt( ent ) then return end

    if not ent.APG_Ghosted then
        ent.FPPAntiSpamIsGhosted = nil -- Override FPP Ghosting.

        ent.APG_oColGroup = ent:GetCollisionGroup()

        if not enforce then
            -- If and old collision group was set get it.
            if ent.OldCollisionGroup then ent.APG_oColGroup = ent.OldCollisionGroup end -- For FPP
            if ent.DPP_oldCollision then ent.APG_oColGroup = ent.DPP_oldCollision end -- For DPP

            ent.OldCollisionGroup = nil
            ent.DPP_oldCollision = nil
        end

        ent.APG_Ghosted = true

        if not ent.APG_oldColor then
            ent.APG_oldColor = ent:GetColor()
            if not enforce then
                if ent.OldColor then ent.APG_oldColor = ent.OldColor end -- For FPP
                if ent.__DPPColor then ent.APG_oldColor = ent.__DPPColor end -- For DPP

                ent.OldColor = nil
                ent.__DPPColor = nil
            end
        end

        ent:SetRenderMode(RENDERMODE_TRANSALPHA)
        ent:DrawShadow(false)
        ent:SetColor( APG.cfg["ghost_color"].value )
        if noCollide then
            ent:SetCollisionGroup( COLLISION_GROUP_WORLD )
        else
            ent:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
        end
    end
end

function APG.entUnGhost( ent, ply )
    if not APG.modules[ mod ] or not APG.isBadEnt( ent ) then return end
    if ent.APG_HeldBy and #ent.APG_HeldBy > 1 then return end

    if ent.APG_Ghosted and not ent.APG_Picked then
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
            APG.log( "There is something in this prop !", ply )
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

APG.hookAdd( mod, "PhysgunPickup","APG_makeGhost",function(ply, ent)
    if not APG.canPhysGun( ent, ply ) then return end
    if not APG.modules[ mod ] or not APG.isBadEnt( ent ) then return end
    ent.APG_Picked = true

    APG.entGhost(ent)

    APG.ConstrainApply( ent, function( _ent )
        if not _ent.APG_Frozen then
            _ent.APG_Picked = true
            APG.entGhost( _ent )
        end
    end) -- Apply ghost to all constrained ents
end)

APG.hookAdd( mod, "PlayerUnfrozeObject", "APG_unFreezeInteract", function (ply, ent, object)
    if not APG.canPhysGun( ent, ply ) then return end
    if not APG.modules[ mod ] or not APG.isBadEnt( ent ) then return end
    if APG.cfg["alwaysFrozen"].value then return false end -- Do not unfreeze if Always Frozen is enabled !
    if ent:GetCollisionGroup( ) != COLLISION_GROUP_WORLD then
        ent:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
    end
end)

APG.dJobRegister( "unghost", 0.1, 20, function( ent )
    if not IsValid( ent ) then return end
    APG.entUnGhost( ent )
end)

APG.hookAdd( mod, "PhysgunDrop", "APG_pGunDropUnghost", function( ply, ent )
    if not APG.modules[ mod ] or not APG.isBadEnt( ent ) then return end
    ent.APG_Picked = false

    if APG.cfg["alwaysFrozen"].value then
        APG.freezeIt( ent )
    end
    APG.entUnGhost( ent )
    APG.ConstrainApply( ent, function( _ent )
        _ent.APG_Picked = false
        APG.startDJob( "unghost", _ent )
    end) -- Apply unghost to all constrained ents
end)

APG.hookAdd( mod, "OnEntityCreated", "APG_noColOnCreate", function( ent )
    if not APG.modules[ mod ] or not APG.isBadEnt( ent ) then return end
    timer.Simple(0, function()
        if not IsValid( ent ) then return end
        local owner = APG.getOwner( ent )
        if IsValid( owner ) and owner:IsPlayer() then
            local pObj = ent:GetPhysicsObject()
            if IsValid(pObj) and APG.cfg["alwaysFrozen"].value then
                pObj:EnableMotion( false)
            elseif IsValid(pObj) and pObj:IsMoveable() then
                ent.APG_Frozen = false
                ent:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
            else
                ent.APG_Frozen = true
                ent:SetCollisionGroup( COLLISION_GROUP_NONE )
            end
        end
    end)
    timer.Simple(0.03, function()
        if ent.FPPAntiSpamIsGhosted then
            DropEntityIfHeld(ent)
            ent:ForcePlayerDrop()
        end
        APG.entGhost( ent )
        APG.startDJob( "unghost", ent )
    end)
end)
