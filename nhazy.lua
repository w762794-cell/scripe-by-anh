-- Delta Executor: Egg Steal + Teleport + Speed + Circle Menu
-- VERSION កែសម្រួល 100% ដំណើរការ
-- ប្រើ loadstring និងការពារ error គ្រប់ជំហាន

-- ============ ការពារ ERROR ទូទៅ ============
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ============ CONFIG ============
local SAFEZONE_CFRAME = CFrame.new(0, 50, 0)
local STEAL_DISTANCE = 15
local TELEPORT_DELAY = 0.15
local CHECK_INTERVAL = 0.1
local SPEED_VALUE = 150
-- ================================

-- ============ WAIT FOR CHARACTER ============
local Character, HumanoidRootPart, Humanoid

local function updateCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
    Humanoid = Character:WaitForChild("Humanoid", 10)
end

updateCharacter()

-- ============ STATE ============
local isEnabled = false
local speedEnabled = false
local stolenEggs = {}
local processingEggs = {}
local eggRemotes = {}
local running = true

-- ============ SCAN REMOTES ============
local function scanRemotes()
    pcall(function()
        eggRemotes = {}
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:find("egg") or n:find("steal") or n:find("collect")
                   or n:find("pick") or n:find("grab") or n:find("claim")
                   or n:find("take") or n:find("hatch") then
                    table.insert(eggRemotes, obj)
                end
            end
        end
    end)
end
scanRemotes()

-- ============ GET EGGS ============
local function getEggs()
    local eggs = {}
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local n = obj.Name:lower()
                if (n:find("egg") or n:find("pet") or n:find("collectible") or n:find("prize"))
                   and not stolenEggs[obj] and not processingEggs[obj] then
                    table.insert(eggs, obj)
                end
            end
        end
    end)
    return eggs
end

-- ============ TRY STEAL ============
local function trySteal(egg)
    local eggPart = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
    if not eggPart then return false end
    
    -- ProximityPrompt
    local prompt = egg:FindFirstChildOfClass("ProximityPrompt", true)
    if not prompt and eggPart then prompt = eggPart:FindFirstChildOfClass("ProximityPrompt") end
    if prompt then
        pcall(function() fireproximityprompt(prompt) end)
    end
    
    -- ClickDetector
    local clickDetector = egg:FindFirstChildOfClass("ClickDetector", true)
    if not clickDetector and eggPart then clickDetector = eggPart:FindFirstChildOfClass("ClickDetector") end
    if clickDetector then
        pcall(function() fireclickdetector(clickDetector) end)
    end
    
    -- Remotes
    for _, remote in ipairs(eggRemotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(egg)
                remote:FireServer(eggPart)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(egg)
                remote:InvokeServer(eggPart)
            end
        end)
    end
    
    -- Touch Interest
    if HumanoidRootPart then
        pcall(function()
            firetouchinterest(HumanoidRootPart, eggPart, 0)
            task.wait(0.05)
            firetouchinterest(HumanoidRootPart, eggPart, 1)
        end)
    end
    
    return true
end

-- ============ TELEPORT ============
local function teleportToSafeZone()
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    pcall(function()
        HumanoidRootPart.CFrame = SAFEZONE_CFRAME
        HumanoidRootPart.Velocity = Vector3.zero
        HumanoidRootPart.RotVelocity = Vector3.zero
    end)
end

-- ============ PROCESS EGG ============
local function processEgg(egg)
    if not isEnabled then return end
    if not egg or not egg.Parent then return end
    if stolenEggs[egg] or processingEggs[egg] then return end
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    
    local eggPart = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
    if not eggPart then return end
    
    local distance = (HumanoidRootPart.Position - eggPart.Position).Magnitude
    if distance > STEAL_DISTANCE then return end
    
    processingEggs[egg] = true
    task.wait(0.05)
    
    if not egg.Parent then
        processingEggs[egg] = nil
        return
    end
    
    trySteal(egg)
    task.wait(TELEPORT_DELAY)
    stolenEggs[egg] = true
    teleportToSafeZone()
    
    processingEggs[egg] = nil
end

