-- palofsc: NhazX Steal An Egg - v30 FINAL
-- ដំណើរការសម្រាប់ហ្គេម "Steal An Egg"
-- ពេល steal egg បាន → teleport មក Home (safezone) ភ្លាម
-- មិនកាន់ដំបងពេល steal (កាត់បន្ថយការដេញ)

print("[NhazX v30] Loading...")

local P = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local S = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = P.LocalPlayer
local Ch = LP.Character or LP.CharacterAdded:Wait()
local H = Ch:WaitForChild("HumanoidRootPart")
local Hu = Ch:WaitForChild("Humanoid")
local PG = LP:WaitForChild("PlayerGui")

local on = false
local autoSteal = false
local home = H.CFrame
local lastTp = 0
local lastCount = 0
local baselineCount = 0
local anim = ""

print("[NhazX] Home: " .. tostring(home.Position))

-- រក remotes
local remotes = {}
for _, r in pairs(RS:GetDescendants()) do
    if r:IsA("RemoteEvent") then
        local n = string.lower(r.Name)
        if n:find("steal") or n:find("collect") or n:find("egg") or n:find("grab") or n:find("place") or n:find("equip") then
            table.insert(remotes, r)
        end
    end
end
print("[NhazX] Remotes: " .. #remotes)

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
f.Size = UDim2.new(0, 175, 0, 175)
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
local aB = mkBtn("Auto: OFF", 46)
local hB = mkBtn("Set Home (here)", 82, Color3.fromRGB(0, 130, 0))
local stB = mkBtn("Ready", 118, Color3.fromRGB(40, 40, 40))
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
-- រាប់ Tool
-- ============================================================
local function countTools()
    local c = LP.Character
    if not c then return 0 end
    local n = 0
    for _, o in pairs(c:GetChildren()) do
        if o:IsA("Tool") then n = n + 1 end
    end
    return n
end

-- ============================================================
-- រក egg ជិត (ដើម្បី steal ដោយខ្លួនឯង)
-- ============================================================
local function findEgg()
    if not H or not H.Parent then return nil end
    local closest = nil
    local dist = 30
    for _, o in pairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") then
            local n = string.lower(o.Name)
            if n:find("egg") then
                local d = (o.Position - H.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = o
                end
            end
        end
    end
    return closest
end

-- ============================================================
-- STEAL FUNCTION
-- ============================================================
local function doSteal()
    if not H or not H.Parent then return end
    
    -- បើកាន់ egg រួចហើយ → teleport home
    local cnt = countTools()
    if cnt > baselineCount then
        local t = tick()
        if t - lastTp > 0.8 then
            lastTp = t
            pcall(function() H.CFrame = home end)
            stB.Text = "Teleported Home!"
        end
        return
    end
    
    -- រក egg ជិត
    local e = findEgg()
    if not e then return end
    
    -- ទៅ steal
    pcall(function()
        H.CFrame = CFrame.new(e.Position + Vector3.new(0, 3, 0))
    end)
    task.wait(0.1)
    
    -- ProximityPrompt
    for _, c in pairs(e:GetChildren()) do
        if c:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(c, 0) end)
        elseif c:IsA("ClickDetector") then
            pcall(function() fireclickdetector(c) end)
        end
    end
    
    -- Touch
    pcall(function()
        firetouchinterest(H, e, 0)
        task.wait(0.02)
        firetouchinterest(H, e, 1)
    end)
    
    -- Remotes
    for _, r in pairs(remotes) do
        pcall(function()
            r:FireServer(e)
            r:FireServer(e.Name)
        end)
    end
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
S.Heartbeat:Connect(function()
    if not on then return end
    
    -- ពិនិត្យ tool count រាល់ frame
    local cnt = countTools()
    
    if cnt > baselineCount then
        -- មាន egg ថ្មី → teleport home ភ្លាម
        local t = tick()
        if t - lastTp > 0.8 then
            lastTp = t
            pcall(function() H.CFrame = home end)
            stB.Text = "Teleported!"
        end
    end
    
    if autoSteal then
        pcall(doSteal)
    end
end)

LP.CharacterAdded:Connect(function(c)
    task.wait(1)
    Ch = c
    H = c:WaitForChild("HumanoidRootPart")
    Hu = c:WaitForChild("Humanoid")
    baselineCount = countTools()
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
        baselineCount = countTools()
        stB.Text = "Running..."
    else
        oB.Text = "OFF"
        oB.BackgroundColor3 = Color3.fromRGB(55,55,55)
        bs.Color = Color3.fromRGB(0,255,200)
        stB.Text = "Stopped"
    end
end)

aB.MouseButton1Click:Connect(function()
    autoSteal = not autoSteal
    if autoSteal then
        aB.Text = "Auto: ON"
        aB.BackgroundColor3 = Color3.fromRGB(0,180,0)
    else
        aB.Text = "Auto: OFF"
        aB.BackgroundColor3 = Color3.fromRGB(55,55,55)
    end
end)

hB.MouseButton1Click:Connect(function()
    home = H.CFrame
    hB.Text = "Saved!"
    stB.Text = "Home: " .. math.floor(home.Position.X) .. "," .. math.floor(home.Position.Z)
    task.wait(1)
    hB.Text = "Set Home (here)"
end)

baselineCount = countTools()
print("[NhazX v30] Ready | Tools: " .. baselineCount)
