local H = game.Players.LocalPlayer.Character.HumanoidRootPart
local home = H.CFrame
task.wait(3)
H.CFrame = home + Vector3.new(0, 50, 0)
print("Teleported up 50 studs")
