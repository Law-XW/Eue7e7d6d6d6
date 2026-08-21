local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Teams = game:GetService("Teams")

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
local speedBoostValue = 1
local playerFlySpeedValue = 50
local isTeleporting = false
local RadarFarmEnabled = false
local AutoTaserEnabled = false
local AutoTaserWallCheck = false

local SilentAimEnabled = false
local SAaimPart = "Head"
local SAFovSize = 150
local SAShowFOV = false
local SAFovColor = Color3.fromRGB(255, 105, 180)
local SAHighlightTarget = false
local SASnapline = false
local SAWallCheck = false
local SATeamCheck = false
local SAIgnoreWanted = false
local SAIgnoreUntouchable = false
local BulletTracersEnabled = false
local TracerColor = Color3.fromRGB(255, 105, 180)

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

local function isWantedPlayer(plr)
    if not plr.Character then return false end
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

local function getClosestSATarget()
    local cam = Workspace.CurrentCamera
    if not cam then return nil, nil end
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local bestDist, bestChar, bestScreen = SAFovSize, nil, nil
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return nil, nil end
    local localTeam = LP.Team
    local isPolice = localTeam and (localTeam.Name == "Police" or localTeam.Name == "Polizei")

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local part = plr.Character:FindFirstChild(SAaimPart) or plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                local skip = false
                if SATeamCheck and localTeam and plr.Team and localTeam == plr.Team then
                    skip = true
                end
                if not skip and SAIgnoreUntouchable and plr.Team then
                    local untouchable = {
                        Teams:FindFirstChild("Prisoner"),
                        Teams:FindFirstChild("TruckCompany"),
                        Teams:FindFirstChild("HARS"),
                        Teams:FindFirstChild("FireDepartment"),
                        Teams:FindFirstChild("BusCompany")
                    }
                    for _, t in ipairs(untouchable) do
                        if t and plr.Team == t then
                            skip = true
                            break
                        end
                    end
                    if not skip then
                        local tn = plr.Team.Name
                        if tn == "Prisoner" or tn == "TruckCompany" or tn == "HARS" or tn == "FireDepartment" or tn == "BusCompany" then
                            skip = true
                        end
                    end
                end
                if not skip and not SAIgnoreWanted then
                    local targetIsWanted = isWantedPlayer(plr)
                    local targetIsPolice = plr.Team and (plr.Team.Name == "Police" or plr.Team.Name == "Polizei")
                    if isPolice then
                        if not targetIsWanted then skip = true end
                    else
                        if not targetIsWanted and not targetIsPolice then skip = true end
                    end
                end
                if not skip and SAWallCheck then
                    local rp = RaycastParams.new()
                    rp.FilterType = Enum.RaycastFilterType.Exclude
                    local bl = {LP.Character, plr.Character}
                    local vehiclesFolder = Workspace:FindFirstChild("Vehicles")
                    if vehiclesFolder then table.insert(bl, vehiclesFolder) end
                    rp.FilterDescendantsInstances = bl
                    local r = Workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, rp)
                    if r then skip = true end
                end
                if not skip then
                    local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen and sp.Z > 0 then
                        local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if sd < bestDist then
                            bestDist = sd
                            bestChar = plr.Character
                            bestScreen = Vector2.new(sp.X, sp.Y)
                        end
                    end
                end
            end
        end
    end
    return bestChar, bestScreen
end

RunService.RenderStepped:Connect(function()
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

    if antiDamageEnabled or isTeleporting then
        if hum:GetState() == Enum.HumanoidStateType.Freefall or hrp.AssemblyLinearVelocity.Y < 0 then
            if hrp.AssemblyLinearVelocity.Y < -8 then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -8, hrp.AssemblyLinearVelocity.Z)
            end
        end
    end

    if playerFlyEnabled then
        local cam = Workspace.CurrentCamera
        if not cam then return end
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
    elseif speedBoostEnabled then
        if hum.MoveDirection.Magnitude > 0 then
            local speed = 16 + (speedBoostValue * 5)
            local targetVel = hum.MoveDirection * speed
            hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, hrp.AssemblyLinearVelocity.Y, targetVel.Z)
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

local function createPlayerESP(player)
    if player == LP then return end

    local function setupCharacter(char)
        if not char then return end
        local head = char:WaitForChild("Head", 5)
        if not head then return end

        local existing = head:FindFirstChild("PlayerESPGui")
        if existing then existing:Destroy() end

        local bgui = Instance.new("BillboardGui")
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

    player.CharacterAdded:Connect(setupCharacter)
    if player.Character then
        setupCharacter(player.Character)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    createPlayerESP(p)
end
Players.PlayerAdded:Connect(createPlayerESP)

RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local bgui = head and head:FindFirstChild("PlayerESPGui")

            if bgui and hum and hrp and hum.Health > 0 then
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
            elseif bgui then
                bgui.Enabled = false
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

local CombatTab = Window:AddTab({ Name = "Combat", Icon = "swords" })

local CombatSection = CombatTab:AddSection({
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

CombatSection:AddToggle({
    Name     = "Silent Aim",
    Default  = false,
    Callback = function(state)
        SilentAimEnabled = state
    end,
})

CombatSection:AddDropdown({
    Name     = "Aim Part",
    Values   = {"Head", "HumanoidRootPart"},
    Default  = "Head",
    Callback = function(val)
        SAaimPart = val
    end,
})

CombatSection:AddToggle({
    Name     = "Wall Check",
    Default  = false,
    Callback = function(state)
        SAWallCheck = state
    end,
})

CombatSection:AddToggle({
    Name     = "Team Check",
    Default  = false,
    Callback = function(state)
        SATeamCheck = state
    end,
})

CombatSection:AddToggle({
    Name     = "Ignore Untouchable Teams",
    Default  = false,
    Callback = function(state)
        SAIgnoreUntouchable = state
    end,
})

CombatSection:AddToggle({
    Name     = "Ignore Wanted Filter",
    Default  = false,
    Callback = function(state)
        SAIgnoreWanted = state
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
