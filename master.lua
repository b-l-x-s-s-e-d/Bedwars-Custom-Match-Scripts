-- some of these are broken/not working
-- not working modules: fly, scaffold, reach, spider
-- not tested modules: inventory stealer, pvp enhancements, pickup range, bow rapidfire

local YOUR_NAME = "DeathKiller19386"  -- your username

-- Feature toggles
local ENABLE_AIMBOT = true
local ENABLE_FLY = true
local ENABLE_ANTIVOID = true
local ENABLE_SCAFFOLD = true
local ENABLE_GODMODE = true
local ENABLE_KILLAURA = true
local ENABLE_REACH = true
local ENABLE_SPIDER = true
local ENABLE_INVENTORY_STEALER = true
local ENABLE_PVP_ENHANCEMENTS = true
local ENABLE_PICKUP_RANGE = true
local ENABLE_BOW_RAPIDFIRE = true

-- Services
local PlayerService = game:GetService("PlayerService")
local EntityService = game:GetService("EntityService")
local CombatService = game:GetService("CombatService")
local InventoryService = game:GetService("InventoryService")
local BlockService = game:GetService("BlockService")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Get local player
local me
for _, p in pairs(PlayerService.getPlayers()) do
    if p.Name == YOUR_NAME then
        me = p
        break
    end
end

-- Key tracking for fly/spider
local keysDown = {}
local forwardHeld = false

UserInput.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysDown[input.KeyCode] = true
    end
    if input.KeyCode == Enum.KeyCode.W then forwardHeld = true end
end)

UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysDown[input.KeyCode] = nil
    end
    if input.KeyCode == Enum.KeyCode.W then forwardHeld = false end
end)

-- Aimbot
if ENABLE_AIMBOT then
    Events.ProjectileLaunched(function(event)
        if event.shooter == nil then return end
        local proj = event.projectileType
        if proj ~= "arrow" and proj ~= "crossbow_arrow" and proj ~= "tactical_crossbow_arrow" and 
           proj ~= "headhunter_arrow" and proj ~= "tactical_headhunter_arrow" then
            return
        end
        
        local player = event.shooter:getPlayer()
        if player.name ~= YOUR_NAME then return end
        
        local closest = nil
        local bestDist = math.huge
        
        for _, p in PlayerService.getPlayers() do
            if p.name == player.name then continue end
            local ent = p:getEntity()
            if not ent then continue end
            local dist = (ent:getPosition() - player:getEntity():getPosition()).Magnitude
            if dist < bestDist then
                closest = ent
                bestDist = dist
            end
        end
        
        if not closest then return end
        
        local dmg = 18
        if proj == "crossbow_arrow" then dmg = 34
        elseif proj == "tactical_crossbow_arrow" then dmg = 38
        elseif proj == "headhunter_arrow" then dmg = 55
        elseif proj == "tactical_headhunter_arrow" then dmg = 60 end

        CombatService.damage(closest, dmg)
    end)
end

-- Fly
if ENABLE_FLY then
    local FLY_SPEED = 50
    local UP_KEY = Enum.KeyCode.Space
    local DOWN_KEY = Enum.KeyCode.LeftShift

    RunService.Heartbeat:Connect(function()
        if not me then return end
        local ent = me:getEntity()
        if not ent or not ent:isAlive() then return end

        local moveDir = Vector3.new(0,0,0)
        local lookVec = ent:getLookVector() or Vector3.new(0,0,1)

        if keysDown[UP_KEY] then moveDir = moveDir + Vector3.new(0, FLY_SPEED, 0) end
        if keysDown[DOWN_KEY] then moveDir = moveDir + Vector3.new(0, -FLY_SPEED, 0) end
        if keysDown[Enum.KeyCode.W] then moveDir = moveDir + lookVec * FLY_SPEED end
        if keysDown[Enum.KeyCode.S] then moveDir = moveDir - lookVec * FLY_SPEED end
        if keysDown[Enum.KeyCode.A] then moveDir = moveDir - ent:getRightVector() * FLY_SPEED end
        if keysDown[Enum.KeyCode.D] then moveDir = moveDir + ent:getRightVector() * FLY_SPEED end

        ent:setVelocity(moveDir)
    end)
