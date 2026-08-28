if not getgenv().OPSuite or not getgenv().OPSuite.findUltimateTarget then
    warn("CRITICAL ERROR: Run Parts 1 and 2 before running Part 3!")
    return
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Config = getgenv().OPSuite.Config

task.spawn(function()
    while task.wait(0.02) do
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if Config.AutoGetBoss then
                    local targetBoss = getgenv().OPSuite.findUltimateTarget(true)
                    if targetBoss and targetBoss:FindFirstChild("HumanoidRootPart") then
                        getgenv().OPSuite.teleportCombatOffset(targetBoss.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                        if Config.AutoKillAuraBoss then
                            local weapon = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if weapon then 
                                if weapon.Parent ~= char then weapon.Parent = char end 
                                weapon:Activate() 
                            end
                        end
                    end
                end
                
                if Config.AutoGetMobs and not (Config.AutoGetBoss and getgenv().OPSuite.findUltimateTarget(true)) then
                    local targetMob = getgenv().OPSuite.findUltimateTarget(false)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        getgenv().OPSuite.teleportCombatOffset(targetMob.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
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
                                pcall(function() child.MouseButton1Click:Fire() end)
                            elseif Config.AutoPlayNextDifficulty and (string.find(lowerText, "next") or string.find(lowerName, "next") or string.find(lowerText, "diff")) then
                                pcall(function() child.MouseButton1Click:Fire() end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

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

getgenv().OPSuite.createToggle("Toggle Walkspeed 300", "WalkSpeed300")
getgenv().OPSuite.createToggle("Toggle Tween Teleportation", "TweenSpeedHack")
getgenv().OPSuite.createToggle("Toggle Deep Box ESP", "EnemyTrackingESP")
getgenv().OPSuite.createToggle("Toggle Auto Detect Mobs", "AutoGetMobs")
getgenv().OPSuite.createToggle("Toggle Auto Kill Aura Mobs", "AutoAuraKillMobs")
getgenv().OPSuite.createToggle("Toggle Auto Detect Bosses", "AutoGetBoss")
getgenv().OPSuite.createToggle("Toggle Auto Kill Aura Bosses", "AutoKillAuraBoss")
getgenv().OPSuite.createToggle("Toggle Auto Special Spam [E,R,F,X,C]", "AutoClickSpecials")
getgenv().OPSuite.createToggle("Toggle Auto Replay Match", "AutoPlayAgain")
getgenv().OPSuite.createToggle("Toggle Auto Next Difficulty", "AutoPlayNextDifficulty")

if getgenv().LogBox then getgenv().LogBox.Text = "[SYSTEM FULLY OPERATIONAL AND ARMED]" end
