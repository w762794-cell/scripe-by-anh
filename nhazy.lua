-- palofsc: NhazX Egg Steal - v14 STABLE
-- ដំណើរការបានប្រាកដ (បង្កើតពី minimal test ដែល work)
-- GUI: NhazX | Auto Steal | Auto Return SafeZone | Camera ធម្មតា

print("[NhazX] Loading...")

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer

local Char = LP.Character
if not Char then Char = LP.CharacterAdded:Wait() end
local HRP = Char:WaitForChild("HumanoidRootPart", 10)
local Hum = Char:WaitForChild("Humanoid", 10)
local PG = LP:WaitForChild("PlayerGui", 10)

print("[NhazX] Character ready")

-- ============================================================
-- CONFIG
-- ============================================================
local isRunning = false
local autoSteal = false
local autoReturn = true
local speed = 60
local speeds = {60, 100, 200, 500, 1000, 2000, 5000}
local sIdx = 1
local originalSpeed = Hum.WalkSpeed
local lastSteal = 0
local stealDelay = 0.5
local safeZoneCFrame = nil
local returnDelay = 0.15
local stealRemotes = {}

-- ============================================================
-- GUI NhazX
-- ============================================================
local old = PG:FindFirstChild("NhazX")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "NhazX"
gui.ResetOnSpawn = false
gui.Parent = PG

-- ប៊ូតុងមូល N
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 55, 0, 55)
btn.Position = UDim2.new(0, 20, 0, 200)
btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
btn.Text = "N"
btn.TextColor3 = Color3.fromRGB(0, 255, 200)
btn.TextSize = 28
btn.Font = Enum.Font.GothamBold
btn.BorderSizePixel = 0
btn.Draggable = true
btn.Parent = gui

local bc = Instance.new("UICorner")
bc.CornerRadius = UDim.new(1, 0)
bc.Parent = btn

local bs = Instance.new("UIStroke")
bs.Color = Color3.fromRGB(0, 255, 200)
bs.Thickness = 2
bs.Parent = btn

-- Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 190, 0, 310)
panel.Position = UDim2.new(0, 85, 0, 200)
panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local pc = Instance.new("UICorner")
pc.CornerRadius = UDim.new(0, 14)
pc.Parent = panel

local ps = Instance.new("UIStroke")
ps.Color = Color3.fromRGB(0, 255, 200)
ps.Thickness = 1.5
ps.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "NhazX"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = panel

local onBtn = Instance.new("TextButton")
onBtn.Size = UDim2.new(0, 160, 0, 36)
onBtn.Position = UDim2.new(0, 15, 0, 40)
onBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
onBtn.Text = "OFF"
onBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
onBtn.Font = Enum.Font.GothamBold
onBtn.TextSize = 16
onBtn.BorderSizePixel = 0
onBtn.Parent = panel

local oc = Instance.new("UICorner")
oc.CornerRadius = UDim.new(0, 9)
oc.Parent = onBtn

local spdBtn = Instance.new("TextButton")
spdBtn.Size = UDim2.new(0, 160, 0, 28)
spdBtn.Position = UDim2.new(0, 15, 0, 84)
spdBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
spdBtn.Text = "Speed: 60"
spdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spdBtn.Font = Enum.Font.Gotham
spdBtn.TextSize = 12
spdBtn.BorderSizePixel = 0
spdBtn.Parent = panel

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(0, 9)
sc.Parent = spdBtn

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0, 160, 0, 28)
autoBtn.Position = UDim2.new(0, 15, 0, 118)
autoBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
autoBtn.Text = "Auto Steal: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.Font = Enum.Font.Gotham
autoBtn.TextSize = 12
autoBtn.BorderSizePixel = 0
autoBtn.Parent = panel

local ac = Instance.new("UICorner")
ac.CornerRadius = UDim.new(0, 9)
ac.Parent = autoBtn

local retBtn = Instance.new("TextButton")
retBtn.Size = UDim2.new(0, 160, 0, 28)
retBtn.Position = UDim2.new(0, 15, 0, 152)
retBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
retBtn.Text = "Auto Return: ON"
retBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
retBtn.Font = Enum.Font.Gotham
retBtn.TextSize = 12
retBtn.BorderSizePixel = 0
retBtn.Parent = panel

