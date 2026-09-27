-- palofsc: Delta Roblox egg steal script + anti-cheat bypass
-- ស្គ្រីបនេះរួមបញ្ចូល bypass សម្រាប់ anti-cheat ថ្មី (update 26.09.2026)
-- ប្រើ hookmetamethod និង property spoofing ដើម្បីលាក់ការកែប្រែ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ============================================================
-- ANTI-CHEAT BYPASS SECTION
-- រក្សាតម្លៃដើមសម្រាប់ property ដែល anti-cheat ពិនិត្យ
-- ============================================================

local originalWalkSpeed = Humanoid.WalkSpeed
local originalJumpPower = Humanoid.JumpPower
local originalCFrame = HumanoidRootPart.CFrame

-- Hook __index និង __newindex ដើម្បីលាក់ការកែប្រែ
local mt = getrawmetatable(game)
local oldIndex = mt.__index
local oldNewIndex = mt.__newindex

setreadonly(mt, false)

mt.__index = newcclosure(function(self, key)
    if self == Humanoid then
        if key == "WalkSpeed" then
            return originalWalkSpeed
        elseif key == "JumpPower" then
            return originalJumpPower
        end
    end
    if self == HumanoidRootPart and key == "CFrame" then
        return originalCFrame
    end
    return oldIndex(self, key)
end)

mt.__newindex = newcclosure(function(self, key, value)
    if self == Humanoid then
        if key == "WalkSpeed" or key == "JumpPower" then
            -- ទទួលយកតម្លៃថ្មីតែក្នុង local ដោយមិនឱ្យ anti-cheat ឃើញ
            oldNewIndex(self, key, value)
            return
        end
    end
    return oldNewIndex(self, key, value)
end)

setreadonly(mt, true)

-- ============================================================
-- TELEPORT និង EGG STEAL
-- ============================================================

-- កំណត់ល្បឿនខ្ពស់បំផុត (នឹងត្រូវបានលាក់ដោយ bypass)
pcall(function()
    Humanoid.WalkSpeed = 9999
    Humanoid.JumpPower = 9999
    Humanoid.UseJumpPower = true
end)

-- មុខងារស្វែងរក egg ទាំងអស់
local function getAllEggs()
    local eggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = string.lower(obj.Name)
            if string.find(name, "egg") then
                table.insert(eggs, obj)
            end
        end
    end
    return eggs
end

-- មុខងារលួច egg ពីចម្ងាយ
local function stealEgg(egg)
    local targetPart
    if egg:IsA("BasePart") then
        targetPart = egg
    elseif egg:IsA("Model") then
        targetPart = egg:FindFirstChildWhichIsA("BasePart")
    end
    if not targetPart then return end

    -- Teleport ដោយបន្ថែម offset តូចដើម្បីកាត់បន្ថយ detection
    local offset = Vector3.new(
        math.random(-2, 2),
        math.random(0, 1),
        math.random(-2, 2)
    )
    
    pcall(function()
        HumanoidRootPart.Velocity = Vector3.zero
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.CFrame = targetPart.CFrame + offset
    end)
    
    task.wait(0.03)

    -- ប្រើ proximity prompt ប្រសិនបើមាន
    for _, prompt in pairs(targetPart:GetChildren()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                fireproximityprompt(prompt)
            end)
        end
    end

    -- ប្រើ firetouchinterest សម្រាប់ egg ដែលត្រូវការ touch
    pcall(function()
        firetouchinterest(HumanoidRootPart, targetPart, 0)
        task.wait(0.01)
        firetouchinterest(HumanoidRootPart, targetPart, 1)
    end)
end

-- រង្វិលជាប់ពេលលួច egg ទាំងអស់
RunService.Heartbeat:Connect(function()
    local eggs = getAllEggs()
    for _, egg in pairs(eggs) do
        pcall(function()
            stealEgg(egg)
        end)
    end
end)

-- រក្សាល្បឿនខ្ពស់ (តម្លៃពិតនឹងត្រូវលាក់ដោយ bypass)
while task.wait(0.1) do
    if Humanoid and Humanoid.Parent then
        pcall(function()
            Humanoid.WalkSpeed = 9999
            Humanoid.JumpPower = 9999
        end)
    else
        Character = LocalPlayer.Character
        if Character then
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            Humanoid = Character:WaitForChild("Humanoid")
        end
    end
end
