local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

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

Window:EditOpenButton({
    Title = "💫 NovaAxis",
    Icon = "sparkles",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new( -- gradient
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

local Tab = Window:Tab({
    Title = "Main",
    Icon = "sparkles", -- optional
    Locked = false,
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

    -- Поле ввода для суммы денег (замена слайдера)
    local MoneyInput = MoneyTab:Input({
        Title = "Money Amount",
        Desc = "Enter amount",
        Type = "Number", -- Предполагаем поддержку числового ввода, иначе используем "Text"
        Placeholder = "Enter amount (100000 to 1000000000000)",
        Callback = function(value)
            local numValue = tonumber(value)
            if numValue then
                print("Money Input value: " .. tostring(numValue))
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
            -- Получение значения из поля ввода
            local value = MoneyInput:GetValue() -- Замените на правильный метод WindUI, если нужно
            print("Button clicked, value: " .. tostring(value))

            -- Валидация введенного значения
            local numValue = tonumber(value)
            if not numValue then
                warn("Invalid value: not a number")
                return
            end
            if numValue < 100000 or numValue > 1000000000000 then
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
                print("Sending to server: Money, " .. tostring(numValue))
                remote:FireServer("Money", numValue)
            end)

            if success then
                print("Successfully sent to server: Money, " .. tostring(numValue))
            else
                warn("Failed to send to server: " .. tostring(err))
            end
        end
    })
end
