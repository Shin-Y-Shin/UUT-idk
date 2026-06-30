--[[
    ShinyHub — Sell Lemons 🍋 v4
    Full rewrite — left sidebar, polished, feature-complete
]]

if game.CoreGui:FindFirstChild("SLHub") then game.CoreGui:FindFirstChild("SLHub"):Destroy() end
if getgenv().SL_RUNNING then getgenv().SL_RUNNING = false task.wait(0.3) end
getgenv().SL_RUNNING = true

local Players = game:GetService("Players")
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local LP      = Players.LocalPlayer

--------------------------------------------------------------
-- TYCOON DISCOVERY
--------------------------------------------------------------
local myTycoon
for i = 1, 10 do
    for _, f in game.Workspace:GetChildren() do
        if f.Name == "Tycoon" .. i and f:IsA("Folder") then
            local o = f:FindFirstChild("Owner")
            if o and o.Value == LP then myTycoon = f break end
        end
    end
    if myTycoon then break end
end
if not myTycoon then warn("[ShinyHub] Tycoon not found") return end

local Remotes   = myTycoon:WaitForChild("Remotes")
local Purchases = myTycoon:WaitForChild("Purchases")
local Constant  = myTycoon:WaitForChild("Constant")
local Locations = myTycoon:WaitForChild("Locations")
local Values    = myTycoon:FindFirstChild("Values")

local RS = game:GetService("ReplicatedStorage")
local RemReq = RS:FindFirstChild("Core") and RS.Core:FindFirstChild("RemoteRequest")
local CashDropRedeem = RemReq and RemReq:FindFirstChild("CashDropService") and RemReq.CashDropService:FindFirstChild("Redeem")

local areaNames = {
    "Lemon Stand", "Lemon Trading", "Lemon Depot", "Lemon Labs",
    "LemonDash", "Lemon Robotics", "Lemon Republic", "LemonX",
}

local locationRenames = {
    XVoidPortalExit = "Void Exit", SpaceRocket = "Space Rocket",
    SpaceFall = "Space Fall", SpaceReturn = "Space Return",
    LemonDash = "Lemon Dash", MinigameRace = "Minigame Race",
}

--------------------------------------------------------------
-- THEME ENGINE
--------------------------------------------------------------
local Themes = {
    {name="Lemon",    dot=Color3.fromRGB(255,210,40),  accent=Color3.fromRGB(255,210,40),  accentDark=Color3.fromRGB(180,148,28), bg=Color3.fromRGB(16,15,10),  card=Color3.fromRGB(24,23,15), cardH=Color3.fromRGB(34,32,20), sidebar=Color3.fromRGB(20,19,13), border=Color3.fromRGB(44,40,20), text=Color3.fromRGB(245,242,228), sub=Color3.fromRGB(140,136,100), dim=Color3.fromRGB(82,78,48), on=Color3.fromRGB(255,210,40), off=Color3.fromRGB(38,36,22), knobOn=Color3.fromRGB(28,26,10), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(18,17,11), section=Color3.fromRGB(14,13,8)},
    {name="Midnight", dot=Color3.fromRGB(130,80,255),  accent=Color3.fromRGB(130,80,255),  accentDark=Color3.fromRGB(90,55,180),  bg=Color3.fromRGB(12,12,20),  card=Color3.fromRGB(21,21,32), cardH=Color3.fromRGB(30,30,46), sidebar=Color3.fromRGB(16,16,26), border=Color3.fromRGB(36,34,54), text=Color3.fromRGB(232,232,242), sub=Color3.fromRGB(120,120,150), dim=Color3.fromRGB(65,65,90), on=Color3.fromRGB(130,80,255), off=Color3.fromRGB(36,36,52), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(14,14,23), section=Color3.fromRGB(10,10,17)},
    {name="Ocean",    dot=Color3.fromRGB(45,140,255),  accent=Color3.fromRGB(45,140,255),  accentDark=Color3.fromRGB(30,100,190),  bg=Color3.fromRGB(8,11,20),   card=Color3.fromRGB(15,20,34), cardH=Color3.fromRGB(24,32,50), sidebar=Color3.fromRGB(11,15,26), border=Color3.fromRGB(26,40,66), text=Color3.fromRGB(218,230,248), sub=Color3.fromRGB(100,126,158), dim=Color3.fromRGB(52,72,104), on=Color3.fromRGB(45,140,255), off=Color3.fromRGB(22,32,50), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(9,13,23), section=Color3.fromRGB(6,9,17)},
    {name="Lime",     dot=Color3.fromRGB(100,220,60),  accent=Color3.fromRGB(100,220,60),  accentDark=Color3.fromRGB(70,155,42),   bg=Color3.fromRGB(10,13,8),   card=Color3.fromRGB(18,24,14), cardH=Color3.fromRGB(28,38,22), sidebar=Color3.fromRGB(13,17,10), border=Color3.fromRGB(32,48,24), text=Color3.fromRGB(236,246,230), sub=Color3.fromRGB(118,152,104), dim=Color3.fromRGB(65,96,50), on=Color3.fromRGB(100,220,60), off=Color3.fromRGB(26,38,18), knobOn=Color3.fromRGB(18,28,10), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(11,15,9), section=Color3.fromRGB(8,11,6)},
    {name="Sakura",   dot=Color3.fromRGB(240,120,170), accent=Color3.fromRGB(240,120,170), accentDark=Color3.fromRGB(170,85,120),  bg=Color3.fromRGB(18,12,16),  card=Color3.fromRGB(30,20,26), cardH=Color3.fromRGB(44,30,38), sidebar=Color3.fromRGB(23,15,20), border=Color3.fromRGB(56,38,48), text=Color3.fromRGB(248,234,240), sub=Color3.fromRGB(160,120,140), dim=Color3.fromRGB(100,70,86), on=Color3.fromRGB(240,120,170), off=Color3.fromRGB(42,30,36), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(20,13,17), section=Color3.fromRGB(14,9,12)},
    {name="Rose",     dot=Color3.fromRGB(255,80,80),   accent=Color3.fromRGB(255,80,80),   accentDark=Color3.fromRGB(180,56,56),   bg=Color3.fromRGB(18,10,10),  card=Color3.fromRGB(30,18,18), cardH=Color3.fromRGB(44,26,26), sidebar=Color3.fromRGB(23,13,13), border=Color3.fromRGB(56,30,30), text=Color3.fromRGB(248,232,232), sub=Color3.fromRGB(160,110,110), dim=Color3.fromRGB(100,60,60), on=Color3.fromRGB(255,80,80), off=Color3.fromRGB(42,24,24), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(20,11,11), section=Color3.fromRGB(14,7,7)},
    {name="Frost",    dot=Color3.fromRGB(140,220,255),  accent=Color3.fromRGB(140,220,255),  accentDark=Color3.fromRGB(98,154,178),  bg=Color3.fromRGB(10,14,18),  card=Color3.fromRGB(18,24,30), cardH=Color3.fromRGB(28,38,48), sidebar=Color3.fromRGB(13,18,23), border=Color3.fromRGB(36,52,66), text=Color3.fromRGB(230,242,250), sub=Color3.fromRGB(120,150,170), dim=Color3.fromRGB(65,90,110), on=Color3.fromRGB(140,220,255), off=Color3.fromRGB(24,34,44), knobOn=Color3.fromRGB(16,22,28), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(11,16,20), section=Color3.fromRGB(8,11,15)},
}

