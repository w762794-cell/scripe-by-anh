-- palofsc: NhazX - v59 SIMPLE TP
-- មានតែ 2 ប៊ូតុង: TP និង SetHome
-- ចុច TP → teleport ទៅ SafeZone ភ្លាម គ្មានស្លាប់

print("[NhazX v59] Loading...")

local P = game:GetService("Players")
local LP = P.LocalPlayer
local Ch = LP.Character or LP.CharacterAdded:Wait()
local H = Ch:WaitForChild("HumanoidRootPart")
local Hu = Ch:WaitForChild("Humanoid")
local PG = LP:WaitForChild("PlayerGui")

local home = H.CFrame

print("[NhazX] Home saved: " .. tostring(home.Position))

if PG:FindFirstChild("NhazX") then PG.NhazX:Destroy() end

-- ============================================================
-- GUI
-- ============================================================
local g = Instance.new("ScreenGui")
g.Name = "NhazX"
g.ResetOnSpawn = false
g.Parent = PG

-- ប៊ូតុង N មូល
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
f.Size = UDim2.new(0, 175, 0, 130)
f.Position = UDim2.new(0, 85, 0.3, 0)
f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
f.BorderSizePixel = 0
f.Visible = false
f.Parent = g
local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0,14) fc.Parent = f
local fs = Instance.new("UIStroke") fs.Color = Color3.fromRGB(0,255,200) fs.Thickness = 1.5 fs.Parent = f

local function mkBtn(txt, y, col)
    local x = Instance.new("TextButton")
    x.Size = UDim2.new(0, 145, 0, 32)
    x.Position = UDim2.new(0, 15, 0, y)
    x.BackgroundColor3 = col or Color3.fromRGB(55,55,55)
    x.Text = txt
    x.TextColor3 = Color3.fromRGB(255,255,255)
    x.Font = Enum.Font.GothamBold
    x.TextSize = 13
    x.BorderSizePixel = 0
    x.Parent = f
    local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0,8) cc.Parent = x
    return x
end

local hB = mkBtn("Set Home (here)", 12, Color3.fromRGB(0, 100, 180))
local tB = mkBtn("Teleport", 50, Color3.fromRGB(0, 180, 100))
local stB = mkBtn("Home: SET", 88, Color3.fromRGB(40, 40, 40))
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

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dStart
        local nx = sPos.X.Offset + d.X
        local ny = sPos.Y.Offset + d.Y
        nBtn.Position = UDim2.new(sPos.X.Scale, nx, sPos.Y.Scale, ny)
        f.Position = UDim2.new(0, nx + 65, 0, ny)
    end
end)

-- ============================================================
-- TELEPORT FUNCTION
-- ============================================================
local function tpHome()
    if not H or not H.Parent then return end
    pcall(function()
        H.Velocity = Vector3.zero
        H.AssemblyLinearVelocity = Vector3.zero
        H.CFrame = home
    end)
    print("[NhazX] Teleported to home")
end

-- ============================================================
-- BUTTONS
-- ============================================================
nBtn.MouseButton1Click:Connect(function()
    f.Visible = not f.Visible
end)

-- ប៊ូតុង TP ធំ
tpBtn.MouseButton1Click:Connect(function()
    tpHome()
    tpBtn.Text = "OK!"
    task.wait(0.5)
    tpBtn.Text = "TP"
end)

-- ប៊ូតុង Teleport ក្នុង Panel
tB.MouseButton1Click:Connect(function()
    tpHome()
    tB.Text = "Teleported!"
    task.wait(0.8)
    tB.Text = "Teleport"
end)

-- ប៊ូតុង Set Home
hB.MouseButton1Click:Connect(function()
    home = H.CFrame
    stB.Text = "Home: " .. math.floor(home.Position.X) .. "," .. math.floor(home.Position.Z)
    hB.Text = "Saved!"
    task.wait(1)
    hB.Text = "Set Home (here)"
    print("[NhazX] Home saved: " .. tostring(home.Position))
end)

-- Respawn
LP.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    Ch = c
    H = c:WaitForChild("HumanoidRootPart")
    Hu = c:WaitForChild("Humanoid")
end)

print("[NhazX v59] Ready - TP + SetHome")
