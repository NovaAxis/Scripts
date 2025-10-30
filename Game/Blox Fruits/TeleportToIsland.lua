isTeleporting = state

if state then
    if not selectedLocation or selectedLocation == "No locations available" then
        WindUI:Notify({
            Title = "⚠️ Error",
            Content = "Please select a valid location first!",
            Duration = 3,
            Icon = "alert-triangle"
        })
        TeleportToggle:Set(false)
        return
    end

    local character = Player.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local selectedModel = mapFolder and mapFolder:FindFirstChild(selectedLocation)
    if not selectedModel then
        WindUI:Notify({
            Title = "⚠️ Error",
            Content = "Location not found!",
            Duration = 3,
            Icon = "alert-triangle"
        })
        TeleportToggle:Set(false)
        return
    end

    local teleportPosition
    if selectedModel.PrimaryPart then
        teleportPosition = selectedModel.PrimaryPart.Position
    else
        local firstPart = selectedModel:FindFirstChildOfClass("Part") or selectedModel:FindFirstChildOfClass("BasePart")
        if firstPart then
            teleportPosition = firstPart.Position
        end
    end

    if not teleportPosition then
        WindUI:Notify({
            Title = "⚠️ Error",
            Content = "Could not find teleport point!",
            Duration = 3,
            Icon = "alert-triangle"
        })
        TeleportToggle:Set(false)
        return
    end

    local liftUpPosition = humanoidRootPart.Position + Vector3.new(0, 50, 0)
    local liftTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local liftGoal = {CFrame = CFrame.new(liftUpPosition)}
    local liftTween = TweenService:Create(humanoidRootPart, liftTweenInfo, liftGoal)
    
    liftTween:Play()
    liftTween.Completed:Wait()
    
    local finalPosition = teleportPosition + Vector3.new(0, 5, 0)
    local distance = (finalPosition - humanoidRootPart.Position).Magnitude
    local duration = distance / tweenSpeed
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    
    local goal = {CFrame = CFrame.new(finalPosition)}
    currentTween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    
    currentTween:Play()
    
    WindUI:Notify({
        Title = "🌀 Teleporting",
        Content = "Teleporting to " .. selectedLocation .. " at speed " .. tweenSpeed,
        Duration = 3,
        Icon = "send"
    })
    
    currentTween.Completed:Connect(function()
        WindUI:Notify({
            Title = "✅ Arrived",
            Content = "Successfully teleported to " .. selectedLocation,
            Duration = 3,
            Icon = "check"
        })
        TeleportToggle:Set(false)
        isTeleporting = false
    end)
else
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
        WindUI:Notify({
            Title = "⏸️ Teleport Cancelled",
            Content = "Teleportation stopped",
            Duration = 3,
            Icon = "pause"
        })
    end
end
