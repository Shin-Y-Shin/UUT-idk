--[[
    ShinyHub — Sell Lemons 🍋
    Auto-farm, auto-buy, auto-upgrade, rebirth/evolve/ascend
]]

if game.CoreGui:FindFirstChild("SellLemonsHub") then game.CoreGui:FindFirstChild("SellLemonsHub"):Destroy() end
if getgenv().SL_RUNNING then getgenv().SL_RUNNING = false task.wait(0.3) end
getgenv().SL_RUNNING = true

local Players    = game:GetService("Players")
local TS         = game:GetService("TweenService")
local UIS        = game:GetService("UserInputService")

local LP = Players.LocalPlayer

--------------------------------------------------------------
-- FIND PLAYER'S TYCOON
--------------------------------------------------------------
local myTycoon = nil
for i = 1, 10 do
    for _, folder in game.Workspace:GetChildren() do
        if folder.Name == "Tycoon" .. i and folder:IsA("Folder") then
            local owner = folder:FindFirstChild("Owner")
            if owner and owner.Value == LP then
                myTycoon = folder
                break
            end
        end
    end
    if myTycoon then break end
end

if not myTycoon then
    warn("[ShinyHub] Could not find your tycoon")
    return
end

local Remotes   = myTycoon:WaitForChild("Remotes")
local Purchases = myTycoon:WaitForChild("Purchases")
local Constant  = myTycoon:WaitForChild("Constant")
local Locations = myTycoon:WaitForChild("Locations")

--------------------------------------------------------------
-- AREA LIST (income streams / earners)
--------------------------------------------------------------
local areaNames = {
    "Lemon Stand", "Lemon Trading", "Lemon Depot", "Lemon Labs",
    "LemonDash", "Lemon Robotics", "Lemon Republic", "LemonX"
}

local locationNames = {}
for _, loc in Locations:GetChildren() do
    table.insert(locationNames, loc.Name)
end
table.sort(locationNames)

--------------------------------------------------------------
-- THEME ENGINE
--------------------------------------------------------------
local ThemeList = {
    {name="Midnight", accent=Color3.fromRGB(130,80,255),  bg=Color3.fromRGB(14,14,22),  card=Color3.fromRGB(24,24,38), cardH=Color3.fromRGB(34,34,55), tabBg=Color3.fromRGB(18,18,28), tabActive=Color3.fromRGB(130,80,255), border=Color3.fromRGB(45,40,70), text=Color3.fromRGB(235,235,245), sub=Color3.fromRGB(140,140,170), dim=Color3.fromRGB(80,80,110), on=Color3.fromRGB(130,80,255), off=Color3.fromRGB(45,45,65)},
    {name="Ocean",    accent=Color3.fromRGB(45,140,255),  bg=Color3.fromRGB(10,14,24),  card=Color3.fromRGB(18,26,42), cardH=Color3.fromRGB(28,38,60), tabBg=Color3.fromRGB(14,18,30), tabActive=Color3.fromRGB(45,140,255), border=Color3.fromRGB(35,55,85), text=Color3.fromRGB(225,235,250), sub=Color3.fromRGB(120,145,180), dim=Color3.fromRGB(65,90,125), on=Color3.fromRGB(45,140,255), off=Color3.fromRGB(30,42,62)},
    {name="Sakura",   accent=Color3.fromRGB(240,120,170), bg=Color3.fromRGB(22,14,20),  card=Color3.fromRGB(40,26,35), cardH=Color3.fromRGB(55,36,48), tabBg=Color3.fromRGB(28,18,25), tabActive=Color3.fromRGB(240,120,170), border=Color3.fromRGB(80,50,65), text=Color3.fromRGB(250,235,242), sub=Color3.fromRGB(185,140,160), dim=Color3.fromRGB(120,85,105), on=Color3.fromRGB(240,120,170), off=Color3.fromRGB(58,38,48)},
    {name="Emerald",  accent=Color3.fromRGB(40,210,130),  bg=Color3.fromRGB(10,18,15),  card=Color3.fromRGB(18,34,28), cardH=Color3.fromRGB(28,50,40), tabBg=Color3.fromRGB(13,24,20), tabActive=Color3.fromRGB(40,210,130), border=Color3.fromRGB(32,65,50), text=Color3.fromRGB(225,248,238), sub=Color3.fromRGB(120,165,145), dim=Color3.fromRGB(70,115,95), on=Color3.fromRGB(40,210,130), off=Color3.fromRGB(30,52,42)},
    {name="Lemon",    accent=Color3.fromRGB(255,220,50),  bg=Color3.fromRGB(18,16,10),  card=Color3.fromRGB(34,30,18), cardH=Color3.fromRGB(50,44,26), tabBg=Color3.fromRGB(24,22,14), tabActive=Color3.fromRGB(255,220,50), border=Color3.fromRGB(75,65,30), text=Color3.fromRGB(252,248,230), sub=Color3.fromRGB(180,170,120), dim=Color3.fromRGB(120,110,70), on=Color3.fromRGB(255,220,50), off=Color3.fromRGB(55,50,28)},
}

