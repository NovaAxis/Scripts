--[[
    💫 NovaAxis Hub - Steal A Femboy (WindUI)
    
    Author: NovaAxis
    Version: 5.0
    Library: WindUI
]]

local repo = "https://raw.githubusercontent.com/FootageSus/WindUI/main/"
local Library = loadstring(game:HttpGet(repo .. "source.lua"))()

-- Services
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Player
local player = Players.LocalPlayer

-- Target Names
local TARGET_NAMES = {
    ["Roommate"] = true,
    ["Casual Astolfo"] = true,
    ["Chihiro Fujisaki"] = true,
    ["Venti"] = true,
    ["Gasper"] = true,
    ["Saika"] = true,   
    ["J*b Application"] = true,
    ["Mythical Lucky Block"] = true,
    ["Nagisa Shiota"] = true,
    ["Felix"] = true,
    ["Rimuru"] = true,
}

-- State
local isRunning = false
local autoStealEnabled = false
local autoStealDelay = 5
local promptTimeout = 5
local walkSpeedEnabled = false
local customWalkSpeed = 16
local noclipEnabled = false
local noclipConnection = nil

-- Utility Functions
local function SetupKickProtection()
    local mt = getrawmetatable(game)
    if not mt then return end
    
    local oldNamecall = mt.__namecall
    
    if setreadonly then
        setreadonly(mt, false)
    end
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" then
            return nil
        end
        return oldNamecall(self, ...)
    end)
end

local function DisconnectAllConnections(object, signalName)
    if not object then return end
    local signal = object[signalName]
    if not signal then return end
    
    local connections = getconnections(signal)
    if connections then
        for _, conn in pairs(connections) do
            if conn and type(conn.Disconnect) == "function" then
                conn:Disconnect()
            end
        end
    end
end

local function ExecuteBypass()
    SetupKickProtection()
    
    repeat task.wait() until player
    repeat task.wait() until player.Character
    
    local character = player.Character
    
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            DisconnectAllConnections(humanoid, "StateChanged")
            DisconnectAllConnections(humanoid, "Changed")
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            DisconnectAllConnections(rootPart, "ChildAdded")
        end
        
        DisconnectAllConnections(character, "ChildRemoved")
    end
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        DisconnectAllConnections(backpack, "ChildAdded")
    end
    
    local camera = workspace.CurrentCamera
    if camera then
        DisconnectAllConnections(camera, "ChildAdded")
    end
    
    local antiScript = script.Parent and script.Parent:FindFirstChild("Anti")
    if antiScript then
        antiScript.Disabled = true
        antiScript:Destroy()
    end
    
    task.spawn(function()
        while task.wait(5) do
            local newAnti = script.Parent and script.Parent:FindFirstChild("Anti")
            if newAnti then
                newAnti.Disabled = true
                newAnti:Destroy()
            end
            
            if character and character.Parent then
                local currentHumanoid = character:FindFirstChild("Humanoid")
                if currentHumanoid then
                    DisconnectAllConnections(currentHumanoid, "StateChanged")
                end
            end
        end
    end)
end

local function SafeExecute()
    local success, error = pcall(ExecuteBypass)
    if not success then
        local mt = getrawmetatable(game)
        if mt then
            local old = mt.__namecall
            if setreadonly then setreadonly(mt, false) end
            mt.__namecall = function(self, ...)
                if getnamecallmethod() == "Kick" then return nil end
                return old(self, ...)
            end
        end
        WindUI:Notify({
            Title = "⚠️ Warning",
            Content = "Bypass partial failure, kick protection enabled",
            Duration = 3
        })
    else
        WindUI:Notify({
            Title = "🛡️ Success",
            Content = "Anti-Cheat bypassed successfully!",
            Duration = 2
        })
    end
end

local function getAnyBasePart(model)
    if not model then return nil end
    if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then 
        return model.PrimaryPart 
    end
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then 
            return descendant 
        end
    end
    return nil
end

local function findPlayerBase()
    local basesFolder = Workspace:FindFirstChild("Bases")
    if not basesFolder then return nil end

    for _, base in ipairs(basesFolder:GetChildren()) do
        if base:IsA("Model") then
            local config = base:FindFirstChild("Configuration") or base:FindFirstChild("Configurationsa")
            if config then
                local playerValue = config:FindFirstChild("Player")
                if playerValue and (playerValue.Value == player or playerValue.Value == player.Name) then
                    return base
                end
            end
        end
    end
    return nil
