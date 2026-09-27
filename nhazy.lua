-- Roblox script: Steal an Egg auto-teleport to SafeZone
-- សូមប្រើក្នុងការអនុញ្ញាតតែប៉ុណ្ណោះ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- កំណត់ SafeZone CFrame (ដាក់ទីតាំងរបស់អ្នក)
local SAFEZONE_CFRAME = CFrame.new(0, 50, 0)

-- មុខងារ teleport ទៅ SafeZone
local function teleportToSafeZone()
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = SAFEZONE_CFRAME
    end
end

-- រង់ចាំ egg ក្នុង workspace
local function onEggTouched(egg)
    if egg:IsA("BasePart") or egg:IsA("Model") then
        local part = egg:IsA("BasePart") and egg or egg.PrimaryPart
        if part then
            part.Touched:Connect(function(hit)
                if hit:IsDescendantOf(Character) then
                    teleportToSafeZone()
                end
            end)
        end
    end
end

-- ស្កេន egg ថ្មីៗ
for _, obj in pairs(workspace:GetDescendants()) do
    if obj.Name:lower():find("egg") then
        onEggTouched(obj)
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if obj.Name:lower():find("egg") then
        onEggTouched(obj)
    end
end)

-- ជម្រើស: ចាប់យក egg ដោយផ្ទាល់ពេលប៉ះ
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)
