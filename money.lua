-- NhazX V2 | Credit: @nhaz_samurai
-- Full auto steal + escape + deliver

local P=game:GetService("Players")
local R=game:GetService("RunService")
local U=game:GetService("UserInputService")
local T=game:GetService("TweenService")
local CG=game:GetService("CoreGui")
local LP=P.LocalPlayer
local VIM=game:GetService("VirtualInputManager")

-- Anti-detect layer
pcall(function()
    if getgenv then
        getgenv().NX_HASH=tostring(os.time()).."_"..tostring(math.random(1e6,9e6))
    end
end)
if _G.NX_ACTIVE then pcall(function()_G.NX_UI:Destroy()end)end
_G.NX_ACTIVE=true

-- State
local State={
    AutoSteal=false,
    AutoEscape=false,
    AutoDeliver=false,
    Speed=false,
    Fly=false,
    Noclip=false,
    EggCount=0,
    BaseCFrame=nil,
    CurrentEgg=nil,
    Locked=false,
}

-- GUI Setup
local S=Instance.new("ScreenGui")
S.Name="NX_"..math.random(1,999999)
S.ResetOnSpawn=false
S.IgnoreGuiInset=true
pcall(function()S.Parent=CG end)
if not S.Parent then S.Parent=LP:WaitForChild("PlayerGui")end
_G.NX_UI=S

-- Icon
local I=Instance.new("TextButton")
I.Size=UDim2.new(0,58,0,58)
I.Position=UDim2.new(0,20,.5,-29)
I.BackgroundColor3=Color3.fromRGB(15,15,20)
I.Text="NX"
I.TextColor3=Color3.fromRGB(0,255,170)
I.Font=Enum.Font.GothamBlack
I.TextSize=24
I.BorderSizePixel=0
I.AutoButtonColor=false
I.Parent=S
Instance.new("UICorner",I).CornerRadius=UDim.new(0,14)
local ist=Instance.new("UIStroke",I)
ist.Color=Color3.fromRGB(0,255,170)
ist.Thickness=2

-- Main Frame
local M=Instance.new("Frame")
M.Size=UDim2.new(0,440,0,420)
M.Position=UDim2.new(.5,-220,.5,-210)
M.BackgroundColor3=Color3.fromRGB(12,12,16)
M.BorderSizePixel=0
M.Visible=false
M.Active=true
M.Parent=S
Instance.new("UICorner",M).CornerRadius=UDim.new(0,16)
local mst=Instance.new("UIStroke",M)
mst.Color=Color3.fromRGB(0,255,170)
mst.Thickness=1.5
mst.Transparency=.2

-- Gradient bg
local grad=Instance.new("UIGradient",M)
grad.Color=ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(12,12,16)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(25,15,35))
}
grad.Rotation=135

-- TopBar
local TB=Instance.new("Frame")
TB.Size=UDim2.new(1,0,0,44)
TB.BackgroundColor3=Color3.fromRGB(20,20,28)
TB.BorderSizePixel=0
TB.Parent=M
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,16)
local tfix=Instance.new("Frame")
tfix.Size=UDim2.new(1,0,0,16)
tfix.Position=UDim2.new(0,0,1,-16)
tfix.BackgroundColor3=Color3.fromRGB(20,20,28)
tfix.BorderSizePixel=0
tfix.Parent=TB

local Tt=Instance.new("TextLabel")
Tt.Size=UDim2.new(1,-120,1,0)
Tt.Position=UDim2.new(0,16,0,0)
Tt.BackgroundTransparency=1
Tt.Text="⚡ NhazX V2 | Egg Steal"
Tt.TextColor3=Color3.fromRGB(0,255,170)
Tt.Font=Enum.Font.GothamBold
Tt.TextSize=16
Tt.TextXAlignment=Enum.TextXAlignment.Left
Tt.Parent=TB

local Cr=Instance.new("TextLabel")
Cr.Size=UDim2.new(0,100,1,0)
Cr.Position=UDim2.new(1,-108,0,0)
Cr.BackgroundTransparency=1
Cr.Text="@nhaz_samurai"
Cr.TextColor3=Color3.fromRGB(200,200,200)
Cr.Font=Enum.Font.Gotham
Cr.TextSize=11
Cr.TextXAlignment=Enum.TextXAlignment.Right
Cr.Parent=TB

