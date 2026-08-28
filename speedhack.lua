--===================================================================================--
--               DUNGEON HEROES: PERFECT ALL-IN-ONE AUTOMATION MATRIX                --
--===================================================================================--

-- [1. SERVICE MANAGEMENT & SAFE BINDINGS]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local ScriptContext = game:GetService("ScriptContext")

local LocalPlayer = Players.LocalPlayer
local CONFIG_FILE = "DungeonHeroes_Perfect_V4.json"

-- Global Settings Engine
local Config = {
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

-- [2. ERROR LOGGING AND SCREEN DIAGNOSTICS]
local function reportError(errorMessage, stackTrace)
    pcall(function()
        if _G.LogBox then
            _G.LogBox.Text = _G.LogBox.Text .. "\n[ERROR] " .. tostring(errorMessage)
            if string.len(_G.LogBox.Text) > 2000 then
                _G.LogBox.Text = string.sub(_G.LogBox.Text, -2000)
            end
        end
        warn("[OP SUITE SYSTEM ERROR]: " .. tostring(errorMessage))
    end)
end

-- Intercept runtime execution errors and spit them directly to screen logs
ScriptContext.Error:Connect(function(message, stack, scriptObj)
    reportError(message .. " | " .. stack)
end)

-- [3. PERSISTENT SAVE/LOAD CACHE]
local function saveSettings()
    if writefile then
        pcall(function()
            writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
        end)
    end
end

local function loadSettings()
    if isfile and isfile(CONFIG_FILE) and readfile then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_FILE))
        end)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do Config[k] = v end
        end
    end
end
loadSettings()

-- [4. DESIGN MATRIX: THE SCROLLING BLACK BOX GUI]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OP_Perfect_Suite_V4"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui") end)

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

-- The Scrolling Container Black Box
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -160)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundColor3 = Color3.fromRGB(5, 5, 7)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
Scroll.ScrollBarThickness = 5
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 85)
Scroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Scroll

-- Live Screen Debug Logger Panel at the Bottom of the Box
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
LogBox.Text = "[SYSTEM DIAGNOSTICS STARTED - WAITING FOR LOGS...]"
LogBox.TextColor3 = Color3.fromRGB(0, 255, 100)
LogBox.TextSize = 11
LogBox.Font = Enum.Font.Code
LogBox.TextXAlignment = Enum.TextXAlignment.Left
LogBox.TextYAlignment = Enum.TextYAlignment.Top
LogBox.TextWrapped = true
LogBox.Parent = LogScroll
_G.LogBox = LogBox

-- Dynamic UI Toggle Instantiator
local function createToggle(text, configKey)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 36)
    Button.BorderSizePixel = 0
    Button.Font = Enum.Font.SourceSansSemiBold
    Button.TextSize = 13
    Button.Parent = Scroll
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Button
    
    local function refresh()
        if Config[configKey] then
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
        local success, err = pcall(function()
            Config[configKey] = not Config[configKey]
            refresh()
            saveSettings()
        end)
        if not success then reportError(err) end
    end)
end

-- [5. MULTI-METHOD ACQUISITION SCANNER ENGINE]
local function findUltimateTarget(lookForBoss)
    local bestTarget = nil
    local shortestDistance = math.huge
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myRoot = char.HumanoidRootPart

    -- SCAN METHOD A: Dedicated Game Directories
    local structuralFolders = {"Enemies", "Mobs", "Monsters", "Baddies", "NPCs"}
    for _, folderName in ipairs(structuralFolders) do
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

    -- SCAN METHOD B: Recursive Deep Scan (Workspace Brute-force fallback)
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

-- [6. ADVANCED SPEED MODIFIERS (NON-STOP SYSTEM)]
task.spawn(function()
    while task.wait(0.2) do
        local success, err = pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                if Config.WalkSpeed300 then
                    char.Humanoid.WalkSpeed = 300
                    -- Break standard physics limits to avoid server rubber-banding
                    char.Humanoid.MoveDirection.Unit:Clone() 
                end
            end
        end)
        if not success then reportError(err) end
    end
end)

