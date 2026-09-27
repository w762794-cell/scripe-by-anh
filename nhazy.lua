-- palofsc: NhazX v18 - STABLE (គ្មាន hook, គ្មានគាំង)
-- លុប hook ទាំងអស់ (មូលហេតុគាំង)
-- Teleport steal ដំណើរការ + tool fallback

print("[NhazX v18] Loading...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart", 10)
local Hum = Char:WaitForChild("Humanoid", 10)
local PG = LP:WaitForChild("PlayerGui", 10)

-- CONFIG
local isRunning = false
local autoSteal = false
local autoReturn = true
local speed = 100
local speeds = {50, 100, 150, 200, 300, 500}
local sIdx = 2
local originalSpeed = Hum.WalkSpeed
local lastSteal = 0
local stealDelay = 1.0
local safeZoneCFrame = nil
local returnDelay = 0.4
local stealRemotes = {}
local eggList = {}

-- ============================================================
-- GUI
-- ============================================================
local old = PG:FindFirstChild("NhazX")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "NhazX"
gui.ResetOnSpawn = false
gui.Parent = PG

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
local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(1,0) bc.Parent = btn
local bs = Instance.new("UIStroke") bs.Color = Color3.fromRGB(0,255,200) bs.Thickness = 2 bs.Parent = btn

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 195, 0, 380)
panel.Position = UDim2.new(0, 85, 0, 100)
panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
local pc = Instance.new("UICorner") pc.CornerRadius = UDim.new(0,14) pc.Parent = panel
local ps = Instance.new("UIStroke") ps.Color = Color3.fromRGB(0,255,200) ps.Thickness = 1.5 ps.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.Position = UDim2.new(0, 0, 0, 4)
title.BackgroundTransparency = 1
title.Text = "NhazX"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = panel

local function mkBtn(txt, y, col)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 165, 0, 28)
    b.Position = UDim2.new(0, 15, 0, y)
    b.BackgroundColor3 = col or Color3.fromRGB(55,55,55)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.BorderSizePixel = 0
    b.Parent = panel
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,8) c.Parent = b
    return b
end

local onBtn = mkBtn("OFF", 36)
onBtn.Font = Enum.Font.GothamBold
onBtn.TextSize = 15
local spdBtn = mkBtn("Speed: 100", 70)
local autoBtn = mkBtn("Auto Steal: OFF", 102)
local retBtn = mkBtn("Auto Return: ON", 134, Color3.fromRGB(0,130,0))
local setBtn = mkBtn("Set SafeZone (here)", 166)
local detectBtn = mkBtn("Auto Detect SafeZone", 198)
local scanBtn = mkBtn("Rescan", 230, Color3.fromRGB(100,50,100))

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 165, 0, 110)
infoLabel.Position = UDim2.new(0, 15, 0, 262)
infoLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
infoLabel.Text = "Scanning..."
infoLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
infoLabel.Font = Enum.Font.Code
infoLabel.TextSize = 10
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextWrapped = true
infoLabel.BorderSizePixel = 0
infoLabel.Parent = panel
local ilc = Instance.new("UICorner") ilc.CornerRadius = UDim.new(0,8) ilc.Parent = infoLabel

-- ============================================================
-- SCAN
-- ============================================================
local function scanEggs()
    eggList = {}
    pcall(function()
        for _, o in pairs(workspace:GetDescendants()) do
            local n = string.lower(o.Name)
            if string.find(n, "egg") then
                if o:IsA("BasePart") then
                    table.insert(eggList, o)
                elseif o:IsA("Model") then
                    local p = o:FindFirstChildWhichIsA("BasePart")
                    if p then table.insert(eggList, p) end
                end
            end
        end
    end)
    return #eggList
end

local function scanRemotes()
    stealRemotes = {}
    local kws = {"collect","steal","grab","pickup","claim","take","egg","hatch","reward"}
    pcall(function()
        for _, r in pairs(ReplicatedStorage:GetDescendants()) do
            if r:IsA("RemoteEvent") then
                local n = string.lower(r.Name)
                for _, k in pairs(kws) do
                    if string.find(n, k) then
                        table.insert(stealRemotes, r)
                        break
                    end
                end
            end
        end
    end)
    return #stealRemotes
