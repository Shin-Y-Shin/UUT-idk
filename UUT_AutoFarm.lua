--[[
    UUT Hub v7 — Untitled Upgrade Tree
    World-based farming | Session stats | Teleport tab | Modern tabs
]]

if game.CoreGui:FindFirstChild("UUTHub") then game.CoreGui:FindFirstChild("UUTHub"):Destroy() end
if getgenv().UUT_RUNNING then getgenv().UUT_RUNNING = false task.wait(0.3) end
getgenv().UUT_RUNNING = true

local Players    = game:GetService("Players")
local RS         = game:GetService("ReplicatedStorage")
local TS         = game:GetService("TweenService")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP       = Players.LocalPlayer
local PD       = LP:WaitForChild("Data"):WaitForChild("PlayerData")
local Upgrades = LP.Data:WaitForChild("Upgrades")
local Remotes  = RS:WaitForChild("Remotes")

local allUpgradeIds = {}
for _, v in pairs(Upgrades:GetChildren()) do
    local n = tonumber(v.Name)
    if n then table.insert(allUpgradeIds, n) end
end
table.sort(allUpgradeIds)

-- Map CurrencyCost values to world names
local currencyToWorld = {
    Points = "Spawn", Clicks = "Spawn", TotalRolls = "Spawn",
    PrestigePoints = "Spawn", EvilPoints = "Spawn",
    Bubbles = "Spawn", PlayerLevelPoints = "Spawn",
    DailyPoints = "Spawn", PortalFragment = "Spawn",
    GalaxyPoints = "Galaxy", Rocks = "Galaxy", Steel = "Galaxy",
    DarkEnergie = "BlackHole", DarkPrestigeEnergie = "BlackHole",
    Token = "BlackHole", DarkEvilEnergie = "BlackHole",
    AntiPoint = "AntiWorld", AntiPrestigePoint = "AntiWorld",
    AntiEvilPoint = "AntiWorld", AntiLevelsToken = "AntiWorld",
    SupernovaPoint = "Supernova",
    Hecker = "Hecker",
    Units = "Genesis", Blocks = "Genesis",
    TowerPoints = "Tower", TowerPrestigePoints = "Tower",
    Alpha = "God", Coins = "God",
    WishToken = "Bigbang", Beta = "Bigbang", Memories = "Bigbang",
    VoidCurrency = "Void", WorldCurrency = "Void",
    AscendPoints = "Cycle", Shards = "Cycle",
    CosmicMatter = "Space", RocketParts = "Space", Stars = "Space",
    Currency1 = "Unknown1", Currency2 = "Unknown2", Currency3 = "Unknown3",
}

local worldDisplayCurrencies = {
    Spawn = "Points, Clicks, Rolls, Prestige, Evil, Bubbles, Skill Points",
    Galaxy = "Galaxy Points, Rocks, Steel",
    BlackHole = "Dark Energy, Dark Prestige, Token, Dark Evil",
    AntiWorld = "Anti Points, Anti Prestige, Anti Evil",
    Supernova = "Supernova Points",
    Hecker = "Heck Credits",
    Genesis = "Units, Blocks",
    Tower = "Tower Points, Tower Prestige",
    God = "Alpha, Coins",
    Bigbang = "Wish, Beta, Memories",
    Void = "Void Currency, World Currency",
    Cycle = "Ascend Points, Shards",
    Space = "Cosmic Matter, Rocket Parts, Stars",
}

local worldPrestige = {
    Spawn = {
        {name = "Auto Prestige", fn = function() pcall(Remotes.Prestige.FireServer, Remotes.Prestige) task.wait(0.3) end},
        {name = "Auto Evil", fn = function() pcall(Remotes.Evil.FireServer, Remotes.Evil) task.wait(0.3) end},
        {name = "Auto Loop", fn = function() pcall(Remotes.Loop.FireServer, Remotes.Loop) task.wait(0.5) end},
    },
    BlackHole = {
        {name = "Auto Dark Prestige", fn = function() pcall(Remotes.DarkPrestige.FireServer, Remotes.DarkPrestige) task.wait(0.3) end},
        {name = "Auto Dark Evil", fn = function() pcall(Remotes.DarkEvil.FireServer, Remotes.DarkEvil) task.wait(0.3) end},
    },
    AntiWorld = {
        {name = "Auto Anti-Prestige", fn = function() pcall(Remotes.AntiPrestige.FireServer, Remotes.AntiPrestige) task.wait(0.3) end},
        {name = "Auto Anti-Evil", fn = function() pcall(Remotes.AntiEvil.FireServer, Remotes.AntiEvil) task.wait(0.3) end},
    },
    Supernova = {
        {name = "Auto Supernova", fn = function() pcall(Remotes.Supernova.FireServer, Remotes.Supernova) task.wait(0.5) end},
    },
    Cycle = {
        {name = "Auto Ascend", fn = function() pcall(Remotes.Ascend.FireServer, Remotes.Ascend) task.wait(0.5) end},
        {name = "Auto Cycle", fn = function() pcall(Remotes.Cycle.FireServer, Remotes.Cycle) task.wait(0.5) end},
    },
    Tower = {
        {name = "Auto Tower Prestige", fn = function() pcall(Remotes.TowerPrestige.FireServer, Remotes.TowerPrestige) task.wait(0.3) end},
    },
    Bigbang = {
        {name = "Auto Beta", fn = function() pcall(Remotes.Beta.FireServer, Remotes.Beta) task.wait(0.3) end},
    },
}

