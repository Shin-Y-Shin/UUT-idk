--[[
    ShinyHub — Sell Lemons 🍋 v6.0
    Ultimate edition
]]

if game.CoreGui:FindFirstChild("SLHub") then game.CoreGui:FindFirstChild("SLHub"):Destroy() end
if getgenv().SL_RUNNING then getgenv().SL_RUNNING = false task.wait(0.3) end
getgenv().SL_RUNNING = true

local Players = game:GetService("Players")
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")
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
    {name="Lemon",    dot=Color3.fromRGB(255,210,40),  accent=Color3.fromRGB(255,210,40),  bg=Color3.fromRGB(16,15,10),  card=Color3.fromRGB(24,23,15), cardH=Color3.fromRGB(34,32,20), sidebar=Color3.fromRGB(20,19,13), border=Color3.fromRGB(44,40,20), text=Color3.fromRGB(245,242,228), sub=Color3.fromRGB(140,136,100), dim=Color3.fromRGB(82,78,48), on=Color3.fromRGB(255,210,40), off=Color3.fromRGB(38,36,22), knobOn=Color3.fromRGB(28,26,10), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(18,17,11), section=Color3.fromRGB(14,13,8)},
    {name="Midnight", dot=Color3.fromRGB(130,80,255),  accent=Color3.fromRGB(130,80,255),  bg=Color3.fromRGB(12,12,20),  card=Color3.fromRGB(21,21,32), cardH=Color3.fromRGB(30,30,46), sidebar=Color3.fromRGB(16,16,26), border=Color3.fromRGB(36,34,54), text=Color3.fromRGB(232,232,242), sub=Color3.fromRGB(120,120,150), dim=Color3.fromRGB(65,65,90), on=Color3.fromRGB(130,80,255), off=Color3.fromRGB(36,36,52), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(14,14,23), section=Color3.fromRGB(10,10,17)},
    {name="Ocean",    dot=Color3.fromRGB(45,140,255),  accent=Color3.fromRGB(45,140,255),  bg=Color3.fromRGB(8,11,20),   card=Color3.fromRGB(15,20,34), cardH=Color3.fromRGB(24,32,50), sidebar=Color3.fromRGB(11,15,26), border=Color3.fromRGB(26,40,66), text=Color3.fromRGB(218,230,248), sub=Color3.fromRGB(100,126,158), dim=Color3.fromRGB(52,72,104), on=Color3.fromRGB(45,140,255), off=Color3.fromRGB(22,32,50), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(9,13,23), section=Color3.fromRGB(6,9,17)},
    {name="Lime",     dot=Color3.fromRGB(100,220,60),  accent=Color3.fromRGB(100,220,60),  bg=Color3.fromRGB(10,13,8),   card=Color3.fromRGB(18,24,14), cardH=Color3.fromRGB(28,38,22), sidebar=Color3.fromRGB(13,17,10), border=Color3.fromRGB(32,48,24), text=Color3.fromRGB(236,246,230), sub=Color3.fromRGB(118,152,104), dim=Color3.fromRGB(65,96,50), on=Color3.fromRGB(100,220,60), off=Color3.fromRGB(26,38,18), knobOn=Color3.fromRGB(18,28,10), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(11,15,9), section=Color3.fromRGB(8,11,6)},
    {name="Sakura",   dot=Color3.fromRGB(240,120,170), accent=Color3.fromRGB(240,120,170), bg=Color3.fromRGB(18,12,16),  card=Color3.fromRGB(30,20,26), cardH=Color3.fromRGB(44,30,38), sidebar=Color3.fromRGB(23,15,20), border=Color3.fromRGB(56,38,48), text=Color3.fromRGB(248,234,240), sub=Color3.fromRGB(160,120,140), dim=Color3.fromRGB(100,70,86), on=Color3.fromRGB(240,120,170), off=Color3.fromRGB(42,30,36), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(20,13,17), section=Color3.fromRGB(14,9,12)},
    {name="Rose",     dot=Color3.fromRGB(255,80,80),   accent=Color3.fromRGB(255,80,80),   bg=Color3.fromRGB(18,10,10),  card=Color3.fromRGB(30,18,18), cardH=Color3.fromRGB(44,26,26), sidebar=Color3.fromRGB(23,13,13), border=Color3.fromRGB(56,30,30), text=Color3.fromRGB(248,232,232), sub=Color3.fromRGB(160,110,110), dim=Color3.fromRGB(100,60,60), on=Color3.fromRGB(255,80,80), off=Color3.fromRGB(42,24,24), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(20,11,11), section=Color3.fromRGB(14,7,7)},
    {name="Frost",    dot=Color3.fromRGB(140,220,255), accent=Color3.fromRGB(140,220,255), bg=Color3.fromRGB(10,14,18),  card=Color3.fromRGB(18,24,30), cardH=Color3.fromRGB(28,38,48), sidebar=Color3.fromRGB(13,18,23), border=Color3.fromRGB(36,52,66), text=Color3.fromRGB(230,242,250), sub=Color3.fromRGB(120,150,170), dim=Color3.fromRGB(65,90,110), on=Color3.fromRGB(140,220,255), off=Color3.fromRGB(24,34,44), knobOn=Color3.fromRGB(16,22,28), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(11,16,20), section=Color3.fromRGB(8,11,15)},
    {name="Gold",     dot=Color3.fromRGB(255,180,30),  accent=Color3.fromRGB(255,180,30),  bg=Color3.fromRGB(16,13,8),   card=Color3.fromRGB(26,22,14), cardH=Color3.fromRGB(40,34,20), sidebar=Color3.fromRGB(20,17,10), border=Color3.fromRGB(50,42,22), text=Color3.fromRGB(255,248,230), sub=Color3.fromRGB(170,148,100), dim=Color3.fromRGB(110,92,54), on=Color3.fromRGB(255,180,30), off=Color3.fromRGB(40,34,18), knobOn=Color3.fromRGB(30,25,8), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(18,15,9), section=Color3.fromRGB(12,10,6)},
    {name="Void",     dot=Color3.fromRGB(190,50,255),  accent=Color3.fromRGB(190,50,255),  bg=Color3.fromRGB(6,2,12),    card=Color3.fromRGB(14,8,24),  cardH=Color3.fromRGB(24,14,40), sidebar=Color3.fromRGB(10,4,18),  border=Color3.fromRGB(40,20,60),  text=Color3.fromRGB(240,230,255), sub=Color3.fromRGB(140,110,170), dim=Color3.fromRGB(80,55,110), on=Color3.fromRGB(190,50,255), off=Color3.fromRGB(28,16,42), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(8,3,14), section=Color3.fromRGB(4,1,9)},
    {name="Blood",    dot=Color3.fromRGB(200,15,15),   accent=Color3.fromRGB(200,15,15),   bg=Color3.fromRGB(12,4,4),    card=Color3.fromRGB(22,10,10), cardH=Color3.fromRGB(36,16,16), sidebar=Color3.fromRGB(16,6,6),   border=Color3.fromRGB(50,18,18),  text=Color3.fromRGB(255,230,230), sub=Color3.fromRGB(160,90,90),   dim=Color3.fromRGB(100,45,45), on=Color3.fromRGB(200,15,15), off=Color3.fromRGB(36,14,14), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(150,150,150), header=Color3.fromRGB(14,5,5), section=Color3.fromRGB(9,2,2)},
}

local C = Themes[1]
if getgenv().SL_THEME then
    for _, t in ipairs(Themes) do
        if t.name == getgenv().SL_THEME then C = t break end
    end
end
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
local stats = {clicks = 0, bought = 0, upgrades = 0, rebirths = 0, drops = 0, income = 0, evolves = 0, ascends = 0, fruits_tp = 0}

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
    return n
end

-- Track which tab each toggle belongs to for badge counting
local tabToggles = {}

--------------------------------------------------------------
-- ANTI-AFK
--------------------------------------------------------------
local VirtualUser = game:GetService("VirtualUser")
table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
        task.wait(60)
    end
end))

--------------------------------------------------------------
-- NOTIFICATION SYSTEM
--------------------------------------------------------------
local notifContainer
local notifLog = {}
local MAX_LOG = 50

local notifColors = {
    info = Color3.fromRGB(45, 140, 255),
    success = Color3.fromRGB(50, 200, 80),
    warning = Color3.fromRGB(255, 180, 30),
    error = Color3.fromRGB(255, 70, 70),
}

local function showNotif(text, nType)
    table.insert(notifLog, 1, {text = text, time = os.date("%I:%M:%S"), type = nType or "default"})
    if #notifLog > MAX_LOG then table.remove(notifLog) end
    if not notifContainer or not notifContainer.Parent then return end
    local pipColor = nType and notifColors[nType] or nil

    local n = Instance.new("Frame")
    n.Size = UDim2.new(1, 0, 0, 0)
    n.BackgroundTransparency = 1
    n.ZIndex = 20
    n.ClipsDescendants = true
    n.Parent = notifContainer

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 22)
    bg.BorderSizePixel = 0
    bg.ZIndex = 20
    bg.Parent = n
    bg.BackgroundTransparency = 0.1
    bnd(bg, {BackgroundColor3 = "card"})
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

    local bStrk = Instance.new("UIStroke")
    bStrk.Thickness = 1
    bStrk.Transparency = 0.7
    bStrk.Parent = bg
    bnd(bStrk, {Color = "border"})

    local pip = Instance.new("Frame")
    pip.Size = UDim2.new(0, 2, 0.5, 0)
    pip.Position = UDim2.new(0, 4, 0.25, 0)
    pip.BorderSizePixel = 0
    pip.ZIndex = 21
    pip.Parent = bg
    if pipColor then
        pip.BackgroundColor3 = pipColor
    else
        bnd(pip, {BackgroundColor3 = "accent"})
    end
    Instance.new("UICorner", pip).CornerRadius = UDim.new(1, 0)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.GothamBold
    l.TextSize = 9
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 21
    l.Parent = bg
    bnd(l, {TextColor3 = "text"})

    tw(n, {Size = UDim2.new(1, 0, 0, 26)}, 0.2, Enum.EasingStyle.Back)

    task.delay(3.5, function()
        tw(n, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        tw(bg, {BackgroundTransparency = 1}, 0.3)
        tw(l, {TextTransparency = 1}, 0.3)
        task.delay(0.35, function() pcall(function() n:Destroy() end) end)
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
local WIN_W  = 530
local WIN_H  = 390

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
local HDR_H = 38
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

-- Accent line under header (gradient glow)
local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 1, 0)
AccentLine.BorderSizePixel = 0
AccentLine.BackgroundTransparency = 0.3
AccentLine.ZIndex = 11
AccentLine.Parent = Header
bnd(AccentLine, {BackgroundColor3 = "accent"})

local accentGrad = Instance.new("UIGradient")
accentGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.8),
    NumberSequenceKeypoint.new(0.3, 0),
    NumberSequenceKeypoint.new(0.7, 0),
    NumberSequenceKeypoint.new(1, 0.8),
})
accentGrad.Parent = AccentLine

table.insert(threads, task.spawn(function()
    local offset = 0
    while getgenv().SL_RUNNING do
        offset = (offset + 0.005) % 1
        accentGrad.Offset = Vector2.new(offset, 0)
        task.wait(1/30)
    end
end))

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
        tw(StatusDot, {BackgroundTransparency = 0.6, Size = UDim2.new(0, 5, 0, 5), Position = UDim2.new(0, 15, 0.5, -2)}, 0.8)
        task.wait(0.9)
        tw(StatusDot, {BackgroundTransparency = 0, Size = UDim2.new(0, 7, 0, 7), Position = UDim2.new(0, 14, 0.5, -3)}, 0.8)
        task.wait(0.9)
    end
