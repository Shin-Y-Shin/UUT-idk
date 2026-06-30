--[[
    ShinyHub — Blox Fruits v1.0
    Modern script hub | Auto farm | Fruit sniper | ESP
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
-- ACCENT & STYLE
--------------------------------------------------------------
local accent = Color3.fromRGB(90, 120, 255)
local accent2 = Color3.fromRGB(120, 80, 255)
local bgMain = Color3.fromRGB(15, 15, 22)
local bgCard = Color3.fromRGB(22, 22, 32)
local bgCardH = Color3.fromRGB(30, 30, 44)
local bgSide = Color3.fromRGB(18, 18, 26)
local bgHeader = Color3.fromRGB(12, 12, 18)
local textCol = Color3.fromRGB(235, 235, 245)
local subCol = Color3.fromRGB(130, 130, 160)
local dimCol = Color3.fromRGB(70, 70, 95)
local onCol = Color3.fromRGB(90, 120, 255)
local offCol = Color3.fromRGB(35, 35, 50)
local borderCol = Color3.fromRGB(40, 40, 58)

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
-- NOTIFICATIONS
--------------------------------------------------------------
local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0, 240, 1, 0)
NotifHolder.Position = UDim2.new(1, -250, 0, 0)
NotifHolder.BackgroundTransparency = 1
NotifHolder.ZIndex = 100
NotifHolder.Parent = Gui
local nl = Instance.new("UIListLayout", NotifHolder)
nl.SortOrder = Enum.SortOrder.LayoutOrder
nl.Padding = UDim.new(0, 5)
nl.VerticalAlignment = Enum.VerticalAlignment.Bottom

local notifCount = 0
local function notify(text, color)
    notifCount += 1
    color = color or accent
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    f.BorderSizePixel = 0
    f.ZIndex = 101
    f.LayoutOrder = notifCount
    f.BackgroundTransparency = 1
    f.Parent = NotifHolder
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local strk = Instance.new("UIStroke", f)
    strk.Thickness = 1
    strk.Color = color
    strk.Transparency = 0.7

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(0, 3, 0.6, 0)
    bar.Position = UDim2.new(0, 6, 0.2, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.ZIndex = 102
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -20, 1, 0)
    l.Position = UDim2.new(0, 16, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = textCol
    l.ZIndex = 102

    tw(f, {BackgroundTransparency = 0.05}, 0.3)
    task.delay(3.5, function()
        tw(f, {BackgroundTransparency = 1}, 0.4)
        tw(l, {TextTransparency = 1}, 0.4)
        tw(strk, {Transparency = 1}, 0.4)
        task.wait(0.5) f:Destroy()
    end)
end

--------------------------------------------------------------
-- DATA HELPERS
--------------------------------------------------------------
local function fmtNum(n)
    if not n or n == 0 then return "0" end
    local s = {"K","M","B","T","Qd","Qn"}
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
local W, H = 560, 380

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, W, 0, H)
Main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
Main.BackgroundColor3 = bgMain
Main.BorderSizePixel = 0
Main.ZIndex = 1
Main.ClipsDescendants = true
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Thickness = 1
mainStroke.Color = borderCol
mainStroke.Transparency = 0.5

-- Glow accent line at top
local TopGlow = Instance.new("Frame", Main)
TopGlow.Size = UDim2.new(1, 0, 0, 2)
TopGlow.Position = UDim2.new(0, 0, 0, 0)
TopGlow.BorderSizePixel = 0
TopGlow.ZIndex = 20
TopGlow.BackgroundColor3 = accent

--------------------------------------------------------------
-- HEADER
--------------------------------------------------------------
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Position = UDim2.new(0, 0, 0, 2)
Header.BackgroundColor3 = bgHeader
Header.BorderSizePixel = 0
Header.ZIndex = 10

local Logo = Instance.new("TextLabel", Header)
Logo.Size = UDim2.new(0, 140, 1, 0)
Logo.Position = UDim2.new(0, 16, 0, 0)
Logo.BackgroundTransparency = 1
Logo.RichText = true
Logo.Text = '<font color="#5A78FF">Shiny</font><font color="#EEEEF5">Hub</font>'
Logo.Font = Enum.Font.GothamBlack
Logo.TextSize = 15
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.ZIndex = 11

local GameTag = Instance.new("TextLabel", Header)
GameTag.Size = UDim2.new(0, 80, 0, 16)
GameTag.Position = UDim2.new(0, 108, 0.5, -8)
GameTag.BackgroundColor3 = accent
GameTag.BackgroundTransparency = 0.85
GameTag.Text = "BLOX FRUITS"
GameTag.Font = Enum.Font.GothamBlack
GameTag.TextSize = 7
GameTag.TextColor3 = accent
GameTag.ZIndex = 12
Instance.new("UICorner", GameTag).CornerRadius = UDim.new(0, 4)

-- Window controls
local isMinimized = false
local controlX = W - 16
for i, info in ipairs({{"\xE2\x9C\x95", Color3.fromRGB(255,80,80)}, {"\xE2\x80\x93", Color3.fromRGB(255,190,50)}, {"\xE2\x97\x8B", Color3.fromRGB(80,200,80)}}) do
    controlX -= 22
    local btn = Instance.new("TextButton", Header)
    btn.Size = UDim2.new(0, 18, 0, 18)
    btn.Position = UDim2.new(0, controlX, 0.5, -9)
    btn.BackgroundColor3 = info[2]
    btn.BackgroundTransparency = 0.8
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    btn.MouseEnter:Connect(function() tw(btn, {BackgroundTransparency = 0.3}, 0.1) end)
    btn.MouseLeave:Connect(function() tw(btn, {BackgroundTransparency = 0.8}, 0.15) end)

    if i == 1 then
        btn.MouseButton1Click:Connect(function()
            getgenv().BF_RUNNING = false
            Gui:Destroy()
        end)
    elseif i == 2 then
        btn.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            tw(Main, {Size = isMinimized and UDim2.new(0, W, 0, 42) or UDim2.new(0, W, 0, H)}, 0.35, Enum.EasingStyle.Back)
        end)
    end
