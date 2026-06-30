--[[
    ShinyHub — Sell Lemons 🍋 v2
    Clean horizontal-tab UI with hover effects & animations
]]

if game.CoreGui:FindFirstChild("SLHub") then game.CoreGui:FindFirstChild("SLHub"):Destroy() end
if getgenv().SL_RUNNING then getgenv().SL_RUNNING = false task.wait(0.3) end
getgenv().SL_RUNNING = true

local Players = game:GetService("Players")
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local LP      = Players.LocalPlayer

--------------------------------------------------------------
-- FIND PLAYER'S TYCOON
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

local areaNames = {
    "Lemon Stand", "Lemon Trading", "Lemon Depot", "Lemon Labs",
    "LemonDash", "Lemon Robotics", "Lemon Republic", "LemonX",
}

local locationRenames = {
    XVoidPortalExit = "Void Exit",
    SpaceRocket = "Space Rocket",
    SpaceFall = "Space Fall",
    SpaceReturn = "Space Return",
    LemonDash = "Lemon Dash",
    MinigameRace = "Minigame Race",
}

--------------------------------------------------------------
-- THEME
--------------------------------------------------------------
local Themes = {
    {name="Lemon",    accent=Color3.fromRGB(255,210,40),  bg=Color3.fromRGB(15,14,10),  card=Color3.fromRGB(26,25,17), cardH=Color3.fromRGB(38,36,22), tabBg=Color3.fromRGB(20,19,13), tabActive=Color3.fromRGB(255,210,40), border=Color3.fromRGB(55,50,22), text=Color3.fromRGB(250,248,235), sub=Color3.fromRGB(160,155,110), dim=Color3.fromRGB(100,96,58), on=Color3.fromRGB(255,210,40), off=Color3.fromRGB(42,40,24), knobOn=Color3.fromRGB(25,23,8), knobOff=Color3.fromRGB(200,200,200)},
    {name="Midnight", accent=Color3.fromRGB(130,80,255),  bg=Color3.fromRGB(12,12,20),  card=Color3.fromRGB(22,22,35), cardH=Color3.fromRGB(32,32,50), tabBg=Color3.fromRGB(16,16,26), tabActive=Color3.fromRGB(130,80,255), border=Color3.fromRGB(40,36,62), text=Color3.fromRGB(235,235,245), sub=Color3.fromRGB(130,130,160), dim=Color3.fromRGB(72,72,100), on=Color3.fromRGB(130,80,255), off=Color3.fromRGB(40,40,58), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(200,200,200)},
    {name="Ocean",    accent=Color3.fromRGB(45,140,255),  bg=Color3.fromRGB(8,12,22),   card=Color3.fromRGB(16,24,40), cardH=Color3.fromRGB(26,36,56), tabBg=Color3.fromRGB(12,16,28), tabActive=Color3.fromRGB(45,140,255), border=Color3.fromRGB(30,48,78), text=Color3.fromRGB(225,235,250), sub=Color3.fromRGB(110,135,170), dim=Color3.fromRGB(58,82,115), on=Color3.fromRGB(45,140,255), off=Color3.fromRGB(26,38,56), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(200,200,200)},
    {name="Lime",     accent=Color3.fromRGB(100,220,60),  bg=Color3.fromRGB(10,14,9),   card=Color3.fromRGB(20,28,16), cardH=Color3.fromRGB(30,42,24), tabBg=Color3.fromRGB(14,20,12), tabActive=Color3.fromRGB(100,220,60), border=Color3.fromRGB(38,58,28), text=Color3.fromRGB(240,250,235), sub=Color3.fromRGB(130,165,115), dim=Color3.fromRGB(75,105,58), on=Color3.fromRGB(100,220,60), off=Color3.fromRGB(30,44,22), knobOn=Color3.fromRGB(18,28,10), knobOff=Color3.fromRGB(200,200,200)},
    {name="Sakura",   accent=Color3.fromRGB(240,120,170), bg=Color3.fromRGB(20,12,18),  card=Color3.fromRGB(36,24,32), cardH=Color3.fromRGB(50,34,44), tabBg=Color3.fromRGB(26,16,22), tabActive=Color3.fromRGB(240,120,170), border=Color3.fromRGB(70,44,58), text=Color3.fromRGB(250,235,242), sub=Color3.fromRGB(175,130,150), dim=Color3.fromRGB(110,78,96), on=Color3.fromRGB(240,120,170), off=Color3.fromRGB(50,34,42), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(200,200,200)},
}