local Cb=Instance.new("TextButton")
Cb.Size=UDim2.new(0,28,0,28)
Cb.Position=UDim2.new(1,-36,0,8)
Cb.BackgroundColor3=Color3.fromRGB(255,60,60)
Cb.Text="✕"
Cb.TextColor3=Color3.fromRGB(255,255,255)
Cb.Font=Enum.Font.GothamBold
Cb.TextSize=14
Cb.BorderSizePixel=0
Cb.Parent=TB
Instance.new("UICorner",Cb).CornerRadius=UDim.new(0,8)

-- Status bar
local Status=Instance.new("TextLabel")
Status.Size=UDim2.new(1,-30,0,22)
Status.Position=UDim2.new(0,15,0,50)
Status.BackgroundTransparency=1
Status.Text="● Idle"
Status.TextColor3=Color3.fromRGB(150,150,150)
Status.Font=Enum.Font.GothamMedium
Status.TextSize=12
Status.TextXAlignment=Enum.TextXAlignment.Left
Status.Parent=M

-- Drag
local dg,di,ds,sp
TB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dg=true
        ds=i.Position
        sp=M.Position
        i.Changed:Connect(function()
            if i.UserInputState==Enum.UserInputState.End then dg=false end
        end)
    end
end)
TB.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        di=i
    end
end)
U.InputChanged:Connect(function(i)
    if i==di and dg then
        local d=i.Position-ds
        M.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
end)

I.MouseButton1Click:Connect(function()
    M.Visible=not M.Visible
    T:Create(I,TweenInfo.new(.15),{
        BackgroundColor3=M.Visible and Color3.fromRGB(0,255,170) or Color3.fromRGB(15,15,20),
        TextColor3=M.Visible and Color3.fromRGB(15,15,20) or Color3.fromRGB(0,255,170)
    }):Play()
end)
Cb.MouseButton1Click:Connect(function()M.Visible=false end)

-- Toggle maker
local function mTog(name,y,cb)
    local h=Instance.new("Frame")
    h.Size=UDim2.new(0,195,0,42)
    h.BackgroundColor3=Color3.fromRGB(20,20,28)
    h.BorderSizePixel=0
    h.Parent=M
    Instance.new("UICorner",h).CornerRadius=UDim.new(0,10)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-70,1,0)
    l.Position=UDim2.new(0,12,0,0)
    l.BackgroundTransparency=1
    l.Text=name
    l.TextColor3=Color3.fromRGB(235,235,235)
    l.Font=Enum.Font.GothamMedium
    l.TextSize=13
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=h
    local sw=Instance.new("TextButton")
    sw.Size=UDim2.new(0,46,0,24)
    sw.Position=UDim2.new(1,-54,.5,-12)
    sw.BackgroundColor3=Color3.fromRGB(55,55,65)
    sw.Text=""
    sw.BorderSizePixel=0
    sw.AutoButtonColor=false
    sw.Parent=h
    Instance.new("UICorner",sw).CornerRadius=UDim.new(1,0)
    local k=Instance.new("Frame")
    k.Size=UDim2.new(0,18,0,18)
    k.Position=UDim2.new(0,3,.5,-9)
    k.BackgroundColor3=Color3.fromRGB(255,255,255)
    k.BorderSizePixel=0
    k.Parent=sw
    Instance.new("UICorner",k).CornerRadius=UDim.new(1,0)
    local on=false
    sw.MouseButton1Click:Connect(function()
        on=not on
        T:Create(sw,TweenInfo.new(.15),{
            BackgroundColor3=on and Color3.fromRGB(0,255,170) or Color3.fromRGB(55,55,65)
        }):Play()
        T:Create(k,TweenInfo.new(.15),{
            Position=on and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)
        }):Play()
        if cb then cb(on)end
    end)
    return {Set=function(v)
        on=v
        sw.BackgroundColor3=v and Color3.fromRGB(0,255,170) or Color3.fromRGB(55,55,65)
        k.Position=v and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)
        if cb then cb(v)end
    end}
