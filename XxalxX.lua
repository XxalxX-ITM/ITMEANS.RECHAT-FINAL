--[[
    ITMEANS RECHAT - ULTIMATE FINAL COMPLETED (AURA + RANK FIX + PROFILE UPDATE)
    Firebase: itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app
    Creator: XxalxX (itmeans0011)
]]

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserId = LocalPlayer.UserId
local ScriptStartTime = os.time()

-- Sounds
local SOUND_TOGGLE = "rbxasset://sounds/ui_click.wav"
local SOUND_MESSAGE = "rbxasset://sounds/electronicpingshort.wav"

-- State
local IsFullyLoaded = false
local uiToggled = false
local renderedMessageIds = {}
local CurrentThemeColor = Color3.fromRGB(255, 20, 147)
local DarkBG = Color3.fromRGB(18, 18, 24)
local SecondaryBG = Color3.fromRGB(28, 28, 36)
local LastMessageTime = 0
local MESSAGE_COOLDOWN = 1.5
local AnimatedRankLabels = {}
local AnimatedSystemLabels = {}
local BannedUsers = {}

-- Firebase URLs
local CurrentServerId = (game.JobId ~= "" and game.JobId) or "StudioLocalServer"
local FirebaseURL = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/SecretChat_" .. CurrentServerId .. ".json"
local FirebaseTypingURL = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/SecretTyping_" .. CurrentServerId .. ".json"
local FirebaseRanksURL = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/Ranks.json"
local FirebaseAurasURL = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/Auras.json"
local FirebaseFollowsURL = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/Followers.json"

-- Rank System
local Creators = {
    ["itmeans0011"] = true,
    ["ArynX_Xhehe"] = true,
    [11017676057] = true,
}
local Admins = {}
local Vips = {
    ["AaravGamer9586"] = true,
}
local Daddys = {
    ["diva_bobagirl"] = true,
}

local RGBRanks = {}
local SyncedAuras = {}
local activeAuras = {}
local sendSecretMessage

-- ==================== AURA CUSTOM COLORS ====================
local AuraColors = {
    ["pink"] = Color3.fromRGB(255, 20, 147),
    ["golden"] = Color3.fromRGB(255, 215, 0),
    ["gold"] = Color3.fromRGB(255, 215, 0),
    ["black"] = Color3.fromRGB(15, 15, 15),
    ["red"] = Color3.fromRGB(255, 0, 0),
    ["green"] = Color3.fromRGB(0, 255, 0),
    ["blue"] = Color3.fromRGB(0, 0, 255),
    ["white"] = Color3.fromRGB(255, 255, 255),
    ["silver"] = Color3.fromRGB(192, 192, 192)
}

-- ==================== AURA DESIGN STRUCTURES ====================
local partsStructure = {
    -- LEFT WING
    {size = Vector3.new(1.8, 1.8, 2), offset = CFrame.new(-1.8, 2.5, 2.2), isDetail = false},
    {size = Vector3.new(2.2, 2.2, 2.2), offset = CFrame.new(-2.8, 2.8, 2.4) * CFrame.Angles(0, math.rad(15), 0), isDetail = false},
    {size = Vector3.new(2.5, 3.5, 2.5), offset = CFrame.new(-4, 3.5, 2.6) * CFrame.Angles(0, 0, math.rad(-10)), isDetail = false},
    {size = Vector3.new(2.6, 1, 2.6), offset = CFrame.new(-4, 3.5, 2.6) * CFrame.Angles(0, 0, math.rad(-10)), isDetail = true}, 
    {size = Vector3.new(2.4, 3.2, 2.4), offset = CFrame.new(-5.2, 3.2, 2.7) * CFrame.Angles(0, 0, math.rad(-5)), isDetail = false},
    {size = Vector3.new(1, 6.5, 3), offset = CFrame.new(-4.5, 6.2, 3) * CFrame.Angles(0, 0, math.rad(-45)), isDetail = false},
    {size = Vector3.new(1.2, 2.5, 3.1), offset = CFrame.new(-4.2, 5.0, 3) * CFrame.Angles(0, 0, math.rad(-45)), isDetail = true}, 
    {size = Vector3.new(0.8, 5.5, 2.8), offset = CFrame.new(-6.2, 6.5, 3.2) * CFrame.Angles(0, 0, math.rad(-25)), isDetail = false},
    {size = Vector3.new(0.6, 4.5, 2.5), offset = CFrame.new(-7.8, 6.4, 3.4) * CFrame.Angles(0, 0, math.rad(-5)), isDetail = false},
    {size = Vector3.new(1.5, 1.8, 5.5), offset = CFrame.new(-4.2, 1.2, 2.3) * CFrame.Angles(math.rad(30), math.rad(-15), 0), isDetail = false},
    {size = Vector3.new(1.2, 1.4, 6.5), offset = CFrame.new(-5.8, -0.2, 2.1) * CFrame.Angles(math.rad(50), math.rad(-25), 0), isDetail = false},
    {size = Vector3.new(1.4, 0.4, 6.6), offset = CFrame.new(-5.8, -0.2, 2.1) * CFrame.Angles(math.rad(50), math.rad(-25), 0), isDetail = true}, 
    {size = Vector3.new(0.9, 1.1, 5), offset = CFrame.new(-7.2, -1.4, 1.8) * CFrame.Angles(math.rad(65), math.rad(-35), 0), isDetail = false},
    -- RIGHT WING
    {size = Vector3.new(1.8, 1.8, 2), offset = CFrame.new(1.8, 2.5, 2.2), isDetail = false},
    {size = Vector3.new(2.2, 2.2, 2.2), offset = CFrame.new(2.8, 2.8, 2.4) * CFrame.Angles(0, math.rad(-15), 0), isDetail = false},
    {size = Vector3.new(2.5, 3.5, 2.5), offset = CFrame.new(4, 3.5, 2.6) * CFrame.Angles(0, 0, math.rad(10)), isDetail = false},
    {size = Vector3.new(2.6, 1, 2.6), offset = CFrame.new(4, 3.5, 2.6) * CFrame.Angles(0, 0, math.rad(10)), isDetail = true}, 
    {size = Vector3.new(2.4, 3.2, 2.4), offset = CFrame.new(5.2, 3.2, 2.7) * CFrame.Angles(0, 0, math.rad(5)), isDetail = false},
    {size = Vector3.new(1, 6.5, 3), offset = CFrame.new(4.5, 6.2, 3) * CFrame.Angles(0, 0, math.rad(45)), isDetail = false},
    {size = Vector3.new(1.2, 2.5, 3.1), offset = CFrame.new(4.2, 5.0, 3) * CFrame.Angles(0, 0, math.rad(45)), isDetail = true}, 
    {size = Vector3.new(0.8, 5.5, 2.8), offset = CFrame.new(6.2, 6.5, 3.2) * CFrame.Angles(0, 0, math.rad(25)), isDetail = false},
    {size = Vector3.new(0.6, 4.5, 2.5), offset = CFrame.new(7.8, 6.4, 3.4) * CFrame.Angles(0, 0, math.rad(5)), isDetail = false},
    {size = Vector3.new(1.5, 1.8, 5.5), offset = CFrame.new(4.2, 1.2, 2.3) * CFrame.Angles(math.rad(30), math.rad(15), 0), isDetail = false},
    {size = Vector3.new(1.2, 1.4, 6.5), offset = CFrame.new(5.8, -0.2, 2.1) * CFrame.Angles(math.rad(50), math.rad(25), 0), isDetail = false},
    {size = Vector3.new(1.4, 0.4, 6.6), offset = CFrame.new(5.8, -0.2, 2.1) * CFrame.Angles(math.rad(50), math.rad(25), 0), isDetail = true}, 
    {size = Vector3.new(0.9, 1.1, 5), offset = CFrame.new(7.2, -1.4, 1.8) * CFrame.Angles(math.rad(65), math.rad(35), 0), isDetail = false},
}

local orbitStructure = {
    {size = Vector3.new(1.2, 1.2, 1.2), shape = Enum.PartType.Ball, isDetail = false},
    {size = Vector3.new(1.2, 1.2, 1.2), shape = Enum.PartType.Ball, isDetail = false},
    {size = Vector3.new(1.2, 1.2, 1.2), shape = Enum.PartType.Ball, isDetail = false},
    {size = Vector3.new(1.2, 1.2, 1.2), shape = Enum.PartType.Ball, isDetail = false}
}

-- Helper HTTP Request Function
local request_func = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)
if not request_func then
    request_func = function(options)
        local success, result = pcall(function()
            if options.Method == "GET" then
                return {StatusCode = 200, Body = game:HttpGet(options.Url)}
            elseif options.Method == "POST" or options.Method == "PUT" then
                return {StatusCode = 200, Body = game:HttpPost(options.Url, options.Body)}
            elseif options.Method == "DELETE" then
                return {StatusCode = 200, Body = "{}"}
            end
        end)
        return success and result or {StatusCode = 400, Body = "null"}
    end
end

