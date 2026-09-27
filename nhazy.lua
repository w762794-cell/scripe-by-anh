-- palofsc: Delta Roblox egg steal script v5
-- Screen ដូចលេងធម្មតា (camera follow ធម្មជាតិ)
-- ល្បឿនកំណត់បានតាម slider
-- កាត់បន្ថយ load ដើម្បីមិនគាំង phone
-- Anti-cheat bypass 26.09.2026

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ============================================================
-- ANTI-CHEAT BYPASS (ស្រាល មិនធ្ងន់)
-- ============================================================
local originalWalkSpeed = Humanoid.WalkSpeed
local originalJumpPower = Humanoid.JumpPower

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
local speedPresets = {1000, 5000, 10000, 50000, 100000, 500000, 1000000, 999999999999}
local lastCollectTime = 0
local collectInterval = 0.15  -- កាត់បន្ថយ frequency ដើម្បីមិនគាំង

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
panel.Size = UDim2.new(0, 180, 0, 220)
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
toggleBtn.Size = UDim2.new(0, 150, 0, 40)
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

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 150, 0, 25)
speedLabel.Position = UDim2.new(0, 15, 0, 65)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 1000"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 14
speedLabel.Parent = panel

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0, 150, 0, 10)
sliderBg.Position = UDim2.new(0, 15, 0, 95)
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
sliderKnob.Size = UDim2.new(0, 18, 0, 18)
sliderKnob.Position = UDim2.new(0, -9, 0.5, -9)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBg

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = sliderKnob

local presetBtn = Instance.new("TextButton")
presetBtn.Size = UDim2.new(0, 150, 0, 30)
presetBtn.Position = UDim2.new(0, 15, 0, 120)
presetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
presetBtn.Text = "Next Preset"
presetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
presetBtn.Font = Enum.Font.Gotham
presetBtn.TextSize = 14
presetBtn.BorderSizePixel = 0
presetBtn.Parent = panel

local presetCorner = Instance.new("UICorner")
presetCorner.CornerRadius = UDim.new(0, 8)
presetCorner.Parent = presetBtn

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0, 150, 0, 30)
autoBtn.Position = UDim2.new(0, 15, 0, 160)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoBtn.Text = "Auto Collect: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.Font = Enum.Font.Gotham
autoBtn.TextSize = 14
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
-- Egg detection (cache ដើម្បីមិន scan ញឹកញាប់)
-- ============================================================
local eggCache = {}
local lastScan = 0
local scanInterval = 1.0

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

local function getEggPart(egg)
    if egg:IsA("BasePart") then return egg end
    if egg:IsA("Model") then return egg:FindFirstChildWhichIsA("BasePart") end
    return nil
end

local function stealEgg(targetPart)
    if not targetPart or not targetPart.Parent then return end

    -- Teleport ខ្លីៗ
    pcall(function()
        HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 1.5, 0)
    end)

    -- ProximityPrompt
    for _, prompt in pairs(targetPart:GetChildren()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                fireproximityprompt(prompt, 0)
            end)
        end
    end

    -- Touch
    pcall(function()
        firetouchinterest(HumanoidRootPart, targetPart, 0)
        firetouchinterest(HumanoidRootPart, targetPart, 1)
    end)
end

-- ============================================================
-- RenderStepped - update ល្បឿន និង auto collect
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    if not isRunning then return end
    if not Humanoid or not Humanoid.Parent then return end

    -- កំណត់ WalkSpeed តាម slider (លេខពិតលាក់ដោយ bypass)
    pcall(function()
        Humanoid.WalkSpeed = currentSpeed
        Humanoid.JumpPower = 50
    end)

    -- Auto collect
    if autoCollect then
        local now = tick()
        if now - lastCollectTime >= collectInterval then
            lastCollectTime = now

            if now - lastScan >= scanInterval then
                lastScan = now
                refreshEggCache()
            end

            for _, egg in pairs(eggCache) do
                pcall(function()
                    local part = getEggPart(egg)
                    if part then
                        stealEgg(part)
                    end
                end)
            end
        end
    end
end)

-- រក្សាតួអង្គថ្មី
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    originalWalkSpeed = Humanoid.WalkSpeed
    originalJumpPower = Humanoid.JumpPower
end)

-- ============================================================
-- ប៊ូតុង
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
        autoBtn.Text = "Auto Collect: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        refreshEggCache()
    else
        autoBtn.Text = "Auto Collect: OFF"
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
    sliderKnob.Position = UDim2.new(alpha, -9, 0.5, -9)
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
