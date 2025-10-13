local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

-- Создаем GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BaseLockGUI"
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 80)
mainFrame.Position = UDim2.new(1, -220, 1, -100) -- Внизу справа
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 80)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Lock Bases"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Toggle Switch
local toggleFrame = Instance.new("Frame")
toggleFrame.Size = UDim2.new(0, 60, 0, 30)
toggleFrame.Position = UDim2.new(0.5, -30, 1, -40)
toggleFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleFrame.BorderSizePixel = 0
toggleFrame.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 15)
toggleCorner.Parent = toggleFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 26, 0, 26)
toggleButton.Position = UDim2.new(0, 2, 0, 2)
toggleButton.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
toggleButton.BorderSizePixel = 0
toggleButton.Text = ""
toggleButton.Parent = toggleFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 13)
buttonCorner.Parent = toggleButton

-- Переменные
local isEnabled = false
local lockDebounce = false

-- Функция для плавного перемещения тоггла
local function animateToggle(state)
    local goal = {}
    if state then
        goal.Position = UDim2.new(1, -28, 0, 2)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    else
        goal.Position = UDim2.new(0, 2, 0, 2)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(toggleButton, tweenInfo, goal)
    tween:Play()
end

-- Функция блокировки базы (исправленная)
local function lockBase(base)
    local lockAttachment = base:FindFirstChild("Lock")
    if lockAttachment then
        -- Ищем LockAttachment (может быть BoolValue, NumberValue, или другой тип)
        local lock = lockAttachment:FindFirstChild("LockAttachment")
        local touchInterest = lockAttachment:FindFirstChild("TounchInterest")
        
        if lock then
            -- Пробуем разные варианты блокировки
            if lock:IsA("BoolValue") then
                lock.Value = true
            elseif lock:IsA("NumberValue") then
                lock.Value = 1
            elseif lock:IsA("StringValue") then
                lock.Value = "true"
            elseif lock:IsA("IntValue") then
                lock.Value = 1
            else
                -- Если это Attachment или другой объект, пробуем отключить
                if lock:IsA("Attachment") then
                    lock.Visible = false
                end
            end
        end
        
        -- Обрабатываем TouchInterest
        if touchInterest then
            if touchInterest:IsA("ClickDetector") then
                touchInterest.MaxActivationDistance = 0
            elseif touchInterest:IsA("BoolValue") then
                touchInterest.Value = false
            else
                touchInterest.Enabled = false
            end
        end
    end
end

-- Функция проверки и блокировки баз
local function checkAndLockBases()
    if not isEnabled or lockDebounce then return end
    
    lockDebounce = true
    
    for i = 1, 8 do
        local baseName = "Base" .. i
        local base = workspace.Bases:FindFirstChild(baseName)
        
        if base then
            local config = base:FindFirstChild("Configuration")
            if config then
                local playerValue = config:FindFirstChild("Player")
                if playerValue and playerValue:IsA("ObjectValue") and playerValue.Value then
                    -- Если это база текущего игрока - блокируем
                    if playerValue.Value == localPlayer then
                        lockBase(base)
                        print("Заблокирована база: " .. baseName)
                    end
                end
            end
        end
    end
    
    wait(0.5) -- Задержка против спама
    lockDebounce = false
end

-- Обработчик клика по тогглу
toggleButton.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    animateToggle(isEnabled)
    
    if isEnabled then
        print("Auto Lock включен")
        -- Сразу проверяем базы при включении
        checkAndLockBases()
    else
        print("Auto Lock выключен")
    end
end)

-- Функция для исследования структуры Lock (для отладки)
local function debugLockStructure()
    for i = 1, 8 do
        local baseName = "Base" .. i
        local base = workspace.Bases:FindFirstChild(baseName)
        if base then
            local lockAttachment = base:FindFirstChild("Lock")
            if lockAttachment then
                print("Структура Lock для " .. baseName .. ":")
                for _, child in ipairs(lockAttachment:GetChildren()) do
                    print("  " .. child.Name .. " (" .. child.ClassName .. ")")
                end
            end
        end
    end
end

-- Запускаем отладку при старте
wait(2)
debugLockStructure()

-- Постоянная проверка баз когда включено
while true do
    if isEnabled then
        checkAndLockBases()
    end
    wait(1) -- Проверяем каждую секунду
end