local C = Themes[1]
local binds = {}
local togRefresh = {}

local function tw(o, p, d, style)
    TS:Create(o, TweenInfo.new(d or 0.2, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p):Play()
end

local function bnd(obj, map)
    table.insert(binds, {o = obj, m = map})
    for prop, key in pairs(map) do obj[prop] = C[key] end
end

local function applyTheme()
    for _, b in ipairs(binds) do
        if b.o and b.o.Parent then
            local p = {}
            for prop, key in pairs(b.m) do p[prop] = C[key] end
            tw(b.o, p, 0.45)
        end
    end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
end

--------------------------------------------------------------
-- STATE
--------------------------------------------------------------
local toggles = {}
local threads = {}
local sessionStart = os.clock()
local startCash = 0
pcall(function()
    local ls = LP:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild("Cash") then startCash = ls.Cash.Value end
end)
local stats = {clicks = 0, bought = 0, upgrades = 0, rebirths = 0, drops = 0, income = 0, evolves = 0}
local activeCount = 0

local function loop(key, fn)
    table.insert(threads, task.spawn(function()
        while getgenv().SL_RUNNING do
            if toggles[key] then pcall(fn) else task.wait(0.3) end
        end
    end))
end

local function countActive()
    local n = 0
    for _, v in pairs(toggles) do if v then n = n + 1 end end
    activeCount = n
    return n
end

--------------------------------------------------------------
-- NOTIFICATION SYSTEM
--------------------------------------------------------------
local notifQueue = {}
local notifContainer

local function showNotif(text)
    if not notifContainer or not notifContainer.Parent then return end
    local n = Instance.new("Frame")
    n.Size = UDim2.new(1, 0, 0, 24)
    n.BackgroundTransparency = 1
    n.ZIndex = 20
    n.Parent = notifContainer

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BorderSizePixel = 0
    bg.ZIndex = 20
    bg.Parent = n
    bg.BackgroundTransparency = 0.15
    bnd(bg, {BackgroundColor3 = "card"})
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

    local pip = Instance.new("Frame")
    pip.Size = UDim2.new(0, 2, 0.6, 0)
    pip.Position = UDim2.new(0, 4, 0.2, 0)
    pip.BorderSizePixel = 0
    pip.ZIndex = 21
    pip.Parent = bg
    bnd(pip, {BackgroundColor3 = "accent"})
    Instance.new("UICorner", pip).CornerRadius = UDim.new(1, 0)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.Gotham
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 21
    l.Parent = bg
    bnd(l, {TextColor3 = "text"})

    task.delay(3, function()
        tw(bg, {BackgroundTransparency = 1}, 0.4)
        tw(l, {TextTransparency = 1}, 0.4)
        task.delay(0.5, function() n:Destroy() end)
    end)
end

--------------------------------------------------------------
-- GUI SHELL
--------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "SLHub"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = game.CoreGui

local SIDE_W = 130
local WIN_W  = 520
local WIN_H  = 380

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
Main.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui
bnd(Main, {BackgroundColor3 = "bg"})
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Strk = Instance.new("UIStroke")
Strk.Thickness = 1
Strk.Transparency = 0.5
Strk.Parent = Main
bnd(Strk, {Color = "border"})

--------------------------------------------------------------
-- HEADER
--------------------------------------------------------------
local HDR_H = 36
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, HDR_H)
Header.BorderSizePixel = 0
Header.ZIndex = 10
Header.Parent = Main
bnd(Header, {BackgroundColor3 = "header"})
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local HeaderFill = Instance.new("Frame")
HeaderFill.Size = UDim2.new(1, 0, 0, 14)
HeaderFill.Position = UDim2.new(0, 0, 1, -14)
HeaderFill.BorderSizePixel = 0
HeaderFill.ZIndex = 10
HeaderFill.Parent = Header
bnd(HeaderFill, {BackgroundColor3 = "header"})

-- Status dot (pulsing)
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 7, 0, 7)
StatusDot.Position = UDim2.new(0, 14, 0.5, -3)
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 12
StatusDot.Parent = Header
bnd(StatusDot, {BackgroundColor3 = "accent"})
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        tw(StatusDot, {BackgroundTransparency = 0.6}, 0.8)
        task.wait(0.9)
        tw(StatusDot, {BackgroundTransparency = 0}, 0.8)
        task.wait(0.9)
    end
