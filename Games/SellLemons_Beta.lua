--[[
    ShinyHub BETA — Sell Lemons 🍋 v7.0-beta
    Experimental features & new UI
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
if not myTycoon then warn("[ShinyHub BETA] Tycoon not found") return end

local Remotes   = myTycoon:WaitForChild("Remotes")
local Purchases = myTycoon:WaitForChild("Purchases")
local Constant  = myTycoon:WaitForChild("Constant")
local Locations = myTycoon:WaitForChild("Locations")
local Values    = myTycoon:FindFirstChild("Values")

local RS = game:GetService("ReplicatedStorage")
local RemReq = RS:FindFirstChild("Core") and RS.Core:FindFirstChild("RemoteRequest")
local CashDropRedeem = RemReq and RemReq:FindFirstChild("CashDropService") and RemReq.CashDropService:FindFirstChild("Redeem")

--------------------------------------------------------------
-- BETA THEME (dark with neon green accent)
--------------------------------------------------------------
local C = {
    name="Beta", dot=Color3.fromRGB(0,255,120), accent=Color3.fromRGB(0,255,120),
    bg=Color3.fromRGB(10,10,14), card=Color3.fromRGB(18,18,24), cardH=Color3.fromRGB(28,28,36),
    sidebar=Color3.fromRGB(14,14,18), border=Color3.fromRGB(36,36,46),
    text=Color3.fromRGB(230,230,240), sub=Color3.fromRGB(130,130,150), dim=Color3.fromRGB(70,70,90),
    on=Color3.fromRGB(0,255,120), off=Color3.fromRGB(30,30,40),
    knobOn=Color3.fromRGB(10,10,14), knobOff=Color3.fromRGB(130,130,130),
    header=Color3.fromRGB(12,12,16), section=Color3.fromRGB(8,8,10),
}

local binds = {}
local togRefresh = {}

local function tw(o, p, d, style)
    TS:Create(o, TweenInfo.new(d or 0.2, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p):Play()
end

local function bnd(obj, map)
    table.insert(binds, {o = obj, m = map})
    for prop, key in pairs(map) do obj[prop] = C[key] end
end

--------------------------------------------------------------
-- NOTIFICATION SYSTEM
--------------------------------------------------------------
local notifColors = {
    info = Color3.fromRGB(45, 140, 255),
    success = Color3.fromRGB(0, 255, 120),
    warning = Color3.fromRGB(255, 180, 30),
    error = Color3.fromRGB(255, 70, 70),
}

local PG = LP:WaitForChild("PlayerGui")
local Gui = Instance.new("ScreenGui")
Gui.Name = "SLHub"
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.ResetOnSpawn = false
pcall(function() Gui.Parent = game.CoreGui end)
if not Gui.Parent then Gui.Parent = PG end

local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0, 220, 1, 0)
NotifHolder.Position = UDim2.new(1, -230, 0, 0)
NotifHolder.BackgroundTransparency = 1
NotifHolder.ZIndex = 100
NotifHolder.Parent = Gui
local notifLayout = Instance.new("UIListLayout")
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.Padding = UDim.new(0, 4)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Parent = NotifHolder

local notifCount = 0
local function showNotif(text, nType)
    notifCount += 1
    local col = notifColors[nType or "info"] or notifColors.info
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundColor3 = C.card
    f.BorderSizePixel = 0
    f.ZIndex = 101
    f.LayoutOrder = notifCount
    f.BackgroundTransparency = 1
    f.Parent = NotifHolder
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0.6, 0)
    bar.Position = UDim2.new(0, 4, 0.2, 0)
    bar.BackgroundColor3 = col
    bar.BorderSizePixel = 0
    bar.ZIndex = 102
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.Gotham
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = C.text
    l.ZIndex = 102
    l.Parent = f
    tw(f, {BackgroundTransparency = 0}, 0.3)
    task.delay(3, function()
        tw(f, {BackgroundTransparency = 1}, 0.4)
        tw(l, {TextTransparency = 1}, 0.4)
        task.wait(0.5)
        f:Destroy()
    end)
end

--------------------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------------------
local WIN_W, WIN_H = 520, 380

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
Main.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.ZIndex = 1
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = C.header
Header.BorderSizePixel = 0
Header.ZIndex = 2
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local HeaderFill = Instance.new("Frame")
HeaderFill.Size = UDim2.new(1, 0, 0, 12)
HeaderFill.Position = UDim2.new(0, 0, 1, -12)
HeaderFill.BackgroundColor3 = C.header
HeaderFill.BorderSizePixel = 0
HeaderFill.ZIndex = 2
HeaderFill.Parent = Header

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 1, 0)
AccentLine.BackgroundColor3 = C.accent
AccentLine.BorderSizePixel = 0
AccentLine.ZIndex = 3
AccentLine.Parent = Header

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 12, 0.5, -4)
StatusDot.BackgroundColor3 = C.accent
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 4
StatusDot.Parent = Header
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0, 200, 1, 0)
TitleLbl.Position = UDim2.new(0, 26, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "ShinyHub"
TitleLbl.Font = Enum.Font.GothamBlack
TitleLbl.TextSize = 13
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.TextColor3 = C.text
TitleLbl.ZIndex = 4
TitleLbl.Parent = Header

local BetaTag = Instance.new("TextLabel")
BetaTag.Size = UDim2.new(0, 36, 0, 14)
BetaTag.Position = UDim2.new(0, 90, 0.5, -7)
BetaTag.BackgroundColor3 = C.accent
BetaTag.BackgroundTransparency = 0.15
BetaTag.Text = "BETA"
BetaTag.Font = Enum.Font.GothamBlack
BetaTag.TextSize = 8
BetaTag.TextColor3 = C.bg
BetaTag.ZIndex = 5
BetaTag.Parent = Header
Instance.new("UICorner", BetaTag).CornerRadius = UDim.new(0, 4)

local SubTitleLbl = Instance.new("TextLabel")
SubTitleLbl.Size = UDim2.new(0, 120, 1, 0)
SubTitleLbl.Position = UDim2.new(0, 130, 0, 0)
SubTitleLbl.BackgroundTransparency = 1
SubTitleLbl.Text = "Sell Lemons"
SubTitleLbl.Font = Enum.Font.Gotham
SubTitleLbl.TextSize = 10
SubTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
SubTitleLbl.TextColor3 = C.dim
SubTitleLbl.ZIndex = 4
SubTitleLbl.Parent = Header

-- Close / Minimize dots
for idx, col in ipairs({Color3.fromRGB(255, 95, 87), Color3.fromRGB(255, 189, 46), Color3.fromRGB(39, 201, 63)}) do
    local dot = Instance.new("TextButton")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(1, -14 * (4 - idx) - 6, 0.5, -5)
    dot.BackgroundColor3 = col
    dot.Text = ""
    dot.BorderSizePixel = 0
    dot.AutoButtonColor = false
    dot.ZIndex = 5
    dot.Parent = Header
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    if idx == 1 then
        dot.MouseButton1Click:Connect(function()
            getgenv().SL_RUNNING = false
            Gui:Destroy()
        end)
    elseif idx == 2 then
        local isMinimized = false
        dot.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            if isMinimized then
                tw(Main, {Size = UDim2.new(0, WIN_W, 0, 36)}, 0.3, Enum.EasingStyle.Back)
            else
                tw(Main, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.3, Enum.EasingStyle.Back)
            end
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
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

--------------------------------------------------------------
-- CONTENT AREA (simple single-page beta)
--------------------------------------------------------------
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -56)
Content.Position = UDim2.new(0, 10, 0, 44)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = C.dim
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ZIndex = 2
Content.Parent = Main