-- User Color Helper
local LightColors = {"#FF8C8C", "#8CFF8C", "#D28CFF", "#FFFFFF", "#8CE6FF"}
local function getUserColor(uId, sName)
    local num = uId or (sName and #sName) or 1
    return LightColors[(num % #LightColors) + 1]
end

-- Play Sound Helper
local function playSound(soundId)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = 1
        sound.Parent = SoundService
        sound:Play()
        Debris:AddItem(sound, 2)
    end)
end

-- ==================== DRAGGABLE SYSTEM ====================
local function MakeDraggable(frame, handleFrame)
    local dragging = false
    local dragInput, dragStart, startPos
    local dragHandle = handleFrame or frame

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ==================== LOADING SCREEN ====================
local LoadScreenGui = Instance.new("ScreenGui")
LoadScreenGui.Name = "ITMEANS_Load"
LoadScreenGui.Parent = CoreGui
LoadScreenGui.IgnoreGuiInset = true

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(0, 450, 0, 250)
LoadingFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(10, 6, 14)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = LoadScreenGui

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0.25, 0)
LoadingCorner.Parent = LoadingFrame

local LoadingStroke = Instance.new("UIStroke")
LoadingStroke.Thickness = 3
LoadingStroke.Color = Color3.fromRGB(130, 0, 255)
LoadingStroke.Parent = LoadingFrame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0.15, 0)
Status.Position = UDim2.new(0, 0, 0.72, 0)
Status.Text = ""
Status.TextColor3 = Color3.fromRGB(180, 40, 255)
Status.TextSize = 13
Status.Font = Enum.Font.Code
Status.BackgroundTransparency = 1
Status.Parent = LoadingFrame

local function typeWrite(label, text, speed)
    label.Text = ""
    for i = 1, #text do
        label.Text = string.sub(text, 1, i)
        task.wait(speed or 0.03)
    end
end

-- ==================== MAIN GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ITMEANS_Chat"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = false

local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "ITMEANS_Notifs"
NotifGui.Parent = CoreGui
NotifGui.ResetOnSpawn = false
NotifGui.Enabled = true

-- Side Toggle (Draggable)
local VerticalToggle = Instance.new("Frame")
VerticalToggle.Size = UDim2.new(0, 45, 0, 120)
VerticalToggle.Position = UDim2.new(0, 10, 0.4, -60)
VerticalToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
VerticalToggle.BackgroundTransparency = 0.4
VerticalToggle.BorderSizePixel = 0
VerticalToggle.ClipsDescendants = false
VerticalToggle.Parent = ScreenGui

local VTCorner = Instance.new("UICorner")
VTCorner.CornerRadius = UDim.new(0, 12)
VTCorner.Parent = VerticalToggle

local VTStroke = Instance.new("UIStroke")
VTStroke.Thickness = 1.5
VTStroke.Color = Color3.fromRGB(80,80,90)
VTStroke.Parent = VerticalToggle

-- Moving Stars Around Side Toggle Border
local starList = {}
local numStars = 4
local starSize = 14
local toggleW, toggleH = 45, 120
local perimeter = 2 * (toggleW + toggleH)

for i = 1, numStars do
    local star = Instance.new("TextLabel")
    star.Size = UDim2.new(0, starSize, 0, starSize)
    star.BackgroundTransparency = 1
    star.Text = "✨"
    star.TextSize = 11
    star.ZIndex = 10
    star.Parent = VerticalToggle
    table.insert(starList, star)
end

local function getBorderPos(d)
    d = d % perimeter
    if d < toggleW then
        return d, 0
    elseif d < toggleW + toggleH then
        return toggleW, d - toggleW
    elseif d < 2 * toggleW + toggleH then
        return toggleW - (d - (toggleW + toggleH)), toggleH
    else
        return 0, toggleH - (d - (2 * toggleW + toggleH))
    end
end

local TopIcon = Instance.new("ImageLabel")
TopIcon.Size = UDim2.new(0, 25, 0, 25)
TopIcon.Position = UDim2.new(0.5, -12, 0, 5)
TopIcon.BackgroundTransparency = 1
TopIcon.Image = "rbxassetid://6031763426"
TopIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
TopIcon.Parent = VerticalToggle

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, 0, 1, -30)
ToggleButton.Position = UDim2.new(0, 0, 0, 30)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = "C\nA\nT"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = VerticalToggle

MakeDraggable(VerticalToggle, VerticalToggle)

-- Main Frame
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.4, -150)
MainFrame.BackgroundColor3 = DarkBG
MainFrame.BackgroundTransparency = 0.25
MainFrame.GroupTransparency = 0
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = CurrentThemeColor
MainStroke.Parent = MainFrame

local ThemeObjects = { Backgrounds = {}, Strokes = {}, Texts = {} }
table.insert(ThemeObjects.Strokes, MainStroke)

-- ==================== PROFILE PANEL (NEW) ====================
local ProfilePanel = Instance.new("CanvasGroup")
ProfilePanel.Size = UDim2.new(0, 220, 0, 320)
ProfilePanel.Position = UDim2.new(0, -250, 0.5, -160) -- Hidden off-screen left by default
ProfilePanel.BackgroundColor3 = DarkBG
ProfilePanel.BackgroundTransparency = 0.15
ProfilePanel.GroupTransparency = 0
ProfilePanel.BorderSizePixel = 0
ProfilePanel.Visible = false
ProfilePanel.Parent = ScreenGui

MakeDraggable(ProfilePanel, ProfilePanel)

local ProfCorner = Instance.new("UICorner")
ProfCorner.CornerRadius = UDim.new(0, 12)
ProfCorner.Parent = ProfilePanel

local ProfStroke = Instance.new("UIStroke")
ProfStroke.Thickness = 2
ProfStroke.Color = CurrentThemeColor
ProfStroke.Parent = ProfilePanel
table.insert(ThemeObjects.Strokes, ProfStroke)

local ProfTopBar = Instance.new("Frame")
ProfTopBar.Size = UDim2.new(1, 0, 0, 30)
ProfTopBar.BackgroundTransparency = 1
ProfTopBar.Parent = ProfilePanel

local ProfBackBtn = Instance.new("TextButton")
ProfBackBtn.Size = UDim2.new(0, 50, 0, 20)
ProfBackBtn.Position = UDim2.new(0, 10, 0, 5)
ProfBackBtn.BackgroundColor3 = SecondaryBG
ProfBackBtn.Text = "BACK"
ProfBackBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ProfBackBtn.Font = Enum.Font.GothamBold
ProfBackBtn.TextSize = 10
ProfBackBtn.Parent = ProfTopBar
local PBB_Corner = Instance.new("UICorner")
PBB_Corner.CornerRadius = UDim.new(0, 6)
PBB_Corner.Parent = ProfBackBtn

local ProfAvatar = Instance.new("ImageLabel")
ProfAvatar.Size = UDim2.new(0, 80, 0, 80)
ProfAvatar.Position = UDim2.new(0.5, -40, 0, 35)
ProfAvatar.BackgroundColor3 = SecondaryBG
ProfAvatar.Image = ""
ProfAvatar.Parent = ProfilePanel
local ProfAvCorner = Instance.new("UICorner")
ProfAvCorner.CornerRadius = UDim.new(1, 0)
ProfAvCorner.Parent = ProfAvatar
local ProfAvStroke = Instance.new("UIStroke")
ProfAvStroke.Thickness = 2
ProfAvStroke.Color = CurrentThemeColor
ProfAvStroke.Parent = ProfAvatar
table.insert(ThemeObjects.Strokes, ProfAvStroke)

local ProfDisplayName = Instance.new("TextLabel")
ProfDisplayName.Size = UDim2.new(1, -20, 0, 20)
ProfDisplayName.Position = UDim2.new(0, 10, 0, 125)
ProfDisplayName.BackgroundTransparency = 1
ProfDisplayName.Text = "DisplayName"
ProfDisplayName.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfDisplayName.Font = Enum.Font.GothamBold
ProfDisplayName.TextSize = 14
ProfDisplayName.Parent = ProfilePanel

local ProfUsername = Instance.new("TextLabel")
ProfUsername.Size = UDim2.new(1, -20, 0, 15)
ProfUsername.Position = UDim2.new(0, 10, 0, 145)
ProfUsername.BackgroundTransparency = 1
ProfUsername.Text = "@username"
ProfUsername.TextColor3 = Color3.fromRGB(170, 170, 180)
ProfUsername.Font = Enum.Font.Gotham
ProfUsername.TextSize = 11
ProfUsername.Parent = ProfilePanel

local ProfFollowBtn = Instance.new("TextButton")
ProfFollowBtn.Size = UDim2.new(0, 120, 0, 30)
ProfFollowBtn.Position = UDim2.new(0.5, -60, 0, 170)
ProfFollowBtn.BackgroundColor3 = CurrentThemeColor
ProfFollowBtn.Text = "FOLLOW"
ProfFollowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfFollowBtn.Font = Enum.Font.GothamBold
ProfFollowBtn.TextSize = 12
ProfFollowBtn.Parent = ProfilePanel
local PFB_Corner = Instance.new("UICorner")
PFB_Corner.CornerRadius = UDim.new(0, 8)
PFB_Corner.Parent = ProfFollowBtn
table.insert(ThemeObjects.Backgrounds, ProfFollowBtn)

local ProfFollowersCount = Instance.new("TextLabel")
ProfFollowersCount.Size = UDim2.new(1, -20, 0, 15)
ProfFollowersCount.Position = UDim2.new(0, 10, 0, 210)
ProfFollowersCount.BackgroundTransparency = 1
ProfFollowersCount.Text = "Followers: 0"
ProfFollowersCount.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfFollowersCount.Font = Enum.Font.GothamBold
ProfFollowersCount.TextSize = 11
ProfFollowersCount.TextXAlignment = Enum.TextXAlignment.Left
ProfFollowersCount.Parent = ProfilePanel

