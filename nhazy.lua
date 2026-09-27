-- Roblox: Steal an Egg / Steal a Brainrot
-- GUI: NhazX | Credit: script by @nhaz_samurai
-- + Speed hack (ល្បឿនដើរ) + Auto-steal + Round mini toggle
-- Paste into executor (Delta, Fluxus, Solara, Synapse, etc.)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================================================
-- CONFIG / ការកំណត់
-- =========================================================
local CONFIG = {
    AutoSteal    = true,
    InstantClaim = true,
    ForceClaim   = true,
    StealRange   = 1000,
    AntiKick     = true,
    AntiLog      = true,
    LoopDelay    = 0.05,

    -- Speed / ល្បឿន
    SpeedEnabled = false,
    WalkSpeed    = 100,   -- default 16
    JumpPower    = 100,   -- default 50
    JumpEnabled  = false,
}

-- =========================================================
-- ANTI-KICK
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
-- ANTI-LOG
-- =========================================================
local function enableAntiLog()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find("log") then
            pcall(function() obj:Destroy() end)
        end
    end
end

-- =========================================================
-- OWNER BYPASS
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
-- SPEED HACK / ល្បឿន
-- =========================================================
local function applySpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if CONFIG.SpeedEnabled then
        hum.WalkSpeed = CONFIG.WalkSpeed
    else
        hum.WalkSpeed = 16
    end

    if CONFIG.JumpEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = CONFIG.JumpPower
    else
        hum.UseJumpPower = true
        hum.JumpPower = 50
    end
end

-- អនុវត្តល្បឿនរៀងរាល់ 0.5 វិនាទី (ការពារ reset ពី game)
task.spawn(function()
    while task.wait(0.5) do
        if CONFIG.SpeedEnabled or CONFIG.JumpEnabled then
            applySpeed()
        end
    end
end)

-- អនុវត្តពេល respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed()
end)

-- =========================================================
-- REMOTE CACHE
-- =========================================================
local StealRemotes = {}
local function cacheRemotes()
    StealRemotes = {}
    local function scan(parent)
        for _, r in pairs(parent:GetDescendants()) do
            if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
                local n = r.Name:lower()
                if n:find("steal") or n:find("claim") or n:find("take")
                or n:find("grab") or n:find("pickup") or n:find("own")
                or n:find("place") or n:find("collect") then
                    table.insert(StealRemotes, r)
                end
            end
        end
    end
    scan(ReplicatedStorage)
    scan(workspace)
    scan(LocalPlayer)
end

-- =========================================================
-- GET ALL EGGS
-- =========================================================
local function getAllEggs()
    local list = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = obj.Name:lower()
            if n:find("egg") or n:find("brainrot") or n:find("pet") then
                table.insert(list, obj)
            end
        end
    end
    return list
end

