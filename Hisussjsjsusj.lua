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
local UserInputService = cloneref(game:GetService("UserInputService"))

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

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

local EspTab = Window:Tab({
    Title = "ESP",
    Icon = "eye",
})

local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "chart-column",
})

local MopSection = FarmTab:Section({ Title = "Mop Farm" })
MopSection:Section({ Title = "Be near the job", TextSize = 14, TextTransparency = 0.4 })
local BoxSection = FarmTab:Section({ Title = "Box Farm" })
BoxSection:Section({ Title = "Be near the job", TextSize = 14, TextTransparency = 0.4 })
local SettingSection = FarmTab:Section({ Title = "Settings" })

local PlayerSection = PlayerTab:Section({ Title = "Local Player" })
local AtmSection = PlayerTab:Section({ Title = "ATM" })
local VehicleSection = PlayerTab:Section({ Title = "Vehicle" })

local EspToggleSection = EspTab:Section({ Title = "Toggles" })
local EspColorsSection = EspTab:Section({ Title = "Colors" })
local EspSettingsSection = EspTab:Section({ Title = "Settings" })

local TargetSection = MiscTab:Section({ Title = "Player Interaction" })

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

local VehicleFlyEnabled = false
local VehicleFlySpeed = 50
local VehicleFlyConn = nil

local SelectedPlayerName = ""
local TargetHudEnabled = false
local SpectateEnabled = false
local SendMoneyAmount = 1000

local TargetHudGui = nil
local TargetHudConn = nil
local SpectateConn = nil

local EspConfig = {
    Box = false,
    BoxOutline = false,
    Corner = false,
    Healthbar = false,
    Skeleton = false,
    Name = false,
    Distance = false,
    HealthText = false,
    Weapon = false,
    Backpack = false,
    FriendCheck = false,
    MaxDistanceEnabled = false,
    MaxDistance = 1000,
    Colors = {
        Box = Color3.fromRGB(255, 255, 255),
        Corner = Color3.fromRGB(255, 255, 255),
        Healthbar = Color3.fromRGB(0, 255, 0),
        Skeleton = Color3.fromRGB(255, 255, 255),
        Name = Color3.fromRGB(255, 255, 255),
        Distance = Color3.fromRGB(200, 200, 200),
        HealthText = Color3.fromRGB(255, 255, 255),
        Weapon = Color3.fromRGB(255, 215, 0),
        Backpack = Color3.fromRGB(180, 180, 180),
        Friend = Color3.fromRGB(0, 255, 128),
    }
}

local FriendsCache = {}
local function isFriend(player)
    if not EspConfig.FriendCheck then return false end
    if FriendsCache[player.UserId] ~= nil then
        return FriendsCache[player.UserId]
    end
    local success, res = pcall(function()
        return LocalPlayer:IsFriendsWith(player.UserId)
    end)
    if success then
        FriendsCache[player.UserId] = res
        return res
    end
    return false
end

Players.PlayerRemoving:Connect(function(plr)
    FriendsCache[plr.UserId] = nil
end)

local EspObjects = {}
local PlayerToolCache = {}

local function getPlayerTools(plr)
    local now = os.clock()
    if PlayerToolCache[plr] and (now - PlayerToolCache[plr].Time < 0.4) then
        return PlayerToolCache[plr].Equipped, PlayerToolCache[plr].Backpack
    end

    local char = plr.Character
    local equipped = "None"
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                equipped = item.Name
                break
            end
        end
    end

    local tools = {}
    local bp = plr:FindFirstChildOfClass("Backpack") or plr:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(tools, item.Name)
            end
        end
    end

    local bpText = #tools > 0 and ("[" .. table.concat(tools, ", ") .. "]") or "[]"
    PlayerToolCache[plr] = { Time = now, Equipped = equipped, Backpack = bpText }
    return equipped, bpText
end

local function createDrawing(class, properties)
    local obj = Drawing.new(class)
    for k, v in pairs(properties) do
        obj[k] = v
    end
    return obj
end

