--===================================================================================--
--               DUNGEON HEROES AUTOMATION MATRIX - PART 1 OF 2                      --
--===================================================================================--

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local CONFIG_FILE = "DungeonHeroes_Perfect_V4.json"

-- Clear old UI if it exists
if _G.OPSuite and _G.OPSuite.Gui then _G.OPSuite.Gui:Destroy() end

-- Global Setup Holder
_G.OPSuite = {}
_G.OPSuite.Config = {
    TweenSpeedHack = false,
    MaxTweenSpeed = 100,
    WalkSpeed300 = false,
    EnemyTrackingESP = false,
    AutoGetMobs = false,
    AutoAuraKillMobs = false,
    AutoGetBoss = false,
    AutoKillAuraBoss = false,
    AutoClickSpecials = false,
    AutoPlayAgain = false,
    AutoPlayNextDifficulty = false,
    ClickDelayMS = 1
}

local function saveSettings()
    if writefile then
        pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(_G.OPSuite.Config)) end)
    end
end

local function loadSettings()
    if isfile and isfile(CONFIG_FILE) and readfile then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do _G.OPSuite.Config[k] = v end
        end
    end
end
loadSettings()

-- GUI Initialization
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OP_Perfect_Suite_V4"
ScreenGui.ResetOnSpawn = false
local pSuccess = pcall(function() ScreenGui.Parent = CoreGui end)
if not pSuccess then pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end
_G.OPSuite.Gui = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 85)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "★ DUNGEON HEROES MASTER HARVESTER ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -160)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundColor3 = Color3.fromRGB(5, 5, 7)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
Scroll.ScrollBarThickness = 5
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 85)
Scroll.Parent = MainFrame
_G.OPSuite.ScrollContainer = Scroll

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Scroll

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -20, 0, 100)
LogScroll.Position = UDim2.new(0, 10, 1, -110)
LogScroll.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LogScroll.BorderSizePixel = 1
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 1000)
LogScroll.Parent = MainFrame

local LogBox = Instance.new("TextLabel")
LogBox.Size = UDim2.new(1, -10, 1, 0)
LogBox.BackgroundTransparency = 1
LogBox.Text = "[PART 1 SUCCESSFUL - RUN PART 2 NEXT]"
LogBox.TextColor3 = Color3.fromRGB(0, 255, 100)
LogBox.TextSize = 11
LogBox.Font = Enum.Font.Code
LogBox.TextXAlignment = Enum.TextXAlignment.Left
LogBox.TextYAlignment = Enum.TextYAlignment.Top
LogBox.TextWrapped = true
LogBox.Parent = LogScroll
_G.LogBox = LogBox

function _G.OPSuite.createToggle(text, configKey)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 36)
    Button.BorderSizePixel = 0
    Button.Font = Enum.Font.SourceSansSemiBold
    Button.TextSize = 13
    Button.Parent = _G.OPSuite.ScrollContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Button
    
    local function refresh()
        if _G.OPSuite.Config[configKey] then
            Button.BackgroundColor3 = Color3.fromRGB(255, 0, 85)
            Button.Text = text .. " : ACTIVE"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Button.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            Button.Text = text .. " : INACTIVE"
            Button.TextColor3 = Color3.fromRGB(140, 140, 140)
        end
    end
    refresh()
    
    Button.MouseButton1Click:Connect(function()
        pcall(function()
            _G.OPSuite.Config[configKey] = not _G.OPSuite.Config[configKey]
            refresh()
            saveSettings()
        end)
    end)
end

print("[PART 1] Interface initialized. Waiting for Part 2...")
--===================================================================================--
--               DUNGEON HEROES AUTOMATION MATRIX - PART 2 OF 2                      --
--===================================================================================--

if not _G.OPSuite or not _G.OPSuite.Config then
    warn("ERROR: Please run Part 1 before executing Part 2!")
    return
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Config = _G.OPSuite.Config

local function reportError(msg)
    pcall(function()
        if _G.LogBox then _G.LogBox.Text = _G.LogBox.Text .. "\n[ERROR] " .. tostring(msg) end
    end)
end

-- Target Finder Engine
local function findUltimateTarget(lookForBoss)
    local bestTarget = nil
    local shortestDistance = math.huge
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myRoot = char.HumanoidRootPart

    local structuralFolders = {"Enemies", "Mobs", "Monsters", "Baddies", "NPCs"}
    for _, folderName in ipairs(structuralFolders) do
        local directory = Workspace:FindFirstChild(folderName)
        if directory then
            for _, obj in pairs(directory:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj.Humanoid.Health > 0 then
                    local isBoss = obj:SetAttribute("Boss") or string.find(string.lower(obj.Name), "boss")
                    if (lookForBoss and isBoss) or (not lookForBoss and not isBoss) then
                        local dist = (obj.HumanoidRootPart.Position - myRoot.Position).Magnitude
                        if dist < shortestDistance then shortestDistance = dist bestTarget = obj end
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
                        if dist < shortestDistance then shortestDistance = dist bestTarget = obj end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Speed Loop
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

-- Teleport Engine
local function teleportCombatOffset(pos)
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

-- Main Combat Automation
task.spawn(function()
    while task.wait(0.02) do
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if Config.AutoGetBoss then
                    local targetBoss = findUltimateTarget(true)
                    if targetBoss and targetBoss:FindFirstChild("HumanoidRootPart") then
                        teleportCombatOffset(targetBoss.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                        if Config.AutoKillAuraBoss then
                            local weapon = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if weapon then if weapon.Parent ~= char then weapon.Parent = char end weapon:Activate() end
                        end
                    end
                end
                
                if Config.AutoGetMobs and not (Config.AutoGetBoss and findUltimateTarget(true)) then
                    local targetMob = findUltimateTarget(false)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        teleportCombatOffset(targetMob.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                        if Config.AutoAuraKillMobs then
                            local weapon = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if weapon then if weapon.Parent ~= char then weapon.Parent = char end weapon:Activate() end
                        end
                    end
                end
            end
        end)
    end
end)

-- Ability Clicker
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

-- Screen UI Auto-Scraper (Play Again)
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

-- ESP Engine
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

-- Build the Buttons
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
print("[PART 2] Completed successfully.")
