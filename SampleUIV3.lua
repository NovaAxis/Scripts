-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Игрок и персонаж
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Флаги функций
local noclipEnabled = false
local infiniteJumpEnabled = false
local flyEnabled = false
local currentWalkSpeed = 16
local currentJumpHeight = 7.2 -- Стандартное значение JumpHeight
local flySpeed = 50

-- Переменные для полёта
local flyConnection
local bodyVelocity
local bodyGyro

-- Функция безопасного получения humanoid
local function getHumanoid()
    if character and character:FindFirstChild("Humanoid") then
        return character.Humanoid
    end
    return nil
end

-- Функция обновления персонажа
local function onCharacterAdded(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    
    -- Переключаем на JumpHeight если используется JumpPower
    if humanoid.UseJumpPower then
        humanoid.UseJumpPower = false
    end
    
    -- Восстанавливаем настройки
    humanoid.WalkSpeed = currentWalkSpeed
    humanoid.JumpHeight = currentJumpHeight
    
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
        -- Создаём объекты для полёта
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.Parent = rootPart
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
        bodyGyro.P = 10000
        bodyGyro.Parent = rootPart
        
        -- Цикл управления полётом
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not rootPart then return end
            
            local camera = workspace.CurrentCamera
            local moveDirection = Vector3.new(0, 0, 0)
            
            -- Получаем направление движения
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
            
            -- Применяем движение
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
            end
            
            bodyVelocity.Velocity = moveDirection * flySpeed
            bodyGyro.CFrame = camera.CFrame
        end)
    else
        -- Отключаем полёт
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
            Color3.fromHex("be185d"),
            Color3.fromHex("1f0308")
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

-- DISCORD NOVAAXIS SECTION
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

-- DISCORD MEOW SECTION
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

-- UI LIBRARY SECTION
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

-- MAIN TAB
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "house"
})

-- LOCAL PLAYER TAB
local LocalPlayerTab = Window:Tab({
    Title = "Local Player",
    Icon = "user-cog",
})

-- MOVEMENT SECTION
local MovementSection = LocalPlayerTab:Section({ 
    Title = "Movement",
    Icon = "gauge",
    Opened = true,
})

MovementSection:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = {
        Min = 16,
        Max = 100,
        Default = 16,
    },
    Callback = function(value)
        currentWalkSpeed = value
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = value
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
            -- Убеждаемся что используется JumpHeight
            if hum.UseJumpPower then
                hum.UseJumpPower = false
            end
            hum.JumpHeight = value
        end
    end
})

-- ABILITIES SECTION
local AbilitiesSection = LocalPlayerTab:Section({ 
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
    Title = "Fly (PC)",
    Desc = "WASD + Space/Shift",
    Icon = "plane",
    Default = false,
    Callback = function(state) 
        toggleFly(state)
    end
})

AbilitiesSection:Slider({
    Title = "Fly Speed",
    Step = 1,
    Value = {
        Min = 10,
        Max = 200,
        Default = 50,
    },
    Callback = function(value)
        flySpeed = value
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

-- Очистка при выходе
player.CharacterRemoving:Connect(function()
    if flyEnabled then
        toggleFly(false)
    end
end)

