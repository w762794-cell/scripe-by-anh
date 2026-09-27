-- palofsc: NhazX FIX TELEPORT + ANTI-CHEAT BYPASS - v62
-- Bypass anti-cheat ខ្លាំងសម្រាប់ Update 26-27.09.2026
-- Teleport ជាន់ៗ + NetworkOwner + Hook Protection

print("[NhazX v62] Loading...")

local P = game:GetService("Players")
local S = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = P.LocalPlayer
local Ch = LP.Character or LP.CharacterAdded:Wait()
local H = Ch:WaitForChild("HumanoidRootPart")
local Hu = Ch:WaitForChild("Humanoid")
local PG = LP:WaitForChild("PlayerGui")

local home = H.CFrame
local isTeleporting = false
local lastTp = 0
local cooldown = 2.5
local originalSpeed = Hu.WalkSpeed
local lastCFrame = H.CFrame

print("[NhazX] Home: " .. tostring(home.Position))

if PG:FindFirstChild("NhazX") then PG.NhazX:Destroy() end

-- ============================================================
-- ANTI-CHEAT BYPASS (ខ្លាំង)
-- ============================================================
local bypassActive = false

local function setupBypass()
    local success = pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return false end
        
        local oldIndex = mt.__index
        local oldNewIndex = mt.__newindex
        local oldNamecall = mt.__namecall
        
        setreadonly(mt, false)
        
        -- Hook __index - លាក់ CFrame ពិត
        mt.__index = newcclosure(function(self, key)
            if self == H and key == "CFrame" then
                if isTeleporting then
                    return lastCFrame
                end
            end
            if self == Hu then
                if key == "WalkSpeed" then
                    return originalSpeed
                end
            end
            return oldIndex(self, key)
        end)
        
        -- Hook __newindex - ចាប់ការកែប្រែ
        mt.__newindex = newcclosure(function(self, key, value)
            if self == H and key == "CFrame" then
                if not isTeleporting then
                    lastCFrame = value
                end
                return oldNewIndex(self, key, value)
            end
            return oldNewIndex(self, key, value)
        end)
        
        setreadonly(mt, true)
        return true
    end)
    
    if success then
        bypassActive = true
        print("[NhazX] Anti-cheat bypass ACTIVE")
    else
        print("[NhazX] Bypass FAILED - hook not available")
    end
end

-- ព្យាយាមបើក bypass
pcall(setupBypass)

-- ============================================================
-- NETWORK OWNER LOOP
-- ============================================================
spawn(function()
    while task.wait(1) do
        pcall(function()
            if H and H.Parent then
                if H:GetNetworkOwner() ~= LP then
                    H:SetNetworkOwner(LP)
                end
            end
        end)
    end
end)

-- ============================================================
-- GODMODE (ការពារស្លាប់)
-- ============================================================
spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if Ch and Ch.Parent then
                local hum = Ch:FindFirstChildOfClass("Humanoid")
                if hum then
                    if hum.Health < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                    end
                end
                -- ForceField
                if not Ch:FindFirstChild("NhazXShield") then
                    local ff = Instance.new("ForceField")
                    ff.Name = "NhazXShield"
                    ff.Visible = false
                    ff.Parent = Ch
                end
            end
        end)
    end
end)

-- ============================================================
-- GUI
-- ============================================================
local g = Instance.new("ScreenGui")
g.Name = "NhazX"
g.ResetOnSpawn = false
g.Parent = PG

local nBtn = Instance.new("TextButton")
nBtn.Size = UDim2.new(0, 55, 0, 55)
nBtn.Position = UDim2.new(0, 20, 0.3, 0)
nBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
nBtn.Text = "N"
nBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
nBtn.TextSize = 28
nBtn.Font = Enum.Font.GothamBold
nBtn.BorderSizePixel = 0
nBtn.Parent = g
local nc = Instance.new("UICorner") nc.CornerRadius = UDim.new(1,0) nc.Parent = nBtn
local ns = Instance.new("UIStroke") ns.Color = Color3.fromRGB(0,255,200) ns.Thickness = 2 ns.Parent = nBtn

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0, 80, 0, 80)
tpBtn.Position = UDim2.new(0.82, 0, 0.4, 0)
tpBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
tpBtn.Text = "TP"
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.TextSize = 24
tpBtn.Font = Enum.Font.GothamBold
tpBtn.BorderSizePixel = 0
tpBtn.Parent = g
local tpc = Instance.new("UICorner") tpc.CornerRadius = UDim.new(1,0) tpc.Parent = tpBtn
local tps = Instance.new("UIStroke") tps.Color = Color3.fromRGB(0, 255, 150) tps.Thickness = 3 tps.Parent = tpBtn

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 185, 0, 180)
f.Position = UDim2.new(0, 85, 0.3, 0)
f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
f.BorderSizePixel = 0
f.Visible = false
f.Parent = g
local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0,14) fc.Parent = f
local fs = Instance.new("UIStroke") fs.Color = Color3.fromRGB(0,255,200) fs.Thickness = 1.5 fs.Parent = f

