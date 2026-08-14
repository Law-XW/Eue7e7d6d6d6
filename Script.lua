local executor = "Unknown"

if identifyexecutor then
    executor = identifyexecutor()
end

executor = string.lower(executor)

local OrionURL

if string.find(executor, "Delta") then
    OrionURL = "https://gist.githubusercontent.com/s63195220-boop/ba8304efb7d5e8d4526ba745e5d4cd7e/raw/22b1a462804772fc126a0f145245c173b3faa406/adasdasd"
else
    OrionURL = "https://gist.githubusercontent.com/timprime837-sys/f0329995e8164fc79907975ef6f383fa/raw/b33b2cb9f85406a4525448cc2d76b6d306cbbe82/TrixoLib"
end

local OrionLib = loadstring(game:HttpGet(OrionURL))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VehiclesFolder = workspace:WaitForChild("Vehicles")

-- Lokale Variablen (zusammengefasst in Tabellen um Register zu sparen)
local LocalPlayer = Players.LocalPlayer
local player = LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")

local vehicle = nil
local driveSeat = nil
local seat = nil

local Camera = Workspace.CurrentCamera
local vehiclesFolder = Workspace:FindFirstChild("Vehicles")

-- Fenster
local Window = OrionLib:MakeWindow({
    Name = "│Trixo v18 │〄Emergency Hamburg",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TrixoConfig",
    IntroEnabled = true,
    IntroText = "Trixo v18",
    Music = true,
})

-- ==================== TAB5: PLAYER ====================
Tab5 = Window:MakeTab({ Name = "⚙️| Player", PremiumOnly = false })
Tab5:AddSection({ Name = "Misc-Options" })



Tab5:AddToggle({
    Name = "⚫ License Plate Spoof",
    Default = false,
    Callback = function(Value)
        if Value then
            
            local function setPlate(vehicle)
                local plates = vehicle:FindFirstChild("Body") 
                    and vehicle.Body:FindFirstChild("LicensePlates")

                if plates then
                    for _, side in pairs({"Front", "Back"}) do
                        local part = plates:FindFirstChild(side)
                        if part and part:FindFirstChild("Gui") then
                            local label = part.Gui:FindFirstChildOfClass("TextLabel")
                            if label then
                                label.Text = "TrixoBeste"
                            end
                        end
                    end
                end
            end

            -- bestehende Fahrzeuge
            for _, v in pairs(workspace.Vehicles:GetChildren()) do
                setPlate(v)
            end

            -- neue Fahrzeuge
            workspace.Vehicles.ChildAdded:Connect(function(v)
                task.wait(1) -- warten bis alles geladen ist
                setPlate(v)
            end)
        end
    end    
})