end))

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0, 260, 1, 0)
TitleLbl.Position = UDim2.new(0, 28, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "ShinyHub  \xC2\xB7  Sell Lemons"
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 12
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 11
TitleLbl.Parent = Header
bnd(TitleLbl, {TextColor3 = "sub"})

-- Active count badge
local ActiveBadge = Instance.new("TextLabel")
ActiveBadge.Size = UDim2.new(0, 50, 0, 16)
ActiveBadge.Position = UDim2.new(1, -90, 0.5, -8)
ActiveBadge.BackgroundTransparency = 0.85
ActiveBadge.BorderSizePixel = 0
ActiveBadge.Font = Enum.Font.GothamBold
ActiveBadge.TextSize = 9
ActiveBadge.ZIndex = 12
ActiveBadge.Parent = Header
bnd(ActiveBadge, {TextColor3 = "accent", BackgroundColor3 = "accent"})
Instance.new("UICorner", ActiveBadge).CornerRadius = UDim.new(1, 0)

table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        local n = countActive()
        ActiveBadge.Text = n .. " active"
        task.wait(0.5)
    end
end))

-- Minimize btn
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 22, 0, 22)
MinBtn.Position = UDim2.new(1, -56, 0.5, -11)
MinBtn.Text = "\xE2\x80\x93"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
MinBtn.BackgroundTransparency = 1
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 12
MinBtn.AutoButtonColor = false
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

MinBtn.MouseEnter:Connect(function()
    tw(MinBtn, {TextColor3 = Color3.fromRGB(255, 200, 50), BackgroundTransparency = 0.85, BackgroundColor3 = Color3.fromRGB(255, 200, 50)}, 0.1)
end)
MinBtn.MouseLeave:Connect(function()
    tw(MinBtn, {TextColor3 = Color3.fromRGB(160, 160, 160), BackgroundTransparency = 1}, 0.12)
end)
MinBtn.MouseButton1Click:Connect(function()
    tw(Main, {Size = UDim2.new(0, WIN_W, 0, HDR_H)}, 0.3, Enum.EasingStyle.Back)
    task.delay(0.3, function()
        MinBtn.Visible = false
    end)
end)

-- Close btn
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -11)
CloseBtn.Text = "\xC3\x97"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
CloseBtn.BackgroundTransparency = 1
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 12
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseEnter:Connect(function()
    tw(CloseBtn, {TextColor3 = Color3.fromRGB(240, 70, 70), BackgroundTransparency = 0.85, BackgroundColor3 = Color3.fromRGB(240, 70, 70)}, 0.1)
end)
CloseBtn.MouseLeave:Connect(function()
    tw(CloseBtn, {TextColor3 = Color3.fromRGB(160, 160, 160), BackgroundTransparency = 1}, 0.12)
end)
CloseBtn.MouseButton1Click:Connect(function()
    getgenv().SL_RUNNING = false
    tw(Main, {Size = UDim2.new(0, WIN_W, 0, 0), BackgroundTransparency = 1}, 0.3)
    task.delay(0.35, function()
        for _, t in ipairs(threads) do pcall(task.cancel, t) end
        Gui:Destroy()
    end)
end)

-- Click header to restore when minimized
Header.InputBegan:Connect(function(i)
    if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and Main.AbsoluteSize.Y < 50 then
        MinBtn.Visible = true
        tw(Main, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.35, Enum.EasingStyle.Back)
    end
end)

--------------------------------------------------------------
-- LEFT SIDEBAR
--------------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, SIDE_W, 1, -HDR_H)
Sidebar.Position = UDim2.new(0, 0, 0, HDR_H)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 5
Sidebar.Parent = Main
bnd(Sidebar, {BackgroundColor3 = "sidebar"})

local SideDiv = Instance.new("Frame")
SideDiv.Size = UDim2.new(0, 1, 1, 0)
SideDiv.Position = UDim2.new(1, 0, 0, 0)
SideDiv.BorderSizePixel = 0
SideDiv.BackgroundTransparency = 0.5
SideDiv.ZIndex = 6
SideDiv.Parent = Sidebar
bnd(SideDiv, {BackgroundColor3 = "border"})

local tabNames = {"Home", "Farm", "Boost", "Teleport", "Stats", "Settings"}
local tabIcons = {Home = "H", Farm = "F", Boost = "B", Teleport = "T", Stats = "S", Settings = "G"}
local tabBtns = {}
local tabPages = {}
local activeTab = nil

local SideIndicator = Instance.new("Frame")
SideIndicator.Size = UDim2.new(0, 3, 0, 24)
SideIndicator.Position = UDim2.new(0, 0, 0, 14)
SideIndicator.BorderSizePixel = 0
SideIndicator.ZIndex = 7
SideIndicator.Parent = Sidebar
bnd(SideIndicator, {BackgroundColor3 = "accent"})
Instance.new("UICorner", SideIndicator).CornerRadius = UDim.new(0, 2)

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, 8 + (i - 1) * 34)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 1
    btn.ZIndex = 6
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 20, 1, 0)
    icon.Position = UDim2.new(0, 12, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = tabIcons[name]
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 10
    icon.ZIndex = 7
    icon.Parent = btn
    bnd(icon, {TextColor3 = "dim"})

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -38, 1, 0)
    lbl.Position = UDim2.new(0, 32, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 7
    lbl.Parent = btn
    bnd(lbl, {TextColor3 = "dim"})

    btn.MouseEnter:Connect(function()
        if activeTab ~= name then
            tw(btn, {BackgroundTransparency = 0.85, BackgroundColor3 = C.card}, 0.1)
            tw(lbl, {TextColor3 = C.sub}, 0.1)
            tw(icon, {TextColor3 = C.sub}, 0.1)
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= name then
            tw(btn, {BackgroundTransparency = 1}, 0.12)
            tw(lbl, {TextColor3 = C.dim}, 0.12)
            tw(icon, {TextColor3 = C.dim}, 0.12)
        end
    end)

    tabBtns[name] = {btn = btn, lbl = lbl, icon = icon}
end

-- Version label at bottom of sidebar
local VerLbl = Instance.new("TextLabel")
VerLbl.Size = UDim2.new(1, -10, 0, 20)
VerLbl.Position = UDim2.new(0, 5, 1, -26)
VerLbl.BackgroundTransparency = 1
VerLbl.Text = "v4.0"
VerLbl.Font = Enum.Font.Gotham
VerLbl.TextSize = 9
VerLbl.ZIndex = 6
VerLbl.Parent = Sidebar
bnd(VerLbl, {TextColor3 = "dim"})

--------------------------------------------------------------
-- CONTENT AREA
--------------------------------------------------------------
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -SIDE_W, 1, -HDR_H)
Content.Position = UDim2.new(0, SIDE_W, 0, HDR_H)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.ZIndex = 2
Content.Parent = Main

