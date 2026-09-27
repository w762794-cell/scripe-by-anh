-- palofsc: NhazX UNIVERSAL - v19 FINAL (WORK ALL)
-- សាមញ្ញ ស្រាល មិនគាំង ដំណើរការគ្រប់ game
-- Teleport + Auto Steal + Auto Return + Camera ធម្មតា

print("[NhazX v19] Loading...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")
local PG = LP:WaitForChild("PlayerGui")

-- CONFIG
local isOn = false
local autoOn = false
local speed = 100
local speeds = {50, 100, 150, 200, 300, 500}
local sIdx = 2
local origSpeed = Hum.WalkSpeed
local lastSteal = 0
local safeZone = nil
local remotes = {}
local eggs = {}

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

local bc = Instance.new("UICorner")
bc.CornerRadius = UDim.new(1, 0)
bc.Parent = btn

local bs = Instance.new("UIStroke")
bs.Color = Color3.fromRGB(0, 255, 200)
bs.Thickness = 2
bs.Parent = btn

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 195, 0, 370)
panel.Position = UDim2.new(0, 85, 0, 100)
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
    b.BackgroundColor3 = col or Color3.fromRGB(55, 55, 55)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.BorderSizePixel = 0
    b.Parent = panel
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = b
    return b
end

local onBtn = mkBtn("OFF", 36)
onBtn.Font = Enum.Font.GothamBold
onBtn.TextSize = 15

local spdBtn = mkBtn("Speed: 100", 70)
local autoBtn = mkBtn("Auto Steal: OFF", 102)
local setBtn = mkBtn("Set SafeZone (here)", 134)
local detectBtn = mkBtn("Auto Detect SafeZone", 166)
local scanBtn = mkBtn("Rescan", 198, Color3.fromRGB(100, 50, 100))

local info = Instance.new("TextLabel")
info.Size = UDim2.new(0, 165, 0, 110)
info.Position = UDim2.new(0, 15, 0, 230)
info.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
info.Text = "Ready"
info.TextColor3 = Color3.fromRGB(180, 255, 180)
info.Font = Enum.Font.Code
info.TextSize = 10
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.TextWrapped = true
info.BorderSizePixel = 0
info.Parent = panel

local ic = Instance.new("UICorner")
ic.CornerRadius = UDim.new(0, 8)
ic.Parent = info

-- ============================================================
-- SCAN FUNCTIONS
-- ============================================================
local function scanRemotes()
    remotes = {}
    local kws = {"collect","steal","grab","pickup","claim","take","egg","hatch","reward","get","buy"}
    pcall(function()
        for _, r in pairs(ReplicatedStorage:GetDescendants()) do
            if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
                local n = string.lower(r.Name)
                for _, k in pairs(kws) do
                    if string.find(n, k) then
                        table.insert(remotes, r)
                        break
                    end
                end
            end
        end
    end)
end

local function scanEggs()
    eggs = {}
    pcall(function()
        for _, o in pairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") then
                local n = string.lower(o.Name)
                if string.find(n, "egg") then
                    table.insert(eggs, o)
                end
            elseif o:IsA("Model") then
                local n = string.lower(o.Name)
                if string.find(n, "egg") then
                    local p = o:FindFirstChildWhichIsA("BasePart")
                    if p then table.insert(eggs, p) end
                end
            end
        end
    end)
end

