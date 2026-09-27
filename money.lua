-- Roblox: Steal an Egg / Steal a Brainrot
-- Credit: script by @nhaz_samurai
-- GUI អូសបាន (draggable) + Speed + Treadmill teleport
-- Paste into executor (Delta, Fluxus, Solara)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================================================
-- SPEED
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
-- FIND TREADMILL
-- =========================================================
local treadmillPos = nil
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        local n = obj.Name:lower()
        if n:find("treadmill") or n:find("walk") or n:find("run") then
            treadmillPos = obj
            break
        end
    end
end

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
-- DRAGGABLE FUNCTION (អូស GUI បាន)
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
-- GUI BUILD
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NhazX"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

-- Mini round button (អូសបាន)
local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 55, 0, 55)
MiniBtn.Position = UDim2.new(0, 30, 0, 150)
MiniBtn.BackgroundColor3 = Color3.fromRGB(230, 40, 40)
MiniBtn.BorderSizePixel = 0
MiniBtn.Text = "N"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 24
MiniBtn.Active = true
MiniBtn.Parent = ScreenGui
local MC = Instance.new("UICorner"); MC.CornerRadius = UDim.new(1, 0); MC.Parent = MiniBtn
local MS = Instance.new("UIStroke"); MS.Color = Color3.fromRGB(255, 255, 255); MS.Thickness = 2; MS.Parent = MiniBtn

-- Main Panel (អូសបាន)
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 230, 0, 300)
Panel.Position = UDim2.new(0, 30, 0, 220)
Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Panel.BorderSizePixel = 0
Panel.Visible = false
Panel.Active = true
Panel.Parent = ScreenGui
local PC = Instance.new("UICorner"); PC.CornerRadius = UDim.new(0, 10); PC.Parent = Panel
local PS = Instance.new("UIStroke"); PS.Color = Color3.fromRGB(230, 40, 40); PS.Thickness = 2; PS.Parent = Panel

-- Title bar (អូសតាម title)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 34)
Title.BackgroundColor3 = Color3.fromRGB(230, 40, 40)
Title.BorderSizePixel = 0
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
    b.Size = UDim2.new(1, -20, 0, 36)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    b.BorderSizePixel = 0
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
speedBtn = mkBtn("SPEED: ON (250)", 60, function()
    if SPEED > 20 then
        SPEED = 16
        speedBtn.Text = "SPEED: OFF (16)"
    else
        SPEED = 250
        speedBtn.Text = "SPEED: ON (250)"
    end
end)

mkBtn("TELEPORT TREADMILL", 105, function()
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

mkBtn("JUMP POWER 100", 195, function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = 100; hum.UseJumpPower = true end
    end
end)

mkBtn("CLOSE", 240, function()
    Panel.Visible = false
end)

-- Toggle panel
MiniBtn.MouseButton1Click:Connect(function()
    Panel.Visible = not Panel.Visible
    MiniBtn.BackgroundColor3 = Panel.Visible and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(230, 40, 40)
end)

-- =========================================================
-- ធ្វើឲ្យអូសបាន
-- =========================================================
makeDraggable(MiniBtn)                  -- អូសរូបមូល
makeDraggable(Panel, Title)             -- អូសតាម title bar

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NhazX",
    Text = "Draggable GUI | @nhaz_samurai",
    Duration = 5
})
