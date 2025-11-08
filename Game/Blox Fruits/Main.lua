-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Игрок и персонаж
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoidRootPart = rootPart
local char = character
local hrp = rootPart

-- Флаги функций
local noclipEnabled = false
local infiniteJumpEnabled = false
local currentJumpHeight = 7.2
local speedMultiplier = 1

-- Функция безопасного получения humanoid
local function getHumanoid()
    if character and character:FindFirstChild("Humanoid") then
        return character.Humanoid
    end
    return nil
end

-- Функция обновления персонажа
local function onCharacterAdded(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoidRootPart = rootPart
    char = newChar
    hrp = rootPart
    
    if humanoid.UseJumpPower then
        humanoid.UseJumpPower = false
    end
    
    humanoid.JumpHeight = currentJumpHeight
    character:SetAttribute("SpeedMultiplier", speedMultiplier)
    
    if noclipEnabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Noclip цикл
RunService.Stepped:Connect(function()
    if noclipEnabled and character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Инициализация WindUI
local WindUI
do
    local ok, result = pcall(function() return require("./src/Init") end)
    if ok and result then
        WindUI = result
    else
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()
    end
end

WindUI:SetFont("rbxasset://fonts/families/RobotoMono.json")

-- Создание окна
local Window = WindUI:CreateWindow({
    Title = "NovaAxis | Hub",
    Icon = "sparkles",
    Author = "By NovaAxis | discord.gg/wAwgJatMMt",
    Theme = "Indigo",
    Resizable = true,
    ScrollBarEnabled = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "NovaAxis | Hub",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Color = ColorSequence.new(
            Color3.fromHex("3730a3"),
            Color3.fromHex("1e1b4b")
        ),
    },
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            local playerObj = game.Players.LocalPlayer
            if playerObj then
                local nickname = playerObj.Name
                setclipboard(nickname)
                
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
})

Window:SetToggleKey(Enum.KeyCode.RightShift)

-- HOME TAB
local HomeTab = Window:Tab({
    Title = "Home",
    Icon = "server"
})

local DiscordNovaAxisSection = HomeTab:Section({
    Title = "NovaAxis | Hub Discord server!",
    Icon = "globe",
    Opened = true,
})

DiscordNovaAxisSection:Paragraph({
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
                    Content = "Discord invite link copied!", 
                    Duration = 2, 
                    Icon = "copy" 
                })
            end
        }
    }
})

local DiscordSectionMeow = HomeTab:Section({ 
    Title = "Meow Discord server!",
    Icon = "globe",
    Opened = true,
})

DiscordSectionMeow:Paragraph({
    Title = "Meow",
    Desc = "Join our Discord community :)",
    ImageSize = 64,
    Buttons = {
        {
            Title = "Copy Discord Invite",
            Icon = "link",
            Callback = function()
                setclipboard("discord.gg/WYyANHBgbZ")
                WindUI:Notify({ 
                    Title = "✅ Copied", 
                    Content = "Discord invite link copied!", 
                    Duration = 2, 
                    Icon = "copy" 
                })
            end
        }
    }
})

local UISection = HomeTab:Section({ 
    Title = "UI Library (Author)",
    Icon = "palette",
    Opened = true,
})

UISection:Button({
    Title = "GitHub Author",
    Desc = "Click to copy GitHub author link",
    Icon = "palette",
    Callback = function()
        pcall(function() setclipboard("https://github.com/Footagesus") end)
        WindUI:Notify({ 
            Title = "✅ Copied", 
            Content = "GitHub author link copied!", 
            Duration = 3, 
            Icon = "copy" 
        })
    end
})

-- FARM TAB
local FarmTab = Window:Tab({
    Title = "Farm",
    Icon = "house",
    Locked = false,
})

local MainFarmSection = FarmTab:Section({ 
    Title = "Main Farm",
    Icon = "wheat",
    Opened = true,
})

local Settings = {
    FarmTool = "Melee", -- "Sword" / "Blox Fruit"
    BringMobs = true,
    BringDistance = 350,
    AutoAttack = true,
    SmoothMode = false,
    NoAimMobs = false
}

local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Remotes:WaitForChild("CommF_")
local Enemies = Workspace:WaitForChild("Enemies")
local Characters = Workspace:WaitForChild("Characters")

-- Quest Data
local QuestData = {
    ForgottenQuest = {
        {LevelReq = 1425, Name = "Sea Soldier", Task = {["Sea Soldier"] = 8}},
        {LevelReq = 1450, Name = "Water Fighter", Task = {["Water Fighter"] = 8}},
        {LevelReq = 1475, Name = "Tide Keeper", Task = {["Tide Keeper"] = 1}}
    },
    JungleQuest = {
        {LevelReq = 10, Name = "Monkeys", Task = {Monkey = 6}},
        {LevelReq = 15, Name = "Gorillas", Task = {Gorilla = 8}},
        {LevelReq = 20, Name = "Gorilla King", Task = {["The Gorilla King"] = 1}}
    },
    BanditQuest1 = {
        {LevelReq = 0, Name = "Bandits", Task = {Bandit = 5}}
    },
    BuggyQuest1 = {
        {LevelReq = 30, Name = "Pirates", Task = {Pirate = 8}},
        {LevelReq = 40, Name = "Brute", Task = {Brute = 8}},
        {LevelReq = 55, Name = "Bobby", Task = {Bobby = 1}}
    },
    DesertQuest = {
        {LevelReq = 60, Name = "Desert Bandit", Task = {["Desert Bandit"] = 8}},
        {LevelReq = 75, Name = "Desert Officer", Task = {["Desert Officer"] = 6}}
    },
    SnowQuest = {
        {LevelReq = 90, Name = "Snow Bandit", Task = {["Snow Bandit"] = 7}},
        {LevelReq = 100, Name = "Snowman", Task = {Snowman = 8}},
        {LevelReq = 105, Name = "Yeti", Task = {Yeti = 1}}
    },
    MarineQuest2 = {
        {LevelReq = 120, Name = "Chief Petty Officer", Task = {["Chief Petty Officer"] = 8}},
        {LevelReq = 130, Name = "Vice Admiral", Task = {["Vice Admiral"] = 1}}
    },
    SkyQuest = {
        {LevelReq = 150, Name = "Sky Bandit", Task = {["Sky Bandit"] = 7}},
        {LevelReq = 175, Name = "Dark Master", Task = {["Dark Master"] = 8}}
    },
}