local contentLayout = Instance.new("UIListLayout")
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 4)
contentLayout.Parent = Content

local layoutOrder = 0
local function nxt() layoutOrder += 1 return layoutOrder end

--------------------------------------------------------------
-- UI HELPERS
--------------------------------------------------------------
local toggles = {}
local threads = {}

local function mkSection(txt)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 20)
    f.BackgroundTransparency = 1
    f.LayoutOrder = nxt()
    f.ZIndex = 2
    f.Parent = Content
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = string.upper(txt)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 9
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = C.accent
    l.ZIndex = 2
    l.Parent = f
end

local function mkSpacer(h)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, 0, 0, h or 4)
    s.BackgroundTransparency = 1
    s.LayoutOrder = nxt()
    s.Parent = Content
end

local function mkToggle(name, desc)
    toggles[name] = false

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = C.card
    row.BorderSizePixel = 0
    row.LayoutOrder = nxt()
    row.ZIndex = 2
    row.Parent = Content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -70, 0, 14)
    l.Position = UDim2.new(0, 12, 0, 4)
    l.BackgroundTransparency = 1
    l.Text = name
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = C.text
    l.ZIndex = 3
    l.Parent = row

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -70, 0, 10)
        d.Position = UDim2.new(0, 12, 0, 18)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.Font = Enum.Font.Gotham
        d.TextSize = 8
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextColor3 = C.dim
        d.ZIndex = 3
        d.Parent = row
    end

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 32, 0, 16)
    track.Position = UDim2.new(1, -44, 0.5, -8)
    track.BackgroundColor3 = C.off
    track.Text = ""
    track.BorderSizePixel = 0
    track.AutoButtonColor = false
    track.ZIndex = 3
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = C.knobOff
    knob.BorderSizePixel = 0
    knob.ZIndex = 4
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function ref()
        local on = toggles[name]
        tw(track, {BackgroundColor3 = on and C.on or C.off}, 0.2)
        tw(knob, {Position = on and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = on and C.knobOn or C.knobOff}, 0.2)
    end
    table.insert(togRefresh, ref)

    track.MouseButton1Click:Connect(function()
        toggles[name] = not toggles[name]
        for _, fn in ipairs(togRefresh) do pcall(fn) end
    end)

    row.MouseEnter:Connect(function() tw(row, {BackgroundColor3 = C.cardH}, 0.08) end)
    row.MouseLeave:Connect(function() tw(row, {BackgroundColor3 = C.card}, 0.1) end)