-- Build per-world upgrade ID lists dynamically
local worldUpgrades = {}
local worldList = {"Spawn", "Galaxy", "BlackHole", "AntiWorld", "Supernova", "Hecker", "Genesis", "Tower", "God", "Bigbang", "Void", "Cycle", "Space"}
for _, w in ipairs(worldList) do worldUpgrades[w] = {} end

pcall(function()
    local UpgModule = require(RS.Modules.Upgrades)
    for id, data in pairs(UpgModule) do
        if type(data) == "table" then
            local cc = type(data.CurrencyCost) == "string" and data.CurrencyCost or nil
            if cc then
                local world = currencyToWorld[cc]
                if world and worldUpgrades[world] then
                    table.insert(worldUpgrades[world], id)
                end
            end
        end
    end
end)
for _, ids in pairs(worldUpgrades) do table.sort(ids) end

--------------------------------------------------------------
-- THEME ENGINE
--------------------------------------------------------------
local ThemeList = {
    {name="Midnight", accent=Color3.fromRGB(130,80,255),  bg=Color3.fromRGB(14,14,22),  card=Color3.fromRGB(24,24,38), cardH=Color3.fromRGB(34,34,55), tabBg=Color3.fromRGB(18,18,28), tabActive=Color3.fromRGB(130,80,255), border=Color3.fromRGB(45,40,70), text=Color3.fromRGB(235,235,245), sub=Color3.fromRGB(140,140,170), dim=Color3.fromRGB(80,80,110), on=Color3.fromRGB(130,80,255), off=Color3.fromRGB(45,45,65)},
    {name="Ocean",    accent=Color3.fromRGB(45,140,255),  bg=Color3.fromRGB(10,14,24),  card=Color3.fromRGB(18,26,42), cardH=Color3.fromRGB(28,38,60), tabBg=Color3.fromRGB(14,18,30), tabActive=Color3.fromRGB(45,140,255), border=Color3.fromRGB(35,55,85), text=Color3.fromRGB(225,235,250), sub=Color3.fromRGB(120,145,180), dim=Color3.fromRGB(65,90,125), on=Color3.fromRGB(45,140,255), off=Color3.fromRGB(30,42,62)},
    {name="Sakura",   accent=Color3.fromRGB(240,120,170), bg=Color3.fromRGB(22,14,20),  card=Color3.fromRGB(40,26,35), cardH=Color3.fromRGB(55,36,48), tabBg=Color3.fromRGB(28,18,25), tabActive=Color3.fromRGB(240,120,170), border=Color3.fromRGB(80,50,65), text=Color3.fromRGB(250,235,242), sub=Color3.fromRGB(185,140,160), dim=Color3.fromRGB(120,85,105), on=Color3.fromRGB(240,120,170), off=Color3.fromRGB(58,38,48)},
    {name="Emerald",  accent=Color3.fromRGB(40,210,130),  bg=Color3.fromRGB(10,18,15),  card=Color3.fromRGB(18,34,28), cardH=Color3.fromRGB(28,50,40), tabBg=Color3.fromRGB(13,24,20), tabActive=Color3.fromRGB(40,210,130), border=Color3.fromRGB(32,65,50), text=Color3.fromRGB(225,248,238), sub=Color3.fromRGB(120,165,145), dim=Color3.fromRGB(70,115,95), on=Color3.fromRGB(40,210,130), off=Color3.fromRGB(30,52,42)},
    {name="Sunset",   accent=Color3.fromRGB(255,125,50),  bg=Color3.fromRGB(20,14,10),  card=Color3.fromRGB(38,28,22), cardH=Color3.fromRGB(55,40,30), tabBg=Color3.fromRGB(26,18,14), tabActive=Color3.fromRGB(255,125,50), border=Color3.fromRGB(80,55,38), text=Color3.fromRGB(252,244,236), sub=Color3.fromRGB(185,150,125), dim=Color3.fromRGB(125,100,80), on=Color3.fromRGB(255,125,50), off=Color3.fromRGB(58,42,32)},
}

local C = ThemeList[1]
local binds = {}
local togRefresh = {}
local uiAlpha = 0

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
local sakuraEnabled = false
local activeWorld = nil
local sessionStart = os.clock()
local statsUpgBought = 0
local statsRebirths = 0

local worldTPZones = {
    Spawn = "Baseplate", Galaxy = "BaseplateGalaxie", BlackHole = "BaseplateBlackhole",
    AntiWorld = "BaseplateAntiWorld", Supernova = "BaseplateSupernova",
    Hecker = "HeckerBaseplate", Genesis = "GenesisBaseplate", Tower = "TowerBaseplate",
    God = "Playtime", Bigbang = "Temple", Void = "Void", Cycle = "Cycle", Space = "GroundSpace",
}

local worldHasClick = {Spawn = true}

local function loop(key, fn)
    table.insert(threads, task.spawn(function()
        while getgenv().UUT_RUNNING do
            if toggles[key] then pcall(fn) else task.wait(0.3) end
        end
    end))
end

--------------------------------------------------------------
-- GUI SHELL
--------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "UUTHub"
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

local BgImage = Instance.new("ImageLabel")
BgImage.Name = "BgImage"
BgImage.Size = UDim2.new(1, 0, 1, 0)
BgImage.BackgroundTransparency = 1
BgImage.ImageTransparency = 1
BgImage.ScaleType = Enum.ScaleType.Crop
BgImage.ZIndex = 0
BgImage.Parent = Main

local BgOverlay = Instance.new("Frame")
BgOverlay.Size = UDim2.new(1, 0, 1, 0)
BgOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BgOverlay.BackgroundTransparency = 1
BgOverlay.ZIndex = 0
BgOverlay.BorderSizePixel = 0
BgOverlay.Parent = Main

