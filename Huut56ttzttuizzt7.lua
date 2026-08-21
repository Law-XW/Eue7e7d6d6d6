local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Teams = game:GetService("Teams")
local SoundService = game:GetService("SoundService")

local LP = Players.LocalPlayer

local ModernV2 = loadstring(game:HttpGet("https://robloxui.vercel.app/"))()

ModernV2:AddTheme({
    Name        = "Pink Black",
    Accent      = Color3.fromRGB(255, 105, 180),
    Background  = Color3.fromRGB(10, 10, 12),
    Surface     = Color3.fromRGB(20, 20, 24),
    Outline     = Color3.fromRGB(40, 40, 45),
    Text        = Color3.fromRGB(255, 255, 255),
    Placeholder = Color3.fromRGB(140, 140, 155),
    Button      = Color3.fromRGB(255, 105, 180),
    Icon        = Color3.fromRGB(255, 255, 255),
})

local Loading = ModernV2:AddLoading({
    Title      = "Emergency Hamburg",
    Icon       = "lucide:rocket",
    TotalSteps = 2,
})

Loading:SetMessage("Loading Script...")
Loading:SetDescription("Loading Script...")
task.wait(0.5)

Loading:SetCurrentStep(1)
Loading:ShowSidebarPage(true)
Loading.Sidebar:AddLabel("User: " .. LP.Name)
Loading.Sidebar:AddLabel("Credits: Xeioa")
task.wait(0.5)

local Window = ModernV2:Window({
    Title   = "Emergency Hamburg",
    Content = "By Xeioa",
    Logo    = "rbxassetid://113064253322398",
    Color   = Color3.fromRGB(255, 105, 180),
    Config  = {
        ConfigFolder       = "xeioa",
        AutoSaveFile       = "Default",
        AutoSave           = true,
        AutoLoad           = true,
        Overwrite          = true,
        Encrypted          = false,
        ShowAutoSaveToggle = false,
        SaveWindowState   = false,
    },
})

local Watermark = Window:Watermark({
    Name       = "Emergency Hamburg",
    Logo       = Window.Logo,
    Enabled    = true,
    Draggable  = true,
    Position   = UDim2.new(0.5, 0, 0, 6),
    Desc       = "Credits: Xeioa | {TIME} | {FPS} FPS | {MS} ms",
})

local MenuIcon = ModernV2:CreateMenuIcon({
    Image       = "grid",
    Size        = 48,
    IconColor   = Color3.fromRGB(255, 255, 255),
    BGColor     = Color3.fromRGB(20, 22, 27),
    StrokeColor = ModernV2.AccentColor,
    StrokeThick = 1.5,
    Draggable   = true,
})

Window:AttachMenuIcon(MenuIcon)

local antiDamageEnabled = false
local speedBoostEnabled = false
local playerFlyEnabled = false
local spinbotEnabled = false
local speedBoostValue = 1
local playerFlySpeedValue = 50
local spinbotSpeedValue = 50
local isTeleporting = false
local RadarFarmEnabled = false
local AutoTaserEnabled = false
local AutoTaserWallCheck = false

local SilentAimEnabled = false
local SilentAimKeybind = Enum.KeyCode.T
local AutoShootEnabled = false
local SAaimPart = "Head"
local SAFovSize = 150
local SAShowFOV = false
local SAFovColor = Color3.fromRGB(255, 105, 180)
local SAHighlightTarget = false
local SASnapline = false
local SAWallCheck = false
local SATeamCheck = false
local SAIgnoreWanted = true
local SAIgnoreUntouchable = false
local SAMaxDistance = 15000

local TriggerbotEnabled = false
local TriggerbotKeybind = Enum.KeyCode.Y
local TriggerbotWallCheck = false
local TriggerbotTeamCheck = false
local TriggerbotIgnoreUntouchable = false
local TriggerbotIgnoreWanted = true
local TriggerbotAimPart = "All"
local TriggerbotMaxDistance = 15000

local AimbotEnabled = false
local AimbotActive = false
local AimbotMobileActive = false
local AimbotKeybind = Enum.KeyCode.E
local AimbotAimPart = "Head"
local AimbotSmoothness = 18
local AimbotPrediction = false
local AimbotPredictionValue = 0.165
local AimbotSticky = false
local AimbotWallCheck = false
local AimbotTeamCheck = false
local AimbotIgnoreUntouchable = false
local AimbotIgnoreWanted = true
local AimbotMaxDistance = 15000
local currentAimbotTarget = nil

local BulletTracersEnabled = false
local TracerColor = Color3.fromRGB(255, 105, 180)

local customHitsoundEnabled = false
local selectedHitsound = "Neverlose"

local hitsoundMap = {
    ["Neverlose"] = "rbxassetid://139452805868562",
    ["Hurt"]      = "rbxassetid://140721035016341",
    ["Beamhit"]   = "rbxassetid://103134129110384",
    ["Slash Hit"] = "rbxassetid://101804080457161"
}

local function applyHitsound()
    if not customHitsoundEnabled then return end
    local hitSound = SoundService:FindFirstChild("CrosshairHitmarker")
    if not hitSound then
        hitSound = ReplicatedStorage:FindFirstChild("CrosshairHitmarker")
    end
    if not hitSound then
        hitSound = Instance.new("Sound")
        hitSound.Name = "CrosshairHitmarker"
        hitSound.Parent = SoundService
    end
    if hitsoundMap[selectedHitsound] then
        hitSound.SoundId = hitsoundMap[selectedHitsound]
    end
end

local customShootSoundEnabled = false
local selectedShootSound = "Neverlose"
local defaultShootSounds = {}

local shootSoundMap = {
    ["Neverlose"]    = "rbxassetid://139452805868562",
    ["Minecraft"]    = "rbxassetid://135478009117226",
    ["Click"]        = "rbxassetid://88442833509532",
    ["Shotgun"]      = "rbxassetid://132711300701696",
    ["Better Click"] = "rbxassetid://139403951941162"
}

local function applyShootSound()
    pcall(function()
        local code = ReplicatedStorage:WaitForChild("Code", 2)
        if not code then return end
        local assets = code:WaitForChild("assets", 2)
        if not assets then return end
        local soundsModule = assets:WaitForChild("sounds", 2)
        if not soundsModule then return end

        local rbxRequire = (getrenv and getrenv().require) or require
        local sounds = rbxRequire(soundsModule)
        if not sounds or not sounds.default then return end
        local default = sounds.default

        local shootSounds = {"PistolShoot","RifleShoot","ShotgunShoot","SniperShoot","DesertEagleShoot1","DesertEagleShoot2","DesertEagleShoot3","DesertEagleShoot4"}

        if customShootSoundEnabled and shootSoundMap[selectedShootSound] then
            local newId = shootSoundMap[selectedShootSound]
            for _, name in ipairs(shootSounds) do
                if default[name] then
                    if not defaultShootSounds[name] then
                        defaultShootSounds[name] = default[name].SoundId
                    end
                    default[name].SoundId = newId
                end
            end
        else
            for name, origId in pairs(defaultShootSounds) do
                if default[name] then
                    default[name].SoundId = origId
                end
            end
        end
    end)
end

local components = nil
local AIM_CameraController = nil

task.spawn(function()
    pcall(function()
        local code = ReplicatedStorage:WaitForChild("Code", 5)
        if not code then return end
        local rbxts = code:WaitForChild("rbxts_include", 5)
        if not rbxts then return end
        local node = rbxts:WaitForChild("node_modules", 5)
        if not node then return end
        local fwModule = node:WaitForChild("@flamework", 5)
        if not fwModule then return end
        local core = fwModule:WaitForChild("core", 5)
        if not core then return end
        local out = core:WaitForChild("out", 5)
        if not out then return end
        local flamework = require(out).Flamework
        components = flamework.resolveDependency("$c:components@Components")
        pcall(function()
            AIM_CameraController = flamework.resolveDependency("$c:controllers/cameraController@CameraController")
        end)
    end)
end)

local function shootFirearm()
    if not components then return end
    local char = LP.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool:HasTag("Firearm Tool") then
            local firearm = components:getComponent(tool, "Mgq")
            if firearm and not firearm.reloading and (tool:GetAttribute("MagCurrentSize") or 1) > 0 then
                firearm:shoot()
                task.wait(tool:GetAttribute("ShootDelay") or 0.1)
            end
        end
    end
