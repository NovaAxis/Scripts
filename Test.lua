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

-- theme gradients
WindUI:AddTheme({
    Name = "Nova Neon", -- theme name
    
    Accent = WindUI:Gradient({                                                  
        ["0"] = { Color = Color3.fromHex("#260534"), Transparency = 0 },        
        ["100"]   = { Color = Color3.fromHex("#12394a"), Transparency = 0 },    
    }, {                                                                        
        Rotation = 0,                                                           
    }),                                                                         
    Dialog = Color3.fromHex("#121214"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#e6e6e6"),
    Placeholder = Color3.fromHex("#82828c"),
    Background = Color3.fromHex("#08080a"),
    Button = Color3.fromHex("#32283c"),
    Icon = Color3.fromHex("#beb4ff")
})

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

-- WalkSpeed
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

-- Noclip
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

-- Infinite Jump
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

-- FPS Boost
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
-- 🔹 INFORMATION TAB — Discord Button Only
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
