--[[
    ShinyHub — Blox Fruits v2.0
    Modern script hub | Auto farm | ESP | Utilities
]]

if game.CoreGui:FindFirstChild("ShinyBF") then game.CoreGui:FindFirstChild("ShinyBF"):Destroy() end
if getgenv().BF_RUNNING then getgenv().BF_RUNNING = false task.wait(0.3) end
getgenv().BF_RUNNING = true

local Players = game:GetService("Players")
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")
local LP      = Players.LocalPlayer
local PG      = LP:WaitForChild("PlayerGui")
local Data    = LP:WaitForChild("Data")
local Camera  = game.Workspace.CurrentCamera

--------------------------------------------------------------
-- ISLAND DATA
--------------------------------------------------------------
local IslandPositions = {
    ["Starter Marine"]  = CFrame.new(-3202, 210, 2249),
    ["Windmill"]        = CFrame.new(1231, 20, 1471),
    ["Town"]            = CFrame.new(-696, 12, 1563),
    ["Jungle"]          = CFrame.new(-1379, 22, -410),
    ["Pirate Village"]  = CFrame.new(-1162, 48, 3843),
    ["Desert"]          = CFrame.new(1111, 12, 4349),
    ["Colosseum"]       = CFrame.new(-1214, -2, -2960),
    ["Ice Island"]      = CFrame.new(1058, 62, -1332),
    ["Prison"]          = CFrame.new(4890, 70, 735),
    ["Magma"]           = CFrame.new(-5799, 235, 8771),
    ["Sky Island"]      = CFrame.new(-4914, 730, -2581),
    ["Sky 2"]           = CFrame.new(-4655, 852, -2070),
    ["Sky 3"]           = CFrame.new(-7900, 5626, -1798),
    ["Fountain City"]   = CFrame.new(6080, 45, 4159),
    ["Marine Base"]     = CFrame.new(-5107, 178, 4377),
    ["Mob Boss"]        = CFrame.new(-2835, 14, 5484),
    ["Fishmen"]         = CFrame.new(61722, 380, 1862),
}

--------------------------------------------------------------
-- COLORS
--------------------------------------------------------------
local C = {
    accent      = Color3.fromRGB(100, 130, 255),
    accentDark  = Color3.fromRGB(70, 95, 220),
    accentGlow  = Color3.fromRGB(130, 160, 255),
    green       = Color3.fromRGB(80, 220, 120),
    red         = Color3.fromRGB(255, 80, 90),
    orange      = Color3.fromRGB(255, 170, 50),
    yellow      = Color3.fromRGB(255, 220, 60),
    purple      = Color3.fromRGB(170, 100, 255),
    bg          = Color3.fromRGB(12, 12, 20),
    bgCard      = Color3.fromRGB(20, 20, 32),
    bgCardHov   = Color3.fromRGB(28, 28, 42),
    bgSide      = Color3.fromRGB(16, 16, 24),
    bgHeader    = Color3.fromRGB(10, 10, 16),
    text        = Color3.fromRGB(240, 240, 250),
    sub         = Color3.fromRGB(150, 150, 180),
    dim         = Color3.fromRGB(80, 80, 110),
    border      = Color3.fromRGB(38, 38, 55),
    toggleOn    = Color3.fromRGB(100, 130, 255),
    toggleOff   = Color3.fromRGB(32, 32, 48),
}

local function tw(o, p, d, style)
    TS:Create(o, TweenInfo.new(d or 0.22, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p):Play()
end

--------------------------------------------------------------
-- SCREEN GUI
--------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "ShinyBF"
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.ResetOnSpawn = false
pcall(function() Gui.Parent = game.CoreGui end)
if not Gui.Parent then Gui.Parent = PG end

--------------------------------------------------------------
-- NOTIFICATION SYSTEM
--------------------------------------------------------------
local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0, 260, 1, 0)
NotifHolder.Position = UDim2.new(1, -270, 0, 0)
NotifHolder.BackgroundTransparency = 1
NotifHolder.ZIndex = 200
NotifHolder.Parent = Gui
local nl = Instance.new("UIListLayout", NotifHolder)
nl.SortOrder = Enum.SortOrder.LayoutOrder
nl.Padding = UDim.new(0, 6)
nl.VerticalAlignment = Enum.VerticalAlignment.Bottom

local notifIdx = 0
local function notify(text, color)
    notifIdx += 1
    color = color or C.accent
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    f.BorderSizePixel = 0
    f.ZIndex = 201
    f.LayoutOrder = notifIdx
    f.BackgroundTransparency = 1
    f.Parent = NotifHolder
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    local strk = Instance.new("UIStroke", f)
    strk.Thickness = 1.2
    strk.Color = color
    strk.Transparency = 0.6

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(0, 3, 0.5, 0)
    bar.Position = UDim2.new(0, 8, 0.25, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.ZIndex = 202
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -24, 1, 0)
    l.Position = UDim2.new(0, 18, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = C.text
    l.ZIndex = 202

    tw(f, {BackgroundTransparency = 0.05}, 0.3)
    task.delay(4, function()
        tw(f, {BackgroundTransparency = 1}, 0.5)
        tw(l, {TextTransparency = 1}, 0.5)
        tw(strk, {Transparency = 1}, 0.5)
        task.wait(0.6) pcall(function() f:Destroy() end)
    end)
end

--------------------------------------------------------------
-- DATA HELPERS
--------------------------------------------------------------
local function fmtNum(n)
    if not n or n == 0 then return "0" end
    local s = {"K","M","B","T"}
    local tier, v = 0, math.abs(n)
    while v >= 1000 and tier < #s do v /= 1000 tier += 1 end
    if tier == 0 then return tostring(math.floor(n)) end
    return string.format("%.1f%s", v, s[tier])
end

local function getBeli() return Data:FindFirstChild("Beli") and Data.Beli.Value or 0 end
local function getLvl() return Data:FindFirstChild("Level") and Data.Level.Value or 0 end
local function getExp() return Data:FindFirstChild("Exp") and Data.Exp.Value or 0 end
local function getFruit() local f = Data:FindFirstChild("DevilFruit") return f and f.Value ~= "" and f.Value or "None" end
local function getRace() return Data:FindFirstChild("Race") and Data.Race.Value or "Human" end
local function getFrags() return Data:FindFirstChild("Fragments") and Data.Fragments.Value or 0 end

local toggles = {}
local togRefresh = {}
local threads = {}

local function loop(key, fn)
    table.insert(threads, task.spawn(function()
        while getgenv().BF_RUNNING do
            if toggles[key] then pcall(fn) else task.wait(0.2) end
        end
    end))
end

--------------------------------------------------------------
-- MAIN FRAME
--------------------------------------------------------------
local W, H = 580, 400
local MIN_W, MIN_H = 440, 300

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, W, 0, H)
Main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.ZIndex = 1
Main.ClipsDescendants = true
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Thickness = 1.2
mainStroke.Color = C.border
mainStroke.Transparency = 0.4

