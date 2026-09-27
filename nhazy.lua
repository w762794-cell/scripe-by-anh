-- palofsc: Delta Roblox Steal An Egg script v6 - Stable Edition
-- Screen ធម្មតា 100% (មិនប៉ះពាល់ camera)
-- Auto steal ចូល inventory ដោយផ្ទាល់ Players (មិនបាច់រត់ទៅ safezone)
-- Compatible 27.09.2026 anti-cheat

local Players = game:GetService.Local("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
Playerlocal CoreGui = game:GetService("CoreGui")

local LocalPlayer =
local Camera = workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ============================================================
 Human-- ANTI-CHEAT BYPASS (ស្រាល)
-- ============================================================
local originalWalkSpeed = Humanoid.WalkoidSpeed
local originalJumpPower =.JumpPower

local mt = getrawmetatable(game)
local oldIndex = mt.__index
local oldNewIndex = mt.__newindex
setreadonly(mt, false)

mt.__index = newcclosure(function(self, key)
    if self == Humanoid then
        if key == "WalkSpeed" then return originalWalkSpeed end
        if key == "JumpPower" then return originalJumpPower end
    end
    return oldIndex(self, key)
end)

mt.__newindex = newcclosure(function(self, key, value)
    if self == Humanoid and (key == "WalkSpeed" or key == "JumpPower") then
        oldNewIndex(self, key, value)
        return
    end
    return oldNewIndex(self, key, value)
end)
setreadonly(mt, true)

-- ============================================================
-- អថេរ
-- ============================================================
local isRunning = false
local autoCollect = false
local currentSpeed = 1000
local speedPresets = {1000, 9000, 10000, 40000, 170000, 700000, 2500000, 17000000, 700000000}
local lastCollectTime = 0
local collectInterval = 0.25
local eggCache = {}
local lastScan = 0
local scanInterval = 0.8

-- ============================================================
-- GUI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggStealMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 55, 0, 55)
mainButton.Position = UDim2.new(0, 20, 0, 200)
mainButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainButton.Text = "EGG"
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.TextScaled = true
mainButton.Font = Enum.Font.GothamBold
mainButton.BorderSizePixel = 0
mainButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = mainButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 50, 50)
stroke.Thickness = 2
stroke.Parent = mainButton

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 180, 0, 210)
panel.Position = UDim2.new(0, 85, 0, 200)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(255, 50, 50)
panelStroke.Thickness = 1.5
panelStroke.Parent = panel

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 150, 0, 38)
toggleBtn.Position = UDim2.new(0, 15, 0, 15)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 17
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = panel

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 150, 0, 22)
speedLabel.Position = UDim2.new(0, 15, 0, 60)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 1000"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 13
speedLabel.Parent = panel

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0, 150, 0, 8)
sliderBg.Position = UDim2.new(0, 15, 0, 88)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = panel

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = sliderFill

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 16, 0, 16)
sliderKnob.Position = UDim2.new(0, -8, 0.5, -8)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBg

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = sliderKnob

local presetBtn = Instance.new("TextButton")
presetBtn.Size = UDim2.new(0, 150, 0, 26)
presetBtn.Position = UDim2.new(0, 15, 0, 108)
presetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
presetBtn.Text = "Next Preset"
presetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
presetBtn.Font = Enum.Font.Gotham
presetBtn.TextSize = 13
presetBtn.BorderSizePixel = 0
presetBtn.Parent = panel

local presetCorner = Instance.new("UICorner")
presetCorner.CornerRadius = UDim.new(0, 8)
presetCorner.Parent = presetBtn

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0, 150, 0, 26)
autoBtn.Position = UDim2.new(0, 15, 0, 144)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoBtn.Text = "Auto Steal: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.Font = Enum.Font.Gotham
autoBtn.TextSize = 13
autoBtn.BorderSizePixel = 0
autoBtn.Parent = panel

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 8)
autoCorner.Parent = autoBtn

-- ============================================================
-- GUI Logic
-- ============================================================
local panelOpen = false
mainButton.MouseButton1Click:Connect(function()
    panelOpen = not panelOpen
    panel.Visible = panelOpen
end)

local dragging, dragStart, startPos
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
        mainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        panel.Position = UDim2.new(0, mainButton.Position.X.Offset + 65, 0, mainButton.Position.Y.Offset)
    end
end)

-- ============================================================
-- Egg Detection
-- ============================================================
local function refreshEggCache()
    eggCache = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            if string.find(name, "egg") and not string.find(name, "gui") then
                table.insert(eggCache, obj)
            end
        elseif obj:IsA("Model") then
            local name = string.lower(obj.Name)
            if string.find(name, "egg") then
                local part = obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    table.insert(eggCache, part)
                end
            end
        end
    end
