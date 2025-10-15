-- NovaAxis Hub - Auto Farm
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Настройки
local settings = {
    enabled = false
}

-- Переменные для автосбора
local savedPosition = nil
local isCollecting = false

-- Функция для сохранения текущей позиции
local function savePosition()
    if humanoidRootPart then
        savedPosition = humanoidRootPart.Position
        print("Позиция сохранена: " .. tostring(savedPosition))
    end
end

-- Функция для проверки наличия Wooden Box
local function hasWoodenBoxes()
    local itemsFolder = Workspace:FindFirstChild("World")
    if itemsFolder then
        itemsFolder = itemsFolder:FindFirstChild("Items")
        if itemsFolder then
            for _, item in pairs(itemsFolder:GetChildren()) do
                if item.Name == "Wooden Box" then
                    return true
                end
            end
        end
    end
    return false
end

-- Функция для сбора всех Wooden Box
local function collectWoodenBoxes()
    local itemsFolder = Workspace:FindFirstChild("World")
    if not itemsFolder then return false end
    
    itemsFolder = itemsFolder:FindFirstChild("Items")
    if not itemsFolder then return false end
    
    local collected = false
    for _, item in pairs(itemsFolder:GetChildren()) do
        if item.Name == "Wooden Box" then
            -- Проверяем наличие ProximityPrompt
            local prompt = item:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then
                -- Телепортируемся к предмету
                if humanoidRootPart then
                    humanoidRootPart.CFrame = CFrame.new(item.Position + Vector3.new(0, 3, 0))
                    wait(0.5)
                    
                    -- Активируем ProximityPrompt
                    fireproximityprompt(prompt)
                    collected = true
                    wait(1)
                end
            end
        end
    end
    return collected
end

-- Функция для телепортации к сохраненной позиции
local function teleportToSavedPosition()
    if savedPosition and humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(savedPosition)
        print("Телепортирован к сохраненной позиции")
    else
        print("Нет сохраненной позиции!")
    end
end

-- Основная функция сбора
local function startCollecting()
    if isCollecting then return end
    isCollecting = true
    
    -- Сохраняем текущую позицию
    savePosition()
    
    spawn(function()
        while settings.enabled and hasWoodenBoxes() do
            local collected = collectWoodenBoxes()
            if not collected then
                break
            end
            wait(1)
        end
        
        -- Если Wooden Box закончились или сбор выключен, телепортируемся обратно
        if savedPosition then
            teleportToSavedPosition()
        end
        
        -- Выключаем автофарм если предметы закончились
        if settings.enabled and not hasWoodenBoxes() then
            settings.enabled = false
            updateUI()
            print("Автофарм завершен: предметы закончились")
        end
        
        isCollecting = false
    end)
end

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NovaAxisHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 150)
MainFrame.Position = UDim2.new(1, -320, 1, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Закругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Градиент
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "NovaAxis Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Линия под заголовком
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -20, 0, 2)
Divider.Position = UDim2.new(0, 10, 0, 55)
Divider.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- Контейнер для переключателя
local ToggleContainer = Instance.new("Frame")
ToggleContainer.Name = "ToggleContainer"
ToggleContainer.Size = UDim2.new(1, -20, 0, 50)
ToggleContainer.Position = UDim2.new(0, 10, 0, 70)
ToggleContainer.BackgroundTransparency = 1
ToggleContainer.Parent = MainFrame

-- Текст переключателя
local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "Auto Farm Wooden Box"
ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ToggleLabel.TextSize = 16
ToggleLabel.Font = Enum.Font.Gotham
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.Parent = ToggleContainer

-- Фон переключателя
local ToggleBackground = Instance.new("Frame")
ToggleBackground.Name = "ToggleBackground"
ToggleBackground.Size = UDim2.new(0, 50, 0, 26)
ToggleBackground.Position = UDim2.new(1, -50, 0.5, -13)
ToggleBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
ToggleBackground.BorderSizePixel = 0
ToggleBackground.Parent = ToggleContainer

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBackground

-- Кнопка переключателя
local ToggleButton = Instance.new("Frame")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 22, 0, 22)
ToggleButton.Position = UDim2.new(0, 2, 0.5, -11)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = ToggleBackground

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = ToggleButton

-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 1, -25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Disabled"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Функция обновления UI
local function updateUI()
    local targetPos = settings.enabled and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
    local targetColor = settings.enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 70)
    local buttonColor = settings.enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
    
    TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = targetPos, BackgroundColor3 = buttonColor}):Play()
    TweenService:Create(ToggleBackground, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
    
    if settings.enabled then
        StatusLabel.Text = "Status: Farming..."
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        StatusLabel.Text = "Status: Disabled"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end

-- Функция переключения
local function toggleFarm()
    settings.enabled = not settings.enabled
    updateUI()
    
    if settings.enabled then
        print("Автофарм включен")
        startCollecting()
    else
        print("Автофарм выключен")
        -- Телепортируемся обратно при выключении
        if savedPosition then
            teleportToSavedPosition()
        end
    end
end

-- Клик по переключателю
local ToggleButtonClick = Instance.new("TextButton")
ToggleButtonClick.Size = UDim2.new(1, 0, 1, 0)
ToggleButtonClick.BackgroundTransparency = 1
ToggleButtonClick.Text = ""
ToggleButtonClick.Parent = ToggleBackground

ToggleButtonClick.MouseButton1Click:Connect(toggleFarm)

-- Обработчик появления нового персонажа
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    
    -- Пересохраняем позицию если автофарм активен
    if settings.enabled then
        wait(2) -- Ждем полной загрузки персонажа
        savePosition()
        startCollecting()
    end
end)

-- Родитель GUI
ScreenGui.Parent = player:WaitForChild("PlayerGui")

print("NovaAxis Hub Auto Farm загружен!")
