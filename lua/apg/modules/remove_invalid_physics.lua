local mod = "remove_invalid_physics"

hook.Remove("OnEntityCreated", "APG_removeInvalidPhysics")
-- Really didn't want to make a whole module for this
APG.hookAdd( mod, "OnEntityCreated", "APG_removeInvalidPhysics", function( ent )
    if not IsValid( ent ) then return end

    timer.Simple(0, function()
        local owner = APG.getOwner( ent )
        if IsValid( owner ) and owner:IsPlayer() then
            local pObj = ent:GetPhysicsObject()
            if not IsValid(pObj) and not APG.cfg["invalidPhysicsWhitelist"].value[ent:GetModel()] then
                timer.Simple(0, function()
                    ent:Remove()
                    --APG.debug(tostring(ent) .. " spawned by " .. owner:Nick() .. " doesn't have physics!")
                end)
            end
        end
    end)
end)

--[[------------------------------------------
		Load hooks and timers
]]--------------------------------------------


APG.updateHooks(mod)
APG.updateTimers(mod)