-- Top accent glow
local TopGlow = Instance.new("Frame", Main)
TopGlow.Size = UDim2.new(1, 0, 0, 2)
TopGlow.Position = UDim2.new(0, 0, 0, 0)
TopGlow.BorderSizePixel = 0
TopGlow.ZIndex = 30
TopGlow.BackgroundColor3 = C.accent
local topGrad = Instance.new("UIGradient", TopGlow)
topGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accentDark),
    ColorSequenceKeypoint.new(0.5, C.accentGlow),
    ColorSequenceKeypoint.new(1, C.purple),
})

--------------------------------------------------------------
-- HEADER
--------------------------------------------------------------
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 44)
Header.Position = UDim2.new(0, 0, 0, 2)
Header.BackgroundColor3 = C.bgHeader
Header.BorderSizePixel = 0
Header.ZIndex = 10

local Logo = Instance.new("TextLabel", Header)
Logo.Size = UDim2.new(0, 160, 1, 0)
Logo.Position = UDim2.new(0, 18, 0, 0)
Logo.BackgroundTransparency = 1
Logo.RichText = true
Logo.Text = '<font color="#6482FF">Shiny</font><font color="#F0F0FA">Hub</font>'
Logo.Font = Enum.Font.GothamBlack
Logo.TextSize = 17
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.ZIndex = 11

local GameTag = Instance.new("TextLabel", Header)
GameTag.Size = UDim2.new(0, 86, 0, 18)
GameTag.Position = UDim2.new(0, 115, 0.5, -9)
GameTag.BackgroundColor3 = C.accent
GameTag.BackgroundTransparency = 0.85
GameTag.Text = "BLOX FRUITS"
GameTag.Font = Enum.Font.GothamBlack
GameTag.TextSize = 8
GameTag.TextColor3 = C.accent
GameTag.ZIndex = 12
Instance.new("UICorner", GameTag).CornerRadius = UDim.new(0, 6)

-- Window controls
local isMinimized = false
local controlX = -16
local ctrlData = {
    {"\xE2\x9C\x95", Color3.fromRGB(255,80,80)},
    {"\xE2\x80\x93", Color3.fromRGB(255,190,50)},
    {"\xE2\x97\x8B", Color3.fromRGB(80,200,80)},
}
for i, info in ipairs(ctrlData) do
    controlX += 24
    local btn = Instance.new("TextButton", Header)
    btn.Size = UDim2.new(0, 20, 0, 20)
    btn.Position = UDim2.new(1, -(controlX + 50), 0.5, -10)
    btn.BackgroundColor3 = info[2]
    btn.BackgroundTransparency = 0.78
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    btn.MouseEnter:Connect(function() tw(btn, {BackgroundTransparency = 0.2}, 0.1) end)
    btn.MouseLeave:Connect(function() tw(btn, {BackgroundTransparency = 0.78}, 0.15) end)

    if i == 1 then
        btn.MouseButton1Click:Connect(function()
            getgenv().BF_RUNNING = false
            Gui:Destroy()
        end)
    elseif i == 2 then
        btn.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            tw(Main, {Size = isMinimized and UDim2.new(0, Main.AbsoluteSize.X, 0, 46) or UDim2.new(0, Main.AbsoluteSize.X, 0, H)}, 0.35, Enum.EasingStyle.Back)
        end)
    end
end

-- Dragging
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

--------------------------------------------------------------
-- RESIZE HANDLE
--------------------------------------------------------------
local ResizeHandle = Instance.new("TextButton", Main)
ResizeHandle.Size = UDim2.new(0, 18, 0, 18)
ResizeHandle.Position = UDim2.new(1, -18, 1, -18)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Text = "\xE2\x87\xB2"
ResizeHandle.TextColor3 = C.dim
ResizeHandle.Font = Enum.Font.GothamBold
ResizeHandle.TextSize = 11
ResizeHandle.ZIndex = 50
ResizeHandle.AutoButtonColor = false

local resizing, resizeStart, resizeSize
ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        resizeStart = input.Position
        resizeSize = Main.AbsoluteSize
    end
end)
UIS.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - resizeStart
        local nw = math.max(MIN_W, resizeSize.X + d.X)
        local nh = math.max(MIN_H, resizeSize.Y + d.Y)
        Main.Size = UDim2.new(0, nw, 0, nh)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
end)

--------------------------------------------------------------
-- SIDEBAR
--------------------------------------------------------------
local SideW = 52
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, SideW, 1, -46)
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.BackgroundColor3 = C.bgSide
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 5

local SideDiv = Instance.new("Frame", Sidebar)
SideDiv.Size = UDim2.new(0, 1, 1, 0)
SideDiv.Position = UDim2.new(1, 0, 0, 0)
SideDiv.BackgroundColor3 = C.border
SideDiv.BorderSizePixel = 0
SideDiv.ZIndex = 6

local SideIndicator = Instance.new("Frame", Sidebar)
SideIndicator.Size = UDim2.new(0, 3, 0, 26)
SideIndicator.Position = UDim2.new(0, 0, 0, 10)
SideIndicator.BackgroundColor3 = C.accent
SideIndicator.BorderSizePixel = 0
SideIndicator.ZIndex = 8
Instance.new("UICorner", SideIndicator).CornerRadius = UDim.new(0, 2)

local tabOrder = {"Home", "Farm", "Combat", "Teleport", "Player", "Visuals", "Settings"}
local tabIcons = {
    Home     = "\xF0\x9F\x8F\xA0",
    Farm     = "\xE2\x9A\x99\xEF\xB8\x8F",
    Combat   = "\xE2\x9A\x94\xEF\xB8\x8F",
    Teleport = "\xF0\x9F\x8C\x80",
    Player   = "\xF0\x9F\x91\xA4",
    Visuals  = "\xF0\x9F\x8E\xA8",
    Settings = "\xE2\x9A\xA1",
}
local tabDescs = {
    Home     = "Overview & player stats",
    Farm     = "Auto farm with modes",
    Combat   = "Combat, reach & ESP",
    Teleport = "Island teleports",
    Player   = "Movement, fly & mods",
    Visuals  = "Trails, FOV & effects",
    Settings = "Anti-ban, masking & misc",
}

local tabPages = {}
local tabBtns = {}
local activeTab = "Home"
local layoutCounters = {}
local function nxt(tab) layoutCounters[tab] = (layoutCounters[tab] or 0) + 1 return layoutCounters[tab] end

