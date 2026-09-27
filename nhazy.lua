-- palofsc: Delta Roblox egg steal script v3
-- Speed range: 1K - 999B (randomized per steal)
-- Auto-collect: egg ចូលខ្លួនភ្លាម ដោយមិនបាច់រត់ទៅ safezone
-- Bypass anti-cheat update 26.09.2026 ដោយប្រើ CFrame + network ownership

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ============================================================
-- ANTI-CHEAT BYPASS (ការពារ detection លើ WalkSpeed និង CFrame)
-- ============================================================

local spoofedSpeed = 16
local spoofedCFrame = HumanoidRootPart.CFrame

local mt = getrawmetatable(game)
local oldIndex = mt.__index
local oldNewIndex = mt.__newindex
setreadonly(mt, false)

mt.__index = newcclosure(function(self, key)
    if self == Humanoid and key == "WalkSpeed" then
        return spoofedSpeed
    end
    if self == HumanoidRootPart and key == "CFrame" then
        return spoofedCFrame
    end
    return oldIndex(self, key)
end)

mt.__newindex = newcclosure(function(self, key, value)
    if self == Humanoid and key == "WalkSpeed" then
        oldNewIndex(self, key, value)
        return
    end
    if self == HumanoidRootPart and key == "CFrame" then
        oldNewIndex(self, key, value)
        spoofedCFrame = value
        return
    end
    return oldNewIndex(self, key, value)
end)

setreadonly(mt, true)

-- ============================================================
-- SPEED RANDOMIZER: 1K - 999B
-- ============================================================

local function getRandomSpeed()
    local ranges = {
        {1000, 9999},           -- 1K - 9K
        {10000, 99999},         -- 10K - 99K
        {100000, 999999},       -- 100K - 999K
        {1000000, 9999999},     -- 1M - 9M
        {10000000, 99999999},   -- 10M - 99M
        {100000000, 999999999}, -- 100M - 999M
        {1000000000, 99999999999} -- 1B - 99B
    }
    local pick = ranges[math.random(1, #ranges)]
    return math.random(pick[1], pick[2])
end

-- ============================================================
-- AUTO-COLLECT: បង្ខំ egg ចូលខ្លួនដោយគ្មានរត់
-- ============================================================

local function forceCollect(egg)
    local targetPart
    if egg:IsA("BasePart") then
        targetPart = egg
    elseif egg:IsA("Model") then
        targetPart = egg:FindFirstChildWhichIsA("BasePart") or egg.PrimaryPart
    end
    if not targetPart then return end

    -- បង្ខំ network ownership ទៅ client ដើម្បីគ្រប់គ្រង egg
    pcall(function()
        targetPart:SetNetworkOwner(LocalPlayer)
    end)

    -- Teleport egg មករកយើងផ្ទាល់ (មិនបាច់រត់ទៅរកវា)
    pcall(function()
        targetPart.CFrame = HumanoidRootPart.CFrame
        targetPart.Velocity = Vector3.zero
        targetPart.AssemblyLinearVelocity = Vector3.zero
    end)

    -- បង្កើត touch ដើម្បី trigger collection event
    pcall(function()
        firetouchinterest(HumanoidRootPart, targetPart, 0)
        task.wait(0.01)
        firetouchinterest(HumanoidRootPart, targetPart, 1)
    end)

    -- ប្រើ proximity prompt បើមាន
    for _, prompt in pairs(targetPart:GetChildren()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                fireproximityprompt(prompt)
            end)
        end
    end

    -- ពិនិត្យ remote events ក្នុង egg សម្រាប់ collection
    for _, remote in pairs(targetPart:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            pcall(function()
                remote:FireServer()
            end)
        end
    end
end

-- ============================================================
-- MAIN LOOP
-- ============================================================

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

RunService.Heartbeat:Connect(function()
    local eggs = getAllEggs()
    for _, egg in pairs(eggs) do
        pcall(function()
            forceCollect(egg)
        end)
    end
end)

-- កំណត់ល្បឿនចៃដន្យរាល់ 0.5 វិនាទី (1K - 999B)
task.spawn(function()
    while task.wait(0.5) do
        if Humanoid and Humanoid.Parent then
            local newSpeed = getRandomSpeed()
            pcall(function()
                Humanoid.WalkSpeed = newSpeed
                Humanoid.JumpPower = newSpeed
                Humanoid.UseJumpPower = true
            end)
        else
            Character = LocalPlayer.Character
            if Character then
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                Humanoid = Character:WaitForChild("Humanoid")
            end
        end
    end
end)
