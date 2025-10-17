--[[ 
    💫 NovaAxis Hub - Steal A Femboy (WindUI full rewrite, bypass auto-enable)
    Author: NovaAxis (interface ported to WindUI)
    Version: 4.6-full
    Notes: Full, unabridged version. WindUI loaded from GitHub release.
]]

-- Load WindUI (latest)
local successWind, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not successWind or not WindUI then
    warn("WindUI failed to load. Aborting UI creation.")
    return
end

-- Services
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

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

-- Create a neon theme (Nova Neon: accent RGB(120,80,255))
WindUI:AddTheme({
    Name = "Nova Neon",
    Accent = Color3.fromRGB(120, 80, 255),            -- strong neon accent
    Dialog = Color3.fromRGB(18, 18, 20),
    Outline = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(230, 230, 230),
    Placeholder = Color3.fromRGB(130, 130, 140),
    Background = Color3.fromRGB(8, 8, 10),
    Button = Color3.fromRGB(50, 40, 60),
    Icon = Color3.fromRGB(190, 180, 255)
})

WindUI:SetTheme("Nova Neon")

-- Notification helper
local function Notify(opts)
    -- opts: {Title, Content, Duration, Icon}
    WindUI:Notify({
        Title = opts.Title or "Notification",
        Content = opts.Content or "",
        Duration = opts.Duration or 3,
        Icon = opts.Icon or "activity"
    })
end

-- Create Config Manager placeholder (WindUI may have own config API; placeholder)
local ConfigManager = {
    Directory = "NovaAxis-FemboySteal",
    Config = "Default-Config"
}

-- -------------------------
-- Utility functions (kept from original, unchanged behavior)
-- -------------------------
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
    local success, signal = pcall(function() return object[signalName] end)
    if not success then return end
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
        Notify({
            Title = "⚠️ Warning",
            Content = "Bypass partial failure, kick protection enabled",
            Duration = 3,
            Icon = "alert-circle"
        });
    else
        Notify({
            Title = "🛡️ Success",
            Content = "Anti-Cheat bypassed successfully!",
            Duration = 2,
            Icon = "shield-check"
        });
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
        Notify({
            Title = "⚠️ Warning",
            Content = "Already running!",
            Duration = 2,
            Icon = "alert-circle"
        });
        return
    end

    isRunning = true

    local character = player.Character
    if not character then
        Notify({
            Title = "❌ Error",
            Content = "Character not found!",
            Duration = 3,
            Icon = "x"
        });
        isRunning = false
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not humanoidRootPart then
        Notify({
            Title = "❌ Error",
            Content = "Humanoid/HRP not found!",
            Duration = 3,
            Icon = "x"
        });
        isRunning = false
        return
    end

    local playerBase = findPlayerBase()
    if not playerBase then
        Notify({
            Title = "❌ Error",
            Content = "Your base not found!",
            Duration = 3,
            Icon = "x"
        });
        isRunning = false
        return
    end

    local targetModel, targetBase = findTargetFemboy(playerBase)
    if not targetModel then
        Notify({
            Title = "❌ Error",
            Content = "Target not found!",
            Duration = 3,
            Icon = "x"
        });
        isRunning = false
        return
    end

    local targetPart = getAnyBasePart(targetModel)
    if not targetPart then
        Notify({
            Title = "❌ Error",
            Content = "Could not find target part",
            Duration = 3,
            Icon = "x"
        });
        isRunning = false
        return
    end

    local targetPosition = targetPart.Position + Vector3.new(0, 3, 0)

    local savedWalkSpeed = humanoid.WalkSpeed
    local savedJumpPower = humanoid.JumpPower
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    Notify({
        Title = "✨ Info",
        Content = "Teleporting to target...",
        Duration = 2,
        Icon = "arrow-right-circle"
    });

    if not teleportCharacterToPosition(targetPosition) then
        Notify({
            Title = "❌ Error",
            Content = "Teleportation failed!",
            Duration = 3,
            Icon = "x"
        });
        humanoid.WalkSpeed = savedWalkSpeed
        humanoid.JumpPower = savedJumpPower
        isRunning = false
        return
    end

    task.wait(0.3)

    local prompt = findProximityPromptInModel(targetBase or targetModel, targetPosition, 25)

    local promptActivated = false
    if prompt then
        Notify({
            Title = "⏳ Info",
            Content = "Activating prompt... (" .. promptTimeout .. "s timeout)",
            Duration = 2,
            Icon = "clock"
        });
        
        local success, errorMessage = activateProximityPromptWithTimeout(prompt, promptTimeout)
        
        if success then
            promptActivated = true
            Notify({
                Title = "✅ Success",
                Content = "Prompt activated!",
                Duration = 2,
                Icon = "check"
            });
            task.wait(1)
        else
            Notify({
                Title = "⚠️ Warning",
                Content = errorMessage or "Prompt timeout!",
                Duration = 3,
                Icon = "alert-circle"
            });
        end
    else
        Notify({
            Title = "⚠️ Warning",
            Content = "Prompt not found!",
            Duration = 2,
            Icon = "alert-circle"
        });
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
            Notify({
                Title = "🏠 Info",
                Content = "Returning to base...",
                Duration = 2,
                Icon = "home"
            });
            teleportCharacterToPosition(spawnPosition + Vector3.new(0, 3, 0))
            task.wait(0.3)
            Notify({
                Title = "✅ Success",
                Content = "Returned successfully!",
                Duration = 2,
                Icon = "check"
            });
        end
    end

    humanoid.WalkSpeed = savedWalkSpeed
    humanoid.JumpPower = savedJumpPower
    isRunning = false