local ProfFollowersScroller = Instance.new("ScrollingFrame")
ProfFollowersScroller.Size = UDim2.new(1, -20, 1, -235)
ProfFollowersScroller.Position = UDim2.new(0, 10, 0, 230)
ProfFollowersScroller.BackgroundTransparency = 1
ProfFollowersScroller.ScrollBarThickness = 2
ProfFollowersScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
ProfFollowersScroller.Parent = ProfilePanel

local ProfListLayout = Instance.new("UIListLayout")
ProfListLayout.Padding = UDim.new(0, 5)
ProfListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ProfListLayout.Parent = ProfFollowersScroller

local CurrentProfileTarget = ""

-- Profile Functions
local function updateFollowersList(followersTable)
    for _, child in ipairs(ProfFollowersScroller:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    
    local count = 0
    local isFollowing = false
    local myNameLower = string.lower(LocalPlayer.Name)

    if followersTable then
        for fName, _ in pairs(followersTable) do
            count = count + 1
            if string.lower(fName) == myNameLower then isFollowing = true end
            
            local fl = Instance.new("TextLabel")
            fl.Size = UDim2.new(1, 0, 0, 20)
            fl.BackgroundColor3 = SecondaryBG
            fl.BackgroundTransparency = 0.4
            fl.Text = "  " .. fName
            fl.TextColor3 = Color3.fromRGB(200, 200, 200)
            fl.Font = Enum.Font.Gotham
            fl.TextSize = 11
            fl.TextXAlignment = Enum.TextXAlignment.Left
            fl.Parent = ProfFollowersScroller
            local fc = Instance.new("UICorner")
            fc.CornerRadius = UDim.new(0, 4)
            fc.Parent = fl
        end
    end
    
    ProfFollowersCount.Text = "Followers: " .. tostring(count)
    ProfFollowersScroller.CanvasSize = UDim2.new(0, 0, 0, ProfListLayout.AbsoluteContentSize.Y)
    
    if isFollowing then
        ProfFollowBtn.Text = "UNFOLLOW"
        ProfFollowBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    else
        ProfFollowBtn.Text = "FOLLOW"
        ProfFollowBtn.BackgroundColor3 = CurrentThemeColor
    end
end

local function OpenProfilePanel(userId, username, displayName)
    CurrentProfileTarget = string.lower(username)
    ProfAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150"
    ProfDisplayName.Text = displayName
    ProfUsername.Text = "@" .. username
    ProfFollowersCount.Text = "Loading..."
    updateFollowersList({}) -- Clear current list
    
    ProfilePanel.Visible = true
    TweenService:Create(ProfilePanel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 15, 0.5, -160)
    }):Play()

    -- Fetch Followers
    task.spawn(function()
        local url = string.gsub(FirebaseFollowsURL, ".json", "/" .. CurrentProfileTarget .. ".json")
        local response = request_func({Url = url, Method = "GET"})
        if response and response.StatusCode == 200 and response.Body ~= "null" then
            local data = HttpService:JSONDecode(response.Body)
            updateFollowersList(data)
        else
            updateFollowersList({})
        end
    end)
end

ProfBackBtn.Activated:Connect(function()
    local hideTw = TweenService:Create(ProfilePanel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0, -250, 0.5, -160)
    })
    hideTw:Play()
    hideTw.Completed:Connect(function() ProfilePanel.Visible = false end)
end)

ProfFollowBtn.Activated:Connect(function()
    if CurrentProfileTarget == "" then return end
    if CurrentProfileTarget == string.lower(LocalPlayer.Name) then
        sendNotification("SYSTEM", "You cannot follow yourself!", 0)
        return
    end

    ProfFollowBtn.Text = "..."
    local myName = LocalPlayer.Name
    local isFollowing = (ProfFollowBtn.BackgroundColor3 ~= CurrentThemeColor)
    local url = string.gsub(FirebaseFollowsURL, ".json", "/" .. CurrentProfileTarget .. "/" .. myName .. ".json")
    
    task.spawn(function()
        if isFollowing then
            -- Unfollow
            request_func({Url = url, Method = "DELETE", Headers = {["Content-Type"] = "application/json"}})
        else
            -- Follow
            request_func({Url = url, Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(true)})
        end
        -- Refresh Profile
        local refreshUrl = string.gsub(FirebaseFollowsURL, ".json", "/" .. CurrentProfileTarget .. ".json")
        local response = request_func({Url = refreshUrl, Method = "GET"})
        if response and response.StatusCode == 200 and response.Body ~= "null" then
            updateFollowersList(HttpService:JSONDecode(response.Body))
        else
            updateFollowersList({})
        end
    end)
end)

-- ==================== TOGGLE FUNCTION ====================
local function toggleMenu()
    if not IsFullyLoaded then return end
    uiToggled = not uiToggled
    playSound(SOUND_TOGGLE)
    if uiToggled then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
    else
        local fadeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1})
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            if not uiToggled then MainFrame.Visible = false end
        end)
    end
end

ToggleButton.Activated:Connect(toggleMenu)
UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.X then
        toggleMenu()
    end
end)

-- ==================== HEADER WITH GLOWING TITLE ====================
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.ClipsDescendants = false
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.48, 0, 1, 0)
Title.Position = UDim2.new(0, 8, 0, 0)
Title.BackgroundTransparency = 1
Title.ClipsDescendants = false
Title.Text = "ITMEANS RECHAT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextStrokeTransparency = 0.2
Title.TextStrokeColor3 = Color3.fromRGB(255, 100, 255)
Title.Parent = Header

local titleGlow = Instance.new("UIStroke")
titleGlow.Thickness = 3
titleGlow.Color = Color3.fromRGB(255, 100, 255)
titleGlow.Transparency = 0.4
titleGlow.Parent = Title

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 200, 0, 25)
TabContainer.Position = UDim2.new(1, -205, 0, 7)
TabContainer.BackgroundColor3 = SecondaryBG
TabContainer.BackgroundTransparency = 0.3
TabContainer.Parent = Header

local TCInfo = Instance.new("UICorner")
TCInfo.CornerRadius = UDim.new(0,8)
TCInfo.Parent = TabContainer

local ChatTabBtn = Instance.new("TextButton")
ChatTabBtn.Size = UDim2.new(0.33, 0, 1, 0)
ChatTabBtn.BackgroundTransparency = 1
ChatTabBtn.Text = "CHAT"
ChatTabBtn.TextColor3 = CurrentThemeColor
ChatTabBtn.Font = Enum.Font.GothamBold
ChatTabBtn.TextSize = 7
ChatTabBtn.Parent = TabContainer

local ThemeTabBtn = Instance.new("TextButton")
ThemeTabBtn.Size = UDim2.new(0.33, 0, 1, 0)
ThemeTabBtn.Position = UDim2.new(0.33, 0, 0, 0)
ThemeTabBtn.BackgroundTransparency = 1
ThemeTabBtn.Text = "THEME"
ThemeTabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
ThemeTabBtn.Font = Enum.Font.GothamBold
ThemeTabBtn.TextSize = 7
ThemeTabBtn.Parent = TabContainer

local GalleryTabBtn = Instance.new("TextButton")
GalleryTabBtn.Size = UDim2.new(0.34, 0, 1, 0)
GalleryTabBtn.Position = UDim2.new(0.66, 0, 0, 0)
GalleryTabBtn.BackgroundTransparency = 1
GalleryTabBtn.Text = "GALLERY"
GalleryTabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
GalleryTabBtn.Font = Enum.Font.GothamBold
GalleryTabBtn.TextSize = 7
GalleryTabBtn.Parent = TabContainer

-- ==================== CONTENT FRAMES ====================
local ChatContentFrame = Instance.new("Frame", MainFrame)
ChatContentFrame.Size = UDim2.new(1, 0, 1, -40)
ChatContentFrame.Position = UDim2.new(0, 0, 0, 40)
ChatContentFrame.BackgroundTransparency = 1

local GalleryContentFrame = Instance.new("Frame", MainFrame)
GalleryContentFrame.Size = UDim2.new(1, 0, 1, -40)
GalleryContentFrame.Position = UDim2.new(0, 0, 0, 40)
GalleryContentFrame.BackgroundTransparency = 1
GalleryContentFrame.Visible = false

local ThemeContentFrame = Instance.new("Frame", MainFrame)
ThemeContentFrame.Size = UDim2.new(1, 0, 1, -40)
ThemeContentFrame.Position = UDim2.new(0, 0, 0, 40)
ThemeContentFrame.BackgroundTransparency = 1
ThemeContentFrame.Visible = false

-- ==================== CHAT UI ====================
local ChatDisplay = Instance.new("ScrollingFrame")
ChatDisplay.Size = UDim2.new(1, -20, 1, -90)
ChatDisplay.Position = UDim2.new(0, 10, 0, 5)
ChatDisplay.BackgroundTransparency = 1
ChatDisplay.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatDisplay.ScrollBarThickness = 2
ChatDisplay.Parent = ChatContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ChatDisplay

local StickerPanel = Instance.new("Frame")
StickerPanel.Size = UDim2.new(1, -20, 0, 140)
StickerPanel.Position = UDim2.new(0, 10, 1, 5)
StickerPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
StickerPanel.Visible = false
StickerPanel.ClipsDescendants = true
StickerPanel.Parent = ChatContentFrame

