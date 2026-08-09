local MarketplaceService = game:GetService("MarketplaceService")
local GameInfo = MarketplaceService:GetProductInfo(game.PlaceId)

local Arcane = loadstring(game:HttpGet("https://raw.githubusercontent.com/Da7mu/Ui-Collection/refs/heads/main/Arcane%20Ui/Library.lua"))()

local Window = Arcane:Window({
    Name = "Xeioa",
    User = GameInfo.Name,
    Logo = "97741915311873"
})

local Combat = Window:Page({ Name = "Combat", Icon = "swords" })
local ESP = Window:Page({ Name = "ESP", Icon = "eye" })
local Visual = Window:Page({ Name = "Visual", Icon = "palette" })
local Settings = Window:Page({ Name = "Settings", Icon = "settings" })

local ConfigSub = Settings:SubPage({ Name = "Configs", Icon = "save" })
ConfigSub:Config()

local SilentAimSub = Combat:SubPage({ Name = "Silent Aim", Icon = "crosshair" })

local SALeft = SilentAimSub:Section({ Name = "General", Side = 1 })
local SARight = SilentAimSub:Section({ Name = "Visuals", Side = 2 })

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local RuntimeLib = require(ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local network = RuntimeLib.import(script, LocalPlayer.PlayerScripts, "TS", "network")
local Events = network.Events
local ClientFirearmToolModule = RuntimeLib.import(script, LocalPlayer.PlayerScripts, "TS", "components", "firearm", "clientFirearmTool")
local ClientFirearmTool = ClientFirearmToolModule.ClientFirearmTool

local cfg = {
    enabled = false,
    showFov = true,
    snapline = true,
    highlightTarget = true,
    fovSize = 120,
    fovColor = Color3.fromRGB(255, 255, 255),
    wallCheck = true,
    aliveCheck = true,
    friendCheck = true,
}

local target = nil
local camera = workspace.CurrentCamera

local highlight = Instance.new("Highlight")
highlight.FillTransparency = 0.5
highlight.OutlineTransparency = 0
highlight.OutlineColor = Color3.fromRGB(255, 0, 0)

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.NumSides = 64

local snapLine = Drawing.new("Line")
snapLine.Thickness = 1
snapLine.Visible = false
snapLine.Color = Color3.fromRGB(255, 0, 0)

local function isVisible(origin, targetPos)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local chars = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(chars, p.Character) end
    end
    if LocalPlayer.Character then table.insert(chars, LocalPlayer.Character) end
    rayParams.FilterDescendantsInstances = chars
    local result = workspace:Raycast(origin, (targetPos - origin), rayParams)
    return result == nil
end

local function isFriend(player)
    local ok, result = pcall(function()
        return LocalPlayer:IsFriendsWith(player.UserId)
    end)
    return ok and result
end

local function getNearestEnemy()
    local char = LocalPlayer.Character
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    local origin = head and head.Position or char:GetPivot().Position
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local nearest = nil
    local nearestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if cfg.aliveCheck and (not humanoid or humanoid.Health <= 0) then continue end
        if cfg.friendCheck and isFriend(player) then continue end
        local targetHead = player.Character:FindFirstChild("Head")
        if not targetHead then continue end
        if cfg.wallCheck and not isVisible(origin, targetHead.Position) then continue end
        local screenPos, onScreen = camera:WorldToViewportPoint(targetHead.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if dist < cfg.fovSize and dist < nearestDist then
            nearestDist = dist
            nearest = player
        end
    end
    return nearest
end

local function getTargetPosition(character)
    local head = character:FindFirstChild("Head")
    if head then return head.Position end
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if torso then return torso.Position end
    return character.PrimaryPart and character.PrimaryPart.Position or character:GetPivot().Position
end

local oldGetAimDirection = ClientFirearmTool.getAimDirection
ClientFirearmTool.getAimDirection = function(self, origin)
    if cfg.enabled and target and target.Character then
        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
        if not cfg.aliveCheck or (humanoid and humanoid.Health > 0) then
            local targetPos = getTargetPosition(target.Character)
            return (targetPos - origin).Unit
        end
    end
    return oldGetAimDirection(self, origin)
end

RunService.Heartbeat:Connect(function()
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    fovCircle.Visible = cfg.enabled and cfg.showFov
    fovCircle.Position = screenCenter
    fovCircle.Radius = cfg.fovSize
    fovCircle.Color = cfg.fovColor

    if cfg.enabled then
        local newTarget = getNearestEnemy()
        if newTarget ~= target then
            target = newTarget
            if target and target.Character and cfg.highlightTarget then
                highlight.Parent = target.Character
                highlight.Adornee = target.Character
            else
                highlight.Parent = nil
                highlight.Adornee = nil
            end
        end

        if target and target.Character then
            local targetHead = target.Character:FindFirstChild("Head")
            if targetHead and cfg.snapline then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetHead.Position)
                if onScreen then
                    snapLine.Visible = true
                    snapLine.From = screenCenter
                    snapLine.To = Vector2.new(screenPos.X, screenPos.Y)
                    snapLine.Color = cfg.fovColor
                else
                    snapLine.Visible = false
                end
            else
                snapLine.Visible = false
            end
        else
            snapLine.Visible = false
        end
    else
        target = nil
        highlight.Parent = nil
        highlight.Adornee = nil
        snapLine.Visible = false
    end
end)

local EnableToggle = SALeft:Toggle({
    Name = "Enable",
    Default = false,
    Flag = "SilentAimEnabled",
    Callback = function(v)
        cfg.enabled = v
        if not v then
            target = nil
            highlight.Parent = nil
            highlight.Adornee = nil
            snapLine.Visible = false
        end
    end
})

SALeft:Toggle({
    Name = "Wall Check",
    Default = true,
    Flag = "SilentAimWallCheck",
    Callback = function(v) cfg.wallCheck = v end
})

SALeft:Toggle({
    Name = "Alive Check",
    Default = true,
    Flag = "SilentAimAliveCheck",
    Callback = function(v) cfg.aliveCheck = v end
})

SALeft:Toggle({
    Name = "Friend Check",
    Default = true,
    Flag = "SilentAimFriendCheck",
    Callback = function(v) cfg.friendCheck = v end
})

SALeft:Slider({
    Name = "FOV Size",
    Min = 10,
    Max = 400,
    Default = 120,
    Flag = "SilentAimFOVSize",
    Callback = function(v) cfg.fovSize = v end
})

SARight:Toggle({
    Name = "Show FOV Circle",
    Default = true,
    Flag = "SilentAimShowFOV",
    Callback = function(v) cfg.showFov = v end
})

SARight:Toggle({
    Name = "Snapline",
    Default = true,
    Flag = "SilentAimSnapline",
    Callback = function(v) cfg.snapline = v end
})

SARight:Toggle({
    Name = "Highlight Target",
    Default = true,
    Flag = "SilentAimHighlight",
    Callback = function(v)
        cfg.highlightTarget = v
        if not v then
            highlight.Parent = nil
            highlight.Adornee = nil
        end
    end
})

SARight:Colorpicker({
    Name = "FOV Color",
    Default = Color3.fromRGB(255, 255, 255),
    Flag = "SilentAimFOVColor",
    Callback = function(v)
        cfg.fovColor = v
        fovCircle.Color = v
    end
})