Tab5:AddButton({
    Name = "💰 999999 Mio (Visuel)",
    Callback = function()
        local playerGui = player:WaitForChild("PlayerGui")
        for _, obj in pairs(playerGui:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if string.find(obj.Text, "€") then obj.Text = "99999 Mio" end
            end
        end
    end
})

Tab5:AddButton({
    Name = "💰 Inft Monay (Visuel)",
    Callback = function()
        local playerGui = player:WaitForChild("PlayerGui")
        for _, obj in pairs(playerGui:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if string.find(obj.Text, "€") then obj.Text = "Inft" end
            end
        end
    end
})

-- Anti-Fall
local antiFallEnabled = false
local antiFallConnection = nil

function AntiFallFunction(Value)
    antiFallEnabled = Value
    if antiFallEnabled and not antiFallConnection then
        antiFallConnection = RunService.RenderStepped:Connect(function()
            if character then
                local hum = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart and hum then
                    if hum:GetState() == Enum.HumanoidStateType.Freefall then
                        local velocity = rootPart.Velocity
                        if velocity.Y < 0 then
                            rootPart.Velocity = Vector3.new(velocity.X, math.max(velocity.Y, -15), velocity.Z)
                        end
                    end
                    local rp = RaycastParams.new()
                    rp.FilterType = Enum.RaycastFilterType.Blacklist
                    rp.FilterDescendantsInstances = {character}
                    local ray = workspace:Raycast(rootPart.Position, Vector3.new(0, -8, 0), rp)
                    if ray and rootPart.Velocity.Y < -50 then
                        rootPart.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end)
    elseif not antiFallEnabled and antiFallConnection then
        antiFallConnection:Disconnect()
        antiFallConnection = nil
    end
end

Tab5:AddToggle({ Name = "⚫ Anti-Fall/Damage", Default = false, Callback = function(Value) AntiFallFunction(Value) end })


-- Fake Cuffed Animation
local AnimationTrack = nil
local FakeAnim = Instance.new("Animation")
FakeAnim.AnimationId = "rbxassetid://9357137817"

local function playAnim()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    AnimationTrack = hum:LoadAnimation(FakeAnim)
    AnimationTrack:Play()
end

local function stopAnim()
    if AnimationTrack then AnimationTrack:Stop(); AnimationTrack = nil end
end

Tab5:AddToggle({ Name = "⚫ Fake Cuffed", Default = false, Callback = function(v) if v then playAnim() else stopAnim() end end })

Tab5:AddToggle({
    Name = "⚫ God Mode",
    CurrentValue = false,
    Flag = "Toggle2",
    Callback = function(Value)
        getgenv().godMode = Value
        task.spawn(function()
            while true do
                if not getgenv().godMode then return end
                game.Players.LocalPlayer.Character.Humanoid.Health = 100
                task.wait()
            end
        end)
    end,
})

-- Click to Delete
local mouse = game.Players.LocalPlayer:GetMouse()
local destroyEnabled = false
Tab5:AddToggle({ Name = "⚫ Click to Delete", Default = false, Callback = function(v) destroyEnabled = v end })
mouse.Button1Down:Connect(function()
    if destroyEnabled and mouse.Target then mouse.Target:Destroy() end
end)

Tab5:AddToggle({
    Name = "⚫ FreeCam",
    CurrentValue = false,
    Callback = function(state)
        if state then
            loadstring(game:HttpGet("https://gist.githubusercontent.com/timprime837-sys/7fed2cd0d69a831a1643f6660791c00d/raw/a3c79d5aeca4f791abd3bfdacd8fb2e7dc83750a/FreeCam"))()
        end
    end
})

local noclip = false
Tab5:AddToggle({ Name = "⚫ Noclip", CurrentValue = false, Callback = function(state) noclip = state end })
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Animations
local animations = {
    ["Helicopter"] = 95301257497525, ["Default Dance"] = 88455578674030,
    ["Sit"] = 97185364700038, ["Take The L"] = 78653596566468,
    ["Tank"] = 94915612757079, ["Vehicle"] = 108747312576405,
    ["Rizz Backflip"] = 131205329995035, ["Snow Surfer"] = 100663712757148,
    ["Skibidi Toilet"] = 127154705636043, ["Beat Da Koto Nai"] = 93497729736287,
    ["Spider"] = 87025086742503, ["Slickback"] = 74288964113793,
}
local animationList = {}
for name,_ in pairs(animations) do table.insert(animationList, name) end
local currentTrack = nil
local selectedAnimation = animationList[1]

Tab5:AddDropdown({ Name = "⚫ Select Animation", Default = selectedAnimation, Options = animationList, Callback = function(value) selectedAnimation = value end })
Tab5:AddToggle({
    Name = "⚫ Play Animation",
    Default = false,
    Callback = function(isOn)
        if isOn then
            if currentTrack then currentTrack:Stop() end
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://" .. animations[selectedAnimation]
            currentTrack = humanoid:LoadAnimation(anim)
            currentTrack:Play()
        else
            if currentTrack then currentTrack:Stop() end
        end
    end
})

Tab5:AddButton({
    Name = "⚫ Instant-Respawn",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
            wait(0.1)
            player:LoadCharacter()
        end
    end,
})

player.CharacterAdded:Connect(function(char)
    if autoReviveEnabled then
        char:WaitForChild("Humanoid").HealthChanged:Connect(function(hp)
            if hp <= char.Humanoid.MaxHealth * 0.27 then checkHealthAndTeleport() end
        end)
    end
end)

Tab5:AddButton({
    Name = "⚫ Steal Nearest Bike",
    Callback = function()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local function isUUID(name)
            return string.match(name, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
        end
        local function findNearestDriveSeat()
            local closestDistance = math.huge
            local closestSeat
            for _, v in ipairs(vehiclesFolder:GetChildren()) do
                if isUUID(v.Name) then
                    local s = v:FindFirstChild("DriveSeat", true)
                    if s and s:IsA("Seat") then
                        local dist = (s.Position - hrp.Position).Magnitude
                        if dist < closestDistance then closestDistance = dist; closestSeat = s end
                    end
                end
            end
            return closestSeat
        end
        local s = findNearestDriveSeat()
        if s then s:Sit(character:WaitForChild("Humanoid")) end
    end
})

Tab5:AddButton({
    Name = "⚫ Self Revive",
    Callback = function()
        local FARMspeed = 170
        local startPosition = nil
        local function isPlayerDead()
            if player and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then return hum.Health <= 24 end
            end
            return false
        end
        local function showNotification(message)
            game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Trixo", Text = message, Duration = 5 })
        end
        local function ensurePlayerInVehicle()
            if player and player.Character then
                local v = workspace.Vehicles:FindFirstChild(player.Name)
                if v and player.Character:FindFirstChild("Humanoid") then
                    local hum = player.Character:FindFirstChild("Humanoid")
                    if hum and not hum.SeatPart then
                        local ds = v:FindFirstChild("DriveSeat")
                        if ds then ds:Sit(hum) end
                    end
                end
            end
        end
        local function flyVehicleTo(targetCFrame, callback)
            local v = workspace.Vehicles:FindFirstChild(player.Name)
            if not v then return end
            local ds = v:FindFirstChild("DriveSeat")
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")
            if hum and ds and not hum.SeatPart then ds:Sit(hum) end
            if not v.PrimaryPart then
                local body = v:FindFirstChild("Body")
                if body then
                    local mass = body:FindFirstChild("Mass")
                    if mass then v.PrimaryPart = mass else return end
                else return end
            end
            local startPos = v.PrimaryPart.Position
            local targetPos = targetCFrame.Position
            local flightHeight = -1
            local startFlightPos = Vector3.new(startPos.X, flightHeight, startPos.Z)
            v:SetPrimaryPartCFrame(CFrame.new(startFlightPos))
            local flightTarget = Vector3.new(targetPos.X, flightHeight, targetPos.Z)
            local distance = (Vector3.new(startPos.X, 0, startPos.Z) - Vector3.new(flightTarget.X, 0, flightTarget.Z)).Magnitude
            local duration = distance / FARMspeed
            local info = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
            local CFrameValue = Instance.new("CFrameValue")
            CFrameValue.Value = v:GetPrimaryPartCFrame()
            CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
                local currentPos = CFrameValue.Value.Position
                v:SetPrimaryPartCFrame(CFrame.new(currentPos.X, flightHeight, currentPos.Z))
                v.PrimaryPart.Velocity = Vector3.new(0,0,0)
            end)
            local tween = TweenService:Create(CFrameValue, info, { Value = CFrame.new(flightTarget) })
            tween:Play()
            tween.Completed:Connect(function()
                CFrameValue:Destroy()
                v:SetPrimaryPartCFrame(targetCFrame)
                if callback then callback() end
            end)
        end
        local function goToHospitalAndSit()
            local char = player.Character or player.CharacterAdded:Wait()
            char:MoveTo(Vector3.new(-107.427, 7.648, 1073.643))
            wait(1)
            local buildings = workspace:FindFirstChild("Buildings")
            local hospital = buildings:FindFirstChild("Hospital")
            local bed = hospital:FindFirstChild("HospitalBed")
            local s = bed:FindFirstChild("Seat")
            char:MoveTo(s.Position + Vector3.new(0, 2, 0))
            wait(0.7)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then s:Sit(hum) end
        end
        local VIM = game:GetService("VirtualInputManager")
        local function pressSpace()
            VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            wait(0.1)
            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            wait(0.2)
        end
        if isPlayerDead() then
            startPosition = player.Character and player.Character.PrimaryPart and player.Character.PrimaryPart.CFrame or nil
            ensurePlayerInVehicle()
            wait(0.5)
            flyVehicleTo(CFrame.new(-89.70, 5.88, 1055.77), function()
                wait(1)
                player.Character:MoveTo(Vector3.new(-107.427, 7.648, 1073.643))
                wait(0.5)
                goToHospitalAndSit()
                task.spawn(function()
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    while hum and hum.Health <= 27 do
                        wait(1)
                        hum = player.Character:FindFirstChildOfClass("Humanoid")
                    end
                    pressSpace()
                    wait(0.5)
                    ensurePlayerInVehicle()
                    wait(0.5)
                    if startPosition then flyVehicleTo(startPosition) end
                end)
            end)
        else
            showNotification("You are not dead.")
        end
    end
})

Tab5:AddParagraph("Fly INFO","Press V to Fly")

-- Fly
local flyingSpeed = 50
local isFlying = false
local attachment, alignPosition, alignOrientation

local function enableFly()
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    if not (root and hum) then return end
    attachment = Instance.new("Attachment", root)
    alignPosition = Instance.new("AlignPosition")
    alignPosition.Attachment0 = attachment
    alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
    alignPosition.MaxForce = 5000
    alignPosition.Responsiveness = 45
    alignPosition.Parent = root
    alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.Attachment0 = attachment
    alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignOrientation.MaxTorque = 5000
    alignOrientation.Responsiveness = 45
    alignOrientation.Parent = root
    hum.PlatformStand = true
    isFlying = true
    local lastPosition = root.Position
    alignPosition.Position = lastPosition
    task.spawn(function()
        while isFlying and root and hum do
            local moveDir = Vector3.zero
            local camCFrame = workspace.CurrentCamera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camCFrame.RightVector end
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
                local newPos = lastPosition + (moveDir * flyingSpeed * RunService.Heartbeat:Wait())
                alignPosition.Position = newPos
                lastPosition = newPos
            end
            alignOrientation.CFrame = CFrame.new(Vector3.zero, camCFrame.LookVector)
            RunService.Heartbeat:Wait()
        end
    end)
end

local function disableFly()
    isFlying = false
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = false end
    if attachment then attachment:Destroy() end
    if alignPosition then alignPosition:Destroy() end
    if alignOrientation then alignOrientation:Destroy() end
end

Tab5:AddToggle({
    Name = "⚫ Fly", CurrentValue = false,
    Callback = function(v) if v then enableFly() else disableFly() end end
})

Tab5:AddSection({ Name = "Character-Settings" })

Tab5:AddSlider({
    Name = "⚫Fly Speed", Min = 10, Max = 150, Default = 76,
    Color = Color3.fromRGB(69,64,64), Increment = 1, ValueName = "Speed",
    CurrentValue = flyingSpeed, Callback = function(v) flyingSpeed = v end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.V then
        if isFlying then disableFly() else enableFly() end
    end
end)

local boostAmount = 5
Tab5:AddSlider({
    Name = "⚫WalkSpeed", Min = 0, Max = 82, Default = 0,
    Color = Color3.fromRGB(69,64,64), Increment = 1, ValueName = "Speed",
    Callback = function(Value) boostAmount = Value / 335 end
})
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum and hrp and boostAmount > 0 and hum.MoveDirection.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * boostAmount
    end
end)

local jumpBoostPower = 350
Tab5:AddSlider({
    Name = "⚫ Jump Power", Min = 0, Max = 350, Default = 0,
    Color = Color3.fromRGB(69,64,64), Increment = 1, ValueName = "Power",
    Callback = function(Value) jumpBoostPower = Value end
})
humanoid.Jumping:Connect(function()
    if jumpBoostPower > 0 then
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(
            HumanoidRootPart.AssemblyLinearVelocity.X,
            jumpBoostPower,
            HumanoidRootPart.AssemblyLinearVelocity.Z
        )
    end
end)

AimbotTab = Window:MakeTab({Name = "🔴│Aimbot", PremiumOnly = false})

local FOVring = Drawing.new("Circle")
FOVring.Visible, FOVring.Thickness, FOVring.Radius = false, 1, 90
FOVring.Transparency, FOVring.Color, FOVring.Position = 1, Color3.fromRGB(255,255,255), workspace.CurrentCamera.ViewportSize / 2

local settings = {
    AimFOV = 90,
    smoothing = 0.5,
    maxDistance = 500,
    prediction = 0.0575,
    predictOn = false,
    lockPart = "HumanoidRootPart",
    aimOn = false,
    fovShow = false,
    fovColor = Color3.fromRGB(255,255,255)
}

AimbotTab:AddSection({Name = "Aimbot Settings"})

AimbotTab:AddToggle({
    Name = "🔴 Aimbot",
    Default = false,
    Callback = function(v) settings.aimOn = v end
})

mouse.Button1Down:Connect(function()
    if destroyEnabled and mouse.Target then mouse.Target:Destroy() end
end)

AimbotTab:AddToggle({
    Name = "🔴 FreeCam",
    CurrentValue = false,
    Callback = function(state)
        if state then
            -- Wenn der Toggle aktiviert ist, wird das FreeCam-Skript ausgeführt
            loadstring(game:HttpGet("https://raw.githubusercontent.com/DanielHubll/DanielHubll/refs/heads/main/Aimbot%20Mobile"))()
        else
            -- Optional: Hier könntest du auch eine Funktion zum Deaktivieren des FreeCam-Modus hinzufügen
            -- z.B. ein Deaktivieren der Kamera, wenn der Toggle ausgeschaltet wird
            -- (Falls das FreeCam-Skript eine Möglichkeit bietet, es zu stoppen)
        end
    end
})

AimbotTab:AddToggle({
    Name = "🔴 FOV Circle",
    Default = false,
    Callback = function(v) 
        settings.fovShow = v 
        FOVring.Visible = v and settings.aimOn
    end
})

AimbotTab:AddBind({
    Name = "🔴 Aimbot Keybind",
    Default = Enum.KeyCode.M,
    Hold = false,
    Callback = function()
        settings.aimOn = not settings.aimOn
        FOVring.Visible = settings.aimOn and settings.fovShow
    end
})

AimbotTab:AddDropdown({
    Name = "🔴 Aim Part",
    Default = "Head",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Callback = function(v) settings.lockPart = v end
})

AimbotTab:AddToggle({
    Name = "🔴 Prediction",
    Default = false,
    Callback = function(v) settings.predictOn = v end
})

AimbotTab:AddSlider({
    Name = "🔴 FOV Size",
    Min = 10, Max = 200, Default = 90,
    Color = Color3.fromRGB(255,0,0), Increment = 1,
    ValueName = "FOV",
    Callback = function(v)
        settings.AimFOV = v
        FOVring.Radius = v
    end
})

AimbotTab:AddSlider({
    Name = "🔴 Smoothness",
    Min = 1, Max = 10, Default = 5,
    Increment = 1, Color = Color3.fromRGB(255,0,0),
    ValueName = "",
    Callback = function(v) settings.smoothing = (10 - v) / 10 end
})

AimbotTab:AddSlider({
    Name = "🔴 Max Distance",
    Min = 50, Max = 1000, Default = 500,
    Increment = 50, Color = Color3.fromRGB(255,0,0),
    ValueName = "Distance",
    Callback = function(v) settings.maxDistance = v end
})

AimbotTab:AddSlider({
    Name = "🔴 Prediction Factor",
    Min = 1, Max = 100, Default = 5,
    Increment = 1, Color = Color3.fromRGB(255,0,0),
    ValueName = "",
    Callback = function(v) settings.prediction = v / 100 end
})

AimbotTab:AddColorpicker({
    Name = "🔴 FOV Color",
    Default = Color3.fromRGB(255,255,255),
    Callback = function(v)
        settings.fovColor = v
        FOVring.Color = v
    end
})

AimbotTab:AddParagraph("Instructions", "Hold Right Mouse Button | Keybind: M to toggle")

RunService.RenderStepped:Connect(function()
    if settings.aimOn then
        FOVring.Position = workspace.CurrentCamera.ViewportSize / 2
        
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local screenCenter = workspace.CurrentCamera.ViewportSize / 2
            local closestTarget, shortestDist
            
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(settings.lockPart) then
                    local targetPart = v.Character[settings.lockPart]
                    local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                        local worldDist = (workspace.CurrentCamera.CFrame.Position - targetPart.Position).Magnitude
                        
                        if dist <= settings.AimFOV and worldDist <= settings.maxDistance then
                            if not closestTarget or dist < shortestDist then
                                shortestDist = dist
                                closestTarget = v
                            end
                        end
                    end
                end
            end
            
            if closestTarget and closestTarget.Character then
                local targetPart = closestTarget.Character[settings.lockPart]
                if targetPart then
                    local aimPos = targetPart.Position
                    if settings.predictOn then
                        aimPos = aimPos + (targetPart.Velocity * settings.prediction)
                    end
                    
                    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(
                        CFrame.new(workspace.CurrentCamera.CFrame.Position, aimPos), 
                        settings.smoothing
                    )
                end
            end
        end
    end
end)

game.Players.LocalPlayer.AncestryChanged:Connect(function() FOVring:Remove() end)


ShootRemote = ReplicatedStorage:WaitForChild("2Wz"):WaitForChild("5acb020e-ac6e-4ef8-8c2c-a548efc1af68")
SyncRemote = ReplicatedStorage:WaitForChild("2Wz"):WaitForChild("0423e028-a779-42b1-873b-ce6b0a6e87fe")

function CheckGCFunctionality()
    if not getgc then return false end
    dummy = {["Test"] = true}
    success = false
    for i=1, 30 do
        gc = getgc(true)
        if gc then
            for _, v in pairs(gc) do if v == dummy then success = true break end end
        end
        if success then break end
        task.wait()
    end
    return success
end

isGCFunctional = CheckGCFunctionality()
currentMasterID = 0
isSynced = false
lastShootAttempt = 0
weaponVelocities = {
    ["G36"] = 3286, ["Glock 17"] = 1339, ["MP5"] = 1429,
    ["M58B Shotgun"] = 1607, ["M4 Carbine"] = 3250
}

SilentTab = Window:MakeTab({
    Name = "🐻|Silent Elite",
    PremiumOnly = false
})

s = {
    on = false,
    fovOn = true,
    fovSize = 150,
    fovColor = Color3.fromRGB(255, 255, 255),
    dynamicFovColor = false,
    targetPart = "HumanoidRootPart",
    maxDist = 1500,
    predictionOn = true,
    predSensitivity = 1.0,
    deadCheck = true,
    shootAtPolice = false,
    shootAtWanted = true,
    wallCheck = true,
    visibleCheck = true
}

FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1.5
FovCircle.Radius = s.fovSize
FovCircle.Color = s.fovColor
FovCircle.Visible = s.fovOn

function GetBulletCountFromGC()
    if not isGCFunctional then return nil end
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "projectileIdCounter") then
            return v.projectileIdCounter, v
        end
    end
    return nil
end

function GetAmmoCount()
    for _, g in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.DisplayOrder == 13 then
            t = g:FindFirstChildWhichIsA("ImageLabel", true)
            f = t and t.Parent:FindFirstChild("2")
            l = f and f:FindFirstChild("2")
            if l and l:IsA("TextLabel") then
                split = string.split(l.Text, "/")
                return tonumber(split[1])
            end
        end
    end
    return nil
end

function IsValidTarget(p)
    char = p.Character
    hum = char and char:FindFirstChild("Humanoid")
    hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return false end
    if s.deadCheck and hum.Health < 25 then return false end
    if s.visibleCheck and char:GetAttribute("Visible") == false then return false end
    team = tostring(p.Team)
    isWanted = hrp:GetAttribute("IsWanted") == true
    bannedTeams = {["HARS"] = true, ["FireDepartment"] = true, ["Prisoner"] = true, ["TruckCompany"] = true, ["BusCompany"] = true}
    if bannedTeams[team] then return false end
    if s.shootAtPolice and team == "Police" then return true end
    if s.shootAtWanted and isWanted then return true end
    if team == "Citizen" and not isWanted then return false end
    return false
end

function GetClosestTarget()
    camera = Workspace.CurrentCamera
    center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    target, closestDist = nil, s.fovSize
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not IsValidTarget(p) then continue end
        char = p.Character
        targetPart = char:FindFirstChild(s.targetPart)
        if not targetPart then continue end
        distToPlayer = (LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
        if distToPlayer > s.maxDist then continue end
        if s.wallCheck then
            rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayResult = Workspace:Raycast(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * distToPlayer, rayParams)
            if rayResult then continue end
        end
        screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
        if onScreen then
            dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if dist < closestDist then
                closestDist = dist
                target = targetPart
            end
        end
    end
    return target
end

MainTab = SilentTab
MainTab:AddToggle({Name = "🟤 Enable Silent Aim", Default = false, Callback = function(v) s.on = v end})
MainTab:AddToggle({Name = "🎯 Prediction", Default = true, Callback = function(v) s.predictionOn = v end})
MainTab:AddSlider({Name = "🎯 Pred Sensitivity", Min = 1, Max = 200, Default = 100, Callback = function(v) s.predSensitivity = v/100 end})
MainTab:AddToggle({Name = "💀 Dead Check (25 HP)", Default = true, Callback = function(v) s.deadCheck = v end})
MainTab:AddToggle({Name = "🟤 Wall Check", Default = true, Callback = function(v) s.wallCheck = v end})
MainTab:AddToggle({Name = "🔵 Shoot at Police", Default = false, Callback = function(v) s.shootAtPolice = v end})
MainTab:AddToggle({Name = "🔵 Shoot at Wanted", Default = true, Callback = function(v) s.shootAtWanted = v end})
MainTab:AddDropdown({
    Name = "🎯 Target Part",
    Default = "HumanoidRootPart",
    Options = {"Head", "HumanoidRootPart"},
    Callback = function(v) s.targetPart = v end
})
MainTab:AddSlider({
    Name = "📏 Max Distance", Min = 50, Max = 1500, Default = 1500,
    Callback = function(v) s.maxDist = v end
})
MainTab:AddToggle({Name = "⭕ Enable FOV", Default = false, Callback = function(v) s.fovOn = v end})
MainTab:AddSlider({
    Name = "⭕ FOV Size", Min = 50, Max = 800, Default = 150,
    Callback = function(v) s.fovSize = v FovCircle.Radius = v end
})
MainTab:AddColorpicker({
    Name = "⭕ FOV Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(v) s.fovColor = v end
})
MainTab:AddToggle({Name = "🟢 FOV Green on Target", Default = false, Callback = function(v) s.dynamicFovColor = v end})

RunService.RenderStepped:Connect(function()
    FovCircle.Visible = s.fovOn
    if FovCircle.Visible then
        cam = Workspace.CurrentCamera
        FovCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        curT = GetClosestTarget()
        FovCircle.Color = (curT and s.dynamicFovColor) and Color3.fromRGB(0, 255, 0) or s.fovColor
    end
    if not s.on or not ShootRemote then return end
    ammo = GetAmmoCount()
    if ammo and ammo <= 0 then return end
    target = GetClosestTarget()
    if target and (tick() - lastShootAttempt >= 0.18) then
        lastShootAttempt = tick()
        myChar = LocalPlayer.Character
        weapon = myChar and myChar:FindFirstChildWhichIsA("Tool")
        camera = Workspace.CurrentCamera
        if weapon and camera then
            predictedPos = target.Position
            if s.predictionOn then
                speed = weaponVelocities[weapon.Name] or 2000
                dist = (target.Position - camera.CFrame.Position).Magnitude
                ping = LocalPlayer:GetNetworkPing()
                travelTime = (dist / speed) + (ping * s.predSensitivity)
                targetHRP = target.Parent:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    predictedPos = target.Position + (targetHRP.Velocity * travelTime)
                end
            end
            dir = (predictedPos - camera.CFrame.Position).Unit
            bulletID = 0
            gcID, gcTable = GetBulletCountFromGC()
            if gcID then bulletID = gcID gcTable.projectileIdCounter = gcTable.projectileIdCounter + 1 else bulletID = currentMasterID end
            oldAmmo = ammo
            ShootRemote:FireServer(bulletID, dir, false, SyncRemote.OnClientEvent:Wait())
            if not gcID then
                task.delay(0.05, function()
                    nA = GetAmmoCount()
                    if oldAmmo and nA and nA < oldAmmo then currentMasterID = currentMasterID + 1 isSynced = true else currentMasterID = currentMasterID + 1 end
                end)
            end
        end
    end
end)

OrionLib:Init()
game.Players.LocalPlayer.AncestryChanged:Connect(function() FovCircle:Remove() end)

-- ==================== TAB19: GUN MODS ====================
Tab19 = Window:MakeTab({ Name = "🔫| Gun Mods", PremiumOnly = false })
Tab19:AddSection({ Name = "Weapon Settings" })

local rapidFireEnabled = false
Tab19:AddToggle({
    Name = "🟣 FastShot-Firer (OP)", CurrentValue = false, Flag = "RapidFireToggle",
    Callback = function(Value)
        rapidFireEnabled = Value
        if rapidFireEnabled then
            task.spawn(function()
                while rapidFireEnabled do
                    local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if Tool then Tool:SetAttribute("ShootDelay", 0); Tool:SetAttribute("Automatic", true) end
                    task.wait(0.1)
                end
            end)
        end
    end
})

local VirtualInputManager = game:GetService("VirtualInputManager")
local autoRefillEnabled = false
local trackedWeapons = {"G36","Glock 17","MP5","M4 Carabine","Sniper","M58B Shotgun"}

task.spawn(function()
    while true do
        if autoRefillEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, weaponName in ipairs(trackedWeapons) do
                        local w = char:FindFirstChild(weaponName) or workspace:FindFirstChild(weaponName)
                        if w then
                            local magSize = w:GetAttribute("MagCurrentSize") or w:GetAttribute("Ammo")
                                or w:GetAttribute("Clip") or (w:FindFirstChild("Ammo") and w.Ammo.Value)
                            if magSize and magSize == 0 then
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                                task.wait(0.1)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                                task.wait(1)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

Tab19:AddToggle({ Name = "🟣 Auto-Reload", CurrentValue = false, Flag = "AutoReload", Callback = function(Value) autoRefillEnabled = Value end })


local noRecoilEnabled = false
Tab19:AddToggle({
    Name = "🟣 No-Recoil", CurrentValue = false, Flag = "NoRecoilToggle",
    Callback = function(Value)
        noRecoilEnabled = Value
        if noRecoilEnabled then
            task.spawn(function()
                while noRecoilEnabled do
                    local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if Tool then Tool:SetAttribute("Recoil", 0); Tool:SetAttribute("Instability", 0) end
                    task.wait(0.1)
                end
            end)
        end
    end
})

local soundOptions = {"Default","Ak47","Sniper","MP40","P90","Laser Gun","Pixel Gun"}
local soundIds = {
    ["Ak47"] = "rbxassetid://5910000043", ["Sniper"] = "rbxassetid://6581933860",
    ["MP40"] = "rbxassetid://103807799095792", ["P90"] = "rbxassetid://87534588983395",
    ["Laser Gun"] = "rbxassetid://7380537613", ["Pixel Gun"] = "rbxassetid://438149153"
}
local targetSoundIds = { ["rbxassetid://801226154"] = true, ["rbxassetid://801217802"] = true }
local originalSounds = {}
local selectedSound = "Default"

local function cacheSounds()
    for _, s in ipairs(game:GetDescendants()) do
        if s:IsA("Sound") and targetSoundIds[s.SoundId] then
            if not originalSounds[s] then originalSounds[s] = s.SoundId end
        end
    end
end
local function applySound()
    cacheSounds()
    for sound, originalId in pairs(originalSounds) do
        if sound and sound.Parent then
            sound.SoundId = (selectedSound == "Default") and originalId or soundIds[selectedSound]
        end
    end
end

Tab19:AddDropdown({
    Name = "🟣 Weapon Sound", Default = "Default", Save = true, Flag = "WeaponSoundSelect", Options = soundOptions,
    Callback = function(value) selectedSound = value; applySound() end
})
LocalPlayer.CharacterAdded:Connect(function() task.wait(1); applySound() end)

-- ==================== TAB3: ESP ====================
Tab3 = Window:MakeTab({ Name = "👁️| ESP", PremiumOnly = false })
Tab3:AddSection({ Name = "ESP-Settings" })

local plr = Players.LocalPlayer
local state = {
    espEnabled = false, showNames = false, showTeams = false, showDistance = false,
    showHealth = false, showEquipped = false, showWanted = false, espObjects = {}, espDistance = 1000
}

local function teamColorForTeam(team)
    if not team then return Color3.fromRGB(200,200,200) end
    local tn = tostring(team.Name):lower()
    if tn:find("police") then return Color3.fromRGB(80,160,255)
    elseif tn:find("fire") then return Color3.fromRGB(255,80,80)
    elseif tn:find("hospital") or tn:find("medic") then return Color3.fromRGB(120,255,140)
    else return Color3.fromRGB(200,200,200) end
end

local function createESPForPlayer(other)
    if not other.Character then return end
    if state.espObjects[other.UserId] then return end
    local hrp = other.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. other.Name
    billboard.Adornee = hrp
    billboard.Size = UDim2.new(0,160,0,100)
    billboard.StudsOffset = Vector3.new(0,3.5,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = other.Character
    local function newLabel(yOffset, color)
        local lbl = Instance.new("TextLabel", billboard)
        lbl.Size = UDim2.new(1,0,0,18)
        lbl.Position = UDim2.new(0,0,0,yOffset)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextStrokeTransparency = 0.6
        lbl.TextColor3 = color or Color3.new(1,1,1)
        return lbl
    end
    state.espObjects[other.UserId] = {
        billboard = billboard, nameLbl = newLabel(0), infoLbl = newLabel(20),
        healthLbl = newLabel(38, Color3.fromRGB(120,255,120)),
        equipLbl = newLabel(56, Color3.fromRGB(255,255,0)), wantedLbl = newLabel(74)
    }
end

local function updateESPEntry(other)
    local entry = state.espObjects[other.UserId]
    if not entry then return end
    local char = other.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then entry.billboard.Enabled = false; return end
    local plrRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not plrRoot then return end
    local dist = (plrRoot.Position - hrp.Position).Magnitude
    if dist > state.espDistance then entry.billboard.Enabled = false; return else entry.billboard.Enabled = true end
    local team = other.Team
    local teamColor = teamColorForTeam(team)
    entry.nameLbl.Text = state.showNames and other.Name or ""
    entry.nameLbl.TextColor3 = teamColor
    entry.infoLbl.Text = state.showDistance and ((team and ("["..team.Name.."] ") or "") .. math.floor(dist) .. "m") or (team and ("["..team.Name.."]") or "")
    entry.healthLbl.Text = state.showHealth and ("HP: "..math.floor(hum.Health)) or ""
    if state.showEquipped then
        local tool = char:FindFirstChildOfClass("Tool")
        entry.equipLbl.Text = tool and ("Equipped: "..tool.Name) or "Nothing Equipped"
    else entry.equipLbl.Text = "" end
    if state.showWanted then
        if hrp:GetAttribute("IsWanted") then entry.wantedLbl.Text = "Wanted"; entry.wantedLbl.TextColor3 = Color3.fromRGB(255,140,0)
        else entry.wantedLbl.Text = "Not Wanted"; entry.wantedLbl.TextColor3 = Color3.fromRGB(0,255,0) end
    else entry.wantedLbl.Text = "" end
end

RunService.RenderStepped:Connect(function()
    if not state.espEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            if not state.espObjects[p.UserId] then createESPForPlayer(p) end
            updateESPEntry(p)
        end
    end
end)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if state.espEnabled then task.wait(1); createESPForPlayer(p) end
    end)
end)
Players.PlayerRemoving:Connect(function(p)
    local entry = state.espObjects[p.UserId]
    if entry then if entry.billboard then entry.billboard:Destroy() end; state.espObjects[p.UserId] = nil end
end)

Tab3:AddToggle({
    Name="⚪ Player ESP", CurrentValue=false,
    Callback=function(v)
        state.espEnabled = v
        if not v then
            for _,e in pairs(state.espObjects) do e.billboard:Destroy() end
            state.espObjects = {}
        else
            for _,p in ipairs(Players:GetPlayers()) do if p ~= plr then createESPForPlayer(p) end end
        end
    end
})
Tab3:AddToggle({Name="⚪ Show Wanted",CurrentValue=false,Callback=function(v)state.showWanted=v end})
Tab3:AddToggle({Name="⚪ Show Names",CurrentValue=false,Callback=function(v)state.showNames=v end})
Tab3:AddToggle({Name="⚪ Show Teams",CurrentValue=false,Callback=function(v)state.showTeams=v end})
Tab3:AddToggle({Name="⚪ Show Distance",CurrentValue=false,Callback=function(v)state.showDistance=v end})
Tab3:AddToggle({Name="⚪ Show Health",CurrentValue=false,Callback=function(v)state.showHealth=v end})
Tab3:AddToggle({Name="⚪ Show Equipped",CurrentValue=false,Callback=function(v)state.showEquipped=v end})
Tab3:AddSlider({
    Name = "⚪ ESP-Distance", Min = 100, Max = 2000, Default = 1000,
    Color = Color3.fromRGB(255,255,255), Increment = 50, ValueName = "Studs",
    CurrentValue = state.espDistance, Callback = function(value) state.espDistance = value end
})
Tab3:AddSection({ Name = "Car ESP" })

local Vehicles = workspace:WaitForChild("Vehicles")
local carESPEnabled = false
local highlights = {}

local function clearHighlights()
    for _, h in pairs(highlights) do if h and h.Parent then h:Destroy() end end
    table.clear(highlights)
end
local function addHighlight(v)
    if not v:IsA("Model") then return end
    local part = v:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = v
    highlight.FillColor = Color3.fromRGB(255,0,0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255,255,255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = workspace
    table.insert(highlights, highlight)
end
local function toggleCarESP(s)
    carESPEnabled = s; clearHighlights()
    if not s then return end
    for _, v in ipairs(Vehicles:GetChildren()) do addHighlight(v) end
    Vehicles.ChildAdded:Connect(function(v) if carESPEnabled then task.wait(0.1); addHighlight(v) end end)
end

local carHealthESPEnabled = false
local healthUIs = {}
local updateConnection = nil
local childAddedConnection = nil

local function getHealth(v) local val = v:FindFirstChild("currentHealth", true); if val and val:IsA("NumberValue") then return val.Value end; return v:GetAttribute("currentHealth") end
local function getMaxHealth(v) local val = v:FindFirstChild("maxHealth", true); if val and val:IsA("NumberValue") then return val.Value end; return v:GetAttribute("maxHealth") or 100 end

local function createHealthUI(v)
    if healthUIs[v] then return end
    if not v:IsA("Model") then return end
    local part = v:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    local gui = Instance.new("BillboardGui"); gui.Adornee = part; gui.Size = UDim2.fromScale(4,0.8); gui.StudsOffset = Vector3.new(0,4,0); gui.AlwaysOnTop = true; gui.Parent = workspace
    local bg = Instance.new("Frame", gui); bg.Size = UDim2.fromScale(1,1); bg.BackgroundColor3 = Color3.fromRGB(25,25,25); bg.BorderSizePixel = 0; Instance.new("UICorner", bg).CornerRadius = UDim.new(0,8)
    local bar = Instance.new("Frame", bg); bar.Name = "Bar"; bar.Size = UDim2.fromScale(1,1); bar.BackgroundColor3 = Color3.fromRGB(0,200,0); bar.BorderSizePixel = 0; Instance.new("UICorner", bar).CornerRadius = UDim.new(0,8)
    local text = Instance.new("TextLabel", bg); text.Size = UDim2.fromScale(1,1); text.BackgroundTransparency = 1; text.TextScaled = true; text.Font = Enum.Font.GothamBold; text.TextColor3 = Color3.new(1,1,1); text.TextStrokeTransparency = 0
    healthUIs[v] = { gui = gui, bar = bar, text = text }
end
local function clearHealthESP()
    for _, ui in pairs(healthUIs) do if ui.gui then ui.gui:Destroy() end end
    table.clear(healthUIs)
    if updateConnection then updateConnection:Disconnect(); updateConnection = nil end
    if childAddedConnection then childAddedConnection:Disconnect(); childAddedConnection = nil end
end
local function toggleCarHealthESP(s)
    carHealthESPEnabled = s; clearHealthESP()
    if not s then return end
    for _, car in ipairs(Vehicles:GetChildren()) do createHealthUI(car) end
    childAddedConnection = Vehicles.ChildAdded:Connect(function(car) task.wait(0.2); if carHealthESPEnabled then createHealthUI(car) end end)
    updateConnection = RunService.RenderStepped:Connect(function()
        for v, ui in pairs(healthUIs) do
            if not v or not v.Parent then ui.gui:Destroy(); healthUIs[v] = nil; continue end
            local health = getHealth(v)
            if not health then continue end
            local percent = math.clamp(health / getMaxHealth(v), 0, 1)
            ui.bar.Size = UDim2.fromScale(percent, 1)
            ui.text.Text = math.floor(health) .. " HP"
            ui.bar.BackgroundColor3 = (percent > 0.6) and Color3.fromRGB(0,200,0) or (percent > 0.3) and Color3.fromRGB(255,170,0) or Color3.fromRGB(200,0,0)
        end
    end)
end

Tab3:AddToggle({ Name = "⚪ Car-ESP", CurrentValue = false, Flag = "CarESP_Highlight", Callback = function(val) toggleCarESP(val) end })
Tab3:AddToggle({ Name = "⚪ Car Live-ESP", CurrentValue = false, Flag = "CarESP_Health", Callback = function(val) toggleCarHealthESP(val) end })

-- ==================== TAB4: TELEPORT ====================
local PathfindingService = game:GetService("PathfindingService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local targetCFrame = CFrame.new(440.400, 5.520, -1438.111)
local moveSpeed = 100

_G.AutoNavEnabled = false
_G.flightSpeed = 190

local minSpeed, maxSpeed = 140, 200
local speedStep = 10
local fps = 60
local currentPing = 100
local isTeleporting = false

RunService.RenderStepped:Connect(function(deltaTime)
    fps = math.floor(1 / deltaTime)
end)

local function getPing()
    local dataPing = Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("Ping")
    if dataPing then 
        return dataPing:GetValue() 
    end
    if player and player:IsDescendantOf(game) then
        local success, ping = pcall(function() return player:GetNetworkPing() * 1000 end)
        if success then return ping end
    end
    return 100
end

task.spawn(function()
    while true do
        currentPing = getPing()
        local pingFactor = math.clamp(1 - (currentPing / 300), 0, 1)
        local fpsFactor = math.clamp(fps / 60, 0.5, 1.2)
        local targetSpeed = math.clamp(minSpeed * fpsFactor * pingFactor, minSpeed, maxSpeed)
        
        if _G.flightSpeed < targetSpeed then
            _G.flightSpeed = math.min(_G.flightSpeed + speedStep, targetSpeed)
        elseif _G.flightSpeed > targetSpeed then
            _G.flightSpeed = math.max(_G.flightSpeed - speedStep, targetSpeed)
        end
        task.wait(1)
    end
end)

local function getOwnVehicle()
    local vehiclesFolder = Workspace:FindFirstChild("Vehicles")
    if not vehiclesFolder then return nil end

    local vehicle = vehiclesFolder:FindFirstChild(player.Name)
    if not vehicle or not vehicle:IsA("Model") then return nil end

    local driveSeat = vehicle:FindFirstChild("DriveSeat", true)
    if not driveSeat or not driveSeat:IsA("Seat") then return nil end

    if not vehicle.PrimaryPart then
        local body = vehicle:FindFirstChild("Body")
        local mass = body and body:FindFirstChild("Mass")

        if mass and mass:IsA("BasePart") then
            vehicle.PrimaryPart = mass
        else
            vehicle.PrimaryPart = driveSeat
        end
    end

    return vehicle, driveSeat
end

local function enterOwnCar()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")

    if not hum then return false end

    local vehicle, driveSeat = getOwnVehicle()
    if not vehicle or not driveSeat then return false end
    if hum.SeatPart == driveSeat then return true end

    if rootPart and (rootPart.Position - driveSeat.Position).Magnitude > 8 then
        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            AgentCanClimb = false,
            WaypointSpacing = 4
        })

        local success = pcall(function()
            path:ComputeAsync(rootPart.Position, driveSeat.Position)
        end)

        if success and path.Status == Enum.PathStatus.Success then
            for _, waypoint in ipairs(path:GetWaypoints()) do
                if hum.SeatPart == driveSeat then break end
                hum:MoveTo(waypoint.Position)
                if waypoint.Action == Enum.PathWaypointAction.Jump then
                    hum.Jump = true
                end
                hum.MoveToFinished:Wait()
            end
        else
            hum:MoveTo(driveSeat.Position)
            hum.MoveToFinished:Wait()
        end
    end

    if hum.SeatPart ~= driveSeat then
        driveSeat:Sit(hum)
        task.wait(0.5)
    end

    if hum.SeatPart ~= driveSeat and rootPart then
        rootPart.CFrame = driveSeat.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.2)
        driveSeat:Sit(hum)
        task.wait(0.5)
    end

    return hum.SeatPart == driveSeat
end

local function driveVehicleTo(destinationCFrame)
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    local vehicle, driveSeat = getOwnVehicle()
    if not vehicle or not driveSeat or not vehicle.PrimaryPart then return false end
    if not enterOwnCar() then return false end

    local primary = vehicle.PrimaryPart
    local targetPos = destinationCFrame.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {vehicle, char}

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not vehicle or not vehicle.Parent or not primary or not primary.Parent then
            if connection then connection:Disconnect() end
            return
        end

        if hum.SeatPart ~= driveSeat then
            driveSeat:Sit(hum)
        end

        local currentPos = primary.Position
        local offset = targetPos - currentPos
        local flatOffset = Vector3.new(offset.X, 0, offset.Z)

        if flatOffset.Magnitude < 15 then
            primary.AssemblyLinearVelocity = Vector3.zero
            primary.AssemblyAngularVelocity = Vector3.zero
            vehicle:PivotTo(destinationCFrame)
            connection:Disconnect()
            return
        end

        local direction = offset.Magnitude > 0.01 and offset.Unit or Vector3.new(0, 0, 1)
        local flatDirection = Vector3.new(direction.X, 0, direction.Z)
        local lookDirection = flatDirection.Magnitude > 0.01 and flatDirection.Unit or Vector3.new(1, 0, 0)

        vehicle:PivotTo(CFrame.lookAt(currentPos, currentPos + lookDirection))

        local rayOrigin = currentPos + Vector3.new(0, 2, 0)
        local rayResult = Workspace:Raycast(rayOrigin, lookDirection * 30, raycastParams)

        if rayResult and rayResult.Normal.Y < 0.7 then
            primary.AssemblyLinearVelocity = Vector3.new(
                lookDirection.X * moveSpeed,
                120,
                lookDirection.Z * moveSpeed
            )
        else
            primary.AssemblyLinearVelocity = direction * moveSpeed
        end

        primary.AssemblyAngularVelocity = Vector3.zero
    end)

    return true