local SPCorn = Instance.new("UICorner")
SPCorn.CornerRadius = UDim.new(0, 8)
SPCorn.Parent = StickerPanel

local SPStroke = Instance.new("UIStroke")
SPStroke.Thickness = 1
SPStroke.Color = CurrentThemeColor
SPStroke.Parent = StickerPanel
table.insert(ThemeObjects.Strokes, SPStroke)

local PanelHeaderTitle = Instance.new("TextLabel")
PanelHeaderTitle.Size = UDim2.new(1, 0, 0, 22)
PanelHeaderTitle.BackgroundTransparency = 1
PanelHeaderTitle.Text = "STICKER LIBRARY"
PanelHeaderTitle.Font = Enum.Font.GothamBold
PanelHeaderTitle.TextColor3 = Color3.fromRGB(180, 180, 190)
PanelHeaderTitle.TextSize = 9
PanelHeaderTitle.Parent = StickerPanel

local StickerScroller = Instance.new("ScrollingFrame")
StickerScroller.Size = UDim2.new(1, -6, 1, -24)
StickerScroller.Position = UDim2.new(0, 3, 0, 22)
StickerScroller.BackgroundTransparency = 1
StickerScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
StickerScroller.ScrollBarThickness = 3
StickerScroller.Parent = StickerPanel

local StickerLayout = Instance.new("UIGridLayout")
StickerLayout.CellSize = UDim2.new(0, 70, 0, 70)
StickerLayout.CellPadding = UDim2.new(0, 10, 0, 10)
StickerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
StickerLayout.SortOrder = Enum.SortOrder.LayoutOrder
StickerLayout.Parent = StickerScroller

local InputBar = Instance.new("Frame")
InputBar.Size = UDim2.new(1, -20, 0, 35)
InputBar.Position = UDim2.new(0, 10, 1, -38)
InputBar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
InputBar.BackgroundTransparency = 0.2
InputBar.Parent = ChatContentFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 15)
InputCorner.Parent = InputBar

local InputStroke = Instance.new("UIStroke")
InputStroke.Thickness = 1
InputStroke.Color = CurrentThemeColor
InputStroke.Parent = InputBar
table.insert(ThemeObjects.Strokes, InputBar)

local ImageMenuBtn = Instance.new("TextButton")
ImageMenuBtn.Size = UDim2.new(0, 25, 0, 25)
ImageMenuBtn.Position = UDim2.new(0, 4, 0, 5)
ImageMenuBtn.BackgroundTransparency = 1
ImageMenuBtn.Text = "📸"
ImageMenuBtn.TextSize = 14
ImageMenuBtn.Parent = InputBar

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -90, 1, 0)
TextBox.Position = UDim2.new(0, 35, 0, 0)
TextBox.BackgroundTransparency = 1
TextBox.PlaceholderText = "ITMEANS Chat..."
TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 12
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.Parent = InputBar

local SendBtn = Instance.new("TextButton")
SendBtn.Size = UDim2.new(0, 25, 0, 25)
SendBtn.Position = UDim2.new(1, -30, 0, 5)
SendBtn.BackgroundColor3 = CurrentThemeColor
SendBtn.Text = "↑"
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.TextStrokeTransparency = 0
SendBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
SendBtn.Font = Enum.Font.GothamBold
SendBtn.TextSize = 14
SendBtn.Parent = InputBar

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(1, 0)
SendCorner.Parent = SendBtn
table.insert(ThemeObjects.Backgrounds, SendBtn)

-- ==================== STICKERS ====================
local StickerRegistry = {
    "rbxthumb://type=Asset&id=126155452969559&w=420&h=420",
    "rbxthumb://type=Asset&id=76528918733148&w=420&h=420",
    "rbxthumb://type=Asset&id=139746534721570&w=420&h=420",
    "rbxthumb://type=Asset&id=107882158860216&w=420&h=420",
    "rbxthumb://type=Asset&id=99467189295335&w=420&h=420",
    "rbxthumb://type=Asset&id=114738142020573&w=420&h=420",
    "rbxthumb://type=Asset&id=100644268219896&w=420&h=420",
    "rbxthumb://type=Asset&id=82732486060449&w=420&h=420",
    "rbxthumb://type=Asset&id=84345768144066&w=420&h=420",
    "rbxthumb://type=Asset&id=85611228914039&w=420&h=420",
    "rbxthumb://type=Asset&id=126857592936719&w=420&h=420",
    "rbxthumb://type=Asset&id=106945724992072&w=420&h=420",
    "rbxthumb://type=Asset&id=102454731178873&w=420&h=420",
    "rbxthumb://type=Asset&id=33230128&w=420&h=420",
    "rbxthumb://type=Asset&id=33199969&w=420&h=420",
    "rbxthumb://type=Asset&id=33200194&w=420&h=420",
    "rbxthumb://type=Asset&id=33200310&w=420&h=420",
    "rbxthumb://type=Asset&id=33200394&w=420&h=420",
}

local StickerOpened = false

for i, sticker in ipairs(StickerRegistry) do
    local StkBtn = Instance.new("ImageButton")
    StkBtn.Image = sticker
    StkBtn.BackgroundColor3 = SecondaryBG
    StkBtn.ScaleType = Enum.ScaleType.Fit
    StkBtn.Parent = StickerScroller
    local SBCorn = Instance.new("UICorner")
    SBCorn.CornerRadius = UDim.new(0, 5)
    SBCorn.Parent = StkBtn
    
    StkBtn.Activated:Connect(function()
        sendSecretMessage(sticker)
        if StickerOpened then
            StickerOpened = false
            local closeTween = TweenService:Create(StickerPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0, 10, 1, 5)
            })
            closeTween:Play()
            closeTween.Completed:Connect(function()
                if not StickerOpened then StickerPanel.Visible = false end
            end)
        end
    end)
end

task.delay(0.1, function()
    StickerScroller.CanvasSize = UDim2.new(0, 0, 0, StickerLayout.AbsoluteContentSize.Y + 10)
end)

ImageMenuBtn.Activated:Connect(function()
    if not StickerOpened then
        StickerOpened = true
        StickerPanel.Visible = true
        StickerPanel.Position = UDim2.new(0, 10, 1, 5)
        TweenService:Create(StickerPanel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 10, 1, -145)
        }):Play()
    else
        StickerOpened = false
        local closeTween = TweenService:Create(StickerPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0, 10, 1, 5)
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            if not StickerOpened then StickerPanel.Visible = false end
        end)
    end
end)

-- ==================== GALLERY TAB ====================
local GalleryContent = Instance.new("Frame")
GalleryContent.Size = UDim2.new(1, -20, 1, -20)
GalleryContent.Position = UDim2.new(0, 10, 0, 10)
GalleryContent.BackgroundTransparency = 1
GalleryContent.Parent = GalleryContentFrame

local GalLabel = Instance.new("TextLabel")
GalLabel.Size = UDim2.new(1, 0, 0, 18)
GalLabel.Position = UDim2.new(0, 0, 0, 0)
GalLabel.Text = "IMAGE PREVIEW"
GalLabel.Font = Enum.Font.GothamBold
GalLabel.TextColor3 = Color3.fromRGB(200,200,200)
GalLabel.TextSize = 10
GalLabel.BackgroundTransparency = 1
GalLabel.Parent = GalleryContent

local ImagePreview = Instance.new("ImageLabel")
ImagePreview.Size = UDim2.new(0,120,0,120)
ImagePreview.Position = UDim2.new(0.5,-60,0,25)
ImagePreview.BackgroundColor3 = SecondaryBG
ImagePreview.Image = "rbxassetid://0"
ImagePreview.ScaleType = Enum.ScaleType.Fit
ImagePreview.Parent = GalleryContent

local IPCorner = Instance.new("UICorner")
IPCorner.CornerRadius = UDim.new(0,8)
IPCorner.Parent = ImagePreview

local IPStroke = Instance.new("UIStroke")
IPStroke.Thickness = 1.5
IPStroke.Color = CurrentThemeColor
IPStroke.Parent = ImagePreview
table.insert(ThemeObjects.Strokes, IPStroke)

local UrlInput = Instance.new("TextBox")
UrlInput.Size = UDim2.new(1,-30,0,30)
UrlInput.Position = UDim2.new(0,15,0,155)
UrlInput.BackgroundColor3 = Color3.fromRGB(12,12,16)
UrlInput.BackgroundTransparency = 0.2
UrlInput.PlaceholderText = "Paste Image URL / rbxassetid..."
UrlInput.Text = ""
UrlInput.TextColor3 = Color3.fromRGB(255,255,255)
UrlInput.Font = Enum.Font.Gotham
UrlInput.TextSize = 10
UrlInput.Parent = GalleryContent

local UrlCorner = Instance.new("UICorner")
UrlCorner.CornerRadius = UDim.new(0,6)
UrlCorner.Parent = UrlInput

local GalSendBtn = Instance.new("TextButton")
GalSendBtn.Size = UDim2.new(0,120,0,32)
GalSendBtn.Position = UDim2.new(0.5,-60,0,195)
GalSendBtn.BackgroundColor3 = CurrentThemeColor
GalSendBtn.Text = "SEND TO CHAT"
GalSendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GalSendBtn.TextStrokeTransparency = 0
GalSendBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
GalSendBtn.Font = Enum.Font.GothamBold
GalSendBtn.TextSize = 11
GalSendBtn.Parent = GalleryContent

