-- palofsc: NhazX Steal An Egg - v37
-- Teleport មុនពេលស្លាប់ + ជីវិតគ្មានកំណត់ (Godmode)
-- ពេលមេដេញ → teleport Home ភ្លាម
-- បើស្លាប់ → respawn ភ្លាម

print("[NhazX v37] Loading...")

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
local chaseRange = 300
local cooldown = 0.3

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
local gB = mkBtn("Godmode: ON", 46, Color3.fromRGB(0, 130, 0))
local rdB = mkBtn("Range: 300", 82)
local hB = mkBtn("Set Home (here)", 118, Color3.fromRGB(0, 100, 180))
local stB = mkBtn("Status: OFF", 154, Color3.fromRGB(40, 40, 40))
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
-- GODMODE - មិនស្លាប់
-- ============================================================
local godmode = true

local function applyGodmode()
    if not godmode then return end
    if not Ch or not Ch.Parent then return end
    
    pcall(function()
        local hum = Ch:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
        -- បិទ damage
        for _, o in pairs(Ch:GetChildren()) do
            if o:IsA("ForceField") then o:Destroy() end
        end
        -- បន្ថែម ForceField
        if not Ch:FindFirstChild("NhazXShield") then
            local ff = Instance.new("ForceField")
            ff.Name = "NhazXShield"
            ff.Visible = false
            ff.Parent = Ch
        end
    end)
end

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
end

-- ============================================================
-- WATCHER - ចាប់សត្វដេញ
-- ============================================================
local function startWatcher()
    if not H or not H.Parent then return end
    
    if H:FindFirstChild("NhazXWatcher") then
        H.NhazXWatcher:Destroy()
    end
    
    local region = Instance.new("Part")
    region.Name = "NhazXWatcher"
    region.Size = Vector3.new(chaseRange * 2, chaseRange * 2, chaseRange * 2)
    region.Anchored = true
    region.CanCollide = false
    region.Transparency = 1
    region.CanTouch = true
    region.CanQuery = false
    region.Parent = H
    
    region.Touched:Connect(function(hit)
        if not on then return end
        local t = tick()
        if t - lastTp < cooldown then return end
        
        local model = hit:FindFirstAncestorOfClass("Model")
        if not model or model == LP.Character then return end
        
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        -- បើជា player ផ្សេង → មិន teleport
        for _, pl in pairs(P:GetPlayers()) do
            if pl ~= LP and pl.Character == model then
                return
            end
        end
        
        -- ជាសត្វ → teleport home
        lastTp = t
        stB.Text = "Chased: " .. model.Name
        tpHome()
        print("[NhazX] Chased by: " .. model.Name .. " -> Home")
    end)
end

-- ============================================================
-- LOOP ពិនិត្យជីវិត + សត្វជិត
-- ============================================================
spawn(function()
    while task.wait(0.1) do
        if not Ch or not Ch.Parent then continue end
        
        -- Godmode
        if godmode then
            pcall(function()
                local hum = Ch:FindFirstChildOfClass("Humanoid")
                if hum then
                    if hum.Health < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                    end
                end
            end)
        end
        
        if not on then continue end
        if not H or not H.Parent then continue end
        
        -- ពិនិត្យសត្វនៅជិត
        local closest = nil
        local closestDist = chaseRange
        
        for _, o in pairs(workspace:GetDescendants()) do
            if o:IsA("Model") and o ~= Ch then
                local hum = o:FindFirstChildOfClass("Humanoid")
                local root = o:FindFirstChild("HumanoidRootPart") or o.PrimaryPart
                
                if hum and root and hum.Health > 0 then
                    local dist = (root.Position - H.Position).Magnitude
                    if dist < closestDist then
                        -- មិនមែន player
                        local isPl = false
                        for _, pl in pairs(P:GetPlayers()) do
                            if pl.Character == o then isPl = true break end
                        end
                        if not isPl then
                            closestDist = dist
                            closest = o
                        end
                    end
                end
            end
        end
        
        if closest then
            local t = tick()
            if t - lastTp > cooldown then
                lastTp = t
                stB.Text = "Chased: " .. closest.Name
                tpHome()
                print("[NhazX] Chase: " .. closest.Name .. " at " .. math.floor(closestDist))
            end
        end
    end
end)

-- Respawn ភ្លាម
LP.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    Ch = c
    H = c:WaitForChild("HumanoidRootPart")
    Hu = c:WaitForChild("Humanoid")
    applyGodmode()
    -- Teleport ទៅ home ភ្លាមពេល respawn
    if on then
        task.wait(0.3)
        tpHome()
    end
    if on then startWatcher() end
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
        applyGodmode()
        startWatcher()
    else
        oB.Text = "OFF"
        oB.BackgroundColor3 = Color3.fromRGB(55,55,55)
        bs.Color = Color3.fromRGB(0,255,200)
        stB.Text = "Status: OFF"
        if H:FindFirstChild("NhazXWatcher") then
            H.NhazXWatcher:Destroy()
        end
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

rdB.MouseButton1Click:Connect(function()
    if chaseRange == 300 then chaseRange = 100
    elseif chaseRange == 100 then chaseRange = 200
    elseif chaseRange == 200 then chaseRange = 300
    elseif chaseRange == 300 then chaseRange = 500
    else chaseRange = 300 end
    rdB.Text = "Range: " .. chaseRange
    if on then startWatcher() end
end)

hB.MouseButton1Click:Connect(function()
    home = H.CFrame
    hB.Text = "Saved!"
    task.wait(1)
    hB.Text = "Set Home (here)"
    print("[NhazX] Home: " .. tostring(home.Position))
end)

applyGodmode()
print("[NhazX v37] Ready | Godmode + Chase Range: " .. chaseRange)
