--===================================================================================--
--               DUNGEON HEROES AUTOMATION MATRIX - PART 1 OF 3                      --
--===================================================================================--

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local CONFIG_FILE = "DungeonHeroes_Perfect_V4.json"

if _G.OPSuite and _G.OPSuite.Gui then 
    _G.OPSuite.Gui:Destroy() 
end

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
LogBox.Text = "[PART 1 SUCCESSFUL - PROCEED TO RUN PART 2]"
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

print("[PART 1] Core framework online.")
