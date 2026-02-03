# Custom Match Scripts

These scripts work **ONLY** in the Roblox Bedwars Custom Game Script tab. It **CANNOT** get you banned, and it is **NOT** going to work outside of Roblox Bedwars.<br>
Most of these were made with GPT-5.<br><br>
If any of these scripts do not work. Troubleshooting is provided at the bottom.

## How to Use

1. Open Roblox Bedwars
2. Create a Custom Game and make sure you are the host
3. Press the 3 dots (⋮) on the top right corner and click "Scripts"
4. Create a new script and copy your desired script
5. Replace `YOUR_NAME` with your Roblox username
6. Save the script, then press run. The script should be running now
7. If you update the script, make sure to resave it and rerun it


## Aimbot
```lua
Events.ProjectileLaunched(function(event)
    if event.shooter == nil then return end
    
    local proj = event.projectileType
    if proj ~= "arrow" and proj ~= "crossbow_arrow" and proj ~= "tactical_crossbow_arrow" and 
       proj ~= "headhunter_arrow" and proj ~= "tactical_headhunter_arrow" then
        return
    end
    
    local player = event.shooter:getPlayer()
    if player.name ~= "DeathKiller19386" then return end  -- your username
    
    local closest = nil
    local bestDist = math.huge                            -- aimbot distance (math.huge = infinite)
    
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
    
    local dmg = 25
    if proj == "crossbow_arrow" then dmg = 35
    elseif proj == "tactical_crossbow_arrow" then dmg = 50
    elseif proj:find("headhunter") then dmg = 60 end
    
    CombatService.damage(closest, dmg)
end)
```

## Anti-Void

```lua
local YOUR_NAME = "DeathKiller19386"  -- your username

local player, voidY, safePos

for _, p in PlayerService.getPlayers() do
    if p.name == YOUR_NAME then
        player = p
        break
    end
end

if player then
    local pos = player:getEntity():getPosition()
    voidY = pos.Y - 20
    safePos = pos
end

task.spawn(function()
    while true do
        task.wait(0.1)
        
        if not player then
            player = PlayerService.getPlayerByUserName(YOUR_NAME)
            if not player then continue end
        end
        
        local ent = player:getEntity()
        if not ent then continue end
        
        local pos = ent:getPosition()
        
        if pos.Y < voidY then
            if safePos then
                ent:setPosition(safePos + Vector3.new(0,5,0))
                if ent.setVelocity then
                    ent:setVelocity(Vector3.new(0,0,0))
                end
            end
        else
            local below = pos - Vector3.new(0,5,0)
            if BlockService.getBlockAt(below) then
                safePos = pos
            end
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
```

## Scaffold

```lua
local names = {"DeathKiller19386"} -- your username

while task.wait(0.1) do
    local player = PlayerService.getLocalPlayer()
    if not player then continue end
    
    local isMe = false
    for _, name in names do
        if player.name == name then
            isMe = true
            break
        end
    end
    
    if not isMe then continue end
    
    local ent = player:getEntity()
    if not ent then continue end
    
    local pos = ent:getPosition()
    local checkPos = pos - Vector3.new(0, 10, 0)
    
    local blockBelow = BlockService.getBlockAt(pos - Vector3.new(0, 1, 0))
    
    if pos.Y > 50 or pos.Y < -10 then
        if not blockBelow and not BlockService.getBlockAt(checkPos) then
            BlockService.placeBlock(ItemType.WOOL_WHITE, pos - Vector3.new(0, 1, 0))
        end
    end
end
```

## GodMode / AntiHit

```lua
local YOUR_NAME = "DeathKiller19386"  -- your username

Events.EntityDamage:Connect(function(event)
    local p = event.entity:getPlayer()
    if p and p.name == YOUR_NAME then
        event.cancelled = true        -- true: cancels damage
        event.damage = 0              -- double checks and removes any damage that might still slip through event.cancelled
    end
end)
```

## KillAura

```lua
local YOUR_NAME = "DeathKiller19386"  -- your username
local RANGE = 18                      -- kill aura range (default is 18)
local DPS = 10                        -- damage
local DELAY = 0.3                     -- attack delay (default is 0.3)

local me
for _, p in PlayerService.getPlayers() do
    if p.name == YOUR_NAME then
        me = p
        break
    end
end

task.spawn(function()
    while true do
        task.wait(DELAY)
        if not me then continue end
        
        local ent = me:getEntity()
        if not ent or not ent:isAlive() then continue end
        
        local pos = ent:getPosition()
        local targets = EntityService.getNearbyEntities(pos, RANGE)
        
        for _, t in targets or {} do
            if t == ent or not t:isAlive() then continue end
            local tp = t:getPlayer()
            if tp and tp ~= me then
                CombatService.damage(t, DPS, ent)
                break
            end
        end
    end
end)
```

## Reach

```lua
local YOUR_NAME = "DeathKiller19386" -- your username

task.spawn(function()
    while task.wait(0.5) do
        for _, player in PlayerService.getPlayers() do
            if player.name == YOUR_NAME then continue end
            
            local char = player.Character
            if not char then continue end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Size = Vector3.new(25, 6, 25)
            end
        end
    end
end)
```

## Spider

