if APG.cfg["ratioLag"] or false then
    print("[Warning] You don\'t have the latest version of APG!") -- Make a fancy warning?
    APG.cfg.lagSensitivity = APG.cfg.ratioLag
end
local ENT = FindMetaTable( "Entity" )
if APG.cfg.ghosting then
    APG.oSetColGroup = APG.oSetColGroup or ENT.SetCollisionGroup
    function ENT:SetCollisionGroup( group )
        if APG.inEntList( self ) and IsValid(self:CPPIGetOwner()) and self:CPPIGetOwner():IsPlayer() then
            if group == COLLISION_GROUP_NONE then
                if not self.Frozen then
                    group = COLLISION_GROUP_INTERACTIVE
                end
            end
        end
        return APG.oSetColGroup( self, group )
    end
    local PhysObj = FindMetaTable("PhysObj")
    APG.oEnableMotion = APG.oEnableMotion or PhysObj.EnableMotion
    function PhysObj:EnableMotion( bool )
        local ent = self:GetEntity()
        if IsValid(ent) and APG.inEntList( ent ) and IsValid(ent:CPPIGetOwner()) and ent:CPPIGetOwner():IsPlayer() then
            ent.Frozen = not bool
            if not ent.Frozen then
                ent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
            end
        end
        return APG.oEnableMotion( self, bool)
    end
end
function ENT:UnGhost( ply )
    if not APG.inEntList( self, ply ) or not APG.cfg.ghosting then return false end
    if (not self.FoundSmth) and (self:GetCollisionGroup() == COLLISION_GROUP_WORLD) then
        return
    end
    if not self.Picked and self.Ghosted then
        self.FoundSmth = false
        for _,v in pairs(ents.FindInSphere(self:GetPos(),20)) do
            if v:IsPlayer() or v:IsVehicle() then
                self.FoundSmth = true
                if ply then
                    APG.notify( "There is something in this prop!", { ply } )
                end
                continue
            end
        end
        if not self.FoundSmth then
            self.Ghosted = false
            self:DrawShadow(true)
            self:SetColor( self.APG_oldColor or Color(255,255,255,255))
            self.APG_oldColor = false
            if self.Frozen then
                self:SetCollisionGroup( COLLISION_GROUP_NONE )
            else
                self:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE  )
            end
        else
            self:SetCollisionGroup( COLLISION_GROUP_WORLD  )
        end
    end
end
if APG.cfg.lagDetect then
    local lastThink = SysTime()
    local chokeCount = 0
    local func = APG.cfg.lagFunc
    local delta = 0.030
    local triggerLag = 1
    APG.avgLag = 10
    local tickTable = {}
    timer.Create("APG_process", 5, 0, function()
        if delta < triggerLag then
            table.insert(tickTable, delta)
            if #tickTable > 100 then
                table.remove(tickTable, 1)
            end
            APG.avgLag = APG.process( tickTable )
            triggerLag = APG.avgLag * APG.cfg.lagSensitivity
        end
    end)
    local pause = false
    hook.Add("Think","APG_detectLag",function()
        local curTime = SysTime()
        delta = curTime - lastThink
        if delta >= triggerLag then
            chokeCount = chokeCount + 1
            if (chokeCount >= APG.cfg.lagCount) or ( delta > APG.cfg.bigLag ) then
                chokeCount = 0
                if not pause then
                    if isstring(func) then
                        APG[ func ]()
                    else
                        func()
                    end
                    pause = true
                    timer.Simple( APG.cfg.lagSpamTime, function() pause = false end)
                end
            end
        else
            chokeCount = chokeCount > 0 and (chokeCount - 0.5) or 0
        end
        lastThink = curTime
    end)
end
print("[APG] DRM Loaded")
APG.cfg.drmLoaded = true
