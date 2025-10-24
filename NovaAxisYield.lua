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
        Color3.fromHex("260534"), 
        Color3.fromHex("12394a")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- theme gradients
WindUI:AddTheme({
    Name = "Nova Neon",
    
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

local AdminTab = Window:Tab({
    Title = "Admin",
    Icon = "shield",
    Locked = false,
})

----------------------------------------------------------
-- MAIN TAB - Infinite Yield Integration
----------------------------------------------------------
local MainSection = MainTab:Section({
    Title = "🎮 Admin Commands",
    Icon = "terminal",
    Opened = true
})

MainSection:Button({
    Title = "Load Infinite Yield",
    Description = "Execute Infinite Yield admin commands",
    Icon = "command",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua'))()
        WindUI:Notify({
            Title = "✅ Infinite Yield",
            Content = "Admin commands loaded successfully!",
            Duration = 3,
            Icon = "check-circle"
        })
    end
})

----------------------------------------------------------
-- UTILITY TAB
----------------------------------------------------------
local MovementSection = UtilityTab:Section({
    Title = "⚡ Movement",
    Icon = "zap",
    Opened = true
})

-- WalkSpeed
MovementSection:Slider({
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

-- JumpPower
MovementSection:Slider({
    Title = "JumpPower", 
    Description = "Adjust your jump height (50 - 200)",
    Icon = "arrow-up-circle",
    Value = {
        Min = 50,
        Max = 200,
        Default = 50,
    },
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = value
        end
    end
})

-- Noclip
local noclip = false
local noclipConnection

MovementSection:Toggle({
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

MovementSection:Toggle({
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

-- Fly
local flying = false
local flySpeed = 50
local flyConnection

local function enableFly()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    
    local bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = hrp.CFrame
    bg.Parent = hrp
    
    local bv = Instance.new("BodyVelocity")
    bv.velocity = Vector3.new(0, 0, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp
    
    flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not flying then return end
        
        local cam = workspace.CurrentCamera
        local moveDirection = Vector3.new()
        
        if userInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + cam.CFrame.LookVector
        end
        if userInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - cam.CFrame.LookVector
        end
        if userInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - cam.CFrame.RightVector
        end
        if userInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + cam.CFrame.RightVector
        end
        
        bv.velocity = moveDirection * flySpeed
        bg.cframe = cam.CFrame
    end)
end

local function disableFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    for _, v in pairs(hrp:GetChildren()) do
        if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
            v:Destroy()
        end
    end
end

MovementSection:Toggle({
    Title = "Fly",
    Description = "Fly around the map (WASD to move)",
    Icon = "plane",
    Default = false,
    Callback = function(state)
        flying = state
        if flying then
            enableFly()
        else
            disableFly()
        end
    end
})

MovementSection:Slider({
    Title = "Fly Speed", 
    Description = "Adjust flying speed",
    Icon = "gauge",
    Value = {
        Min = 10,
        Max = 150,
        Default = 50,
    },
    Callback = function(value)
        flySpeed = value
    end
})

-- Performance Section
local PerformanceSection = UtilityTab:Section({
    Title = "🚀 Performance",
    Icon = "cpu",
    Opened = true
})

-- FPS Boost
PerformanceSection:Button({
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

-- Anti-AFK
local antiAFK = false
PerformanceSection:Toggle({
    Title = "Anti-AFK",
    Description = "Prevent being kicked for inactivity",
    Icon = "clock",
    Default = false,
    Callback = function(state)
        antiAFK = state
        if antiAFK then
            local vu = game:GetService("VirtualUser")
            game:GetService("Players").LocalPlayer.Idled:Connect(function()
                if antiAFK then
                    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    wait(1)
                    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end)
            WindUI:Notify({
                Title = "✅ Anti-AFK",
                Content = "Anti-AFK enabled!",
                Duration = 2,
                Icon = "clock"
            })
        end
    end
})

----------------------------------------------------------
-- ADMIN TAB
----------------------------------------------------------
local QuickCommandsSection = AdminTab:Section({
    Title = "⚡ Quick Commands",
    Icon = "zap",
    Opened = true
})

QuickCommandsSection:Button({
    Title = "Reset Character",
    Description = "Respawn your character",
    Icon = "refresh-cw",
    Callback = function()
        game.Players.LocalPlayer.Character:BreakJoints()
    end
})

QuickCommandsSection:Button({
    Title = "God Mode",
    Description = "Remove Humanoid (may break some features)",
    Icon = "shield",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:Destroy()
            WindUI:Notify({
                Title = "✅ God Mode",
                Content = "Humanoid removed!",
                Duration = 3,
                Icon = "shield"
            })
        end
    end
})

QuickCommandsSection:Button({
    Title = "Remove Fog",
    Description = "Clear all fog effects",
    Icon = "eye",
    Callback = function()
        local lighting = game:GetService("Lighting")
        lighting.FogEnd = 1e10
        WindUI:Notify({
            Title = "✅ Fog Removed",
            Content = "Fog cleared successfully!",
            Duration = 2,
            Icon = "eye"
        })
    end
})

QuickCommandsSection:Button({
    Title = "FullBright",
    Description = "Maximum brightness",
    Icon = "sun",
    Callback = function()
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.FogEnd = 1e10
        lighting.GlobalShadows = false
        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        WindUI:Notify({
            Title = "✅ FullBright",
            Content = "Maximum brightness enabled!",
            Duration = 2,
            Icon = "sun"
        })
    end
})

----------------------------------------------------------
-- INFORMATION TAB
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
    Icon = "message-circle",
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

InfoSection:Paragraph({
    Title = "ℹ️ About",
    Description = [[NovaAxis Hub - Universal script hub with admin commands

Features:
• Infinite Yield integration
• Movement controls
• Performance optimization
• Quick admin commands

Press F9 to open console for IY commands after loading.]]
})