local GSCorner = Instance.new("UICorner")
GSCorner.CornerRadius = UDim.new(0,6)
GSCorner.Parent = GalSendBtn

local GSStroke = Instance.new("UIStroke")
GSStroke.Thickness = 1.5
GSStroke.Color = Color3.fromRGB(255, 255, 255)
GSStroke.Parent = GalSendBtn

UrlInput:GetPropertyChangedSignal("Text"):Connect(function()
    ImagePreview.Image = UrlInput.Text
end)

GalSendBtn.Activated:Connect(function()
    if UrlInput.Text ~= "" then
        sendSecretMessage(UrlInput.Text)
        UrlInput.Text = ""
        ImagePreview.Image = "rbxassetid://0"
    end
end)

-- ==================== THEME TAB ====================
local ThemeDisplay = Instance.new("ScrollingFrame")
ThemeDisplay.Size = UDim2.new(1, -20, 1, -20)
ThemeDisplay.Position = UDim2.new(0, 10, 0, 10)
ThemeDisplay.BackgroundTransparency = 1
ThemeDisplay.CanvasSize = UDim2.new(0, 0, 0, 0)
ThemeDisplay.ScrollBarThickness = 2
ThemeDisplay.Parent = ThemeContentFrame

local ThemeGrid = Instance.new("UIGridLayout")
ThemeGrid.CellSize = UDim2.new(0, 60, 0, 50)
ThemeGrid.CellPadding = UDim2.new(0, 8, 0, 8)
ThemeGrid.Parent = ThemeDisplay

local AvailableThemes = {
    {Name = "Riser Pink", Color = Color3.fromRGB(255, 20, 147)},
    {Name = "Ruby Red", Color = Color3.fromRGB(220, 20, 60)},
    {Name = "Crimson", Color = Color3.fromRGB(180, 0, 0)},
    {Name = "Sunset", Color = Color3.fromRGB(255, 80, 0)},
    {Name = "Orange", Color = Color3.fromRGB(255, 140, 0)},
    {Name = "Gold", Color = Color3.fromRGB(255, 215, 0)},
    {Name = "Lime", Color = Color3.fromRGB(50, 205, 50)},
    {Name = "Neon Green", Color = Color3.fromRGB(57, 255, 20)},
    {Name = "Teal", Color = Color3.fromRGB(0, 128, 128)},
    {Name = "Cyan", Color = Color3.fromRGB(0, 255, 255)},
    {Name = "Royal Blue", Color = Color3.fromRGB(65, 105, 225)},
    {Name = "Neon Purple", Color = Color3.fromRGB(176, 38, 255)},
    {Name = "White", Color = Color3.fromRGB(255, 255, 255)}
}

local function ApplyTheme(newColor)
    CurrentThemeColor = newColor
    for _, obj in ipairs(ThemeObjects.Backgrounds) do
        if obj and obj.Parent then obj.BackgroundColor3 = newColor end
    end
    for _, obj in ipairs(ThemeObjects.Strokes) do
        if obj and obj.Parent then obj.Color = newColor end
    end
    for _, obj in ipairs(ThemeObjects.Texts) do
        if obj and obj.Parent then obj.TextColor3 = newColor end
    end
    GalSendBtn.BackgroundColor3 = newColor
    
    if ProfFollowBtn.Text == "FOLLOW" then
        ProfFollowBtn.BackgroundColor3 = newColor
    end

    if ChatContentFrame.Visible then
        ChatTabBtn.TextColor3 = newColor
    elseif ThemeContentFrame.Visible then
        ThemeTabBtn.TextColor3 = newColor
    elseif GalleryContentFrame.Visible then
        GalleryTabBtn.TextColor3 = newColor
    end
end

for i, theme in ipairs(AvailableThemes) do
    local ColorBtn = Instance.new("TextButton")
    ColorBtn.BackgroundColor3 = theme.Color
    ColorBtn.Text = ""
    ColorBtn.Parent = ThemeDisplay
    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(0, 10)
    CCorner.Parent = ColorBtn
    local NameLbl = Instance.new("TextLabel")
    NameLbl.Size = UDim2.new(1, 0, 0, 12)
    NameLbl.Position = UDim2.new(0, 0, 1, -12)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text = theme.Name
    NameLbl.TextColor3 = Color3.fromRGB(255,255,255)
    NameLbl.Font = Enum.Font.GothamBold
    NameLbl.TextSize = 7
    NameLbl.Parent = ColorBtn
    ColorBtn.Activated:Connect(function()
        ApplyTheme(theme.Color)
    end)
end

task.delay(0.1, function()
    ThemeDisplay.CanvasSize = UDim2.new(0, 0, 0, ThemeGrid.AbsoluteContentSize.Y + 10)
end)

-- ==================== TAB SWITCHING ====================
local function SwitchTab(tab)
    ChatTabBtn.TextColor3 = (tab == "Chat") and CurrentThemeColor or Color3.fromRGB(150, 150, 160)
    ThemeTabBtn.TextColor3 = (tab == "Theme") and CurrentThemeColor or Color3.fromRGB(150, 150, 160)
    GalleryTabBtn.TextColor3 = (tab == "Gallery") and CurrentThemeColor or Color3.fromRGB(150, 150, 160)

    ChatContentFrame.Visible = (tab == "Chat")
    ThemeContentFrame.Visible = (tab == "Theme")
    GalleryContentFrame.Visible = (tab == "Gallery")
end

ChatTabBtn.Activated:Connect(function() SwitchTab("Chat") end)
ThemeTabBtn.Activated:Connect(function() SwitchTab("Theme") end)
GalleryTabBtn.Activated:Connect(function() SwitchTab("Gallery") end)

-- ==================== RANK & AURA MANAGEMENT ====================
local function fetchRanksFromFirebase()
    pcall(function()
        local response = request_func({Url = FirebaseRanksURL, Method = "GET"})
        if response and response.StatusCode == 200 and response.Body ~= "null" then
            local data = HttpService:JSONDecode(response.Body)
            if data then
                RGBRanks = {}
                for usernameStr, rank in pairs(data) do
                    RGBRanks[string.lower(usernameStr)] = rank
                end
            end
        end
    end)
end

local function updateRankInFirebase(username, rankName)
    local userKey = string.lower(username)
    local rankUrl = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/Ranks/" .. userKey .. ".json"
    
    local ok, result = pcall(function()
        return request_func({
            Url = rankUrl, Method = "PUT",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(rankName)
        })
    end)
    return (ok and result and result.StatusCode == 200)
end

local function removeRankFromFirebase(username)
    local userKey = string.lower(username)
    local rankUrl = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/Ranks/" .. userKey .. ".json"
    local ok, result = pcall(function()
        return request_func({Url = rankUrl, Method = "DELETE", Headers = {["Content-Type"] = "application/json"}})
    end)
    return (ok and result and result.StatusCode == 200)
end

local function fetchAurasFromFirebase()
    pcall(function()
        local response = request_func({Url = FirebaseAurasURL, Method = "GET"})
        if response and response.StatusCode == 200 and response.Body ~= "null" then
            local data = HttpService:JSONDecode(response.Body)
            if data then
                SyncedAuras = {}
                for usernameStr, val in pairs(data) do
                    if type(val) == "table" then
                        SyncedAuras[string.lower(usernameStr)] = val
                    else
                        SyncedAuras[string.lower(usernameStr)] = {Active = val, Color = "pink", Type = "Mecha"}
                    end
                end
            end
        end
    end)
end

local function updateAuraDataInFirebase(username, dataObj)
    local userKey = string.lower(username)
    local url = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/Auras/" .. userKey .. ".json"

    if dataObj then
        local ok, result = pcall(function()
            return request_func({Url = url, Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(dataObj)})
        end)
        return (ok and result and result.StatusCode == 200)
    else
        local ok, result = pcall(function()
            return request_func({Url = url, Method = "DELETE", Headers = {["Content-Type"] = "application/json"}})
        end)
        return (ok and result and result.StatusCode == 200)
    end
end

local function createAuraForPlayer(targetPlayer, auraType)
    if activeAuras[targetPlayer] then return end
    local char = targetPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local model = Instance.new("Model", char)
    model.Name = "SyncedMechaAura"
    local createdParts = {}
    
    local structureToUse = (auraType == "Orbit") and orbitStructure or partsStructure

    for _, data in ipairs(structureToUse) do
        local p = Instance.new("Part")
        p.Material = Enum.Material.Neon
        p.Color = data.isDetail and Color3.fromRGB(5, 5, 5) or CurrentThemeColor
        p.CanCollide = false
        p.Anchored = true
        p.Size = data.size
        
        if data.shape then p.Shape = data.shape end
        
        p.Parent = model
        table.insert(createdParts, {part = p, offset = data.offset, isDetail = data.isDetail})
    end

    activeAuras[targetPlayer] = {Model = model, Parts = createdParts, Type = auraType}
end

local function removeAuraForPlayer(targetPlayer)
    if activeAuras[targetPlayer] then
        if activeAuras[targetPlayer].Model then activeAuras[targetPlayer].Model:Destroy() end
        activeAuras[targetPlayer] = nil
    end
end

