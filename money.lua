-- Roblox: Steal an Egg / Steal a Brainrot
-- Credit: script by @nhaz_samurai
-- Steal without chasing (instant) + Aimbot for far steal
-- Paste into executor (Delta, Fluxus, Solara)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- =========================================================
-- CONFIG
-- =========================================================
local CONFIG = {
    AutoSteal     = false,   -- លួចស្វ័យប្រវត្តិ
    InstantClaim  = true,    -- លួចភ្លាម មិនបាច់មេដេញ
    Aimbot        = false,   -- វៃគេឆ្ងាយ
    StealRange    = 9999,    -- ចម្ងាយគ្មានកំណត់
    AimbotRange   = 5000,
    AntiKick      = true,
    LoopDelay     = 0.05,
}

-- =========================================================
-- ANTI-KICK
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
-- REMOTE CACHE (steal/claim/take/grab/pickup)
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
                or n:find("place") or n:find("collect") or n:find("egg") then
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
-- GET ALL EGGS (រករបស់ទាំងអស់)
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
-- INSTANT CLAIM (លួចភ្លាម មិនបាច់មេដេញ)
-- =========================================================
local function instantClaim(obj)
    if not obj then return end
    local target = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
    if not target then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- Fire remotes ទាំងអស់
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

    -- បង្ខំ attribute
    pcall(function()
        obj:SetAttribute("Owner", LocalPlayer.UserId)
        obj:SetAttribute("OwnerId", LocalPlayer.UserId)
        obj:SetAttribute("Claimed", true)
        target:SetAttribute("Owner", LocalPlayer.UserId)
        target:SetAttribute("OwnerId", LocalPlayer.UserId)
    end)

    -- បង្ខំ Value objects
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

    -- បញ្ចូល ProximityPrompt
    pcall(function()
        for _, p in pairs(obj:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                p:InputHoldBegin()
                task.wait(0.01)
                p:InputHoldEnd()
            end
        end
    end)

    -- ទូរទៅរករបស់ (បើ instant មិនកើត)
    if CONFIG.InstantClaim then
        pcall(function()
            char.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 2, 0)
        end)
    end
end

-- =========================================================
-- AIMBOT (វៃគេឆ្ងាយ - Teleport + Steal)
-- =========================================================
local function aimbotSteal(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return end
    local char = targetPlayer.Character
    if not char then return end

    local targetPart = nil
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("brainrot")) then
            targetPart = obj
            break
        end
    end
    if not targetPart then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local owner = obj:FindFirstChild("Owner") or obj:FindFirstChild("OwnerId")
                if owner and ((owner:IsA("ObjectValue") and owner.Value == targetPlayer)
                or (owner:IsA("IntValue") and owner.Value == targetPlayer.UserId)) then
                    targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                    break
                end
            end
        end
    end

    if targetPart then
        instantClaim(targetPart)
    else
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 2, 0)
        end
    end
end

-- =========================================================
-- CLOSEST PLAYER AIMBOT
-- =========================================================
local function getClosestPlayer()
    local closest, dist = nil, CONFIG.AimbotRange
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
            if d < dist then closest, dist = p, d end
        end
    end
    return closest
end

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
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
-- GUI
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
Panel.Size = UDim2.new(0, 240, 0, 360)
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
Title.Text = "NhazX Steal+Aimbot"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
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

local stealBtn
stealBtn = mkBtn("AUTO STEAL: OFF", 58, function()
    CONFIG.AutoSteal = not CONFIG.AutoSteal
    stealBtn.Text = "AUTO STEAL: " .. (CONFIG.AutoSteal and "ON" or "OFF")
    stealBtn.BackgroundColor3 = CONFIG.AutoSteal and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(50, 50, 60)
end)

local aimBtn
aimBtn = mkBtn("AIMBOT: OFF", 100, function()
    CONFIG.Aimbot = not CONFIG.Aimbot
    aimBtn.Text = "AIMBOT: " .. (CONFIG.Aimbot and "ON" or "OFF")
    aimBtn.BackgroundColor3 = CONFIG.Aimbot and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(50, 50, 60)
end)

mkBtn("STEAL ALL NOW", 142, function()
    for _, e in ipairs(getAllEggs()) do instantClaim(e) end
end)

mkBtn("AIMBOT NEAREST PLAYER", 184, function()
    local p = getClosestPlayer()
    if p then aimbotSteal(p) end
end)

mkBtn("REFRESH REMOTES", 226, function()
    cacheRemotes()
end)

mkBtn("CLOSE", 268, function()
    Panel.Visible = false
end)

MiniBtn.MouseButton1Click:Connect(function()
    Panel.Visible = not Panel.Visible
    MiniBtn.BackgroundColor3 = Panel.Visible and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(230, 40, 40)
end)

makeDraggable(MiniBtn)
makeDraggable(Panel, Title)

-- =========================================================
-- LOOPS
-- =========================================================
cacheRemotes()

task.spawn(function() while task.wait(5) do cacheRemotes() end end)

-- Auto Steal
task.spawn(function()
    while task.wait(CONFIG.LoopDelay) do
        if CONFIG.AutoSteal then
            for _, e in ipairs(getAllEggs()) do instantClaim(e) end
        end
    end
end)

-- Aimbot loop
task.spawn(function()
    while task.wait(0.2) do
        if CONFIG.Aimbot then
            local p = getClosestPlayer()
            if p then aimbotSteal(p) end
        end
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "NhazX",
        Text = "Steal + Aimbot loaded | @nhaz_samurai",
        Duration = 5
    })
end)