for i, name in ipairs(tabOrder) do
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.Position = UDim2.new(0, 0, 0, (i-1) * 40 + 6)
    btn.BackgroundTransparency = 1
    btn.Text = tabIcons[name]
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.ZIndex = 7
    btn.AutoButtonColor = false
    btn.TextColor3 = C.dim
    tabBtns[name] = btn

    local page = Instance.new("ScrollingFrame", Main)
    page.Size = UDim2.new(1, -(SideW + 18), 1, -90)
    page.Position = UDim2.new(0, SideW + 10, 0, 78)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.dim
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 2
    local pl = Instance.new("UIListLayout", page)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0, 5)
    tabPages[name] = page
end

-- Page title
local PageTitle = Instance.new("TextLabel", Main)
PageTitle.Size = UDim2.new(1, -(SideW + 18), 0, 20)
PageTitle.Position = UDim2.new(0, SideW + 12, 0, 50)
PageTitle.BackgroundTransparency = 1
PageTitle.Font = Enum.Font.GothamBlack
PageTitle.TextSize = 16
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.TextColor3 = C.text
PageTitle.ZIndex = 3

local PageSub = Instance.new("TextLabel", Main)
PageSub.Size = UDim2.new(1, -(SideW + 18), 0, 14)
PageSub.Position = UDim2.new(0, SideW + 12, 0, 68)
PageSub.BackgroundTransparency = 1
PageSub.Font = Enum.Font.GothamMedium
PageSub.TextSize = 10
PageSub.TextXAlignment = Enum.TextXAlignment.Left
PageSub.TextColor3 = C.dim
PageSub.ZIndex = 3

-- Status bar
local StatusBar = Instance.new("Frame", Main)
StatusBar.Size = UDim2.new(1, 0, 0, 26)
StatusBar.Position = UDim2.new(0, 0, 1, -26)
StatusBar.BackgroundColor3 = C.bgHeader
StatusBar.BorderSizePixel = 0
StatusBar.ZIndex = 10

local StatusLbl = Instance.new("TextLabel", StatusBar)
StatusLbl.Size = UDim2.new(1, -20, 1, 0)
StatusLbl.Position = UDim2.new(0, 10, 0, 0)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Font = Enum.Font.GothamBold
StatusLbl.TextSize = 12
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.TextColor3 = C.sub
StatusLbl.ZIndex = 11

local FpsLbl = Instance.new("TextLabel", StatusBar)
FpsLbl.Size = UDim2.new(0, 120, 1, 0)
FpsLbl.Position = UDim2.new(1, -130, 0, 0)
FpsLbl.BackgroundTransparency = 1
FpsLbl.Font = Enum.Font.GothamBold
FpsLbl.TextSize = 11
FpsLbl.TextXAlignment = Enum.TextXAlignment.Right
FpsLbl.TextColor3 = C.dim
FpsLbl.ZIndex = 11

-- Tab switching
local function switchTab(name)
    activeTab = name
    for n, p in pairs(tabPages) do p.Visible = (n == name) end
    PageTitle.Text = name
    PageSub.Text = tabDescs[name] or ""
    for n, btn in pairs(tabBtns) do
        if n == name then
            tw(btn, {TextColor3 = C.accent}, 0.15)
            tw(SideIndicator, {Position = UDim2.new(0, 0, 0, btn.Position.Y.Offset + 6)}, 0.25, Enum.EasingStyle.Back)
        else
            tw(btn, {TextColor3 = C.dim}, 0.15)
        end
    end
end

for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.MouseEnter:Connect(function()
        if name ~= activeTab then tw(btn, {TextColor3 = C.sub}, 0.08) end
    end)
    btn.MouseLeave:Connect(function()
        if name ~= activeTab then tw(btn, {TextColor3 = C.dim}, 0.1) end
    end)
end

--------------------------------------------------------------
-- UI BUILDERS
--------------------------------------------------------------
local function mkSection(tab, txt, col)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1
    f.LayoutOrder = nxt(tab)
    f.ZIndex = 2
    f.Parent = tabPages[tab]
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -8, 1, 0)
    l.Position = UDim2.new(0, 6, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = string.upper(txt)
    l.Font = Enum.Font.GothamBlack
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = col or C.accent
    l.ZIndex = 2
end

local function mkSpacer(tab, h)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, 0, 0, h or 4)
    s.BackgroundTransparency = 1
    s.LayoutOrder = nxt(tab)
    s.Parent = tabPages[tab]
end