local C = ThemeList[1]
local binds = {}
local togRefresh = {}

local function tw(o, p, d)
    TS:Create(o, TweenInfo.new(d or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), p):Play()
end
local function twBack(o, p, d)
    TS:Create(o, TweenInfo.new(d or 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), p):Play()
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
            tw(b.o, p, 0.4)
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
local statsBought = 0
local statsRebirths = 0
local statsClicks = 0
local statsUpgrades = 0

local function loop(key, fn)
    table.insert(threads, task.spawn(function()
        while getgenv().SL_RUNNING do
            if toggles[key] then pcall(fn) else task.wait(0.3) end
        end
    end))
end

--------------------------------------------------------------
-- GUI SHELL
--------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "SellLemonsHub"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 520, 0, 380)
Main.Position = UDim2.new(0.5, -260, 0.5, -190)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui
bnd(Main, {BackgroundColor3 = "bg"})
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Strk = Instance.new("UIStroke")
Strk.Thickness = 1.5
Strk.Transparency = 0.4
Strk.Parent = Main
bnd(Strk, {Color = "accent"})

--------------------------------------------------------------
-- TOP BAR
--------------------------------------------------------------
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 6
TopBar.Parent = Main
bnd(TopBar, {BackgroundColor3 = "tabBg"})

local TopDiv = Instance.new("Frame")
TopDiv.Size = UDim2.new(1, 0, 0, 1)
TopDiv.Position = UDim2.new(0, 0, 1, -1)
TopDiv.BorderSizePixel = 0
TopDiv.ZIndex = 6
TopDiv.Parent = TopBar
bnd(TopDiv, {BackgroundColor3 = "border"})

local GlowLine = Instance.new("Frame")
GlowLine.Size = UDim2.new(0, 60, 0, 2)
GlowLine.Position = UDim2.new(0, 14, 1, -2)
GlowLine.BorderSizePixel = 0
GlowLine.ZIndex = 7
GlowLine.Parent = TopBar
bnd(GlowLine, {BackgroundColor3 = "accent"})

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0, 200, 1, 0)
TitleLbl.Position = UDim2.new(0, 16, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "Sell Lemons \xF0\x9F\x8D\x8B"
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 16
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 7
TitleLbl.Parent = TopBar
bnd(TitleLbl, {TextColor3 = "accent"})

local VerLbl = Instance.new("TextLabel")
VerLbl.Size = UDim2.new(0, 40, 0, 14)
VerLbl.Position = UDim2.new(0, 140, 0.5, -7)
VerLbl.BackgroundTransparency = 1
VerLbl.Text = "v1"
VerLbl.Font = Enum.Font.Gotham
VerLbl.TextSize = 10
VerLbl.ZIndex = 7
VerLbl.TextXAlignment = Enum.TextXAlignment.Left
VerLbl.Parent = TopBar
bnd(VerLbl, {TextColor3 = "dim"})

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 24)
MinBtn.Position = UDim2.new(1, -72, 0.5, -12)
MinBtn.Text = "\xE2\x80\x94"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 8
MinBtn.AutoButtonColor = false
MinBtn.Parent = TopBar
bnd(MinBtn, {BackgroundColor3 = "card"})
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

MinBtn.MouseEnter:Connect(function() tw(MinBtn, {BackgroundColor3 = C.cardH}, 0.12) end)
MinBtn.MouseLeave:Connect(function() tw(MinBtn, {BackgroundColor3 = C.card}, 0.12) end)

-- Popup notification
local Popup = Instance.new("Frame")
Popup.Size = UDim2.new(0, 200, 0, 36)
Popup.Position = UDim2.new(1, -210, 1, -50)
Popup.BackgroundTransparency = 1
Popup.BorderSizePixel = 0
Popup.ZIndex = 50
Popup.Visible = false
Popup.Parent = Gui
bnd(Popup, {BackgroundColor3 = "card"})
Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 10)

