-- NhazX Egg Steal | Credit: @nhaz_samurai
-- Compact + Anti-detection version

local P=game:GetService("Players")local R=game:GetService("RunService")
local U=game:GetService("UserInputService")local T=game:GetService("TweenService")
local CG=game:GetService("CoreGui")local LP=P.LocalPlayer

-- Anti-detect
pcall(function()if getgenv then getgenv().NX=tostring(math.random(1e5,1e6))end end)
if _G.NX_G then pcall(function()_G.NX_G:Destroy()end)end
_G.NX_G=true

-- GUI
local S=Instance.new("ScreenGui")S.Name="NX_"..math.random(1,99999)
S.ResetOnSpawn=false
pcall(function()S.Parent=CG end)
if not S.Parent then S.Parent=LP:WaitForChild("PlayerGui")end
_G.NX_GUI=S

-- Icon
local I=Instance.new("TextButton")I.Size=UDim2.new(0,55,0,55)
I.Position=UDim2.new(0,20,.5,-27)I.BackgroundColor3=Color3.fromRGB(18,18,22)
I.Text="NX"I.TextColor3=Color3.fromRGB(0,255,170)I.Font=Enum.Font.GothamBlack
I.TextSize=22 I.BorderSizePixel=0 I.Parent=S
Instance.new("UICorner",I).CornerRadius=UDim.new(0,12)
local st=Instance.new("UIStroke",I)st.Color=Color3.fromRGB(0,255,170)st.Thickness=2

-- Main
local M=Instance.new("Frame")M.Size=UDim2.new(0,400,0,300)
M.Position=UDim2.new(.5,-200,.5,-150)
M.BackgroundColor3=Color3.fromRGB(15,15,20)M.BorderSizePixel=0
M.Visible=false M.Active=true M.Parent=S
Instance.new("UICorner",M).CornerRadius=UDim.new(0,14)
local ms=Instance.new("UIStroke",M)ms.Color=Color3.fromRGB(0,255,170)
ms.Thickness=1.5 ms.Transparency=.3

-- TopBar
local TB=Instance.new("Frame")TB.Size=UDim2.new(1,0,0,40)
TB.BackgroundColor3=Color3.fromRGB(20,20,28)TB.BorderSizePixel=0 TB.Parent=M
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,14)
local tf=Instance.new("Frame")tf.Size=UDim2.new(1,0,0,14)
tf.Position=UDim2.new(0,0,1,-14)tf.BackgroundColor3=Color3.fromRGB(20,20,28)
tf.BorderSizePixel=0 tf.Parent=TB

local Tt=Instance.new("TextLabel")Tt.Size=UDim2.new(1,-100,1,0)
Tt.Position=UDim2.new(0,15,0,0)Tt.BackgroundTransparency=1
Tt.Text="NhazX  |  Egg Steal"Tt.TextColor3=Color3.fromRGB(0,255,170)
Tt.Font=Enum.Font.GothamBold Tt.TextSize=16
Tt.TextXAlignment=Enum.TextXAlignment.Left Tt.Parent=TB

local Cr=Instance.new("TextLabel")Cr.Size=UDim2.new(0,90,1,0)
Cr.Position=UDim2.new(1,-95,0,0)Cr.BackgroundTransparency=1
Cr.Text="@nhaz_samurai"Cr.TextColor3=Color3.fromRGB(255,255,255)
Cr.Font=Enum.Font.Gotham Cr.TextSize=11
Cr.TextXAlignment=Enum.TextXAlignment.Right Cr.Parent=TB

local Cb=Instance.new("TextButton")Cb.Size=UDim2.new(0,26,0,26)
Cb.Position=UDim2.new(1,-34,0,7)Cb.BackgroundColor3=Color3.fromRGB(255,60,60)
Cb.Text="X"Cb.TextColor3=Color3.fromRGB(255,255,255)
Cb.Font=Enum.Font.GothamBold Cb.TextSize=14 Cb.BorderSizePixel=0 Cb.Parent=TB
Instance.new("UICorner",Cb).CornerRadius=UDim.new(0,8)

-- Drag
local dg,di,ds,sp
TB.InputBegan:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
  dg=true ds=i.Position sp=M.Position
  i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then dg=false end end)
 end
end)
TB.InputChanged:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then di=i end
end)
U.InputChanged:Connect(function(i)
 if i==di and dg then
  local d=i.Position-ds
  M.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
 end
end)