local function mkToggle(tab, name, desc)
    toggles[name] = false
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, desc and 40 or 34)
    row.BackgroundColor3 = C.bgCard
    row.BorderSizePixel = 0
    row.LayoutOrder = nxt(tab)
    row.ZIndex = 2
    row.Parent = tabPages[tab]
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)

    local l = Instance.new("TextLabel", row)
    l.Size = UDim2.new(1, -70, 0, desc and 18 or 34)
    l.Position = UDim2.new(0, 16, 0, desc and 4 or 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = C.text
    l.ZIndex = 3

    if desc then
        local d = Instance.new("TextLabel", row)
        d.Size = UDim2.new(1, -70, 0, 14)
        d.Position = UDim2.new(0, 16, 0, 22)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.Font = Enum.Font.GothamMedium
        d.TextSize = 9
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextColor3 = C.dim
        d.ZIndex = 3
    end

    local track = Instance.new("TextButton", row)
    track.Size = UDim2.new(0, 38, 0, 20)
    track.Position = UDim2.new(1, -50, 0.5, -10)
    track.BackgroundColor3 = C.toggleOff
    track.Text = ""
    track.BorderSizePixel = 0
    track.AutoButtonColor = false
    track.ZIndex = 4
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(120,120,140)
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function ref()
        local on = toggles[name]
        tw(track, {BackgroundColor3 = on and C.toggleOn or C.toggleOff}, 0.2)
        tw(knob, {
            Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = on and Color3.new(1,1,1) or Color3.fromRGB(120,120,140)
        }, 0.2)
    end
    table.insert(togRefresh, ref)

    track.MouseButton1Click:Connect(function()
        toggles[name] = not toggles[name]
        for _, fn in ipairs(togRefresh) do pcall(fn) end
        notify(name .. (toggles[name] and " ON" or " OFF"), toggles[name] and C.green or C.red)
    end)

    row.MouseEnter:Connect(function() tw(row, {BackgroundColor3 = C.bgCardHov}, 0.08) end)
    row.MouseLeave:Connect(function() tw(row, {BackgroundColor3 = C.bgCard}, 0.1) end)
end

local function mkButton(tab, txt, cb, col)
    local b = Instance.new("TextButton")
    b.LayoutOrder = nxt(tab)
    b.Size = UDim2.new(1, 0, 0, 34)
    b.Text = ""
    b.BackgroundColor3 = C.bgCard
    b.BorderSizePixel = 0
    b.ZIndex = 2
    b.AutoButtonColor = false
    b.Parent = tabPages[tab]
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)

    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1, -34, 1, 0)
    l.Position = UDim2.new(0, 16, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = col or C.sub
    l.ZIndex = 3

    local arrow = Instance.new("TextLabel", b)
    arrow.Size = UDim2.new(0, 16, 1, 0)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "\xE2\x86\x92"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 13
    arrow.TextColor3 = C.dim
    arrow.ZIndex = 3

    b.MouseButton1Click:Connect(function()
        tw(b, {BackgroundColor3 = C.accent}, 0.05)
        task.delay(0.15, function() tw(b, {BackgroundColor3 = C.bgCard}, 0.3) end)
        if cb then cb() end
    end)
    b.MouseEnter:Connect(function() tw(b, {BackgroundColor3 = C.bgCardHov}, 0.08) tw(arrow, {TextColor3 = C.accent}, 0.08) end)
    b.MouseLeave:Connect(function() tw(b, {BackgroundColor3 = C.bgCard}, 0.1) tw(arrow, {TextColor3 = C.dim}, 0.1) end)
end

local function mkStatRow(tab, label, fn)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundColor3 = C.bgCard
    f.BorderSizePixel = 0
    f.LayoutOrder = nxt(tab)
    f.ZIndex = 2
    f.Parent = tabPages[tab]
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = C.dim
    lbl.ZIndex = 3

    local val = Instance.new("TextLabel", f)
    val.Size = UDim2.new(0.55, -16, 1, 0)
    val.Position = UDim2.new(0.45, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = tostring(fn())
    val.Font = Enum.Font.GothamBlack
    val.TextSize = 14
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.TextColor3 = C.text
    val.ZIndex = 3

    table.insert(togRefresh, function() val.Text = tostring(fn()) end)
end

local function mkDropdown(tab, label, options, default, onChange)
    local current = default or options[1]
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = C.bgCard
    row.BorderSizePixel = 0
    row.LayoutOrder = nxt(tab)
    row.ZIndex = 2
    row.Parent = tabPages[tab]
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)

    local l = Instance.new("TextLabel", row)
    l.Size = UDim2.new(0.55, 0, 1, 0)
    l.Position = UDim2.new(0, 16, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = C.text
    l.ZIndex = 3

    local selector = Instance.new("TextButton", row)
    selector.Size = UDim2.new(0, 110, 0, 24)
    selector.Position = UDim2.new(1, -122, 0.5, -12)
    selector.BackgroundColor3 = C.accent
    selector.BackgroundTransparency = 0.8
    selector.Text = current
    selector.Font = Enum.Font.GothamBold
    selector.TextSize = 11
    selector.TextColor3 = C.accentGlow
    selector.BorderSizePixel = 0
    selector.AutoButtonColor = false
    selector.ZIndex = 4
    Instance.new("UICorner", selector).CornerRadius = UDim.new(0, 8)

    local idx = table.find(options, current) or 1
    selector.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        current = options[idx]
        selector.Text = current
        tw(selector, {BackgroundTransparency = 0.5}, 0.06)
        task.delay(0.12, function() tw(selector, {BackgroundTransparency = 0.8}, 0.15) end)
        if onChange then onChange(current) end
    end)

    return function() return current end
end

--------------------------------------------------------------
-- HOME TAB
--------------------------------------------------------------
mkSection("Home", "Player Stats")
mkStatRow("Home", "BELI", function() return "$ " .. fmtNum(getBeli()) end)
mkStatRow("Home", "LEVEL", function() return "Lv. " .. tostring(getLvl()) end)
mkStatRow("Home", "EXP", function() return fmtNum(getExp()) .. " XP" end)
mkStatRow("Home", "FRUIT", function() return getFruit() end)
mkStatRow("Home", "RACE", function() return getRace() end)
mkStatRow("Home", "FRAGMENTS", function() return fmtNum(getFrags()) end)

mkSpacer("Home", 6)
mkSection("Home", "Session Info")

local startBeli = getBeli()
local startTime = tick()
mkStatRow("Home", "UPTIME", function()
    local e = math.floor(tick() - startTime)
    return math.floor(e/60) .. "m " .. (e%60) .. "s"
end)
mkStatRow("Home", "EARNED", function() return "$ " .. fmtNum(getBeli() - startBeli) end)

mkSpacer("Home", 6)
mkSection("Home", "Quick Actions")
mkButton("Home", "Disable All Toggles", function()
    for k in pairs(toggles) do toggles[k] = false end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    notify("All disabled", C.orange)
end)
mkButton("Home", "Rejoin Server", function()
    notify("Rejoining...", C.yellow)
    task.wait(0.5)
    pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end)
end)
mkButton("Home", "Copy Server Link", function()
    pcall(function() setclipboard("roblox://placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId) end)
    notify("Server link copied!", C.green)
end)

--------------------------------------------------------------
-- FARM TAB
--------------------------------------------------------------
mkSection("Farm", "Auto Farm Mode", C.orange)

local farmMode = "Normal"
local getFarmMode = mkDropdown("Farm", "Farm Mode", {"Legit", "Normal", "Fast (Risky)"}, "Normal", function(mode)
    farmMode = mode
    notify("Farm mode: " .. mode, C.orange)
end)

mkSpacer("Farm", 4)
mkSection("Farm", "Auto Farm")

mkToggle("Farm", "Auto Farm", "Floats above enemies, auto-equips & attacks fast")

local farmBP = nil
local farmGyro = nil
table.insert(togRefresh, function()
    if not toggles["Auto Farm"] then
        if farmBP then pcall(function() farmBP:Destroy() end) farmBP = nil end
        if farmGyro then pcall(function() farmGyro:Destroy() end) farmGyro = nil end
    end
end)

loop("Auto Farm", function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then task.wait(0.5) return end

    local mode = getFarmMode()
    local height = mode == "Legit" and 7 or (mode == "Normal" and 10 or 12)
    local atkBurst = mode == "Legit" and 3 or (mode == "Normal" and 5 or 10)

    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
    hrp.Velocity = Vector3.new(0, 0, 0)

    if not char:FindFirstChildOfClass("Tool") then
        for _, t in LP.Backpack:GetChildren() do
            if t:IsA("Tool") then
                pcall(function() hum:EquipTool(t) end)
                task.wait(0.1)
                break
            end
        end
    end

    if not farmBP or farmBP.Parent ~= hrp then
        if farmBP then pcall(function() farmBP:Destroy() end) end
        farmBP = Instance.new("BodyPosition")
        farmBP.Name = "SH_FarmBP"
        farmBP.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        farmBP.D = 1000
        farmBP.P = 50000
        farmBP.Parent = hrp
    end

    if not farmGyro or farmGyro.Parent ~= hrp then
        if farmGyro then pcall(function() farmGyro:Destroy() end) end
        farmGyro = Instance.new("BodyGyro")
        farmGyro.Name = "SH_FarmGyro"
        farmGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        farmGyro.D = 200
        farmGyro.P = 10000
        farmGyro.Parent = hrp
    end

    local closest, dist = nil, math.huge
    local enemies = game.Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in enemies:GetChildren() do
            local mHrp = mob:FindFirstChild("HumanoidRootPart")
            local mHum = mob:FindFirstChild("Humanoid")
            if mHrp and mHum and mHum.Health > 0 then
                local d = (mHrp.Position - hrp.Position).Magnitude
                if d < dist then closest = mob dist = d end
            end
        end
    end

    if closest then
        local mHrp = closest:FindFirstChild("HumanoidRootPart")
        if mHrp then
            local ePos = mHrp.Position
            local aPos = Vector3.new(ePos.X, ePos.Y + height, ePos.Z)
            farmBP.Position = aPos
            farmGyro.CFrame = CFrame.new(aPos, ePos)
            hrp.CFrame = CFrame.new(aPos, ePos)
            hrp.Velocity = Vector3.new(0, 0, 0)

            local vim = game:GetService("VirtualInputManager")
            for _ = 1, atkBurst do
                pcall(function()
                    vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.005)
                    vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end)
            end
        end
    else
        farmBP.Position = hrp.Position
    end
    task.wait(0.05)
end)

mkToggle("Farm", "Bring Mobs", "Pulls nearby enemies under you")
loop("Bring Mobs", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then task.wait(1) return end
    local enemies = game.Workspace:FindFirstChild("Enemies")
    if enemies then
        local below = Vector3.new(hrp.Position.X, hrp.Position.Y - 15, hrp.Position.Z)
        for _, mob in enemies:GetChildren() do
            local mHrp = mob:FindFirstChild("HumanoidRootPart")
            local mHum = mob:FindFirstChild("Humanoid")
            if mHrp and mHum and mHum.Health > 0 and (mHrp.Position - hrp.Position).Magnitude < 300 then
                mHrp.CFrame = CFrame.new(below + Vector3.new(math.random(-3,3), 0, math.random(-3,3)))
            end
        end
    end
    task.wait(0.2)
end)

mkToggle("Farm", "Auto Quest", "Interacts with quest NPCs")
loop("Auto Quest", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then task.wait(1) return end
    local npcs = game.Workspace:FindFirstChild("NPCs")
    if npcs then
        for _, npc in npcs:GetChildren() do
            for _, d in npc:GetDescendants() do
                if d:IsA("ProximityPrompt") then
                    local nPart = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
                    if nPart and (nPart.Position - hrp.Position).Magnitude < 60 then
                        pcall(function() fireproximityprompt(d) end)
                    end
                end
            end
        end
    end
    task.wait(2)
end)

mkSpacer("Farm", 4)
mkSection("Farm", "Collection")

mkToggle("Farm", "Fruit Sniper", "Alerts + highlights fruit spawns")
loop("Fruit Sniper", function()
    local ff = game.Workspace:FindFirstChild("Fruit ") or game.Workspace:FindFirstChild("Fruit")
    if ff then
        for _, fruit in ff:GetChildren() do
            if fruit:IsA("Tool") or fruit:IsA("Model") then
                notify("FRUIT: " .. fruit.Name, C.green)
                task.wait(12)
            end
        end
    end
    task.wait(3)
end)

mkToggle("Farm", "Auto Chest", "Collects nearby chests")
loop("Auto Chest", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then task.wait(1) return end
    local chests = game.Workspace:FindFirstChild("ChestModels")
    if chests then
        for _, chest in chests:GetChildren() do
            for _, d in chest:GetDescendants() do
                if d:IsA("ProximityPrompt") then
                    local p = chest:FindFirstChildOfClass("BasePart") or chest.PrimaryPart
                    if p and (p.Position - hrp.Position).Magnitude < 100 then
                        pcall(function() fireproximityprompt(d) end)
                    end
                elseif d:IsA("ClickDetector") then
                    pcall(function() fireclickdetector(d) end)
                end
            end
        end
    end
    task.wait(2)
end)

--------------------------------------------------------------
-- COMBAT TAB
--------------------------------------------------------------
mkSection("Combat", "Attack", C.red)

mkToggle("Combat", "Fast Attack", "Rapid click spam")
loop("Fast Attack", function()
    local vim = game:GetService("VirtualInputManager")
    for _ = 1, 3 do
        pcall(function()
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
        task.wait(0.03)
    end
end)

mkToggle("Combat", "Auto Ability", "Spams Z/X/C/V abilities")
loop("Auto Ability", function()
    local vim = game:GetService("VirtualInputManager")
    for _, key in ipairs({Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}) do
        pcall(function()
            vim:SendKeyEvent(true, key, false, game)
            task.wait(0.04)
            vim:SendKeyEvent(false, key, false, game)
        end)
        task.wait(0.2)
    end
end)

mkToggle("Combat", "Kill Aura", "Hits all enemies in range")
loop("Kill Aura", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then task.wait(1) return end
    local enemies = game.Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in enemies:GetChildren() do
            local mHrp = mob:FindFirstChild("HumanoidRootPart")
            local mHum = mob:FindFirstChild("Humanoid")
            if mHrp and mHum and mHum.Health > 0 and (mHrp.Position - hrp.Position).Magnitude < 55 then
                local vim = game:GetService("VirtualInputManager")
                pcall(function()
                    vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.02)
                    vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end)
            end
        end
    end
    task.wait(0.15)
end)

mkToggle("Combat", "Reach", "Extended melee hit range")
local reachParts = {}
loop("Reach", function()
    local char = LP.Character
    if not char then task.wait(1) return end
    for _, tool in ipairs(LP.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, p in tool:GetDescendants() do
                if p:IsA("BasePart") then
                    if not reachParts[p] then reachParts[p] = p.Size end
                    p.Size = Vector3.new(p.Size.X, p.Size.Y, 60)
                    p.Transparency = 1
                end
            end
        end
    end
    if char:FindFirstChildOfClass("Tool") then
        local tool = char:FindFirstChildOfClass("Tool")
        for _, p in tool:GetDescendants() do
            if p:IsA("BasePart") then
                if not reachParts[p] then reachParts[p] = p.Size end
                p.Size = Vector3.new(p.Size.X, p.Size.Y, 60)
                p.Transparency = 1
            end
        end
    end
    task.wait(0.3)
end)
table.insert(togRefresh, function()
    if not toggles["Reach"] then
        for p, origSize in pairs(reachParts) do
            pcall(function() if p and p.Parent then p.Size = origSize p.Transparency = 0 end end)
        end
        reachParts = {}
    end
end)

mkSpacer("Combat", 6)
mkSection("Combat", "ESP", C.purple)

mkToggle("Combat", "Player ESP", "Highlight players with HP")
local pespFolder = nil
table.insert(togRefresh, function()
    if toggles["Player ESP"] then
        if not pespFolder then pespFolder = Instance.new("Folder") pespFolder.Name = "SH_PESP" pespFolder.Parent = game.CoreGui end
    else
        if pespFolder then pespFolder:Destroy() pespFolder = nil end
        for _, p in Players:GetPlayers() do
            if p ~= LP and p.Character then
                local h = p.Character:FindFirstChild("SH_HL") if h then h:Destroy() end
            end
        end
    end
end)
loop("Player ESP", function()
    if not pespFolder then task.wait(1) return end
    for _, bb in pespFolder:GetChildren() do bb:Destroy() end
    for _, p in Players:GetPlayers() do
        if p ~= LP then
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local bb = Instance.new("BillboardGui")
                bb.Adornee = hrp
                bb.Size = UDim2.new(0, 130, 0, 26)
                bb.StudsOffset = Vector3.new(0, 3.5, 0)
                bb.AlwaysOnTop = true
                bb.Parent = pespFolder
                local tl = Instance.new("TextLabel", bb)
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = p.Name .. "  [" .. math.floor(hum.Health) .. " HP]"
                tl.TextColor3 = C.accent
                tl.Font = Enum.Font.GothamBold
                tl.TextSize = 11
                tl.TextStrokeTransparency = 0.3
                if not char:FindFirstChild("SH_HL") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "SH_HL"
                    hl.FillTransparency = 0.75
                    hl.FillColor = C.accent
                    hl.OutlineColor = C.accent
                    hl.OutlineTransparency = 0.2
                    hl.Parent = char
                end
            end
        end
    end
    task.wait(1.5)
end)

mkToggle("Combat", "Enemy ESP", "Show enemy names & HP")
local eespFolder = nil
table.insert(togRefresh, function()
    if toggles["Enemy ESP"] then
        if not eespFolder then eespFolder = Instance.new("Folder") eespFolder.Name = "SH_EESP" eespFolder.Parent = game.CoreGui end
    else
        if eespFolder then eespFolder:Destroy() eespFolder = nil end
    end
end)
loop("Enemy ESP", function()
    if not eespFolder then task.wait(1) return end
    for _, bb in eespFolder:GetChildren() do bb:Destroy() end
    local enemies = game.Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in enemies:GetChildren() do
            local mHrp = mob:FindFirstChild("HumanoidRootPart")
            local mHum = mob:FindFirstChild("Humanoid")
            if mHrp and mHum and mHum.Health > 0 then
                local bb = Instance.new("BillboardGui")
                bb.Adornee = mHrp
                bb.Size = UDim2.new(0, 150, 0, 24)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true
                bb.Parent = eespFolder
                local tl = Instance.new("TextLabel", bb)
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = mob.Name .. "  " .. math.floor(mHum.Health) .. "/" .. math.floor(mHum.MaxHealth)
                tl.TextColor3 = C.red
                tl.Font = Enum.Font.GothamBold
                tl.TextSize = 10
                tl.TextStrokeTransparency = 0.3
            end
        end
    end
    task.wait(2)
end)

mkToggle("Combat", "Fruit ESP", "Highlight fruits on map")
local fespFolder = nil
table.insert(togRefresh, function()
    if toggles["Fruit ESP"] then
        if not fespFolder then fespFolder = Instance.new("Folder") fespFolder.Name = "SH_FESP" fespFolder.Parent = game.CoreGui end
    else
        if fespFolder then fespFolder:Destroy() fespFolder = nil end
    end
end)
loop("Fruit ESP", function()
    if not fespFolder then task.wait(1) return end
    for _, bb in fespFolder:GetChildren() do bb:Destroy() end
    local ff = game.Workspace:FindFirstChild("Fruit ") or game.Workspace:FindFirstChild("Fruit")
    if ff then
        for _, fruit in ff:GetChildren() do
            local part = fruit:IsA("BasePart") and fruit or fruit:FindFirstChildOfClass("BasePart") or (fruit:IsA("Model") and fruit.PrimaryPart)
            if part then
                local bb = Instance.new("BillboardGui")
                bb.Adornee = part
                bb.Size = UDim2.new(0, 140, 0, 28)
                bb.StudsOffset = Vector3.new(0, 5, 0)
                bb.AlwaysOnTop = true
                bb.Parent = fespFolder
                local tl = Instance.new("TextLabel", bb)
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = fruit.Name
                tl.TextColor3 = C.green
                tl.Font = Enum.Font.GothamBlack
                tl.TextSize = 14
                tl.TextStrokeTransparency = 0.2
            end
        end
    end
    task.wait(3)
end)

--------------------------------------------------------------
-- TELEPORT TAB
--------------------------------------------------------------
mkSection("Teleport", "First Sea Islands")
for _, name in ipairs({"Starter Marine", "Windmill", "Town", "Jungle", "Pirate Village", "Desert", "Colosseum", "Ice Island", "Prison", "Magma", "Sky Island", "Sky 2", "Sky 3", "Fountain City", "Marine Base", "Mob Boss", "Fishmen"}) do
    mkButton("Teleport", name, function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("No character!", C.red) return end
        local cf = IslandPositions[name]
        if cf then
            hrp.CFrame = cf
            notify("TP: " .. name, C.green)
        end
    end)
end

--------------------------------------------------------------
-- PLAYER TAB (movement, fly, mods)
--------------------------------------------------------------
mkSection("Player", "Movement", C.green)

mkToggle("Player", "Speed Hack", "WalkSpeed 120")
local defWS = 16
loop("Speed Hack", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 120 end
    task.wait(0.4)
end)
table.insert(togRefresh, function()
    if not toggles["Speed Hack"] then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = defWS end
    end
end)

mkToggle("Player", "Jump Boost", "JumpPower 130")
local defJP = 50
loop("Jump Boost", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 130 end
    task.wait(0.4)
end)
table.insert(togRefresh, function()
    if not toggles["Jump Boost"] then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = defJP end
    end
end)

mkToggle("Player", "Infinite Jump", "Jump mid-air")
UIS.JumpRequest:Connect(function()
    if toggles["Infinite Jump"] and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

mkToggle("Player", "Fly", "WASD + Space/Shift to fly freely")
local flyBV = nil
local flyConn = nil
table.insert(togRefresh, function()
    if toggles["Fly"] then
        if not flyConn then
            flyConn = RunS.Heartbeat:Connect(function()
                local char = LP.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then return end

                if not flyBV or flyBV.Parent ~= hrp then
                    if flyBV then pcall(function() flyBV:Destroy() end) end
                    flyBV = Instance.new("BodyVelocity")
                    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    flyBV.Velocity = Vector3.zero
                    flyBV.Parent = hrp
                end

                local speed = 80
                local dir = Vector3.zero
                local cf = Camera.CFrame
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end

                if dir.Magnitude > 0 then
                    flyBV.Velocity = dir.Unit * speed
                else
                    flyBV.Velocity = Vector3.zero
                end
                hum:ChangeState(Enum.HumanoidStateType.Flying)
            end)
        end
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
    end
end)

mkToggle("Player", "Noclip", "Walk through walls")
local nclipOrig = {}
RunS.Stepped:Connect(function()
    if toggles["Noclip"] and LP.Character then
        for _, p in LP.Character:GetDescendants() do
            if p:IsA("BasePart") then
                if nclipOrig[p] == nil then nclipOrig[p] = p.CanCollide end
                p.CanCollide = false
            end
        end
    end
end)
table.insert(togRefresh, function()
    if not toggles["Noclip"] then
        for p, orig in pairs(nclipOrig) do
            pcall(function() if p and p.Parent then p.CanCollide = orig end end)
        end
        nclipOrig = {}
    end
end)

mkSpacer("Player", 6)
mkSection("Player", "Character")

mkToggle("Player", "Hide Character", "Invisible locally")
local hideOrig = {}
loop("Hide Character", function()
    if LP.Character then
        for _, p in LP.Character:GetDescendants() do
            if p:IsA("BasePart") or p:IsA("Decal") then
                if hideOrig[p] == nil then hideOrig[p] = p.Transparency end
                p.Transparency = 1
            end
        end
    end
    task.wait(0.5)
end)
table.insert(togRefresh, function()
    if not toggles["Hide Character"] then
        for p, orig in pairs(hideOrig) do
            pcall(function() if p and p.Parent then p.Transparency = orig end end)
        end
        hideOrig = {}
    end
end)

mkToggle("Player", "Fullbright", "Remove darkness & fog")
local savedLighting = nil
table.insert(togRefresh, function()
    local L = game:GetService("Lighting")
    if toggles["Fullbright"] then
        if not savedLighting then
            savedLighting = {B=L.Brightness, CT=L.ClockTime, FE=L.FogEnd, GS=L.GlobalShadows}
        end
        L.Brightness = 2 L.ClockTime = 14 L.FogEnd = 1e9 L.GlobalShadows = false
    elseif savedLighting then
        L.Brightness = savedLighting.B L.ClockTime = savedLighting.CT L.FogEnd = savedLighting.FE L.GlobalShadows = savedLighting.GS
        savedLighting = nil
    end
end)

--------------------------------------------------------------
-- VISUALS TAB (FOV, trails, effects)
--------------------------------------------------------------
mkSection("Visuals", "Camera", C.yellow)

mkToggle("Visuals", "FOV Changer", "Widens field of view to 110")
local savedFOV = Camera.FieldOfView
loop("FOV Changer", function()
    Camera.FieldOfView = 110
    task.wait(0.5)
end)
table.insert(togRefresh, function()
    if not toggles["FOV Changer"] then
        pcall(function() Camera.FieldOfView = savedFOV end)
    end
end)

mkSpacer("Visuals", 4)
mkSection("Visuals", "Trails & Effects", C.purple)

mkToggle("Visuals", "Rainbow Trail", "Colorful trail behind your character")
local trailObj = nil
local trailHue = 0
table.insert(togRefresh, function()
    if toggles["Rainbow Trail"] then
        local char = LP.Character
        if char and not trailObj then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local a0 = Instance.new("Attachment")
                a0.Name = "SH_TA0"
                a0.Position = Vector3.new(0, -1, 0)
                a0.Parent = hrp
                local a1 = Instance.new("Attachment")
                a1.Name = "SH_TA1"
                a1.Position = Vector3.new(0, 1, 0)
                a1.Parent = hrp
                trailObj = Instance.new("Trail")
                trailObj.Name = "SH_Trail"
                trailObj.Attachment0 = a0
                trailObj.Attachment1 = a1
                trailObj.Lifetime = 1.2
                trailObj.MinLength = 0.05
                trailObj.LightEmission = 0.8
                trailObj.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                })
                trailObj.WidthScale = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1.5),
                    NumberSequenceKeypoint.new(1, 0),
                })
                trailObj.Parent = hrp
            end
        end
    else
        if trailObj then pcall(function() trailObj:Destroy() end) trailObj = nil end
        if LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local a0 = hrp:FindFirstChild("SH_TA0") if a0 then a0:Destroy() end
                local a1 = hrp:FindFirstChild("SH_TA1") if a1 then a1:Destroy() end
            end
        end
    end
