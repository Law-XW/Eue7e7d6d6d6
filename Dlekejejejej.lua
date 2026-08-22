local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local lplr = players.LocalPlayer
local char = lplr.Character or lplr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local cam = workspace.CurrentCamera

local targetCFrame1 = CFrame.new(820.763427734375, 3.3624675273895264, 1454.57861328125)
local targetCFrame2 = CFrame.new(886.0747680664062, 12.512099266052246, 1463.5357666015625)
local targetCFrame3 = CFrame.new(886.29931640625, 12.512099266052246, 1469.546630859375)
local speed = 35

local vel
local event

local function startSwim()
    if vel then return end
    vel = Instance.new("BodyVelocity")
    vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    vel.P = 1000000
    vel.Parent = root

    humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

    event = runService.Heartbeat:Connect(function()
        local cf = cam.CFrame.Rotation
        local dir = cf:VectorToObjectSpace(humanoid.MoveDirection * speed)
        local direction
        if dir.Magnitude == 0 then
            direction = Vector3.new(0, 0, 0)
        else
            direction = cf:VectorToWorldSpace(Vector3.new(dir.X, 0, dir.Z).Unit * dir.Magnitude)
        end
        vel.Velocity = direction
        humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
    end)
end

local function tweenTo(targetCFrame)
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed
    local tween = tweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

startSwim()

tweenTo(targetCFrame1)
tweenTo(targetCFrame2)
tweenTo(targetCFrame3)

local startPrompt = workspace:WaitForChild("ConstructionJob"):WaitForChild("Start"):WaitForChild("ProximityPrompt")

local function hasVest()
    return char:FindFirstChild("Job_SiteVest") or (lplr:FindFirstChild("Backpack") and lplr.Backpack:FindFirstChild("Job_SiteVest"))
end

repeat
    fireproximityprompt(startPrompt)
    task.wait(0.5)
until hasVest()

local materialsFolder = workspace:WaitForChild("ConstructionJob"):WaitForChild("Materials")
local houseFolder = workspace:WaitForChild("ConstructionJob"):WaitForChild("Plot"):WaitForChild("House")

local function getActiveTarget()
    for _, part in ipairs(houseFolder:GetDescendants()) do
        if part:IsA("ProximityPrompt") and part.Enabled then
            return part
        end
    end
    return nil
end

local function getMaterialName(prompt)
    local text = string.lower(prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name)
    for _, mat in ipairs(materialsFolder:GetChildren()) do
        if string.find(text, string.lower(mat.Name)) then
            return mat.Name
        end
    end
    return prompt.Parent.Name
end

local function getMaterialPrompt(matName)
    local matModel = materialsFolder:FindFirstChild(matName)
    if matModel then
        for _, v in ipairs(matModel:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                return v
            end
        end
    end
    return nil
end

local function getTool(matName)
    local search = string.lower(matName)
    local function check(parent)
        if not parent then return nil end
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("Tool") and string.find(string.lower(child.Name), search) then
                return child
            end
        end
        return nil
    end
    return check(char) or check(lplr:FindFirstChild("Backpack"))
end

local function equipTool(matName)
    local tool = getTool(matName)
    if tool and tool.Parent == lplr:FindFirstChild("Backpack") then
        humanoid:EquipTool(tool)
    end
end

while true do
    local targetPrompt = getActiveTarget()
    if not targetPrompt then
        task.wait(1)
        targetPrompt = getActiveTarget()
        if not targetPrompt then break end
    end

    local matName = getMaterialName(targetPrompt)
    local matPrompt = getMaterialPrompt(matName)

    if matPrompt then
        if not getTool(matName) then
            tweenTo(matPrompt.Parent.CFrame)

            repeat
                fireproximityprompt(matPrompt)
                task.wait(0.3)
            until getTool(matName)
        end

        tweenTo(targetPrompt.Parent.CFrame)

        repeat
            equipTool(matName)
            fireproximityprompt(targetPrompt)
            task.wait(0.3)
        until not targetPrompt.Enabled or not targetPrompt:IsDescendantOf(workspace)
    else
        task.wait(0.5)
    end
end
