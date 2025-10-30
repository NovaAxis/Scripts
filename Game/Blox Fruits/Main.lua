-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Global variables
_G.autoFarmChest = false
_G.autoFarmMobs = false
_G.fastAttack = false
_G.bringMobs = false
_G.autoQuest = false
_G.useSkills = {Z = false, X = false, C = false, V = false, F = false}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

-- Game Objects
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Remotes:WaitForChild("CommF_")
local Enemies = workspace:WaitForChild("Enemies")
local Map = workspace:WaitForChild("Map")

-- Auto Farm Configuration
local FarmConfig = {
    AttackDelay = 0.1,
    FarmDistance = 20,
    BringDistance = 350,
    TweenSpeed = 300,
    LastAttack = 0,
    CurrentTarget = nil,
    CurrentTween = nil
}

-- Utility Functions
local function IsAlive(model)
    if not model or not model.Parent then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function GetDistance(pos)
    if typeof(pos) ~= "Vector3" then
        pos = pos.Position
    end
    return Player:DistanceFromCharacter(pos)
end

local function GetPlayerCharacter()
    return Player.Character
end

local function GetRootPart()
    local char = GetPlayerCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Enemy Functions
local function GetClosestEnemy(maxDistance)
    maxDistance = maxDistance or 5000
    local closest = nil
    local closestDist = maxDistance
    
    for _, enemy in pairs(Enemies:GetChildren()) do
        if IsAlive(enemy) then
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                local dist = GetDistance(enemyRoot.Position)
                if dist < closestDist then
                    closest = enemy
                    closestDist = dist
                end
            end
        end
    end
    
    return closest, closestDist
end

local function GetEnemiesByName(name)
    local enemies = {}
    for _, enemy in pairs(Enemies:GetChildren()) do
        if enemy.Name == name and IsAlive(enemy) then
            table.insert(enemies, enemy)
        end
    end
    return enemies
end

-- Quest System
local QuestData = {
    {min = 1, max = 9, quest = "BanditQuest1", npc = "Bandit"},
    {min = 10, max = 14, quest = "JungleQuest", npc = "Monkey"},
    {min = 15, max = 29, quest = "BuggyQuest1", npc = "Bandit"},
    {min = 30, max = 59, quest = "DesertQuest", npc = "Desert Bandit"},
    {min = 60, max = 89, quest = "SnowQuest", npc = "Snow Bandit"},
    {min = 90, max = 119, quest = "MarineQuest2", npc = "Marine Captain"},
    {min = 120, max = 149, quest = "SnowMountainQuest", npc = "Winter Warrior"},
}

local function GetCurrentQuest()
    local playerGui = Player:WaitForChild("PlayerGui")
    local questUI = playerGui:FindFirstChild("Main")
    if not questUI then return nil end
    
    local questInfo = questUI:FindFirstChild("Quest")
    if questInfo and questInfo.Visible then
        return {
            Active = true,
            Title = questInfo.Container.QuestTitle.Title.Text
        }
    end
    return nil
end

local function TakeQuest(questName, questNumber)
    local args = {
        [1] = "StartQuest",
        [2] = questName,
        [3] = questNumber or 1
    }
    CommF:InvokeServer(unpack(args))
    task.wait(0.5)
end

local function GetRecommendedQuest()
    local level = Player.Data.Level.Value
    
    for _, quest in pairs(QuestData) do
        if level >= quest.min and level <= quest.max then
            return quest
        end
    end
    
    return QuestData[1]
end

-- Combat Functions
local function EquipTool()
    local char = GetPlayerCharacter()
    if not char then return false end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return true end
    
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:EquipTool(item)
                task.wait(0.3)
                return true
            end
        end
    end
    
    return false
end

local function Attack()
    if tick() - FarmConfig.LastAttack < FarmConfig.AttackDelay then return end
    
    local char = GetPlayerCharacter()
    if not char then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    FarmConfig.LastAttack = tick()