local function removeEsp(plr)
    PlayerToolCache[plr] = nil
    if EspObjects[plr] then
        for _, obj in pairs(EspObjects[plr].Drawings) do
            if type(obj) == "table" then
                for _, sub in pairs(obj) do
                    if sub and sub.Remove then sub:Remove() end
                end
            elseif obj and obj.Remove then
                obj:Remove()
            end
        end
        EspObjects[plr] = nil
    end
end

local function hideAllDrawings(drawings)
    for _, d in pairs(drawings) do
        if type(d) == "table" then
            for _, sub in pairs(d) do sub.Visible = false end
        else
            d.Visible = false
        end
    end
end

local function setupEsp(plr)
    if plr == LocalPlayer or EspObjects[plr] then return end

    local drawings = {
        BoxOutline = createDrawing("Square", { Thickness = 3, Color = Color3.new(0,0,0), Filled = false, Visible = false }),
        Box = createDrawing("Square", { Thickness = 1, Color = EspConfig.Colors.Box, Filled = false, Visible = false }),
        
        Corners = {},
        
        HealthbarBackground = createDrawing("Square", { Thickness = 1, Color = Color3.new(0,0,0), Filled = true, Visible = false }),
        Healthbar = createDrawing("Square", { Thickness = 1, Color = EspConfig.Colors.Healthbar, Filled = true, Visible = false }),
        
        Name = createDrawing("Text", { Size = 13, Center = true, Outline = true, Color = EspConfig.Colors.Name, Visible = false }),
        FriendTag = createDrawing("Text", { Size = 12, Center = true, Outline = true, Color = EspConfig.Colors.Friend, Text = "[FRIEND]", Visible = false }),
        Distance = createDrawing("Text", { Size = 12, Center = true, Outline = true, Color = EspConfig.Colors.Distance, Visible = false }),
        HealthText = createDrawing("Text", { Size = 12, Center = true, Outline = true, Color = EspConfig.Colors.HealthText, Visible = false }),
        Weapon = createDrawing("Text", { Size = 12, Center = true, Outline = true, Color = EspConfig.Colors.Weapon, Visible = false }),
        Backpack = createDrawing("Text", { Size = 11, Center = true, Outline = true, Color = EspConfig.Colors.Backpack, Visible = false }),
        
        Skeleton = {}
    }

    for i = 1, 8 do
        drawings.Corners[i] = createDrawing("Line", { Thickness = 1, Color = EspConfig.Colors.Corner, Visible = false })
    end

    local limbs = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"},
        {"Head", "Torso"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"}
    }

    for i = 1, #limbs do
        drawings.Skeleton[i] = createDrawing("Line", { Thickness = 1, Color = EspConfig.Colors.Skeleton, Visible = false })
    end

    EspObjects[plr] = {
        Drawings = drawings,
        Limbs = limbs
    }
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then setupEsp(p) end
end

Players.PlayerAdded:Connect(setupEsp)
Players.PlayerRemoving:Connect(removeEsp)

RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    for plr, data in pairs(EspObjects) do
        local drawings = data.Drawings
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and char:FindFirstChild("Head")

        if char and root and hum and head and hum.Health > 0 then
            local dist = (root.Position - myRoot.Position).Magnitude

            if EspConfig.MaxDistanceEnabled and dist > EspConfig.MaxDistance then
                hideAllDrawings(drawings)
                continue
            end

            local topWorld = root.Position + Vector3.new(0, 3, 0)
            local bottomWorld = root.Position - Vector3.new(0, 3.5, 0)

            local topPos, topOnScreen = Camera:WorldToViewportPoint(topWorld)
            local bottomPos, bottomOnScreen = Camera:WorldToViewportPoint(bottomWorld)
            local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)

            if rootOnScreen or topOnScreen or bottomOnScreen then
                local boxHeight = math.clamp(math.abs(topPos.Y - bottomPos.Y), 8, 2000)
                local boxWidth = math.clamp(boxHeight * 0.6, 6, 1200)
                local boxX = rootPos.X - (boxWidth / 2)
                local boxY = topPos.Y

                local isFriendPlayer = isFriend(plr)
                local baseColor = isFriendPlayer and EspConfig.Colors.Friend or nil

                if EspConfig.Box then
                    drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
                    drawings.Box.Position = Vector2.new(boxX, boxY)
                    drawings.Box.Color = baseColor or EspConfig.Colors.Box
                    drawings.Box.Visible = true

                    if EspConfig.BoxOutline then
                        drawings.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
                        drawings.BoxOutline.Position = Vector2.new(boxX, boxY)
                        drawings.BoxOutline.Visible = true
                    else
                        drawings.BoxOutline.Visible = false
                    end
                else
                    drawings.Box.Visible = false
                    drawings.BoxOutline.Visible = false
                end

                if EspConfig.Corner then
                    local lineLen = math.clamp(boxWidth * 0.25, 2, 50)
                    local col = baseColor or EspConfig.Colors.Corner

                    local c = drawings.Corners
                    c[1].From = Vector2.new(boxX, boxY); c[1].To = Vector2.new(boxX + lineLen, boxY)
                    c[2].From = Vector2.new(boxX, boxY); c[2].To = Vector2.new(boxX, boxY + lineLen)
                    c[3].From = Vector2.new(boxX + boxWidth, boxY); c[3].To = Vector2.new(boxX + boxWidth - lineLen, boxY)
                    c[4].From = Vector2.new(boxX + boxWidth, boxY); c[4].To = Vector2.new(boxX + boxWidth, boxY + lineLen)
                    c[5].From = Vector2.new(boxX, boxY + boxHeight); c[5].To = Vector2.new(boxX + lineLen, boxY + boxHeight)
                    c[6].From = Vector2.new(boxX, boxY + boxHeight); c[6].To = Vector2.new(boxX, boxY + boxHeight - lineLen)
                    c[7].From = Vector2.new(boxX + boxWidth, boxY + boxHeight); c[7].To = Vector2.new(boxX + boxWidth - lineLen, boxY + boxHeight)
                    c[8].From = Vector2.new(boxX + boxWidth, boxY + boxHeight); c[8].To = Vector2.new(boxX + boxWidth, boxY + boxHeight - lineLen)

                    for i = 1, 8 do
                        c[i].Color = col
                        c[i].Visible = true
                    end
                else
                    for i = 1, 8 do drawings.Corners[i].Visible = false end
                end

                if EspConfig.Healthbar then
                    local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    local barHeight = boxHeight * healthPct
                    local barX = boxX - 6

                    drawings.HealthbarBackground.Size = Vector2.new(3, boxHeight + 2)
                    drawings.HealthbarBackground.Position = Vector2.new(barX - 1, boxY - 1)
                    drawings.HealthbarBackground.Visible = true

                    drawings.Healthbar.Size = Vector2.new(1, barHeight)
                    drawings.Healthbar.Position = Vector2.new(barX, boxY + (boxHeight - barHeight))
                    drawings.Healthbar.Color = baseColor or Color3.fromRGB(255 - (255 * healthPct), 255 * healthPct, 0)
                    drawings.Healthbar.Visible = true
                else
                    drawings.Healthbar.Visible = false
                    drawings.HealthbarBackground.Visible = false
                end

                local topOffset = 2
                if isFriendPlayer then
                    drawings.FriendTag.Position = Vector2.new(rootPos.X, boxY - 14 - topOffset)
                    drawings.FriendTag.Color = EspConfig.Colors.Friend
                    drawings.FriendTag.Visible = true
                    topOffset = topOffset + 14
                else
                    drawings.FriendTag.Visible = false
                end

                if EspConfig.Name then
                    drawings.Name.Position = Vector2.new(rootPos.X, boxY - 14 - topOffset)
                    drawings.Name.Text = plr.Name
                    drawings.Name.Color = baseColor or EspConfig.Colors.Name
                    drawings.Name.Visible = true
                else
                    drawings.Name.Visible = false
                end

                local bottomOffset = 2
                if EspConfig.Distance then
                    drawings.Distance.Position = Vector2.new(rootPos.X, boxY + boxHeight + bottomOffset)
                    drawings.Distance.Text = string.format("%dm", math.floor(dist))
                    drawings.Distance.Color = baseColor or EspConfig.Colors.Distance
                    drawings.Distance.Visible = true
                    bottomOffset = bottomOffset + 13
                else
                    drawings.Distance.Visible = false
                end

                if EspConfig.HealthText then
                    drawings.HealthText.Position = Vector2.new(rootPos.X, boxY + boxHeight + bottomOffset)
                    drawings.HealthText.Text = string.format("%d HP", math.floor(hum.Health))
                    drawings.HealthText.Color = baseColor or EspConfig.Colors.HealthText
                    drawings.HealthText.Visible = true
                    bottomOffset = bottomOffset + 13
                else
                    drawings.HealthText.Visible = false
                end

                local equippedTool, bpText = "None", "[]"
                if EspConfig.Weapon or EspConfig.Backpack then
                    equippedTool, bpText = getPlayerTools(plr)
                end

                if EspConfig.Weapon then
                    drawings.Weapon.Position = Vector2.new(rootPos.X, boxY + boxHeight + bottomOffset)
                    drawings.Weapon.Text = equippedTool
                    drawings.Weapon.Color = baseColor or EspConfig.Colors.Weapon
                    drawings.Weapon.Visible = true
                    bottomOffset = bottomOffset + 13
                else
                    drawings.Weapon.Visible = false
                end

                if EspConfig.Backpack then
                    drawings.Backpack.Position = Vector2.new(rootPos.X, boxY + boxHeight + bottomOffset)
                    drawings.Backpack.Text = bpText
                    drawings.Backpack.Color = baseColor or EspConfig.Colors.Backpack
                    drawings.Backpack.Visible = true
                else
                    drawings.Backpack.Visible = false
                end

                if EspConfig.Skeleton then
                    local skelColor = baseColor or EspConfig.Colors.Skeleton
                    for i, pair in ipairs(data.Limbs) do
                        local part1 = char:FindFirstChild(pair[1])
                        local part2 = char:FindFirstChild(pair[2])
                        local line = drawings.Skeleton[i]

                        if part1 and part2 and line then
                            local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                            local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)

                            if vis1 and vis2 then
                                line.From = Vector2.new(pos1.X, pos1.Y)
                                line.To = Vector2.new(pos2.X, pos2.Y)
                                line.Color = skelColor
                                line.Visible = true
                            else
                                line.Visible = false
                            end
                        elseif line then
                            line.Visible = false
                        end
                    end
                else
                    for i = 1, #drawings.Skeleton do
                        drawings.Skeleton[i].Visible = false
                    end
                end
            else
                hideAllDrawings(drawings)
            end
        else
            hideAllDrawings(drawings)
        end
    end