end

local function findTargetFemboy(playerBase)
    local basesFolder = Workspace:FindFirstChild("Bases")
    if not basesFolder then return nil, nil end

    for _, base in ipairs(basesFolder:GetChildren()) do
        if base:IsA("Model") and base ~= playerBase then
            local slots = base:FindFirstChild("Slots")
            if slots then
                for _, slot in ipairs(slots:GetChildren()) do
                    for _, model in ipairs(slot:GetChildren()) do
                        if model:IsA("Model") then
                            local modelName = model.Name
                            if modelName:lower():find("femboy") or TARGET_NAMES[modelName] then
                                return model, base
                            end
                        end
                    end
                end
            end
        end
    end
    return nil, nil
end

local function teleportCharacterToPosition(position)
    local character = player.Character
    if not character then return false end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end

    pcall(function() 
        humanoidRootPart.Velocity = Vector3.zero 
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end)

    humanoidRootPart.CFrame = CFrame.new(position)
    RunService.Heartbeat:Wait()

    pcall(function() 
        humanoidRootPart.Velocity = Vector3.zero 
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end)

    return true
end

local function findProximityPromptInModel(rootModel, originPosition, maxDistance)
    local bestPrompt, bestDistance
    maxDistance = maxDistance or 20

    for _, descendant in ipairs(rootModel:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Enabled then
            local part = descendant.Parent
            if part and part:IsA("BasePart") then
                local distance = (part.Position - originPosition).Magnitude
                if distance <= maxDistance and (not bestDistance or distance < bestDistance) then
                    bestPrompt = descendant
                    bestDistance = distance
                end
            end
        end
    end
    return bestPrompt
end

local function activateProximityPromptWithTimeout(prompt, timeout)
    local success = false
    local errorMessage = nil
    
    local thread = task.spawn(function()
        local result, err = pcall(function()
            if prompt:IsA("ProximityPrompt") then
                prompt:InputHoldBegin()
                local holdDuration = prompt.HoldDuration or 0.5
                task.wait(holdDuration)
                prompt:InputHoldEnd()
                
                local remoteEvent = prompt:FindFirstChildOfClass("RemoteEvent")
                if remoteEvent then
                    remoteEvent:FireServer()
                end
                success = true
            else
                error("Object is not a ProximityPrompt")
            end
        end)
        
        if not result then
            errorMessage = err
        end
    end)
    
    local startTime = tick()
    while not success and (tick() - startTime) < timeout do
        task.wait(0.1)
    end
    
    if not success then
        return false, "Timeout: Prompt not activated in " .. timeout .. " seconds"
    end
    
    return success, errorMessage
end

local function executeInstantSteal()
    if isRunning then
        WindUI:Notify({
            Title = "⚠️ Warning",
            Content = "Already running!",
            Duration = 2
        })
        return
    end

    isRunning = true

    local character = player.Character
    if not character then
        WindUI:Notify({
            Title = "❌ Error",
            Content = "Character not found!",
            Duration = 3
        })
        isRunning = false
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not humanoidRootPart then
        WindUI:Notify({
            Title = "❌ Error",
            Content = "Humanoid/HRP not found!",
            Duration = 3
        })
        isRunning = false
        return
    end

    local playerBase = findPlayerBase()
    if not playerBase then
        WindUI:Notify({
            Title = "❌ Error",
            Content = "Your base not found!",
            Duration = 3
        })
        isRunning = false
        return
    end

    local targetModel, targetBase = findTargetFemboy(playerBase)
    if not targetModel then
        WindUI:Notify({
            Title = "❌ Error",
            Content = "Target not found!",
            Duration = 3
        })
        isRunning = false
        return
    end

    local targetPart = getAnyBasePart(targetModel)
    if not targetPart then
        WindUI:Notify({
            Title = "❌ Error",
            Content = "Could not find target part",
            Duration = 3
        })
        isRunning = false
        return
    end

    local targetPosition = targetPart.Position + Vector3.new(0, 3, 0)

    local savedWalkSpeed = humanoid.WalkSpeed
    local savedJumpPower = humanoid.JumpPower
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    WindUI:Notify({
        Title = "✨ Info",
        Content = "Teleporting to target...",
        Duration = 2
    })

    if not teleportCharacterToPosition(targetPosition) then
        WindUI:Notify({
            Title = "❌ Error",
            Content = "Teleportation failed!",
            Duration = 3
        })
        humanoid.WalkSpeed = savedWalkSpeed
        humanoid.JumpPower = savedJumpPower
        isRunning = false
        return
    end

    task.wait(0.3)

    local prompt = findProximityPromptInModel(targetBase or targetModel, targetPosition, 25)

    local promptActivated = false
    if prompt then
        WindUI:Notify({
            Title = "⏳ Info",
            Content = "Activating prompt... (" .. promptTimeout .. "s timeout)",
            Duration = 2
        })
        
        local success, errorMessage = activateProximityPromptWithTimeout(prompt, promptTimeout)
        
        if success then
            promptActivated = true
            WindUI:Notify({
                Title = "✅ Success",
                Content = "Prompt activated!",
                Duration = 2
            })
            task.wait(1)
        else
            WindUI:Notify({
                Title = "⚠️ Warning",
                Content = errorMessage or "Prompt timeout!",
                Duration = 3
            })
        end
    else
        WindUI:Notify({
            Title = "⚠️ Warning",
            Content = "Prompt not found!",
            Duration = 2
        })
    end

    local spawn = playerBase:FindFirstChild("Spawn")
    if spawn then
        local spawnPosition
        
        if spawn:IsA("BasePart") then
            spawnPosition = spawn.Position
        else
            local basePart = spawn:FindFirstChild("Base")
            if basePart and basePart:IsA("BasePart") then
                spawnPosition = basePart.Position
            end
        end

        if spawnPosition then
            WindUI:Notify({
                Title = "🏠 Info",
                Content = "Returning to base...",
                Duration = 2
            })
            teleportCharacterToPosition(spawnPosition + Vector3.new(0, 3, 0))
            task.wait(0.3)
            WindUI:Notify({
                Title = "✅ Success",
                Content = "Returned successfully!",
                Duration = 2
            })
        end
    end

    humanoid.WalkSpeed = savedWalkSpeed
    humanoid.JumpPower = savedJumpPower
    isRunning = false
end

-- Creating Window
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis Hub",
    Author = "NovaAxis | v5.0",
    Size = UDim2.fromOffset(580, 460),
    KeyBind = Enum.KeyCode.LeftAlt,
    Folder = "NovaAxis-FemboySteal",
    Config = "NovaAxis-Config",
    Theme = "Dark"
})