end

local function UseSkills()
    for key, enabled in pairs(_G.useSkills) do
        if enabled then
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
            task.wait(0.1)
        end
    end
end

local function BringMobs(targetName, bringPosition)
    if not _G.bringMobs then return end
    
    local enemies = GetEnemiesByName(targetName)
    
    for _, enemy in pairs(enemies) do
        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
        if enemyRoot and GetDistance(enemyRoot.Position) < FarmConfig.BringDistance then
            for _, part in pairs(enemy:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            
            enemyRoot.CFrame = bringPosition
            enemyRoot.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Tween Function
local function TweenTo(targetCFrame)
    local rootPart = GetRootPart()
    if not rootPart then return end
    
    local distance = (targetCFrame.Position - rootPart.Position).Magnitude
    local duration = distance / FarmConfig.TweenSpeed
    
    if FarmConfig.CurrentTween then
        FarmConfig.CurrentTween:Cancel()
    end
    
    FarmConfig.CurrentTween = TweenService:Create(
        rootPart,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {CFrame = targetCFrame}
    )
    
    FarmConfig.CurrentTween:Play()
    return FarmConfig.CurrentTween
end

-- Main Farm Loop
local function FarmMob(mob)
    if not IsAlive(mob) then return false end
    
    FarmConfig.CurrentTarget = mob
    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
    
    if not mobRoot then return false end
    
    EquipTool()
    
    while IsAlive(mob) and _G.autoFarmMobs do
        local char = GetPlayerCharacter()
        local rootPart = GetRootPart()
        
        if not char or not rootPart then
            task.wait(1)
            continue
        end
        
        local farmCFrame = mobRoot.CFrame * CFrame.new(0, 0, FarmConfig.FarmDistance)
        rootPart.CFrame = farmCFrame
        
        if _G.bringMobs then
            BringMobs(mob.Name, mobRoot.CFrame)
        end
        
        if _G.fastAttack then
            Attack()
        end
        
        UseSkills()
        
        task.wait(0.1)
    end
    
    return true
end

local function AutoFarmLoop()
    while _G.autoFarmMobs do
        task.wait(0.5)
        
        local char = GetPlayerCharacter()
        if not char or not IsAlive(char) then
            task.wait(3)
            continue
        end
        
        if _G.autoQuest then
            local currentQuest = GetCurrentQuest()
            
            if not currentQuest then
                local quest = GetRecommendedQuest()
                if quest then
                    TakeQuest(quest.quest, 1)
                    task.wait(1)
                end
            end
        end
        
        local target = GetClosestEnemy()
        
        if target then
            FarmMob(target)
        else
            task.wait(2)
        end
    end
end

-- Create main window
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis",
    Icon = "sparkles",
    Author = "by NovaAxis",
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
    }
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

-- Tabs
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "house",
    Locked = false,
})

local FarmSection = MainTab:Section({
    Title = "Auto Farm",
    Icon = "wheat",
    Opened = true
})

-- Auto Farm Mobs Toggle
FarmSection:Toggle({
    Title = "Auto Farm Mobs",
    Icon = "swords",
    Default = false,
    Callback = function(state)
        _G.autoFarmMobs = state
        
        if state then
            WindUI:Notify({
                Title = "✅ Auto Farm Started",
                Content = "Farming nearest mobs...",
                Duration = 3,
                Icon = "swords"
            })
            
            task.spawn(AutoFarmLoop)
        else
            WindUI:Notify({
                Title = "⏸️ Auto Farm Stopped",
                Content = "Mob farming disabled",
                Duration = 3,
                Icon = "pause"
            })
        end
    end
})

-- Fast Attack Toggle
FarmSection:Toggle({
    Title = "Fast Attack",
    Icon = "zap",
    Default = false,
    Callback = function(state)
        _G.fastAttack = state
        WindUI:Notify({
            Title = state and "⚡ Fast Attack ON" or "⏸️ Fast Attack OFF",
            Content = state and "Attacking at maximum speed!" or "Normal attack speed restored",
            Duration = 2,
            Icon = "zap"
        })
    end
})