end

local function frameTween(targetCF)
    if driveVehicleTo(targetCF) then return true end

    local char = player.Character or player.CharacterAdded:Wait()
    local rootPart = char:FindFirstChild("HumanoidRootPart")

    if rootPart then
        rootPart.CFrame = targetCF + Vector3.new(0, 3, 0)
        return true
    end

    return false
end

local function teleportButton(targetPos)
    local tCFrame = CFrame.new(targetPos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local vFolder = workspace:FindFirstChild("Vehicles")
    local v = vFolder and vFolder:FindFirstChild(player.Name)

    if v and v:IsA("Model") then
        if not v.PrimaryPart then 
            local ds = v:FindFirstChild("DriveSeat")
            if ds and ds:IsA("BasePart") then v.PrimaryPart = ds end 
        end
        frameTween(tCFrame + Vector3.new(0,1,0))
    else
        if hrp then hrp.CFrame = tCFrame + Vector3.new(0,3,0) end
    end
end

local function getToCarAndDrive()
    return driveVehicleTo(targetCFrame)
end

local Tab4 = Window:MakeTab({ Name = "🌀| Teleport", PremiumOnly = false })

Tab4:AddToggle({
    Name = "🔵 Auto Navigation (Map Tracker)",
    Default = false,
    Callback = function(Value)
        _G.AutoNavEnabled = Value
    end
})

local NavLocations = {
    ["Police Station"] = CFrame.new(-1658.55, 5.619, 2735.71),
    ["Fire Station"] = CFrame.new(-963.32, 5.865, 3895.37),
    ["Bus Company"] = CFrame.new(-1695.8, 5.882, -1274.29),
    ["Truck Company"] = CFrame.new(652.55, 5.638, 1510.85),
    ["Bank"] = CFrame.new(-1174.68, 5.87, 3209.03),
    ["Jeweler"] = CFrame.new(-346.63, 5.87, 3572.74),
    ["Ares Fuel"] = CFrame.new(-870.86, 5.622, 1505.16),
    ["Gas-N-Go Fuel"] = CFrame.new(-1544.4, 5.619, 3802.16),
    ["Osso Fuel"] = CFrame.new(-27.55, 5.622, -754.6),
    ["Club"] = CFrame.new(-1844.95, 5.872, 3211.08),
    ["Tool Shop"] = CFrame.new(-717.23, 5.654, 729.08),
    ["Farm Shop"] = CFrame.new(-911.5, 5.371, -1169.2),
    ["Clothing Store"] = CFrame.new(479.05, 3.158, -1452.59),
    ["Tuning Garage"] = CFrame.new(-1429.04, 5.57, 143.96),
    ["Dealership"] = CFrame.new(-1454.02, 5.615, 940.83),
    ["Hospital"] = CFrame.new(-293.16, 5.627, 1053.98),
    ["Prison"] = CFrame.new(-514.34, 5.615, 2795.94),
    ["HARS"] = CFrame.new(-295.056, 3.574, 515.761)
}

task.spawn(function()
    while true do
        task.wait(1)
        if not _G.AutoNavEnabled or isTeleporting then continue end
        local playerGui = player:FindFirstChild("PlayerGui")
        local targetGui = nil
        if playerGui then
            for _, gui in ipairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.DisplayOrder == 32 then
                    targetGui = gui
                    break
                end
            end
        end
        if targetGui and targetGui.Enabled then
            local container = targetGui:FindFirstChildOfClass("Frame")
            local navMap = container and container:FindFirstChild("NavigationMap")
            if navMap then
                for _, btn in ipairs(navMap:GetChildren()) do
                    if btn:IsA("ImageButton") then
                        local color = btn.ImageColor3
                        if math.floor(color.R*255)==255 and math.floor(color.G*255)==255 and math.floor(color.B*255)==255 then
                            local label = btn:FindFirstChildOfClass("TextLabel")
                            if label and NavLocations[label.ContentText] then
                                isTeleporting = true
                                pcall(function() frameTween(NavLocations[label.ContentText]) end)
                                isTeleporting = false
                                task.wait(2)
                            end
                        end
                    end
                end
            end
        end
    end
end)

Tab4:AddButton({
    Name = "🔵 Teleport to Nearest Dealer",
    Callback = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local v = workspace.Vehicles:FindFirstChild(player.Name)
        if not v then return end
        local dealers = workspace:FindFirstChild("Dealers")
        if not dealers then return end
        local closest, shortest = nil, math.huge
        for _, dealer in pairs(dealers:GetChildren()) do
            if dealer:FindFirstChild("Head") then
                local dist = (char.HumanoidRootPart.Position - dealer.Head.Position).Magnitude
                if dist < shortest then 
                    shortest = dist
                    closest = dealer.Head 
                end
            end
        end
        if not closest then return end
        frameTween(closest.CFrame + Vector3.new(0,5,0))
    end
})

Tab4:AddButton({
    Name = "🔵 Vending Machine",
    Callback = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local v = workspace.Vehicles:FindFirstChild(player.Name)
        local machines = workspace:FindFirstChild("Robberies") and workspace.Robberies:FindFirstChild("VendingMachines")
        if not v or not machines then return end
        local closest, shortest = nil, math.huge
        for _, model in pairs(machines:GetChildren()) do
            for _, part in pairs(model:GetChildren()) do
                if part:IsA("Part") and part.Color == Color3.fromRGB(73,147,0) then
                    local dist = (char.HumanoidRootPart.Position - part.Position).Magnitude
                    if dist < shortest then 
                        shortest = dist
                        closest = part 
                    end
                end
            end
        end
        if not closest then 
            if OrionLib then
                OrionLib:MakeNotification({Name="Not Founded",Content="Robbable Vending Machine not Founded",Image="rbxassetid://4483345998",Time=5})
            end
            return 
        end
        frameTween(closest.CFrame)
    end
})

Tab4:AddButton({ 
    Name = "🔵 Robbery Bank (OP)", 
    Callback = function() 
        teleportButton(Vector3.new(-1201.792480, 9.034365, 3150.516846)) 
    end 
})

Tab4:AddButton({ 
    Name = "🔵 Robbery Juwe (OP)", 
    Callback = function() 
        teleportButton(Vector3.new(-435.869904, 21.250017, 3559.450928)) 
    end 
})

Tab4:AddDropdown({
    Name = "🔵 Normal Places", 
    Default = "1",
    Options = {"Prison Out","Prison In","Police","Tuning Garage","Hospital","Tuner","Dealership","Fire Station","Smuggler (near clothing store)","Truck Company","Bus Company"},
    Callback = function(Value)
        local locations = {
            ["Prison Out"]=CFrame.new(-615.5797729492188,5.289504051208496,2862.23681640625),
            ["Prison In"]=CFrame.new(-572.1055297851562,6.382352352142334,3061.3740234375),
            ["Police"]=CFrame.new(-1658.071899,5.63,2737.27),
            ["Tuning Garage"]=CFrame.new(-1438.654053,5.63,118.45),
            ["Fire Station"]=CFrame.new(-1025.360595703125,4.500086784362793,3899.155029296875),
            ["Truck Company"]=CFrame.new(704.4508666992188,4.229461669921875,1479.9267578125),
            ["Smuggler (near clothing store)"]=CFrame.new(796.5571899414062,-18.67022705078125,-1526.3787841796875),
            ["Tuner"]=CFrame.new(-1438.34705,5.35521317,171.125198,0.0264777429,0.0146148987,0.999542534,-0.0202042889,0.999696672,-0.0140819438,-0.9994452,-0.0198221896,0.0267649963),
            ["Bus Company"]=CFrame.new(-1682.2969970703125,8.779464721679688,-1273.07763671875),
            ["Hospital"]=CFrame.new(-278.833740234375,7.7454142570495605,1085.7965087890625),
            ["Dealership"]=CFrame.new(-1415.6986083984375,4.552238464355469,940.5262451171875),
        }
        local tCF = locations[Value]
        if not tCF then return end
        local v = workspace:FindFirstChild("Vehicles") and workspace.Vehicles:FindFirstChild(player.Name)
        if not v or not v:IsA("Model") then return end
        frameTween(tCF)
    end
})

Tab4:AddDropdown({
    Name = "🔵 Robbery Places", 
    Default = "1",
    Options = {"Bank","Jewellery","Erwin Club","Gas-N-Go Fuel","Ares Fuel","Tool Shop","Farm Shop","Osso Fuel","Container Ship","Clothing Store"},
    Callback = function(Value)
        local locations = {
            ["Bank"]=CFrame.new(-1183.296,10.912,3228.297), 
            ["Jewellery"]=CFrame.new(-407.536,21.950,3516.854),
            ["Erwin Club"]=CFrame.new(-1856.962,5.706,2990.518), 
            ["Gas-N-Go Fuel"]=CFrame.new(-1560.674,3.944,3813.656),
            ["Ares Fuel"]=CFrame.new(-824.447,4.182,1512.941), 
            ["Tool Shop"]=CFrame.new(-767.815,4.374,663.494),
            ["Farm Shop"]=CFrame.new(-887.220,5.831,-1150.356), 
            ["Osso Fuel"]=CFrame.new(-27.464,5.245,-749.413),
            ["Container Ship"]=CFrame.new(1191.836,29.550,2140.703), 
            ["Clothing Store"]=CFrame.new(440.400,5.520,-1438.111),
        }
        local tCF = locations[Value]
        if not tCF then return end
        local v = workspace:FindFirstChild("Vehicles") and workspace.Vehicles:FindFirstChild(player.Name)
        if not v or not v:IsA("Model") then return end
        frameTween(tCF)
    end
})

getToCarAndDrive()


-- ==================== TAB6: CAR ====================
Tab6 = Window:MakeTab({ Name = "🛺| Car", Icon = "", PremiumOnly = false })

Tab6:AddButton({
    Name = "🟢 Mobile Car Fly",
    Callback = function()
        local flightEnabled2 = false
        local kmhToSpeed = 7.77
        local flightSpeed2 = 150 * kmhToSpeed
        local moveUp, moveDown, moveLeft, moveRight = false,false,false,false
        local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
        local frame = Instance.new("Frame", screenGui)
        frame.Size = UDim2.new(0,150,0,180); frame.Position = UDim2.new(0.5,-75,0.5,-90)
        frame.BackgroundColor3 = Color3.fromRGB(30,30,30); frame.BackgroundTransparency = 0.3
        frame.Active = true; frame.Draggable = true; frame.AnchorPoint = Vector2.new(0.5,0.5)
        local toggle = Instance.new("TextButton", frame)
        toggle.Size = UDim2.new(1,-20,0,35); toggle.Position = UDim2.new(0,10,0,10)
        toggle.BackgroundColor3 = Color3.fromRGB(180,0,0); toggle.Text = "Car Fly OFF"
        toggle.TextColor3 = Color3.new(1,1,1); toggle.Font = Enum.Font.SourceSansBold; toggle.TextSize = 18; toggle.AutoButtonColor = false
        toggle.MouseButton1Click:Connect(function()
            flightEnabled2 = not flightEnabled2
            toggle.Text = flightEnabled2 and "Car Fly ON" or "Car Fly OFF"
            toggle.BackgroundColor3 = flightEnabled2 and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
        end)
        local function createArrow(text, pos)
            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(0,40,0,40); btn.Position = pos
            btn.BackgroundColor3 = Color3.fromRGB(50,50,50); btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 28; btn.Text = text; btn.AutoButtonColor = false
            return btn
        end
        local btnUp = createArrow("↑", UDim2.new(0.5,-20,0,55))
        local btnDown = createArrow("↓", UDim2.new(0.5,-20,0,110))
        local btnLeft = createArrow("←", UDim2.new(0.22,-20,0,82))
        local btnRight = createArrow("→", UDim2.new(0.78,-20,0,82))
        btnUp.MouseButton1Down:Connect(function() moveUp=true end); btnUp.MouseButton1Up:Connect(function() moveUp=false end); btnUp.MouseLeave:Connect(function() moveUp=false end)
        btnDown.MouseButton1Down:Connect(function() moveDown=true end); btnDown.MouseButton1Up:Connect(function() moveDown=false end); btnDown.MouseLeave:Connect(function() moveDown=false end)
        btnLeft.MouseButton1Down:Connect(function() moveLeft=true end); btnLeft.MouseButton1Up:Connect(function() moveLeft=false end); btnLeft.MouseLeave:Connect(function() moveLeft=false end)
        btnRight.MouseButton1Down:Connect(function() moveRight=true end); btnRight.MouseButton1Up:Connect(function() moveRight=false end); btnRight.MouseLeave:Connect(function() moveRight=false end)
        local lastPos2, lastLook2 = nil, nil
        RunService.RenderStepped:Connect(function()
            if not flightEnabled2 then lastPos2,lastLook2=nil,nil; return end
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or not hum.SeatPart or hum.SeatPart.Name ~= "DriveSeat" then return end
            local v2 = hum.SeatPart.Parent
            if not v2.PrimaryPart then v2.PrimaryPart = hum.SeatPart end
            local lookVector = workspace.CurrentCamera.CFrame.LookVector
            local rightVector = lookVector:Cross(Vector3.new(0,1,0)).Unit
            if not lastPos2 then lastPos2 = v2.PrimaryPart.Position end
            if not lastLook2 then lastLook2 = lookVector end
            local moveY2 = (moveUp and 1) or (moveDown and -1) or 0
            local moveX2 = (moveRight and 1) or (moveLeft and -1) or 0
            local speedMult = flightSpeed2/100
            local targetPos = v2.PrimaryPart.Position + lookVector*moveY2*speedMult + rightVector*moveX2*speedMult
            local newPos = lastPos2:Lerp(targetPos, 0.3)
            local smoothLook = lastLook2:Lerp(lookVector, 0.2)
            if moveX2~=0 or moveY2~=0 then v2:SetPrimaryPartCFrame(CFrame.new(newPos, newPos+smoothLook))
            else v2:SetPrimaryPartCFrame(CFrame.new(v2.PrimaryPart.Position, v2.PrimaryPart.Position+smoothLook)) end
            lastPos2=newPos; lastLook2=smoothLook
            for _, part in pairs(v2:GetDescendants()) do
                if part:IsA("BasePart") then part.AssemblyLinearVelocity=Vector3.zero; part.AssemblyAngularVelocity=Vector3.zero; part.Velocity=Vector3.zero; part.RotVelocity=Vector3.zero end
            end
        end)
    end
})

-- Car Fly vars
local flightEnabled = false
local baseFlightSpeed = 150
local kmhToSpeed = 7.77
local flightSpeed = baseFlightSpeed * kmhToSpeed
local LP = game.Players.LocalPlayer
local U_S_I = game:GetService("UserInputService")
local flingActive = false
local shouldFling = false
local lastUpdateTime = tick()
local exitThreadRunning = false
local safeFlyEnabled = true
local POSITION_LERP_ALPHA = 0.3
local ROTATION_LERP_ALPHA = 0.2
local lastCarPosition = nil
local lastCarLookVector = nil
local straightFlightStartTime = nil
local STRAIGHT_FLIGHT_DURATION = 1
local hasShiftedRight = false
local SHIFT_DISTANCE = 10
local vehicleFlingEnabled = false
local flingStartTime = 0
local FLING_DELAY = 0.6
local hasPerformedSingleExit = false
local singleExitCompleted = false

local function enterVehicle()
    return enterOwnCar()
end

local safeFlyConnection
local lastForceEnterTime = 0
local FORCE_ENTER_COOLDOWN = 0.2
local singleExitTimerStarted = false

local function performSingleExit()
    if singleExitCompleted or not safeFlyEnabled or not flightEnabled or vehicleFlingEnabled then return end
    local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart.Name == "DriveSeat" then
        hasPerformedSingleExit = true
        hum.Sit = false; hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.delay(0.2, function()
            if safeFlyEnabled and flightEnabled and not vehicleFlingEnabled then enterVehicle(); singleExitCompleted = true end
        end)
    end
end

local function startSafeFly()
    if safeFlyConnection then return end
    singleExitCompleted=false; hasPerformedSingleExit=false; singleExitTimerStarted=false
    safeFlyConnection = RunService.Heartbeat:Connect(function()
        if safeFlyEnabled and flightEnabled and not vehicleFlingEnabled then
            local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            local currentTime = tick()
            if hum then
                if not singleExitTimerStarted and not hasPerformedSingleExit then singleExitTimerStarted=true; task.delay(3, performSingleExit) end
                if not hum.SeatPart or hum.SeatPart.Name ~= "DriveSeat" then
                    if (currentTime - lastForceEnterTime) > FORCE_ENTER_COOLDOWN then
                        lastForceEnterTime = currentTime
                        if not enterVehicle() then task.wait(0.1); enterVehicle() end
                    end
                end
            end
        end
    end)
end

local function stopSafeFly()
    if safeFlyConnection then safeFlyConnection:Disconnect(); safeFlyConnection = nil end
    hasPerformedSingleExit=false; singleExitCompleted=false; singleExitTimerStarted=false
end

local function updateFlightState()
    if flightEnabled then startSafeFly() else stopSafeFly() end
end

local function sitInCar()
    return enterOwnCar()
end

local function getOutCar()
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum and hum.SeatPart then hum.Sit=false; task.wait(0.01); return true end
    return false
end

local function startAutoExitThread()
    if exitThreadRunning then return end
    exitThreadRunning = true
    task.spawn(function()
        while flightEnabled and not vehicleFlingEnabled and exitThreadRunning do
            for i=1,500 do
                if not flightEnabled or vehicleFlingEnabled or not exitThreadRunning then break end
                task.wait(0.01)
            end
            if flightEnabled and not vehicleFlingEnabled and exitThreadRunning and LP.Character and LP.Character:FindFirstChildWhichIsA("Humanoid") then
                if LP.Character.Humanoid.Sit then getOutCar(); task.wait(0.1); sitInCar() end
            end
        end
        exitThreadRunning = false
    end)
end

local function stopAutoExitThread() exitThreadRunning = false end
local function updateAutoExitTimer()
    if flightEnabled and not vehicleFlingEnabled then startAutoExitThread() else stopAutoExitThread() end
end

-- Fling physics
RunService.Heartbeat:Connect(function()
    if vehicleFlingEnabled then
        local c = LP.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h and h.SeatPart and h:GetState() == Enum.HumanoidStateType.Seated then
                flingActive = true
                if (tick() - flingStartTime) >= FLING_DELAY then
                    local hrp = c:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        for _, part in pairs(hrp:GetTouchingParts()) do
                            if part:IsA("BasePart") and part:IsDescendantOf(Workspace) and not part:IsDescendantOf(LP) then
                                hrp.AssemblyLinearVelocity = -(part.Position - hrp.Position).Unit * 9999999; break
                            end
                        end
                    end
                end
            else flingActive = false end
        else flingActive = false end
    else flingActive = false end
end)

RunService.Heartbeat:Connect(function()
    if not shouldFling then return end
    local c = LP.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    if not h.SeatPart or h.SeatPart.Name ~= "DriveSeat" then
        flingActive = false
        local vf = Workspace:FindFirstChild("Vehicles")
        local v = vf and vf:FindFirstChild(LP.Name)
        if v then
            local s = v:FindFirstChild("DriveSeat") or v:FindFirstChildWhichIsA("VehicleSeat")
            if s then h.Sit=false; task.wait(0.1); s:Sit(h) end
        end
    else
        flingActive = true
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, part in pairs(hrp:GetTouchingParts()) do
                if part:IsA("BasePart") and part:IsDescendantOf(Workspace) and not part:IsDescendantOf(LP) then
                    hrp.AssemblyLinearVelocity = -(part.Position - hrp.Position).Unit * 99999999; break
                end
            end
        end
    end
end)

-- Car Fly logic
RunService.RenderStepped:Connect(function(deltaTime)
    local character2 = LP.Character
    if vehicleFlingEnabled then flightEnabled = true end
    if flightEnabled and character2 then
        local hum = character2:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart and hum.SeatPart.Name == "DriveSeat" then
            local seat2 = hum.SeatPart
            local v = seat2.Parent
            if not v.PrimaryPart then v.PrimaryPart = seat2 end
            local cam = Workspace.CurrentCamera
            if not cam then return end
            local lookVector = cam.CFrame.LookVector
            if not lastCarPosition then lastCarPosition = v.PrimaryPart.Position end
            if not lastCarLookVector then lastCarLookVector = lookVector end
            local moveY2 = U_S_I:IsKeyDown(Enum.KeyCode.W) and 1 or U_S_I:IsKeyDown(Enum.KeyCode.S) and -1 or 0
            local moveZ2 = U_S_I:IsKeyDown(Enum.KeyCode.E) and 1 or U_S_I:IsKeyDown(Enum.KeyCode.Q) and -1 or 0
            local isFlyingStraight = U_S_I:IsKeyDown(Enum.KeyCode.W) and not U_S_I:IsKeyDown(Enum.KeyCode.S) and not U_S_I:IsKeyDown(Enum.KeyCode.E) and not U_S_I:IsKeyDown(Enum.KeyCode.Q) and not U_S_I:IsKeyDown(Enum.KeyCode.A) and not U_S_I:IsKeyDown(Enum.KeyCode.D)
            local ct = tick()
            if isFlyingStraight then
                if not straightFlightStartTime then straightFlightStartTime = ct end
                if not hasShiftedRight and (ct - straightFlightStartTime) >= STRAIGHT_FLIGHT_DURATION then
                    local rightVector = lookVector:Cross(Vector3.new(0,1,0)).Unit
                    local shiftPos = v.PrimaryPart.Position + (rightVector * SHIFT_DISTANCE)
                    v:SetPrimaryPartCFrame(CFrame.new(shiftPos, shiftPos+lookVector))
                    lastCarPosition = shiftPos; hasShiftedRight = true
                end
            else straightFlightStartTime = nil; hasShiftedRight = false end
            local speedMult = flightSpeed/100
            local targetPos = v.PrimaryPart.Position + (lookVector*moveY2*speedMult) + (Vector3.new(0,1,0)*moveZ2*speedMult)
            local newPos = lastCarPosition:Lerp(targetPos, POSITION_LERP_ALPHA)
            local smoothLook = lastCarLookVector:Lerp(lookVector, ROTATION_LERP_ALPHA)
            if moveY2~=0 or moveZ2~=0 then v:SetPrimaryPartCFrame(CFrame.new(newPos, newPos+smoothLook))
            else v:SetPrimaryPartCFrame(CFrame.new(v.PrimaryPart.Position, v.PrimaryPart.Position+smoothLook)) end
            lastCarPosition=newPos; lastCarLookVector=smoothLook
            for _, part in pairs(v:GetDescendants()) do
                if part:IsA("BasePart") then part.AssemblyLinearVelocity=Vector3.zero; part.AssemblyAngularVelocity=Vector3.zero; part.Velocity=Vector3.zero; part.RotVelocity=Vector3.zero end
            end
        else lastCarPosition=nil; lastCarLookVector=nil; straightFlightStartTime=nil; hasShiftedRight=false end
    else lastCarPosition=nil; lastCarLookVector=nil; straightFlightStartTime=nil; hasShiftedRight=false end
end)

local function updateFlightSpeed(newSpeed)
    baseFlightSpeed = newSpeed
    flightSpeed = baseFlightSpeed * kmhToSpeed
end

local speedLabel = nil

if Tab6 then
    Tab6:AddToggle({
        Name = "🟢 Car Fly", Default = false,
        Callback = function(Value)
            flightEnabled = vehicleFlingEnabled or Value
            updateFlightState()
            if flightEnabled then startAutoExitThread() else stopAutoExitThread() end
        end
    })
    Tab6:AddToggle({
        Name = "🟢 Safe Fly", Default = true,
        Callback = function(Value)
            safeFlyEnabled = Value; updateFlightState()
            if safeFlyEnabled and flightEnabled then startAutoExitThread() else stopAutoExitThread() end
        end
    })
    Tab6:AddToggle({
        Name = "🟢 Vehicle Fling", Default = false,
        Callback = function(value)
            vehicleFlingEnabled = value
            if value then flightEnabled=true; flingStartTime=tick(); updateFlightState(); shouldFling=true; stopAutoExitThread()
            else shouldFling=false; updateAutoExitTimer() end
        end
    })
    Tab6:AddSlider({
        Name = "🚀 Fluggeschwindigkeit", Min = 20, Max = 300, Default = 95,
        Color = Color3.fromRGB(0,255,0), Increment = 1, ValueName = "km/h",
        Callback = function(Value) updateFlightSpeed(Value) end
    })
    speedLabel = Tab6:AddLabel("Aktuelle Geschwindigkeit: 150 km/h")
end

local function updateSpeedLabel()
    if speedLabel then speedLabel:Set("Aktuelle Geschwindigkeit: "..math.floor(baseFlightSpeed).." km/h") end
end

U_S_I.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.X then
            flightEnabled = not flightEnabled
            if flightEnabled then sitInCar(); updateAutoExitTimer(); updateFlightState()
            else stopAutoExitThread(); updateFlightState() end
        elseif input.KeyCode == Enum.KeyCode.R and flightEnabled then
            updateFlightSpeed(math.min(baseFlightSpeed+10,300)); updateSpeedLabel()
        elseif input.KeyCode == Enum.KeyCode.F and flightEnabled then
            updateFlightSpeed(math.max(baseFlightSpeed-10,20)); updateSpeedLabel()
        end
    end
end)