end

-- Keep WalkSpeed when character respawns
local function keepWalkSpeedOnRespawn()
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if walkSpeedEnabled then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = customWalkSpeed
            end
        end
    end)
end

-- === AUTO-RUN BYPASS BEFORE UI CREATION ===
-- Run bypass immediately so anti-cheat protections are disabled before anything else initializes.
-- Use pcall to avoid blocking UI creation if bypass errors.
pcall(function()
    SafeExecute()
end)

-- -------------------------
-- Build WindUI layout (Tabs, Sections, Elements)
-- -------------------------

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Author = "NovaAxis",
    Folder = "NovaAxis-FemboySteal",
    Size = UDim2.fromOffset(780, 520),
    MinSize = Vector2.new(640, 420),
    Transparent = true,
    Theme = "Nova Neon",
    Resizable = true,
    SideBarWidth = 220,
    BackgroundImageTransparency = 0.45,
})

-- Set default toggle key (LeftAlt)
Window:SetToggleKey(Enum.KeyCode.LeftAlt)

Notify({Title = "💫 NovaAxis Hub", Content = "Successfully loaded for Steal A Femboy!", Duration = 4, Icon = "sparkles"})

-- -------------------------
-- Variables for movement/noclip kept in UI scope
-- -------------------------
local walkSpeedEnabled = false
local customWalkSpeed = 16
local noclipEnabled = false
local noclipConnection = nil

-- -------------------------
-- Main Tab: Femboy Stealer
-- -------------------------
local mainTab = Window:Tab({ Title = "Femboy Stealer", Icon = "target" })

local StealSection = mainTab:Section({
    Title = "⚡ Instant Steal",
    Icon = "zap",
    Opened = true
})

StealSection:Button({
    Title = "⚡ Execute Instant Steal",
    Desc = "Teleport, activate prompt, return.",
    Callback = function()
        task.spawn(function()
            local ok, err = pcall(executeInstantSteal)
            if not ok then
                Notify({
                    Title = "❌ Error",
                    Content = "Error: " .. tostring(err),
                    Duration = 3,
                    Icon = "x"
                })
            end
        end)
    end
})

StealSection:Paragraph({
    Title = "ℹ️ How it works",
    Content = "Teleports to target femboy, activates prompt, and returns to your base automatically."
})

local AutoSection = mainTab:Section({
    Title = "🔄 Auto Steal",
    Icon = "repeat",
    Opened = true
})