local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, -24, 0, 28)
PageTitle.Position = UDim2.new(0, 16, 0, 6)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "Home"
PageTitle.Font = Enum.Font.GothamBold
PageTitle.TextSize = 16
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.ZIndex = 3
PageTitle.Parent = Content
bnd(PageTitle, {TextColor3 = "text"})

local PageSub = Instance.new("TextLabel")
PageSub.Size = UDim2.new(1, -24, 0, 14)
PageSub.Position = UDim2.new(0, 16, 0, 28)
PageSub.BackgroundTransparency = 1
PageSub.Text = ""
PageSub.Font = Enum.Font.Gotham
PageSub.TextSize = 9
PageSub.TextXAlignment = Enum.TextXAlignment.Left
PageSub.ZIndex = 3
PageSub.Parent = Content
bnd(PageSub, {TextColor3 = "dim"})

-- Notification container (top right of content)
notifContainer = Instance.new("Frame")
notifContainer.Size = UDim2.new(0, 180, 0, 120)
notifContainer.Position = UDim2.new(1, -190, 0, 4)
notifContainer.BackgroundTransparency = 1
notifContainer.ZIndex = 20
notifContainer.ClipsDescendants = true
notifContainer.Parent = Content
local notifLayout = Instance.new("UIListLayout", notifContainer)
notifLayout.Padding = UDim.new(0, 3)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder

local tabSubtitles = {
    Home = "Overview & session info",
    Farm = "Automation toggles",
    Boost = "Progression & boosts",
    Teleport = "Quick travel",
    Stats = "Session statistics",
    Settings = "Themes & player mods",
}

for _, name in ipairs(tabNames) do
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, -20, 1, -46)
    page.Position = UDim2.new(0, 12, 0, 44)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.BorderSizePixel = 0
    page.ZIndex = 2
    page.Parent = Content
    bnd(page, {ScrollBarImageColor3 = "dim"})

    local lay = Instance.new("UIListLayout", page)
    lay.Padding = UDim.new(0, 4)
    lay.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", page)
    pad.PaddingBottom = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 6)

    tabPages[name] = page
end

local function switchTab(name)
    activeTab = name
    PageTitle.Text = name
    PageSub.Text = tabSubtitles[name] or ""
    for n, p in pairs(tabPages) do p.Visible = (n == name) end
    for n, t in pairs(tabBtns) do
        if n == name then
            tw(t.btn, {BackgroundTransparency = 0.88, BackgroundColor3 = C.card}, 0.2)
            tw(t.lbl, {TextColor3 = C.text}, 0.2)
            tw(t.icon, {TextColor3 = C.accent}, 0.2)
        else
            tw(t.btn, {BackgroundTransparency = 1}, 0.2)
            tw(t.lbl, {TextColor3 = C.dim}, 0.2)
            tw(t.icon, {TextColor3 = C.dim}, 0.2)
        end
    end
    local idx = table.find(tabNames, name) or 1
    tw(SideIndicator, {Position = UDim2.new(0, 0, 0, 8 + (idx - 1) * 34 + 3)}, 0.25, Enum.EasingStyle.Back)
end

for name, t in pairs(tabBtns) do
    t.btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

--------------------------------------------------------------
-- DRAG
--------------------------------------------------------------
local dragging, dragSt, dragPos
Header.InputBegan:Connect(function(i)
    if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and Main.AbsoluteSize.Y > 50 then
        dragging = true; dragSt = i.Position; dragPos = Main.Position
    end
end)
Header.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragSt
        Main.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + d.X, dragPos.Y.Scale, dragPos.Y.Offset + d.Y)
    end
end)

-- Keybind (RightShift)
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then
            tw(Main, {Size = UDim2.new(0, WIN_W, 0, 0), BackgroundTransparency = 1}, 0.25)
            task.delay(0.25, function() Main.Visible = false end)
        else
            Main.Visible = true
            Main.Size = UDim2.new(0, WIN_W, 0, 0)
            Main.BackgroundTransparency = 1
            tw(Main, {BackgroundTransparency = 0, Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.35, Enum.EasingStyle.Back)
        end
    end
end)

--------------------------------------------------------------
-- UI FACTORIES
--------------------------------------------------------------
local ords = {}
for _, n in ipairs(tabNames) do ords[n] = 0 end
local function nxt(t) ords[t] = (ords[t] or 0) + 1 return ords[t] end

local function mkSection(tab, title, parent)
    local h = Instance.new("Frame")
    h.LayoutOrder = nxt(tab)
    h.Size = UDim2.new(1, 0, 0, 22)
    h.BackgroundTransparency = 1
    h.ZIndex = 2
    h.Parent = parent or tabPages[tab]

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0, 10)
    bar.Position = UDim2.new(0, 2, 0.5, -5)
    bar.BorderSizePixel = 0
    bar.ZIndex = 3
    bar.Parent = h
    bnd(bar, {BackgroundColor3 = "accent"})
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -14, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = string.upper(title)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 9
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = h
    bnd(l, {TextColor3 = "dim"})
end

