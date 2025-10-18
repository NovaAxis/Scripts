-- Загрузка WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Создание окна
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis",
    Icon = "sparkles", -- lucide icon. optional
    Author = "NovaAxis", -- optional
    BackgroundImageTransparency = 0.45,
    User = {
        Enabled = true,
        Anonymous = false,
    },
})

-- Кастомизация кнопки открытия
Window:EditOpenButton({
    Title = "💫 NovaAxis",
    Icon = "sparkles",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new( -- gradient
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- Создание вкладки "Main"
local Tab = Window:Tab({
    Title = "Main",
    Icon = "sparkles", -- optional
    Locked = false,
})

-- Создание секции внутри вкладки "Main"
local ElementsSection = Tab:Section({
    Title = "Elements",
    Size = UDim2.new(1, 0, 0, 300) -- Размер секции
})

-- Предполагается, что код находится в локальном скрипте Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Функция для создания UI, принимающая ElementsSection (WindUI)
local function CreateUI(ElementsSection)
    -- Вкладка для демонстрации полей ввода
    local InputTab = ElementsSection:Tab({
        Title = "Input",
        Icon = "text-cursor-input",
    })

    -- Поле ввода (обычное текстовое поле)
    InputTab:Input({
        Title = "Input",
        Icon = "mouse",
        Placeholder = "Enter text",
        Type = "Text",
        Callback = function(value)
            print("Input value: " .. tostring(value))
        end
    })

    InputTab:Space()

    -- Текстовое поле (Textarea)
    InputTab:Input({
        Title = "Input Textarea",
        Type = "Textarea",
        Icon = "mouse",
        Placeholder = "Enter longer text",
        Callback = function(value)
            print("Textarea value: " .. tostring(value))
        end
    })

    InputTab:Space()

    -- Текстовое поле без иконки
    InputTab:Input({
        Title = "Input Textarea",
        Type = "Textarea",
        Placeholder = "Enter longer text",
        Callback = function(value)
            print("Textarea (no icon) value: " .. tostring(value))
        end
    })

    InputTab:Space()

    -- Поле ввода с описанием
    InputTab:Input({
        Title = "Input",
        Desc = "Input example",
        Type = "Text",
        Placeholder = "Enter text",
        Callback = function(value)
            print("Input with desc value: " .. tostring(value))
        end
    })

    InputTab:Space()

    -- Текстовое поле с описанием
    InputTab:Input({
        Title = "Input Textarea",
        Desc = "Input example",
        Type = "Textarea",
        Placeholder = "Enter longer text",
        Callback = function(value)
            print("Textarea with desc value: " .. tostring(value))
        end
    })

    InputTab:Space()

    -- Заблокированное поле ввода
    InputTab:Input({
        Title = "Input",
        Type = "Text",
        Locked = true,
        Placeholder = "Locked input",
        Callback = function(value)
            print("Locked input value: " .. tostring(value)) -- Не сработает, если Locked = true
        end
    })

    InputTab:Space()

    -- Заблокированное поле ввода с описанием
    InputTab:Input({
        Title = "Input",
        Desc = "Input example",
        Type = "Text",
        Locked = true,
        Placeholder = "Locked input",
        Callback = function(value)
            print("Locked input with desc value: " .. tostring(value)) -- Не сработает, если Locked = true
        end
    })

    -- Вкладка для ввода суммы и кнопки
    local MoneyTab = ElementsSection:Tab({
        Title = "Money Claim",
        Icon = "currency-dollar",
    })

    -- Переменная для хранения текущего значения поля ввода
    local currentMoneyValue = 100000 -- Значение по умолчанию

    -- Поле ввода для суммы денег (замена слайдера)
    local MoneyInput = MoneyTab:Input({
        Title = "Money Amount",
        Desc = "Enter amount",
        Type = "Text", -- WindUI не поддерживает Type = "Number", используем Text с валидацией
        Placeholder = "Enter amount (100000 to 1000000000000)",
        Callback = function(value)
            local numValue = tonumber(value)
            if numValue then
                if numValue >= 100000 and numValue <= 1000000000000 then
                    currentMoneyValue = numValue
                    print("Money Input value: " .. tostring(numValue))
                else
                    print("Input out of range: " .. tostring(value))
                end
            else
                print("Invalid input: " .. tostring(value))
            end
        end
    })

    MoneyTab:Space()

    -- Кнопка для отправки значения на сервер
    local Button = MoneyTab:Button({
        Title = "Claim Money",
        Desc = "Claim amount",
        Locked = false,
        Callback = function()
            -- Используем сохраненное значение из Callback
            print("Button clicked, value: " .. tostring(currentMoneyValue))

            -- Валидация значения
            if not currentMoneyValue then
                warn("Invalid value: no valid number entered")
                return
            end
            if currentMoneyValue < 100000 or currentMoneyValue > 1000000000000 then
                warn("Invalid value: must be between 100000 and 1000000000000")
                return
            end

            -- Отправка на сервер
            local success, err = pcall(function()
                local remote = ReplicatedStorage:FindFirstChild("ClaimReward")
                if not remote then
                    error("ClaimReward RemoteEvent not found in ReplicatedStorage")
                end
                if not remote:IsA("RemoteEvent") then
                    error("ClaimReward is not a RemoteEvent")
                end
                print("Sending to server: Money, " .. tostring(currentMoneyValue))
                remote:FireServer("Money", currentMoneyValue)
            end)

            if success then
                print("Successfully sent to server: Money, " .. tostring(currentMoneyValue))
                MoneyTab:Notify({ -- Добавляем уведомление, если WindUI поддерживает
                    Title = "Success",
                    Desc = "Claimed " .. tostring(currentMoneyValue)
                })
            else
                warn("Failed to send to server: " .. tostring(err))
                MoneyTab:Notify({
                    Title = "Error",
                    Desc = tostring(err)
                })
            end
        end
    })
end

-- Вызов функции CreateUI с ElementsSection
CreateUI(ElementsSection)
