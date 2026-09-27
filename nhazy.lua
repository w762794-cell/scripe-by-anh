-- palofsc: NhazX Steal An Egg - v45 FINAL
-- Freeze NPC (កុំឱ្យដេញ) + Teleport ពេលដេញ + ON/OFF
-- Range: unlimited

print("[NhazX v45] Loading...")

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
local lastTp = 0
local cooldown = 2.5
local lastChaseTime = 0
local tpCount = 0
local frozenNPCs = {}

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
f.Size = UDim2.new(0, 185, 0, 200)
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
local fzB = mkBtn("Freeze NPC: OFF", 82, Color3.fromRGB(80, 40, 100))
local rdB = mkBtn("Range: unlimited", 118, Color3.fromRGB(0, 100, 180))
local hB = mkBtn("Set Home (here)", 154, Color3.fromRGB(0, 80, 130))
local stB = mkBtn("Status: OFF", 190, Color3.fromRGB(40, 40, 40))
stB.TextSize = 10

-- Panel ត្រូវធំជាងមុន
f.Size = UDim2.new(0, 185, 0, 240)

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
-- FREEZE NPC
-- ============================================================
local freezeNPCs = false

local function freezeAllNPCs()
    if not freezeNPCs then return end
    pcall(function()
        for _, o in pairs(workspace:GetDescendants()) do
            if o:IsA("Model") and o ~= Ch then
                local hum = o:FindFirstChildOfClass("Humanoid")
                local root = o:FindFirstChild("HumanoidRootPart") or o.PrimaryPart
                
                if hum and root then
                    -- ពិនិត្យថាមិនមែន player
                    local isPl = false
                    for _, pl in pairs(P:GetPlayers()) do
                        if pl.Character == o then isPl = true break end
                    end
                    
                    if not isPl then
                        -- Freeze NPC
                        pcall(function()
                            hum.WalkSpeed = 0
                            hum.JumpPower = 0
                        end)
                        pcall(function()
                            if not frozenNPCs[o] then
                                frozenNPCs[o] = root.Anchored
                            end
                            root.Anchored = true
                        end)
                    end
                end
            end
        end
    end)
end

local function unfreezeAllNPCs()
    pcall(function()
        for npc, wasAnchored in pairs(frozenNPCs) do
            if npc and npc.Parent then
                local hum = npc:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 16
                    hum.JumpPower = 50
                end
                local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                if root then
                    root.Anchored = wasAnchored or false
                end
            end
        end
    end)
    frozenNPCs = {}
end

-- ============================================================
-- ពិនិត្យ NPC ដេញ
-- ============================================================
local function findChaser()
    if not H or not H.Parent then return nil end

    for _, o in pairs(workspace:GetDescendants()) do
        if o:IsA("Model") and o ~= Ch then
            local hum = o:FindFirstChildOfClass("Humanoid")
            local root = o:FindFirstChild("HumanoidRootPart") or o.PrimaryPart

            if hum and root and hum.Health > 0 then
                local isPl = false
                for _, pl in pairs(P:GetPlayers()) do
                    if pl.Character == o then isPl = true break end
                end

                if not isPl then
                    local dist = (root.Position - H.Position).Magnitude
                    local vel = hum.MoveDirection
                    if vel.Magnitude > 0.1 then
                        local toUs = (H.Position - root.Position).Unit
                        local dot = vel.Unit:Dot(toUs)
                        if dot > 0.5 then
                            return o, dist
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- ============================================================
-- TELEPORT
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
-- LOOP
-- ============================================================
spawn(function()
    while task.wait(0.3) do
        if not Ch or not Ch.Parent then continue end

        if godmode then
            pcall(function()
                local hum = Ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end)
        end

        -- Freeze NPC បើបើក
        if freezeNPCs then
            freezeAllNPCs()
        end

        if not on then continue end
        if not H or not H.Parent then continue end

        -- បើ Freeze NPC បើក → មិនត្រូវការ teleport
        if freezeNPCs then
            stB.Text = "NPCs Frozen"
            continue
        end

        local chaser, dist = findChaser()

        if chaser then
            local t = tick()
            if t - lastTp > cooldown then
                lastTp = t
                lastChaseTime = t
                tpCount = tpCount + 1
                stB.Text = "TP #" .. tpCount .. ": " .. chaser.Name
                tpHome()
                print("[NhazX] #" .. tpCount .. " " .. chaser.Name .. " at " .. math.floor(dist))
            end
        else
            if tick() - lastChaseTime > 2 then
                stB.Text = "Watching... (" .. tpCount .. ")"
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
b.MouseButton1Click:Connect(function() f.Visible = not f.Visible end)

oB.MouseButton1Click:Connect(function()
    on = not on
    if on then
        oB.Text = "ON"
        oB.BackgroundColor3 = Color3.fromRGB(0,180,0)
        bs.Color = Color3.fromRGB(0,255,0)
        stB.Text = "Watching..."
        lastChaseTime = 0
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

fzB.MouseButton1Click:Connect(function()
    freezeNPCs = not freezeNPCs
    if freezeNPCs then
        fzB.Text = "Freeze NPC: ON"
        fzB.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        freezeAllNPCs()
        stB.Text = "NPCs Frozen"
    else
        fzB.Text = "Freeze NPC: OFF"
        fzB.BackgroundColor3 = Color3.fromRGB(80, 40, 100)
        unfreezeAllNPCs()
        stB.Text = "NPCs Released"
    end
end)

rdB.MouseButton1Click:Connect(function()
    if rdB.Text == "Range: unlimited" then
        rdB.Text = "Range: 30"
        rdB.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    else
        rdB.Text = "Range: unlimited"
        rdB.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
    end
end)

hB.MouseButton1Click:Connect(function()
    home = H.CFrame
    hB.Text = "Saved!"
    task.wait(1)
    hB.Text = "Set Home (here)"
    print("[NhazX] Home: " .. tostring(home.Position))
end)

applyGodmode()
print("[NhazX v45] Script By @nhaz_samurai")
