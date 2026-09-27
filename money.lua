-- Roblox: Steal an Egg / Steal a Brainrot
-- GUI: NhazX | Credit: script by @nhaz_samurai
-- Money farm 100K per hit + Speed boost for treadmill
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
    MoneyPerHit  = 100000,       -- 100K
    AutoFarm     = false,
    AutoSell     = false,
    AutoCollect  = false,
    FarmDelay    = 0.05,
    AntiKick     = true,

    SpeedEnabled = false,
    WalkSpeed    = 200,
    JumpEnabled  = false,
    JumpPower    = 100,
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
-- SPEED HACK / ល្បឿន
-- =========================================================
local function applySpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.WalkSpeed = CONFIG.SpeedEnabled and CONFIG.WalkSpeed or 16

    if CONFIG.JumpEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = CONFIG.JumpPower
    else
        hum.UseJumpPower = true
        hum.JumpPower = 50
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if CONFIG.SpeedEnabled or CONFIG.JumpEnabled then
            applySpeed()
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed()
end)

-- =========================================================
-- REMOTE CACHE / ចាប់ remote លុយ
-- =========================================================
local MoneyRemotes = {}
local function cacheRemotes()
    MoneyRemotes = {}
    local function scan(parent)
        for _, r in pairs(parent:GetDescendants()) do
            if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
                local n = r.Name:lower()
                if n:find("money") or n:find("cash") or n:find("coin")
                or n:find("sell") or n:find("buy") or n:find("earn")
                or n:find("reward") or n:find("collect") or n:find("income")
                or n:find("claim") or n:find("give") or n:find("add")
                or n:find("step") or n:find("walk") or n:find("treadmill")
                or n:find("speed") or n:find("upgrade") then
                    table.insert(MoneyRemotes, r)
                end
            end
        end
    end
    scan(ReplicatedStorage)
    scan(workspace)
end

-- =========================================================
-- GET CURRENCY / រករបស់លុយ
-- =========================================================
local function getCurrency()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, v in pairs(ls:GetChildren()) do
            local n = v.Name:lower()
            if n:find("money") or n:find("cash") or n:find("coin")
            or n:find("balance") or n:find("dollar") or n:find("brainrot") then
                return v
            end
        end
    end
    for _, v in pairs(LocalPlayer:GetChildren()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            local n = v.Name:lower()
            if n:find("money") or n:find("cash") or n:find("coin") or n:find("balance") then
                return v
            end
        end
    end
    return nil
end

-- =========================================================
-- GIVE MONEY / បន្ថែមលុយ
-- =========================================================
local function giveMoney(amount)
    local cur = getCurrency()
    if cur then
        pcall(function() cur.Value = cur.Value + amount end)
    end

    for _, r in pairs(MoneyRemotes) do
        pcall(function()
            if r:IsA("RemoteEvent") then
                r:FireServer(amount)
                r:FireServer("add", amount)
                r:FireServer("give", amount)
                r:FireServer(LocalPlayer, amount)
                r:FireServer("step", amount)
                r:FireServer("walk", amount)
                r:FireServer("earn", amount)
            else
                r:InvokeServer(amount)
                r:InvokeServer("add", amount)
            end
        end)
    end
end

-- =========================================================
-- AUTO SELL / COLLECT
-- =========================================================
local function autoSellAll()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("egg") or n:find("brainrot") or n:find("pet") then
                for _, r in pairs(MoneyRemotes) do
                    pcall(function()
                        if r:IsA("RemoteEvent") then r:FireServer("sell", obj) end
                    end)
                end
            end
        end
    end
end

local function autoCollect()
    for _, r in pairs(MoneyRemotes) do
        pcall(function()
            if r:IsA("RemoteEvent") then r:FireServer("collect")
            else r:InvokeServer("collect") end
        end)
    end
end

-- =========================================================
-- GUI BUILD
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NhazX"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

-- Round mini button (already visible in your screenshot)
local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 50, 0, 50)
MiniBtn.Position = UDim2.new(0, 30, 0, 150)
MiniBtn.BackgroundColor3 = Color3.fromRGB(230, 40, 40)
MiniBtn.BorderSizePixel = 0
MiniBtn.Text = "N"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 22
MiniBtn.Active = true
MiniBtn.Draggable = true
MiniBtn.Parent = ScreenGui
local MC = Instance.new("UICorner"); MC.CornerRadius = UDim.new(1, 0); MC.Parent = MiniBtn
local MS = Instance.new("UIStroke"); MS.Color = Color3.fromRGB(255, 255, 255); MS.Thickness = 2; MS.Parent = MiniBtn

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 430)
Main.Position = UDim2.new(0, 30, 0, 210)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = ScreenGui
local UC = Instance.new("UICorner"); UC.CornerRadius = UDim.new(0, 10); UC.Parent = Main
local ST = Instance.new("UIStroke"); ST.Color = Color3.fromRGB(255, 60, 60); ST.Thickness = 2; ST.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(230, 40, 40)
Title.BorderSizePixel = 0
Title.Text = "NhazX | Money+Speed"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Main
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 10); TC.Parent = Title

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.ZIndex = 2
CloseBtn.Parent = Title
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(1, 0); CC.Parent = CloseBtn

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
Status.Size = UDim2.new(1, -20, 0, 20)
Status.Position = UDim2.new(0, 10, 0, 56)
Status.BackgroundTransparency = 1
Status.Text = "Balance: 0"
Status.TextColor3 = Color3.fromRGB(120, 255, 120)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -100)
Scroll.Position = UDim2.new(0, 10, 0, 80)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 420)
Scroll.Parent = Main
local LL = Instance.new("UIListLayout"); LL.Padding = UDim.new(0, 6); LL.SortOrder = Enum.SortOrder.LayoutOrder; LL.Parent = Scroll

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

