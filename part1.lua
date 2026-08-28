-- Part 1: Configuration, Data Storage, ESP Engine, and Velocity Core
if _G.DungeonMasterPart1 then print("Part 1 already running!") return end
_G.DungeonMasterPart1 = true

-- --- ENGINES & SERVICES ---
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local FILE_NAME = "DungeonHeroes_MasterConfig.json"

-- --- CENTRAL RUNTIME CONFIGURATION ---
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

-- --- DATA PERSISTENCE ENGINE (AUTO-SAVE & AUTO-LOAD) ---
function _G.SaveConfig()
    if writefile then
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, _G.Config)
        if success then writefile(FILE_NAME, encoded) end
    end
end

local function LoadConfig()
    if readfile and isfile and isfile(FILE_NAME) then
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(FILE_NAME))
        if success and type(decoded) == "table" then
            for key, value in pairs(decoded) do _G.Config[key] = value end
            print("[LOADED] Last saved settings restored successfully!")
        end
    else
        _G.SaveConfig()
    end
end
LoadConfig()

-- --- CORE SPATIAL TARGETING LOGIC ---
function _G.GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

function _G.GetClosestEnemy(lookForBoss)
    local char = _G.GetCharacter()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closest = nil
    local shortestDistance = math.huge
    local enemyFolder = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs") or Workspace
    
    for _, obj in pairs(enemyFolder:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local isBoss = obj:SetAttribute("IsBoss") or string.find(string.lower(obj.Name), "boss")
            if obj.Humanoid.Health > 0 and (not lookForBoss or (lookForBoss and isBoss)) then
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

-- --- COMPACT VELOCITY INTERPOLATION SYSTEM ---
function _G.TweenTo(targetPosition)
    local char = _G.GetCharacter()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if _G.Config.TweenSpeed >= 100 then
        root.CFrame = CFrame.new(targetPosition)
        return
    end
    
    local distance = (root.Position - targetPosition).Magnitude
    local duration = distance / _G.Config.TweenSpeed
    local startTime = os.clock()
    local startPos = root.Position
    
    while os.clock() - startTime < duration and (_G.Config.AutoKillMobs or _G.Config.AutoKillBosses) do
        local t = (os.clock() - startTime) / duration
        root.CFrame = CFrame.new(startPos:Lerp(targetPosition, t))
        RunService.Heartbeat:Wait()
    end
end

-- --- DRAWING OVERLAY SYSTEM (ESP BOXES) ---
local VisualBoxes = {}
RunService.RenderStepped:Connect(function()
    if not _G.Config.ESPEnabled then
        for _, box in pairs(VisualBoxes) do box.Visible = false end
        return
    end
    
    local enemyFolder = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("Mobs") or Workspace
    for _, enemy in pairs(enemyFolder:GetChildren()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            if enemy ~= _G.GetCharacter() then
                local rootPart = enemy.HumanoidRootPart
                local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    local box = VisualBoxes[enemy]
                    if not box then
                        box = Drawing.new("Square")
                        box.Color = Color3.fromRGB(255, 0, 0)
                        box.Thickness = 2
                        box.Filled = false
                        VisualBoxes[enemy] = box
                    end
                    
                    local sizeY = (Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0)).Y)
                    local sizeX = sizeY * 0.6
                    
                    box.Size = Vector2.new(sizeX, sizeY)
                    box.Position = Vector2.new(vector.X - sizeX / 2, vector.Y - sizeY / 2)
                    box.Visible = true
                else
                    if VisualBoxes[enemy] then VisualBoxes[enemy].Visible = false end
                end
            end
        end
    end
end)

print("[PART 1 SYSTEM] Core engine online.")

