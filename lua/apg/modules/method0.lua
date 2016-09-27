--[[------------------------------------------

    A.P.G. - a lightweight Anti Prop Griefing solution (v{{ script_version_name }})
    Made by :
    - While True (http://steamcommunity.com/id/76561197972967270)
    - LuaTenshi (http://steamcommunity.com/id/76561198096713277)

    Licensed to : http://steamcommunity.com/id/{{ user_id }}

    ============================
        METHOD0 MODULE
    ============================

    Developper informations :
    ---------------------------------
    TO COME - We are working on it

]]--------------------------------------------
local mod = "method0"

return -- Disable for now. (Remove this line when testing.)

APG.Memory = APG.Memory or {}
APG.Memory.BadEnt = APG.Memory.BadEnt or {}

function APG.setBadEnt(ent)
    local mem = APG.Memory.BadEnt[ent:EntIndex()]

    mem = {
        ent = ent,
        time = CurTime()+5,
    }

    return mem
end

local vector_origin = Vector()

function APG.PhysicsCollide(ent, data)
    local mem = APG.setBadEnt(ent)
    local speed = data.OurOldVelocity:Length()

    if speed < 8.4 then return end
    mem.time = CurTime()+5

    if IsValid(data.HitEntity) then
        timer.Simple(0.001, function()
            if (speed > 95 or (IsValid(data.HitObject) and data.HitObject:GetVelocity():Length() > 75)) then
                APG.setBadEnt(data.HitEntity)
            end
        end)
    end
end

APG.timerRegister(mod, "APG_Method0", 5, 0, function()
    for k,v in next, APG.Memory.BadEnt do
        if v.time < CurTime() then
            APG.Memory.BadEnt[k] = nil
        end
    end
end)

APG.hookRegister(mod, "OnEntityCreated", "APG_Method0_Register", function(ent)
    timer.Simple(0.005, function()
        ent:AddCallback( "PhysicsCollide", APG.PhysicsCollide )
    end)
end)

APG.hookRegister(mod, "APGisBadEnt", "APG_Method0", function(ent)
    local bad = table.HasValue(APG.Memory.BadEnt, ent)
    if bad then return true end
end)



for k, v in next, APG[mod]["hooks"] do
    hook.Add( v.event, v.identifier, v.func )
end

for k, v in next, APG[mod]["timers"] do
    timer.Create( v.identifier, v.delay, v.repetitions, v.func )
end