local SakuraContainer = Instance.new("Frame")
SakuraContainer.Size = UDim2.new(1, 0, 1, 0)
SakuraContainer.BackgroundTransparency = 1
SakuraContainer.ClipsDescendants = true
SakuraContainer.ZIndex = 1
SakuraContainer.Parent = Main

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
TitleLbl.Text = "UUT Hub"
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 16
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 7
TitleLbl.Parent = TopBar
bnd(TitleLbl, {TextColor3 = "accent"})

local VerLbl = Instance.new("TextLabel")
VerLbl.Size = UDim2.new(0, 40, 0, 14)
VerLbl.Position = UDim2.new(0, 90, 0.5, -7)
VerLbl.BackgroundTransparency = 1
VerLbl.Text = "v7"
VerLbl.Font = Enum.Font.Gotham
VerLbl.TextSize = 10
VerLbl.ZIndex = 7
VerLbl.TextXAlignment = Enum.TextXAlignment.Left
VerLbl.Parent = TopBar
bnd(VerLbl, {TextColor3 = "dim"})

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
    getgenv().UUT_RUNNING = false
    task.wait(0.15)
    for _, t in ipairs(threads) do pcall(task.cancel, t) end
    Gui:Destroy()
end)

--------------------------------------------------------------
-- RIGHT TAB BAR
--------------------------------------------------------------
local TAB_W = 90
local tabNames = {"Home", "World", "Teleport", "Player", "Misc"}

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
-- SAKURA PETALS
--------------------------------------------------------------
local petalColors = {
    Color3.fromRGB(255, 183, 197),
    Color3.fromRGB(255, 160, 180),
    Color3.fromRGB(248, 200, 220),
    Color3.fromRGB(255, 140, 170),
    Color3.fromRGB(255, 210, 225),
}

local function spawnPetal()
    if not sakuraEnabled or not getgenv().UUT_RUNNING then return end
    local petal = Instance.new("TextLabel")
    petal.Text = "*"
    petal.TextSize = math.random(10, 20)
    petal.Font = Enum.Font.SourceSansBold
    petal.TextColor3 = petalColors[math.random(1, #petalColors)]
    petal.BackgroundTransparency = 1
    petal.Size = UDim2.new(0, 20, 0, 20)
    petal.ZIndex = 1
    petal.TextTransparency = math.random(20, 50) / 100
    petal.Rotation = math.random(0, 360)
    local startX = math.random(0, 100) / 100
    petal.Position = UDim2.new(startX, 0, -0.05, 0)
    petal.Parent = SakuraContainer
    local duration = math.random(30, 60) / 10
    local endX = startX + math.random(-20, 20) / 100
    local t1 = TS:Create(petal, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Position = UDim2.new(endX, 0, 1.1, 0),
        Rotation = petal.Rotation + math.random(-180, 180),
        TextTransparency = 0.8
    })
    t1:Play()
    t1.Completed:Connect(function() petal:Destroy() end)
end

table.insert(threads, task.spawn(function()
    while getgenv().UUT_RUNNING do
        if sakuraEnabled then for _ = 1, 2 do spawnPetal() end task.wait(0.3)
        else task.wait(0.5) end
    end
end))

--------------------------------------------------------------
-- UI ELEMENT FACTORIES
--------------------------------------------------------------
local ords = {}
for _, n in ipairs(tabNames) do ords[n] = 0 end
local function nxt(t) ords[t] = ords[t] + 1 return ords[t] end

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

local function mkSlider(tab, name, mn, mx, def, cb, parent)
    local h = Instance.new("Frame")
    h.LayoutOrder = nxt(tab)
    h.Size = UDim2.new(1, 0, 0, 50)
    h.BorderSizePixel = 0
    h.ZIndex = 2
    h.Parent = parent or tabPages[tab]
    bnd(h, {BackgroundColor3 = "card"})
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 20)
    l.Position = UDim2.new(0, 14, 0, 4)
    l.BackgroundTransparency = 1
    l.Text = name .. "  " .. def
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = h
    bnd(l, {TextColor3 = "text"})

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -28, 0, 5)
    bg.Position = UDim2.new(0, 14, 0, 35)
    bg.BorderSizePixel = 0
    bg.ZIndex = 3
    bg.Parent = h
    bnd(bg, {BackgroundColor3 = "off"})
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local fl = Instance.new("Frame")
    fl.Size = UDim2.new((def - mn) / (mx - mn), 0, 1, 0)
    fl.BorderSizePixel = 0
    fl.ZIndex = 4
    fl.Parent = bg
    bnd(fl, {BackgroundColor3 = "accent"})
    Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((def - mn) / (mx - mn), 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    knob.Parent = bg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1, 0, 0, 26)
    hit.Position = UDim2.new(0, 0, 0, 22)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.ZIndex = 5
    hit.Parent = h

    local sliding = false
    local val = def

    local function upd(input)
        local x = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        val = math.floor(mn + x * (mx - mn))
        fl.Size = UDim2.new(x, 0, 1, 0)
        knob.Position = UDim2.new(x, 0, 0.5, 0)
        l.Text = name .. "  " .. val
        if cb then cb(val) end
    end

    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true upd(i) end
    end)
    hit.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)

    return function() return val end
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
        while getgenv().UUT_RUNNING do l.Text = "  " .. fn() task.wait(1) end
    end))
end