end

-- BIG STEAL BUTTON
local SB=Instance.new("TextButton")
SB.Size=UDim2.new(1,-30,0,52)
SB.Position=UDim2.new(0,15,0,80)
SB.BackgroundColor3=Color3.fromRGB(0,255,170)
SB.Text="🔥 STEAL EGG NOW"
SB.TextColor3=Color3.fromRGB(15,15,20)
SB.Font=Enum.Font.GothamBlack
SB.TextSize=18
SB.BorderSizePixel=0
SB.Parent=M
Instance.new("UICorner",SB).CornerRadius=UDim.new(0,12)

-- Deliver button
local DB=Instance.new("TextButton")
DB.Size=UDim2.new(1,-30,0,42)
DB.Position=UDim2.new(0,15,0,140)
DB.BackgroundColor3=Color3.fromRGB(255,140,0)
DB.Text="🏠 DELIVER TO BASE"
DB.TextColor3=Color3.fromRGB(15,15,20)
DB.Font=Enum.Font.GothamBold
DB.TextSize=15
DB.BorderSizePixel=0
DB.Parent=M
Instance.new("UICorner",DB).CornerRadius=UDim.new(0,10)

-- Save base button
local SaveB=Instance.new("TextButton")
SaveB.Size=UDim2.new(0,120,0,32)
SaveB.Position=UDim2.new(0,15,0,190)
SaveB.BackgroundColor3=Color3.fromRGB(80,80,100)
SaveB.Text="📍 Save Base"
SaveB.TextColor3=Color3.fromRGB(255,255,255)
SaveB.Font=Enum.Font.GothamMedium
SaveB.TextSize=12
SaveB.BorderSizePixel=0
SaveB.Parent=M
Instance.new("UICorner",SaveB).CornerRadius=UDim.new(0,8)

-- Egg counter
local EC=Instance.new("TextLabel")
EC.Size=UDim2.new(0,150,0,32)
EC.Position=UDim2.new(1,-165,0,190)
EC.BackgroundColor3=Color3.fromRGB(30,30,40)
EC.Text="🥚 Eggs: 0"
EC.TextColor3=Color3.fromRGB(0,255,170)
EC.Font=Enum.Font.GothamBold
EC.TextSize=13
EC.BorderSizePixel=0
EC.Parent=M
Instance.new("UICorner",EC).CornerRadius=UDim.new(0,8)

-- Toggles row 1
local t1=mTog("Auto Steal",230,function(v)State.AutoSteal=v;UpdateStatus()end)
t1.Set:GetPropertyChangedSignal and nil
local tog1=Instance.new("Frame")
tog1.Size=UDim2.new(0,195,0,42)
tog1.Position=UDim2.new(0,15,0,230)
tog1.BackgroundTransparency=1
tog1.Parent=M
t1=nil
-- Re-create properly positioned toggles
local function mkToggle(name,x,y,cb)
    local h=Instance.new("Frame")
    h.Size=UDim2.new(0,195,0,42)
    h.Position=UDim2.new(0,x,0,y)
    h.BackgroundColor3=Color3.fromRGB(20,20,28)
    h.BorderSizePixel=0
    h.Parent=M
    Instance.new("UICorner",h).CornerRadius=UDim.new(0,10)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-70,1,0)
    l.Position=UDim2.new(0,12,0,0)
    l.BackgroundTransparency=1
    l.Text=name
    l.TextColor3=Color3.fromRGB(235,235,235)
    l.Font=Enum.Font.GothamMedium
    l.TextSize=13
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=h
    local sw=Instance.new("TextButton")
    sw.Size=UDim2.new(0,46,0,24)
    sw.Position=UDim2.new(1,-54,.5,-12)
    sw.BackgroundColor3=Color3.fromRGB(55,55,65)
    sw.Text=""
    sw.BorderSizePixel=0
    sw.AutoButtonColor=false
    sw.Parent=h
    Instance.new("UICorner",sw).CornerRadius=UDim.new(1,0)
    local k=Instance.new("Frame")
    k.Size=UDim2.new(0,18,0,18)
    k.Position=UDim2.new(0,3,.5,-9)
    k.BackgroundColor3=Color3.fromRGB(255,255,255)
    k.BorderSizePixel=0
    k.Parent=sw
    Instance.new("UICorner",k).CornerRadius=UDim.new(1,0)
    local on=false
    sw.MouseButton1Click:Connect(function()
        on=not on
        T:Create(sw,TweenInfo.new(.15),{
            BackgroundColor3=on and Color3.fromRGB(0,255,170) or Color3.fromRGB(55,55,65)
        }):Play()
        T:Create(k,TweenInfo.new(.15),{
            Position=on and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)
        }):Play()
        if cb then cb(on)end
    end)
    return function()return on end