-- =========================================================
-- FORCE CLAIM
-- =========================================================
local function forceClaim(obj)
    if not obj then return end
    local target = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
    if not target then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    for _, r in pairs(StealRemotes) do
        pcall(function()
            if r:IsA("RemoteEvent") then
                r:FireServer(obj)
                r:FireServer(target)
                r:FireServer(obj, LocalPlayer)
                r:FireServer(target, LocalPlayer.UserId)
            else
                r:InvokeServer(obj)
                r:InvokeServer(target)
            end
        end)
    end

    pcall(function()
        obj:SetAttribute("Owner", LocalPlayer.UserId)
        obj:SetAttribute("OwnerId", LocalPlayer.UserId)
        obj:SetAttribute("Claimed", true)
        obj:SetAttribute("Placed", true)
        target:SetAttribute("Owner", LocalPlayer.UserId)
        target:SetAttribute("OwnerId", LocalPlayer.UserId)
    end)

    pcall(function()
        for _, v in pairs(obj:GetDescendants()) do
            local nm = v.Name:lower()
            if v:IsA("ObjectValue") and (nm:find("owner") or nm:find("creator")) then
                v.Value = LocalPlayer
            elseif (v:IsA("IntValue") or v:IsA("NumberValue")) and (nm:find("owner") or nm:find("creator")) then
                v.Value = LocalPlayer.UserId
            elseif v:IsA("StringValue") and (nm:find("owner") or nm:find("creator")) then
                v.Value = LocalPlayer.Name
            end
        end
    end)

    pcall(function()
        local base = workspace:FindFirstChild(LocalPlayer.Name .. "Base")
            or workspace:FindFirstChild(LocalPlayer.Name)
            or LocalPlayer:FindFirstChild("Backpack")
        if base then obj.Parent = base end
    end)

    pcall(function()
        char.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 2, 0)
    end)

    pcall(function()
        for _, p in pairs(obj:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                p:InputHoldBegin()
                task.wait(0.01)
                p:InputHoldEnd()
            end
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

-- Round mini button
local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 50, 0, 50)
MiniBtn.Position = UDim2.new(0, 30, 0, 150)
MiniBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
MiniBtn.BorderSizePixel = 0
MiniBtn.Text = "N"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 22
MiniBtn.Active = true
MiniBtn.Draggable = true
MiniBtn.Parent = ScreenGui
local MiniCorner = Instance.new("UICorner"); MiniCorner.CornerRadius = UDim.new(1, 0); MiniCorner.Parent = MiniBtn
local MiniStroke = Instance.new("UIStroke"); MiniStroke.Color = Color3.fromRGB(255, 255, 255); MiniStroke.Thickness = 2; MiniStroke.Parent = MiniBtn

-- Main frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 420)
Main.Position = UDim2.new(0, 30, 0, 210)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = ScreenGui
local UICorner = Instance.new("UICorner"); UICorner.CornerRadius = UDim.new(0, 10); UICorner.Parent = Main
local Stroke = Instance.new("UIStroke"); Stroke.Color = Color3.fromRGB(255, 60, 60); Stroke.Thickness = 2; Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Title.BorderSizePixel = 0
Title.Text = "NhazX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Main
local TitleCorner = Instance.new("UICorner"); TitleCorner.CornerRadius = UDim.new(0, 10); TitleCorner.Parent = Title

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.ZIndex = 2
CloseBtn.Parent = Title
local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(1, 0); cc.Parent = CloseBtn

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 18)
Credit.Position = UDim2.new(0, 0, 0, 36)
Credit.BackgroundTransparency = 1
Credit.Text = "script by @nhaz_samurai"
Credit.TextColor3 = Color3.fromRGB(180, 180, 180)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 11
Credit.Parent = Main

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -70)
Scroll.Position = UDim2.new(0, 10, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 420)
Scroll.Parent = Main
local UIListLayout = Instance.new("UIListLayout"); UIListLayout.Padding = UDim.new(0, 6); UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder; UIListLayout.Parent = Scroll

local function createToggle(name, order, default, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -8, 0, 32)
    Btn.BackgroundColor3 = default and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(45, 45, 50)
    Btn.BorderSizePixel = 0
    Btn.Text = name .. ": " .. (default and "ON" or "OFF")
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 12
    Btn.LayoutOrder = order
    Btn.Parent = Scroll
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = Btn
    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = name .. ": " .. (state and "ON" or "OFF")
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(45, 45, 50)
        }):Play()
        callback(state)
    end)
end

-- មុខងារ steal
createToggle("Auto Steal", 1, CONFIG.AutoSteal, function(v) CONFIG.AutoSteal = v end)
createToggle("Instant Claim", 2, CONFIG.InstantClaim, function(v) CONFIG.InstantClaim = v end)
createToggle("Force Claim", 3, CONFIG.ForceClaim, function(v) CONFIG.ForceClaim = v end)
createToggle("Anti Kick", 4, CONFIG.AntiKick, function(v) CONFIG.AntiKick = v end)
createToggle("Anti Log", 5, CONFIG.AntiLog, function(v) CONFIG.AntiLog = v end)

-- មុខងារល្បឿន
createToggle("Speed Hack", 6, CONFIG.SpeedEnabled, function(v)
    CONFIG.SpeedEnabled = v
    applySpeed()
end)
createToggle("Jump Hack", 7, CONFIG.JumpEnabled, function(v)
    CONFIG.JumpEnabled = v
    applySpeed()
end)

-- Slider WalkSpeed
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -8, 0, 22)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed: " .. CONFIG.WalkSpeed
SpeedLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 12
SpeedLabel.LayoutOrder = 8
SpeedLabel.Parent = Scroll

local SpeedSlider = Instance.new("TextButton")
SpeedSlider.Size = UDim2.new(1, -8, 0, 18)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
SpeedSlider.BorderSizePixel = 0
SpeedSlider.Text = ""
SpeedSlider.LayoutOrder = 9
SpeedSlider.Parent = Scroll
local ssc = Instance.new("UICorner"); ssc.CornerRadius = UDim.new(0, 4); ssc.Parent = SpeedSlider
local SpeedFill = Instance.new("Frame")
SpeedFill.Size = UDim2.new(0.2, 0, 1, 0)
SpeedFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
SpeedFill.BorderSizePixel = 0
SpeedFill.Parent = SpeedSlider
local sfc = Instance.new("UICorner"); sfc.CornerRadius = UDim.new(0, 4); sfc.Parent = SpeedFill