end

-- AntiVoid
if ENABLE_ANTIVOID then
    local voidY, safePos
    if me then
        local pos = me:getEntity():getPosition()
        voidY = pos.Y - 20
        safePos = pos
    end

    task.spawn(function()
        while true do
            task.wait(0.1)
            if not me then me = PlayerService.getPlayerByUserName(YOUR_NAME) if not me then continue end end
            local ent = me:getEntity()
            if not ent then continue end
            local pos = ent:getPosition()

            if pos.Y < voidY then
                if safePos then
                    ent:setPosition(safePos + Vector3.new(0,5,0))
                    if ent.setVelocity then ent:setVelocity(Vector3.new(0,0,0)) end
                end
            else
                local below = pos - Vector3.new(0,5,0)
                if BlockService.getBlockAt(below) then safePos = pos end
            end
        end
    end)

    Events.EntityDamage:Connect(function(event)
        local tp = event.target:getPlayer()
        if tp and tp.name == YOUR_NAME and (event.amount > 30 or event.target:getPosition().Y < voidY) then
            event.amount = 0
            CombatService.heal(event.target, 50)
        end
    end)
end

-- Scaffold
if ENABLE_SCAFFOLD then
    task.spawn(function()
        while task.wait(0.1) do
            if not me then continue end
            local ent = me:getEntity()
            if not ent or not ent:isAlive() then continue end
            local pos = ent:getPosition()
            local blockBelow = BlockService.getBlockAt(pos - Vector3.new(0,1,0))
            if not blockBelow then
                BlockService.placeBlock(ItemType.WOOL_WHITE, pos - Vector3.new(0,1,0))
            end
        end
    end)
end

-- GodMode / AntiHit
if ENABLE_GODMODE then
    Events.EntityDamage(function(event)
        local tp = event.entity:getPlayer()
        if tp and tp.name == YOUR_NAME then
            event.cancelled = true
            event.damage = 0
        end
    end)
end

-- KillAura
if ENABLE_KILLAURA then
    local RANGE = 18
    local DPS = 10
    local DELAY = 0.3

    task.spawn(function()
        while true do
            task.wait(DELAY)
            if not me then continue end
            local ent = me:getEntity()
            if not ent or not ent:isAlive() then continue end
            local pos = ent:getPosition()
            local targets = EntityService.getNearbyEntities(pos, RANGE)
            for _, t in pairs(targets or {}) do
                if t == ent or not t:isAlive() then continue end
                local tp = t:getPlayer()
                if tp and tp ~= me then
                    CombatService.damage(t, DPS, ent)
                    break
                end
            end
        end
    end)
end

-- Reach
if ENABLE_REACH then
    local REACH_RANGE = 25
    task.spawn(function()
        while task.wait(0.5) do
            if not me then continue end
            local pos = me:getEntity():getPosition()
            for _, p in pairs(PlayerService.getPlayers()) do
                if p == me then continue end
                local ent = p:getEntity()
                if ent and ent:isAlive() and (ent:getPosition() - pos).Magnitude <= REACH_RANGE then
                    ent:setOutlineColor(Color3.fromRGB(255,0,0))
                end
            end
        end
    end)
end

-- Spider
if ENABLE_SPIDER then
    local CLIMB_SPEED = 35
    task.spawn(function()
        while task.wait(0.05) do
            if not me then continue end
            local ent = me:getEntity()
            if not ent or not ent:isAlive() or not forwardHeld then continue end
            local pos = ent:getPosition()
            local look = ent:getLookVector()
            local checkPos = pos + Vector3.new(0,2,0) + (look * 2)
            if BlockService.getBlockAt(checkPos) then
                ent:setVelocity(Vector3.new(ent:getVelocity().X, CLIMB_SPEED, ent:getVelocity().Z))
            end
        end
    end)