local C = Themes[1]
local binds = {}
local togRefresh = {}

local function tw(o, p, d, style, dir)
    TS:Create(o, TweenInfo.new(d or 0.22, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), p):Play()
end
local function twBack(o, p, d)
    TS:Create(o, TweenInfo.new(d or 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), p):Play()
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
local stats = {clicks = 0, bought = 0, upgrades = 0, rebirths = 0}

local function loop(key, fn)
    table.insert(threads, task.spawn(function()
        while getgenv().SL_RUNNING do
            if toggles[key] then pcall(fn) else task.wait(0.3) end
        end
    end))
end

--------------------------------------------------------------
-- GUI
--------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "SLHub"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = game.CoreGui

-- Shadow behind main window
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(0, 510, 0, 390)
Shadow.Position = UDim2.new(0.5, -255, 0.5, -195)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.ZIndex = 0
Shadow.Parent = Gui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 470, 0, 350)
Main.Position = UDim2.new(0.5, -235, 0.5, -175)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui
bnd(Main, {BackgroundColor3 = "bg"})
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local Strk = Instance.new("UIStroke")
Strk.Thickness = 1
Strk.Transparency = 0.5
Strk.Parent = Main
bnd(Strk, {Color = "border"})

--------------------------------------------------------------
-- TITLE BAR
--------------------------------------------------------------
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 10
TitleBar.Parent = Main
bnd(TitleBar, {BackgroundColor3 = "tabBg"})

-- Accent line under title
local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 1)
AccentLine.Position = UDim2.new(0, 0, 1, -1)
AccentLine.BorderSizePixel = 0
AccentLine.BackgroundTransparency = 0.7
AccentLine.ZIndex = 10
AccentLine.Parent = TitleBar
bnd(AccentLine, {BackgroundColor3 = "accent"})

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0, 200, 1, 0)
TitleLbl.Position = UDim2.new(0, 16, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "\xF0\x9F\x8D\x8B  Sell Lemons"
TitleLbl.Font = Enum.Font.GothamBlack
TitleLbl.TextSize = 14
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 11
TitleLbl.Parent = TitleBar
bnd(TitleLbl, {TextColor3 = "accent"})

local VerLbl = Instance.new("TextLabel")
VerLbl.Size = UDim2.new(0, 30, 0, 14)
VerLbl.Position = UDim2.new(0, 152, 0.5, -7)
VerLbl.BackgroundTransparency = 1
VerLbl.Text = "v2"
VerLbl.Font = Enum.Font.Gotham
VerLbl.TextSize = 9
VerLbl.ZIndex = 11
VerLbl.TextXAlignment = Enum.TextXAlignment.Left
VerLbl.Parent = TitleBar
bnd(VerLbl, {TextColor3 = "dim"})

-- Window buttons
local function mkWinBtn(text, posX, color, hoverColor, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 24, 0, 24)
    b.Position = UDim2.new(1, posX, 0.5, -12)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = text == "X" and 11 or 14
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.2
    b.BorderSizePixel = 0
    b.ZIndex = 12
    b.AutoButtonColor = false
    b.Parent = TitleBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseEnter:Connect(function()
        tw(b, {BackgroundColor3 = hoverColor, BackgroundTransparency = 0, Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, posX - 1, 0.5, -13)}, 0.15)
    end)
    b.MouseLeave:Connect(function()
        tw(b, {BackgroundColor3 = color, BackgroundTransparency = 0.2, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, posX, 0.5, -12)}, 0.15)
    end)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- Popup
local Popup = Instance.new("Frame")
Popup.Size = UDim2.new(0, 185, 0, 32)
Popup.Position = UDim2.new(1, -195, 1, -46)
Popup.BackgroundTransparency = 1
Popup.BorderSizePixel = 0
Popup.ZIndex = 50
Popup.Visible = false
Popup.Parent = Gui
bnd(Popup, {BackgroundColor3 = "card"})
Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 12)