end

local function mkButton(txt, cb)
    local b = Instance.new("TextButton")
    b.LayoutOrder = nxt()
    b.Size = UDim2.new(1, 0, 0, 28)
    b.Text = ""
    b.BorderSizePixel = 0
    b.ZIndex = 2
    b.AutoButtonColor = false
    b.BackgroundColor3 = C.card
    b.Parent = Content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -30, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = C.sub
    l.ZIndex = 3
    l.Parent = b

    b.MouseButton1Click:Connect(function()
        tw(b, {BackgroundColor3 = C.accent}, 0.04)
        tw(l, {TextColor3 = C.bg}, 0.04)
        task.delay(0.12, function()
            tw(b, {BackgroundColor3 = C.card}, 0.3)
            tw(l, {TextColor3 = C.sub}, 0.3)
        end)
        if cb then cb() end
    end)
    b.MouseEnter:Connect(function() tw(b, {BackgroundColor3 = C.cardH}, 0.08) end)
    b.MouseLeave:Connect(function() tw(b, {BackgroundColor3 = C.card}, 0.1) end)
end

local function loop(key, fn)
    table.insert(threads, task.spawn(function()
        while getgenv().SL_RUNNING do
            if toggles[key] then
                pcall(fn)
            else
                task.wait(0.2)
            end
        end
    end))
end

--------------------------------------------------------------
-- BETA INFO
--------------------------------------------------------------
mkSection("Beta Program")

local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(1, 0, 0, 50)
infoFrame.BackgroundColor3 = C.card
infoFrame.BorderSizePixel = 0
infoFrame.LayoutOrder = nxt()
infoFrame.ZIndex = 2
infoFrame.Parent = Content
Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 8)

