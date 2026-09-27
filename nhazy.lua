-- palofsc: TEST - Anti-cheat Teleport Check
-- ពិនិត្យថា game មាន anti-teleport ឬអត់

print("[TEST] ចាប់ផ្ដើម 3 វិនាទី...")

local LP = game:GetService("Players").LocalPlayer
local Ch = LP.Character
if not Ch then
    Ch = LP.CharacterAdded:Wait()
end
local H = Ch:WaitForChild("HumanoidRootPart")

local home = H.CFrame
print("[TEST] Home saved: " .. tostring(home.Position))

task.wait(3)

print("[TEST] Teleport ឡើងលើ 100 studs...")
H.CFrame = home + Vector3.new(0, 100, 0)
print("[TEST] Teleported to: " .. tostring(H.Position))

task.wait(1)
print("[TEST] Position ក្រោយ 1 វិនាទី: " .. tostring(H.Position))

task.wait(2)
print("[TEST] Position ក្រោយ 3 វិនាទី: " .. tostring(H.Position))

-- ប្រៀបធៀប
local dist = (H.Position - (home.Position + Vector3.new(0, 100, 0))).Magnitude
if dist < 10 then
    print("[TEST] ✓ TELEPORT WORK - នៅខ្ពស់")
else
    print("[TEST] ✗ TELEPORT FAILED - ត្រូវបាន server ទាញមកវិញ")
    print("[TEST] ចម្ងាយខុស: " .. tostring(dist))
end
