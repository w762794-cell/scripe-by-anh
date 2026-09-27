-- palofsc: Delta Roblox egg steal script v4
-- ដោះស្រាយបញ្ហា screen នៅមួយកន្លែង ពេលល្បឿនខ្ពស់
-- ប្រើ CFrame teleport ជំនួស Velocity ដើម្បីឱ្យ camera និង character ធ្វើដំណើរជាមួយគ្នា
-- បន្ថែម camera update និង character network ownership

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
-- ANTI-CHEAT BYPASS
-- ============================================================
local originalWalkSpeed = Humanoid.WalkSpeed
local originalJumpPower = Humanoid.JumpPower
local originalCFrame = HumanoidRootPart.CFrame

local mt = getrawmetatable(game)
local oldIndex = mt.__index
local oldNewIndex = mt.__newindex
setreadonly(mt, false)

mt.__index = newcclosure(function(self, key)
    if self == Humanoid then
        if key == "WalkSpeed" then return originalWalkSpeed end
        if key == "JumpPower" then return originalJumpPower end
    end
    if self == HumanoidRootPart and key == "CFrame" then
        return originalCFrame
    end
    return oldIndex(self, key)
end)

mt.__newindex = newcclosure(function(self, key, value)
    if self == Humanoid and (key == "WalkSpeed" or key == "JumpPower") then
        oldNewIndex(self, key, value)
        return
    end
    if self == HumanoidRootPart and key == "CFrame" then
        originalCFrame = value
    end
    return oldNewIndex(self, key, value)
end)
setreadonly(mt, true)

-- ============================================================
-- អថេរស្ថានភាព
-- ============================================================
local isRunning = false
local autoCollect = false
local currentSpeed = 1000
local speedPresets = {1000, 5000, 10000, 50000, 100000, 500000, 1000000, 999999999999}

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
-- មុខងារលួច egg
-- ============================================================
local function getAllEggs()
    local eggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = string.lower(obj.Name)
            if string.find(name, "egg") then
                table.insert(eggs, obj)
            end
        end
    end
    return eggs
end

local function getEggPart(egg)
    if egg:IsA("BasePart") then return egg end
    if egg:IsA("Model") then return egg:FindFirstChildWhichIsA("BasePart") end
    return nil
end

local function stealEgg(egg)
    local targetPart = getEggPart(egg)
    if not targetPart then return end

    -- យក network ownership ដើម្បីឱ្យ client គ្រប់គ្រង character
    pcall(function()
        if HumanoidRootPart:GetNetworkOwner() ~= LocalPlayer then
            HumanoidRootPart:SetNetworkOwner(LocalPlayer)
        end
        if targetPart:CanSetNetworkOwnership() then
            targetPart:SetNetworkOwner(LocalPlayer)
        end
    end)

    -- Teleport ដោយ CFrame ផ្ទាល់ (មិនប្រើ Velocity)
    pcall(function()
        HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 2, 0)
    end)

    -- Update camera ភ្លាមៗដើម្បីកុំឱ្យ screen នៅមួយកន្លែង
    pcall(function()
        Camera.CFrame = CFrame.new(HumanoidRootPart.Position + Vector3.new(0, 10, 10), HumanoidRootPart.Position)
        Camera.Focus = HumanoidRootPart.CFrame
    end)

    task.wait(0.02)

    for _, prompt in pairs(targetPart:GetChildren()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                fireproximityprompt(prompt, 0)
            end)
        end
    end

    pcall(function()
        firetouchinterest(HumanoidRootPart, targetPart, 0)
        task.wait(0.01)
        firetouchinterest(HumanoidRootPart, targetPart, 1)
    end)

    pcall(function()
        for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local rname = string.lower(remote.Name)
                if string.find(rname, "collect") or string.find(rname, "egg") or string.find(rname, "claim") then
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(targetPart)
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- មុខងារសម្រាប់ល្បឿនខ្ពស់ (ដោះស្រាយ screen នៅមួយកន្លែង)
-- ============================================================
local moveDirection = Vector3.zero

-- ចាប់យក input ពី player ដើម្បីធ្វើចលនា
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.W then moveDirection = moveDirection + Vector3.new(0, 0, -1) end
    if input.KeyCode == Enum.KeyCode.S then moveDirection = moveDirection + Vector3.new(0, 0, 1) end
    if input.KeyCode == Enum.KeyCode.A then moveDirection = moveDirection + Vector3.new(-1, 0, 0) end
    if input.KeyCode == Enum.KeyCode.D then moveDirection = moveDirection + Vector3.new(1, 0, 0) end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then moveDirection = moveDirection - Vector3.new(0, 0, -1) end
    if input.KeyCode == Enum.KeyCode.S then moveDirection = moveDirection - Vector3.new(0, 0, 1) end
    if input.KeyCode == Enum.KeyCode.A then moveDirection = moveDirection - Vector3.new(-1, 0, 0) end
    if input.KeyCode == Enum.KeyCode.D then moveDirection = moveDirection - Vector3.new(1, 0, 0) end
end)

-- ============================================================
-- RenderStepped សម្រាប់ធ្វើចលនារលូន និង camera follow
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    if not isRunning then return end
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end

    -- កំណត់ WalkSpeed ខ្ពស់ (តម្លៃពិតលាក់ដោយ bypass)
    pcall(function()
        Humanoid.WalkSpeed = currentSpeed
        Humanoid.JumpPower = currentSpeed
    end)

    -- ធ្វើចលនាដោយ CFrame ផ្ទាល់ ដើម្បីឱ្យ camera ធ្វើតាម
    if moveDirection.Magnitude > 0 then
        local camCF = Camera.CFrame
        local forward = camCF.LookVector
        local right = camCF.RightVector
        local moveVec = (forward * -moveDirection.Z + right * moveDirection.X).Unit
        local distance = currentSpeed * dt
        
        pcall(function()
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + moveVec * distance
        end)
    end

    -- Update camera ឱ្យធ្វើតាម character ជានិច្ច
    pcall(function()
        Camera.CFrame = Camera.CFrame + (HumanoidRootPart.Position - Camera.CFrame.Position)
        Camera.Focus = HumanoidRootPart.CFrame
    end)

    -- Auto collect
    if autoCollect then
        local eggs = getAllEggs()
        for _, egg in pairs(eggs) do
            pcall(function()
                stealEgg(egg)
            end)
        end
    end
end)

-- រក្សាតួអង្គ
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    originalWalkSpeed = Humanoid.WalkSpeed
    originalJumpPower = Humanoid.JumpPower
    pcall(function()
        HumanoidRootPart:SetNetworkOwner(LocalPlayer)
    end)
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
        pcall(function()
            HumanoidRootPart:SetNetworkOwner(LocalPlayer)
        end)
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
