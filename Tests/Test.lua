-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Игрок и персонаж
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Переменные
local currentFOV = 60
local currentWalkSpeed = 30
local speedEnabled = false
local flyEnabled = false
local flySpeed = 10
local tpWalkSpeed = 1
local tpWalkEnabled = false
local noclipEnabled = false
local infiniteJumpEnabled = false
local fullbrightEnabled = false

-- Переменные для полёта
local flyConnection
local bodyVelocity
local bodyGyro

-- Сохраненные значения
local originalFogEnd
local originalFogStart
local originalAmbient
local originalBrightness
local originalOutdoorAmbient

-- Функция обновления персонажа
local function onCharacterAdded(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    
    -- Восстанавливаем настройки
    if speedEnabled then
        humanoid.WalkSpeed = currentWalkSpeed
    end
    
    -- Применяем noclip если был включен
    if noclipEnabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- Подключаем обработчик появления персонажа
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

-- Функция полёта
local function toggleFly(state)
    flyEnabled = state
    
    if flyEnabled then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.Parent = rootPart
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
        bodyGyro.P = 10000
        bodyGyro.Parent = rootPart
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not rootPart then return end
            
            local moveDirection = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
            end
            
            bodyVelocity.Velocity = moveDirection * flySpeed
            bodyGyro.CFrame = camera.CFrame
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        
        if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
        end
    end
end

-- Функция TP Walk (исправленная версия с TranslateBy)
local tpWalkConnection
local function toggleTPWalk(state)
    tpWalkEnabled = state
    
    if tpWalkEnabled then
        tpWalkConnection = RunService.Heartbeat:Connect(function(delta)
            if not tpWalkEnabled or not humanoid or not character then return end
            
            if humanoid.MoveDirection.Magnitude > 0 then
                -- Используем TranslateBy для плавного движения (метод из Infinite Yield)
                character:TranslateBy(humanoid.MoveDirection * tpWalkSpeed * delta * 10)
            end
        end)
    else
        if tpWalkConnection then
            tpWalkConnection:Disconnect()
            tpWalkConnection = nil
        end
    end
end

-- Функция Fullbright
local function toggleFullbright(state)
    fullbrightEnabled = state
    
    if fullbrightEnabled then
        -- Сохраняем оригинальные значения
        originalFogEnd = Lighting.FogEnd
        originalFogStart = Lighting.FogStart
        originalAmbient = Lighting.Ambient
        originalBrightness = Lighting.Brightness
        originalOutdoorAmbient = Lighting.OutdoorAmbient
        
        -- Применяем fullbright
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        -- Восстанавливаем оригинальные значения
        if originalAmbient then
            Lighting.Ambient = originalAmbient
            Lighting.Brightness = originalBrightness
            Lighting.FogEnd = originalFogEnd
            Lighting.FogStart = originalFogStart
            Lighting.OutdoorAmbient = originalOutdoorAmbient
        end
    end
end

-- Инициализация WindUI
local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        WindUI = result
    else 
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/NovaAxis/WindUI/refs/heads/main/dist/main.lua"))()
    end
end

-- Создание окна
local Window = WindUI:CreateWindow({
    Title = "NovaAxis | Hub",
    Icon = "sparkles",
    Author = "By CreatorNovaAxis | discord.gg/wAwgJatMMt",
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

-- INFORMATION TAB
local InformationTab = Window:Tab({
    Title = "Information",
    Icon = "info"
})

-- DISCORD NOVAAXIS SECTION
local DiscordNovaAxisSection = InformationTab:Section({
    Title = "NovaAxis | Hub Discord server",
    Icon = "globe",
    Opened = true,
})

DiscordNovaAxisSection:Button({
    Title = "NovaAxis | Hub",
    Desc = "Click to copy Discord invite link",
    Icon = "sparkles",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/wAwgJatMMt") end)
        WindUI:Notify({ 
            Title = "✅ Copied", 
            Content = "Discord invite link copied!", 
            Duration = 3, 
            Icon = "copy" 
        })
    end
})

-- DISCORD MEOW SECTION
local DiscordMeowSection = InformationTab:Section({ 
    Title = "Meow Discord server",
    Icon = "globe",
    Opened = true,
})

DiscordMeowSection:Button({
    Title = "Meow",
    Desc = "Click to copy Discord invite link",
    Icon = "cat",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/WYyANHBgbZ") end)
        WindUI:Notify({ 
            Title = "✅ Copied", 
            Content = "Discord invite link copied!", 
            Duration = 3, 
            Icon = "copy" 
        })
    end
})

-- UI LIBRARY SECTION
local UISection = InformationTab:Section({ 
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

-- MAIN TAB
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "house"
})

-- LOCAL PLAYER TAB
local LocalPlayerTab = Window:Tab({
    Title = "Local Player",
    Icon = "circle-user",
})

-- SELF SECTION
local SelfSection = LocalPlayerTab:Section({
    Title = "Self",
    Icon = "user",
    Opened = true,
})

SelfSection:Toggle({
    Title = "FOV",
    Icon = "check",
    Default = false,
    Callback = function(state)
        if state then
            camera.FieldOfView = currentFOV
        else
            camera.FieldOfView = 70
        end
    end
})

SelfSection:Slider({
    Title = "FOV",
    Step = 1,
    Value = {
        Min = 10,
        Max = 120,
        Default = 60,
    },
    Callback = function(value)
        currentFOV = value
        camera.FieldOfView = value
    end
})

-- MOVEMENT SECTION
local MovementSection = LocalPlayerTab:Section({
    Title = "Movement",
    Icon = "user",
    Opened = true,
})

MovementSection:Slider({
    Title = "Walk Speed",
    Step = 1,
    Value = {
        Min = 0,
        Max = 100,
        Default = 30,
    },
    Callback = function(value)
        currentWalkSpeed = value
        if speedEnabled and humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

MovementSection:Toggle({
    Title = "Speed",
    Icon = "check",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if humanoid then
            if state then
                humanoid.WalkSpeed = currentWalkSpeed
            else
                humanoid.WalkSpeed = 16
            end
        end
    end
})

MovementSection:Toggle({
    Title = "Fly",
    Icon = "check",
    Default = false,
    Callback = function(state)
        toggleFly(state)
    end
})

MovementSection:Slider({
    Title = "Fly Speed",
    Step = 1,
    Value = {
        Min = 1,
        Max = 100,
        Default = 10,
    },
    Callback = function(value)
        flySpeed = value
    end
})

MovementSection:Slider({
    Title = "TP Walk Speed",
    Step = 0.1,
    Value = {
        Min = 0.1,
        Max = 5,
        Default = 1,
    },
    Callback = function(value)
        tpWalkSpeed = value
    end
})

MovementSection:Toggle({
    Title = "TP Walk",
    Icon = "check",
    Default = false,
    Callback = function(state)
        toggleTPWalk(state)
    end
})

MovementSection:Toggle({
    Title = "Noclip",
    Icon = "check",
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

MovementSection:Toggle({
    Title = "Infinite Jump",
    Icon = "check",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
    end
})

-- USEFUL STUFF SECTION
local UsefulSection = LocalPlayerTab:Section({
    Title = "Useful Stuff",
    Icon = "star",
    Opened = true,
})

UsefulSection:Toggle({
    Title = "Fullbright",
    Icon = "check",
    Default = false,
    Callback = function(state)
        toggleFullbright(state)
    end
})

UsefulSection:Button({
    Title = "Remove Fog",
    Icon = "mouse-pointer-click",
    Callback = function()
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        WindUI:Notify({
            Title = "✅ Fog Removed",
            Content = "Fog has been removed from the game.",
            Duration = 2,
            Icon = "cloud-off",
        })
    end
})

UsefulSection:Button({
    Title = "Remove Sky",
    Icon = "mouse-pointer-click",
    Callback = function()
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then
                v:Destroy()
            end
        end
        WindUI:Notify({
            Title = "✅ Sky Removed",
            Content = "Sky has been removed from the game.",
            Duration = 2,
            Icon = "cloud",
        })
    end
})

-- THEME TAB
local ThemeTab = Window:Tab({
    Title = "Theme",
    Icon = "app-window-mac",
})

-- THEME SECTION
local ThemeSection = ThemeTab:Section({ 
    Title = "Theme",
    Icon = "app-window-mac",
    Opened = true,
})

local Themes = (function()
    return function(WindUI)
        return {
            Dark = {
                Name = "Dark",
                Accent = Color3.fromHex("#18181b"),
                Dialog = Color3.fromHex("#161616"),
                Outline = Color3.fromHex("#FFFFFF"),
                Text = Color3.fromHex("#FFFFFF"),
                Placeholder = Color3.fromHex("#7a7a7a"),
                Background = Color3.fromHex("#101010"),
                Button = Color3.fromHex("#52525b"),
                Icon = Color3.fromHex("#a1a1aa"),
                Toggle = Color3.fromHex("#33C759"),
                Checkbox = Color3.fromHex("#0091ff"),
            },

            Light = {
                Name = "Light",
                Accent = Color3.fromHex("#FFFFFF"),
                Dialog = Color3.fromHex("#f4f4f5"),
                Outline = Color3.fromHex("#09090b"),
                Text = Color3.fromHex("#000000"),
                Placeholder = Color3.fromHex("#555555"),
                Background = Color3.fromHex("#e4e4e7"),
                Button = Color3.fromHex("#18181b"),
                Icon = Color3.fromHex("#52525b"),
            },

            Rose = {
                Name = "Rose",
                Accent = Color3.fromHex("#be185d"),
                Dialog = Color3.fromHex("#4c0519"),
                Outline = Color3.fromHex("#fecdd3"),
                Text = Color3.fromHex("#fdf2f8"),
                Placeholder = Color3.fromHex("#d67aa6"),
                Background = Color3.fromHex("#1f0308"),
                Button = Color3.fromHex("#e11d48"),
                Icon = Color3.fromHex("#fb7185"),
            },

            Plant = {
                Name = "Plant",
                Accent = Color3.fromHex("#166534"),
                Dialog = Color3.fromHex("#052e16"),
                Outline = Color3.fromHex("#bbf7d0"),
                Text = Color3.fromHex("#f0fdf4"),
                Placeholder = Color3.fromHex("#4fbf7a"),
                Background = Color3.fromHex("#0a1b0f"),
                Button = Color3.fromHex("#16a34a"),
                Icon = Color3.fromHex("#4ade80"),
            },

            Red = {
                Name = "Red",
                Accent = Color3.fromHex("#991b1b"),
                Dialog = Color3.fromHex("#450a0a"),
                Outline = Color3.fromHex("#fecaca"),
                Text = Color3.fromHex("#fef2f2"),
                Placeholder = Color3.fromHex("#d95353"),
                Background = Color3.fromHex("#1c0606"),
                Button = Color3.fromHex("#dc2626"),
                Icon = Color3.fromHex("#ef4444"),
            },

            Indigo = {
                Name = "Indigo",
                Accent = Color3.fromHex("#3730a3"),
                Dialog = Color3.fromHex("#1e1b4b"),
                Outline = Color3.fromHex("#c7d2fe"),
                Text = Color3.fromHex("#f1f5f9"),
                Placeholder = Color3.fromHex("#7078d9"),
                Background = Color3.fromHex("#0f0a2e"),
                Button = Color3.fromHex("#4f46e5"),
                Icon = Color3.fromHex("#6366f1"),
            },

            Sky = {
                Name = "Sky",
                Accent = Color3.fromHex("#0369a1"),
                Dialog = Color3.fromHex("#0c4a6e"),
                Outline = Color3.fromHex("#bae6fd"),
                Text = Color3.fromHex("#f0f9ff"),
                Placeholder = Color3.fromHex("#4fb6d9"),
                Background = Color3.fromHex("#041f2e"),
                Button = Color3.fromHex("#0284c7"),
                Icon = Color3.fromHex("#0ea5e9"),
            },

            Violet = {
                Name = "Violet",
                Accent = Color3.fromHex("#6d28d9"),
                Dialog = Color3.fromHex("#3c1361"),
                Outline = Color3.fromHex("#ddd6fe"),
                Text = Color3.fromHex("#faf5ff"),
                Placeholder = Color3.fromHex("#8f7ee0"),
                Background = Color3.fromHex("#1e0a3e"),
                Button = Color3.fromHex("#7c3aed"),
                Icon = Color3.fromHex("#8b5cf6"),
            },

            Amber = {
                Name = "Amber",
                Accent = Color3.fromHex("#b45309"),
                Dialog = Color3.fromHex("#451a03"),
                Outline = Color3.fromHex("#fde68a"),
                Text = Color3.fromHex("#fffbeb"),
                Placeholder = Color3.fromHex("#d1a326"),
                Background = Color3.fromHex("#1c1003"),
                Button = Color3.fromHex("#d97706"),
                Icon = Color3.fromHex("#f59e0b"),
            },

            Emerald = {
                Name = "Emerald",
                Accent = Color3.fromHex("#047857"),
                Dialog = Color3.fromHex("#022c22"),
                Outline = Color3.fromHex("#a7f3d0"),
                Text = Color3.fromHex("#ecfdf5"),
                Placeholder = Color3.fromHex("#3fbf8f"),
                Background = Color3.fromHex("#011411"),
                Button = Color3.fromHex("#059669"),
                Icon = Color3.fromHex("#10b981"),
            },

            Midnight = {
                Name = "Midnight",
                Accent = Color3.fromHex("#1e3a8a"),
                Dialog = Color3.fromHex("#0c1e42"),
                Outline = Color3.fromHex("#bfdbfe"),
                Text = Color3.fromHex("#dbeafe"),
                Placeholder = Color3.fromHex("#2f74d1"),
                Background = Color3.fromHex("#0a0f1e"),
                Button = Color3.fromHex("#2563eb"),
                Icon = Color3.fromHex("#3b82f6"),
            },

            Crimson = {
                Name = "Crimson",
                Accent = Color3.fromHex("#b91c1c"),
                Dialog = Color3.fromHex("#450a0a"),
                Outline = Color3.fromHex("#fca5a5"),
                Text = Color3.fromHex("#fef2f2"),
                Placeholder = Color3.fromHex("#6f757b"),
                Background = Color3.fromHex("#0c0404"),
                Button = Color3.fromHex("#991b1b"),
                Icon = Color3.fromHex("#dc2626"),
            },

            MonokaiPro = {
                Name = "Monokai Pro",
                Accent = Color3.fromHex("#fc9867"),
                Dialog = Color3.fromHex("#1e1e1e"),
                Outline = Color3.fromHex("#78dce8"),
                Text = Color3.fromHex("#fcfcfa"),
                Placeholder = Color3.fromHex("#6f6f6f"),
                Background = Color3.fromHex("#191622"),
                Button = Color3.fromHex("#ab9df2"),
                Icon = Color3.fromHex("#a9dc76"),
            },

            CottonCandy = {
                Name = "Cotton Candy",
                Accent = Color3.fromHex("#ec4899"),
                Dialog = Color3.fromHex("#2d1b3d"),
                Outline = Color3.fromHex("#f9a8d4"),
                Text = Color3.fromHex("#fdf2f8"),
                Placeholder = Color3.fromHex("#8a5fd3"),
                Background = Color3.fromHex("#1a0b2e"),
                Button = Color3.fromHex("#d946ef"),
                Icon = Color3.fromHex("#06b6d4"),
            }, 
            Ocean = {
            Name = "Ocean",

            Accent = Color3.fromHex("#0e7490"),
            Dialog = Color3.fromHex("#022c3a"),
            Outline = Color3.fromHex("#67e8f9"),
            Text = Color3.fromHex("#e0faff"),
            Placeholder = Color3.fromHex("#4faec2"),
            Background = Color3.fromHex("#01161b"),
            Button = Color3.fromHex("#0891b2"),
            Icon = Color3.fromHex("#22d3ee"),
        },
        Lava = {
            Name = "Lava",

            Accent = Color3.fromHex("#b91c1c"),
            Dialog = Color3.fromHex("#330000"),
            Outline = Color3.fromHex("#fca5a5"),
            Text = Color3.fromHex("#fff2f2"),
            Placeholder = Color3.fromHex("#d26565"),
            Background = Color3.fromHex("#190000"),
            Button = Color3.fromHex("#ef4444"),
            Icon = Color3.fromHex("#fb7185"),
        },
        Cyberpunk = {
            Name = "Cyberpunk",

            Accent = Color3.fromHex("#ff009d"),
            Dialog = Color3.fromHex("#140015"),
            Outline = Color3.fromHex("#00f0ff"),
            Text = Color3.fromHex("#e3efff"),
            Placeholder = Color3.fromHex("#8d4fe6"),
            Background = Color3.fromHex("#05000a"),
            Button = Color3.fromHex("#00eaff"),
            Icon = Color3.fromHex("#ff00f5"),
        },
        Neon = {
            Name = "Neon",

            Accent = Color3.fromHex("#39ff14"),
            Dialog = Color3.fromHex("#051b0a"),
            Outline = Color3.fromHex("#72ff6a"),
            Text = Color3.fromHex("#ccffdd"),
            Placeholder = Color3.fromHex("#6df699"),
            Background = Color3.fromHex("#020f05"),
            Button = Color3.fromHex("#25ff72"),
            Icon = Color3.fromHex("#4dffb8"),
        },
        Ice = {
            Name = "Ice",

            Accent = Color3.fromHex("#38bdf8"),
            Dialog = Color3.fromHex("#0c1f2c"),
            Outline = Color3.fromHex("#bae6fd"),
            Text = Color3.fromHex("#e0f8ff"),
            Placeholder = Color3.fromHex("#6bbad8"),
            Background = Color3.fromHex("#041319"),
            Button = Color3.fromHex("#0ea5e9"),
            Icon = Color3.fromHex("#7dd3fc"),
        },
        Galaxy = {
            Name = "Galaxy",

            Accent = Color3.fromHex("#7c3aed"),
            Dialog = Color3.fromHex("#1a1031"),
            Outline = Color3.fromHex("#c4b5fd"),
            Text = Color3.fromHex("#f3e8ff"),
            Placeholder = Color3.fromHex("#8d75d9"),
            Background = Color3.fromHex("#0b0718"),
            Button = Color3.fromHex("#9333ea"),
            Icon = Color3.fromHex("#c084fc"),
        },
        Sunset = {
            Name = "Sunset",

            Accent = Color3.fromHex("#f97316"),
            Dialog = Color3.fromHex("#3d0c02"),
            Outline = Color3.fromHex("#fdba74"),
            Text = Color3.fromHex("#fff7ed"),
            Placeholder = Color3.fromHex("#dd8a54"),
            Background = Color3.fromHex("#1a0600"),
            Button = Color3.fromHex("#fb923c"),
            Icon = Color3.fromHex("#fda56a"),
        },
        Toxic = {
            Name = "Toxic",

            Accent = Color3.fromHex("#b6ff00"),
            Dialog = Color3.fromHex("#142003"),
            Outline = Color3.fromHex("#d4ff71"),
            Text = Color3.fromHex("#f4ffe6"),
            Placeholder = Color3.fromHex("#8ed157"),
            Background = Color3.fromHex("#0a1501"),
            Button = Color3.fromHex("#a3ff00"),
            Icon = Color3.fromHex("#d7ff52"),
        },
        Steel = {
            Name = "Steel",

            Accent = Color3.fromHex("#4b5563"),
            Dialog = Color3.fromHex("#111827"),
            Outline = Color3.fromHex("#9ca3af"),
            Text = Color3.fromHex("#f3f4f6"),
            Placeholder = Color3.fromHex("#6b7280"),
            Background = Color3.fromHex("#0a0f18"),
            Button = Color3.fromHex("#6b7280"),
            Icon = Color3.fromHex("#d1d5db"),
        },
        Peach = {
            Name = "Peach",

            Accent = Color3.fromHex("#fb7185"),
            Dialog = Color3.fromHex("#3b0a14"),
            Outline = Color3.fromHex("#fecdd3"),
            Text = Color3.fromHex("#ffe4e6"),
            Placeholder = Color3.fromHex("#e08da2"),
            Background = Color3.fromHex("#22040a"),
            Button = Color3.fromHex("#f43f5e"),
            Icon = Color3.fromHex("#fda4af"),
        },
        Arctic = {
            Name = "Arctic",

            Accent = Color3.fromHex("#60a5fa"),
            Dialog = Color3.fromHex("#0c1220"),
            Outline = Color3.fromHex("#bfdbfe"),
            Text = Color3.fromHex("#e8f1ff"),
            Placeholder = Color3.fromHex("#89aefc"),
            Background = Color3.fromHex("#050a14"),
            Button = Color3.fromHex("#3b82f6"),
            Icon = Color3.fromHex("#93c5fd"),
        },
        Coffee = {
            Name = "Coffee",

            Accent = Color3.fromHex("#a16207"),
            Dialog = Color3.fromHex("#2a1805"),
            Outline = Color3.fromHex("#fcd34d"),
            Text = Color3.fromHex("#fef9c3"),
            Placeholder = Color3.fromHex("#c19d4b"),
            Background = Color3.fromHex("#1b1003"),
            Button = Color3.fromHex("#ca8a04"),
            Icon = Color3.fromHex("#facc15"),
        },
        Sakura = {
            Name = "Sakura",

            Accent = Color3.fromHex("#f472b6"),
            Dialog = Color3.fromHex("#2d0f1c"),
            Outline = Color3.fromHex("#fbcfe8"),
            Text = Color3.fromHex("#fff0f7"),
            Placeholder = Color3.fromHex("#d88ab6"),
            Background = Color3.fromHex("#190811"),
            Button = Color3.fromHex("#ec4899"),
            Icon = Color3.fromHex("#f9a8d4"),
        },
        ArcticNight = {
            Name = "Arctic Night",

            Accent = Color3.fromHex("#0ea5e9"),
            Dialog = Color3.fromHex("#0b132b"),
            Outline = Color3.fromHex("#7dd3fc"),
            Text = Color3.fromHex("#e0f7ff"),
            Placeholder = Color3.fromHex("#5699c6"),
            Background = Color3.fromHex("#050917"),
            Button = Color3.fromHex("#0284c7"),
            Icon = Color3.fromHex("#38bdf8"),
        },
        Hacker = {
            Name = "Hacker",

            Accent = Color3.fromHex("#00ff41"),
            Dialog = Color3.fromHex("#001406"),
            Outline = Color3.fromHex("#72ff95"),
            Text = Color3.fromHex("#d2ffe1"),
            Placeholder = Color3.fromHex("#6cfaa0"),
            Background = Color3.fromHex("#000a03"),
            Button = Color3.fromHex("#00cc33"),
            Icon = Color3.fromHex("#00ff66"),
        },
            Rainbow = {
                Name = "Rainbow",

                Accent = WindUI:Gradient({
                    ["0"]   = { Color = Color3.fromHex("#00ff41"), Transparency = 0 },
                    ["33"]  = { Color = Color3.fromHex("#00ffff"), Transparency = 0 },
                    ["66"]  = { Color = Color3.fromHex("#0080ff"), Transparency = 0 }, 
                    ["100"] = { Color = Color3.fromHex("#8000ff"), Transparency = 0 },
                }, { Rotation = 45 }),

                Dialog = WindUI:Gradient({
                    ["0"]   = { Color = Color3.fromHex("#ff0080"), Transparency = 0 }, 
                    ["25"]  = { Color = Color3.fromHex("#8000ff"), Transparency = 0 },
                    ["50"]  = { Color = Color3.fromHex("#0080ff"), Transparency = 0 },
                    ["75"]  = { Color = Color3.fromHex("#00ff80"), Transparency = 0 },
                    ["100"] = { Color = Color3.fromHex("#ff8000"), Transparency = 0 },
                }, { Rotation = 135 }),

                Outline = Color3.fromHex("#ffffff"),
                Text = Color3.fromHex("#ffffff"),
                Placeholder = Color3.fromHex("#00ff80"),

                Background = WindUI:Gradient({
                    ["0"]   = { Color = Color3.fromHex("#ff0040"), Transparency = 0 },
                    ["20"]  = { Color = Color3.fromHex("#ff4000"), Transparency = 0 },
                    ["40"]  = { Color = Color3.fromHex("#ffff00"), Transparency = 0 },
                    ["60"]  = { Color = Color3.fromHex("#00ff40"), Transparency = 0 },
                    ["80"]  = { Color = Color3.fromHex("#0040ff"), Transparency = 0 },
                    ["100"] = { Color = Color3.fromHex("#4000ff"), Transparency = 0 },
                }, { Rotation = 90 }),

                Button = WindUI:Gradient({
                    ["0"]   = { Color = Color3.fromHex("#ff0080"), Transparency = 0 },
                    ["25"]  = { Color = Color3.fromHex("#ff8000"), Transparency = 0 },
                    ["50"]  = { Color = Color3.fromHex("#ffff00"), Transparency = 0 },
                    ["75"]  = { Color = Color3.fromHex("#80ff00"), Transparency = 0 },
                    ["100"] = { Color = Color3.fromHex("#00ffff"), Transparency = 0 },
                }, { Rotation = 60 }),

                Icon = Color3.fromHex("#ffffff"),
            },
        }
    end
end)()

local ThemeList = Themes(WindUI)
local ThemeNames = {}

for name in pairs(ThemeList) do
    table.insert(ThemeNames, name)
end

ThemeSection:Dropdown({
    Title = "Select Theme",
    Values = ThemeNames,
    Locked = false,
    Value = ThemeNames[9],
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        WindUI:SetTheme(option)
    end
})

-- Infinite Jump обработчик
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Очистка при выходе
player.CharacterRemoving:Connect(function()
    if flyEnabled then
        toggleFly(false)
    end
    if tpWalkEnabled then
        toggleTPWalk(false)
    end
end)

Window:SelectTab(1)