--------------------------------------------------------------
-- SMART TP
--------------------------------------------------------------
local function smartTP(worldName)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local zoneName = worldTPZones[worldName]
    local pos
    if zoneName then
        local zone = workspace:FindFirstChild(zoneName)
        if zone then
            for _, v in pairs(zone:GetDescendants()) do
                if v:IsA("BasePart") and v:GetAttribute("isZoneBlock") then
                    pos = v.Position
                    break
                end
            end
            if not pos then
                local p = zone:IsA("BasePart") and zone or zone:FindFirstChildWhichIsA("BasePart", true)
                if p then pos = p.Position end
            end
        end
    end

    if not pos then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v:GetAttribute("isZoneBlock") and v.Parent and v.Parent.Name == zoneName then
                pos = v.Position
                break
            end
        end
    end

    if pos then
        pcall(function() LP:RequestStreamAroundAsync(pos, 10) end)
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
    pcall(function() Remotes.ChangeWorld:FireServer(worldName) end)
end

--------------------------------------------------------------
-- HOME TAB
--------------------------------------------------------------
local Card = Instance.new("Frame")
Card.LayoutOrder = nxt("Home")
Card.Size = UDim2.new(1, 0, 0, 82)
Card.BorderSizePixel = 0
Card.ZIndex = 2
Card.Parent = tabPages.Home
bnd(Card, {BackgroundColor3 = "card"})
Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

local AviRing = Instance.new("Frame")
AviRing.Size = UDim2.new(0, 60, 0, 60)
AviRing.Position = UDim2.new(0, 10, 0.5, -30)
AviRing.BorderSizePixel = 0
AviRing.ZIndex = 3
AviRing.Parent = Card
bnd(AviRing, {BackgroundColor3 = "accent"})
Instance.new("UICorner", AviRing).CornerRadius = UDim.new(1, 0)

local Avi = Instance.new("ImageLabel")
Avi.Size = UDim2.new(0, 54, 0, 54)
Avi.Position = UDim2.new(0.5, -27, 0.5, -27)
Avi.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Avi.BorderSizePixel = 0
Avi.ZIndex = 4
Avi.Parent = AviRing
Instance.new("UICorner", Avi).CornerRadius = UDim.new(1, 0)
pcall(function()
    Avi.Image = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
end)

local Nm = Instance.new("TextLabel")
Nm.Size = UDim2.new(1, -90, 0, 20)
Nm.Position = UDim2.new(0, 80, 0, 12)
Nm.BackgroundTransparency = 1
Nm.Text = LP.DisplayName
Nm.Font = Enum.Font.GothamBold
Nm.TextSize = 16
Nm.TextXAlignment = Enum.TextXAlignment.Left
Nm.ZIndex = 3
Nm.Parent = Card
bnd(Nm, {TextColor3 = "text"})

local Un = Instance.new("TextLabel")
Un.Size = UDim2.new(1, -90, 0, 14)
Un.Position = UDim2.new(0, 80, 0, 33)
Un.BackgroundTransparency = 1
Un.Text = "@" .. LP.Name .. "  |  ID: " .. LP.UserId
Un.Font = Enum.Font.Gotham
Un.TextSize = 10
Un.TextXAlignment = Enum.TextXAlignment.Left
Un.ZIndex = 3
Un.Parent = Card
bnd(Un, {TextColor3 = "sub"})

local Wl = Instance.new("TextLabel")
Wl.Size = UDim2.new(1, -90, 0, 12)
Wl.Position = UDim2.new(0, 80, 0, 52)
Wl.BackgroundTransparency = 1
Wl.Font = Enum.Font.Gotham
Wl.TextSize = 10
Wl.TextXAlignment = Enum.TextXAlignment.Left
Wl.ZIndex = 3
Wl.Parent = Card
bnd(Wl, {TextColor3 = "dim"})
table.insert(threads, task.spawn(function()
    while getgenv().UUT_RUNNING do
        Wl.Text = "World: " .. (PD:FindFirstChild("WorldIn") and PD.WorldIn.Value or "?") .. "  |  Loop: " .. (PD:FindFirstChild("Loop") and PD.Loop.Value or "?")
        task.wait(1)
    end
end))

mkSpacer("Home", 4)
mkLabel("Home", "LIVE STATS")

mkInfo("Home", function()
    return "Loop: " .. (PD:FindFirstChild("Loop") and PD.Loop.Value or 0) .. "  |  Supernova: " .. (PD:FindFirstChild("SupernovaMilestone") and PD.SupernovaMilestone.Value or 0)
end)
mkInfo("Home", function()
    return "Cycle: " .. (PD:FindFirstChild("Cycle") and PD.Cycle.Value or 0) .. "  |  Stage: " .. (PD:FindFirstChild("Stage") and PD.Stage.Value or 0)
end)
mkInfo("Home", function()
    return "Ping: " .. math.floor(LP:GetNetworkPing() * 1000) .. "ms  |  FPS: " .. math.floor(1 / RunService.RenderStepped:Wait())
end)
mkInfo("Home", function()
    return "Players: " .. #Players:GetPlayers() .. "  |  Server: " .. string.sub(game.JobId, 1, 8) .. "..."
end)

mkSpacer("Home", 4)
mkLabel("Home", "SESSION STATS")

mkInfo("Home", function()
    local elapsed = os.clock() - sessionStart
    local h = math.floor(elapsed / 3600)
    local m = math.floor((elapsed % 3600) / 60)
    local s = math.floor(elapsed % 60)
    return "Session: " .. string.format("%02d:%02d:%02d", h, m, s)
end)
mkInfo("Home", function()
    return "Upgrades Bought: " .. statsUpgBought .. "  |  Rebirths: " .. statsRebirths
end)

--------------------------------------------------------------
-- TELEPORT TAB
--------------------------------------------------------------
mkLabel("Teleport", "QUICK TELEPORT")