end))

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0, 200, 1, 0)
TitleLbl.Position = UDim2.new(0, 28, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "ShinyHub"
TitleLbl.Font = Enum.Font.GothamBlack
TitleLbl.TextSize = 13
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 11
TitleLbl.Parent = Header
bnd(TitleLbl, {TextColor3 = "text"})

local SubTitleLbl = Instance.new("TextLabel")
SubTitleLbl.Size = UDim2.new(0, 120, 1, 0)
SubTitleLbl.Position = UDim2.new(0, 88, 0, 1)
SubTitleLbl.BackgroundTransparency = 1
SubTitleLbl.Text = "Sell Lemons"
SubTitleLbl.Font = Enum.Font.Gotham
SubTitleLbl.TextSize = 11
SubTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
SubTitleLbl.ZIndex = 11
SubTitleLbl.Parent = Header
bnd(SubTitleLbl, {TextColor3 = "dim"})

-- FPS / Ping display
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0, 80, 1, 0)
FPSLabel.Position = UDim2.new(1, -200, 0, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "-- FPS | --ms"
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextSize = 9
FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
FPSLabel.ZIndex = 12
FPSLabel.Parent = Header
bnd(FPSLabel, {TextColor3 = "dim"})

table.insert(threads, task.spawn(function()
    local lastTick = os.clock()
    local frames = 0
    RunS.RenderStepped:Connect(function()
        frames = frames + 1
    end)
    while getgenv().SL_RUNNING do
        task.wait(0.5)
        local now = os.clock()
        local dt = now - lastTick
        local fps = math.floor(frames / dt)
        frames = 0
        lastTick = now
        local ping = "?"
        pcall(function()
            local s = game:GetService("Stats")
            local ns = s:FindFirstChild("Network")
            if ns then
                local sc = ns:FindFirstChild("ServerStatsItem")
                if sc then
                    ping = tostring(math.floor(sc:GetValue()))
                end
            end
        end)
        pcall(function()
            ping = tostring(math.floor(LP:GetNetworkPing() * 1000))
        end)
        FPSLabel.Text = fps .. " FPS | " .. ping .. "ms"
        if fps >= 50 then
            FPSLabel.TextColor3 = C.dim
        elseif fps >= 30 then
            FPSLabel.TextColor3 = notifColors.warning
        else
            FPSLabel.TextColor3 = notifColors.error
        end
    end
end))

-- Active count badge
local ActiveBadge = Instance.new("TextLabel")
ActiveBadge.Size = UDim2.new(0, 46, 0, 16)
ActiveBadge.Position = UDim2.new(1, -114, 0.5, -8)
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
        ActiveBadge.Text = countActive() .. " on"
        task.wait(0.5)
    end
end))

-- Ghost window buttons
for idx, col in ipairs({Color3.fromRGB(255, 95, 87), Color3.fromRGB(255, 189, 46), Color3.fromRGB(39, 201, 63)}) do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 9, 0, 9)
    dot.Position = UDim2.new(1, -46 + (idx - 1) * 14, 0.5, -4)
    dot.BorderSizePixel = 0
    dot.BackgroundColor3 = col
    dot.BackgroundTransparency = 0.7
    dot.ZIndex = 12
    dot.Parent = Header
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
end

-- Close on red dot area
local CloseBtnArea = Instance.new("TextButton")
CloseBtnArea.Size = UDim2.new(0, 14, 0, 14)
CloseBtnArea.Position = UDim2.new(1, -48, 0.5, -7)
CloseBtnArea.BackgroundTransparency = 1
CloseBtnArea.Text = ""
CloseBtnArea.ZIndex = 13
CloseBtnArea.Parent = Header
CloseBtnArea.MouseButton1Click:Connect(function()
    getgenv().SL_RUNNING = false
    tw(Main, {Size = UDim2.new(0, WIN_W, 0, 0), BackgroundTransparency = 1}, 0.3)
    task.delay(0.35, function()
        for _, t in ipairs(threads) do pcall(task.cancel, t) end
        Gui:Destroy()
    end)
end)

-- Minimize on yellow dot
local MinBtnArea = Instance.new("TextButton")
MinBtnArea.Size = UDim2.new(0, 14, 0, 14)
MinBtnArea.Position = UDim2.new(1, -34, 0.5, -7)
MinBtnArea.BackgroundTransparency = 1
MinBtnArea.Text = ""
MinBtnArea.ZIndex = 13
MinBtnArea.Parent = Header
local isMinimized = false
MinBtnArea.MouseButton1Click:Connect(function()
    if not isMinimized then
        isMinimized = true
        tw(Main, {Size = UDim2.new(0, WIN_W, 0, HDR_H)}, 0.3, Enum.EasingStyle.Back)
    end
end)

-- Restore on header click when minimized
Header.InputBegan:Connect(function(i)
    if isMinimized and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
        isMinimized = false
        tw(Main, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.35, Enum.EasingStyle.Back)
        return
    end
end)

--------------------------------------------------------------
-- LEFT SIDEBAR
--------------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, SIDE_W, 1, -HDR_H - 18)
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
local tabIcons = {Home = "\xE2\x97\x8F", Farm = "\xE2\x9A\x99", Boost = "\xE2\x9A\xA1", Teleport = "\xE2\x86\x97", Stats = "\xE2\x96\xA0", Settings = "\xE2\x9C\xA6"}
local tabBtns = {}
local tabPages = {}
local tabBadges = {}
local activeTab = nil

local SideIndicator = Instance.new("Frame")
SideIndicator.Size = UDim2.new(0, 3, 0, 22)
SideIndicator.Position = UDim2.new(0, 0, 0, 14)
SideIndicator.BorderSizePixel = 0
SideIndicator.ZIndex = 8
SideIndicator.Parent = Sidebar
bnd(SideIndicator, {BackgroundColor3 = "accent"})
Instance.new("UICorner", SideIndicator).CornerRadius = UDim.new(0, 2)

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.Position = UDim2.new(0, 5, 0, 8 + (i - 1) * 32)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 1
    btn.ZIndex = 6
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 14, 1, 0)
    icon.Position = UDim2.new(0, 10, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = tabIcons[name] or ""
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 10
    icon.ZIndex = 7
    icon.Parent = btn
    bnd(icon, {TextColor3 = "dim"})

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -34, 1, 0)
    lbl.Position = UDim2.new(0, 28, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 7
    lbl.Parent = btn
    bnd(lbl, {TextColor3 = "dim"})

    -- Badge (shows active toggle count per tab)
    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 16, 0, 14)
    badge.Position = UDim2.new(1, -20, 0.5, -7)
    badge.BackgroundTransparency = 0.8
    badge.BorderSizePixel = 0
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 8
    badge.ZIndex = 8
    badge.Visible = false
    badge.Parent = btn
    bnd(badge, {TextColor3 = "accent", BackgroundColor3 = "accent"})
    Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)

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
    tabBadges[name] = badge
    tabToggles[name] = {}
end

-- Update tab badges
table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        for tabName, toggleList in pairs(tabToggles) do
            local n = 0
            for _, tName in ipairs(toggleList) do
                if toggles[tName] then n = n + 1 end
            end
            local badge = tabBadges[tabName]
            if badge then
                if n > 0 then
                    badge.Text = tostring(n)
                    badge.Visible = true
                else
                    badge.Visible = false
                end
            end
        end
        task.wait(0.5)
    end
end))

-- Version + keybind at bottom
local VerLbl = Instance.new("TextLabel")
VerLbl.Size = UDim2.new(1, -10, 0, 14)
VerLbl.Position = UDim2.new(0, 5, 1, -32)
VerLbl.BackgroundTransparency = 1
VerLbl.Text = "v6.0"
VerLbl.Font = Enum.Font.GothamBold
VerLbl.TextSize = 9
VerLbl.ZIndex = 6
VerLbl.Parent = Sidebar
bnd(VerLbl, {TextColor3 = "dim"})

local KeyLbl = Instance.new("TextLabel")
KeyLbl.Size = UDim2.new(1, -10, 0, 12)
KeyLbl.Position = UDim2.new(0, 5, 1, -18)
KeyLbl.BackgroundTransparency = 1
KeyLbl.Text = "RShift hide | \\ panic"
KeyLbl.Font = Enum.Font.Gotham
KeyLbl.TextSize = 8
KeyLbl.ZIndex = 6
KeyLbl.Parent = Sidebar
bnd(KeyLbl, {TextColor3 = "dim"})

--------------------------------------------------------------
-- CONTENT
--------------------------------------------------------------
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -SIDE_W, 1, -HDR_H - 18)
Content.Position = UDim2.new(0, SIDE_W, 0, HDR_H)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.ZIndex = 2
Content.Parent = Main

-- Status bar at bottom
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, 0, 0, 18)
StatusBar.Position = UDim2.new(0, 0, 1, -18)
StatusBar.BorderSizePixel = 0
StatusBar.ZIndex = 10
StatusBar.Parent = Main
bnd(StatusBar, {BackgroundColor3 = "header"})

local StatusBarLbl = Instance.new("TextLabel")
StatusBarLbl.Size = UDim2.new(1, -20, 1, 0)
StatusBarLbl.Position = UDim2.new(0, 10, 0, 0)
StatusBarLbl.BackgroundTransparency = 1
StatusBarLbl.Font = Enum.Font.Gotham
StatusBarLbl.TextSize = 8
StatusBarLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusBarLbl.ZIndex = 11
StatusBarLbl.Parent = StatusBar
bnd(StatusBarLbl, {TextColor3 = "dim"})

local StatusBarRight = Instance.new("TextLabel")
StatusBarRight.Size = UDim2.new(0.5, -10, 1, 0)
StatusBarRight.Position = UDim2.new(0.5, 0, 0, 0)
StatusBarRight.BackgroundTransparency = 1
StatusBarRight.Font = Enum.Font.Gotham
StatusBarRight.TextSize = 8
StatusBarRight.TextXAlignment = Enum.TextXAlignment.Right
StatusBarRight.ZIndex = 11
StatusBarRight.Parent = StatusBar
bnd(StatusBarRight, {TextColor3 = "dim"})

table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        local n = countActive()
        local e = os.clock() - sessionStart
        local uptime = string.format("%dm %ds", math.floor(e / 60), math.floor(e % 60))
        StatusBarLbl.Text = n .. " active | " .. uptime .. " | " .. fmtNum(getCash()) .. " cash"
        StatusBarRight.Text = "ShinyHub v6.0 | !help for cmds"
        task.wait(1)
    end
end))

local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, -24, 0, 22)
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
PageSub.Size = UDim2.new(1, -24, 0, 12)
PageSub.Position = UDim2.new(0, 16, 0, 26)
PageSub.BackgroundTransparency = 1
PageSub.Text = ""
PageSub.Font = Enum.Font.Gotham
PageSub.TextSize = 9
PageSub.TextXAlignment = Enum.TextXAlignment.Left
PageSub.ZIndex = 3
PageSub.Parent = Content
bnd(PageSub, {TextColor3 = "dim"})

notifContainer = Instance.new("Frame")
notifContainer.Size = UDim2.new(0, 175, 0, 100)
notifContainer.Position = UDim2.new(1, -185, 0, 6)
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
    Boost = "Progression & power",
    Teleport = "Quick travel",
    Stats = "Session statistics",
    Settings = "Themes & player mods",
}

for _, name in ipairs(tabNames) do
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, -18, 1, -42)
    page.Position = UDim2.new(0, 10, 0, 42)
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

local switching = false
local function switchTab(name)
    if switching then return end
    activeTab = name

    for n, p in pairs(tabPages) do
        if n == name then
            p.Visible = true
            p.Position = UDim2.new(0, 10, 0, 52)
            for _, child in p:GetChildren() do
                if child:IsA("GuiObject") then
                    child.BackgroundTransparency = child:GetAttribute("_origBT") or child.BackgroundTransparency
                end
            end
            tw(p, {Position = UDim2.new(0, 10, 0, 42)}, 0.18)
        else
            p.Visible = false
        end
    end

    tw(PageTitle, {TextTransparency = 1}, 0.08)
    tw(PageSub, {TextTransparency = 1}, 0.08)
    task.delay(0.08, function()
        PageTitle.Text = name
        PageSub.Text = tabSubtitles[name] or ""
        tw(PageTitle, {TextTransparency = 0}, 0.15)
        tw(PageSub, {TextTransparency = 0}, 0.15)
    end)

    for n, t in pairs(tabBtns) do
        if n == name then
            tw(t.btn, {BackgroundTransparency = 0.88, BackgroundColor3 = C.card}, 0.2)
            tw(t.lbl, {TextColor3 = C.text}, 0.2)
            if t.icon then tw(t.icon, {TextColor3 = C.accent}, 0.2) end
        else
            tw(t.btn, {BackgroundTransparency = 1}, 0.2)
            tw(t.lbl, {TextColor3 = C.dim}, 0.2)
            if t.icon then tw(t.icon, {TextColor3 = C.dim}, 0.2) end
        end
    end
    local idx = table.find(tabNames, name) or 1
    tw(SideIndicator, {Position = UDim2.new(0, 0, 0, 8 + (idx - 1) * 32 + 3)}, 0.25, Enum.EasingStyle.Back)
end

