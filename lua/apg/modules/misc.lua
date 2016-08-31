local mod = "misc"

--[[--------------------
    No Collide vehicles on spawn
]]----------------------
APG.hookAdd(mod,"PlayerSpawnedVehicle","APG_noCollideVeh",function(ent)
    if APG.cfg["vehNoCollide"].value then
        ent:SetCollisionGroup( COLLISION_GROUP_WEAPON )
    end
end)

--[[--------------------
    Disable prop damage
]]----------------------
local function isVehDamage(dmg,atk,ent)
    if dmg:GetDamageType() == DMG_VEHICLE or atk:IsVehicle() or (IsValid(ent) and (ent:IsVehicle() or ent:GetClass() == "prop_vehicle_jeep")) then
        return true
    end
    return false
end

APG.hookAdd(mod, "EntityTakeDamage","APG_noPropDmg",function(target, dmg)
    local atk, ent = dmg:GetAttacker(), dmg:GetInflictor()
    if APG.isBadEnt( ent ) or dmg:GetDamageType() == DMG_CRUSH or (APG.cfg["vehDamage"].value and isVehDamage(dmg,atk,ent)) then
        dmg:SetDamage(0)
        dmg:ScaleDamage( 0 )
    end
end)

--[[--------------------
    Auto prop freeze
]]----------------------
if APG.cfg["autoFreeze"].value then
    APG.timerCreate( "APG_autoFreeze", APG.cfg["autoFreezeTime"].value, 0, function()
        APG.freezeProps( true )
    end)
end

