-- =============================================================================
--                 DUNGEON HEROES MASTER AUTOMATION ALL-IN-ONE
-- =============================================================================
if _G.DungeonMasterRunning then print("Script already active!") return end
_G.DungeonMasterRunning = true

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local FILE_NAME = "DH_Master_Config_Local.json"

-- --- VISUAL ON-SCREEN CONSOLE ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DH_Status_UI"
ScreenGui.Parent = CoreGui
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 35)
StatusLabel.Position = UDim2.new(0, 0, 0, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
StatusLabel.BackgroundTransparency = 0.3
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
StatusLabel.TextSize = 18
StatusLabel.Font = Enum.Font.Code
StatusLabel.Text = "[SYSTEM ACTIVE] Use /mobs on, /boss on, /skills on, /speed 100"
StatusLabel.Parent = ScreenGui

local function Log(msg) StatusLabel.Text = ">> " .. tostring(msg) .. " <<" end

-- --- CORE STORAGE SETTINGS ---
_G.Config = {
    TweenSpeed = 50,
    ESPEnabled = false,
    AutoKillMobs = false,
    AutoKillBosses = false,
    AutoClickSpecials = false,
    AutoPlayAgain = false,
    KillAuraRange = 25
}

local function SaveConfig()
    if writefile then
        local ok, str = pcall(HttpService.JSONEncode, HttpService, _G.Config)
        if ok then writefile(FILE_NAME, str) end
    end
end

local function LoadConfig()
    if readfile and isfile and isfile(FILE_NAME) then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(FILE_NAME))
        if ok and type(data) == "table" then
            for k, v in pairs(data) do _G.Config[k] = v end
            Log("Configuration values restored successfully.")
        end
    end
end
LoadConfig()

-- --- UNIVERSAL ENEMY LOCATOR ---
local function ClearName(name) return string.lower(name) end
local function GetTarget(isBossStage)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local bestTarget = nil
    local maxDist = math.huge
    
    -- Deep scan strategy to bypass folder structure updates
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("Humanoid") and item.Health > 0 and item.Parent.Name ~= LocalPlayer.Name then
            local eModel = item.Parent
            local eRoot = eModel:FindFirstChild("HumanoidRootPart")
            if eRoot then
                local dist = (root.Position - eRoot.Position).Magnitude
                local matchesBoss = string.find(ClearName(eModel.Name), "boss") or eModel:GetAttribute("IsBoss")
                
                if (isBossStage and matchesBoss) or (not isBossStage) then
                    if dist < maxDist then
                        bestTarget = eModel
                        maxDist = dist
                    end
                end
            end
        end
    end
    return bestTarget
end

-- --- MOTION INTERPOLATION ---
local function MoveTo(pos)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if _G.Config.TweenSpeed >= 100 then
        root.CFrame = CFrame.new(pos)
        return
    end
    
    local dist = (root.Position - pos).Magnitude
    local info = TweenInfo.new(dist / _G.Config.TweenSpeed, Enum.EasingStyle.Linear)
    local tw = game:GetService("TweenService"):Create(root, info, {CFrame = CFrame.new(pos)})
    tw:Play()
    tw.Completed:Wait()
end

-- --- AUTOMATION LOOP PIPELINES ---
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.Config.AutoKillMobs or _G.Config.AutoKillBosses then
            local currentTarget = nil
            if _G.Config.AutoKillBosses then currentTarget = GetTarget(true) end
            if not currentTarget and _G.Config.AutoKillMobs then currentTarget = GetTarget(false) end
            
            if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
                Log("Farming Enemy Target: " .. currentTarget.Name)
                MoveTo(currentTarget.HumanoidRootPart.Position + Vector3.new(0, 4, 0))
                
                -- Tool Trigger Matrix
                local tool = LocalPlayer.Character winter and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                    if firetouchinterest then
                        firetouchinterest(tool.Handle, currentTarget.HumanoidRootPart, 0)
                        firetouchinterest(tool.Handle, currentTarget.HumanoidRootPart, 1)
                    end
                end
            else
                Log("Zone Clear - Scanning Area for New Spawns...")
            end
        end
    end
end)

-- --- 1MS SKILL MACRO PIPELINE ---
local macroKeys = {Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.F, Enum.KeyCode.X, Enum.KeyCode.C}
task.spawn(function()
    while true do
        task.wait(0.001)
        if _G.Config.AutoClickSpecials then
            for _, key in ipairs(macroKeys) do
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end
        end
    end
end)

-- --- SCREEN PATH REPLAY LOOP ---
task.spawn(function()
    while true do
        task.wait(1)
        if _G.Config.AutoPlayAgain then
            local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if playerGui then
                for _, uiElement in pairs(playerGui:GetDescendants()) do
                    if uiElement:IsA("TextButton") and uiElement.Visible then
                        local btnText = string.lower(uiElement.Text)
                        if string.find(btnText, "again") or string.find(btnText, "retry") or string.find(btnText, "play") then
                            firesignal(uiElement.MouseButton1Click)
                        end
                    end
                end
            end
        end
    end
end)

-- --- COMMAND CONTROLLER INTERFACE ---
LocalPlayer.Chatted:Connect(function(rawMsg)
    local msg = string.lower(rawMsg)
    if msg == "/mobs on" then _G.Config.AutoKillMobs = true SaveConfig() Log("Auto-Farm Mobs: ENABLED") end
    if msg == "/mobs off" then _G.Config.AutoKillMobs = false SaveConfig() Log("Auto-Farm Mobs: DISABLED") end
    if msg == "/boss on" then _G.Config.AutoKillBosses = true SaveConfig() Log("Boss Focus: ENABLED") end
    if msg == "/boss off" then _G.Config.AutoKillBosses = false SaveConfig() Log("Boss Focus: DISABLED") end
    if msg == "/skills on" then _G.Config.AutoClickSpecials = true SaveConfig() Log("1ms Skill Cycle: ENABLED") end
    if msg == "/skills off" then _G.Config.AutoClickSpecials = false SaveConfig() Log("1ms Skill Cycle: DISABLED") end
    if msg == "/retry on" then _G.Config.AutoPlayAgain = true SaveConfig() Log("Auto Matchmaking Restart: ENABLED") end
    if msg == "/retry off" then _G.Config.AutoPlayAgain = false SaveConfig() Log("Auto Matchmaking Restart: DISABLED") end
    if string.sub(msg, 1, 7) == "/speed " then
        local spd = tonumber(string.sub(msg, 8))
        if spd then _G.Config.TweenSpeed = math.clamp(spd, 1, 100) SaveConfig() Log("Tracking Speed Set To: " .. _G.Config.TweenSpeed) end
    end
end)

Log("DEPLOYMENT SUCCESS. Enter chat parameters to toggle features.")
