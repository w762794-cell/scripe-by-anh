-- Roblox: Steal an Egg / Steal a Brainrot
-- Credit: script by @nhaz_samurai
-- Simple autofarm treadmill + speed
-- Paste into executor (Delta, Fluxus, Solara)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- =========================================================
-- SPEED (រត់លើ treadmill លឿន → +2 ច្រើន → លុយកើន)
-- =========================================================
local SPEED = 250

task.spawn(function()
    while task.wait(0.3) do
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = SPEED
                hum.JumpPower = 100
                hum.UseJumpPower = true
            end
        end
    end
end)

-- =========================================================
-- AUTO REJOIN TREADMILL (ត្រឡប់ទៅ treadmill វិញ)
-- =========================================================
local treadmillPos = nil

-- រក treadmill ក្នុង workspace
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        local n = obj.Name:lower()
        if n:find("treadmill") or n:find("walk") or n:find("run") then
            treadmillPos = obj
            break
        end
    end
end

-- បើរកមិនឃើញ តាមឈ្មោះ → រកតាម part ដែលនៅក្រោមជើង
if not treadmillPos then
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Size.Y < 3 and obj.Size.X > 5 then
            treadmillPos = obj
            break
        end
    end
end

-- Teleport ទៅ treadmill រៀងរាល់ 2 វិនាទី (ការពាររអិលចេញ)
if treadmillPos then
    task.spawn(function()
        while task.wait(2) do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = treadmillPos.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end)
end

-- =========================================================
-- GUI (តូច សាមញ្ញ)
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NhazX"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0, 60, 0, 60)
Btn.Position = UDim2.new(0, 30, 0, 150)
Btn.BackgroundColor3 = Color3.fromRGB(230, 40, 40)
Btn.Text = "N"
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 26
Btn.Draggable = true
Btn.Parent = ScreenGui
local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(1, 0); C.Parent = Btn

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 220, 0, 260)
Panel.Position = UDim2.new(0, 30, 0, 220)
Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Panel.Visible = false
Panel.Draggable = true
Panel.Parent = ScreenGui
local PC = Instance.new("UICorner"); PC.CornerRadius = UDim.new(0, 10); PC.Parent = Panel

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundColor3 = Color3.fromRGB(230, 40, 40)
Title.Text = "NhazX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Panel
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 10); TC.Parent = Title

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 16)
Credit.Position = UDim2.new(0, 0, 0, 32)
Credit.BackgroundTransparency = 1
Credit.Text = "script by @nhaz_samurai"
Credit.TextColor3 = Color3.fromRGB(180, 180, 180)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 10
Credit.Parent = Panel

local function mkBtn(text, y, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 36)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Parent = Panel
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = b
    b.MouseButton1Click:Connect(cb)
    return b
end

local speedBtn
speedBtn = mkBtn("SPEED: ON", 60, function()
    if SPEED > 20 then
        SPEED = 16
        speedBtn.Text = "SPEED: OFF"
    else
        SPEED = 250
        speedBtn.Text = "SPEED: ON"
    end
end)

local tpBtn = mkBtn("TELEPORT TREADMILL", 105, function()
    if treadmillPos then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = treadmillPos.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

mkBtn("FIND TREADMILL", 150, function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("treadmill") or n:find("walk") or n:find("run") then
                treadmillPos = obj
                break
            end
        end
    end
end)

mkBtn("CLOSE", 195, function()
    Panel.Visible = false
end)

-- Toggle
Btn.MouseButton1Click:Connect(function()
    Panel.Visible = not Panel.Visible
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NhazX",
    Text = "Speed + Treadmill | @nhaz_samurai",
    Duration = 5
})