Tab6:AddSection({ Name = "Car-Mods" })

function bringCarToPlayer()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 2)
    local car = workspace:FindFirstChild("Vehicles") and workspace.Vehicles:FindFirstChild(player.Name)
    if car and root then
        local s = car:FindFirstChild("DriveSeat", true)
        if not s then OrionLib:MakeNotification({Title="❌ Kein Sitz",Content="DriveSeat nicht gefunden",Duration=4}); return end
        car.PrimaryPart = s
        car:SetPrimaryPartCFrame(CFrame.new(root.Position + root.CFrame.LookVector*10, root.Position))
        task.wait(0.5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then s:Sit(hum) end
        OrionLib:MakeNotification({Title="✅ Auto gebracht",Content="Fahrzeug teleportiert.",Duration=4})
    else OrionLib:MakeNotification({Title="❌ Fehler",Content="Kein Fahrzeug gefunden.",Duration=4}) end
end

Tab6:AddButton({ Name = "🟢 Bring-Car", Callback = function() bringCarToPlayer() end })
Tab6:AddButton({
    Name = "🟢 Jump from Seat",
    Callback = function()
        local character3 = game.Players.LocalPlayer.Character
        if character3 and character3:FindFirstChild("Humanoid") then
            character3.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
})
Tab6:AddButton({
    Name = "🟢 Sit in Car",
    Callback = function()
        local car = workspace:FindFirstChild("Vehicles") and workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
        if not car or not car:FindFirstChild("DriveSeat", true) then return end
        local ds = car:FindFirstChild("DriveSeat", true)
        car.PrimaryPart = ds
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            ds:Sit(LocalPlayer.Character.Humanoid)
        end
    end
})

Tab6:AddToggle({
    Name = "🟢 Anti Crash Damage", CurrentValue = false, Save = true, Flag = "AntiCrashDamageToggle",
    Callback = function(enabled)
        vehiclesFolder = workspace:FindFirstChild("Vehicles")
        if not vehiclesFolder then return end
        vehicle = vehiclesFolder:FindFirstChild(player.Name)
        if not vehicle then return end
        vehicle:SetAttribute("IsBeingTowed", enabled)
    end
})

Tab6:AddParagraph("Fling INFO","ONLY IN CAR FLY")

player = game:GetService("Players").LocalPlayer
RunService = game:GetService("RunService")
vehicleGodMode = false
lastVehicle = nil

RunService.Heartbeat:Connect(function()
    if not vehicleGodMode then return end
    if not lastVehicle or not lastVehicle.Parent then
        lastVehicle = vehiclesFolder and vehiclesFolder:FindFirstChild(player.Name)
    end
    if lastVehicle then
        lastVehicle:SetAttribute("IsOn", true)
        lastVehicle:SetAttribute("currentHealth", 500)
        lastVehicle:SetAttribute("currentFuel", math.huge)
    end
end)

Tab6:AddToggle({
    Name = "🟢 Car-Godmode", CurrentValue = false, Flag = "CarGodModeToggle",
    Callback = function(Value) vehicleGodMode = Value; if not Value then lastVehicle = nil end end
})

local GhostEnabled = false
local lastColor = nil

local function changeCarToGhost(s2)
    local car = workspace.Vehicles:FindFirstChild(game.Players.LocalPlayer.Name)
    if not car then return end
    local bodyFolder = car:FindFirstChild("Body")
    if not bodyFolder then return end
    local part = bodyFolder:FindFirstChild("Body") or bodyFolder:FindFirstChild("Main")
    if not part or not part:IsA("MeshPart") then return end
    if s2 then
        if not lastColor then lastColor = part.Color end
        part.Material = Enum.Material.ForceField; part.Color = Color3.fromRGB(29,53,53)
    else part.Material = Enum.Material.SmoothPlastic end
end

Tab6:AddToggle({ Name = "🟢 Car Ghost", Default = false, Callback = function(Value) GhostEnabled = Value; changeCarToGhost(Value) end })

Tab6:AddButton({
    Name = "🟢 Tire/Reifen Repair",
    Callback = function()
        local pName = player.Name
        local vf2 = workspace:FindFirstChild("Vehicles")
        if not vf2 then return end
        local playerFolder = vf2:FindFirstChild(pName)
        if not playerFolder then return end
        local body = playerFolder:FindFirstChild("Body")
        if not body then return end
        local wheels = body:FindFirstChild("Wheels")
        if not wheels then return end
        local myConfig = playerFolder:GetAttribute("Config")
        local function isUUID2(name) return name:match("^[0-9a-f%-]+$") and #name == 36 end
        local function getFallbackTire(tireName) local fb={FL="FR",FR="FL",RL="RR",RR="RL"}; return fb[tireName] or tireName end
        local function findTemplateTire(tireName)
            local myWheel = wheels:FindFirstChild(tireName)
            if myWheel and myWheel:FindFirstChild("Tire") then return myWheel.Tire end
            for _, vehicleModel in ipairs(vf2:GetChildren()) do
                if vehicleModel == playerFolder or isUUID2(vehicleModel.Name) then continue end
                if vehicleModel:GetAttribute("Config") ~= myConfig then continue end
                local b2 = vehicleModel:FindFirstChild("Body")
                local w2 = b2 and b2:FindFirstChild("Wheels")
                local wheel = w2 and w2:FindFirstChild(tireName)
                if wheel and wheel:FindFirstChild("Tire") then return wheel.Tire end
            end
            local fallbackName = getFallbackTire(tireName)
            for _, vehicleModel in ipairs(vf2:GetChildren()) do
                if vehicleModel == playerFolder or isUUID2(vehicleModel.Name) then continue end
                if vehicleModel:GetAttribute("Config") ~= myConfig then continue end
                local b2 = vehicleModel:FindFirstChild("Body")
                local w2 = b2 and b2:FindFirstChild("Wheels")
                local wheel = w2 and w2:FindFirstChild(fallbackName)
                if wheel and wheel:FindFirstChild("Tire") then return wheel.Tire end
            end
            local targetSize = Vector3.new(1.997,1.997,1.997)
            local closest, closestDist = nil, math.huge
            for _, vehicleModel in ipairs(vf2:GetChildren()) do
                if vehicleModel == playerFolder or isUUID2(vehicleModel.Name) then continue end
                local b2 = vehicleModel:FindFirstChild("Body")
                local w2 = b2 and b2:FindFirstChild("Wheels")
                if w2 then
                    for _, wheel in ipairs(w2:GetChildren()) do
                        local tire = wheel:FindFirstChild("Tire")
                        local main = tire and tire:FindFirstChild("Main")
                        if main then
                            local dist = (main.Size - targetSize).Magnitude
                            if dist < closestDist then closestDist=dist; closest=tire end
                        end
                    end
                end
            end
            return closest
        end
        for _, wheel in ipairs(wheels:GetChildren()) do
            if wheel:FindFirstChild("Rim") and not wheel:FindFirstChild("Tire") then
                local templateTire = findTemplateTire(wheel.Name)
                if not templateTire then continue end
                local clonedTire = templateTire:Clone()
                clonedTire.Parent = wheel
                local rigidConstraint = clonedTire:FindFirstChild("RigidConstraint")
                local tireMain = clonedTire:FindFirstChild("Main")
                local rimMain = wheel.Rim.Main
                rigidConstraint.Attachment0 = tireMain.Connector
                rigidConstraint.Attachment1 = rimMain.Connector
                local templateMain = templateTire.Main
                if templateMain then tireMain.Size=templateMain.Size; tireMain.CustomPhysicalProperties=templateMain.CustomPhysicalProperties end
            end
        end
        local referenceWheel = nil
        for _, wheelPart in ipairs(wheels:GetChildren()) do
            if wheelPart:IsA("BasePart") and wheelPart.CustomPhysicalProperties then referenceWheel=wheelPart; break end
        end
        if referenceWheel then
            local refCPP = referenceWheel.CustomPhysicalProperties
            local refSize = referenceWheel.Size
            for _, wheelPart in ipairs(wheels:GetChildren()) do
                if wheelPart:IsA("BasePart") then
                    wheelPart.CustomPhysicalProperties = PhysicalProperties.new(refCPP.Density,refCPP.Friction,refCPP.Elasticity,refCPP.FrictionWeight,refCPP.ElasticityWeight)
                    wheelPart.Size = refSize
                end
            end
        end
        playerFolder:SetAttribute("flatTires", "")
    end
})

Tab6:AddSection({ Name = "Drift Mode" })

local driftModeEnabled = false
local fakeGravity = -10
local driftVectorForces = {}

local function enableDriftMode()
    driftModeEnabled = true
    local v = workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
    if not v then return end
    local bodyPart = v:FindFirstChild("Body") and v.Body:FindFirstChild("Body")
    if not bodyPart or not bodyPart:IsA("BasePart") then return end
    if string.find(bodyPart.Name:lower(), "wheel") then return end
    local att = Instance.new("Attachment", bodyPart)
    local vf3 = Instance.new("VectorForce")
    vf3.Attachment0 = att; vf3.RelativeTo = Enum.ActuatorRelativeTo.World
    vf3.Force = Vector3.new(0, bodyPart.AssemblyMass*(workspace.Gravity-fakeGravity), 0); vf3.Parent = bodyPart
    table.insert(driftVectorForces, {attachment=att, vectorForce=vf3, part=bodyPart})
end
local function disableDriftMode()
    driftModeEnabled = false
    for _, data in ipairs(driftVectorForces) do
        if data.vectorForce then data.vectorForce:Destroy() end
        if data.attachment then data.attachment:Destroy() end
    end
    driftVectorForces = {}
end
local function updateDriftGravity()
    for _, data in ipairs(driftVectorForces) do
        if data.vectorForce and data.part then
            data.vectorForce.Force = Vector3.new(0, data.part.AssemblyMass*(workspace.Gravity-fakeGravity), 0)
        end
    end
end

Tab6:AddToggle({ Name = "🟡 Enable Drift Mode", Default = false, Callback = function(Value) if Value then enableDriftMode() else disableDriftMode() end end })
Tab6:AddSlider({ Name = "🟡 Drift Strength", Min = 1, Max = 10, Default = 5, Color = Color3.fromRGB(255,200,0), Increment = 1, ValueName = "", Callback = function(Value) fakeGravity = 25-((Value-1)/9)*60; updateDriftGravity() end })

local slidingEnabled = false
local slidingStrength = 5
local originalWheelSizes = {}

local function enableSliding()
    slidingEnabled = true
    local v = workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
    if not v then return end
    local rearWheels = {v:FindFirstChild("Body") and v.Body:FindFirstChild("Wheels") and v.Body.Wheels:FindFirstChild("RR"), v:FindFirstChild("Body") and v.Body:FindFirstChild("Wheels") and v.Body.Wheels:FindFirstChild("RL")}
    for _, wheel in ipairs(rearWheels) do
        if wheel and wheel:IsA("BasePart") then
            if not originalWheelSizes[wheel] then originalWheelSizes[wheel] = wheel.Size.X end
            local newSize = originalWheelSizes[wheel] - ((slidingStrength-1)/9)*(originalWheelSizes[wheel]-1.2)
            wheel.Size = Vector3.new(newSize, wheel.Size.Y, wheel.Size.Z)
        end
    end
end
local function disableSliding()
    slidingEnabled = false
    local v = workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
    if not v then return end
    local rearWheels = {v:FindFirstChild("Body") and v.Body:FindFirstChild("Wheels") and v.Body.Wheels:FindFirstChild("RR"), v:FindFirstChild("Body") and v.Body:FindFirstChild("Wheels") and v.Body.Wheels:FindFirstChild("RL")}
    for _, wheel in ipairs(rearWheels) do
        if wheel and wheel:IsA("BasePart") and originalWheelSizes[wheel] then
            wheel.Size = Vector3.new(originalWheelSizes[wheel], wheel.Size.Y, wheel.Size.Z)
        end
    end
end
local function updateSlidingStrength()
    if not slidingEnabled then return end
    local v = workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
    if not v then return end
    local rearWheels = {v:FindFirstChild("Body") and v.Body:FindFirstChild("Wheels") and v.Body.Wheels:FindFirstChild("RR"), v:FindFirstChild("Body") and v.Body:FindFirstChild("Wheels") and v.Body.Wheels:FindFirstChild("RL")}
    for _, wheel in ipairs(rearWheels) do
        if wheel and wheel:IsA("BasePart") and originalWheelSizes[wheel] then
            local newSize = originalWheelSizes[wheel]-((slidingStrength-1)/9)*(originalWheelSizes[wheel]-1.2)
            wheel.Size = Vector3.new(newSize, wheel.Size.Y, wheel.Size.Z)
        end
    end
end

Tab6:AddToggle({ Name = "🟡 Enable Sliding", Default = false, Callback = function(Value) if Value then enableSliding() else disableSliding() end end })
Tab6:AddSlider({ Name = "🟡 Sliding Strength", Min = 1, Max = 10, Default = 5, Color = Color3.fromRGB(255,200,0), Increment = 1, ValueName = "", Callback = function(Value) slidingStrength=Value; updateSlidingStrength() end })

Tab6:AddSection({ Name = "Car-Tuning" })

local engineOpts = {"Default","V6 Engine","V8 Engine","V10 Engine","Electric Engine","Electric Engine 2","Funny Electric Engine","Mercedes AMG One Engine","Roblox Engine"}
local engineIds = {
    ["Default"]={e="rbxassetid://140685060",d="rbxassetid://358130654",s="rbxassetid://144126324"},
    ["V6 Engine"]={e="rbxassetid://113404171295712",d="rbxassetid://2057815938",s="rbxassetid://96066650287312"},
    ["V8 Engine"]={e="rbxassetid://7427073034",d="rbxassetid://8144394164",s="rbxassetid://96066650287312"},
    ["V10 Engine"]={e="rbxassetid://976645312",d="rbxassetid://8144394631",s="rbxassetid://96066650287312"},
    ["Electric Engine"]={e="rbxassetid://402899121",d="rbxassetid://1160914875",s="rbxassetid://268260239"},
    ["Electric Engine 2"]={e="rbxassetid://402899121",d="rbxassetid://9070018398",s="rbxassetid://268260239"},
    ["Funny Electric Engine"]={e="rbxassetid://402899121",d="rbxassetid://139592319059397",s="rbxassetid://268260239"},
    ["Mercedes AMG One Engine"]={e="rbxassetid://402899121",d="rbxassetid://101796349615590",s="rbxassetid://268260239"},
    ["Roblox Engine"]={e="rbxassetid://140685060",d="rbxassetid://6948077542",s="rbxassetid://144126324"},
}
local origSounds = {e={},d={},s={}}
for _,v in pairs(game:GetDescendants()) do
    if v:IsA("Sound") then
        local id = v.SoundId
        if id:match("140685060") then origSounds.e[v]=id
        elseif id:match("358130654") then origSounds.d[v]=id
        elseif id:match("144126324") then origSounds.s[v]=id end
    end
end
game.DescendantAdded:Connect(function(v)
    if v:IsA("Sound") then
        local id = v.SoundId
        if id:match("140685060") then origSounds.e[v]=id
        elseif id:match("358130654") then origSounds.d[v]=id
        elseif id:match("144126324") then origSounds.s[v]=id end
    end
end)

Tab6:AddDropdown({
    Name = "🟢 Engine Sound", Default = "Default", Options = engineOpts, Save = true, Flag = "EngineSoundDropdown",
    Callback = function(sel)
        local data = engineIds[sel]
        if sel == "Default" then
            for snd,oid in pairs(origSounds.e) do if snd and snd.Parent then snd.SoundId=oid end end
            for snd,oid in pairs(origSounds.d) do if snd and snd.Parent then snd.SoundId=oid end end
            for snd,oid in pairs(origSounds.s) do if snd and snd.Parent then snd.SoundId=oid end end
        elseif data then
            for snd in pairs(origSounds.e) do if snd and snd.Parent then snd.SoundId=data.e end end
            for snd in pairs(origSounds.d) do if snd and snd.Parent then snd.SoundId=data.d end end
            for snd in pairs(origSounds.s) do if snd and snd.Parent then snd.SoundId=data.s end end
        end
    end
})

Tab6:AddDropdown({
    Name = "🟢 Select Suspension Height", Default = "Default",
    Options = {"Extreme Low Rider","Low Rider","Default","Medium Suspension","Monster Suspension"},
    Save = true, Flag = "SuspensionHeightDropdown",
    Callback = function(SelectedOption)
        if typeof(SelectedOption) == "table" then SelectedOption = SelectedOption[1] end
        if typeof(SelectedOption) == "string" then
            local Character4 = game.Players.LocalPlayer.Character
            if Character4 then
                local Humanoid4 = Character4:FindFirstChild("Humanoid")
                if Humanoid4 then
                    local Seat4 = Humanoid4.SeatPart
                    if Seat4 and Seat4:IsA("Seat") then
                        local Springs = {}
                        for _, Child in pairs(Seat4:GetChildren()) do
                            if Child:IsA("SpringConstraint") and Child.Name:find("Spring") then table.insert(Springs, Child) end
                        end
                        if #Springs > 0 then
                            local SuspensionValues = {["Extreme Low Rider"]=1.2,["Low Rider"]=1.7,["Default"]=2,["Medium Suspension"]=4.23,["Monster Suspension"]=6}
                            if SuspensionValues[SelectedOption] then
                                for _, Spring in pairs(Springs) do Spring.FreeLength=SuspensionValues[SelectedOption] end
                                for _, Child in pairs(Seat4:GetChildren()) do
                                    if Child:IsA("RopeConstraint") and Child.Name:find("SafetyConstraint") then
                                        Child.Length = (SelectedOption == "Monster Suspension") and 2 or 0.7
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
})

-- Speed Boost
local boostEnabled = false
local boostConnection = nil
local speedValue = 250
local healthConn = nil
local originalMaxHealth = nil
local humanoidRef = nil

local function getCharacterParts()
    if not player.Character then return nil end
    local char = player.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso")
    return char, hum, hrp
end

local function startBoostEnforcer()
    if boostConnection then return end
    boostConnection = RunService.RenderStepped:Connect(function()
        if not boostEnabled then return end
        local _, hum, hrp = getCharacterParts()
        if hrp and hrp.Parent and boostEnabled then
            local forward = hrp.CFrame.LookVector
            local currentY = 0
            local ok, av = pcall(function() return hrp.AssemblyLinearVelocity end)
            if ok and type(av) == "Vector3" then currentY=av.Y else currentY=hrp.Velocity.Y end
            pcall(function()
                if hrp and hrp.Parent then hrp.AssemblyLinearVelocity = Vector3.new(forward.X*speedValue, currentY, forward.Z*speedValue)
                else hrp.Velocity = Vector3.new(forward.X*speedValue, currentY, forward.Z*speedValue) end
            end)
        end
    end)
end

local function stopBoostEnforcer()
    if boostConnection then pcall(function() boostConnection:Disconnect() end); boostConnection=nil end
end

local function enableNoDamage()
    if healthConn then pcall(function() healthConn:Disconnect() end); healthConn=nil end
    local _, hum, _ = getCharacterParts()
    if not hum then return end
    humanoidRef = hum
    originalMaxHealth = hum.MaxHealth
    pcall(function() hum.MaxHealth=math.max(hum.MaxHealth,100000); hum.Health=hum.MaxHealth end)
    healthConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
        pcall(function() if hum and hum.Parent and hum.Health < hum.MaxHealth then hum.Health=hum.MaxHealth end end)
    end)