end

mkToggle("Auto Steal",15,230,function(v)State.AutoSteal=v;UpdateStatus()end)
mkToggle("Speed x10",230,230,function(v)State.Speed=v;if v then StartSpeed()else StopSpeed()end end)
mkToggle("Fly",15,280,function(v)State.Fly=v;if v then StartFly()else StopFly()end end)
mkToggle("Noclip",230,280,function(v)State.Noclip=v;if v then StartNoclip()else StopNoclip()end end)

-- Update status
function UpdateStatus()
    local t={}
    if State.AutoSteal then table.insert(t,"Auto")end
    if State.Speed then table.insert(t,"Speed")end
    if State.Fly then table.insert(t,"Fly")end
    if State.Noclip then table.insert(t,"Noclip")end
    if #t==0 then
        Status.Text="● Idle"
        Status.TextColor3=Color3.fromRGB(150,150,150)
    else
        Status.Text="● Active: "..table.concat(t,", ")
        Status.TextColor3=Color3.fromRGB(0,255,170)
    end
end

-- ═══════════ CORE FUNCTIONS ═══════════

local function GetChar()
    local c=LP.Character
    if not c then return nil,nil,nil end
    return c,c:FindFirstChild("HumanoidRootPart"),c:FindFirstChildOfClass("Humanoid")
end

-- Get current base position (saved or spawn)
local function GetBase()
    if State.BaseCFrame then return State.BaseCFrame end
    local sp=workspace:FindFirstChildOfClass("SpawnLocation")
    if sp then return sp.CFrame+Vector3.new(0,5,0)end
    local c=LP.Character
    if c and c:FindFirstChild("HumanoidRootPart")then
        return c.HumanoidRootPart.CFrame
    end
    return CFrame.new(0,50,0)
end

SaveB.MouseButton1Click:Connect(function()
    local _,hrp=GetChar()
    if hrp then
        State.BaseCFrame=hrp.CFrame
        SaveB.Text="✅ Base Saved"
        SaveB.BackgroundColor3=Color3.fromRGB(0,200,100)
        task.wait(1.5)
        SaveB.Text="📍 Save Base"
        SaveB.BackgroundColor3=Color3.fromRGB(80,80,100)
    end
end)

-- Find nearest egg
local function FindNearestEgg()
    local _,hrp=GetChar()
    if not hrp then return nil end
    local closest,dist=nil,math.huge
    local pos=hrp.Position
    for _,o in ipairs(workspace:GetDescendants())do
        if o:IsA("BasePart")and not o:IsDescendantOf(LP.Character)then
            local n=o.Name:lower()
            if n:find("egg")and not n:find("decal")and not n:find("gui")then
                local d=(o.Position-pos).Magnitude
                if d<dist then
                    closest=o
                    dist=d
                end
            end
        end
    end
    return closest
end

-- Check if holding egg
local function IsHoldingEgg()
    local c=GetChar()
    if not c then return false end
    for _,o in ipairs(c:GetChildren())do
        if o.Name:lower():find("egg")then return true end
    end
    -- Check tools
    for _,o in ipairs(LP.Backpack:GetChildren())do
        if o.Name:lower():find("egg")then return true end
    end
    return false
end