end

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "FOVScreenGui"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.Parent = LP:WaitForChild("PlayerGui")

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, SAFovSize * 2, 0, SAFovSize * 2)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = fovGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = SAFovColor
fovStroke.Thickness = 1.5
fovStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
fovStroke.Parent = fovCircle

local snapline = Instance.new("Frame")
snapline.Name = "Snapline"
snapline.AnchorPoint = Vector2.new(0.5, 0.5)
snapline.BackgroundColor3 = SAFovColor
snapline.BorderSizePixel = 0
snapline.Visible = false
snapline.Parent = fovGui

local targetHighlight = Instance.new("Highlight")
targetHighlight.Name = "SATargetHighlight"
targetHighlight.FillColor = SAFovColor
targetHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
targetHighlight.FillTransparency = 0.5
targetHighlight.OutlineTransparency = 0

local aimbotMobileGui = Instance.new("ScreenGui")
aimbotMobileGui.Name = "AimbotMobileGui"
aimbotMobileGui.ResetOnSpawn = false
aimbotMobileGui.Enabled = false
aimbotMobileGui.Parent = LP:WaitForChild("PlayerGui")

local aimbotBtn = Instance.new("TextButton")
aimbotBtn.Name = "AimbotButton"
aimbotBtn.Size = UDim2.new(0, 75, 0, 75)
aimbotBtn.Position = UDim2.new(0.8, 0, 0.55, 0)
aimbotBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
aimbotBtn.BorderColor3 = Color3.fromRGB(255, 105, 180)
aimbotBtn.BorderSizePixel = 2
aimbotBtn.Text = "AIM: OFF"
aimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotBtn.TextSize = 13
aimbotBtn.Font = Enum.Font.GothamBold
aimbotBtn.Parent = aimbotMobileGui

local aimbotBtnCorner = Instance.new("UICorner")
aimbotBtnCorner.CornerRadius = UDim.new(0, 12)
aimbotBtnCorner.Parent = aimbotBtn

local aimDragging = false
local aimDragStart, aimStartPos

aimbotBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        aimDragging = true
        aimDragStart = input.Position
        aimStartPos = aimbotBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                aimDragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if aimDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - aimDragStart
        aimbotBtn.Position = UDim2.new(aimStartPos.X.Scale, aimStartPos.X.Offset + delta.X, aimStartPos.Y.Scale, aimStartPos.Y.Offset + delta.Y)
    end
end)

aimbotBtn.MouseButton1Click:Connect(function()
    AimbotMobileActive = not AimbotMobileActive
    aimbotBtn.Text = AimbotMobileActive and "AIM: ON" or "AIM: OFF"
    aimbotBtn.TextColor3 = AimbotMobileActive and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(255, 255, 255)
end)

local silentAimMobileGui = Instance.new("ScreenGui")
silentAimMobileGui.Name = "SilentAimMobileGui"
silentAimMobileGui.ResetOnSpawn = false
silentAimMobileGui.Enabled = false
silentAimMobileGui.Parent = LP:WaitForChild("PlayerGui")

local silentAimBtn = Instance.new("TextButton")
silentAimBtn.Name = "SilentAimButton"
silentAimBtn.Size = UDim2.new(0, 75, 0, 75)
silentAimBtn.Position = UDim2.new(0.8, 0, 0.7, 0)
silentAimBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
silentAimBtn.BorderColor3 = Color3.fromRGB(255, 105, 180)
silentAimBtn.BorderSizePixel = 2
silentAimBtn.Text = "SILENT: OFF"
silentAimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
silentAimBtn.TextSize = 13
silentAimBtn.Font = Enum.Font.GothamBold
silentAimBtn.Parent = silentAimMobileGui

local silentAimBtnCorner = Instance.new("UICorner")
silentAimBtnCorner.CornerRadius = UDim.new(0, 12)
silentAimBtnCorner.Parent = silentAimBtn

local saDragging = false
local saDragStart, saStartPos

silentAimBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        saDragging = true
        saDragStart = input.Position
        saStartPos = silentAimBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                saDragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if saDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - saDragStart
        silentAimBtn.Position = UDim2.new(saStartPos.X.Scale, saStartPos.X.Offset + delta.X, saStartPos.Y.Scale, saStartPos.Y.Offset + delta.Y)
    end
end)

silentAimBtn.MouseButton1Click:Connect(function()
    SilentAimEnabled = not SilentAimEnabled
    silentAimBtn.Text = SilentAimEnabled and "SILENT: ON" or "SILENT: OFF"
    silentAimBtn.TextColor3 = SilentAimEnabled and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(255, 255, 255)
end)

local triggerbotMobileGui = Instance.new("ScreenGui")
triggerbotMobileGui.Name = "TriggerbotMobileGui"
triggerbotMobileGui.ResetOnSpawn = false
triggerbotMobileGui.Enabled = false
triggerbotMobileGui.Parent = LP:WaitForChild("PlayerGui")

local triggerbotBtn = Instance.new("TextButton")
triggerbotBtn.Name = "TriggerbotButton"
triggerbotBtn.Size = UDim2.new(0, 75, 0, 75)
triggerbotBtn.Position = UDim2.new(0.8, 0, 0.85, 0)
triggerbotBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
triggerbotBtn.BorderColor3 = Color3.fromRGB(255, 105, 180)
triggerbotBtn.BorderSizePixel = 2
triggerbotBtn.Text = "TRIG: OFF"
triggerbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
triggerbotBtn.TextSize = 13
triggerbotBtn.Font = Enum.Font.GothamBold
triggerbotBtn.Parent = triggerbotMobileGui

local triggerbotBtnCorner = Instance.new("UICorner")
triggerbotBtnCorner.CornerRadius = UDim.new(0, 12)
triggerbotBtnCorner.Parent = triggerbotBtn

local tbDragging = false
local tbDragStart, tbStartPos

triggerbotBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tbDragging = true
        tbDragStart = input.Position
        tbStartPos = triggerbotBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                tbDragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if tbDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - tbDragStart
        triggerbotBtn.Position = UDim2.new(tbStartPos.X.Scale, tbStartPos.X.Offset + delta.X, tbStartPos.Y.Scale, tbStartPos.Y.Offset + delta.Y)
    end
end)

triggerbotBtn.MouseButton1Click:Connect(function()
    TriggerbotEnabled = not TriggerbotEnabled
    triggerbotBtn.Text = TriggerbotEnabled and "TRIG: ON" or "TRIG: OFF"
    triggerbotBtn.TextColor3 = TriggerbotEnabled and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(255, 255, 255)
end)

local function isWantedPlayer(plr)
    if not plr or not plr.Character then return false end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, n in ipairs({"IsWanted", "Wanted", "WantedLevel", "WantedStars"}) do
            local v = hrp:GetAttribute(n)
            if v and v ~= false and v ~= 0 then return true end
        end
    end
    for _, n in ipairs({"IsWanted", "Wanted", "WantedLevel", "WantedStars"}) do
        local o = plr.Character:FindFirstChild(n)
        if o and o.Value and o.Value ~= false and o.Value ~= 0 then return true end
    end
    return false
end

local function validateTarget(plr, partName, wallCheck, teamCheck, ignoreUntouchable, ignoreWanted)
    if not plr or plr == LP or not plr.Character then return false end
    local part = plr.Character:FindFirstChild(partName) or plr.Character:FindFirstChild("HumanoidRootPart")
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if not part or not hum or hum.Health <= 0 then return false end

    local localTeam = LP.Team
    local isPolice = localTeam and (localTeam.Name == "Police" or localTeam.Name == "Polizei")

    if teamCheck and localTeam and plr.Team and localTeam == plr.Team then
        return false
    end

    if ignoreUntouchable and plr.Team then
        local tn = plr.Team.Name
        if tn == "Prisoner" or tn == "TruckCompany" or tn == "HARS" or tn == "FireDepartment" or tn == "BusCompany" then
            return false
        end
    end

    if not ignoreWanted then
        local targetIsWanted = isWantedPlayer(plr)
        local targetIsPolice = plr.Team and (plr.Team.Name == "Police" or plr.Team.Name == "Polizei")
        if isPolice then
            if not targetIsWanted then return false end
        else
            if not targetIsWanted and not targetIsPolice then return false end
        end
    end

    if wallCheck then
        local cam = Workspace.CurrentCamera
        if not cam then return false end
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local bl = {LP.Character, plr.Character}
        local vehiclesFolder = Workspace:FindFirstChild("Vehicles")
        if vehiclesFolder then table.insert(bl, vehiclesFolder) end
        rayParams.FilterDescendantsInstances = bl
        local r = Workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, rayParams)
        if r then return false end
    end

    return true