end

-- FPS + Active count in header
local HeaderInfo = Instance.new("TextLabel", Header)
HeaderInfo.Size = UDim2.new(0, 160, 1, 0)
HeaderInfo.Position = UDim2.new(0, 200, 0, 0)
HeaderInfo.BackgroundTransparency = 1
HeaderInfo.Font = Enum.Font.Gotham
HeaderInfo.TextSize = 9
HeaderInfo.TextColor3 = dimCol
HeaderInfo.TextXAlignment = Enum.TextXAlignment.Left
HeaderInfo.ZIndex = 11

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
-- SIDEBAR (icon-based, slim)
--------------------------------------------------------------
local SideW = 48
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, SideW, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = bgSide
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 5

local SideDiv = Instance.new("Frame", Sidebar)
SideDiv.Size = UDim2.new(0, 1, 1, 0)
SideDiv.Position = UDim2.new(1, 0, 0, 0)
SideDiv.BackgroundColor3 = borderCol
SideDiv.BorderSizePixel = 0
SideDiv.ZIndex = 6

local SideIndicator = Instance.new("Frame", Sidebar)
SideIndicator.Size = UDim2.new(0, 3, 0, 24)
SideIndicator.Position = UDim2.new(0, 0, 0, 8)
SideIndicator.BackgroundColor3 = accent
SideIndicator.BorderSizePixel = 0
SideIndicator.ZIndex = 8
Instance.new("UICorner", SideIndicator).CornerRadius = UDim.new(0, 2)

