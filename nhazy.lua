-- palofsc: Delta Roblox Steal An Egg script v7 - Fixed
-- ដោះស្រាយបញ្ហា script មិនចេញ / error ពេលចាប់ផ្ដើម
-- លុប bypass ដែលបង្ក error ក្នុង Delta
-- ប្រើ pcall គ្រប់កន្លែងដើម្បីការពារ crash

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- រង់ចាំ character
local Character = LocalPlayer.Character
if not Character then
    Character = LocalPlayer.CharacterAdded:Wait()
end

local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

if not HumanoidRootPart or not Humanoid then
    warn("មិនអាចរកឃើញ Character")
    return
end

-- ============================================================
-- អថេរ
-- ============================================================
local isRunning = false
local autoCollect = false
local currentSpeed = 1000
local speedPresets = {1000, 9000, 10000, 40000, 170000, 700000, 2500000, 17000000, 700000000}
local lastCollectTime = 0
local collectInterval = 0.3
local eggCache = {}
local lastScan = 0
local scanInterval = 1.0

-- ============================================================
-- GUI
-- ============================================================
pcall(function()
    local existing = CoreGui:FindFirstChild("EggStealMenu")
    if existing then existing:Destroy() end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggStealMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
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
mainButton.Active = true
mainButton.Draggable = true
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

-- ============================================================
-- Egg Detection
-- ============================================================
local function refreshEggCache()
    eggCache = {}
    local ok, err = pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = string.lower(obj.Name)
                if string.find(name, "egg") then
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
    end)
    if not ok then
        warn("Egg scan error: " .. tostring(err))
    end
end

-- ============================================================
-- STEAL LOGIC
-- ============================================================
local function stealEgg(targetPart)
    if not targetPart or not targetPart.Parent then return end
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end

    pcall(function()
        HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 1, 0)
    end)

    task.wait(0.03)

    -- ProximityPrompt
    pcall(function()
        for _, prompt in pairs(targetPart:GetChildren()) do
            if prompt:IsA("ProximityPrompt") then
                fireproximityprompt(prompt, 0)
            end
        end
    end)

    -- ClickDetector
    pcall(function()
        for _, detector in pairs(targetPart:GetChildren()) do
            if detector:IsA("ClickDetector") then
                fireclickdetector(detector)
            end
        end
    end)

    -- Touch interest
    pcall(function()
        firetouchinterest(HumanoidRootPart, targetPart, 0)
        firetouchinterest(HumanoidRootPart, targetPart, 1)
    end)

    -- Remote events
    pcall(function()
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local rname = string.lower(remote.Name)
                if string.find(rname, "collect") or string.find(rname, "steal") or 
                   string.find(rname, "grab") or string.find(rname, "pickup") then
                    remote:FireServer(targetPart)
                end
            end
        end
    end)
end

-- ============================================================
-- Main Loop
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    if not isRunning then return end
    if not Humanoid or not Humanoid.Parent then return end

    pcall(function()
        Humanoid.WalkSpeed = currentSpeed
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

-- រក្សាតួអង្គថ្មី
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)
    Humanoid = char:WaitForChild("Humanoid", 10)
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

print("[EGG SCRIPT v7] ដំណើរការជោគជ័យ")
