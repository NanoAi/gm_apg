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

local function getphys(ent)
	local phys = IsValid(ent) and ent.GetPhysicsObject and ent:GetPhysicsObject() or false
	return IsValid(phys) and phys or false
end

hookAdd("CanTool", "APG_canTool", function(ply, tr, tool)
	if IsValid(tr.Entity) and tr.Entity.APG_Ghosted then
		APG.notify("Cannot use tool on ghosted entity!", ply, 1)
		return false
	end
	if APG.cfg["thFadingDoors"].value and tool == "fading_door" then
		timer.Simple(0, function()
			if IsValid(tr.Entity) and not tr.Entity:IsPlayer() then
				local ent = tr.Entity

				if not IsValid(ent) then return end
				if not ent.isFadingDoor then return end

				local state = ent.fadeActive

				if state then
					ent:fadeDeactivate()
				end

				ent.oldFadeActivate = ent.oldFadeActivate or ent.fadeActivate
				ent.oldFadeDeactivate = ent.oldFadeDeactivate or ent.fadeDeactivate

				function ent:fadeActivate()
					if hook.Run("APG.FadingDoorToggle", self, true, ply) then return end
					ent:oldFadeActivate()
				end

				function ent:fadeDeactivate()
					if hook.Run("APG.FadingDoorToggle", self, false, ply) then return end
					ent:oldFadeDeactivate()
					ent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
				end

				if state then
					ent:fadeActivate()
				end
			end
		end)
	end
end)

hookAdd("APG.FadingDoorToggle", "init", function(ent, state, ply)
	if ent.APG_Ghosted then
		APG.notify("Your fading door is ghosted! (" .. ( type(ent.GetModel) == "function" and ent:GetModel() or "???" ) .. ")", ply, 1)
		return true
	end

	ent:ForcePlayerDrop()

	local phys = getphys(ent)
	if phys then
		phys:EnableMotion(false)
	end
end)

--[[ FRZR9K ]]--

local zero = Vector(0,0,0)
local pstop = FrameTime()*3

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
		local time = CurTime() + 5
		local obj = ent['frzr9k']

		obj.Collisions = (obj.Collisions or 0) + 1
		obj.LastCollision = obj.LastCollision or CurTime()

		if obj.Collisions > 23 then
			obj.Collisions = 0
			mep:SetVelocityInstantaneous(Vector(0,0,0))
			hit:SetVelocityInstantaneous(Vector(0,0,0))
			mep:Sleep()
			hit:Sleep()
		end

		if time < obj.LastCollision then
			obj.Collisions = math.max(obj.Collisions - 1, 0)
		end

		obj.LastCollision = CurTime()
		MsgN("[APG-DEBUG] " .. tostring(obj) .. " has collided! Hits: " .. obj.Collisions .. "/23 | LastHit: " .. string.NiceTime(obj.LastCollision) .. " ago")
		
		print("[APG-DEBUG] --DATA TABLE-- [APG-DEBUG]")
		PrintTable(obj)
		print("[APG-DEBUG] --DATA END-- [APG-DEBUG]")

		ent['frzr9k'] = obj
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