createToggle("Auto Farm 100K", 1, CONFIG.AutoFarm, function(v) CONFIG.AutoFarm = v end)
createToggle("Auto Sell All", 2, CONFIG.AutoSell, function(v) CONFIG.AutoSell = v end)
createToggle("Auto Collect", 3, CONFIG.AutoCollect, function(v) CONFIG.AutoCollect = v end)
createToggle("Speed Hack (Treadmill)", 4, CONFIG.SpeedEnabled, function(v)
    CONFIG.SpeedEnabled = v; applySpeed()
end)
createToggle("Jump Hack", 5, CONFIG.JumpEnabled, function(v)
    CONFIG.JumpEnabled = v; applySpeed()
end)
createToggle("Anti Kick", 6, CONFIG.AntiKick, function(v) CONFIG.AntiKick = v end)

-- Slider Speed
local SLabel = Instance.new("TextLabel")
SLabel.Size = UDim2.new(1, -8, 0, 20)
SLabel.BackgroundTransparency = 1
SLabel.Text = "WalkSpeed: " .. CONFIG.WalkSpeed
SLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
SLabel.Font = Enum.Font.Gotham
SLabel.TextSize = 11
SLabel.LayoutOrder = 7
SLabel.Parent = Scroll

local SSlider = Instance.new("TextButton")
SSlider.Size = UDim2.new(1, -8, 0, 16)
SSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
SSlider.BorderSizePixel = 0
SSlider.Text = ""
SSlider.LayoutOrder = 8
SSlider.Parent = Scroll
local SSC = Instance.new("UICorner"); SSC.CornerRadius = UDim.new(0, 4); SSC.Parent = SSlider
local SFill = Instance.new("Frame")
SFill.Size = UDim2.new(0.37, 0, 1, 0)
SFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
SFill.BorderSizePixel = 0
SFill.Parent = SSlider
local SFC = Instance.new("UICorner"); SFC.CornerRadius = UDim.new(0, 4); SFC.Parent = SFill

-- Button: Give 100K
local GiveBtn = Instance.new("TextButton")
GiveBtn.Size = UDim2.new(1, -8, 0, 42)
GiveBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
GiveBtn.BorderSizePixel = 0
GiveBtn.Text = "GET 100K NOW"
GiveBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
GiveBtn.Font = Enum.Font.GothamBold
GiveBtn.TextSize = 14
GiveBtn.LayoutOrder = 9
GiveBtn.Parent = Scroll
local GBC = Instance.new("UICorner"); GBC.CornerRadius = UDim.new(0, 6); GBC.Parent = GiveBtn

GiveBtn.MouseButton1Click:Connect(function()
    giveMoney(CONFIG.MoneyPerHit)
    Status.Text = "Balance: " .. tostring(CONFIG.MoneyPerHit)
end)

-- Button: Sell
local SellBtn = Instance.new("TextButton")
SellBtn.Size = UDim2.new(1, -8, 0, 34)
SellBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 30)
SellBtn.BorderSizePixel = 0
SellBtn.Text = "SELL ALL NOW"
SellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SellBtn.Font = Enum.Font.GothamBold
SellBtn.TextSize = 13
SellBtn.LayoutOrder = 10
SellBtn.Parent = Scroll
local SBC = Instance.new("UICorner"); SBC.CornerRadius = UDim.new(0, 6); SBC.Parent = SellBtn

SellBtn.MouseButton1Click:Connect(function()
    autoSellAll(); autoCollect()
end)

-- Slider events
local dragSpeed = false
SSlider.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragSpeed = true
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragSpeed = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragSpeed and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local rel = math.clamp((i.Position.X - SSlider.AbsolutePosition.X) / SSlider.AbsoluteSize.X, 0, 1)
        SFill.Size = UDim2.new(rel, 0, 1, 0)
        CONFIG.WalkSpeed = math.floor(rel * 500) + 16
        SLabel.Text = "WalkSpeed: " .. CONFIG.WalkSpeed
        applySpeed()
    end
end)

-- Toggle GUI
local guiOpen = false
local function toggleGUI()
    guiOpen = not guiOpen
    if guiOpen then
        Main.Visible = true
        Main.Size = UDim2.new(0, 260, 0, 0)
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 260, 0, 430)
        }):Play()
        MiniBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
        MiniBtn.Text = "−"
    else
        local t = TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 260, 0, 0)
        })
        t:Play()
        t.Completed:Connect(function() Main.Visible = false end)
        MiniBtn.BackgroundColor3 = Color3.fromRGB(230, 40, 40)
        MiniBtn.Text = "N"
    end
end

MiniBtn.MouseButton1Click:Connect(toggleGUI)
CloseBtn.MouseButton1Click:Connect(function() if guiOpen then toggleGUI() end end)

-- =========================================================
-- INIT
-- =========================================================
if CONFIG.AntiKick then enableAntiKick() end
cacheRemotes()
applySpeed()

task.spawn(function() while task.wait(5) do cacheRemotes() end end)

task.spawn(function()
    while task.wait(1) do
        local cur = getCurrency()
        if cur then Status.Text = "Balance: " .. tostring(cur.Value) end
    end
end)

task.spawn(function()
    while task.wait(CONFIG.FarmDelay) do
        if CONFIG.AutoFarm then giveMoney(CONFIG.MoneyPerHit) end
        if CONFIG.AutoSell then autoSellAll() end
        if CONFIG.AutoCollect then autoCollect() end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NhazX",
    Text = "100K Farm + Speed | script by @nhaz_samurai",
    Duration = 5
})
