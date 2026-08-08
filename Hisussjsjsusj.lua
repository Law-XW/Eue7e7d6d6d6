if not game:IsLoaded() then
    game.Loaded:Wait()
end

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local TweenService = cloneref(game:GetService("TweenService"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local Workspace = cloneref(game:GetService("Workspace"))

local LocalPlayer = Players.LocalPlayer

local WindUI
do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)

    if ok then
        WindUI = result
    else
        if RunService:IsStudio() then
            WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

local LogoAsset = "rbxassetid://106237632702124"

local Window = WindUI:CreateWindow({
    Title = "StreetLife by Xeioa",
    Folder = "streetlife",
    Icon = LogoAsset,
    NewElements = true,
    HideSearchBar = true,
    OpenButton = {
        Title = "Open UI",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"),
            Color3.fromHex("#e7ff2f")
        ),
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Default",
    },
})

local FarmTab = Window:Tab({
    Title = "Farm",
    Icon = LogoAsset,
})

local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "user",
})

local MopSection = FarmTab:Section({
    Title = "Mop Farm",
})

MopSection:Section({
    Title = "Be near the job",
    TextSize = 14,
    TextTransparency = 0.4,
})

local BoxSection = FarmTab:Section({
    Title = "Box Farm",
})

BoxSection:Section({
    Title = "Be near the job",
    TextSize = 14,
    TextTransparency = 0.4,
})

local SettingSection = FarmTab:Section({
    Title = "Settings",
})

local PlayerSection = PlayerTab:Section({
    Title = "Local Player",
})

local AtmSection = PlayerTab:Section({
    Title = "ATM",
})

local MopFarmEnabled = false
local MopFarmMethod = "Legit"

local BoxFarmEnabled = false
local BoxFarmMethod = "Legit"

local TweenSpeed = 25

local staminaEnabled = false
local staminaConn = nil

local AtmAmount = 1000
local AutoDepositEnabled = false
local AutoWithdrawEnabled = false

local grid = 2.5
local radius = 1.2
local heightOffset = 2.5
local maxStep = 3.5
local maxDrop = 15

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.RespectCanCollide = true

local vf = Workspace:FindFirstChild("PathVisual") or Instance.new("Folder")
vf.Name = "PathVisual"
vf.Parent = Workspace

local groundCache = {}

local function getKey(v)
    return string.format("%d_%d_%d", math.floor(v.X / grid + 0.5), math.floor(v.Y / grid + 0.5), math.floor(v.Z / grid + 0.5))
end

local function bezier(t, p0, p1, p2)
    return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

local function push(h, k, f)
    table.insert(h, k)
    local i = #h
    while i > 1 and f[h[i]] < f[h[math.floor(i / 2)]] do
        local p = math.floor(i / 2)
        h[i], h[p] = h[p], h[i]
        i = p
    end
end

