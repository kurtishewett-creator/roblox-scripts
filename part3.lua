--===================================================================================--
--               DUNGEON HEROES AUTOMATION MATRIX - PART 3 OF 3                      --
--===================================================================================--

if not _G.OPSuite or not _G.OPSuite.findUltimateTarget then
    warn("CRITICAL ERROR: Run Parts 1 and 2 before running Part 3!")
    return
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Config = _G.OPSuite.Config

-- Main Harvest Combat Loop
task.spawn(function()
    while task.wait(0.02) do
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if Config.AutoGetBoss then
                    local targetBoss = _G.OPSuite.findUltimateTarget(true)
                    if targetBoss and targetBoss:FindFirstChild("HumanoidRootPart") then
                        _G.OPSuite.teleportCombatOffset(targetBoss.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                        if Config.AutoKillAuraBoss then
                            local weapon = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if weapon then 
                                if weapon.Parent ~= char then weapon.Parent = char end 
                                weapon:Activate() 
                            end
                        end
                    end
                end
                
                if Config.AutoGetMobs and not (Config.AutoGetBoss and _G.OPSuite.findUltimateTarget(true)) then
                    local targetMob = _G.OPSuite.findUltimateTarget(false)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        _G.OPSuite.teleportCombatOffset(targetMob.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                        if Config.AutoAuraKillMobs then
                            local weapon = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if weapon then 
                                if weapon.Parent ~= char then weapon.Parent = char end 
                                weapon:Activate() 
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Multi-Key High Frequency Clicker
task.spawn(function()
    local keysToSpam = {Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.F, Enum.KeyCode.X, Enum.KeyCode.C}
    while true do
        task.wait(math.max(Config.ClickDelayMS / 1000, 0.001))
        if Config.AutoClickSpecials then
            pcall(function()
                for _, key in ipairs(keysToSpam) do
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    task.wait(0.0001)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end
            end)
        end
    end
end)

-- Screen Auto Re-Queuer
task.spawn(function()
    while task.wait(1) do
        if Config.AutoPlayAgain or Config.AutoPlayNextDifficulty then
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                if playerGui then
                    for _, child in pairs(playerGui:GetDescendants()) do
                        if child:IsA("TextButton") and child.Visible then
                            local lowerText = string.lower(child.Text)
                            local lowerName = string.lower(child.Name)
                            if Config.AutoPlayAgain and (string.find(lowerText, "again") or string.find(lowerName, "again") or string.find(lowerText, "replay")) then
                                local click = getconnections or child.MouseButton1Click
                                if type(click) == "table" then for _, c in pairs(click) do c:Fire() end else child:SimulateClick() end
                            elseif Config.AutoPlayNextDifficulty and (string.find(lowerText, "next") or string.find(lowerName, "next") or string.find(lowerText, "diff")) then
                                local click = getconnections or child.MouseButton1Click
                                if type(click) == "table" then for _, c in pairs(click) do c:Fire() end else child:SimulateClick() end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Render-Stepped Box Tracker (ESP)
RunService.RenderStepped:Connect(function()
    pcall(function()
        for _, descendant in pairs(Workspace:GetDescendants()) do
            if descendant.Name == "PerfectSuiteESP" and not Config.EnemyTrackingESP then descendant:Destroy() end
        end
        if Config.EnemyTrackingESP then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                    if obj ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(obj) then
                        if not obj:FindFirstChild("PerfectSuiteESP") then
                            local highlight = Instance.new("BoxHandleAdornment")
                            highlight.Name = "PerfectSuiteESP"
                            highlight.Size = obj:GetExtentsSize() + Vector3.new(0.1, 0.1, 0.1)
                            highlight.Color3 = Color3.fromRGB(255, 0, 85)
                            highlight.AlwaysOnTop = true
                            highlight.ZIndex = 7
                            highlight.Adornee = obj.HumanoidRootPart
                            highlight.Parent = obj
                        end
                    end
                end
            end
        end
    end)
end)

-- Button Compiler Elements Injection
_G.OPSuite.createToggle("Toggle Walkspeed 300", "WalkSpeed300")
_G.OPSuite.createToggle("Toggle Tween Teleportation", "TweenSpeedHack")
_G.OPSuite.createToggle("Toggle Deep Box ESP", "EnemyTrackingESP")
_G.OPSuite.createToggle("Toggle Auto Detect Mobs", "AutoGetMobs")
_G.OPSuite.createToggle("Toggle Auto Kill Aura Mobs", "AutoAuraKillMobs")
_G.OPSuite.createToggle("Toggle Auto Detect Bosses", "AutoGetBoss")
_G.OPSuite.createToggle("Toggle Auto Kill Aura Bosses", "AutoKillAuraBoss")
_G.OPSuite.createToggle("Toggle Auto Special Spam [E,R,F,X,C]", "AutoClickSpecials")
_G.OPSuite.createToggle("Toggle Auto Replay Match", "AutoPlayAgain")
_G.OPSuite.createToggle("Toggle Auto Next Difficulty", "AutoPlayNextDifficulty")

if _G.LogBox then _G.LogBox.Text = "[SYSTEM FULLY OPERATIONAL AND ARMED]" end
print("[PART 3] Script activation successful.")
