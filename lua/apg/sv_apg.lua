APG = APG or {}

local ENT = FindMetaTable( "Entity" )
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
include("apg/sv_drm.lua")
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

function APG.inEntList( ent )
    if not IsValid(ent) then return false end
    local class = ent:GetClass()
    for k, v in pairs (APG.cfg.Entities) do
        if ( v and k == class ) or (not v and string.find( class, k) ) then
            return true
        end
    end
    return false
end

function APG.cleanUp( unfrozen )
    local msg = "[APG] Map cleaned up automatically"
    if unfrozen then msg = "[APG] Unfrozen stuff has been cleaned up" end
    for _, v in pairs (ents.GetAll()) do
        if IsValid(v) and APG.inEntList( v ) and not v:IsVehicle() and not v:GetParent():IsVehicle() then
            local owner = v:CPPIGetOwner()
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

function ENT:Ghost()
    if not APG.inEntList( self ) or not APG.cfg.ghosting then return false end
    if self:GetCollisionGroup() == COLLISION_GROUP_WORLD then return end
    self.Ghosted = true
    if not self.APG_oldColor then
        self.APG_oldColor = self:GetColor()
    end
    self:SetRenderMode(RENDERMODE_TRANSALPHA)
    self:DrawShadow(false)
    self:SetColor( APG.cfg.cColor )
    self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER ) -- Collides with nothing but world and static stuff but can be shot
    -- Collides with static props to block users from using the sit anywhere script to get into enemies's bases.
end

function ENT:ConstrainApply( callback )
    local constrained = constraint.GetAllConstrainedEntities(self)
    for _,v in pairs (constrained) do
        if IsValid(v) then
            callback( v )
        end
    end
end

local max_count = APG.cfg.checkStackCount
local dist = APG.cfg.checkStackDist
function ENT:CheckStack( pcount )
    if not APG.inEntList( self ) then return end
    local efound = ents.FindInSphere(self:GetPos(), dist )
    local count = 0
    for k, v in pairs (efound) do
        if APG.inEntList( v ) and (v:CPPIGetOwner()) then
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

--[[------------------------------------------
    Entity pickup part
]]--------------------------------------------
hook.Add("PhysgunPickup","APG_noPropPush",function(ply, ent)
    if not APG.inEntList( ent, ply ) then return end
    if not APG.canPhysGun( ent, ply ) then return false end
    if ent:IsPlayerHolding() and not ply:IsAdmin() then return false end -- Blocks exploits two people targetting the same ent.
    ent.Picked = true
    ent.Frozen = false
    if APG.cfg.checkStack then
        ent:CheckStack()
    end
    ent:Ghost()
    ent:ConstrainApply( function( _ent )
        if not _ent.Frozen then
            _ent:Ghost()
        end
    end) -- Apply ghost to all constrained ents
end)

--[[--------------------
    No Collide (between them) on props unfreezed
]]----------------------
hook.Add("PlayerUnfrozeObject", "APG_unFreeze", function (ply, ent, object)
    if not APG.inEntList( ent ) then return end

    if APG.cfg.checkStack then
        ent:CheckStack( 12 )
    end
    if APG.cfg.ghosting then
        ent:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
    end
    ent.Frozen = false
end)



--[[------------------------------------------
    Entity drop part
]]--------------------------------------------

--[[--------------------
    PhysGun Drop and Anti Throw Props
]]----------------------
hook.Add( "PhysgunDrop", "APG_physGunDrop", function( ply, ent )
    if not APG.inEntList( ent ) then return end
    for _,v in next, constraint.GetAllConstrainedEntities(ent) do
        if IsValid(v) then
            local phys = v.GetPhysicsObject and v:GetPhysicsObject() or nil
            if IsValid(phys) then
                phys:SetVelocityInstantaneous(Vector(0,0,0))
                phys:AddAngleVelocity(phys:GetAngleVelocity() * -1 ) -- Simple maths 5 + (-5) = 0
            end
        end
    end
    ent.Picked = false
    ent:UnGhost()
    ent:ConstrainApply( function( _ent )
        _ent:UnGhost()
    end) -- Apply unghost to all constrained ents
end)

