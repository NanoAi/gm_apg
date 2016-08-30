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

function APG.cleanUp ( mode, show, adminsOnly )
	for _, v in next, ents.GetAll() do
		if not APG.isBadEnt(v) or not APG.getOwner( v ) or v:GetParent():IsVehicle() then continue end
		if mode == "unfrozen" and not v.APG_Frozen then
			continue
		else
			v:Remove()
		end
	end
	if show and adminsOnly then
		APG.notify("Cleaned Up !", { admin, superadmin })
	elseif show then
		APG.notify("Cleaned Up !", {})
	end
	APG.log("[APG] Cleaned up (mode:".. mode )
end

function APG.ghostThemAll( show, adminsOnly )
	if not APG.modules[ mod ] then
		return APG.log("[APG] Warning : Tried to ghost props but ghosting is disabled !")
	end
	for _, v in next, ents.GetAll() do
		if not APG.isBadEnt(v) or not APG.getOwner( v ) or v:GetParent():IsVehicle() or v.APG_Frozen then continue end
			APG.entGhost( v )
		end
	end
	if show and adminsOnly then
		APG.notify("Unfrozen props ghosted !", { admin, superadmin })
	elseif show then
		APG.notify("Unfrozen props ghosted !", {})
	end
	APG.log("[APG] Unfrozen props ghosted !")
end

function APG.freezeProps( show, adminsOnly)
	for _, v in next, ents.GetAll() do
		if not APG.isBadEnt(v) or not APG.getOwner( v ) then continue end
		    local physObj = v:GetPhysicsObject()
            if IsValid(physObj) then
            	physObj:EnableMotion(false)
            	v.APG_Frozen = true
            end
        end
    end
    if show and adminsOnly then
		APG.notify("Props frozen !", { admin, superadmin })
	elseif show then
		APG.notify("Props frozen !", {})
	end
	APG.log("[APG] Props frozen") 
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
hook.Add("PhysgunPickup","APG_PhysgunPickup",function(ply, ent)
    if not APG.canPhysGun( ent, ply ) then return false end
    if ent:IsPlayerHolding() and not ply:IsAdmin() then return false end -- Blocks exploits two people targetting the same ent.

    ent.APG_Picked = true
    ent.APG_Frozen = false
end)

--[[--------------------
    No Collide (between them) on props unfreezed
]]----------------------
hook.Add("PlayerUnfrozeObject", "APG_PlayerUnfrozeObject", function (ply, ent, object)
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
hook.Add( "OnPhysgunFreeze", "APG_OnPhysgunFreeze", function( weap, phys, ent, ply )
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