end)

EspToggleSection:Toggle({
    Title = "Box ESP",
    Value = false,
    Callback = function(v) EspConfig.Box = v end
})

EspToggleSection:Toggle({
    Title = "Box Outline",
    Value = false,
    Callback = function(v) EspConfig.BoxOutline = v end
})

EspToggleSection:Toggle({
    Title = "Corner Box ESP",
    Value = false,
    Callback = function(v) EspConfig.Corner = v end
})

EspToggleSection:Toggle({
    Title = "Healthbar ESP",
    Value = false,
    Callback = function(v) EspConfig.Healthbar = v end
})

EspToggleSection:Toggle({
    Title = "Skeleton ESP",
    Value = false,
    Callback = function(v) EspConfig.Skeleton = v end
})

EspToggleSection:Toggle({
    Title = "Name ESP",
    Value = false,
    Callback = function(v) EspConfig.Name = v end
})

EspToggleSection:Toggle({
    Title = "Distance ESP",
    Value = false,
    Callback = function(v) EspConfig.Distance = v end
})

EspToggleSection:Toggle({
    Title = "Health Text ESP",
    Value = false,
    Callback = function(v) EspConfig.HealthText = v end
})

EspToggleSection:Toggle({
    Title = "Weapon ESP",
    Value = false,
    Callback = function(v) EspConfig.Weapon = v end
})