-- Toggle GUI
I.MouseButton1Click:Connect(function()
 M.Visible=not M.Visible
 T:Create(I,TweenInfo.new(.15),{
  BackgroundColor3=M.Visible and Color3.fromRGB(0,255,170) or Color3.fromRGB(18,18,22),
  TextColor3=M.Visible and Color3.fromRGB(18,18,22) or Color3.fromRGB(0,255,170)
 }):Play()
end)
Cb.MouseButton1Click:Connect(function()M.Visible=false end)

-- Toggle factory
local function mTog(n,y,cb)
 local h=Instance.new("Frame")h.Size=UDim2.new(1,-30,0,40)
 h.Position=UDim2.new(0,15,0,y)h.BackgroundColor3=Color3.fromRGB(22,22,30)
 h.BorderSizePixel=0 h.Parent=M
 Instance.new("UICorner",h).CornerRadius=UDim.new(0,10)
 local l=Instance.new("TextLabel")l.Size=UDim2.new(1,-80,1,0)
 l.Position=UDim2.new(0,15,0,0)l.BackgroundTransparency=1
 l.Text=n l.TextColor3=Color3.fromRGB(240,240,240)
 l.Font=Enum.Font.GothamMedium l.TextSize=14
 l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=h
 local sw=Instance.new("TextButton")sw.Size=UDim2.new(0,50,0,26)
 sw.Position=UDim2.new(1,-62,.5,-13)
 sw.BackgroundColor3=Color3.fromRGB(60,60,70)sw.Text=""
 sw.BorderSizePixel=0 sw.AutoButtonColor=false sw.Parent=h
 Instance.new("UICorner",sw).CornerRadius=UDim.new(1,0)
 local k=Instance.new("Frame")k.Size=UDim2.new(0,20,0,20)
 k.Position=UDim2.new(0,3,.5,-10)k.BackgroundColor3=Color3.fromRGB(255,255,255)
 k.BorderSizePixel=0 k.Parent=sw
 Instance.new("UICorner",k).CornerRadius=UDim.new(1,0)
 local s=false
 sw.MouseButton1Click:Connect(function()
  s=not s
  T:Create(sw,TweenInfo.new(.15),{BackgroundColor3=s and Color3.fromRGB(0,255,170) or Color3.fromRGB(60,60,70)}):Play()
  T:Create(k,TweenInfo.new(.15),{Position=s and UDim2.new(1,-23,.5,-10) or UDim2.new(0,3,.5,-10)}):Play()
  if cb then cb(s)end
 end)
end

-- Steal Button
local SB=Instance.new("TextButton")SB.Size=UDim2.new(1,-30,0,44)
SB.Position=UDim2.new(0,15,0,14)SB.BackgroundColor3=Color3.fromRGB(0,255,170)
SB.Text="⚡ STEAL EGG"SB.TextColor3=Color3.fromRGB(15,15,20)
SB.Font=Enum.Font.GothamBold SB.TextSize=17 SB.BorderSizePixel=0 SB.Parent=M
Instance.new("UICorner",SB).CornerRadius=UDim.new(0,10)

-- Fly
local fy=false local fv,fg,fc
local function SF()
 if fy then return end fy=true
 local c=LP.Character if not c then return end
 local r=c:FindFirstChild("HumanoidRootPart") if not r then return end
 fv=Instance.new("BodyVelocity",r)fv.MaxForce=Vector3.new(9e9,9e9,9e9)fv.Velocity=Vector3.new()
 fg=Instance.new("BodyGyro",r)fg.MaxTorque=Vector3.new(9e9,9e9,9e9)
 fg.P=1000 fg.D=50 fg.CFrame=r.CFrame
 fc=R.RenderStepped:Connect(function()
  if not fy then return end
  local ch=LP.Character if not ch then return end
  local rt=ch:FindFirstChild("HumanoidRootPart") if not rt or not fv then return end
  local cm=workspace.CurrentCamera local mv=Vector3.new()
  if U:IsKeyDown(Enum.KeyCode.W)then mv=mv+cm.CFrame.LookVector end
  if U:IsKeyDown(Enum.KeyCode.S)then mv=mv-cm.CFrame.LookVector end
  if U:IsKeyDown(Enum.KeyCode.A)then mv=mv-cm.CFrame.RightVector end
  if U:IsKeyDown(Enum.KeyCode.D)then mv=mv+cm.CFrame.RightVector end
  if U:IsKeyDown(Enum.KeyCode.Space)then mv=mv+Vector3.new(0,1,0)end
  if U:IsKeyDown(Enum.KeyCode.LeftShift)then mv=mv-Vector3.new(0,1,0)end
  if mv.Magnitude>0 then mv=mv.Unit*80 end
  fv.Velocity=mv fg.CFrame=cm.CFrame
 end)