end

local function getClosestSATarget()
    local cam = Workspace.CurrentCamera
    if not cam then return nil, nil end
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local bestDist, bestChar, bestScreen = SAFovSize, nil, nil
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return nil, nil end

    for _, plr in pairs(Players:GetPlayers()) do
        if validateTarget(plr, SAaimPart, SAWallCheck, SATeamCheck, SAIgnoreUntouchable, SAIgnoreWanted) then
            local part = plr.Character:FindFirstChild(SAaimPart) or plr.Character:FindFirstChild("HumanoidRootPart")
            if (part.Position - cam.CFrame.Position).Magnitude <= SAMaxDistance then
                local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                if onScreen and sp.Z > 0 then
                    local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if sd <= bestDist then
                        bestDist = sd
                        bestChar = plr.Character
                        bestScreen = Vector2.new(sp.X, sp.Y)
                    end
                end
            end
        end
    end
    return bestChar, bestScreen
end

local function getClosestAimbotTarget()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local bestDist, bestPlr = SAFovSize, nil

    for _, plr in pairs(Players:GetPlayers()) do
        if validateTarget(plr, AimbotAimPart, AimbotWallCheck, AimbotTeamCheck, AimbotIgnoreUntouchable, AimbotIgnoreWanted) then
            local part = plr.Character:FindFirstChild(AimbotAimPart) or plr.Character:FindFirstChild("HumanoidRootPart")
            if (part.Position - cam.CFrame.Position).Magnitude <= AimbotMaxDistance then
                local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                if onScreen and sp.Z > 0 then
                    local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if sd <= bestDist then
                        bestDist = sd
                        bestPlr = plr
                    end
                end
            end
        end
    end
    return bestPlr
end

local function getTriggerbotTarget()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local mousePos = UIS:GetMouseLocation()
    local ray = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local filter = {LP.Character}
    local vehiclesFolder = Workspace:FindFirstChild("Vehicles")
    if vehiclesFolder then table.insert(filter, vehiclesFolder) end
    rayParams.FilterDescendantsInstances = filter

    local result = Workspace:Raycast(ray.Origin, ray.Direction * TriggerbotMaxDistance, rayParams)
    if result and result.Instance then
        if TriggerbotAimPart ~= "All" and result.Instance.Name ~= TriggerbotAimPart then return nil end
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        if model then
            local plr = Players:GetPlayerFromCharacter(model)
            if plr and validateTarget(plr, "HumanoidRootPart", TriggerbotWallCheck, TriggerbotTeamCheck, TriggerbotIgnoreUntouchable, TriggerbotIgnoreWanted) then
                return model
            end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if AutoShootEnabled and SilentAimEnabled then
            local targetChar, _ = getClosestSATarget()
            if targetChar then
                shootFirearm()
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        if TriggerbotEnabled then
            local target = getTriggerbotTarget()
            if target then
                shootFirearm()
            end
        end
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == AimbotKeybind or input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotActive = true
    elseif input.KeyCode == SilentAimKeybind then
        SilentAimEnabled = not SilentAimEnabled
        silentAimBtn.Text = SilentAimEnabled and "SILENT: ON" or "SILENT: OFF"
        silentAimBtn.TextColor3 = SilentAimEnabled and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(255, 255, 255)
    elseif input.KeyCode == TriggerbotKeybind then
        TriggerbotEnabled = not TriggerbotEnabled
        triggerbotBtn.Text = TriggerbotEnabled and "TRIG: ON" or "TRIG: OFF"
        triggerbotBtn.TextColor3 = TriggerbotEnabled and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(255, 255, 255)
    end
end)

UIS.InputEnded:Connect(function(input, gp)
    if input.KeyCode == AimbotKeybind or input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotActive = false
        currentAimbotTarget = nil
    end
end)

RunService.RenderStepped:Connect(function(dt)
    local cam = Workspace.CurrentCamera
    if cam then
        local vp = cam.ViewportSize
        fovCircle.Position = UDim2.new(0, vp.X / 2, 0, vp.Y / 2)
    end
    fovCircle.Visible = SAShowFOV
    fovCircle.Size = UDim2.new(0, SAFovSize * 2, 0, SAFovSize * 2)
    fovStroke.Color = SAFovColor
    snapline.BackgroundColor3 = SAFovColor
    targetHighlight.FillColor = SAFovColor

    if SilentAimEnabled then
        local targetChar, targetScreen = getClosestSATarget()

        if SAHighlightTarget and targetChar then
            targetHighlight.Adornee = targetChar
            targetHighlight.Parent = targetChar
            targetHighlight.Enabled = true
        else
            targetHighlight.Enabled = false
            targetHighlight.Parent = nil
        end

        if SASnapline and targetScreen and cam then
            local vp = cam.ViewportSize
            local center = Vector2.new(vp.X / 2, vp.Y / 2)
            local diff = targetScreen - center
            local dist = diff.Magnitude
            local angle = math.deg(math.atan2(diff.Y, diff.X))

            snapline.Size = UDim2.new(0, dist, 0, 2)
            snapline.Position = UDim2.new(0, center.X + diff.X / 2, 0, center.Y + diff.Y / 2)
            snapline.Rotation = angle
            snapline.Visible = true
        else
            snapline.Visible = false
        end
    else
        targetHighlight.Enabled = false
        targetHighlight.Parent = nil
        snapline.Visible = false
    end

    if AimbotEnabled and (AimbotActive or AimbotMobileActive) and cam then
        local targetPlr = nil
        if AimbotSticky and currentAimbotTarget and validateTarget(currentAimbotTarget, AimbotAimPart, AimbotWallCheck, AimbotTeamCheck, AimbotIgnoreUntouchable, AimbotIgnoreWanted) then
            targetPlr = currentAimbotTarget
        else
            targetPlr = getClosestAimbotTarget()
            currentAimbotTarget = targetPlr
        end

        if targetPlr and targetPlr.Character then
            local part = targetPlr.Character:FindFirstChild(AimbotAimPart) or targetPlr.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local targetPos = part.Position
                if AimbotPrediction and part:IsA("BasePart") then
                    targetPos = targetPos + (part.AssemblyLinearVelocity * AimbotPredictionValue)
                end

                local lookAt = CFrame.new(cam.CFrame.Position, targetPos)
                local alpha = math.clamp((AimbotSmoothness / 100) * math.max(dt * 60, 0.25), 0.01, 1)

                pcall(function()
                    if AIM_CameraController and typeof(AIM_CameraController.MimicRotation) == "function" then
                        AIM_CameraController:MimicRotation(cam.CFrame:Lerp(lookAt, alpha))
                    else
                        cam.CFrame = cam.CFrame:Lerp(lookAt, alpha)
                    end
                end)
            end
        end
    else
        currentAimbotTarget = nil
    end
end)

local function createBulletTracer(origin, direction)
    if not BulletTracersEnabled then return end
    if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" or direction.Magnitude == 0 then return end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local filter = {LP.Character}
    local vehiclesFolder = Workspace:FindFirstChild("Vehicles")
    if vehiclesFolder then table.insert(filter, vehiclesFolder) end
    raycastParams.FilterDescendantsInstances = filter

    local rayResult = Workspace:Raycast(origin, direction * 1000, raycastParams)
    local targetPos = rayResult and rayResult.Position or (origin + direction * 1000)

    local part0 = Instance.new("Part")
    part0.Size = Vector3.new(0.05, 0.05, 0.05)
    part0.Transparency = 1
    part0.CanCollide = false
    part0.Anchored = true
    part0.CFrame = CFrame.new(origin)
    part0.Parent = Workspace

    local part1 = Instance.new("Part")
    part1.Size = Vector3.new(0.05, 0.05, 0.05)
    part1.Transparency = 1
    part1.CanCollide = false
    part1.Anchored = true
    part1.CFrame = CFrame.new(targetPos)
    part1.Parent = Workspace

    local att0 = Instance.new("Attachment", part0)
    local att1 = Instance.new("Attachment", part1)

    local beam = Instance.new("Beam")
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Color = ColorSequence.new(TracerColor)
    beam.FaceCamera = true
    beam.Width0 = 0.15
    beam.Width1 = 0.15
    beam.Parent = part0

    task.spawn(function()
        local transVal = Instance.new("NumberValue")
        transVal.Value = 0
        local conn = transVal.Changed:Connect(function(v)
            if beam and beam.Parent then
                beam.Transparency = NumberSequence.new(v)
            end
        end)

        local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tweenBeam = TweenService:Create(beam, tweenInfo, {Width0 = 0, Width1 = 0})
        local tweenTrans = TweenService:Create(transVal, tweenInfo, {Value = 1})
        
        tweenBeam:Play()
        tweenTrans:Play()
        tweenBeam.Completed:Wait()

        conn:Disconnect()
        transVal:Destroy()
        part0:Destroy()
        part1:Destroy()
    end)
