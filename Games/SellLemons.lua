--[[
    ShinyHub — Sell Lemons 🍋 v3
    Left sidebar layout
]]

if game.CoreGui:FindFirstChild("SLHub") then game.CoreGui:FindFirstChild("SLHub"):Destroy() end
if getgenv().SL_RUNNING then getgenv().SL_RUNNING = false task.wait(0.3) end
getgenv().SL_RUNNING = true

local Players = game:GetService("Players")
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local LP      = Players.LocalPlayer

--------------------------------------------------------------
-- TYCOON
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
-- THEME
--------------------------------------------------------------
local Themes = {
    {name="Lemon",    dot=Color3.fromRGB(255,210,40),  accent=Color3.fromRGB(255,210,40),  bg=Color3.fromRGB(18,17,12),  card=Color3.fromRGB(26,25,17), cardH=Color3.fromRGB(36,34,22), sidebar=Color3.fromRGB(22,21,15), border=Color3.fromRGB(44,40,20), text=Color3.fromRGB(245,242,228), sub=Color3.fromRGB(140,136,100), dim=Color3.fromRGB(82,78,48), on=Color3.fromRGB(255,210,40), off=Color3.fromRGB(38,36,22), knobOn=Color3.fromRGB(28,26,10), knobOff=Color3.fromRGB(170,170,170), header=Color3.fromRGB(20,19,13)},
    {name="Midnight", dot=Color3.fromRGB(130,80,255),  accent=Color3.fromRGB(130,80,255),  bg=Color3.fromRGB(14,14,22),  card=Color3.fromRGB(23,23,34), cardH=Color3.fromRGB(32,32,48), sidebar=Color3.fromRGB(18,18,28), border=Color3.fromRGB(36,34,54), text=Color3.fromRGB(232,232,242), sub=Color3.fromRGB(120,120,150), dim=Color3.fromRGB(65,65,90), on=Color3.fromRGB(130,80,255), off=Color3.fromRGB(36,36,52), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(170,170,170), header=Color3.fromRGB(16,16,25)},
    {name="Ocean",    dot=Color3.fromRGB(45,140,255),  accent=Color3.fromRGB(45,140,255),  bg=Color3.fromRGB(10,13,22),  card=Color3.fromRGB(17,22,36), cardH=Color3.fromRGB(26,34,52), sidebar=Color3.fromRGB(13,17,28), border=Color3.fromRGB(26,40,66), text=Color3.fromRGB(218,230,248), sub=Color3.fromRGB(100,126,158), dim=Color3.fromRGB(52,72,104), on=Color3.fromRGB(45,140,255), off=Color3.fromRGB(22,32,50), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(170,170,170), header=Color3.fromRGB(11,15,25)},
    {name="Lime",     dot=Color3.fromRGB(100,220,60),  accent=Color3.fromRGB(100,220,60),  bg=Color3.fromRGB(12,15,10),  card=Color3.fromRGB(20,26,16), cardH=Color3.fromRGB(30,40,24), sidebar=Color3.fromRGB(15,19,12), border=Color3.fromRGB(32,48,24), text=Color3.fromRGB(236,246,230), sub=Color3.fromRGB(118,152,104), dim=Color3.fromRGB(65,96,50), on=Color3.fromRGB(100,220,60), off=Color3.fromRGB(26,38,18), knobOn=Color3.fromRGB(18,28,10), knobOff=Color3.fromRGB(170,170,170), header=Color3.fromRGB(13,17,11)},
    {name="Sakura",   dot=Color3.fromRGB(240,120,170), accent=Color3.fromRGB(240,120,170), bg=Color3.fromRGB(20,14,18),  card=Color3.fromRGB(32,22,28), cardH=Color3.fromRGB(46,32,40), sidebar=Color3.fromRGB(25,17,22), border=Color3.fromRGB(56,38,48), text=Color3.fromRGB(248,234,240), sub=Color3.fromRGB(160,120,140), dim=Color3.fromRGB(100,70,86), on=Color3.fromRGB(240,120,170), off=Color3.fromRGB(42,30,36), knobOn=Color3.fromRGB(255,255,255), knobOff=Color3.fromRGB(170,170,170), header=Color3.fromRGB(22,15,19)},
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
local stats = {clicks = 0, bought = 0, upgrades = 0, rebirths = 0, drops = 0}

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

local SIDE_W = 120
local WIN_W = 500
local WIN_H = 360

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
Strk.Transparency = 0.6
Strk.Parent = Main
bnd(Strk, {Color = "border"})

--------------------------------------------------------------
-- HEADER BAR
--------------------------------------------------------------
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 34)
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

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0, 250, 1, 0)
TitleLbl.Position = UDim2.new(0, 14, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "Sell Lemons  |  ShinyHub"
TitleLbl.Font = Enum.Font.Gotham
TitleLbl.TextSize = 12
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 11
TitleLbl.Parent = Header
bnd(TitleLbl, {TextColor3 = "sub"})

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
    task.wait(0.15)
    for _, t in ipairs(threads) do pcall(task.cancel, t) end
    Gui:Destroy()
end)