end
local function XF()
 fy=false
 if fc then fc:Disconnect()fc=nil end
 if fv then fv:Destroy()fv=nil end
 if fg then fg:Destroy()fg=nil end
end

-- Speed
local spd=false local sc
local function SS()
 spd=true
 local ch=LP.Character local hm=ch and ch:FindFirstChildOfClass("Humanoid")
 if hm then hm.WalkSpeed=120 end
 sc=R.Heartbeat:Connect(function()
  if not spd then return end
  local c=LP.Character local h=c and c:FindFirstChildOfClass("Humanoid")
  if h then h.WalkSpeed=120 end
 end)
end
local function XS()
 spd=false
 if sc then sc:Disconnect()sc=nil end
 local c=LP.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 if h then h.WalkSpeed=16 end
end

-- Find + TP egg
local function FindE()
 for _,o in ipairs(workspace:GetDescendants())do
  if o:IsA("BasePart")and o.Name:lower():find("egg")then return o end
 end
end
local function TPE(e)
 local c=LP.Character if not c then return end
 local r=c:FindFirstChild("HumanoidRootPart") if not r or not e then return end
 r.CFrame=CFrame.new(e.Position+Vector3.new(0,3,0))
 task.wait(.05)
 pcall(function()
  if firetouchinterest then firetouchinterest(r,e,0)task.wait(.02)firetouchinterest(r,e,1)
  elseif fireproximityprompt then
   local p=e:FindFirstChildOfClass("ProximityPrompt")if p then fireproximityprompt(p)end
  end
 end)
end
local function Back()
 local c=LP.Character if not c then return end
 local r=c:FindFirstChild("HumanoidRootPart") if not r then return end
 local s=workspace:FindFirstChildOfClass("SpawnLocation")
 if s then r.CFrame=s.CFrame+Vector3.new(0,5,0)end
end

-- Steal click
local cnt=0
SB.MouseButton1Click:Connect(function()
 SB.Text="⏳ STEALING..."SB.BackgroundColor3=Color3.fromRGB(255,200,0)
 task.spawn(function()
  local e=FindE()
  if e then TPE(e)cnt=cnt+1 task.wait(.1)Back()
   SB.Text="✅ STOLEN ("..cnt..")"
  else SB.Text="❌ NO EGG"end
  task.wait(1.2)SB.Text="⚡ STEAL EGG"SB.BackgroundColor3=Color3.fromRGB(0,255,170)
 end)
end)

-- Toggles
mTog("Speed Boost",68,function(v)if v then SS()else XS()end end)
mTog("Fly",118,function(v)if v then SF()else XF()end end)
local auto=false local ac
mTog("Auto Steal",168,function(v)
 auto=v
 if v then
  ac=task.spawn(function()
   while auto do
    local e=FindE()
    if e then TPE(e)cnt=cnt+1 task.wait(.1)Back()end
    task.wait(.3)
   end
  end)
 else
  if ac then pcall(function()task.cancel(ac)end)ac=nil end
 end
end)

-- Respawn
LP.CharacterAdded:Connect(function()
 task.wait(1)
 if spd then XS()SS()end
 if fy then XF()SF()end
end)

-- Notify
local N=Instance.new("TextLabel")N.Size=UDim2.new(0,290,0,38)
N.Position=UDim2.new(.5,-145,0,30)
N.BackgroundColor3=Color3.fromRGB(0,255,170)N.BackgroundTransparency=.1
N.Text="NhazX Loaded | @nhaz_samurai"N.TextColor3=Color3.fromRGB(15,15,20)
N.Font=Enum.Font.GothamBold N.TextSize=13 N.Parent=S
Instance.new("UICorner",N).CornerRadius=UDim.new(0,10)
task.spawn(function()
 task.wait(3)
 T:Create(N,TweenInfo.new(.5),{BackgroundTransparency=1,TextTransparency=1}):Play()
 task.wait(.5)N:Destroy()
end)
