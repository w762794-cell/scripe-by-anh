-- palofsc: NhazX Steal An Egg - v35
-- ពេលទៅ steal egg → មេវាដេញ → teleport មក Home ភ្លាម
-- មិនមែនពេលកាន់ egg ទេ

print("[NhazX v35] Loading...")

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
local chaseDistance = 30     -- ចម្ងាយដែលចាត់ទុកថាដេញ
local cooldown = 1.5          -- ចន្លោះពេលរវាង teleport

print("[NhazX] Home: " .. tostring(home.Position))

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
f.Size = UDim2.new(0, 180, 0, 180)
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

local oB = mkBtn("OFF", 10)
oB.TextSize = 16
local ddB = mkBtn("Chase Range: 30", 46)
local hB = mkBtn("Set Home (here)", 82, Color3.fromRGB(0, 130, 0))
local stB = mkBtn("Status: OFF", 118, Color3.fromRGB(40, 40, 40))
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
-- ពិនិត្យថាមានសត្វដេញឬអត់
-- ============================================================
local function checkChase()
    if not H or not H.Parent then return false, nil end
    
    local closest = nil
    local closestDist = chaseDistance
    
    for _, o in pairs(workspace:GetDescendants()) do
        -- ពិនិត្យ Model ដែលមាន Humanoid (សត្វ/NPC)
        if o:IsA("Model") and o ~= LP.Character then
            local hum = o:FindFirstChildOfClass("Humanoid")
            local root = o:FindFirstChild("HumanoidRootPart") or o.PrimaryPart
            
            if hum and root then
                local dist = (root.Position - H.Position).Magnitude
                
                if dist < closestDist then
                    -- ពិនិត្យថាកំពុងដេញ (កំពុងផ្លាស់ទី)
                    local speed = hum.WalkSpeed
                    if speed > 0 then
                        closestDist = dist
                        closest = o
                    end
                end
            end
        end
    end
    
    return closest ~= nil, closest
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
spawn(function()
    while task.wait(0.2) do
        if not on then continue end
        if not H or not H.Parent then continue end

        -- ពិនិត្យថាមានសត្វដេញ
        local isChased, animal = checkChase()

        if isChased then
            local t = tick()
            if t - lastTp > cooldown then
                lastTp = t
                
                local name = animal and animal.Name or "?"
                stB.Text = "Chased by: " .. name
                
                -- Teleport home ភ្លាម
                pcall(function()
                    H.Velocity = Vector3.zero
                    H.AssemblyLinearVelocity = Vector3.zero
                    H.CFrame = home
                end)
                
                print("[NhazX] ត្រូវដេញដោយ: " .. name .. " → Teleport Home")
            end
        else
            stB.Text = "Status: Safe"
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
    if on then
        oB.Text = "ON"
        oB.BackgroundColor3 = Color3.fromRGB(0,180,0)
        bs.Color = Color3.fromRGB(0,255,0)
        stB.Text = "Watching..."
    else
        oB.Text = "OFF"
        oB.BackgroundColor3 = Color3.fromRGB(55,55,55)
        bs.Color = Color3.fromRGB(0,255,200)
        stB.Text = "Status: OFF"
    end
end)

ddB.MouseButton1Click:Connect(function()
    -- ប្តូរចម្ងាយ
    if chaseDistance == 30 then chaseDistance = 15
    elseif chaseDistance == 15 then chaseDistance = 50
    elseif chaseDistance == 50 then chaseDistance = 100
    else chaseDistance = 30 end
    ddB.Text = "Chase Range: " .. chaseDistance
end)

hB.MouseButton1Click:Connect(function()
    home = H.CFrame
    hB.Text = "Saved!"
    task.wait(1)
    hB.Text = "Set Home (here)"
    print("[NhazX] New home: " .. tostring(home.Position))
end)

print("[NhazX v35] Ready | Chase Range: " .. chaseDistance)
