-- ============================
-- 💫 NovaAxis — Auto Collect + Utility Hub
-- ============================

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create main window
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis",
    Icon = "sparkles",
    Author = "by NovaAxis",
    BackgroundImageTransparency = 0.45,
    User = {
        Enabled = true,
        Anonymous = false,
    },
})

-- Customize open button
Window:EditOpenButton({
    Title = "💫 NovaAxis",
    Icon = "sparkles",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("BEB4FF"), 
        Color3.fromHex("7850FF")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- Add and set theme
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

-- Tabs
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "sparkles",
    Locked = false,
})

local UtilityTab = Window:Tab({
    Title = "Utility",
    Icon = "wrench",
    Locked = false,
})

----------------------------------------------------------
-- 🔹 AUTO LOCK SYSTEM (Locker)
----------------------------------------------------------
local autoLock = false
local autoLockThread
local lockDelay = 60 -- default delay (seconds)

local function lockLocker()
    local playerBase = baseFolder:FindFirstChild(player.Name .. "'s Base")
    if not playerBase then 
        warn("⚠️ Player base not found!") 
        return 
    end

    local floor1 = playerBase:FindFirstChild("Floor1")
    if not floor1 then 
        warn("⚠️ Floor1 not found!") 
        return 
    end

    local locker = floor1:FindFirstChild("Locker")
    if not locker then 
        warn("⚠️ Locker not found!") 
        return 
    end

    local args = { locker }
    local lockRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Base:Lock")
    lockRemote:FireServer(unpack(args))
    print("🔒 Base locked for", player.Name)
end

MainTab:Toggle({
    Title = "Auto Lock Base",
    Description = "Automatically locks your base every set interval",
    Icon = "lock",
    Default = false,
    Callback = function(state)
        autoLock = state
        if autoLock then
            WindUI:Notify({
                Title = "🔒 Auto Lock Enabled",
                Content = "Base will lock every " .. lockDelay .. " seconds.",
                Duration = 3,
                Icon = "lock"
            })
            autoLockThread = task.spawn(function()
                while autoLock do
                    lockLocker()
                    task.wait(lockDelay)
                end
            end)
        else
            WindUI:Notify({
                Title = "🔓 Auto Lock Disabled",
                Content = "Stopped automatic base locking.",
                Duration = 3,
                Icon = "unlock"
            })
            autoLock = false
        end
    end
})

MainTab:Slider({
    Title = "Auto Lock Interval (seconds)",
    Description = "Set how often the base will lock (60 - 160 sec)",
    Icon = "clock",
    Value = {
        Min = 60,
        Max = 160,
        Default = 60,
    },
    Callback = function(value)
        lockDelay = value
        if autoLock then
            WindUI:Notify({
                Title = "⏱️ Auto Lock Interval Updated",
                Content = "Now locking every " .. value .. " seconds",
                Duration = 3,
                Icon = "clock"
            })
        end
    end
})


----------------------------------------------------------
-- 🔹 AUTO COLLECT SYSTEM
----------------------------------------------------------
local autoCollect = false
local autoCollectThread
local collectDelay = 10 -- default delay (seconds)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local baseFolder = workspace:WaitForChild("Player Bases")

local function collectAllSlots()
    local playerBase = baseFolder:FindFirstChild(player.Name .. "'s Base")
    if not playerBase then
        warn("⚠️ Player base not found!")
        return
    end

    local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Base:CollectSlot")

    for floorIndex = 1, 3 do
        local floor = playerBase:FindFirstChild("Floor" .. floorIndex)
        if floor then
            for slotIndex = 1, 30 do
                local slot = floor:FindFirstChild("Slot" .. slotIndex)
                if slot then
                    remote:FireServer(slot)
                    task.wait(0.1)
                end
            end
        end
    end
end

