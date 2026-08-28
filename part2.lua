--===================================================================================--
--               DUNGEON HEROES AUTOMATION MATRIX - PART 2 OF 3                      --
--===================================================================================--

if not _G.OPSuite or not _G.OPSuite.Config then
    warn("CRITICAL ERROR: Run Part 1 before running Part 2!")
    return
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Config = _G.OPSuite.Config

-- Target Finder Engine
function _G.OPSuite.findUltimateTarget(lookForBoss)
    local bestTarget = nil
    local shortestDistance = math.huge
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myRoot = char.HumanoidRootPart

    local folders = {"Enemies", "Mobs", "Monsters", "Baddies", "NPCs"}
    for _, folderName in ipairs(folders) do
        local directory = Workspace:FindFirstChild(folderName)
        if directory then
            for _, obj in pairs(directory:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj.Humanoid.Health > 0 then
                    local isBoss = obj:SetAttribute("Boss") or string.find(string.lower(obj.Name), "boss")
                    if (lookForBoss and isBoss) or (not lookForBoss and not isBoss) then
                        local dist = (obj.HumanoidRootPart.Position - myRoot.Position).Magnitude
                        if dist < shortestDistance then 
                            shortestDistance = dist 
                            bestTarget = obj 
                        end
                    end
                end
            end
        end
    end

    if not bestTarget then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj.Humanoid.Health > 0 then
                if obj ~= char and not Players:GetPlayerFromCharacter(obj) then
                    local isBoss = obj:SetAttribute("Boss") or string.find(string.lower(obj.Name), "boss")
                    if (lookForBoss and isBoss) or (not lookForBoss and not isBoss) then
                        local dist = (obj.HumanoidRootPart.Position - myRoot.Position).Magnitude
                        if dist < shortestDistance then 
                            shortestDistance = dist 
                            bestTarget = obj 
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Walkspeed System Loop
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and Config.WalkSpeed300 then
                char.Humanoid.WalkSpeed = 300
            end
        end)
    end
end)

-- Teleport Engine Vector Offset 
function _G.OPSuite.teleportCombatOffset(pos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    
    if Config.TweenSpeedHack then
        local dist = (pos - root.Position).Magnitude
        local duration = dist / math.max(Config.MaxTweenSpeed, 1)
        char.Humanoid.PlatformStand = true
        local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
        tween:Play()
        tween.Completed:Wait()
        char.Humanoid.PlatformStand = false
    else
        root.CFrame = CFrame.new(pos)
    end
end

if _G.LogBox then _G.LogBox.Text = "[PART 2 SUCCESSFUL - PROCEED TO RUN PART 3]" end
print("[PART 2] Target engines loaded successfully.")