--------------------------------------------------------------
-- LEFT SIDEBAR
--------------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, SIDE_W, 1, -34)
Sidebar.Position = UDim2.new(0, 0, 0, 34)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 5
Sidebar.Parent = Main
bnd(Sidebar, {BackgroundColor3 = "sidebar"})

local SideDiv = Instance.new("Frame")
SideDiv.Size = UDim2.new(0, 1, 1, 0)
SideDiv.Position = UDim2.new(1, 0, 0, 0)
SideDiv.BorderSizePixel = 0
SideDiv.BackgroundTransparency = 0.5
SideDiv.ZIndex = 5
SideDiv.Parent = Sidebar
bnd(SideDiv, {BackgroundColor3 = "border"})

local tabNames = {"Home", "Farm", "Bonus", "Stats", "Settings"}
local tabBtns = {}
local tabPages = {}
local activeTab = nil

-- Active indicator bar
local SideIndicator = Instance.new("Frame")
SideIndicator.Size = UDim2.new(0, 3, 0, 26)
SideIndicator.Position = UDim2.new(0, 0, 0, 14)
SideIndicator.BorderSizePixel = 0
SideIndicator.ZIndex = 7
SideIndicator.Parent = Sidebar
bnd(SideIndicator, {BackgroundColor3 = "accent"})
Instance.new("UICorner", SideIndicator).CornerRadius = UDim.new(0, 2)

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 32)
    btn.Position = UDim2.new(0, 4, 0, 8 + (i - 1) * 36)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 1
    btn.ZIndex = 6
    btn.AutoButtonColor = false
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    bnd(btn, {TextColor3 = "dim"})

    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft = UDim.new(0, 16)

    btn.MouseEnter:Connect(function()
        if activeTab ~= name then
            tw(btn, {TextColor3 = C.sub, BackgroundTransparency = 0.85, BackgroundColor3 = C.card}, 0.1)
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= name then
            tw(btn, {TextColor3 = C.dim, BackgroundTransparency = 1}, 0.12)
        end
    end)

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    tabBtns[name] = btn
end

--------------------------------------------------------------
-- CONTENT
--------------------------------------------------------------
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -SIDE_W, 1, -34)
Content.Position = UDim2.new(0, SIDE_W, 0, 34)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.ZIndex = 2
Content.Parent = Main

-- Page title
local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, -24, 0, 30)
PageTitle.Position = UDim2.new(0, 16, 0, 4)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "Home"
PageTitle.Font = Enum.Font.GothamBold
PageTitle.TextSize = 15
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.ZIndex = 3
PageTitle.Parent = Content
bnd(PageTitle, {TextColor3 = "text"})

for _, name in ipairs(tabNames) do
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, -22, 1, -38)
    page.Position = UDim2.new(0, 12, 0, 36)
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
    pad.PaddingRight = UDim.new(0, 8)

    tabPages[name] = page