```lua
local CLIMB_SPEED = 50                -- climb speed (changeable)
local YOUR_NAME = "DeathKiller19386"  -- your username

local me
for _, p in PlayerService.getPlayers() do
    if p.name == YOUR_NAME then
        me = p
        break
    end
end

while task.wait() do
    if not me then continue end
    
    local char = me.Character
    if not char then continue end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    local foot = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
    
    if not (hrp and hum and foot) then continue end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = workspace:Raycast(foot.Position, hrp.CFrame.LookVector * 2, rayParams)
    
    if result then
        hum.PlatformStand = true
        hum:ChangeState(Enum.HumanoidStateType.Climbing)
        local v = hrp.Velocity
        hrp.Velocity = Vector3.new(v.X, CLIMB_SPEED, v.Z)
    else
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end
end
```

## Inventory Stealer

```lua
local myUsername = "DeathKiller19386"  -- your username

while true do
    wait(math.random(10,30))
    
    local me = game.Players:FindFirstChild(myUsername)
    if not me then continue end
    
    local t = MatchService:getMatchDurationSec()
    if t <= 0 then continue end
    
    local m = math.floor(t / 60)
    
    local opps = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= me and p.Team ~= me.Team then
            table.insert(opps, p)
        end
    end
    
    if #opps == 0 then continue end
    
    local vic = opps[math.random(1, #opps)]
    
    local ress = {ItemType.IRON, ItemType.DIAMOND, ItemType.EMERALD}
    local res = ress[math.random(1,3)]
    
    local ta
    if res == ItemType.IRON then
        if m < 5 then
            ta = 10
        elseif m < 15 then
            ta = 50
        else
            ta = 100
        end
    elseif res == ItemType.EMERALD then
        if m < 5 then
            ta = 1
        elseif m < 15 then
            ta = 2
        elseif m < 20 then
            ta = 3
        else
            ta = 5
        end
    else
        if m < 5 then
            ta = 1
        elseif m < 15 then
            ta = 3
        elseif m < 20 then
            ta = 5
        else
            ta = 7
        end
    end
    
    local a = InventoryService:getAmount(vic, res)
    local s = math.min(ta, a)
    if s > 0 then
        InventoryService:removeItemAmount(vic, res, s)
        InventoryService:giveItem(me, res, s, true)
    end
end
```

## Subtle PvP Enhancements

```lua
local YOUR_NAME = "DeathKiller19386" -- your username

-- these values can be changed to be more blatant or subtle
local DAMAGE_REDUCTION = 0.1
local KNOCKBACK_INCREASE = 1.1
local SPEED_BOOST = 1.05
local JUMP_BOOST = 1.05
local FALL_DAMAGE_REDUCTION = 0.5
local ATTACK_COOLDOWN_REDUCTION = 0.9

task.spawn(function()
    while true do
        task.wait(0.1)
        
        local me = PlayerService.getLocalPlayer()
        if not me or me.name ~= YOUR_NAME then continue end
        local myEnt = me:getEntity()
        if not myEnt then continue end
        
        if myEnt.setWalkSpeed then
            myEnt:setWalkSpeed(SPEED_BOOST)
        end
        if myEnt.setJumpPower then
            myEnt:setJumpPower(myEnt:getJumpPower() * JUMP_BOOST)
        end
        if myEnt.setFallDamageModifier then
            myEnt:setFallDamageModifier(FALL_DAMAGE_REDUCTION)
        end
        if myEnt.setAttackCooldown then
            myEnt:setAttackCooldown(myEnt:getAttackCooldown() * ATTACK_COOLDOWN_REDUCTION)
        end
        
        for _, player in pairs(PlayerService.getPlayers()) do
            if player.name == YOUR_NAME or player.Team == me.Team then continue end
            local ent = player:getEntity()
            if not ent or not ent:isAlive() then continue end
            
            if ent.setDamageModifier then
                ent:setDamageModifier(1 - DAMAGE_REDUCTION)
            end
            if ent.setKnockbackModifier then
                ent:setKnockbackModifier(1 + KNOCKBACK_INCREASE)
            end
            if ent.setOutlineColor then
                ent:setOutlineColor(Color3.fromRGB(255,150,150))
            end
        end
    end
end)
```

## Pickup Range

```lua
local YOUR_NAME = "DeathKiller19386" -- your username
local PICKUP_RANGE = 20              -- pickup range

task.spawn(function()
    while true do
        task.wait(0.1)
        
        local me = PlayerService.getLocalPlayer()
        if not me or me.name ~= YOUR_NAME then continue end
        local myEnt = me:getEntity()
        if not myEnt then continue end
        local myPos = myEnt:getPosition()
        
        for _, item in pairs(EntityService.getNearbyEntities(myPos, PICKUP_RANGE)) do
            if not item:isAlive() then continue end
            local itemType = item:getItemType()
            if itemType ~= ItemType.IRON and itemType ~= ItemType.DIAMOND and itemType ~= ItemType.EMERALD then continue end
            local distance = (item:getPosition() - myPos).Magnitude
            if distance > PICKUP_RANGE then continue end
            
            local amount = item:getAmount()
            if amount > 0 then
                InventoryService:giveItem(me, itemType, amount, true)
            end
        end
    end
end)
```

## Troubleshooting

**Problem:** Getting anti-cheated while using some scripts<br>
**Solution:** Run this command in chat: `/setac disabled`

**Problem:** Some scripts are not working<br>
**Solution:** Make sure that the whole script was pasted, and make sure your username is correct and in the right places. If none of these work, wait for an update

**Problem:** Scripts affecting teammates<br>
**Solution:** Ensure only your username is in the `local YOUR_NAME = ...` or similar

## Credits

- Written and maintained by Joseph (Pluto).
- Uses Roblox Bedwars API functions like PlayerService, EntityService, CombatService, and InventoryService.

