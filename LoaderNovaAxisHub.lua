local games = {
    [8243510333] = {
        name = "Steal A Femboy",
        url = "https://raw.githubusercontent.com/NovaAxis/Scripts/refs/heads/main/Game/Steal%20A%20Femboy/Main.lua"
    },
    [8483837377] = {
        name = "Steal a 99 Nights",
        url = "https://raw.githubusercontent.com/NovaAxis/Scripts/refs/heads/main/Game/Steal%20a%2099%20Nights/Main.lua"
    },
    [8170321325] = {
        name = "Steal A Cat",
        url = "https://raw.githubusercontent.com/NovaAxis/Scripts/refs/heads/main/Game/Steal%20A%20Cat/Main.lua"
    },
    [8166233521] = {
        name = "Survive On A Raft",
        url = "https://raw.githubusercontent.com/NovaAxis/Scripts/refs/heads/main/Game/Survive%20On%20A%20Raft/Main.lua"
    },
    [994732206] = {
        name = "Blox Fruits",
        url = "https://raw.githubusercontent.com/NovaAxis/Scripts/refs/heads/main/Game/Blox%20Fruits/Main.lua"
    }
}

local function loadScript()
    local gameId = game.PlaceId
    local gameData = games[gameId]
    
    if gameData then
        print("Detected game: " .. gameData.name)
        print("Loading script...")
        
        local success, err = pcall(function()
            loadstring(game:HttpGet(gameData.url))()
        end)
        
        if success then
            print("Script loaded successfully!")
        else
            warn("Loading error: " .. tostring(err))
        end
    else
        warn("Game not supported (PlaceId: " .. gameId .. ")")
        warn("Supported games:")
        for id, data in pairs(games) do
            warn("  - " .. data.name .. " (ID: " .. id .. ")")
        end
    end
end

loadScript()