-- Bring Mobs Toggle
FarmSection:Toggle({
    Title = "Bring Mobs",
    Icon = "magnet",
    Default = false,
    Callback = function(state)
        _G.bringMobs = state
        WindUI:Notify({
            Title = state and "🧲 Bring Mobs ON" or "⏸️ Bring Mobs OFF",
            Content = state and "Pulling mobs to you!" or "Mobs will stay in place",
            Duration = 2,
            Icon = "magnet"
        })
    end
})

-- Auto Quest Toggle
FarmSection:Toggle({
    Title = "Auto Quest",
    Icon = "scroll",
    Default = false,
    Callback = function(state)
        _G.autoQuest = state
        WindUI:Notify({
            Title = state and "📜 Auto Quest ON" or "⏸️ Auto Quest OFF",
            Content = state and "Automatically taking quests!" or "Quest automation disabled",
            Duration = 2,
            Icon = "scroll"
        })
    end
})

-- Skills Section
local SkillsSection = MainTab:Section({
    Title = "Skills",
    Icon = "sparkles",
    Opened = true
})

-- Skill Z
SkillsSection:Toggle({
    Title = "Use Skill Z",
    Icon = "z",
    Default = false,
    Callback = function(state)
        _G.useSkills.Z = state
    end
})

-- Skill X
SkillsSection:Toggle({
    Title = "Use Skill X",
    Icon = "x",
    Default = false,
    Callback = function(state)
        _G.useSkills.X = state
    end
})

-- Skill C
SkillsSection:Toggle({
    Title = "Use Skill C",
    Icon = "c",
    Default = false,
    Callback = function(state)
        _G.useSkills.C = state
    end
})

-- Skill V
SkillsSection:Toggle({
    Title = "Use Skill V",
    Icon = "v",
    Default = false,
    Callback = function(state)
        _G.useSkills.V = state
    end
})

-- Farm Settings
local SettingsSection = MainTab:Section({
    Title = "Farm Settings",
    Icon = "settings",
    Opened = true
})

SettingsSection:Slider({
    Title = "Farm Distance",
    Icon = "ruler",
    Value = {
        Min = 10,
        Max = 50,
        Default = 20,
    },
    Callback = function(value)
        FarmConfig.FarmDistance = value
    end
})

SettingsSection:Slider({
    Title = "Bring Distance",
    Icon = "expand",
    Value = {
        Min = 100,
        Max = 500,
        Default = 350,
    },
    Callback = function(value)
        FarmConfig.BringDistance = value
    end
})

SettingsSection:Slider({
    Title = "Tween Speed",
    Icon = "gauge",
    Value = {
        Min = 100,
        Max = 500,
        Default = 300,
    },
    Callback = function(value)
        FarmConfig.TweenSpeed = value
    end
})

local CollectSection = MainTab:Section({
    Title = "Collect",
    Icon = "coins",
    Opened = true
})

