-- Roblox: Steal an Egg / Steal a Brainrot
-- Credit: script by @nhaz_samurai
-- FIX: ចាប់ remote ពិតដោយ RemoteSpy + fire ត្រឹមត្រូវ
-- Paste into executor (Delta, Fluxus, Solara, Synapse, etc.)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================================================
-- CONFIG
-- =========================================================
local CONFIG = {
    MoneyPerHit = 100000,
    AutoFarm    = false,
    AntiKick    = true,
    AutoSpy     = true,   -- ស្តាប់ remote ស្វ័យប្រវត្តិ
}

-- =========================================================
-- ANTI-KICK
-- =========================================================
if CONFIG.AntiKick then
    local mt = getrawmetatable(game)
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

-- =========================================================
-- REMOTE SPY / ចាប់ឈ្មោះ remote ពិត
-- =========================================================
local CapturedRemotes = {}   -- [name] = {remote=..., args={...}}

local function startSpy()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" then
            local args = {...}
            local full = self:GetFullName()
            CapturedRemotes[full] = {remote = self, args = args, method = method}
            print("[NhazX Spy]", method, "->", full, "| args:", unpack and unpack(args) or table.unpack(args))
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

if CONFIG.AutoSpy then startSpy() end

-- =========================================================
-- GET CURRENCY (leaderstats + Player + ReplicatedStorage)
-- =========================================================
local function getCurrency()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, v in pairs(ls:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then return v end
        end
    end
    for _, v in pairs(LocalPlayer:GetChildren()) do
        if (v:IsA("IntValue") or v:IsA("NumberValue")) then
            local n = v.Name:lower()
            if n:find("money") or n:find("cash") or n:find("coin")
            or n:find("balance") or n:find("dollar") or n:find("egg") then
                return v
            end
        end
    end
    return nil
end

-- =========================================================
-- GIVE MONEY (client + fire captured remotes)
-- =========================================================
local function giveMoney(amount)
    -- 1. កែ client value
    local cur = getCurrency()
    if cur then pcall(function() cur.Value = cur.Value + amount end) end

    -- 2. Fire remote ដែលចាប់បាន
    for name, data in pairs(CapturedRemotes) do
        local r, args, method = data.remote, data.args, data.method
        pcall(function()
            -- replay ជាមួយ args ដើម និងបន្ថែម amount
            if method == "FireServer" then
                r:FireServer(table.unpack(args))
                r:FireServer(amount)
                r:FireServer("add", amount)
            else
                r:InvokeServer(table.unpack(args))
                r:InvokeServer(amount)
            end
        end)
    end

    -- 3. Scan remote ឈ្មោះពាក់ព័ន្ធលុយ
    for _, r in pairs(ReplicatedStorage:GetDescendants()) do
        if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
            local n = r.Name:lower()
            if n:find("money") or n:find("cash") or n:find("coin")
            or n:find("reward") or n:find("earn") or n:find("step")
            or n:find("walk") or n:find("income") or n:find("collect") then
                pcall(function()
                    if r:IsA("RemoteEvent") then
                        r:FireServer(amount)
                        r:FireServer("add", amount)
                    else
                        r:InvokeServer(amount)
                    end
                end)
            end
        end
    end
end

-- =========================================================
-- GUI
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NhazX"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 50, 0, 50)
MiniBtn.Position = UDim2.new(0, 30, 0, 150)
MiniBtn.BackgroundColor3 = Color3.fromRGB(230, 40, 40)
MiniBtn.Text = "N"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 22
MiniBtn.Active = true
MiniBtn.Draggable = true
MiniBtn.Parent = ScreenGui
local MC = Instance.new("UICorner"); MC.CornerRadius = UDim.new(1, 0); MC.Parent = MiniBtn

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 270, 0, 460)
Main.Position = UDim2.new(0, 30, 0, 200)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = ScreenGui
local UC = Instance.new("UICorner"); UC.CornerRadius = UDim.new(0, 10); UC.Parent = Main
local ST = Instance.new("UIStroke"); ST.Color = Color3.fromRGB(230, 40, 40); ST.Thickness = 2; ST.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(230, 40, 40)
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

local SpyLog = Instance.new("TextLabel")
SpyLog.Size = UDim2.new(1, -20, 0, 40)
SpyLog.Position = UDim2.new(0, 10, 0, 56)
SpyLog.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
SpyLog.Text = "Spy: waiting..."
SpyLog.TextColor3 = Color3.fromRGB(120, 255, 120)
SpyLog.Font = Enum.Font.Code
SpyLog.TextSize = 10
SpyLog.TextWrapped = true
SpyLog.TextXAlignment = Enum.TextXAlignment.Left
SpyLog.Parent = Main
local SLC = Instance.new("UICorner"); SLC.CornerRadius = UDim.new(0, 5); SLC.Parent = SpyLog

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -120)
Scroll.Position = UDim2.new(0, 10, 0, 100)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
Scroll.Parent = Main
local LL = Instance.new("UIListLayout"); LL.Padding = UDim.new(0, 6); LL.SortOrder = Enum.SortOrder.LayoutOrder; LL.Parent = Scroll

local function createBtn(text, color, order, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 36)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.LayoutOrder = order
    b.Parent = Scroll
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = b
    b.MouseButton1Click:Connect(cb)
    return b
end

createBtn("GET 100K NOW", Color3.fromRGB(255, 200, 0), 1, function()
    giveMoney(CONFIG.MoneyPerHit)
end)
createBtn("AUTO FARM 100K", Color3.fromRGB(40, 160, 60), 2, function()
    CONFIG.AutoFarm = not CONFIG.AutoFarm
end)
createBtn("SHOW CAPTURED REMOTES", Color3.fromRGB(60, 60, 120), 3, function()
    local txt = ""
    local i = 0
    for name in pairs(CapturedRemotes) do
        i = i + 1
        txt = txt .. i .. ". " .. name:sub(-40) .. "\n"
        if i >= 8 then break end
    end
    if txt == "" then txt = "none captured yet" end
    SpyLog.Text = txt
end)
createBtn("CLEAR SPY", Color3.fromRGB(120, 40, 40), 4, function()
    CapturedRemotes = {}
    SpyLog.Text = "Spy: cleared"
end)
createBtn("SPEED HACK ON/OFF", Color3.fromRGB(40, 100, 200), 5, function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = (hum.WalkSpeed > 50) and 16 or 300 end
end)

local guiOpen = false
local function toggleGUI()
    guiOpen = not guiOpen
    Main.Visible = guiOpen
    MiniBtn.BackgroundColor3 = guiOpen and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(230, 40, 40)
end
MiniBtn.MouseButton1Click:Connect(toggleGUI)
CloseBtn.MouseButton1Click:Connect(toggleGUI)

-- =========================================================
-- FARM LOOP
-- =========================================================
task.spawn(function()
    while task.wait(0.1) do
        if CONFIG.AutoFarm then giveMoney(CONFIG.MoneyPerHit) end
    end
end)

-- Update spy log រៀងរាល់ 1s
task.spawn(function()
    while task.wait(1) do
        local count = 0
        for _ in pairs(CapturedRemotes) do count = count + 1 end
        if count > 0 then
            SpyLog.Text = "Spy: captured " .. count .. " remotes"
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NhazX",
    Text = "Spy mode ON | script by @nhaz_samurai",
    Duration = 5
})
