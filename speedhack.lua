--===================================================================================--
--                DUNGEON HEROES: ULTIMATE COMBAT & AUTOMATION SUITE                 --
--===================================================================================--

-- [1. SERVICE INITIALIZATION]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local CONFIG_FILE = "DungeonHeroes_OP_Suite.json"

-- [2. CONFIGURATION PERSISTENCE MATRIX]
local Config = {
    TweenSpeedHack = false,
    MaxTweenSpeed = 100,
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
            for k, v in pairs(decoded) do
                Config[k] = v
            end
        end
    end
end

loadSettings()

-- [3. SCREEN GUI INTERACTIVE HUB]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OPSuiteGui"
ScreenGui.ResetOnSpawn = false
-- Safe check to inject into CoreGui to bypass standard UI detection
pcall(function() ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui") end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UUDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Allows mobile drag positioning
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(85, 0, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "★ DUNGEON HEROES SYSTEM V4 ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -60)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 520)
Scroll.ScrollBarThickness = 4
Scroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Scroll

-- Compact UI Toggle Generator Function
local function createToggle(text, configKey, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 40)
    Button.BorderSizePixel = 0
    Button.Font = Enum.Font.SourceSansSemiBold
    Button.TextSize = 14
    Button.Parent = Scroll
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    local function updateVisuals()
        if Config[configKey] then
            Button.BackgroundColor3 = Color3.fromRGB(85, 0, 255)
            Button.Text = text .. " : [ ON ]"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            Button.Text = text .. " : [ OFF ]"
            Button.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
    
    updateVisuals()
    
    Button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        updateVisuals()
        saveSettings()
        if callback then callback(Config[configKey]) end
    end)
end

-- [4. CORE TARGET ENGAGEMENT ENGINE]
local function getClosestEnemy(lookForBoss)
    local target = nil
    local maxDist = math.huge
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    -- Scans absolute workspace path fallbacks to prevent level design discrepancies
    local pool = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs") or Workspace
    
    for _, obj in pairs(pool:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if obj.Humanoid.Health > 0 then
                local isBoss = obj:SetAttribute("Boss") or string.find(string.lower(obj.Name), "boss")
                if (lookForBoss and isBoss) or (not lookForBoss and not isBoss) or (pool ~= Workspace) then
                    local dist = (obj.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                    if dist < maxDist then
                        maxDist = dist
                        target = obj
                    end
                end
            end
        end
    end
    return target
end

-- [5. FRICTIONLESS TELEPORT ENGINE]
local function safeTeleport(pos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    
    if Config.TweenSpeedHack then
        local dist = (pos - root.Position).Magnitude
        -- Dynamic frame calculation prevents character animations from overriding velocity vector anchors
        local duration = dist / math.max(Config.MaxTweenSpeed, 1)
        local tInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(root, tInfo, {CFrame = CFrame.new(pos)})
        
        char.Humanoid.PlatformStand = true
        tween:Play()
        tween.Completed:Wait()
        char.Humanoid.PlatformStand = false
    else
        root.CFrame = CFrame.new(pos)
    end
end

-- [6. PARALLEL AUTOMATION WORKER THREADS]

-- Combat Routing Framework Loop
task.spawn(function()
    while task.wait(0.05) do
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            
            -- Stage 1: Boss Intercept Focus
            if Config.AutoGetBoss then
                local boss = getClosestEnemy(true)
                if boss and boss:FindFirstChild("HumanoidRootPart") then
                    safeTeleport(boss.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                    if Config.AutoKillAuraBoss then
                        local weapon = char:FindFirstChildOfClass("Tool")
                        if weapon then weapon:Activate() end
                    end
                end
            end
            
            -- Stage 2: Mob Clear Processing
            if Config.AutoGetMobs and not (Config.AutoGetBoss and getClosestEnemy(true)) then
                local mob = getClosestEnemy(false)
                if mob and mob:FindFirstChild("HumanoidRootPart") then
                    safeTeleport(mob.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                    if Config.AutoAuraKillMobs then
                        local weapon = char:FindFirstChildOfClass("Tool")
                        if weapon then weapon:Activate() end
                    end
                end
            end
            
        end
    end
end)

-- High-Frequency 1 Millisecond Intercept Clicker (Bypasses Movement Locks)
task.spawn(function()
    local inputKeys = {Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.F, Enum.KeyCode.X, Enum.KeyCode.C}
    while true do
        local delayRate = math.max(Config.ClickDelayMS / 1000, 0.001)
        task.wait(delayRate)
        
        if Config.AutoClickSpecials then
            for _, key in ipairs(inputKeys) do
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                task.wait(0.0001)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end
        end
    end
end)

-- Auto Requeue Interface Scraper
task.spawn(function()
    while task.wait(1.5) do
        local gui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if gui then
            for _, element in pairs(gui:GetDescendants()) do
                if element:IsA("TextButton") and element.Visible then
                    local matchText = string.lower(element.Text)
                    local matchName = string.lower(element.Name)
                    
                    if Config.AutoPlayAgain and (string.find(matchText, "again") or string.find(matchName, "again") or string.find(matchText, "replay")) then
                        local click = getconnections or element.MouseButton1Click
                        if type(click) == "table" then for _, c in pairs(click) do c:Fire() end else element:SimulateClick() end
                    elseif Config.AutoPlayNextDifficulty and (string.find(matchText, "next") or string.find(matchName, "next") or string.find(matchText, "diff")) then
                        local click = getconnections or element.MouseButton1Click
                        if type(click) == "table" then for _, c in pairs(click) do c:Fire() end else element:SimulateClick() end
                    end
                end
            end
        end
    end
end)

-- Render-Stepped ESP Render Core
RunService.RenderStepped:Connect(function()