local AutoFarmLevel = {
    Enabled = false,
    CurrentQuest = nil,
    CurrentQuestData = nil
}

-- Получить уровень игрока
function AutoFarmLevel:GetPlayerLevel()
    local success, levelValue = pcall(function()
        return Player:WaitForChild("Data"):WaitForChild("Level").Value
    end)
    return success and levelValue or 0
end

-- Найти подходящий квест
function AutoFarmLevel:FindSuitableQuest()
    local playerLevel = self:GetPlayerLevel()
    local bestQuest, bestQuestData
    for questName, questList in pairs(QuestData) do
        for _, questInfo in ipairs(questList) do
            if playerLevel >= questInfo.LevelReq then
                if not bestQuestData or questInfo.LevelReq > bestQuestData.LevelReq then
                    bestQuest = questName
                    bestQuestData = questInfo
                end
            end
        end
    end
    return bestQuest, bestQuestData
end

-- Взять квест
function AutoFarmLevel:TakeQuest(questName, questNumber)
    pcall(function()
        CommF:InvokeServer("StartQuest", questName, questNumber or 1)
    end)
end

-- Проверить квест
function AutoFarmLevel:HasQuest()
    local success, result = pcall(function()
        return CommF:InvokeServer("CheckQuest")
    end)
    return success and result or false
end

-- Найти моба
function AutoFarmLevel:FindTargetMob(mobName)
    for _, enemy in pairs(Enemies:GetChildren()) do
        if enemy.Name == mobName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            return enemy
        end
    end
    return nil
end

-- Телепорт персонажа
function AutoFarmLevel:TweenToPosition(targetPosition, speed)
    local character = Player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local humanoidRootPart = character.HumanoidRootPart
    local tweenInfo = TweenInfo.new((humanoidRootPart.Position - targetPosition).Magnitude / (speed or 300), Enum.EasingStyle.Linear)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    tween:Play()
    return tween
end

-- Атака моба
function AutoFarmLevel:AttackMob(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Позиция НАД мобом на 20 Y (чтобы не били)
    local targetCFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
    character.HumanoidRootPart.CFrame = targetCFrame
    
    self:EquipWeapon()
    
    -- Реальная атака
    if Settings.AutoAttack then
        self:PerformAutoAttack()
    end
end

-- Экипировать оружие
function AutoFarmLevel:EquipWeapon()
    local character = Player.Character
    if not character then return end
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return end
    local tool = backpack:FindFirstChildWhichIsA("Tool")
    if tool and not character:FindFirstChildWhichIsA("Tool") then
        character.Humanoid:EquipTool(tool)
    end
end

-- Автоатака
function AutoFarmLevel:PerformAutoAttack()
    local character = player.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    -- Используем RemoteEvent для атаки (как в вашем обфусцированном коде)
    local combat = ReplicatedStorage.Remotes:FindFirstChild("Combat")
    if combat then
        pcall(function()
            combat:FireServer()
        end)
    end
    
    -- Альтернативный метод - виртуальный клик
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.01)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Bring mobs
function AutoFarmLevel:BringMobs(targetMobName)
    if not Settings.BringMobs then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local playerPosition = character.HumanoidRootPart.Position
    
    for _, enemy in pairs(Enemies:GetChildren()) do
        if enemy.Name == targetMobName and enemy:FindFirstChild("HumanoidRootPart") then
            local humanoid = enemy:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local distance = (enemy.HumanoidRootPart.Position - playerPosition).Magnitude
                
                if distance <= Settings.BringDistance then
                    -- Приносим мобов К НАМ (под нас)
                    pcall(function()
                        enemy.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -15, 0)
                        enemy.HumanoidRootPart.CanCollide = false
                        enemy.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60) -- Увеличиваем хитбокс
                        
                        -- Отключаем коллизию
                        if enemy:FindFirstChild("Head") then
                            enemy.Head.CanCollide = false
                        end
                    end)
                end
            end
        end
    end
end

-- Основной цикл фарма
function AutoFarmLevel:StartFarming()
    self.Enabled = true
    task.spawn(function()
        while self.Enabled do
            task.wait(Settings.SmoothMode and 0.25 or 0.05)
            local questName, questData = self:FindSuitableQuest()
            
            if questName and questData then
                if not self:HasQuest() then
                    self:TakeQuest(questName, 1)
                    task.wait(1)
                end

                local targetMobName = next(questData.Task)
                if targetMobName then
                    -- Приносим мобов ПЕРВЫМ
                    self:BringMobs(targetMobName)
                    
                    local targetMob = self:FindTargetMob(targetMobName)
                    if targetMob then
                        self:AttackMob(targetMob)
                    else
                        task.wait(2)
                    end
                else
                    task.wait(5)
                end
            else
                warn("Не найден квест для уровня")
                task.wait(5)
            end
        end
    end)
end

function AutoFarmLevel:StopFarming()
    self.Enabled = false
end

