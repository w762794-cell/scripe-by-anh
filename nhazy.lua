-- palofsc: NhazX Steal An Egg - v31
-- ពេល steal egg បាន → teleport មក Home ភ្លាម
-- មិន teleport ទៅ egg ទេ

print("[NhazX v31] Loading...")

local P = game:GetService("Players")
local S = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = P.LocalPlayer
local Ch = LP.Character or LP.CharacterAdded:Wait()
local H = Ch:WaitForChild("HumanoidRootPart")
local Hu = Ch:WaitForChild("Humanoid")
local PG = LP:WaitForChild("PlayerGui")

local on = false
local home = H.CFrame
local lastTp = 0
local baseline = 0
local lastCount = 0
local prevBackpack = 0

print("[NhazX] Home saved: " .. tostring(home.Position))

-- លុប GUI ចាស់
if PG:FindFirstChild("NhazX") then PG.NhazX:Destroy() end

-- ============================================================
-- GUI
-- ============================================================
local g = Instance.new("ScreenGui")
g.Name = "NhazX"
g.ResetOnSpawn = false
g.Parent = PG

local b = Instance.new("TextButton")
b.Size = UDim2.new(0, 55, 0, 55)
b.Position = UDim2.new(0, 20, 0.3, 0)
b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
b.Text = "N"
b.TextColor3 = Color3.fromRGB(0, 255, 200)
b.TextSize = 28
b.Font = Enum.Font.GothamBold
b.BorderSizePixel = 0
b.Parent = g
local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(1,0) bc.Parent = b
local bs = Instance.new("UIStroke") bs.Color = Color3.fromRGB(0,255,200) bs.Thickness = 2 bs.Parent = b

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 175, 0, 150)
f.Position = UDim2.new(0, 85, 0.3, 0)
f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
f.BorderSizePixel = 0
f.Visible = false
f.Parent = g
local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0,14) fc.Parent = f
local fs = Instance.new("UIStroke") fs.Color = Color3.fromRGB(0,255,200) fs.Thickness = 1.5 fs.Parent = f

local function mkBtn(txt, y, col)
    local x = Instance.new("TextButton")
    x.Size = UDim2.new(0, 145, 0, 30)
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

local oB = mkBtn("OFF", 10)
oB.TextSize = 16
local hB = mkBtn("Set Home (here)", 46, Color3.fromRGB(0, 130, 0))
local stB = mkBtn("Home: SET", 82, Color3.fromRGB(40, 40, 40))
stB.TextSize = 10

-- អូស GUI
local drag = false
local dStart, sPos

b.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dStart = input.Position
        sPos = b.Position
    end
end)

b.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dStart
        local nx = sPos.X.Offset + d.X
        local ny = sPos.Y.Offset + d.Y
        b.Position = UDim2.new(sPos.X.Scale, nx, sPos.Y.Scale, ny)
        f.Position = UDim2.new(0, nx + 65, 0, ny)
    end
end)

-- ============================================================
-- រាប់ចំនួន Tool ទាំង Character + Backpack
-- ============================================================
local function countAllTools()
    local total = 0
    local c = LP.Character
    if c then
        for _, o in pairs(c:GetChildren()) do
            if o:IsA("Tool") then total = total + 1 end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, o in pairs(bp:GetChildren()) do
            if o:IsA("Tool") then total = total + 1 end
        end
    end
    return total
end

-- ============================================================
-- MAIN LOOP - ពិនិត្យចំនួន Tool
-- ============================================================
S.Heartbeat:Connect(function()
    if not on then return end
    if not H or not H.Parent then return end
    
    local cnt = countAllTools()
    
    -- បើចំនួនកើនឡើង → steal egg បាន → teleport home
    if cnt > baseline then
        local t = tick()
        if t - lastTp > 1 then
            lastTp = t
            pcall(function()
                H.Velocity = Vector3.zero
                H.AssemblyLinearVelocity = Vector3.zero
                H.CFrame = home
            end)
            stB.Text = "Teleported Home!"
            print("[NhazX] Steal បាន → Teleport Home | Tools: " .. cnt)
        end
    end
    
    -- ធ្វើឱ្យ baseline តាមចំនួនថ្មី ក្រោយ teleport
    if tick() - lastTp > 1.5 then
        baseline = cnt
    end
end)

LP.CharacterAdded:Connect(function(c)
    task.wait(1)
    Ch = c
    H = c:WaitForChild("HumanoidRootPart")
    Hu = c:WaitForChild("Humanoid")
    baseline = countAllTools()
    stB.Text = "Home: SET"
end)

-- ============================================================
-- BUTTONS
-- ============================================================
b.MouseButton1Click:Connect(function() f.Visible = not f.Visible end)

oB.MouseButton1Click:Connect(function()
    on = not on
    if on then
        oB.Text = "ON"
        oB.BackgroundColor3 = Color3.fromRGB(0,180,0)
        bs.Color = Color3.fromRGB(0,255,0)
        baseline = countAllTools()
        stB.Text = "Baseline: " .. baseline
        print("[NhazX] ON | Baseline tools: " .. baseline)
    else
        oB.Text = "OFF"
        oB.BackgroundColor3 = Color3.fromRGB(55,55,55)
        bs.Color = Color3.fromRGB(0,255,200)
        stB.Text = "Home: SET"
    end
end)

hB.MouseButton1Click:Connect(function()
    home = H.CFrame
    hB.Text = "Saved!"
    stB.Text = "Home: " .. math.floor(home.Position.X) .. "," .. math.floor(home.Position.Z)
    task.wait(1)
    hB.Text = "Set Home (here)"
    print("[NhazX] New home: " .. tostring(home.Position))
end)

baseline = countAllTools()
print("[NhazX v31] Ready | Tools: " .. baseline)