local lastTabClick = {}
for name, t in pairs(tabBtns) do
    t.btn.MouseButton1Click:Connect(function()
        local now = os.clock()
        if lastTabClick[name] and (now - lastTabClick[name]) < 0.4 then
            local toggleList = tabToggles[name]
            if toggleList and #toggleList > 0 then
                local anyOn = false
                for _, tName in ipairs(toggleList) do
                    if toggles[tName] then anyOn = true break end
                end
                for _, tName in ipairs(toggleList) do
                    toggles[tName] = not anyOn
                end
                for _, fn in ipairs(togRefresh) do pcall(fn) end
                showNotif((anyOn and "Disabled" or "Enabled") .. " all " .. name, anyOn and "warning" or "success")
            end
            lastTabClick[name] = 0
        else
            switchTab(name)
            lastTabClick[name] = now
        end
    end)
end

--------------------------------------------------------------
-- DRAG
--------------------------------------------------------------
local dragging, dragSt, dragPos
Header.InputBegan:Connect(function(i)
    if not isMinimized and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
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

-- Keybind + keyboard shortcuts
local tabKeyMap = {
    [Enum.KeyCode.One] = "Home", [Enum.KeyCode.Two] = "Farm",
    [Enum.KeyCode.Three] = "Boost", [Enum.KeyCode.Four] = "Teleport",
    [Enum.KeyCode.Five] = "Stats", [Enum.KeyCode.Six] = "Settings",
}

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then
            tw(Main, {Size = UDim2.new(0, WIN_W, 0, 0), BackgroundTransparency = 1}, 0.25)
            task.delay(0.25, function() Main.Visible = false end)
        else
            Main.Visible = true
            isMinimized = false
            Main.Size = UDim2.new(0, WIN_W, 0, 0)
            Main.BackgroundTransparency = 1
            tw(Main, {BackgroundTransparency = 0, Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.35, Enum.EasingStyle.Back)
        end
    elseif inp.KeyCode == Enum.KeyCode.BackSlash then
        for k, _ in pairs(toggles) do toggles[k] = false end
        for _, fn in ipairs(togRefresh) do pcall(fn) end
        showNotif("PANIC: All features disabled", "error")
    elseif tabKeyMap[inp.KeyCode] and Main.Visible and not isMinimized then
        switchTab(tabKeyMap[inp.KeyCode])
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
    table.insert(tabToggles[tab], name)
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
    pip.Size = UDim2.new(0, 3, 0.45, 0)
    pip.Position = UDim2.new(0, 0, 0.275, 0)
    pip.BorderSizePixel = 0
    pip.BackgroundTransparency = 0.8
    pip.ZIndex = 3
    pip.Parent = h
    bnd(pip, {BackgroundColor3 = "accent"})
    Instance.new("UICorner", pip).CornerRadius = UDim.new(1, 0)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -56, 0, desc and 16 or ROW_H)
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
        d.Size = UDim2.new(1, -56, 0, 14)
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

    local function doToggle()
        toggles[name] = not toggles[name]
        ref()
    end
    tr.MouseButton1Click:Connect(doToggle)

    -- Click anywhere on the row to toggle
    local rowBtn = Instance.new("TextButton")
    rowBtn.Size = UDim2.new(1, -44, 1, 0)
    rowBtn.Position = UDim2.new(0, 0, 0, 0)
    rowBtn.BackgroundTransparency = 1
    rowBtn.Text = ""
    rowBtn.ZIndex = 3
    rowBtn.AutoButtonColor = false
    rowBtn.Parent = h
    rowBtn.MouseButton1Click:Connect(doToggle)

    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then tw(h, {BackgroundColor3 = C.cardH}, 0.08) end
    end)
    h.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then tw(h, {BackgroundColor3 = C.card}, 0.1) end
    end)
end

local function mkSpacer(tab, height, parent)
    local s = Instance.new("Frame")
    s.LayoutOrder = nxt(tab)
    s.Size = UDim2.new(1, 0, 0, height or 4)
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

local function mkSlider(tab, label, min, max, default, step, onChange, parent)
    local value = default
    local h = Instance.new("Frame")
    h.LayoutOrder = nxt(tab)
    h.Size = UDim2.new(1, 0, 0, 38)
    h.BorderSizePixel = 0
    h.ZIndex = 2
    h.Parent = parent or tabPages[tab]
    bnd(h, {BackgroundColor3 = "card"})
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5, -10, 0, 16)
    l.Position = UDim2.new(0, 14, 0, 3)
    l.BackgroundTransparency = 1
    l.Text = label
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = h
    bnd(l, {TextColor3 = "sub"})

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.5, -10, 0, 16)
    valLbl.Position = UDim2.new(0.5, 0, 0, 3)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(value)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 3
    valLbl.Parent = h
    bnd(valLbl, {TextColor3 = "text"})

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1, -28, 0, 6)
    trackBg.Position = UDim2.new(0, 14, 0, 24)
    trackBg.BorderSizePixel = 0
    trackBg.ZIndex = 3
    trackBg.Parent = h
    bnd(trackBg, {BackgroundColor3 = "off"})
    Instance.new("UICorner", trackBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    local pct = (value - min) / (max - min)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BorderSizePixel = 0
    fill.ZIndex = 4
    fill.Parent = trackBg
    bnd(fill, {BackgroundColor3 = "accent"})
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(pct, -6, 0.5, -6)
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    knob.Parent = trackBg
    bnd(knob, {BackgroundColor3 = "text"})
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 0, 18)
    clickArea.Position = UDim2.new(0, 0, 0, 18)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 6
    clickArea.AutoButtonColor = false
    clickArea.Parent = h

    local sliding = false
    local function updateFromX(x)
        local absPos = trackBg.AbsolutePosition.X
        local absSize = trackBg.AbsoluteSize.X
        local rel = math.clamp((x - absPos) / absSize, 0, 1)
        local raw = min + rel * (max - min)
        value = math.floor(raw / step + 0.5) * step
        value = math.clamp(value, min, max)
        local newPct = (value - min) / (max - min)
        fill.Size = UDim2.new(newPct, 0, 1, 0)
        knob.Position = UDim2.new(newPct, -6, 0.5, -6)
        valLbl.Text = tostring(value)
        if onChange then onChange(value) end
    end

    clickArea.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateFromX(i.Position.X)
        end
    end)
    clickArea.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(i.Position.X)
        end
    end)

    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then tw(h, {BackgroundColor3 = C.cardH}, 0.08) end
    end)
    h.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then tw(h, {BackgroundColor3 = C.card}, 0.1) end
    end)

    return function() return value end
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
    accentBar.Size = UDim2.new(0, 3, 0.45, 0)
    accentBar.Position = UDim2.new(0, 0, 0.275, 0)
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

    for side = 1, 2 do
        local box = Instance.new("Frame")
        box.Size = UDim2.new(0.5, -2, 1, 0)
        box.Position = side == 1 and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, 2, 0, 0)
        box.BorderSizePixel = 0
        box.ZIndex = 2
        box.Parent = h
        bnd(box, {BackgroundColor3 = "card"})
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

        local ll = Instance.new("TextLabel")
        ll.Size = UDim2.new(1, -10, 0, 14)
        ll.Position = UDim2.new(0, 10, 0, 5)
        ll.BackgroundTransparency = 1
        ll.Text = side == 1 and label1 or label2
        ll.Font = Enum.Font.GothamBold
        ll.TextSize = 9
        ll.TextXAlignment = Enum.TextXAlignment.Left
        ll.ZIndex = 3
        ll.Parent = box
        bnd(ll, {TextColor3 = "dim"})

        local lv = Instance.new("TextLabel")
        lv.Size = UDim2.new(1, -10, 0, 18)
        lv.Position = UDim2.new(0, 10, 0, 20)
        lv.BackgroundTransparency = 1
        lv.Font = Enum.Font.GothamBold
        lv.TextSize = 13
        lv.TextXAlignment = Enum.TextXAlignment.Left
        lv.ZIndex = 3
        lv.Parent = box
        bnd(lv, {TextColor3 = "text"})

        local fn = side == 1 and fn1 or fn2
        lv.Text = fn()
        table.insert(threads, task.spawn(function()
            while getgenv().SL_RUNNING do lv.Text = fn() task.wait(1) end
        end))
    end
end

local function fmtNum(n)
    if type(n) ~= "number" then return tostring(n) end
    if n >= 1e15 then return string.format("%.2fQd", n / 1e15)
    elseif n >= 1e12 then return string.format("%.2fT", n / 1e12)
    elseif n >= 1e9 then return string.format("%.2fB", n / 1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n / 1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n / 1e3)
    else return tostring(math.floor(n)) end
end

local function getCash()
    local ls = LP:FindFirstChild("leaderstats")
    local cash = ls and ls:FindFirstChild("Cash")
    return cash and cash.Value or 0
end

local function getVal(name)
    if not Values then return nil end
    local v = Values:FindFirstChild(name)
    return v and v.Value or nil
end

local function smartTP(locName)
    local loc = Locations:FindFirstChild(locName)
    if loc and loc:IsA("BasePart") then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = loc.CFrame + Vector3.new(0, 3, 0)
            showNotif("TP: " .. (locationRenames[locName] or locName))
        end
    end
end

--------------------------------------------------------------
-- HOME TAB
--------------------------------------------------------------
mkStatCard("Home", "CASH", function() return fmtNum(getCash()) end)
mkSpacer("Home", 3)

mkDualStat("Home",
    "CASH / HR", function()
        local cph = getCashPerHour()
        if cph == 0 then
            local elapsed = os.clock() - sessionStart
            if elapsed < 5 then return "---" end
            local earned = getCash() - startCash
            return fmtNum(math.max(0, (earned / elapsed) * 3600))
        end
        return fmtNum(cph)
    end,
    "UPTIME", function()
        local e = os.clock() - sessionStart
        if e >= 3600 then return string.format("%dh %dm", math.floor(e/3600), math.floor(e%3600/60)) end
        return string.format("%dm %ds", math.floor(e / 60), math.floor(e % 60))
    end
)
mkSpacer("Home", 3)

mkDualStat("Home",
    "TYCOON", function() return myTycoon.Name:gsub("Tycoon", "#") end,
    "FEATURES ON", function() return tostring(countActive()) end
)

mkSpacer("Home", 3)

mkDualStat("Home",
    "CASH / MIN", function()
        local cph = getCashPerHour()
        if cph == 0 then
            local elapsed = os.clock() - sessionStart
            if elapsed < 5 then return "---" end
            local earned = getCash() - startCash
            return fmtNum(math.max(0, earned / elapsed * 60))
        end
        return fmtNum(cph / 60)
    end,
    "EARNED", function()
        return fmtNum(math.max(0, getCash() - startCash))
    end
)

mkSpacer("Home", 3)

-- Game values row
mkDualStat("Home",
    "REBIRTHS", function()
        local v = getVal("Rebirths") or getVal("Rebirth")
        return v and tostring(v) or "---"
    end,
    "POWER LVL", function()
        local v = getVal("PowerLevel") or getVal("Power")
        return v and tostring(v) or "---"
    end
)

mkSpacer("Home", 3)
mkDualStat("Home",
    "EVOLVES", function()
        return tostring(stats.evolves)
    end,
    "ASCENDS", function()
        return tostring(stats.ascends)
    end
)

mkSpacer("Home", 3)
mkDualStat("Home",
    "CLOCK", function()
        return os.date("%I:%M %p")
    end,
    "ITEMS BOUGHT", function()
        return fmtNum(stats.bought)
    end
)

mkSpacer("Home", 3)
mkStatCard("Home", "ACTIVE FEATURES", function()
    local names = {}
    for k, v in pairs(toggles) do
        if v then table.insert(names, k) end
    end
    if #names == 0 then return "None" end
    if #names <= 3 then return table.concat(names, ", ") end
    return #names .. " features running"
end)

mkSpacer("Home", 6)
mkSection("Home", "Shortcuts")

local shortcutsCard = Instance.new("Frame")
shortcutsCard.LayoutOrder = nxt("Home")
shortcutsCard.Size = UDim2.new(1, 0, 0, 68)
shortcutsCard.BorderSizePixel = 0
shortcutsCard.ZIndex = 2
shortcutsCard.Parent = tabPages.Home
bnd(shortcutsCard, {BackgroundColor3 = "card"})
Instance.new("UICorner", shortcutsCard).CornerRadius = UDim.new(0, 8)