AutoSection:Toggle({
    Title = "Enable Auto Steal",
    Desc = "Automatically steal every N seconds",
    Default = false,
    Callback = function(value)
        autoStealEnabled = value
        if value then
            Notify({
                Title = "✅ Auto Steal",
                Content = "Auto Steal Enabled!",
                Duration = 2,
                Icon = "play"
            });
            
            task.spawn(function()
                while autoStealEnabled do
                    if not isRunning then
                        executeInstantSteal()
                    end
                    task.wait(autoStealDelay)
                end
            end)
        else
            Notify({
                Title = "❌ Auto Steal",
                Content = "Auto Steal Disabled!",
                Duration = 2,
                Icon = "pause"
            });
        end
    end
});

AutoSection:Slider({
    Title = "Auto Steal Delay (seconds)",
    Step = 1,
    Value = { Min = 1, Max = 60, Default = 5 },
    Callback = function(value)
        autoStealDelay = value
    end
});

local SettingsSection = mainTab:Section({
    Title = "⚙️ Settings",
    Icon = "settings",
    Opened = true
});

SettingsSection:Keybind({
    Title = "Quick Steal Hotkey",
    Desc = "Set quick steal hotkey",
    Value = "F",
    Callback = function(v)
        local key = v
        local successKey, code = pcall(function() return Enum.KeyCode[key] end)
        if successKey and code then
            if _G.NovaAxisQuickStealConnection then
                _G.NovaAxisQuickStealConnection:Disconnect()
                _G.NovaAxisQuickStealConnection = nil
            end
            _G.NovaAxisQuickStealConnection = UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if input.KeyCode == code then
                    executeInstantSteal()
                end
            end)
        end
    end
});

SettingsSection:Slider({
    Title = "Prompt Timeout (seconds)",
    Step = 1,
    Value = { Min = 1, Max = 10, Default = 5 },
    Callback = function(value)
        promptTimeout = value
        Notify({
            Title = "⚙️ Settings",
            Content = "Timeout set to " .. value .. "s",
            Duration = 2,
            Icon = "clock"
        });
    end
});

local TargetSection = mainTab:Section({
    Title = "🎯 Target List",
    Icon = "list",
    Opened = false
});

TargetSection:Paragraph({
    Title = "🎯 Targets",
    Content = "• Any name with 'femboy'\n• Roommate\n• Casual Astolfo\n• Chihiro Fujisaki\n• Venti\n• Gasper\n• Saika\n• J*b Application\n• Mythical Lucky Block\n• Nagisa Shiota\n• Felix\n• Rimuru"
});

-- Remove in-Femboy Information section (per request) — Information moved to dedicated tab

-- -------------------------
-- Utility Tab (movement only; bypass removed from UI)
-- -------------------------
local UtilityTab = Window:Tab({
    Title = "Utility",
    Icon = "tool",
    EnableScrolling = true
});

UtilityTab:Paragraph({
    Title = "ℹ️ About Utility",
    Content = "Здесь находятся вспомогательные функции — изменение скорости и прохождение сквозь стены (Noclip)."
});

local MovementSection = UtilityTab:Section({
    Title = "🏃 Movement",
    Icon = "run",
    Opened = true
});

MovementSection:Toggle({
    Title = "Enable Custom WalkSpeed",
    Default = false,
    Callback = function(value)
        walkSpeedEnabled = value
        
        if value then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = customWalkSpeed
                    Notify({
                        Title = "✅ WalkSpeed",
                        Content = "WalkSpeed set to " .. customWalkSpeed,
                        Duration = 2,
                        Icon = "run"
                    });
                end
            end
        else
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                    Notify({
                        Title = "🔄 WalkSpeed",
                        Content = "WalkSpeed reset to 16",
                        Duration = 2,
                        Icon = "refresh-ccw"
                    });
                end
            end
        end
    end
});

MovementSection:Slider({
    Title = "WalkSpeed Value",
    Step = 1,
    Value = { Min = 16, Max = 350, Default = 16 },
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
});

MovementSection:Toggle({
    Title = "Enable Noclip",
    Default = false,
    Callback = function(value)
        noclipEnabled = value
        
        if value then
            Notify({
                Title = "✅ Noclip",
                Content = "Noclip Enabled!",
                Duration = 2,
                Icon = "move"
            });
            
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
            Notify({
                Title = "🔄 Noclip",
                Content = "Noclip Disabled!",
                Duration = 2,
                Icon = "move"
            });
            
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
});

