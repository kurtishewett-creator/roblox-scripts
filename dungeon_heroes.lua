-- Ensure the script only runs once per execution
if _G.DungeonAutomationLoaded then return end
_G.DungeonAutomationLoaded = true

-- --- SERVICES & VARIABLES ---
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- --- CONFIGURATION SYSTEM ---
local FILE_NAME = "DungeonHeroes_Config.json"
_G.Config = {
    TweenSpeed = 50,
    ESPEnabled = false,
    AutoKillMobs = false,
    AutoKillBosses = false,
    AutoClickSpecials = false,
    AutoPlayAgain = false,
    AutoNextDifficulty = false,
    KillAuraRange = 25
}

-- Save current configuration to local storage
local function SaveConfig()
    if writefile then
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, _G.Config)
        if success then
            writefile(FILE_NAME, encoded)
        end
    end
end

-- Load last saved configuration from local storage
local function LoadConfig()
    if readfile and isfile and isfile(FILE_NAME) then
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(FILE_NAME))
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                _G.Config[k] = v
            end
        end
    end
end
LoadConfig()

-- --- CORE UTILITIES & TARGET FINDERS ---

-- Safely handles character physics without breaking movement animations
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- Find targets inside the workspace dungeon structure
local function GetClosestEnemy(lookForBoss)
    local char = GetCharacter()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closest = nil
    local shortestDistance = math.huge
    
    -- Target path adapts to Dungeon Heroes architecture
    local enemyFolder = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs") or Workspace
    
    for _, obj in pairs(enemyFolder:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local isBoss = obj:SetAttribute("IsBoss") or string.find(string.lower(obj.Name), "boss")
            local humanoid = obj.Humanoid
            
            if humanoid.Health > 0 and (not lookForBoss or (lookForBoss and isBoss)) then
                local dist = (char.HumanoidRootPart.Position - obj.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then
                    closest = obj
                    shortestDistance = dist
                end
            end
        end
    end
    return closest
end

-- High-speed linear interpolation for bypassing standard walkspeed limits
local function TweenTo(targetPosition)
    local char = GetCharacter()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local distance = (root.Position - targetPosition).Magnitude
    local speed = _G.Config.TweenSpeed
    local duration = distance / speed
    
    -- Teleport directly if maximum speed limit is engaged
    if speed >= 100 then
        root.CFrame = CFrame.new(targetPosition)
        return
    end
    
    local startTime = os.clock()
    local startPos = root.Position
    
    while os.clock() - startTime < duration and _G.Config.AutoKillMobs do
        local t = (os.clock() - startTime) / duration
        root.CFrame = CFrame.new(startPos:Lerp(targetPosition, t))
        RunService.Heartbeat:Wait()
    end
end

-- --- AUTOMATION LOOPS (MULTI-THREADED) ---

-- Thread 1: Movement & Kill Aura Loop
task.spawn(function()
    while true do
        task.wait()
        local char = GetCharacter()
        local tool = char and char:FindFirstChildOfClass("Tool")
        
        -- Prioritize Boss target if configured, drop down to basic mob if missing
        local target = nil
        if _G.Config.AutoKillBosses then target = GetClosestEnemy(true) end
        if not target and _G.Config.AutoKillMobs then target = GetClosestEnemy(false) end
        
        if target and char and char:FindFirstChild("HumanoidRootPart") then
            local enemyRoot = target:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                -- Position script 4 studs above the target to stay safe while swinging downward
                local combatPosition = enemyRoot.Position + Vector3.new(0, 4, 0)
                TweenTo(combatPosition)
                
                -- Attack execution if inside range limit
                local distance = (char.HumanoidRootPart.Position - enemyRoot.Position).Magnitude
                if distance <= _G.Config.KillAuraRange and tool then
                    tool:Activate()
                    -- Instantly registers touch interactions on parts via executor privileges
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

-- Thread 2: Sub-Millisecond Input Simulation Loop (E, R, F, X, C Skills)
local keysToPress = {"E", "R", "F", "X", "C"}
task.spawn(function()
    while true do
        task.wait(0.001) -- 1 Millisecond processing throttle
        if _G.Config.AutoClickSpecials then
            for _, keyStr in ipairs(keysToPress) do
                local keyCode = Enum.KeyCode[keyStr]
                VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                task.wait(0.0005)
                VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
            end
        end
    end
end)

-- Thread 3: Matchmaking / Screen Overlay Automation Loop
task.spawn(function()
    while true do
        task.wait(1)
        local localGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if localGui then
            -- Searches interface components for restart paths
            for _, element in pairs(localGui:GetDescendants()) do
                if element:IsA("TextButton") and element.Visible then
                    local buttonText = string.lower(element.Text)
                    if _G.Config.AutoPlayAgain and (string.find(buttonText, "again") or string.find(buttonText, "retry")) then
                        firesignal(element.MouseButton1Click)
                    elseif _G.Config.AutoNextDifficulty and (string.find(buttonText, "next") or string.find(buttonText, "difficult")) then
                        firesignal(element.MouseButton1Click)
                    end
                end
            end
        end
    end
end)

-- Thread 4: Visual Tracking Render Pipeline (ESP Box Engine)
local espObjects = {}
RunService.RenderStepped:Connect(function()
    if not _G.Config.ESPEnabled then
        for _, box in pairs(espObjects) do box.Visible = false end
        return
    end
    
    local enemyFolder = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs") or Workspace
    for _, enemy in pairs(enemyFolder:GetChildren()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            if enemy ~= GetCharacter() then
                local rootPart = enemy.HumanoidRootPart
                local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    local box = espObjects[enemy]
                    if not box then
                        box = Drawing.new("Square")
                        box.Color = Color3.fromRGB(255, 0, 0)
                        box.Thickness = 2
                        box.Filled = false
                        espObjects[enemy] = box
                    end
                    
                    -- Render box parameters relative to depth size
                    local sizeY = (Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0)).Y)
                    local sizeX = sizeY * 0.6
                    
                    box.Size = Vector2.new(sizeX, sizeY)
                    box.Position = Vector2.new(vector.X - sizeX / 2, vector.Y - sizeY / 2)
                    box.Visible = true
                else
                    if espObjects[enemy] then espObjects[enemy].Visible = false end
                end
            end
        end
    end
end)

print("[SUCCESS] Dungeon Heroes framework initialized. Use settings controls to change values.")