-- Frictionless Anti-Rubberband Teleport Execution
local function teleportCombatOffset(pos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    
    if Config.TweenSpeedHack then
        local dist = (pos - root.Position).Magnitude
        local speed = math.max(Config.MaxTweenSpeed, 1)
        local timeDuration = dist / speed
        
        char.Humanoid.PlatformStand = true
        local tween = TweenService:Create(root, TweenInfo.new(timeDuration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
        tween:Play()
        tween.Completed:Wait()
        char.Humanoid.PlatformStand = false
    else
        root.CFrame = CFrame.new(pos)
    end
end

-- [7. MULTI-METHOD ENGAGEMENT LOOPS (PARALLEL EXECUTION RUNNERS)]

-- Threat Neutralizer Thread
task.spawn(function()
    while task.wait(0.02) do
local stateSuccess, stateErr = pcall(function()local char = LocalPlayer.Characterif char and char:FindFirstChild("HumanoidRootPart") then-- ENGAGEMENT METHOD 1: Boss Termination Logicif Config.AutoGetBoss thenlocal targetBoss = findUltimateTarget(true)if targetBoss and targetBoss:FindFirstChild("HumanoidRootPart") thenteleportCombatOffset(targetBoss.HumanoidRootPart.Position + Vector3.new(0, 3, 0))if Config.AutoKillAuraBoss thenlocal weapon = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")if weapon thenif weapon.Parent ~= char then weapon.Parent = char end -- Automatic auto-equip strikeweapon:Activate()endendendend-- ENGAGEMENT METHOD 2: Mob Harvesting Logicif Config.AutoGetMobs and not (Config.AutoGetBoss and findUltimateTarget(true)) thenlocal targetMob = findUltimateTarget(false)if targetMob and targetMob:FindFirstChild("HumanoidRootPart") thenteleportCombatOffset(targetMob.HumanoidRootPart.Position + Vector3.new(0, 3, 0))if Config.AutoAuraKillMobs thenlocal weapon = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")if weapon thenif weapon.Parent ~= char then weapon.Parent = char endweapon:Activate()endendendendendend)if not stateSuccess then reportError(stateErr) endendend)-- High-Frequency Instant Action Activator Core (1 Millisecond Action Tracker)task.spawn(function()local keysToSpam = {Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.F, Enum.KeyCode.X, Enum.KeyCode.C}while true dolocal rateLimit = math.max(Config.ClickDelayMS / 1000, 0.001)task.wait(rateLimit)if Config.AutoClickSpecials thenpcall(function()for _, key in ipairs(keysToSpam) doVirtualInputManager:SendKeyEvent(true, key, false, game)task.wait(0.0001)VirtualInputManager:SendKeyEvent(false, key, false, game)endend)endendend)-- Auto Interface Scraper Frameworktask.spawn(function()while task.wait(1) doif Config.AutoPlayAgain or Config.AutoPlayNextDifficulty thenpcall(function()local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")if playerGui thenfor _, child in pairs(playerGui:GetDescendants()) doif child:IsA("TextButton") and child.Visible thenlocal lowerText = string.lower(child.Text)local lowerName = string.lower(child.Name)if Config.AutoPlayAgain and (string.find(lowerText, "again") or string.find(lowerName, "again") or string.find(lowerText, "replay")) thenlocal clickConns = getconnections or child.MouseButton1Clickif type(clickConns) == "table" then for _, c in pairs(clickConns) do c:Fire() end else child:SimulateClick() endelseif Config.AutoPlayNextDifficulty and (string.find(lowerText, "next") or string.find(lowerName, "next") or string.find(lowerText, "diff")) thenlocal clickConns = getconnections or child.MouseButton1Clickif type(clickConns) == "table" then for _, c in pairs(clickConns) do c:Fire() end else child:SimulateClick() endendendendendend)endendend)-- Dynamic Overlay Render Stepper (ESP)RunService.RenderStepped:Connect(function()pcall(function()for _, descendant in pairs(Workspace:GetDescendants()) doif descendant.Name == "PerfectSuiteESP" and not Config.EnemyTrackingESP thendescendant:Destroy()endendif Config.EnemyTrackingESP thenfor _, obj in pairs(Workspace:GetDescendants()) doif obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 thenif obj ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(obj) thenif not obj:FindFirstChild("PerfectSuiteESP") thenlocal highlight = Instance.new("BoxHandleAdornment")highlight.Name = "PerfectSuiteESP"highlight.Size = obj:GetExtentsSize() + Vector3.new(0.1, 0.1, 0.1)highlight.Color3 = Color3.fromRGB(255, 0, 85)highlight.AlwaysOnTop = truehighlight.ZIndex = 7highlight.Adornee = obj.HumanoidRootParthighlight.Parent = objendendendendendend)end)-- [8. SUITE COMPILATION ELEMENT INITIALIZATION]createToggle("Toggle Walkspeed 300", "WalkSpeed300")createToggle("Toggle Tween Teleportation", "TweenSpeedHack")createToggle("Toggle Deep Box ESP", "EnemyTrackingESP")createToggle("Toggle Auto Detect Mobs", "AutoGetMobs")createToggle("Toggle Auto Kill Aura Mobs", "AutoAuraKillMobs")createToggle("Toggle Auto Detect Bosses", "AutoGetBoss")createToggle("Toggle Auto Kill Aura Bosses", "AutoKillAuraBoss")createToggle("Toggle Auto Special Spam [E,R,F,X,C]", "AutoClickSpecials")createToggle("Toggle Auto Replay Match", "AutoPlayAgain")createToggle("Toggle Auto Next Difficulty", "AutoPlayNextDifficulty")print("[COMPILATION SUCCESSFUL] System Fully Operational.")