local shortcutsText = Instance.new("TextLabel")
shortcutsText.Size = UDim2.new(1, -20, 1, -6)
shortcutsText.Position = UDim2.new(0, 14, 0, 3)
shortcutsText.BackgroundTransparency = 1
shortcutsText.Text = "1-6: Switch tabs  |  RShift: Hide UI\n\\: Panic (disable all)  |  Ctrl+Click: TP\nDouble-click tab: Toggle all in tab\nChat: !speed !jump !fov !tp !afk !off !help"
shortcutsText.Font = Enum.Font.Gotham
shortcutsText.TextSize = 9
shortcutsText.TextXAlignment = Enum.TextXAlignment.Left
shortcutsText.TextWrapped = true
shortcutsText.ZIndex = 3
shortcutsText.RichText = false
shortcutsText.Parent = shortcutsCard
bnd(shortcutsText, {TextColor3 = "sub"})

mkSpacer("Home", 6)
mkSection("Home", "Purchase Progress")

mkStatCard("Home", "ITEMS PROGRESS", function()
    local total, bought = 0, 0
    for _, area in Purchases:GetChildren() do
        local buttons = area:FindFirstChild("Buttons")
        if buttons then
            local function scan(folder)
                for _, item in folder:GetChildren() do
                    if item:IsA("Folder") then scan(item)
                    elseif item:IsA("Model") then
                        total = total + 1
                        if item:GetAttribute("Purchased") == true then
                            bought = bought + 1
                        end
                    end
                end
            end
            scan(buttons)
        end
    end
    if total == 0 then return "---" end
    local pct = math.floor((bought / total) * 100)
    return bought .. " / " .. total .. " (" .. pct .. "%)"
end)

mkSpacer("Home", 6)
mkSection("Home", "Quick Actions")

mkButton("Home", "Enable All Farm", function()
    for _, name in ipairs({"Auto Buy Items", "Auto Click Income", "Auto Upgrade Earners", "Auto Collect Fruit", "Auto Collect Drops", "Auto Phone Offer"}) do
        toggles[name] = true
    end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    showNotif("All farm features enabled")
end)

mkButton("Home", "Enable All Boost", function()
    for _, name in ipairs({"Auto Rebirth", "Auto Evolve", "Auto Ascend", "Auto Upgrade Power"}) do
        toggles[name] = true
    end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    showNotif("All boost features enabled")
end)

mkButton("Home", "Enable Everything", function()
    for k, _ in pairs(toggles) do toggles[k] = true end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    showNotif("Everything enabled")
end)

mkButton("Home", "Enable All Mods", function()
    for _, name in ipairs({"Speed Boost", "Infinite Jump", "Noclip", "Player ESP", "Fullbright"}) do
        toggles[name] = true
    end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    showNotif("All player mods enabled", "success")
end)

mkButton("Home", "Disable All", function()
    for k, _ in pairs(toggles) do toggles[k] = false end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    showNotif("All features disabled", "warning")
end)

mkSpacer("Home", 6)
mkSection("Home", "Presets")

mkButton("Home", "AFK Mode", function()
    for k, _ in pairs(toggles) do toggles[k] = false end
    for _, name in ipairs({"Auto Buy Items", "Auto Click Income", "Auto Upgrade Earners", "Auto Collect Fruit", "Auto Collect Drops", "Auto Phone Offer", "Auto Toggle Conveyors", "Auto Rebirth", "Auto Evolve", "Auto Ascend", "Auto Upgrade Power", "Auto Special Income", "Auto All Prompts", "TP to Trees"}) do
        toggles[name] = true
    end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    showNotif("AFK Mode: All automation ON", "success")
end)

mkButton("Home", "Grind Mode", function()
    for k, _ in pairs(toggles) do toggles[k] = false end
    for _, name in ipairs({"Auto Buy Items", "Auto Click Income", "Auto Upgrade Earners", "Auto Collect Fruit", "Auto Collect Drops", "Auto Phone Offer", "Auto Toggle Conveyors", "Auto Rebirth", "Auto Evolve", "Auto Ascend", "Auto Upgrade Power", "Auto Special Income", "Auto All Prompts", "Auto Fruit Service", "Auto Click All", "TP to Trees", "Speed Boost", "Fullbright"}) do
        toggles[name] = true
    end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    showNotif("Grind Mode: MAX automation + speed", "success")
end)

mkButton("Home", "Stealth Mode", function()
    for k, _ in pairs(toggles) do toggles[k] = false end
    for _, name in ipairs({"Auto Buy Items", "Auto Collect Drops", "Auto Phone Offer", "Auto Rebirth"}) do
        toggles[name] = true
    end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    showNotif("Stealth Mode: Minimal automation", "info")
end)

mkButton("Home", "Explorer Mode", function()
    for k, _ in pairs(toggles) do toggles[k] = false end
    for _, name in ipairs({"Speed Boost", "Infinite Jump", "Noclip", "Fly", "Fullbright", "Player ESP", "Show Area Waypoints", "Item ESP"}) do
        toggles[name] = true
    end
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    showNotif("Explorer Mode: Movement + ESP ON", "info")
end)

--------------------------------------------------------------
-- FARM TAB
--------------------------------------------------------------
mkSection("Farm", "Farm Speed")
local getFarmDelay = mkSlider("Farm", "Cycle Delay (ms)", 10, 500, 200, 10)

mkSpacer("Farm", 2)
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

mkButton("Farm", "Buy All Now (One Pass)", function()
    local count = 0
    for _, area in Purchases:GetChildren() do
        local buttons = area:FindFirstChild("Buttons")
        if buttons then
            local function scan(folder)
                for _, item in folder:GetChildren() do
                    if item:IsA("Folder") then scan(item)
                    elseif item:IsA("Model") and item:GetAttribute("Purchased") ~= true and item:GetAttribute("Enabled") == true then
                        local rem = item:FindFirstChild("Purchase")
                        if rem and rem:IsA("RemoteFunction") then
                            pcall(function() rem:InvokeServer(false) end)
                            count = count + 1
                        end
                    end
                end
            end
            scan(buttons)
        end
    end
    showNotif("Bought " .. count .. " items", "success")
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
mkToggle("Farm", "TP to Trees", "Teleports to trees for faster collection")

loop("Auto Collect Fruit", function()
    local trees = Constant:FindFirstChild("Trees")
    if not trees then task.wait(1) return end

    if toggles["TP to Trees"] then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local firstTree = trees:GetChildren()[1]
            if firstTree then
                local treePart = firstTree:FindFirstChildWhichIsA("BasePart")
                if treePart then
                    hrp.CFrame = treePart.CFrame + Vector3.new(0, 5, 0)
                    stats.fruits_tp = stats.fruits_tp + 1
                end
            end
        end
    end

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

mkToggle("Farm", "Auto Collect Drops", "Redeems cash drops")
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

mkToggle("Farm", "Auto Fruit Service", "Uses ClickFruitService remote")
loop("Auto Fruit Service", function()
    local clickFruit = RemReq and RemReq:FindFirstChild("ClickFruitService") and RemReq.ClickFruitService:FindFirstChild("Clicked")
    if clickFruit then
        local trees = Constant:FindFirstChild("Trees")
        if trees then
            for _, tree in trees:GetChildren() do
                if not getgenv().SL_RUNNING or not toggles["Auto Fruit Service"] then return end
                for _, fruit in tree:GetChildren() do
                    if fruit.Name == "Fruit" and fruit.Transparency < 1 then
                        pcall(function() clickFruit:InvokeServer(fruit) end)
                    end
                end
            end
        end
    end
    task.wait(0.1)
end)

mkSpacer("Farm", 2)
mkSection("Farm", "Misc")

mkToggle("Farm", "Auto Workspace Drops", "Collects dropped items in workspace")
loop("Auto Workspace Drops", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then task.wait(1) return end
    for _, obj in game.Workspace:GetChildren() do
        if not getgenv().SL_RUNNING or not toggles["Auto Workspace Drops"] then return end
        if obj:IsA("BasePart") and obj:FindFirstChild("ClickDetector") then
            if (obj.Position - hrp.Position).Magnitude < 200 then
                pcall(fireclickdetector, obj.ClickDetector)
            end
        elseif obj:IsA("Model") then
            local cd = obj:FindFirstChildWhichIsA("ClickDetector", true)
            if cd then
                local part = cd.Parent
                if part and part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude < 200 then
                    pcall(fireclickdetector, cd)
                end
            end
        end
    end
    task.wait(0.3)
end)

mkToggle("Farm", "Auto Click All", "Clicks every ClickDetector in tycoon")
loop("Auto Click All", function()
    for _, desc in myTycoon:GetDescendants() do
        if not getgenv().SL_RUNNING or not toggles["Auto Click All"] then return end
        if desc:IsA("ClickDetector") then
            pcall(fireclickdetector, desc)
        end
    end
    task.wait(0.2)
end)

mkToggle("Farm", "Auto All Prompts", "Fires every ProximityPrompt in tycoon")
loop("Auto All Prompts", function()
    for _, desc in myTycoon:GetDescendants() do
        if not getgenv().SL_RUNNING or not toggles["Auto All Prompts"] then return end
        if desc:IsA("ProximityPrompt") then
            pcall(fireproximityprompt, desc)
        end
    end
    task.wait(0.3)
end)

mkSpacer("Farm", 2)
mkToggle("Farm", "TP Income Loop", "TPs to each earner + clicks income")
table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        if toggles["TP Income Loop"] then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, areaName in ipairs(areaNames) do
                    if not toggles["TP Income Loop"] then break end
                    local area = Purchases:FindFirstChild(areaName)
                    if area then
                        local m = area:FindFirstChild(areaName)
                        if m and m:IsA("Model") then
                            local part = m:FindFirstChild(areaName)
                            if part and part:IsA("BasePart") then
                                hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                                task.wait(0.1)
                                local prompt = part:FindFirstChild("Prompt")
                                if prompt then pcall(fireproximityprompt, prompt) end
                                local upg = part:FindFirstChild("Upgrade")
                                if upg then pcall(function() upg:InvokeServer(1) end) end
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        else
            task.wait(0.3)
        end
    end
end))

mkSpacer("Farm", 2)
mkSection("Farm", "Conveyors")

mkToggle("Farm", "Auto Toggle Conveyors", "Fires conveyor belt prompts")
loop("Auto Toggle Conveyors", function()
    for _, area in Purchases:GetChildren() do
        if not getgenv().SL_RUNNING or not toggles["Auto Toggle Conveyors"] then return end
        local function findPrompts(parent)
            for _, child in parent:GetChildren() do
                if not getgenv().SL_RUNNING or not toggles["Auto Toggle Conveyors"] then return end
                if child.Name == "TogglePrompt" and child:IsA("ProximityPrompt") then
                    pcall(fireproximityprompt, child)
                    task.wait(0.1)
                elseif child:IsA("Model") or child:IsA("Folder") or child:IsA("BasePart") then
                    findPrompts(child)
                end
            end
        end
        findPrompts(area)
    end
    task.wait(2)
end)

--------------------------------------------------------------
-- BOOST TAB
--------------------------------------------------------------
mkSection("Boost", "Progression")

mkToggle("Boost", "Auto Rebirth", "Rebirths when available")
loop("Auto Rebirth", function()
    local before = stats.rebirths
    local ok = pcall(function() Remotes.Rebirth:InvokeServer() end)
    if ok then
        stats.rebirths = stats.rebirths + 1
        if stats.rebirths > before then
            showNotif("Rebirth #" .. stats.rebirths)
        end
    end
    task.wait(0.8)
end)

mkToggle("Boost", "Auto Evolve", "Evolves when available")
loop("Auto Evolve", function()
    local before = stats.evolves
    local ok = pcall(function() Remotes.Evolve:InvokeServer() end)
    if ok then
        stats.evolves = stats.evolves + 1
        if stats.evolves > before then
            showNotif("Evolved #" .. stats.evolves)
        end
    end
    task.wait(1.5)
end)

mkToggle("Boost", "Auto Ascend", "Ascends when available")
loop("Auto Ascend", function()
    local ok = pcall(function() Remotes.Ascend:InvokeServer() end)
    if ok then stats.ascends = stats.ascends + 1 end
    task.wait(2)
end)

mkSpacer("Boost", 2)
mkSection("Boost", "Power")

mkToggle("Boost", "Auto Upgrade Power", "Upgrades power level")
loop("Auto Upgrade Power", function()
    pcall(function() Remotes.UpgradePowerLevel:InvokeServer() end)
    task.wait(0.8)
end)

local getPowerSelect = mkSlider("Boost", "Power Level Select", 1, 50, 1, 1)
mkButton("Boost", "Set Power Level", function()
    local lvl = getPowerSelect()
    pcall(function() Remotes.SelectPowerLevel:InvokeServer(lvl) end)
    showNotif("Power level set to " .. lvl, "success")
end)