end

local function disableNoDamage()
    if healthConn then pcall(function() healthConn:Disconnect() end); healthConn=nil end
    if humanoidRef and humanoidRef.Parent and originalMaxHealth then
        pcall(function() humanoidRef.MaxHealth=originalMaxHealth; humanoidRef.Health=math.clamp(humanoidRef.Health,0,humanoidRef.MaxHealth) end)
    end
    humanoidRef=nil; originalMaxHealth=nil
end

local function enableSafeSpeedBoost(val)
    boostEnabled = val
    if val then startBoostEnforcer(); enableNoDamage() else stopBoostEnforcer(); disableNoDamage() end
end

player.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    if boostEnabled then enableNoDamage() end
end)

Tab6:AddToggle({
    Name = "🟢 Speed Boost (Safe Mode)", CurrentValue = false, Flag = "BoostToggle",
    Callback = function(Value)
        enableSafeSpeedBoost(Value)
        pcall(function() OrionLib:MakeNotification({Title="Boost",Content=Value and "Boost aktiviert (Kein Schaden)" or "Boost deaktiviert",Duration=2}) end)
    end
})
Tab6:AddSlider({
    Name = "🟢 Boost Speed", Min = 0, Max = 300, Default = 5,
    Color = Color3.fromRGB(0,255,0), Increment = 1, ValueName = "KMH", CurrentValue = speedValue,
    Callback = function(value)
        speedValue = math.floor(tonumber(value) or speedValue)
        pcall(function() OrionLib:MakeNotification({Title="Speed",Content="Speed: "..tostring(speedValue),Duration=1}) end)
    end
})

