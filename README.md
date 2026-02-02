# Custom Match Scripts

These scripts work ONLY in the Roblox Bedwars Custom Game Script tab. It CANNOT get you banned, and it is NOT going to work outside of Roblox Bedwars

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
    local bestDist = 999999
    
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
                    ent:setVelocity(Vector3.zero)
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
local names = {"DeathKiller19386"}  -- your username

while task.wait() do
    for _, player in PlayerService.getPlayers() do
        local ent = player:getEntity()
        if not ent then continue end
        
        local isProtected = false
        for _, name in names do
            if player.name == name then
                isProtected = true
                break
            end
        end
        if isProtected then continue end
        
        local pos = ent:getPosition() - Vector3.new(0,5,0)
        if BlockService.getBlockAt(pos) then
            BlockService.destroyBlock(pos)
        end
        BlockService.placeBlock(ItemType.WOOL_WHITE, pos)
    end
end
```

## GodMode / AntiHit

```lua
local YOUR_NAME = "DeathKiller19386"  -- your username

Events.EntityDamage(function(event)
    local p = event.entity:getPlayer()
    if p and p.name == YOUR_NAME then
        event.cancelled = true
        event.damage = 0
    end
end)
```

## KillAura

```lua
local YOUR_NAME = "DeathKiller19386"  -- your username
local RANGE = 18
local DPS = 10
local DELAY = 0.3

local me
for _, p in PlayerService.getPlayers() do
    if p.name == YOUR_NAME then me = p break end
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
# Reach

```lua
local YOUR_NAME = "DeathKiller19386"

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
local CLIMB_SPEED = 50
local YOUR_NAME = "DeathKiller19386"  -- your username

local me
for _, p in PlayerService.getPlayers() do
    if p.name == YOUR_NAME then me = p break end
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