mkSpacer("Boost", 2)
mkSection("Boost", "Auto Firing")

mkToggle("Boost", "Auto Special Income", "Fires SpecialIncome remote")
loop("Auto Special Income", function()
    pcall(function() Remotes.SpecialIncome:FireServer() end)
    task.wait(0.5)
end)

mkToggle("Boost", "Auto Void Events", "Fires VoidEventService remote")
loop("Auto Void Events", function()
    local voidRemote = RemReq and RemReq:FindFirstChild("VoidEventService") and RemReq.VoidEventService:FindFirstChild("Event")
    if voidRemote then
        pcall(function() voidRemote:FireServer() end)
    end
    task.wait(1)
end)

mkToggle("Boost", "Auto Minigame Race", "Starts minigame races")
loop("Auto Minigame Race", function()
    local raceStart = RemReq and RemReq:FindFirstChild("MinigameRaceService") and RemReq.MinigameRaceService:FindFirstChild("Start")
    if raceStart then
        pcall(function() raceStart:InvokeServer() end)
    end
    task.wait(5)
end)

mkSpacer("Boost", 2)
mkSection("Boost", "Instant Boosts")

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
mkButton("Boost", "Spam Upgrade All x50", function()
    showNotif("Spam upgrading earners...", "info")
    task.spawn(function()
        for _ = 1, 50 do
            for _, areaName in ipairs(areaNames) do
                local area = Purchases:FindFirstChild(areaName)
                if area then
                    local m = area:FindFirstChild(areaName)
                    if m and m:IsA("Model") then
                        local part = m:FindFirstChild(areaName)
                        if part then
                            local upg = part:FindFirstChild("Upgrade")
                            if upg and upg:IsA("RemoteFunction") then
                                pcall(function() upg:InvokeServer(1) end)
                            end
                        end
                    end
                end
            end
            task.wait(0.02)
        end
        showNotif("50x upgrade complete!", "success")
    end)
end)

mkButton("Boost", "Spam Power Upgrade x100", function()
    showNotif("Spamming power upgrades...", "info")
    task.spawn(function()
        for _ = 1, 100 do
            pcall(function() Remotes.UpgradePowerLevel:InvokeServer() end)
            task.wait(0.02)
        end
        showNotif("100x power upgrade done!", "success")
    end)
end)

mkSpacer("Boost", 2)
mkButton("Boost", "Collect ALL Boosts", function()
    pcall(function() Remotes.UseTimeCash:InvokeServer() end)
    pcall(function() Remotes.UseEarnerBoost:InvokeServer() end)
    pcall(function() Remotes.DoubleOfflineCash:InvokeServer() end)
    showNotif("All boosts collected!", "success")
end)

mkButton("Boost", "Fire ALL Known Remotes", function()
    showNotif("Firing all remotes...", "info")
    local count = 0
    for _, remote in Remotes:GetChildren() do
        pcall(function()
            if remote:IsA("RemoteFunction") then
                remote:InvokeServer()
            elseif remote:IsA("RemoteEvent") then
                remote:FireServer()
            end
            count = count + 1
        end)
    end
    showNotif("Fired " .. count .. " remotes", "success")
end)

mkSpacer("Boost", 2)
mkButton("Boost", "MEGA MAX (Buy+Upgrade+Power x100)", function()
    showNotif("MEGA MAX running...", "warning")
    task.spawn(function()
        for _ = 1, 100 do
            if not getgenv().SL_RUNNING then return end
            for _, area in Purchases:GetChildren() do
                local buttons = area:FindFirstChild("Buttons")
                if buttons then
                    for _, item in buttons:GetDescendants() do
                        if item:IsA("Model") and item:GetAttribute("Purchased") ~= true and item:GetAttribute("Enabled") == true then
                            local rem = item:FindFirstChild("Purchase")
                            if rem then pcall(function() rem:InvokeServer(false) end) end
                        end
                    end
                end
                local m = area:FindFirstChild(area.Name)
                if m and m:IsA("Model") then
                    local part = m:FindFirstChild(area.Name)
                    if part then
                        local upg = part:FindFirstChild("Upgrade")
                        if upg then pcall(function() upg:InvokeServer(1) end) end
                    end
                end
            end
            pcall(function() Remotes.UpgradePowerLevel:InvokeServer() end)
            pcall(function() Remotes.Rebirth:InvokeServer() end)
            pcall(function() Remotes.Evolve:InvokeServer() end)
            task.wait(0.02)
        end
        showNotif("MEGA MAX complete!", "success")
    end)
end)

--------------------------------------------------------------
-- TELEPORT TAB
--------------------------------------------------------------
mkSection("Teleport", "Tycoon Areas")

local areaLocs, otherLocs = {}, {}
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

mkSpacer("Teleport", 4)
mkSection("Teleport", "Waypoints")

mkToggle("Teleport", "Show Area Waypoints", "BillboardGui markers on areas")
local waypointGuis = {}

local function createWaypoints()
    for _, areaName in ipairs(areaNames) do
        local area = Purchases:FindFirstChild(areaName)
        if area then
            local m = area:FindFirstChild(areaName)
            if m and m:IsA("Model") then
                local part = m:FindFirstChild(areaName)
                if part and part:IsA("BasePart") then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "SH_Waypoint"
                    bb.Size = UDim2.new(0, 100, 0, 30)
                    bb.StudsOffset = Vector3.new(0, 6, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = part
                    bb.Parent = game.CoreGui

                    local l = Instance.new("TextLabel")
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.BackgroundTransparency = 0.4
                    l.BackgroundColor3 = C.bg
                    l.Text = areaName
                    l.Font = Enum.Font.GothamBold
                    l.TextSize = 11
                    l.TextColor3 = C.accent
                    l.Parent = bb
                    Instance.new("UICorner", l).CornerRadius = UDim.new(0, 6)

                    local strk = Instance.new("UIStroke")
                    strk.Thickness = 1
                    strk.Transparency = 0.5
                    strk.Color = C.accent
                    strk.Parent = l

                    table.insert(waypointGuis, bb)
                end
            end
        end
    end
end

local function destroyWaypoints()
    for _, gui in ipairs(waypointGuis) do
        pcall(function() gui:Destroy() end)
    end
    waypointGuis = {}
end

table.insert(threads, task.spawn(function()
    local wasOn = false
    while getgenv().SL_RUNNING do
        if toggles["Show Area Waypoints"] and not wasOn then
            createWaypoints()
            wasOn = true
        elseif not toggles["Show Area Waypoints"] and wasOn then
            destroyWaypoints()
            wasOn = false
        end
        task.wait(0.3)
    end
    destroyWaypoints()
end))

mkToggle("Teleport", "Item ESP", "Shows unpurchased items through walls")
local itemEspGuis = {}

local function updateItemESP()
    for _, gui in ipairs(itemEspGuis) do pcall(function() gui:Destroy() end) end
    itemEspGuis = {}
    if not toggles["Item ESP"] then return end
    for _, area in Purchases:GetChildren() do
        local buttons = area:FindFirstChild("Buttons")
        if buttons then
            local function scan(folder)
                for _, item in folder:GetChildren() do
                    if item:IsA("Folder") then scan(item)
                    elseif item:IsA("Model") and item:GetAttribute("Purchased") ~= true then
                        local prim = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                        if prim then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "SH_ItemESP"
                            bb.Size = UDim2.new(0, 80, 0, 18)
                            bb.StudsOffset = Vector3.new(0, 4, 0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = prim
                            bb.Parent = game.CoreGui

                            local displayName = item:GetAttribute("DisplayName") or item.Name
                            local enabled = item:GetAttribute("Enabled") == true
                            local col = enabled and Color3.fromRGB(50, 200, 80) or Color3.fromRGB(255, 70, 70)

                            local l = Instance.new("TextLabel")
                            l.Size = UDim2.new(1, 0, 1, 0)
                            l.BackgroundTransparency = 0.4
                            l.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                            l.Text = displayName
                            l.Font = Enum.Font.GothamBold
                            l.TextSize = 8
                            l.TextColor3 = col
                            l.Parent = bb
                            Instance.new("UICorner", l).CornerRadius = UDim.new(0, 4)

                            table.insert(itemEspGuis, bb)
                        end
                    end
                end
            end
            scan(buttons)
        end
    end
end

table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        if toggles["Item ESP"] then updateItemESP() end
        task.wait(3)
    end
    for _, gui in ipairs(itemEspGuis) do pcall(function() gui:Destroy() end) end
end))

table.insert(togRefresh, function()
    if not toggles["Item ESP"] then
        for _, gui in ipairs(itemEspGuis) do pcall(function() gui:Destroy() end) end
        itemEspGuis = {}
    end
end)

mkToggle("Teleport", "Item Highlights", "Glowing outlines on available items")
local itemHighlights = {}

local function updateItemHighlights()
    for _, hl in ipairs(itemHighlights) do pcall(function() hl:Destroy() end) end
    itemHighlights = {}
    if not toggles["Item Highlights"] then return end
    for _, area in Purchases:GetChildren() do
        local buttons = area:FindFirstChild("Buttons")
        if buttons then
            local function scan(folder)
                for _, item in folder:GetChildren() do
                    if item:IsA("Folder") then scan(item)
                    elseif item:IsA("Model") and item:GetAttribute("Purchased") ~= true then
                        local enabled = item:GetAttribute("Enabled") == true
                        pcall(function()
                            local hl = Instance.new("Highlight")
                            hl.Name = "SH_HL"
                            hl.FillColor = enabled and Color3.fromRGB(50, 200, 80) or Color3.fromRGB(255, 70, 70)
                            hl.OutlineColor = enabled and Color3.fromRGB(30, 150, 50) or Color3.fromRGB(180, 40, 40)
                            hl.FillTransparency = 0.7
                            hl.OutlineTransparency = 0.3
                            hl.Adornee = item
                            hl.Parent = game.CoreGui
                            table.insert(itemHighlights, hl)
                        end)
                    end
                end
            end
            scan(buttons)
        end
    end
end

table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        if toggles["Item Highlights"] then updateItemHighlights() end
        task.wait(5)
    end
    for _, hl in ipairs(itemHighlights) do pcall(function() hl:Destroy() end) end
end))

table.insert(togRefresh, function()
    if not toggles["Item Highlights"] then
        for _, hl in ipairs(itemHighlights) do pcall(function() hl:Destroy() end) end
        itemHighlights = {}
    end
end)