-- ============ MAIN LOOP ============
task.spawn(function()
    while running do
        pcall(function()
            if isEnabled then
                if not HumanoidRootPart or not HumanoidRootPart.Parent then
                    updateCharacter()
                end
                
                local eggs = getEggs()
                for _, egg in ipairs(eggs) do
                    task.spawn(function()
                        pcall(processEgg, egg)
                    end)
                end
            end
        end)
        task.wait(CHECK_INTERVAL)
    end
end)

-- ============ SPEED LOOP ============
task.spawn(function()
    while running do
        pcall(function()
            if speedEnabled and Humanoid and Humanoid.Parent then
                Humanoid.WalkSpeed = SPEED_VALUE
                Humanoid.JumpPower = 100
                Humanoid.UseJumpPower = true
            elseif Humanoid and Humanoid.Parent then
                Humanoid.WalkSpeed = 16
                Humanoid.JumpPower = 50
            end
        end)
        task.wait(0.1)
    end
end)

-- ============ CHARACTER RESPAWN ============
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart", 10)
    Humanoid = newChar:WaitForChild("Humanoid", 10)
end)

-- ============ RESCAN REMOTES ============
task.spawn(function()
    while running do
        task.wait(30)
        pcall(scanRemotes)
    end
end)

-- ============ GUI ============
-- លុប GUI ចាស់បើមាន
pcall(function()
    if CoreGui:FindFirstChild("EggStealUI") then
        CoreGui.EggStealUI:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EggStealUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999

-- ព្យាយាម parent ចូល CoreGui
local parented = false
pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
        parented = true
    end
end)

if not parented then
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
            ScreenGui.Parent = CoreGui
            parented = true
        end
    end)
end

if not parented then
    pcall(function()
        ScreenGui.Parent = CoreGui
        parented = true
    end)
end

if not parented then
    pcall(function()
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end)
end

-- ============ FLOATING CIRCLE BUTTON ============
local CircleBtn = Instance.new("TextButton")
CircleBtn.Name = "CircleBtn"
CircleBtn.Size = UDim2.new(0, 60, 0, 60)
CircleBtn.Position = UDim2.new(0, 20, 0.5, -30)
CircleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
CircleBtn.BorderSizePixel = 0
CircleBtn.Text = "E"
CircleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleBtn.TextSize = 24
CircleBtn.Font = Enum.Font.GothamBold
CircleBtn.AutoButtonColor = false
CircleBtn.Active = true
CircleBtn.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = CircleBtn

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(255, 255, 255)
CircleStroke.Thickness = 2
CircleStroke.Parent = CircleBtn

-- ============ MAIN MENU FRAME ============
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 270)
MainFrame.Position = UDim2.new(0, 90, 0.5, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "EGG STEAL MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Close X
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -20, 0, 22)
StatusLabel.Position = UDim2.new(0, 10, 0, 38)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Egg Steal: បិទ"
StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Toggle Egg Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(1, -20, 0, 36)
ToggleBtn.Position = UDim2.new(0, 10, 0, 64)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "បើក Egg Steal"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

-- Save Position Button
local SavePosBtn = Instance.new("TextButton")
SavePosBtn.Name = "SavePosBtn"
SavePosBtn.Size = UDim2.new(1, -20, 0, 32)
SavePosBtn.Position = UDim2.new(0, 10, 0, 106)
SavePosBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
SavePosBtn.BorderSizePixel = 0
SavePosBtn.Text = "រក្សាទុកទីតាំង SafeZone"
SavePosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SavePosBtn.TextSize = 12
SavePosBtn.Font = Enum.Font.GothamBold
SavePosBtn.Parent = MainFrame

local SavePosCorner = Instance.new("UICorner")
SavePosCorner.CornerRadius = UDim.new(0, 8)
SavePosCorner.Parent = SavePosBtn

-- Speed Status Label
local SpeedStatusLabel = Instance.new("TextLabel")
SpeedStatusLabel.Name = "SpeedStatusLabel"
SpeedStatusLabel.Size = UDim2.new(1, -20, 0, 22)
SpeedStatusLabel.Position = UDim2.new(0, 10, 0, 146)
SpeedStatusLabel.BackgroundTransparency = 1
SpeedStatusLabel.Text = "Speed: បិទ"
SpeedStatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
SpeedStatusLabel.TextSize = 13
SpeedStatusLabel.Font = Enum.Font.GothamBold
SpeedStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedStatusLabel.Parent = MainFrame

