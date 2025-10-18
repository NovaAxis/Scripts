-- ============================
-- Services
-- ============================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- ============================
-- Player
-- ============================
local player = Players.LocalPlayer

-- ============================
-- Anti-Cheat Bypass
-- ============================
local function SetupKickProtection()
    local success, mt = pcall(getrawmetatable, game)
    if not success or not mt then return end
    
    local oldNamecall = mt.__namecall
    if not oldNamecall then return end
    
    if setreadonly then
        pcall(setreadonly, mt, false)
    elseif make_writeable then
        pcall(make_writeable, mt)
    end
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" then
            return nil
        end
        return oldNamecall(self, ...)
    end)
    
    if setreadonly then
        pcall(setreadonly, mt, true)
    elseif make_readonly then
        pcall(make_readonly, mt)
    end
end

local function DisconnectAllConnections(object, signalName)
    if not object then return end
    
    local success, signal = pcall(function() return object[signalName] end)
    if not success or not signal then return end
    
    if getconnections then
        local connections = getconnections(signal)
        if connections then
            for _, conn in pairs(connections) do
                if conn and typeof(conn.Disable) == "function" then
                    pcall(conn.Disable, conn)
                elseif conn and typeof(conn.Disconnect) == "function" then
                    pcall(conn.Disconnect, conn)
                end
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
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            DisconnectAllConnections(humanoid, "StateChanged")
            DisconnectAllConnections(humanoid, "Changed")
            DisconnectAllConnections(humanoid, "Died")
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            DisconnectAllConnections(rootPart, "ChildAdded")
            DisconnectAllConnections(rootPart, "Changed")
        end
        
        DisconnectAllConnections(character, "ChildRemoved")
        DisconnectAllConnections(character, "DescendantRemoving")
    end
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        DisconnectAllConnections(backpack, "ChildAdded")
    end
    
    local camera = Workspace.CurrentCamera
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
                    pcall(function() 
                        newAnti.Disabled = true
                        newAnti:Destroy() 
                    end)
                end
            end
            
            if character and character.Parent then
                local currentHumanoid = character:FindFirstChildOfClass("Humanoid")
                if currentHumanoid then
                    DisconnectAllConnections(currentHumanoid, "StateChanged")
                end
            end
        end
    end)
end

pcall(ExecuteBypass)

-- ============================
-- Load WindUI
-- ============================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

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
-- State Variables
-- ============================
local isRunning = false
local noclip = false
local noclipConnection = nil
local infiniteJump = false