local VehiclesFolder2 = workspace:FindFirstChild("Vehicles")
local sliderMoved = false
Tab6:AddSlider({
    Name = "🟢 Vehicle Height Standart/13", Min = 0.5, Max = 100, Default = 1.5,
    Color = Color3.fromRGB(0,255,0), Increment = 0.1, ValueName = "",
    Callback = function(Value)
        if not sliderMoved then sliderMoved=true; return end
        pcall(function()
            local v2 = VehiclesFolder2 and VehiclesFolder2:FindFirstChild(LocalPlayer.Name)
            if not v2 then return end
            local ds = v2:FindFirstChild("DriveSeat", true)
            if not ds then return end
            for _, ch in pairs(ds:GetChildren()) do
                if ch:IsA("SpringConstraint") then ch.LimitsEnabled=true; ch.MinLength=Value; ch.MaxLength=Value
                elseif ch:IsA("RopeConstraint") then ch.Length=Value end
            end
        end)
    end
})


-- ==================== TAB0: CAR COLORS ====================
Tab0 = Window:MakeTab({ Name = "🚓| Car Colors", Icon = "", PremiumOnly = false })

local rainbowSpeed = 5
local rainbowAktiv = false
local fahrzeugColor = Color3.fromRGB(255,255,255)

local function getRainbowColor(t) return Color3.fromHSV((t % rainbowSpeed)/rainbowSpeed, 1, 1) end
local function applyColorToVehicle(color)
    local v = workspace:WaitForChild("Vehicles"):FindFirstChild(player.Name)
    if v and v:IsA("Model") then
        for _, part in ipairs(v:GetDescendants()) do
            if part:IsA("BasePart") then part.Color=color; part.Material=Enum.Material.SmoothPlastic end
        end
    end
