local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Переменные для хранения позиции и состояния
local savedPosition = nil
local isCollecting = false
local toggleSwitch = false

-- Функция для сохранения текущей позиции
local function savePosition()
    savedPosition = humanoidRootPart.Position
    print("Позиция сохранена: " .. tostring(savedPosition))
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
    if not itemsFolder then return end
    
    itemsFolder = itemsFolder:FindFirstChild("Items")
    if not itemsFolder then return end
    
    for _, item in pairs(itemsFolder:GetChildren()) do
        if item.Name == "Wooden Box" then
            -- Проверяем наличие ProximityPrompt
            local prompt = item:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then
                -- Телепортируемся к предмету
                humanoidRootPart.CFrame = CFrame.new(item.Position + Vector3.new(0, 3, 0))
                wait(0.5)
                
                -- Активируем ProximityPrompt
                fireproximityprompt(prompt)
                wait(1)
            end
        end
    end
end

-- Функция для телепортации к сохраненной позиции
local function teleportToSavedPosition()
    if savedPosition then
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
    
    while toggleSwitch and hasWoodenBoxes() do
        collectWoodenBoxes()
        wait(1) -- Небольшая задержка между проверками
    end
    
    -- Если Wooden Box закончились, телепортируемся обратно
    if savedPosition then
        teleportToSavedPosition()
    end
    
    -- Выключаем toggle switch
    toggleSwitch = false
    isCollecting = false
    print("Сбор завершен, toggle switch выключен")
end

-- Функция для переключения режима
local function toggleCollection()
    toggleSwitch = not toggleSwitch
    
    if toggleSwitch then
        print("Автосбор включен")
        startCollecting()
    else
        print("Автосбор выключен")
    end
end

-- Создаем GUI для управления (опционально)
local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local ToggleButton = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")
    
    ScreenGui.Parent = player.PlayerGui
    ScreenGui.Name = "AutoCollectGUI"
    
    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(0, 200, 0, 100)
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    
    ToggleButton.Parent = Frame
    ToggleButton.Size = UDim2.new(0.8, 0, 0.4, 0)
    ToggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
    ToggleButton.Text = "Включить автосбор"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    StatusLabel.Parent = Frame
    StatusLabel.Size = UDim2.new(0.8, 0, 0.3, 0)
    StatusLabel.Position = UDim2.new(0.1, 0, 0.65, 0)
    StatusLabel.Text = "Статус: Выключено"
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    ToggleButton.MouseButton1Click:Connect(function()
        toggleCollection()
        
        if toggleSwitch then
            ToggleButton.Text = "Выключить автосбор"
            StatusLabel.Text = "Статус: Включено"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            ToggleButton.Text = "Включить автосбор"
            StatusLabel.Text = "Статус: Выключено"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
end

-- Инициализация
if player.PlayerGui then
    createGUI()
else
    player:WaitForChild("PlayerGui")
    createGUI()
end

print("Скрипт автосбора загружен! Используйте GUI для управления.")
