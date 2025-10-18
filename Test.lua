-- 💫 NovaAxis - Instant Steal (Minimal WindUI) — Без anti-cheat bypass
-- Автор: NovaAxis (adapted)
-- Примечание: Я отказался от любых обходов анти-чита. Этот скрипт — безопасная минималка с логгингом и 'Safe Mode'.

-- Load WindUI
local successWind, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not successWind or not WindUI then
    warn("WindUI failed to load.")
    return
end

-- Services & player
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Notify helper (uses WindUI)
local function Notify(opts)
    WindUI:Notify({
        Title = opts.Title or "Notification",
        Content = opts.Content or "",
        Duration = opts.Duration or 3,
        Icon = opts.Icon or "activity"
    })
end

-- Theme (Nova Neon)
WindUI:AddTheme({
    Name = "Nova Neon",
    Accent = Color3.fromRGB(120, 80, 255),
    Dialog = Color3.fromRGB(18, 18, 20),
    Outline = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(230, 230, 230),
    Placeholder = Color3.fromRGB(130, 130, 140),
    Background = Color3.fromRGB(8, 8, 10),
    Button = Color3.fromRGB(50, 40, 60),
    Icon = Color3.fromRGB(190, 180, 255)
})
WindUI:SetTheme("Nova Neon")

-- Create minimal window (only main tab)
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis",
    Icon = "sparkles",
    Author = "by NovaAxis",
    BackgroundImageTransparency = 0.45,
    Theme = "Nova Neon",
})
Window:SetToggleKey(Enum.KeyCode.LeftAlt)

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "zap",
})

-- ===== Configurable options =====
local promptTimeout = 5
local retryCount = 2
local safeMode = true -- если true — не выполняются потенциально рискованные операции

-- ===== Helpers & core steal logic (no bypass) =====
local TARGET_NAMES = {
    ["Roommate"] = true, ["Casual Astolfo"] = true,
    ["Chihiro Fujisaki"] = true, ["Venti"] = true,
    ["Gasper"] = true, ["Saika"] = true,
    ["J*b Application"] = true, ["Mythical Lucky Block"] = true,
    ["Nagisa Shiota"] = true, ["Felix"] = true, ["Rimuru"] = true,
}

local function safePcall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

local function getAnyBasePart(model)
    if not model then return nil end
    if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then
        return model.PrimaryPart
    end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
    return nil
end

local function findPlayerBase()
    local basesFolder = Workspace:FindFirstChild("Bases")
    if not basesFolder then return nil end
    for _, base in ipairs(basesFolder:GetChildren()) do
        if base:IsA("Model") then
            local config = base:FindFirstChild("Configuration") or base:FindFirstChild("Configurationsa")
            if config then
                local playerValue = config:FindFirstChild("Player")
                if playerValue and (playerValue.Value == player or playerValue.Value == player.Name) then
                    return base
                end
            end
        end
    end
    return nil
end

local function findTargetFemboy(playerBase)
    local basesFolder = Workspace:FindFirstChild("Bases")
    if not basesFolder then return nil, nil end
    for _, base in ipairs(basesFolder:GetChildren()) do
        if base:IsA("Model") and base ~= playerBase then
            local slots = base:FindFirstChild("Slots")
            if slots then
                for _, slot in ipairs(slots:GetChildren()) do
                    for _, model in ipairs(slot:GetChildren()) do
                        if model:IsA("Model") then
                            local name = tostring(model.Name)
                            if (type(name) == "string" and name:lower():find("femboy")) or TARGET_NAMES[name] then
                                return model, base
                            end
                        end
                    end
                end
            end
        end
    end
    return nil, nil
end