local function applyAuras()
    for _, plr in ipairs(Players:GetPlayers()) do
        local userKey = string.lower(plr.Name)
        if SyncedAuras[userKey] and SyncedAuras[userKey].Active then
            local currentType = SyncedAuras[userKey].Type or "Mecha"
            
            -- If aura type changed or doesn't exist, recreate it
            if activeAuras[plr] and activeAuras[plr].Type ~= currentType then
                removeAuraForPlayer(plr)
            end
            
            if not activeAuras[plr] then
                createAuraForPlayer(plr, currentType)
            end
        else
            removeAuraForPlayer(plr)
        end
    end
end

-- Aura Render & Sync Loop
RunService.RenderStepped:Connect(function()
    local t = tick()
    local speed = 1.4
    local height = 0.35
    local float = math.sin(t * speed) * height

    for targetPlayer, data in pairs(activeAuras) do
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and data.Model.Parent then
            local rootCF = targetPlayer.Character.HumanoidRootPart.CFrame
            local userKey = string.lower(targetPlayer.Name)
            local auraData = SyncedAuras[userKey]
            
            local targetColor = CurrentThemeColor
            if auraData and auraData.Color and AuraColors[auraData.Color] then
                targetColor = AuraColors[auraData.Color]
            end

            for i, item in ipairs(data.Parts) do
                if item.part and item.part.Parent then
                    if item.isDetail then
                        item.part.Color = Color3.fromRGB(5, 5, 5)
                    else
                        item.part.Color = targetColor
                    end
                    
                    if data.Type == "Orbit" then
                        local orbitSpeed = t * 2.5
                        local radius = 3.5
                        local offsetAngle = (i / #data.Parts) * math.pi * 2
                        local x = math.cos(orbitSpeed + offsetAngle) * radius
                        local z = math.sin(orbitSpeed + offsetAngle) * radius
                        local y = math.sin(t * 2 + offsetAngle) * 1.5 
                        
                        item.part.CFrame = rootCF * CFrame.new(x, y, z)
                    else
                        item.part.CFrame = rootCF * item.offset * CFrame.new(0, float, 0)
                    end
                end
            end
        else
            removeAuraForPlayer(targetPlayer)
        end
    end
end)

-- ==================== NOTIFICATION & OVERHEAD BUBBLE ====================
local function createOverheadBubble(player, text)
    if not player or not player.Character or not player.Character:FindFirstChild("Head") then return end
    local head = player.Character.Head
    if head:FindFirstChild("RechatOverhead") then
        head.RechatOverhead:Destroy()
    end
    local bb = Instance.new("BillboardGui")
    bb.Name = "RechatOverhead"
    bb.Size = UDim2.new(0, 150, 0, 40)
    bb.Adornee = head
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.Parent = head
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundColor3 = DarkBG
    f.BackgroundTransparency = 0.2
    f.Parent = bb
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = f
    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Color = CurrentThemeColor
    s.Parent = f
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -8, 1, -8)
    l.Position = UDim2.new(0, 4, 0, 4)
    l.BackgroundTransparency = 1
    l.Text = (string.find(text, "roblox.com/asset") or string.find(text, "rbxassetid://") or string.find(text, "rbxthumb://")) and "[Sticker/Image]" or text
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 10
    l.TextWrapped = true
    l.Parent = f
    task.delay(4, function()
        if bb and bb.Parent then bb:Destroy() end
    end)
end

local function sendNotification(senderName, text, userId)
    if NotifGui:FindFirstChild("CurrentNotif") then NotifGui.CurrentNotif:Destroy() end
    local NotifGroup = Instance.new("CanvasGroup")
    NotifGroup.Name = "CurrentNotif"
    NotifGroup.Size = UDim2.new(0, 250, 0, 60)
    NotifGroup.Position = UDim2.new(0, -280, 1, -90)
    NotifGroup.BackgroundColor3 = DarkBG
    NotifGroup.BackgroundTransparency = 0.2
    NotifGroup.GroupTransparency = 1
    NotifGroup.Parent = NotifGui

    local NCorner = Instance.new("UICorner")
    NCorner.CornerRadius = UDim.new(0, 10)
    NCorner.Parent = NotifGroup

    local NStroke = Instance.new("UIStroke")
    NStroke.Thickness = 2
    NStroke.Color = CurrentThemeColor
    NStroke.Parent = NotifGroup

    local NAvatar = Instance.new("ImageLabel")
    NAvatar.Size = UDim2.new(0, 40, 0, 40)
    NAvatar.Position = UDim2.new(0, 10, 0.5, -20)
    NAvatar.BackgroundColor3 = SecondaryBG
    NAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId or 0) .. "&w=48&h=48"
    NAvatar.Parent = NotifGroup

    local NACorner = Instance.new("UICorner")
    NACorner.CornerRadius = UDim.new(1, 0)
    NACorner.Parent = NAvatar

    local NName = Instance.new("TextLabel")
    NName.Size = UDim2.new(1, -60, 0, 16)
    NName.Position = UDim2.new(0, 55, 0, 10)
    NName.BackgroundTransparency = 1
    NName.Text = senderName or "SYSTEM"
    NName.TextColor3 = CurrentThemeColor
    NName.Font = Enum.Font.GothamBold
    NName.TextSize = 12
    NName.TextXAlignment = Enum.TextXAlignment.Left
    NName.Parent = NotifGroup

    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -60, 0, 20)
    NText.Position = UDim2.new(0, 55, 0, 28)
    NText.BackgroundTransparency = 1
    
    local preview = text or ""
    if string.find(preview, "roblox.com/asset") or string.find(preview, "rbxassetid://") or string.find(preview, "rbxthumb://") then
        preview = "Sent a sticker/image"
    end
    if #preview > 28 then preview = string.sub(preview, 1, 25) .. "..." end
    
    NText.Text = preview
    NText.TextColor3 = Color3.fromRGB(255, 255, 255)
    NText.Font = Enum.Font.Gotham
    NText.TextSize = 10
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.TextWrapped = true
    NText.Parent = NotifGroup

    playSound(SOUND_MESSAGE)

    TweenService:Create(NotifGroup, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {GroupTransparency = 0, Position = UDim2.new(0, 15, 1, -90)}):Play()
    task.delay(4, function()
        if NotifGroup and NotifGroup.Parent then
            local fade = TweenService:Create(NotifGroup, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1, Position = UDim2.new(0, -280, 1, -90)})
            fade:Play()
            fade.Completed:Connect(function() NotifGroup:Destroy() end)
        end
    end)
end

-- ==================== SLOW SMOOTH RGB ANIMATION LOOP ====================
RunService.Heartbeat:Connect(function()
    local hue = (tick() * 0.15) % 1
    local rgbColor = Color3.fromHSV(hue, 0.85, 1)
    local hexColor = rgbColor:ToHex()
    
    for label, info in pairs(AnimatedRankLabels) do
        if label and label.Parent then
            label.Text = '<font color="#' .. hexColor .. '"><b>[' .. info.RankText .. ']</b></font> <font color="' .. info.NameHex .. '"><b>' .. info.SenderText .. '</b></font>:'
        else
            AnimatedRankLabels[label] = nil
        end
    end

    for label, rawText in pairs(AnimatedSystemLabels) do
        if label and label.Parent then
            label.Text = '<font color="#' .. hexColor .. '"><b>' .. rawText .. '</b></font>'
        else
            AnimatedSystemLabels[label] = nil
        end
    end

    local moveSpeed = tick() * 35
    for i, star in ipairs(starList) do
        local offset = (i - 1) * (perimeter / numStars)
        local posX, posY = getBorderPos(moveSpeed + offset)
        star.Position = UDim2.new(0, posX - (starSize / 2), 0, posY - (starSize / 2))
    end
end)