end

task.spawn(function()
    pcall(function()
        local ps = LP:WaitForChild("PlayerScripts", 10)
        if not ps then return end
        local code = ps:WaitForChild("Code", 10)
        if not code then return end
        local ctrl = code:WaitForChild("controllers", 10)
        if not ctrl then return end
        local proj = ctrl:WaitForChild("projectile", 10)
        if not proj then return end
        local mod = proj:WaitForChild("projectileController", 10)
        if not mod then return end

        local rbxRequire = (getrenv and getrenv().require) or require
        local ProjectileControllerModule = rbxRequire(mod)
        local ProjectileController = ProjectileControllerModule.ProjectileController
        local originalFire = ProjectileController.fireProjectile

        ProjectileController.fireProjectile = function(self, p53, p54, p55)
            if SilentAimEnabled then
                local target, _ = getClosestSATarget()
                if target then
                    local part = target:FindFirstChild(SAaimPart) or target:FindFirstChild("HumanoidRootPart")
                    if part and typeof(p54) == "Vector3" then
                        local dir = (part.Position - p54)
                        if dir.Magnitude > 0 then
                            p55 = dir.Unit
                        end
                    end
                end
            end
            if typeof(p54) == "Vector3" and typeof(p55) == "Vector3" then
                createBulletTracer(p54, p55)
            end
            return originalFire(self, p53, p54, p55)
        end
    end)
end)

RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if spinbotEnabled then
        hum.AutoRotate = false
        hrp.AssemblyAngularVelocity = Vector3.new(0, spinbotSpeedValue, 0)
    else
        hum.AutoRotate = true
    end

    if antiDamageEnabled or isTeleporting then
        if hum:GetState() == Enum.HumanoidStateType.Freefall or hrp.AssemblyLinearVelocity.Y < 0 then
            if hrp.AssemblyLinearVelocity.Y < -8 then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -8, hrp.AssemblyLinearVelocity.Z)
            end
        end
    end

    if playerFlyEnabled then
        hum.PlatformStand = true
        local cam = Workspace.CurrentCamera
        if cam then
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local camCF = cam.CFrame
                local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
                local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)

                if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
                if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end

                local fwd = moveDir:Dot(flatLook)
                local side = moveDir:Dot(flatRight)

                local finalDir = (camCF.LookVector * fwd) + (camCF.RightVector * side)
                if finalDir.Magnitude > 0 then
                    finalDir = finalDir.Unit
                end
                hrp.AssemblyLinearVelocity = finalDir * playerFlySpeedValue
            else
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    else
        if hum.PlatformStand then
            hum.PlatformStand = false
        end
        if speedBoostEnabled then
            if hum.MoveDirection.Magnitude > 0 then
                local speed = 16 + (speedBoostValue * 5)
                local targetVel = hum.MoveDirection * speed
                hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, hrp.AssemblyLinearVelocity.Y, targetVel.Z)
            end
        end
    end
end)

local locations = {
    ["Osso"] = Vector3.new(11.667860984802246, 5.177574634552002, -826.5599365234375),
    ["Jewelery"] = Vector3.new(-419.3553466796875, 5.17756986618042, 3509.17529296875),
    ["Bank"] = Vector3.new(-1129.0791015625, 5.427597999572754, 3217.9736328125),
    ["Gas N Go"] = Vector3.new(-1459.1614990234375, 5.566028118133545, 3839.43115234375),
    ["Fire Department"] = Vector3.new(-845.8880615234375, 5.563575744628906, 3940.01220703125),
    ["Erwin Club"] = Vector3.new(-1874.04296875, 5.566071510314941, 3068.038818359375),
    ["Police"] = Vector3.new(-1662.85205078125, 5.554450035095215, 2718.907958984375),
    ["Prison"] = Vector3.new(-603.4866943359375, 5.560446739196777, 2818.731201171875),
    ["Ares"] = Vector3.new(-950.607421875, 5.562959671020508, 1465.7235107421875),
    ["Hospital"] = Vector3.new(-317.9139404296875, 5.562045574188232, 1100.9007568359375),
    ["ToolShop"] = Vector3.new(-686.195068359375, 5.554235935211182, 705.15576171875),
    ["DealerShip"] = Vector3.new(-1414.05517578125, 5.556241035461426, 918.715576171875),
    ["Tuning Garage"] = Vector3.new(-1341.414306640625, 5.561634540557861, 134.84201049804688),
    ["Adac"] = Vector3.new(-218.83712768554688, 5.323729038238525, 336.9349670410156),
    ["BusStation"] = Vector3.new(-1663.249755859375, 5.567526817321777, -1286.4893798828125),
    ["FarmShop"] = Vector3.new(-829.0420532226562, 5.290912628173828, -1156.48779296875),
    ["ClothStore"] = Vector3.new(477.54656982421875, 5.539468765258789, -1539.2904052734375)
}

local locationKeys = {
    "Osso", "Jewelery", "Bank", "Gas N Go", "Fire Department", 
    "Erwin Club", "Police", "Prison", "Ares", "Hospital", 
    "ToolShop", "DealerShip", "Tuning Garage", "Adac", 
    "BusStation", "FarmShop", "ClothStore"
}

local selectedLocation = "Osso"

local function executeVehicleTeleport(targetVec)
    isTeleporting = true
    local char = LP.Character
    if not char then 
        isTeleporting = false
        return 
    end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then 
        isTeleporting = false
        return 
    end

    local vehiclesFolder = Workspace:FindFirstChild("Vehicles")
    local vehicle = vehiclesFolder and vehiclesFolder:FindFirstChild(LP.Name)

    if not vehicle then
        Window:Notify({Title = "Teleport", Content = "Vehicle not found!", Duration = 3})
        isTeleporting = false
        return
    end

    local seat = vehicle:FindFirstChildWhichIsA("Seat", true) or vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
    if not seat then
        Window:Notify({Title = "Teleport", Content = "Seat not found!", Duration = 3})
        isTeleporting = false
        return
    end

    vehicle:PivotTo(hrp.CFrame)
    for _, part in ipairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then
            part.AssemblyLinearVelocity = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
        end
    end

    task.wait(0.1)
    hrp.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
    task.wait(0.1)
    seat:Sit(hum)
    task.wait(0.1)
    seat:Sit(hum)
    task.wait(0.2)

    local targetCFrame = CFrame.new(targetVec)
    local airOffset = Vector3.new(0, 500, 0)

    local function teleportVehicle(cf)
        vehicle:PivotTo(cf)
        for _, part in ipairs(vehicle:GetDescendants()) do
            if part:IsA("BasePart") then
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end

    local currentPos = vehicle:GetPivot().Position
    teleportVehicle(CFrame.new(currentPos + airOffset))
    task.wait(0.1)
    teleportVehicle(CFrame.new(targetCFrame.Position + airOffset))
    task.wait(0.1)
    teleportVehicle(targetCFrame)

    task.wait(0.2)

    local vehPos = vehicle:GetPivot().Position
    local isPlayerInAir = hrp.Position.Y > (vehPos.Y + 10) or hum:GetState() == Enum.HumanoidStateType.Freefall or hum:GetState() == Enum.HumanoidStateType.FallingDown

    if not hum.SeatPart or isPlayerInAir then
        hrp.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.1)
        seat:Sit(hum)
        task.wait(0.2)
        seat:Sit(hum)
    end

    local newDist = (vehicle:GetPivot().Position - hrp.Position).Magnitude
    if newDist > 25 then
        vehicle:PivotTo(hrp.CFrame)
        Window:Notify({Title = "Teleport", Content = "Teleport Failed!", Duration = 3})
        isTeleporting = false
        return
    end

    Window:Notify({Title = "Teleport", Content = "Teleport successful!", Duration = 3})
    task.delay(3, function()
        isTeleporting = false
    end)
end

