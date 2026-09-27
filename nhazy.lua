-- palofsc: NhazX UNIVERSAL - មិនត្រូវការឈ្មោះ egg
-- ពេលកាន់ Tool អ្វីក៏ដោយ (លើកលែង tool ដើម) → teleport Home ភ្លាម
-- ដំណើរការគ្រប់ game steal egg

local P = game:GetService("Players")
local S = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = P.LocalPlayer
local Ch = LP.Character or LP.CharacterAdded:Wait()
local H = Ch:WaitForChild("HumanoidRootPart")
local PG = LP:WaitForChild("PlayerGui")

local on = false
local home = H.CFrame
local lastCount = 0
local lastTp = 0
local baselineTools = {}

print("[NhazX] Home: " .. tostring(home.Position))

-- NetworkOwner
pcall(function()
    if H:GetNetworkOwner() ~= LP then
        H:SetNetworkOwner(LP)
    end
end)

-- កត់ត្រា tool ដើម (មុនពេលចាប់ផ្ដើម)
local function recordBaseline()
    baselineTools = {}
    local c = LP.Character
    if c then
        for _, o in pairs(c:GetChildren()) do
            if o:IsA("Tool") then
                baselineTools[o.Name] = true
            end
        end
    end
end

recordBaseline()

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
f.Size = UDim2.new(0, 170, 0, 130)
f.Position = UDim2.new(0, 85, 0.3, 0)
f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
f.BorderSizePixel = 0
f.Visible = false
f.Parent = g
local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0,14) fc.Parent = f
local fs = Instance.new("UIStroke") fs.Color = Color3.fromRGB(0,255,200) fs.Thickness = 1.5 fs.Parent = f

local ti = Instance.new("TextLabel")
ti.Size = UDim2.new(1, 0, 0, 24)
ti.Position = UDim2.new(0, 0, 0, 4)
ti.BackgroundTransparency = 1
ti.Text = "NhazX"
ti.TextColor3 = Color3.fromRGB(0, 255, 200)
ti.Font = Enum.Font.GothamBold
ti.TextSize = 17
ti.Parent = f

local oB = Instance.new("TextButton")
oB.Size = UDim2.new(0, 140, 0, 34)
oB.Position = UDim2.new(0, 15, 0, 34)
oB.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
oB.Text = "OFF"
oB.TextColor3 = Color3.fromRGB(255, 255, 255)
oB.Font = Enum.Font.GothamBold
oB.TextSize = 16
oB.BorderSizePixel = 0
oB.Parent = f
local oc = Instance.new("UICorner") oc.CornerRadius = UDim.new(0,8) oc.Parent = oB

local hB = Instance.new("TextButton")
hB.Size = UDim2.new(0, 140, 0, 26)
hB.Position = UDim2.new(0, 15, 0, 76)
hB.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
hB.Text = "Set Home (here)"
hB.TextColor3 = Color3.fromRGB(255, 255, 255)
hB.Font = Enum.Font.GothamBold
hB.TextSize = 12
hB.BorderSizePixel = 0
hB.Parent = f
local hc = Instance.new("UICorner") hc.CornerRadius = UDim.new(0,8) hc.Parent = hB

-- អូស GUI
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
-- រាប់ចំនួន Tool ក្នុង Character (គ្មានឈ្មោះ)
-- ============================================================
local function countTools()
    local c = LP.Character
    if not c then return 0 end
    local count = 0
    for _, o in pairs(c:GetChildren()) do
        if o:IsA("Tool") then
            count = count + 1
        end
    end
    return count
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
spawn(function()
    while task.wait(0.15) do
        if not on then continue end
        if not H or not H.Parent then continue end

        local count = countTools()

        -- បើចំនួន tool កើនឡើង → មានអ្វីថ្មី (egg)
        if count > lastCount then
            local t = tick()
            if t - lastTp > 1 then
                lastTp = t

                pcall(function()
                    if H:GetNetworkOwner() ~= LP then
                        H:SetNetworkOwner(LP)
                    end
                end)

                pcall(function()
                    H.Velocity = Vector3.zero
                    H.AssemblyLinearVelocity = Vector3.zero
                    H.CFrame = home
                end)

                print("[NhazX] Tool ថ្មី → Teleport Home | Count: " .. count)
            end
        end

        lastCount = count
    end
end)

-- NetworkOwner loop
spawn(function()
    while task.wait(2) do
        pcall(function()
            if H and H.Parent and H:GetNetworkOwner() ~= LP then
                H:SetNetworkOwner(LP)
            end
        end)
    end
end)

LP.CharacterAdded:Connect(function(c)
    task.wait(1)
    Ch = c
    H = c:WaitForChild("HumanoidRootPart")
    pcall(function() H:SetNetworkOwner(LP) end)
    lastCount = 0
    recordBaseline()
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
    if on then
        lastCount = countTools()
    end
end)

hB.MouseButton1Click:Connect(function()
    home = H.CFrame
    hB.Text = "Home Saved!"
    task.wait(1)
    hB.Text = "Set Home (here)"
    print("[NhazX] New home: " .. tostring(home.Position))
end)

-- កត់ត្រា baseline ចាប់ផ្ដើម
lastCount = countTools()

print("[NhazX] Ready | Tools: " .. lastCount)
