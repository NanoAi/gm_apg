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
hook.Add( "Think", "APG_InitStackFix", function()
    local working = false
    local entQueue = { }

    local function delayedWeld( )
        if working then return end
        working = true
        local i, delay = 1, 0.3
        hook.Add( "Think", "delayedWeld", function()
            if #entQueue then
                local ents = entQueue[1]
                timer.Create( "delayedWeld_" .. i , ( i - 1 ) * delay , 1, function()
                    if not IsValid(ents[1]) or not IsValid(ents[2]) then return end
                    constraint.Weld( ents[1], ents[2], 0, 0, 0 )
                    if #entQueue < 1 then working = false end
                end)
                table.remove(entQueue, 1)
                i = i + 1
            else
                if timer.Exists("removeDelayedWeld") then return end
                timer.Create("removeDelayedWeld", 1, 1, function()
                    if #entQueue < 1 then
                        hook.Remove("Think", "delayedWeld")
                    end
                end)
            end
        end)

    end

    local TOOL = weapons.GetStored("gmod_tool")["Tool"][ "stacker" ]
    function TOOL:ApplyWeld( lastEnt, newEnt )
        if ( not self:ShouldForceWeld() and not self:ShouldApplyWeld() ) then return end
        table.insert(entQueue, {lastEnt, newEnt})
        delayedWeld( )
    end
    hook.Remove("Think", "APG_InitStackFix")
end)