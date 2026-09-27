-- palofsc: Delta Roblox Steal An Egg - v9 ANTI-KICK + AUTO INVENTORY
-- ដោះស្រាយ: anti-cheat kick/teleport back + auto steal ចូល inventory
-- Camera ធម្មតា 100%

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

repeat task.wait() until LocalPlayer.Character
local Character = LocalPlayer.Character
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ============================================================
-- អថេរ
-- ============================================================
local isRunning = false
local autoCollect = false
local currentSpeed = 1000
local speeds = {1000, 5000, 10000, 50000, 100000, 500000, 1000000, 9999999}
local sIdx = 1
local lastPos = HumanoidRootPart.CFrame
local lastPosTime = tick()
local originalWalkSpeed = Humanoid.WalkSpeed

-- ============================================================
-- ANTI-KICK / ANTI-TELEPORT BACK
-- ============================================================
-- ចាប់យក CFrame ដើមដើម្បីប្រើពេល server teleport ត្រឡប់
spawn(function()
    while task.wait(0.5) do
        if HumanoidRootPart and HumanoidRootPart.Parent then
            -- ពិនិត្យថាតើ server teleport ត្រឡប់មកវិញ
            local currentPos = HumanoidRootPart.Position
            local dist = (currentPos - lastPos.Position).Magnitude
            
            -- បើចម្ងាយលើស 500 studs ក្នុង 0.5 វិនាទី → server teleport back
            if dist > 500 and isRunning then
                pcall(function()
                    HumanoidRootPart.CFrame = lastPos
                end)
            end
            
            lastPos = HumanoidRootPart.CFrame
            lastPosTime = tick()
        end
    end
end)

-- ============================================================
-- GUI
-- ============================================================
pcall(function()
    local old = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("EggMenu")
    if old then old:Destroy() end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0, 20, 0, 200)
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.Text = "EGG"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextScaled = true
btn.Font = Enum.Font.GothamBold
btn.BorderSizePixel = 0
btn.Draggable = true
btn.Parent = screenGui

local c1 = Instance.new("UICorner")
c1.CornerRadius = UDim.new(1, 0)
c1.Parent = btn

local s1 = Instance.new("UIStroke")
s1.Color = Color3.fromRGB(255, 50, 50)
s1.Thickness = 2
s1.Parent = btn

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 170, 0, 210)
panel.Position = UDim2.new(0, 90, 0, 200)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = screenGui

local c2 = Instance.new("UICorner")
c2.CornerRadius = UDim.new(0, 12)
c2.Parent = panel

local s2 = Instance.new("UIStroke")
s2.Color = Color3.fromRGB(255, 50, 50)
s2.Thickness = 1.5
s2.Parent = panel

local onBtn = Instance.new("TextButton")
onBtn.Size = UDim2.new(0, 140, 0, 40)
onBtn.Position = UDim2.new(0, 15, 0, 15)
onBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
onBtn.Text = "OFF"
onBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
onBtn.Font = Enum.Font.GothamBold
onBtn.TextSize = 18
onBtn.BorderSizePixel = 0
onBtn.Parent = panel

local c3 = Instance.new("UICorner")
c3.CornerRadius = UDim.new(0, 8)
c3.Parent = onBtn

local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0, 140, 0, 22)
lbl.Position = UDim2.new(0, 15, 0, 62)
lbl.BackgroundTransparency = 1
lbl.Text = "Speed: 1000"
lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
lbl.Font = Enum.Font.GothamBold
lbl.TextSize = 13
lbl.Parent = panel

local pBtn = Instance.new("TextButton")
pBtn.Size = UDim2.new(0, 140, 0, 28)
pBtn.Position = UDim2.new(0, 15, 0, 90)
pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
pBtn.Text = "Speed: 1000"
pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
pBtn.Font = Enum.Font.Gotham
pBtn.TextSize = 13
pBtn.BorderSizePixel = 0
pBtn.Parent = panel

local c4 = Instance.new("UICorner")
c4.CornerRadius = UDim.new(0, 8)
c4.Parent = pBtn

local aBtn = Instance.new("TextButton")
aBtn.Size = UDim2.new(0, 140, 0, 30)
aBtn.Position = UDim2.new(0, 15, 0, 126)
aBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
aBtn.Text = "Auto Steal: OFF"
aBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aBtn.Font = Enum.Font.Gotham
aBtn.TextSize = 13
aBtn.BorderSizePixel = 0
aBtn.Parent = panel

local c5 = Instance.new("UICorner")
c5.CornerRadius = UDim.new(0, 8)
c5.Parent = aBtn

local stBtn = Instance.new("TextButton")
stBtn.Size = UDim2.new(0, 140, 0, 26)
stBtn.Position = UDim2.new(0, 15, 0, 164)
stBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
stBtn.Text = "STATUS: IDLE"
stBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
stBtn.Font = Enum.Font.Gotham
stBtn.TextSize = 12
stBtn.BorderSizePixel = 0
stBtn.Parent = panel

local c6 = Instance.new("UICorner")
c6.CornerRadius = UDim.new(0, 8)
c6.Parent = stBtn