for _, wName in ipairs(worldList) do
    local tpB = Instance.new("TextButton")
    tpB.LayoutOrder = nxt("Teleport")
    tpB.Size = UDim2.new(1, 0, 0, 34)
    tpB.Text = ""
    tpB.BorderSizePixel = 0
    tpB.ZIndex = 2
    tpB.AutoButtonColor = false
    tpB.Parent = tabPages.Teleport
    bnd(tpB, {BackgroundColor3 = "card"})
    Instance.new("UICorner", tpB).CornerRadius = UDim.new(0, 8)

    local tpL = Instance.new("TextLabel")
    tpL.Size = UDim2.new(1, -20, 1, 0)
    tpL.Position = UDim2.new(0, 14, 0, 0)
    tpL.BackgroundTransparency = 1
    tpL.Text = wName
    tpL.Font = Enum.Font.GothamBold
    tpL.TextSize = 13
    tpL.TextXAlignment = Enum.TextXAlignment.Left
    tpL.ZIndex = 3
    tpL.Parent = tpB
    bnd(tpL, {TextColor3 = "text"})

    local tpArr = Instance.new("TextLabel")
    tpArr.Size = UDim2.new(0, 20, 1, 0)
    tpArr.Position = UDim2.new(1, -28, 0, 0)
    tpArr.BackgroundTransparency = 1
    tpArr.Text = ">"
    tpArr.Font = Enum.Font.GothamBold
    tpArr.TextSize = 14
    tpArr.ZIndex = 3
    tpArr.Parent = tpB
    bnd(tpArr, {TextColor3 = "dim"})

    tpB.MouseButton1Click:Connect(function()
        tw(tpB, {BackgroundColor3 = C.accent}, 0.08)
        task.delay(0.3, function() tw(tpB, {BackgroundColor3 = C.card}, 0.2) end)
        smartTP(wName)
    end)
    tpB.MouseEnter:Connect(function() tw(tpB, {BackgroundColor3 = C.cardH}, 0.12) end)
    tpB.MouseLeave:Connect(function() tw(tpB, {BackgroundColor3 = C.card}, 0.12) end)
end

--------------------------------------------------------------
-- WORLD TAB (world list + per-world sub-pages)
--------------------------------------------------------------
-- World list page (the main scrolling frame for World tab)
local worldListPage = tabPages.World

-- Container for each world's sub-page (overlays the World tab content)
local worldSubPages = {}

-- Create sub-page frames (hidden by default, shown when a world is selected)
for _, wName in ipairs(worldList) do
    local sub = Instance.new("ScrollingFrame")
    sub.Name = "Sub_" .. wName
    sub.Size = UDim2.new(1, -16, 1, -12)
    sub.Position = UDim2.new(0, 10, 0, 6)
    sub.BackgroundTransparency = 1
    sub.ScrollBarThickness = 3
    sub.CanvasSize = UDim2.new(0, 0, 0, 0)
    sub.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sub.Visible = false
    sub.BorderSizePixel = 0
    sub.ZIndex = 3
    sub.Parent = Content
    bnd(sub, {ScrollBarImageColor3 = "accent"})

    local lay = Instance.new("UIListLayout", sub)
    lay.Padding = UDim.new(0, 5)
    lay.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", sub)
    pad.PaddingTop = UDim.new(0, 2)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 6)

    worldSubPages[wName] = sub
end

local function openWorldSub(wName)
    activeWorld = wName
    worldListPage.Visible = false
    for n, sp in pairs(worldSubPages) do sp.Visible = (n == wName) end
end

local function closeWorldSub()
    activeWorld = nil
    for _, sp in pairs(worldSubPages) do sp.Visible = false end
    worldListPage.Visible = true
end

-- Override switchTab to also close world sub-pages
local origSwitchTab = switchTab
switchTab = function(name)
    -- Hide all world sub-pages when switching tabs
    for _, sp in pairs(worldSubPages) do sp.Visible = false end
    activeWorld = nil
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

-- Re-bind tab buttons to updated switchTab
for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- Build the world list buttons
mkLabel("World", "SELECT WORLD")

for _, wName in ipairs(worldList) do
    local b = Instance.new("TextButton")
    b.LayoutOrder = nxt("World")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.Text = ""
    b.BorderSizePixel = 0
    b.ZIndex = 2
    b.AutoButtonColor = false
    b.Parent = worldListPage
    bnd(b, {BackgroundColor3 = "card"})
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -40, 0, 18)
    l.Position = UDim2.new(0, 14, 0, 4)
    l.BackgroundTransparency = 1
    l.Text = wName
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = b
    bnd(l, {TextColor3 = "text"})

    if worldDisplayCurrencies[wName] then
        local currPrev = Instance.new("TextLabel")
        currPrev.Size = UDim2.new(1, -44, 0, 14)
        currPrev.Position = UDim2.new(0, 14, 0, 20)
        currPrev.BackgroundTransparency = 1
        currPrev.Text = worldDisplayCurrencies[wName]
        currPrev.Font = Enum.Font.Gotham
        currPrev.TextSize = 9
        currPrev.TextXAlignment = Enum.TextXAlignment.Left
        currPrev.TextTruncate = Enum.TextTruncate.AtEnd
        currPrev.ZIndex = 3
        currPrev.Parent = b
        bnd(currPrev, {TextColor3 = "dim"})
    end

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -28, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = ">"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    arrow.ZIndex = 3
    arrow.Parent = b
    bnd(arrow, {TextColor3 = "dim"})

    b.MouseButton1Click:Connect(function()
        tw(b, {BackgroundColor3 = C.accent}, 0.08)
        task.delay(0.15, function() tw(b, {BackgroundColor3 = C.card}, 0.2) end)
        openWorldSub(wName)
    end)
    b.MouseEnter:Connect(function() tw(b, {BackgroundColor3 = C.cardH}, 0.12) end)
    b.MouseLeave:Connect(function() tw(b, {BackgroundColor3 = C.card}, 0.12) end)
