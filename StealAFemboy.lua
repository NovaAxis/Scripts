-- Load NOTHING UI Library
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()
local Notification = NothingLibrary.Notification()

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
}

-- State
local isRunning = false
local autoStealEnabled = false
local autoStealDelay = 5
local promptTimeout = 5

-- Show initial notification
Notification.new({
    Title = "💫 NovaAxis | Hub",
    Description = "✅ Femboy Stealer Loaded!",
    Duration = 3,
    Icon = "rbxassetid://7733960981"
})

-- Utility Functions
local function removeRagdoll()
    local character = player.Character
    if not character then return false end
    
    local ragdollValue = character:FindFirstChild("Ragdoll")
    if ragdollValue then
        ragdollValue:Destroy()
        Notification.new({
            Title = "✅ Success",
            Description = "Ragdoll removed!",
            Duration = 2,
            Icon = "rbxassetid://7733960981"
        })
        return true
    else
        Notification.new({
            Title = "ℹ️ Info",
            Description = "No Ragdoll found",
            Duration = 2,
            Icon = "rbxassetid://7733964719"
        })
        return false
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
                            -- Check if name contains "femboy" anywhere or ends with "femboy" or is in TARGET_NAMES
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
    
    -- Wait for timeout
    local startTime = tick()
    while not success and (tick() - startTime) < timeout do
        task.wait(0.1)
    end
    
    if not success then
        return false, "Timeout: Prompt not activated in " .. timeout .. " seconds"
    end
    
    return success, errorMessage
end