end

local function switchTab(name)
    activeTab = name
    PageTitle.Text = name
    for n, p in pairs(tabPages) do p.Visible = (n == name) end
    for n, b in pairs(tabBtns) do
        if n == name then
            tw(b, {TextColor3 = C.text, BackgroundTransparency = 0.9, BackgroundColor3 = C.card}, 0.2)
        else
            tw(b, {TextColor3 = C.dim, BackgroundTransparency = 1}, 0.2)
        end
    end
    local idx = table.find(tabNames, name) or 1
    tw(SideIndicator, {Position = UDim2.new(0, 0, 0, 8 + (idx - 1) * 36 + 3)}, 0.25, Enum.EasingStyle.Back)
end

for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

--------------------------------------------------------------
-- DRAG
--------------------------------------------------------------
local dragging, dragSt, dragPos
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
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

-- Keybind
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then
            tw(Main, {BackgroundTransparency = 1, Size = UDim2.new(0, WIN_W, 0, 0)}, 0.25)
            task.delay(0.25, function() Main.Visible = false end)
        else
            Main.Visible = true
            Main.Size = UDim2.new(0, WIN_W, 0, 0)
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

local function mkToggle(tab, name, parent)
    toggles[name] = false
    local h = Instance.new("Frame")
    h.LayoutOrder = nxt(tab)
    h.Size = UDim2.new(1, 0, 0, 32)
    h.BorderSizePixel = 0
    h.ZIndex = 2
    h.Parent = parent or tabPages[tab]
    bnd(h, {BackgroundColor3 = "card"})
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

    -- Left accent pip
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
    l.Size = UDim2.new(1, -54, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = h
    bnd(l, {TextColor3 = "sub"})

    local tr = Instance.new("TextButton")
    tr.Size = UDim2.new(0, 32, 0, 16)
    tr.Position = UDim2.new(1, -42, 0.5, -8)
    tr.Text = ""
    tr.BorderSizePixel = 0
    tr.ZIndex = 3
    tr.AutoButtonColor = false
    tr.Parent = h
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)

    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0, 12, 0, 12)
    kn.Position = UDim2.new(0, 2, 0.5, -6)
    kn.BackgroundColor3 = C.knobOff
    kn.BorderSizePixel = 0
    kn.ZIndex = 4
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
    b.Size = UDim2.new(1, 0, 0, 30)
    b.Text = ""
    b.BorderSizePixel = 0
    b.ZIndex = 2
    b.AutoButtonColor = false
    b.Parent = parent or tabPages[tab]
    bnd(b, {BackgroundColor3 = "card"})
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 1, 0)
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
        task.delay(0.1, function()
            tw(b, {BackgroundColor3 = C.card}, 0.25)
            tw(l, {TextColor3 = C.sub}, 0.25)
        end)
        if cb then cb() end
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
    bnd(l, {TextColor3 = "dim"})
    l.Text = "  " .. fn()
    table.insert(threads, task.spawn(function()
        while getgenv().SL_RUNNING do l.Text = "  " .. fn() task.wait(1) end
    end))
end

