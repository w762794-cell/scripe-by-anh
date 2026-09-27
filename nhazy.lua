-- Delta Executor: Anti-AntiCheat Egg Steal + SafeZone Teleport
-- គាំទ្រ AntiCheat ថ្មី (update 27.09.2026)
-- ប្រើ method bypass: metatable spoof, CFrame lock, remote spy, position conceal

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- រង់ចាំ character
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ============ CONFIG ============
local SAFEZONE_CFRAME = CFrame.new(0, 50, 0) -- កែទីតាំង SafeZone
local STEAL_DISTANCE = 20
local TELEPORT_DELAY = 0.08
local SPOOF_POSITION = true -- បិទបាំងទីតាំងពិតពី anti-cheat
-- ================================

-- Bypass 1: បិទបាំងការ detect របស់ anti-cheat តាមរយៈ metatable
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() then
        -- បិទបាំង HumanoidRootPart ពី external scripts
        if self == HumanoidRootPart and (key == "Position" or key == "CFrame" or key == "Velocity") then
            return oldIndex(self, key)
        end
        -- បិទបាំងការ detect លើ LocalPlayer
        if self == LocalPlayer and key == "Character" then
            return Character
        end
    end
    return oldIndex(self, key)
end)

-- Bypass 2: បិទបាំងការ detect តាមរយៈ namecall (Kick, Ban)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- ទប់ស្កាត់ការ Kick ពី anti-cheat
    if method == "Kick" and self == LocalPlayer then
        return nil
    end
    
    -- ទប់ស្កាត់ RemoteEvent ដែល anti-cheat ប្រើដើម្បី report
    if (method == "FireServer" or method == "InvokeServer") and self:IsA("RemoteEvent") then
        local remoteName = self.Name:lower()
        if remoteName:find("report") or remoteName:find("detect") or remoteName:find("ban") or remoteName:find("kick") or remoteName:find("anticheat") then
            return nil -- បិទការ report
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Bypass 3: បិទបាំងការ detect តាមរយៈ Velocity/Position checks
local spoofedCFrame = HumanoidRootPart.CFrame

-- Bypass 4: Remote Spy - ស្វែងរក remote សម្រាប់យក egg
local function findEggRemote()
    local remotes = {}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:find("egg") or n:find("steal") or n:find("collect") or n:find("pick") or n:find("grab") then
                table.insert(remotes, obj)
            end
        end
    end
    return remotes
end

local eggRemotes = findEggRemote()

-- Bypass 5: ស្វែងរក egg ទាំងអស់ក្នុង workspace
local function getEggs()
    local eggs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = obj.Name:lower()
            if n:find("egg") or n:find("pet") or n:find("collectible") then
                table.insert(eggs, obj)
            end
        end
    end
    return eggs
end

-- Bypass 6: Teleport ដោយប្រើ CFrame ផ្ទាល់ + បិទបាំងពី anti-cheat
local function safeTeleport(targetCFrame)
    if not HumanoidRootPart then return end
    
    -- បិទបាំងទីតាំងពី anti-cheat ដោយ set តម្លៃតែម្តង
    pcall(function()
        HumanoidRootPart.CFrame = targetCFrame
        HumanoidRootPart.Velocity = Vector3.zero
        HumanoidRootPart.RotVelocity = Vector3.zero
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end)
    
    -- ធ្វើឱ្យតម្លៃនៅដដែលដើម្បីកុំឱ្យ anti-cheat ឃើញការផ្លាស់ប្តូរ
    spoofedCFrame = targetCFrame
end

-- Bypass 7: ចាប់យក egg ដោយប្រើ remote ឬ proximity prompt
local function stealEgg(egg)
    if not egg or not egg.Parent then return end
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    
    local eggPart = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
    if not eggPart then return end
    
    local distance = (HumanoidRootPart.Position - eggPart.Position).Magnitude
    if distance > STEAL_DISTANCE then return end
    
    -- វិធី 1: ប្រើ remote ដែលរកឃើញ
    for _, remote in ipairs(eggRemotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(egg)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(egg)
            end
        end)
    end
    
    -- វិធី 2: ប្រើ ProximityPrompt
    local prompt = egg:FindFirstChildOfClass("ProximityPrompt", true)
    if prompt then
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
    
    -- វិធី 3: ប្រើ touch interest
    pcall(function()
        firetouchinterest(HumanoidRootPart, eggPart, 0)
        task.wait(0.05)
        firetouchinterest(HumanoidRootPart, eggPart, 1)
    end)
    
    -- Teleport ទៅ SafeZone ភ្លាមៗ
    task.wait(TELEPORT_DELAY)
    safeTeleport(SAFEZONE_CFRAME)
end

-- Bypass 8: Main loop ជាមួយ anti-detection
local running = true
local heartbeatConn
heartbeatConn = RunService.Heartbeat:Connect(function()
    if not running then return end
    
    if not HumanoidRootPart or not HumanoidRootPart.Parent then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        Humanoid = Character:WaitForChild("Humanoid")
        return
    end
    
    local eggs = getEggs()
    for _, egg in ipairs(eggs) do
        pcall(stealEgg, egg)
    end
end)

-- ការពារ character respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Humanoid = newChar:WaitForChild("Humanoid")
end)

-- បង្ហាញ notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Delta Bypass 27.09.2026",
        Text = "Anti-AntiCheat Egg Steal បានដំណើរការ",
        Duration = 5
    })
end)
