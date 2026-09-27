-- Roblox: Steal an Egg / Steal a Brainrot
-- Credit: script by @nhaz_samurai
-- SAFE MODE: បញ្ចុះល្បឿន + Anti-Kick ស្រាល ជៀសវាងគាំង/ងាប់
-- Paste into executor

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================================================
-- CONFIG (បញ្ចុះដើម្បីជៀស anti-cheat)
-- =========================================================
local CONFIG = {
    Speed       = 60,        -- ធ្លាប់ 250 → បញ្ចុះ 60 (safe)
    Jump        = 60,        -- ធ្លាប់ 100 → បញ្ចុះ 60
    SpeedOn     = false,
    AutoTP      = false,     -- បិទ auto-teleport (បណ្តាលគាំង)
    TPInterval  = 3,
    AntiKick    = true,
}

-- =========================================================
-- ANTI-KICK (safe)
-- =========================================================
if CONFIG.AntiKick then
    pcall(function()
        local mt = getrawmetatable(game)
        if mt and mt.__namecall then
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                if getnamecallmethod() == "Kick" and self == LocalPlayer then
                    return nil
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end
    end)
end

-- =========================================================
-- SPEED (smooth, មិនគាំង)
-- =========================================================
local function applySpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if CONFIG.SpeedOn then
        hum.WalkSpeed = CONFIG.Speed
        hum.JumpPower = CONFIG.Jump
        hum.UseJumpPower = true
    else
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
end

-- កែរៀងរាល់ 1 វិនាទី (ជំនួស 0.2 → ជៀស rate-limit)
task.spawn(function()
    while task.wait(1) do
        if CONFIG.SpeedOn then applySpeed() end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.5)
    applySpeed()
end)

-- =========================================================
-- TREADMILL POSITION
-- =========================================================
local treadmillPos = nil

-- =========================================================
-- DRAGGABLE
-- =========================================================
local function makeDraggable(frame, dragArea)
    dragArea = dragArea or frame
    local dragging, dragStart, startPos

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- =========================================================
-- GUI (safe, មិន animate)
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NhazX"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 55, 0, 55)
MiniBtn.Position = UDim2.new(0.75, 0, 0.25, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(230, 40, 40)
MiniBtn.Text = "N"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 24
MiniBtn.Active = true
MiniBtn.Parent = ScreenGui
local MC = Instance.new("UICorner"); MC.CornerRadius = UDim.new(1, 0); MC.Parent = MiniBtn
local MS = Instance.new("UIStroke"); MS.Color = Color3.fromRGB(255, 255, 255); MS.Thickness = 2; MS.Parent = MiniBtn

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 230, 0, 310)
Panel.Position = UDim2.new(0, 30, 0, 220)
Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Panel.BorderSizePixel = 0
Panel.Visible = false
Panel.Active = true
Panel.Parent = ScreenGui
local PC = Instance.new("UICorner"); PC.CornerRadius = UDim.new(0, 10); PC.Parent = Panel
local PS = Instance.new("UIStroke"); PS.Color = Color3.fromRGB(230, 40, 40); PS.Thickness = 2; PS.Parent = Panel

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 34)
Title.BackgroundColor3 = Color3.fromRGB(230, 40, 40)
Title.Text = "NhazX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Active = true
Title.Parent = Panel
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 10); TC.Parent = Title

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 16)
Credit.Position = UDim2.new(0, 0, 0, 34)
Credit.BackgroundTransparency = 1
Credit.Text = "script by @nhaz_samurai"
Credit.TextColor3 = Color3.fromRGB(180, 180, 180)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 10
Credit.Parent = Panel

local function mkBtn(text, y, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 34)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Parent = Panel
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = b
    b.MouseButton1Click:Connect(cb)
    return b
end

local speedBtn
speedBtn = mkBtn("SPEED: OFF (safe 60)", 58, function()
    CONFIG.SpeedOn = not CONFIG.SpeedOn
    speedBtn.Text = CONFIG.SpeedOn and "SPEED: ON (60)" or "SPEED: OFF (safe 60)"
    speedBtn.BackgroundColor3 = CONFIG.SpeedOn and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(50, 50, 60)
    applySpeed()
end)

mkBtn("SET CURRENT POS", 100, function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        treadmillPos = char.HumanoidRootPart
    end
end)

mkBtn("TELEPORT BACK", 142, function()
    if treadmillPos then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = treadmillPos.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

local autoTPBtn
autoTPBtn = mkBtn("AUTO TP: OFF", 184, function()
    CONFIG.AutoTP = not CONFIG.AutoTP
    autoTPBtn.Text = "AUTO TP: " .. (CONFIG.AutoTP and "ON" or "OFF")
    autoTPBtn.BackgroundColor3 = CONFIG.AutoTP and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(50, 50, 60)
end)

mkBtn("CLOSE", 226, function()
    Panel.Visible = false
end)

MiniBtn.MouseButton1Click:Connect(function()
    Panel.Visible = not Panel.Visible
    MiniBtn.BackgroundColor3 = Panel.Visible and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(230, 40, 40)
end)

makeDraggable(MiniBtn)
makeDraggable(Panel, Title)

-- Auto TP loop (បើបើក)
task.spawn(function()
    while task.wait(CONFIG.TPInterval) do
        if CONFIG.AutoTP and treadmillPos then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = treadmillPos.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "NhazX SAFE",
        Text = "Loaded low-speed mode | @nhaz_samurai",
        Duration = 5
    })
end)