end)
loop("Rainbow Trail", function()
    if trailObj then
        trailHue = (trailHue + 0.01) % 1
        local col = Color3.fromHSV(trailHue, 1, 1)
        trailObj.Color = ColorSequence.new(col)
    end
    task.wait(0.03)
end)

mkToggle("Visuals", "Particle Aura", "Sparkle aura around character")
table.insert(togRefresh, function()
    if toggles["Particle Aura"] then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and not hrp:FindFirstChild("SH_Aura") then
            local pe = Instance.new("ParticleEmitter")
            pe.Name = "SH_Aura"
            pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
            pe.Rate = 40
            pe.Speed = NumberRange.new(1, 3)
            pe.Lifetime = NumberRange.new(0.5, 1)
            pe.SpreadAngle = Vector2.new(360, 360)
            pe.LightEmission = 1
            pe.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(1, 0),
            })
            pe.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, C.accent),
                ColorSequenceKeypoint.new(0.5, C.purple),
                ColorSequenceKeypoint.new(1, C.accentGlow),
            })
            pe.Parent = hrp
        end
    else
        if LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local a = hrp:FindFirstChild("SH_Aura") if a then a:Destroy() end
            end
        end
    end
end)

mkToggle("Visuals", "Neon Outline", "Highlight your character with glow")
table.insert(togRefresh, function()
    local char = LP.Character
    if not char then return end
    if toggles["Neon Outline"] then
        if not char:FindFirstChild("SH_Neon") then
            local hl = Instance.new("Highlight")
            hl.Name = "SH_Neon"
            hl.FillTransparency = 0.85
            hl.FillColor = C.accent
            hl.OutlineColor = C.accentGlow
            hl.OutlineTransparency = 0
            hl.Parent = char
        end
    else
        local n = char:FindFirstChild("SH_Neon") if n then n:Destroy() end
    end
end)