-- Teleport (safe method)
local function Teleport(pos)
    local c,hrp=GetChar()
    if not hrp then return end
    if typeof(pos)=="Vector3"then
        hrp.CFrame=CFrame.new(pos)
    elseif typeof(pos)=="CFrame"then
        hrp.CFrame=pos
    end
end

-- Steal egg
local function StealEgg()
    if State.Locked then return end
    State.Locked=true
    local egg=FindNearestEgg()
    if not egg then
        Status.Text="● No egg found"
        Status.TextColor3=Color3.fromRGB(255,80,80)
        task.wait(1)
        UpdateStatus()
        State.Locked=false
        return
    end
    State.CurrentEgg=egg
    Status.Text="● Stealing egg..."
    Status.TextColor3=Color3.fromRGB(255,200,0)

    local _,hrp=GetChar()
    if not hrp then State.Locked=false return end

    -- Save return pos
    local returnPos=State.BaseCFrame or hrp.CFrame

    -- Approach egg
    for i=1,3 do
        if not egg or not egg:IsDescendantOf(workspace)then break end
        Teleport(egg.Position+Vector3.new(0,2,0))
        task.wait(.05)
        -- Try all touch methods
        pcall(function()
            if firetouchinterest then
                firetouchinterest(hrp,egg,0)
                task.wait(.02)
                firetouchinterest(hrp,egg,1)
            end
        end)
        pcall(function()
            if fireproximityprompt then
                local p=egg:FindFirstChildOfClass("ProximityPrompt")
                if p then fireproximityprompt(p)end
                for _,d in ipairs(egg:GetDescendants())do
                    if d:IsA("ProximityPrompt")then fireproximityprompt(d)end
                end
            end
        end)
        pcall(function()
            if fireclickdetector then
                for _,d in ipairs(egg:GetDescendants())do
                    if d:IsA("ClickDetector")then fireclickdetector(d)end
                end
            end
        end)
        task.wait(.08)
        if IsHoldingEgg()then break end
    end

    -- Return to base
    if IsHoldingEgg()then
        State.EggCount=State.EggCount+1
        EC.Text="🥚 Eggs: "..State.EggCount
        Status.Text="● Returning to base..."
        Status.TextColor3=Color3.fromRGB(0,255,170)

        -- Path back to base
        local base=GetBase()
        for i=1,3 do
            Teleport(base)
            task.wait(.08)
        end

        -- Auto deliver
        local c=GetChar()
        if c then
            -- Touch all parts near base
            for _,o in ipairs(workspace:GetDescendants())do
                if o:IsA("BasePart")then
                    pcall(function()
                        if firetouchinterest then
                            firetouchinterest(hrp,o,0)
                            task.wait(.005)
                            firetouchinterest(hrp,o,1)
                        end
                    end)
                end
            end
        end
        Status.Text="● Egg stolen! ("..State.EggCount..")"
        Status.TextColor3=Color3.fromRGB(0,255,170)
    else
        Status.Text="● Failed to grab egg"
        Status.TextColor3=Color3.fromRGB(255,80,80)
    end
    task.wait(1)
    UpdateStatus()
    State.Locked=false
end

-- ═══════════ SPEED ═══════════
local speedConn
function StartSpeed()
    StopSpeed()
    local _,_,hum=GetChar()
    if hum then hum.WalkSpeed=160 end
    speedConn=R.Heartbeat:Connect(function()
        if not State.Speed then return end
        local _,_,h=GetChar()
        if h and h.WalkSpeed<160 then h.WalkSpeed=160 end
    end)
end
function StopSpeed()
    if speedConn then speedConn:Disconnect()speedConn=nil end
    local _,_,h=GetChar()
    if h then h.WalkSpeed=16 end
end

