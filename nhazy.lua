-- palofsc: NhazX - v60 FINAL
-- ដោះស្រាយ: teleport ទៅវិញទៅមក + មិនបាន egg + ស្លាប់
-- ប្រើ CFrame + NetworkOwner + រង់ចាំ server

print("[NhazX v60] Loading...")

local P = game:GetService("Players")
local S = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = P.LocalPlayer
local Ch = LP.Character or LP.CharacterAdded:Wait()
local H = Ch:WaitForChild("HumanoidRootPart")
local Hu = Ch:WaitForChild("Humanoid")
local PG = LP:WaitForChild("PlayerGui")

local home = H.CFrame
local tpCount = 0
local lastTp = 0
local cooldown = 2.5
local isTeleporting = false

print("[NhazX] Home saved: " .. tostring(home.Position))

if PG:FindFirstChild("NhazX") then PG.NhazX:Destroy() end

-- ============================================================
-- GUI
-- ============================================================
local g = Instance.new("ScreenGui")
g.Name = "NhazX"
g.ResetOnSpawn = false
g.Parent = PG

-- ប៊ូតុង N
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

-- ប៊ូតុង TP ធំ
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

-- Panel
local f = Instance.new("Frame")
f.Size = UDim2.new(0, 180, 0, 150)
f.Position = UDim2.new(0, 85, 0.3, 0)
f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
f.BorderSizePixel = 0
f.Visible = false
f.Parent = g
local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0,14) fc.Parent = f
local fs = Instance.new("UIStroke") fs.Color = Color3.fromRGB(0,255,200) fs.Thickness = 1.5 fs.Parent = f

local function mkBtn(txt, y, col)
    local x = Instance.new("TextButton")
    x.Size = UDim2.new(0, 150, 0, 30)
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
local stB = mkBtn("Ready", 78, Color3.fromRGB(40, 40, 40))
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
-- TELEPORT FUNCTION - ជួសជុល
-- ============================================================
local function tpHome()
    if not H or not H.Parent then return false end
    if isTeleporting then return false end
    
    local now = tick()
    if now - lastTp < cooldown then
        stB.Text = "Cooldown: " .. math.floor(cooldown - (now - lastTp)) .. "s"
        return false
    end
    
    isTeleporting = true
    lastTp = now
    tpCount = tpCount + 1
    
    -- 1. ទាញ NetworkOwner
    pcall(function()
        if H:GetNetworkOwner() ~= LP then
            H:SetNetworkOwner(LP)
        end
    end)
    
    -- 2. រង់ចាំ 0.1 វិនាទីឱ្យ server ទទួលស្គាល់ egg
    task.wait(0.1)
    
    -- 3. Teleport
    pcall(function()
        H.Velocity = Vector3.zero
        H.AssemblyLinearVelocity = Vector3.zero
        H.CFrame = home
    end)
    
    -- 4. រង់ចាំបន្ថែម
    task.wait(0.3)
    
    -- 5. Teleport ម្ដងទៀតដើម្បីធានា
    pcall(function()
        H.CFrame = home
    end)
    
    isTeleporting = false
    return true
end

-- ============================================================
-- BUTTONS
-- ============================================================
nBtn.MouseButton1Click:Connect(function()
    f.Visible = not f.Visible
end)

tpBtn.MouseButton1Click:Connect(function()
    if tpHome() then
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
    if tpHome() then
        tB.Text = "Teleported!"
        task.wait(0.8)
        tB.Text = "Teleport"
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

-- Respawn
LP.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    Ch = c
    H = c:WaitForChild("HumanoidRootPart")
    Hu = c:WaitForChild("Humanoid")
    isTeleporting = false
end)

print("[NhazX v60] Ready - TP + SetHome")