local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1, -20, 1, 0)
infoLbl.Position = UDim2.new(0, 10, 0, 0)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "Welcome to ShinyHub Beta! These features are experimental and may not work as expected. Report bugs to the ShinyHub Team."
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextSize = 10
infoLbl.TextWrapped = true
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextColor3 = C.sub
infoLbl.ZIndex = 3
infoLbl.Parent = infoFrame

mkSpacer(4)

--------------------------------------------------------------
-- BETA FEATURES
--------------------------------------------------------------
mkSection("Beta Automation")

local defaultWalkSpeed = 16
local defaultJumpPower = 50

mkToggle("Auto Collect Everything", "Collects all drops, fruit, and income at once")
loop("Auto Collect Everything", function()
    for _, r in Remotes:GetChildren() do
        if r:IsA("RemoteEvent") and (r.Name:find("Collect") or r.Name:find("Click") or r.Name:find("Income")) then
            pcall(function() r:FireServer() end)
        end
    end
    if CashDropRedeem then
        for _, drop in game.Workspace:GetDescendants() do
            if drop:IsA("BasePart") and drop.Name == "CashDrop" then
                pcall(function() CashDropRedeem:FireServer(drop) end)
            end
        end
    end
    task.wait(0.1)
end)

mkToggle("Auto Buy All Areas", "Automatically purchases area unlocks")
loop("Auto Buy All Areas", function()
    for _, area in Purchases:GetChildren() do
        local buttons = area:FindFirstChild("Buttons")
        if buttons then
            for _, item in buttons:GetDescendants() do
                if item:IsA("ClickDetector") then
                    pcall(function() fireclickdetector(item) end)
                end
            end
        end
    end
    task.wait(1)
end)

mkToggle("Smart Farm", "Combines all farming actions into one toggle")
loop("Smart Farm", function()
    for _, r in Remotes:GetChildren() do
        if r:IsA("RemoteEvent") then
            pcall(function() r:FireServer() end)
        end
    end
    task.wait(0.15)
end)

mkSpacer(4)
mkSection("Beta Visuals")

mkToggle("Matrix Rain", "Green text rain effect on screen")
local matrixGui = nil
table.insert(togRefresh, function()
    if toggles["Matrix Rain"] then
        if not matrixGui then
            matrixGui = Instance.new("ScreenGui")
            matrixGui.Name = "SH_Matrix"
            matrixGui.IgnoreGuiInset = true
            matrixGui.DisplayOrder = -1
            pcall(function() matrixGui.Parent = game.CoreGui end)
            if not matrixGui.Parent then matrixGui.Parent = PG end

            for i = 1, 30 do
                task.spawn(function()
                    while getgenv().SL_RUNNING and toggles["Matrix Rain"] do
                        local col = Instance.new("TextLabel")
                        col.Size = UDim2.new(0, 14, 0, 20)
                        col.Position = UDim2.new(math.random() * 0.95, 0, -0.05, 0)
                        col.BackgroundTransparency = 1
                        col.Text = string.char(math.random(33, 126))
                        col.Font = Enum.Font.Code
                        col.TextSize = math.random(10, 16)
                        col.TextColor3 = Color3.fromRGB(0, 255, math.random(60, 140))
                        col.TextTransparency = math.random() * 0.4
                        col.ZIndex = 1
                        col.Parent = matrixGui
                        local speed = math.random(20, 60) / 10
                        tw(col, {Position = UDim2.new(col.Position.X.Scale, 0, 1.1, 0), TextTransparency = 1}, speed, Enum.EasingStyle.Linear)
                        task.delay(speed, function() col:Destroy() end)
                        task.wait(math.random(1, 5) / 10)
                    end
                end)
            end
        end
    else
        if matrixGui then matrixGui:Destroy() matrixGui = nil end
    end
end)

mkToggle("Neon Outline", "Adds glowing outline to your character")
local outlineHighlight = nil
table.insert(togRefresh, function()
    if toggles["Neon Outline"] then
        if not outlineHighlight and LP.Character then
            outlineHighlight = Instance.new("Highlight")
            outlineHighlight.Name = "SH_NeonOutline"
            outlineHighlight.FillTransparency = 1
            outlineHighlight.OutlineColor = C.accent
            outlineHighlight.OutlineTransparency = 0
            outlineHighlight.Parent = LP.Character
        end
    else
        if outlineHighlight then outlineHighlight:Destroy() outlineHighlight = nil end
    end
end)