-- Welcome Notification
WindUI:Notify({
    Title = "💫 NovaAxis Hub",
    Content = "Successfully loaded for Steal A Femboy!",
    Duration = 5
})

-- Create Sections
local MainSection = Window:Section({
    Title = "🌸 Femboy Stealer",
    Opened = true
})

local UtilitySection = Window:Section({
    Title = "⚙️ Utilities",
    Opened = true
})

-- Create Tabs
local MainTab = MainSection:Tab({
    Title = "Main Features",
    Icon = "target",
    Desc = "Instant & Auto Steal"
})

local UtilityTab = UtilitySection:Tab({
    Title = "Utility",
    Icon = "shield",
    Desc = "Bypass & Movement"
})

-- Instant Steal Section
MainTab:Button({
    Title = "⚡ Execute Instant Steal",
    Desc = "Teleports to target, activates prompt, returns",
    Callback = function()
        task.spawn(function()
            local success, errorMessage = pcall(executeInstantSteal)
            if not success then
                WindUI:Notify({
                    Title = "❌ Error",
                    Content = "Error: " .. tostring(errorMessage),
                    Duration = 3
                })
            end
        end)
    end
})

MainTab:Keybind({
    Title = "Quick Steal Hotkey",
    Desc = "Press to instantly execute steal",
    Default = Enum.KeyCode.F,
    Callback = function()
        executeInstantSteal()
    end
})

MainTab:Divider()

