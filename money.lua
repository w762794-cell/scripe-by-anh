-- Roblox: Steal an Egg / Steal a Brainrot
-- GUI: NhazX | Credit: script by @nhaz_samurai
-- Auto-target high value pets + Instant claim + Fast fly back
-- Paste into executor (Delta, Fluxus, Solara, Synapse)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- =========================================================
-- CONFIG / ការកំណត់
-- =========================================================
local CONFIG = {
    AutoSteal     = false,
    InstantClaim  = true,
    FlySpeed      = 250,      -- ល្បឿនហោះទៅរក egg
    ReturnSpeed   = 350,      -- ល្បឿនត្រឡប់មកវិញ
    StealRange    = 9999,
    PriorityList  = true,     -- យកតែ egg តម្លៃថ្លៃមុន
    AntiKick      = true,
    LoopDelay     = 0.1,
}

-- =========================================================
-- PRIORITY PETS / របស់តម្លៃថ្លៃ (តាមរូបភាព)
-- =========================================================
local PRIORITY_PETS = {
    -- Divine (ខ្ពស់បំផុត)
    ["Aetheron"]     = 100,
    ["World Burner"] = 99,
    ["ArchAngel"]    = 98,
    ["Kitsune"]      = 97,
    ["Unicorn"]      = 96,
    ["Nightflame"]   = 95,

    -- Eternal
    ["Gorilla King"] = 90,

    -- Cosmic
    ["Triceratops"]  = 85,

    -- Mythic
    ["Ankylosaurus"] = 80,

    -- Legendary
    ["Pterodactyl"]  = 75,

    -- Royal
    ["Orca"]         = 70,
    ["Scorpion"]     = 69,
    ["Royal Sphinx"] = 68,

    -- Rare
    ["Sand Spider"]  = 60,
    ["Owl"]          = 59,

    -- Common
    ["Turtle"]       = 50,
    ["Duckling"]     = 49,
    ["Chicken"]      = 48,
}

-- =========================================================
-- ANTI-KICK / ការពារការបណ្តេញ
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
-- REMOTE CACHE / ចាប់ remote លួច
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
-- GET PET VALUE / រកតម្លៃរបស់
-- =========================================================
local function getPetValue(obj)
    if not obj then return 0 end
    local name = obj.Name

    -- ពិនិត្យឈ្មោះផ្ទាល់
    for petName, value in pairs(PRIORITY_PETS) do
        if name:lower():find(petName:lower()) then
            return value
        end
    end

    -- ពិនិត្យ attribute
    local attr = obj:GetAttribute("PetName") or obj:GetAttribute("Name")
    if attr then
        for petName, value in pairs(PRIORITY_PETS) do
            if tostring(attr):lower():find(petName:lower()) then
                return value
            end
        end
    end

    return 0
end

-- =========================================================
-- GET ALL EGGS with VALUE / រក egg ទាំងអស់តាមតម្លៃ
-- =========================================================
local function getAllEggsSorted()
    local list = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = obj.Name:lower()
            if n:find("egg") or n:find("brainrot") or n:find("pet")
            or n:find("chicken") or n:find("duck") or n:find("turtle")
            or n:find("owl") or n:find("spider") or n:find("sphinx")
            or n:find("scorpion") or n:find("orca") or n:find("ptero")
            or n:find("ankylo") or n:find("trice") or n:find("gorilla")
            or n:find("nightflame") or n:find("unicorn") or n:find("kitsune")
            or n:find("archangel") or n:find("burner") or n:find("aetheron") then
                local value = getPetValue(obj)
                table.insert(list, {obj = obj, value = value})
            end
        end
    end
    -- តម្រៀបតាមតម្លៃខ្ពស់មុន
    if CONFIG.PriorityList then
        table.sort(list, function(a, b) return a.value > b.value end)
    end
    return list
end

-- =========================================================
-- FLY TO TARGET / ហោះទៅរករបស់
-- =========================================================
local function flyTo(targetPart, speed)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if not targetPart then return end

    local hrp = char.HumanoidRootPart
    local startPos = hrp.Position
    local endPos = targetPart.Position + Vector3.new(0, 3, 0)
    local distance = (endPos - startPos).Magnitude
    local duration = distance / speed

    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(endPos, endPos + targetPart.CFrame.LookVector)
    })
    tween:Play()
    tween.Completed:Wait()
end

-- =========================================================
-- INSTANT CLAIM / លួចភ្លាម
-- =========================================================
local function instantClaim(obj)
    if not obj then return end
    local target = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
    if not target then return end

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

    -- ProximityPrompt
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
-- STEAL + FLY BACK / លួច + ហោះត្រឡប់
-- =========================================================
local function stealAndReturn(eggData)
    if not eggData or not eggData.obj then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart
    local originalPos = hrp.CFrame

    local target = eggData.obj:IsA("Model") and (eggData.obj.PrimaryPart or eggData.obj:FindFirstChildWhichIsA("BasePart")) or eggData.obj
    if not target then return end

    -- 1. ហោះទៅរក egg លឿន
    flyTo(target, CONFIG.FlySpeed)

    -- 2. លួច
    instantClaim(eggData.obj)

    -- 3. ហោះត្រឡប់មកវិញលឿន
    local returnTween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
        CFrame = originalPos
    })
    returnTween:Play()
    returnTween.Completed:Wait()
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
Panel.Size = UDim2.new(0, 250, 0, 320)
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
Title.Text = "NhazX | Auto High Value"
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
    b.Size = UDim2.new(1, -20, 0, 32)
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
stealBtn = mkBtn("AUTO HIGH VALUE: OFF", 58, function()
    CONFIG.AutoSteal = not CONFIG.AutoSteal
    stealBtn.Text = "AUTO HIGH VALUE: " .. (CONFIG.AutoSteal and "ON" or "OFF")
    stealBtn.BackgroundColor3 = CONFIG.AutoSteal and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(50, 50, 60)
end)

local priorityBtn
priorityBtn = mkBtn("PRIORITY: ON", 100, function()
    CONFIG.PriorityList = not CONFIG.PriorityList
    priorityBtn.Text = "PRIORITY: " .. (CONFIG.PriorityList and "ON" or "OFF")
    priorityBtn.BackgroundColor3 = CONFIG.PriorityList and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(50, 50, 60)
end)

mkBtn("STEAL HIGHEST NOW", 142, function()
    local list = getAllEggsSorted()
    if list[1] then
        stealAndReturn(list[1])
    end
end)

mkBtn("REFRESH REMOTES", 184, function()
    cacheRemotes()
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

-- =========================================================
-- INIT / ចាប់ផ្តើម
-- =========================================================
cacheRemotes()

task.spawn(function() while task.wait(5) do cacheRemotes() end end)

-- Auto steal loop
task.spawn(function()
    while task.wait(CONFIG.LoopDelay) do
        if CONFIG.AutoSteal then
            local list = getAllEggsSorted()
            if list[1] then
                stealAndReturn(list[1])
            end
        end
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "NhazX",
        Text = "Auto High Value loaded | @nhaz_samurai",
        Duration = 5
    })
end)
