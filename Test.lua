-- ============================
-- Anti-Cheat Bypass (запускается перед UI)
-- ============================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

local function SetupKickProtection()
    local mt = getrawmetatable(game)
    if not mt then return end
    local oldNamecall = mt.__namecall
    if setreadonly then
        pcall(function() setreadonly(mt, false) end)
    end
    if oldNamecall then
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" then
                return nil
            end
            return oldNamecall(self, ...)
        end)
    end
end

local function DisconnectAllConnections(object, signalName)
    if not object then return end
    local ok, signal = pcall(function() return object[signalName] end)
    if not ok or not signal then return end
    local connections = getconnections(signal)
    if connections then
        for _, conn in pairs(connections) do
            if conn and type(conn.Disconnect) == "function" then
                pcall(function() conn:Disconnect() end)
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
        pcall(function()
            antiScript.Disabled = true
            antiScript:Destroy()
        end)
    end

    task.spawn(function()
        while task.wait(5) do
            if script.Parent then
                local newAnti = script.Parent:FindFirstChild("Anti")
                if newAnti then
                    pcall(function() newAnti.Disabled = true; newAnti:Destroy() end)
                end
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

-- Запускаем анти-чит байпас
pcall(ExecuteBypass)

-- ============================
-- Load WindUI
-- ============================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ============================
-- Services
-- ============================
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- ============================
-- Player
-- ============================
local player = Players.LocalPlayer

-- ============================
-- Target Names
-- ============================
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

-- ============================
-- State variables for Instant Steal
-- ============================
local isRunning = false
local promptTimeout = 5

-- ============================
-- Improved Instant Steal Functions
-- ============================
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
            local config = base:FindFirstChild("Configuration") or base:FindFirstChild("Configurationsa") or base:FindFirstChild("Config")
            if config then
                local playerValue = config:FindFirstChild("Player") or config:FindFirstChild("PlayerName") or config:FindFirstChild("Owner")
                if playerValue and (playerValue.Value == player or playerValue.Value == player.Name or tostring(playerValue.Value):lower() == player.Name:lower()) then
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
            -- Check slots first
            local slots = base:FindFirstChild("Slots")
            if slots then
                for _, slot in ipairs(slots:GetChildren()) do
                    for _, model in ipairs(slot:GetChildren()) do
                        if model:IsA("Model") then
                            local modelName = model.Name
                            if (type(modelName) == "string" and (modelName:lower():find("femboy") or modelName:lower():find("astolfo") or modelName:lower():find("venti"))) or TARGET_NAMES[modelName] then
                                return model, base
                            end
                        end
                    end
                end
            end
            
            -- Also check direct children of base
            for _, model in ipairs(base:GetChildren()) do
                if model:IsA("Model") then
                    local modelName = model.Name
                    if (type(modelName) == "string" and (modelName:lower():find("femboy") or modelName:lower():find("astolfo") or modelName:lower():find("venti"))) or TARGET_NAMES[modelName] then
                        return model, base
                    end
                end
            end
        end
    end
    return nil, nil
end

local function smoothTeleport(position)
    local character = player.Character
    if not character then return false end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end

    -- Stop any movement
    pcall(function()
        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        humanoidRootPart.RotVelocity = Vector3.zero
        humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end)

    -- Smooth teleport with multiple steps
    local currentPos = humanoidRootPart.Position
    local steps = 5
    local stepWait = 0.05
    
    for i = 1, steps do
        local lerpPos = currentPos:Lerp(position, i/steps)
        humanoidRootPart.CFrame = CFrame.new(lerpPos)
        task.wait(stepWait)
    end

    -- Final precise positioning
    humanoidRootPart.CFrame = CFrame.new(position)
    RunService.Heartbeat:Wait()
    
    -- Ensure no velocity
    pcall(function()
        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end)

    return true
end

local function findBestProximityPrompt(rootModel, originPosition, maxDistance)
    local bestPrompt, bestDistance = nil, math.huge
    maxDistance = maxDistance or 25

    for _, descendant in ipairs(rootModel:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Enabled then
            local part = descendant.Parent
            if part and part:IsA("BasePart") then
                local distance = (part.Position - originPosition).Magnitude
                if distance <= maxDistance and distance < bestDistance then
                    bestPrompt = descendant
                    bestDistance = distance
                end
            end
        end
    end
    
    -- If no prompt found in target model, search in the entire base
    if not bestPrompt then
        local base = rootModel:FindFirstAncestorOfClass("Model")
        if base then
            for _, descendant in ipairs(base:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") and descendant.Enabled then
                    local part = descendant.Parent
                    if part and part:IsA("BasePart") then
                        local distance = (part.Position - originPosition).Magnitude
                        if distance <= maxDistance and distance < bestDistance then
                            bestPrompt = descendant
                            bestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return bestPrompt
end

local function activateProximityPromptAdvanced(prompt, timeout)
    local success = false
    local errorMessage = nil
    local attempts = 0
    local maxAttempts = 3

    while attempts < maxAttempts and not success do
        attempts += 1
        
        local thread = task.spawn(function()
            local result, err = pcall(function()
                if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    -- Fire the prompt using different methods
                    local holdDuration = prompt.HoldDuration or 0.5
                    
                    -- Method 1: Direct fire
                    if prompt:IsA("ProximityPrompt") then
                        fireproximityprompt(prompt)
                        task.wait(0.1)
                    end
                    
                    -- Method 2: Input hold simulation
                    prompt:InputHoldBegin()
                    task.wait(holdDuration + 0.1) -- Slightly longer to ensure activation
                    prompt:InputHoldEnd()
                    
                    -- Method 3: Remote event if exists
                    local remoteEvent = prompt:FindFirstChildOfClass("RemoteEvent")
                    if remoteEvent then
                        pcall(function() 
                            remoteEvent:FireServer()
                            task.wait(0.1)
                        end)
                    end
                    
                    -- Method 4: Try to find and fire any related remote events in parent
                    local parent = prompt.Parent
                    if parent then
                        for _, obj in ipairs(parent:GetDescendants()) do
                            if obj:IsA("RemoteEvent") and obj.Name:lower():find("prompt") then
                                pcall(function() obj:FireServer() end)
                            end
                        end
                    end
                    
                    success = true
                else
                    error("Invalid or disabled ProximityPrompt")
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
            task.wait(0.5) -- Wait before retry
        end
    end

    if not success then
        return false, errorMessage or "Failed to activate prompt after " .. attempts .. " attempts"
    end

    return true, nil
end

local function getSpawnPosition(playerBase)
    local spawn = playerBase:FindFirstChild("Spawn") or playerBase:FindFirstChild("SpawnPoint")
    if spawn then
        if spawn:IsA("BasePart") then
            return spawn.Position
        else
            local basePart = spawn:FindFirstChild("Base") or spawn:FindFirstChild("Part") or spawn:FindFirstChild("Position")
            if basePart and basePart:IsA("BasePart") then
                return basePart.Position
            end
        end
    end
    
    -- Fallback: find any part in the base that might be a spawn
    for _, part in ipairs(playerBase:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():find("spawn") then
            return part.Position
        end
    end
    
    -- Ultimate fallback: use the base's primary part
    if playerBase.PrimaryPart then
        return playerBase.PrimaryPart.Position
    end
    
    return nil
end

local function executeInstantSteal()
    if isRunning then
        WindUI:Notify({ Title = "⚠️ Warning", Content = "Already running!", Duration = 2, Icon = "alert-circle" })
        return
    end

    isRunning = true

    local character = player.Character
    if not character then
        WindUI:Notify({ Title = "❌ Error", Content = "Character not found!", Duration = 3, Icon = "x" })
        isRunning = false
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not humanoidRootPart then
        WindUI:Notify({ Title = "❌ Error", Content = "Humanoid/HRP not found!", Duration = 3, Icon = "x" })
        isRunning = false
        return
    end

    WindUI:Notify({ Title = "🔍 Searching", Content = "Looking for your base...", Duration = 2, Icon = "search" })

    local playerBase = findPlayerBase()
    if not playerBase then
        WindUI:Notify({ Title = "❌ Error", Content = "Your base not found!", Duration = 3, Icon = "x" })
        isRunning = false
        return
    end

    WindUI:Notify({ Title = "🎯 Scanning", Content = "Searching for targets...", Duration = 2, Icon = "target" })

    local targetModel, targetBase = findTargetFemboy(playerBase)
    if not targetModel then
        WindUI:Notify({ Title = "❌ Error", Content = "No target femboy found!", Duration = 3, Icon = "x" })
        isRunning = false
        return
    end

    local targetPart = getAnyBasePart(targetModel)
    if not targetPart then
        WindUI:Notify({ Title = "❌ Error", Content = "Could not find target part", Duration = 3, Icon = "x" })
        isRunning = false
        return
    end

    local targetPosition = targetPart.Position + Vector3.new(0, 3, 2) -- Slightly higher and forward

    local savedWalkSpeed = humanoid.WalkSpeed
    local savedJumpPower = humanoid.JumpPower
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    WindUI:Notify({ Title = "✨ Teleporting", Content = "Moving to target...", Duration = 2, Icon = "arrow-right-circle" })

    if not smoothTeleport(targetPosition) then
        WindUI:Notify({ Title = "❌ Error", Content = "Teleportation failed!", Duration = 3, Icon = "x" })
        humanoid.WalkSpeed = savedWalkSpeed
        humanoid.JumpPower = savedJumpPower
        isRunning = false
        return
    end

    task.wait(0.5) -- Give time for everything to load

    WindUI:Notify({ Title = "🔎 Scanning", Content = "Looking for interaction prompt...", Duration = 2, Icon = "search" })

    local prompt = findBestProximityPrompt(targetModel, targetPosition, 30)
    
    if not prompt then
        -- Try searching in the entire base
        prompt = findBestProximityPrompt(targetBase or targetModel, targetPosition, 30)
    end

    if prompt then
        WindUI:Notify({ 
            Title = "⏳ Activating", 
            Content = "Found prompt! Activating... (" .. promptTimeout .. "s timeout)", 
            Duration = 2, 
            Icon = "clock" 
        })
        
        local ok, err = activateProximityPromptAdvanced(prompt, promptTimeout)

        if ok then
            WindUI:Notify({ Title = "✅ Success", Content = "Prompt activated successfully!", Duration = 3, Icon = "check" })
            task.wait(1)
        else
            WindUI:Notify({ Title = "⚠️ Warning", Content = "Prompt issue: " .. (err or "Unknown error"), Duration = 3, Icon = "alert-circle" })
        end
    else
        WindUI:Notify({ Title = "⚠️ Warning", Content = "No prompt found near target", Duration = 3, Icon = "alert-circle" })
    end

    -- Return to base
    WindUI:Notify({ Title = "🏠 Returning", Content = "Going back to your base...", Duration = 2, Icon = "home" })
    
    local spawnPosition = getSpawnPosition(playerBase)
    if spawnPosition then
        smoothTeleport(spawnPosition + Vector3.new(0, 3, 0))
        task.wait(0.5)
        WindUI:Notify({ Title = "✅ Complete", Content = "Successfully returned to base!", Duration = 3, Icon = "check" })
    else
        WindUI:Notify({ Title = "⚠️ Notice", Content = "Could not find spawn point, but steal attempt completed", Duration = 3, Icon = "info" })
    end

    -- Restore movement
    humanoid.WalkSpeed = savedWalkSpeed
    humanoid.JumpPower = savedJumpPower
    isRunning = false
end

-- ============================
-- Create main window
-- ============================
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis",
    Icon = "sparkles",
    Author = "by NovaAxis",
    BackgroundImageTransparency = 0.45,
    User = {
        Enabled = true,
        Anonymous = false,
    },
})

-- Customize open button
Window:EditOpenButton({
    Title = "💫 NovaAxis",
    Icon = "sparkles",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("BEB4FF"), 
        Color3.fromHex("7850FF")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- Add and set theme
WindUI:AddTheme({
    Name = "Nova Neon",
    Accent = Color3.fromRGB(120, 80, 255),
    Dialog = Color3.fromRGB(18, 18, 20),
    Outline = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(230, 230, 230),
    Placeholder = Color3.fromRGB(130, 130, 140),
    Background = Color3.fromRGB(8, 8, 10),
    Button = Color3.fromRGB(50, 40, 60),
    Icon = Color3.fromRGB(190, 180, 255)
})
WindUI:SetTheme("Nova Neon")

-- ============================
-- Tabs
-- ============================
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "sparkles",
    Locked = false,
})

local UtilityTab = Window:Tab({
    Title = "Utility",
    Icon = "wrench",
    Locked = false,
})

-- ============================
-- INSTANT STEAL SECTION (Main Tab)
-- ============================
local StealSection = MainTab:Section({
    Title = "⚡ Instant Steal",
    Icon = "zap",
    Opened = true
})

StealSection:Button({
    Title = "⚡ Execute Instant Steal",
    Description = "Teleport, activate prompt, return.",
    Icon = "zap",
    Callback = function()
        task.spawn(function()
            local ok, err = pcall(executeInstantSteal)
            if not ok then
                WindUI:Notify({ Title = "❌ Error", Content = "Error: " .. tostring(err), Duration = 3, Icon = "x" })
            end
        end)
    end
})

StealSection:Keybind({
    Title = "Quick Steal Hotkey",
    Description = "Set quick steal hotkey",
    Icon = "keyboard",
    Value = "F",
    Callback = function(v)
        local successKey, code = pcall(function() return Enum.KeyCode[v] end)
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
            WindUI:Notify({ Title = "✅ Hotkey", Content = "Quick steal hotkey set to " .. v, Duration = 2, Icon = "keyboard" })
        end
    end
})

-- Target List Section
local TargetSection = MainTab:Section({
    Title = "🎯 Target List",
    Icon = "list",
    Opened = true
})

TargetSection:Paragraph({
    Title = "🎯 Available Targets",
    Content = "• Any name with 'femboy'\n• Roommate\n• Casual Astolfo\n• Chihiro Fujisaki\n• Venti\n• Gasper\n• Saika\n• J*b Application\n• Mythical Lucky Block\n• Nagisa Shiota\n• Felix\n• Rimuru"
})

-- ============================
-- UTILITY TAB (existing features)
-- ============================
-- WalkSpeed
UtilityTab:Slider({
    Title = "WalkSpeed", 
    Description = "Adjust your walking speed (16 - 100)",
    Icon = "activity",
    Value = {
        Min = 16,
        Max = 100,
        Default = 16,
    },
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end
})

-- Noclip
local noclip = false
local noclipConnection

UtilityTab:Toggle({
    Title = "Noclip",
    Description = "Toggle wall collision on/off",
    Icon = "box",
    Default = false,
    Callback = function(state)
        noclip = state
        local char = game.Players.LocalPlayer.Character
        if not char then return end

        if noclip then
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
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
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

-- Infinite Jump
local infiniteJump = false

UtilityTab:Toggle({
    Title = "Infinite Jump",
    Description = "Jump infinitely while in the air",
    Icon = "arrow-up",
    Default = false,
    Callback = function(state)
        infiniteJump = state
    end
})

UserInputService.JumpRequest:Connect(function()
    if infiniteJump then
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

-- FPS Boost
UtilityTab:Button({
    Title = "FPS Boost",
    Description = "Optimize game for better performance",
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

-- ============================
-- INFORMATION TAB
-- ============================
local InfoTab = Window:Tab({
    Title = "Information",
    Icon = "info",
    Locked = false,
})

local InfoSection = InfoTab:Section({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Opened = true
})

InfoSection:Button({
    Title = "🌐 Discord Server",
    Description = "Click to copy invite link (Discord.gg/Eg98P4wf2V)",
    Icon = "discord",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.gg/Eg98P4wf2V")
        end)
        WindUI:Notify({
            Title = "✅ Copied",
            Content = "Discord invite copied to clipboard!",
            Duration = 3,
            Icon = "copy"
        })
    end
})

-- ============================
-- Final notification
-- ============================
WindUI:Notify({
    Title = "💫 NovaAxis Hub",
    Content = "Successfully loaded with Anti-Cheat Bypass!",
    Duration = 3,
    Icon = "sparkles"
})