local function mkStatCard(tab, label, fn, parent)
    local h = Instance.new("Frame")
    h.LayoutOrder = nxt(tab)
    h.Size = UDim2.new(1, 0, 0, 38)
    h.BorderSizePixel = 0
    h.ZIndex = 2
    h.Parent = parent or tabPages[tab]
    bnd(h, {BackgroundColor3 = "card"})
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -14, 0, 16)
    lbl.Position = UDim2.new(0, 14, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = h
    bnd(lbl, {TextColor3 = "dim"})

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(1, -14, 0, 18)
    val.Position = UDim2.new(0, 14, 0, 18)
    val.BackgroundTransparency = 1
    val.Font = Enum.Font.GothamBold
    val.TextSize = 13
    val.TextXAlignment = Enum.TextXAlignment.Left
    val.ZIndex = 3
    val.Parent = h
    bnd(val, {TextColor3 = "text"})
    val.Text = fn()
    table.insert(threads, task.spawn(function()
        while getgenv().SL_RUNNING do val.Text = fn() task.wait(1) end
    end))
end

local function smartTP(locName)
    local loc = Locations:FindFirstChild(locName)
    if loc and loc:IsA("BasePart") then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = loc.CFrame + Vector3.new(0, 3, 0) end
    end
end

--------------------------------------------------------------
-- HOME
--------------------------------------------------------------
mkStatCard("Home", "CASH", function()
    local ls = LP:FindFirstChild("leaderstats")
    local cash = ls and ls:FindFirstChild("Cash")
    return cash and tostring(cash.Value) or "---"
end)
mkSpacer("Home", 2)
mkStatCard("Home", "TYCOON", function() return myTycoon.Name end)
mkSpacer("Home", 2)
mkStatCard("Home", "UPTIME", function()
    local e = os.clock() - sessionStart
    return string.format("%dm %ds", math.floor(e / 60), math.floor(e % 60))
end)

mkSpacer("Home", 8)
mkInfo("Home", function() return "ShinyHub  \xC2\xB7  Sell Lemons  \xC2\xB7  v3" end)

--------------------------------------------------------------
-- FARM
--------------------------------------------------------------
mkToggle("Farm", "Auto Buy Upgrades")
loop("Auto Buy Upgrades", function()
    for _, area in Purchases:GetChildren() do
        local buttons = area:FindFirstChild("Buttons")
        if buttons then
            local function scan(folder)
                for _, item in folder:GetChildren() do
                    if not getgenv().SL_RUNNING or not toggles["Auto Buy Upgrades"] then return end
                    if item:IsA("Folder") then scan(item)
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
    task.wait(0.2)
end)

mkToggle("Farm", "Auto Click Income")
loop("Auto Click Income", function()
    for _, areaName in ipairs(areaNames) do
        if not getgenv().SL_RUNNING or not toggles["Auto Click Income"] then return end
        local area = Purchases:FindFirstChild(areaName)
        if area then
            local m = area:FindFirstChild(areaName)
            if m then
                local inner = m:FindFirstChild(areaName)
                if inner then
                    local prompt = inner:FindFirstChild("Prompt")
                    if prompt and prompt:IsA("ProximityPrompt") then
                        fireproximityprompt(prompt)
                    end
                end
            end
        end
        task.wait(0.15)
    end
    task.wait(0.5)
end)

mkToggle("Farm", "Auto Upgrade Stands")
loop("Auto Upgrade Stands", function()
    for _, areaName in ipairs(areaNames) do
        if not getgenv().SL_RUNNING or not toggles["Auto Upgrade Stands"] then return end
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

mkSpacer("Farm", 4)

mkToggle("Farm", "Auto Collect Fruit")
loop("Auto Collect Fruit", function()
    local trees = Constant:FindFirstChild("Trees")
    if not trees then task.wait(1) return end
    for _, tree in trees:GetChildren() do
        if not getgenv().SL_RUNNING or not toggles["Auto Collect Fruit"] then return end
        for _, fruit in tree:GetChildren() do
            if fruit.Name == "Fruit" then
                local cp = fruit:FindFirstChild("ClickPart")
                if cp then
                    local cd = cp:FindFirstChild("ClickDetector")
                    if cd then
                        fireclickdetector(cd)
                        stats.clicks = stats.clicks + 1
                        task.wait(0.04)
                    end
                end
            end
        end
    end
    task.wait(0.1)
end)

mkToggle("Farm", "Auto Collect Drops")
loop("Auto Collect Drops", function()
    pcall(function()
        if CashDropRedeem then CashDropRedeem:InvokeServer() end
        stats.drops = stats.drops + 1
    end)
    task.wait(0.5)
end)

mkSpacer("Farm", 4)

mkToggle("Farm", "Auto Phone Offer")
loop("Auto Phone Offer", function()
    pcall(function() Remotes.PhoneOffer:FireServer() end)
    task.wait(2)
end)

mkToggle("Farm", "Auto Rebirth")
loop("Auto Rebirth", function()
    local ok = pcall(function() Remotes.Rebirth:InvokeServer() end)
    if ok then stats.rebirths = stats.rebirths + 1 end
    task.wait(1)
end)

mkToggle("Farm", "Auto Ascend")
loop("Auto Ascend", function()
    pcall(function() Remotes.Ascend:InvokeServer() end)
    task.wait(3)
end)

--------------------------------------------------------------
-- BONUS
--------------------------------------------------------------
mkToggle("Bonus", "Auto Evolve")
loop("Auto Evolve", function()
    pcall(function() Remotes.Evolve:InvokeServer() end)
    task.wait(2)
end)

mkToggle("Bonus", "Auto Upgrade Power")
loop("Auto Upgrade Power", function()
    pcall(function() Remotes.UpgradePowerLevel:InvokeServer() end)
    task.wait(1)
end)

mkSpacer("Bonus", 6)
mkButton("Bonus", "Collect Time Cash", function()
    pcall(function() Remotes.UseTimeCash:InvokeServer() end)
end)
mkButton("Bonus", "Use Earner Boost", function()
    pcall(function() Remotes.UseEarnerBoost:InvokeServer() end)
end)
mkButton("Bonus", "Double Offline Cash", function()
    pcall(function() Remotes.DoubleOfflineCash:InvokeServer() end)
end)

mkSpacer("Bonus", 8)

-- Teleport section inside Bonus
local sortedLocs = {}
for _, loc in Locations:GetChildren() do table.insert(sortedLocs, loc.Name) end
table.sort(sortedLocs)
for _, locName in ipairs(sortedLocs) do
    local display = locationRenames[locName] or locName
    mkButton("Bonus", "TP: " .. display, function() smartTP(locName) end)
end

--------------------------------------------------------------
-- STATS
--------------------------------------------------------------
mkStatCard("Stats", "LEMONS CLICKED", function() return tostring(stats.clicks) end)
mkSpacer("Stats", 2)
mkStatCard("Stats", "ITEMS BOUGHT", function() return tostring(stats.bought) end)
mkSpacer("Stats", 2)
mkStatCard("Stats", "EARNER UPGRADES", function() return tostring(stats.upgrades) end)
mkSpacer("Stats", 2)
mkStatCard("Stats", "REBIRTHS", function() return tostring(stats.rebirths) end)
mkSpacer("Stats", 2)
mkStatCard("Stats", "DROPS COLLECTED", function() return tostring(stats.drops) end)

--------------------------------------------------------------
-- SETTINGS
--------------------------------------------------------------
mkToggle("Settings", "Speed Boost")
loop("Speed Boost", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 80 end
    task.wait(0.5)
end)

mkToggle("Settings", "Jump Boost")
loop("Jump Boost", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 120 end
    task.wait(0.5)
end)

mkButton("Settings", "Toggle Infinite Jump", function()
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

mkSpacer("Settings", 6)
mkButton("Settings", "Reset Character", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end)
mkButton("Settings", "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

mkSpacer("Settings", 8)

-- Theme buttons with color dots
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
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, 14, 0.5, -4)
    dot.BorderSizePixel = 0
    dot.BackgroundColor3 = theme.dot
    dot.ZIndex = 3
    dot.Parent = b
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -36, 1, 0)
    l.Position = UDim2.new(0, 30, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = theme.name
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = b
    bnd(l, {TextColor3 = "sub"})

    b.MouseButton1Click:Connect(function()
        C = theme
        applyTheme()
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
-- ENTRANCE
--------------------------------------------------------------
Main.BackgroundTransparency = 1
Main.Size = UDim2.new(0, WIN_W, 0, 0)
Strk.Transparency = 1

task.delay(0.05, function()
    tw(Main, {Size = UDim2.new(0, WIN_W, 0, WIN_H), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back)
    tw(Strk, {Transparency = 0.6}, 0.5)
end)

switchTab("Home")