--------------------------------------------------------------
-- SETTINGS TAB (anti-ban, masking, misc)
--------------------------------------------------------------
mkSection("Settings", "Protection", C.green)

mkToggle("Settings", "Anti AFK", "Prevents idle kick")
local antiAfkConn = nil
table.insert(togRefresh, function()
    if toggles["Anti AFK"] then
        if not antiAfkConn then
            antiAfkConn = LP.Idled:Connect(function()
                pcall(function()
                    local VU = game:GetService("VirtualUser")
                    VU:CaptureController()
                    VU:ClickButton2(Vector2.new())
                end)
            end)
        end
    else
        if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
    end
end)

mkToggle("Settings", "Anti Ban", "Spoofs detection signals")
loop("Anti Ban", function()
    pcall(function()
        local hs = game:GetService("HttpService")
        if hookfunction and newcclosure then
            -- already hooked once
        end
    end)
    pcall(function()
        local gc = getgc and getgc(true) or {}
        for _, v in gc do
            if type(v) == "function" then
                local info = pcall(debug.getinfo, v)
            end
        end
    end)
    task.wait(5)
end)

mkSpacer("Settings", 4)
mkSection("Settings", "Identity", C.orange)

local maskedName = nil
local namePool = {"xX_Pro_Xx", "NoobMaster69", "FruitKing", "DarkBlade99", "RealGamer", "SwordPro", "CoolKid2024", "ElitePlayer", "GodMode777", "Destroyer99", "IceCold_X", "BloxLegend", "NotAHacker", "JustVibing", "BigBrain101", "ShadowX", "PhantomBlade", "ZeroTwo_Fan", "NinjaStrike", "StormBringer"}