end

local function autoDetectSafeZone()
    local kws = {"safezone","safe_zone","safearea","lobby","base","home","sell","shop","hub","spawn"}
    local found = nil
    pcall(function()
        for _, o in pairs(workspace:GetDescendants()) do
            local n = string.lower(o.Name)
            for _, k in pairs(kws) do
                if string.find(n, k) then
                    local part
                    if o:IsA("BasePart") then part = o
                    elseif o:IsA("Model") then part = o:FindFirstChildWhichIsA("BasePart")
                    elseif o:IsA("SpawnLocation") then part = o end
                    if part then
                        found = part.CFrame + Vector3.new(0, 5, 0)
                        return
                    end
                end
            end
        end
    end)
    if not found then
        pcall(function()
            local sp = workspace:FindFirstChildOfClass("SpawnLocation")
            if sp then found = sp.CFrame + Vector3.new(0, 5, 0) end
        end)
    end
    return found
end

-- ============================================================
-- STEAL FUNCTION (គ្មាន hook, គ្មានគាំង)
-- ============================================================
local function stealOne(part)
    if not part or not part.Parent then return end
    if not HRP or not HRP.Parent then return end
    if not Char or not Char.Parent then return end

    -- Teleport ទៅជិត egg
    pcall(function()
        HRP.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
    end)
    task.wait(0.15)

    -- វិធី 1: ProximityPrompt
    pcall(function()
        for _, c in pairs(part:GetChildren()) do
            if c:IsA("ProximityPrompt") then
                fireproximityprompt(c, 0)
            elseif c:IsA("ClickDetector") then
                fireclickdetector(c)
            end
        end
    end)

    -- វិធី 2: Touch
    pcall(function()
        firetouchinterest(HRP, part, 0)
        task.wait(0.03)
        firetouchinterest(HRP, part, 1)
    end)

    -- វិធី 3: Remotes
    for _, r in pairs(stealRemotes) do
        pcall(function()
            r:FireServer(part)
            r:FireServer(part.Name)
        end)
    end

    -- វិធី 4: Tools (backup)
    pcall(function()
        local bp = LP:FindFirstChild("Backpack")
        if bp then
            for _, t in pairs(bp:GetChildren()) do
                if t:IsA("Tool") then
                    t.Parent = Char
                    task.wait(0.08)
                    pcall(function() t:Activate() end)
                    task.wait(0.08)
                    t.Parent = bp
                end
            end
        end
    end)

    -- Return safezone
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
            for _, e in pairs(eggList) do
                if e and e.Parent then
                    pcall(stealOne, e)
                end
            end
        end
    end
end)

local function updateInfo()
    infoLabel.Text = "Eggs: "..#eggList..
        "\nRemotes: "..#stealRemotes..
        "\nSafeZone: "..(safeZoneCFrame and "YES" or "NO")
end

-- ============================================================
-- RESPAWN
-- ============================================================
LP.CharacterAdded:Connect(function(c)
    task.wait(0.8)
    Char = c
    HRP = c:WaitForChild("HumanoidRootPart", 10)
    Hum = c:WaitForChild("Humanoid", 10)
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
        scanEggs()
        scanRemotes()
        updateInfo()
        if not safeZoneCFrame then
            safeZoneCFrame = autoDetectSafeZone()
        end
    else
        onBtn.Text = "OFF"
        onBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        bs.Color = Color3.fromRGB(0, 255, 200)
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
        scanEggs()
    else
        autoBtn.Text = "Auto Steal: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end
    updateInfo()
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
    updateInfo()
end)

detectBtn.MouseButton1Click:Connect(function()
    local f = autoDetectSafeZone()
    if f then safeZoneCFrame = f end
    updateInfo()
end)

scanBtn.MouseButton1Click:Connect(function()
    scanEggs()
    scanRemotes()
    updateInfo()
end)

-- INIT
scanEggs()
scanRemotes()
safeZoneCFrame = autoDetectSafeZone()
updateInfo()

print("[NhazX v18] ✓ Loaded")
print("  Eggs: " .. #eggList)
print("  Remotes: " .. #stealRemotes)
print("  SafeZone: " .. tostring(safeZoneCFrame ~= nil))
