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
    Icon = "wallet",
    Locked = false,
})

local UtilityTab = Window:Tab({
    Title = "Utility",
    Icon = "wrench",
    Locked = false,
})

----------------------------------------------------------
-- 🔹 MAIN TAB — Claim Money
----------------------------------------------------------
local moneyAmount = 0

MainTab:Input({
    Title = "Enter Amount",
    Description = "Enter the amount of money to claim",
    Placeholder = "Example: 100",
    Numeric = true,
    Callback = function(value)
        moneyAmount = tonumber(value) or 0
    end
})

MainTab:Button({
    Title = "Claim Money",
    Description = "Send a server request with your amount",
    Icon = "dollar-sign",
    Callback = function()
        if moneyAmount <= 0 then
            warn("⚠️ Please enter a valid amount first!")
            return
        end
        local args = {
            "Money",
            moneyAmount
        }
        game:GetService("ReplicatedStorage"):WaitForChild("ClaimReward"):FireServer(unpack(args))
        print("💰 Claimed Money:", moneyAmount)
    end
})

----------------------------------------------------------
-- 🔹 UTILITY TAB — WalkSpeed
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
-- 🔹 UTILITY TAB — Noclip
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
-- 🔹 UTILITY TAB — Infinite Jump
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
-- 🔹 UTILITY TAB — FPS Boost
----------------------------------------------------------
UtilityTab:Button({
    Title = "FPS Boost",
    Description = "Optimize game for better performance",
    Callback = function()
        -- Lower graphic settings and remove unnecessary effects
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            elseif v:IsA("Explosion") then
                v.BlastPressure = 0
                v.BlastRadius = 0
            elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end

        -- Lighting optimization
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 1e10
        lighting.Brightness = 1
        lighting.EnvironmentDiffuseScale = 0
        lighting.EnvironmentSpecularScale = 0

        -- Reduce terrain details
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        end

        -- Remove textures
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end

        -- Lower render settings
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

        print("✅ FPS Boost applied! Game performance optimized.")
    end
})

----------------------------------------------------------
-- 🔹 INFORMATION TAB — NovaAxis Hub
----------------------------------------------------------
local InfoTab = Window:Tab({
    Title = "Information",
    Icon = "info",
    EnableScrolling = true
})

local InfoSection = InfoTab:Section({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Opened = true
})

InfoSection:Paragraph({
    Title = "About",
    Content = "NovaAxis Hub — WindUI rewrite v4.8\nGame: Steal A Femboy\nAuthor: NovaAxis"
})

InfoSection:Button({
    Title = "🌐 Discord Server",
    Desc = "Copy Discord invite to clipboard",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.gg/Eg98P4wf2V")
        end)

        -- Уведомление WindUI
        WindUI:Notify({
            Title = "✅ Copied",
            Content = "Discord invite copied to clipboard!",
            Duration = 3,
            Icon = "copy"
        })
    end
})