-- ==================== ADD MESSAGE TO UI ====================
function addMessageToUI(sender, text, userId, isSystem, displayName)
    sender = (sender and sender ~= "") and sender or "User"
    text = tostring(text or "")
    local shownName = (displayName and displayName ~= "") and displayName or sender

    local MsgFrame = Instance.new("Frame")
    MsgFrame.Size = UDim2.new(1, 0, 0, 0)
    MsgFrame.AutomaticSize = Enum.AutomaticSize.Y
    MsgFrame.BackgroundTransparency = 1
    MsgFrame.Parent = ChatDisplay

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 30)
    Padding.Parent = MsgFrame

    if userId and not isSystem then
        local MiniAvatar = Instance.new("ImageButton")
        MiniAvatar.Size = UDim2.new(0, 20, 0, 20)
        MiniAvatar.Position = UDim2.new(0, -25, 0, 2)
        MiniAvatar.BackgroundColor3 = SecondaryBG
        MiniAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=48&h=48"
        MiniAvatar.Parent = MsgFrame
        local MACorner = Instance.new("UICorner")
        MACorner.CornerRadius = UDim.new(1,0)
        MACorner.Parent = MiniAvatar
        
        MiniAvatar.Activated:Connect(function()
            OpenProfilePanel(userId, sender, shownName)
        end)
    end

    if isSystem then
        Padding.PaddingLeft = UDim.new(0, 8)
        MsgFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
        MsgFrame.BackgroundTransparency = 0.4
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = MsgFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -10, 1, 0)
        Label.Position = UDim2.new(0, 5, 0, 0)
        Label.AutomaticSize = Enum.AutomaticSize.Y
        Label.BackgroundTransparency = 1
        Label.TextSize = 11
        Label.Font = Enum.Font.GothamBold
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextWrapped = true
        Label.RichText = true
        Label.Parent = MsgFrame

        AnimatedSystemLabels[Label] = text
    else
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 14)
        Label.BackgroundTransparency = 1
        Label.TextSize = 12
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.RichText = true
        Label.Parent = MsgFrame

        local customTag = nil
        local senderLower = string.lower(sender)
        local actualPlayer = userId and Players:GetPlayerByUserId(userId) or nil

        if RGBRanks[senderLower] then
            customTag = RGBRanks[senderLower]
        elseif Creators[userId] or Creators[sender] or (actualPlayer and Creators[actualPlayer.Name]) then
            customTag = "Creator"
        elseif Admins[userId] or Admins[sender] or (actualPlayer and Admins[actualPlayer.Name]) then
            customTag = "Admin"
        elseif Vips[userId] or Vips[sender] or (actualPlayer and Vips[actualPlayer.Name]) then
            customTag = "Vip"
        elseif Daddys[userId] or Daddys[sender] or (actualPlayer and Daddys[actualPlayer.Name]) then
            customTag = "Daddy"
        end

        local nameHex = getUserColor(userId, sender)
        if customTag then
            AnimatedRankLabels[Label] = {
                RankText = customTag,
                SenderText = shownName,
                NameHex = nameHex
            }
        else
            Label.Text = '<font color="' .. nameHex .. '"><b>' .. shownName .. '</b></font>:'
        end

        local isImage = string.find(text, "roblox.com/asset") or string.find(text, "rbxassetid://") or string.find(text, "rbxthumb://")

        if isImage then
            local SharedImg = Instance.new("ImageLabel")
            SharedImg.Size = UDim2.new(0, 90, 0, 90)
            SharedImg.Position = UDim2.new(0, 0, 0, 18)
            SharedImg.BackgroundColor3 = SecondaryBG
            SharedImg.Image = text
            SharedImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
            SharedImg.ScaleType = Enum.ScaleType.Fit
            SharedImg.Parent = MsgFrame
            local SICorn = Instance.new("UICorner")
            SICorn.CornerRadius = UDim.new(0, 6)
            SICorn.Parent = SharedImg
            local Spacer = Instance.new("Frame")
            Spacer.Size = UDim2.new(1,0,0,110)
            Spacer.BackgroundTransparency = 1
            Spacer.Parent = MsgFrame
        else
            local TextBlock = Instance.new("TextLabel")
            TextBlock.Size = UDim2.new(1, 0, 0, 0)
            TextBlock.Position = UDim2.new(0,0,0,16)
            TextBlock.AutomaticSize = Enum.AutomaticSize.Y
            TextBlock.BackgroundTransparency = 1
            TextBlock.TextSize = 12
            TextBlock.Font = Enum.Font.Gotham
            TextBlock.TextColor3 = Color3.fromRGB(255,255,255)
            TextBlock.TextXAlignment = Enum.TextXAlignment.Left
            TextBlock.TextWrapped = true
            TextBlock.Text = text
            TextBlock.Parent = MsgFrame
        end
    end
end

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ChatDisplay.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 35)
    TweenService:Create(ChatDisplay, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CanvasPosition = Vector2.new(0, math.max(0, UIListLayout.AbsoluteContentSize.Y - ChatDisplay.AbsoluteWindowSize.Y + 35))
    }):Play()
end)

-- ==================== SEND MESSAGE & COMMANDS ====================
function sendSecretMessage(message, isSystemMsg)
    message = tostring(message or "")
    if message == "" or string.gsub(message, " ", "") == "" then return end

    local isCreator = Creators[LocalPlayer.UserId] or Creators[LocalPlayer.Name]
    local args = string.split(message, " ")
    local cmd = string.lower(args[1] or "")

    if cmd == "!rank" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can use this command!", nil, true)
            return
        end
        if #args >= 3 then
            local targetUsername = args[#args]
            local rankName = table.concat(args, " ", 2, #args - 1)
            local success = updateRankInFirebase(targetUsername, rankName)
            if success then
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " has given " .. rankName .. " rank to " .. targetUsername .. ".", true)
                fetchRanksFromFirebase()
            else
                addMessageToUI(nil, "⚡ [SYSTEM] : Failed to update database.", nil, true)
            end
        else
            addMessageToUI(nil, "⚡ [SYSTEM] : Usage: !rank <rank name> <username>", nil, true)
        end
        return
    end

    if cmd == "!removerank" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can use this command!", nil, true)
            return
        end
        if #args >= 2 then
            local targetUsername = args[2]
            local success = removeRankFromFirebase(targetUsername)
            if success then
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " has removed rank from " .. targetUsername .. ".", true)
                fetchRanksFromFirebase()
            else
                addMessageToUI(nil, "⚡ [SYSTEM] : Failed to remove rank.", nil, true)
            end
        else
            addMessageToUI(nil, "⚡ [SYSTEM] : Usage: !removerank <username>", nil, true)
        end
        return
    end

    if cmd == "!aura" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can give Auras!", nil, true)
            return
        end
        if #args >= 2 then
            local targetUsername = args[2]
            local success = updateAuraDataInFirebase(targetUsername, {Active = true, Color = "pink", Type = "Mecha"})
            if success then
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " granted Mecha Aura to " .. targetUsername .. ".", true)
                SyncedAuras[string.lower(targetUsername)] = {Active = true, Color = "pink", Type = "Mecha"}
                applyAuras()
            else
                addMessageToUI(nil, "⚡ [SYSTEM] : Failed to update database.", nil, true)
            end
        else
            addMessageToUI(nil, "⚡ [SYSTEM] : Usage: !aura <username>", nil, true)
        end
        return
    end

    if cmd == "!auraround" or cmd == "/auraround" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can give Orbit Auras!", nil, true)
            return
        end
        if #args >= 2 then
            local targetUsername = args[2]
            local success = updateAuraDataInFirebase(targetUsername, {Active = true, Color = "pink", Type = "Orbit"})
            if success then
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " granted Orbit Aura to " .. targetUsername .. ".", true)
                SyncedAuras[string.lower(targetUsername)] = {Active = true, Color = "pink", Type = "Orbit"}
                applyAuras()
            else
                addMessageToUI(nil, "⚡ [SYSTEM] : Failed to update database.", nil, true)
            end
        else
            addMessageToUI(nil, "⚡ [SYSTEM] : Usage: !auraround <username>", nil, true)
        end
        return
    end

    if cmd == "!colouraura" or cmd == "!auracolour" or cmd == "!coloraura" or cmd == "!auracolor" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can change Aura Colors!", nil, true)
            return
        end
        if #args >= 3 then
            local colorName = string.lower(args[2])
            local targetUsername = args[3]
            local targetLower = string.lower(targetUsername)

            if not AuraColors[colorName] then
                addMessageToUI(nil, "⚡ [SYSTEM] : Invalid color! Use pink, golden, black, red, green, blue, white.", nil, true)
                return
            end

            local currentType = (SyncedAuras[targetLower] and SyncedAuras[targetLower].Type) or "Mecha"
            local success = updateAuraDataInFirebase(targetUsername, {Active = true, Color = colorName, Type = currentType})
            
            if success then
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Aura color updated to " .. colorName .. " for " .. targetUsername .. ".", true)
                SyncedAuras[targetLower] = {Active = true, Color = colorName, Type = currentType}
                applyAuras()
            else
                addMessageToUI(nil, "⚡ [SYSTEM] : Failed to update database.", nil, true)
            end
        else
            addMessageToUI(nil, "⚡ [SYSTEM] : Usage: !auracolour <color> <username>", nil, true)
        end
        return
    end

    if cmd == "!removeaura" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can remove Auras!", nil, true)
            return
        end
        if #args >= 2 then
            local targetUsername = args[2]
            local success = updateAuraDataInFirebase(targetUsername, nil)
            if success then
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " removed Aura from " .. targetUsername .. ".", true)
                SyncedAuras[string.lower(targetUsername)] = nil
                applyAuras()
            else
                addMessageToUI(nil, "⚡ [SYSTEM] : Failed to remove Aura.", nil, true)
            end
        else
            addMessageToUI(nil, "⚡ [SYSTEM] : Usage: !removeaura <username>", nil, true)
        end
        return
    end

    if cmd == "!kick" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can kick!", nil, true)
            return
        end
        if #args >= 2 then
            local targetName = args[2]
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer then
                pcall(function() targetPlayer:Kick("Kicked by Creator " .. LocalPlayer.Name .. " via ITMEANS Rechat") end)
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " has kicked " .. targetName .. " from the server.", true)
            else
                addMessageToUI(nil, "⚡ [SYSTEM] : Player not found in this specific server.", nil, true)
            end
        else
            addMessageToUI(nil, "⚡ [SYSTEM] : Usage: !kick <username>", nil, true)
        end
        return
    end

    if cmd == "!ban" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can ban!", nil, true)
            return
        end
        if #args >= 2 then
            local targetName = args[2]
            BannedUsers[string.lower(targetName)] = true
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer then
                pcall(function() targetPlayer:Kick("Banned by Creator " .. LocalPlayer.Name .. " via ITMEANS Rechat") end)
            end
            TextBox.Text = ""
            sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " has banned " .. targetName .. " from the server.", true)
        else
            addMessageToUI(nil, "⚡ [SYSTEM] : Usage: !ban <username>", nil, true)
        end
        return
    end

    -- Anti-spam Check
    local senderLower = string.lower(LocalPlayer.Name)
    local hasCreatorBypass = isCreator or (RGBRanks[senderLower] and string.lower(RGBRanks[senderLower]) == "creator")

    if not isSystemMsg and not hasCreatorBypass then
        if (tick() - LastMessageTime) < MESSAGE_COOLDOWN then
            addMessageToUI(nil, "⚡ [SYSTEM] : Slow down! Anti-spam active.", nil, true)
            return
        end
        LastMessageTime = tick()
    end

    if string.lower(message) == "/help" then
        TextBox.Text = ""
        addMessageToUI(nil, "⚡ [SYSTEM] : Commands: !rank <tag> <user>, !removerank <user>, !aura <user>, !auraround <user>, !auracolour <color> <user>, !removeaura <user>, !kick <user>, !ban <user>, /help", nil, true)
        return
    end

    local msgId = "msg_" .. tostring(LocalPlayer.UserId) .. "_" .. tostring(math.floor(tick() * 10000))
    renderedMessageIds[msgId] = true

    if isSystemMsg then
        addMessageToUI(nil, message, nil, true)
        sendNotification("SYSTEM", message, LocalPlayer.UserId)
    else
        addMessageToUI(LocalPlayer.Name, message, LocalPlayer.UserId, false, LocalPlayer.DisplayName)
        createOverheadBubble(LocalPlayer, message)
        sendNotification(LocalPlayer.DisplayName, message, LocalPlayer.UserId)
    end
    TextBox.Text = ""

    local payload = HttpService:JSONEncode({
        Sender = isSystemMsg and "SYSTEM" or LocalPlayer.Name,
        DisplayName = isSystemMsg and "SYSTEM" or LocalPlayer.DisplayName,
        Text = message,
        Timestamp = os.time(),
        UserId = isSystemMsg and 0 or LocalPlayer.UserId,
        IsSystem = isSystemMsg or false
    })

    task.spawn(function()
        pcall(function()
            local putUrl = string.gsub(FirebaseURL, ".json", "/" .. msgId .. ".json")
            request_func({
                Url = putUrl,
                Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = payload
            })
        end)
    end)