mkToggle("Teleport", "Teleport Loop", "Cycles through all areas every 5s")
table.insert(threads, task.spawn(function()
    local loopIdx = 1
    while getgenv().SL_RUNNING do
        if toggles["Teleport Loop"] then
            local locs = Locations:GetChildren()
            if #locs > 0 then
                loopIdx = ((loopIdx - 1) % #locs) + 1
                local loc = locs[loopIdx]
                if loc:IsA("BasePart") then
                    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = loc.CFrame + Vector3.new(0, 3, 0)
                        local display = locationRenames[loc.Name] or loc.Name
                        showNotif("Loop TP: " .. display, "info")
                    end
                end
                loopIdx = loopIdx + 1
            end
            task.wait(5)
        else
            task.wait(0.3)
        end
    end
end))

mkSpacer("Teleport", 4)
mkSection("Teleport", "Special")
mkButton("Teleport", "TP to Spawn", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local spawn = game.Workspace:FindFirstChild("SpawnLocation") or game.Workspace:FindFirstChild("Spawn")
        if spawn then
            hrp.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
        else
            hrp.CFrame = CFrame.new(0, 50, 0)
        end
        showNotif("TP: Spawn")
    end
end)
mkButton("Teleport", "TP to My Tycoon", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local firstLoc = Locations:GetChildren()[1]
    if hrp and firstLoc and firstLoc:IsA("BasePart") then
        hrp.CFrame = firstLoc.CFrame + Vector3.new(0, 3, 0)
        showNotif("TP: My Tycoon")
    end
end)

mkButton("Teleport", "TP to Random Player", function()
    local others = {}
    for _, p in Players:GetPlayers() do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(others, p)
        end
    end
    if #others > 0 then
        local target = others[math.random(#others)]
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            showNotif("TP: " .. target.Name, "info")
        end
    else
        showNotif("No other players!", "warning")
    end
end)

mkButton("Teleport", "TP Behind Random Player", function()
    local others = {}
    for _, p in Players:GetPlayers() do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(others, p)
        end
    end
    if #others > 0 then
        local target = others[math.random(#others)]
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local tHRP = target.Character.HumanoidRootPart
        if hrp then
            hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, 5)
            showNotif("Behind: " .. target.Name, "info")
        end
    else
        showNotif("No other players!", "warning")
    end
end)

mkSpacer("Teleport", 4)
mkSection("Teleport", "Follow")

mkToggle("Teleport", "Follow Nearest Player", "Auto-TPs to closest player")
table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        if toggles["Follow Nearest Player"] then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local closest, closestDist = nil, math.huge
                for _, p in Players:GetPlayers() do
                    if p ~= LP and p.Character then
                        local pHRP = p.Character:FindFirstChild("HumanoidRootPart")
                        if pHRP then
                            local dist = (hrp.Position - pHRP.Position).Magnitude
                            if dist < closestDist then
                                closest = pHRP
                                closestDist = dist
                            end
                        end
                    end
                end
                if closest and closestDist > 10 then
                    hrp.CFrame = closest.CFrame * CFrame.new(0, 0, 5)
                end
            end
            task.wait(2)
        else
            task.wait(0.3)
        end
    end
end))

mkSpacer("Teleport", 4)
mkSection("Teleport", "Players")

-- Dynamic player TP buttons
local playerTPContainer = Instance.new("Frame")
playerTPContainer.LayoutOrder = nxt("Teleport")
playerTPContainer.Size = UDim2.new(1, 0, 0, 0)
playerTPContainer.BackgroundTransparency = 1
playerTPContainer.AutomaticSize = Enum.AutomaticSize.Y
playerTPContainer.ZIndex = 2
playerTPContainer.Parent = tabPages.Teleport

local playerTPLayout = Instance.new("UIListLayout", playerTPContainer)
playerTPLayout.Padding = UDim.new(0, 4)
playerTPLayout.SortOrder = Enum.SortOrder.Name

local function refreshPlayerTP()
    for _, c in playerTPContainer:GetChildren() do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, player in Players:GetPlayers() do
        if player ~= LP then
            local b = Instance.new("TextButton")
            b.Name = player.Name
            b.Size = UDim2.new(1, 0, 0, 26)
            b.Text = ""
            b.BorderSizePixel = 0
            b.ZIndex = 2
            b.AutoButtonColor = false
            b.Parent = playerTPContainer
            bnd(b, {BackgroundColor3 = "card"})
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

            local dist = ""
            pcall(function()
                local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local pHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if myHRP and pHRP then
                    dist = " [" .. math.floor((myHRP.Position - pHRP.Position).Magnitude) .. "m]"
                end
            end)

            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -30, 1, 0)
            l.Position = UDim2.new(0, 14, 0, 0)
            l.BackgroundTransparency = 1
            l.Text = player.Name .. dist
            l.Font = Enum.Font.Gotham
            l.TextSize = 11
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.ZIndex = 3
            l.Parent = b
            bnd(l, {TextColor3 = "sub"})

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

            b.MouseButton1Click:Connect(function()
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local targetHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and targetHRP then
                    hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
                    showNotif("TP: " .. player.Name)
                end
                tw(b, {BackgroundColor3 = C.accent}, 0.04)
                task.delay(0.12, function() tw(b, {BackgroundColor3 = C.card}, 0.3) end)
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
    end
end

refreshPlayerTP()
Players.PlayerAdded:Connect(function() task.delay(1, refreshPlayerTP) end)
Players.PlayerRemoving:Connect(function() task.delay(0.5, refreshPlayerTP) end)

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

mkDualStat("Stats",
    "ASCENDS", function() return tostring(stats.ascends) end,
    "DROPS COLLECTED", function() return fmtNum(stats.drops) end
)
mkSpacer("Stats", 3)

mkStatCard("Stats", "TOTAL CASH EARNED", function()
    local earned = getCash() - startCash
    return fmtNum(math.max(0, earned))
end)
mkSpacer("Stats", 3)

mkDualStat("Stats",
    "SESSION TIME", function()
        local e = os.clock() - sessionStart
        if e >= 3600 then return string.format("%dh %dm %ds", math.floor(e/3600), math.floor(e%3600/60), math.floor(e%60)) end
        return string.format("%dm %ds", math.floor(e / 60), math.floor(e % 60))
    end,
    "CASH / HR", function() return fmtNum(getCashPerHour()) end
)

mkSpacer("Stats", 3)

mkStatCard("Stats", "SERVER PLAYERS", function()
    return tostring(#Players:GetPlayers()) .. " / " .. tostring(Players.MaxPlayers)
end)

mkSpacer("Stats", 3)
mkStatCard("Stats", "FRUIT TPS", function()
    return fmtNum(stats.fruits_tp)
end)

mkSpacer("Stats", 6)
mkSection("Stats", "Area Progress")

for _, areaName in ipairs(areaNames) do
    mkStatCard("Stats", areaName:upper(), function()
        local area = Purchases:FindFirstChild(areaName)
        if not area then return "N/A" end
        local buttons = area:FindFirstChild("Buttons")
        if not buttons then return "No items" end
        local total, bought = 0, 0
        local function scan(folder)
            for _, item in folder:GetChildren() do
                if item:IsA("Folder") then scan(item)
                elseif item:IsA("Model") then
                    total = total + 1
                    if item:GetAttribute("Purchased") == true then bought = bought + 1 end
                end
            end
        end
        scan(buttons)
        if total == 0 then return "Empty" end
        local pct = math.floor((bought / total) * 100)
        return bought .. "/" .. total .. " (" .. pct .. "%)"
    end)
end

mkSpacer("Stats", 6)
mkSection("Stats", "Notification Log")

local logLabel = Instance.new("TextLabel")
logLabel.LayoutOrder = nxt("Stats")
logLabel.Size = UDim2.new(1, 0, 0, 14)
logLabel.BackgroundTransparency = 1
logLabel.Font = Enum.Font.Gotham
logLabel.TextSize = 9
logLabel.TextXAlignment = Enum.TextXAlignment.Left
logLabel.TextWrapped = true
logLabel.AutomaticSize = Enum.AutomaticSize.Y
logLabel.ZIndex = 2
logLabel.RichText = true
logLabel.Parent = tabPages.Stats
bnd(logLabel, {TextColor3 = "sub"})

table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        local lines = {}
        local count = math.min(15, #notifLog)
        for i = 1, count do
            local entry = notifLog[i]
            local color = "gray"
            if entry.type == "success" then color = "#32C850"
            elseif entry.type == "warning" then color = "#FFB41E"
            elseif entry.type == "error" then color = "#FF4646"
            elseif entry.type == "info" then color = "#2D8CFF"
            end
            table.insert(lines, '<font color="' .. color .. '">[' .. entry.time .. ']</font> ' .. entry.text)
        end
        logLabel.Text = #lines > 0 and table.concat(lines, "\n") or "No notifications yet"
        logLabel.Size = UDim2.new(1, 0, 0, math.max(14, #lines * 13))
        task.wait(1)
    end
end))

mkSpacer("Stats", 6)
mkSection("Stats", "Export")

mkButton("Stats", "Copy Stats to Clipboard", function()
    local e = os.clock() - sessionStart
    local timeStr = string.format("%dh %dm %ds", math.floor(e/3600), math.floor(e%3600/60), math.floor(e%60))
    local lines = {
        "=== ShinyHub Stats ===",
        "Session: " .. timeStr,
        "Cash: " .. fmtNum(getCash()),
        "Cash/hr: " .. fmtNum(getCashPerHour()),
        "Lemons Clicked: " .. fmtNum(stats.clicks),
        "Items Bought: " .. fmtNum(stats.bought),
        "Earner Upgrades: " .. fmtNum(stats.upgrades),
        "Income Taps: " .. fmtNum(stats.income),
        "Rebirths: " .. stats.rebirths,
        "Evolves: " .. stats.evolves,
        "Ascends: " .. stats.ascends,
        "Drops: " .. fmtNum(stats.drops),
        "==================",
    }
    pcall(function() setclipboard(table.concat(lines, "\n")) end)
    showNotif("Stats copied to clipboard!", "success")
end)

mkSpacer("Stats", 3)
mkSection("Stats", "Server Info")

mkDualStat("Stats",
    "SERVER AGE", function()
        local age = game.Workspace.DistributedGameTime
        if age >= 3600 then return string.format("%dh %dm", math.floor(age/3600), math.floor(age%3600/60)) end
        return string.format("%dm %ds", math.floor(age/60), math.floor(age%60))
    end,
    "GAME ID", function()
        return tostring(game.JobId):sub(1, 8) .. "..."
    end
)

mkSpacer("Stats", 3)
mkSection("Stats", "Cash Leaderboard")

local leaderLabel = Instance.new("TextLabel")
leaderLabel.LayoutOrder = nxt("Stats")
leaderLabel.Size = UDim2.new(1, 0, 0, 14)
leaderLabel.BackgroundTransparency = 1
leaderLabel.Font = Enum.Font.Gotham
leaderLabel.TextSize = 10
leaderLabel.TextXAlignment = Enum.TextXAlignment.Left
leaderLabel.TextWrapped = true
leaderLabel.AutomaticSize = Enum.AutomaticSize.Y
leaderLabel.ZIndex = 2
leaderLabel.RichText = true
leaderLabel.Parent = tabPages.Stats
bnd(leaderLabel, {TextColor3 = "sub"})

table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        local entries = {}
        for _, player in Players:GetPlayers() do
            local ls = player:FindFirstChild("leaderstats")
            local cash = ls and ls:FindFirstChild("Cash")
            if cash then
                table.insert(entries, {name = player.Name, cash = cash.Value, isMe = player == LP})
            end
        end
        table.sort(entries, function(a, b) return a.cash > b.cash end)
        local lines = {}
        for i, e in ipairs(entries) do
            local prefix = e.isMe and "<b>" or ""
            local suffix = e.isMe and " (You)</b>" or ""
            local medal = i == 1 and "1st" or (i == 2 and "2nd" or (i == 3 and "3rd" or i .. "th"))
            table.insert(lines, "  " .. prefix .. medal .. " — " .. e.name .. ": " .. fmtNum(e.cash) .. suffix)
        end
        leaderLabel.Text = #lines > 0 and table.concat(lines, "\n") or "No players"
        leaderLabel.Size = UDim2.new(1, 0, 0, math.max(14, #lines * 14))
        task.wait(5)
    end
end))

mkSpacer("Stats", 3)
mkSection("Stats", "Tycoon Owners")

-- Dynamic list of tycoon owners
local ownerList = Instance.new("TextLabel")
ownerList.LayoutOrder = nxt("Stats")
ownerList.Size = UDim2.new(1, 0, 0, 14)
ownerList.BackgroundTransparency = 1
ownerList.Font = Enum.Font.Gotham
ownerList.TextSize = 10
ownerList.TextXAlignment = Enum.TextXAlignment.Left
ownerList.TextWrapped = true
ownerList.AutomaticSize = Enum.AutomaticSize.Y
ownerList.ZIndex = 2
ownerList.RichText = true
ownerList.Parent = tabPages.Stats
bnd(ownerList, {TextColor3 = "sub"})

table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        local lines = {}
        for i = 1, 10 do
            for _, f in game.Workspace:GetChildren() do
                if f.Name == "Tycoon" .. i and f:IsA("Folder") then
                    local o = f:FindFirstChild("Owner")
                    if o and o.Value and o.Value:IsA("Player") then
                        local isMe = o.Value == LP
                        local prefix = isMe and "<b>" or ""
                        local suffix = isMe and " (You)</b>" or ""
                        table.insert(lines, "  " .. prefix .. "#" .. i .. " — " .. o.Value.Name .. suffix)
                    end
                end
            end
        end
        ownerList.Text = table.concat(lines, "\n")
        ownerList.Size = UDim2.new(1, 0, 0, math.max(14, #lines * 14))
        task.wait(5)
    end
end))

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

mkToggle("Settings", "Super Speed", "WalkSpeed 150")
loop("Super Speed", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 150 end
    task.wait(0.5)
end)

local getCustomSpeed = mkSlider("Settings", "Custom Speed", 16, 500, 16, 1)
mkToggle("Settings", "Custom WalkSpeed", "Set your own speed")
loop("Custom WalkSpeed", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = getCustomSpeed() end
    task.wait(0.3)
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

mkToggle("Settings", "Noclip", "Walk through walls")

mkToggle("Settings", "Anti Void", "TP back if you fall below -200")
table.insert(threads, task.spawn(function()
    local safePos = CFrame.new(0, 50, 0)
    while getgenv().SL_RUNNING do
        if toggles["Anti Void"] then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if hrp.Position.Y > -100 then
                    safePos = hrp.CFrame
                elseif hrp.Position.Y < -200 then
                    hrp.CFrame = safePos
                    showNotif("Anti-Void: Saved you!", "warning")
                end
            end
        end
        task.wait(0.2)
    end
end))
table.insert(threads, task.spawn(function()
    RunS.Stepped:Connect(function()
        if toggles["Noclip"] and LP.Character then
            for _, part in LP.Character:GetDescendants() do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end))

mkSpacer("Settings", 2)
mkSection("Settings", "Exploits")

local getFlySpeedVal = mkSlider("Settings", "Fly Speed", 10, 300, 60, 5)

mkToggle("Settings", "Fly", "Press E to fly, Q to descend")
local flySpeed = 60
local flyBody = nil
local flyGyro = nil

local function startFly()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end

    flyBody = Instance.new("BodyVelocity")
    flyBody.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBody.Velocity = Vector3.new(0, 0, 0)
    flyBody.Parent = hrp

    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyGyro.D = 200
    flyGyro.P = 40000
    flyGyro.Parent = hrp
end

local function stopFly()
    if flyBody then flyBody:Destroy() flyBody = nil end
    if flyGyro then flyGyro:Destroy() flyGyro = nil end
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

table.insert(threads, task.spawn(function()
    local wasFlying = false
    while getgenv().SL_RUNNING do
        if toggles["Fly"] then
            if not wasFlying then startFly() wasFlying = true end
            local cam = game.Workspace.CurrentCamera
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp and flyBody and flyGyro then
                local dir = Vector3.new(0, 0, 0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.E) then dir = dir + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.Q) then dir = dir - Vector3.new(0, 1, 0) end
                if dir.Magnitude > 0 then dir = dir.Unit end
                flyBody.Velocity = dir * getFlySpeedVal()
                flyGyro.CFrame = cam.CFrame
            end
        else
            if wasFlying then stopFly() wasFlying = false end
        end
        task.wait(1/60)
    end
    if wasFlying then stopFly() end
end))

mkToggle("Settings", "Player ESP", "See players through walls")
local espGuis = {}
local function updateESP()
    for _, gui in ipairs(espGuis) do pcall(function() gui:Destroy() end) end
    espGuis = {}
    if not toggles["Player ESP"] then return end
    for _, player in Players:GetPlayers() do
        if player ~= LP and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local bb = Instance.new("BillboardGui")
                bb.Name = "SH_ESP"
                bb.Size = UDim2.new(0, 80, 0, 22)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true
                bb.Adornee = head
                bb.Parent = game.CoreGui

                local l = Instance.new("TextLabel")
                l.Size = UDim2.new(1, 0, 1, 0)
                l.BackgroundTransparency = 0.5
                l.BackgroundColor3 = C.bg
                l.Text = player.Name
                l.Font = Enum.Font.GothamBold
                l.TextSize = 10
                l.TextColor3 = C.accent
                l.Parent = bb
                Instance.new("UICorner", l).CornerRadius = UDim.new(0, 4)

                table.insert(espGuis, bb)
            end
        end
    end
end

table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        if toggles["Player ESP"] then updateESP() end
        task.wait(2)
    end
    for _, gui in ipairs(espGuis) do pcall(function() gui:Destroy() end) end
end))

-- Clean up ESP when toggled off
table.insert(togRefresh, function()
    if not toggles["Player ESP"] then
        for _, gui in ipairs(espGuis) do pcall(function() gui:Destroy() end) end
        espGuis = {}
    end
end)

mkToggle("Settings", "God Mode", "Speed + Jump + Noclip + Infinite Jump")
table.insert(togRefresh, function()
    if toggles["God Mode"] then
        toggles["Speed Boost"] = true
        toggles["Jump Boost"] = true
        toggles["Noclip"] = true
        toggles["Infinite Jump"] = true
    end
end)

mkToggle("Settings", "Click TP", "Hold Ctrl + Click to teleport")
local mouse = LP:GetMouse()
mouse.Button1Down:Connect(function()
    if toggles["Click TP"] and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and mouse.Hit then
            hrp.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
            showNotif("Click TP!", "info")
        end
    end
end)

mkToggle("Settings", "Speed Display", "Shows speed on screen")
local speedGui = Instance.new("TextLabel")
speedGui.Size = UDim2.new(0, 120, 0, 20)
speedGui.Position = UDim2.new(0.5, -60, 0, 5)
speedGui.BackgroundTransparency = 0.5
speedGui.BorderSizePixel = 0
speedGui.Font = Enum.Font.GothamBold
speedGui.TextSize = 11
speedGui.ZIndex = 50
speedGui.Visible = false
speedGui.Parent = Gui
bnd(speedGui, {BackgroundColor3 = "bg", TextColor3 = "text"})
Instance.new("UICorner", speedGui).CornerRadius = UDim.new(0, 6)

table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        if toggles["Speed Display"] then
            speedGui.Visible = true
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.AssemblyLinearVelocity or hrp.Velocity
                local speed = math.floor(Vector3.new(vel.X, 0, vel.Z).Magnitude)
                speedGui.Text = speed .. " studs/s"
            end
        else
            speedGui.Visible = false
        end
        task.wait(0.1)
    end
    speedGui.Visible = false
end))

mkSpacer("Settings", 2)
mkSection("Settings", "Camera & World")

local getFOV = mkSlider("Settings", "Field of View", 30, 120, 70, 1, function(v)
    pcall(function() game.Workspace.CurrentCamera.FieldOfView = v end)
end)

mkToggle("Settings", "Custom FOV", "Use the FOV slider above")
loop("Custom FOV", function()
    pcall(function() game.Workspace.CurrentCamera.FieldOfView = getFOV() end)
    task.wait(0.5)
end)
table.insert(togRefresh, function()
    if not toggles["Custom FOV"] then
        pcall(function() game.Workspace.CurrentCamera.FieldOfView = 70 end)
    end
end)

mkToggle("Settings", "Low Gravity", "Workspace gravity reduced to 50")
local savedGravity = nil
loop("Low Gravity", function()
    if not savedGravity then savedGravity = game.Workspace.Gravity end
    game.Workspace.Gravity = 50
    task.wait(0.5)
end)
table.insert(togRefresh, function()
    if not toggles["Low Gravity"] and savedGravity then
        game.Workspace.Gravity = savedGravity
    end
end)

mkToggle("Settings", "Zero Gravity", "Workspace gravity set to 0")
loop("Zero Gravity", function()
    if not savedGravity then savedGravity = game.Workspace.Gravity end
    game.Workspace.Gravity = 0
    task.wait(0.5)
end)
table.insert(togRefresh, function()
    if not toggles["Zero Gravity"] and not toggles["Low Gravity"] and savedGravity then
        game.Workspace.Gravity = savedGravity
    end
end)

mkToggle("Settings", "Hide Character", "Makes you invisible locally")
loop("Hide Character", function()
    local char = LP.Character
    if char then
        for _, p in char:GetDescendants() do
            if p:IsA("BasePart") or p:IsA("Decal") then
                p.Transparency = 1
            end
        end
    end
    task.wait(0.5)
end)
table.insert(togRefresh, function()
    if not toggles["Hide Character"] then
        local char = LP.Character
        if char then
            for _, p in char:GetDescendants() do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.Transparency = 0
                elseif p:IsA("Decal") then
                    p.Transparency = 0
                end
            end
        end
    end
end)

mkToggle("Settings", "Auto Respawn", "Respawns instantly on death")
table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        if toggles["Auto Respawn"] then
            local char = LP.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    LP:LoadCharacter()
                    task.wait(1)
                end
            end
        end
        task.wait(0.3)
    end
end))