-- Toggle Speed Button
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Name = "SpeedBtn"
SpeedBtn.Size = UDim2.new(1, -20, 0, 36)
SpeedBtn.Position = UDim2.new(0, 10, 0, 172)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
SpeedBtn.BorderSizePixel = 0
SpeedBtn.Text = "បើក Speed"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.TextSize = 14
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.Parent = MainFrame

local SpeedBtnCorner = Instance.new("UICorner")
SpeedBtnCorner.CornerRadius = UDim.new(0, 8)
SpeedBtnCorner.Parent = SpeedBtn

-- Hint
local HintLabel = Instance.new("TextLabel")
HintLabel.Name = "HintLabel"
HintLabel.Size = UDim2.new(1, -20, 0, 40)
HintLabel.Position = UDim2.new(0, 10, 0, 214)
HintLabel.BackgroundTransparency = 1
HintLabel.Text = "ចុច 'រក្សាទុកទីតាំង' ពេលឈរនៅ SafeZone"
HintLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
HintLabel.TextSize = 11
HintLabel.Font = Enum.Font.Gotham
HintLabel.TextWrapped = true
HintLabel.Parent = MainFrame

-- ============ UPDATE UI ============
local function updateUI()
    if isEnabled then
        StatusLabel.Text = "Egg Steal: បើក"
        StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        ToggleBtn.Text = "បិទ Egg Steal"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    else
        StatusLabel.Text = "Egg Steal: បិទ"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        ToggleBtn.Text = "បើក Egg Steal"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
    if speedEnabled then
        SpeedStatusLabel.Text = "Speed: បើក"
        SpeedStatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        SpeedBtn.Text = "បិទ Speed"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    else
        SpeedStatusLabel.Text = "Speed: បិទ"
        SpeedStatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        SpeedBtn.Text = "បើក Speed"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
    if isEnabled or speedEnabled then
        CircleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    else
        CircleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    end
end

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 2
        })
    end)
end

local function toggleEnabled()
    isEnabled = not isEnabled
    updateUI()
    notify("Egg Steal", isEnabled and "បើកដំណើរការ" or "បិទដំណើរការ")
end

local function toggleSpeed()
    speedEnabled = not speedEnabled
    updateUI()
    notify("Speed", speedEnabled and ("បើក - ល្បឿន " .. SPEED_VALUE) or "បិទ")
end

local function saveCurrentPosition()
    if HumanoidRootPart then
        local pos = HumanoidRootPart.Position
        SAFEZONE_CFRAME = CFrame.new(pos.X, pos.Y, pos.Z)
        notify("SafeZone", string.format("បានរក្សាទុក: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
    end
end

-- ============ SHOW / HIDE MENU ============
local menuOpen = false

local function openMenu()
    menuOpen = true
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 240, 0, 270)
    }):Play()
end

local function closeMenu()
    menuOpen = false
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    tween:Play()
    tween.Completed:Connect(function()
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 240, 0, 270)
    end)
end

-- ============ EVENTS ============
CircleBtn.MouseButton1Click:Connect(function()
    if menuOpen then closeMenu() else openMenu() end
end)

CloseBtn.MouseButton1Click:Connect(closeMenu)
ToggleBtn.MouseButton1Click:Connect(toggleEnabled)
SpeedBtn.MouseButton1Click:Connect(toggleSpeed)
SavePosBtn.MouseButton1Click:Connect(saveCurrentPosition)

-- ============ DRAG TITLE BAR ============
local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ============ DRAG CIRCLE BUTTON ============
local circleDragging, circleDragStart, circleStartPos

CircleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        circleDragging = true
        circleDragStart = input.Position
        circleStartPos = CircleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                circleDragging = false
            end
        end)
    end
end)

CircleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if circleDragging then
            local delta = input.Position - circleDragStart
            CircleBtn.Position = UDim2.new(circleStartPos.X.Scale, circleStartPos.X.Offset + delta.X, circleStartPos.Y.Scale, circleStartPos.Y.Offset + delta.Y)
        end
    end
end)

updateUI()
notify("Script Loaded", "ចុច E ដើម្បីបើក menu")
