-- palofsc: NhazX Steal a Egg - v24
-- សម្រាប់ game "Steal a Egg"
-- ពេលលួច egg បាន (កាន់ egg ក្នុងដៃ) → teleport មក Home ភ្លាម គ្មានថាឆ្ងាយប៉ុន្មាន

local P = game:GetService("Players")
local R = game:GetService("ReplicatedStorage")
local S = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = P.LocalPlayer
local Ch = LP.Character or LP.CharacterAdded:Wait()
local H = Ch:WaitForChild("HumanoidRootPart")
local Hu = Ch:WaitForChild("Humanoid")
local PG = LP:WaitForChild("PlayerGui")

local on = false
local auto = false
local spd = 100
local spdList = {60, 100, 200, 500, 1000}
local si = 2
local originalSpd = 60
local home = H.CFrame
local rem = {}
local lastTeleport = 0

-- រក remotes សម្រាប់ steal
for _, r in pairs(R:GetDescendants()) do
    if r:IsA("RemoteEvent") then
        local n = string.lower(r.Name)
        if n:find("collect") or n:find("steal") or n:find("grab") or n:find("pickup") or n:find("egg") or n:find("take") then
            table.insert(rem, r)
        end
    end
end

-- លុប GUI ចាស់
if PG:FindFirstChild("NhazX") then PG.NhazX:Destroy() end

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
f.Size = UDim2.new(0, 180, 0, 280)
f.Position = UDim2.new(0, 85, 0.3, 0)
f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
f.BorderSizePixel = 0
f.Visible = false
f.Parent = g
local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0,14) fc.Parent = f
local fs = Instance.new("UIStroke") fs.Color = Color3.fromRGB(0,255,200) fs.Thickness = 1.5 fs.Parent = f

local ti = Instance.new("TextLabel")
ti.Size = UDim2.new(1, 0, 0, 26)
ti.Position = UDim2.new(0, 0, 0, 4)
ti.BackgroundTransparency = 1
ti.Text = "NhazX"
ti.TextColor3 = Color3.fromRGB(0, 255, 200)
ti.Font = Enum.Font.GothamBold
ti.TextSize = 18
ti.Parent = f

local function btn(txt, y, c)
    local x = Instance.new("TextButton")
    x.Size = UDim2.new(0, 150, 0, 28)
    x.Position = UDim2.new(0, 15, 0, y)
    x.BackgroundColor3 = c or Color3.fromRGB(55,55,55)
    x.Text = txt
    x.TextColor3 = Color3.fromRGB(255,255,255)
    x.Font = Enum.Font.GothamBold
    x.TextSize = 12
    x.BorderSizePixel = 0
    x.Parent = f
    local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0,8) cc.Parent = x
    return x
end

local oB = btn("OFF", 34)
local autoB = btn("Auto Steal: OFF", 68)
local spdB = btn("Speed: 100", 102)
local homeB = btn("Set Home (here)", 136, Color3.fromRGB(0, 130, 0))
local statusB = btn("Home: NOT SET", 170, Color3.fromRGB(40,40,40))
statusB.TextSize = 11
local remB = btn("Remotes: "..#rem, 204, Color3.fromRGB(40,40,40))
remB.TextSize = 10

-- ============================================================
-- មុខងារអូស GUI
-- ============================================================
local dragging = false
local dragStart = nil
local startPos = nil

b.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = b.Position
    end
end)

b.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y
        b.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        f.Position = UDim2.new(0, newX + 65, 0, newY)
    end
end)

-- ============================================================
-- ពិនិត្យថាតើកាន់ egg ក្នុងដៃឬអត់
-- ============================================================
local function holdingEgg()
    local char = LP.Character
    if not char then return false end
    for _, c in pairs(char:GetChildren()) do
        if c:IsA("Tool") or c:IsA("Model") then
            local n = string.lower(c.Name)
            if n:find("egg") or n:find("steal") then
                return true
            end
        end
    end
    -- ពិនិត្យក្នុង backpack ផង
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, c in pairs(bp:GetChildren()) do
            if c:IsA("Tool") then
                local n = string.lower(c.Name)
                if n:find("egg") then return true end
            end
        end
    end
    return false