local PopupStrk = Instance.new("UIStroke")
PopupStrk.Thickness = 1
PopupStrk.Transparency = 0.6
PopupStrk.Parent = Popup
bnd(PopupStrk, {Color = "accent"})

local PopupLbl = Instance.new("TextLabel")
PopupLbl.Size = UDim2.new(1, 0, 1, 0)
PopupLbl.BackgroundTransparency = 1
PopupLbl.Text = "RightShift to open"
PopupLbl.Font = Enum.Font.GothamBold
PopupLbl.TextSize = 11
PopupLbl.ZIndex = 51
PopupLbl.TextTransparency = 1
PopupLbl.Parent = Popup
bnd(PopupLbl, {TextColor3 = "accent"})

local popT
local function showPopup()
    if popT then pcall(task.cancel, popT) end
    Popup.Visible = true
    Popup.BackgroundTransparency = 1
    PopupLbl.TextTransparency = 1
    Popup.Position = UDim2.new(1, -195, 1, -16)
    twBack(Popup, {BackgroundTransparency = 0.08, Position = UDim2.new(1, -195, 1, -46)}, 0.4)
    tw(PopupLbl, {TextTransparency = 0}, 0.35)
    popT = task.spawn(function()
        task.wait(3)
        tw(Popup, {BackgroundTransparency = 1, Position = UDim2.new(1, -195, 1, -16)}, 0.45)
        tw(PopupLbl, {TextTransparency = 1}, 0.4)
        task.wait(0.5)
        Popup.Visible = false
    end)
end

local function minimizeHub()
    tw(Main, {Size = UDim2.new(0, 470, 0, 0), BackgroundTransparency = 1}, 0.3)
    tw(Shadow, {ImageTransparency = 1}, 0.3)
    task.delay(0.3, function() Main.Visible = false Shadow.Visible = false showPopup() end)
end

local function openHub()
    Main.Visible = true
    Shadow.Visible = true
    Main.Size = UDim2.new(0, 470, 0, 0)
    Main.BackgroundTransparency = 1
    Shadow.ImageTransparency = 1
    tw(Main, {Size = UDim2.new(0, 470, 0, 350), BackgroundTransparency = 0}, 0.4)
    tw(Shadow, {ImageTransparency = 0.5}, 0.4)
end

mkWinBtn("\xE2\x80\x94", -58, C.card, C.cardH, minimizeHub)
mkWinBtn("X", -28, Color3.fromRGB(180, 45, 50), Color3.fromRGB(220, 55, 60), function()
    getgenv().SL_RUNNING = false
    task.wait(0.15)
    for _, t in ipairs(threads) do pcall(task.cancel, t) end
    Gui:Destroy()
end)

--------------------------------------------------------------
-- HORIZONTAL TAB BAR
--------------------------------------------------------------
local TAB_H = 32
local tabNames = {"Overview", "Auto", "Rebirth", "Teleport", "Player"}

local TabStrip = Instance.new("Frame")
TabStrip.Size = UDim2.new(1, 0, 0, TAB_H)
TabStrip.Position = UDim2.new(0, 0, 0, 38)
TabStrip.BorderSizePixel = 0
TabStrip.ZIndex = 8
TabStrip.Parent = Main
bnd(TabStrip, {BackgroundColor3 = "bg"})

local TabStripBorder = Instance.new("Frame")
TabStripBorder.Size = UDim2.new(1, 0, 0, 1)
TabStripBorder.Position = UDim2.new(0, 0, 1, -1)
TabStripBorder.BorderSizePixel = 0
TabStripBorder.BackgroundTransparency = 0.5
TabStripBorder.ZIndex = 8
TabStripBorder.Parent = TabStrip
bnd(TabStripBorder, {BackgroundColor3 = "border"})

-- Sliding indicator pill
local tabW = 1 / #tabNames
local Indicator = Instance.new("Frame")
Indicator.Size = UDim2.new(tabW, -20, 0, 3)
Indicator.Position = UDim2.new(0, 10, 1, -3)
Indicator.BorderSizePixel = 0
Indicator.ZIndex = 9
Indicator.Parent = TabStrip
bnd(Indicator, {BackgroundColor3 = "accent"})
Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