EspToggleSection:Toggle({
    Title = "Backpack ESP",
    Value = false,
    Callback = function(v) EspConfig.Backpack = v end
})

EspToggleSection:Toggle({
    Title = "Friend Check",
    Value = false,
    Callback = function(v) EspConfig.FriendCheck = v end
})

EspColorsSection:Colorpicker({
    Title = "Box Color",
    Default = EspConfig.Colors.Box,
    Callback = function(v) EspConfig.Colors.Box = v end
})

EspColorsSection:Colorpicker({
    Title = "Corner Color",
    Default = EspConfig.Colors.Corner,
    Callback = function(v) EspConfig.Colors.Corner = v end
})

EspColorsSection:Colorpicker({
    Title = "Healthbar Color",
    Default = EspConfig.Colors.Healthbar,
    Callback = function(v) EspConfig.Colors.Healthbar = v end
})

EspColorsSection:Colorpicker({
    Title = "Skeleton Color",
    Default = EspConfig.Colors.Skeleton,
    Callback = function(v) EspConfig.Colors.Skeleton = v end
})

EspColorsSection:Colorpicker({
    Title = "Name Color",
    Default = EspConfig.Colors.Name,
    Callback = function(v) EspConfig.Colors.Name = v end
})

EspColorsSection:Colorpicker({
    Title = "Distance Color",
    Default = EspConfig.Colors.Distance,
    Callback = function(v) EspConfig.Colors.Distance = v end
})

EspColorsSection:Colorpicker({
    Title = "Health Text Color",
    Default = EspConfig.Colors.HealthText,
    Callback = function(v) EspConfig.Colors.HealthText = v end
})

EspColorsSection:Colorpicker({
    Title = "Weapon Color",
    Default = EspConfig.Colors.Weapon,
    Callback = function(v) EspConfig.Colors.Weapon = v end
})

EspColorsSection:Colorpicker({
    Title = "Backpack Color",
    Default = EspConfig.Colors.Backpack,
    Callback = function(v) EspConfig.Colors.Backpack = v end
})

EspColorsSection:Colorpicker({
    Title = "Friend Color",
    Default = EspConfig.Colors.Friend,
    Callback = function(v) EspConfig.Colors.Friend = v end
})

EspSettingsSection:Toggle({
    Title = "Enable Max Distance",
    Value = false,
    Callback = function(v) EspConfig.MaxDistanceEnabled = v end
})

EspSettingsSection:Slider({
    Title = "Max Distance",
    Step = 10,
    Value = {
        Min = 50,
        Max = 5000,
        Default = 1000,
    },
    Callback = function(v) EspConfig.MaxDistance = v end
})

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

local function getMyVehicleSeat()
    local vehicles = Workspace:FindFirstChild("Vehicles")
    if not vehicles then return nil end
    
    for _, v in ipairs(vehicles:GetChildren()) do
        if v.Name:lower():find(LocalPlayer.Name:lower()) then
            local ds = v:FindFirstChild("DriveSeat")
            if ds then return ds end
            for _, d in ipairs(v:GetDescendants()) do
                if d:IsA("VehicleSeat") then return d end
            end
        end
    end
    return nil
end

local function getCurrentSittingSeat()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        return hum.SeatPart
    end
    return nil
end

