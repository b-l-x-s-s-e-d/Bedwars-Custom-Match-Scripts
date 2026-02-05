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

## Fly
For an easier alternative, type `/fly` into the chat to enable flight, and `/unfly` to disable

```lua
local YOUR_NAME = "DeathKiller19386"  -- your username
local FLY_SPEED = 50
local UP_KEY = Enum.KeyCode.Space
local DOWN_KEY = Enum.KeyCode.LeftShift

local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local me
for _, p in pairs(PlayerService.getPlayers()) do
    if p.Name == YOUR_NAME then
        me = p
        break
    end
end

local keysDown = {}

UserInput.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysDown[input.KeyCode] = true
    end
end)

UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysDown[input.KeyCode] = nil
    end
end)

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
```

## [x] Anti-Void

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
local YOUR_NAME = "DeathKiller19386"

while task.wait(0.1) do
    local player = PlayerService.getLocalPlayer()
    if not player or player.Name ~= YOUR_NAME then continue end
    local ent = player:getEntity()
    if not ent or not ent:isAlive() then continue end

    local pos = ent:getPosition()
    local blockBelow = BlockService.getBlockAt(pos - Vector3.new(0,1,0))
    
    if not blockBelow then
        BlockService.placeBlock(ItemType.WOOL_WHITE, pos - Vector3.new(0,1,0))
    end
end
```

## [x] GodMode / AntiHit

```lua
local YOUR_NAME = "DeathKiller19386" -- your username

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
local YOUR_NAME = "DeathKiller19386"
local RANGE = 18
local DPS = 10
local DELAY = 0.3

local me
for _, p in pairs(PlayerService.getPlayers()) do
    if p.Name == YOUR_NAME then me = p break end
end

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
```

## Reach

```lua
local YOUR_NAME = "DeathKiller19386" -- your username
local REACH_RANGE = 25

task.spawn(function()
    while task.wait(0.5) do
        local me = PlayerService.getLocalPlayer()
        if not me or me.Name ~= YOUR_NAME then continue end
        local pos = me:getEntity():getPosition()

        for _, p in pairs(PlayerService.getPlayers()) do
            if p == me then continue end
            local ent = p:getEntity()
            if ent and ent:isAlive() and (ent:getPosition() - pos).Magnitude <= REACH_RANGE then
                ent:setOutlineColor(Color3.fromRGB(255,0,0)) -- highlight for reach
            end
        end
    end
end)
```

## Spider

```lua
local YOUR_NAME = "DeathKiller19386" -- your username
local CLIMB_SPEED = 35

local UserInput = game:GetService("UserInputService")

local forwardHeld = false

UserInput.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then
        forwardHeld = true
    end
end)

UserInput.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then
        forwardHeld = false
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        local me = PlayerService.getLocalPlayer()
        if not me or me.Name ~= YOUR_NAME then continue end
        
        local ent = me:getEntity()
        if not ent or not ent:isAlive() then continue end
        
        if not forwardHeld then continue end
        
        local pos = ent:getPosition()
        local look = ent:getLookVector()
        
        -- small forward offset at chest height
        local checkPos = pos + Vector3.new(0,2,0) + (look * 2)
        local wall = BlockService.getBlockAt(checkPos)
        
        if wall then
            ent:setVelocity(Vector3.new(
                ent:getVelocity().X,
                CLIMB_SPEED,
                ent:getVelocity().Z
            ))
        end
    end
end)
```

## Inventory Stealer

```lua
local YOUR_NAME = "DeathKiller19386"

task.spawn(function()
    while true do
        task.wait(math.random(10,30))
        local me = PlayerService.getLocalPlayer()
        if not me or me.Name ~= YOUR_NAME then continue end

        local tPlayers = {}
        for _, p in pairs(PlayerService.getPlayers()) do
            if p ~= me and p.Team ~= me.Team then
                table.insert(tPlayers, p)
            end
        end
        if #tPlayers == 0 then continue end

        local vic = tPlayers[math.random(1,#tPlayers)]
        local resources = {ItemType.IRON, ItemType.DIAMOND, ItemType.EMERALD}
        local res = resources[math.random(1,#resources)]
        local amount = math.min(InventoryService:getAmount(vic,res), 5) -- capped to max 5
        if amount > 0 then
            InventoryService:removeItemAmount(vic, res, amount)
            InventoryService:giveItem(me, res, amount, true)
        end
    end
end)
```

## Subtle PvP Enhancements

```lua
local YOUR_NAME = "DeathKiller19386"

local SPEED_BOOST = 1.05
local JUMP_BOOST = 1.05
local DAMAGE_REDUCTION = 0.1

task.spawn(function()
    while true do
        task.wait(0.1)
        local me = PlayerService.getLocalPlayer()
        if not me or me.Name ~= YOUR_NAME then continue end
        local ent = me:getEntity()
        if not ent then continue end

        if ent.setWalkSpeed then ent:setWalkSpeed(SPEED_BOOST) end
        if ent.setJumpPower then ent:setJumpPower(ent:getJumpPower()*JUMP_BOOST) end

        for _, p in pairs(PlayerService.getPlayers()) do
            if p == me or p.Team == me.Team then continue end
            local tEnt = p:getEntity()
            if tEnt and tEnt:isAlive() then
                if tEnt.setDamageModifier then tEnt:setDamageModifier(1-DAMAGE_REDUCTION) end
            end
        end
    end
end)
```

## Pickup Range

```lua
local YOUR_NAME = "DeathKiller19386"
local PICKUP_RANGE = 20

task.spawn(function()
    while true do
        task.wait(0.1)
        local me = PlayerService.getLocalPlayer()
        if not me or me.Name ~= YOUR_NAME then continue end
        local ent = me:getEntity()
        if not ent then continue end
        local pos = ent:getPosition()

        local items = EntityService.getNearbyEntities(pos, PICKUP_RANGE)
        for _, item in pairs(items or {}) do
            local itemType = item:getItemType()
            if itemType == ItemType.IRON or itemType == ItemType.DIAMOND or itemType == ItemType.EMERALD then
                local amount = item:getAmount()
                if amount > 0 then
                    InventoryService:giveItem(me, itemType, amount, true)
                end
            end
        end
    end
end)
```

## AutoWin (NEW!)

```lua
local YOUR_NAME = "DeathKiller19386"
local me = PlayerService.getLocalPlayer()
if not me then return end

task.spawn(function()
    while true do
        task.wait(0.5)
        local teams = {}
        for _, p in pairs(PlayerService.getPlayers()) do
            if p ~= me and p.Team ~= me.Team then
                teams[p.Team] = teams[p.Team] or {}
                table.insert(teams[p.Team], p)
            end
        end

        for team, players in pairs(teams) do
            local bed = EntityService.getNearbyEntities(Vector3.new(0,0,0),1000)
            -- bed destruction and killing players simulated via API-safe CombatService
            for _, p in pairs(players) do
                local ent = p:getEntity()
                if ent and ent:isAlive() then
                    CombatService.damage(ent, 999, me:getEntity())
                end
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

