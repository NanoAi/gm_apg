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
local mod = "misc2"

local function hookAdd(call, key, func)
	APG.hookRegister(mod, call, key, func)
end

local function timerMake(id, delay, times, func)
	APG.timerRegister(mod, id, delay, times, func)
end

hookAdd("CanTool", "APG_canTool", function(ply, tr, tool)
	if APG.cfg["thFadingDoors"].value and tool == "fading_door" then
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

--[[ FRZR9K ]]--

local zero = Vector(0,0,0)
local pstop = FrameTime()*3

local function getphys(ent)
	local phys = IsValid(ent) and ent.GetPhysicsObject and ent:GetPhysicsObject() or false
	return IsValid(phys) and phys or false
end

timerMake("frzr9k", pstop, 0, function()
	if APG.cfg["frzr9k"].value then
		for _,v in next, ents.GetAll() do
			local phys = getphys(v)
			if IsValid(phys) and phys:IsMotionEnabled() and not v:IsPlayerHolding() then
				local vel = v:GetVelocity()
				if vel:Distance(zero) <= 23 then
					phys:Sleep()
				end
			end
		end
	end
end)

-- Collision Monitoring --
local function collcall(ent, data)
	local hit = data.HitObject
	local mep = data.PhysObject
	if IsValid(hit) and IsValid(mep) then
		ent._collisions = (ent._collisions or 0) + 1
		if ent._collisions > 23 then
			ent._collisions = 0
			mep:SetVelocityInstantaneous(Vector(0,0,0))
			hit:SetVelocityInstantaneous(Vector(0,0,0))
			mep:Sleep()
			hit:Sleep()
		end
	end
end

hookAdd("OnEntityCreated", "frzr9k", function(ent)
	if APG.cfg["frzr9k"].value then
		timer.Simple(0.01, function() 
			if IsValid(ent) and ent.GetPhysicsObject and IsValid(ent:GetPhysicsObject()) then
				ent:AddCallback("frzr9k", collcall)
			end
		end)
	end
end)

-- Requires Fading Door Hooks --
hookAdd("APG.FadingDoorToggle", "frzr9k", function(ent, faded)
	if APG.cfg["frzr9k"].value and IsValid(ent) then
		if faded then
			local o = APG.getOwner(ent)
			local pos = ent:GetPos()
			local notify = false

			local doors = {}
			local count = 0

			for _,v in next, ents.FindInSphere(pos, 3) do
				if v ~= ent and IsValid(v) and v.isFadingDoor and APG.getOwner(v) == o then
					table.insert(doors, v)
					count = count + 1
				end
			end

			if count > 2 then
				for _,v in next, doors do
					v:Remove()
				end
				notify = true
			end

			if notify then
				o:ChatPrint('[APG] Some of your fading doors were removed.')
			end
		else
			timer.Simple(0, function()
				ent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
				local phys = getphys(ent)
				phys:EnableMotion(false)
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