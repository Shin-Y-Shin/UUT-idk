--[[
    ShinyHub — Universal Roblox Script Hub
    One loadstring, auto-detects your game
]]

local REPO = "https://raw.githubusercontent.com/Shin-Y-Shin/UUT-idk/main/Games/"

local SupportedGames = {
    [113814738390716] = {name = "Untitled Upgrade Tree", file = "UUT.lua"},
}

local placeId = game.PlaceId
local gameData = SupportedGames[placeId]

if gameData then
    local url = REPO .. gameData.file
    local ok, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if not ok then
        warn("[ShinyHub] Failed to load " .. gameData.name .. ": " .. tostring(err))
    end
else
    -- Game not supported — show a notification
    local Players = game:GetService("Players")
    local LP = Players.LocalPlayer
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