end

-- ============================================================
-- STEAL LOGIC (ចូល inventory ដោយផ្ទាល់)
-- ============================================================
local function stealEgg(targetPart)
    if not targetPart or not targetPart.Parent then return end

    -- Teleport ទៅ egg
    pcall(function()
        HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 1, 0)
    end)

    task.wait(0.03)

    -- វិធីសាស្ត្រទី 1: ProximityPrompt
    for _, prompt in pairs(targetPart:GetChildren()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                fireproximityprompt(prompt, 0)
            end)
        end
    end

    -- វិធីសាស្ត្រទី 2: ClickDetector
    for _, detector in pairs(targetPart:GetChildren()) do
        if detector:IsA("ClickDetector") then
            pcall(function()
                fireclickdetector(detector)
            end)
        end
    end

    -- វិធីសាស្ត្រទី 3: Touch interest
    pcall(function()
        firetouchinterest(HumanoidRootPart, targetPart, 0)
        task.wait(0.01)
        firetouchinterest(HumanoidRootPart, targetPart, 1)
    end)

    -- វិធីសាស្ត្រទី 4: Remote events (ស្វែងរក collect/steal/grab)
    pcall(function()
        for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local rname = string.lower(remote.Name)
                if string.find(rname, "collect") or string.find(rname, "steal") or 
                   string.find(rname, "grab") or string.find(rname, "pickup") or 
                   string.find(rname, "egg") then
                    remote:FireServer(targetPart)
                end
            end
        end
    end)

    -- វិធីសាស្ត្រទី 5: ព្យាយាមប្រើ tool ប្រសិនបើមាន
    pcall(function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and string.find(string.lower(tool.Name), "steal") then
                    tool.Parent = Character
                    task.wait(0.02)
                    tool:Activate()
                    task.wait(0.02)
                    tool.Parent = backpack
                end
            end
        end
    end)
end

-- ============================================================
-- RenderStepped
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    if not isRunning then return end
    if not Humanoid or not Humanoid.Parent then return end

    pcall(function()
        Humanoid.WalkSpeed = currentSpeed
        Humanoid.JumpPower = 50
    end)

    if autoCollect then
        local now = tick()
        if now - lastCollectTime >= collectInterval then
            lastCollectTime = now

            if now - lastScan >= scanInterval then
                lastScan = now
                refreshEggCache()
            end

            for _, eggPart in pairs(eggCache) do
                pcall(function()
                    stealEgg(eggPart)
                end)
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    originalWalkSpeed = Humanoid.WalkSpeed
    originalJumpPower = Humanoid.JumpPower
end)

-- ============================================================
-- Buttons
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
        autoBtn.Text = "Auto Steal: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        refreshEggCache()
    else
        autoBtn.Text = "Auto Steal: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

-- ============================================================
-- SLIDER
-- ============================================================
local minSpeed = 1000
local maxSpeed = 999999999999
local minLog = math.log10(minSpeed)
local maxLog = math.log10(maxSpeed)

local function updateSliderFromValue(value)
    local logVal = math.log10(math.clamp(value, minSpeed, maxSpeed))
    local alpha = (logVal - minLog) / (maxLog - minLog)
    sliderFill.Size = UDim2.new(alpha, 0, 1, 0)
    sliderKnob.Position = UDim2.new(alpha, -8, 0.5, -8)
    speedLabel.Text = "Speed: " .. tostring(math.floor(value))
end

local function updateValueFromAlpha(alpha)
    alpha = math.clamp(alpha, 0, 1)
    local logVal = minLog + alpha * (maxLog - minLog)
    currentSpeed = math.floor(10 ^ logVal)
    updateSliderFromValue(currentSpeed)
end

local sliderDragging = false
sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        local relX = input.Position.X - sliderBg.AbsolutePosition.X
        updateValueFromAlpha(relX / sliderBg.AbsoluteSize.X)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relX = input.Position.X - sliderBg.AbsolutePosition.X
        updateValueFromAlpha(relX / sliderBg.AbsoluteSize.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

local presetIndex = 1
presetBtn.MouseButton1Click:Connect(function()
    presetIndex = presetIndex + 1
    if presetIndex > #speedPresets then presetIndex = 1 end
    currentSpeed = speedPresets[presetIndex]
    updateSliderFromValue(currentSpeed)
end)

updateSliderFromValue(currentSpeed)
