--[[
    ShinyHub — Universal Roblox Script Hub
    One loadstring, auto-detects your game
]]

local REPO = "https://raw.githubusercontent.com/Shin-Y-Shin/UUT-idk/main/Games/"
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local SupportedGames = {
    [113814738390716] = {name = "Untitled Upgrade Tree", file = "UUT.lua"},
    [79268393072444]  = {name = "Sell Lemons", file = "SellLemons.lua"},
}

local placeId = game.PlaceId
local gameData = SupportedGames[placeId]

--------------------------------------------------------------
-- LOADING SCREEN
--------------------------------------------------------------
local function showLoadScreen(gameName, callback)
    if PG:FindFirstChild("ShinyHubLoader") then PG:FindFirstChild("ShinyHubLoader"):Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "ShinyHubLoader"
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent = PG

    -- Dark overlay
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 100
    overlay.Parent = sg

    -- Center container
    local center = Instance.new("Frame")
    center.Size = UDim2.new(0, 320, 0, 120)
    center.Position = UDim2.new(0.5, -160, 0.5, -60)
    center.BackgroundTransparency = 1
    center.ZIndex = 101
    center.Parent = sg

    -- ShinyHub title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "ShinyHub"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 32
    title.TextColor3 = Color3.fromRGB(130, 80, 255)
    title.TextTransparency = 1
    title.ZIndex = 102
    title.Parent = center

    -- Game name subtitle
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 20)
    sub.Position = UDim2.new(0, 0, 0, 42)
    sub.BackgroundTransparency = 1
    sub.Text = "Loading " .. gameName .. "..."
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 14
    sub.TextColor3 = Color3.fromRGB(180, 180, 200)
    sub.TextTransparency = 1
    sub.ZIndex = 102
    sub.Parent = center

    -- Loading bar background
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.8, 0, 0, 6)
    barBg.Position = UDim2.new(0.1, 0, 0, 80)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    barBg.BackgroundTransparency = 1
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 102
    barBg.Parent = center
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    -- Loading bar fill
    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
    barFill.BackgroundTransparency = 1
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 103
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    -- Glow effect on bar
    local glow = Instance.new("UIGradient")
    glow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 80, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 140, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 80, 255)),
    })
    glow.Parent = barFill

    local tw = function(obj, props, dur, style)
        local t = TS:Create(obj, TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
        t:Play()
        return t
    end

    -- Fade in
    tw(title, {TextTransparency = 0}, 0.5)
    tw(sub, {TextTransparency = 0}, 0.5)
    tw(barBg, {BackgroundTransparency = 0}, 0.5)
    tw(barFill, {BackgroundTransparency = 0}, 0.5)
    task.wait(0.3)

    -- Animate loading bar
    local scriptCode = nil
    local loadDone = false

    task.spawn(function()
        local ok, result = pcall(function()
            return game:HttpGet(REPO .. gameData.file)
        end)
        if ok then
            scriptCode = result
        end
        loadDone = true
    end)

    -- Smooth bar fill while downloading
    local progress = 0
    while not loadDone do
        progress = math.min(progress + 0.02, 0.85)
        tw(barFill, {Size = UDim2.new(progress, 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear)
        task.wait(0.05)
    end

    -- Snap to 100%
    tw(barFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.3)
    task.wait(0.5)

    -- Fade out loading elements
    tw(sub, {TextTransparency = 1}, 0.3)
    tw(barBg, {BackgroundTransparency = 1}, 0.3)
    tw(barFill, {BackgroundTransparency = 1}, 0.3)
    tw(title, {TextTransparency = 1}, 0.2)
    task.wait(0.4)

    -- Big ShinyHub splash text
    local splash = Instance.new("TextLabel")
    splash.Size = UDim2.new(1, 0, 0, 80)
    splash.Position = UDim2.new(0, 0, 0.5, -40)
    splash.BackgroundTransparency = 1
    splash.Text = "ShinyHub"
    splash.Font = Enum.Font.GothamBlack
    splash.TextSize = 60
    splash.TextColor3 = Color3.fromRGB(130, 80, 255)
    splash.TextTransparency = 1
    splash.TextStrokeColor3 = Color3.fromRGB(60, 30, 140)
    splash.TextStrokeTransparency = 1
    splash.ZIndex = 105
    splash.Parent = sg

    -- Pop in with scale
    splash.TextSize = 30
    tw(splash, {TextTransparency = 0, TextStrokeTransparency = 0.7, TextSize = 60}, 0.4, Enum.EasingStyle.Back)
    task.wait(1)

    -- Fade out
    tw(splash, {TextTransparency = 1, TextStrokeTransparency = 1}, 0.6)
    tw(overlay, {BackgroundTransparency = 1}, 0.6)
    task.wait(0.7)

    sg:Destroy()

    -- Execute the script
    if scriptCode then
        local ok, err = pcall(loadstring(scriptCode))
        if not ok then
            warn("[ShinyHub] Script error: " .. tostring(err))
        end
    else
        warn("[ShinyHub] Failed to download script")
    end
end

--------------------------------------------------------------
-- MAIN
--------------------------------------------------------------
if gameData then
    showLoadScreen(gameData.name)
else
    local SG = game:GetService("StarterGui")
    pcall(function()
        SG:SetCore("SendNotification", {
            Title = "ShinyHub",
            Text = "Game not supported yet! (PlaceId: " .. tostring(placeId) .. ")",
            Duration = 8,
        })
    end)
    warn("[ShinyHub] Game not supported — PlaceId: " .. tostring(placeId))
end
