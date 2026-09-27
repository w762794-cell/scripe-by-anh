-- palofsc: TEST BYPASS v2 - ព្យាយាមច្រើនវិធី
-- ពិនិត្យថា game មាន anti-teleport បែបណា

print("========================================")
print("=== TEST BYPASS v2 ===")
print("========================================")

local LP = game:GetService("Players").LocalPlayer
local Ch = LP.Character
if not Ch then
    Ch = LP.CharacterAdded:Wait()
end
local H = Ch:WaitForChild("HumanoidRootPart")

local home = H.CFrame
print("[TEST] Home: " .. tostring(home.Position))
print("[TEST] ចាំ 3 វិនាទី...")

task.wait(3)

-- ============================================================
-- វិធី 1: NetworkOwner + CFrame
-- ============================================================
print("")
print("[វិធី 1] SetNetworkOwner + CFrame")
pcall(function()
    if H:GetNetworkOwner() ~= LP then
        H:SetNetworkOwner(LP)
        print("  NetworkOwner: OK")
    else
        print("  NetworkOwner: Already set")
    end
end)

H.Velocity = Vector3.zero
H.AssemblyLinearVelocity = Vector3.zero
H.CFrame = home + Vector3.new(0, 50, 0)

task.wait(0.5)
print("  Position 0.5s: " .. tostring(H.Position))

task.wait(1)
print("  Position 1.5s: " .. tostring(H.Position))

task.wait(2)
print("  Position 3.5s: " .. tostring(H.Position))

local dist1 = (H.Position - (home.Position + Vector3.new(0, 50, 0))).Magnitude
print("  ចម្ងាយខុស: " .. tostring(math.floor(dist1)))

if dist1 < 10 then
    print("  ✓ វិធី 1 WORK")
else
    print("  ✗ វិធី 1 FAILED")
end

-- ============================================================
-- វិធី 2: CFrame ជាន់ៗ (stealth)
-- ============================================================
print("")
print("[វិធី 2] CFrame ជាន់ៗ")
local startPos = H.Position
local targetPos = home.Position + Vector3.new(0, 50, 0)

for i = 1, 10 do
    local pos = startPos:Lerp(targetPos, i/10)
    H.CFrame = CFrame.new(pos)
    task.wait(0.05)
end

task.wait(0.5)
print("  Position 0.5s: " .. tostring(H.Position))

task.wait(2)
print("  Position 2.5s: " .. tostring(H.Position))

local dist2 = (H.Position - targetPos).Magnitude
print("  ចម្ងាយខុស: " .. tostring(math.floor(dist2)))

if dist2 < 10 then
    print("  ✓ វិធី 2 WORK")
else
    print("  ✗ វិធី 2 FAILED")
end

-- ============================================================
-- វិធី 3: BodyVelocity (ចលនា)
-- ============================================================
print("")
print("[វិធី 3] BodyVelocity")
pcall(function()
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 500, 0)
    bv.MaxForce = Vector3.new(0, 1e6, 0)
    bv.Parent = H
    
    task.wait(0.3)
    bv:Destroy()
end)

task.wait(0.5)
print("  Position: " .. tostring(H.Position))

-- ============================================================
-- វិធី 4: Anchored
-- ============================================================
print("")
print("[វិធី 4] Anchored + CFrame")
local oldAnchored = H.Anchored
H.Anchored = true
H.CFrame = home + Vector3.new(0, 80, 0)

task.wait(1)
print("  Position 1s: " .. tostring(H.Position))

task.wait(2)
print("  Position 3s: " .. tostring(H.Position))

local dist4 = (H.Position - (home.Position + Vector3.new(0, 80, 0))).Magnitude
print("  ចម្ងាយខុស: " .. tostring(math.floor(dist4)))

if dist4 < 10 then
    print("  ✓ វិធី 4 WORK - Anchored ទប់ស្កាត់ anti-cheat")
else
    print("  ✗ វិធី 4 FAILED")
end

H.Anchored = oldAnchored

-- ============================================================
-- សេចក្ដីសង្ខេប
-- ============================================================
print("")
print("========================================")
print("=== សេចក្ដីសង្ខេប ===")
print("========================================")
print("វិធី 1 (NetworkOwner): " .. (dist1 < 10 and "WORK" or "FAILED"))
print("វិធី 2 (Step CFrame): " .. (dist2 < 10 and "WORK" or "FAILED"))
print("វិធី 4 (Anchored): " .. (dist4 < 10 and "WORK" or "FAILED"))
print("")
print("ប្រាប់ខ្ញុំលទ្ធផលទាំងអស់នេះ")