end

-- ============================================================
-- ពិនិត្យថាតើមាន egg នៅជិតឬអត់ (សម្រាប់ steal)
-- ============================================================
local function findNearbyEgg()
    if not H or not H.Parent then return nil end
    local closest = nil
    local closestDist = 15 -- ចម្ងាយក្នុង studs
    for _, o in pairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") and string.find(string.lower(o.Name), "egg") then
            local dist = (o.Position - H.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = o
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
    
    -- ពិនិត្យថាកាន់ egg រួចហើយ → teleport មក Home ភ្លាម
    if holdingEgg() then
        if home then
            pcall(function()
                H.CFrame = home
            end)
        end
        return
    end
    
    -- រក egg ជិត
    local egg = findNearbyEgg()
    if not egg then return end
    
    -- ព្យាយាមយក
    for _, c in pairs(egg:GetChildren()) do
        if c:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(c, 0) end)
        elseif c:IsA("ClickDetector") then
            pcall(function() fireclickdetector(c) end)
        end
    end
    
    pcall(function()
        firetouchinterest(H, egg, 0)
        task.wait(0.02)
        firetouchinterest(H, egg, 1)
    end)
    
    for _, r in pairs(rem) do
        pcall(function()
            r:FireServer(egg)
            r:FireServer(egg.Name)
        end)
    end
end

-- ============================================================
-- MAIN LOOP - ពិនិត្យរាល់ frame
-- ============================================================
S.Heartbeat:Connect(function()
    if not on then return end

    -- Speed
    pcall(function()
        if Hu and Hu.Parent then
            Hu.WalkSpeed = spd
        end
    end)

    -- Auto Steal
    if auto then
        pcall(doSteal)
    end
end)

-- ============================================================
-- ពិនិត្យរាល់ 0.3 វិនាទី - បើកាន់ egg → teleport home ភ្លាម
-- ============================================================
spawn(function()
    while task.wait(0.3) do
        if on and auto and home then
            if holdingEgg() then
                pcall(function()
                    H.CFrame = home
                end)
            end
        end
    end
end)

LP.CharacterAdded:Connect(function(c)
    task.wait(1)
    Ch = c
    H = c:WaitForChild("HumanoidRootPart")
    Hu = c:WaitForChild("Humanoid")
end)

-- ============================================================
-- BUTTONS
-- ============================================================
b.MouseButton1Click:Connect(function() f.Visible = not f.Visible end)

oB.MouseButton1Click:Connect(function()
    on = not on
    oB.Text = on and "ON" or "OFF"
    oB.BackgroundColor3 = on and Color3.fromRGB(0,180,0) or Color3.fromRGB(55,55,55)
    bs.Color = on and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,255,200)
end)

autoB.MouseButton1Click:Connect(function()
    auto = not auto
    autoB.Text = auto and "Auto Steal: ON" or "Auto Steal: OFF"
    autoB.BackgroundColor3 = auto and Color3.fromRGB(0,180,0) or Color3.fromRGB(55,55,55)
end)

spdB.MouseButton1Click:Connect(function()
    si = si + 1
    if si > #spdList then si = 1 end
    spd = spdList[si]
    spdB.Text = "Speed: "..spd
end)

homeB.MouseButton1Click:Connect(function()
    home = H.CFrame
    statusB.Text = "Home: SET"
    statusB.TextColor3 = Color3.fromRGB(0, 255, 100)
    homeB.Text = "Home Saved!"
    task.wait(1)
    homeB.Text = "Set Home (here)"
end)

print("[NhazX v24] Loaded | Remotes: "..#rem)
