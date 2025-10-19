-- ============================
-- 💫 NovaAxis — Auto Collect + Auto Lock + Utility Hub + Info Tab
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

----------------------------------------------------------
-- 🔹 TABS
----------------------------------------------------------
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

local InfoTab = Window:Tab({
    Title = "Information",
    Icon = "info",
    Locked = false,
})

----------------------------------------------------------
-- 🔹 VARIABLES
----------------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local baseFolder = workspace:WaitForChild("Player Bases")

----------------------------------------------------------
-- 🔹 AUTO COLLECT
----------------------------------------------------------
local autoCollect = false
local collectDelay = 10
local autoCollectThread

local function collectAllSlots()
    local playerBase = baseFolder:FindFirstChild(player.Name .. "'s Base")
    if not playerBase then return end
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
        if state then
            WindUI:Notify({
                Title = "✅ Auto Collect Enabled",
                Content = "Collecting every " .. collectDelay .. " seconds.",
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
            autoCollect = false
            WindUI:Notify({
                Title = "⛔ Auto Collect Disabled",
                Content = "Stopped collecting.",
                Duration = 3,
                Icon = "x"
            })
        end
    end
})

MainTab:Slider({
    Title = "Auto Collect Delay",
    Description = "Delay between collections (10–30 sec)",
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
            Content = "Now collecting every " .. value .. " seconds.",
            Duration = 2,
            Icon = "clock"
        })
    end
})

MainTab:Button({
    Title = "Collect Once",
    Description = "Instantly collects all slots one time",
    Icon = "zap",
    Callback = function()
        collectAllSlots()
        WindUI:Notify({
            Title = "⚡ Collected",
            Content = "All slots collected successfully!",
            Duration = 2,
            Icon = "check"
        })
    end
})

Tab:Divider()

----------------------------------------------------------
-- 🔹 AUTO LOCK BASE
----------------------------------------------------------
local autoLock = false
local lockDelay = 60
local autoLockThread

local function lockBase()
    local playerBase = baseFolder:FindFirstChild(player.Name .. "'s Base")
    if not playerBase then return end
    local floor1 = playerBase:FindFirstChild("Floor1")
    if not floor1 then return end
    local locker = floor1:FindFirstChild("Locker")
    if not locker then return end

    local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Base:Lock")
    remote:FireServer(locker)
end

MainTab:Toggle({
    Title = "Auto Lock Base",
    Description = "Automatically locks your base",
    Icon = "lock",
    Default = false,
    Callback = function(state)
        autoLock = state
        if state then
            WindUI:Notify({
                Title = "🔒 Auto Lock Enabled",
                Content = "Locking every " .. lockDelay .. " seconds.",
                Duration = 3,
                Icon = "lock"
            })
            autoLockThread = task.spawn(function()
                while autoLock do
                    lockBase()
                    task.wait(lockDelay)
                end
            end)
        else
            autoLock = false
            WindUI:Notify({
                Title = "🔓 Auto Lock Disabled",
                Content = "Stopped auto-locking.",
                Duration = 3,
                Icon = "unlock"
            })
        end
    end
})

MainTab:Slider({
    Title = "Auto Lock Delay",
    Description = "Time between locking base (60–160 sec)",
    Icon = "timer",
    Value = {
        Min = 60,
        Max = 160,
        Default = 60,
    },
    Callback = function(value)
        lockDelay = value
        WindUI:Notify({
            Title = "🕒 Lock Delay Updated",
            Content = "Now locking every " .. value .. " seconds.",
            Duration = 2,
            Icon = "clock"
        })
    end
})

MainTab:Button({
    Title = "Lock Base Now",
    Description = "Manually lock your base instantly",
    Icon = "shield",
    Callback = function()
        lockBase()
        WindUI:Notify({
            Title = "🔐 Base Locked",
            Content = "Your base has been locked manually!",
            Duration = 2,
            Icon = "check"
        })
    end
})

----------------------------------------------------------
-- 🔹 UTILITY FEATURES
----------------------------------------------------------
UtilityTab:Slider({
    Title = "WalkSpeed", 
    Description = "Adjust walk speed (16–100)",
    Icon = "activity",
    Value = { Min = 16, Max = 100, Default = 16 },
    Callback = function(value)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})

local noclip = false
local noclipConnection
UtilityTab:Toggle({
    Title = "Noclip",
    Description = "Toggle wall collision on/off",
    Icon = "box",
    Default = false,
    Callback = function(state)
        noclip = state
        local char = player.Character
        if not char then return end
        if state then
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
})

local infiniteJump = false
local UIS = game:GetService("UserInputService")
UtilityTab:Toggle({
    Title = "Infinite Jump",
    Description = "Jump infinitely while in air",
    Icon = "arrow-up",
    Default = false,
    Callback = function(state)
        infiniteJump = state
    end
})
UIS.JumpRequest:Connect(function()
    if infiniteJump then
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

UtilityTab:Button({
    Title = "FPS Boost",
    Description = "Optimize game performance",
    Icon = "gauge",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end

        WindUI:Notify({
            Title = "✅ FPS Boost",
            Content = "Game performance improved!",
            Duration = 3,
            Icon = "gauge"
        })
    end
})

----------------------------------------------------------
-- 🔹 INFORMATION TAB — Discord Button
----------------------------------------------------------
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
