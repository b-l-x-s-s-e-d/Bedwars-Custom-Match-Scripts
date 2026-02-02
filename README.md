# Custom Match Scripts

## Aimbot
```lua
Events.ProjectileLaunched(function(event)
    if (event.shooter == nil) then
        return
    end
    if (event.projectileType == "arrow") or (event.projectileType == "crossbow_arrow") or (event.projectileType == "tactical_crossbow_arrow") or (event.projectileType == "headhunter_arrow") or (event.projectileType == "tactical_headhunter_arrow") then

        local player = event.shooter:getPlayer()
        if player.name == "DeathKiller19386" then -- Insert Your Username Here
            local target = 0
            local targetDistance = 100000
            for i, enemy in PlayerService.getPlayers() do
                local enemyPosition = enemy:getEntity():getPosition()
                local playerPosition = player:getEntity():getPosition()
                local distance = (enemyPosition - playerPosition).magnitude
                if ((distance < targetDistance) and (enemy.name ~= "DeathKiller19386")) then -- Insert Your Username Here
                    target = enemy
                    targetDistance = distance
                end
            end
            if (event.projectileType == "arrow") then
                CombatService.damage(target:getEntity(), 25)
            elseif (event.projectileType == "crossbow_arrow") then
                CombatService.damage(target:getEntity(), 35)
            elseif (event.projectileType == "tactical_crossbow_arrow") then
                CombatService.damage(target:getEntity(), 50)
            elseif (event.projectileType == "tactical_headhunter_arrow") then
                CombatService.damage(target:getEntity(), 60)
            end
        end
    end
end)
```

## Anti-Void

```lua
local YOUR_NAME = "DeathKiller19386"
local voidThreshold = nil
local lastSafePos = nil
local player = nil

for _, p in pairs(PlayerService.getPlayers()) do
    if p.name == YOUR_NAME then
        player = p
        break
    end
end

if player then
    local entity = player:getEntity()
    local spawnPos = entity:getPosition()
    voidThreshold = spawnPos.Y - 20
    lastSafePos = spawnPos
end

task.spawn(function()
    while true do
        task.wait(0.1)
        
        if not player then
            player = PlayerService.getPlayerByUserName(YOUR_NAME)
            if not player then continue end
        end
        
        local entity = player:getEntity()
        if not entity then continue end
        
        local currPos = entity:getPosition()
        local currY = currPos.Y
        
        if currY < voidThreshold then
            if lastSafePos then
                local bouncePos = lastSafePos + Vector3.new(0, 5, 0)
                entity:setPosition(bouncePos)
                if entity.setVelocity then
                    entity:setVelocity(Vector3.new(0, 0, 0))
                end
            end
        else
            local belowPos = currPos - Vector3.new(0, 5, 0)
            local blockBelow = BlockService.getBlockAt(belowPos)
            if blockBelow then
                lastSafePos = Vector3.new(currPos.X, currPos.Y, currPos.Z)
            end
        end
    end
end)

Events.EntityDamage:Connect(function(event)
    local targetPlayer = event.target:getPlayer()
    if targetPlayer and targetPlayer.name == YOUR_NAME then
        local pos = event.target:getPosition()
        if (event.amount or 0) > 30 or pos.Y < (voidThreshold or 0) then
            event.amount = 0
            CombatService.heal(event.target, 50)
        end
    end
end)

print("[COMPACT LAND BOUNCE] Loaded for " .. YOUR_NAME)
```

## Scaffold