local function handleVehicleFly(enabled)
    VehicleFlyEnabled = enabled
    if VehicleFlyConn then
        VehicleFlyConn:Disconnect()
        VehicleFlyConn = nil
    end

    if not VehicleFlyEnabled then
        local seat = getCurrentSittingSeat()
        if seat then
            local model = seat:FindFirstAncestorOfClass("Model") or seat.Parent
            local root = model:IsA("Model") and model.PrimaryPart or seat
            if root then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end
        return
    end

    VehicleFlyConn = RunService.RenderStepped:Connect(function(dt)
        if not VehicleFlyEnabled then return end
        local seat = getCurrentSittingSeat()
        if not seat then return end

        local model = seat:FindFirstAncestorOfClass("Model") or seat.Parent
        local root = (model:IsA("Model") and model.PrimaryPart) or seat
        if not root then return end

        local camera = Workspace.CurrentCamera
        local moveDir = Vector3.zero

        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
            local moveVector = Vector3.zero
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    moveVector = hum.MoveDirection
                end
            end
            if moveVector.Magnitude > 0.05 then
                local camCFrame = camera.CFrame
                local forward = camCFrame.LookVector
                local right = camCFrame.RightVector
                local flatForward = Vector3.new(forward.X, 0, forward.Z).Unit
                local flatRight = Vector3.new(right.X, 0, right.Z).Unit
                
                local localZ = moveVector:Dot(flatForward)
                local localX = moveVector:Dot(flatRight)
                
                moveDir = (forward * localZ) + (right * localX)
            end
        else
            local look = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            local up = Vector3.new(0, 1, 0)

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + look end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - look end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + right end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - right end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + up end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - up end
        end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end

        local targetVelocity = moveDir * VehicleFlySpeed
        root.AssemblyLinearVelocity = targetVelocity
        root.AssemblyAngularVelocity = Vector3.zero
        
        if moveDir.Magnitude > 0 then
            root.CFrame = CFrame.lookAt(root.Position, root.Position + moveDir)
        end
    end)
end

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    if #names == 0 then
        table.insert(names, "None")
    end
    return names
end

local function getSelectedPlayerObj()
    if SelectedPlayerName == "" or SelectedPlayerName == "None" then return nil end
    return Players:FindFirstChild(SelectedPlayerName)
end

