-- palofsc: NhazX Steal An Egg - v58 FINAL
-- Script ដំណើរការ 100% - Teleport ភ្លាម ពេលកាន់ egg
-- មានប៊ូតុងលើ screen ចុចទៅ SafeZone ភ្លាម

print("[NhazX v58] Loading...")

local P = game:GetService("Players")
local S = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = P.LocalPlayer
local Ch = LP.Character or LP.CharacterAdded:Wait()
local H = Ch:WaitForChild("HumanoidRootPart")
local Hu = Ch:WaitForChild("Humanoid")
local PG = LP:WaitForChild("PlayerGui")

local on = false
local godmode = true
local home = H.CFrame
local tpCount = 0
local lastTp = 0
local cooldown = 1.0
local lastStealPoint = nil
local autoReturn = true
local returnDelay = 1.2

print("[NhazX] Home: " .. tostring(home.Position))

if PG:FindFirstChild("NhazX") then PG.NhazX:Destroy() end

-- ============================================================
-- GUI - ប៊ូតុងលើ screen
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

-- ប៊ូតុង TELEPORT ធំ លើ screen
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0, 70, 0, 70)
tpBtn.Position = UDim2.new(0.85, 0, 0.4, 0)
tpBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
tpBtn.Text = "TP"
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.TextSize = 22
tpBtn.Font = Enum.Font.GothamBold
tpBtn.BorderSizePixel = 0
tpBtn.Parent = g
local tpc = Instance.new("UICorner") tpc.CornerRadius = UDim.new(1,0) tpc.Parent = tpBtn
local tps = Instance.new("UIStroke") tps.Color = Color3.fromRGB(0, 255, 150) tps.Thickness = 3 tps.Parent = tpBtn

-- Panel
local f = Instance.new("Frame")
f.Size = UDim2.new(0, 185, 0, 240)
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

local oB = mkBtn("OFF", 10)
oB.TextSize = 16
local gB = mkBtn("Godmode: ON", 46, Color3.fromRGB(0, 130, 0))
local hB = mkBtn("Set Home (here)", 82, Color3.fromRGB(0, 100, 180))
local rb = mkBtn("Auto Return: ON", 118, Color3.fromRGB(0, 130, 0))
local stB = mkBtn("Status: OFF", 154, Color3.fromRGB(40, 40, 40))
stB.TextSize = 10
local infoB = mkBtn("Holding: NO", 190, Color3.fromRGB(30, 30, 30))
infoB.TextSize = 10

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, 0, 0, 18)
credit.Position = UDim2.new(0, 0, 1, -20)
credit.BackgroundTransparency = 1
credit.Text = "Script By @nhaz_samurai"
credit.TextColor3 = Color3.fromRGB(0, 255, 200)
credit.Font = Enum.Font.GothamBold
credit.TextSize = 11
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
-- GODMODE
-- ============================================================
local function applyGodmode()
    if not godmode then return end
    if not Ch or not Ch.Parent then return end
    pcall(function()
        local hum = Ch:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
        if not Ch:FindFirstChild("NhazXShield") then
            local ff = Instance.new("ForceField")
            ff.Name = "NhazXShield"
            ff.Visible = false
            ff.Parent = Ch
        end
    end)
end

-- ============================================================
-- ពិនិត្យកាន់ egg
-- ============================================================
local function hasEgg()
    local c = LP.Character
    if not c then return false end
    for _, o in pairs(c:GetChildren()) do
        if o:IsA("Tool") then
            local n = string.lower(o.Name)
            if n:find("egg") or n:find("stolen") then
                return true
            end
        end
    end
    return false
end

-- ============================================================
-- TELEPORT
-- ============================================================
local function tpTo(cf)
    if not H or not H.Parent then return end
    pcall(function()
        H.Velocity = Vector3.zero
        H.AssemblyLinearVelocity = Vector3.zero
        H.CFrame = cf
    end)
end

-- ============================================================
-- LOOP - ពេលកាន់ egg → teleport ភ្លាម
-- ============================================================
spawn(function()
    while task.wait(0.1) do
        if not Ch or not Ch.Parent then continue end

        if godmode then
            pcall(function()
                local hum = Ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end)
        end

        if not on then continue end
        if not H or not H.Parent then continue end

        local egg = hasEgg()
        infoB.Text = "Holding: " .. (egg and "YES" or "NO")

        -- បើកាន់ egg → teleport Home ភ្លាម
        if egg then
            local t = tick()
            if t - lastTp > cooldown then
                lastTp = t
                tpCount = tpCount + 1
                
                -- ចាំចំណុចបច្ចុប្បន្ន
                lastStealPoint = H.CFrame
                
                -- Teleport Home ភ្លាម
                stB.Text = "TP #" .. tpCount .. " → Home"
                tpTo(home)
                print("[NhazX] #" .. tpCount .. " Holding egg → Home")
                
                -- Auto Return
                if autoReturn and lastStealPoint then
                    task.wait(returnDelay)
                    stB.Text = "TP #" .. tpCount .. " → Return"
                    tpTo(lastStealPoint)
                    print("[NhazX] #" .. tpCount .. " → Return")
                end
            end
        else
            if tick() - lastTp > 1.5 then
                stB.Text = "Watching..."
            end
        end
    end
end)

LP.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    Ch = c
    H = c:WaitForChild("HumanoidRootPart")
    Hu = c:WaitForChild("Humanoid")
    applyGodmode()
end)

-- ============================================================
-- BUTTONS
-- ============================================================
nBtn.MouseButton1Click:Connect(function()
    f.Visible = not f.Visible
end)

-- ប៊ូតុង TELEPORT ធំ → ចុចទៅ SafeZone ភ្លាម
tpBtn.MouseButton1Click:Connect(function()
    if not H or not H.Parent then return end
    -- Teleport ទៅ Home ភ្លាម
    tpTo(home)
    tpBtn.Text = "OK!"
    task.wait(0.5)
    tpBtn.Text = "TP"
    print("[NhazX] Manual teleport to home")
end)

oB.MouseButton1Click:Connect(function()
    on = not on
    if on then
        oB.Text = "ON"
        oB.BackgroundColor3 = Color3.fromRGB(0,180,0)
        bs.Color = Color3.fromRGB(0,255,0)
        stB.Text = "Watching..."
        tpCount = 0
        applyGodmode()
    else
        oB.Text = "OFF"
        oB.BackgroundColor3 = Color3.fromRGB(55,55,55)
        bs.Color = Color3.fromRGB(0,255,200)
        stB.Text = "Status: OFF"
    end
end)

gB.MouseButton1Click:Connect(function()
    godmode = not godmode
    if godmode then
        gB.Text = "Godmode: ON"
        gB.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
        applyGodmode()
    else
        gB.Text = "Godmode: OFF"
        gB.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end
end)

hB.MouseButton1Click:Connect(function()
    home = H.CFrame
    hB.Text = "Saved!"
    task.wait(1)
    hB.Text = "Set Home (here)"
    print("[NhazX] Home: " .. tostring(home.Position))
end)

rb.MouseButton1Click:Connect(function()
    autoReturn = not autoReturn
    if autoReturn then
        rb.Text = "Auto Return: ON"
        rb.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
    else
        rb.Text = "Auto Return: OFF"
        rb.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end
end)

applyGodmode()
print("[NhazX v58] Script By @nhaz_samurai")
