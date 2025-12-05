local HttpService = game:GetService("HttpService")

-- Load WindUI library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
WindUI:SetTheme("Indigo")
WindUI:SetFont("rbxasset://fonts/families/RobotoMono.json")

local games = {
    [8243510333] = {name = "Steal A Femboy", url = "Steal%20A%20Femboy/Main.lua"},
    [8483837377] = {name = "Steal a 99 Nights", url = "Steal%20a%2099%20Nights/Main.lua"},
    [8170321325] = {name = "Steal A Cat", url = "Steal%20A%20Cat/Main.lua"},
    [8166233521] = {name = "Survive On A Raft", url = "Survive%20On%20A%20Raft/Main.lua"},
    [994732206]  = {name = "Blox Fruits", url = "Blox%20Fruits/Main.lua"},
    [7738927312] = {name = "Build A Bunker", url = "Build%20A%20Bunker/Main.lua"},
    [3457700596] = {name = "Fruit Battlegrounds", url = "Fruit%20Battlegrounds/Main.lua"},
    [3085257211] = {name = "Rainbow Friends", url = "Rainbow%20Friends/Main.lua"},
}

local gameInfo = games[game.GameId]

if gameInfo then
    -- Notification for supported game
    WindUI:Notify({
        Title = "Game Supported!",
        Content = "Loading script for " .. gameInfo.name .. "...",
        Duration = 5,
        Icon = "circle-check",
        IconThemed = true
    })
    
    -- Small delay to show notification
    task.wait(0.5)
    
    -- Load script
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NovaAxis/Scripts/refs/heads/main/Game/" .. gameInfo.url))()
    end)
    
    if success then
        WindUI:Notify({
            Title = "Successfully Loaded!",
            Content = "Script for " .. gameInfo.name .. " is now running",
            Duration = 3,
            Icon = "circle-check",
            IconThemed = true
        })
    else
        WindUI:Notify({
            Title = "Loading Error",
            Content = "Failed to load script: " .. tostring(err),
            Duration = 5,
            Icon = "circle-x",
            IconThemed = true
        })
    end
else
    -- Notification for unsupported game
    WindUI:Notify({
        Title = "Game Not Supported",
        Content = "Unfortunately, this game is not currently supported",
        Duration = 5,
        Icon = "circle-alert",
        IconThemed = true
    })
end
