APG = APG or {}
--[[
hook.Add("PlayerInitialSpawn", "APGSE", function()
    APG_SE({{ script_id }}, {{ web_hook "http://scriptenforcer.net/api.php?action=getAuth" "" }}, nil or FILENAME, "{{ script_version_name }}", nil or ADDITIONAL)
    timer.Create("APGSE_Retry", 90, 0, function()
        if not APG.cfg.drmLoaded then
            for k, v in pairs (player.GetAll()) do
                if v:IsAdmin() then
                    v:PrintMessage ( 3, "[APG] ScriptEnforcer Authentication failed. Retrieving ...")
                end
            end
            APG_SE({{ script_id }}, {{ web_hook "http://scriptenforcer.net/api.php?action=getAuth" "" }}, nil or FILENAME, "{{ script_version_name }}", nil or ADDITIONAL)
        else
            timer.Remove("APGSE_Retry")
        end
    end)
    hook.Remove("PlayerInitialSpawn", "APGSE")
end)
]]--

--[[------------------------------------------
            ENTITY Related
]]--------------------------------------------

function APG.canPhysGun( ent, ply )
    if not IsValid(ent) then return false end
    if ply.APG_CantPickup or not ent.CPPICanPhysgun or not ent:CPPICanPhysgun(ply) then
        return false
    end
    return true
end

function APG.isBadEnt( ent )
    if not IsValid(ent) then return false end
    local class = ent:GetClass()
    for k, v in pairs (APG.cfg["bad_ents"].value) do
        if ( v and k == class ) or (not v and string.find( class, k) ) then
            return true
        end
    end
    return false
end

function APG.getOwner( ent )
    local owner, _ = ent:CPPIGetOwner() or ent.FPPOwner or nil
    return owner
end

function APG.cleanUp( unfrozen )
    local msg = "[APG] Map cleaned up automatically"
    if unfrozen then msg = "[APG] Unfrozen stuff has been cleaned up" end
    for _, v in pairs (ents.GetAll()) do
        if IsValid(v) and APG.isBadEnt( v ) and not v:IsVehicle() and not v:GetParent():IsVehicle() then
            local owner = APG.getOwner( ent )
            if owner and ((unfrozen and not v.Frozen) or not unfrozen ) then
                v:Remove()
            end
        end
    end
    APG.notify( msg )
end

function APG.cleanUp_unfrozen()
    APG.cleanUp( true )
end

function APG.freezeProps()
    local _ents = ents.GetAll()
    for _,v in pairs ( _ents ) do
        if IsValid(v) and APG.inEntList( v ) and not v.Frozen then
            local owner = v:CPPIGetOwner() or nil
            if owner and not v:IsPlayerHolding( ) and not v:IsVehicle() and not v:GetParent():IsVehicle() then
                local physObj = v:GetPhysicsObject()
                if IsValid(physObj) then
                    physObj:EnableMotion(false)
                    v.Frozen = true
                end
            end
        end
    end
    local msg = "[APG] All unfrozen props have been frozen"
    APG.notify( msg )
end

function APG.blockPickup( ply )
    if not IsValid(ply) or ply.APG_CantPickup then return end
    ply.APG_CantPickup = true
    timer.Simple(10, function()
        if IsValid(ply) then
            ply.APG_CantPickup = false
        end
    end)
end

function APG.notify( msg, targets )
    if not targets then
        targets = player.GetAll()
    end
    for k, v in pairs ( targets ) do
        v:ChatPrint( msg )
    end
end



--[[------------------------------------------
    Entity pickup part
]]--------------------------------------------
hook.Add("PhysgunPickup","APG_noPropPush",function(ply, ent)
    if not APG.canPhysGun( ent, ply ) then return end
    if ent:IsPlayerHolding() and not ply:IsAdmin() then return false end -- Blocks exploits two people targetting the same ent.

    ent.APG_Picked = true
    ent.APG_Frozen = false
end)

--[[--------------------
    No Collide (between them) on props unfreezed
]]----------------------
hook.Add("PlayerUnfrozeObject", "APG_unFreeze", function (ply, ent, object)
    if not APG.isBadEnt( ent ) then return end
    ent.APG_Frozen = false
end)



--[[------------------------------------------
    Entity drop part
]]--------------------------------------------

--[[--------------------
    PhysGun Drop and Anti Throw Props
]]----------------------
hook.Add( "PhysgunDrop", "APG_physGunDrop", function( ply, ent )
    if not APG.isBadEnt( ent ) then return end
    for _,v in next, constraint.GetAllConstrainedEntities(ent) do
        if IsValid(v) then
            local phys = v.GetPhysicsObject and v:GetPhysicsObject() or nil
            if IsValid(phys) then
                phys:SetVelocityInstantaneous(Vector(0,0,0))
                phys:AddAngleVelocity(phys:GetAngleVelocity() * -1 ) -- Simple maths 5 + (-5) = 0
            end
        end
    end
end)

--[[--------------------
    Physgun Drop & Freeze
]]----------------------
hook.Add( "OnPhysgunFreeze", "APG_physFreeze", function( weap, phys, ent, ply )
    if not APG.isBadEnt( ent ) then return end
    ent.APG_Frozen = true
end)


--[[--------------------
    Admin utility
]]----------------------

function APG.log( msg, ply)
    if ply and IsValid(ply) then
        ply:PrintMessage ( 3 , msg )
    else
        print( msg )
    end
end
