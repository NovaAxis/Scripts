local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

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
    
    -- Проходим по всем Wooden Box
    for _, item in pairs(itemsFolder:GetChildren()) do
        if item.Name == "Wooden Box" then
            -- Телепортируемся к ящику
            local targetPosition
            if item:IsA("Model") and item.PrimaryPart then
                targetPosition = item.PrimaryPart.CFrame
            elseif item:IsA("BasePart") then
                targetPosition = item.CFrame
            elseif item:IsA("Model") then
                -- Если нет PrimaryPart, ищем первую BasePart
                for _, part in pairs(item:GetDescendants()) do
                    if part:IsA("BasePart") then
                        targetPosition = part.CFrame
                        break
                    end
                end
            end
            
            if targetPosition then
                humanoidRootPart.CFrame = targetPosition
                wait(0.2) -- Небольшая задержка для стабильности
                
                -- Ищем ProximityPrompt
                local prompt = findProximityPrompt(item)
                if prompt and prompt.Enabled then
                    -- Активируем ProximityPrompt
                    fireproximityprompt(prompt)
                    wait(0.5) -- Ждем выполнения действия
                end
                
                wait(0.1) -- Дополнительная пауза между ящиками
            end
        end
    end
    
    -- Возвращаемся на сохраненную позицию
    humanoidRootPart.CFrame = savedPosition
    wait(2) -- Пауза перед следующим циклом (можно изменить)
end