local tabBtns = {}
local tabPages = {}
local activeTab = nil

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(tabW, 0, 1, -2)
    btn.Position = UDim2.new(tabW * (i - 1), 0, 0, 0)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 1
    btn.ZIndex = 9
    btn.AutoButtonColor = false
    btn.Parent = TabStrip
    bnd(btn, {TextColor3 = "dim"})

    btn.MouseEnter:Connect(function()
        if activeTab ~= name then tw(btn, {TextColor3 = C.sub}, 0.12) end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= name then tw(btn, {TextColor3 = C.dim}, 0.12) end
    end)

    tabBtns[name] = btn
end

--------------------------------------------------------------
-- CONTENT
--------------------------------------------------------------
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -(38 + TAB_H))
Content.Position = UDim2.new(0, 0, 0, 38 + TAB_H)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.ZIndex = 2
Content.Parent = Main

for _, name in ipairs(tabNames) do
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, -24, 1, -8)
    page.Position = UDim2.new(0, 14, 0, 4)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.BorderSizePixel = 0
    page.ZIndex = 2
    page.Parent = Content
    bnd(page, {ScrollBarImageColor3 = "accent"})

    local lay = Instance.new("UIListLayout", page)
    lay.Padding = UDim.new(0, 4)
    lay.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 8)

    tabPages[name] = page
end

local function switchTab(name)
    activeTab = name
    for n, p in pairs(tabPages) do p.Visible = (n == name) end
    for n, b in pairs(tabBtns) do
        tw(b, {TextColor3 = n == name and C.accent or C.dim}, 0.25)
    end
    local idx = table.find(tabNames, name) or 1
    tw(Indicator, {
        Position = UDim2.new(tabW * (idx - 1), 10, 1, -3),
        Size = UDim2.new(tabW, -20, 0, 3)
    }, 0.3, Enum.EasingStyle.Back)
end

for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

--------------------------------------------------------------
-- DRAG
--------------------------------------------------------------
local dragging, dragSt, dragPos
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragSt = i.Position; dragPos = Main.Position
    end
end)
TitleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragSt
        local newPos = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + d.X, dragPos.Y.Scale, dragPos.Y.Offset + d.Y)
        Main.Position = newPos
        Shadow.Position = UDim2.new(0, newPos.X.Offset + Main.Size.X.Offset/2 - 255, 0, newPos.Y.Offset + Main.Size.Y.Offset/2 - 195)
    end
end)

-- Resize
local Rsz = Instance.new("TextButton")
Rsz.Size = UDim2.new(0, 12, 0, 12)
Rsz.Position = UDim2.new(1, -14, 1, -14)
Rsz.Text = ""
Rsz.BackgroundTransparency = 0.6
Rsz.BorderSizePixel = 0
Rsz.ZIndex = 10
Rsz.Parent = Main
bnd(Rsz, {BackgroundColor3 = "dim"})
Instance.new("UICorner", Rsz).CornerRadius = UDim.new(0, 3)

Rsz.MouseEnter:Connect(function() tw(Rsz, {BackgroundTransparency = 0.2}, 0.12) end)
Rsz.MouseLeave:Connect(function() tw(Rsz, {BackgroundTransparency = 0.6}, 0.12) end)

local resizing, resSt, resSz
Rsz.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        resizing = true; resSt = i.Position; resSz = Main.Size
    end
end)
Rsz.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then resizing = false end
end)
UIS.InputChanged:Connect(function(i)
    if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - resSt
        Main.Size = UDim2.new(0, math.clamp(resSz.X.Offset + d.X, 380, 620), 0, math.clamp(resSz.Y.Offset + d.Y, 260, 520))
    end
end)

-- Keybind
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then minimizeHub() else openHub() end
    end
end)

--------------------------------------------------------------
-- UI FACTORIES
--------------------------------------------------------------
local ords = {}
for _, n in ipairs(tabNames) do ords[n] = 0 end
local function nxt(t) ords[t] = (ords[t] or 0) + 1 return ords[t] end

local function mkLabel(tab, txt, parent)
    local l = Instance.new("TextLabel")
    l.LayoutOrder = nxt(tab)
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = "  " .. txt
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 2
    l.Parent = parent or tabPages[tab]
    bnd(l, {TextColor3 = "accent"})
