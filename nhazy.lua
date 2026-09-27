-- Delta Executor: Egg Steal + Teleport + GUI Menu (ON/OFF)
-- មាន menu បើក/បិទ ដោយប្រើ Keybind
-- ដំណើរការលើ Delta Executor ជំនាន់ថ្មី

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ============ CONFIG ============
local SAFEZONE_CFRAME = CFrame.new(0, 50, 0)   -- កែទីតាំង SafeZone/កសិដ្ឋាន
local STEAL_DISTANCE = 15
local TELEPORT_DELAY = 0.15
local CHECK_INTERVAL = 0.1
local TOGGLE_KEY = Enum.KeyCode.RightShift  -- ចុច RightShift ដើម្បីបើក/បិទ
-- ================================

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ============ STATE ============
local isEnabled = false
local stolenEggs = {}
local processingEggs = {}
local eggRemotes = {}
local running = true

-- ============ SCAN REMOTES ============
local function scanRemotes()
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
end
scanRemotes()

-- ============ GET EGGS ============
local function getEggs()
    local eggs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = obj.Name:lower()
            if (n:find("egg") or n:find("pet") or n:find("collectible") or n:find("prize"))
               and not stolenEggs[obj] and not processingEggs[obj] then
                table.insert(eggs, obj)
            end
        end
    end
    return eggs
end

-- ============ TRY STEAL ============
local function trySteal(egg)
    local eggPart = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
    if not eggPart then return false end
    
    local success = false
    
    local prompt = egg:FindFirstChildOfClass("ProximityPrompt", true)
    if not prompt and eggPart then prompt = eggPart:FindFirstChildOfClass("ProximityPrompt") end
    if prompt then
        pcall(function() fireproximityprompt(prompt) end)
        success = true
    end
    
    local clickDetector = egg:FindFirstChildOfClass("ClickDetector", true)
    if not clickDetector and eggPart then clickDetector = eggPart:FindFirstChildOfClass("ClickDetector") end
    if clickDetector then
        pcall(function() fireclickdetector(clickDetector) end)
        success = true
    end
    
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
        success = true
    end
    
    if HumanoidRootPart then
        pcall(function()
            firetouchinterest(HumanoidRootPart, eggPart, 0)
            task.wait(0.05)
            firetouchinterest(HumanoidRootPart, eggPart, 1)
        end)
        success = true
    end
    
    return success
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
    
    local attempted = trySteal(egg)
    
    if attempted then
        task.wait(TELEPORT_DELAY)
        stolenEggs[egg] = true
        teleportToSafeZone()
    end
    
    processingEggs[egg] = nil
end

-- ============ MAIN LOOP ============
task.spawn(function()
    while running do
        if isEnabled then
            if not HumanoidRootPart or not HumanoidRootPart.Parent then
                Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            end
            
            local eggs = getEggs()
            for _, egg in ipairs(eggs) do
                task.spawn(function()
                    pcall(processEgg, egg)
                end)
            end
        end
        task.wait(CHECK_INTERVAL)
    end
end)

-- ============ CHARACTER RESPAWN ============
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- ============ RESCAN REMOTES ============
task.spawn(function()
    while running do
        task.wait(30)
        pcall(scanRemotes)
    end
end)

-- ============ GUI MENU ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EggStealMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ប្រើ pcall ដើម្បីធានាថា parent បានត្រឹមត្រូវ
pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
end)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 130)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
Title.BorderSizePixel = 0
Title.Text = "EGG STEAL MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "ស្ថានភាព: បិទ"
StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(1, -20, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 65)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "បើក (ON)"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

-- Hint Label
local HintLabel = Instance.new("TextLabel")
HintLabel.Name = "HintLabel"
HintLabel.Size = UDim2.new(1, -20, 0, 20)
HintLabel.Position = UDim2.new(0, 10, 0, 105)
HintLabel.BackgroundTransparency = 1
HintLabel.Text = "ចុច RightShift ដើម្បីបើក/បិទ"
HintLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
HintLabel.TextSize = 11
HintLabel.Font = Enum.Font.Gotham
HintLabel.Parent = MainFrame

-- ============ TOGGLE FUNCTION ============
local function updateUI()
    if isEnabled then
        StatusLabel.Text = "ស្ថានភាព: បើក"
        StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        ToggleBtn.Text = "បិទ (OFF)"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        UIStroke.Color = Color3.fromRGB(80, 255, 80)
    else
        StatusLabel.Text = "ស្ថានភាព: បិទ"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        ToggleBtn.Text = "បើក (ON)"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        UIStroke.Color = Color3.fromRGB(0, 170, 255)
    end
end

local function toggleEnabled()
    isEnabled = not isEnabled
    updateUI()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Egg Steal",
            Text = isEnabled and "បើកដំណើរការ" or "បិទដំណើរការ",
            Duration = 2
        })
    end)
end

ToggleBtn.MouseButton1Click:Connect(toggleEnabled)

-- ============ KEYBIND ============
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == TOGGLE_KEY then
        toggleEnabled()
    end
end)

-- ============ DRAG SUPPORT FOR MOBILE ============
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
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

MainFrame.InputChanged:Connect(function(input)
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

updateUI()
