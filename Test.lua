-- 52
-- NovaAxis Hub - Chest Farm Script
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Настройки
local settings = {
    enabled = false,
    jumpInterval = 0.5,
    antiKick = true,
    currentChestIndex = 1
}

-- Anti-Kick
if settings.antiKick then
    for _, v in pairs(getconnections(player.Idled)) do
        v:Disable()
    end
end

-- Поиск сундуков
local function getChests()
    local chests = {}
    local chestsFolder = workspace.Map:FindFirstChild("Модели")
    
    if chestsFolder then
        local chestsContainer = chestsFolder:FindFirstChild("Chests")
        if chestsContainer then
            local modeliFolder = chestsContainer:FindFirstChild("Модели")
            if modeliFolder then
                for i = 1, 3 do
                    local chest = modeliFolder:FindFirstChild("Chest" .. i)
                    if chest then
                        table.insert(chests, chest)
                    end
                end
            end
        end
    end
    
    return chests
end

-- Телепортация к сундуку
-- Поиск сундуков
local function getChests()
    local chests = {}
    
    -- Пробуем разные пути к сундукам
    local paths = {
        workspace.Map.Модели.Chests.Модели,
        workspace.Map.Модели.Chests,
        workspace.Map.Chests.Модели,
        workspace.Map.Chests
    }
    
    for _, path in ipairs(paths) do
        if path then
            for i = 1, 3 do
                local chest = path:FindFirstChild("Chest" .. i)
                if chest then
                    table.insert(chests, chest)
                    print("Найден сундук:", chest.Name, "по пути:", path:GetFullName())
                end
            end
            if #chests > 0 then
                break
            end
        end
    end
    
    if #chests == 0 then
        print("Сундуки не найдены! Проверяю всё workspace...")
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:match("Chest%d") then
                table.insert(chests, obj)
                print("Найден сундук:", obj:GetFullName())
            end
        end
    end
    
    return chests
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
ToggleLabel.Text = "Auto Farm"
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

-- Функция переключения
local function toggleFarm()
    settings.enabled = not settings.enabled
    
    local targetPos = settings.enabled and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
    local targetColor = settings.enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 70)
    local buttonColor = settings.enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
    
    TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = targetPos, BackgroundColor3 = buttonColor}):Play()
    TweenService:Create(ToggleBackground, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
    
    StatusLabel.Text = settings.enabled and "Status: Farming..." or "Status: Disabled"
    StatusLabel.TextColor3 = settings.enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(150, 150, 150)
end

-- Клик по переключателю
local ToggleButtonClick = Instance.new("TextButton")
ToggleButtonClick.Size = UDim2.new(1, 0, 1, 0)
ToggleButtonClick.BackgroundTransparency = 1
ToggleButtonClick.Text = ""
ToggleButtonClick.Parent = ToggleBackground

ToggleButtonClick.MouseButton1Click:Connect(toggleFarm)

-- Родитель GUI
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Автопрыжки
local lastJump = 0
RunService.Heartbeat:Connect(function()
    if settings.enabled then
        local currentTime = tick()
        if currentTime - lastJump >= settings.jumpInterval then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            lastJump = currentTime
        end
    end
end)

-- Основной цикл фарма
task.spawn(function()
    while true do
        if settings.enabled then
            local chests = getChests()
            
            if #chests > 0 then
                local chest = chests[settings.currentChestIndex]
                teleportToChest(chest)
                
                settings.currentChestIndex = settings.currentChestIndex + 1
                if settings.currentChestIndex > #chests then
                    settings.currentChestIndex = 1
                end
                
                task.wait(0.1)
            else
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end)

-- Обновление персонажа при респавне
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
end)

print("NovaAxis Hub загружен!")