local rc = Instance.new("UICorner")
rc.CornerRadius = UDim.new(0, 9)
rc.Parent = retBtn

local setBtn = Instance.new("TextButton")
setBtn.Size = UDim2.new(0, 160, 0, 28)
setBtn.Position = UDim2.new(0, 15, 0, 186)
setBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
setBtn.Text = "Set SafeZone (here)"
setBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setBtn.Font = Enum.Font.Gotham
setBtn.TextSize = 12
setBtn.BorderSizePixel = 0
setBtn.Parent = panel

local setc = Instance.new("UICorner")
setc.CornerRadius = UDim.new(0, 9)
setc.Parent = setBtn

local detectBtn = Instance.new("TextButton")
detectBtn.Size = UDim2.new(0, 160, 0, 28)
detectBtn.Position = UDim2.new(0, 15, 0, 220)
detectBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
detectBtn.Text = "Auto Detect SafeZone"
detectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
detectBtn.Font = Enum.Font.Gotham
detectBtn.TextSize = 12
detectBtn.BorderSizePixel = 0
detectBtn.Parent = panel

local dc = Instance.new("UICorner")
dc.CornerRadius = UDim.new(0, 9)
dc.Parent = detectBtn

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 160, 0, 30)
status.Position = UDim2.new(0, 15, 0, 254)
status.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
status.Text = "NhazX Ready"
status.TextColor3 = Color3.fromRGB(0, 255, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.BorderSizePixel = 0
status.Parent = panel

local stc = Instance.new("UICorner")
stc.CornerRadius = UDim.new(0, 8)
stc.Parent = status

-- ============================================================
-- AUTO DETECT SAFEZONE
-- ============================================================
local function autoDetectSafeZone()
    local keywords = {"safezone", "safe_zone", "safearea", "spawn", "lobby", "base", "home", "sell", "shop"}
    local found = nil
    pcall(function()
        for _, o in pairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") or o:IsA("Model") or o:IsA("SpawnLocation") then
                local n = string.lower(o.Name)
                for _, k in pairs(keywords) do
                    if string.find(n, k) then
                        local part
                        if o:IsA("BasePart") then part = o
                        elseif o:IsA("Model") then part = o:FindFirstChildWhichIsA("BasePart")
                        else part = o end
                        if part then
                            found = part.CFrame + Vector3.new(0, 3, 0)
                            return
                        end
                    end
                end
            end
        end
    end)
    if not found then
        pcall(function()
            local sp = workspace:FindFirstChildOfClass("SpawnLocation")
            if sp then found = sp.CFrame + Vector3.new(0, 3, 0) end
        end)
    end
    return found
end

-- ============================================================
-- REMOTE SCAN
-- ============================================================
local function scanRemotes()
    stealRemotes = {}
    local keywords = {"collect", "steal", "grab", "pickup", "claim", "take", "get", "egg", "pet"}
    local function check(container)
        pcall(function()
            for _, r in pairs(container:GetDescendants()) do
                if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
                    local n = string.lower(r.Name)
                    for _, k in pairs(keywords) do
                        if string.find(n, k) then
                            table.insert(stealRemotes, r)
                            break
                        end
                    end
                end
            end
        end)
    end
    check(ReplicatedStorage)
    check(workspace)
    status.Text = "NhazX | R:" .. #stealRemotes
end

-- ============================================================
-- FIND EGGS
-- ============================================================
local function findEggs()
    local eggs = {}
    pcall(function()
        for _, o in pairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") then
                if string.find(string.lower(o.Name), "egg") then
                    table.insert(eggs, o)
                end
            elseif o:IsA("Model") then
                if string.find(string.lower(o.Name), "egg") then
                    local p = o:FindFirstChildWhichIsA("BasePart")
                    if p then table.insert(eggs, p) end
                end
            end
        end
    end)
    return eggs
end

-- ============================================================
-- STEAL
-- ============================================================
local function steal(part)
    if not part or not part.Parent then return end
    if not HRP or not HRP.Parent then return end

    pcall(function()
        HRP.CFrame = part.CFrame + Vector3.new(0, 1, 0)
    end)

    task.wait(0.05)

    for _, c in pairs(part:GetChildren()) do
        if c:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(c, 0) end)
        elseif c:IsA("ClickDetector") then
            pcall(function() fireclickdetector(c) end)
        end
    end

    pcall(function()
        firetouchinterest(HRP, part, 0)
        task.wait(0.01)
        firetouchinterest(HRP, part, 1)
    end)

    for _, r in pairs(stealRemotes) do
        pcall(function()
            if r:IsA("RemoteEvent") then
                r:FireServer(part)
                r:FireServer(part.Name)
                r:FireServer(part.Parent)
            end
        end)
    end

    pcall(function()
        local bp = LP:FindFirstChild("Backpack")
        if bp then
            for _, t in pairs(bp:GetChildren()) do
                if t:IsA("Tool") then
                    local n = string.lower(t.Name)
                    if string.find(n, "steal") or string.find(n, "grab") or string.find(n, "net") then
                        t.Parent = Char
                        task.wait(0.05)
                        t:Activate()
                        task.wait(0.05)
                        t.Parent = bp
                    end
                end
            end
        end
    end)

    if autoReturn and safeZoneCFrame then
        task.wait(returnDelay)
        pcall(function()
            HRP.CFrame = safeZoneCFrame
        end)
    end
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not isRunning then return end
    pcall(function()
        if Hum and Hum.Parent then
            Hum.WalkSpeed = speed
        end
    end)
    if autoSteal then
        local now = tick()
        if now - lastSteal >= stealDelay then
            lastSteal = now
            for _, e in pairs(findEggs()) do
                pcall(steal, e)
            end
        end
    end