mkToggle("Settings", "Freeze", "Anchors your HumanoidRootPart")
loop("Freeze", function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end
    task.wait(0.3)
end)
table.insert(togRefresh, function()
    if not toggles["Freeze"] then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = false end
    end
end)

mkToggle("Settings", "Big Head", "Makes your head huge")
loop("Big Head", function()
    local head = LP.Character and LP.Character:FindFirstChild("Head")
    if head then
        head.Size = Vector3.new(4, 3, 3)
        local mesh = head:FindFirstChildOfClass("SpecialMesh")
        if mesh then mesh.Scale = Vector3.new(2.25, 2.25, 2.25) end
    end
    task.wait(0.5)
end)
table.insert(togRefresh, function()
    if not toggles["Big Head"] then
        local head = LP.Character and LP.Character:FindFirstChild("Head")
        if head then
            head.Size = Vector3.new(2, 1, 1)
            local mesh = head:FindFirstChildOfClass("SpecialMesh")
            if mesh then mesh.Scale = Vector3.new(1.25, 1.25, 1.25) end
        end
    end
end)

mkToggle("Settings", "Tiny Character", "Shrinks your character")
loop("Tiny Character", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            local bd = hum:FindFirstChildOfClass("HumanoidDescription")
            if bd then
                bd.HeightScale = 0.3
                bd.WidthScale = 0.3
                bd.DepthScale = 0.3
                bd.HeadScale = 0.3
                hum:ApplyDescription(bd)
            end
        end)
    end
    task.wait(2)
end)

mkToggle("Settings", "Spin", "Continuously rotates your character")
table.insert(threads, task.spawn(function()
    while getgenv().SL_RUNNING do
        if toggles["Spin"] then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(15), 0)
            end
            task.wait(1/30)
        else
            task.wait(0.3)
        end
    end
end))

mkSpacer("Settings", 2)
mkSection("Settings", "Visuals")

mkToggle("Settings", "XRay", "Makes walls transparent")
local xrayOriginals = {}
loop("XRay", function()
    for _, part in game.Workspace:GetDescendants() do
        if part:IsA("BasePart") and not part:IsDescendantOf(LP.Character or game) then
            if not xrayOriginals[part] then
                xrayOriginals[part] = part.Transparency
            end
            if part.Transparency < 0.7 then
                part.Transparency = 0.7
            end
        end
    end
    task.wait(2)
end)
table.insert(togRefresh, function()
    if not toggles["XRay"] then
        for part, orig in pairs(xrayOriginals) do
            pcall(function() part.Transparency = orig end)
        end
        xrayOriginals = {}
    end
end)

mkToggle("Settings", "Night Mode", "Sets game to nighttime")
loop("Night Mode", function()
    local L = game:GetService("Lighting")
    L.ClockTime = 0
    L.Brightness = 0.5
    L.Ambient = Color3.fromRGB(40, 40, 60)
    task.wait(1)
end)
table.insert(togRefresh, function()
    if not toggles["Night Mode"] and savedLighting then
        local L = game:GetService("Lighting")
        pcall(function()
            L.ClockTime = savedLighting.ClockTime
            L.Brightness = savedLighting.Brightness
            L.Ambient = savedLighting.Ambient
        end)
    end
end)

mkToggle("Settings", "Fullbright", "Removes darkness & fog")
local savedLighting = nil
loop("Fullbright", function()
    local L = game:GetService("Lighting")
    if not savedLighting then
        savedLighting = {
            Brightness = L.Brightness,
            ClockTime = L.ClockTime,
            FogEnd = L.FogEnd,
            GlobalShadows = L.GlobalShadows,
            Ambient = L.Ambient,
        }
    end
    L.Brightness = 2
    L.ClockTime = 14
    L.FogEnd = 100000
    L.GlobalShadows = false
    L.Ambient = Color3.fromRGB(178, 178, 178)
    task.wait(1)
end)

table.insert(threads, task.spawn(function()
    local wasOn = false
    while getgenv().SL_RUNNING do
        if wasOn and not toggles["Fullbright"] and savedLighting then
            local L = game:GetService("Lighting")
            pcall(function()
                L.Brightness = savedLighting.Brightness
                L.ClockTime = savedLighting.ClockTime
                L.FogEnd = savedLighting.FogEnd
                L.GlobalShadows = savedLighting.GlobalShadows
                L.Ambient = savedLighting.Ambient
            end)
        end
        wasOn = toggles["Fullbright"]
        task.wait(0.3)
    end
end))

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

mkButton("Settings", "Server Hop", function()
    showNotif("Finding new server...")
    task.spawn(function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local ok, servers = pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=10"
            return Http:JSONDecode(game:HttpGet(url))
        end)
        if ok and servers and servers.data then
            for _, sv in ipairs(servers.data) do
                if sv.playing and sv.maxPlayers and sv.playing < sv.maxPlayers and sv.id ~= game.JobId then
                    TPS:TeleportToPlaceInstance(game.PlaceId, sv.id, LP)
                    return
                end
            end
        end
        showNotif("No servers found, rejoining...")
        TPS:Teleport(game.PlaceId, LP)
    end)
