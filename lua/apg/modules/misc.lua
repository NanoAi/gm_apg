--[[------------------------------------------

    A.P.G. - a lightweight Anti Prop Griefing solution (v{{ script_version_name }})
    Made by :
    - While True (http://steamcommunity.com/id/76561197972967270)
    - LuaTenshi (http://steamcommunity.com/id/76561198096713277)

    Licensed to : http://steamcommunity.com/id/{{ user_id }}

    ============================
        MISCELLANEOUS MODULE
    ============================

    Developper informations :
    ---------------------------------
    Used variables :
        vehDamage = { value = true, desc = "True to enable vehicles damages, false to disable." }
        vehNoCollide = { value = false, desc = "True to disable collisions between vehicles and players"}
        autoFreeze = { value = false, desc = "Freeze every unfrozen prop each X seconds" }
        autoFreezeTime = { value = 120, desc = "Auto freeze timer (seconds)"}

]]--------------------------------------------
local mod = "misc"

--[[--------------------
    Vehicle damage
]]----------------------
local function isVehDamage(dmg,atk,ent)
    if dmg:GetDamageType() == DMG_VEHICLE or atk:IsVehicle() or (IsValid(ent) and (ent:IsVehicle() or ent:GetClass() == "prop_vehicle_jeep")) then
        return true
    end
    return false
end

--[[--------------------
    No Collide vehicles on spawn
]]----------------------
APG.hookRegister(mod,"PlayerSpawnedVehicle","APG_noCollideVeh",function( _ , ent)
    timer.Simple(0.1, function()
        if APG.cfg["vehNoCollide"].value then
            ent:SetCollisionGroup( COLLISION_GROUP_WEAPON )
        end
    end)
end)

--[[--------------------
    Disable prop damage
]]----------------------
APG.hookRegister(mod, "EntityTakeDamage","APG_noPropDmg",function(target, dmg)
    local atk, ent = dmg:GetAttacker(), dmg:GetInflictor()
    if APG.isBadEnt( ent ) or dmg:GetDamageType() == DMG_CRUSH or (APG.cfg["vehDamage"].value and isVehDamage(dmg,atk,ent)) then
        dmg:SetDamage(0)
        dmg:ScaleDamage(0)
    end
end)

--[[--------------------
    Auto prop freeze
]]----------------------
APG.timerRegister( mod, "APG_autoFreeze", APG.cfg["autoFreezeTime"].value, 0, function()
    if APG.cfg["autoFreeze"].value then
        APG.freezeProps( true )
    end
end)

--[[------------------------------------------
        Load hooks and timers
]]--------------------------------------------
for k, v in next, APG[mod]["hooks"] do
    hook.Add( v.event, v.identifier, v.func )
end

for k, v in next, APG[mod]["timers"] do
    timer.Create( v.identifier, v.delay, v.repetitions, v.func )
end