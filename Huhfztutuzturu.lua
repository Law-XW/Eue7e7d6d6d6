if not hookfunction or typeof(hookfunction) ~= "function" then
    print("Executor is not supported")
end

local Workspace: Workspace? = game:GetService("Workspace")
if not Workspace then return warn("did not get Workspace") end 
local Players: Players? = game:GetService("Players")
if not Players then return warn("did not get Players") end 

local LocalPlayer: Player = Players.LocalPlayer
if not LocalPlayer then return warn("didnt get localplayer") end

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
    Title      = "CounterBlox",
    Icon       = "lucide:rocket",
    TotalSteps = 4,
})

Loading:SetMessage("Initializing...")
Loading:SetDescription("Waiting for game to load...")
task.wait(1)

Loading:SetCurrentStep(1)
Loading:SetDescription("Loading configuration...")
task.wait(1)

Loading:SetCurrentStep(2)
Loading:ShowSidebarPage(true)
Loading.Sidebar:AddLabel("User: " .. LocalPlayer.Name)
Loading.Sidebar:AddLabel("Version: v1.0.0")
task.wait(1)

local Window = ModernV2:Window({
    Title   = "CounterBlox",
    Content = "By Xeioa",
    Logo    = "rbxassetid://113064253322398",
    Color   = Color3.fromRGB(255, 105, 180),
    Config  = {
        ConfigFolder       = "CounterBloxXeioa",
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
    Name       = "CounterBlox | Xeioa",
    Logo       = Window.Logo,
    Enabled    = true,
    Draggable  = true,
    Position   = UDim2.new(0.5, 0, 0, 6),
    Desc       = "CounterBlox | Xeioa | {TIME} | {FPS} FPS | {MS} ms",
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

local CombatTab = Window:AddTab({ Name = "Combat", Icon = "crosshairs" })
local EspTab = Window:AddTab({ Name = "Esp", Icon = "eye" })
local VisualTab = Window:AddTab({ Name = "Visual", Icon = "palette" })

local Settings = {
    SilentAim = false,
    TeamCheck = true,
    WallCheck = true,
    AliveCheck = true,
    TargetPart = "Head",
    ShowFOV = false,
    FOVSize = 100,
    FOVColor = Color3.fromRGB(255, 105, 180),
    FOVFilled = false,
    FOVTransparency = 0.5,
    FOVThickness = 1,
    Snapline = false,
    SnaplineColor = Color3.fromRGB(255, 255, 255),
    SnaplineThickness = 1,
    HighlightTarget = false,
    HighlightColor = Color3.fromRGB(255, 0, 0),
    HighlightOutline = Color3.fromRGB(255, 255, 255),
    HighlightFillTransparency = 0.5,
    HighlightOutlineTransparency = 0,
    ThirdPerson = false,
    ThirdPersonDistance = 12,
    TargetHUD = false,

    ESP_Enabled = false,
    ESP_TeamCheck = true,
    ESP_Box = false,
    ESP_CornerBox = false,
    ESP_BoxColor = Color3.fromRGB(255, 255, 255),
    ESP_Name = false,
    ESP_NameColor = Color3.fromRGB(255, 255, 255),
    ESP_HealthBar = false,
    ESP_HealthText = false,
    ESP_Distance = false,
    ESP_DistanceColor = Color3.fromRGB(200, 200, 200),
    ESP_HeadDot = false,
    ESP_HeadDotColor = Color3.fromRGB(255, 105, 180),
    ESP_HeadDotSize = 4,
    ESP_Skeleton = false,
    ESP_SkeletonColor = Color3.fromRGB(255, 255, 255),

    Chams_Enabled = false,
    Chams_Type = "Highlight Visible",
    Chams_Color = Color3.fromRGB(255, 105, 180),
    Chams_OutlineColor = Color3.fromRGB(255, 255, 255),
    Chams_FillTransparency = 0.5,
    Chams_OutlineTransparency = 0,

    AntiAim = false,
    AntiAimType = "Spinbot",
    AntiAimSpeed = 20,

    SelfChams = false,
    SelfChamsColor = Color3.fromRGB(255, 105, 180),
    SelfChamsTransparency = 0.5,
}

local SilentAimSection = CombatTab:AddSection({
    Name = "SILENT AIM",
    Position = "Left",
    Collapsible = false,
    Collapsed = false,
    Box = false,
    TextSize = 11,
    TextXAlignment = "Left",
})

SilentAimSection:AddToggle({
    Name = "Enabled",
    Default = false,
    Flag = "SilentAim_Enabled",
    Callback = function(v) Settings.SilentAim = v end,
})

SilentAimSection:AddToggle({
    Name = "Team Check",
    Default = true,
    Flag = "SilentAim_TeamCheck",
    Callback = function(v) Settings.TeamCheck = v end,
})

SilentAimSection:AddToggle({
    Name = "Wall Check",
    Default = true,
    Flag = "SilentAim_WallCheck",
    Callback = function(v) Settings.WallCheck = v end,
})

SilentAimSection:AddToggle({
    Name = "Alive Check",
    Default = true,
    Flag = "SilentAim_AliveCheck",
    Callback = function(v) Settings.AliveCheck = v end,
})

SilentAimSection:AddDropdown({
    Name = "Target Part",
    Values = {"Head", "HumanoidRootPart"},
    Default = "Head",
    Flag = "SilentAim_TargetPart",
    Callback = function(v) Settings.TargetPart = v end,
})

SilentAimSection:AddToggle({
    Name = "Target HUD",
    Default = false,
    Flag = "SilentAim_TargetHUD",
    Callback = function(v) Settings.TargetHUD = v end,
})

local FOVSection = CombatTab:AddSection({
    Name = "FOV SETTINGS",
    Position = "Right",
    Collapsible = false,
    Collapsed = false,
    Box = false,
    TextSize = 11,
    TextXAlignment = "Left",
})

FOVSection:AddToggle({
    Name = "Show FOV",
    Default = false,
    Flag = "FOV_Show",
    Callback = function(v) Settings.ShowFOV = v end,
})

FOVSection:AddSlider({
    Name = "FOV Radius",
    Default = 100,
    Min = 10,
    Max = 500,
    Flag = "FOV_Radius",
    Callback = function(v) Settings.FOVSize = v end,
})

FOVSection:AddColorPicker({
    Name = "FOV Color",
    Default = Color3.fromRGB(255, 105, 180),
    Flag = "FOV_Color",
    Callback = function(v) Settings.FOVColor = v end,
})

FOVSection:AddToggle({
    Name = "Filled FOV",
    Default = false,
    Flag = "FOV_Filled",
    Callback = function(v) Settings.FOVFilled = v end,
})

FOVSection:AddSlider({
    Name = "FOV Transparency",
    Default = 5,
    Min = 1,
    Max = 10,
    Flag = "FOV_Transparency",
    Callback = function(v) Settings.FOVTransparency = v / 10 end,
})

FOVSection:AddSlider({
    Name = "FOV Thickness",
    Default = 1,
    Min = 1,
    Max = 5,
    Flag = "FOV_Thickness",
    Callback = function(v) Settings.FOVThickness = v end,
})

FOVSection:AddToggle({
    Name = "Snapline to Target",
    Default = false,
    Flag = "FOV_Snapline",
    Callback = function(v) Settings.Snapline = v end,
})

FOVSection:AddColorPicker({
    Name = "Snapline Color",
    Default = Color3.fromRGB(255, 255, 255),
    Flag = "FOV_SnaplineColor",
    Callback = function(v) Settings.SnaplineColor = v end,
})

FOVSection:AddSlider({
    Name = "Snapline Thickness",
    Default = 1,
    Min = 1,
    Max = 5,
    Flag = "FOV_SnaplineThickness",
    Callback = function(v) Settings.SnaplineThickness = v end,
})

FOVSection:AddToggle({
    Name = "Highlight Target",
    Default = false,
    Flag = "FOV_HighlightTarget",
    Callback = function(v) Settings.HighlightTarget = v end,
})

FOVSection:AddColorPicker({
    Name = "Highlight Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "FOV_HighlightColor",
    Callback = function(v) Settings.HighlightColor = v end,
})

FOVSection:AddColorPicker({
    Name = "Highlight Outline Color",
    Default = Color3.fromRGB(255, 255, 255),
    Flag = "FOV_HighlightOutline",
    Callback = function(v) Settings.HighlightOutline = v end,
})

local EspMainSec = EspTab:AddSection({
    Name = "ESP MAIN",
    Position = "Left",
    Collapsible = false,
    Collapsed = false,
    Box = false,
    TextSize = 11,
    TextXAlignment = "Left",
})

EspMainSec:AddToggle({
    Name = "ESP Enabled",
    Default = false,
    Flag = "ESP_Enabled",
    Callback = function(v) Settings.ESP_Enabled = v end,
})

EspMainSec:AddToggle({
    Name = "Team Check",
    Default = true,
    Flag = "ESP_TeamCheck",
    Callback = function(v) Settings.ESP_TeamCheck = v end,
})

EspMainSec:AddToggle({
    Name = "Box ESP",
    Default = false,
    Flag = "ESP_Box",
    Callback = function(v) Settings.ESP_Box = v end,
})

EspMainSec:AddToggle({
    Name = "Corner Box ESP",
    Default = false,
    Flag = "ESP_CornerBox",
    Callback = function(v) Settings.ESP_CornerBox = v end,
})

EspMainSec:AddColorPicker({
    Name = "Box Color",
    Default = Color3.fromRGB(255, 255, 255),
    Flag = "ESP_BoxColor",
    Callback = function(v) Settings.ESP_BoxColor = v end,
})

EspMainSec:AddToggle({
    Name = "Name ESP",
    Default = false,
    Flag = "ESP_Name",
    Callback = function(v) Settings.ESP_Name = v end,
})

EspMainSec:AddColorPicker({
    Name = "Name Color",
    Default = Color3.fromRGB(255, 255, 255),
    Flag = "ESP_NameColor",
    Callback = function(v) Settings.ESP_NameColor = v end,
})

local EspSubSec = EspTab:AddSection({
    Name = "ESP EXTRA",
    Position = "Right",
    Collapsible = false,
    Collapsed = false,
    Box = false,
    TextSize = 11,
    TextXAlignment = "Left",
})

EspSubSec:AddToggle({
    Name = "Health Bar",
    Default = false,
    Flag = "ESP_HealthBar",
    Callback = function(v) Settings.ESP_HealthBar = v end,
})

EspSubSec:AddToggle({
    Name = "Health Text",
    Default = false,
    Flag = "ESP_HealthText",
    Callback = function(v) Settings.ESP_HealthText = v end,
})

EspSubSec:AddToggle({
    Name = "Distance ESP",
    Default = false,
    Flag = "ESP_Distance",
    Callback = function(v) Settings.ESP_Distance = v end,
})

EspSubSec:AddColorPicker({
    Name = "Distance Color",
    Default = Color3.fromRGB(200, 200, 200),
    Flag = "ESP_DistanceColor",
    Callback = function(v) Settings.ESP_DistanceColor = v end,
})

EspSubSec:AddToggle({
    Name = "Head Dot",
    Default = false,
    Flag = "ESP_HeadDot",
    Callback = function(v) Settings.ESP_HeadDot = v end,
})

EspSubSec:AddColorPicker({
    Name = "Head Dot Color",
    Default = Color3.fromRGB(255, 105, 180),
    Flag = "ESP_HeadDotColor",
    Callback = function(v) Settings.ESP_HeadDotColor = v end,
})

EspSubSec:AddSlider({
    Name = "Head Dot Size",
    Default = 4,
    Min = 2,
    Max = 10,
    Flag = "ESP_HeadDotSize",
    Callback = function(v) Settings.ESP_HeadDotSize = v end,
})

EspSubSec:AddToggle({
    Name = "Skeleton ESP",
    Default = false,
    Flag = "ESP_Skeleton",
    Callback = function(v) Settings.ESP_Skeleton = v end,
})

EspSubSec:AddColorPicker({
    Name = "Skeleton Color",
    Default = Color3.fromRGB(255, 255, 255),
    Flag = "ESP_SkeletonColor",
    Callback = function(v) Settings.ESP_SkeletonColor = v end,
})

local ChamsSec = EspTab:AddSection({
    Name = "CHAMS ESP",
    Position = "Left",
    Collapsible = false,
    Collapsed = false,
    Box = false,
    TextSize = 11,
    TextXAlignment = "Left",
})

ChamsSec:AddToggle({
    Name = "Chams Enabled",
    Default = false,
    Flag = "Chams_Enabled",
    Callback = function(v) Settings.Chams_Enabled = v end,
})

ChamsSec:AddDropdown({
    Name = "Chams Type",
    Values = {"Highlight AlwaysOnTop", "Highlight Visible", "ForceField", "Neon", "Glass"},
    Default = "Highlight Visible",
    Flag = "Chams_Type",
    Callback = function(v) Settings.Chams_Type = v end,
})

ChamsSec:AddColorPicker({
    Name = "Chams Color",
    Default = Color3.fromRGB(255, 105, 180),
    Flag = "Chams_Color",
    Callback = function(v) Settings.Chams_Color = v end,
})

ChamsSec:AddColorPicker({
    Name = "Outline Color",
    Default = Color3.fromRGB(255, 255, 255),
    Flag = "Chams_OutlineColor",
    Callback = function(v) Settings.Chams_OutlineColor = v end,
})

ChamsSec:AddSlider({
    Name = "Fill Transparency",
    Default = 5,
    Min = 0,
    Max = 10,
    Flag = "Chams_FillTrans",
    Callback = function(v) Settings.Chams_FillTransparency = v / 10 end,
})

ChamsSec:AddSlider({
    Name = "Outline Transparency",
    Default = 0,
    Min = 0,
    Max = 10,
    Flag = "Chams_OutlineTrans",
    Callback = function(v) Settings.Chams_OutlineTransparency = v / 10 end,
})

local CameraSection = VisualTab:AddSection({
    Name = "Camera",
    Position = "Left",
    Collapsible = false,
    Collapsed = false,
    Box = false,
    TextSize = 11,
    TextXAlignment = "Left",
})

CameraSection:AddToggle({
    Name = "Third Person",
    Default = false,
    Flag = "Visual_ThirdPerson",
    Callback = function(v) Settings.ThirdPerson = v end,
})

CameraSection:AddSlider({
    Name = "Third Person Distance",
    Default = 12,
    Min = 5,
    Max = 30,
    Flag = "Visual_ThirdPersonDist",
    Callback = function(v) Settings.ThirdPersonDistance = v end,
})

local AntiAimSec = VisualTab:AddSection({
    Name = "Anti Aim",
    Position = "Right",
    Collapsible = false,
    Collapsed = false,
    Box = false,
    TextSize = 11,
    TextXAlignment = "Left",
})

AntiAimSec:AddToggle({
    Name = "Enabled",
    Default = false,
    Flag = "AntiAim_Enabled",
    Callback = function(v) Settings.AntiAim = v end,
})

AntiAimSec:AddDropdown({
    Name = "Type",
    Values = {"Spinbot", "Jitter", "Backwards", "Down"},
    Default = "Spinbot",
    Flag = "AntiAim_Type",
    Callback = function(v) Settings.AntiAimType = v end,
})

AntiAimSec:AddSlider({
    Name = "Speed / Offset",
    Default = 20,
    Min = 1,
    Max = 100,
    Flag = "AntiAim_Speed",
    Callback = function(v) Settings.AntiAimSpeed = v end,
})

local SelfChamsSec = VisualTab:AddSection({
    Name = "Player Chams",
    Position = "Left",
    Collapsible = false,
    Collapsed = false,
    Box = false,
    TextSize = 11,
    TextXAlignment = "Left",
})

SelfChamsSec:AddToggle({
    Name = "ForceField Player",
    Default = false,
    Flag = "SelfChams_Enabled",
    Callback = function(v) Settings.SelfChams = v end,
})

SelfChamsSec:AddColorPicker({
    Name = "Player Color",
    Default = Color3.fromRGB(255, 105, 180),
    Flag = "SelfChams_Color",
    Callback = function(v) Settings.SelfChamsColor = v end,
})

SelfChamsSec:AddSlider({
    Name = "Transparency",
    Default = 5,
    Min = 0,
    Max = 10,
    Flag = "SelfChams_Trans",
    Callback = function(v) Settings.SelfChamsTransparency = v / 10 end,
})

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XeioaTargetHUDGui"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

local TargetFrame = Instance.new("Frame")
TargetFrame.Name = "TargetHUD"
TargetFrame.Size = UDim2.new(0, 260, 0, 80)
TargetFrame.Position = UDim2.new(0.5, -130, 0.7, 0)
TargetFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
TargetFrame.BorderSizePixel = 0
TargetFrame.Visible = false
TargetFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = TargetFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 105, 180)
UIStroke.Thickness = 1.5
UIStroke.Parent = TargetFrame

local ViewportFrame = Instance.new("ViewportFrame")
ViewportFrame.Size = UDim2.new(0, 64, 0, 64)
ViewportFrame.Position = UDim2.new(0, 8, 0.5, -32)
ViewportFrame.BackgroundTransparency = 1
ViewportFrame.Parent = TargetFrame

local VPCamera = Instance.new("Camera")
ViewportFrame.CurrentCamera = VPCamera
VPCamera.Parent = ViewportFrame

local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(0, 170, 0, 20)
NameLabel.Position = UDim2.new(0, 80, 0, 10)
NameLabel.BackgroundTransparency = 1
NameLabel.Font = Enum.Font.SourceSansBold
NameLabel.TextSize = 16
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Text = "Name: None"
NameLabel.Parent = TargetFrame

local TeamLabel = Instance.new("TextLabel")
TeamLabel.Size = UDim2.new(0, 170, 0, 18)
TeamLabel.Position = UDim2.new(0, 80, 0, 30)
TeamLabel.BackgroundTransparency = 1
TeamLabel.Font = Enum.Font.SourceSans
TeamLabel.TextSize = 14
TeamLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TeamLabel.TextXAlignment = Enum.TextXAlignment.Left
TeamLabel.Text = "Team: None"
TeamLabel.Parent = TargetFrame

local HealthBarBackground = Instance.new("Frame")
HealthBarBackground.Size = UDim2.new(0, 170, 0, 12)
HealthBarBackground.Position = UDim2.new(0, 80, 0, 52)
HealthBarBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
HealthBarBackground.BorderSizePixel = 0
HealthBarBackground.Parent = TargetFrame

local HealthCorner = Instance.new("UICorner")
HealthCorner.CornerRadius = UDim.new(0, 4)
HealthCorner.Parent = HealthBarBackground

local HealthBar = Instance.new("Frame")
HealthBar.Size = UDim2.new(1, 0, 1, 0)
HealthBar.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
HealthBar.BorderSizePixel = 0
HealthBar.Parent = HealthBarBackground

local HealthCorner2 = Instance.new("UICorner")
HealthCorner2.CornerRadius = UDim.new(0, 4)
HealthCorner2.Parent = HealthBar

local HealthText = Instance.new("TextLabel")
HealthText.Size = UDim2.new(1, 0, 1, 0)
HealthText.BackgroundTransparency = 1
HealthText.Font = Enum.Font.SourceSansBold
HealthText.TextSize = 11
HealthText.TextColor3 = Color3.fromRGB(255, 255, 255)
HealthText.Text = "100 HP"
HealthText.Parent = HealthBarBackground

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = Settings.FOVThickness
FOVCircle.Color = Settings.FOVColor
FOVCircle.Filled = Settings.FOVFilled
FOVCircle.Transparency = Settings.FOVTransparency
FOVCircle.Radius = Settings.FOVSize

local Snapline = Drawing.new("Line")
Snapline.Visible = false
Snapline.Thickness = Settings.SnaplineThickness
Snapline.Color = Settings.SnaplineColor

local TargetHighlight = Instance.new("Highlight")
TargetHighlight.Name = "XeioaTargetHighlight"
TargetHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

local ESPCache = {}
local ChamsCache = {}
local SelfCache = { DefaultMaterials = {}, DefaultTrans = {} }

local function CreateESP(player)
    if ESPCache[player] then return end
    
    local drawings = {
        Box = Drawing.new("Square"),
        CornerLines = {},
        Name = Drawing.new("Text"),
        HealthBarBG = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        HealthText = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HeadDot = Drawing.new("Circle"),
        Skeleton = {},
    }

    drawings.Box.Visible = false
    drawings.Box.Thickness = 1
    drawings.Box.Filled = false

    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1
        table.insert(drawings.CornerLines, line)
    end

    drawings.Name.Visible = false
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Size = 13

    drawings.HealthBarBG.Visible = false
    drawings.HealthBarBG.Filled = true
    drawings.HealthBarBG.Color = Color3.fromRGB(20, 20, 20)

    drawings.HealthBar.Visible = false
    drawings.HealthBar.Filled = true

    drawings.HealthText.Visible = false
    drawings.HealthText.Center = true
    drawings.HealthText.Outline = true
    drawings.HealthText.Size = 11

    drawings.Distance.Visible = false
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Size = 11

    drawings.HeadDot.Visible = false
    drawings.HeadDot.Filled = true

    local skeletonBones = {
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
    }

    for _, pair in ipairs(skeletonBones) do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1
        table.insert(drawings.Skeleton, {line = line, bone1 = pair[1], bone2 = pair[2]})
    end

    ESPCache[player] = drawings
end

local function RemoveESP(player)
    if ESPCache[player] then
        local drawings = ESPCache[player]
        drawings.Box:Remove()
        for _, line in ipairs(drawings.CornerLines) do line:Remove() end
        drawings.Name:Remove()
        drawings.HealthBarBG:Remove()
        drawings.HealthBar:Remove()
        drawings.HealthText:Remove()
        drawings.Distance:Remove()
        drawings.HeadDot:Remove()
        for _, item in ipairs(drawings.Skeleton) do item.line:Remove() end
        ESPCache[player] = nil
    end

    if ChamsCache[player] then
        if ChamsCache[player].Highlight then ChamsCache[player].Highlight:Destroy() end
        ChamsCache[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)
Players.PlayerRemoving:Connect(RemoveESP)

local target = nil
local lastTargetChar = nil
local aaAngle = 0

local function isVisible(targetPart: Instance?): boolean
    if not targetPart or typeof(targetPart) ~= "Instance" or targetPart.Parent == nil then 
        return false 
    end 
    local cam: Camera? = Workspace.CurrentCamera
    if not cam then return false end 
    local char: Model? = LocalPlayer.Character
    if not char then return false end
    local origin: CFrame = cam.CFrame

    local params: RaycastParams = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    params.IgnoreWater = true

    if not targetPart:IsA("BasePart") then return false end

    local direction: Vector3 = (targetPart.Position - origin.Position)
    local result: RaycastResult? = Workspace:Raycast(origin.Position, direction, params)

    if result then
        local model: Model? = result.Instance:FindFirstAncestorOfClass("Model")
        if model and Players:GetPlayerFromCharacter(model) then
            return true
        end
        return false
    else
        return true
    end
end

local function isEnemy(player: Player): boolean
    if not player or player == LocalPlayer then return false end
    
    local Status = player:FindFirstChild("Status")
    local LocalStatus = LocalPlayer:FindFirstChild("Status")
    
    if Settings.AliveCheck and Status then
        local Alive = Status:FindFirstChild("Alive")
        if Alive and not Alive.Value then return false end
    end

    if Settings.TeamCheck and Status and LocalStatus then
        local Team = Status:FindFirstChild("Team")
        local LocalTeam = LocalStatus:FindFirstChild("Team")
        if Team and LocalTeam then
            if Team.Value == "Spectator" or Team.Value == LocalTeam.Value then
                return false
            end
        end
    end

    return true
end

local function isESPEnemy(player: Player): boolean
    if not player or player == LocalPlayer then return false end
    
    local Status = player:FindFirstChild("Status")
    local LocalStatus = LocalPlayer:FindFirstChild("Status")
    
    if Status then
        local Alive = Status:FindFirstChild("Alive")
        if Alive and not Alive.Value then return false end
    end

    if Settings.ESP_TeamCheck and Status and LocalStatus then
        local Team = Status:FindFirstChild("Team")
        local LocalTeam = LocalStatus:FindFirstChild("Team")
        if Team and LocalTeam then
            if Team.Value == "Spectator" or Team.Value == LocalTeam.Value then
                return false
            end
        end
    end

    return true
end

local function GetClosestPlayer(): Instance?
    if not Settings.SilentAim then return nil end

    local closestDistance: number = Settings.FOVSize
    local closest: Instance = nil
    local camera: Camera = Workspace.CurrentCamera
    if not camera then return nil end

    local center: Vector2 = camera.ViewportSize / 2

    for _, v in pairs(Players:GetPlayers()) do
        if v == LocalPlayer then continue end
        
        local char: Model? = v.Character
        if not char then continue end

        if not isEnemy(v) then continue end

        local hitPart: Instance? = char:FindFirstChild(Settings.TargetPart)
        if not hitPart or not hitPart:IsA("BasePart") then continue end

        local screenPos: Vector3, onScreen: boolean = camera:WorldToViewportPoint(hitPart.Position)
        if onScreen then
            local distance: number = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if distance <= closestDistance then
                if Settings.WallCheck and not isVisible(hitPart) then continue end
                closestDistance = distance
                closest = hitPart
            end
        end
    end
    return closest
end

local function UpdateViewport(char)
    ViewportFrame:ClearAllChildren()
    local cam = Instance.new("Camera")
    ViewportFrame.CurrentCamera = cam
    cam.Parent = ViewportFrame
    
    char.Archivable = true
    local clone = char:Clone()
    char.Archivable = false
    
    for _, v in pairs(clone:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") then
            v:Destroy()
        end
    end
    
    clone.Parent = ViewportFrame
    
    local hrp = clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChild("Head")
    if hrp then
        cam.CFrame = CFrame.new(hrp.Position + (hrp.CFrame.LookVector * 4) + Vector3.new(0, 1.5, 0), hrp.Position + Vector3.new(0, 1, 0))
    end
end

local function UpdateChams(player)
    local char = player.Character
    if not char then return end

    if not ChamsCache[player] then
        ChamsCache[player] = { DefaultMaterials = {}, DefaultTrans = {} }
    end

    local cache = ChamsCache[player]

    if Settings.Chams_Enabled and isESPEnemy(player) then
        if Settings.Chams_Type == "Highlight AlwaysOnTop" or Settings.Chams_Type == "Highlight Visible" then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and cache.DefaultMaterials[part] then
                    part.Material = cache.DefaultMaterials[part]
                    part.Transparency = cache.DefaultTrans[part]
                end
            end

            if not cache.Highlight or cache.Highlight.Parent ~= char then
                if cache.Highlight then cache.Highlight:Destroy() end
                cache.Highlight = Instance.new("Highlight")
                cache.Highlight.Name = "XeioaChams"
                cache.Highlight.Parent = char
            end

            cache.Highlight.Enabled = true
            cache.Highlight.FillColor = Settings.Chams_Color
            cache.Highlight.OutlineColor = Settings.Chams_OutlineColor
            cache.Highlight.FillTransparency = Settings.Chams_FillTransparency
            cache.Highlight.OutlineTransparency = Settings.Chams_OutlineTransparency
            if Settings.Chams_Type == "Highlight AlwaysOnTop" then
                cache.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            else
                cache.Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
            end
        else
            if cache.Highlight then
                cache.Highlight.Enabled = false
            end

            local mat = Enum.Material.ForceField
            if Settings.Chams_Type == "Neon" then mat = Enum.Material.Neon end
            if Settings.Chams_Type == "Glass" then mat = Enum.Material.Glass end

            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if not cache.DefaultMaterials[part] then
                        cache.DefaultMaterials[part] = part.Material
                        cache.DefaultTrans[part] = part.Transparency
                    end
                    part.Material = mat
                    part.Color = Settings.Chams_Color
                    part.Transparency = Settings.Chams_FillTransparency
                end
            end
        end
    else
        if cache.Highlight then
            cache.Highlight.Enabled = false
        end
        for part, mat in pairs(cache.DefaultMaterials) do
            if part and part.Parent then
                part.Material = mat
                part.Transparency = cache.DefaultTrans[part] or 0
            end
        end
    end
end

local function UpdateSelfChams()
    local char = LocalPlayer.Character
    if not char then return end

    if Settings.SelfChams then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if not SelfCache.DefaultMaterials[part] then
                    SelfCache.DefaultMaterials[part] = part.Material
                    SelfCache.DefaultTrans[part] = part.Transparency
                end
                part.Material = Enum.Material.ForceField
                part.Color = Settings.SelfChamsColor
                part.Transparency = Settings.SelfChamsTransparency
            end
        end
    else
        for part, mat in pairs(SelfCache.DefaultMaterials) do
            if part and part.Parent then
                part.Material = mat
                part.Transparency = SelfCache.DefaultTrans[part] or 0
            end
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    local camera: Camera = Workspace.CurrentCamera
    if camera then
        FOVCircle.Position = camera.ViewportSize / 2
        FOVCircle.Radius = Settings.FOVSize
        FOVCircle.Color = Settings.FOVColor
        FOVCircle.Visible = Settings.ShowFOV
        FOVCircle.Filled = Settings.FOVFilled
        FOVCircle.Transparency = Settings.FOVTransparency
        FOVCircle.Thickness = Settings.FOVThickness

        if Settings.ThirdPerson and LocalPlayer.Character then
            local char = LocalPlayer.Character
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.LocalTransparencyModifier = 0
                end
            end

            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if head then
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {char}
                
                local raycastResult = Workspace:Raycast(head.Position, -camera.CFrame.LookVector * Settings.ThirdPersonDistance, rayParams)
                local targetDist = Settings.ThirdPersonDistance
                if raycastResult then
                    targetDist = (raycastResult.Position - head.Position).Magnitude - 0.5
                end
                camera.CFrame = camera.CFrame * CFrame.new(0, 0, targetDist)
            end
        end
    else
        FOVCircle.Visible = false
    end

    if Settings.AntiAim and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if Settings.AntiAimType == "Spinbot" then
                aaAngle = (aaAngle + Settings.AntiAimSpeed) % 360
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(aaAngle), 0)
            elseif Settings.AntiAimType == "Jitter" then
                local jitter = (math.random(-Settings.AntiAimSpeed, Settings.AntiAimSpeed))
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(jitter), 0)
            elseif Settings.AntiAimType == "Backwards" then
                if camera then
                    local camY = camera.CFrame.LookVector
                    local yaw = math.atan2(-camY.X, -camY.Z)
                    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, yaw, 0)
                end
            elseif Settings.AntiAimType == "Down" then
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(math.rad(89), 0, 0)
            end
        end
    end

    UpdateSelfChams()

    target = GetClosestPlayer()

    if target and target:IsA("BasePart") and camera then
        local screenPos, onScreen = camera:WorldToViewportPoint(target.Position)
        
        if Settings.Snapline and onScreen then
            Snapline.From = camera.ViewportSize / 2
            Snapline.To = Vector2.new(screenPos.X, screenPos.Y)
            Snapline.Color = Settings.SnaplineColor
            Snapline.Thickness = Settings.SnaplineThickness
            Snapline.Visible = true
        else
            Snapline.Visible = false
        end

        local charModel = target:FindFirstAncestorOfClass("Model")
        local player = charModel and Players:GetPlayerFromCharacter(charModel)

        if Settings.HighlightTarget and charModel then
            TargetHighlight.Parent = charModel
            TargetHighlight.FillColor = Settings.HighlightColor
            TargetHighlight.OutlineColor = Settings.HighlightOutline
            TargetHighlight.FillTransparency = Settings.HighlightFillTransparency
            TargetHighlight.OutlineTransparency = Settings.HighlightOutlineTransparency
            TargetHighlight.Enabled = true
        else
            TargetHighlight.Enabled = false
            TargetHighlight.Parent = nil
        end

        if Settings.TargetHUD and player and charModel then
            TargetFrame.Visible = true
            NameLabel.Text = "Name: " .. player.Name
            
            local status = player:FindFirstChild("Status")
            local teamVal = status and status:FindFirstChild("Team")
            TeamLabel.Text = "Team: " .. (teamVal and tostring(teamVal.Value) or "None")

            local hum = charModel:FindFirstChildOfClass("Humanoid")
            if hum then
                local hp = math.clamp(hum.Health, 0, hum.MaxHealth)
                local maxHp = hum.MaxHealth
                HealthBar.Size = UDim2.new(hp / maxHp, 0, 1, 0)
                HealthText.Text = math.floor(hp) .. " / " .. math.floor(maxHp) .. " HP"
            end

            if lastTargetChar ~= charModel then
                lastTargetChar = charModel
                UpdateViewport(charModel)
            end
        else
            TargetFrame.Visible = false
            lastTargetChar = nil
        end
    else
        Snapline.Visible = false
        TargetHighlight.Enabled = false
        TargetHighlight.Parent = nil
        TargetFrame.Visible = false
        lastTargetChar = nil
    end

    for player, drawings in pairs(ESPCache) do
        UpdateChams(player)

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if Settings.ESP_Enabled and char and hrp and head and hum and camera and isESPEnemy(player) then
            local hrpPos, onScreen = camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 2
                local boxPos = Vector2.new(hrpPos.X - width / 2, headPos.Y)

                if Settings.ESP_Box then
                    drawings.Box.Size = Vector2.new(width, height)
                    drawings.Box.Position = boxPos
                    drawings.Box.Color = Settings.ESP_BoxColor
                    drawings.Box.Visible = true
                else
                    drawings.Box.Visible = false
                end

                if Settings.ESP_CornerBox then
                    local lineLen = width / 4
                    local cLines = drawings.CornerLines

                    cLines[1].From = boxPos
                    cLines[1].To = boxPos + Vector2.new(lineLen, 0)

                    cLines[2].From = boxPos
                    cLines[2].To = boxPos + Vector2.new(0, lineLen)

                    cLines[3].From = boxPos + Vector2.new(width, 0)
                    cLines[3].To = boxPos + Vector2.new(width - lineLen, 0)

                    cLines[4].From = boxPos + Vector2.new(width, 0)
                    cLines[4].To = boxPos + Vector2.new(width, lineLen)

                    cLines[5].From = boxPos + Vector2.new(0, height)
                    cLines[5].To = boxPos + Vector2.new(lineLen, height)

                    cLines[6].From = boxPos + Vector2.new(0, height)
                    cLines[6].To = boxPos + Vector2.new(0, height - lineLen)

                    cLines[7].From = boxPos + Vector2.new(width, height)
                    cLines[7].To = boxPos + Vector2.new(width - lineLen, height)

                    cLines[8].From = boxPos + Vector2.new(width, height)
                    cLines[8].To = boxPos + Vector2.new(width, height - lineLen)

                    for _, line in ipairs(cLines) do
                        line.Color = Settings.ESP_BoxColor
                        line.Visible = true
                    end
                else
                    for _, line in ipairs(drawings.CornerLines) do line.Visible = false end
                end

                if Settings.ESP_Name then
                    drawings.Name.Text = player.Name
                    drawings.Name.Position = Vector2.new(boxPos.X + width / 2, boxPos.Y - 16)
                    drawings.Name.Color = Settings.ESP_NameColor
                    drawings.Name.Visible = true
                else
                    drawings.Name.Visible = false
                end

                if Settings.ESP_HealthBar then
                    local hp = math.clamp(hum.Health, 0, hum.MaxHealth)
                    local pct = hp / hum.MaxHealth
                    local barHeight = height * pct

                    drawings.HealthBarBG.Size = Vector2.new(4, height)
                    drawings.HealthBarBG.Position = Vector2.new(boxPos.X - 6, boxPos.Y)
                    drawings.HealthBarBG.Visible = true

                    drawings.HealthBar.Size = Vector2.new(2, barHeight)
                    drawings.HealthBar.Position = Vector2.new(boxPos.X - 5, boxPos.Y + (height - barHeight))
                    drawings.HealthBar.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), pct)
                    drawings.HealthBar.Visible = true
                else
                    drawings.HealthBarBG.Visible = false
                    drawings.HealthBar.Visible = false
                end

                if Settings.ESP_HealthText then
                    local hp = math.floor(hum.Health)
                    drawings.HealthText.Text = hp .. " HP"
                    drawings.HealthText.Position = Vector2.new(boxPos.X - 22, boxPos.Y + height / 2 - 6)
                    drawings.HealthText.Color = Color3.fromRGB(255, 255, 255)
                    drawings.HealthText.Visible = true
                else
                    drawings.HealthText.Visible = false
                end

                if Settings.ESP_Distance then
                    local dist = math.floor((camera.CFrame.Position - hrp.Position).Magnitude)
                    drawings.Distance.Text = dist .. "m"
                    drawings.Distance.Position = Vector2.new(boxPos.X + width / 2, boxPos.Y + height + 2)
                    drawings.Distance.Color = Settings.ESP_DistanceColor
                    drawings.Distance.Visible = true
                else
                    drawings.Distance.Visible = false
                end

                if Settings.ESP_HeadDot then
                    local hDotPos = camera:WorldToViewportPoint(head.Position)
                    drawings.HeadDot.Position = Vector2.new(hDotPos.X, hDotPos.Y)
                    drawings.HeadDot.Radius = Settings.ESP_HeadDotSize
                    drawings.HeadDot.Color = Settings.ESP_HeadDotColor
                    drawings.HeadDot.Visible = true
                else
                    drawings.HeadDot.Visible = false
                end

                if Settings.ESP_Skeleton then
                    for _, item in ipairs(drawings.Skeleton) do
                        local p1 = char:FindFirstChild(item.bone1)
                        local p2 = char:FindFirstChild(item.bone2)
                        if p1 and p2 then
                            local pos1, vis1 = camera:WorldToViewportPoint(p1.Position)
                            local pos2, vis2 = camera:WorldToViewportPoint(p2.Position)
                            if vis1 and vis2 then
                                item.line.From = Vector2.new(pos1.X, pos1.Y)
                                item.line.To = Vector2.new(pos2.X, pos2.Y)
                                item.line.Color = Settings.ESP_SkeletonColor
                                item.line.Visible = true
                            else
                                item.line.Visible = false
                            end
                        else
                            item.line.Visible = false
                        end
                    end
                else
                    for _, item in ipairs(drawings.Skeleton) do item.line.Visible = false end
                end
            else
                drawings.Box.Visible = false
                for _, line in ipairs(drawings.CornerLines) do line.Visible = false end
                drawings.Name.Visible = false
                drawings.HealthBarBG.Visible = false
                drawings.HealthBar.Visible = false
                drawings.HealthText.Visible = false
                drawings.Distance.Visible = false
                drawings.HeadDot.Visible = false
                for _, item in ipairs(drawings.Skeleton) do item.line.Visible = false end
            end
        else
            drawings.Box.Visible = false
            for _, line in ipairs(drawings.CornerLines) do line.Visible = false end
            drawings.Name.Visible = false
            drawings.HealthBarBG.Visible = false
            drawings.HealthBar.Visible = false
            drawings.HealthText.Visible = false
            drawings.Distance.Visible = false
            drawings.HeadDot.Visible = false
            for _, item in ipairs(drawings.Skeleton) do item.line.Visible = false end
        end
    end
end)

local old: any
pcall(function()
    old = hookfunction(Ray.new, newcclosure(function(origin, direction)
        local trace = debug.traceback()
        if trace:find("Client") and not trace:find("10420") and not trace:find("10595") then
            local finalDir = direction
            if Settings.SilentAim and target and target:IsA("BasePart") then
                finalDir = target.Position - origin
            end
            return old(origin, finalDir)
        end
        return old(origin, direction)
    end))
end)

Loading:SetCurrentStep(4)
Loading:Continue(Window)

Window:Notify({ Title = "CounterBlox", Content = "Script loaded!", Duration = 4 })