local function mkToggle(tab, name, desc, parent)
    toggles[name] = false
    local ROW_H = desc and 38 or 30
    local h = Instance.new("Frame")
    h.LayoutOrder = nxt(tab)
    h.Size = UDim2.new(1, 0, 0, ROW_H)
    h.BorderSizePixel = 0
    h.ZIndex = 2
    h.Parent = parent or tabPages[tab]
    bnd(h, {BackgroundColor3 = "card"})
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

    local pip = Instance.new("Frame")
    pip.Size = UDim2.new(0, 3, 0.5, 0)
    pip.Position = UDim2.new(0, 0, 0.25, 0)
    pip.BorderSizePixel = 0
    pip.BackgroundTransparency = 0.8
    pip.ZIndex = 3
    pip.Parent = h
    bnd(pip, {BackgroundColor3 = "accent"})
    Instance.new("UICorner", pip).CornerRadius = UDim.new(1, 0)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -54, 0, desc and 16 or ROW_H)
    l.Position = UDim2.new(0, 14, 0, desc and 4 or 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = h
    bnd(l, {TextColor3 = "sub"})

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -54, 0, 14)
        d.Position = UDim2.new(0, 14, 0, 20)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.Font = Enum.Font.Gotham
        d.TextSize = 9
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.ZIndex = 3
        d.Parent = h
        bnd(d, {TextColor3 = "dim"})
    end

    local tr = Instance.new("TextButton")
    tr.Size = UDim2.new(0, 34, 0, 16)
    tr.Position = UDim2.new(1, -44, 0.5, -8)
    tr.Text = ""
    tr.BorderSizePixel = 0
    tr.ZIndex = 4
    tr.AutoButtonColor = false
    tr.Parent = h
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)

    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0, 12, 0, 12)
    kn.Position = UDim2.new(0, 2, 0.5, -6)
    kn.BorderSizePixel = 0
    kn.ZIndex = 5
    kn.Parent = tr
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)

    local function ref()
        local on = toggles[name]
        tw(tr, {BackgroundColor3 = on and C.on or C.off}, 0.2)
        tw(kn, {
            Position = on and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
            BackgroundColor3 = on and C.knobOn or C.knobOff
        }, 0.2)
        tw(pip, {BackgroundTransparency = on and 0 or 0.8}, 0.2)
        tw(l, {TextColor3 = on and C.text or C.sub}, 0.2)
    end
    ref()
    table.insert(togRefresh, ref)

    tr.MouseButton1Click:Connect(function()
        toggles[name] = not toggles[name]
        ref()
    end)
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then tw(h, {BackgroundColor3 = C.cardH}, 0.08) end
    end)
    h.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then tw(h, {BackgroundColor3 = C.card}, 0.1) end
    end)
end

local function mkSpacer(tab, h, parent)
    local s = Instance.new("Frame")
    s.LayoutOrder = nxt(tab)
    s.Size = UDim2.new(1, 0, 0, h or 4)
    s.BackgroundTransparency = 1
    s.ZIndex = 2
    s.Parent = parent or tabPages[tab]
end