end
local function startRainbow()
    task.spawn(function()
        while rainbowAktiv do
            local v = workspace:WaitForChild("Vehicles"):FindFirstChild(player.Name)
            if v then applyColorToVehicle(getRainbowColor(tick())) end
            task.wait(0.1)
        end
    end)
end

Tab0:AddButton({
    Name = "🌈 Car Rainbow",
    Callback = function()
        rainbowAktiv = not rainbowAktiv
        if rainbowAktiv then startRainbow() else applyColorToVehicle(fahrzeugColor) end
    end
})

local function isRim(part)
    local name = part.Name:lower()
    return name:find("rim") or name:find("wheel") or name:find("reifen") or name:find("felge")
        or (part.Material == Enum.Material.Metal and part.Size.X < 3 and part.Size.Y < 3)
end

local function FindVehicle2()
    local vehicles = game:GetService("Workspace"):FindFirstChild("Vehicles")
    if not vehicles then return nil end
    return vehicles:FindFirstChild(game.Players.LocalPlayer.Name) or vehicles:FindFirstChild("Jaden9078201702")
end

local function updateCarColors(mainColor, rimColor)
    pcall(function()
        local car = FindVehicle2()
        if not car then return end
        for _, part in ipairs(car:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("UnionOperation") or part:IsA("MeshPart") then
                local partName = part.Name:lower()
                if partName:find("body") or partName:find("chassis") or partName:find("door") or partName:find("hood") or partName:find("trunk") or partName:find("fender") or partName:find("bumper") or partName:find("roof") then
                    part.Color = mainColor
                end
                if isRim(part) then part.Color = rimColor end
            end
        end
    end)
end

local function updateHeadlightsColor(lightColor)
    pcall(function()
        local car = FindVehicle2()
        if not car then return end
        for _, part in ipairs(car:GetDescendants()) do
            if (part:IsA("BasePart") or part:IsA("UnionOperation") or part:IsA("MeshPart")) and part.Name:lower() == "headlights" then
                part.Color = lightColor
            end
            if part:IsA("SpotLight") then part.Color = lightColor end
        end
    end)
end

local mainColorValue = Color3.fromRGB(255,255,255)
local rimColorValue = Color3.fromRGB(120,120,120)
local lightColorValue = Color3.fromRGB(255,255,255)
local colorsEnabled = false

Tab0:AddButton({
    Name = "🔘 Activate Color",
    Callback = function()
        colorsEnabled = not colorsEnabled
        if OrionLib then OrionLib:MakeNotification({Name="Color Change",Content=colorsEnabled and "Aktiviert!" or "Deaktiviert!",Duration=2}) end
    end
})
Tab0:AddColorpicker({ Name = "🔘 Body Color", Color = mainColorValue, Callback = function(c) if colorsEnabled then mainColorValue=c; updateCarColors(mainColorValue, rimColorValue) end end })
Tab0:AddColorpicker({ Name = "🔘 Wheel Color", Color = rimColorValue, Callback = function(c) if colorsEnabled then rimColorValue=c; updateCarColors(mainColorValue, rimColorValue) end end })
Tab0:AddColorpicker({ Name = "🔘 Lights Color", Color = lightColorValue, Callback = function(c) if colorsEnabled then lightColorValue=c; updateHeadlightsColor(lightColorValue) end end })

local function setPlateText(text)
    pcall(function()
        local car = FindVehicle2()
        if not car then return end
        local body = car:FindFirstChild("Body", true)
        if not body then return end
        local plates = body:FindFirstChild("LicensePlates")
        if not plates then return end
        for _, plate in ipairs(plates:GetChildren()) do
            if plate:FindFirstChild("Gui") and plate.Gui:FindFirstChild("TextLabel") then
                plate.Gui.TextLabel.Text = text
            end
        end
    end)
end

Tab0:AddTextbox({ Name = "🔘 Custom Plate", PlaceholderText = "TRIXO", RemoveTextAfterFocusLost = false, Callback = function(value) if value and value ~= "" then setPlateText(value) end end })

local function FindSpotLights2()
    local v = FindVehicle2()
    if not v then return nil,nil,nil end
    local spotlights = {}
    for _, d in pairs(v:GetDescendants()) do if d:IsA("SpotLight") then table.insert(spotlights, d) end end
    if #spotlights >= 2 then return spotlights[1], spotlights[2], v end
    return nil,nil,nil
end

local function UpdateHeadlights2(color, range, brightness, angle)
    local leftLight, rightLight, _ = FindSpotLights2()
    if leftLight and rightLight then
        if color then leftLight.Color=color; rightLight.Color=color end
        if range then leftLight.Range=range; rightLight.Range=range end
        if brightness then leftLight.Brightness=brightness; rightLight.Brightness=brightness end
        if angle then leftLight.Angle=angle; rightLight.Angle=angle end
        return true
    end
    return false
end

Tab0:AddSlider({ Name = "📏 Reichweite", Min=1, Max=120, Default=60, Color=Color3.fromRGB(0,200,100), Increment=1, ValueName="Meter", Callback=function(Value) UpdateHeadlights2(nil,Value,nil,nil) end })
Tab0:AddSlider({ Name = "💡 Helligkeit", Min=0.1, Max=100, Default=1, Color=Color3.fromRGB(255,200,0), Increment=0.1, ValueName="Stärke", Callback=function(Value) UpdateHeadlights2(nil,nil,Value,nil) end })
Tab0:AddSlider({ Name = "📐 Winkel", Min=1, Max=180, Default=90, Color=Color3.fromRGB(255,100,100), Increment=1, ValueName="Grad", Callback=function(Value) UpdateHeadlights2(nil,nil,nil,Value) end })

local lightsEnabled = true
Tab0:AddToggle({
    Name = "💡 Scheinwerfer", Default = false,
    Callback = function(Value)
        lightsEnabled = Value
        local l1, l2, _ = FindSpotLights2()
        if l1 and l2 then l1.Enabled=Value; l2.Enabled=Value end
    end
})
Tab0:AddButton({ Name = "🔄 Auf Standard zurücksetzen", Callback = function() UpdateHeadlights2(Color3.fromRGB(255,255,255),60,1,90) end })
Tab0:AddButton({
    Name = "🔍 Lichter überprüfen",
    Callback = function()
        local v = FindVehicle2()
        local l1, l2, _ = FindSpotLights2()
        if v then
            local msg = "Fahrzeug: "..v.Name
            if l1 and l2 then
                msg = msg.."\nLinks: "..tostring(l1.Enabled).."\nReichweite: "..l1.Range.."\nHelligkeit: "..l1.Brightness.."\nWinkel: "..l1.Angle
            else msg = msg.."\nSpotLights nicht gefunden" end
            if OrionLib then OrionLib:MakeNotification({Name="Lichter-Status",Content=msg,Duration=6}) end
        end
    end
})

-- ==================== TAB7: POLICE ====================
Tab7 = Window:MakeTab({ Name = "👮| Police", Icon = "", PremiumOnly = false })
Tab7:AddSection({ Name = "Anti-Police" })

local RadarRemote = ReplicatedStorage:WaitForChild("2Wz"):WaitForChild("cf170e4b-063f-4c0a-ba4d-920a0bb1941a")
RadarFarmEnabled = false

function startRadarFarm()
    while RadarFarmEnabled do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local radarGun = char and char:FindFirstChild("Radar Gun")
        if hrp and radarGun then
            local vs = Workspace:FindFirstChild("Vehicles")
            if vs then
                for _, v in ipairs(vs:GetChildren()) do
                    local s = v:FindFirstChild("DriveSeat")
                    if s and s.Occupant then
                        local dir = s.Position - hrp.Position
                        if dir.Magnitude > 0 then pcall(function() RadarRemote:FireServer(radarGun, s.Position, dir.Unit) end) end
                    end
                end
            end
        end
        task.wait(1)
    end
end

Tab7:AddToggle({
    Name = "🐛 Radar Farm [Police]", CurrentValue = false,
    Callback = function(v) RadarFarmEnabled = v; if v then task.spawn(startRadarFarm) end end
})

local antiAfkEnabled = false
local bb = game:GetService('VirtualUser')
Tab7:AddToggle({
    Name = "💤 [Anti-AFK]", Default = false,
    Callback = function(Value)
        antiAfkEnabled = Value
        if antiAfkEnabled then
            player.Idled:Connect(function()
                if antiAfkEnabled then bb:CaptureController(); bb:ClickButton2(Vector2.new()) end
            end)
        end
    end
})

local policeLocations = {
    Police = CFrame.new(-1670.691528, 5.99, 2771.11),
    Farm = CFrame.new(-1148.454346, 9.49, 2805.56)
}

Tab7:AddButton({ Name = "🚔 Teleport to [Police]", Callback = function() frameTween(policeLocations.Police) end })
Tab7:AddButton({ Name = "🚔 Teleport to [Farm Police]", Callback = function() frameTween(policeLocations.Farm) end })

local TaserRemote = ReplicatedStorage:WaitForChild("2Wz"):WaitForChild("3d4642d3-a886-4e77-b3a8-2f26ecceb51c")
local autoTaserEnabled = false
local lastTase = 0
local AUTO_TASER_INTERVAL = 0.5
local MAX_TASE_RANGE = 80

local function getTaserData()
    local char = LocalPlayer.Character
    if not char then return end
    local taser = char:FindFirstChild("Taser")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if taser and hrp then return taser, hrp.Position end
end

local function findNearestEnemy()
    local _, myPos = getTaserData()
    if not myPos then return end
    local nearest, dist
    for _, plr2 in ipairs(Players:GetPlayers()) do
        if plr2 ~= LocalPlayer and plr2.Team ~= LocalPlayer.Team then
            local hrp = plr2.Character and plr2.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myPos).Magnitude
                if d <= MAX_TASE_RANGE and (not dist or d < dist) then dist=d; nearest=hrp end
            end
        end
    end
    return nearest
