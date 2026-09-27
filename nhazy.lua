-- Steal An Egg | Delta Mobile/PC
-- made by seraph

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- ===== CONFIG =====
local FARM_POS = Vector3.new(0, 50, 0) -- ដាក់ទីតាំងកសិដ្ឋានរបស់អ្នក
local SPEED_VALUE = 1e9 -- 1B default
local TELEPORT_ON_STEAL = true

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "SeraphEgg"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 60, 0, 60)
main.Position = UDim2.new(0, 20, 0.5, -30)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BackgroundTransparency = 0.2
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(1, 0)

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, 0, 1, 0)
toggle.BackgroundTransparency = 1
toggle.Text = "🥚"
toggle.TextScaled = true
toggle.Parent = main

-- ម៉ឺនុយរង្វង់មូល
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 220, 0, 220)
menu.Position = UDim2.new(0, 90, 0.5, -110)
menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menuChild.BackgroundTransparency = 0.1
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = gui
Instance.new("UICor("ner", menu).CornerRadius = UDim.new(1, 0)

toggle.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
Humanend)

-- ===== FUNCTIONS =====
local function makeBtn(text, yPos, callback)
    local b = Instance.new("TextButton")
    b.Size =oid UDim2.new(0, 180, 0, 30)
    b.Position = UDim2.new(0.5, -90, 0, yPos)
    b.BackgroundRootColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1, 1, 1Part)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Parent = menu
    Instance.new("UICorner", b).Corner")
Radius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- Steal Egg +    Teleport
local function stealEgg()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirst if not hrp then return end

    -- ស្វែងរក Remote សម្រាប់ steal
    for _, v in pairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = string.lower(v.Name)
            if n:find("steal") or n:find("egg") or n:find("collect") then
                pcall(function()
                    if v:IsA("RemoteEvent") then
                        v:FireServer()
                    else
                        v:InvokeServer()
                    end
                end)
            end
        end
    end

    if TELEPORT_ON_STEAL then
        hrp.CFrame = CFrame.new(FARM_POS)
    end
end

-- Speed
local function setSpeed(val)
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = val
        hum.JumpPower = val
        hum.JumpHeight = val
    end
end

-- ===== MENU BUTTONS =====
makeBtn("🥚 Steal Egg + Teleport", 20, function()
    stealEgg()
end)

makeBtn("⚡ Speed 1B", 60, function()
    SPEED_VALUE = 1e9
    setSpeed(SPEED_VALUE)
end)

makeBtn("⚡ Speed 1Qa", 100, function()
    SPEED_VALUE = 1e15
    setSpeed(SPEED_VALUE)
end)

makeBtn("❌ Close", 150, function()
    menu.Visible = false
end)

-- ===== AUTO LOOP =====
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local char = LP.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char.Humanoid.WalkSpeed = SPEED_VALUE
            end
        end)
    end
end)

LP.CharacterAdded:Connect(function(char)
    task.wait(2)
    setSpeed(SPEED_VALUE)
end)

print("[Seraph] Steal An Egg loaded")
