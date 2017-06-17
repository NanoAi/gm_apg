--[[------------------------------------------

	A.P.G. - a lightweight Anti Prop Griefing solution (v{{ script_version_name }})
	Made by :
	- While True (http://steamcommunity.com/id/76561197972967270)
	- LuaTenshi (http://steamcommunity.com/id/76561198096713277)

	Licensed to : http://steamcommunity.com/id/{{ user_id }}

	============================
	   STACK DETECTION MODULE
	============================

	Developper informations :
	---------------------------------
	Used variables :
		stackMax = { value = 20, desc = "Max amount of entities stacked on a small area"}
		stackArea = { value = 15, desc = "Sphere radius for stack detection (gmod units)"}

]]--------------------------------------------
local mod = "tool_hacks"

APG.hookRegister(mod, "CanTool", "APG_canTool", function(ply, tr, tool)
	if tool == "fading_door" then
		if IsValid(tr.Entity) and not tr.Entity:IsPlayer() then
			local ent = tr.Entity
			timer.Simple(0, function()
				if not IsValid(ent) then return end
				if not ent.isFadingDoor then return end

				local state = ent.fadeActive

				if state then
					ent:fadeDeactivate()
				end

				ent.oldFadeActivate = ent.oldFadeActivate or ent.fadeActivate
				function ent:fadeActivate()
					if hook.Run("APG.FadingDoorToggle", self, true) then return end
					ent:oldFadeActivate()
				end

				ent.oldFadeDeactivate = ent.oldFadeDeactivate or ent.fadeDeactivate
				function ent:fadeDeactivate()
					if hook.Run("APG.FadingDoorToggle", self, false) then return end
					ent:oldFadeDeactivate()
				end

				if state then
					ent:fadeActivate()
				end
			end)
		end
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