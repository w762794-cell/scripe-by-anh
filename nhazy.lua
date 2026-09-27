-- Delta Executor: Egg Steal + Teleport ទៅ SafeZone/កសិដ្ឋាន
-- ជំនាន់កែសម្រួល៖ ចាប់យក egg បានជោគជ័យ ទើប teleport
-- មិន teleport មុនពេលយក (ដើម្បីកុំឱ្យ egg កន្ដាក់ៗបាត់)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ============ CONFIG កែត្រង់នេះ ============
local SAFEZONE_CFRAME = CFrame.new(0, 50, 0)   -- កែទីតាំង SafeZone ឬកសិដ្ឋានរបស់អ្នក
local STEAL_DISTANCE = 15                        -- ចម្ងាយអាចចាប់ egg
local TELEPORT_DELAY = 0.15                      -- រង់ចាំបន្តិច ក្រោយយកបាន ទើប teleport
local CHECK_INTERVAL = 0.1                       -- ពេលពិនិត្យ egg ថ្មី
-- =============================================

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- បញ្ជី egg ដែលបានយករួច (កុំយកម្តងទៀត)
local stolenEggs = {}
-- បញ្ជី egg ដែលកំពុងដំណើរការ
local processingEggs = {}

-- ============ ស្វែងរក Remote សម្រាប់យក egg ============
local eggRemotes = {}
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

-- ============ ស្វែងរក Egg ក្នុង workspace ============
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

-- ============ ទទួលយក egg ដោយសាកល្បងគ្រប់វិធី ============
local function trySteal(egg)
    local eggPart = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
    if not eggPart then return false end
    
    local success = false
    
    -- វិធី 1: ProximityPrompt
    local prompt = egg:FindFirstChildOfClass("ProximityPrompt", true)
    if not prompt and eggPart then
        prompt = eggPart:FindFirstChildOfClass("ProximityPrompt")
    end
    if prompt then
        local ok = pcall(function()
            fireproximityprompt(prompt)
        end)
        if ok then success = true end
    end
    
    -- វិធី 2: ClickDetector
    local clickDetector = egg:FindFirstChildOfClass("ClickDetector", true)
    if not clickDetector and eggPart then
        clickDetector = eggPart:FindFirstChildOfClass("ClickDetector")
    end
    if clickDetector then
        local ok = pcall(function()
            fireclickdetector(clickDetector)
        end)
        if ok then success = true end
    end
    
    -- វិធី 3: RemoteEvent/RemoteFunction
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
    
    -- វិធី 4: Touch interest
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

-- ============ Teleport ទៅ SafeZone ក្រោយយកបាន ============
local function teleportToSafeZone()
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    pcall(function()
        HumanoidRootPart.CFrame = SAFEZONE_CFRAME
        HumanoidRootPart.Velocity = Vector3.zero
        HumanoidRootPart.RotVelocity = Vector3.zero
    end)
end

-- ============ ដំណើរការយក egg ============
local function processEgg(egg)
    if not egg or not egg.Parent then return end
    if stolenEggs[egg] or processingEggs[egg] then return end
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    
    local eggPart = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
    if not eggPart then return end
    
    local distance = (HumanoidRootPart.Position - eggPart.Position).Magnitude
    if distance > STEAL_DISTANCE then return end
    
    processingEggs[egg] = true
    
    -- រង់ចាំបន្តិច ដើម្បីធានាថា egg នៅជិត
    task.wait(0.05)
    
    -- ពិនិត្យម្តងទៀត
    if not egg.Parent then
        processingEggs[egg] = nil
        return
    end
    
    -- ព្យាយាមយក egg
    local attempted = trySteal(egg)
    
    if attempted then
        -- រង់ចាំបន្តិច ដើម្បីឱ្យ server ចាប់យក egg បានជោគជ័យ
        task.wait(TELEPORT_DELAY)
        
        -- សម្គាល់ថាបានយករួច
        stolenEggs[egg] = true
        
        -- Teleport ទៅ SafeZone
        teleportToSafeZone()
        
        -- បង្ហាញ notification
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Egg Steal",
                Text = "យក egg បានជោគជ័យ - Teleport ទៅ SafeZone",
                Duration = 2
            })
        end)
    end
    
    processingEggs[egg] = nil
end

-- ============ Main Loop ============
local running = true

task.spawn(function()
    while running do
        if not HumanoidRootPart or not HumanoidRootPart.Parent then
            Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            Humanoid = Character:WaitForChild("Humanoid")
        end
        
        local eggs = getEggs()
        for _, egg in ipairs(eggs) do
            task.spawn(function()
                pcall(processEgg, egg)
            end)
        end
        
        task.wait(CHECK_INTERVAL)
    end
end)

-- ============ ការពារ Character Respawn ============
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Humanoid = newChar:WaitForChild("Humanoid")
end)

-- ============ Scan Remote ម្តងទៀតរៀងរាល់ 30 វិនាទី ============
task.spawn(function()
    while running do
        task.wait(30)
        pcall(scanRemotes)
    end
end)

-- ============ Notification ចាប់ផ្តើម ============
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Egg Steal + SafeZone",
        Text = "កំពុងដំណើរការ - យក egg បានទើប teleport",
        Duration = 5
    })
end)
