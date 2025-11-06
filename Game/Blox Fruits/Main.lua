-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- State Variables
local isRunning = false
local noclip = false
local noclipConnection = nil
local infiniteJump = false

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create main window
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis",
    Icon = "sparkles",
    Author = "by NovaAxis | https://discord.gg/wAwgJatMMt",
    BackgroundImageTransparency = 0.45,

    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            local player = game.Players.LocalPlayer
            if player then
                local nickname = player.Name
                setclipboard(nickname)
                print("Nickname copied " .. nickname)
                
                WindUI:Notify({
                    Title = "👤 Nickname Copied",
                    Content = "Your Username '" .. nickname .. "' has been copied to the clipboard.",
                    Duration = 3,
                    Icon = "user",
                })
            else
                warn("Player not found.")
            end
        end,
    },
    HideSearchBar = false,
})

-- Customize open button
Window:EditOpenButton({
    Title = "💫 NovaAxis",
    Icon = "sparkles",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("beb4ff"), 
        Color3.fromHex("7c3aed")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

WindUI:AddTheme({
    Name = "Nova Neon",
    
    Accent = WindUI:Gradient({                                                  
        ["0"]   = { Color = Color3.fromHex("#beb4ff"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#7c3aed"), Transparency = 0 },
    }, {                                                                        
        Rotation = 90,
    }),                                                                         
    Dialog = Color3.fromHex("#121214"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#e6e6e6"),
    Placeholder = Color3.fromHex("#82828c"),
    Background = Color3.fromHex("#08080a"),
    Button = Color3.fromHex("#32283c"),
    Icon = Color3.fromHex("#beb4ff")
})

WindUI:SetTheme("Nova Neon")

Window:SetToggleKey(Enum.KeyCode.RightShift)

-- Home Tab
local HomeTab = Window:Tab({
    Title = "Home",
    Icon = "server",
    Locked = false,
})

-- Discord Section in Home Tab
local DiscordSection = HomeTab:Section({
    Title = "Join our Discord server!",
    Icon = "globe",
    Opened = true
})

DiscordSection:Paragraph({
    Title = "NovaAxis | Hub",
    Desc = "Join our Discord community :)",
    ImageSize = 64,
    Buttons = {
        {
            Title = "Copy Discord Invite",
            Icon = "link",
            Callback = function()
                setclipboard("https://discord.gg/wAwgJatMMt")
                WindUI:Notify({
                    Title = "✅ Copied",
                    Content = "Discord invite link copied to clipboard!",
                    Duration = 2,
                    Icon = "copy"
                })
            end
        }
    }
})

-- UI Library Section in Home Tab
local UISection = HomeTab:Section({
    Title = "UI Library (Author)",
    Icon = "palette",
    Opened = true
})

UISection:Button({
    Title = "GitHub Author",
    Desc = "Click to copy GitHub author link",
    Icon = "palette",
    Callback = function()
        pcall(function()
            setclipboard("https://github.com/Footagesus")
        end)
        WindUI:Notify({
            Title = "✅ Copied",
            Content = "GitHub author link copied to clipboard!",
            Duration = 3,
            Icon = "copy"
        })
    end
})

-- Main Tab
local FarmTab = Window:Tab({
    Title = "Farm",
    Icon = "wheat",
    Locked = false,
})

local MainFarmSection = FarmTab:Section({ 
    Title = "Main Farm",
    Opened = true,
})

local Toggle = MainFarmSection:Toggle({
    Title = "Auto Farm Level",
    Desc = "Level Farm",
    Icon = "arrow-big-up",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local Toggle = MainFarmSection:Toggle({
    Title = "Auto Farm Nearest",
    Desc = "Level Nearest Mobs",
    Icon = "nfc",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local Toggle = MainFarmSection:Toggle({
    Title = "Auto Factory",
    Icon = "factory",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local Toggle = MainFarmSection:Toggle({
    Title = "Auto Pirate Raid",
    Icon = "shield-alert",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local EctoplasmSection = FarmTab:Section({ 
    Title = "Ectoplasm",
    Opened = true,
})

local Toggle = EctoplasmSection:Toggle({
    Title = "Auto Farm Ectoplasm",
    Icon = "tractor",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local CollectSection = FarmTab:Section({ 
    Title = "Collect",
    Opened = true,
})

local Toggle = CollectSection:Toggle({
    Title = "Auto Chest",
    Desc = "Tween",
    Icon = "wallet-cards",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local Toggle = CollectSection:Toggle({
    Title = "Auto Collect Berries",
    Desc = "Tween",
    Icon = "grape",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local BossesSection = FarmTab:Section({ 
    Title = "Bosses",
    Opened = true,
})

local Dropdown = BossesSection:Dropdown({
    Title = "Boss List",
    Values = { "Boss 1", "Boss 2", "Boss 3" },
    Value = false, -- default value,
    Multi = false,
    AllowNone = true,
    Callback = function(option) 
        -- option is a table: { "Category A", "Category B" }
        print("Categories selected: " .. game:GetService("HttpService"):JSONEncode(option)) 
    end
})

local Toggle = BossesSection:Toggle({
    Title = "Auto Kill Boss Selected",
    Desc = "Kill boss selected",
    Icon = "id-card-lanyard",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local Toggle = BossesSection:Toggle({
    Title = "Auto Farm All Bosses",
    Desc = "Kill all Dosses spawned",
    Icon = "id-card-lanyard",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local Toggle = BossesSection:Toggle({
    Title = "Take Boss Quest",
    Icon = "circle-question-mark",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local MaterialSection = FarmTab:Section({ 
    Title = "Material",
    Opened = true,
})

local Dropdown = MaterialSection:Dropdown({
    Title = "Material List",
    Values = { "Material 1", "Material 2", "Material 3" },
    Value = false, -- default value,
    Multi = false,
    AllowNone = true,
    Callback = function(option) 
        -- option is a table: { "Category A", "Category B" }
        print("Categories selected: " .. game:GetService("HttpService"):JSONEncode(option)) 
    end
})

local Toggle = MaterialSection:Toggle({
    Title = "Auto Farm Material",
    Desc = "Farm material selected",
    Icon = "circle-question-mark",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local SeaTab = Window:Tab({
    Title = "Sea",
    Icon = "waves",
    Locked = false,
})

local FishingTab = Window:Tab({
    Title = "Fishing",
    Icon = "fish",
    Locked = false,
})

local FishingSection = FishingTab:Section({ 
    Title = "Fishing",
    Opened = true,
})


local Toggle = FishingSection:Toggle({
    Title = "Auto Fish",
    Icon = "shrimp",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local BaitSection = FishingTab:Section({ 
    Title = "Bait",
    Opened = true,
})

local Dropdown = BaitSection:Dropdown({
    Title = "Select Bait",
    Values = { "Bait 1", "Bait 2", "Bait 3" },
    Value = false, -- default value,
    Multi = false,
    AllowNone = true,
    Callback = function(option) 
        -- option is a table: { "Category A", "Category B" }
        print("Categories selected: " .. game:GetService("HttpService"):JSONEncode(option)) 
    end
})

local Slider = BaitSection:Slider({
    Title = "Max Baits",
    
    -- To make float number supported, 
    -- make the Step a float number.
    -- example: Step = 0.1
    Step = 10,
    Value = {
        Min = 10,
        Max = 90,
        Default = 10,
    },
    Callback = function(value)
        print(value)
    end
})

local Toggle = BaitSection:Toggle({
    Title = "Auto Buy Baits",
    Icon = "shrimp",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local Toggle = BaitSection:Toggle({
    Title = "Auto Buy Baits",
    Icon = "shrimp",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local Button = BaitSection:Button({
    Title = "Buy Baits",
    Icon = "fish",
    Callback = function()
        -- ...
    end
})

local QuestSection = FishingTab:Section({ 
    Title = "Quest",
    Opened = true,
})

local Dropdown = QuestSection:Dropdown({
    Title = "Skip Quests",
    Values = { "Quest 1", "Quest 2", "Quest 3" },
    Value = false, -- default value,
    Multi = false,
    AllowNone = true,
    Callback = function(option) 
        -- option is a table: { "Category A", "Category B" }
        print("Categories selected: " .. game:GetService("HttpService"):JSONEncode(option)) 
    end
})

local Toggle = QuestSection:Toggle({
    Title = "Auto Quest",
    Desc = "Skip, Get Complete",
    Icon = "circle-check-big",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local Toggle = QuestSection:Toggle({
    Title = "Take Quest Only When Fishing",
    Icon = "check",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local SellSection = FishingTab:Section({ 
    Title = "Sell",
    Opened = true,
})

local Dropdown = SellSection:Dropdown({
    Title = "Select Fish Kind",
    Values = { "Normal", "Cursed", "Celestial" },
    Value = false, -- default value,
    Multi = false,
    AllowNone = true,
    Callback = function(option) 
        -- option is a table: { "Category A", "Category B" }
        print("Categories selected: " .. game:GetService("HttpService"):JSONEncode(option)) 
    end
})

local Toggle = SellSection:Toggle({
    Title = "Auto Sell Fish",
    Icon = "store",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local QuestsItemsTab = Window:Tab({
    Title = "Quests/Items",
    Icon = "circle-question-mark",
    Locked = false,
})

local NextSeaSection = QuestsItemsTab:Section({ 
    Title = "Next Sea",
    Opened = true,
})

local Toggle = NextSeaSection:Toggle({
    Title = "Auto Third Sea",
    Desc = "Auto unlocks access to the Third Sea",
    Icon = "waves",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local Toggle = NextSeaSection:Toggle({
    Title = "Auto Kill Don Swan",
    Desc = "Auto defeats Don Swan",
    Icon = "skull",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local BossesSection = QuestsItemsTab:Section({ 
    Title = "Bosses",
    Opened = true,
})

local Toggle = BossesSection:Toggle({
    Title = "Auto Darkbeard",
    Desc = "Auto spawn and defeat Darkbeard",
    Icon = "moon",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local Toggle = BossesSection:Toggle({
    Title = "Auto Cursed Captain",
    Desc = "Defeat the \"Cursed Captain\" Auto",
    Icon = "ghost",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local OrderSection = QuestsItemsTab:Section({ 
    Title = "Order Law",
    Opened = true,
})

local Toggle = OrderSection:Toggle({
    Title = "Fully Raid Order",
    Desc = "Auto Spawns and defeats Order",
    Icon = "skull",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local Toggle = OrderSection:Toggle({
    Title = "Auto Start [Fully]",
    Desc = "Auto spawns and defeats",
    Icon = "play",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local SwordSection = QuestsItemsTab:Section({ 
    Title = "Sword",
    Opened = true,
})

local Toggle = SwordSection:Toggle({
    Title = "Auto Buy Legendary Sword",
    Desc = "Auto purchases Legendary Swords when available",
    Icon = "play",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local FruitRaidTab = Window:Tab({
    Title = "Fruit/Raid",
    Icon = "apple",
    Locked = false,
})

local GachaSection = FruitRaidTab:Section({ 
    Title = "Gacha",
    Opened = true,
})

local Button = GachaSection:Button({
    Title = "Roll Gacha Box",
    Icon = "box",
    Callback = function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local function formatSecondsAsClock(sec)
            sec = math.max(0, math.floor(sec or 0))
            local h = math.floor(sec / 3600)
            local m = math.floor((sec % 3600) / 60)
            local s = sec % 60
            if h > 0 then
                return string.format("%d:%02d:%02d", h, m, s)
            else
                return string.format("%02d:%02d", m, s)
            end
        end

        local function tryExtractSecondsFromString(str)
            if not str or str == "" then return nil end
            
            local hms = string.match(str, "(%d+:%d+:%d+)")
            if hms then
                local h, m, s = hms:match("(%d+):(%d+):(%d+)")
                if h and m and s then
                    return tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s)
                end
            end
            
            local ms = string.match(str, "(%d+:%d+)")
            if ms then
                local m, s = ms:match("(%d+):(%d+)")
                if m and s then
                    return tonumber(m) * 60 + tonumber(s)
                end
            end

            local hours = string.match(str, "(%d+)%s*[hH]e?ours?")
            if not hours then hours = string.match(str, "(%d+)%s*[hH]") end
            if hours then
                return tonumber(hours) * 3600
            end

            local mins = string.match(str, "(%d+)%s*[mM]in")
            if not mins then mins = string.match(str, "(%d+)%s*[mM]inutes?") end
            if mins then
                return tonumber(mins) * 60
            end

            local secs = string.match(str, "(%d+)%s*[sS]ec")
            if not secs then secs = string.match(str, "(%d+)%s*[sS]econds?") end
            if secs then
                return tonumber(secs)
            end

            local num = string.match(str, "(%d+)")
            if num then
                return tonumber(num)
            end

            return nil
        end

        local function extractCooldownSeconds(result)
            if typeof(result) == "number" then
                return tonumber(result)
            end

            if typeof(result) == "boolean" and result == true then
                return nil
            end

            if typeof(result) == "table" then
                local keys = {"Cooldown","cooldown","Time","time","Seconds","seconds","left","Left"}
                for _,k in ipairs(keys) do
                    if result[k] then
                        if typeof(result[k]) == "number" then
                            return tonumber(result[k])
                        elseif typeof(result[k]) == "string" then
                            local s = tryExtractSecondsFromString(result[k])
                            if s then return s end
                        end
                    end
                end
                local ok, s = pcall(function() return tostring(result) end)
                if ok and s then
                    local parsed = tryExtractSecondsFromString(s)
                    if parsed then return parsed end
                end
                return nil
            end

            if typeof(result) == "string" then
                return tryExtractSecondsFromString(result)
            end

            return nil
        end

        local success, result = pcall(function()
            return ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
        end)

        if success then
            if result == true or result == "ok" or result == "success" then
                WindUI:Notify({
                    Title = "✅ Success!",
                    Content = "Fruit successfully purchased!",
                    Duration = 4,
                    Icon = "check"
                })
                return
            end

            local secs = extractCooldownSeconds(result)

            if secs and secs > 0 then
                local clock = formatSecondsAsClock(secs)
                WindUI:Notify({
                    Title = "⏳ Gacha Cooldown",
                    Content = "Please wait " .. clock .. " before spinning again!",
                    Duration = 5,
                    Icon = "clock"
                })
            else
                WindUI:Notify({
                    Title = "✅ Success!",
                    Content = "Fruit successfully purchased!",
                    Duration = 4,
                    Icon = "check"
                })
            end
        else
            local secs = extractCooldownSeconds(result)
            if secs and secs > 0 then
                local clock = formatSecondsAsClock(secs)
                WindUI:Notify({
                    Title = "⏳ Gacha Cooldown",
                    Content = "Please wait " .. clock .. " before spinning again!",
                    Duration = 5,
                    Icon = "clock"
                })
            else
                WindUI:Notify({
                    Title = "❌ Error",
                    Content = tostring(result) or "Failed to execute the request.",
                    Duration = 5,
                    Icon = "x-circle"
                })
            end
        end
    end
})

local Button = GachaSection:Button({
    Title = "Roll Haunted Gacha",
    Icon = "ghost",
    Callback = function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Покупка Halloween гача
    local success, result = pcall(function()
    return ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "HalloweenGacha25")
    end)
    
    if success then
    print("🎃 Haunted Gacha roll successfully!")
    print("Result:", result)
    else
    warn("❌ Failed to purchase:", result)
    end
    end
})

local FruitsSection = FruitRaidTab:Section({ 
    Title = "Fruits",
    Opened = true,
})

-- 🧩 Исправление списка фруктов
local fruits = {
    "Rocket Fruit",
    "Spin Fruit",
    "Blade Fruit",
    "Spring Fruit",
    "Bomb Fruit",
    "Smoke Fruit",
    "Spike Fruit",
    "Flame Fruit",
    "Sand Fruit",
    "Dark Fruit",
    "Eagle Fruit",
    "Diamond Fruit",
    "Light Fruit",
    "Rubber Fruit",
    "Ghost Fruit",
    "Magma Fruit",
    "Quake Fruit",
    "Love Fruit",
    "Spider Fruit",
    "Creation Fruit",
    "Sound Fruit",
    "Phoenix Fruit",
    "Portal Fruit",
    "Lightning Fruit",
    "Rumble Fruit",
    "Pain Fruit",
    "Blizzard Fruit",
    "Gravity Fruit",
    "Mammoth Fruit",
    "T-Rex Fruit",
    "Dough Fruit",
    "Shadow Fruit",
    "Venom Fruit",
    "Control Fruit",
    "Gas Fruit",
    "Spirit Fruit",
    "Tiger Fruit",
    "Leopard Fruit",
    "Yeti Fruit",
    "Kitsune Fruit",
    "Dragon East Fruit",
    "Dragon West Fruit",
    "Fruit"
}


local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local bringing = false

local function bringFruits()
    for _, obj in ipairs(workspace:GetChildren()) do
        -- Проверяем только объекты верхнего уровня
        for _, fruitName in ipairs(fruits) do
            if string.find(string.lower(obj.Name), string.lower(fruitName)) then
                local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                if handle then
                    pcall(function()
                        handle.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                    end)
                end
            end
        end
    end
end

local Toggle = FruitsSection:Toggle({
    Title = "Auto Bring Fruits",
    Icon = "bring-to-front",
    Value = false,
    Callback = function(state)
        bringing = state
        if bringing then
            print("✅ Auto Bring Fruits enabled")
            task.spawn(function()
                while bringing do
                    bringFruits()
                    task.wait(3) -- каждые 3 секунды, можно увеличить до 5–10 если всё ещё лагает
                end
            end)
        else
            print("❌ Auto Bring Fruits disabled")
        end
    end
})

-- 🧩 Auto Store Fruits (вкл/выкл)
local bringingFruits = false

local Toggle = FruitsSection:Toggle({
    Title = "Auto Store Fruits",
    Icon = "backpack",
    Value = false,
    Callback = function(state) 
        bringingFruits = state

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer

        -- Основная функция хранения фруктов
        local function storeFruitsFromAllLocations()
            local storedCount = 0
            local function tryStore(item)
                if item:IsA("Tool") and string.find(item.Name:lower(), "fruit") then
                    local baseName = string.gsub(item.Name, " Fruit", "")
                    local storeName = baseName .. "-" .. baseName
                    local success, result = pcall(function()
                        return ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", storeName, item)
                    end)
                    if success and result == true then
                        storedCount += 1
                        print("🍎 Stored:", item.Name)
                    end
                    task.wait(0.2)
                end
            end

            -- Проверяем Backpack
            for _, item in pairs(player.Backpack:GetChildren()) do
                tryStore(item)
            end

            -- Проверяем персонажа
            local char = player.Character or player.CharacterAdded:Wait()
            for _, item in pairs(char:GetChildren()) do
                tryStore(item)
            end

            return storedCount
        end

        -- Запуск / остановка цикла
        if bringingFruits then
            print("✅ Auto Store Fruits enable")
            WindUI:Notify({
                Title = "🍇 Auto Store Fruits",
                Content = "Auto store fruits enable!",
                Duration = 3,
                Icon = "grape"
            })
            task.spawn(function()
                while bringingFruits do
                    storeFruitsFromAllLocations()
                    task.wait(1)
                end
            end)
        else
            print("❌ Auto Store Fruits disable")
            WindUI:Notify({
                Title = "🍇 Auto Store Fruits",
                Content = "Auto Store fruits enable.",
                Duration = 3,
                Icon = "x"
            })
        end
    end
})


local RaidSection = FruitRaidTab:Section({ 
    Title = "Raid",
    Opened = true,
})

local Dropdown = RaidSection:Dropdown({
    Title = "Select Chip",
    Values = { "Chip 1", "Chip 2", "Chip 3" },
    Value = false, -- default value,
    Multi = false,
    AllowNone = true,
    Callback = function(option) 
        -- option is a table: { "Category A", "Category B" }
        print("Categories selected: " .. game:GetService("HttpService"):JSONEncode(option)) 
    end
})

local Toggle = RaidSection:Toggle({
    Title = "Auto Farm Raid",
    Desc = "Start, Defeat Mobs",
    Icon = "shield-user",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local Toggle = RaidSection:Toggle({
    Title = "Auto Buy Chip",
    Icon = "microchip",
    Value = false, -- default value
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

local HopTab = Window:Tab({
    Title = "Hop",
    Icon = "gem",
    Locked = false,
})

local StatsTab = Window:Tab({
    Title = "Stats",
    Icon = "chart-column-increasing",
    Locked = false,
})

local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "map",
    Locked = false,
})

local TravelSection = TeleportTab:Section({ 
    Title = "Travel",
    Opened = true,
})

local Button = TravelSection:Button({
    Title = "⚠️ Teleport to Sea 1",
    Desc = "Main",
    Icon = "waves",
    Callback = function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Телепорт на Main
    local success, result = pcall(function()
    return ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelMain")
    end)
    
    if success then
    
    else
    
    end
    
    end
})

local Button = TravelSection:Button({
    Title = "⚠️ Teleport to Sea 2",
    Desc = "Zou",
    Icon = "waves",
    Callback = function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Телепорт на Dressrosa
    local success, result = pcall(function()
    return ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
    end)
    
    if success then
    
    else

    end
end
})

local Button = TravelSection:Button({
    Title = "⚠️ Teleport to Sea 3",
    Desc = "Dressrosa",
    Icon = "waves",
    Callback = function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Телепорт на Zou
    local success, result = pcall(function()
    return ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou")
    end)
    
    if success then
    
    else
    
    end
    
    end
})

local IslandsSection = TeleportTab:Section({ 
    Title = "Islands",
    Opened = true,
})

local map = workspace:WaitForChild("Map")

-- === ФУНКЦИЯ ПОЛУЧЕНИЯ ОСТРОВОВ ===
local function GetIslands()
    local islands = {}
    for _, obj in ipairs(map:GetChildren()) do
        if obj:IsA("Model") then
            if not obj.PrimaryPart then
                local part = obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    obj.PrimaryPart = part
                end
            end
            if obj.PrimaryPart then
                table.insert(islands, obj.Name)
            end
        end
    end
    return islands
end

-- === СОЗДАНИЕ DROPDOWN ===
local islands = GetIslands()
local selectedIsland = nil

local Dropdown = IslandsSection:Dropdown({
    Title = "Select Island",
    Values = islands,
    Value = false,
    Multi = false,
    AllowNone = true,
    Callback = function(option)
        selectedIsland = map:FindFirstChild(option)
    end
})

map.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart") then
        Dropdown:SetValues(GetIslands())
    end
end)

-- === ТЕЛЕПОРТ С TWЕEN ===
local activeTween = nil -- для отмены полета

local Toggle = IslandsSection:Toggle({
    Title = "Teleport to Island",
    Icon = "tree-palm",
    Value = false,
    Callback = function(state)
        if state then
            if not selectedIsland then

                return
            end

            local target = selectedIsland.PrimaryPart or selectedIsland:FindFirstChildWhichIsA("BasePart")
            if not target then

                return
            end

            -- 1. Поднимаемся на 50 по оси Y
            local upCFrame = humanoidRootPart.CFrame + Vector3.new(0, 50, 0)
            local upTween = TweenService:Create(
                humanoidRootPart,
                TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { CFrame = upCFrame }
            )
            upTween:Play()
            upTween.Completed:Wait() -- ждём, пока поднимется

            -- 2. Летим к острову
            local distance = (humanoidRootPart.Position - target.Position).Magnitude
            local time = distance / 300 -- скорость = 300
            local goalCFrame = target.CFrame + Vector3.new(0, 5, 0)

            activeTween = TweenService:Create(
                humanoidRootPart,
                TweenInfo.new(time, Enum.EasingStyle.Linear),
                { CFrame = goalCFrame }
            )
            activeTween:Play()

        else
            -- Если выключили — остановим полёт
            if activeTween then
                activeTween:Cancel()
                activeTween = nil
            end
        end
    end
})

local NPCsSection = TeleportTab:Section({ 
    Title = "NPCs",
    Opened = true,
})

local NPCFolder = ReplicatedStorage:WaitForChild("NPCs")

-- === ФУНКЦИЯ ДЛЯ ПОЛУЧЕНИЯ СПИСКА NPC ===
local function GetNPCs()
    local npcs = {}
    for _, obj in ipairs(NPCFolder:GetChildren()) do
        if obj:IsA("Model") then
            if not obj.PrimaryPart then
                local part = obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    obj.PrimaryPart = part
                end
            end
            if obj.PrimaryPart then
                table.insert(npcs, obj.Name)
            end
        end
    end
    return npcs
end

-- === DROPDOWN ===
local npcs = GetNPCs()
local selectedNPC = nil

local Dropdown = NPCsSection:Dropdown({
    Title = "Select NPC",
    Values = npcs,
    Value = false,
    Multi = false,
    AllowNone = true,
    Callback = function(option)
        selectedNPC = NPCFolder:FindFirstChild(option)
    end
})

-- === Автообновление списка, если NPC добавлены позже ===
NPCFolder.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart") then
        Dropdown:SetValues(GetNPCs())
    end
end)

-- === TELEPORT TOGGLE ===
local activeTween = nil

local Toggle = NPCsSection:Toggle({
    Title = "Teleport to NPC",
    Icon = "user",
    Value = false,
    Callback = function(state)
        if state then
            if not selectedNPC then
                warn("NPC не выбран!")
                return
            end

            local target = selectedNPC.PrimaryPart or selectedNPC:FindFirstChildWhichIsA("BasePart")
            if not target then

                return
            end

            -- 1. Поднимаемся вверх на 50 по Y
            local upCFrame = humanoidRootPart.CFrame + Vector3.new(0, 50, 0)
            local upTween = TweenService:Create(
                humanoidRootPart,
                TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { CFrame = upCFrame }
            )
            upTween:Play()
            upTween.Completed:Wait()

            -- 2. Летим к NPC
            local distance = (humanoidRootPart.Position - target.Position).Magnitude
            local time = distance / 300 -- скорость = 300
            local goalCFrame = target.CFrame + Vector3.new(0, 5, 0)

            activeTween = TweenService:Create(
                humanoidRootPart,
                TweenInfo.new(time, Enum.EasingStyle.Linear),
                { CFrame = goalCFrame }
            )
            activeTween:Play()

        else
            -- Если отключаем — останавливаем полёт
            if activeTween then
                activeTween:Cancel()
                activeTween = nil
            end
        end
    end
})

local VisualTab = Window:Tab({
    Title = "Visual",
    Icon = "eye",
    Locked = false,
})

local EspSection = VisualTab:Section({ 
    Title = "ESP",
    Opened = true,
})

-- === ПЕРЕМЕННЫЕ ===
local ESP_Enabled = false
local ESP_Objects = {}
local ESP_Connections = {}

-- === ФУНКЦИИ ===

-- Цвет по команде
local function getPlayerColor(player)
    if player.Team and player.Team.TeamColor then
        return player.Team.TeamColor.Color
    else
        return Color3.fromRGB(255, 255, 255)
    end
end

-- Создаём ESP для игрока
local function createPlayerESP(player)
    if player == Players.LocalPlayer then return end
    if ESP_Objects[player] then return end

    local function setup(char)
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        local hrp = char.HumanoidRootPart
        local head = char:FindFirstChild("Head") or hrp

        -- Highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerESP_Highlight"
        highlight.FillTransparency = 0.75
        highlight.OutlineTransparency = 0.15
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = getPlayerColor(player)
        highlight.OutlineColor = highlight.FillColor
        highlight.Parent = char

        -- Billboard (инфо)
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PlayerESP_Billboard"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 0
        billboard.Parent = head

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.TextStrokeTransparency = 0.5
        label.TextColor3 = getPlayerColor(player)
        label.Parent = billboard

        -- Обновление
        local conn = RunService.Heartbeat:Connect(function()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                conn:Disconnect()
                highlight:Destroy()
                billboard:Destroy()
                ESP_Objects[player] = nil
                return
            end

            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")

            local myChar = Players.LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

            local distance = 0
            if hrp and myHRP then
                distance = math.floor((myHRP.Position - hrp.Position).Magnitude)
            end

            local health = humanoid and math.floor(humanoid.Health) or 0
            local maxHealth = humanoid and math.floor(humanoid.MaxHealth) or 100

            label.TextColor3 = getPlayerColor(player)
            highlight.FillColor = getPlayerColor(player)
            highlight.OutlineColor = getPlayerColor(player)
            label.Text = string.format("%s\nHP: %d/%d\n[%dm]", player.DisplayName or player.Name, health, maxHealth, distance)
        end)

        ESP_Objects[player] = {
            Highlight = highlight,
            Billboard = billboard,
            Conn = conn
        }
    end

    if player.Character then
        setup(player.Character)
    end

    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        setup(char)
    end)
end

-- Удаляем ESP
local function removePlayerESP(player)
    if ESP_Objects[player] then
        local data = ESP_Objects[player]
        if data.Conn then data.Conn:Disconnect() end
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        ESP_Objects[player] = nil
    end
end

local function enableESP()
    disableESP()

    -- Существующие игроки
    for _, player in pairs(Players:GetPlayers()) do
        createPlayerESP(player)
    end

    -- Новые
    ESP_Connections["PlayerAdded"] = Players.PlayerAdded:Connect(function(player)
        createPlayerESP(player)
    end)

    -- Удалённые
    ESP_Connections["PlayerRemoving"] = Players.PlayerRemoving:Connect(function(player)
        removePlayerESP(player)
    end)

    print("[ESP] Player ESP Enabled ✅")
end

function disableESP()
    for player, data in pairs(ESP_Objects) do
        removePlayerESP(player)
    end
    ESP_Objects = {}

    for _, conn in pairs(ESP_Connections) do
        if conn then conn:Disconnect() end
    end
    ESP_Connections = {}

    print("[ESP] Player ESP Disabled ❌")
end

-- === UI ===
local Toggle = EspSection:Toggle({
    Title = "ESP Players",
    Icon = "eye",
    Value = false,
    Callback = function(state)
        ESP_Enabled = state
        if state then
            enableESP()
        else
            disableESP()
        end
    end
})

-- === ПЕРЕМЕННЫЕ ===
local ESP_Fruits_Enabled = false
local ESP_Fruits = {}
local ESP_Connections = {}

-- === НАСТРОЙКА ЦВЕТОВ ПО НАЗВАНИЮ ===
local FruitColors = {
    ["Rocket Fruit"] = Color3.fromRGB(150, 150, 255),
    ["Spin Fruit"] = Color3.fromRGB(255, 220, 100),
    ["Blade Fruit"] = Color3.fromRGB(200, 200, 200),
    ["Spring Fruit"] = Color3.fromRGB(180, 255, 150),
    ["Bomb Fruit"] = Color3.fromRGB(255, 100, 100),
    ["Smoke Fruit"] = Color3.fromRGB(200, 200, 200),
    ["Spike Fruit"] = Color3.fromRGB(240, 240, 240),
    ["Flame Fruit"] = Color3.fromRGB(255, 120, 0),
    ["Sand Fruit"] = Color3.fromRGB(220, 200, 130),
    ["Dark Fruit"] = Color3.fromRGB(70, 0, 100),
    ["Eagle Fruit"] = Color3.fromRGB(255, 230, 150),
    ["Diamond Fruit"] = Color3.fromRGB(0, 255, 255),
    ["Light Fruit"] = Color3.fromRGB(255, 255, 150),
    ["Rubber Fruit"] = Color3.fromRGB(255, 120, 200),
    ["Ghost Fruit"] = Color3.fromRGB(190, 190, 255),
    ["Magma Fruit"] = Color3.fromRGB(255, 80, 20),
    ["Quake Fruit"] = Color3.fromRGB(180, 200, 255),
    ["Love Fruit"] = Color3.fromRGB(255, 100, 200),
    ["Spider Fruit"] = Color3.fromRGB(120, 120, 120),
    ["Creation Fruit"] = Color3.fromRGB(255, 255, 255),
    ["Sound Fruit"] = Color3.fromRGB(255, 180, 0),
    ["Phoenix Fruit"] = Color3.fromRGB(255, 180, 50),
    ["Portal Fruit"] = Color3.fromRGB(100, 200, 255),
    ["Lightning Fruit"] = Color3.fromRGB(255, 255, 100),
    ["Rumble Fruit"] = Color3.fromRGB(200, 255, 255),
    ["Pain Fruit"] = Color3.fromRGB(200, 50, 50),
    ["Blizzard Fruit"] = Color3.fromRGB(150, 200, 255),
    ["Gravity Fruit"] = Color3.fromRGB(180, 50, 255),
    ["Mammoth Fruit"] = Color3.fromRGB(170, 140, 100),
    ["T-Rex Fruit"] = Color3.fromRGB(100, 255, 100),
    ["Dough Fruit"] = Color3.fromRGB(255, 230, 180),
    ["Shadow Fruit"] = Color3.fromRGB(90, 0, 90),
    ["Venom Fruit"] = Color3.fromRGB(120, 0, 255),
    ["Control Fruit"] = Color3.fromRGB(255, 255, 255),
    ["Gas Fruit"] = Color3.fromRGB(200, 255, 200),
    ["Spirit Fruit"] = Color3.fromRGB(180, 240, 255),
    ["Tiger Fruit"] = Color3.fromRGB(255, 170, 70),
    ["Leopard Fruit"] = Color3.fromRGB(255, 200, 100),
    ["Yeti Fruit"] = Color3.fromRGB(220, 240, 255),
    ["Kitsune Fruit"] = Color3.fromRGB(255, 140, 100),
    ["Dragon East Fruit"] = Color3.fromRGB(255, 50, 50),
    ["Dragon Weast Fruit"] = Color3.fromRGB(100, 150, 255),
    ["Fruit"] = Color3.fromRGB(255, 255, 255),
}

-- === ФУНКЦИИ ===
local function getFruitColor(name)
    return FruitColors[name] or Color3.fromRGB(255, 255, 255)
end

local function createFruitESP(fruit)
    if not fruit:IsA("BasePart") and not fruit:IsA("Model") then return end
    if ESP_Fruits[fruit] then return end

    local part = fruit:IsA("BasePart") and fruit or fruit:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local name = fruit.Name

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "FruitESP_Highlight"
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = getFruitColor(name)
    highlight.OutlineColor = getFruitColor(name)
    highlight.Parent = fruit

    -- Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FruitESP_Billboard"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 0
    billboard.Parent = part

    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Font = Enum.Font.GothamBold
    text.TextScaled = true
    text.TextStrokeTransparency = 0.5
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.TextColor3 = getFruitColor(name)
    text.Parent = billboard

    local conn = RunService.Heartbeat:Connect(function()
        if not fruit or not fruit.Parent or not part.Parent then
            conn:Disconnect()
            highlight:Destroy()
            billboard:Destroy()
            ESP_Fruits[fruit] = nil
            return
        end

        local myChar = Players.LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local distance = math.floor((myHRP.Position - part.Position).Magnitude)
        text.Text = string.format("%s\n[%dm]", name, distance)
        text.TextColor3 = getFruitColor(name)
        highlight.FillColor = getFruitColor(name)
        highlight.OutlineColor = getFruitColor(name)
    end)

    ESP_Fruits[fruit] = { Highlight = highlight, Billboard = billboard, Conn = conn }
end

local function removeFruitESP(fruit)
    local data = ESP_Fruits[fruit]
    if not data then return end

    if data.Conn then data.Conn:Disconnect() end
    if data.Highlight then data.Highlight:Destroy() end
    if data.Billboard then data.Billboard:Destroy() end
    ESP_Fruits[fruit] = nil
end

local function enableFruitESP()
    disableFruitESP()

    -- Сканируем всё workspace
    for _, obj in pairs(Workspace:GetChildren()) do
        if FruitColors[obj.Name] then
            createFruitESP(obj)
        end
    end

    -- Новые фрукты
    ESP_Connections["ChildAdded"] = Workspace.ChildAdded:Connect(function(obj)
        if FruitColors[obj.Name] then
            task.wait(0.3)
            createFruitESP(obj)
        end
    end)

    -- Удалённые
    ESP_Connections["ChildRemoved"] = Workspace.ChildRemoved:Connect(function(obj)
        removeFruitESP(obj)
    end)

    print("[ESP] Fruits ESP Enabled ✅")
end

function disableFruitESP()
    for fruit, data in pairs(ESP_Fruits) do
        removeFruitESP(fruit)
    end
    ESP_Fruits = {}

    for _, conn in pairs(ESP_Connections) do
        if conn then conn:Disconnect() end
    end
    ESP_Connections = {}

    print("[ESP] Fruits ESP Disabled ❌")
end

-- === UI ===
local Toggle = EspSection:Toggle({
    Title = "ESP Fruits",
    Icon = "apple",
    Value = false,
    Callback = function(state)
        ESP_Fruits_Enabled = state
        if state then
            enableFruitESP()
        else
            disableFruitESP()
        end
    end
})

-- === НАСТРОЙКИ ===
local ESP_Enabled = false
local ESP_Objects = {}
local ESP_Connections = {}
local ChestFolder = workspace:WaitForChild("ChestModels")

-- === ФУНКЦИИ ===

-- Подбор цвета по названию сундука
local function getChestColor(chestName: string)
    chestName = string.lower(chestName)
    if string.find(chestName, "diamond") then
        return Color3.fromRGB(0, 255, 255) -- Голубой / Бриллиантовый
    elseif string.find(chestName, "gold") then
        return Color3.fromRGB(255, 215, 0) -- Золотистый
    elseif string.find(chestName, "silver") then
        return Color3.fromRGB(192, 192, 192) -- Серебристый
    else
        return Color3.fromRGB(255, 255, 255) -- Белый по умолчанию
    end
end

local function createChestESP(chest)
    if not chest:IsA("Model") then return end
    if ESP_Objects[chest] then return end

    -- Находим деталь для привязки
    local basePart = chest:FindFirstChildWhichIsA("BasePart")
    if not basePart then return end

    -- Определяем цвет
    local color = getChestColor(chest.Name)

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ChestESP_Highlight"
    highlight.FillColor = color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = chest

    -- Billboard (название и дистанция)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ChestESP_Billboard"
    billboard.Size = UDim2.new(0, 150, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 0
    billboard.Parent = basePart

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.5
    label.TextScaled = true
    label.Text = chest.Name
    label.Parent = billboard

    -- Обновление текста с расстоянием
    local conn = RunService.Heartbeat:Connect(function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not chest or not chest.Parent or not hrp then
            conn:Disconnect()
            highlight:Destroy()
            billboard:Destroy()
            ESP_Objects[chest] = nil
            return
        end

        local distance = math.floor((hrp.Position - basePart.Position).Magnitude)
        label.Text = string.format("%s\n[%dm]", chest.Name or "Chest", distance)
    end)

    ESP_Objects[chest] = {
        Highlight = highlight,
        Billboard = billboard,
        Conn = conn
    }
end

local function removeChestESP(chest)
    local data = ESP_Objects[chest]
    if not data then return end

    if data.Conn then data.Conn:Disconnect() end
    if data.Highlight then data.Highlight:Destroy() end
    if data.Billboard then data.Billboard:Destroy() end

    ESP_Objects[chest] = nil
end

local function enableChestESP()
    disableChestESP()

    -- Для всех существующих сундуков
    for _, chest in ipairs(ChestFolder:GetChildren()) do
        createChestESP(chest)
    end

    -- Новые сундуки
    ESP_Connections["ChildAdded"] = ChestFolder.ChildAdded:Connect(function(chest)
        task.wait(0.2)
        createChestESP(chest)
    end)

    -- Удалённые сундуки
    ESP_Connections["ChildRemoved"] = ChestFolder.ChildRemoved:Connect(function(chest)
        removeChestESP(chest)
    end)

    print("[ESP] Chests ESP Enabled ✅")
end

function disableChestESP()
    for chest, data in pairs(ESP_Objects) do
        removeChestESP(chest)
    end
    ESP_Objects = {}

    for _, conn in pairs(ESP_Connections) do
        if conn then conn:Disconnect() end
    end
    ESP_Connections = {}

    print("[ESP] Chests ESP Disabled ❌")
end

-- === UI ===
local Toggle = EspSection:Toggle({
    Title = "ESP Chests",
    Icon = "eye",
    Value = false,
    Callback = function(state)
        ESP_Enabled = state
        if state then
            enableChestESP()
        else
            disableChestESP()
        end
    end
})

local ShopTab = Window:Tab({
    Title = "Shop",
    Icon = "shopping-cart",
    Locked = false,
})

local FightingStyleSection = ShopTab:Section({
    Title = "Fighting Style",
    Icon = "hand-fist",
    Opened = false,
})

local Button = FightingStyleSection:Button({
    Title = "Dark Step",
    Icon = "footprints",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyDarkStep", buy) 
    end,
})

local Button = FightingStyleSection:Button({
    Title = "Electric",
    Icon = "zap",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyElectric", buy) 
    end,
})

local Button = FightingStyleSection:Button({
    Title = "WaterKungFu",
    Icon = "handshake",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyWaterKungFu", buy) 
    end,
})

local Button = FightingStyleSection:Button({
    Title = "DragonBreath",
    Icon = "wind",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyDragonBreath", buy) 
    end,
})

local Button = FightingStyleSection:Button({
    Title = "Superhuman",
    Icon = "square-chevron-up",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuySuperhuman", buy) 
    end,
})

local Button = FightingStyleSection:Button({
    Title = "Death Step",
    Icon = "skull",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyDeathStep", buy) 
    end,
})

local Button = FightingStyleSection:Button({
    Title = "Sharkman Karate",
    Icon = "fish",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuySharkmanKarate", buy) 
    end,
})

local Button = FightingStyleSection:Button({
    Title = "ElectricClaw",
    Icon = "atom",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyElectricClaw", buy) 
    end,
})
local Button = FightingStyleSection:Button({
    Title = "Dragon Talon",
    Icon = "fire",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyDragonTalon", buy) 
    end,
})

local Button = FightingStyleSection:Button({
    Title = "Godhuman",
    Icon = "user",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyGodhuman", buy) 
    end,
})

local Button = FightingStyleSection:Button({
    Title = "Sanguine Art",
    Icon = "droplet",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuySanguineArt", buy) 
    end,
})

local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "cog",
    Locked = false,
})

local ServerSection = MiscTab:Section({
    Title = "Server",
    Opened = true,
})

-- ✅ Rejoin
local Button = ServerSection:Button({
    Title = "Rejoin",
    Icon = "rotate-ccw",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer

        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end,
})

-- ✅ Server Hop
local Button = ServerSection:Button({
    Title = "Server Hop",
    Icon = "workflow",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local HttpService = game:GetService("HttpService")
        local player = Players.LocalPlayer

        local function GetServers()
            local servers = {}
            local cursor = ""

            repeat
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
                local success, result = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet(url))
                end)
                if success and result and result.data then
                    for _, server in ipairs(result.data) do
                        if server.playing < server.maxPlayers and server.id ~= game.JobId then
                            table.insert(servers, server.id)
                        end
                    end
                    cursor = result.nextPageCursor or ""
                else
                    break
                end
            until cursor == ""

            return servers
        end

        local function ServerHop()
            local servers = GetServers()
            if #servers > 0 then
                local serverId = servers[math.random(1, #servers)]
                TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, player)
            else
                warn("❌ No available servers found!")
            end
        end

        ServerHop()
    end,
})

-- ✅ Hop to Low Player Server
local Button = ServerSection:Button({
    Title = "Hop To Lower Player",
    Icon = "workflow",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local HttpService = game:GetService("HttpService")
        local player = Players.LocalPlayer

        local function GetServers()
            local servers = {}
            local cursor = ""

            repeat
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
                local success, result = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet(url))
                end)

                if success and result and result.data then
                    for _, server in ipairs(result.data) do
                        if server.playing >= 1 and server.playing <= 4 and server.id ~= game.JobId then
                            table.insert(servers, server)
                        end
                    end
                    cursor = result.nextPageCursor or ""
                else
                    warn("⚠️ Error getting servers.")
                    break
                end
            until cursor == ""

            return servers
        end

        local function HopToSmallServer()
            local servers = GetServers()
            if #servers > 0 then
                local chosen = servers[math.random(1, #servers)]
                print("Going to server with " .. chosen.playing .. " players.")
                TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen.id, player)
            else
                warn("❌ No servers with 1–4 players found!")
            end
        end

        HopToSmallServer()
    end,
})

local TeamsSection = MiscTab:Section({
    Title = "Teams",
    Opened = true,
})

TeamsSection:Button({
    Title = "Join Pirates Team",
    Icon = "sword",
    Callback = function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Смена команды на Pirates
        local success, result = pcall(function()
            return ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
        end)
        
        if success then

        else

        end
    end
})

TeamsSection:Button({
    Title = "Join Marines Team",
    Icon = "fish",
    Callback = function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Смена команды на Marines
        local success, result = pcall(function()
            return ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
        end)
        
        if success then

        else

        end
    end
})