-- Slider JumpPower
local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(1, -8, 0, 22)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "JumpPower: " .. CONFIG.JumpPower
JumpLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
JumpLabel.Font = Enum.Font.Gotham
JumpLabel.TextSize = 12
JumpLabel.LayoutOrder = 10
JumpLabel.Parent = Scroll

local JumpSlider = Instance.new("TextButton")
JumpSlider.Size = UDim2.new(1, -8, 0, 18)
JumpSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
JumpSlider.BorderSizePixel = 0
JumpSlider.Text = ""
JumpSlider.LayoutOrder = 11
JumpSlider.Parent = Scroll
local jsc = Instance.new("UICorner"); jsc.CornerRadius = UDim.new(0, 4); jsc.Parent = JumpSlider
local JumpFill = Instance.new("Frame")
JumpFill.Size = UDim2.new(0.5, 0, 1, 0)
JumpFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
JumpFill.BorderSizePixel = 0
JumpFill.Parent = JumpSlider
local jfc = Instance.new("UICorner"); jfc.CornerRadius = UDim.new(0, 4); jfc.Parent = JumpFill

local draggingSpeed, draggingJump = false, false

SpeedSlider.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        draggingSpeed = true
    end
end)
JumpSlider.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        draggingJump = true
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        draggingSpeed, draggingJump = false, false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
    if draggingSpeed then
        local rel = math.clamp((i.Position.X - SpeedSlider.AbsolutePosition.X) / SpeedSlider.AbsoluteSize.X, 0, 1)
        SpeedFill.Size = UDim2.new(rel, 0, 1, 0)
        CONFIG.WalkSpeed = math.floor(rel * 500) + 16
        SpeedLabel.Text = "WalkSpeed: " .. CONFIG.WalkSpeed
        applySpeed()
    elseif draggingJump then
        local rel = math.clamp((i.Position.X - JumpSlider.AbsolutePosition.X) / JumpSlider.AbsoluteSize.X, 0, 1)
        JumpFill.Size = UDim2.new(rel, 0, 1, 0)
        CONFIG.JumpPower = math.floor(rel * 500) + 50
        JumpLabel.Text = "JumpPower: " .. CONFIG.JumpPower
        applySpeed()
    end
end)

-- Manual button
local ManualBtn = Instance.new("TextButton")
ManualBtn.Size = UDim2.new(1, -8, 0, 34)
ManualBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ManualBtn.BorderSizePixel = 0
ManualBtn.Text = "STEAL NOW"
ManualBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ManualBtn.Font = Enum.Font.GothamBold
ManualBtn.TextSize = 13
ManualBtn.LayoutOrder = 12
ManualBtn.Parent = Scroll
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 6); mc.Parent = ManualBtn

ManualBtn.MouseButton1Click:Connect(function()
    local eggs = getAllEggs()
    for _, e in ipairs(eggs) do forceClaim(e) end
end)

-- Toggle GUI
local guiOpen = false
local function toggleGUI()
    guiOpen = not guiOpen
    if guiOpen then
        Main.Visible = true
        Main.Size = UDim2.new(0, 260, 0, 0)
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 260, 0, 420)
        }):Play()
        MiniBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
        MiniBtn.Text = "−"
    else
        local t = TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 260, 0, 0)
        })
        t:Play()
        t.Completed:Connect(function() Main.Visible = false end)
        MiniBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        MiniBtn.Text = "N"
    end
end

MiniBtn.MouseButton1Click:Connect(toggleGUI)
CloseBtn.MouseButton1Click:Connect(function() if guiOpen then toggleGUI() end end)

-- =========================================================
-- INIT
-- =========================================================
if CONFIG.AntiKick then enableAntiKick() end
if CONFIG.AntiLog then enableAntiLog() end
enableOwnerBypass()
cacheRemotes()
applySpeed()

task.spawn(function() while task.wait(3) do cacheRemotes() end end)
task.spawn(function()
    while task.wait(CONFIG.LoopDelay) do
        if CONFIG.AutoSteal then
            for _, e in ipairs(getAllEggs()) do
                if CONFIG.InstantClaim then forceClaim(e) end
            end
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NhazX",
    Text = "Loaded + Speed | script by @nhaz_samurai",
    Duration = 5
})
