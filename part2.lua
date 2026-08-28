-- Part 2: Combat Automation, 1ms Skills, Screen Toggles, and Commands Interface
if _G.DungeonMasterPart2 then print("Part 2 already running!") return end
_G.DungeonMasterPart2 = true

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Wait briefly for Part 1 to boot up dependencies
repeat task.wait(0.5) until _G.Config and _G.TweenTo

-- --- WORKER PIPELINE 1: COMBAT MOTION & KILL AURA ENGINE ---
task.spawn(function()
    while true do
        task.wait()
        local char = _G.GetCharacter()
        local tool = char and char:FindFirstChildOfClass("Tool")
        
        local target = nil
        if _G.Config.AutoKillBosses then target = _G.GetClosestEnemy(true) end
        if not target and _G.Config.AutoKillMobs then target = _G.GetClosestEnemy(false) end
        
        if target and char and char:FindFirstChild("HumanoidRootPart") then
            local enemyRoot = target:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                _G.TweenTo(enemyRoot.Position + Vector3.new(0, 4, 0))
                
                local distance = (char.HumanoidRootPart.Position - enemyRoot.Position).Magnitude
                if distance <= _G.Config.KillAuraRange and tool then
                    tool:Activate()
                    if firetouchinterest then
                        for _, part in pairs(target:GetChildren()) do
                            if part:IsA("BasePart") then
                                firetouchinterest(tool.Handle, part, 0)
                                task.wait()
                                firetouchinterest(tool.Handle, part, 1)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- --- WORKER PIPELINE 2: 1-MILLISECOND ABILITY SPAM ENGINE (E, R, F, X, C) ---
local ActionKeys = {"E", "R", "F", "X", "C"}
task.spawn(function()
    while true do
        task.wait(0.001)
        if _G.Config.AutoClickSpecials then
            for _, keyStr in ipairs(ActionKeys) do
                local keyCode = Enum.KeyCode[keyStr]
                VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                task.wait(0.0005)
                VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
            end
        end
    end
end)

-- --- WORKER PIPELINE 3: STAGE CONTINUATION & UI AUTOMATION ---
task.spawn(function()
    while true do
        task.wait(1)
        local localGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if localGui then
            for _, element in pairs(localGui:GetDescendants()) do
                if element:IsA("TextButton") and element.Visible then
                    local text = string.lower(element.Text)
                    if _G.Config.AutoPlayAgain and (string.find(text, "again") or string.find(text, "retry")) then
                        firesignal(element.MouseButton1Click)
                    elseif _G.Config.AutoNextDifficulty and (string.find(text, "next") or string.find(text, "difficult")) then
                        firesignal(element.MouseButton1Click)
                    end
                end
            end
        end
    end
end)

-- --- INTEGRATED CHAT-COMMAND CONFIGURATION MATRIX ---
local function ProcessCommand(msg)
    local args = string.split(string.lower(msg), " ")
    if args[1] == "/mobs" then
        _G.Config.AutoKillMobs = (args[2] == "on")
        _G.SaveConfig()
        print("AutoKillMobs: " .. tostring(_G.Config.AutoKillMobs))
    elseif args[1] == "/boss" then
        _G.Config.AutoKillBosses = (args[2] == "on")
        _G.SaveConfig()
        print("AutoKillBosses: " .. tostring(_G.Config.AutoKillBosses))
    elseif args[1] == "/speed" then
        local targetVal = tonumber(args[2])
        if targetVal then
            _G.Config.TweenSpeed = math.clamp(targetVal, 1, 100)
            _G.SaveConfig()
            print("Movement Speed: " .. _G.Config.TweenSpeed)
        end
    elseif args[1] == "/skills" then
        _G.Config.AutoClickSpecials = (args[2] == "on")
        _G.SaveConfig()
        print("Skills Macro: " .. tostring(_G.Config.AutoClickSpecials))
    elseif args[1] == "/esp" then
        _G.Config.ESPEnabled = (args[2] == "on")
        _G.SaveConfig()
        print("Target ESP: " .. tostring(_G.Config.ESPEnabled))
    elseif args[1] == "/retry" then
        _G.Config.AutoPlayAgain = (args[2] == "on")
        _G.SaveConfig()
        print("Auto Retry: " .. tostring(_G.Config.AutoPlayAgain))
    elseif args[1] == "/next" then
        _G.Config.AutoNextDifficulty = (args[2] == "on")
        _G.SaveConfig()
        print("Auto Next Difficulty: " .. tostring(_G.Config.AutoNextDifficulty))
    end
end

LocalPlayer.Chatted:Connect(ProcessCommand)
print("[PART 2 SYSTEM] Automation loops active. Script fully deployed!")