local function mkBtn(txt, y, col)
    local x = Instance.new("TextButton")
    x.Size = UDim2.new(0, 155, 0, 30)
    x.Position = UDim2.new(0, 15, 0, y)
    x.BackgroundColor3 = col or Color3.fromRGB(55,55,55)
    x.Text = txt
    x.TextColor3 = Color3.fromRGB(255,255,255)
    x.Font = Enum.Font.GothamBold
    x.TextSize = 12
    x.BorderSizePixel = 0
    x.Parent = f
    local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0,8) cc.Parent = x
    return x
end

local hB = mkBtn("Set Home (here)", 10, Color3.fromRGB(0, 100, 180))
local tB = mkBtn("Teleport", 44, Color3.fromRGB(0, 180, 100))
local bB = mkBtn("Bypass: CHECKING", 78, Color3.fromRGB(80, 40, 100))
local stB = mkBtn("Ready", 112, Color3.fromRGB(40, 40, 40))
stB.TextSize = 10

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, 0, 0, 16)
credit.Position = UDim2.new(0, 0, 1, -18)
credit.BackgroundTransparency = 1
credit.Text = "Script By @nhaz_samurai"
credit.TextColor3 = Color3.fromRGB(0, 255, 200)
credit.Font = Enum.Font.GothamBold
credit.TextSize = 10
credit.Parent = f

-- អូស GUI
local drag = false
local dStart, sPos

nBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dStart = input.Position
        sPos = nBtn.Position
    end
end)

nBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dStart
        local nx = sPos.X.Offset + d.X
        local ny = sPos.Y.Offset + d.Y
        nBtn.Position = UDim2.new(sPos.X.Scale, nx, sPos.Y.Scale, ny)
        f.Position = UDim2.new(0, nx + 65, 0, ny)
    end
end)

-- ============================================================
-- STEALTH TELEPORT
-- ============================================================
local function stealthTP(targetCF)
    if not H or not H.Parent then return false end
    if isTeleporting then return false end

    local now = tick()
    if now - lastTp < cooldown then
        stB.Text = "Wait " .. math.ceil(cooldown - (now - lastTp)) .. "s"
        return false
    end

    isTeleporting = true
    lastTp = now
    stB.Text = "Teleporting..."

    -- NetworkOwner
    pcall(function()
        if H:GetNetworkOwner() ~= LP then
            H:SetNetworkOwner(LP)
        end
    end)

    task.wait(0.1)

    -- Teleport ជាន់ៗ 10 steps
    local startPos = H.Position
    local targetPos = targetCF.Position
    local steps = 10

    for i = 1, steps do
        local pos = startPos:Lerp(targetPos, i / steps)
        pcall(function()
            H.CFrame = CFrame.new(pos)
        end)
        task.wait(0.05)
    end

    -- ចុងក្រោយ
    task.wait(0.15)
    pcall(function()
        H.Velocity = Vector3.zero
        H.AssemblyLinearVelocity = Vector3.zero
        H.CFrame = targetCF
    end)

    task.wait(0.2)
    pcall(function()
        H.CFrame = targetCF
    end)

    isTeleporting = false
    stB.Text = "Teleported!"
    return true
end

-- ============================================================
-- BUTTONS
-- ============================================================
nBtn.MouseButton1Click:Connect(function()
    f.Visible = not f.Visible
end)

tpBtn.MouseButton1Click:Connect(function()
    if stealthTP(home) then
        tpBtn.Text = "OK!"
        task.wait(0.5)
        tpBtn.Text = "TP"
    else
        tpBtn.Text = "WAIT"
        task.wait(0.5)
        tpBtn.Text = "TP"
    end
end)

tB.MouseButton1Click:Connect(function()
    if stealthTP(home) then
        tB.Text = "Done!"
        task.wait(0.8)
        tB.Text = "Teleport"
    end
end)

bB.MouseButton1Click:Connect(function()
    if bypassActive then
        bB.Text = "Bypass: ACTIVE"
        bB.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
    else
        bB.Text = "Bypass: FAILED"
        bB.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
    end
    task.wait(2)
    if bypassActive then
        bB.Text = "Bypass: ACTIVE"
    else
        bB.Text = "Bypass: CHECKING"
    end
end)

hB.MouseButton1Click:Connect(function()
    home = H.CFrame
    stB.Text = "Home: " .. math.floor(home.Position.X) .. "," .. math.floor(home.Position.Z)
    hB.Text = "Saved!"
    task.wait(1)
    hB.Text = "Set Home (here)"
    print("[NhazX] Home: " .. tostring(home.Position))
end)

LP.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    Ch = c
    H = c:WaitForChild("HumanoidRootPart")
    Hu = c:WaitForChild("Humanoid")
    originalSpeed = Hu.WalkSpeed
    lastCFrame = H.CFrame
    isTeleporting = false
end)

-- Update bypass status
task.wait(1)
if bypassActive then
    bB.Text = "Bypass: ACTIVE"
    bB.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
else
    bB.Text = "Bypass: FAILED"
    bB.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
end

print("[NhazX v62] Ready | Bypass: " .. tostring(bypassActive))
