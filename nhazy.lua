-- Roblox: Steal an Egg / Steal a Brainrot
-- GUI: NhazX | Credit: script by @nhaz_samurai
-- Round mini toggle button: ចុច → បើក/បិទ GUI
-- Paste into executor (Delta, Fluxus, Solara, Synapse, etc.)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================================================
-- CONFIG
-- =========================================================
local CONFIG = {
    AutoSteal    = true,
    InstantClaim = true,
    ForceClaim   = true,
    StealRange   = 1000,
    AntiKick     = true,
    AntiLog      = true,
    LoopDelay    = 0.05,
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

-- ===== Round Mini Button (រូបមូលតូច) =====
local MiniBtn = Instance.new("TextButton")
MiniBtn.Name = "MiniBtn"
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

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(1, 0)
MiniCorner.Parent = MiniBtn

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(255, 255, 255)
MiniStroke.Thickness = 2
MiniStroke.Parent = MiniBtn

-- ===== Main Frame (ផ្ទាំង GUI) =====
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 250, 0, 340)
Main.Position = UDim2.new(0, 30, 0, 210)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 60, 60)
Stroke.Thickness = 2
Stroke.Parent = Main

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

-- Close button / ប៊ូតុងបិទ
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

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 18)
Status.Position = UDim2.new(0, 10, 0, 56)
Status.BackgroundTransparency = 1
Status.Text = "Status: idle"
Status.TextColor3 = Color3.fromRGB(120, 255, 120)
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -110)
Scroll.Position = UDim2.new(0, 10, 0, 80)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 280)
Scroll.Parent = Main

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Scroll

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

createToggle("Auto Steal", 1, CONFIG.AutoSteal, function(v) CONFIG.AutoSteal = v end)
createToggle("Instant Claim", 2, CONFIG.InstantClaim, function(v) CONFIG.InstantClaim = v end)
createToggle("Force Claim", 3, CONFIG.ForceClaim, function(v) CONFIG.ForceClaim = v end)
createToggle("Anti Kick", 4, CONFIG.AntiKick, function(v) CONFIG.AntiKick = v end)
createToggle("Anti Log", 5, CONFIG.AntiLog, function(v) CONFIG.AntiLog = v end)

local ManualBtn = Instance.new("TextButton")
ManualBtn.Size = UDim2.new(1, -8, 0, 34)
ManualBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ManualBtn.BorderSizePixel = 0
ManualBtn.Text = "STEAL NOW"
ManualBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ManualBtn.Font = Enum.Font.GothamBold
ManualBtn.TextSize = 13
ManualBtn.LayoutOrder = 6
ManualBtn.Parent = Scroll
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 6); mc.Parent = ManualBtn

ManualBtn.MouseButton1Click:Connect(function()
    Status.Text = "Status: stealing..."
    local eggs = getAllEggs()
    for _, e in ipairs(eggs) do forceClaim(e) end
    Status.Text = "Status: done (" .. #eggs .. ")"
end)

-- ===== Toggle GUI (មូលតូច ↔ ផ្ទាំង) =====
local guiOpen = false
local function toggleGUI()
    guiOpen = not guiOpen
    if guiOpen then
        Main.Visible = true
        Main.Size = UDim2.new(0, 250, 0, 0)
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 250, 0, 340)
        }):Play()
        MiniBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
        MiniBtn.Text = "−"
    else
        local t = TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 250, 0, 0)
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

task.spawn(function()
    while task.wait(3) do cacheRemotes() end
end)

task.spawn(function()
    while task.wait(CONFIG.LoopDelay) do
        if CONFIG.AutoSteal then
            local eggs = getAllEggs()
            for _, e in ipairs(eggs) do
                if CONFIG.InstantClaim then forceClaim(e) end
            end
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NhazX",
    Text = "Loaded | script by @nhaz_samurai",
    Duration = 5
})