local function mkButton(tab, txt, cb, parent)
    local b = Instance.new("TextButton")
    b.LayoutOrder = nxt(tab)
    b.Size = UDim2.new(1, 0, 0, 28)
    b.Text = ""
    b.BorderSizePixel = 0
    b.ZIndex = 2
    b.AutoButtonColor = false
    b.Parent = parent or tabPages[tab]
    bnd(b, {BackgroundColor3 = "card"})
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 14, 1, 0)
    arrow.Position = UDim2.new(1, -18, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "\xE2\x80\xBA"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    arrow.ZIndex = 3
    arrow.Parent = b
    bnd(arrow, {TextColor3 = "dim"})

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -30, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = b
    bnd(l, {TextColor3 = "sub"})

    b.MouseButton1Click:Connect(function()
        tw(b, {BackgroundColor3 = C.accent}, 0.04)
        tw(l, {TextColor3 = C.bg}, 0.04)
        tw(arrow, {TextColor3 = C.bg}, 0.04)
        task.delay(0.12, function()
            tw(b, {BackgroundColor3 = C.card}, 0.3)
            tw(l, {TextColor3 = C.sub}, 0.3)
            tw(arrow, {TextColor3 = C.dim}, 0.3)
        end)
        if cb then cb() end
    end)
    b.MouseEnter:Connect(function()
        tw(b, {BackgroundColor3 = C.cardH}, 0.08)
        tw(l, {TextColor3 = C.text}, 0.08)
        tw(arrow, {TextColor3 = C.accent}, 0.08)
    end)
    b.MouseLeave:Connect(function()
        tw(b, {BackgroundColor3 = C.card}, 0.1)
        tw(l, {TextColor3 = C.sub}, 0.1)
        tw(arrow, {TextColor3 = C.dim}, 0.1)
    end)
end

local function mkStatCard(tab, label, fn, parent)
    local h = Instance.new("Frame")
    h.LayoutOrder = nxt(tab)
    h.Size = UDim2.new(1, 0, 0, 42)
    h.BorderSizePixel = 0
    h.ZIndex = 2
    h.Parent = parent or tabPages[tab]
    bnd(h, {BackgroundColor3 = "card"})
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 0.5, 0)
    accentBar.Position = UDim2.new(0, 0, 0.25, 0)
    accentBar.BorderSizePixel = 0
    accentBar.BackgroundTransparency = 0.4
    accentBar.ZIndex = 3
    accentBar.Parent = h
    bnd(accentBar, {BackgroundColor3 = "accent"})
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -14, 0, 14)
    lbl.Position = UDim2.new(0, 14, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = h
    bnd(lbl, {TextColor3 = "dim"})

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(1, -14, 0, 18)
    val.Position = UDim2.new(0, 14, 0, 20)
    val.BackgroundTransparency = 1
    val.Font = Enum.Font.GothamBold
    val.TextSize = 14
    val.TextXAlignment = Enum.TextXAlignment.Left
    val.ZIndex = 3
    val.Parent = h
    bnd(val, {TextColor3 = "text"})
    val.Text = fn()
    table.insert(threads, task.spawn(function()
        while getgenv().SL_RUNNING do val.Text = fn() task.wait(1) end
    end))
end

local function mkDualStat(tab, label1, fn1, label2, fn2, parent)
    local h = Instance.new("Frame")
    h.LayoutOrder = nxt(tab)
    h.Size = UDim2.new(1, 0, 0, 42)
    h.BorderSizePixel = 0
    h.BackgroundTransparency = 1
    h.ZIndex = 2
    h.Parent = parent or tabPages[tab]

    local left = Instance.new("Frame")
    left.Size = UDim2.new(0.5, -2, 1, 0)
    left.BorderSizePixel = 0
    left.ZIndex = 2
    left.Parent = h
    bnd(left, {BackgroundColor3 = "card"})
    Instance.new("UICorner", left).CornerRadius = UDim.new(0, 8)

    local ll = Instance.new("TextLabel")
    ll.Size = UDim2.new(1, -10, 0, 14)
    ll.Position = UDim2.new(0, 10, 0, 5)
    ll.BackgroundTransparency = 1; ll.Text = label1; ll.Font = Enum.Font.GothamBold; ll.TextSize = 9; ll.TextXAlignment = Enum.TextXAlignment.Left; ll.ZIndex = 3; ll.Parent = left
    bnd(ll, {TextColor3 = "dim"})

    local lv = Instance.new("TextLabel")
    lv.Size = UDim2.new(1, -10, 0, 18)
    lv.Position = UDim2.new(0, 10, 0, 20)
    lv.BackgroundTransparency = 1; lv.Font = Enum.Font.GothamBold; lv.TextSize = 13; lv.TextXAlignment = Enum.TextXAlignment.Left; lv.ZIndex = 3; lv.Parent = left
    bnd(lv, {TextColor3 = "text"})

    local right = Instance.new("Frame")
    right.Size = UDim2.new(0.5, -2, 1, 0)
    right.Position = UDim2.new(0.5, 2, 0, 0)
    right.BorderSizePixel = 0
    right.ZIndex = 2
    right.Parent = h
    bnd(right, {BackgroundColor3 = "card"})
    Instance.new("UICorner", right).CornerRadius = UDim.new(0, 8)

    local rl = Instance.new("TextLabel")
    rl.Size = UDim2.new(1, -10, 0, 14)
    rl.Position = UDim2.new(0, 10, 0, 5)
    rl.BackgroundTransparency = 1; rl.Text = label2; rl.Font = Enum.Font.GothamBold; rl.TextSize = 9; rl.TextXAlignment = Enum.TextXAlignment.Left; rl.ZIndex = 3; rl.Parent = right
    bnd(rl, {TextColor3 = "dim"})

    local rv = Instance.new("TextLabel")
    rv.Size = UDim2.new(1, -10, 0, 18)
    rv.Position = UDim2.new(0, 10, 0, 20)
    rv.BackgroundTransparency = 1; rv.Font = Enum.Font.GothamBold; rv.TextSize = 13; rv.TextXAlignment = Enum.TextXAlignment.Left; rv.ZIndex = 3; rv.Parent = right
    bnd(rv, {TextColor3 = "text"})

    table.insert(threads, task.spawn(function()
        while getgenv().SL_RUNNING do lv.Text = fn1(); rv.Text = fn2(); task.wait(1) end
    end))
    lv.Text = fn1(); rv.Text = fn2()
end

local function smartTP(locName)
    local loc = Locations:FindFirstChild(locName)
    if loc and loc:IsA("BasePart") then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = loc.CFrame + Vector3.new(0, 3, 0)
            showNotif("Teleported to " .. (locationRenames[locName] or locName))
        end
    end
end

local function fmtNum(n)
    if n >= 1e12 then return string.format("%.1fT", n / 1e12)
    elseif n >= 1e9 then return string.format("%.1fB", n / 1e9)
    elseif n >= 1e6 then return string.format("%.1fM", n / 1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n / 1e3)
    else return tostring(math.floor(n)) end
end

local function getCash()
    local ls = LP:FindFirstChild("leaderstats")
    local cash = ls and ls:FindFirstChild("Cash")
    return cash and cash.Value or 0
end

--------------------------------------------------------------
-- HOME TAB
--------------------------------------------------------------
mkStatCard("Home", "CASH", function()
    return fmtNum(getCash())
end)

mkSpacer("Home", 3)

mkDualStat("Home",
    "CASH / MIN", function()
        local elapsed = os.clock() - sessionStart
        if elapsed < 5 then return "---" end
        local earned = getCash() - startCash
        local perMin = (earned / elapsed) * 60
        return fmtNum(math.max(0, perMin))
    end,
    "UPTIME", function()
        local e = os.clock() - sessionStart
        if e >= 3600 then return string.format("%dh %dm", math.floor(e/3600), math.floor(e%3600/60)) end
        return string.format("%dm %ds", math.floor(e / 60), math.floor(e % 60))
    end
)

mkSpacer("Home", 3)

mkDualStat("Home",
    "TYCOON", function() return myTycoon.Name end,
    "ACTIVE", function() return countActive() .. " features" end
)

mkSpacer("Home", 6)

mkSection("Home", "Quick Actions")
mkButton("Home", "Enable All Farm", function()
    for _, name in ipairs({"Auto Buy Items", "Auto Click Income", "Auto Upgrade Earners", "Auto Collect Fruit", "Auto Collect Drops"}) do
        toggles[name] = true
    end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    showNotif("All farm features enabled")
end)

mkButton("Home", "Disable All", function()
    for k, _ in pairs(toggles) do toggles[k] = false end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    showNotif("All features disabled")
end)

mkSpacer("Home", 8)
local infoLbl = Instance.new("TextLabel")
infoLbl.LayoutOrder = nxt("Home")
infoLbl.Size = UDim2.new(1, 0, 0, 14)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "  ShinyHub  \xC2\xB7  Sell Lemons  \xC2\xB7  v4.0"
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextSize = 9
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.ZIndex = 2
infoLbl.Parent = tabPages.Home
bnd(infoLbl, {TextColor3 = "dim"})

--------------------------------------------------------------
-- FARM TAB
--------------------------------------------------------------
mkSection("Farm", "Purchasing")

mkToggle("Farm", "Auto Buy Items", "Buys all enabled & available items")
loop("Auto Buy Items", function()
    for _, area in Purchases:GetChildren() do
        local buttons = area:FindFirstChild("Buttons")
        if buttons then
            local function scan(folder)
                for _, item in folder:GetChildren() do
                    if not getgenv().SL_RUNNING or not toggles["Auto Buy Items"] then return end
                    if item:IsA("Folder") then scan(item)
                    elseif item:IsA("Model") and item:GetAttribute("Purchased") ~= true and item:GetAttribute("Enabled") == true then
                        local rem = item:FindFirstChild("Purchase")
                        if rem and rem:IsA("RemoteFunction") then
                            local ok = pcall(function() rem:InvokeServer(false) end)
                            if ok then stats.bought = stats.bought + 1 end
                            task.wait(0.05)
                        end
                    end
                end
            end
            scan(buttons)
        end
    end
    task.wait(0.3)
end)

mkSpacer("Farm", 2)
mkSection("Farm", "Income")

mkToggle("Farm", "Auto Click Income", "Fires earner proximity prompts")
loop("Auto Click Income", function()
    for _, areaName in ipairs(areaNames) do
        if not getgenv().SL_RUNNING or not toggles["Auto Click Income"] then return end
        local area = Purchases:FindFirstChild(areaName)
        if area then
            local m = area:FindFirstChild(areaName)
            if m and m:IsA("Model") then
                local part = m:FindFirstChild(areaName)
                if part then
                    local prompt = part:FindFirstChild("Prompt")
                    if prompt and prompt:IsA("ProximityPrompt") then
                        pcall(fireproximityprompt, prompt)
                        stats.income = stats.income + 1
                    end
                end
            end
        end
    end
    task.wait(0.2)
end)

mkToggle("Farm", "Auto Upgrade Earners", "Levels up all earner stands")
loop("Auto Upgrade Earners", function()
    for _, areaName in ipairs(areaNames) do
        if not getgenv().SL_RUNNING or not toggles["Auto Upgrade Earners"] then return end
        local area = Purchases:FindFirstChild(areaName)
        if area then
            local m = area:FindFirstChild(areaName)
            if m and m:IsA("Model") then
                local part = m:FindFirstChild(areaName)
                if part then
                    local upg = part:FindFirstChild("Upgrade")
                    if upg and upg:IsA("RemoteFunction") then
                        local ok = pcall(function() upg:InvokeServer(1) end)
                        if ok then stats.upgrades = stats.upgrades + 1 end
                    end
                end
            end
        end
    end
    task.wait(0.2)
end)

mkSpacer("Farm", 2)
mkSection("Farm", "Collection")

mkToggle("Farm", "Auto Collect Fruit", "Clicks all lemon tree fruits")
loop("Auto Collect Fruit", function()
    local trees = Constant:FindFirstChild("Trees")
    if not trees then task.wait(1) return end
    for _, tree in trees:GetChildren() do
        if not getgenv().SL_RUNNING or not toggles["Auto Collect Fruit"] then return end
        for _, fruit in tree:GetChildren() do
            if fruit.Name == "Fruit" and fruit.Transparency < 1 then
                local cp = fruit:FindFirstChild("ClickPart")
                if cp then
                    local cd = cp:FindFirstChild("ClickDetector")
                    if cd then
                        fireclickdetector(cd)
                        stats.clicks = stats.clicks + 1
                    end
                end
            end
        end
    end
    task.wait(0.05)
end)

mkToggle("Farm", "Auto Collect Drops", "Redeems cash drops automatically")
loop("Auto Collect Drops", function()
    if CashDropRedeem then
        local ok = pcall(function() CashDropRedeem:InvokeServer() end)
        if ok then stats.drops = stats.drops + 1 end
    end
    task.wait(0.4)
end)

mkToggle("Farm", "Auto Phone Offer", "Accepts phone offers for bonuses")
loop("Auto Phone Offer", function()
    pcall(function() Remotes.PhoneOffer:FireServer() end)
    task.wait(1.5)
end)

--------------------------------------------------------------
-- BOOST TAB
--------------------------------------------------------------
mkSection("Boost", "Progression")

mkToggle("Boost", "Auto Rebirth", "Rebirths when available")
loop("Auto Rebirth", function()
    local ok = pcall(function() Remotes.Rebirth:InvokeServer() end)
    if ok then
        stats.rebirths = stats.rebirths + 1
        showNotif("Rebirth #" .. stats.rebirths)
    end
    task.wait(0.8)
end)

mkToggle("Boost", "Auto Evolve", "Evolves when available")
loop("Auto Evolve", function()
    local ok = pcall(function() Remotes.Evolve:InvokeServer() end)
    if ok then
        stats.evolves = stats.evolves + 1
        showNotif("Evolved #" .. stats.evolves)
    end
    task.wait(1.5)
end)

mkToggle("Boost", "Auto Ascend", "Ascends when available")
loop("Auto Ascend", function()
    pcall(function() Remotes.Ascend:InvokeServer() end)
    task.wait(2)
end)

mkSpacer("Boost", 2)
mkSection("Boost", "Power")

mkToggle("Boost", "Auto Upgrade Power", "Upgrades power level")
loop("Auto Upgrade Power", function()
    pcall(function() Remotes.UpgradePowerLevel:InvokeServer() end)
    task.wait(0.8)
end)

mkSpacer("Boost", 2)
mkSection("Boost", "One-Time Boosts")

mkButton("Boost", "Collect Time Cash", function()
    pcall(function() Remotes.UseTimeCash:InvokeServer() end)
    showNotif("Time Cash collected")
end)
mkButton("Boost", "Use Earner Boost", function()
    pcall(function() Remotes.UseEarnerBoost:InvokeServer() end)
    showNotif("Earner Boost activated")
end)
mkButton("Boost", "Double Offline Cash", function()
    pcall(function() Remotes.DoubleOfflineCash:InvokeServer() end)
    showNotif("Offline Cash doubled")
end)

--------------------------------------------------------------
-- TELEPORT TAB
--------------------------------------------------------------
mkSection("Teleport", "Tycoon Areas")

local areaLocs = {}
local otherLocs = {}
local areaSet = {}
for _, n in ipairs(areaNames) do areaSet[n] = true end

for _, loc in Locations:GetChildren() do
    local display = locationRenames[loc.Name] or loc.Name
    if areaSet[loc.Name] or areaSet[display] then
        table.insert(areaLocs, {name = loc.Name, display = display})
    else
        table.insert(otherLocs, {name = loc.Name, display = display})
    end
end
table.sort(areaLocs, function(a, b) return a.display < b.display end)
table.sort(otherLocs, function(a, b) return a.display < b.display end)

for _, loc in ipairs(areaLocs) do
    mkButton("Teleport", loc.display, function() smartTP(loc.name) end)
end

if #otherLocs > 0 then
    mkSpacer("Teleport", 4)
    mkSection("Teleport", "Other Locations")
    for _, loc in ipairs(otherLocs) do
        mkButton("Teleport", loc.display, function() smartTP(loc.name) end)
    end
end

--------------------------------------------------------------
-- STATS TAB
--------------------------------------------------------------
mkSection("Stats", "Session Performance")

mkDualStat("Stats",
    "LEMONS CLICKED", function() return fmtNum(stats.clicks) end,
    "ITEMS BOUGHT", function() return fmtNum(stats.bought) end
)

mkSpacer("Stats", 3)

mkDualStat("Stats",
    "EARNER UPGRADES", function() return fmtNum(stats.upgrades) end,
    "INCOME TAPS", function() return fmtNum(stats.income) end
)

mkSpacer("Stats", 3)

mkDualStat("Stats",
    "REBIRTHS", function() return tostring(stats.rebirths) end,
    "EVOLVES", function() return tostring(stats.evolves) end
)

mkSpacer("Stats", 3)

mkStatCard("Stats", "DROPS COLLECTED", function() return fmtNum(stats.drops) end)

mkSpacer("Stats", 3)

mkStatCard("Stats", "TOTAL CASH EARNED", function()
    local earned = getCash() - startCash
    return fmtNum(math.max(0, earned))
end)

mkSpacer("Stats", 3)

mkStatCard("Stats", "SESSION TIME", function()
    local e = os.clock() - sessionStart
    if e >= 3600 then return string.format("%dh %dm %ds", math.floor(e/3600), math.floor(e%3600/60), math.floor(e%60)) end
    return string.format("%dm %ds", math.floor(e / 60), math.floor(e % 60))
end)

--------------------------------------------------------------
-- SETTINGS TAB
--------------------------------------------------------------
mkSection("Settings", "Player Mods")

mkToggle("Settings", "Speed Boost", "WalkSpeed 80")
loop("Speed Boost", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 80 end
    task.wait(0.5)
end)

mkToggle("Settings", "Jump Boost", "JumpPower 120")
loop("Jump Boost", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 120 end
    task.wait(0.5)
end)

mkToggle("Settings", "Infinite Jump", "Jump mid-air")
UIS.JumpRequest:Connect(function()
    if toggles["Infinite Jump"] and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

mkSpacer("Settings", 4)
mkSection("Settings", "Actions")

mkButton("Settings", "Reset Character", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
    showNotif("Character reset")
end)

mkButton("Settings", "Rejoin Server", function()
    showNotif("Rejoining...")
    task.delay(0.5, function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end)
end)

mkSpacer("Settings", 6)
mkSection("Settings", "Themes")

for _, theme in ipairs(Themes) do
    local b = Instance.new("TextButton")
    b.LayoutOrder = nxt("Settings")
    b.Size = UDim2.new(1, 0, 0, 28)
    b.Text = ""
    b.BorderSizePixel = 0
    b.ZIndex = 2
    b.AutoButtonColor = false
    b.Parent = tabPages.Settings
    bnd(b, {BackgroundColor3 = "card"})
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, 12, 0.5, -5)
    dot.BorderSizePixel = 0
    dot.BackgroundColor3 = theme.dot
    dot.ZIndex = 3
    dot.Parent = b
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local dotStrk = Instance.new("UIStroke")
    dotStrk.Thickness = 1
    dotStrk.Transparency = 0.7
    dotStrk.Color = theme.accent
    dotStrk.Parent = dot

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -36, 1, 0)
    l.Position = UDim2.new(0, 30, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = theme.name
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = b
    bnd(l, {TextColor3 = "sub"})

    b.MouseButton1Click:Connect(function()
        C = theme
        applyTheme()
        showNotif("Theme: " .. theme.name)
    end)
    b.MouseEnter:Connect(function()
        tw(b, {BackgroundColor3 = C.cardH}, 0.08)
        tw(l, {TextColor3 = C.text}, 0.08)
    end)
    b.MouseLeave:Connect(function()
        tw(b, {BackgroundColor3 = C.card}, 0.1)
        tw(l, {TextColor3 = C.sub}, 0.1)
    end)
end

--------------------------------------------------------------
-- ENTRANCE ANIMATION
--------------------------------------------------------------
Main.BackgroundTransparency = 1
Main.Size = UDim2.new(0, WIN_W, 0, 0)
Strk.Transparency = 1

task.delay(0.05, function()
    tw(Main, {Size = UDim2.new(0, WIN_W, 0, WIN_H), BackgroundTransparency = 0}, 0.45, Enum.EasingStyle.Back)
    tw(Strk, {Transparency = 0.5}, 0.5)
end)

switchTab("Home")