local function detectSafeZone()
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
-- STEAL FUNCTION
-- ============================================================
local function steal(part)
    if not part or not part.Parent then return end
    if not HRP or not HRP.Parent then return end

    -- Teleport ទៅ egg
    pcall(function()
        HRP.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
    end)
    task.wait(0.12)

    -- ProximityPrompt + ClickDetector
    pcall(function()
        for _, c in pairs(part:GetChildren()) do
            if c:IsA("ProximityPrompt") then
                fireproximityprompt(c, 0)
            elseif c:IsA("ClickDetector") then
                fireclickdetector(c)
            end
        end
    end)

    -- Touch
    pcall(function()
        firetouchinterest(HRP, part, 0)
        task.wait(0.02)
        firetouchinterest(HRP, part, 1)
    end)

    -- Remotes
    for _, r in pairs(remotes) do
        pcall(function()
            if r:IsA("RemoteEvent") then
                r:FireServer(part)
                r:FireServer(part.Name)
            elseif r:IsA("RemoteFunction") then
                r:InvokeServer(part)
            end
        end)
    end

    -- Tools (backup)
    pcall(function()
        local bp = LP:FindFirstChild("Backpack")
        if bp then
            for _, t in pairs(bp:GetChildren()) do
                if t:IsA("Tool") then
                    t.Parent = Char
                    task.wait(0.06)
                    pcall(function() t:Activate() end)
                    task.wait(0.06)
                    t.Parent = bp
                end
            end
        end
    end)

    -- Return to safezone
    if safeZone then
        task.wait(0.25)
        pcall(function()
            HRP.CFrame = safeZone
        end)
    end
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not isOn then return end
    pcall(function()
        if Hum and Hum.Parent then
            Hum.WalkSpeed = speed
        end
    end)
    if autoOn then
        local now = tick()
        if now - lastSteal >= 1.0 then
            lastSteal = now
            for _, e in pairs(eggs) do
                if e and e.Parent then
                    pcall(steal, e)
                end
            end
        end
    end
end)

-- ============================================================
-- RESPAWN
-- ============================================================
LP.CharacterAdded:Connect(function(c)
    task.wait(1)
    Char = c
    HRP = c:WaitForChild("HumanoidRootPart")
    Hum = c:WaitForChild("Humanoid")
    origSpeed = Hum.WalkSpeed
end)

-- ============================================================
-- BUTTONS
-- ============================================================
btn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

onBtn.MouseButton1Click:Connect(function()
    isOn = not isOn
    if isOn then
        onBtn.Text = "ON"
        onBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        bs.Color = Color3.fromRGB(0, 255, 0)
        scanRemotes()
        scanEggs()
        if not safeZone then safeZone = detectSafeZone() end
    else
        onBtn.Text = "OFF"
        onBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        bs.Color = Color3.fromRGB(0, 255, 200)
        pcall(function() Hum.WalkSpeed = origSpeed end)
    end
    info.Text = "Eggs: "..#eggs.."\nRemotes: "..#remotes.."\nSafeZone: "..(safeZone and "YES" or "NO")
end)

spdBtn.MouseButton1Click:Connect(function()
    sIdx = sIdx + 1
    if sIdx > #speeds then sIdx = 1 end
    speed = speeds[sIdx]
    spdBtn.Text = "Speed: "..speed
end)

autoBtn.MouseButton1Click:Connect(function()
    autoOn = not autoOn
    if autoOn then
        autoBtn.Text = "Auto Steal: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    else
        autoBtn.Text = "Auto Steal: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end
end)

setBtn.MouseButton1Click:Connect(function()
    safeZone = HRP.CFrame
    info.Text = "Eggs: "..#eggs.."\nRemotes: "..#remotes.."\nSafeZone: YES"
end)

detectBtn.MouseButton1Click:Connect(function()
    local f = detectSafeZone()
    if f then safeZone = f end
    info.Text = "Eggs: "..#eggs.."\nRemotes: "..#remotes.."\nSafeZone: "..(safeZone and "YES" or "NO")
end)

scanBtn.MouseButton1Click:Connect(function()
    scanRemotes()
    scanEggs()
    info.Text = "Eggs: "..#eggs.."\nRemotes: "..#remotes.."\nSafeZone: "..(safeZone and "YES" or "NO")
end)

-- INIT
scanRemotes()
scanEggs()
safeZone = detectSafeZone()
info.Text = "Eggs: "..#eggs.."\nRemotes: "..#remotes.."\nSafeZone: "..(safeZone and "YES" or "NO")

print("[NhazX v19] Loaded | Eggs:"..#eggs.." | Remotes:"..#remotes)