local function pop(h, f)
    local r = h[1]
    h[1] = h[#h]
    table.remove(h)
    local i, s = 1, #h
    while true do
        local m, l, ri = i, 2 * i, 2 * i + 1
        if l <= s and f[h[l]] < f[h[m]] then m = l end
        if ri <= s and f[h[ri]] < f[h[m]] then m = ri end
        if m == i then break end
        h[i], h[m] = h[m], h[i]
        i = m
    end
    return r
end

local dirs = {
    {Vector3.new(grid, 0, 0), grid, 1, 0},
    {Vector3.new(-grid, 0, 0), grid, -1, 0},
    {Vector3.new(0, 0, grid), grid, 0, 1},
    {Vector3.new(0, 0, -grid), grid, 0, -1},
    {Vector3.new(grid, 0, grid), grid * 1.414, 1, 1},
    {Vector3.new(-grid, 0, -grid), grid * 1.414, -1, -1},
    {Vector3.new(grid, 0, -grid), grid * 1.414, 1, -1},
    {Vector3.new(-grid, 0, grid), grid * 1.414, -1, 1}
}

local function checkClearance(p1, p2)
    local vec = p2 - p1
    local dist = vec.Magnitude
    if dist < 0.1 then return true end
    
    local dir = vec.Unit
    local h1 = Workspace:Spherecast(p1 + Vector3.new(0, 1.0, 0), radius, dir * dist, params)
    local h2 = Workspace:Spherecast(p1 + Vector3.new(0, 2.5, 0), radius, dir * dist, params)
    
    return not h1 and not h2
end

local function getGround(pos)
    local k = getKey(pos)
    if groundCache[k] ~= nil then
        return groundCache[k] or nil
    end
    
    local ray = Workspace:Raycast(pos + Vector3.new(0, maxStep + 2, 0), Vector3.new(0, -(maxStep + maxDrop + 5), 0), params)
    if ray then
        local res = ray.Position + Vector3.new(0, heightOffset, 0)
        groundCache[k] = res
        return res
    end
    groundCache[k] = false
    return nil
end

local function findPath(start, dest)
    if not LocalPlayer.Character then return {} end
    params.FilterDescendantsInstances = {LocalPlayer.Character, vf}
    groundCache = {}
    
    local op, cl, cf, g, f, h = {}, {}, {}, {}, {}, {}
    local sk = getKey(start)
    
    op[sk] = start
    g[sk] = 0
    f[sk] = (start - dest).Magnitude
    push(h, sk, f)
    
    local runs = 0
    local bestKey = sk
    local bestDist = f[sk]
    
    while #h > 0 do
        runs = runs + 1
        if runs > 2000 then break end
        
        local ck = pop(h, f)
        if cl[ck] then continue end
        local cp = op[ck]
        
        local dDist = (cp - dest).Magnitude
        if dDist < bestDist then
            bestDist = dDist
            bestKey = ck
        end
        
        if dDist <= grid * 1.5 then
            bestKey = ck
            break
        end
        
        cl[ck] = true
        
        for _, d in ipairs(dirs) do
            local raw = cp + d[1]
            local np = getGround(raw)
            
            if np then
                local nk = getKey(np)
                if not cl[nk] then
                    local yd = np.Y - cp.Y
                    if yd <= maxStep and yd >= -maxDrop then
                        local valid = true
                        
                        if d[3] ~= 0 and d[4] ~= 0 then
                            local c1 = getGround(cp + Vector3.new(d[3] * grid, 0, 0))
                            local c2 = getGround(cp + Vector3.new(0, 0, d[4] * grid))
                            
                            if not c1 or not c2 then
                                valid = false
                            else
                                if not checkClearance(cp, c1) or not checkClearance(cp, c2) then
                                    valid = false
                                end
                            end
                        end
                        
                        if valid and checkClearance(cp, np) then
                            local tg = g[ck] + d[2] + math.abs(yd) * 1.5
                            if tg < (g[nk] or math.huge) then
                                cf[nk] = {k = ck, p = cp}
                                g[nk] = tg
                                f[nk] = tg + (np - dest).Magnitude
                                op[nk] = np
                                push(h, nk, f)
                            end
                        end
                    end
                end
            end
        end
    end
    
    local p, c = {}, bestKey
    while cf[c] do
        table.insert(p, 1, cf[c].p)
        c = cf[c].k
    end
    if #p > 0 then
        table.insert(p, dest)
    end
    return p
end

local function smooth(p)
    if #p <= 2 then return p end
    local s = {p[1]}
    local i = 1
    
    while i < #p do
        local n = #p
        while n > i + 1 do
            local clear = true
            local steps = math.ceil((p[n] - p[i]).Magnitude / grid)
            
            for step = 1, steps do
                local current = p[i]:Lerp(p[n], step / steps)
                local prev = p[i]:Lerp(p[n], (step - 1) / steps)
                if not checkClearance(prev, current) then
                    clear = false
                    break
                end
            end
            
            if clear then break end
            n = n - 1
        end
        table.insert(s, p[n])
        i = n
    end
    return s
end

local partPool = {}

local function clearVisuals()
    for _, part in ipairs(partPool) do
        part.Parent = nil
    end
    vf:ClearAllChildren()
end

local function draw(p)
    clearVisuals()
    local poolIndex = 1
    local function getPooledPart()
        local part = partPool[poolIndex]
        if not part then
            part = Instance.new("Part")
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            partPool[poolIndex] = part
        end
        poolIndex = poolIndex + 1
        return part
    end

    for i = 1, #p - 1 do
        local p1, p2 = p[i], p[i+1]
        local d = (p2 - p1).Magnitude
        
        local l = getPooledPart()
        l.Size = Vector3.new(0.25, 0.25, d)
        l.CFrame = CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -d/2)
        l.Material = Enum.Material.ForceField
        l.Color = Color3.fromRGB(50, 255, 50)
        l.Parent = vf
        
        local dot = getPooledPart()
        dot.Size = Vector3.new(0.6, 0.6, 0.6)
        dot.Position = p2
        dot.Shape = Enum.PartType.Ball
        dot.Material = Enum.Material.Neon
        dot.Color = Color3.fromRGB(255, 255, 255)
        dot.Parent = vf
    end
end

