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

--[[--------------------
    Stacker Exploit Quick Fix
]]----------------------
local toWeld = {}
local processing = false

local i, delay, pLimit = 0, 0, 20

local function startWeld()
    if processing then return end
    processing = true
    i, delay = 1, 0.3
    hook.Add("Tick", "APG_delayWeld", APG_delayWeld)
end

function APG_delayWeld()
    if #toWeld > 1 then
        if i < pLimit then
            local ents = toWeld[1]
            timer.Create( "delayedWeld_" .. i , ( i - 1 ) * delay , 1, function()
                if not IsValid(ents[1]) or not IsValid(ents[2]) then return end
                constraint.Weld( ents[1], ents[2], 0, 0, 0 )
            end)

            table.remove( toWeld, 1)
            i = i + 1

        elseif not timer.Exists( "dWeld_reload") then
            timer.Create("dWeld_reload", ( i * delay ) + 0.1, 1, startWeld)
        end

    elseif not timer.Exists( "dWeld_remove") then
        timer.Create("dWeld_remove", 0, 1, function()
            if #toWeld < 1 then hook.Remove("Tick", "APG_delayWeld") end
        end)
    end
end

hook.Add( "Think", "APG_InitStackFix", function()
    local TOOL = weapons.GetStored("gmod_tool")["Tool"][ "stacker" ]

    function TOOL:ApplyWeld( lastEnt, newEnt )
        if ( not self:ShouldForceWeld() and not self:ShouldApplyWeld() ) then return end
        table.insert( toWeld, {lastEnt, newEnt} )
        startWeld()
    end
    hook.Remove("Think", "APG_InitStackFix")
end)