local PopupLbl = Instance.new("TextLabel")
PopupLbl.Size = UDim2.new(1, 0, 1, 0)
PopupLbl.BackgroundTransparency = 1
PopupLbl.Text = "RightShift to open"
PopupLbl.Font = Enum.Font.GothamBold
PopupLbl.TextSize = 13
PopupLbl.ZIndex = 51
PopupLbl.TextTransparency = 1
PopupLbl.Parent = Popup
bnd(PopupLbl, {TextColor3 = "accent"})

local popupThread = nil
local function showPopup()
    if popupThread then pcall(task.cancel, popupThread) end
    Popup.Visible = true
    Popup.BackgroundTransparency = 1
    PopupLbl.TextTransparency = 1
    Popup.Position = UDim2.new(1, -210, 1, -20)
    twBack(Popup, {BackgroundTransparency = 0.15, Position = UDim2.new(1, -210, 1, -50)}, 0.35)
    tw(PopupLbl, {TextTransparency = 0}, 0.3)
    popupThread = task.spawn(function()
        task.wait(3)
        tw(Popup, {BackgroundTransparency = 1, Position = UDim2.new(1, -210, 1, -20)}, 0.4)
        tw(PopupLbl, {TextTransparency = 1}, 0.4)
        task.wait(0.5)
        Popup.Visible = false
    end)
end

local function minimizeHub()
    tw(Main, {Size = UDim2.new(0, 520, 0, 0), BackgroundTransparency = 1}, 0.3)
    task.delay(0.3, function()
        Main.Visible = false
        showPopup()
    end)
end

local function openHub()
    Main.Visible = true
    Main.Size = UDim2.new(0, 520, 0, 0)
    Main.BackgroundTransparency = 1
    tw(Main, {Size = UDim2.new(0, 520, 0, 380), BackgroundTransparency = 0}, 0.35)
end

MinBtn.MouseButton1Click:Connect(minimizeHub)

local XBtn = Instance.new("TextButton")
XBtn.Size = UDim2.new(0, 30, 0, 24)
XBtn.Position = UDim2.new(1, -38, 0.5, -12)
XBtn.Text = "X"
XBtn.Font = Enum.Font.GothamBold
XBtn.TextSize = 12
XBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
XBtn.BackgroundColor3 = Color3.fromRGB(210, 50, 55)
XBtn.BorderSizePixel = 0
XBtn.ZIndex = 8
XBtn.AutoButtonColor = false
XBtn.Parent = TopBar
Instance.new("UICorner", XBtn).CornerRadius = UDim.new(0, 6)

XBtn.MouseButton1Click:Connect(function()
    getgenv().SL_RUNNING = false
    task.wait(0.15)
    for _, t in ipairs(threads) do pcall(task.cancel, t) end
    Gui:Destroy()
end)

--------------------------------------------------------------
-- RIGHT TAB BAR
--------------------------------------------------------------
local TAB_W = 90
local tabNames = {"Home", "Farm", "Tycoon", "Teleport", "Misc"}

local TabPanel = Instance.new("Frame")
TabPanel.Size = UDim2.new(0, TAB_W, 1, -40)
TabPanel.Position = UDim2.new(1, -TAB_W, 0, 40)
TabPanel.BorderSizePixel = 0
TabPanel.ZIndex = 5
TabPanel.Parent = Main
bnd(TabPanel, {BackgroundColor3 = "tabBg"})

local TabDiv = Instance.new("Frame")
TabDiv.Size = UDim2.new(0, 1, 1, -40)
TabDiv.Position = UDim2.new(1, -TAB_W, 0, 40)
TabDiv.BorderSizePixel = 0
TabDiv.ZIndex = 5
TabDiv.Parent = Main
bnd(TabDiv, {BackgroundColor3 = "border"})

local tabBtns = {}
local tabPages = {}
local activeTab = nil

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, 8 + (i - 1) * 46)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.ZIndex = 6
    btn.AutoButtonColor = false
    btn.Parent = TabPanel
    bnd(btn, {BackgroundColor3 = "tabBg", TextColor3 = "sub"})
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseEnter:Connect(function()
        if activeTab ~= name then
            twBack(btn, {Size = UDim2.new(1, -6, 0, 42), BackgroundColor3 = C.cardH}, 0.2)
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= name then
            tw(btn, {Size = UDim2.new(1, -10, 0, 40), BackgroundColor3 = C.tabBg}, 0.2)
        end
    end)

    tabBtns[name] = btn