local tabOrder = {"Home", "Farm", "Combat", "Teleport", "Settings"}
local tabIcons = {
    Home = "\xF0\x9F\x8F\xA0",
    Farm = "\xE2\x9A\x99\xEF\xB8\x8F",
    Combat = "\xE2\x9A\x94\xEF\xB8\x8F",
    Teleport = "\xF0\x9F\x8C\x80",
    Settings = "\xE2\x9A\xA1",
}
local tabDescs = {
    Home = "Overview & player stats",
    Farm = "Automated farming",
    Combat = "Combat & ESP",
    Teleport = "Island teleports",
    Settings = "Player mods & themes",
}

local tabPages = {}
local tabBtns = {}
local activeTab = "Home"
local layoutCounters = {}
local function nxt(tab) layoutCounters[tab] = (layoutCounters[tab] or 0) + 1 return layoutCounters[tab] end

for i, name in ipairs(tabOrder) do
    -- Icon button
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, (i-1) * 42 + 6)
    btn.BackgroundTransparency = 1
    btn.Text = tabIcons[name]
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.ZIndex = 7
    btn.AutoButtonColor = false
    btn.TextColor3 = dimCol

    tabBtns[name] = btn

    -- Page
    local page = Instance.new("ScrollingFrame", Main)
    page.Size = UDim2.new(1, -(SideW + 16), 1, -82)
    page.Position = UDim2.new(0, SideW + 8, 0, 72)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = dimCol
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 2

    local pl = Instance.new("UIListLayout", page)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0, 5)

    tabPages[name] = page
end

-- Page title & subtitle
local PageTitle = Instance.new("TextLabel", Main)
PageTitle.Size = UDim2.new(1, -(SideW + 16), 0, 18)
PageTitle.Position = UDim2.new(0, SideW + 10, 0, 46)
PageTitle.BackgroundTransparency = 1
PageTitle.Font = Enum.Font.GothamBlack
PageTitle.TextSize = 15
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.TextColor3 = textCol
PageTitle.ZIndex = 3

local PageSub = Instance.new("TextLabel", Main)
PageSub.Size = UDim2.new(1, -(SideW + 16), 0, 12)
PageSub.Position = UDim2.new(0, SideW + 10, 0, 64)
PageSub.BackgroundTransparency = 1
PageSub.Font = Enum.Font.Gotham
PageSub.TextSize = 9
PageSub.TextXAlignment = Enum.TextXAlignment.Left
PageSub.TextColor3 = dimCol
PageSub.ZIndex = 3

-- Status bar
local StatusBar = Instance.new("Frame", Main)
StatusBar.Size = UDim2.new(1, 0, 0, 20)
StatusBar.Position = UDim2.new(0, 0, 1, -20)
StatusBar.BackgroundColor3 = bgHeader
StatusBar.BorderSizePixel = 0
StatusBar.ZIndex = 10

local StatusLbl = Instance.new("TextLabel", StatusBar)
StatusLbl.Size = UDim2.new(1, -16, 1, 0)
StatusLbl.Position = UDim2.new(0, 8, 0, 0)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 9
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.TextColor3 = dimCol
StatusLbl.ZIndex = 11

-- Tab switching
local function switchTab(name)
    activeTab = name
    for n, p in pairs(tabPages) do p.Visible = (n == name) end

    PageTitle.Text = name
    PageSub.Text = tabDescs[name] or ""

    for n, btn in pairs(tabBtns) do
        if n == name then
            tw(btn, {TextColor3 = accent}, 0.15)
            local yPos = btn.Position.Y.Offset
            tw(SideIndicator, {Position = UDim2.new(0, 0, 0, yPos + 8)}, 0.25, Enum.EasingStyle.Back)
        else
            tw(btn, {TextColor3 = dimCol}, 0.15)
        end
    end
end

for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.MouseEnter:Connect(function()
        if name ~= activeTab then tw(btn, {TextColor3 = subCol}, 0.08) end
    end)
    btn.MouseLeave:Connect(function()
        if name ~= activeTab then tw(btn, {TextColor3 = dimCol}, 0.1) end
    end)
end