local function createTargetHudGui()
    if TargetHudGui then
        TargetHudGui:Destroy()
        TargetHudGui = nil
    end

    local guiParent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "TargetHudGui"
    sg.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Name = "TargetHudFrame"
    frame.Size = UDim2.new(0, 240, 0, 160)
    frame.Position = UDim2.new(0.75, 0, 0.35, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = sg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(48, 255, 106)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "TargetHud"
    title.TextColor3 = Color3.fromRGB(48, 255, 106)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local function createLabel(posY, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 22)
        lbl.Position = UDim2.new(0, 10, 0, posY)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
        lbl.TextSize = 13
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        return lbl
    end

    local nameLbl = createLabel(32, "Name: None")
    local hpLbl = createLabel(56, "Health: 0 / 0")
    local distLbl = createLabel(80, "Distance: 0m")
    local equipLbl = createLabel(104, "Equipped: None")
    local backpackLbl = createLabel(128, "Backpack: None")

    sg.Parent = guiParent
    TargetHudGui = sg

    return {
        NameLbl = nameLbl,
        HpLbl = hpLbl,
        DistLbl = distLbl,
        EquipLbl = equipLbl,
        BackpackLbl = backpackLbl,
    }
end

local function handleTargetHud(enabled)
    TargetHudEnabled = enabled

    if TargetHudConn then
        TargetHudConn:Disconnect()
        TargetHudConn = nil
    end

    if not TargetHudEnabled then
        if TargetHudGui then
            TargetHudGui:Destroy()
            TargetHudGui = nil
        end
        return
    end

    local elements = createTargetHudGui()

    TargetHudConn = RunService.RenderStepped:Connect(function()
        if not TargetHudEnabled then return end

        local target = getSelectedPlayerObj()
        if not target then
            elements.NameLbl.Text = "Name: None"
            elements.HpLbl.Text = "Health: N/A"
            elements.DistLbl.Text = "Distance: N/A"
            elements.EquipLbl.Text = "Equipped: None"
            elements.BackpackLbl.Text = "Backpack: None"
            return
        end

        elements.NameLbl.Text = "Name: " .. target.Name

        local char = target.Character
        local myChar = LocalPlayer.Character

        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                elements.HpLbl.Text = string.format("Health: %d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))
            else
                elements.HpLbl.Text = "Health: N/A"
            end

            local root = char:FindFirstChild("HumanoidRootPart")
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if root and myRoot then
                local dist = (root.Position - myRoot.Position).Magnitude
                elements.DistLbl.Text = string.format("Distance: %dm", math.floor(dist))
            else
                elements.DistLbl.Text = "Distance: N/A"
            end

            local equipped, bpText = getPlayerTools(target)
            elements.EquipLbl.Text = "Equipped: " .. equipped
            elements.BackpackLbl.Text = "Backpack: " .. bpText
        else
            elements.HpLbl.Text = "Health: Dead"
            elements.DistLbl.Text = "Distance: N/A"
            elements.EquipLbl.Text = "Equipped: None"
            elements.BackpackLbl.Text = "Backpack: None"
        end
    end)
end

local function handleSpectate(enabled)
    SpectateEnabled = enabled

    if SpectateConn then
        SpectateConn:Disconnect()
        SpectateConn = nil
    end

    if not SpectateEnabled then
        local myChar = LocalPlayer.Character
        if myChar then
            local hum = myChar:FindFirstChildOfClass("Humanoid")
            if hum then
                Workspace.CurrentCamera.CameraSubject = hum
            end
        end
        return
    end

    SpectateConn = RunService.RenderStepped:Connect(function()
        if not SpectateEnabled then return end
        local target = getSelectedPlayerObj()
        if target and target.Character then
            local hum = target.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                Workspace.CurrentCamera.CameraSubject = hum
                return
            end
        end

        local myChar = LocalPlayer.Character
        if myChar then
            local hum = myChar:FindFirstChildOfClass("Humanoid")
            if hum then
                Workspace.CurrentCamera.CameraSubject = hum
            end
        end
    end)
end

local function sendMoneyToTarget()
    local target = getSelectedPlayerObj()
    if not target then return end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local phoneRemote = remotes and remotes:FindFirstChild("Phone")
    if phoneRemote then
        phoneRemote:FireServer("SendMoney", target, SendMoneyAmount)
    end
end

local playerDropdown = TargetSection:Dropdown({
    Title = "Select Player",
    Values = getPlayerNames(),
    Value = getPlayerNames()[1] or "None",
    Callback = function(Value)
        SelectedPlayerName = type(Value) == "table" and Value[1] or Value
    end,
})

local function updatePlayerDropdown()
    local names = getPlayerNames()
    if playerDropdown and playerDropdown.SetValues then
        playerDropdown:SetValues(names)
    end
end

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    updatePlayerDropdown()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    updatePlayerDropdown()
end)

TargetSection:Toggle({
    Title = "TargetHud",
    Value = false,
    Callback = function(Value)
        handleTargetHud(Value)
    end,
})

TargetSection:Toggle({
    Title = "Spectate Player",
    Value = false,
    Callback = function(Value)
        handleSpectate(Value)
    end,
})

TargetSection:Input({
    Title = "Send Money Amount",
    Default = "1000",
    Placeholder = "Enter amount...",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            SendMoneyAmount = num
        end
    end,
})

TargetSection:Button({
    Title = "Send Money",
    Callback = function()
        sendMoneyToTarget()
    end,
})

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

VehicleSection:Toggle({
    Title = "Vehicle Fly",
    Value = false,
    Callback = function(Value)
        handleVehicleFly(Value)
    end,
})

VehicleSection:Slider({
    Title = "Fly Speed",
    Step = 1,
    Value = {
        Min = 10,
        Max = 300,
        Default = 50,
    },
    Callback = function(Value)
        VehicleFlySpeed = Value
    end,
})

VehicleSection:Button({
    Title = "Enter Own Car",
    Callback = function()
        local seat = getMyVehicleSeat()
        if seat then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.1)
                seat:Sit(char:FindFirstChildOfClass("Humanoid"))
            end
        end
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