-- Auto Collect Chests
CollectSection:Toggle({
    Title = "Auto Collect Chest",
    Icon = "box",
    Default = false,
    Callback = function(state)
        _G.autoFarmChest = state

        local function getChestPositionFromModel(model)
            if model.PrimaryPart then return model.PrimaryPart.Position end
            local p = model:FindFirstChildOfClass("BasePart") or model:FindFirstChildOfClass("Part")
            return p and p.Position or nil
        end

        local function getClosestChestPos(hrp)
            local bestPos, bestDist = nil, math.huge
            local tagCandidates = {"_ChestTagged","Chest","ChestModel"}
            for _, tag in ipairs(tagCandidates) do
                local tagged = CollectionService:GetTagged(tag)
                for _, inst in ipairs(tagged) do
                    if inst and inst.Parent then
                        local pos
                        if inst:IsA("Model") then pos = getChestPositionFromModel(inst) end
                        if not pos and inst:IsA("BasePart") then pos = inst.Position end
                        if pos then
                            local d = (pos - hrp.Position).Magnitude
                            if d < bestDist then bestDist, bestPos = d, pos end
                        end
                    end
                end
            end
            if not bestPos then
                local chestFolder = workspace:FindFirstChild("ChestModels")
                if chestFolder then
                    for _, m in ipairs(chestFolder:GetChildren()) do
                        if m:IsA("Model") then
                            local pos = getChestPositionFromModel(m)
                            if pos then
                                local d = (pos - hrp.Position).Magnitude
                                if d < bestDist then bestDist, bestPos = d, pos end
                            end
                        end
                    end
                end
            end
            return bestPos
        end

        if state then
            WindUI:Notify({
                Title = "✅ Auto Collect Started",
                Content = "Collecting nearest chests...",
                Duration = 3,
                Icon = "box"
            })

            task.spawn(function()
                while _G.autoFarmChest do
                    local character = Player.Character
                    if not character then 
                        task.wait(1)
                        continue 
                    end
                    
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if not hrp then 
                        task.wait(1)
                        continue 
                    end

                    local pos = getClosestChestPos(hrp)
                    if not pos then
                        WindUI:Notify({
                            Title = "ℹ️ No Chests Found",
                            Content = "No chests found nearby",
                            Duration = 3,
                            Icon = "info"
                        })
                        task.wait(3)
                        continue
                    end

                    local distance = (pos - hrp.Position).Magnitude
                    if distance > 1000 then
                        WindUI:Notify({
                            Title = "⚠️ Chest Too Far",
                            Content = "Nearest chest is too far away",
                            Duration = 3,
                            Icon = "alert-triangle"
                        })
                        task.wait(3)
                        continue
                    end

                    local duration = distance / 300
                    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                    local goal = {CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))}
                    local tween = TweenService:Create(hrp, tweenInfo, goal)
                    tween:Play()
                    
                    local success
                    local con = tween.Completed:Connect(function()
                        success = true
                    end)
                    
                    task.wait(duration + 0.5)
                    con:Disconnect()
                    
                    if not success then
                        tween:Cancel()
                    end
                    
                    task.wait(0.5)
                end
            end)
        else
            WindUI:Notify({
                Title = "⏸️ Auto Collect Stopped",
                Content = "Chest farming disabled",
                Duration = 3,
                Icon = "pause"
            })
        end
    end
})

-- Shop Tab
local ShopTab = Window:Tab({
    Title = "Shop",
    Icon = "shopping-bag",
    Locked = false,
})

-- Teleport Tab
local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "rocket",
    Locked = false,
})

-- Server Join Tab
local ServerTab = Window:Tab({
    Title = "Server Join",
    Icon = "server",
    Locked = false,
})

local ServerSection = ServerTab:Section({
    Title = "Server Hop",
    Icon = "server",
    Opened = true
})

ServerSection:Button({
    Title = "Rejoin Server",
    Desc = "Rejoin the server",
    Icon = "share",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
    end
})

ServerSection:Button({
    Title = "Server Hop to low-pop server",
    Desc = "Teleport to another public server (1–4 players)",
    Icon = "server",
    Callback = function()
        local placeId = game.PlaceId
        local currentJobId = game.JobId
        
        local success, result = pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
            
            for _, server in pairs(servers.data) do
                if server.playing >= 1 and server.playing <= 4 and server.id ~= currentJobId then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, Player)
                    return
                end
            end
            
            TeleportService:Teleport(placeId, Player)
        end)
        
        if not success then
            TeleportService:Teleport(placeId, Player)
        end
    end
})

local TeleportSection = TeleportTab:Section({
    Title = "Teleport",
    Icon = "rocket",
    Opened = true
})