end

-- Helper: create a toggle inside a sub-page with a custom key
local function mkSubToggle(sub, displayName, key)
    toggles[key] = false
    local h = Instance.new("Frame")
    h.LayoutOrder = nxt("World")
    h.Size = UDim2.new(1, 0, 0, 36)
    h.BorderSizePixel = 0
    h.ZIndex = 3
    h.Parent = sub
    bnd(h, {BackgroundColor3 = "card"})
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -56, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = displayName
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 4
    l.Parent = h
    bnd(l, {TextColor3 = "text"})

    local tr = Instance.new("TextButton")
    tr.Size = UDim2.new(0, 38, 0, 20)
    tr.Position = UDim2.new(1, -48, 0.5, -10)
    tr.Text = ""
    tr.BorderSizePixel = 0
    tr.ZIndex = 4
    tr.AutoButtonColor = false
    tr.Parent = h
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)

    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0, 16, 0, 16)
    kn.Position = UDim2.new(0, 2, 0.5, -8)
    kn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    kn.BorderSizePixel = 0
    kn.ZIndex = 5
    kn.Parent = tr
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)

    local function ref()
        local on = toggles[key]
        tw(tr, {BackgroundColor3 = on and C.on or C.off}, 0.2)
        tw(kn, {Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
    end
    ref()
    table.insert(togRefresh, ref)

    tr.MouseButton1Click:Connect(function()
        toggles[key] = not toggles[key]
        ref()
    end)

    h.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then tw(h, {BackgroundColor3 = C.cardH}, 0.12) end end)
    h.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then tw(h, {BackgroundColor3 = C.card}, 0.12) end end)
end

-- Build each world's sub-page content
for _, wName in ipairs(worldList) do
    local sub = worldSubPages[wName]
    local buyKey = "AutoBuy_" .. wName
    local clickKey = "AutoClick_" .. wName

    -- Back button
    local back = Instance.new("TextButton")
    back.LayoutOrder = 0
    back.Size = UDim2.new(0, 70, 0, 28)
    back.Text = ""
    back.BorderSizePixel = 0
    back.ZIndex = 3
    back.AutoButtonColor = false
    back.Parent = sub
    bnd(back, {BackgroundColor3 = "card"})
    Instance.new("UICorner", back).CornerRadius = UDim.new(0, 8)

    local backLbl = Instance.new("TextLabel")
    backLbl.Size = UDim2.new(1, 0, 1, 0)
    backLbl.BackgroundTransparency = 1
    backLbl.Text = "< Back"
    backLbl.Font = Enum.Font.GothamBold
    backLbl.TextSize = 11
    backLbl.ZIndex = 4
    backLbl.Parent = back
    bnd(backLbl, {TextColor3 = "accent"})

    back.MouseButton1Click:Connect(function() closeWorldSub() end)
    back.MouseEnter:Connect(function() tw(back, {BackgroundColor3 = C.cardH}, 0.12) end)
    back.MouseLeave:Connect(function() tw(back, {BackgroundColor3 = C.card}, 0.12) end)

    -- World title
    local title = Instance.new("TextLabel")
    title.LayoutOrder = 1
    title.Size = UDim2.new(1, 0, 0, 28)
    title.BackgroundTransparency = 1
    title.Text = "  " .. wName
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 3
    title.Parent = sub
    bnd(title, {TextColor3 = "text"})

    -- Currency info
    if worldDisplayCurrencies[wName] then
        local cInfo = Instance.new("TextLabel")
        cInfo.LayoutOrder = 2
        cInfo.Size = UDim2.new(1, 0, 0, 22)
        cInfo.BackgroundTransparency = 1
        cInfo.Text = "  " .. worldDisplayCurrencies[wName]
        cInfo.Font = Enum.Font.Gotham
        cInfo.TextSize = 11
        cInfo.TextXAlignment = Enum.TextXAlignment.Left
        cInfo.ZIndex = 3
        cInfo.TextWrapped = true
        cInfo.AutomaticSize = Enum.AutomaticSize.Y
        cInfo.Parent = sub
        bnd(cInfo, {TextColor3 = "sub"})
    end

    local farmTitle = Instance.new("TextLabel")
    farmTitle.LayoutOrder = nxt("World")
    farmTitle.Size = UDim2.new(1, 0, 0, 20)
    farmTitle.BackgroundTransparency = 1
    farmTitle.Text = "  AUTO FARM"
    farmTitle.Font = Enum.Font.GothamBold
    farmTitle.TextSize = 11
    farmTitle.TextXAlignment = Enum.TextXAlignment.Left
    farmTitle.ZIndex = 3
    farmTitle.Parent = sub
    bnd(farmTitle, {TextColor3 = "accent"})

    -- Auto Click toggle (only for Spawn)
    if worldHasClick[wName] then
        mkSubToggle(sub, "Auto Click", clickKey)
        loop(clickKey, function() Remotes.Clicker:FireServer() task.wait(0.05) end)
    end

    -- Auto Buy toggle
    mkSubToggle(sub, "Auto Buy Upgrades", buyKey)

    -- Prestige toggles for this world
    if worldPrestige[wName] then
        local pSpacer = Instance.new("Frame")
        pSpacer.LayoutOrder = nxt("World")
        pSpacer.Size = UDim2.new(1, 0, 0, 4)
        pSpacer.BackgroundTransparency = 1
        pSpacer.Parent = sub

        local pTitle = Instance.new("TextLabel")
        pTitle.LayoutOrder = nxt("World")
        pTitle.Size = UDim2.new(1, 0, 0, 20)
        pTitle.BackgroundTransparency = 1
        pTitle.Text = "  REBIRTH"
        pTitle.Font = Enum.Font.GothamBold
        pTitle.TextSize = 11
        pTitle.TextXAlignment = Enum.TextXAlignment.Left
        pTitle.ZIndex = 3
        pTitle.Parent = sub
        bnd(pTitle, {TextColor3 = "accent"})

        for _, pInfo in ipairs(worldPrestige[wName]) do
            mkSubToggle(sub, pInfo.name, pInfo.name)
            loop(pInfo.name, function()
                pcall(pInfo.fn)
                statsRebirths = statsRebirths + 1
            end)
        end
    end

    -- Auto Buy loop (faster: 0.1s between rounds)
    loop(buyKey, function()
        local ids = worldUpgrades[wName] or {}
        if #ids == 0 then task.wait(0.5) return end
        for _, id in ipairs(ids) do
            if not getgenv().UUT_RUNNING or not toggles[buyKey] then break end
            local ok = pcall(Remotes.BuyUpg.FireServer, Remotes.BuyUpg, id)
            if ok then statsUpgBought = statsUpgBought + 1 end
        end
        task.wait(0.1)
    end)