local function getTargetBodyParts()
    local vehicles = Workspace:FindFirstChild("Vehicles")
    if not vehicles then return {} end
    local vehicle = vehicles:FindFirstChild(LP.Name)
    if not vehicle then return {} end

    local bodyFolder = vehicle:FindFirstChild("Body")
    if bodyFolder then
        local mainBodyMesh = bodyFolder:FindFirstChild("Body")
        if mainBodyMesh and mainBodyMesh:IsA("BasePart") then
            return {mainBodyMesh}
        end

        local parts = {}
        for _, obj in ipairs(bodyFolder:GetDescendants()) do
            if obj:IsA("BasePart") then
                table.insert(parts, obj)
            end
        end
        if #parts > 0 then return parts end
    end

    local parts = {}
    for _, obj in ipairs(vehicle:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    return parts
end

local ghostModeEnabled = false
local ghostModeColor = Color3.fromRGB(255, 105, 180)
local rainbowEnabled = false
local currentVehicleColor = Color3.fromRGB(255, 255, 255)
local selectedMaterialEnum = Enum.Material.SmoothPlastic
local currentTransparency = 0

local customPlateEnabled = false
local customPlateText = ""

local materialMap = {
    ["SmoothPlastic"] = Enum.Material.SmoothPlastic,
    ["Neon"]          = Enum.Material.Neon,
    ["ForceField"]    = Enum.Material.ForceField,
    ["Glass"]         = Enum.Material.Glass,
    ["Metal"]         = Enum.Material.Metal,
    ["DiamondPlate"]  = Enum.Material.DiamondPlate,
    ["Foil"]          = Enum.Material.Foil
}

local function applyVehicleCustomization()
    local parts = getTargetBodyParts()
    if #parts == 0 then return end

    for _, part in ipairs(parts) do
        part.Transparency = currentTransparency

        if ghostModeEnabled then
            part.Material = Enum.Material.ForceField
            part.Color = ghostModeColor
        else
            part.Material = selectedMaterialEnum
            if not rainbowEnabled then
                part.Color = currentVehicleColor
            end
        end
    end
end

local function applyLicensePlateText(text)
    local vehicles = Workspace:FindFirstChild("Vehicles")
    local vehicle = vehicles and vehicles:FindFirstChild(LP.Name)
    if not vehicle then return end
    local body = vehicle:FindFirstChild("Body") or vehicle
    local plates = body:FindFirstChild("LicensePlates")
    if not plates then return end
    for _, side in ipairs({"Front", "Back"}) do
        local s2 = plates:FindFirstChild(side)
        if s2 and s2:FindFirstChild("Gui") and s2.Gui:FindFirstChild("TextLabel") then
            s2.Gui.TextLabel.Text = text
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.03)
        if rainbowEnabled and not ghostModeEnabled then
            local hue = (tick() % 3) / 3
            local rainbowColor = Color3.fromHSV(hue, 1, 1)
            for _, part in ipairs(getTargetBodyParts()) do
                part.Color = rainbowColor
            end
        end
        if customPlateEnabled then
            applyLicensePlateText(customPlateText)
        end
    end
end)

local flyEnabled = false
local flySpeed = 150
local lockBind = false
local lastFlySeat = nil
local flyKeybind = Enum.KeyCode.X

local mobileGui = Instance.new("ScreenGui")
mobileGui.Name = "MobileBind"
mobileGui.ResetOnSpawn = false
mobileGui.Enabled = false
mobileGui.Parent = LP:WaitForChild("PlayerGui")

local flyBtn = Instance.new("TextButton")
flyBtn.Name = "FlyButton"
flyBtn.Size = UDim2.new(0, 75, 0, 75)
flyBtn.Position = UDim2.new(0.8, 0, 0.4, 0)
flyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
flyBtn.BorderColor3 = Color3.fromRGB(255, 105, 180)
flyBtn.BorderSizePixel = 2
flyBtn.Text = "FLY: OFF"
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.TextSize = 13
flyBtn.Font = Enum.Font.GothamBold
flyBtn.Parent = mobileGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 12)
btnCorner.Parent = flyBtn

local dragging = false
local dragStart, startPos

flyBtn.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not lockBind then
        dragging = true
        dragStart = input.Position
        startPos = flyBtn.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and not lockBind and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        flyBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function toggleFlyState(state)
    if state ~= nil then
        flyEnabled = state
    else
        flyEnabled = not flyEnabled
    end
    flyBtn.Text = flyEnabled and "FLY: ON" or "FLY: OFF"
    flyBtn.TextColor3 = flyEnabled and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(255, 255, 255)
end

flyBtn.MouseButton1Click:Connect(function()
    toggleFlyState()
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == flyKeybind then
        toggleFlyState()
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if not flyEnabled then return end

    local char = LP.Character
    if not char then
        flyEnabled = false
        lastFlySeat = nil
        return
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        flyEnabled = false
        return
    end

    local seat = hum.SeatPart
    if not seat then
        if lastFlySeat and lastFlySeat.Parent then
            seat = lastFlySeat
            seat:Sit(hum)
        else
            flyEnabled = false
            lastFlySeat = nil
            return
        end
    end

    lastFlySeat = seat
    local vehicle = seat:FindFirstAncestorOfClass("Model") or seat.Parent
    local root = seat
    if vehicle and vehicle:IsA("Model") and vehicle.PrimaryPart then
        root = vehicle.PrimaryPart
    end

    local cam = Workspace.CurrentCamera
    if not cam then return end

    local moveDir = Vector3.zero

    if hum.MoveDirection.Magnitude > 0 then
        local camCF = cam.CFrame
        local dotForward = hum.MoveDirection:Dot(camCF.LookVector)
        local dotRight = hum.MoveDirection:Dot(camCF.RightVector)
        moveDir = (camCF.LookVector * dotForward) + (camCF.RightVector * dotRight)
    else
        local forward = 0
        local side = 0
        if UIS:IsKeyDown(Enum.KeyCode.W) then forward = forward + 1 end
        if UIS:IsKeyDown(Enum.KeyCode.S) then forward = forward - 1 end
        if UIS:IsKeyDown(Enum.KeyCode.A) then side = side - 1 end
        if UIS:IsKeyDown(Enum.KeyCode.D) then side = side + 1 end

        if forward ~= 0 or side ~= 0 then
            local camCF = cam.CFrame
            moveDir = (camCF.LookVector * forward) + (camCF.RightVector * side)
        end
    end

    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
    end

    local targetPos = root.Position + moveDir * flySpeed * dt
    local targetCF = CFrame.new(targetPos, targetPos + cam.CFrame.LookVector)

    if vehicle and vehicle:IsA("Model") then
        vehicle:PivotTo(targetCF)
    else
        root.CFrame = targetCF
    end

    for _, part in ipairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then
            part.AssemblyLinearVelocity = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
        end
    end
end)

local infStaminaEnabled = false

task.spawn(function()
    pcall(function()
        local ps = LP:WaitForChild("PlayerScripts", 5)
        if not ps then return end
        local code = ps:WaitForChild("Code", 5)
        if not code then return end
        local ctrl = code:WaitForChild("controllers", 5)
        if not ctrl then return end
        local charCtrl = ctrl:WaitForChild("character", 5)
        if not charCtrl then return end
        local module = charCtrl:WaitForChild("characterStaminaController", 5)
        if not module then return end

        local rbxRequire = (getrenv and getrenv().require) or require
        local staminaMod = rbxRequire(module)
        if not staminaMod then return end
        local stamina = staminaMod.CharacterStaminaController
        if not stamina or typeof(stamina.useStamina) ~= "function" then return end
        if not hookfunction then return end

        local old
        old = hookfunction(stamina.useStamina, function(...)
            if infStaminaEnabled then
                return true
            end
            return old(...)
        end)
    end)
end)

local espEnabled = false
local espWanted = false
local espName = true
local espHealth = true
local espDistance = true
local espWeapon = false
local espTeam = false
local espTeamColor = false
local espTeamCheck = false
local espMaxDistance = 15000

local function getOrCreateESP(p)
    if p == LP or not p.Character then return nil end
    local head = p.Character:FindFirstChild("Head")
    if not head then return nil end

    local bgui = head:FindFirstChild("PlayerESPGui")
    if not bgui then
        bgui = Instance.new("BillboardGui")
        bgui.Name = "PlayerESPGui"
        bgui.Adornee = head
        bgui.Size = UDim2.new(0, 200, 0, 100)
        bgui.StudsOffset = Vector3.new(0, 3, 0)
        bgui.AlwaysOnTop = true
        bgui.Enabled = false
        bgui.Parent = head

        local txt = Instance.new("TextLabel")
        txt.Name = "ESPLabel"
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.GothamBlack
        txt.TextSize = 13
        txt.TextWrapped = true
        txt.RichText = true
        txt.Parent = bgui
    end
    return bgui