--------------------------------------------------------------
-- UI BUILDERS
--------------------------------------------------------------
local function mkSection(tab, txt)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.LayoutOrder = nxt(tab)
    f.ZIndex = 2
    f.Parent = tabPages[tab]
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -8, 1, 0)
    l.Position = UDim2.new(0, 4, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = string.upper(txt)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 9
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = accent
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
    row.Size = UDim2.new(1, 0, 0, desc and 36 or 30)
    row.BackgroundColor3 = bgCard
    row.BorderSizePixel = 0
    row.LayoutOrder = nxt(tab)
    row.ZIndex = 2
    row.Parent = tabPages[tab]
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local l = Instance.new("TextLabel", row)
    l.Size = UDim2.new(1, -65, 0, desc and 16 or 30)
    l.Position = UDim2.new(0, 14, 0, desc and 3 or 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = textCol
    l.ZIndex = 3

    if desc then
        local d = Instance.new("TextLabel", row)
        d.Size = UDim2.new(1, -65, 0, 12)
        d.Position = UDim2.new(0, 14, 0, 20)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.Font = Enum.Font.Gotham
        d.TextSize = 8
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextColor3 = dimCol
        d.ZIndex = 3
    end

    local track = Instance.new("TextButton", row)
    track.Size = UDim2.new(0, 34, 0, 18)
    track.Position = UDim2.new(1, -46, 0.5, -9)
    track.BackgroundColor3 = offCol
    track.Text = ""
    track.BorderSizePixel = 0
    track.AutoButtonColor = false
    track.ZIndex = 4
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(140,140,140)
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function ref()
        local on = toggles[name]
        tw(track, {BackgroundColor3 = on and onCol or offCol}, 0.2)
        tw(knob, {
            Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,140)
        }, 0.2)
    end
    table.insert(togRefresh, ref)

    track.MouseButton1Click:Connect(function()
        toggles[name] = not toggles[name]
        for _, fn in ipairs(togRefresh) do pcall(fn) end
    end)

    row.MouseEnter:Connect(function() tw(row, {BackgroundColor3 = bgCardH}, 0.08) end)
    row.MouseLeave:Connect(function() tw(row, {BackgroundColor3 = bgCard}, 0.1) end)
end

local function mkButton(tab, txt, cb)
    local b = Instance.new("TextButton")
    b.LayoutOrder = nxt(tab)
    b.Size = UDim2.new(1, 0, 0, 30)
    b.Text = ""
    b.BackgroundColor3 = bgCard
    b.BorderSizePixel = 0
    b.ZIndex = 2
    b.AutoButtonColor = false
    b.Parent = tabPages[tab]
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1, -30, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = subCol
    l.ZIndex = 3

    local arrow = Instance.new("TextLabel", b)
    arrow.Size = UDim2.new(0, 14, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "\xE2\x86\x92"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 12
    arrow.TextColor3 = dimCol
    arrow.ZIndex = 3

    b.MouseButton1Click:Connect(function()
        tw(b, {BackgroundColor3 = accent}, 0.05)
        tw(l, {TextColor3 = bgMain}, 0.05)
        task.delay(0.15, function()
            tw(b, {BackgroundColor3 = bgCard}, 0.3)
            tw(l, {TextColor3 = subCol}, 0.3)
        end)
        if cb then cb() end
    end)
    b.MouseEnter:Connect(function() tw(b, {BackgroundColor3 = bgCardH}, 0.08) tw(arrow, {TextColor3 = accent}, 0.08) end)
    b.MouseLeave:Connect(function() tw(b, {BackgroundColor3 = bgCard}, 0.1) tw(arrow, {TextColor3 = dimCol}, 0.1) end)
end

local function mkStatRow(tab, label, fn)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundColor3 = bgCard
    f.BorderSizePixel = 0
    f.LayoutOrder = nxt(tab)
    f.ZIndex = 2
    f.Parent = tabPages[tab]
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = dimCol
    lbl.ZIndex = 3

    local val = Instance.new("TextLabel", f)
    val.Size = UDim2.new(0.55, -14, 1, 0)
    val.Position = UDim2.new(0.45, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = tostring(fn())
    val.Font = Enum.Font.GothamBlack
    val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.TextColor3 = textCol
    val.ZIndex = 3

    table.insert(togRefresh, function() val.Text = tostring(fn()) end)
end

--------------------------------------------------------------
-- HOME TAB
--------------------------------------------------------------
mkSection("Home", "Player Stats")
mkStatRow("Home", "BELI", function() return "$" .. fmtNum(getBeli()) end)
mkStatRow("Home", "LEVEL", function() return tostring(getLvl()) end)
mkStatRow("Home", "EXP", function() return fmtNum(getExp()) end)
mkStatRow("Home", "FRUIT", function() return getFruit() end)
mkStatRow("Home", "RACE", function() return getRace() end)
mkStatRow("Home", "FRAGMENTS", function() return fmtNum(getFrags()) end)

mkSpacer("Home", 6)
mkSection("Home", "Session")

local startBeli = getBeli()
local startTime = tick()
mkStatRow("Home", "UPTIME", function()
    local e = math.floor(tick() - startTime)
    return math.floor(e/60) .. "m " .. (e%60) .. "s"
end)
mkStatRow("Home", "EARNED", function() return "$" .. fmtNum(getBeli() - startBeli) end)

mkSpacer("Home", 6)
mkSection("Home", "Quick Actions")
mkButton("Home", "Disable All", function()
    for k in pairs(toggles) do toggles[k] = false end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    notify("All disabled", Color3.fromRGB(255,180,30))
end)

--------------------------------------------------------------
-- FARM TAB
--------------------------------------------------------------
mkSection("Farm", "Auto Farm")

mkToggle("Farm", "Auto Attack Nearest", "Teleports to & attacks closest enemy")
loop("Auto Attack Nearest", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then task.wait(1) return end

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
        if mHrp then hrp.CFrame = mHrp.CFrame * CFrame.new(0, 0, 3) end
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.1)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end
    task.wait(0.25)
end)

mkToggle("Farm", "Bring Mobs", "Pulls all nearby enemies to you")
loop("Bring Mobs", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then task.wait(1) return end

    local enemies = game.Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in enemies:GetChildren() do
            local mHrp = mob:FindFirstChild("HumanoidRootPart")
            local mHum = mob:FindFirstChild("Humanoid")
            if mHrp and mHum and mHum.Health > 0 then
                if (mHrp.Position - hrp.Position).Magnitude < 200 then
                    mHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 5)
                end
            end
        end
    end
    task.wait(0.3)
end)

mkSpacer("Farm", 4)
mkSection("Farm", "Collection")

mkToggle("Farm", "Fruit Sniper", "Alerts when a fruit spawns on map")
loop("Fruit Sniper", function()
    local ff = game.Workspace:FindFirstChild("Fruit ") or game.Workspace:FindFirstChild("Fruit")
    if ff then
        for _, fruit in ff:GetChildren() do
            if fruit:IsA("Tool") or fruit:IsA("Model") then
                notify("FRUIT SPAWNED: " .. fruit.Name, Color3.fromRGB(50,255,50))
                task.wait(10)
            end
        end
    end
    task.wait(3)
end)

mkToggle("Farm", "Auto Chest", "Collects nearby treasure chests")
loop("Auto Chest", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then task.wait(1) return end

    local chests = game.Workspace:FindFirstChild("ChestModels")
    if chests then
        for _, chest in chests:GetChildren() do
            for _, d in chest:GetDescendants() do
                if d:IsA("ProximityPrompt") then
                    local p = chest:FindFirstChildOfClass("BasePart") or chest.PrimaryPart
                    if p and (p.Position - hrp.Position).Magnitude < 80 then
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

mkToggle("Farm", "Auto Quest", "Interacts with nearby quest NPCs")
loop("Auto Quest", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then task.wait(1) return end

    local npcs = game.Workspace:FindFirstChild("NPCs")
    if npcs then
        for _, npc in npcs:GetChildren() do
            for _, d in npc:GetDescendants() do
                if d:IsA("ProximityPrompt") then
                    local nPart = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
                    if nPart and (nPart.Position - hrp.Position).Magnitude < 50 then
                        pcall(function() fireproximityprompt(d) end)
                    end
                end
            end
        end
    end
    task.wait(2)
end)

--------------------------------------------------------------
-- COMBAT TAB
--------------------------------------------------------------
mkSection("Combat", "Abilities")

mkToggle("Combat", "Auto Ability Spam", "Spams Z/X/C/V abilities")
loop("Auto Ability Spam", function()
    local vim = game:GetService("VirtualInputManager")
    for _, key in ipairs({Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}) do
        pcall(function()
            vim:SendKeyEvent(true, key, false, game)
            task.wait(0.05)
            vim:SendKeyEvent(false, key, false, game)
        end)
        task.wait(0.25)
    end
end)

mkToggle("Combat", "Kill Aura", "Attacks all enemies in range")
loop("Kill Aura", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then task.wait(1) return end
    local enemies = game.Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in enemies:GetChildren() do
            local mHrp = mob:FindFirstChild("HumanoidRootPart")
            local mHum = mob:FindFirstChild("Humanoid")
            if mHrp and mHum and mHum.Health > 0 and (mHrp.Position - hrp.Position).Magnitude < 50 then
                pcall(function()
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.05)
                    vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end)
            end
        end
    end
    task.wait(0.2)
end)

mkSpacer("Combat", 6)
mkSection("Combat", "ESP")

mkToggle("Combat", "Player ESP", "Highlight all players with nametags")
local playerEspFolder = nil
table.insert(togRefresh, function()
    if toggles["Player ESP"] then
        if not playerEspFolder then
            playerEspFolder = Instance.new("Folder")
            playerEspFolder.Name = "SH_PESP"
            playerEspFolder.Parent = game.CoreGui
        end
    else
        if playerEspFolder then playerEspFolder:Destroy() playerEspFolder = nil end
        for _, p in Players:GetPlayers() do
            if p ~= LP and p.Character then
                local h = p.Character:FindFirstChild("SH_HL")
                if h then h:Destroy() end
            end
        end
    end
end)
loop("Player ESP", function()
    if not playerEspFolder then task.wait(1) return end
    for _, bb in playerEspFolder:GetChildren() do bb:Destroy() end
    for _, p in Players:GetPlayers() do
        if p ~= LP then
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local bb = Instance.new("BillboardGui")
                bb.Adornee = hrp
                bb.Size = UDim2.new(0, 120, 0, 24)
                bb.StudsOffset = Vector3.new(0, 3.5, 0)
                bb.AlwaysOnTop = true
                bb.Parent = playerEspFolder
                local tl = Instance.new("TextLabel", bb)
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = p.Name .. " [" .. math.floor(hum.Health) .. "]"
                tl.TextColor3 = accent
                tl.Font = Enum.Font.GothamBold
                tl.TextSize = 10
                tl.TextStrokeTransparency = 0.4

                if not char:FindFirstChild("SH_HL") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "SH_HL"
                    hl.FillTransparency = 0.75
                    hl.FillColor = accent
                    hl.OutlineColor = accent
                    hl.OutlineTransparency = 0.2
                    hl.Parent = char
                end
            end
        end
    end
    task.wait(1.5)
end)

mkToggle("Combat", "Enemy ESP", "Show enemy names & HP through walls")
local enemyEspFolder = nil
table.insert(togRefresh, function()
    if toggles["Enemy ESP"] then
        if not enemyEspFolder then
            enemyEspFolder = Instance.new("Folder")
            enemyEspFolder.Name = "SH_EESP"
            enemyEspFolder.Parent = game.CoreGui
        end
    else
        if enemyEspFolder then enemyEspFolder:Destroy() enemyEspFolder = nil end
    end
end)
loop("Enemy ESP", function()
    if not enemyEspFolder then task.wait(1) return end
    for _, bb in enemyEspFolder:GetChildren() do bb:Destroy() end
    local enemies = game.Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in enemies:GetChildren() do
            local mHrp = mob:FindFirstChild("HumanoidRootPart")
            local mHum = mob:FindFirstChild("Humanoid")
            if mHrp and mHum and mHum.Health > 0 then
                local bb = Instance.new("BillboardGui")
                bb.Adornee = mHrp
                bb.Size = UDim2.new(0, 140, 0, 22)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true
                bb.Parent = enemyEspFolder
                local tl = Instance.new("TextLabel", bb)
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = mob.Name .. "  " .. math.floor(mHum.Health) .. "/" .. math.floor(mHum.MaxHealth)
                tl.TextColor3 = Color3.fromRGB(255, 90, 90)
                tl.Font = Enum.Font.GothamBold
                tl.TextSize = 9
                tl.TextStrokeTransparency = 0.4
            end
        end
    end
    task.wait(2)
end)

mkToggle("Combat", "Fruit ESP", "Highlight fruits on the map")
local fruitEspFolder = nil
table.insert(togRefresh, function()
    if toggles["Fruit ESP"] then
        if not fruitEspFolder then
            fruitEspFolder = Instance.new("Folder")
            fruitEspFolder.Name = "SH_FESP"
            fruitEspFolder.Parent = game.CoreGui
        end
    else
        if fruitEspFolder then fruitEspFolder:Destroy() fruitEspFolder = nil end
    end
end)
loop("Fruit ESP", function()
    if not fruitEspFolder then task.wait(1) return end
    for _, bb in fruitEspFolder:GetChildren() do bb:Destroy() end
    local ff = game.Workspace:FindFirstChild("Fruit ") or game.Workspace:FindFirstChild("Fruit")
    if ff then
        for _, fruit in ff:GetChildren() do
            local part = fruit:IsA("BasePart") and fruit or fruit:FindFirstChildOfClass("BasePart") or (fruit:IsA("Model") and fruit.PrimaryPart)
            if part then
                local bb = Instance.new("BillboardGui")
                bb.Adornee = part
                bb.Size = UDim2.new(0, 130, 0, 26)
                bb.StudsOffset = Vector3.new(0, 5, 0)
                bb.AlwaysOnTop = true
                bb.Parent = fruitEspFolder
                local tl = Instance.new("TextLabel", bb)
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = fruit.Name
                tl.TextColor3 = Color3.fromRGB(50, 255, 100)
                tl.Font = Enum.Font.GothamBlack
                tl.TextSize = 13
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
        if not hrp then notify("No character", Color3.fromRGB(255,80,80)) return end
        local cf = IslandPositions[name]
        if cf then
            hrp.CFrame = cf
            notify("Teleported to " .. name, Color3.fromRGB(80,200,80))
        end
    end)
end

--------------------------------------------------------------
-- SETTINGS TAB
--------------------------------------------------------------
mkSection("Settings", "Player Mods")

local defaultWS = 16
local defaultJP = 50

mkToggle("Settings", "Speed Boost", "WalkSpeed 100")
loop("Speed Boost", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 100 end
    task.wait(0.5)
end)
table.insert(togRefresh, function()
    if not toggles["Speed Boost"] then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = defaultWS end
    end
end)

mkToggle("Settings", "Jump Boost", "JumpPower 120")
loop("Jump Boost", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 120 end
    task.wait(0.5)
end)
table.insert(togRefresh, function()
    if not toggles["Jump Boost"] then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = defaultJP end
    end
end)

mkToggle("Settings", "Infinite Jump", "Jump mid-air")
UIS.JumpRequest:Connect(function()
    if toggles["Infinite Jump"] and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

mkToggle("Settings", "Noclip", "Walk through walls")
local noclipOrig = {}
RunS.Stepped:Connect(function()
    if toggles["Noclip"] and LP.Character then
        for _, p in LP.Character:GetDescendants() do
            if p:IsA("BasePart") then
                if noclipOrig[p] == nil then noclipOrig[p] = p.CanCollide end
                p.CanCollide = false
            end
        end
    end
end)
table.insert(togRefresh, function()
    if not toggles["Noclip"] then
        for p, orig in pairs(noclipOrig) do
            pcall(function() if p and p.Parent then p.CanCollide = orig end end)
        end
        noclipOrig = {}
    end
end)

mkToggle("Settings", "Fullbright", "Remove darkness & shadows")
local savedLight = nil
table.insert(togRefresh, function()
    local L = game:GetService("Lighting")
    if toggles["Fullbright"] then
        if not savedLight then
            savedLight = {B=L.Brightness, CT=L.ClockTime, FE=L.FogEnd, GS=L.GlobalShadows}
        end
        L.Brightness = 2 L.ClockTime = 14 L.FogEnd = 1e9 L.GlobalShadows = false
    elseif savedLight then
        L.Brightness = savedLight.B L.ClockTime = savedLight.CT L.FogEnd = savedLight.FE L.GlobalShadows = savedLight.GS
        savedLight = nil
    end
end)

mkToggle("Settings", "Hide Character", "Invisible locally")
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

mkSpacer("Settings", 6)
mkSection("Settings", "About")

local about = Instance.new("Frame")
about.Size = UDim2.new(1, 0, 0, 44)
about.BackgroundColor3 = bgCard
about.BorderSizePixel = 0
about.LayoutOrder = nxt("Settings")
about.ZIndex = 2
about.Parent = tabPages.Settings
Instance.new("UICorner", about).CornerRadius = UDim.new(0, 10)

local aboutTitle = Instance.new("TextLabel", about)
aboutTitle.Size = UDim2.new(1, -16, 0, 14)
aboutTitle.Position = UDim2.new(0, 12, 0, 6)
aboutTitle.BackgroundTransparency = 1
aboutTitle.RichText = true
aboutTitle.Text = '<font color="#5A78FF">ShinyHub</font> v1.0 — Blox Fruits'
aboutTitle.Font = Enum.Font.GothamBlack
aboutTitle.TextSize = 10
aboutTitle.TextXAlignment = Enum.TextXAlignment.Left
aboutTitle.ZIndex = 3

local aboutSub = Instance.new("TextLabel", about)
aboutSub.Size = UDim2.new(1, -16, 0, 12)
aboutSub.Position = UDim2.new(0, 12, 0, 24)
aboutSub.BackgroundTransparency = 1
aboutSub.Text = "Universal script hub  |  Made by ShinyHub Team"
aboutSub.Font = Enum.Font.Gotham
aboutSub.TextSize = 9
aboutSub.TextXAlignment = Enum.TextXAlignment.Left
aboutSub.TextColor3 = dimCol
aboutSub.ZIndex = 3

--------------------------------------------------------------
-- UPDATE LOOPS
--------------------------------------------------------------
table.insert(threads, task.spawn(function()
    while getgenv().BF_RUNNING do
        for _, fn in ipairs(togRefresh) do pcall(fn) end

        local elapsed = math.floor(tick() - startTime)
        local activeCount = 0
        for _, v in pairs(toggles) do if v then activeCount += 1 end end

        HeaderInfo.Text = math.floor(1 / RunS.RenderStepped:Wait()) .. " FPS  |  " .. activeCount .. " active"
        StatusLbl.Text = "Lv." .. getLvl() .. "  |  $" .. fmtNum(getBeli()) .. "  |  " .. math.floor(elapsed/60) .. "m " .. (elapsed%60) .. "s"

        task.wait(1)
    end
end))

--------------------------------------------------------------
-- INIT
--------------------------------------------------------------
switchTab("Home")
notify("ShinyHub loaded — Blox Fruits v1.0", accent)