end

--------------------------------------------------------------
-- CONTENT PAGES
--------------------------------------------------------------
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -TAB_W, 1, -40)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.ZIndex = 2
Content.Parent = Main

for _, name in ipairs(tabNames) do
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, -16, 1, -12)
    page.Position = UDim2.new(0, 10, 0, 6)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.BorderSizePixel = 0
    page.ZIndex = 2
    page.Parent = Content
    bnd(page, {ScrollBarImageColor3 = "accent"})

    local lay = Instance.new("UIListLayout", page)
    lay.Padding = UDim.new(0, 5)
    lay.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0, 2)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 6)

    tabPages[name] = page
end

local function switchTab(name)
    activeTab = name
    for n, p in pairs(tabPages) do p.Visible = (n == name) end
    for n, b in pairs(tabBtns) do
        if n == name then
            tw(b, {BackgroundColor3 = C.tabActive, TextColor3 = C.bg}, 0.25)
            twBack(b, {Size = UDim2.new(1, -6, 0, 42)}, 0.25)
        else
            tw(b, {BackgroundColor3 = C.tabBg, TextColor3 = C.sub, Size = UDim2.new(1, -10, 0, 40)}, 0.25)
        end
    end
end

for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

--------------------------------------------------------------
-- DRAG & RESIZE
--------------------------------------------------------------
local dragging, dragSt, dragPos
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragSt = i.Position; dragPos = Main.Position
    end
end)
TopBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragSt
        Main.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + d.X, dragPos.Y.Scale, dragPos.Y.Offset + d.Y)
    end
end)

local Rsz = Instance.new("TextButton")
Rsz.Size = UDim2.new(0, 16, 0, 16)
Rsz.Position = UDim2.new(1, -16, 1, -16)
Rsz.Text = ""
Rsz.BackgroundTransparency = 0.4
Rsz.BorderSizePixel = 0
Rsz.ZIndex = 10
Rsz.Parent = Main
bnd(Rsz, {BackgroundColor3 = "border"})
Instance.new("UICorner", Rsz).CornerRadius = UDim.new(0, 4)

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
        Main.Size = UDim2.new(0, math.clamp(resSz.X.Offset + d.X, 400, 700), 0, math.clamp(resSz.Y.Offset + d.Y, 300, 650))
    end
end)

--------------------------------------------------------------
-- KEYBIND — RightShift toggle
--------------------------------------------------------------
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then minimizeHub() else openHub() end
    end
end)

--------------------------------------------------------------
-- UI ELEMENT FACTORIES
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
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 2
    l.Parent = parent or tabPages[tab]
    bnd(l, {TextColor3 = "accent"})
    return l
end

local function mkSpacer(tab, h, parent)
    local s = Instance.new("Frame")
    s.LayoutOrder = nxt(tab)
    s.Size = UDim2.new(1, 0, 0, h or 4)
    s.BackgroundTransparency = 1
    s.ZIndex = 2
    s.Parent = parent or tabPages[tab]
end

local function mkToggle(tab, name, cb, parent)
    toggles[name] = false
    local h = Instance.new("Frame")
    h.LayoutOrder = nxt(tab)
    h.Size = UDim2.new(1, 0, 0, 36)
    h.BorderSizePixel = 0
    h.ZIndex = 2
    h.Parent = parent or tabPages[tab]
    bnd(h, {BackgroundColor3 = "card"})
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -56, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = h
    bnd(l, {TextColor3 = "text"})

    local tr = Instance.new("TextButton")
    tr.Size = UDim2.new(0, 38, 0, 20)
    tr.Position = UDim2.new(1, -48, 0.5, -10)
    tr.Text = ""
    tr.BorderSizePixel = 0
    tr.ZIndex = 3
    tr.AutoButtonColor = false
    tr.Parent = h
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)

    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0, 16, 0, 16)
    kn.Position = UDim2.new(0, 2, 0.5, -8)
    kn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    kn.BorderSizePixel = 0
    kn.ZIndex = 4
    kn.Parent = tr
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)

    local function ref()
        local on = toggles[name]
        tw(tr, {BackgroundColor3 = on and C.on or C.off}, 0.2)
        tw(kn, {Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
    end
    ref()
    table.insert(togRefresh, ref)

    tr.MouseButton1Click:Connect(function()
        toggles[name] = not toggles[name]
        ref()
        if cb then cb(toggles[name]) end
    end)

    h.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then tw(h, {BackgroundColor3 = C.cardH}, 0.12) end end)
    h.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then tw(h, {BackgroundColor3 = C.card}, 0.12) end end)