end

local function mkSpacer(tab, h, parent)
    local s = Instance.new("Frame")
    s.LayoutOrder = nxt(tab)
    s.Size = UDim2.new(1, 0, 0, h or 3)
    s.BackgroundTransparency = 1
    s.ZIndex = 2
    s.Parent = parent or tabPages[tab]
end

local function mkDivider(tab, parent)
    local d = Instance.new("Frame")
    d.LayoutOrder = nxt(tab)
    d.Size = UDim2.new(1, -20, 0, 1)
    d.Position = UDim2.new(0, 10, 0, 0)
    d.BackgroundTransparency = 0.6
    d.BorderSizePixel = 0
    d.ZIndex = 2
    d.Parent = parent or tabPages[tab]
    bnd(d, {BackgroundColor3 = "border"})
end

local function mkToggle(tab, name, cb, parent)
    toggles[name] = false
    local h = Instance.new("Frame")
    h.LayoutOrder = nxt(tab)
    h.Size = UDim2.new(1, 0, 0, 34)
    h.BorderSizePixel = 0
    h.ZIndex = 2
    h.Parent = parent or tabPages[tab]
    bnd(h, {BackgroundColor3 = "card"})
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 10)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -56, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = h
    bnd(l, {TextColor3 = "text"})

    local tr = Instance.new("TextButton")
    tr.Size = UDim2.new(0, 36, 0, 18)
    tr.Position = UDim2.new(1, -46, 0.5, -9)
    tr.Text = ""
    tr.BorderSizePixel = 0
    tr.ZIndex = 3
    tr.AutoButtonColor = false
    tr.Parent = h
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)

    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0, 14, 0, 14)
    kn.Position = UDim2.new(0, 2, 0.5, -7)
    kn.BackgroundColor3 = C.knobOff
    kn.BorderSizePixel = 0
    kn.ZIndex = 4
    kn.Parent = tr
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)

    local function ref()
        local on = toggles[name]
        tw(tr, {BackgroundColor3 = on and C.on or C.off}, 0.22)
        tw(kn, {
            Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = on and C.knobOn or C.knobOff
        }, 0.22)
    end
    ref()
    table.insert(togRefresh, ref)

    tr.MouseButton1Click:Connect(function()
        toggles[name] = not toggles[name]
        ref()
        if cb then cb(toggles[name]) end
    end)

    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            tw(h, {BackgroundColor3 = C.cardH}, 0.12)
            tw(l, {TextColor3 = C.accent}, 0.12)
        end
    end)
    h.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            tw(h, {BackgroundColor3 = C.card}, 0.15)
            tw(l, {TextColor3 = C.text}, 0.15)
        end
    end)
end

local function mkButton(tab, txt, cb, parent)
    local b = Instance.new("TextButton")
    b.LayoutOrder = nxt(tab)
    b.Size = UDim2.new(1, 0, 0, 30)
    b.Text = ""
    b.BorderSizePixel = 0
    b.ZIndex = 2
    b.AutoButtonColor = false
    b.Parent = parent or tabPages[tab]
    bnd(b, {BackgroundColor3 = "card"})
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = b
    bnd(l, {TextColor3 = "text"})

    -- Arrow indicator
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -28, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "\xE2\x80\xBA"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 16
    arrow.TextTransparency = 0.6
    arrow.ZIndex = 3
    arrow.Parent = b
    bnd(arrow, {TextColor3 = "sub"})

    b.MouseButton1Click:Connect(function()
        tw(b, {BackgroundColor3 = C.accent}, 0.06)
        tw(l, {TextColor3 = C.bg}, 0.06)
        task.delay(0.12, function()
            tw(b, {BackgroundColor3 = C.card}, 0.25)
            tw(l, {TextColor3 = C.text}, 0.25)
        end)
        if cb then cb() end
    end)
    b.MouseEnter:Connect(function()
        tw(b, {BackgroundColor3 = C.cardH}, 0.12)
        tw(arrow, {TextTransparency = 0, Position = UDim2.new(1, -24, 0, 0)}, 0.15)
    end)
    b.MouseLeave:Connect(function()
        tw(b, {BackgroundColor3 = C.card}, 0.15)
        tw(arrow, {TextTransparency = 0.6, Position = UDim2.new(1, -28, 0, 0)}, 0.15)
    end)
