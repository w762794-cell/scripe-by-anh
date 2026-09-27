-- palofsc: Delta Roblox egg steal script v4
-- ដក speed ចេញ (មិនកែ WalkSpeed)
-- បង្កើន performance សម្រាប់ទូរស័ព្ទ - មិនគាំង
-- GUI រាងមូលតូច + panel on/off
-- Auto collect egg ចូល inventory ដោយផ្ទាល់

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ============================================================
-- អថេរស្ថានភាព
-- ============================================================
local isRunning = false
local autoCollect = false
local collectDelay = 0.15
local lastEggScan = 0
local eggCache = {}
local scanInterval = 0.5

-- ============================================================
-- GUI រាងមូលតូច
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggStealMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0,, 50, 0, 50)
mainButton.P osition = UDim2.new(0, 20, 0, 200)
mainButton.BackgroundColor3 = Color3.fromRGB(3030, 30)
mainButton.Text = "EGG"
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.TextScaled = true
mainButton.Font = Enum.Font.GothamBold
mainButton.BorderSizePixel = 0
mainButton.Active = true
mainButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = mainButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 50, 50)
stroke.Thickness = 2
stroke.Parent = mainButton

-- Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 170, 0, 130)
panel.Position = UDim2.new(0, 80, 0, 200)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Active = true
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(255, 50, 50)
panelStroke.Thickness = 1.5
panelStroke.Parent = panel

-- ប៊ូតុង ON/OFF
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 140, 0, 40)
toggleBtn.Position = UDim2.new(0, 15, 0, 15)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = panel

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- ប៊ូតុង Auto Collect
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0, 140, 0, 40)
autoBtn.Position = UDim2.new(0, 15, 0, 70)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoBtn.Text = "Auto: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 16
autoBtn.BorderSizePixel = 0
autoBtn.Parent = panel

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 8)
autoCorner.Parent = autoBtn

-- ============================================================
-- មុខងារ GUI
-- ============================================================
local panelOpen = false

mainButton.MouseButton1Click:Connect(function()
    panelOpen = not panelOpen
    panel.Visible = panelOpen
end)

-- អូស GUI (មិនគាំង)
local dragging = false
local dragStart, startPos

mainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainButton.Position
    end
end)

mainButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainButton.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        panel.Position = UDim2.new(0, mainButton.Position.X.Offset + 60, 0, mainButton.Position.Y.Offset)
    end
end)

-- ============================================================
-- មុខងារស្វែងរក egg (cache សម្រាប់ performance)
-- ============================================================
local function refreshEggCache()
    eggCache = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = string.lower(obj.Name)
            if string.find(name, "egg") then
                table.insert(eggCache, obj)
            end
        end
    end
end

-- ============================================================
-- មុខងារលួច egg
-- ============================================================
local function stealEgg(egg)
    local targetPart
    if egg:IsA("BasePart") then
        targetPart = egg
    elseif egg:IsA("Model") then
        targetPart = egg:FindFirstChildWhichIsA("BasePart")
    end
    if not targetPart or not targetPart.Parent then return end

    -- Teleport ខ្លីៗ
    pcall(function()
        if HumanoidRootPart and HumanoidRootPart.Parent then
            HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 2, 0)
        end
    end)

    task.wait(0.03)

    -- ProximityPrompt
    for _, prompt in pairs(targetPart:GetChildren()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                fireproximityprompt(prompt)
            end)
        end
    end

    -- Touch interest
    pcall(function()
        firetouchinterest(HumanoidRootPart, targetPart, 0)
        task.wait(0.01)
        firetouchinterest(HumanoidRootPart, targetPart, 1)
    end)

    -- ហៅ remote collect ដោយផ្ទាល់
    pcall(function()
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local rname = string.lower(remote.Name)
                if string.find(rname, "collect") or string.find(rname, "egg") or string.find(rname, "claim") or string.find(rname, "pickup") then
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(targetPart)
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer(targetPart)
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- រង្វិលជាប់ (មិនគាំង - ប្រើ task.wait និង cache)
-- ============================================================
task.spawn(function()
    while task.wait(collectDelay) do
        if not isRunning or not autoCollect then continue end
        
        local now = tick()
        if now - lastEggScan > scanInterval then
            refreshEggCache()
            lastEggScan = now
        end

        for _, egg in pairs(eggCache) do
            if not egg or not egg.Parent then continue end
            pcall(function()
                stealEgg(egg)
            end)
            task.wait(0.02)
        end
    end
end)

-- រក្សាតួអង្គពេល respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
end)

-- ============================================================
-- មុខងារប៊ូតុង
-- ============================================================
toggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        toggleBtn.Text = "ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        stroke.Color = Color3.fromRGB(0, 255, 0)
    else
        toggleBtn.Text = "OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        stroke.Color = Color3.fromRGB(255, 50, 50)
    end
end)

autoBtn.MouseButton1Click:Connect(function()
    autoCollect = not autoCollect
    if autoCollect then
        autoBtn.Text = "Auto: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        autoBtn.Text = "Auto: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)
