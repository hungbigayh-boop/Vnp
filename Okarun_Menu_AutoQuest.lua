-- Vietnam Piece - Okarun Farm Menu
-- Menu features:
-- Auto Quest (template), Tele High to Boss, Aimbot Boss, Kill Aura Boss, Reduce Cooldown Z, Auto Skill Z

if _G.OKARUN_MENU then return end
_G.OKARUN_MENU = true

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

--// TARGET
local BOSS_NAME = "Okarun"

--// SETTINGS
local TELE_HEIGHT = 20
local KILL_RANGE = 20
local DAMAGE = 999999
local Z_DELAY = 0.15
local COOLDOWN_MULTI = 15

--// STATES
local autoQuest = false
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
local gui = Instance.new("ScreenGui")
gui.Name = "OkarunMenu"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 320)
frame.Position = UDim2.new(0, 20, 0, 160)
frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "OKARUN FARM MENU"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local function makeBtn(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -20, 0, 38)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(55,55,55)
    b.TextColor3 = Color3.new(1,1,1)
    b.BorderSizePixel = 0
    return b
end

local qBtn  = makeBtn("Auto Quest: OFF", 50)
local tBtn  = makeBtn("Tele Boss (High): OFF", 95)
local aBtn  = makeBtn("Aimbot Boss: OFF", 140)
local kBtn  = makeBtn("Kill Aura Boss: OFF", 185)
local cBtn  = makeBtn("Reduce Cooldown Z: OFF", 230)
local zBtn  = makeBtn("Auto Skill Z: OFF", 275)

qBtn.MouseButton1Click:Connect(function()
    autoQuest = not autoQuest
    qBtn.Text = "Auto Quest: " .. (autoQuest and "ON" or "OFF")
end)

tBtn.MouseButton1Click:Connect(function()
    teleBoss = not teleBoss
    tBtn.Text = "Tele Boss (High): " .. (teleBoss and "ON" or "OFF")
    if teleBoss then
        local boss = workspace:FindFirstChild(BOSS_NAME, true)
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            local char = player.Character or player.CharacterAdded:Wait()
            char:WaitForChild("HumanoidRootPart").CFrame =
                boss.HumanoidRootPart.CFrame * CFrame.new(0, TELE_HEIGHT, 0)
        end
    end
end)

aBtn.MouseButton1Click:Connect(function()
    aimbot = not aimbot
    aBtn.Text = "Aimbot Boss: " .. (aimbot and "ON" or "OFF")
end)

kBtn.MouseButton1Click:Connect(function()
    killAura = not killAura
    kBtn.Text = "Kill Aura Boss: " .. (killAura and "ON" or "OFF")
end)

cBtn.MouseButton1Click:Connect(function()
    noCooldown = not noCooldown
    cBtn.Text = "Reduce Cooldown Z: " .. (noCooldown and "ON" or "OFF")
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

--// MAIN LOOP
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local boss = workspace:FindFirstChild(BOSS_NAME, true)

    -- Auto Quest (template - game-specific remotes needed)
    if autoQuest then
        -- Place your Quest RemoteEvent logic here (varies by game)
    end

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
