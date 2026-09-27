-- palofsc: NhazX SIMPLE v22
-- តូចបំផុត ធានាដំណើរការ

local P = game:GetService("Players")
local R = game:GetService("ReplicatedStorage")
local S = game:GetService("RunService")

local LP = P.LocalPlayer
local Ch = LP.Character or LP.CharacterAdded:Wait()
local H = Ch:WaitForChild("HumanoidRootPart")
local Hu = Ch:WaitForChild("Humanoid")
local PG = LP:WaitForChild("PlayerGui")

local on = false
local auto = false
local spd = 100
local home = H.CFrame
local rem = {}

for _, r in pairs(R:GetDescendants()) do
    if r:IsA("RemoteEvent") then
        local n = string.lower(r.Name)
        if n:find("collect") or n:find("steal") or n:find("grab") or n:find("egg") or n:find("claim") then
            table.insert(rem, r)
        end
    end
end

if PG:FindFirstChild("NhazX") then PG.NhazX:Destroy() end

local g = Instance.new("ScreenGui")
g.Name = "NhazX"
g.ResetOnSpawn = false
g.Parent = PG

local b = Instance.new("TextButton")
b.Size = UDim2.new(0, 55, 0, 55)
b.Position = UDim2.new(0, 20, 0, 200)
b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
b.Text = "N"
b.TextColor3 = Color3.fromRGB(0, 255, 200)
b.TextSize = 28
b.Font = Enum.Font.GothamBold
b.BorderSizePixel = 0
b.Draggable = true
b.Parent = g
local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(1,0) bc.Parent = b
local bs = Instance.new("UIStroke") bs.Color = Color3.fromRGB(0,255,200) bs.Thickness = 2 bs.Parent = b

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 175, 0, 220)
f.Position = UDim2.new(0, 85, 0, 200)
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
    x.Size = UDim2.new(0, 145, 0, 28)
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
local aB = btn("Auto: OFF", 68)
local sB = btn("Speed: 100", 102)
local hB = btn("Set Home (here)", 136, Color3.fromRGB(0, 130, 0))
local rB = btn("Remotes: "..#rem, 170, Color3.fromRGB(40, 40, 40))

local function findEgg()
    for _, o in pairs(workspace:GetDescendants()) do
        if (o:IsA("BasePart") or o:IsA("Model")) and string.find(string.lower(o.Name), "egg") then
            if o:IsA("BasePart") then return o end
            local p = o:FindFirstChildWhichIsA("BasePart")
            if p then return p end
        end
    end
    return nil
end

local function doSteal()
    local e = findEgg()
    if not e then return end
    if not H or not H.Parent then return end

    local hp = home
    pcall(function() H.CFrame = CFrame.new(e.Position + Vector3.new(0, 2, 0)) end)
    task.wait(0.1)

    for _, c in pairs(e:GetChildren()) do
        if c:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(c, 0) end)
        elseif c:IsA("ClickDetector") then
            pcall(function() fireclickdetector(c) end)
        end
    end

    pcall(function()
        firetouchinterest(H, e, 0)
        task.wait(0.02)
        firetouchinterest(H, e, 1)
    end)

    for _, r in pairs(rem) do
        pcall(function()
            r:FireServer(e)
            r:FireServer(e.Name)
        end)
    end

    task.wait(0.15)
    if hp then
        pcall(function() H.CFrame = hp end)
    end
end

local last = 0

S.Heartbeat:Connect(function()
    if not on then return end
    pcall(function() Hu.WalkSpeed = spd end)
    if auto then
        local n = tick()
        if n - last >= 1.5 then
            last = n
            pcall(doSteal)
        end
    end
end)

LP.CharacterAdded:Connect(function(c)
    task.wait(1)
    Ch = c
    H = c:WaitForChild("HumanoidRootPart")
    Hu = c:WaitForChild("Humanoid")
end)

b.MouseButton1Click:Connect(function() f.Visible = not f.Visible end)

oB.MouseButton1Click:Connect(function()
    on = not on
    oB.Text = on and "ON" or "OFF"
    oB.BackgroundColor3 = on and Color3.fromRGB(0,180,0) or Color3.fromRGB(55,55,55)
    bs.Color = on and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,255,200)
end)

aB.MouseButton1Click:Connect(function()
    auto = not auto
    aB.Text = auto and "Auto: ON" or "Auto: OFF"
    aB.BackgroundColor3 = auto and Color3.fromRGB(0,180,0) or Color3.fromRGB(55,55,55)
end)

sB.MouseButton1Click:Connect(function()
    if spd == 100 then spd = 200
    elseif spd == 200 then spd = 500
    elseif spd == 500 then spd = 1000
    else spd = 100 end
    sB.Text = "Speed: "..spd
end)

hB.MouseButton1Click:Connect(function()
    home = H.CFrame
    hB.Text = "Home Saved!"
    task.wait(1)
    hB.Text = "Set Home (here)"
end)

print("[NhazX v22] Remotes: "..#rem)