end)

mkToggle("Settings", "Auto Rejoin", "Rejoins server if kicked")
table.insert(threads, task.spawn(function()
    local GCE = game:GetService("GuiService")
    pcall(function()
        GCE.ErrorMessageChanged:Connect(function()
            if toggles["Auto Rejoin"] then
                task.wait(3)
                pcall(function()
                    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
                end)
            end
        end)
    end)
end))

mkSpacer("Settings", 6)
mkSection("Settings", "Themes")

for _, theme in ipairs(Themes) do
    local b = Instance.new("TextButton")
    b.LayoutOrder = nxt("Settings")
    b.Size = UDim2.new(1, 0, 0, 26)
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
    dotStrk.Transparency = 0.6
    dotStrk.Color = theme.accent
    dotStrk.Parent = dot

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -36, 1, 0)
    l.Position = UDim2.new(0, 30, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = theme.name
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = b
    bnd(l, {TextColor3 = "sub"})

    b.MouseButton1Click:Connect(function()
        C = theme
        getgenv().SL_THEME = theme.name
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

mkSpacer("Settings", 4)
mkSection("Settings", "Special")

mkToggle("Settings", "Rainbow Mode", "Cycles accent color automatically")
table.insert(threads, task.spawn(function()
    local hue = 0
    while getgenv().SL_RUNNING do
        if toggles["Rainbow Mode"] then
            hue = (hue + 0.005) % 1
            local col = Color3.fromHSV(hue, 0.8, 1)
            C.accent = col
            C.on = col
            C.dot = col
            StatusDot.BackgroundColor3 = col
            AccentLine.BackgroundColor3 = col
            SideIndicator.BackgroundColor3 = col
            ActiveBadge.TextColor3 = col
            ActiveBadge.BackgroundColor3 = col
            for _, fn in ipairs(togRefresh) do pcall(fn) end
            task.wait(0.03)
        else
            task.wait(0.3)
        end
    end
end))

mkSpacer("Settings", 4)
mkSection("Settings", "UI")

mkToggle("Settings", "Compact Mode", "Smaller window for less screen blocking")
table.insert(togRefresh, function()
    if toggles["Compact Mode"] then
        if not isMinimized then
            tw(Main, {Size = UDim2.new(0, WIN_W - 80, 0, WIN_H - 80)}, 0.3, Enum.EasingStyle.Back)
        end
    else
        if not isMinimized then
            tw(Main, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.3, Enum.EasingStyle.Back)
        end
    end
end)

mkToggle("Settings", "Always On Top", "Keeps UI above game elements")
table.insert(togRefresh, function()
    Gui.DisplayOrder = toggles["Always On Top"] and 999 or 0
end)

mkToggle("Settings", "Sparkle Effect", "Adds sparkles to your character")
local sparkleEffect = nil
table.insert(togRefresh, function()
    if toggles["Sparkle Effect"] then
        if not sparkleEffect then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                sparkleEffect = Instance.new("Sparkles")
                sparkleEffect.Name = "SH_Sparkle"
                sparkleEffect.SparkleColor = C.accent
                sparkleEffect.Parent = hrp
            end
        end
    else
        if sparkleEffect then sparkleEffect:Destroy() sparkleEffect = nil end
    end
end)

mkToggle("Settings", "Fire Effect", "Adds fire to your character")
local fireEffect = nil
table.insert(togRefresh, function()
    if toggles["Fire Effect"] then
        if not fireEffect then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                fireEffect = Instance.new("Fire")
                fireEffect.Name = "SH_Fire"
                fireEffect.Size = 5
                fireEffect.Heat = 10
                fireEffect.Color = C.accent
                fireEffect.SecondaryColor = Color3.fromRGB(255, 200, 50)
                fireEffect.Parent = hrp
            end
        end
    else
        if fireEffect then fireEffect:Destroy() fireEffect = nil end
    end
end)

mkToggle("Settings", "Smoke Effect", "Adds smoke trail to character")
local smokeEffect = nil
table.insert(togRefresh, function()
    if toggles["Smoke Effect"] then
        if not smokeEffect then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                smokeEffect = Instance.new("Smoke")
                smokeEffect.Name = "SH_Smoke"
                smokeEffect.Size = 3
                smokeEffect.Opacity = 0.3
                smokeEffect.Color = C.accent
                smokeEffect.Parent = hrp
            end
        end
    else
        if smokeEffect then smokeEffect:Destroy() smokeEffect = nil end
    end
end)

mkSpacer("Settings", 6)
mkSection("Settings", "About")

local creditsFrame = Instance.new("Frame")
creditsFrame.LayoutOrder = nxt("Settings")
creditsFrame.Size = UDim2.new(1, 0, 0, 60)
creditsFrame.BorderSizePixel = 0
creditsFrame.ZIndex = 2
creditsFrame.Parent = tabPages.Settings
bnd(creditsFrame, {BackgroundColor3 = "card"})
Instance.new("UICorner", creditsFrame).CornerRadius = UDim.new(0, 8)

local creditsTitle = Instance.new("TextLabel")
creditsTitle.Size = UDim2.new(1, -20, 0, 16)
creditsTitle.Position = UDim2.new(0, 14, 0, 6)
creditsTitle.BackgroundTransparency = 1
creditsTitle.Text = "ShinyHub v6.0 — Ultimate Edition"
creditsTitle.Font = Enum.Font.GothamBlack
creditsTitle.TextSize = 11
creditsTitle.TextXAlignment = Enum.TextXAlignment.Left
creditsTitle.ZIndex = 3
creditsTitle.Parent = creditsFrame
bnd(creditsTitle, {TextColor3 = "accent"})

local creditsSub = Instance.new("TextLabel")
creditsSub.Size = UDim2.new(1, -20, 0, 30)
creditsSub.Position = UDim2.new(0, 14, 0, 24)
creditsSub.BackgroundTransparency = 1
creditsSub.Text = "Universal script hub for Roblox\nMade by ShinyHub Team"
creditsSub.Font = Enum.Font.Gotham
creditsSub.TextSize = 9
creditsSub.TextXAlignment = Enum.TextXAlignment.Left
creditsSub.TextWrapped = true
creditsSub.ZIndex = 3
creditsSub.Parent = creditsFrame
bnd(creditsSub, {TextColor3 = "dim"})

--------------------------------------------------------------
-- CASH TRACKING (for accurate cash/hr)
--------------------------------------------------------------
local cashHistory = {}
local lastMilestone = 0

local milestones = {1e3, 5e3, 1e4, 5e4, 1e5, 2.5e5, 5e5, 1e6, 5e6, 1e7, 5e7, 1e8, 5e8, 1e9, 5e9, 1e10, 1e11, 1e12, 1e13, 1e14, 1e15}

table.insert(threads, task.spawn(function()
    lastMilestone = getCash()
    while getgenv().SL_RUNNING do
        local cash = getCash()
        table.insert(cashHistory, {time = os.clock(), cash = cash})
        if #cashHistory > 120 then table.remove(cashHistory, 1) end

        for _, m in ipairs(milestones) do
            if cash >= m and lastMilestone < m then
                showNotif("MILESTONE: " .. fmtNum(m) .. " cash!", "success")
                lastMilestone = cash
                break
            end
        end
        lastMilestone = cash
        task.wait(30)
    end
end))

local function getCashPerHour()
    if #cashHistory < 2 then return 0 end
    local oldest = cashHistory[1]
    local newest = cashHistory[#cashHistory]
    local elapsed = newest.time - oldest.time
    if elapsed < 30 then return 0 end
    local earned = newest.cash - oldest.cash
    return math.max(0, (earned / elapsed) * 3600)
end

--------------------------------------------------------------
-- RESPAWN HANDLER (re-applies effects)
--------------------------------------------------------------
LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    sparkleEffect = nil
    fireEffect = nil
    smokeEffect = nil
    for _, fn in ipairs(togRefresh) do pcall(fn) end
    showNotif("Respawned — effects reapplied", "info")
end)

--------------------------------------------------------------
-- CHAT COMMANDS
--------------------------------------------------------------
pcall(function()
    LP.Chatted:Connect(function(msg)
        local lower = msg:lower()
        if lower:sub(1, 6) == "!speed" then
            local num = tonumber(lower:sub(7))
            if num then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = num end
                showNotif("Speed set to " .. num, "success")
            end
        elseif lower:sub(1, 5) == "!jump" then
            local num = tonumber(lower:sub(6))
            if num then
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = num end
                showNotif("Jump set to " .. num, "success")
            end
        elseif lower:sub(1, 4) == "!fov" then
            local num = tonumber(lower:sub(5))
            if num then
                pcall(function() game.Workspace.CurrentCamera.FieldOfView = math.clamp(num, 1, 120) end)
                showNotif("FOV set to " .. num, "success")
            end
        elseif lower == "!afk" then
            for k, _ in pairs(toggles) do toggles[k] = false end
            for _, name in ipairs({"Auto Buy Items", "Auto Click Income", "Auto Upgrade Earners", "Auto Collect Fruit", "Auto Collect Drops", "Auto Phone Offer", "Auto Toggle Conveyors", "Auto Rebirth", "Auto Evolve", "Auto Ascend", "Auto Upgrade Power"}) do
                toggles[name] = true
            end
            for _, fn in ipairs(togRefresh) do pcall(fn) end
            showNotif("AFK Mode activated via chat", "success")
        elseif lower == "!off" then
            for k, _ in pairs(toggles) do toggles[k] = false end
            for _, fn in ipairs(togRefresh) do pcall(fn) end
            showNotif("All features disabled via chat", "warning")
        elseif lower == "!help" or lower == "!cmds" then
            showNotif("Commands: !speed N, !jump N, !fov N, !afk, !off", "info")
        elseif lower:sub(1, 3) == "!tp" then
            local target = lower:sub(4):match("^%s*(.+)%s*$")
            if target then
                for _, p in Players:GetPlayers() do
                    if p.Name:lower():find(target) and p ~= LP then
                        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        local tHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and tHRP then
                            hrp.CFrame = tHRP.CFrame + Vector3.new(0, 3, 0)
                            showNotif("TP: " .. p.Name, "info")
                        end
                        break
                    end
                end
            end
        end
    end)
end)

--------------------------------------------------------------
-- ENTRANCE ANIMATION
--------------------------------------------------------------
Main.BackgroundTransparency = 1
Main.Size = UDim2.new(0, WIN_W, 0, 0)
Strk.Transparency = 1

-- Hide sidebar elements for stagger
for _, t in pairs(tabBtns) do
    t.lbl.TextTransparency = 1
    t.btn.BackgroundTransparency = 1
    if t.icon then t.icon.TextTransparency = 1 end
end
SideIndicator.BackgroundTransparency = 1
VerLbl.TextTransparency = 1
KeyLbl.TextTransparency = 1
PageTitle.TextTransparency = 1
PageSub.TextTransparency = 1

task.delay(0.05, function()
    tw(Main, {Size = UDim2.new(0, WIN_W, 0, WIN_H), BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Back)
    tw(Strk, {Transparency = 0.5}, 0.6)

    -- Stagger sidebar items
    task.delay(0.3, function()
        for i, name in ipairs(tabNames) do
            task.delay((i - 1) * 0.06, function()
                local t = tabBtns[name]
                tw(t.lbl, {TextTransparency = 0}, 0.3)
                if t.icon then tw(t.icon, {TextTransparency = 0}, 0.3) end
            end)
        end
        task.delay(0.4, function()
            tw(SideIndicator, {BackgroundTransparency = 0}, 0.3)
            tw(VerLbl, {TextTransparency = 0}, 0.3)
            tw(KeyLbl, {TextTransparency = 0}, 0.3)
        end)
        task.delay(0.2, function()
            tw(PageTitle, {TextTransparency = 0}, 0.3)
            tw(PageSub, {TextTransparency = 0}, 0.3)
        end)
    end)
end)

switchTab("Home")

-- Startup notifications
task.delay(1.2, function()
    showNotif("ShinyHub v6.0 loaded", "success")
    task.delay(0.5, function()
        showNotif("Anti-AFK active", "info")
        task.delay(0.5, function()
            showNotif("Keys: 1-6 tabs | \\ panic", "info")
            task.delay(0.5, function()
                showNotif(countActive() .. " features ready")
            end)
        end)
    end)
end)
