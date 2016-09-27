--[[------------------------------------------

    A.P.G. - a lightweight Anti Prop Griefing solution (v{{ script_version_name }})
    Made by :
    - While True (http://steamcommunity.com/id/76561197972967270)
    - LuaTenshi (http://steamcommunity.com/id/76561198096713277)

    Licensed to : http://steamcommunity.com/id/{{ user_id }}

]]--------------------------------------------
util.AddNetworkString("apg_notice_s2c")

APG = APG or {}
--[[------------------------------------------
            ENTITY Related
]]--------------------------------------------

function APG.canPhysGun( ent, ply )
    if not IsValid(ent) then return false end -- The entity isn't valid, don't pickup.
    if ply.APG_CantPickup then return false end -- Is APG blocking the pickup?
    if ent.CPPICanPhysgun then return ent:CPPICanPhysgun(ply) end -- Let CPPI handle things from here.

    return (not ent.PhysgunDisabled) -- By default everything can be picked up, unless it is PhysgunDisabled.
end

function APG.isBadEnt( ent )
    if not IsValid(ent) then return false end
    local class = ent:GetClass()
    for k, v in pairs (APG.cfg["bad_ents"].value) do
        if ( v and k == class ) or (not v and string.find( class, k) ) then
            return true
        end
    end
    return false
end

function APG.getOwner( ent )
    local owner, _ = ent:CPPIGetOwner() or ent.FPPOwner or nil
    return owner
end

function APG.killVelocity(ent, extend, freeze, wake_target)
    local vec = Vector()
    ent:SetVelocity(vec)

    if ent.IsPlayer and ent:IsPlayer() then ent:SetVelocity(ent:GetVelocity()*-1) end

    local function killvel(phys, freeze)
        if not IsValid(phys) then return end
        if freeze then phys:EnableMotion(false) return end

        local collision = phys:IsCollisionEnabled()

        phys:EnableCollisions(false)

        phys:SetVelocity(vec)
        phys:SetVelocityInstantaneous(vec)
        phys:AddAngleVelocity(phys:GetAngleVelocity()*-1)

        phys:EnableCollisions(collision)

        phys:Sleep()
        phys:RecheckCollisionFilter()
    end

    for i = 0, ent:GetPhysicsObjectCount() do killvel(ent:GetPhysicsObjectNum(i), freeze) end -- Includes self?

    if extend then
        for _,v in next, constraint.GetAllConstrainedEntities(ent) do killvel(v:GetPhysicsObject(), freeze) end
    end

    if wake_target then
        local phys = ent:GetPhysicsObject()
        phys:Wake()
    end

    ent:CollisionRulesChanged()
end

local function findwac(ent)
    local e
    local i = 0
    if ent.wac_seatswitch or ent.wac_ignore then return true end
    for _,v in next, constraint.GetAllConstrainedEntities(ent) do
        if v.wac_seatswitch or v.wac_ignore then e = v break end
        if i > 12 then break end -- Only check up to 12.
        i = i + 1
    end
    return IsValid(e)
end

function APG.cleanUp( mode, notify )
    mode = mode or "unfrozen"
    for _, v in next, ents.GetAll() do
        APG.killVelocity(v,false)
        if not APG.isBadEnt(v) or not APG.getOwner( v ) or v:GetParent():IsVehicle() or findwac(v) then continue end
        if mode == "unfrozen" and v.APG_Frozen then -- Wether to clean only not frozen ents or all ents
            continue
        else
            v:Remove()
        end
    end
    -- TODO : Fancy notification system
    APG.log("[APG] Cleaned up (mode:" .. mode .. ")")
end

function APG.ghostThemAll( notify )
    if not APG.modules[ "ghosting" ] then
        return APG.log("[APG] Warning : Tried to ghost props but ghosting is disabled!")
    end
    for _, v in next, ents.GetAll() do
        if not APG.isBadEnt(v) or not APG.getOwner( v ) or v:GetParent():IsVehicle() or v.APG_Frozen then continue end
        APG.entGhost( v, false, true )
    end
    -- TODO : Fancy notification system
    APG.log("[APG] Unfrozen props ghosted!")
end

function APG.freezeIt( ent )
    local pObj = ent:GetPhysicsObject()
    if IsValid(pObj) then
        pObj:EnableMotion( false)
        ent.APG_Frozen = true
    end
end

function APG.freezeProps( notify )
    for _, v in next, ents.GetAll() do
        if not APG.isBadEnt(v) or not APG.getOwner( v ) then continue end
        APG.freezeIt( v )
    end
    -- TODO : Fancy notification system
    APG.log("[APG] Props frozen")
end

function APG.ForcePlayerDrop(ply,ent)
    ent.APG_ForceDrop[ply:SteamID()] = { 
        time = CurTime()+0.1,
        who = ply,
    }
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

function APG.notify(msg, targets, level)

    local msg = string.PatternSafe(tostring(msg):gsub("%%","<p>"))
    local targets = targets
    local level = level
    
    if type(level) == "string" then
        level = string.lower(level)
        level = level == "notice" and 0 or level == "warning" and 1 or level == "alert" and 2
    end

    if type(targets) ~= "table" then -- Convert to a table.
        targets = string.lower(tostring(targets))
        if targets == "1" or targets == "superadmins" then
            for _,v in next, player.GetHumans() do
                if not IsValid(v) then continue end
                if not (v:IsSuperAdmin()) then continue end
                table.insert(targets,v) 
            end
        elseif targets == "2" or targets == "admins" then
            for _,v in next, player.GetHumans() do
                if not IsValid(v) then continue end
                if not (v:IsAdmin() or v:IsSuperAdmin()) then continue end
                table.insert(targets,v) 
            end            
        elseif targets == "0" or targets == "all" or targets == "everyone" then
            targets = player.GetHumans()
        end
    end

    for _,v in next, targets do
        if not IsValid(v) then continue end
        net.Start("apg_notice_s2c")
            net.WriteUInt(level,3)
            net.WriteString(msg)
        net.Send(v)
    end
end


--[[------------------------------------------
    Player Control
]]--------------------------------------------

hook.Add("StartCommand", "APG_StartCmd", function(ply, mv) -- Allows to control player events before they happen.
    local predicted_ent = ply.APG_CurrentlyHolding
    local ent = IsValid(predicted_ent) and predicted_ent or ply:GetEyeTrace().Entity

    if not IsValid(ent) then return end
    if not ent.APG_ForceDrop then return end

    local ForceDrop = ent.APG_ForceDrop[ply:SteamID() or ""]

    if ForceDrop.time < CurTime() then
        ForceDrop = nil
        return
    end

    if (bit.band(mv:GetButtons(),IN_ATTACK) > 0) and ForceDrop.time > CurTime() and ForceDrop.who == ply then
        ForceDrop.time = CurTime()+0.1
        mv:SetButtons(bit.band(mv:GetButtons(),bit.bnot(IN_ATTACK)))
    end
end)

--[[------------------------------------------
    Entity pickup part
]]--------------------------------------------
hook.Add("PhysgunPickup","APG_PhysgunPickup", function(ply, ent)
    if not APG.isBadEnt( ent ) then return end
    if not APG.canPhysGun( ent, ply ) then return false end

    local steamid = ply and ply.SteamID and ply:SteamID()
       
    ent.APG_ForceDrop = ent.APG_ForceDrop or {}
    if ent.APG_ForceDrop[steamid] then return false end

    local HasHolder = (ent.APG_HeldBy and #ent.APG_HeldBy > 0) == true
    local HeldByLast = ent.APG_HeldBy.last

    if HasHolder then
        if HeldByLast and (ply:IsAdmin() or ply:IsSuperAdmin()) then
            ent:ForcePlayerDrop()
            for _,v in next, ent.APG_HeldBy do
                APG.ForcePlayerDrop(v, ent)
            end
        else
            return false
        end
    end

    if IsValid(ply) then
        ent.APG_HeldBy = ent.APG_HeldBy or {}
        ent.APG_HeldBy[ply:SteamID()] = ply
        ent.APG_HeldBy.last = {ply = ply, id = ply:SteamID()}
        ply.APG_CurrentlyHolding = ent
    end

    ent.APG_Picked = true
    ent.APG_Frozen = false
end)

--[[--------------------
    No Collide (between them) on props unfreezed
]]----------------------
hook.Add("PlayerUnfrozeObject", "APG_PlayerUnfrozeObject", function(ply, ent, object)
    if not APG.isBadEnt( ent ) then return end
    ent.APG_Frozen = false
end)

--[[------------------------------------------
    Entity drop part
]]--------------------------------------------

--[[--------------------
    PhysGun Drop and Anti Throw Props
]]----------------------
hook.Add( "PhysgunDrop", "APG_physGunDrop", function( ply, ent )
    ent.APG_HeldBy = ent.APG_HeldBy or {}
    ent.APG_HeldBy[ply:SteamID()] = nil -- Remove the holder.
    ply.APG_CurrentlyHolding = nil

    ent.APG_Picked = false
    
    if not APG.isBadEnt( ent ) then return end
    APG.killVelocity(ent,true,false,true) -- Extend to constrained props, and wake target.
end)

--[[--------------------
    Physgun Drop & Freeze
]]----------------------
hook.Add( "OnPhysgunFreeze", "APG_OnPhysgunFreeze", function( weap, phys, ent, ply )
    if not APG.isBadEnt( ent ) then return end
    ent.APG_Frozen = true
end)


--[[--------------------
    Admin utility
]]----------------------

function APG.log(msg, ply)
    if type(ply) ~= "string" and IsValid(ply) then
        ply:PrintMessage(3, msg)
    else
        print(msg)
    end
end

--[[--------------------
    APG job manager
]]----------------------
local toProcess = {}
function APG.dJobRegister( job, delay, limit, func, onBegin, onEnd )
    local tab = {
        content = {},
        delay = delay,
        limit = limit,
        func = func,
        onBegin = onBegin or nil,
        onEnd = onEnd or nil
    }
    toProcess[job] = tab
end

local function APG_delayedTick( job )
    if toProcess[job].processing and toProcess[job].processing == true then return end
    toProcess[job].processing = true
    if toProcess[job].onBegin then toProcess[job].onBegin() end
    local delay, pLimit = toProcess[job].delay, toProcess[job].limit
    local total = #toProcess[job].content
    local count = math.Clamp(total,0,pLimit)
    for i = 1, count do
        local cur = toProcess[job].content[1]
        timer.Create( "delay_" .. job .. "_" .. i , ( i - 1 ) * delay , 1, function()
            toProcess[job].func( cur )
        end)
        table.remove(toProcess[job].content, 1)
    end
    timer.Create("dJob_" .. job .. "_process", ( count * delay ) + 0.1 , 1, function() toProcess[job].processing = false
        if #toProcess[job].content < 1 and toProcess[job].onEnd then toProcess[job].onEnd() end
    end)
end

function APG.startDJob( job, content )

    if not isstring(job) or not content or table.HasValue(toProcess[job].content, content) then return end
    -- Is it a problem if there is a same ent being unghosted twice ?
    table.insert( toProcess[job].content, content )
    hook.Add("Tick", "APG_delayed_" .. job, function()
        if #toProcess[job].content > 0 then
            APG_delayedTick( job )
        else
            hook.Remove("Tick", "APG_delayed_" .. job)
        end
    end)
end

--[[--------------------
    LOADING DRM + MODULES

local id, hash = {{ script_id }}, {{ web_hook "http://scriptenforcer.net/api.php?action=getAuth" "" }}
local version, add = "{{ script_version_name }}", ""
hook.Add("Initialize", "APG_DRM", function()
    timer.Simple(30, function()
        APG_DRM(id, hash, "base", version, add)
        for k, v in next, APG.modules do
            APG_DRM(id, hash, k, version, add)
        end
        timer.Simple(5, function() APG.reload() end)
    end)
end)

local canDRM = true
concommand.Add( "APG_DRM", function(ply, cmd, arg) -- You can get banned from ScriptEnforcer if you spam this command !
    if (IsValid(ply) and not ply:IsSuperAdmin()) or not canDRM then return end
    canDRM = false
    APG_DRM(id, hash, "base", version, add)
    for k, v in next, APG.modules do
        APG_DRM(id, hash, k, version, add)
    end
    timer.Simple(5, function() APG.reload() end)
    ply:PrintMessage ( 3 , "[APG] DRM Reloaded - You can get banned from ScriptEnforcer if you spam this command" )
    timer.Simple(60, function() canDRM = true end)
end)
]]----------------------