end

RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")

            if hum and hrp and hum.Health > 0 then
                local bgui = getOrCreateESP(p)
                if bgui then
                    local myChar = LP.Character
                    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

                    local isVisible = espEnabled
                    if isVisible and espTeamCheck and p.Team and LP.Team and p.Team == LP.Team then
                        isVisible = false
                    end

                    local dist = 0
                    if myHRP then
                        dist = (myHRP.Position - hrp.Position).Magnitude
                        if dist > espMaxDistance then
                            isVisible = false
                        end
                    end

                    bgui.Enabled = isVisible

                    if isVisible then
                        local txtLabel = bgui:FindFirstChild("ESPLabel")
                        if txtLabel then
                            local isWanted = isWantedPlayer(p)

                            if espWanted and isWanted then
                                txtLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                            elseif espTeamColor and p.Team then
                                txtLabel.TextColor3 = p.TeamColor.Color
                            else
                                txtLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            end

                            local lines = {}
                            if espName then
                                table.insert(lines, p.DisplayName or p.Name)
                            end
                            if espWanted and isWanted then
                                table.insert(lines, '<font color="rgb(255,255,0)">[WANTED]</font>')
                            end
                            if espTeam then
                                table.insert(lines, "Team: " .. (p.Team and p.Team.Name or "None"))
                            end
                            if espHealth then
                                table.insert(lines, '<font color="rgb(0,255,0)">HP: ' .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. '</font>')
                            end
                            if espWeapon then
                                local tool = char:FindFirstChildOfClass("Tool")
                                table.insert(lines, "Weapon: " .. (tool and tool.Name or "Hands"))
                            end
                            if espDistance then
                                table.insert(lines, "[" .. math.floor(dist) .. "m]")
                            end
                            txtLabel.Text = table.concat(lines, "\n")
                        end
                    end
                end
            end
        end
    end
end)

local TeleportTab = Window:AddTab({ Name = "Teleport", Icon = "map-pin" })