-- Main Steal Function
local function executeInstantSteal()
    if isRunning then
        Notification.new({
            Title = "⚠️ Warning",
            Description = "Already running!",
            Duration = 2,
            Icon = "rbxassetid://7733964719"
        })
        return
    end

    isRunning = true

    local character = player.Character
    if not character then
        Notification.new({
            Title = "❌ Error",
            Description = "Character not found!",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        })
        isRunning = false
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not humanoidRootPart then
        Notification.new({
            Title = "❌ Error",
            Description = "Humanoid/HRP not found!",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        })
        isRunning = false
        return
    end

    local playerBase = findPlayerBase()
    if not playerBase then
        Notification.new({
            Title = "❌ Error",
            Description = "Your base not found!",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        })
        isRunning = false
        return
    end

    local targetModel, targetBase = findTargetFemboy(playerBase)
    if not targetModel then
        Notification.new({
            Title = "❌ Error",
            Description = "Target not found!",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        })
        isRunning = false
        return
    end

    local targetPart = getAnyBasePart(targetModel)
    if not targetPart then
        Notification.new({
            Title = "❌ Error",
            Description = "Could not find target part",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        })
        isRunning = false
        return
    end

    local targetPosition = targetPart.Position + Vector3.new(0, 3, 0)

    local savedWalkSpeed = humanoid.WalkSpeed
    local savedJumpPower = humanoid.JumpPower
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    Notification.new({
        Title = "✨ Info",
        Description = "Teleporting to target...",
        Duration = 2,
        Icon = "rbxassetid://7733960981"
    })

    if not teleportCharacterToPosition(targetPosition) then
        Notification.new({
            Title = "❌ Error",
            Description = "Teleportation failed!",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
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
        Notification.new({
            Title = "⏳ Info",
            Description = "Activating prompt... (" .. promptTimeout .. "s timeout)",
            Duration = 2,
            Icon = "rbxassetid://7733960981"
        })
        
        local success, errorMessage = activateProximityPromptWithTimeout(prompt, promptTimeout)
        
        if success then
            promptActivated = true
            Notification.new({
                Title = "✅ Success",
                Description = "Prompt activated!",
                Duration = 2,
                Icon = "rbxassetid://7733960981"
            })
            task.wait(1)
        else
            Notification.new({
                Title = "⚠️ Warning",
                Description = errorMessage or "Prompt timeout!",
                Duration = 3,
                Icon = "rbxassetid://7733964719"
            })
        end
    else
        Notification.new({
            Title = "⚠️ Warning",
            Description = "Prompt not found!",
            Duration = 2,
            Icon = "rbxassetid://7733964719"
        })
    end

    -- Always return to base
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
            Notification.new({
                Title = "🏠 Info",
                Description = "Returning to base...",
                Duration = 2,
                Icon = "rbxassetid://7733960981"
            })
            teleportCharacterToPosition(spawnPosition + Vector3.new(0, 3, 0))
            task.wait(0.3)
            Notification.new({
                Title = "✅ Success",
                Description = "Returned successfully!",
                Duration = 2,
                Icon = "rbxassetid://7733960981"
            })
        end
    end

    humanoid.WalkSpeed = savedWalkSpeed
    humanoid.JumpPower = savedJumpPower
    isRunning = false
end

-- Create UI
local Windows = NothingLibrary.new({
    Title = "💫 NovaAxis | Hub",
    Description = "⚡ Femboy Stealer",
    Keybind = Enum.KeyCode.RightShift,
    Logo = '',
    BrandText = "NovaAxis"
})

-- Main Tab
local MainTab = Windows:NewTab({
    Title = "🏠 Main",
    Description = "Stealer Functions",
    Icon = "rbxassetid://7733960981"
})

-- Steal Section
local StealSection = MainTab:NewSection({
    Title = "⚡ Instant Steal",
    Icon = "rbxassetid://7733779610",
    Position = "Left"
})

StealSection:NewButton({
    Title = "⚡ Instant Steal",
    Callback = function()
        task.spawn(function()
            local success, errorMessage = pcall(executeInstantSteal)
            if not success then
                Notification.new({
                    Title = "❌ Error",
                    Description = "Error: " .. tostring(errorMessage),
                    Duration = 3,
                    Icon = "rbxassetid://7733964719"
                })
            end
        end)
    end
})

-- Ragdoll Section
local RagdollSection = MainTab:NewSection({
    Title = "🔧 Utilities",
    Icon = "rbxassetid://7743869054",
    Position = "Left"
})

RagdollSection:NewButton({
    Title = "🚫 Remove Ragdoll",
    Callback = function()
        removeRagdoll()
    end
})

-- Auto Steal Section
local AutoSection = MainTab:NewSection({
    Title = "🔄 Auto Steal",
    Icon = "rbxassetid://7733955511",
    Position = "Right"
})

AutoSection:NewToggle({
    Title = "🔄 Enable Auto Steal",
    Default = false,
    Callback = function(value)
        autoStealEnabled = value
        if value then
            Notification.new({
                Title = "✅ Auto Steal",
                Description = "Auto Steal Enabled",
                Duration = 2,
                Icon = "rbxassetid://7733960981"
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
            Notification.new({
                Title = "❌ Auto Steal",
                Description = "Auto Steal Disabled",
                Duration = 2,
                Icon = "rbxassetid://7733964719"
            })
        end
    end
})

AutoSection:NewSlider({
    Title = "⏱️ Auto Steal Delay (sec)",
    Min = 1,
    Max = 60,
    Default = 5,
    Callback = function(value)
        autoStealDelay = value
    end
})

-- Target Info Section
local InfoSection = MainTab:NewSection({
    Title = "🎯 Target Info",
    Icon = "rbxassetid://7743869054",
    Position = "Right"
})

InfoSection:NewTitle('🎯 Targets:')
InfoSection:NewTitle('• Any name with "femboy"')
InfoSection:NewTitle('• Roommate')
InfoSection:NewTitle('• Casual Astolfo')
InfoSection:NewTitle('• Chihiro Fujisaki')
InfoSection:NewTitle('• Venti')
InfoSection:NewTitle('• Gasper')
InfoSection:NewTitle('• Saika')
InfoSection:NewTitle('• J*b Application')

-- Settings Tab
local SettingsTab = Windows:NewTab({
    Title = "⚙️ Settings",
    Description = "Configuration",
    Icon = "rbxassetid://7733955511"
})

local SettingsSection = SettingsTab:NewSection({
    Title = "⚙️ Settings",
    Icon = "rbxassetid://7733955511",
    Position = "Left"
})

SettingsSection:NewKeybind({
    Title = "⌨️ Quick Steal Keybind",
    Default = Enum.KeyCode.F,
    Callback = function(key)
        executeInstantSteal()
    end
})

SettingsSection:NewSlider({
    Title = "⏳ Prompt Timeout (sec)",
    Min = 1,
    Max = 10,
    Default = 5,
    Callback = function(value)
        promptTimeout = value
        Notification.new({
            Title = "⚙️ Settings",
            Description = "Timeout set to " .. value .. "s",
            Duration = 2,
            Icon = "rbxassetid://7733960981"
        })
    end
})

-- Info Tab
local InfoTab = Windows:NewTab({
    Title = "ℹ️ Info",
    Description = "Information & Credits",
    Icon = "rbxassetid://7733764088"
})

local InfoSection2 = InfoTab:NewSection({
    Title = "📋 Information",
    Icon = "rbxassetid://7733764088",
    Position = "Left"
})

InfoSection2:NewTitle('💫 NovaAxis | Hub Script')
InfoSection2:NewTitle('📦 Version: 3.9')
InfoSection2:NewTitle('')
InfoSection2:NewTitle('👨‍💻 Created by NovaAxis')

InfoSection2:NewButton({
    Title = "🔗 GitHub",
    Callback = function()
        setclipboard("github.com/NovaAxis")
        Notification.new({
            Title = "✅ Copied",
            Description = "GitHub link copied!",
            Duration = 3,
            Icon = "rbxassetid://7733960981"
        })
    end
})

local HelpSection = InfoTab:NewSection({
    Title = "❓ How to Use",
    Icon = "rbxassetid://7743869054",
    Position = "Right"
})

HelpSection:NewTitle('1️⃣ Click Instant Steal')
HelpSection:NewTitle('2️⃣ Or enable Auto Steal')
HelpSection:NewTitle('3️⃣ Use F key for quick steal')
HelpSection:NewTitle('4️⃣ Remove Ragdoll if needed')
HelpSection:NewTitle('')
HelpSection:NewTitle('⌨️ Press Right Shift to toggle UI')

-- Initialization
print("✅ Femboy Stealer UI loaded!")
print("⌨️ Press Right Shift to toggle UI")