end

local function mkInfo(tab, fn, parent)
    local l = Instance.new("TextLabel")
    l.LayoutOrder = nxt(tab)
    l.Size = UDim2.new(1, 0, 0, 16)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 2
    l.Parent = parent or tabPages[tab]
    bnd(l, {TextColor3 = "sub"})
    l.Text = "    " .. fn()
    table.insert(threads, task.spawn(function()
        while getgenv().SL_RUNNING do l.Text = "    " .. fn() task.wait(1) end
    end))
end

--------------------------------------------------------------
-- TELEPORT
--------------------------------------------------------------
local function smartTP(locName)
    local loc = Locations:FindFirstChild(locName)
    if loc and loc:IsA("BasePart") then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = loc.CFrame + Vector3.new(0, 3, 0) end
    end
end

--------------------------------------------------------------
-- OVERVIEW TAB
--------------------------------------------------------------
mkLabel("Overview", "Session")
mkInfo("Overview", function()
    local ls = LP:FindFirstChild("leaderstats")
    local cash = ls and ls:FindFirstChild("Cash")
    return "Cash:  " .. (cash and tostring(cash.Value) or "---")
end)
mkInfo("Overview", function() return "Tycoon:  " .. myTycoon.Name end)
mkInfo("Overview", function()
    local e = os.clock() - sessionStart
    return string.format("Uptime:  %dm %ds", math.floor(e / 60), math.floor(e % 60))
end)

mkSpacer("Overview", 4)
mkDivider("Overview")
mkSpacer("Overview", 4)

mkLabel("Overview", "Stats")
mkInfo("Overview", function()
    return string.format("Lemons: %d    Bought: %d", stats.clicks, stats.bought)
end)
mkInfo("Overview", function()
    return string.format("Upgrades: %d    Rebirths: %d", stats.upgrades, stats.rebirths)
end)

mkSpacer("Overview", 4)
mkDivider("Overview")
mkSpacer("Overview", 4)

mkLabel("Overview", "Theme")
for _, theme in ipairs(Themes) do
    mkButton("Overview", theme.name, function()
        C = theme
        applyTheme()
    end)
end

--------------------------------------------------------------
-- AUTO TAB
--------------------------------------------------------------
mkLabel("Auto", "Farming")
mkToggle("Auto", "Auto Click Lemons")

loop("Auto Click Lemons", function()
    local trees = Constant:FindFirstChild("Trees")
    if not trees then task.wait(1) return end
    for _, tree in trees:GetChildren() do
        if not getgenv().SL_RUNNING or not toggles["Auto Click Lemons"] then return end
        for _, fruit in tree:GetChildren() do
            if fruit.Name == "Fruit" then
                local cp = fruit:FindFirstChild("ClickPart")
                if cp then
                    local cd = cp:FindFirstChild("ClickDetector")
                    if cd then
                        fireclickdetector(cd)
                        stats.clicks = stats.clicks + 1
                        task.wait(0.05)
                    end
                end
            end
        end
    end
    task.wait(0.1)
end)

mkSpacer("Auto", 4)
mkDivider("Auto")
mkSpacer("Auto", 4)

mkLabel("Auto", "Tycoon")
mkToggle("Auto", "Auto Buy Items")

