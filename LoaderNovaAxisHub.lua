local games = {
    [8243510333] = "Steal%20A%20Femboy/Main.lua",
    [8483837377] = "Steal%20a%2099%20Nights/Main.lua",
    [8170321325] = "Steal%20A%20Cat/Main.lua",
    [8166233521] = "Survive%20On%20A%20Raft/Main.lua"
    [994732206] = "Blox%20Fruits/Main.lua",
    [7738927312] = "Build%20A%20Bunker/Main.lua"
}

local url = games[game.GameId]
if url then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NovaAxis/Scripts/refs/heads/main/Game/"..url))()
end
