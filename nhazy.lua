-- palofsc: NhazX ANTI-CHEAT BYPASS v17
-- សម្រាប់ game anti-cheat ខ្លាំង
-- ប្រើ hookmetamethod + NetworkOwnership + Slow teleport + Remote spy

print("[NhazX v17] Loading anti-cheat bypass...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart", 10)
local Hum = Char:WaitForChild("Humanoid", 10)
local PG = LP:WaitForChild("PlayerGui", 10)

-- ============================================================
-- ANTI-CHEAT BYPASS CORE
-- ============================================================
local bypass = {}
bypass.enabled = false
bypass.originalCFrame = HRP.CFrame
bypass.originalSpeed = Hum.WalkSpeed
bypass.originalJump = Hum.JumpPower

-- Hook metatable ដើម្បី spoof property
local function setupHook()
    local success, mt = pcall(getrawmetatable, game)
    if not success or not mt then
        warn("[NhazX] getrawmetatable not available")
        return false
    end

    local oldIndex = mt.__index
    local oldNewIndex = mt.__newindex
    local oldNamecall = mt.__namecall

    pcall(setreadonly, mt, false)

    mt.__index = newcclosure(function(self, key)
        if self == Hum then
            if key == "WalkSpeed" then return bypass.originalSpeed end
            if key == "JumpPower" then return bypass.originalJump end
        end
        if self == HRP and key == "CFrame" then
            return bypass.originalCFrame
        end
        return oldIndex(self, key)
    end)

    mt.__newindex = newcclosure(function(self, key, value)
        if self == Hum and (key == "WalkSpeed" or key == "JumpPower") then
            oldNewIndex(self, key, value)
            return
        end
        if self == HRP and key == "CFrame" then
            bypass.originalCFrame = value
        end
        return oldNewIndex(self, key, value)
    end)

    pcall(setreadonly, mt, true)
    bypass.enabled = true
    return true
end

-- ============================================================
-- NETWORK OWNERSHIP
-- ============================================================
local function takeNetworkOwnership()
    pcall(function()
        if HRP and HRP:GetNetworkOwner() ~= LP then
            HRP:SetNetworkOwner(LP)
        end
    end)
end

-- ============================================================
-- SLOW TELEPORT (Anti-detection)
-- ============================================================
local function safeTeleport(targetCFrame)
    if not HRP or not HRP.Parent then return end
    pcall(function()
        HRP.Velocity = Vector3.zero
        HRP.AssemblyLinearVelocity = Vector3.zero
        HRP.CFrame = targetCFrame
    end)
    -- Update spy position
    bypass.originalCFrame = targetCFrame
    -- Take ownership ម្ដងទៀត
    takeNetworkOwnership()
end

-- ============================================================
-- REMOTE SPY (ដឹងថា remote ណាប្រើ)
-- ============================================================
local capturedRemotes = {}

local function spyRemotes()
    capturedRemotes = {}
    pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return end
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                    local key = self:GetFullName()
                    capturedRemotes[key] = (capturedRemotes[key] or 0) + 1
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

-- ============================================================
-- CONFIG
-- ============================================================
local isRunning = false
local autoSteal = false
local autoReturn = true
local speed = 100
local speeds = {50, 80, 100, 150, 200, 300}
local sIdx = 3
local lastSteal = 0
local stealDelay = 0.8
local safeZoneCFrame = nil
local returnDelay = 0.3
local stealRemotes = {}
local eggList = {}
local teleportStep = 5       -- ចម្ងាយក្នុងមួយ step
local teleportSpeed = 0.05   -- delay រវាង step

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
panel.Size = UDim2.new(0, 210, 0, 440)
panel.Position = UDim2.new(0, 85, 0, 60)
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
title.Text = "NhazX v17"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = panel

local function mkBtn(txt, y, col, h)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 180, 0, h or 26)
    b.Position = UDim2.new(0, 15, 0, y)
    b.BackgroundColor3 = col or Color3.fromRGB(55,55,55)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 11
    b.BorderSizePixel = 0
    b.Parent = panel
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,8) c.Parent = b
    return b
end

local onBtn = mkBtn("OFF", 36, nil, 34)
onBtn.Font = Enum.Font.GothamBold
onBtn.TextSize = 15
local bypassBtn = mkBtn("Bypass: OFF", 74)
local hookBtn = mkBtn("Enable Hook", 104, Color3.fromRGB(80,40,80))
local spyBtn = mkBtn("Spy Remotes", 134, Color3.fromRGB(80,80,20))
local spdBtn = mkBtn("Speed: 100", 164)
local autoBtn = mkBtn("Auto Steal: OFF", 194)
local retBtn = mkBtn("Auto Return: ON", 224, Color3.fromRGB(0,130,0))
local setBtn = mkBtn("Set SafeZone (here)", 254)
local detectBtn = mkBtn("Auto Detect SafeZone", 284)
local scanBtn = mkBtn("Rescan All", 314, Color3.fromRGB(100,50,100))

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 180, 0, 100)
infoLabel.Position = UDim2.new(0, 15, 0, 344)
infoLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
infoLabel.Text = "Loading..."
infoLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
infoLabel.Font = Enum.Font.Code
infoLabel.TextSize = 9
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextWrapped = true
infoLabel.BorderSizePixel = 0
infoLabel.Parent = panel
local ilc = Instance.new("UICorner") ilc.CornerRadius = UDim.new(0,8) ilc.Parent = infoLabel

