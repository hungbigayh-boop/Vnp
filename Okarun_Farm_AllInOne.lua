-- Vietnam Piece - Okarun Farm GUI (All-in-One)
-- Features:
-- Tele High to Boss, Aimbot Boss, Kill Aura Boss, Reduce Cooldown (Z), Auto Skill Z (Sniper Combat)

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

--// TARGET
local BOSS_NAME = "Okarun"

--// SETTINGS (safe defaults)
local TELE_HEIGHT = 20
local KILL_RANGE = 20
local DAMAGE = 999999
local Z_DELAY = 0.15
local COOLDOWN_MULTI = 15 -- 10–20 recommended

--// STATES
local teleBoss = false
local aimbot = false
local killAura = false
local autoZ = false
local noCooldown = false

local lastHit = 0
local lastZ = 0

--// NO COOLDOWN
local oldClock = os.clock

--// GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "OkarunFarmGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 260)
frame.Position = UDim2.new(0, 20, 0, 180)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true

local function makeBtn(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -20, 0, 40)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(55,55,55)
    b.TextColor3 = Color3.new(1,1,1)
    b.BorderSizePixel = 0
    return b
end

local teleBtn = makeBtn("Tele Boss (High): OFF", 10)
local aimBtn  = makeBtn("Aimbot Boss: OFF", 60)
local auraBtn = makeBtn("Kill Aura Boss: OFF", 110)
local cdBtn   = makeBtn("Reduce Cooldown Z: OFF", 160)
local zBtn    = makeBtn("Auto Skill Z: OFF", 210)

teleBtn.MouseButton1Click:Connect(function()
    teleBoss = not teleBoss
    teleBtn.Text = "Tele Boss (High): " .. (teleBoss and "ON" or "OFF")

    if teleBoss then
        local boss = workspace:FindFirstChild(BOSS_NAME, true)
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            local char = player.Character or player.CharacterAdded:Wait()
            char:WaitForChild("HumanoidRootPart").CFrame =
                boss.HumanoidRootPart.CFrame * CFrame.new(0, TELE_HEIGHT, 0)
        end
    end
end)

aimBtn.MouseButton1Click:Connect(function()
    aimbot = not aimbot
    aimBtn.Text = "Aimbot Boss: " .. (aimbot and "ON" or "OFF")
end)

auraBtn.MouseButton1Click:Connect(function()
    killAura = not killAura
    auraBtn.Text = "Kill Aura Boss: " .. (killAura and "ON" or "OFF")
end)

cdBtn.MouseButton1Click:Connect(function()
    noCooldown = not noCooldown
    cdBtn.Text = "Reduce Cooldown Z: " .. (noCooldown and "ON" or "OFF")

    if noCooldown then
        hookfunction(os.clock, function()
            return oldClock() * COOLDOWN_MULTI
        end)
    else
        hookfunction(os.clock, oldClock)
    end
end)

zBtn.MouseButton1Click:Connect(function()
    autoZ = not autoZ
    zBtn.Text = "Auto Skill Z: " .. (autoZ and "ON" or "OFF")
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local boss = workspace:FindFirstChild(BOSS_NAME, true)

    if aimbot and boss and boss:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, boss.HumanoidRootPart.Position)
    end

    if killAura and boss and boss:FindFirstChild("Humanoid") then
        local bhrp = boss:FindFirstChild("HumanoidRootPart")
        if bhrp and (hrp.Position - bhrp.Position).Magnitude <= KILL_RANGE then
            if tick() - lastHit > 0.1 then
                lastHit = tick()
                boss.Humanoid:TakeDamage(DAMAGE)
            end
        end
    end

    if autoZ and tick() - lastZ >= Z_DELAY then
        lastZ = tick()
        VirtualInput:SendKeyEvent(true, "Z", false, game)
        task.wait()
        VirtualInput:SendKeyEvent(false, "Z", false, game)
    end
end)
