-- 💫 NovaAxis - Instant Steal (Minimal WindUI Template)
-- Только одна кнопка: Instant Steal
-- Автор: NovaAxis (adapted)

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

-- ===== Helpers & core steal logic (compact but full behaviour) =====

local TARGET_NAMES = {
    ["Roommate"] = true, ["Casual Astolfo"] = true,
    ["Chihiro Fujisaki"] = true, ["Venti"] = true,
    ["Gasper"] = true, ["Saika"] = true,
    ["J*b Application"] = true, ["Mythical Lucky Block"] = true,
    ["Nagisa Shiota"] = true, ["Felix"] = true, ["Rimuru"] = true,
}

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
    local success = false
    local ok, err = pcall(function()
        if prompt and prompt:IsA("ProximityPrompt") then
            prompt:InputHoldBegin()
            local hold = prompt.HoldDuration or 0.5
            task.wait(hold)
            prompt:InputHoldEnd()
            local remoteEvent = prompt:FindFirstChildOfClass("RemoteEvent")
            if remoteEvent then pcall(function() remoteEvent:FireServer() end) end
            success = true
        else
            error("Invalid ProximityPrompt")
        end
    end)
    if not success then
        return false, tostring(err)
    end
    return true, nil
end

-- Main execute function (robust)
local isRunning = false
local promptTimeout = 5

local function executeInstantSteal()
    if isRunning then
        Notify({ Title = "⚠️ Warning", Content = "Already running!", Duration = 2 })
        return
    end
    isRunning = true

    local character = player.Character
    if not character then
        Notify({ Title = "❌ Error", Content = "Character not found!", Duration = 3 })
        isRunning = false
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then
        Notify({ Title = "❌ Error", Content = "Humanoid/HRP missing!", Duration = 3 })
        isRunning = false
        return
    end

    local playerBase = findPlayerBase()
    if not playerBase then
        Notify({ Title = "❌ Error", Content = "Your base not found!", Duration = 3 })
        isRunning = false
        return
    end

    local targetModel, targetBase = findTargetFemboy(playerBase)
    if not targetModel then
        Notify({ Title = "❌ Error", Content = "Target not found!", Duration = 3 })
        isRunning = false
        return
    end

    local targetPart = getAnyBasePart(targetModel)
    if not targetPart then
        Notify({ Title = "❌ Error", Content = "Could not find target part", Duration = 3 })
        isRunning = false
        return
    end

    local targetPosition = targetPart.Position + Vector3.new(0, 3, 0)

    -- temporarily disable movement to avoid annoyances
    local savedWalkSpeed = humanoid.WalkSpeed
    local savedJumpPower = humanoid.JumpPower
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    Notify({ Title = "✨ Info", Content = "Teleporting to target...", Duration = 2 })
    if not teleportCharacterToPosition(targetPosition) then
        Notify({ Title = "❌ Error", Content = "Teleportation failed!", Duration = 3 })
        humanoid.WalkSpeed = savedWalkSpeed
        humanoid.JumpPower = savedJumpPower
        isRunning = false
        return
    end

    task.wait(0.3)
    local prompt = findProximityPromptInModel(targetBase or targetModel, targetPosition, 25)
    if prompt then
        Notify({ Title = "⏳ Info", Content = "Activating prompt...", Duration = 2 })
        local ok, err = activateProximityPromptWithTimeout(prompt, promptTimeout)
        if ok then
            Notify({ Title = "✅ Success", Content = "Prompt activated!", Duration = 2 })
            task.wait(1)
        else
            Notify({ Title = "⚠️ Warning", Content = err or "Prompt timeout!", Duration = 3 })
        end
    else
        Notify({ Title = "⚠️ Warning", Content = "Prompt not found!", Duration = 2 })
    end

    -- return to spawn if available
    local spawn = playerBase:FindFirstChild("Spawn")
    if spawn then
        local spawnPosition
        if spawn:IsA("BasePart") then
            spawnPosition = spawn.Position
        else
            local basePart = spawn:FindFirstChild("Base")
            if basePart and basePart:IsA("BasePart") then
                spawnPosition = basePart.Position
            end
        end
        if spawnPosition then
            Notify({ Title = "🏠 Info", Content = "Returning to base...", Duration = 2 })
            teleportCharacterToPosition(spawnPosition + Vector3.new(0,3,0))
            task.wait(0.3)
            Notify({ Title = "✅ Success", Content = "Returned successfully!", Duration = 2 })
        end
    end

    humanoid.WalkSpeed = savedWalkSpeed
    humanoid.JumpPower = savedJumpPower
    isRunning = false
end

-- ===== Button (only UI) =====
MainTab:Button({
    Title = "⚡ INSTANT STEAL",
    Description = "Телепорт, активация промпта, возврат",
    Icon = "zap",
    Callback = function()
        task.spawn(function()
            local ok, err = pcall(executeInstantSteal)
            if not ok then
                Notify({ Title = "❌ Error", Content = "Error: "..tostring(err), Duration = 4 })
            end
        end)
    end
})