-- ============================
-- Utility Functions
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
                            if (type(modelName) == "string" and modelName:lower():find("femboy")) or TARGET_NAMES[modelName] then
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
        humanoidRootPart.RotVelocity = Vector3.zero
    end)
    
    humanoidRootPart.CFrame = CFrame.new(position)
    RunService.Heartbeat:Wait()
    
    pcall(function()
        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        humanoidRootPart.RotVelocity = Vector3.zero
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

local function activateProximityPromptInstantly(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false, "Invalid prompt"
    end
    
    local originalHoldDuration = prompt.HoldDuration
    prompt.HoldDuration = 0
    
    local success, result = pcall(function()
        fireproximityprompt(prompt)
        
        local remoteEvent = prompt:FindFirstChildOfClass("RemoteEvent")
        if remoteEvent then
            remoteEvent:FireServer()
        end
        
        return true
    end)
    
    prompt.HoldDuration = originalHoldDuration
    
    return success, result
end

-- ============================
-- Instant Steal Function
-- ============================
local function executeInstantSteal()
    if isRunning then
        WindUI:Notify({ 
            Title = "⚠️ Warning", 
            Content = "Already running!", 
            Duration = 2, 
            Icon = "alert-circle" 
        })
        return
    end
    
    isRunning = true
    
    local character = player.Character
    if not character then
        WindUI:Notify({ 
            Title = "❌ Error", 
            Content = "Character not found!", 
            Duration = 3, 
            Icon = "x" 
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
            Duration = 3, 
            Icon = "x" 
        })
        isRunning = false
        return
    end
    
    local playerBase = findPlayerBase()
    if not playerBase then
        WindUI:Notify({ 
            Title = "❌ Error", 
            Content = "Your base not found!", 
            Duration = 3, 
            Icon = "x" 
        })
        isRunning = false
        return
    end
    
    local targetModel, targetBase = findTargetFemboy(playerBase)
    if not targetModel then
        WindUI:Notify({ 
            Title = "❌ Error", 
            Content = "Target not found!", 
            Duration = 3, 
            Icon = "x" 
        })
        isRunning = false
        return
    end
    
    local targetPart = getAnyBasePart(targetModel)
    if not targetPart then
        WindUI:Notify({ 
            Title = "❌ Error", 
            Content = "Could not find target part", 
            Duration = 3, 
            Icon = "x" 
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
        Duration = 2, 
        Icon = "arrow-right-circle" 
    })
    
    if not teleportCharacterToPosition(targetPosition) then
        WindUI:Notify({ 
            Title = "❌ Error", 
            Content = "Teleportation failed!", 
            Duration = 3, 
            Icon = "x" 
        })
        humanoid.WalkSpeed = savedWalkSpeed
        humanoid.JumpPower = savedJumpPower
        isRunning = false
        return
    end
    
    task.wait(0.3)
    
    local prompt = findProximityPromptInModel(targetBase or targetModel, targetPosition, 25)
    
    if prompt then
        WindUI:Notify({ 
            Title = "⚡ Info", 
            Content = "Instantly activating prompt...", 
            Duration = 2, 
            Icon = "zap" 
        })
        
        local ok, err = activateProximityPromptInstantly(prompt)
        
        if ok then
            WindUI:Notify({ 
                Title = "✅ Success", 
                Content = "Prompt instantly activated!", 
                Duration = 2, 
                Icon = "check" 
            })
            task.wait(1)
        else
            WindUI:Notify({ 
                Title = "⚠️ Warning", 
                Content = err or "Prompt activation failed!", 
                Duration = 3, 
                Icon = "alert-circle" 
            })
        end
    else
        WindUI:Notify({ 
            Title = "⚠️ Warning", 
            Content = "Prompt not found!", 
            Duration = 2, 
            Icon = "alert-circle" 
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
                Duration = 2, 
                Icon = "home" 
            })
            teleportCharacterToPosition(spawnPosition + Vector3.new(0, 3, 0))
            task.wait(0.3)
            WindUI:Notify({ 
                Title = "✅ Success", 
                Content = "Returned successfully!", 
                Duration = 2, 
                Icon = "check" 
            })
        end
    end
    
    humanoid.WalkSpeed = savedWalkSpeed
    humanoid.JumpPower = savedJumpPower
    isRunning = false
end

-- ============================
-- Create UI
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

local InfoTab = Window:Tab({
    Title = "Information",
    Icon = "info",
    Locked = false,
})

-- ============================
-- Main Tab
-- ============================
local StealSection = MainTab:Section({
    Title = "⚡ Instant Steal",
    Icon = "zap",
    Opened = true
})

StealSection:Button({
    Title = "⚡ Execute Instant Steal",
    Description = "Teleport, instantly activate prompt, return.",
    Icon = "zap",
    Callback = function()
        task.spawn(function()
            local ok, err = pcall(executeInstantSteal)
            if not ok then
                WindUI:Notify({ 
                    Title = "❌ Error", 
                    Content = "Error: " .. tostring(err), 
                    Duration = 3, 
                    Icon = "x" 
                })
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
            end
            _G.NovaAxisQuickStealConnection = UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if input.KeyCode == code then
                    executeInstantSteal()
                end
            end)
            WindUI:Notify({ 
                Title = "✅ Hotkey", 
                Content = "Quick steal hotkey set to " .. v, 
                Duration = 2, 
                Icon = "keyboard" 
            })
        end
    end
})

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
-- Utility Tab
-- ============================
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
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
        end
    end
})

UtilityTab:Toggle({
    Title = "Noclip",
    Description = "Toggle wall collision on/off",
    Icon = "box",
    Default = false,
    Callback = function(state)
        noclip = state
        local char = player.Character
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
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

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
    if infiniteJump and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

UtilityTab:Button({
    Title = "FPS Boost",
    Description = "Optimize game for better performance",
    Icon = "gauge",
    Callback = function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            elseif v:IsA("Explosion") then
                v.BlastPressure = 0
                v.BlastRadius = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
        
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e10
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        end
        
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        
        WindUI:Notify({
            Title = "✅ FPS Boost",
            Content = "Game performance optimized!",
            Duration = 3,
            Icon = "gauge"
        })
    end
})

-- ============================
-- Information Tab
-- ============================
local InfoSection = InfoTab:Section({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Opened = true
})

InfoSection:Button({
    Title = "🌐 Discord Server",
    Description = "Click to copy invite link",
    Icon = "link",
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
-- Final Notification
-- ============================
WindUI:Notify({
    Title = "💫 NovaAxis Hub",
    Content = "Successfully loaded with Anti-Cheat Bypass!",
    Duration = 3,
    Icon = "sparkles"
})