```lua
-- Scaffold ALWAYS ON for DeathKiller19386
-- Places wool blocks under your feet constantly while moving
-- Visual feedback: chat message on start + particles on placed blocks

local YOUR_NAME = "DeathKiller19386"
local BLOCK_TYPE = "wool_white"   -- Change to "wool_red", "obsidian", "stone", etc.
local PLACE_DELAY = 0.08          -- Smoother = lower number, but don't go below ~0.05 to avoid lag/kick
local PARTICLE_COLOR = Color3.fromRGB(255, 255, 255)

-- Get player & entity
local player = nil
for _, p in PlayerService.getPlayers() do
    if p.name == YOUR_NAME then
        player = p
        break
    end
end

if not player then
    print("[Scaffold] Player not found: " .. YOUR_NAME)
    return
end

local entity = player:getEntity()
if not entity then
    print("[Scaffold] Entity not found")
    return
end

-- One-time startup message
player:sendMessage("§aScaffold ALWAYS ON - blocks placed under feet")

-- Main scaffold placement loop
task.spawn(function()
    while true do
        task.wait(PLACE_DELAY)
        
        local pos = entity:getPosition()
        
        -- Calculate position directly under feet
        local placePos = Vector3.new(
            math.floor(pos.X + 0.5),
            math.floor(pos.Y - 1.5),   -- -1.5 usually perfect for under feet
            math.floor(pos.Z + 0.5)
        )
        
        -- Skip if block already exists there (prevents spam/replace)
        if not BlockService.getBlockAt(placePos) then
            BlockService.placeBlock(placePos, BLOCK_TYPE, player)
            
            -- Visual particle effect on placed block
            local part = Instance.new("Part")
            part.Size = Vector3.new(1,1,1)
            part.Position = placePos + Vector3.new(0.5, 0.5, 0.5)
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 1
            part.Parent = workspace
            
            local particle = Instance.new("ParticleEmitter")
            particle.Color = ColorSequence.new(PARTICLE_COLOR)
            particle.Lifetime = NumberRange.new(0.5, 0.8)
            particle.Rate = 25
            particle.Speed = NumberRange.new(4, 8)
            particle.SpreadAngle = Vector2.new(360, 360)
            particle.Enabled = true
            particle.Parent = part
            
            game.Debris:AddItem(part, 0.9)  -- Clean up quickly
        end
    end
end)

print("[Scaffold ALWAYS ON] Loaded for " .. YOUR_NAME .. " - blocks under feet")
```

## Godmode / Antihit

```lua
local YOUR_NAME = "DeathKiller19386"

Events.EntityDamage(function(event)
    local tp = event.entity:getPlayer()
    if tp and tp.name == YOUR_NAME then
        event.cancelled = true
        event.damage = 0
    end
end)
```

## KillAura

```lua
-- ULTIMATE KILL AURA for DeathKiller19386 - Attacks ALL entities (players, titans, mobs, bhan, etc.)
-- Uses EntityService.getNearbyEntities() for ALL damageable targets

local YOUR_NAME = "DeathKiller19386"
local RANGE = 18          -- Melee range (studs)
local DAMAGE = 10        -- Damage per swing
local SWING_DELAY = 0.3  -- Auto-swing speed (lower = faster DPS)

local myPlayer = nil

-- Cache player on load/respawn
Events.PlayerAdded(function(event)
    if event.player.name == YOUR_NAME then
        myPlayer = event.player
        print("[Kill Aura] Player cached: " .. YOUR_NAME)
    end
end)

-- Initial cache
for _, p in PlayerService.getPlayers() do
    if p.name == YOUR_NAME then
        myPlayer = p
        break
    end
end

if not myPlayer then return end

task.spawn(function()
    while true do
        task.wait(SWING_DELAY)
        
        local myEntity = myPlayer:getEntity()
        if not myEntity or not myEntity:isAlive() then continue end
        
        local myPos = myEntity:getPosition()
        local nearbyEntities = EntityService.getNearbyEntities(myPos, RANGE)
        
        if nearbyEntities then
            for _, target in ipairs(nearbyEntities) do
                if target ~= myEntity and target:isAlive() and target:getPlayer() ~= myPlayer then
                    CombatService.damage(target, DAMAGE, myEntity)
                    print("[Kill Aura] Swung " .. DAMAGE .. " dmg on entity (" .. math.floor((target:getPosition() - myPos).magnitude) .. " studs)")
                    break  -- Hit nearest first, or remove to hit all
                end
            end
        end
    end
end)
```
