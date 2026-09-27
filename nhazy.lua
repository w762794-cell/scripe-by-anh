-- Roblox: Steal an Egg / Steal a Brainrot
-- GUI: NhazX | Credit: script by @nhaz_samurai
-- Auto-claim + Anti-Kick + Anti-Log + Owner bypass
-- Paste into executor (Delta, Fluxus, Solara, Synapse, etc.)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================================================
-- CONFIG / ការកំណត់
-- =========================================================
local CONFIG = {
    AutoSteal   = true,
    StealRange  = 12,
    AntiKick    = true,
    AntiLog     = true,
    LoopDelay   = 0.05,
}

-- =========================================================
-- ANTI-KICK / ការពារការបណ្តេញ
-- =========================================================
local function enableAntiKick()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        if getnamecallmethod() == "Kick" and self == LocalPlayer then
            return nil
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- =========================================================
-- ANTI-LOG / ទប់ស្កាត់ log
-- =========================================================
local function enableAntiLog()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find("log") then
            pcall(function() obj:Destroy() end)
        end
    end
end

-- =========================================================
-- OWNER BYPASS / ឆ្លងកាត់ម្ចាស់
-- =========================================================
local function enableOwnerBypass()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
        if key == "OwnerId" or key == "CreatorId" then
            return LocalPlayer.UserId
        end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)
end

-- =========================================================
-- STEAL LOGIC / តក្កៈលួច
-- =========================================================
local function getNearestEgg()
    local nearest, dist = nil, math.huge
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local root = char.HumanoidRootPart
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("brainrot")) then
            local d = (obj.Position - root.Position).Magnitude
            if d < dist and d <= CONFIG.StealRange then
                nearest, dist = obj, d
            end
        end
    end
    return nearest
end

local function claimEgg(egg)
    if not egg then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    char.HumanoidRootPart.CFrame = egg.CFrame + Vector3.new(0, 2, 0)

    for _, r in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if r:IsA("RemoteEvent") and (r.Name:lower():find("steal") or r.Name:lower():find("claim") or r.Name:lower():find("take")) then
            pcall(function() r:FireServer(egg) end)
        end
    end
    pcall(function()
        egg.Parent = LocalPlayer:FindFirstChild("Backpack") or char
    end)
end

-- =========================================================
-- GUI BUILD / សាងសង់ GUI
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NhazX"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Main Frame / ផ្ទាំងមេ
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 240, 0, 300)
Main.Position = UDim2.new(0, 30, 0, 150)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 60, 60)
Stroke.Thickness = 2
Stroke.Parent = Main

-- Title / ចំណងជើង
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Title.BorderSizePixel = 0
Title.Text = "NhazX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Main
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Credit / ក្រេឌីត
local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 18)
Credit.Position = UDim2.new(0, 0, 0, 36)
Credit.BackgroundTransparency = 1
Credit.Text = "script by @nhaz_samurai"
Credit.TextColor3 = Color3.fromRGB(180, 180, 180)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 11
Credit.Parent = Main

-- ScrollFrame / ផ្ទាំងរមូរ
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -90)
Scroll.Position = UDim2.new(0, 10, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 240)
Scroll.Parent = Main

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Scroll

-- Function to create toggle button / មុខងារបង្កើតប៊ូតុងបើក-បិទ
local function createToggle(name, order, default, callback)
    local Btn = Instance.new("TextButton")
    Btn.Name = name
    Btn.Size = UDim2.new(1, -8, 0, 34)
    Btn.BackgroundColor3 = default and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(45, 45, 50)
    Btn.BorderSizePixel = 0
    Btn.Text = name .. ": " .. (default and "ON" or "OFF")
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 13
    Btn.LayoutOrder = order
    Btn.Parent = Scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = Btn

    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = name .. ": " .. (state and "ON" or "OFF")
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(45, 45, 50)
        }):Play()
        callback(state)
    end)
    return Btn
end

-- Toggles / ប៊ូតុងបើក-បិទ
createToggle("Auto Steal", 1, CONFIG.AutoSteal, function(v) CONFIG.AutoSteal = v end)
createToggle("Anti Kick", 2, CONFIG.AntiKick, function(v) CONFIG.AntiKick = v end)
createToggle("Anti Log", 3, CONFIG.AntiLog, function(v) CONFIG.AntiLog = v end)

-- Range slider label / ស្លាយជួរ
local RangeLabel = Instance.new("TextLabel")
RangeLabel.Size = UDim2.new(1, -8, 0, 24)
RangeLabel.BackgroundTransparency = 1
RangeLabel.Text = "Range: " .. CONFIG.StealRange
RangeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
RangeLabel.Font = Enum.Font.Gotham
RangeLabel.TextSize = 12
RangeLabel.LayoutOrder = 4
RangeLabel.Parent = Scroll

local Slider = Instance.new("TextButton")
Slider.Size = UDim2.new(1, -8, 0, 20)
Slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
Slider.BorderSizePixel = 0
Slider.Text = ""
Slider.LayoutOrder = 5
Slider.Parent = Scroll
local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 4); sc.Parent = Slider

local Fill = Instance.new("Frame")
Fill.Size = UDim2.new(0.3, 0, 1, 0)
Fill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Fill.BorderSizePixel = 0
Fill.Parent = Slider
local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 4); fc.Parent = Fill

local dragging = false
Slider.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local rel = math.clamp((i.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        CONFIG.StealRange = math.floor(rel * 50) + 1
        RangeLabel.Text = "Range: " .. CONFIG.StealRange
    end
end)

-- =========================================================
-- INIT / ចាប់ផ្តើម
-- =========================================================
if CONFIG.AntiKick then enableAntiKick() end
if CONFIG.AntiLog then enableAntiLog() end
enableOwnerBypass()

task.spawn(function()
    while task.wait(CONFIG.LoopDelay) do
        if CONFIG.AutoSteal then
            local egg = getNearestEgg()
            if egg then claimEgg(egg) end
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NhazX",
    Text = "Loaded | script by @nhaz_samurai",
    Duration = 5
})