end

--------------------------------------------------------------
-- PLAYER TAB
--------------------------------------------------------------
mkLabel("Player", "CHARACTER")

local getWS = mkSlider("Player", "Walk Speed", 16, 500, 16, function(v)
    local c = LP.Character if c then local h = c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = v end end
end)
local getJP = mkSlider("Player", "Jump Power", 50, 500, 50, function(v)
    local c = LP.Character if c then local h = c:FindFirstChildOfClass("Humanoid") if h then h.JumpPower = v end end
end)

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        local w, j = getWS(), getJP()
        if w > 16 then hum.WalkSpeed = w end
        if j > 50 then hum.JumpPower = j end
    end
end)

--------------------------------------------------------------
-- MISC TAB
--------------------------------------------------------------
mkLabel("Misc", "AUTO")

mkToggle("Misc", "Auto Daily Reward")
loop("Auto Daily Reward", function()
    local last = PD:FindFirstChild("LastTimeClaimed")
    if last and (last.Value == 0 or os.time() - last.Value >= 43200) then Remotes.Daily:FireServer() end
    task.wait(30)
end)

mkSpacer("Misc", 4)
mkLabel("Misc", "EFFECTS")

mkToggle("Misc", "Sakura Petals", function(on)
    sakuraEnabled = on
    if not on then
        for _, c in pairs(SakuraContainer:GetChildren()) do c:Destroy() end
    end
end)

mkSpacer("Misc", 4)
mkLabel("Misc", "UI APPEARANCE")

mkSlider("Misc", "Background Opacity", 0, 100, 100, function(v)
    uiAlpha = 1 - v / 100
    Main.BackgroundTransparency = uiAlpha
    TopBar.BackgroundTransparency = uiAlpha
    TabPanel.BackgroundTransparency = uiAlpha
end)

mkSpacer("Misc", 3)
mkLabel("Misc", "CUSTOM BACKGROUND")

local function resolveImage(id)
    local ok, objs = pcall(function() return game:GetObjects("rbxassetid://" .. id) end)
    if ok and objs and objs[1] then
        local obj = objs[1]
        if obj:IsA("Decal") or obj:IsA("Texture") then
            return obj.Texture
        elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            return obj.Image
        elseif obj:IsA("Shirt") then
            return obj.ShirtTemplate
        elseif obj:IsA("Pants") then
            return obj.PantsTemplate
        end
    end
    return "rbxassetid://" .. id
end

local function setBg(id)
    task.spawn(function()
        local img = resolveImage(id)
        BgImage.Image = img
        BgImage.ImageTransparency = 0
        BgOverlay.BackgroundTransparency = 0.55
    end)
end

do
    local inputH = Instance.new("Frame")
    inputH.LayoutOrder = nxt("Misc")
    inputH.Size = UDim2.new(1, 0, 0, 36)
    inputH.BorderSizePixel = 0
    inputH.ZIndex = 2
    inputH.Parent = tabPages.Misc
    bnd(inputH, {BackgroundColor3 = "card"})
    Instance.new("UICorner", inputH).CornerRadius = UDim.new(0, 8)

    local inputLbl = Instance.new("TextLabel")
    inputLbl.Size = UDim2.new(0, 80, 1, 0)
    inputLbl.Position = UDim2.new(0, 10, 0, 0)
    inputLbl.BackgroundTransparency = 1
    inputLbl.Text = "Image ID:"
    inputLbl.Font = Enum.Font.Gotham
    inputLbl.TextSize = 11
    inputLbl.TextXAlignment = Enum.TextXAlignment.Left
    inputLbl.ZIndex = 3
    inputLbl.Parent = inputH
    bnd(inputLbl, {TextColor3 = "sub"})

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -100, 0, 26)
    inputBox.Position = UDim2.new(0, 85, 0.5, -13)
    inputBox.PlaceholderText = "rbxassetid://123456789"
    inputBox.Text = ""
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 11
    inputBox.BorderSizePixel = 0
    inputBox.ClearTextOnFocus = false
    inputBox.ZIndex = 3
    inputBox.Parent = inputH
    bnd(inputBox, {BackgroundColor3 = "cardH", TextColor3 = "text", PlaceholderColor3 = "dim"})
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

    local inputPad = Instance.new("UIPadding")
    inputPad.PaddingLeft = UDim.new(0, 8)
    inputPad.Parent = inputBox

    inputBox.FocusLost:Connect(function(enter)
        if enter then
            local id = inputBox.Text
            if id == "" then
                BgImage.ImageTransparency = 1
                BgOverlay.BackgroundTransparency = 1
            else
                id = id:gsub("rbxassetid://", "")
                setBg(id)
            end
        end
    end)