-- Auto Steal Section
MainTab:Toggle({
    Title = "Enable Auto Steal",
    Desc = "Automatically steals femboys with delay",
    Default = false,
    Callback = function(value)
        autoStealEnabled = value
        if value then
            WindUI:Notify({
                Title = "✅ Auto Steal",
                Content = "Auto Steal Enabled!",
                Duration = 2
            })
            
            task.spawn(function()
                while autoStealEnabled do
                    if not isRunning then
                        executeInstantSteal()
                    end
                    task.wait(autoStealDelay)
                end
            end)
        else
            WindUI:Notify({
                Title = "❌ Auto Steal",
                Content = "Auto Steal Disabled!",
                Duration = 2
            })
        end
    end
})

MainTab:Slider({
    Title = "Auto Steal Delay",
    Desc = "Delay between auto steal attempts",
    Min = 1,
    Max = 60,
    Default = 5,
    Callback = function(value)
        autoStealDelay = value
    end
})

MainTab:Divider()

-- Settings Section
MainTab:Slider({
    Title = "Prompt Timeout",
    Desc = "Maximum time to wait for prompt activation",
    Min = 1,
    Max = 10,
    Default = 5,
    Callback = function(value)
        promptTimeout = value
        WindUI:Notify({
            Title = "⚙️ Settings",
            Content = "Timeout set to " .. value .. "s",
            Duration = 2
        })
    end
})

MainTab:Divider()

-- Target List Section
MainTab:Paragraph({
    Title = "🎯 Target List",
    Desc = [[Detected Targets:
• Any name with 'femboy'
• Roommate
• Casual Astolfo
• Chihiro Fujisaki
• Venti
• Gasper
• Saika
• J*b Application
• Mythical Lucky Block
• Nagisa Shiota
• Felix
• Rimuru]]
})

-- Utility Tab - Bypass Section
UtilityTab:Button({
    Title = "🛡️ Activate Bypass",
    Desc = "Run if you experience kicks or detection",
    Callback = function()
        SafeExecute()
    end
})

UtilityTab:Divider()

-- Movement Section
UtilityTab:Toggle({
    Title = "Custom WalkSpeed",
    Desc = "Enable custom walk speed",
    Default = false,
    Callback = function(value)
        walkSpeedEnabled = value
        
        if value then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = customWalkSpeed
                    WindUI:Notify({
                        Title = "✅ WalkSpeed",
                        Content = "WalkSpeed set to " .. customWalkSpeed,
                        Duration = 2
                    })
                end
            end
        else
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                    WindUI:Notify({
                        Title = "🔄 WalkSpeed",
                        Content = "WalkSpeed reset to 16",
                        Duration = 2
                    })
                end
            end
        end
    end
})

UtilityTab:Slider({
    Title = "WalkSpeed Value",
    Desc = "Set custom walk speed value",
    Min = 16,
    Max = 350,
    Default = 16,
    Callback = function(value)
        customWalkSpeed = value
        
        if walkSpeedEnabled then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = customWalkSpeed
                end
            end
        end
    end
})

UtilityTab:Divider()

UtilityTab:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
    Default = false,
    Callback = function(value)
        noclipEnabled = value
        
        if value then
            WindUI:Notify({
                Title = "✅ Noclip",
                Content = "Noclip Enabled!",
                Duration = 2
            })
            
            noclipConnection = RunService.Stepped:Connect(function()
                if noclipEnabled then
                    local character = player.Character
                    if character then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        else
            WindUI:Notify({
                Title = "🔄 Noclip",
                Content = "Noclip Disabled!",
                Duration = 2
            })
            
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

UtilityTab:Divider()

-- Info Section
UtilityTab:Paragraph({
    Title = "ℹ️ Information",
    Desc = [[💫 NovaAxis Hub
Version: 5.0
Game: Steal A Femboy
Created by: NovaAxis
Library: WindUI]]
})

UtilityTab:Button({
    Title = "📋 Copy GitHub",
    Desc = "Copy GitHub link to clipboard",
    Callback = function()
        setclipboard("github.com/NovaAxis")
        WindUI:Notify({
            Title = "✅ Copied",
            Content = "GitHub link copied to clipboard!",
            Duration = 3
        })
    end
})

-- Keep WalkSpeed when character respawns
player.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    if walkSpeedEnabled then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = customWalkSpeed
        end
    end
end)

-- Initialization
print("✅ NovaAxis Hub loaded successfully!")
print("⌨️ Press Left Alt to toggle UI")
print("🌸 Game: Steal A Femboy")