local selectedLocation = nil
local tweenSpeed = 100
local isTeleporting = false
local currentTween = nil

local mapFolder = workspace:FindFirstChild("Map")
local locationNames = {}

if mapFolder then
    for _, item in pairs(mapFolder:GetChildren()) do
        if item:IsA("Model") then
            table.insert(locationNames, item.Name)
        end
    end
end

if #locationNames == 0 then
    locationNames = {"No locations available"}
end

local TeleportDropdown = TeleportSection:Dropdown({
    Title = "Locations",
    Desc = "Select location to teleport",
    Values = locationNames,
    Value = locationNames[1],
    Callback = function(option) 
        selectedLocation = option
        print("Location selected: " .. option)
    end
})

TeleportSection:Slider({
    Title = "Tween Speed",
    Desc = "Adjust teleport speed",
    Step = 10,
    Value = {
        Min = 100,
        Max = 300,
        Default = 100,
    },
    Callback = function(value)
        tweenSpeed = value
        print("Tween speed set to: " .. value)
    end
})

local FlyToggle = TeleportSection:Toggle({
    Title = "Fly to Location",
    Icon = "plane",
    Default = false,
    Callback = function(state)
        isTeleporting = state
        
        if state then
            if not selectedLocation or selectedLocation == "No locations available" then
                WindUI:Notify({
                    Title = "⚠️ Error",
                    Content = "Please select a valid location first!",
                    Duration = 3,
                    Icon = "alert-triangle"
                })
                FlyToggle:Set(false)
                return
            end
            
            local character = Player.Character
            if not character then 
                FlyToggle:Set(false)
                return 
            end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then 
                FlyToggle:Set(false)
                return 
            end
            
            local selectedModel = mapFolder and mapFolder:FindFirstChild(selectedLocation)
            if not selectedModel then
                WindUI:Notify({
                    Title = "⚠️ Error",
                    Content = "Location not found!",
                    Duration = 3,
                    Icon = "alert-triangle"
                })
                FlyToggle:Set(false)
                return
            end
            
            local teleportPosition
            if selectedModel.PrimaryPart then
                teleportPosition = selectedModel.PrimaryPart.Position
            else
                local firstPart = selectedModel:FindFirstChildOfClass("Part") or selectedModel:FindFirstChildOfClass("BasePart")
                if firstPart then
                    teleportPosition = firstPart.Position
                end
            end
            
            if not teleportPosition then
                WindUI:Notify({
                    Title = "⚠️ Error",
                    Content = "Could not find teleport point!",
                    Duration = 3,
                    Icon = "alert-triangle"
                })
                FlyToggle:Set(false)
                return
            end
            
            local liftUpPosition = humanoidRootPart.Position + Vector3.new(0, 50, 0)
            local liftTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            local liftGoal = {CFrame = CFrame.new(liftUpPosition)}
            local liftTween = TweenService:Create(humanoidRootPart, liftTweenInfo, liftGoal)
            
            liftTween:Play()
            liftTween.Completed:Wait()
            
            local finalPosition = teleportPosition + Vector3.new(0, 5, 0)
            local distance = (finalPosition - humanoidRootPart.Position).Magnitude
            local duration = distance / tweenSpeed
            
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
            
            local goal = {CFrame = CFrame.new(finalPosition)}
            currentTween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
            
            currentTween:Play()
            
            WindUI:Notify({
                Title = "✈️ Flying",
                Content = "Flying to " .. selectedLocation .. " at speed " .. tweenSpeed,
                Duration = 3,
                Icon = "plane"
            })
            
            currentTween.Completed:Connect(function()
                WindUI:Notify({
                    Title = "✅ Arrived",
                    Content = "Successfully teleported to " .. selectedLocation,
                    Duration = 3,
                    Icon = "check"
                })
                FlyToggle:Set(false)
                isTeleporting = false
            end)
        else
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
                WindUI:Notify({
                    Title = "⏸️ Flight Stopped",
                    Content = "Teleportation cancelled",
                    Duration = 3,
                    Icon = "pause"
                })
            end
        end
    end
})

