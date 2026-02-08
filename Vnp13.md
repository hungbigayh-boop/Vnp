-- OKARUN FARM MENU - ALL IN ONE
-- LocalScript | StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AcceptQuest = Remotes:WaitForChild("AcceptQuest")

-- CONFIG
local BOSS_NAME = "Okaka"
local MAX_RANGE = 300

-- STATE
local AutoQuest = false
local AutoSniperZ = false
local Range = 150

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "OKARUN_FARM_MENU"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.28,0.22)
frame.Position = UDim2.fromScale(0.36,0.7)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0.25,0)
title.BackgroundTransparency = 1
title.Text = "OKARUN FARM MENU"
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold

local btnQuest = Instance.new("TextButton", frame)
btnQuest.Size = UDim2.new(0.9,0,0.22,0)
btnQuest.Position = UDim2.new(0.05,0,0.3,0)
btnQuest.Text = "AUTO QUEST OKAKA : OFF"
btnQuest.TextScaled = true
btnQuest.Font = Enum.Font.GothamBold

local btnSniper = Instance.new("TextButton", frame)
btnSniper.Size = UDim2.new(0.9,0,0.22,0)
btnSniper.Position = UDim2.new(0.05,0,0.55,0)
btnSniper.Text = "AUTO SNIPER Z : OFF"
btnSniper.TextScaled = true
btnSniper.Font = Enum.Font.GothamBold

btnQuest.MouseButton1Click:Connect(function()
	AutoQuest = not AutoQuest
	btnQuest.Text = AutoQuest and "AUTO QUEST OKAKA : ON" or "AUTO QUEST OKAKA : OFF"
end)

btnSniper.MouseButton1Click:Connect(function()
	AutoSniperZ = not AutoSniperZ
	btnSniper.Text = AutoSniperZ and "AUTO SNIPER Z : ON" or "AUTO SNIPER Z : OFF"
end)

-- AUTO QUEST
task.spawn(function()
	while true do
		if AutoQuest then
			pcall(function()
				AcceptQuest:FireServer(BOSS_NAME)
			end)
		end
		task.wait(1.5)
	end
end)

-- GET BOSS
local function GetBoss()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v.Name == BOSS_NAME and v:FindFirstChild("HumanoidRootPart") then
			return v
		end
	end
end

-- GET SNIPER
local function GetSniper()
	for _,v in pairs(player.Character:GetChildren()) do
		if v:IsA("Tool") and v.Name == "SniperCombat" then
			return v
		end
	end
end

-- AUTO AIM + FIRE Z
RunService.Heartbeat:Connect(function()
	if not AutoSniperZ then return end
	if not player.Character then return end

	local boss = GetBoss()
	if not boss then return end

	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if (boss.HumanoidRootPart.Position - hrp.Position).Magnitude > math.min(Range, MAX_RANGE) then return end

	local sniper = GetSniper()
	if not sniper then return end

	workspace.CurrentCamera.CFrame =
		CFrame.new(workspace.CurrentCamera.CFrame.Position, boss.HumanoidRootPart.Position)

	pcall(function()
		sniper:Activate()
	end)
end)