end

local function fireTaser()
    local taser, myPos = getTaserData()
    local targetHRP = findNearestEnemy()
    if not (taser and targetHRP) then return end
    local dir = (targetHRP.Position - myPos).Unit
    pcall(function() TaserRemote:FireServer(taser, targetHRP.Position, dir) end)
end

RunService.RenderStepped:Connect(function()
    if autoTaserEnabled and tick() - lastTase >= AUTO_TASER_INTERVAL then fireTaser(); lastTase = tick() end
end)

Tab7:AddToggle({ Name = "🔵 Auto Taser", CurrentValue = false, Callback = function(v) autoTaserEnabled = v end })

local antiTaserActive = false
local antiTaserConnection = nil
Tab7:AddToggle({
    Name = "🔵 Anti-Taser", CurrentValue = false,
    Callback = function(s)
        antiTaserActive = s
        if s then
            local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
            char:SetAttribute("Tased", false)
            antiTaserConnection = char:GetAttributeChangedSignal("Tased"):Connect(function()
                if antiTaserActive then char:SetAttribute("Tased", false) end
            end)
        else
            if antiTaserConnection then antiTaserConnection:Disconnect(); antiTaserConnection=nil end
        end
    end
})

local Lighting = game:GetService("Lighting")
local BlurEffect = Lighting:FindFirstChild("BlurEffect") or Lighting:FindFirstChildOfClass("BlurEffect")
Tab7:AddToggle({
    Name = "🔵 Anti Flashbang", Default = false, Save = true, Flag = "AntiFlashbang",
    Callback = function(Value)
        if Value then
            if not BlurEffect then BlurEffect = Lighting:FindFirstChild("BlurEffect") or Lighting:FindFirstChildOfClass("BlurEffect") end
            if BlurEffect then BlurEffect.Parent = Workspace end
        else if BlurEffect then BlurEffect.Parent = Lighting end end
    end
})

local antiArrestRunning = false
local antiArrestConn, noclipConn2
Tab7:AddToggle({
    Name = "🔵 Anti Arrest", Default = false,
    Callback = function(s3)
        antiArrestRunning = s3
        if antiArrestRunning then
            local char = player.Character or player.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local rootPart = char:WaitForChild("HumanoidRootPart")
            antiArrestConn = game:GetService("RunService").Heartbeat:Connect(function()
                local nearestPolice, shortestDistance = nil, math.huge
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p.Team and p.Team.Name == "Police" and p.Character then
                        local policeRoot = p.Character:FindFirstChild("HumanoidRootPart")
                        if policeRoot then
                            local dist = (rootPart.Position - policeRoot.Position).Magnitude
                            if dist < shortestDistance then shortestDistance=dist; nearestPolice=policeRoot end
                        end
                    end
                end
                if nearestPolice and shortestDistance <= 30 then
                    local fleeDir = (rootPart.Position - nearestPolice.Position).Unit
                    hum:MoveTo(rootPart.Position + fleeDir*10 + Vector3.new(0,2,0))
                end
            end)
            noclipConn2 = game:GetService("RunService").Stepped:Connect(function()
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide=false end
                end
            end)
        else
            if antiArrestConn then antiArrestConn:Disconnect(); antiArrestConn=nil end
            if noclipConn2 then noclipConn2:Disconnect(); noclipConn2=nil end
        end
    end
})

Tab7:AddSection({ Name = "Auto Arrest" })

local MAX_DISTANCE = 7
local isPressingE = false
local isEnabled2 = false
local VIM2 = game:GetService("VirtualInputManager")

local function hasHandcuffsTool()
    if not player.Character then return false end
    for _, obj in pairs(player.Character:GetChildren()) do
        if obj:IsA("Tool") and obj.Name == "Handcuffs" then return true end
    end
    return false
end

local function isWanted(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.HumanoidRootPart:GetAttribute("IsWanted") == true end

-- FIXED: Separated into two small functions to stay under local register limit
local function startPressingE()
    if isPressingE then return end
    isPressingE = true
    task.wait(0.1)
    VIM2:SendKeyEvent(true, Enum.KeyCode.E, false, game)
end

local function stopPressingE()
    if not isPressingE then return end
    isPressingE = false
    VIM2:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

RunService.Heartbeat:Connect(function()
    if not isEnabled2 then return end
    if not hasHandcuffsTool() then stopPressingE(); return end
    local character5 = player.Character
    if not character5 then stopPressingE(); return end
    local rootPart5 = character5:FindFirstChild("HumanoidRootPart")
    if not rootPart5 then stopPressingE(); return end
    local wantedInRange = false
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and isWanted(otherPlayer) then
            local targetRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot and (rootPart5.Position - targetRoot.Position).Magnitude <= MAX_DISTANCE then
                wantedInRange = true; break
            end
        end
    end
    if wantedInRange then startPressingE() else stopPressingE() end
end)

Tab7:AddToggle({ Name = "🔵 Auto Cuff", Callback = function(Value) isEnabled2=Value; if not isEnabled2 then stopPressingE() end end })
Tab7:AddSlider({ Name = "🔵 Cuff Distance", Min=1, Max=7, Default=7, Increment=1, Save=true, Flag="CuffDistance", Callback = function(Value) MAX_DISTANCE=Value end })

-- ==================== TAB8: SERVER ====================
Tab8 = Window:MakeTab({ Name = "🤓| Server", Icon = "", PremiumOnly = false })
Tab8:AddSection({ Name = "Server-Settings" })

local groupId = 12563021
local requiredRoles = {"Contributer","Staff","Dev"}
local kickMessage = "YOU HAVE BEEN SAVED BY TRIXO: Auto-kick, a moderator has joined the lobby!"
local checkInterval = 1
local localPlayer2 = Players.LocalPlayer
local isScriptActive = true

local function hasRequiredRole(p)
    local role = p:GetRoleInGroup(groupId)
    for _, r in ipairs(requiredRoles) do if role == r then return true end end
    return false
end
local function checkPlayers()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer2 and hasRequiredRole(p) then localPlayer2:Kick(kickMessage); break end
    end
end

Tab8:AddToggle({
    Name = "🟡 Admin Detection", Default = true,
    Callback = function(value)
        isScriptActive = value
        OrionLib:MakeNotification({Name="Auto-Kick",Content=value and "Aktiviert!" or "Deaktiviert!",Image="",Time=3})
    end
})
spawn(function() while true do wait(checkInterval); if isScriptActive then checkPlayers() end end end)

Tab8:AddButton({ Name = "🟡 Rejoin", Callback = function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer) end })
Tab8:AddButton({ Name = "🟡 Leave", Callback = function() game:GetService("Players").LocalPlayer:Kick("You have left the game.") end })

local HttpService = game:GetService("HttpService")
local function RejoinToNewLobby()
    local PlaceId = game.PlaceId
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and response and response.data then
        for _, server in pairs(response.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Player); return
            end
        end
    end
    OrionLib:MakeNotification({Title="⚠️ Fehler",Content="Keine andere Lobby gefunden.",Duration=4})
end
Tab8:AddButton({ Name = "🟡 Server-Hop", Callback = function() RejoinToNewLobby() end })

Tab8:AddSection({ Name = "More-FPS" })

Tab8:AddToggle({
    Name = "🟡 XRay", CurrentValue = false, Flag = "XRayToggle",
    Callback = function(Value)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Transparency < 1 and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
                obj.LocalTransparencyModifier = Value and 0.8 or 0
            end
        end
    end
})

Tab8:AddToggle({
    Name = "🟡 Night Vision", CurrentValue = false, Flag = "NightVisionToggle",
    Callback = function(Value)
        local lighting = game:GetService("Lighting")
        local existing = lighting:FindFirstChild("NightVision")
        if Value and not existing then
            local cc = Instance.new("ColorCorrectionEffect", lighting)
            cc.Name="NightVision"; cc.TintColor=Color3.fromRGB(128,255,128); cc.Contrast=0.1; cc.Saturation=1
        elseif not Value and existing then existing:Destroy() end
    end
})

Tab8:AddToggle({
    Name = "🟡 Fullbright", CurrentValue = false, Flag = "FullbrightToggle",
    Callback = function(Value)
        local lighting = game:GetService("Lighting")
        if Value then
            lighting.Ambient=Color3.new(1,1,1); lighting.OutdoorAmbient=Color3.new(1,1,1); lighting.Brightness=3; lighting.FogEnd=1000000
        else
            lighting.Ambient=Color3.fromRGB(112,112,112); lighting.OutdoorAmbient=Color3.fromRGB(112,112,112); lighting.Brightness=1; lighting.FogEnd=1000
        end
    end
})

Tab8:AddButton({
    Name = "🟡 FPS-Booster",
    Callback = function()
        game.Lighting.GlobalShadows=false; game.Lighting.FogEnd=1000; game.Lighting.Brightness=1; game.Lighting.OutdoorAmbient=Color3.new(1,1,1)
        if workspace:FindFirstChildOfClass("Terrain") then
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            terrain.WaterWaveSize=0; terrain.WaterWaveSpeed=0; terrain.WaterReflectance=0; terrain.WaterTransparency=1
        end
        for _, v in pairs(game:GetService("StarterGui"):GetDescendants()) do
            if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                v.Enabled = false
            end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end
})

-- ==================== TAB9: INFO ====================
Tab9 = Window:MakeTab({ Name = "📢| Info", Icon = "", PremiumOnly = false })
Tab9:AddSection({ Name = "Infos" })
Tab9:AddLabel(" Authors: TrixoBeste", 4483362458, Color3.fromRGB(255,255,255), false)
Tab9:AddLabel(" Version: 2.0", 4483362458, Color3.fromRGB(255,255,255), false)

Tab9:AddButton({
    Name = "🔗 Trixo Discord",
    Callback = function()
        setclipboard("https://discord.gg/fqzdkQrvxy")
        OrionLib:MakeNotification({Title="Discord-Link kopiert!",Content="Füge ihn in deinen Browser ein.",Duration=5})
    end
})
Tab9:AddButton({
    Name = "🌐 Trixo Wep",
    Callback = function()
        setclipboard("https://trixo-scripts.de/")
        OrionLib:MakeNotification({Title="Wep-Link kopiert!",Content="Füge ihn in deinen Browser ein.",Duration=5})
    end
})
Tab9:AddButton({
    Name = "📺 Trixo YouTube",
    Callback = function()
        setclipboard("https://youtube.com/@toxo-zp2kx?si=oJTzPIXp2XncsJfG")
        OrionLib:MakeNotification({Title="YouTube-Link kopiert!",Content="Füge ihn in deinen Browser ein.",Duration=5})
    end
})
Tab9:AddButton({
    Name = "🎵 Trixo TikTok",
    Callback = function()
        setclipboard("https://www.tiktok.com/@trixo_55?_r=1&_t=ZS-923SrfVR6iG")
        OrionLib:MakeNotification({Title="TikTok-Link kopiert!",Content="Füge ihn in deinen Browser ein.",Duration=5})
    end
})