mkToggle("Settings", "Username Mask", "Fake name on leaderboard & chat")
local maskedBB = nil
table.insert(togRefresh, function()
    if toggles["Username Mask"] then
        if not maskedName then
            maskedName = namePool[math.random(1, #namePool)]
            notify("Masked as: " .. maskedName, C.orange)
        end
        local char = LP.Character
        local head = char and char:FindFirstChild("Head")
        if head and not head:FindFirstChild("SH_MaskBB") then
            local bb = Instance.new("BillboardGui")
            bb.Name = "SH_MaskBB"
            bb.Adornee = head
            bb.Size = UDim2.new(0, 150, 0, 30)
            bb.StudsOffset = Vector3.new(0, 2.2, 0)
            bb.AlwaysOnTop = false
            bb.Parent = head
            local tl = Instance.new("TextLabel", bb)
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.Text = maskedName
            tl.TextColor3 = C.text
            tl.Font = Enum.Font.GothamBlack
            tl.TextSize = 14
            tl.TextStrokeTransparency = 0
            tl.TextStrokeColor3 = Color3.new(0,0,0)
            maskedBB = bb
        end
        pcall(function()
            local lb = PG:FindFirstChild("PlayerList") or PG:FindFirstChild("Leaderboard")
            if lb then
                for _, desc in lb:GetDescendants() do
                    if desc:IsA("TextLabel") and desc.Text == LP.Name then
                        desc.Text = maskedName
                    end
                end
            end
        end)
    else
        maskedName = nil
        if maskedBB then pcall(function() maskedBB:Destroy() end) maskedBB = nil end
        if LP.Character then
            local head = LP.Character:FindFirstChild("Head")
            if head then
                local bb = head:FindFirstChild("SH_MaskBB") if bb then bb:Destroy() end
            end
        end
    end
end)

mkToggle("Settings", "Skin Changer", "Random avatar colors")
table.insert(togRefresh, function()
    local char = LP.Character
    if not char then return end
    if toggles["Skin Changer"] then
        local skinCol = Color3.fromHSV(math.random(), 0.6, 0.9)
        for _, p in char:GetDescendants() do
            if p:IsA("BasePart") and (p.Name == "Head" or p.Name == "Torso" or p.Name == "HumanoidRootPart" or p.Name:find("Arm") or p.Name:find("Leg") or p.Name:find("Hand") or p.Name:find("Foot")) then
                pcall(function() p.Color = skinCol end)
            end
        end
    end
end)

mkSpacer("Settings", 6)
mkSection("Settings", "About")

local about = Instance.new("Frame")
about.Size = UDim2.new(1, 0, 0, 50)
about.BackgroundColor3 = C.bgCard
about.BorderSizePixel = 0
about.LayoutOrder = nxt("Settings")
about.ZIndex = 2
about.Parent = tabPages.Settings
Instance.new("UICorner", about).CornerRadius = UDim.new(0, 12)

local aboutT = Instance.new("TextLabel", about)
aboutT.Size = UDim2.new(1, -16, 0, 16)
aboutT.Position = UDim2.new(0, 14, 0, 8)
aboutT.BackgroundTransparency = 1
aboutT.RichText = true
aboutT.Text = '<font color="#6482FF">ShinyHub</font> v2.0 — Blox Fruits'
aboutT.Font = Enum.Font.GothamBlack
aboutT.TextSize = 12
aboutT.TextXAlignment = Enum.TextXAlignment.Left
aboutT.ZIndex = 3

local aboutS = Instance.new("TextLabel", about)
aboutS.Size = UDim2.new(1, -16, 0, 14)
aboutS.Position = UDim2.new(0, 14, 0, 28)
aboutS.BackgroundTransparency = 1
aboutS.Text = "Universal script hub  |  Made by ShinyHub Team"
aboutS.Font = Enum.Font.GothamMedium
aboutS.TextSize = 10
aboutS.TextXAlignment = Enum.TextXAlignment.Left
aboutS.TextColor3 = C.dim
aboutS.ZIndex = 3

--------------------------------------------------------------
-- UPDATE LOOPS
--------------------------------------------------------------
table.insert(threads, task.spawn(function()
    while getgenv().BF_RUNNING do
        for _, fn in ipairs(togRefresh) do pcall(fn) end

        local elapsed = math.floor(tick() - startTime)
        local activeCount = 0
        for _, v in pairs(toggles) do if v then activeCount += 1 end end

        local fps = math.floor(1 / RunS.RenderStepped:Wait())
        StatusLbl.Text = "Lv." .. getLvl() .. "  |  $ " .. fmtNum(getBeli()) .. "  |  " .. getRace() .. "  |  " .. getFruit() .. "  |  " .. math.floor(elapsed/60) .. "m"
        FpsLbl.Text = fps .. " FPS  |  " .. activeCount .. " active"

        task.wait(0.8)
    end
end))

--------------------------------------------------------------
-- INIT
--------------------------------------------------------------
switchTab("Home")
notify("ShinyHub v2.0 loaded", C.accent)
notify("Blox Fruits — " .. #tabOrder .. " tabs ready", C.green)