-- ============================================================
-- GUI Logic
-- ============================================================
btn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

onBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        onBtn.Text = "ON"
        onBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        stBtn.Text = "STATUS: RUNNING"
    else
        onBtn.Text = "OFF"
        onBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        stBtn.Text = "STATUS: IDLE"
        pcall(function()
            Humanoid.WalkSpeed = originalWalkSpeed
        end)
    end
end)

pBtn.MouseButton1Click:Connect(function()
    sIdx = sIdx + 1
    if sIdx > #speeds then sIdx = 1 end
    currentSpeed = speeds[sIdx]
    pBtn.Text = "Speed: " .. tostring(currentSpeed)
    lbl.Text = "Speed: " .. tostring(currentSpeed)
end)

aBtn.MouseButton1Click:Connect(function()
    autoCollect = not autoCollect
    if autoCollect then
        aBtn.Text = "Auto Steal: ON"
        aBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        aBtn.Text = "Auto Steal: OFF"
        aBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

-- ============================================================
-- ស្វែងរក REMOTE សម្រាប់ STEAL (ចូល inventory ដោយផ្ទាល់)
-- ============================================================
local stealRemotes = {}

local function findStealRemotes()
    stealRemotes = {}
    local keywords = {"collect", "steal", "grab", "pickup", "claim", "egg", "take", "get"}
    
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local rname = string.lower(remote.Name)
            for _, kw in pairs(keywords) do
                if string.find(rname, kw) then
                    table.insert(stealRemotes, remote)
                    break
                end
            end
        end
    end
    
    -- ស្វែងរកក្នុង workspace ផងដែរ
    for _, remote in pairs(workspace:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local rname = string.lower(remote.Name)
            for _, kw in pairs(keywords) do
                if string.find(rname, kw) then
                    table.insert(stealRemotes, remote)
                    break
                end
            end
        end
    end
end

-- ស្វែងរក tools ដែលអាច steal បាន
local function findStealTools()
    local tools = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local tname = string.lower(tool.Name)
                if string.find(tname, "steal") or string.find(tname, "grab") or 
                   string.find(tname, "net") or string.find(tname, "hand") then
                    table.insert(tools, tool)
                end
            end
        end
    end
    return tools
end

-- ============================================================
-- STEAL FUNCTION
-- ============================================================
local function stealEgg(targetPart)
    if not targetPart or not targetPart.Parent then return end
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end

    -- រក្សា position ដើមសម្រាប់ anti-teleport-back
    lastPos = HumanoidRootPart.CFrame

    -- Teleport ទៅ egg
    pcall(function()
        HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 1, 0)
    end)

    task.wait(0.05)

    -- វិធី 1: ProximityPrompt
    for _, p in pairs(targetPart:GetChildren()) do
        if p:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(p, 0) end)
        end
        if p:IsA("ClickDetector") then
            pcall(function() fireclickdetector(p) end)
        end
    end

    -- វិធី 2: Touch
    pcall(function()
        firetouchinterest(HumanoidRootPart, targetPart, 0)
        task.wait(0.01)
        firetouchinterest(HumanoidRootPart, targetPart, 1)
    end)

    -- វិធី 3: Remote events (ចូល inventory ដោយផ្ទាល់)
    for _, remote in pairs(stealRemotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(targetPart)
                remote:FireServer(targetPart.Name)
                remote:FireServer()
            end
        end)
    end

    -- វិធី 4: ប្រើ tool
    local tools = findStealTools()
    for _, tool in pairs(tools) do
        pcall(function()
            tool.Parent = Character
            task.wait(0.05)
            tool:Activate()
            task.wait(0.05)
            tool.Parent = LocalPlayer:FindFirstChild("Backpack")
        end)
    end
end

-- ============================================================
-- មុខងារស្វែងរក egg
-- ============================================================
local function getAllEggs()
    local eggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            if string.find(name, "egg") then
                table.insert(eggs, obj)
            end
        elseif obj:IsA("Model") then
            local name = string.lower(obj.Name)
            if string.find(name, "egg") then
                local part = obj:FindFirstChildWhichIsA("BasePart")
                if part then table.insert(eggs, part) end
            end
        end
    end
    return eggs
end

-- ============================================================
-- Main Loop
-- ============================================================
local lastCollect = 0
local collectDelay = 0.4

RunService.Heartbeat:Connect(function()
    if not isRunning then return end

    pcall(function()
        Humanoid.WalkSpeed = currentSpeed
    end)

    if autoCollect then
        local now = tick()
        if now - lastCollect >= collectDelay then
            lastCollect = now
            local eggs = getAllEggs()
            for _, egg in pairs(eggs) do
                pcall(function()
                    stealEgg(egg)
                end)
            end
        end
    end
end)

-- Respawn handler
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    originalWalkSpeed = Humanoid.WalkSpeed
    findStealRemotes()
end)

-- ចាប់ផ្ដើម
findStealRemotes()
stBtn.Text = "STATUS: REMOTES=" .. tostring(#stealRemotes)
print("[EGG v9] Loaded. Remotes found: " .. tostring(#stealRemotes))