-- Keep WalkSpeed when character respawns
player.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    if walkSpeedEnabled then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = customWalkSpeed
        end
    end
end);

-- -------------------------
-- UI Settings Tab
-- -------------------------
local SettingTab = Window:Tab({
    Icon = "settings",
    Title = "UI Settings",
    EnableScrolling = true
});

local UISettings = SettingTab:Section({
    Title = "🎨 UI Customization",
    Icon = "paintbrush"
});

UISettings:Paragraph({
    Title = "Theme",
    Content = "Текущая тема: Nova Neon (Accent: RGB(120,80,255)). Вы можете поменять акцентный цвет ниже."
});

UISettings:Toggle({
    Title = "Always Show Frame",
    Default = false,
    Callback = function(v)
        -- Placeholder: WindUI may not expose direct AlwaysShow property; provide feedback
        if v then
            Notify({Title = "UI", Content = "Always Show Frame enabled (placeholder).", Duration = 2})
        else
            Notify({Title = "UI", Content = "Always Show Frame disabled (placeholder).", Duration = 2})
        end
    end
});

UISettings:Colorpicker({
    Title = "Highlight Color",
    Default = Color3.fromRGB(120, 80, 255),
    Callback = function(v)
        WindUI:AddTheme({
            Name = "Nova Neon - Custom",
            Accent = v,
            Dialog = Color3.fromRGB(18, 18, 20),
            Outline = Color3.fromRGB(255, 255, 255),
            Text = Color3.fromRGB(230, 230, 230),
            Placeholder = Color3.fromRGB(130, 130, 140),
            Background = Color3.fromRGB(8, 8, 10),
            Button = Color3.fromRGB(50, 40, 60),
            Icon = Color3.fromRGB(190, 180, 255)
        })
        WindUI:SetTheme("Nova Neon - Custom")
    end
});

UISettings:Button({
    Title = "Get Theme",
    Callback = function()
        pcall(function() setclipboard("Nova Neon") end)
        Notify({Title = "✅ Theme Copied", Content = "Theme name copied to clipboard!", Duration = 3})
    end
});

-- -------------------------
-- Config Tab
-- -------------------------
local ConfigTab = Window:Tab({
    Title = "Config",
    Icon = "folder",
    EnableScrolling = true
});

local ConfigUI = ConfigTab:Section({
    Title = "Config Manager",
    Icon = "archive"
});

ConfigUI:Paragraph({
    Title = "Config",
    Content = "WindUI предоставляет API для конфигураций. Здесь можно будет добавить сохранение/загрузку настроек в будущем."
});

ConfigUI:Button({
    Title = "Open Config Folder",
    Callback = function()
        -- Placeholder behavior: we can copy folder path or notify
        Notify({Title = "Config", Content = "Config folder: " .. tostring(ConfigManager.Directory), Duration = 3})
    end
});

-- -------------------------
-- Information Tab (new)
-- -------------------------
local InfoTab = Window:Tab({
    Title = "Information",
    Icon = "info",
    EnableScrolling = true
});

local InfoSection = InfoTab:Section({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles"
});

InfoSection:Paragraph({
    Title = "NovaAxis Hub",
    Content = "WindUI rewrite version 4.6-full\nGame: Steal A Femboy\nCreated by: NovaAxis"
});

InfoSection:Button({
    Title = "🌐 Discord Server",
    Desc = "Join NovaAxis Community",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/Eg98P4wf2V") end)
        Notify({Title = "✅ Copied", Content = "Discord invite copied to clipboard!", Duration = 3, Icon = "copy"})
    end
});

InfoSection:Paragraph({
    Title = "Support",
    Content = "Если хочешь добавить баннер, ник или кастомный контакт — скажи, добавлю."
});

-- -------------------------
-- Final initialization logs
-- -------------------------
print("✅ NovaAxis Hub loaded (WindUI - full)")
print("⌨️ Press Left Alt to toggle UI")
