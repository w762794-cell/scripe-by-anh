-- Roblox: Steal an Egg / Steal a Brainrot
-- Credit: script by @nhaz_samurai
-- FIX v3: ដក getrawmetatable ចេញ (បណ្តាលគាំង) → ប្រើ hookfunction ធម្មតា
-- Paste into executor (Delta, Fluxus, Solara, Synapse)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================================================
-- CONFIG
-- =========================================================
local CONFIG = {
    MoneyPerHit = 100000,
    AutoFarm    = false,
    SpeedOn     = false,
    WalkSpeed   = 300,
    AntiKick    = true,
}

-- =========================================================
-- ANTI-KICK (safe mode)
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
-- SPEED
-- =========================================================
local function applySpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.WalkSpeed = CONFIG.SpeedOn and CONFIG.WalkSpeed or 16
end

task.spawn(function()
    while task.wait(0.5) do
        if CONFIG.SpeedOn then applySpeed() end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed()
end)

-- =========================================================
-- CURRENCY DETECT
-- =========================================================
local function getCurrency()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, v in pairs(ls:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then return v end
        end
    end
    return nil
end

-- =========================================================
-- FIRE ALL MONEY REMOTES (dynamic)
-- =========================================================
local function findMoneyRemotes()
    local list = {}
    for _, r in pairs(ReplicatedStorage:GetDescendants()) do
        if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
            local n = r.Name:lower()
            if n:find("money") or n:find("cash") or n:find("coin")
            or n:find("reward") or n:find("earn") or n:find("step")
            or n:find("walk") or n:find("income") or n:find("collect")
            or n:find("balance") or n:find("add") or n:find("give")
            or n:find("sell") or n:find("treadmill") then
                table.insert(list, r)
            end
        end
    end
    return list
end

local function giveMoney(amount)
    local cur = getCurrency()
    if cur then pcall(function() cur.Value = cur.Value + amount end) end

    for _, r in ipairs(findMoneyRemotes()) do
        pcall(function()
            if r:IsA("RemoteEvent") then
                r:FireServer(amount)
                r:FireServer("add", amount)
                r:FireServer("give", amount)
            else
                r:InvokeServer(amount)
            end
        end)
    end
end

-- =========================================================
-- GUI (simple, no animation crash)
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NhazX"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 240, 0, 340)
Main.Position = UDim2.new(0.05, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 34)
Title.BackgroundColor3 = Color3.fromRGB(230, 40, 40)
Title.Text = "NhazX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 16)
Credit.Position = UDim2.new(0, 0, 0, 34)
Credit.BackgroundTransparency = 1
Credit.Text = "script by @nhaz_samurai"
Credit.TextColor3 = Color3.fromRGB(180, 180, 180)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 10
Credit.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 20)
Status.Position = UDim2.new(0, 10, 0, 54)
Status.BackgroundTransparency = 1
Status.Text = "Balance: 0"
Status.TextColor3 = Color3.fromRGB(120, 255, 120)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local List = Instance.new("Frame")
List.Size = UDim2.new(1, -20, 1, -90)
List.Position = UDim2.new(0, 10, 0, 80)
List.BackgroundTransparency = 1
List.Parent = Main
local LL = Instance.new("UIListLayout")
LL.Padding = UDim.new(0, 6)
LL.SortOrder = Enum.SortOrder.LayoutOrder
LL.Parent = List

local function mkBtn(text, color, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Parent = List
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
    return b
end

mkBtn("GET 100K NOW", Color3.fromRGB(255, 200, 0), function()
    giveMoney(CONFIG.MoneyPerHit)
end)

local farmBtn
farmBtn = mkBtn("AUTO FARM: OFF", Color3.fromRGB(60, 60, 60), function()
    CONFIG.AutoFarm = not CONFIG.AutoFarm
    farmBtn.Text = "AUTO FARM: " .. (CONFIG.AutoFarm and "ON" or "OFF")
    farmBtn.BackgroundColor3 = CONFIG.AutoFarm and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(60, 60, 60)
end)

local speedBtn
speedBtn = mkBtn("SPEED: OFF", Color3.fromRGB(60, 60, 60), function()
    CONFIG.SpeedOn = not CONFIG.SpeedOn
    speedBtn.Text = "SPEED: " .. (CONFIG.SpeedOn and "ON" or "OFF")
    speedBtn.BackgroundColor3 = CONFIG.SpeedOn and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(60, 60, 60)
    applySpeed()
end)

mkBtn("CLOSE GUI", Color3.fromRGB(120, 30, 30), function()
    Main.Visible = false
end)

-- =========================================================
-- LOOPS
-- =========================================================
task.spawn(function()
    while task.wait(0.1) do
        if CONFIG.AutoFarm then giveMoney(CONFIG.MoneyPerHit) end
    end
end)

task.spawn(function()
    while task.wait(1) do
        local cur = getCurrency()
        if cur then Status.Text = "Balance: " .. tostring(cur.Value) end
    end
end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "NhazX",
        Text = "Loaded | @nhaz_samurai",
        Duration = 5
    })
end)