end

local function mkButton(tab, txt, cb, parent)
    local b = Instance.new("TextButton")
    b.LayoutOrder = nxt(tab)
    b.Size = UDim2.new(1, 0, 0, 32)
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
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = b
    bnd(l, {TextColor3 = "text"})

    b.MouseButton1Click:Connect(function()
        tw(b, {BackgroundColor3 = C.accent}, 0.08)
        task.delay(0.15, function() tw(b, {BackgroundColor3 = C.card}, 0.2) end)
        if cb then cb() end
    end)
    b.MouseEnter:Connect(function() if b then tw(b, {BackgroundColor3 = C.cardH}, 0.12) end end)
    b.MouseLeave:Connect(function() if b then tw(b, {BackgroundColor3 = C.card}, 0.12) end end)
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
    l.Text = "  " .. fn()
    table.insert(threads, task.spawn(function()
        while getgenv().SL_RUNNING do l.Text = "  " .. fn() task.wait(1) end
    end))
end

--------------------------------------------------------------
-- SMART TELEPORT
--------------------------------------------------------------
local function smartTP(locationName)
    local loc = Locations:FindFirstChild(locationName)
    if loc and loc:IsA("BasePart") then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = loc.CFrame + Vector3.new(0, 3, 0)
        end
    end
end

--------------------------------------------------------------
-- HOME TAB
--------------------------------------------------------------
mkLabel("Home", "ShinyHub — Sell Lemons")
mkSpacer("Home", 4)

mkInfo("Home", function()
    local ls = LP:FindFirstChild("leaderstats")
    local cash = ls and ls:FindFirstChild("Cash")
    return "Cash: " .. (cash and tostring(cash.Value) or "N/A")
end)
mkInfo("Home", function()
    return "Tycoon: " .. myTycoon.Name
end)
mkInfo("Home", function()
    local elapsed = os.clock() - sessionStart
    local m = math.floor(elapsed / 60)
    local s = math.floor(elapsed % 60)
    return string.format("Session: %dm %ds", m, s)
end)
mkSpacer("Home", 4)

mkInfo("Home", function()
    return string.format("Lemons clicked: %d | Items bought: %d", statsClicks, statsBought)
end)
mkInfo("Home", function()
    return string.format("Upgrades: %d | Rebirths: %d", statsUpgrades, statsRebirths)
end)

mkSpacer("Home", 8)
mkLabel("Home", "Theme")

for _, theme in ipairs(ThemeList) do
    mkButton("Home", theme.name, function()
        C = theme
        applyTheme()
    end)
end

--------------------------------------------------------------
-- FARM TAB — Auto Click Lemons + Auto Collect
--------------------------------------------------------------
mkLabel("Farm", "Lemon Clicking")
mkToggle("Farm", "Auto Click Lemons")

loop("Auto Click Lemons", function()
    local trees = Constant:FindFirstChild("Trees")
    if not trees then task.wait(1) return end
    for _, tree in trees:GetChildren() do
        if not getgenv().SL_RUNNING or not toggles["Auto Click Lemons"] then return end
        for _, fruit in tree:GetChildren() do
            if fruit.Name == "Fruit" then
                local clickPart = fruit:FindFirstChild("ClickPart")
                if clickPart then
                    local cd = clickPart:FindFirstChild("ClickDetector")
                    if cd then
                        fireclickdetector(cd)
                        statsClicks = statsClicks + 1
                        task.wait(0.05)
                    end
                end
            end
        end
    end
    task.wait(0.1)
end)

mkSpacer("Farm", 6)
mkLabel("Farm", "Income Streams")
mkToggle("Farm", "Auto Wake Earners")

loop("Auto Wake Earners", function()
    for _, areaName in ipairs(areaNames) do
        if not getgenv().SL_RUNNING or not toggles["Auto Wake Earners"] then return end
        pcall(function()
            Remotes.WakeIncomeStream:InvokeServer(areaName)
        end)
        task.wait(0.2)
    end
    task.wait(1)
end)

mkSpacer("Farm", 6)
mkLabel("Farm", "Earner Upgrades")
mkToggle("Farm", "Auto Upgrade Earners")