local function teleportCharacterToPosition(position)
    local character = player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    pcall(function() hrp.Velocity = Vector3.new(0,0,0); hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
    hrp.CFrame = CFrame.new(position)
    RunService.Heartbeat:Wait()
    pcall(function() hrp.Velocity = Vector3.new(0,0,0); hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
    return true
end

local function findProximityPromptInModel(rootModel, originPosition, maxDistance)
    maxDistance = maxDistance or 20
    local bestPrompt, bestDistance
    for _, d in ipairs(rootModel:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Enabled then
            local part = d.Parent
            if part and part:IsA("BasePart") then
                local dist = (part.Position - originPosition).Magnitude
                if dist <= maxDistance and (not bestDistance or dist < bestDistance) then
                    bestPrompt = d
                    bestDistance = dist
                end
            end
        end
    end
    return bestPrompt
end

local function activateProximityPromptWithTimeout(prompt, timeout)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false, "Invalid ProximityPrompt"
    end
    local ok, err = pcall(function()
        prompt:InputHoldBegin()
        local hold = prompt.HoldDuration or 0.5
        task.wait(hold)
        prompt:InputHoldEnd()
        local remoteEvent = prompt:FindFirstChildOfClass("RemoteEvent")
        if remoteEvent then pcall(function() remoteEvent:FireServer() end) end
    end)
    if not ok then return false, tostring(err) end
    return true, nil
end

-- Main execute function (robust, with retries; does NOT bypass anti-cheat)
local isRunning = false

local function executeInstantSteal()
    if isRunning then
        Notify({ Title = "⚠️", Content = "Уже выполняется", Duration = 2 })
        return
    end
    isRunning = true

    -- Retried execution wrapper
    local function attemptOnce()
        if not player or not player.Character then
            return false, "Character not found"
        end

        local character = player.Character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not hrp then
            return false, "Humanoid/HRP missing"
        end

        local playerBase = findPlayerBase()
        if not playerBase then
            return false, "Your base not found"
        end

        local targetModel, targetBase = findTargetFemboy(playerBase)
        if not targetModel then
            return false, "Target not found"
        end

        local targetPart = getAnyBasePart(targetModel)
        if not targetPart then
            return false, "Target part not found"
        end

        local targetPosition = targetPart.Position + Vector3.new(0,3,0)

        -- If safeMode is true, we avoid modifying humanoid properties heavily.
        local savedWalkSpeed, savedJumpPower
        if not safeMode then
            savedWalkSpeed = humanoid.WalkSpeed
            savedJumpPower = humanoid.JumpPower
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
        end

        Notify({ Title = "✨", Content = "Телепорт к цели...", Duration = 2 })
        local ok = teleportCharacterToPosition(targetPosition)
        if not ok then
            if not safeMode then
                humanoid.WalkSpeed = savedWalkSpeed or humanoid.WalkSpeed
                humanoid.JumpPower = savedJumpPower or humanoid.JumpPower
            end
            return false, "Teleport failed"
        end

        task.wait(0.3)
        local prompt = findProximityPromptInModel(targetBase or targetModel, targetPosition, 25)
        if prompt then
            Notify({ Title = "⏳", Content = "Активация промпта...", Duration = 2 })
            local ok2, err2 = activateProximityPromptWithTimeout(prompt, promptTimeout)
            if not ok2 then
                if not safeMode then
                    humanoid.WalkSpeed = savedWalkSpeed or humanoid.WalkSpeed
                    humanoid.JumpPower = savedJumpPower or humanoid.JumpPower
                end
                return false, "Prompt activation failed: "..tostring(err2)
            end
            Notify({ Title = "✅", Content = "Промпт активирован", Duration = 2 })
            task.wait(0.8)
        else
            if not safeMode then
                humanoid.WalkSpeed = savedWalkSpeed or humanoid.WalkSpeed
                humanoid.JumpPower = savedJumpPower or humanoid.JumpPower
            end
            return false, "Prompt not found"
        end

        -- Return to spawn if exists
        local spawn = playerBase:FindFirstChild("Spawn")
        if spawn then
            local spawnPos
            if spawn:IsA("BasePart") then spawnPos = spawn.Position
            else
                local basePart = spawn:FindFirstChild("Base")
                if basePart and basePart:IsA("BasePart") then spawnPos = basePart.Position end
            end
            if spawnPos then
                Notify({ Title = "🏠", Content = "Возврат на базу...", Duration = 2 })
                teleportCharacterToPosition(spawnPos + Vector3.new(0,3,0))
                task.wait(0.3)
                Notify({ Title = "✅", Content = "Возврат выполнен", Duration = 2 })
            end
        end

        if not safeMode then
            humanoid.WalkSpeed = savedWalkSpeed or humanoid.WalkSpeed
            humanoid.JumpPower = savedJumpPower or humanoid.JumpPower
        end

        return true, nil
    end

    local attempt = 0
    local lastErr
    while attempt <= retryCount do
        attempt = attempt + 1
        local ok, err = safePcall(attemptOnce)
        if ok and err == true then
            isRunning = false
            return
        elseif ok and err == nil then
            -- handled as success (attemptOnce returned true,nil)
            isRunning = false
            return
        else
            lastErr = err or "unknown"
            Notify({ Title = "⚠️ Попытка "..tostring(attempt).." не удалась", Content = tostring(lastErr), Duration = 2 })
            task.wait(0.5)
        end
    end

    Notify({ Title = "❌ Ошибка", Content = "Все попытки завершились неудачей: "..tostring(lastErr), Duration = 4 })
    isRunning = false
end

-- ===== UI controls: Button + SafeMode toggle + Hotkey =====
MainTab:Toggle({
    Title = "Safe Mode",
    Description = "Если включено — не выполняются рискованные изменения (рекомендуется)",
    Default = safeMode,
    Callback = function(v) safeMode = v end
})

MainTab:Slider({
    Title = "Prompt Timeout (s)",
    Value = { Min = 1, Max = 10, Default = promptTimeout },
    Callback = function(v) promptTimeout = v end
})

MainTab:Slider({
    Title = "Retries",
    Description = "Сколько автоматических попыток при ошибке",
    Value = { Min = 0, Max = 5, Default = retryCount },
    Callback = function(v) retryCount = v end
})

MainTab:Button({
    Title = "⚡ INSTANT STEAL",
    Description = "Телепорт, активация промпта, возврат",
    Icon = "zap",
    Callback = function()
        task.spawn(function()
            local ok, err = pcall(executeInstantSteal)
            if not ok then
                Notify({ Title = "❌ Error", Content = "Internal error: "..tostring(err), Duration = 4 })
            end
        end)
    end
})

-- Hotkey: F для быстрого запуска
do
    local key = Enum.KeyCode.F
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == key then
            task.spawn(function()
                local ok, err = pcall(executeInstantSteal)
                if not ok then Notify({ Title = "❌ Error", Content = tostring(err), Duration = 3 }) end
            end)
        end
    end)
end