end

mkSpacer("Misc", 2)
mkLabel("Misc", "PRESETS")

local presets = {
    {id = "11176073582", name = "Preset 1"},
    {id = "1049060234",  name = "Preset 2"},
    {id = "1235887402",  name = "Preset 3"},
    {id = "5304470581",  name = "Preset 4"},
    {id = "1288557127",  name = "Preset 5"},
}
for _, p in ipairs(presets) do
    mkButton("Misc", p.name .. "  [" .. p.id .. "]", function() setBg(p.id) end)
end

mkSlider("Misc", "BG Dim", 0, 90, 55, function(v)
    BgOverlay.BackgroundTransparency = 1 - v / 100
end)

mkButton("Misc", "Clear Background", function()
    BgImage.Image = ""
    BgImage.ImageTransparency = 1
    BgOverlay.BackgroundTransparency = 1
end)

mkSpacer("Misc", 4)
mkLabel("Misc", "THEME")

for _, theme in ipairs(ThemeList) do
    local b = Instance.new("TextButton")
    b.LayoutOrder = nxt("Misc")
    b.Size = UDim2.new(1, 0, 0, 36)
    b.Text = ""
    b.BorderSizePixel = 0
    b.ZIndex = 2
    b.AutoButtonColor = false
    b.Parent = tabPages.Misc
    bnd(b, {BackgroundColor3 = "card"})
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local dot1 = Instance.new("Frame")
    dot1.Size = UDim2.new(0, 18, 0, 18)
    dot1.Position = UDim2.new(0, 10, 0.5, -9)
    dot1.BackgroundColor3 = theme.accent
    dot1.BorderSizePixel = 0
    dot1.ZIndex = 3
    dot1.Parent = b
    Instance.new("UICorner", dot1).CornerRadius = UDim.new(1, 0)

    local dot2 = Instance.new("Frame")
    dot2.Size = UDim2.new(0, 12, 0, 12)
    dot2.Position = UDim2.new(0, 34, 0.5, -6)
    dot2.BackgroundColor3 = theme.card
    dot2.BorderSizePixel = 0
    dot2.ZIndex = 3
    dot2.Parent = b
    Instance.new("UICorner", dot2).CornerRadius = UDim.new(0, 4)

    local dot3 = Instance.new("Frame")
    dot3.Size = UDim2.new(0, 12, 0, 12)
    dot3.Position = UDim2.new(0, 50, 0.5, -6)
    dot3.BackgroundColor3 = theme.bg
    dot3.BorderSizePixel = 0
    dot3.ZIndex = 3
    dot3.Parent = b
    Instance.new("UICorner", dot3).CornerRadius = UDim.new(0, 4)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -80, 1, 0)
    l.Position = UDim2.new(0, 70, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = theme.name
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = b
    bnd(l, {TextColor3 = "text"})

    local chk = Instance.new("TextLabel")
    chk.Name = "chk"
    chk.Size = UDim2.new(0, 20, 1, 0)
    chk.Position = UDim2.new(1, -28, 0, 0)
    chk.BackgroundTransparency = 1
    chk.Font = Enum.Font.GothamBold
    chk.TextSize = 16
    chk.Text = (theme.name == C.name) and "•" or ""
    chk.ZIndex = 3
    chk.Parent = b
    bnd(chk, {TextColor3 = "accent"})

    b.MouseButton1Click:Connect(function()
        C = theme
        applyTheme()
        for _, child in pairs(tabPages.Misc:GetChildren()) do
            if child:IsA("TextButton") then
                local ck = child:FindFirstChild("chk")
                if ck then
                    local nameLabel
                    for _, s in pairs(child:GetChildren()) do
                        if s:IsA("TextLabel") and s ~= ck and s.TextXAlignment == Enum.TextXAlignment.Left then nameLabel = s break end
                    end
                    ck.Text = (nameLabel and nameLabel.Text == theme.name) and "•" or ""
                end
            end
        end
        Main.BackgroundTransparency = uiAlpha
        TopBar.BackgroundTransparency = uiAlpha
        TabPanel.BackgroundTransparency = uiAlpha
        local prev = activeTab
        activeTab = nil
        switchTab(prev)
    end)

    b.MouseEnter:Connect(function() tw(b, {BackgroundColor3 = C.cardH}, 0.12) end)
    b.MouseLeave:Connect(function() tw(b, {BackgroundColor3 = C.card}, 0.12) end)
end

mkSpacer("Misc", 4)
mkLabel("Misc", "WINDOW")
mkButton("Misc", "Reset Size & Position", function()
    tw(Main, {Size = UDim2.new(0, 520, 0, 380), Position = UDim2.new(0.5, -260, 0.5, -190)}, 0.3)
end)

--------------------------------------------------------------
-- KEYBIND: RightShift toggle
--------------------------------------------------------------
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

--------------------------------------------------------------
-- INIT
--------------------------------------------------------------
switchTab("Home")

Main.Size = UDim2.new(0, 520, 0, 0)
Main.BackgroundTransparency = 1
tw(Main, {Size = UDim2.new(0, 520, 0, 380), BackgroundTransparency = 0}, 0.45)

print("[UUT Hub] v7 loaded | RightShift to toggle")