mkToggle("Trail Effect", "Leaves a glowing trail behind you")
local trailAttachments = {}
table.insert(togRefresh, function()
    if toggles["Trail Effect"] then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and #trailAttachments == 0 then
            local a0 = Instance.new("Attachment")
            a0.Position = Vector3.new(0, -2, 0)
            a0.Parent = hrp
            local a1 = Instance.new("Attachment")
            a1.Position = Vector3.new(0, 2, 0)
            a1.Parent = hrp
            local trail = Instance.new("Trail")
            trail.Attachment0 = a0
            trail.Attachment1 = a1
            trail.Lifetime = 0.8
            trail.MinLength = 0.1
            trail.Color = ColorSequence.new(C.accent)
            trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
            trail.LightEmission = 0.8
            trail.Parent = hrp
            trailAttachments = {a0, a1, trail}
        end
    else
        for _, obj in ipairs(trailAttachments) do pcall(function() obj:Destroy() end) end
        trailAttachments = {}
    end
end)

mkSpacer(4)
mkSection("Beta Movement")

mkToggle("Dash", "Double-tap W to dash forward")
local lastWPress = 0
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if toggles["Dash"] and input.KeyCode == Enum.KeyCode.W then
        local now = tick()
        if now - lastWPress < 0.3 then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = hrp.CFrame.LookVector * 120 + Vector3.new(0, 20, 0)
            end
            lastWPress = 0
        else
            lastWPress = now
        end
    end
end)

mkToggle("Auto Respawn", "Automatically respawns on death")
loop("Auto Respawn", function()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then
        LP.Character:BreakJoints()
        task.wait(1)
    end
    task.wait(0.5)
end)

mkSpacer(4)
mkSection("Utilities")

mkButton("Switch to Stable", function()
    showNotif("Switching to stable...", "info")
    getgenv().SL_RUNNING = false
    task.wait(0.5)
    Gui:Destroy()
    local stableUrl = "https://raw.githubusercontent.com/Shin-Y-Shin/UUT-idk/main/Games/SellLemons.lua?v=" .. tostring(os.time())
    local ok, err = pcall(function()
        loadstring(game:HttpGet(stableUrl))()
    end)
    if not ok then
        warn("[ShinyHub BETA] Stable load failed: " .. tostring(err))
    end
end)

mkButton("Rejoin Server", function()
    showNotif("Rejoining...", "info")
    task.wait(0.5)
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

mkSpacer(4)

--------------------------------------------------------------
-- STATUS BAR
--------------------------------------------------------------
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, 0, 0, 18)
StatusBar.Position = UDim2.new(0, 0, 1, -18)
StatusBar.BackgroundColor3 = C.header
StatusBar.BorderSizePixel = 0
StatusBar.ZIndex = 10
StatusBar.Parent = Main

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, -16, 1, 0)
StatusLbl.Position = UDim2.new(0, 8, 0, 0)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "ShinyHub v7.0-beta"
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 9
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.TextColor3 = C.dim
StatusLbl.ZIndex = 11
StatusLbl.Parent = StatusBar

local StatusRight = Instance.new("TextLabel")
StatusRight.Size = UDim2.new(0.5, -8, 1, 0)
StatusRight.Position = UDim2.new(0.5, 0, 0, 0)
StatusRight.BackgroundTransparency = 1
StatusRight.Text = "BETA"
StatusRight.Font = Enum.Font.GothamBold
StatusRight.TextSize = 9
StatusRight.TextXAlignment = Enum.TextXAlignment.Right
StatusRight.TextColor3 = C.accent
StatusRight.ZIndex = 11
StatusRight.Parent = StatusBar

showNotif("ShinyHub BETA loaded!", "success")