local function ResetHumanoidRotation()
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChild("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if Humanoid and RootPart then
        Humanoid.AutoRotate = true
        RootPart.RotVelocity = Vector3.new(0, 0, 0)
        RootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

local function GetValidTargetPos(targetPos)
    local ground = getGround(targetPos)
    if ground then
        return ground
    end
    return targetPos
end

local function NavigateTo(targetPos, method, checkEnabled)
    local Character = LocalPlayer.Character
    if not Character then return end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not RootPart or not Humanoid then return end

    ResetHumanoidRotation()
    
    if (RootPart.Position - targetPos).Magnitude < 3.5 then
        clearVisuals()
        return
    end

    local attempts = 0
    while checkEnabled() and attempts < 3 do
        attempts = attempts + 1
        local startPos = RootPart.Position
        if (startPos - targetPos).Magnitude < 3.5 then break end

        local validTarget = GetValidTargetPos(targetPos)
        local rawPath = findPath(startPos, validTarget)
        local path = smooth(rawPath)

        if #path <= 1 then
            path = {startPos, validTarget}
        end

        draw(path)
        local blocked = false

        for i = 2, #path do
            if not checkEnabled() or not RootPart.Parent then break end
            
            local np = path[i]
            local sp = RootPart.Position
            local dist = (np - sp).Magnitude
            
            if dist < 0.2 then continue end

            local obstacleHit = Workspace:Spherecast(sp + Vector3.new(0, 1.0, 0), radius, (np - sp), params)
            if obstacleHit then
                blocked = true
                break
            end

            if method == "Fast" then
                local currentSpeed = math.max(TweenSpeed, 1)
                local duration = dist / currentSpeed
                local lookDir = (Vector3.new(np.X, sp.Y, np.Z) - sp)
                lookDir = lookDir.Magnitude > 0.001 and lookDir.Unit or RootPart.CFrame.LookVector
                
                local elapsed = 0
                local yd = np.Y - sp.Y
                
                while elapsed < duration do
                    if not checkEnabled() then break end
                    local dt = RunService.Heartbeat:Wait()
                    elapsed = math.min(elapsed + dt, duration)
                    local frac = elapsed / duration
                    local nextPos = (yd > 0.5 and yd <= maxStep) and bezier(frac, sp, sp:Lerp(np, 0.5) + Vector3.new(0, yd + 2.5, 0), np) or sp:Lerp(np, frac)
                    
                    local midHit = Workspace:Spherecast(RootPart.Position, radius, (nextPos - RootPart.Position), params)
                    if midHit then
                        blocked = true
                        break
                    end
                    
                    RootPart.CFrame = CFrame.lookAt(nextPos, nextPos + lookDir)
                end

                if blocked then break end
            else
                Humanoid:MoveTo(np)
                local reached = false
                local conn = Humanoid.MoveToFinished:Connect(function()
                    reached = true
                end)
                
                local timeout = 0
                while not reached and checkEnabled() and timeout < 3 do
                    task.wait(0.05)
                    timeout = timeout + 0.05
                    
                    local moveHit = Workspace:Spherecast(RootPart.Position, radius, (np - RootPart.Position), params)
                    if moveHit then
                        blocked = true
                        if conn then conn:Disconnect() end
                        break
                    end

                    if (RootPart.Position - np).Magnitude < 3 then
                        reached = true
                        break
                    end
                end
                if conn then conn:Disconnect() end
                if blocked then break end
            end
        end

        if not blocked or (RootPart.Position - targetPos).Magnitude < 3.5 then
            break
        end
        task.wait(0.1)
    end

    clearVisuals()
    ResetHumanoidRotation()
end

local function withdrawMoney(amount)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local atm = remotes and remotes:FindFirstChild("ATM")
    if atm then
        atm:FireServer("Withdraw", amount)
    end
end

local function depositMoney(amount)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local atm = remotes and remotes:FindFirstChild("ATM")
    if atm then
        atm:FireServer("Deposit", amount)
    end
end

local staminaRef = nil
PlayerSection:Toggle({
    Title = "Inf Stamina",
    Value = false,
    Callback = function(Value)
        staminaEnabled = Value
        if staminaEnabled then
            if staminaConn then staminaConn:Disconnect() end
            staminaConn = RunService.Heartbeat:Connect(function()
                if not staminaRef or not staminaRef.Parent then
                    if LocalPlayer:FindFirstChild("Data") then
                        staminaRef = LocalPlayer.Data:FindFirstChild("Stamina")
                    end
                end
                if staminaRef then
                    staminaRef.Value = 9999999
                end
            end)
        else
            if staminaConn then
                staminaConn:Disconnect()
                staminaConn = nil
            end
            staminaRef = nil
        end
    end,
})

AtmSection:Slider({
    Title = "Amount",
    Step = 100,
    Value = {
        Min = 100,
        Max = 500000,
        Default = 1000,
    },
    Callback = function(Value)
        AtmAmount = Value
    end,
})

AtmSection:Button({
    Title = "Withdraw",
    Callback = function()
        withdrawMoney(AtmAmount)
    end,
})

AtmSection:Button({
    Title = "Deposit",
    Callback = function()
        depositMoney(AtmAmount)
    end,
})

AtmSection:Toggle({
    Title = "Auto Withdraw",
    Value = false,
    Callback = function(Value)
        AutoWithdrawEnabled = Value
    end,
})

AtmSection:Toggle({
    Title = "Auto Deposit",
    Value = false,
    Callback = function(Value)
        AutoDepositEnabled = Value
    end,
})

SettingSection:Slider({
    Title = "Tween Speed",
    Step = 0.1,
    Value = {
        Min = 1,
        Max = 50,
        Default = 25,
    },
    Callback = function(Value)
        TweenSpeed = Value
    end,
})

task.spawn(function()
    while true do
        if AutoWithdrawEnabled then
            withdrawMoney(AtmAmount)
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if AutoDepositEnabled then
            depositMoney(AtmAmount)
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if MopFarmEnabled then
            local cleanFolder = Workspace:FindFirstChild("Map") 
                and Workspace.Map:FindFirstChild("Jobs") 
                and Workspace.Map.Jobs:FindFirstChild("CleanNPC") 
                and Workspace.Map.Jobs.CleanNPC:FindFirstChild("Clean")

            if cleanFolder then
                local items = cleanFolder:GetChildren()
                for _, item in ipairs(items) do
                    if not MopFarmEnabled then break end

                    if item:IsA("BasePart") or item:IsA("Model") then
                        local prompt = item:FindFirstChildOfClass("ProximityPrompt") or item:FindFirstChild("ProximityPrompt", true)
                        local targetPos = item:IsA("BasePart") and item.Position or item:GetPivot().Position

                        NavigateTo(targetPos, MopFarmMethod, function() return MopFarmEnabled end)

                        if MopFarmEnabled and prompt and item.Parent then
                            task.wait(0.1)
                            fireproximityprompt(prompt)
                            task.wait(0.3)
                        end
                    end
                end
            end
            task.wait(0.1)
        else
            clearVisuals()
            task.wait(0.2)
        end
    end
end)

task.spawn(function()
    local takePos = Vector3.new(205.29685974121094, 52.38993453979492, 339.0135803222656)
    local deliverPos = Vector3.new(157.49252319335938, 53.04217529296875, 261.873779296875)

    while true do
        if BoxFarmEnabled then
            NavigateTo(takePos, BoxFarmMethod, function() return BoxFarmEnabled end)

            if BoxFarmEnabled then
                local takePrompt = Workspace:FindFirstChild("Map")
                    and Workspace.Map:FindFirstChild("Jobs")
                    and Workspace.Map.Jobs:FindFirstChild("BoxJob")
                    and Workspace.Map.Jobs.BoxJob:FindFirstChild("Take")
                    and Workspace.Map.Jobs.BoxJob.Take:FindFirstChild("Take")
                    and Workspace.Map.Jobs.BoxJob.Take.Take:FindFirstChild("Interact")

                if takePrompt then
                    task.wait(0.1)
                    fireproximityprompt(takePrompt)
                    task.wait(0.3)
                end
            end

            if BoxFarmEnabled then
                NavigateTo(deliverPos, BoxFarmMethod, function() return BoxFarmEnabled end)

                if BoxFarmEnabled then
                    local deliverPrompt = Workspace:FindFirstChild("Map")
                        and Workspace.Map:FindFirstChild("Jobs")
                        and Workspace.Map.Jobs:FindFirstChild("BoxJob")
                        and Workspace.Map.Jobs.BoxJob:FindFirstChild("Deliver")
                        and Workspace.Map.Jobs.BoxJob.Deliver:FindFirstChild("Deliver")
                        and Workspace.Map.Jobs.BoxJob.Deliver.Deliver:FindFirstChild("Interact")

                    if deliverPrompt then
                        task.wait(0.1)
                        fireproximityprompt(deliverPrompt)
                        task.wait(0.3)
                    end
                end
            end
            task.wait(0.1)
        else
            clearVisuals()
            task.wait(0.2)
        end
    end
end)

MopSection:Toggle({
    Title = "Enable",
    Value = false,
    Callback = function(Value)
        MopFarmEnabled = Value
        if not Value then clearVisuals() end
    end,
})

MopSection:Dropdown({
    Title = "Method",
    Values = { "Legit", "Fast" },
    Value = "Legit",
    Callback = function(Value)
        MopFarmMethod = type(Value) == "table" and Value[1] or Value
    end,
})

BoxSection:Toggle({
    Title = "Enable",
    Value = false,
    Callback = function(Value)
        BoxFarmEnabled = Value
        if not Value then clearVisuals() end
    end,
})

BoxSection:Dropdown({
    Title = "Method",
    Values = { "Legit", "Fast" },
    Value = "Legit",
    Callback = function(Value)
        BoxFarmMethod = type(Value) == "table" and Value[1] or Value
    end,
})