end

local function broadcastJoinMessage()
    local playerDisplayName = string.upper(LocalPlayer.DisplayName)
    sendSecretMessage("⚡ [SYSTEM] : ITMEANS Rechat connected\nSYSTEM> " .. playerDisplayName .. " HAS JOINED THE CHAT", true)
end

Players.PlayerAdded:Connect(function(plr)
    if BannedUsers[string.lower(plr.Name)] then
        pcall(function() plr:Kick("You are banned from this server via ITMEANS Rechat") end)
    end
end)

SendBtn.Activated:Connect(function()
    sendSecretMessage(TextBox.Text)
    TextBox.Text = ""
end)

TextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        sendSecretMessage(TextBox.Text)
        TextBox.Text = ""
    end
end)

local lastTypingSent = 0
TextBox:GetPropertyChangedSignal("Text"):Connect(function()
    if TextBox.Text ~= "" and (tick() - lastTypingSent) > 2 then
        lastTypingSent = tick()
        task.spawn(function()
            pcall(function()
                request_func({
                    Url = string.gsub(FirebaseTypingURL, ".json", "/" .. LocalPlayer.UserId .. ".json"),
                    Method = "PUT",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({Name = LocalPlayer.Name, Time = os.time()})
                })
            end)
        end)
    end
end)

-- ==================== MAIN INIT SEQUENCE ====================
task.spawn(function()
    typeWrite(Status, "> INITIALIZING ITMEANS RECHAT...", 0.02)
    task.wait(0.5)
    typeWrite(Status, "> AUTHENTICATING USER...", 0.02)
    task.wait(0.5)
    typeWrite(Status, "> CONNECTING TO REALTIME DATABASE...", 0.02)
    task.wait(0.5)
    typeWrite(Status, "> LOADED SUCCESSFULLY!", 0.02)
    task.wait(0.5)

    LoadScreenGui:Destroy()

    sendNotification("ITMEANS RECHAT", "Script executed & loaded successfully!", LocalPlayer.UserId)

    local WelcomeScreen = Instance.new("ScreenGui")
    WelcomeScreen.Name = "ITMEANS_Welcome"
    WelcomeScreen.Parent = CoreGui
    WelcomeScreen.ResetOnSpawn = false
    WelcomeScreen.IgnoreGuiInset = true

    local WelcomeBg = Instance.new("Frame")
    WelcomeBg.Size = UDim2.new(1, 0, 1, 0)
    WelcomeBg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    WelcomeBg.BorderSizePixel = 0
    WelcomeBg.Parent = WelcomeScreen

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 20)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 10, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
    }
    Gradient.Rotation = 45
    Gradient.Parent = WelcomeBg

    local WelcomeCard = Instance.new("Frame")
    WelcomeCard.Size = UDim2.new(0, 0, 0, 0)
    WelcomeCard.Position = UDim2.new(0.5, 0, 0.5, 0)
    WelcomeCard.BackgroundColor3 = SecondaryBG
    WelcomeCard.BorderSizePixel = 0
    WelcomeCard.ClipsDescendants = true
    WelcomeCard.Parent = WelcomeScreen

    local WCorner = Instance.new("UICorner")
    WCorner.CornerRadius = UDim.new(0, 18)
    WCorner.Parent = WelcomeCard

    local RGBStroke = Instance.new("UIStroke")
    RGBStroke.Thickness = 3
    RGBStroke.Parent = WelcomeCard

    TweenService:Create(WelcomeCard, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 350, 0, 220),
        Position = UDim2.new(0.5, -175, 0.5, -110)
    }):Play()

    task.spawn(function()
        while WelcomeCard and WelcomeCard.Parent do
            local hue = tick() % 6 / 6
            RGBStroke.Color = Color3.fromHSV(hue, 0.9, 1)
            task.wait()
        end
    end)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -30, 0, 35)
    TitleLabel.Position = UDim2.new(0, 15, 0, 35)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = ""
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 20
    TitleLabel.Parent = WelcomeCard

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Size = UDim2.new(1, -30, 0, 25)
    SubtitleLabel.Position = UDim2.new(0, 15, 0, 75)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Text = ""
    SubtitleLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextSize = 12
    SubtitleLabel.Parent = WelcomeCard

    local ContinueBtn = Instance.new("TextButton")
    ContinueBtn.Size = UDim2.new(0, 120, 0, 35)
    ContinueBtn.Position = UDim2.new(0.5, -60, 1, -50)
    ContinueBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ContinueBtn.Text = ""
    ContinueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ContinueBtn.Font = Enum.Font.GothamBold
    ContinueBtn.TextSize = 14
    ContinueBtn.AutoButtonColor = false
    ContinueBtn.Parent = WelcomeCard

    local ContCorner = Instance.new("UICorner")
    ContCorner.CornerRadius = UDim.new(0, 8)
    ContCorner.Parent = ContinueBtn

    task.wait(1)
    typeWrite(TitleLabel, "WELCOME TO ITMEANS RECHAT", 0.04)
    task.wait(0.2)
    typeWrite(SubtitleLabel, "Hello " .. LocalPlayer.DisplayName .. ", Click below to start chatting secretly.", 0.03)
    task.wait(0.2)
    ContinueBtn.Text = "CONTINUE"

    ContinueBtn.MouseEnter:Connect(function()
        TweenService:Create(ContinueBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(65, 65, 80)}):Play()
    end)
    ContinueBtn.MouseLeave:Connect(function()
        TweenService:Create(ContinueBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
    end)

    ContinueBtn.Activated:Connect(function()
        playSound(SOUND_TOGGLE)
        TweenService:Create(WelcomeCard, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.wait(0.6)
        WelcomeScreen:Destroy()
        
        IsFullyLoaded = true
        ScreenGui.Enabled = true
        broadcastJoinMessage()
    end)
end)

-- ==================== FAST MESSAGE POLLING ====================
task.spawn(function()
    while task.wait(1.5) do
        if IsFullyLoaded then
            pcall(function()
                local response = request_func({Url = FirebaseURL, Method = "GET"})
                if response.StatusCode == 200 and response.Body ~= "null" then
                    local data = HttpService:JSONDecode(response.Body)
                    if data then
                        local msgList = {}
                        for key, info in pairs(data) do
                            info.Key = key
                            table.insert(msgList, info)
                        end
                        table.sort(msgList, function(a, b) return (a.Timestamp or 0) < (b.Timestamp or 0) end)
                        
                        for _, msg in ipairs(msgList) do
                            if (msg.Timestamp or 0) > ScriptStartTime and not renderedMessageIds[msg.Key] then
                                renderedMessageIds[msg.Key] = true
                                if msg.IsSystem then
                                    addMessageToUI(nil, msg.Text, nil, true)
                                else
                                    addMessageToUI(msg.Sender, msg.Text, msg.UserId, false, msg.DisplayName)
                                    sendNotification(msg.DisplayName or msg.Sender, msg.Text, msg.UserId)
                                    
                                    local actualPlr = Players:GetPlayerByUserId(msg.UserId)
                                    if actualPlr and actualPlr ~= LocalPlayer then
                                        createOverheadBubble(actualPlr, msg.Text)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ==================== RANK & AURA SYNC POLLING ====================
task.spawn(function()
    while task.wait(5) do
        if IsFullyLoaded then
            fetchRanksFromFirebase()
            fetchAurasFromFirebase()
            applyAuras()
        end
    end
end)
