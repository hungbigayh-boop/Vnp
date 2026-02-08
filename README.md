----------------------------------------------------------------
-- OKAKA FULL SYSTEM (ONE FILE)
-- Chủ game sử dụng – Server-side – An toàn
----------------------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------
local BOSS_NAME = "Okaka"

-- Kill Aura
local DESIRED_KILL_RANGE = 150
local MAX_KILL_RANGE = 300
local KILL_RANGE = math.clamp(DESIRED_KILL_RANGE, 1, MAX_KILL_RANGE)

-- Hover
local HOVER_DISTANCE = 80
local HOVER_HEIGHT = 35
local HOVER_LERP = 0.15

-- Skill Z
local Z_COOLDOWN = 2.5

----------------------------------------------------------------
-- SNIPER COMBAT (GIẢ LẬP – GẮN VÀO COMBAT CỦA BẠN)
----------------------------------------------------------------
local SniperCombat = {}
local lastZ = {}

function SniperCombat:UseZ(player)
	local now = os.clock()
	lastZ[player] = lastZ[player] or 0
	if now - lastZ[player] < Z_COOLDOWN then return end
	lastZ[player] = now

	-- BẮN Z Ở ĐÂY (logic damage bạn đã có sẵn)
end

----------------------------------------------------------------
-- UTILS
----------------------------------------------------------------
local function getBoss()
	if not workspace:FindFirstChild("Mobs") then return end
	for _, m in pairs(workspace.Mobs:GetChildren()) do
		if m.Name == BOSS_NAME
		and m:FindFirstChild("Humanoid")
		and m:FindFirstChild("HumanoidRootPart")
		and m.Humanoid.Health > 0 then
			return m
		end
	end
end

----------------------------------------------------------------
-- MAIN LOOP
----------------------------------------------------------------
RunService.Heartbeat:Connect(function()
	local boss = getBoss()
	if not boss then return end
	local bossHRP = boss.HumanoidRootPart

	for _, player in pairs(Players:GetPlayers()) do
		local char = player.Character
		if not char then continue end

		local hum = char:FindFirstChild("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp or hum.Health <= 0 then continue end

		-- KILL AURA
		local dist = (hrp.Position - bossHRP.Position).Magnitude
		if player:GetAttribute("KillAura") == true then
			if dist <= KILL_RANGE then
				hum.Health = 0
			end
		end

		-- AUTO HOVER
		if player:GetAttribute("AutoHover") == true then
			local dir = (hrp.Position - bossHRP.Position).Unit
			if dir.Magnitude == 0 then
				dir = bossHRP.CFrame.LookVector
			end

			local targetPos =
				bossHRP.Position
				+ dir * HOVER_DISTANCE
				+ Vector3.new(0, HOVER_HEIGHT, 0)

			local cf = CFrame.new(targetPos, bossHRP.Position)
			hrp.CFrame = hrp.CFrame:Lerp(cf, HOVER_LERP)
		end

		-- AUTO AIM + AUTO Z
		if player:GetAttribute("AutoZ") == true then
			hrp.CFrame = CFrame.new(hrp.Position, bossHRP.Position)
			SniperCombat:UseZ(player)
		end
	end
end)

----------------------------------------------------------------
-- AUTO QUEST (KHÔNG TELE)
----------------------------------------------------------------
if ReplicatedStorage:FindFirstChild("Remotes")
and ReplicatedStorage.Remotes:FindFirstChild("AcceptQuest") then
	local QuestRemote = ReplicatedStorage.Remotes.AcceptQuest

	Players.PlayerAdded:Connect(function(player)
		player:SetAttribute("AutoQuest", true)
	end)

	RunService.Heartbeat:Connect(function()
		for _, player in pairs(Players:GetPlayers()) do
			if player:GetAttribute("AutoQuest") == true then
				QuestRemote:FireServer(BOSS_NAME)
			end
		end
	end)
end

----------------------------------------------------------------
-- DEFAULT ATTRIBUTES
----------------------------------------------------------------
Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("AutoZ", false)
	player:SetAttribute("AutoHover", false)
	player:SetAttribute("KillAura", false)
	player:SetAttribute("AutoQuest", true)
end)