loop("Auto Upgrade Earners", function()
    for _, areaName in ipairs(areaNames) do
        if not getgenv().SL_RUNNING or not toggles["Auto Upgrade Earners"] then return end
        local area = Purchases:FindFirstChild(areaName)
        if area then
            local earnerModel = area:FindFirstChild(areaName)
            if earnerModel then
                local inner = earnerModel:FindFirstChild(areaName)
                if inner then
                    local upg = inner:FindFirstChild("Upgrade")
                    if upg and upg:IsA("RemoteFunction") then
                        local ok = pcall(function()
                            upg:InvokeServer(1)
                        end)
                        if ok then statsUpgrades = statsUpgrades + 1 end
                    end
                end
            end
        end
        task.wait(0.1)
    end
    task.wait(0.5)
end)

--------------------------------------------------------------
-- TYCOON TAB — Auto Buy, Rebirth, Evolve, Ascend
--------------------------------------------------------------
mkLabel("Tycoon", "Purchases")
mkToggle("Tycoon", "Auto Buy Items")

loop("Auto Buy Items", function()
    for _, area in Purchases:GetChildren() do
        local buttons = area:FindFirstChild("Buttons")
        if buttons then
            local function scanAndBuy(folder)
                for _, item in folder:GetChildren() do
                    if not getgenv().SL_RUNNING or not toggles["Auto Buy Items"] then return end
                    if item:IsA("Folder") then
                        scanAndBuy(item)
                    elseif item:IsA("Model") then
                        local purchased = item:GetAttribute("Purchased")
                        if purchased == false then
                            local rem = item:FindFirstChild("Purchase")
                            if rem and rem:IsA("RemoteFunction") then
                                local ok = pcall(function()
                                    rem:InvokeServer(false)
                                end)
                                if ok then statsBought = statsBought + 1 end
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end
            scanAndBuy(buttons)
        end
    end
    task.wait(0.3)
end)

mkSpacer("Tycoon", 6)
mkLabel("Tycoon", "Rebirth / Evolve / Ascend")

mkToggle("Tycoon", "Auto Rebirth")
loop("Auto Rebirth", function()
    local ok = pcall(function()
        Remotes.Rebirth:InvokeServer()
    end)
    if ok then statsRebirths = statsRebirths + 1 end
    task.wait(1)
end)

mkToggle("Tycoon", "Auto Evolve")
loop("Auto Evolve", function()
    pcall(function()
        Remotes.Evolve:InvokeServer()
    end)
    task.wait(2)
end)

mkToggle("Tycoon", "Auto Ascend")
loop("Auto Ascend", function()
    pcall(function()
        Remotes.Ascend:InvokeServer()
    end)
    task.wait(3)
end)

mkSpacer("Tycoon", 6)
mkLabel("Tycoon", "Power Level")

mkToggle("Tycoon", "Auto Upgrade Power")
loop("Auto Upgrade Power", function()
    pcall(function()
        Remotes.UpgradePowerLevel:InvokeServer()
    end)
    task.wait(1)
end)

mkSpacer("Tycoon", 6)
mkLabel("Tycoon", "Boosts")

mkButton("Tycoon", "Use Time Cash", function()
    pcall(function() Remotes.UseTimeCash:InvokeServer() end)
end)

mkButton("Tycoon", "Use Earner Boost", function()
    pcall(function() Remotes.UseEarnerBoost:InvokeServer() end)
end)

--------------------------------------------------------------
-- TELEPORT TAB
--------------------------------------------------------------
mkLabel("Teleport", "Tycoon Locations")

for _, locName in ipairs(locationNames) do
    mkButton("Teleport", locName, function()
        smartTP(locName)
    end)
end

--------------------------------------------------------------
-- MISC TAB
--------------------------------------------------------------
mkLabel("Misc", "Player")

mkButton("Misc", "Infinite Jump", function()
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

mkToggle("Misc", "Speed Boost")
loop("Speed Boost", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 80 end
    task.wait(0.5)
end)

mkToggle("Misc", "Jump Boost")
loop("Jump Boost", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 120 end
    task.wait(0.5)
end)

mkSpacer("Misc", 8)
mkLabel("Misc", "Settings")

mkButton("Misc", "Reset Character", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end)

mkButton("Misc", "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

--------------------------------------------------------------
-- INIT
--------------------------------------------------------------
switchTab("Home")
