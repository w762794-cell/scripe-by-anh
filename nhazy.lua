-- TEST BYPASS - ព្យាយាមច្រើនវិធី
local LP = game:GetService("Players").LocalPlayer
local Ch = LP.Character
local H = Ch:WaitForChild("HumanoidRootPart")

local home = H.CFrame
print("Home: " .. tostring(home.Position))

-- វិធី 1: NetworkOwner
pcall(function()
    if H:GetNetworkOwner() ~= LP then
        H:SetNetworkOwner(LP)
        print("[1] SetNetworkOwner OK")
    end
end)

task.wait(2)

-- វិធី 2: CFrame + Velocity reset
print("[2] Teleport with reset...")
H.Velocity = Vector3.zero
H.AssemblyLinearVelocity = Vector3.zero
H.CFrame = home + Vector3.new(0, 50, 0)

task.wait(0.5)
print("Position: " .. tostring(H.Position))

task.wait(1)
print("Position 1.5s: " .. tostring(H.Position))

task.wait(2)
print("Position 3.5s: " .. tostring(H.Position))

-- វិធី 3: បើនៅតែធ្លាក់ → ប្រើ loop teleport
print("[3] Loop teleport test...")
for i = 1, 10 do
    H.CFrame = home + Vector3.new(0, 50, 0)
    task.wait(0.05)
end
print("Position loop end: " .. tostring(H.Position))