end

-- Inventory Stealer
if ENABLE_INVENTORY_STEALER then
    task.spawn(function()
        while true do
            task.wait(math.random(10,30))
            if not me then continue end
            local tPlayers = {}
            for _, p in pairs(PlayerService.getPlayers()) do
                if p ~= me and p.Team ~= me.Team then table.insert(tPlayers,p) end
            end
            if #tPlayers == 0 then continue end
            local vic = tPlayers[math.random(1,#tPlayers)]
            local resources = {ItemType.IRON, ItemType.DIAMOND, ItemType.EMERALD}
            local res = resources[math.random(1,#resources)]
            local amount = math.min(InventoryService:getAmount(vic,res), 5)
            if amount > 0 then
                InventoryService:removeItemAmount(vic, res, amount)
                InventoryService:giveItem(me, res, amount, true)
            end
        end
    end)
end

-- Subtle PvP Enhancements
if ENABLE_PVP_ENHANCEMENTS then
    local SPEED_BOOST = 1.05
    local JUMP_BOOST = 1.05
    local DAMAGE_REDUCTION = 0.1

    task.spawn(function()
        while true do
            task.wait(0.1)
            if not me then continue end
            local ent = me:getEntity()
            if not ent then continue end
            if ent.setWalkSpeed then ent:setWalkSpeed(SPEED_BOOST) end
            if ent.setJumpPower then ent:setJumpPower(ent:getJumpPower()*JUMP_BOOST) end

            for _, p in pairs(PlayerService.getPlayers()) do
                if p == me or p.Team == me.Team then continue end
                local tEnt = p:getEntity()
                if tEnt and tEnt:isAlive() and tEnt.setDamageModifier then
                    tEnt:setDamageModifier(1-DAMAGE_REDUCTION)
                end
            end
        end
    end)
end

-- Pickup Range
if ENABLE_PICKUP_RANGE then
    local PICKUP_RANGE = 20
    task.spawn(function()
        while true do
            task.wait(0.1)
            if not me then continue end
            local ent = me:getEntity()
            if not ent or not ent:isAlive() then continue end
            local pos = ent:getPosition()
            local items = EntityService.getNearbyEntities(pos, PICKUP_RANGE) or {}
            local resources = {ItemType.IRON, ItemType.DIAMOND, ItemType.EMERALD}
            for _, item in pairs(items) do
                local itemType = item:getItemType()
                if table.find(resources, itemType) then
                    local amount = item:getAmount() or 0
                    if amount > 0 then
                        InventoryService:giveItem(me, itemType, amount, true)
                        InventoryService:removeItemAmount(item, itemType, amount)
                    end
                end
            end
        end
    end)
end

-- Bow Rapid Fire
if ENABLE_BOW_RAPIDFIRE then
    local FIRE_DELAY = 0.1
    local MAX_RANGE = 100
    task.spawn(function()
        while true do
            task.wait(FIRE_DELAY)
            if not me then continue end
            local ent = me:getEntity()
            if not ent or not ent:isAlive() then continue end
            local pos = ent:getPosition()
            local closest = nil
            local bestDist = math.huge
            for _, p in pairs(PlayerService.getPlayers()) do
                if p == me then continue end
                local targetEnt = p:getEntity()
                if targetEnt and targetEnt:isAlive() then
                    local dist = (targetEnt:getPosition() - pos).Magnitude
                    if dist < bestDist and dist <= MAX_RANGE then
                        closest = targetEnt
                        bestDist = dist
                    end
                end
            end
            if not closest then continue end
            local arrowType = "arrow"
            local proj = EntityService.spawnProjectile(arrowType, ent:getPosition() + Vector3.new(0,2,0))
            local dir = (closest:getPosition() - proj:getPosition()).Unit
            proj:setVelocity(dir * 150)
        end
    end)
end
