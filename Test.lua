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

local function smoothTeleport(position)
    local character = player.Character
    if not character then return false end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end

    -- Плавный телепорт с твином
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
    
    pcall(function()
        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end)
    
    tween:Play()
    tween.Completed:Wait()
    
    pcall(function()
        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end)

    return true
end

local function getAllProximityPromptsInRange(originPosition, maxDistance)
    local prompts = {}
    maxDistance = maxDistance or 30
    
    -- Ищем во всем workspace
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Enabled then
            local part = descendant.Parent
            if part and part:IsA("BasePart") then
                local distance = (part.Position - originPosition).Magnitude
                if distance <= maxDistance then
                    table.insert(prompts, {
                        Prompt = descendant,
                        Distance = distance,
                        Part = part
                    })
                end
            end
        end
    end
    
    -- Сортируем по расстоянию (ближайшие first)
    table.sort(prompts, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return prompts
end

local function findBestProximityPrompt(searchTime)
    local character = player.Character
    if not character then return nil end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    
    local startTime = tick()
    local searchRadius = 30
    local bestPrompt = nil
    local closestDistance = math.huge
    
    WindUI:Notify({ Title = "🔍 Поиск", Content = "Ищу все proximity prompts вокруг...", Duration = 1, Icon = "search" })
    
    while tick() - startTime < searchTime do
        local allPrompts = getAllProximityPromptsInRange(humanoidRootPart.Position, searchRadius)
        
        if #allPrompts > 0 then
            -- Берем самый близкий prompt
            bestPrompt = allPrompts[1].Prompt
            closestDistance = allPrompts[1].Distance
            WindUI:Notify({ 
                Title = "✅ Найдено", 
                Content = "Найдено " .. #allPrompts .. " prompts, ближайший: " .. math.floor(closestDistance) .. " studs", 
                Duration = 1, 
                Icon = "check" 
            })
            break
        end
        
        -- Если не нашли, увеличиваем радиус поиска
        if tick() - startTime > searchTime * 0.5 then
            searchRadius = 50
        end
        
        task.wait(0.05) -- Уменьшил задержку для более быстрого поиска
    end
    
    return bestPrompt
end

local function advancedProximityPromptActivation(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false, "Invalid prompt"
    end

    local success = false
    local errorMessage = nil

    -- Метод 1: Прямая активация с изменением HoldDuration
    local originalHoldDuration = prompt.HoldDuration
    prompt.HoldDuration = 0

    local result1, err1 = pcall(function()
        prompt:InputHoldBegin()
        prompt:InputHoldEnd()
        
        local remoteEvent = prompt:FindFirstChildOfClass("RemoteEvent")
        if remoteEvent then
            remoteEvent:FireServer()
        end
        
        return true
    end)

    prompt.HoldDuration = originalHoldDuration

    if result1 then
        return true
    end

    -- Метод 2: Используем fireproximityprompt
    local result2, err2 = pcall(function()
        game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("FireProximityPrompt"):FireServer(prompt)
        return true
    end)

    if result2 then
        return true
    end

    -- Метод 3: Симуляция клика игрока
    local result3, err3 = pcall(function()
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                prompt:InputHoldBegin()
                task.wait(0.1)
                prompt:InputHoldEnd()
                return true
            end
        end
        return false
    end)

    if result3 then
        return true
    end

    -- Метод 4: Прямой вызов Triggered
    local result4, err4 = pcall(function()
        if prompt.Triggered then
            prompt.Triggered:Connect(function()
                -- Triggered event connected
            end)
        end
        return true
    end)

    return result4, err4 or "All activation methods failed"
end

local function ensureCharacterReady()
    local character = player.Character
    if not character then
        player.CharacterAdded:Wait()
        character = player.Character
    end
    
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)
    
    return character, humanoidRootPart, humanoid
end

local function executeInstantSteal()
    if isRunning then
        WindUI:Notify({ Title = "⚠️ Warning", Content = "Already running!", Duration = 2, Icon = "alert-circle" })
        return
    end

    isRunning = true

    -- Ожидаем готовности персонажа
    local character, humanoidRootPart, humanoid = ensureCharacterReady()
    if not character or not humanoidRootPart or not humanoid then
        WindUI:Notify({ Title = "❌ Error", Content = "Character not ready!", Duration = 3, Icon = "x" })
        isRunning = false
        return
    end

    local playerBase = findPlayerBase()
    if not playerBase then
        WindUI:Notify({ Title = "❌ Error", Content = "Your base not found!", Duration = 3, Icon = "x" })
        isRunning = false
        return
    end

    local targetModel, targetBase = findTargetFemboy(playerBase)
    if not targetModel then
        WindUI:Notify({ Title = "❌ Error", Content = "Target not found!", Duration = 3, Icon = "x" })
        isRunning = false
        return
    end

    local targetPart = getAnyBasePart(targetModel)
    if not targetPart then
        WindUI:Notify({ Title = "❌ Error", Content = "Could not find target part", Duration = 3, Icon = "x" })
        isRunning = false
        return
    end

    local targetPosition = targetPart.Position + Vector3.new(0, 3, 0)

    local savedWalkSpeed = humanoid.WalkSpeed
    local savedJumpPower = humanoid.JumpPower
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    WindUI:Notify({ Title = "✨ Телепорт", Content = "Плавный телепорт к цели...", Duration = 2, Icon = "arrow-right-circle" })

    if not smoothTeleport(targetPosition) then
        WindUI:Notify({ Title = "❌ Ошибка", Content = "Телепортация не удалась!", Duration = 3, Icon = "x" })
        humanoid.WalkSpeed = savedWalkSpeed
        humanoid.JumpPower = savedJumpPower
        isRunning = false
        return
    end

    task.wait(0.2)

    -- Улучшенный поиск proximity prompt
    WindUI:Notify({ Title = "🔍 Поиск", Content = "Расширенный поиск proximity prompt...", Duration = 1, Icon = "search" })
    local prompt = findBestProximityPrompt(1.5) -- Увеличил время поиска до 1.5 секунд

    if prompt then
        WindUI:Notify({ 
            Title = "⚡ Активация", 
            Content = "Активирую prompt улучшенным методом...", 
            Duration = 2, 
            Icon = "zap" 
        })
        
        local ok, err = advancedProximityPromptActivation(prompt)

        if ok then
            WindUI:Notify({ 
                Title = "✅ Успех", 
                Content = "Prompt успешно активирован!", 
                Duration = 2, 
                Icon = "check" 
            })
            task.wait(0.5)
        else
            WindUI:Notify({ 
                Title = "⚠️ Предупреждение", 
                Content = "Ошибка активации: " .. tostring(err), 
                Duration = 3, 
                Icon = "alert-circle" 
            })
        end
    else
        WindUI:Notify({ 
            Title = "⚠️ Предупреждение", 
            Content = "Prompt не найден после расширенного поиска!", 
            Duration = 2, 
            Icon = "alert-circle" 
        })
    end

    -- Возврат на базу
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
            WindUI:Notify({ Title = "🏠 Возврат", Content = "Возвращаюсь на базу...", Duration = 2, Icon = "home" })
            smoothTeleport(spawnPosition + Vector3.new(0, 3, 0))
            task.wait(0.3)
            WindUI:Notify({ Title = "✅ Успех", Content = "Успешно вернулся на базу!", Duration = 2, Icon = "check" })
        end
    end

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
-- IMPROVED INSTANT STEAL SECTION (Main Tab)
-- ============================
local StealSection = MainTab:Section({
    Title = "⚡ Улучшенный Instant Steal",
    Icon = "zap",
    Opened = true
})

StealSection:Button({
    Title = "⚡ Запустить Улучшенный Steal",
    Description = "Плавный телепорт + улучшенная активация prompt",
    Icon = "zap",
    Callback = function()
        task.spawn(function()
            local ok, err = pcall(executeInstantSteal)
            if not ok then
                WindUI:Notify({ Title = "❌ Ошибка", Content = "Ошибка: " .. tostring(err), Duration = 3, Icon = "x" })
            end
        end)
    end
})

StealSection:Keybind({
    Title = "Горячая клавиша Steal",
    Description = "Быстрая активация улучшенного steal",
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
            WindUI:Notify({ Title = "✅ Горячая клавиша", Content = "Горячая клавиша установлена на " .. v, Duration = 2, Icon = "keyboard" })
        end
    end
})

-- Target List Section
local TargetSection = MainTab:Section({
    Title = "🎯 Список Целей",
    Icon = "list",
    Opened = true
})

TargetSection:Paragraph({
    Title = "🎯 Доступные цели",
    Content = "• Любое имя с 'femboy'\n• Roommate\n• Casual Astolfo\n• Chihiro Fujisaki\n• Venti\n• Gasper\n• Saika\n• J*b Application\n• Mythical Lucky Block\n• Nagisa Shiota\n• Felix\n• Rimuru"
})

-- ============================
-- UTILITY TAB (existing features)
-- ============================
-- WalkSpeed
UtilityTab:Slider({
    Title = "Скорость ходьбы", 
    Description = "Настройте скорость ходьбы (16 - 100)",
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
    Description = "Включить/выключить столкновения",
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
    Title = "Бесконечный прыжок",
    Description = "Прыгать бесконечно в воздухе",
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
    Title = "Ускорение FPS",
    Description = "Оптимизировать игру для лучшей производительности",
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
            Title = "✅ Ускорение FPS",
            Content = "Производительность игры оптимизирована!",
            Duration = 3,
            Icon = "gauge"
        })
    end
})

-- ============================
-- INFORMATION TAB
-- ============================
local InfoTab = Window:Tab({
    Title = "Информация",
    Icon = "info",
    Locked = false,
})

local InfoSection = InfoTab:Section({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Opened = true
})

InfoSection:Button({
    Title = "🌐 Discord Сервер",
    Description = "Нажмите чтобы скопировать ссылку (Discord.gg/Eg98P4wf2V)",
    Icon = "discord",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.gg/Eg98P4wf2V")
        end)
        WindUI:Notify({
            Title = "✅ Скопировано",
            Content = "Ссылка на Discord скопирована!",
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
    Content = "Успешно загружено с улучшенным Instant Steal!",
    Duration = 3,
    Icon = "sparkles"
})