local LocalPlayerTab = Window:Tab({
    Title = "Local Player",
    Icon = "user",
    Locked = false,
})

local LocalPlayerSection = LocalPlayerTab:Section({
    Title = "Local Player",
    Icon = "user",
    Opened = true
})

LocalPlayerSection:Slider({
    Title = "WalkSpeed",
    Icon = "activity",
    Value = {
        Min = 16,
        Max = 100,
        Default = 16,
    },
    Callback = function(value)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = value
        end
    end
})

local noclip = false
local noclipConnection

LocalPlayerSection:Toggle({
    Title = "Noclip",
    Icon = "box",
    Default = false,
    Callback = function(state)
        noclip = state
        local char = Player.Character
        if not char then return end

        if noclip then
            noclipConnection = RunService.Stepped:Connect(function()
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
})

local infiniteJump = false

LocalPlayerSection:Toggle({
    Title = "Infinite Jump",
    Icon = "arrow-up",
    Default = false,
    Callback = function(state)
        infiniteJump = state
    end
})

UserInputService.JumpRequest:Connect(function()
    if infiniteJump then
        if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

LocalPlayerSection:Button({
    Title = "FPS Boost",
    Desc = "Makes bad graphics to increase fps",
    Icon = "gauge",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            elseif v:IsA("Explosion") then
                v.BlastPressure = 0
                v.BlastRadius = 0
            end
        end

        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 1e10
        lighting.Brightness = 1
        lighting.EnvironmentDiffuseScale = 0
        lighting.EnvironmentSpecularScale = 0

        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        end

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end

        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        WindUI:Notify({
            Title = "✅ FPS Boost",
            Content = "Game performance optimized successfully!",
            Duration = 3,
            Icon = "gauge"
        })
    end
})

local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "cog",
    Locked = false,
})

local MiscSection = MiscTab:Section({
    Title = "Code",
    Icon = "gift",
    Opened = true
})

-- Centralized list of codes
local ALL_CODES = {
    "LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","NOMOREHACK","BANEXPLOIT","krazydares","TRIPLEABUSE","24NOADMIN","REWARDFUN","Chandler","NEWTROLL","KITT_RESET","Sub2CaptainMaui","kittgaming","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK","Starcodeheo","Bluxxy","fudd10_v2","SUB2GAMERROBOT_EXP1","Sub2NoobMaster123","Sub2UncleKizaru","Sub2Daigrock","Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie","Fudd10","Bignews","TheGreatAce","SECRET_ADMIN","SUB2GAMERROBOT_RESET1","SUB2OFFICIALNOOBIE","AXIORE","BIGNEWS","BLUXXY","CHANDLER","ENYU_IS_PRO","FUDD10","FUDD10_V2","KITTGAMING","MAGICBUS","STARCODEHEO","STRAWHATMAINE","SUB2CAPTAINMAUI","SUB2DAIGROCK","SUB2FER999","SUB2NOOBMASTER123","SUB2UNCLEKIZARU","TANTAIGAMING","THEGREATACE"
}

-- Find CommF remote
local function findCommF()
    local rs = game:GetService("ReplicatedStorage")
    local candidates = {"CommF_", "CommF", "Comm", "RemoteFunction", "RF"}
    
    for _, name in ipairs(candidates) do
        local remote = rs:FindFirstChild(name)
        if remote and remote:IsA("RemoteFunction") then
            return remote
        end
    end
    
    -- Deep search
    for _, inst in ipairs(rs:GetDescendants()) do
        if inst:IsA("RemoteFunction") then
            local name = inst.Name:lower()
            if name:find("comm") or name:find("remote") then
                return inst
            end
        end
    end
    
    return nil
end