end)

-- ============================================================
-- RESPAWN
-- ============================================================
LP.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    Char = c
    HRP = c:WaitForChild("HumanoidRootPart")
    Hum = c:WaitForChild("Humanoid")
    originalSpeed = Hum.WalkSpeed
end)

-- ============================================================
-- BUTTONS
-- ============================================================
btn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

onBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        onBtn.Text = "ON"
        onBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        bs.Color = Color3.fromRGB(0, 255, 0)
        status.Text = "NhazX Running"
        scanRemotes()
        if not safeZoneCFrame then
            safeZoneCFrame = autoDetectSafeZone()
        end
    else
        onBtn.Text = "OFF"
        onBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        bs.Color = Color3.fromRGB(0, 255, 200)
        status.Text = "NhazX Stopped"
        pcall(function() Hum.WalkSpeed = originalSpeed end)
    end
end)

spdBtn.MouseButton1Click:Connect(function()
    sIdx = sIdx + 1
    if sIdx > #speeds then sIdx = 1 end
    speed = speeds[sIdx]
    spdBtn.Text = "Speed: " .. speed
end)

autoBtn.MouseButton1Click:Connect(function()
    autoSteal = not autoSteal
    if autoSteal then
        autoBtn.Text = "Auto Steal: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    else
        autoBtn.Text = "Auto Steal: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end
end)

retBtn.MouseButton1Click:Connect(function()
    autoReturn = not autoReturn
    if autoReturn then
        retBtn.Text = "Auto Return: ON"
        retBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
    else
        retBtn.Text = "Auto Return: OFF"
        retBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end
end)

setBtn.MouseButton1Click:Connect(function()
    safeZoneCFrame = HRP.CFrame
    status.Text = "NhazX SafeZone OK"
    task.wait(1.5)
    status.Text = "NhazX | R:" .. #stealRemotes
end)

detectBtn.MouseButton1Click:Connect(function()
    local found = autoDetectSafeZone()
    if found then
        safeZoneCFrame = found
        status.Text = "SafeZone Detected"
    else
        status.Text = "Not Found - Set Manual"
    end
    task.wait(1.5)
    status.Text = "NhazX | R:" .. #stealRemotes
end)

-- ============================================================
-- INIT
-- ============================================================
scanRemotes()
safeZoneCFrame = autoDetectSafeZone()

if safeZoneCFrame then
    status.Text = "NhazX SafeZone OK"
else
    status.Text = "Set SafeZone!"
end

print("[NhazX v14] ✓ Loaded | Remotes: " .. #stealRemotes .. " | SafeZone: " .. tostring(safeZoneCFrame ~= nil))
