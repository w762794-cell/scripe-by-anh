-- Delta Executor script: Steal Egg + Teleport to SafeZone
-- បង្កើតឡើងសម្រាប់ Delta Executor (Roblox)
-- សូមប្រើនៅក្នុងហ្គេមដែលមាន Egg Stealing mechanic និង SafeZone

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- កំណត់ SafeZone CFrame (ត្រូវកែទីតាំងតាមហ្គេមរបស់អ្នក)
local SAFEZONE_CFRAME = CFrame.new(0, 50, 0)

-- ចម្ងាយអប្បបរមាសម្រាប់ការចាប់យក Egg
local STEAL_DISTANCE = 15

-- បិទមុខងារ teleport ដើម្បីការពារ interference
local function getEggs()
    local eggs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("pet")) then
            table.insert(eggs, obj)
        end
    end
    return eggs
end

-- មុខងារ teleport ទៅ SafeZone
local function teleportToSafeZone()
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = SAFEZONE_CFRAME
        HumanoidRootPart.Velocity = Vector3.zero
        HumanoidRootPart.RotVelocity = Vector3.zero
    end
end

-- មុខងារចាប់យក Egg និង teleport
local function stealEgg(egg)
    if not egg or not egg.Parent then return end
    if not HumanoidRootPart then return end
    
    local distance = (HumanoidRootPart.Position - egg.Position).Magnitude
    if distance <= STEAL_DISTANCE then
        -- ព្យាយាមប្រើ remote/proximity prompt ដើម្បីយក egg
        local prompt = egg:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
        else
            -- ប្រើ firetouchinterest ប្រសិនបើគ្មាន prompt
            firetouchinterest(HumanoidRootPart, egg, 0)
            task.wait(0.1)
            firetouchinterest(HumanoidRootPart, egg, 1)
        end
        
        -- Teleport ទៅ SafeZone ភ្លាមៗ
        task.wait(0.05)
        teleportToSafeZone()
    end
end

-- រង្វង់ loop ស្វែងរក egg ជាបន្តបន្ទាប់
local connection
connection = RunService.Heartbeat:Connect(function()
    if not HumanoidRootPart or not HumanoidRootPart.Parent then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        return
    end
    
    local eggs = getEggs()
    for _, egg in ipairs(eggs) do
        stealEgg(egg)
    end
end)

-- សម្អាតនៅពេល script ត្រូវបានបញ្ចប់
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- បង្ហាញសារ
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Delta Script",
    Text = "Egg Stealer + SafeZone Teleport បានដំណើរការ",
    Duration = 5
})
