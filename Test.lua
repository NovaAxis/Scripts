local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRoot")

local itemsFolder = workspace.World.Items
local isRunning = true

-- Функция для поиска ProximityPrompt в объекте
local function findProximityPrompt(obj)
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            return child
        end
    end
    return nil
end

-- Основной цикл
while isRunning do
    -- Сохраняем текущую позицию игрока
    local savedPosition = humanoidRootPart.CFrame
    
    -- Проходим по всем предметам в папке
    for _, item in pairs(itemsFolder:GetChildren()) do
        if item:IsA("BasePart") or item:IsA("Model") then
            -- Телепортируемся к предмету
            local targetPosition
            if item:IsA("Model") and item.PrimaryPart then
                targetPosition = item.PrimaryPart.CFrame
            elseif item:IsA("BasePart") then
                targetPosition = item.CFrame
            end
            
            if targetPosition then
                humanoidRootPart.CFrame = targetPosition
                wait(0.1) -- Небольшая задержка для стабильности
                
                -- Ищем ProximityPrompt
                local prompt = findProximityPrompt(item)
                if prompt and prompt.Enabled then
                    -- Активируем ProximityPrompt
                    fireproximityprompt(prompt)
                    wait(0.5) -- Ждем выполнения действия
                end
            end
        end
    end
    
    -- Возвращаемся на сохраненную позицию
    humanoidRootPart.CFrame = savedPosition
    wait(1) -- Пауза перед следующим циклом
end