MainFarmSection:Toggle({
    Title = "Auto Farm Level",
    Desc = "Auto complete quests and farm",
    Icon = "circle-fading-arrow-up",
    Value = false,
    Callback = function(state) 
        if state then
            print("Auto Farm Level: Включен")
            AutoFarmLevel:StartFarming()
        else
            print("Auto Farm Level: Выключен")
            AutoFarmLevel:StopFarming()
        end
    end
})
MainFarmSection:Toggle({
    Title = "Auto Factory",
    Icon = "factory",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

MainFarmSection:Toggle({
    Title = "Auto Pirate Raid",
    Icon = "shield-alert",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

local EctoplasmSection = FarmTab:Section({ 
    Title = "Ectoplasm",
    Icon = "ghost",
    Opened = true,
})

EctoplasmSection:Toggle({
    Title = "Auto Farm Ectoplasm",
    Icon = "play",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

-- COLLECT SECTION
local CollectSection = FarmTab:Section({ 
    Title = "Collect",
    Icon = "box",
    Opened = true,
})

local chestModels = workspace:WaitForChild("ChestModels")
local collectFlySpeed = 300
local isCollecting = false
local currentTween = nil

local function flyToModel(targetModel)
    if not targetModel:IsA("Model") then return end
    if not isCollecting then return end
    
    local targetPosition
    if targetModel.PrimaryPart then
        targetPosition = targetModel.PrimaryPart.Position
    else
        local _, size = targetModel:GetBoundingBox()
        targetPosition = size.Position
    end
    
    local distance = (targetPosition - humanoidRootPart.Position).Magnitude
    local duration = distance / collectFlySpeed
    
    local dynamicTweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
    
    currentTween = TweenService:Create(
        humanoidRootPart,
        dynamicTweenInfo,
        {CFrame = CFrame.new(targetPosition)}
    )
    
    currentTween:Play()
    currentTween.Completed:Wait()
end

local function startCollecting()
    while isCollecting do
        local collected = false
        
        for _, chestModel in ipairs(chestModels:GetChildren()) do
            if not isCollecting then break end
            
            flyToModel(chestModel)
            
            if isCollecting then
                wait(0.5)
                collected = true
            end
        end
        
        if not collected or not isCollecting then
            break
        end
        
        wait(0.5)
    end
end

CollectSection:Toggle({
    Title = "Auto Collect Chests",
    Desc = "Tween",
    Icon = "box",
    Default = false,
    Callback = function(value)
        isCollecting = value
        
        if value then
            spawn(function()
                startCollecting()
            end)
        else
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
        end
    end
})

CollectSection:Toggle({
    Title = "Auto Collect Berries",
    Desc = "Tween",
    Icon = "grape",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

-- BOSSES SECTION
local BossesSection = FarmTab:Section({ 
    Title = "Bosses",
    Icon = "id-card-lanyard",
    Opened = true,
})

BossesSection:Dropdown({
    Title = "Boss List",
    Values = { "Boss 1", "Boss 2", "Boss 3" },
    Value = false,
    Multi = false,
    AllowNone = true,
    Callback = function(option) 
        -- Добавьте логику здесь
    end
})

BossesSection:Toggle({
    Title = "Auto Kill Boss Selected",
    Desc = "Kill boss selected",
    Icon = "id-card-lanyard",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

BossesSection:Toggle({
    Title = "Auto Farm All Bosses",
    Desc = "Kill all Bosses spawned",
    Icon = "id-card-lanyard",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

BossesSection:Toggle({
    Title = "Take Boss Quest",
    Icon = "circle-question-mark",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

-- MATERIAL SECTION
local MaterialSection = FarmTab:Section({ 
    Title = "Material",
    Icon = "gem",
    Opened = true,
})

MaterialSection:Dropdown({
    Title = "Material List",
    Values = { "Material 1", "Material 2", "Material 3" },
    Value = false,
    Multi = false,
    AllowNone = true,
    Callback = function(option) 
        -- Добавьте логику здесь
    end
})

MaterialSection:Toggle({
    Title = "Auto Farm Material",
    Desc = "Farm material selected",
    Icon = "circle-question-mark",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

-- SEA TAB
local SeaTab = Window:Tab({
    Title = "Sea",
    Icon = "waves",
    Locked = false,
})

local SeaFarmSection = SeaTab:Section({
    Title = "Drive",
    Icon = "sailboat",
    Opened = true
})

local AutoSail = false
local StepInterval = 0.25
local StepDistance = 10

SeaFarmSection:Toggle({
    Title = "Auto Drive Boat",
    Icon = "sailboat",
    Default = false,
    Callback = function(state)
        AutoSail = state
        if state then
            WindUI:Notify({
                Title = "🚀 Auto Drive Boat Enabled",
                Content = "Teleporting to nearest boat...",
                Duration = 2,
                Icon = "anchor"
            })

            task.spawn(function()
                while AutoSail do
                    task.wait(StepInterval)

                    local localChar = player.Character
                    if not localChar then continue end
                    local localHrp = localChar:FindFirstChild("HumanoidRootPart")
                    if not localHrp then continue end

                    local boats = workspace:FindFirstChild("Boats")
                    if not boats then continue end
                    
                    local targetBoat = nil
                    for _, boat in ipairs(boats:GetChildren()) do
                        local seat = boat:FindFirstChildWhichIsA("VehicleSeat")
                        if seat then
                            targetBoat = seat
                            break
                        end
                    end

                    if not targetBoat then continue end
                    local seat = targetBoat

                    if not seat.Occupant then
                        localHrp.CFrame = seat.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.2)
                        local humanoid = localChar:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            pcall(function()
                                seat:Sit(humanoid)
                            end)
                        end
                    else
                        pcall(function()
                            seat.CFrame = seat.CFrame + seat.CFrame.LookVector * StepDistance
                        end)
                    end
                end
            end)
        else
            WindUI:Notify({
                Title = "🛑 Auto Drive Boat Disabled",
                Content = "Auto boat teleport stopped.",
                Duration = 2,
                Icon = "anchor"
            })
        end
    end
})

local SeaConfigsSection = SeaTab:Section({
    Title = "Configs",
    Icon = "cog",
    Opened = true
})

SeaConfigsSection:Slider({
    Title = "Step Interval",
    Step = 0.1,
    Value = {Min = 0.25, Max = 2, Default = StepInterval},
    Callback = function(v)
        StepInterval = v
    end
})

SeaConfigsSection:Slider({
    Title = "Step Distance",
    Step = 5,
    Value = {Min = 10, Max = 125, Default = StepDistance},
    Callback = function(v)
        StepDistance = v
    end
})

-- FISHING TAB
local FishingTab = Window:Tab({
    Title = "Fishing",
    Icon = "fish",
    Locked = false,
})

local FishingSection = FishingTab:Section({ 
    Title = "Fishing",
    Icon = "fish",
    Opened = true,
})

FishingSection:Toggle({
    Title = "Auto Fish",
    Icon = "shrimp",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

local BaitSection = FishingTab:Section({ 
    Title = "Bait",
    Icon = "shrimp",
    Opened = true,
})

BaitSection:Dropdown({
    Title = "Select Bait",
    Values = { "Bait 1", "Bait 2", "Bait 3" },
    Value = false,
    Multi = false,
    AllowNone = true,
    Callback = function(option) 
        -- Добавьте логику здесь
    end
})

BaitSection:Slider({
    Title = "Max Baits",
    Step = 10,
    Value = {
        Min = 10,
        Max = 90,
        Default = 10,
    },
    Callback = function(value)
        -- Добавьте логику здесь
    end
})

BaitSection:Toggle({
    Title = "Auto Buy Baits",
    Icon = "shrimp",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

BaitSection:Button({
    Title = "Buy Baits",
    Icon = "fish",
    Callback = function()
        -- Добавьте логику здесь
    end
})

local QuestSection = FishingTab:Section({ 
    Title = "Quest",
    Icon = "circle-question-mark",
    Opened = true,
})

QuestSection:Dropdown({
    Title = "Skip Quests",
    Values = { "Quest 1", "Quest 2", "Quest 3" },
    Value = false,
    Multi = false,
    AllowNone = true,
    Callback = function(option) 
        -- Добавьте логику здесь
    end
})

QuestSection:Toggle({
    Title = "Auto Quest",
    Desc = "Skip, Get Complete",
    Icon = "circle-check-big",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

QuestSection:Toggle({
    Title = "Take Quest Only When Fishing",
    Icon = "check",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

local SellSection = FishingTab:Section({ 
    Title = "Sell",
    Icon = "store",
    Opened = true,
})

SellSection:Dropdown({
    Title = "Select Fish Kind",
    Values = { "Normal", "Cursed", "Celestial" },
    Value = false,
    Multi = false,
    AllowNone = true,
    Callback = function(option) 
        -- Добавьте логику здесь
    end
})

SellSection:Toggle({
    Title = "Auto Sell Fish",
    Icon = "store",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

-- QUESTS/ITEMS TAB
local QuestsItemsTab = Window:Tab({
    Title = "Quests/Items",
    Icon = "circle-question-mark",
    Locked = false,
})

local NextSeaSection = QuestsItemsTab:Section({ 
    Title = "Next Sea",
    Icon = "arrow-big-right",
    Opened = true,
})

NextSeaSection:Toggle({
    Title = "Auto Third Sea",
    Desc = "Auto unlocks access to the Third Sea",
    Icon = "waves",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

NextSeaSection:Toggle({
    Title = "Auto Kill Don Swan",
    Desc = "Auto defeats Don Swan",
    Icon = "skull",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

local BossesSection2 = QuestsItemsTab:Section({ 
    Title = "Bosses",
    Icon = "id-card-lanyard",
    Opened = true,
})

BossesSection2:Toggle({
    Title = "Auto Darkbeard",
    Desc = "Auto spawn and defeat Darkbeard",
    Icon = "moon",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

BossesSection2:Toggle({
    Title = "Auto Cursed Captain",
    Desc = "Defeat the \"Cursed Captain\" Auto",
    Icon = "ghost",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

local OrderSection = QuestsItemsTab:Section({ 
    Title = "Order Law",
    Icon = "skull",
    Opened = true,
})

OrderSection:Toggle({
    Title = "Fully Raid Order",
    Desc = "Auto Spawns and defeats Order",
    Icon = "skull",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

OrderSection:Toggle({
    Title = "Auto Start [Fully]",
    Desc = "Auto spawns and defeats",
    Icon = "play",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

local SwordSection = QuestsItemsTab:Section({ 
    Title = "Sword",
    Icon = "sword",
    Opened = true,
})

SwordSection:Toggle({
    Title = "Auto Buy Legendary Sword",
    Desc = "Auto purchases Legendary Swords when available",
    Icon = "play",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

-- FRUIT/RAID TAB
local FruitRaidTab = Window:Tab({
    Title = "Fruit/Raid",
    Icon = "apple",
    Locked = false,
})

local GachaSection = FruitRaidTab:Section({ 
    Title = "Gacha",
    Icon = "dollar-sign",
    Opened = true,
})

GachaSection:Button({
    Title = "Roll Gacha Box",
    Icon = "box",
    Callback = function()
        local success, result = pcall(function()
            return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Cousin", "Buy")
        end)
        
        if success then
            -- можно обработать result, если нужно
        else
        
        end
    end
})

GachaSection:Button({
    Title = "Roll Haunted Gacha",
    Icon = "ghost",
    Callback = function()
    local success, result = pcall(function()
    return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Cousin", "Buy")
    end)
    
    if success then
    -- можно обработать result, если нужно
    else
    
    end

    end
})

local FruitsSection = FruitRaidTab:Section({ 
    Title = "Fruits",
    Icon = "apple",
    Opened = true,
})

local fruits = {
    "Rocket Fruit", "Spin Fruit", "Blade Fruit", "Spring Fruit", "Bomb Fruit",
    "Smoke Fruit", "Spike Fruit", "Flame Fruit", "Sand Fruit", "Dark Fruit",
    "Eagle Fruit", "Diamond Fruit", "Light Fruit", "Rubber Fruit", "Ghost Fruit",
    "Magma Fruit", "Quake Fruit", "Love Fruit", "Spider Fruit", "Creation Fruit",
    "Sound Fruit", "Phoenix Fruit", "Portal Fruit", "Lightning Fruit", "Rumble Fruit",
    "Pain Fruit", "Blizzard Fruit", "Gravity Fruit", "Mammoth Fruit", "T-Rex Fruit",
    "Dough Fruit", "Shadow Fruit", "Venom Fruit", "Control Fruit", "Gas Fruit",
    "Spirit Fruit", "Tiger Fruit", "Leopard Fruit", "Yeti Fruit", "Kitsune Fruit",
    "Dragon East Fruit", "Dragon West Fruit", "Fruit"
}

local bringing = false

local function bringFruits()
    for _, obj in ipairs(workspace:GetChildren()) do
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

FruitsSection:Toggle({
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
                    task.wait(3)
                end
            end)
        else
            print("❌ Auto Bring Fruits disabled")
        end
    end
})

local bringingFruits = false

FruitsSection:Toggle({
    Title = "Auto Store Fruits",
    Icon = "backpack",
    Value = false,
    Callback = function(state) 
        bringingFruits = state

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

            for _, item in pairs(player.Backpack:GetChildren()) do
                tryStore(item)
            end

            local localChar = player.Character or player.CharacterAdded:Wait()
            for _, item in pairs(localChar:GetChildren()) do
                tryStore(item)
            end

            return storedCount
        end

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
                Content = "Auto Store fruits disable.",
                Duration = 3,
                Icon = "x"
            })
        end
    end
})

local RaidSection = FruitRaidTab:Section({ 
    Title = "Raid",
    Icon = "shield-half",
    Opened = true,
})

RaidSection:Dropdown({
    Title = "Select Chip",
    Values = { "Chip 1", "Chip 2", "Chip 3" },
    Value = false,
    Multi = false,
    AllowNone = true,
    Callback = function(option) 
        -- Добавьте логику здесь
    end
})

RaidSection:Toggle({
    Title = "Auto Farm Raid",
    Desc = "Start, Defeat Mobs",
    Icon = "shield-user",
    Value = false,
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})

RaidSection:Toggle({
    Title = "Auto Buy Chip",
    Icon = "microchip",
    Value = false,
    Callback = function(state) 
        -- Добавьте логику здесь
    end
})

-- HOP TAB
local HopTab = Window:Tab({
    Title = "Hop",
    Icon = "gem",
    Locked = false,
})

-- STATS TAB
local StatsTab = Window:Tab({
    Title = "Stats",
    Icon = "chart-column-increasing",
    Locked = false,
})

-- TELEPORT TAB
local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "map",
    Locked = false,
})

local TravelSection = TeleportTab:Section({ 
    Title = "Travel",
    Icon = "navigation",
    Opened = true,
})

TravelSection:Button({
    Title = "⚠️ Teleport to Sea 1",
    Desc = "Main",
    Icon = "waves",
    Callback = function()
        local success, result = pcall(function()
            return ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelMain")
        end)
        
        if success then
            print("Teleported to Sea 1")
        else
            warn("Failed to teleport to Sea 1")
        end
    end
})

TravelSection:Button({
    Title = "⚠️ Teleport to Sea 2",
    Desc = "Zou",
    Icon = "waves",
    Callback = function()
        local success, result = pcall(function()
            return ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
        end)
        
        if success then
            print("Teleported to Sea 2")
        else
            warn("Failed to teleport to Sea 2")
        end
    end
})

TravelSection:Button({
    Title = "⚠️ Teleport to Sea 3",
    Desc = "Dressrosa",
    Icon = "waves",
    Callback = function()
        local success, result = pcall(function()
            return ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou")
        end)
        
        if success then
            print("Teleported to Sea 3")
        else
            warn("Failed to teleport to Sea 3")
        end
    end
})

local IslandsSection = TeleportTab:Section({ 
    Title = "Islands",
    Icon = "tree-palm",
    Opened = true,
})

local map = workspace:WaitForChild("Map")

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

local islands = GetIslands()
local selectedIsland = nil

local IslandDropdown = IslandsSection:Dropdown({
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
        IslandDropdown:SetValues(GetIslands())
    end
end)

local activeTween = nil

IslandsSection:Toggle({
    Title = "Teleport to Island",
    Icon = "tree-palm",
    Value = false,
    Callback = function(state)
        if state then
            if not selectedIsland then
                warn("Island not selected!")
                return
            end

            local target = selectedIsland.PrimaryPart or selectedIsland:FindFirstChildWhichIsA("BasePart")
            if not target then
                warn("Island has no valid part!")
                return
            end

            local upCFrame = humanoidRootPart.CFrame + Vector3.new(0, 50, 0)
            local upTween = TweenService:Create(
                humanoidRootPart,
                TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { CFrame = upCFrame }
            )
            upTween:Play()
            upTween.Completed:Wait()

            local distance = (humanoidRootPart.Position - target.Position).Magnitude
            local time = distance / 300
            local goalCFrame = target.CFrame + Vector3.new(0, 5, 0)

            activeTween = TweenService:Create(
                humanoidRootPart,
                TweenInfo.new(time, Enum.EasingStyle.Linear),
                { CFrame = goalCFrame }
            )
            activeTween:Play()

        else
            if activeTween then
                activeTween:Cancel()
                activeTween = nil
            end
        end
    end
})

local NPCsSection = TeleportTab:Section({ 
    Title = "NPCs",
    Icon = "circle-question-mark",
    Opened = true,
})

local NPCFolder = ReplicatedStorage:WaitForChild("NPCs")

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

local npcs = GetNPCs()
local selectedNPC = nil

local NPCDropdown = NPCsSection:Dropdown({
    Title = "Select NPC",
    Values = npcs,
    Value = false,
    Multi = false,
    AllowNone = true,
    Callback = function(option)
        selectedNPC = NPCFolder:FindFirstChild(option)
    end
})

NPCFolder.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart") then
        NPCDropdown:SetValues(GetNPCs())
    end
end)

local activeTweenNPC = nil

NPCsSection:Toggle({
    Title = "Teleport to NPC",
    Icon = "user",
    Value = false,
    Callback = function(state)
        if state then
            if not selectedNPC then
                warn("NPC not selected!")
                return
            end

            local target = selectedNPC.PrimaryPart or selectedNPC:FindFirstChildWhichIsA("BasePart")
            if not target then
                warn("NPC has no valid part!")
                return
            end

            local upCFrame = humanoidRootPart.CFrame + Vector3.new(0, 50, 0)
            local upTween = TweenService:Create(
                humanoidRootPart,
                TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { CFrame = upCFrame }
            )
            upTween:Play()
            upTween.Completed:Wait()

            local distance = (humanoidRootPart.Position - target.Position).Magnitude
            local time = distance / 300
            local goalCFrame = target.CFrame + Vector3.new(0, 5, 0)

            activeTweenNPC = TweenService:Create(
                humanoidRootPart,
                TweenInfo.new(time, Enum.EasingStyle.Linear),
                { CFrame = goalCFrame }
            )
            activeTweenNPC:Play()

        else
            if activeTweenNPC then
                activeTweenNPC:Cancel()
                activeTweenNPC = nil
            end
        end
    end
})

local IslandsFastSection = TeleportTab:Section({ 
    Title = "Islands Fast",
    Icon = "fast-forward",
    Opened = true,
})

local function simulateTouch(part)
    if not part or not part:IsA("BasePart") then
        return
    end

    if typeof(firetouchinterest) == "function" then
        pcall(function()
            firetouchinterest(hrp, part, 0)
            task.wait(0.12)
            firetouchinterest(hrp, part, 1)
        end)
        return true
    end

    local targetCFrame = part.CFrame * CFrame.new(0, 0, -2)
    local origCFrame = hrp.CFrame
    local touchedOnce = false
    local conn

    conn = part.Touched:Connect(function(hit)
        if hit and hit.Parent == char then
            touchedOnce = true
        end
    end)

    pcall(function()
        hrp.CFrame = targetCFrame
    end)

    local timeout = 2
    local timer = 0
    while not touchedOnce and timer < timeout do
        task.wait(0.1)
        timer = timer + 0.1
    end

    pcall(function()
        hrp.CFrame = origCFrame
    end)

    if conn then conn:Disconnect() end

    return touchedOnce
end

IslandsFastSection:Button({
    Title = "Teleport to Castle on the Sea",
    Icon = "castle",
    Callback = function()
        local targetPart = workspace.Map.Turtle.MapTeleportB.Hitbox
        simulateTouch(targetPart)
    end
})

IslandsFastSection:Button({
    Title = "Teleport to Mansion",
    Icon = "house-heart",
    Callback = function()
        local targetPart = workspace.Map["Boat Castle"].MapTeleportA.Hitbox
        simulateTouch(targetPart)
    end
})

IslandsFastSection:Button({
    Title = "Teleport to Hydra Island",
    Icon = "tree-palm",
    Callback = function()
        local targetPart = workspace.Map["Boat Castle"].MapTeleportB.Hitbox
        simulateTouch(targetPart)
    end
})

IslandsFastSection:Button({
    Title = "Teleport to Tiki Outpost",
    Icon = "waves",
    Callback = function()
        local targetPart = workspace.Map["Boat Castle"].MapTeleportC.Hitbox
        simulateTouch(targetPart)
    end
})

-- VISUAL TAB
local VisualTab = Window:Tab({
    Title = "Visual",
    Icon = "eye",
    Locked = false,
})

local EspSection = VisualTab:Section({ 
    Title = "ESP",
    Icon = "eye",
    Opened = true,
})

local ESP_Enabled = false
local ESP_Objects = {}
local ESP_Connections = {}

local function getPlayerColor(player)
    if player.Team and player.Team.TeamColor then
        return player.Team.TeamColor.Color
    else
        return Color3.fromRGB(255, 255, 255)
    end
end

local function createPlayerESP(player)
    if player == Players.LocalPlayer then return end
    if ESP_Objects[player] then return end

    local function setup(char)
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        local hrp = char.HumanoidRootPart
        local head = char:FindFirstChild("Head") or hrp

        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerESP_Highlight"
        highlight.FillTransparency = 0.75
        highlight.OutlineTransparency = 0.15
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = getPlayerColor(player)
        highlight.OutlineColor = highlight.FillColor
        highlight.Parent = char

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

    for _, player in pairs(Players:GetPlayers()) do
        createPlayerESP(player)
    end

    ESP_Connections["PlayerAdded"] = Players.PlayerAdded:Connect(function(player)
        createPlayerESP(player)
    end)

    ESP_Connections["PlayerRemoving"] = Players.PlayerRemoving:Connect(function(player)
        removePlayerESP(player)
    end)

    print("[ESP] Player ESP Enabled ✅")
end

local function disableESP()
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

EspSection:Toggle({
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

local ESP_Fruits_Enabled = false
local ESP_Fruits = {}
local ESP_Fruit_Connections = {}

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
    ["Dragon West Fruit"] = Color3.fromRGB(100, 150, 255),
    ["Fruit"] = Color3.fromRGB(255, 255, 255),
}

local function getFruitColor(name)
    return FruitColors[name] or Color3.fromRGB(255, 255, 255)
end

local function createFruitESP(fruit)
    if not fruit:IsA("BasePart") and not fruit:IsA("Model") then return end
    if ESP_Fruits[fruit] then return end

    local part = fruit:IsA("BasePart") and fruit or fruit:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local name = fruit.Name

    local highlight = Instance.new("Highlight")
    highlight.Name = "FruitESP_Highlight"
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = getFruitColor(name)
    highlight.OutlineColor = getFruitColor(name)
    highlight.Parent = fruit

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

    for _, obj in pairs(Workspace:GetChildren()) do
        if FruitColors[obj.Name] then
            createFruitESP(obj)
        end
    end

    ESP_Fruit_Connections["ChildAdded"] = Workspace.ChildAdded:Connect(function(obj)
        if FruitColors[obj.Name] then
            task.wait(0.3)
            createFruitESP(obj)
        end
    end)

    ESP_Fruit_Connections["ChildRemoved"] = Workspace.ChildRemoved:Connect(function(obj)
        removeFruitESP(obj)
    end)

    print("[ESP] Fruits ESP Enabled ✅")
end

local function disableFruitESP()
    for fruit, data in pairs(ESP_Fruits) do
        removeFruitESP(fruit)
    end
    ESP_Fruits = {}

    for _, conn in pairs(ESP_Fruit_Connections) do
        if conn then conn:Disconnect() end
    end
    ESP_Fruit_Connections = {}

    print("[ESP] Fruits ESP Disabled ❌")
end

EspSection:Toggle({
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

local ESP_Chest_Enabled = false
local ESP_Chests = {}
local ESP_Chest_Connections = {}
local ChestFolder = workspace:WaitForChild("ChestModels")

local function getChestColor(chestName)
    chestName = string.lower(chestName)
    if string.find(chestName, "diamond") then
        return Color3.fromRGB(0, 255, 255)
    elseif string.find(chestName, "gold") then
        return Color3.fromRGB(255, 215, 0)
    elseif string.find(chestName, "silver") then
        return Color3.fromRGB(192, 192, 192)
    else
        return Color3.fromRGB(255, 255, 255)
    end
end

local function createChestESP(chest)
    if not chest:IsA("Model") then return end
    if ESP_Chests[chest] then return end

    local basePart = chest:FindFirstChildWhichIsA("BasePart")
    if not basePart then return end

    local color = getChestColor(chest.Name)

    local highlight = Instance.new("Highlight")
    highlight.Name = "ChestESP_Highlight"
    highlight.FillColor = color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = chest

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

    local conn = RunService.Heartbeat:Connect(function()
        local localPlayer = game.Players.LocalPlayer
        local localChar = localPlayer.Character
        local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

        if not chest or not chest.Parent or not localHrp then
            conn:Disconnect()
            highlight:Destroy()
            billboard:Destroy()
            ESP_Chests[chest] = nil
            return
        end

        local distance = math.floor((localHrp.Position - basePart.Position).Magnitude)
        label.Text = string.format("%s\n[%dm]", chest.Name or "Chest", distance)
    end)

    ESP_Chests[chest] = {
        Highlight = highlight,
        Billboard = billboard,
        Conn = conn
    }
end

local function removeChestESP(chest)
    local data = ESP_Chests[chest]
    if not data then return end

    if data.Conn then data.Conn:Disconnect() end
    if data.Highlight then data.Highlight:Destroy() end
    if data.Billboard then data.Billboard:Destroy() end

    ESP_Chests[chest] = nil
end

local function enableChestESP()
    disableChestESP()

    for _, chest in ipairs(ChestFolder:GetChildren()) do
        createChestESP(chest)
    end

    ESP_Chest_Connections["ChildAdded"] = ChestFolder.ChildAdded:Connect(function(chest)
        task.wait(0.2)
        createChestESP(chest)
    end)

    ESP_Chest_Connections["ChildRemoved"] = ChestFolder.ChildRemoved:Connect(function(chest)
        removeChestESP(chest)
    end)

    print("[ESP] Chests ESP Enabled ✅")
end

local function disableChestESP()
    for chest, data in pairs(ESP_Chests) do
        removeChestESP(chest)
    end
    ESP_Chests = {}

    for _, conn in pairs(ESP_Chest_Connections) do
        if conn then conn:Disconnect() end
    end
    ESP_Chest_Connections = {}

    print("[ESP] Chests ESP Disabled ❌")
end

EspSection:Toggle({
    Title = "ESP Chests",
    Icon = "eye",
    Value = false,
    Callback = function(state)
        ESP_Chest_Enabled = state
        if state then
            enableChestESP()
        else
            disableChestESP()
        end
    end
})

-- SHOP TAB
local CommF = ReplicatedStorage.Remotes.CommF_

local ShopTab = Window:Tab({ 
    Title = "Shop",
    Icon = "shopping-cart",
    Locked = false,
})

local function au(title, sectionIcon, items)
    local section = ShopTab:Section({
        Title = title,
        Icon = sectionIcon or "circle",
        Opened = true,
    })

    for _, v in ipairs(items) do
        local buttonTitle = v[1]
        local args = v[2]
        local buttonIcon = v[3] or "shopping-bag"

        section:Button({
            Title = buttonTitle,
            Icon = buttonIcon,
            Callback = function()
                CommF:InvokeServer(unpack(args))
            end,
        })
    end
end

au("Frags", "coins", {
    {"Race Reroll", {"BlackbeardReward","Reroll","2"}, "rotate-ccw"},
    {"Reset Stats", {"BlackbeardReward","Refund","2"}, "refresh-cw"},
})

au("Fighting Style", "hand", {
    {"Buy Black Leg", {"BuyBlackLeg"}, "flame"},
    {"Buy Electro", {"BuyElectro"}, "zap"},
    {"Buy Fishman Karate", {"BuyFishmanKarate"}, "droplet"},
    {"Buy Dragon Claw", {"BlackbeardReward","DragonClaw","2"}, "flame"},
    {"Buy Superhuman", {"BuySuperhuman"}, "sparkles"},
    {"Buy Death Step", {"BuyDeathStep"}, "skull"},
    {"Buy Sharkman Karate", {"BuySharkmanKarate"}, "anchor"},
    {"Buy Electric Claw", {"BuyElectricClaw"}, "zap"},
    {"Buy Dragon Talon", {"BuyDragonTalon"}, "flame"},
    {"Buy GodHuman", {"BuyGodhuman"}, "star"},
    {"Buy Sanguine Art", {"BuySanguineArt"}, "droplet"},
})

au("Ability Teacher", "brain", {
    {"Buy Geppo", {"BuyHaki","Geppo"}, "wind"},
    {"Buy Buso", {"BuyHaki","Buso"}, "shield"},
    {"Buy Soru", {"BuyHaki","Soru"}, "zap"},
    {"Buy Ken", {"KenTalk","Buy"}, "eye"},
})

au("Sword", "swords", {
    {"Buy Katana", {"BuyItem","Katana"}, "sword"},
    {"Buy Cutlass", {"BuyItem","Cutlass"}, "axe"},
    {"Buy Dual Katana", {"BuyItem","Dual Katana"}, "swords"},
    {"Buy Iron Mace", {"BuyItem","Iron Mace"}, "hammer"},
    {"Buy Triple Katana", {"BuyItem","Triple Katana"}, "swords"},
    {"Buy Pipe", {"BuyItem","Pipe"}, "minus"},
    {"Buy Dual-Headed Blade", {"BuyItem","Dual-Headed Blade"}, "scissors"},
    {"Buy Soul Cane", {"BuyItem","Soul Cane"}, "wand"},
    {"Buy Bisento", {"BuyItem","Bisento"}, "axe"},
})

au("Gun", "target", {
    {"Buy Musket", {"BuyItem","Musket"}, "crosshair"},
    {"Buy Slingshot", {"BuyItem","Slingshot"}, "target"},
    {"Buy Flintlock", {"BuyItem","Flintlock"}, "target"},
    {"Buy Refined Slingshot", {"BuyItem","Refined Slingshot"}, "target"},
    {"Buy Dual Flintlock", {"BuyItem","Dual Flintlock"}, "target"},
    {"Buy Cannon", {"BuyItem","Cannon"}, "bomb"},
    {"Buy Kabucha", {"BlackbeardReward","Slingshot","2"}, "rocket"},
})

au("Accessories", "crown", {
    {"Buy Black Cape", {"BuyItem","Black Cape"}, "shield"},
    {"Buy Swordsman Hat", {"BuyItem","Swordsman Hat"}, "crown"},
    {"Buy Tomoe Ring", {"BuyItem","Tomoe Ring"}, "circle"},
})

au("Race", "user", {
    {"Ghoul Race", {"Ectoplasm","Change",4}, "skull"},
    {"Cyborg Race", {"CyborgTrainer","Buy"}, "cpu"},
})

-- MISC TAB
local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "cog",
    Locked = false,
})

local ServerSection = MiscTab:Section({
    Title = "Server",
    Icon = "server",
    Opened = true,
})

ServerSection:Button({
    Title = "Rejoin",
    Icon = "rotate-ccw",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end,
})

ServerSection:Button({
    Title = "Server Hop",
    Icon = "workflow",
    Callback = function()
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

ServerSection:Button({
    Title = "Hop To Lower Player",
    Icon = "workflow",
    Callback = function()
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
    Icon = "swords",
    Opened = true,
})

TeamsSection:Button({
    Title = "Join Pirates Team",
    Icon = "sword",
    Callback = function()
        local success, result = pcall(function()
            return ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
        end)
    end
})

TeamsSection:Button({
    Title = "Join Marines Team",
    Icon = "anchor",
    Callback = function()
        local success, result = pcall(function()
            return ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
        end)
    end
})

local MenuSection = MiscTab:Section({ 
    Title = "Menu",
    Icon = "menu",
    Opened = true,
})

MenuSection:Button({
    Title = "Titles New",
    Icon = "captions",
    Callback = function()
        local titlesMenu = player.PlayerGui:WaitForChild("TitlesMenu")
        titlesMenu.Open:Fire()
    end
})

MenuSection:Button({
    Title = "Titles Old",
    Icon = "captions",
    Callback = function()
        local titlesFrame = player:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Titles")
        titlesFrame.Visible = true
    end
})

MenuSection:Button({
    Title = "Fish Index",
    Icon = "archive",
    Callback = function()
        local fishFrame = player:WaitForChild("PlayerGui"):WaitForChild("FishIndex"):WaitForChild("ROOT"):WaitForChild("Frame")
        fishFrame.Visible = not fishFrame.Visible
    end
})

local MovementSection = MiscTab:Section({ 
    Title = "Movement",
    Icon = "gauge",
    Opened = true,
})

MovementSection:Slider({
    Title = "Speed Multiplier",
    Step = 0.1,
    Value = {
        Min = 1,
        Max = 10,
        Default = 1,
    },
    Callback = function(value)
        speedMultiplier = value
        if character then
            character:SetAttribute("SpeedMultiplier", value)
        end
    end
})

MovementSection:Slider({
    Title = "JumpHeight",
    Step = 0.5,
    Value = {
        Min = 7.2,
        Max = 50,
        Default = 7.2,
    },
    Callback = function(value)
        currentJumpHeight = value
        local hum = getHumanoid()
        if hum then
            if hum.UseJumpPower then
                hum.UseJumpPower = false
            end
            hum.JumpHeight = value
        end
    end
})

local AbilitiesSection = MiscTab:Section({ 
    Title = "Abilities",
    Icon = "zap",
    Opened = true,
})

AbilitiesSection:Toggle({
    Title = "Noclip",
    Icon = "box",
    Default = false,
    Callback = function(state) 
        noclipEnabled = state
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not state
                end
            end
        end
    end
})

AbilitiesSection:Toggle({
    Title = "Infinite Jump",
    Icon = "arrow-up",
    Default = false,
    Callback = function(state) 
        infiniteJumpEnabled = state
    end
})

AbilitiesSection:Toggle({
    Title = "Walking on Water (Ice)",
    Icon = "waves",
    Value = false,
    Callback = function(state)
        if character then
            character:SetAttribute("WaterWalking", state)
        end
    end
})

local antiAdminEnabled = false
local antiAdminConnections = {}

AbilitiesSection:Toggle({
    Title = "Anti Admin",
    Icon = "shield-half",
    Default = false,
    Callback = function(state)
        antiAdminEnabled = state
        
        -- Очистка старых подключений
        for _, conn in pairs(antiAdminConnections) do
            if conn then conn:Disconnect() end
        end
        antiAdminConnections = {}
        
        if not state then return end

        local adminIds = {
            912348,
            3095250,
            17884881,
            8616008638,
        }

        local kickMessages = {
            [912348] = "Mygame43 joined your server",
            [3095250] = "Rip_indra joined your server",
            [17884881] = "Uzoth joined your server",
            [8616008638] = "Owner NovaAxis joined your server wow u lucky",
        }

        local adminSet = {}
        for _, id in ipairs(adminIds) do
            adminSet[id] = true
        end

        local function kickIfAdminPresent()
            for _, plr in ipairs(Players:GetPlayers()) do
                if adminSet[plr.UserId] then
                    local reason = kickMessages[plr.UserId] or "Restricted user joined — kicking to avoid interaction."
                    pcall(function()
                        player:Kick(reason)
                    end)
                    return true
                end
            end
            return false
        end

        -- Проверка текущих игроков
        kickIfAdminPresent()

        -- Слушатель новых игроков
        antiAdminConnections.PlayerAdded = Players.PlayerAdded:Connect(function(plr)
            if adminSet[plr.UserId] then
                local reason = kickMessages[plr.UserId] or "Restricted user joined — kicking to avoid interaction."
                pcall(function()
                    player:Kick(reason)
                end)
            end
        end)
    end
})

-- Infinite Jump обработчик
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)