-- ═══════════ FLY ═══════════
local fv,fg,fc
function StartFly()
    StopFly()
    local _,hrp=GetChar()
    if not hrp then return end
    fv=Instance.new("BodyVelocity")
    fv.MaxForce=Vector3.new(9e9,9e9,9e9)
    fv.Velocity=Vector3.new()
    fv.Parent=hrp
    fg=Instance.new("BodyGyro")
    fg.MaxTorque=Vector3.new(9e9,9e9,9e9)
    fg.P=1000
    fg.D=50
    fg.CFrame=hrp.CFrame
    fg.Parent=hrp
    fc=R.RenderStepped:Connect(function()
        if not State.Fly then return end
        local _,r=GetChar()
        if not r or not fv then return end
        local cm=workspace.CurrentCamera
        local mv=Vector3.new()
        if U:IsKeyDown(Enum.KeyCode.W)then mv=mv+cm.CFrame.LookVector end
        if U:IsKeyDown(Enum.KeyCode.S)then mv=mv-cm.CFrame.LookVector end
        if U:IsKeyDown(Enum.KeyCode.A)then mv=mv-cm.CFrame.RightVector end
        if U:IsKeyDown(Enum.KeyCode.D)then mv=mv+cm.CFrame.RightVector end
        if U:IsKeyDown(Enum.KeyCode.Space)then mv=mv+Vector3.new(0,1,0)end
        if U:IsKeyDown(Enum.KeyCode.LeftShift)then mv=mv-Vector3.new(0,1,0)end
        if mv.Magnitude>0 then mv=mv.Unit*100 end
        fv.Velocity=mv
        fg.CFrame=cm.CFrame
    end)
end
function StopFly()
    if fc then fc:Disconnect()fc=nil end
    if fv then fv:Destroy()fv=nil end
    if fg then fg:Destroy()fg=nil end
end

-- ═══════════ NOCLIP ═══════════
local ncConn
function StartNoclip()
    StopNoclip()
    ncConn=R.Stepped:Connect(function()
        if not State.Noclip then return end
        local c=LP.Character
        if not c then return end
        for _,p in ipairs(c:GetDescendants())do
            if p:IsA("BasePart")and p.CanCollide then p.CanCollide=false end
        end
    end)
end
function StopNoclip()
    if ncConn then ncConn:Disconnect()ncConn=nil end
end

-- ═══════════ AUTO LOOP ═══════════
local autoThread
function StartAuto()
    if autoThread then return end
    autoThread=task.spawn(function()
        while State.AutoSteal do
            if not State.Locked then
                StealEgg()
            end
            task.wait(.3)
        end
    end)
end

SB.MouseButton1Click:Connect(function()
    if State.Locked then return end
    task.spawn(StealEgg)
end)

DB.MouseButton1Click:Connect(function()
    task.spawn(function()
        local _,hrp=GetChar()
        if not hrp then return end
        local base=GetBase()
        for i=1,3 do
            Teleport(base)
            task.wait(.08)
        end
        Status.Text="● Returned to base"
        Status.TextColor3=Color3.fromRGB(0,255,170)
        task.wait(1)
        UpdateStatus()
    end)
end)

-- Watch AutoSteal state
task.spawn(function()
    while _G.NX_ACTIVE do
        if State.AutoSteal and not autoThread then
            StartAuto()
        elseif not State.AutoSteal and autoThread then
            pcall(function()task.cancel(autoThread)end)
            autoThread=nil
        end
        task.wait(.5)
    end
end)

-- Respawn handler
LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    State.Locked=false
    if State.Speed then StartSpeed()end
    if State.Fly then StopFly()StartFly()end
    if State.Noclip then StartNoclip()end
end)

-- Notify
local N=Instance.new("TextLabel")
N.Size=UDim2.new(0,320,0,42)
N.Position=UDim2.new(.5,-160,0,30)
N.BackgroundColor3=Color3.fromRGB(0,255,170)
N.BackgroundTransparency=.1
N.Text="⚡ NhazX V2 Loaded | @nhaz_samurai"
N.TextColor3=Color3.fromRGB(15,15,20)
N.Font=Enum.Font.GothamBold
N.TextSize=14
N.Parent=S
Instance.new("UICorner",N).CornerRadius=UDim.new(0,10)
task.spawn(function()
    task.wait(3)
    T:Create(N,TweenInfo.new(.5),{BackgroundTransparency=1,TextTransparency=1}):Play()
    task.wait(.5)
    N:Destroy()
end)