local TeleportSection = TeleportTab:AddSection({
    Name           = "TELEPORT SYSTEM",
    Position       = "Left",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

TeleportSection:AddDropdown({
    Name     = "Select Location",
    Values   = locationKeys,
    Default  = "Osso",
    Callback = function(value)
        selectedLocation = value
    end,
})

TeleportSection:AddButton({
    Name     = "Teleport Vehicle",
    Callback = function()
        local targetPos = locations[selectedLocation]
        if targetPos then
            executeVehicleTeleport(targetPos)
        end
    end,
})

local PlayerTab = Window:AddTab({ Name = "Player", Icon = "user" })

local PlayerSection = PlayerTab:AddSection({
    Name           = "PLAYER SETTINGS",
    Position       = "Left",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

PlayerSection:AddToggle({
    Name    = "Infinite Stamina",
    Default = false,
    Callback = function(state)
        infStaminaEnabled = state
    end,
})

PlayerSection:AddToggle({
    Name    = "Anti Damage",
    Default = false,
    Callback = function(state)
        antiDamageEnabled = state
    end,
})

PlayerSection:AddToggle({
    Name    = "Speed Boost",
    Default = false,
    Callback = function(state)
        speedBoostEnabled = state
    end,
})

PlayerSection:AddSlider({
    Name     = "Speed Multiplier",
    Min      = 1,
    Max      = 5,
    Default  = 1,
    Precision = 0,
    Callback = function(v)
        speedBoostValue = v
    end,
})

PlayerSection:AddToggle({
    Name    = "Player Fly",
    Default = false,
    Callback = function(state)
        playerFlyEnabled = state
    end,
})

PlayerSection:AddSlider({
    Name     = "Player Fly Speed",
    Min      = 10,
    Max      = 200,
    Default  = 50,
    Precision = 0,
    Callback = function(v)
        playerFlySpeedValue = v
    end,
})

PlayerSection:AddToggle({
    Name    = "Spinbot",
    Default = false,
    Callback = function(state)
        spinbotEnabled = state
    end,
})

PlayerSection:AddSlider({
    Name     = "Spinbot Speed",
    Min      = 10,
    Max      = 200,
    Default  = 50,
    Precision = 0,
    Callback = function(v)
        spinbotSpeedValue = v
    end,
})

local CombatTab = Window:AddTab({ Name = "Combat", Icon = "swords" })

local CameraAimbotSection = CombatTab:AddSection({
    Name           = "CAMERA AIMBOT",
    Position       = "Left",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

CameraAimbotSection:AddToggle({
    Name     = "Enable Aimbot",
    Default  = false,
    Callback = function(state)
        AimbotEnabled = state
    end,
})

CameraAimbotSection:AddKeybind({
    Name     = "Aimbot Keybind",
    Default  = Enum.KeyCode.E,
    Callback = function(key)
        AimbotKeybind = key
    end,
})

CameraAimbotSection:AddToggle({
    Name     = "Mobile Aimbot Button",
    Default  = false,
    Callback = function(state)
        aimbotMobileGui.Enabled = state
    end,
})

CameraAimbotSection:AddDropdown({
    Name     = "Aimbot Aim Part",
    Values   = {"Head", "HumanoidRootPart"},
    Default  = "Head",
    Callback = function(val)
        AimbotAimPart = val
    end,
})

CameraAimbotSection:AddSlider({
    Name     = "Smoothness",
    Min      = 1,
    Max      = 100,
    Default  = 18,
    Precision = 0,
    Callback = function(v)
        AimbotSmoothness = v
    end,
})

CameraAimbotSection:AddToggle({
    Name     = "Prediction",
    Default  = false,
    Callback = function(state)
        AimbotPrediction = state
    end,
})

CameraAimbotSection:AddSlider({
    Name     = "Prediction Velocity",
    Min      = 0,
    Max      = 1,
    Default  = 0.165,
    Precision = 3,
    Callback = function(v)
        AimbotPredictionValue = v
    end,
})

CameraAimbotSection:AddSlider({
    Name     = "Max Distance",
    Min      = 10,
    Max      = 15000,
    Default  = 15000,
    Precision = 0,
    Callback = function(v)
        AimbotMaxDistance = v
    end,
})

CameraAimbotSection:AddToggle({
    Name     = "Sticky Aim",
    Default  = false,
    Callback = function(state)
        AimbotSticky = state
    end,
})

CameraAimbotSection:AddToggle({
    Name     = "Aimbot Wall Check",
    Default  = false,
    Callback = function(state)
        AimbotWallCheck = state
    end,
})

CameraAimbotSection:AddToggle({
    Name     = "Aimbot Team Check",
    Default  = false,
    Callback = function(state)
        AimbotTeamCheck = state
    end,
})

CameraAimbotSection:AddToggle({
    Name     = "Aimbot Ignore Untouchable",
    Default  = false,
    Callback = function(state)
        AimbotIgnoreUntouchable = state
    end,
})

CameraAimbotSection:AddToggle({
    Name     = "Aimbot Ignore Wanted Filter",
    Default  = true,
    Callback = function(state)
        AimbotIgnoreWanted = state
    end,
})

local SilentAimSection = CombatTab:AddSection({
    Name           = "SILENT AIM",
    Position       = "Left",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

SilentAimSection:AddToggle({
    Name     = "Silent Aim",
    Default  = false,
    Callback = function(state)
        SilentAimEnabled = state
    end,
})

SilentAimSection:AddKeybind({
    Name     = "Silent Aim Keybind",
    Default  = Enum.KeyCode.T,
    Callback = function(key)
        SilentAimKeybind = key
    end,
})

SilentAimSection:AddToggle({
    Name     = "Mobile Silent Aim Button",
    Default  = false,
    Callback = function(state)
        silentAimMobileGui.Enabled = state
    end,
})

SilentAimSection:AddToggle({
    Name     = "Auto Shoot",
    Default  = false,
    Callback = function(state)
        AutoShootEnabled = state
    end,
})

SilentAimSection:AddDropdown({
    Name     = "Aim Part",
    Values   = {"Head", "HumanoidRootPart"},
    Default  = "Head",
    Callback = function(val)
        SAaimPart = val
    end,
})

SilentAimSection:AddSlider({
    Name     = "Max Distance",
    Min      = 10,
    Max      = 15000,
    Default  = 15000,
    Precision = 0,
    Callback = function(v)
        SAMaxDistance = v
    end,
})

SilentAimSection:AddToggle({
    Name     = "Wall Check",
    Default  = false,
    Callback = function(state)
        SAWallCheck = state
    end,
})

SilentAimSection:AddToggle({
    Name     = "Team Check",
    Default  = false,
    Callback = function(state)
        SATeamCheck = state
    end,
})

SilentAimSection:AddToggle({
    Name     = "Ignore Untouchable Teams",
    Default  = false,
    Callback = function(state)
        SAIgnoreUntouchable = state
    end,
})

SilentAimSection:AddToggle({
    Name     = "Ignore Wanted Filter",
    Default  = true,
    Callback = function(state)
        SAIgnoreWanted = state
    end,
})

local TriggerbotSection = CombatTab:AddSection({
    Name           = "TRIGGERBOT",
    Position       = "Right",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

TriggerbotSection:AddToggle({
    Name     = "Triggerbot",
    Default  = false,
    Callback = function(state)
        TriggerbotEnabled = state
    end,
})

TriggerbotSection:AddKeybind({
    Name     = "Triggerbot Keybind",
    Default  = Enum.KeyCode.Y,
    Callback = function(key)
        TriggerbotKeybind = key
    end,
})

TriggerbotSection:AddToggle({
    Name     = "Mobile Triggerbot Button",
    Default  = false,
    Callback = function(state)
        triggerbotMobileGui.Enabled = state
    end,
})

TriggerbotSection:AddDropdown({
    Name     = "Aim Part",
    Values   = {"Head", "HumanoidRootPart", "All"},
    Default  = "All",
    Callback = function(val)
        TriggerbotAimPart = val
    end,
})

TriggerbotSection:AddSlider({
    Name     = "Max Distance",
    Min      = 10,
    Max      = 15000,
    Default  = 15000,
    Precision = 0,
    Callback = function(v)
        TriggerbotMaxDistance = v
    end,
})

TriggerbotSection:AddToggle({
    Name     = "Triggerbot Wall Check",
    Default  = false,
    Callback = function(state)
        TriggerbotWallCheck = state
    end,
})

TriggerbotSection:AddToggle({
    Name     = "Triggerbot Team Check",
    Default  = false,
    Callback = function(state)
        TriggerbotTeamCheck = state
    end,
})

TriggerbotSection:AddToggle({
    Name     = "Triggerbot Ignore Untouchable",
    Default  = false,
    Callback = function(state)
        TriggerbotIgnoreUntouchable = state
    end,
})

TriggerbotSection:AddToggle({
    Name     = "Triggerbot Ignore Wanted Filter",
    Default  = true,
    Callback = function(state)
        TriggerbotIgnoreWanted = state
    end,
})

local FOVSection = CombatTab:AddSection({
    Name           = "FOV SETTINGS",
    Position       = "Right",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

FOVSection:AddToggle({
    Name     = "Show FOV",
    Default  = false,
    Callback = function(state)
        SAShowFOV = state
    end,
})

FOVSection:AddSlider({
    Name     = "FOV Size",
    Min      = 30,
    Max      = 800,
    Default  = 150,
    Precision = 0,
    Callback = function(val)
        SAFovSize = val
    end,
})

FOVSection:AddColorPicker({
    Name     = "FOV Color",
    Default  = Color3.fromRGB(255, 105, 180),
    Callback = function(color)
        SAFovColor = color
    end,
})

FOVSection:AddToggle({
    Name     = "Highlight Target",
    Default  = false,
    Callback = function(state)
        SAHighlightTarget = state
    end,
})

FOVSection:AddToggle({
    Name     = "Snapline",
    Default  = false,
    Callback = function(state)
        SASnapline = state
    end,
})

local GunTab = Window:AddTab({ Name = "Gun", Icon = "crosshair" })

local GunSoundSection = GunTab:AddSection({
    Name           = "CUSTOM SOUNDS",
    Position       = "Left",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

GunSoundSection:AddToggle({
    Name     = "Enable Custom Hitsound",
    Default  = false,
    Callback = function(state)
        customHitsoundEnabled = state
        if state then
            applyHitsound()
        end
    end,
})

GunSoundSection:AddDropdown({
    Name     = "Custom Hitsound",
    Values   = {"Neverlose", "Hurt", "Beamhit", "Slash Hit"},
    Default  = "Neverlose",
    Callback = function(val)
        selectedHitsound = val
        if customHitsoundEnabled then
            applyHitsound()
        end
    end,
})

GunSoundSection:AddToggle({
    Name     = "Enable Custom Shoot Sound",
    Default  = false,
    Callback = function(state)
        customShootSoundEnabled = state
        applyShootSound()
    end,
})

GunSoundSection:AddDropdown({
    Name     = "Custom Shoot Sound",
    Values   = {"Neverlose", "Minecraft", "Click", "Shotgun", "Better Click"},
    Default  = "Neverlose",
    Callback = function(val)
        selectedShootSound = val
        if customShootSoundEnabled then
            applyShootSound()
        end
    end,
})

local PoliceTab = Window:AddTab({ Name = "Police", Icon = "shield" })

local PoliceSection = PoliceTab:AddSection({
    Name           = "POLICE FEATURES",
    Position       = "Left",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

PoliceSection:AddToggle({
    Name    = "Radar Farm",
    Default = false,
    Flag    = "RadarFarm",
    Save    = true,
    Callback = function(v)
        RadarFarmEnabled = v
        if v then
            task.spawn(function()
                while RadarFarmEnabled do
                    local char = LP.Character
                    if char then
                        local radar = char:FindFirstChild("Radar Gun")
                        local remote = ReplicatedStorage:FindFirstChild("2Wz") and ReplicatedStorage["2Wz"]:FindFirstChild("cf170e4b-063f-4c0a-ba4d-920a0bb1941a")
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if radar and remote and hrp then
                            local vehicles = Workspace:FindFirstChild("Vehicles")
                            if vehicles then
                                for _, veh in ipairs(vehicles:GetChildren()) do
                                    local ds = veh:FindFirstChild("DriveSeat")
                                    if ds and veh ~= vehicles:FindFirstChild(LP.Name) then
                                        local pos = ds.Position
                                        local dir = (pos - hrp.Position).Unit
                                        pcall(function() remote:FireServer(radar, pos, dir) end)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

PoliceSection:AddToggle({
    Name     = "Auto Taser",
    Default  = false,
    Flag     = "AutoTaser",
    Save     = true,
    Callback = function(v)
        AutoTaserEnabled = v
    end
})

PoliceSection:AddToggle({
    Name     = "Auto Taser Wall Check",
    Default  = false,
    Flag     = "AutoTaserWallCheck",
    Save     = true,
    Callback = function(v)
        AutoTaserWallCheck = v
    end
})

task.spawn(function()
    while true do
        task.wait(0.05)
        if AutoTaserEnabled then
            local char = LP.Character
            if not char then continue end
            local taser = char:FindFirstChild("Taser")
            if not taser then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local remote = ReplicatedStorage:FindFirstChild("2Wz") and ReplicatedStorage["2Wz"]:FindFirstChild("3d4642d3-a886-4e77-b3a8-2f26ecceb51c")
            if not remote then continue end
            local best, closest = nil, 20
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local p = plr.Character:FindFirstChild("HumanoidRootPart")
                    local h = plr.Character:FindFirstChild("Humanoid")
                    if p and h and h.Health > 0 and p:GetAttribute("IsWanted") and not h.Sit then
                        local d = (hrp.Position - p.Position).Magnitude
                        if d < closest then
                            local visible = true
                            if AutoTaserWallCheck then
                                local rp = RaycastParams.new()
                                rp.FilterType = Enum.RaycastFilterType.Exclude
                                local bl = {char, plr.Character}
                                local vehiclesFolder = Workspace:FindFirstChild("Vehicles")
                                if vehiclesFolder then table.insert(bl, vehiclesFolder) end
                                rp.FilterDescendantsInstances = bl
                                local r = Workspace:Raycast(hrp.Position, p.Position - hrp.Position, rp)
                                if r then visible = false end
                            end
                            if visible then
                                closest = d
                                best = p
                            end
                        end
                    end
                end
            end
            if best and remote then
                local pp = best.Position + (best.Velocity * 0.22)
                remote:FireServer(taser, pp, (pp - hrp.Position).Unit)
            end
        end
    end
end)

local VehicleTab = Window:AddTab({ Name = "Vehicle", Icon = "car" })

local VehicleSection = VehicleTab:AddSection({
    Name           = "CUSTOMIZATION",
    Position       = "Left",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

VehicleSection:AddToggle({
    Name    = "Ghost Mode",
    Default = false,
    Callback = function(state)
        ghostModeEnabled = state
        applyVehicleCustomization()
    end,
})

VehicleSection:AddColorPicker({
    Name     = "Ghost Mode Color",
    Default  = Color3.fromRGB(255, 105, 180),
    Callback = function(color)
        ghostModeColor = color
        if ghostModeEnabled then
            applyVehicleCustomization()
        end
    end,
})

VehicleSection:AddDropdown({
    Name     = "Vehicle Material",
    Values   = {"SmoothPlastic", "Neon", "ForceField", "Glass", "Metal", "DiamondPlate", "Foil"},
    Default  = "SmoothPlastic",
    Callback = function(matName)
        if materialMap[matName] then
            selectedMaterialEnum = materialMap[matName]
            applyVehicleCustomization()
        end
    end,
})

VehicleSection:AddColorPicker({
    Name     = "Vehicle Color",
    Default  = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        currentVehicleColor = color
        if not rainbowEnabled and not ghostModeEnabled then
            applyVehicleCustomization()
        end
    end,
})

VehicleSection:AddToggle({
    Name    = "Rainbow Vehicle",
    Default = false,
    Callback = function(state)
        rainbowEnabled = state
        if not state then
            applyVehicleCustomization()
        end
    end,
})

VehicleSection:AddSlider({
    Name     = "Vehicle Transparency",
    Default  = 0,
    Min      = 0,
    Max      = 1,
    Precision = 2,
    Callback = function(val)
        currentTransparency = val
        applyVehicleCustomization()
    end,
})

VehicleSection:AddToggle({
    Name    = "Enable Custom License Plate",
    Default = false,
    Callback = function(state)
        customPlateEnabled = state
        if state then
            applyLicensePlateText(customPlateText)
        end
    end,
})

VehicleSection:AddInput({
    Name     = "Custom License Plate",
    Default  = "",
    Callback = function(text)
        customPlateText = text
        if customPlateEnabled then
            applyLicensePlateText(text)
        end
    end,
})

local TuningSection = VehicleTab:AddSection({
    Name           = "TUNING",
    Position       = "Right",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

for _, info in ipairs({{"armorLevel", "Armor"}, {"brakesLevel", "Brakes"}, {"engineLevel", "Engine"}}) do
    local attr, label = info[1], info[2]
    TuningSection:AddSlider({
        Name     = label .. " Level",
        Min      = 0,
        Max      = 6,
        Default  = 0,
        Precision = 0,
        Callback = function(v)
            local vehicles = Workspace:FindFirstChild("Vehicles")
            local vehicle = vehicles and vehicles:FindFirstChild(LP.Name)
            if vehicle then
                vehicle:SetAttribute(attr, v)
            end
        end,
    })
end

local FlySection = VehicleTab:AddSection({
    Name           = "CAR FLY",
    Position       = "Right",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

FlySection:AddToggle({
    Name    = "Enable Car Fly",
    Default = false,
    Callback = function(state)
        toggleFlyState(state)
    end,
})

FlySection:AddKeybind({
    Name     = "Fly Keybind",
    Default  = Enum.KeyCode.X,
    Callback = function(key)
        flyKeybind = key
    end,
})

FlySection:AddSlider({
    Name     = "Fly Speed",
    Min      = 100,
    Max      = 300,
    Default  = 150,
    Precision = 0,
    Callback = function(v)
        flySpeed = v
    end,
})

FlySection:AddToggle({
    Name    = "Mobile Button",
    Default = false,
    Callback = function(state)
        mobileGui.Enabled = state
    end,
})

FlySection:AddToggle({
    Name    = "Lock Mobile Button",
    Default = false,
    Callback = function(state)
        lockBind = state
    end,
})

local VisualTab = Window:AddTab({ Name = "Visual", Icon = "eye" })

local ESPSection = VisualTab:AddSection({
    Name           = "ESP SETTINGS",
    Position       = "Left",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

ESPSection:AddToggle({
    Name    = "Enable Esp",
    Default = false,
    Callback = function(state)
        espEnabled = state
    end,
})

ESPSection:AddToggle({
    Name    = "Wanted ESP",
    Default = false,
    Callback = function(state)
        espWanted = state
    end,
})

ESPSection:AddToggle({
    Name    = "Name",
    Default = true,
    Callback = function(state)
        espName = state
    end,
})

ESPSection:AddToggle({
    Name    = "Health",
    Default = true,
    Callback = function(state)
        espHealth = state
    end,
})

ESPSection:AddToggle({
    Name    = "Distance",
    Default = true,
    Callback = function(state)
        espDistance = state
    end,
})

ESPSection:AddToggle({
    Name    = "Weapon",
    Default = false,
    Callback = function(state)
        espWeapon = state
    end,
})

ESPSection:AddToggle({
    Name    = "Team",
    Default = false,
    Callback = function(state)
        espTeam = state
    end,
})

ESPSection:AddToggle({
    Name    = "Team Color",
    Default = false,
    Callback = function(state)
        espTeamColor = state
    end,
})

ESPSection:AddToggle({
    Name    = "Teamcheck",
    Default = false,
    Callback = function(state)
        espTeamCheck = state
    end,
})

ESPSection:AddSlider({
    Name     = "Max Distance",
    Min      = 100,
    Max      = 15000,
    Default  = 15000,
    Precision = 0,
    Callback = function(v)
        espMaxDistance = v
    end,
})

local TracerSection = VisualTab:AddSection({
    Name           = "BULLET TRACERS",
    Position       = "Right",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

TracerSection:AddToggle({
    Name     = "Bullet Tracers",
    Default  = false,
    Callback = function(state)
        BulletTracersEnabled = state
    end,
})

TracerSection:AddColorPicker({
    Name     = "Tracer Color",
    Default  = Color3.fromRGB(255, 105, 180),
    Callback = function(color)
        TracerColor = color
    end,
})

local MiscTab = Window:AddTab({ Name = "Misc", Icon = "sliders" })

local MiscSection = MiscTab:AddSection({
    Name           = "MISCELLANEOUS",
    Position       = "Left",
    Collapsible    = false,
    Collapsed      = false,
    Box            = false,
    Icon           = nil,
    IconColor      = Color3.fromRGB(223, 223, 223),
    TextSize       = 11,
    TextXAlignment = "Left",
    SearchFilter   = false,
})

local antiAfkConn = nil
MiscSection:AddToggle({
    Name    = "Anti-AFK",
    Default = false,
    Callback = function(state)
        if state then
            local vu = game:GetService("VirtualUser")
            antiAfkConn = LP.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            end)
        else
            if antiAfkConn then
                antiAfkConn:Disconnect()
                antiAfkConn = nil
            end
        end
    end,
})

MiscSection:AddButton({
    Name     = "Rejoin Server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end,
})

MiscSection:AddButton({
    Name     = "Server Hop",
    Callback = function()
        local placeId = game.PlaceId
        local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if req then
            local servers = {}
            local url = string.format("https://games.roblox.com/v1/games/%d/servers/0?sortOrder=Asc&limit=100", placeId)
            local res = req({Url = url, Method = "GET"})
            if res and res.Body then
                local body = HttpService:JSONDecode(res.Body)
                if body and body.data then
                    for _, s in ipairs(body.data) do
                        if type(s) == "table" and s.playing < s.maxPlayers and s.id ~= game.JobId then
                            table.insert(servers, s.id)
                        end
                    end
                end
            end
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], LP)
            else
                Window:Notify({Title = "Server Hop", Content = "No alternative server found!", Duration = 3})
            end
        else
            Window:Notify({Title = "Server Hop", Content = "HTTP Request not supported by executor!", Duration = 3})
        end
    end,
})

local playerCountLabel = MiscSection:AddLabel("Players Online: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers)

Players.PlayerAdded:Connect(function()
    playerCountLabel:SetText("Players Online: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers)
end)

Players.PlayerRemoving:Connect(function()
    playerCountLabel:SetText("Players Online: " .. #Players:GetPlayers() - 1 .. " / " .. Players.MaxPlayers)
end)

Loading:SetCurrentStep(2)
Loading:Continue(Window)

Window:Notify({ Title = "Emergency Hamburg", Content = "Script loaded! Created by Xeioa", Duration = 4 })