MainTab:Toggle({
    Title = "Auto Collect Slots",
    Description = "Automatically collects all slots from all floors",
    Icon = "database",
    Default = false,
    Callback = function(state)
        autoCollect = state
        if autoCollect then
            WindUI:Notify({
                Title = "✅ Auto Collect Enabled",
                Content = "Collecting slots every " .. collectDelay .. " seconds.",
                Duration = 3,
                Icon = "sparkles"
            })
            autoCollectThread = task.spawn(function()
                while autoCollect do
                    collectAllSlots()
                    task.wait(collectDelay)
                end
            end)
        else
            WindUI:Notify({
                Title = "⛔ Auto Collect Disabled",
                Content = "Stopped collecting slots.",
                Duration = 3,
                Icon = "x"
            })
            autoCollect = false
        end
    end
})

MainTab:Slider({
    Title = "Auto Collect Delay (seconds)",
    Description = "Adjust the interval between each auto collect (10 - 30 sec)",
    Icon = "clock",
    Value = {
        Min = 10,
        Max = 30,
        Default = 10,
    },
    Callback = function(value)
        collectDelay = value
        WindUI:Notify({
            Title = "⏱️ Delay Updated",
            Content = "New delay: " .. value .. " seconds",
            Duration = 2,
            Icon = "clock"
        })
    end
})

----------------------------------------------------------
-- 🔹 WALK SPEED SLIDER
----------------------------------------------------------
UtilityTab:Slider({
    Title = "WalkSpeed", 
    Description = "Adjust your walking speed (16 - 100)",
    Icon = "activity",
    Value = {
        Min = 16,
        Max = 100,
        Default = 16,
    },
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end
})

----------------------------------------------------------
-- 🔹 NOCLIP
----------------------------------------------------------
local noclip = false
local noclipConnection

UtilityTab:Toggle({
    Title = "Noclip",
    Description = "Toggle wall collision on/off",
    Icon = "box",
    Default = false,
    Callback = function(state)
        noclip = state
        local char = game.Players.LocalPlayer.Character
        if not char then return end

        if noclip then
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

----------------------------------------------------------
-- 🔹 INFINITE JUMP
----------------------------------------------------------
local infiniteJump = false
local userInputService = game:GetService("UserInputService")

UtilityTab:Toggle({
    Title = "Infinite Jump",
    Description = "Jump infinitely while in the air",
    Icon = "arrow-up",
    Default = false,
    Callback = function(state)
        infiniteJump = state
    end
})

userInputService.JumpRequest:Connect(function()
    if infiniteJump then
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

----------------------------------------------------------
-- 🔹 FPS BOOST
----------------------------------------------------------
UtilityTab:Button({
    Title = "FPS Boost",
    Description = "Optimize game for better performance",
    Icon = "gauge",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            elseif v:IsA("Explosion") then
                v.BlastPressure = 0
                v.BlastRadius = 0
            end
        end

        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 1e10
        lighting.Brightness = 1
        lighting.EnvironmentDiffuseScale = 0
        lighting.EnvironmentSpecularScale = 0

        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        end

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end

        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        WindUI:Notify({
            Title = "✅ FPS Boost",
            Content = "Game performance optimized successfully!",
            Duration = 3,
            Icon = "gauge"
        })
    end
})

----------------------------------------------------------
-- 🔹 INFORMATION TAB — Discord Button
----------------------------------------------------------
local InfoTab = Window:Tab({
    Title = "Information",
    Icon = "info",
    Locked = false,
})

local InfoSection = InfoTab:Section({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Opened = true
})

InfoSection:Button({
    Title = "🌐 Discord Server",
    Description = "Click to copy invite link (Discord.gg/Eg98P4wf2V)",
    Icon = "discord",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.gg/Eg98P4wf2V")
        end)
        WindUI:Notify({
            Title = "✅ Copied",
            Content = "Discord invite copied to clipboard!",
            Duration = 3,
            Icon = "copy"
        })
    end
})