loop("Auto Buy Items", function()
    for _, area in Purchases:GetChildren() do
        local buttons = area:FindFirstChild("Buttons")
        if buttons then
            local function scan(folder)
                for _, item in folder:GetChildren() do
                    if not getgenv().SL_RUNNING or not toggles["Auto Buy Items"] then return end
                    if item:IsA("Folder") then
                        scan(item)
                    elseif item:IsA("Model") and item:GetAttribute("Purchased") == false then
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

mkSpacer("Auto", 4)
mkDivider("Auto")
mkSpacer("Auto", 4)

mkLabel("Auto", "Earners")
mkToggle("Auto", "Auto Upgrade Earners")

loop("Auto Upgrade Earners", function()
    for _, areaName in ipairs(areaNames) do
        if not getgenv().SL_RUNNING or not toggles["Auto Upgrade Earners"] then return end
        local area = Purchases:FindFirstChild(areaName)
        if area then
            local m = area:FindFirstChild(areaName)
            if m then
                local inner = m:FindFirstChild(areaName)
                if inner then
                    local upg = inner:FindFirstChild("Upgrade")
                    if upg and upg:IsA("RemoteFunction") then
                        local ok = pcall(function() upg:InvokeServer(1) end)
                        if ok then stats.upgrades = stats.upgrades + 1 end
                    end
                end
            end
        end
        task.wait(0.1)
    end
    task.wait(0.3)
end)

--------------------------------------------------------------
-- REBIRTH TAB
--------------------------------------------------------------
mkLabel("Rebirth", "Progression")
mkToggle("Rebirth", "Auto Rebirth")
loop("Auto Rebirth", function()
    local ok = pcall(function() Remotes.Rebirth:InvokeServer() end)
    if ok then stats.rebirths = stats.rebirths + 1 end
    task.wait(1)
end)

mkToggle("Rebirth", "Auto Evolve")
loop("Auto Evolve", function()
    pcall(function() Remotes.Evolve:InvokeServer() end)
    task.wait(2)
end)

mkToggle("Rebirth", "Auto Ascend")
loop("Auto Ascend", function()
    pcall(function() Remotes.Ascend:InvokeServer() end)
    task.wait(3)
end)

mkSpacer("Rebirth", 4)
mkDivider("Rebirth")
mkSpacer("Rebirth", 4)

mkLabel("Rebirth", "Power")
mkToggle("Rebirth", "Auto Upgrade Power")
loop("Auto Upgrade Power", function()
    pcall(function() Remotes.UpgradePowerLevel:InvokeServer() end)
    task.wait(1)
end)

mkSpacer("Rebirth", 4)
mkDivider("Rebirth")
mkSpacer("Rebirth", 4)

mkLabel("Rebirth", "Boosts")
mkButton("Rebirth", "Collect Time Cash", function()
    pcall(function() Remotes.UseTimeCash:InvokeServer() end)
end)
mkButton("Rebirth", "Use Earner Boost", function()
    pcall(function() Remotes.UseEarnerBoost:InvokeServer() end)
end)

--------------------------------------------------------------
-- TELEPORT TAB
--------------------------------------------------------------
mkLabel("Teleport", "Tycoon Areas")

local sortedLocs = {}
for _, loc in Locations:GetChildren() do table.insert(sortedLocs, loc.Name) end
table.sort(sortedLocs)

for _, locName in ipairs(sortedLocs) do
    local display = locationRenames[locName] or locName
    mkButton("Teleport", display, function() smartTP(locName) end)
end

--------------------------------------------------------------
-- PLAYER TAB
--------------------------------------------------------------
mkLabel("Player", "Movement")
mkToggle("Player", "Speed Boost")
loop("Speed Boost", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 80 end
    task.wait(0.5)
end)

mkToggle("Player", "Jump Boost")
loop("Jump Boost", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 120 end
    task.wait(0.5)
end)

mkButton("Player", "Toggle Infinite Jump", function()
    if not getgenv().SL_INFJUMP then
        getgenv().SL_INFJUMP = true
        UIS.JumpRequest:Connect(function()
            if getgenv().SL_INFJUMP and LP.Character then
                local hum = LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    else
        getgenv().SL_INFJUMP = false
    end
end)

mkSpacer("Player", 4)
mkDivider("Player")
mkSpacer("Player", 4)

mkLabel("Player", "Actions")
mkButton("Player", "Reset Character", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end)
mkButton("Player", "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

--------------------------------------------------------------
-- ENTRANCE ANIMATION
--------------------------------------------------------------
Main.BackgroundTransparency = 1
Main.Size = UDim2.new(0, 470, 0, 0)
Shadow.ImageTransparency = 1
Strk.Transparency = 1

task.delay(0.05, function()
    tw(Main, {Size = UDim2.new(0, 470, 0, 350), BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Back)
    tw(Shadow, {ImageTransparency = 0.5}, 0.5)
    tw(Strk, {Transparency = 0.5}, 0.6)
end)

switchTab("Overview")
