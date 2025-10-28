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
    Callback = function()
        local player = game.Players.LocalPlayer
        if player then
            local nickname = player.Name
            setclipboard(nickname)
            print("Nickname copied " .. nickname)
            
            WindUI:Notify({
                Title = "👤 Nickname Copied",
                Content = "Your Username '" .. nickname .. "' has been copied to the clipboard.",
                Duration = 3,
                Icon = "user",
            })
        else
            warn("Player not found.")
        end
    end,
}
})

-- Customize open button
Window:EditOpenButton({
    Title = "💫 NovaAxis",
    Icon = "sparkles",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("260534"), 
        Color3.fromHex("12394a")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

WindUI:AddTheme({
    Name = "Nova Neon",
    
    Accent = WindUI:Gradient({                                                  
        ["0"]   = { Color = Color3.fromHex("#beb4ff"), Transparency = 0 },  -- Soft lavender start
        ["100"] = { Color = Color3.fromHex("#7c3aed"), Transparency = 0 },  -- Vibrant violet end
    }, {                                                                        
        Rotation = 90,                                                         -- Vertical gradient
    }),                                                                         
    Dialog = Color3.fromHex("#121214"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#e6e6e6"),
    Placeholder = Color3.fromHex("#82828c"),
    Background = Color3.fromHex("#08080a"),
    Button = Color3.fromHex("#32283c"),
    Icon = Color3.fromHex("#beb4ff")
})

WindUI:SetTheme("Nova Neon")

Window:SetToggleKey(Enum.KeyCode.RightShift)

-- Tabs
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "house",
    Locked = false,
})

local LocalPlayerTab = Window:Tab({
    Title = "Local Player",
    Icon = "user",
    Locked = false,
})

local LocalPlayerSection = LocalPlayerTab:Section({
    Title = "Local Player",
    Icon = "user",
    Opened = true
})

-- WalkSpeed
LocalPlayerTab:Slider({
    Title = "WalkSpeed",
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

LocalPlayerTab:Toggle({
    Title = "Noclip",
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

LocalPlayerTab:Toggle({
    Title = "Infinite Jump",
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
LocalPlayerTab:Button({
    Title = "FPS Boost",
    Desc = "Makes bad graphics to increase fps",
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
-- 🔹 INFORMATION TAB
----------------------------------------------------------
local InfoTab = Window:Tab({
    Title = "Information",
    Icon = "info",
    Locked = false,
})

local InfoSection = InfoTab:Section({
    Title = "Discord Server (NovaAxis Hub)",
    Icon = "globe",
    Opened = true
})

InfoSection:Button({
    Title = "🌐 Discord NovaAxis Hub",
    Desc = "Click to copy invite link",
    Icon = "globe",
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

local InfoSection = InfoTab:Section({
    Title = "UI Library (Author)",
    Icon = "palette",
    Opened = true
})

InfoSection:Button({
    Title = "🎨 GitHub Author",
    Desc = "Click to copy GitHub author link",
    Icon = "palette",
    Callback = function()
        pcall(function()
            setclipboard("https://github.com/Footagesus")
        end)
        WindUI:Notify({
            Title = "✅ Copied",
            Content = "GitHub avtor link copied to clipboard!",
            Duration = 3,
            Icon = "copy"
        })
    end
})