-- Initialize CommF
local commF = findCommF()

function RedeemCode(code)
    if not commF then
        return false, "CommF not found"
    end
    
    local ok, res = pcall(function()
        return commF:InvokeServer("Redeem", code)
    end)
    
    return ok, res
end

local selectedCode = ALL_CODES[1]

local CodeDropdown = MiscSection:Dropdown({
    Title = "Code",
    Desc = "Select code to redeem",
    Values = ALL_CODES,
    Value = ALL_CODES[1],
    Callback = function(option) 
        selectedCode = option
        print("Code selected: " .. option)
        
        WindUI:Notify({
            Title = "✅ Code Selected",
            Content = "Code '" .. option .. "' is ready to redeem!",
            Duration = 2,
            Icon = "code"
        })
    end
})

MiscSection:Button({
    Title = "Redeem Code",
    Icon = "gift",
    Callback = function()
        local ok, res = RedeemCode(selectedCode)
        
        if ok then
            WindUI:Notify({
                Title = "✅ Code Redeemed",
                Content = "Code '" .. selectedCode .. "' redeemed successfully!",
                Duration = 3,
                Icon = "check"
            })
        else
            WindUI:Notify({
                Title = "⚠️ Redeem Failed",
                Content = "Failed to redeem '" .. selectedCode .. "': " .. tostring(res),
                Duration = 3,
                Icon = "alert-triangle"
            })
        end
    end
})

-- Redeem all codes with one button
MiscSection:Button({
    Title = "Redeem All Codes",
    Desc = "Redeem all codes from the list",
    Icon = "gift",
    Callback = function()
        task.spawn(function()
            local total = #ALL_CODES
            local okCount, failCount = 0, 0
            
            WindUI:Notify({
                Title = "▶️ Redeeming...",
                Content = "Processing " .. tostring(total) .. " codes",
                Duration = 2,
                Icon = "loader"
            })
            
            for _, code in ipairs(ALL_CODES) do
                local ok, res = RedeemCode(code)
                if ok then 
                    okCount = okCount + 1 
                else 
                    failCount = failCount + 1 
                end
                task.wait(0.5)
            end
            
            WindUI:Notify({
                Title = "📊 Codes Redeemed",
                Content = string.format("Success: %d | Failed: %d", okCount, failCount),
                Duration = 5,
                Icon = "check"
            })
        end)
    end
})

-- Auto Redeem toggle
local autoRedeem = false
local autoRedeemConnection

MiscSection:Toggle({
    Title = "Auto Redeem Codes",
    Icon = "refresh-cw",
    Default = false,
    Callback = function(state)
        autoRedeem = state
        
        if state then
            WindUI:Notify({
                Title = "🔄 Auto Redeem ON",
                Content = "Automatically redeeming codes every 30 seconds",
                Duration = 3,
                Icon = "refresh-cw"
            })
            
            autoRedeemConnection = task.spawn(function()
                while autoRedeem do
                    task.wait(30)
                    
                    for _, code in ipairs(ALL_CODES) do
                        RedeemCode(code)
                        task.wait(0.5)
                    end
                    
                    WindUI:Notify({
                        Title = "🔄 Auto Redeem",
                        Content = "All codes have been automatically redeemed",
                        Duration = 3,
                        Icon = "refresh-cw"
                    })
                end
            end)
        else
            if autoRedeemConnection then
                task.cancel(autoRedeemConnection)
                autoRedeemConnection = nil
            end
            
            WindUI:Notify({
                Title = "⏸️ Auto Redeem OFF",
                Content = "Auto redeem disabled",
                Duration = 3,
                Icon = "pause"
            })
        end
    end
})

-- Initialize the script
WindUI:Notify({
    Title = "💫 NovaAxis Loaded",
    Content = "Script successfully loaded!",
    Duration = 5,
    Icon = "sparkles"
})

print("NovaAxis script loaded successfully!")