-- ============================================================
-- SCAN FUNCTIONS
-- ============================================================
local function scanEggs()
    eggList = {}
    pcall(function()
        for _, o in pairs(workspace:GetDescendants()) do
            local n = string.lower(o.Name)
            if string.find(n, "egg") or string.find(n, "pet") or string.find(n, "collectible") then
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
    local kws = {"collect","steal","grab","pickup","claim","take","get","egg","pet","hatch","spawn","reward"}
    pcall(function()
        for _, r in pairs(ReplicatedStorage:GetDescendants()) do
            if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
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
-- STEALTH TELEPORT (Slow, step by step)
-- ============================================================
local function stealthTeleport(target)
    if not HRP or not HRP.Parent then return end
    pcall(function()
        local current = HRP.Position
        local targetPos = target.Position
        local dir = (targetPos - current)
        local dist = dir.Magnitude
        if dist < 3 then
            safeTeleport(target)
            return
        end
        local steps = math.min(math.floor(dist / teleportStep), 30)
        local unit = dir.Unit
        for i = 1, steps do
            local newPos = current + unit * (teleportStep * i)
            pcall(function()
                HRP.CFrame = CFrame.new(newPos, newPos + unit)
            end)
            task.wait(teleportSpeed)
        end
    end)
end

-- ============================================================
-- STEAL
-- ============================================================
local function stealOne(part)
    if not part or not part.Parent then return end
    if not HRP or not HRP.Parent then return end

    -- Stealth teleport ជំនួស teleport ផ្ទាល់
    stealthTeleport(part.CFrame + Vector3.new(0, 2, 0))
    task.wait(0.1)

    -- Prompts
    for _, c in pairs(part:GetChildren()) do
        if c:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(c, 0) end)
        elseif c:IsA("ClickDetector") then
            pcall(function() fireclickdetector(c) end)
        end
    end

    -- Touch
    pcall(function()
        firetouchinterest(HRP, part, 0)
        task.wait(0.02)
        firetouchinterest(HRP, part, 1)
    end)

    -- Remotes
    for _, r in pairs(stealRemotes) do
        pcall(function()
            if r:IsA("RemoteEvent") then
                r:FireServer(part)
                r:FireServer(part.Name)
            end
        end)
    end

    -- Return safezone (stealth)
    if autoReturn and safeZoneCFrame then
        task.wait(returnDelay)
        stealthTeleport(safeZoneCFrame)
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
    local spyCount = 0
    for _ in pairs(capturedRemotes) do spyCount = spyCount + 1 end
    infoLabel.Text = "Eggs: "..#eggList..
        "\nRemotes: "..#stealRemotes..
        "\nSpy: "..spyCount..
        "\nHook: "..(bypass.enabled and "ON" or "OFF")..
        "\nSafeZone: "..(safeZoneCFrame and "YES" or "NO")
end

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
        takeNetworkOwnership()
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
        pcall(function() Hum.WalkSpeed = bypass.originalSpeed end)
    end
end)

bypassBtn.MouseButton1Click:Connect(function()
    if bypass.enabled then
        bypassBtn.Text = "Bypass: OFF"
        bypassBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        bypass.enabled = false
    else
        bypassBtn.Text = "Bypass: ON"
        bypassBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        bypass.enabled = true
        takeNetworkOwnership()
    end
end)

hookBtn.MouseButton1Click:Connect(function()
    local ok = setupHook()
    if ok then
        hookBtn.Text = "Hook: ACTIVE"
        hookBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        hookBtn.Text = "Hook: FAILED"
        hookBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
    updateInfo()
end)

spyBtn.MouseButton1Click:Connect(function()
    spyRemotes()
    spyBtn.Text = "Spy: ACTIVE"
    spyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
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

-- ============================================================
-- INIT
-- ============================================================
scanEggs()
scanRemotes()
safeZoneCFrame = autoDetectSafeZone()
updateInfo()

print("[NhazX v17] ✓ Loaded")
print("  Eggs: " .. #eggList)
print("  Remotes: " .. #stealRemotes)
print("  SafeZone: " .. tostring(safeZoneCFrame ~= nil))
print("  Hook available: " .. tostring(bypass.enabled))