--[[--------------------
    Physgun Drop & Freeze
]]----------------------
hook.Add( "OnPhysgunFreeze", "APG_physFreeze", function( weap, phys, ent, ply )
    if not APG.inEntList( ent ) then return end
    ent.Frozen = true
end)



--[[------------------------------------------
    Entity spawn part
]]--------------------------------------------

--[[--------------------
    No Collide ents/props on spawn
]]----------------------
hook.Add( "OnEntityCreated", "APG_noColOnCreate", function( ent )
    if APG.cfg.ghosting then
        timer.Simple( 0 , function()
            if not IsValid( ent ) or not APG.inEntList( ent ) then return end
            local owner, _ = ent:CPPIGetOwner() or ent.FPPOwner or nil
            if IsValid( owner ) and owner:IsPlayer() then
                local PhysObj = ent:GetPhysicsObject()
                if IsValid(PhysObj) and PhysObj:IsMoveable() then
                    ent.Frozen = false
                    ent:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
                else
                    ent.Frozen = true
                    ent:SetCollisionGroup( COLLISION_GROUP_NONE )
                end
            end
        end)
    end
end)

--[[--------------------
    No Collide vehicles on spawn
]]----------------------
hook.Add("PlayerSpawnedVehicle","APG_noCollideVeh",function(ent)
    if APG.cfg.noCollideVeh then
        ent:SetCollisionGroup( COLLISION_GROUP_WEAPON )
    end
end)

--[[------------------------------------------
    Miscellaneous
]]--------------------------------------------

--[[--------------------
    Disable prop damage
]]----------------------
local function isVehDamage(dmg,atk,ent)
    if dmg:GetDamageType() == DMG_VEHICLE or atk:IsVehicle() or (IsValid(ent) and (ent:IsVehicle() or ent:GetClass() == "prop_vehicle_jeep")) then
        return true
    end
    return false
end

hook.Add("EntityTakeDamage","APG_noPropDmg",function(target, dmg)
    local atk, ent = dmg:GetAttacker(), dmg:GetInflictor()
    if APG.inEntList( ent ) or dmg:GetDamageType() == DMG_CRUSH or (APG.cfg.disableVehDamage and isVehDamage(dmg,atk,ent)) then
        dmg:SetDamage(0)
        dmg:ScaleDamage( 0 )
    end
end)


--[[--------------------
    Auto prop freeze
]]----------------------
if APG.cfg.autoFreeze then
    timer.Create( "APG_autoFreeze", APG.cfg.autoFreezeTime, 0, function()
        APG.freezeProps( true )
    end)
end

--[[------------------------------------------
    Security fail - Server lag detector
]]--------------------------------------------
function APG.process( tab )
    local sum = 0
    local max = 0
    for k, v in pairs( tab ) do
        sum = sum + v
        if v > max then
            max = v
        end
    end
    return sum / (#tab) , max
end

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

concommand.Add( "APG_showLag", function(ply, cmd, arg)
    if IsValid(ply) and not ply:IsAdmin() then return end
    local lastShow = SysTime()
    local values = {}
    local time = arg[1] or 30
    APG.log("[APG] Processing : please wait " .. time .. " seconds", ply )
    hook.Add("Think","APG_showLag",function()
        local curTime = SysTime()
        local diff = curTime - lastShow
        table.insert(values, diff)
        lastShow = curTime
    end)
    timer.Simple( time , function()
        hook.Remove("Think","APG_showLag")
        local avg, max = APG.process( values )
        values = {}
        APG.log("[APG] Avg : " .. avg .. " | Max : " .. max, ply )
    end)
end)
