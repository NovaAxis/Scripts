--[[
    💫 NovaAxis Hub - Steal A Femboy
    
    Author: NovaAxis
    Version: 4.5
    
    Press Left Alt to open / close
]]

local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();

-- Services
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Player
local player = Players.LocalPlayer

-- Target Names
local TARGET_NAMES = {
    ["Roommate"] = true,
    ["Casual Astolfo"] = true,
    ["Chihiro Fujisaki"] = true,
    ["Venti"] = true,
    ["Gasper"] = true,
    ["Saika"] = true,   
    ["J*b Application"] = true,
    ["Mythical Lucky Block"] = true,
    ["Nagisa Shiota"] = true,
    ["Felix"] = true,
    ["Rimuru"] = true,
}

-- State
local isRunning = false
local autoStealEnabled = false
local autoStealDelay = 5
local promptTimeout = 5

-- Create Notification
local Notifier = Compkiller.newNotify();

-- Create Config Manager
local ConfigManager = Compkiller:ConfigManager({
    Directory = "NovaAxis-FemboySteal",
    Config = "Default-Config"
});

-- Loading UI
Compkiller:Loader("rbxassetid://7733960981", 2.5).yield();

-- Creating Window
local Window = Compkiller.new({
    Name = "💫 NovaAxis Hub",
    Keybind = "LeftAlt",
    Logo = "rbxassetid://7733960981",
    Scale = Compkiller.Scale.Window,
    TextSize = 15,
});

-- Welcome Notification
Notifier.new({
    Title = "💫 NovaAxis Hub",
    Content = "Successfully loaded for Steal A Femboy!",
    Duration = 5,
    Icon = "rbxassetid://7733960981"
});

-- Watermark
local Watermark = Window:Watermark();

Watermark:AddText({
    Icon = "user",
    Text = "NovaAxis",
});

Watermark:AddText({
    Icon = "clock",
    Text = Compkiller:GetDate(),
});

local Time = Watermark:AddText({
    Icon = "timer",
    Text = "TIME",
});

task.spawn(function()
    while true do task.wait()
        Time:SetText(Compkiller:GetTimeNow());
    end
end)

Watermark:AddText({
    Icon = "activity",
    Text = "v4.5",
});

-- Utility Functions
local function SetupKickProtection()
    local mt = getrawmetatable(game)
    if not mt then return end
    
    local oldNamecall = mt.__namecall
    
    if setreadonly then
        setreadonly(mt, false)
    end
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" then
            return nil
        end
        return oldNamecall(self, ...)
    end)
end

local function DisconnectAllConnections(object, signalName)
    if not object then return end
    local signal = object[signalName]
    if not signal then return end
    
    local connections = getconnections(signal)
    if connections then
        for _, conn in pairs(connections) do
            if conn and type(conn.Disconnect) == "function" then
                conn:Disconnect()
            end
        end
    end
end

local function ExecuteBypass()
    SetupKickProtection()
    
    repeat task.wait() until player
    repeat task.wait() until player.Character
    
    local character = player.Character
    
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            DisconnectAllConnections(humanoid, "StateChanged")
            DisconnectAllConnections(humanoid, "Changed")
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            DisconnectAllConnections(rootPart, "ChildAdded")
        end
        
        DisconnectAllConnections(character, "ChildRemoved")
    end
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        DisconnectAllConnections(backpack, "ChildAdded")
    end
    
    local camera = workspace.CurrentCamera
    if camera then
        DisconnectAllConnections(camera, "ChildAdded")
    end
    
    local antiScript = script.Parent and script.Parent:FindFirstChild("Anti")
    if antiScript then
        antiScript.Disabled = true
        antiScript:Destroy()
    end
    
    task.spawn(function()
        while task.wait(5) do
            local newAnti = script.Parent and script.Parent:FindFirstChild("Anti")
            if newAnti then
                newAnti.Disabled = true
                newAnti:Destroy()
            end
            
            if character and character.Parent then
                local currentHumanoid = character:FindFirstChild("Humanoid")
                if currentHumanoid then
                    DisconnectAllConnections(currentHumanoid, "StateChanged")
                end
            end
        end
    end)
end

local function SafeExecute()
    local success, error = pcall(ExecuteBypass)
    if not success then
        local mt = getrawmetatable(game)
        if mt then
            local old = mt.__namecall
            if setreadonly then setreadonly(mt, false) end
            mt.__namecall = function(self, ...)
                if getnamecallmethod() == "Kick" then return nil end
                return old(self, ...)
            end
        end
        Notifier.new({
            Title = "⚠️ Warning",
            Content = "Bypass partial failure, kick protection enabled",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        });
    else
        Notifier.new({
            Title = "🛡️ Success",
            Content = "Anti-Cheat bypassed successfully!",
            Duration = 2,
            Icon = "rbxassetid://7733960981"
        });
    end
end

local function getAnyBasePart(model)
    if not model then return nil end
    if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then 
        return model.PrimaryPart 
    end
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then 
            return descendant 
        end
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
                            local modelName = model.Name
                            if modelName:lower():find("femboy") or TARGET_NAMES[modelName] then
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

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end

    pcall(function() 
        humanoidRootPart.Velocity = Vector3.zero 
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end)

    humanoidRootPart.CFrame = CFrame.new(position)
    RunService.Heartbeat:Wait()

    pcall(function() 
        humanoidRootPart.Velocity = Vector3.zero 
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end)

    return true
end

local function findProximityPromptInModel(rootModel, originPosition, maxDistance)
    local bestPrompt, bestDistance
    maxDistance = maxDistance or 20

    for _, descendant in ipairs(rootModel:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Enabled then
            local part = descendant.Parent
            if part and part:IsA("BasePart") then
                local distance = (part.Position - originPosition).Magnitude
                if distance <= maxDistance and (not bestDistance or distance < bestDistance) then
                    bestPrompt = descendant
                    bestDistance = distance
                end
            end
        end
    end
    return bestPrompt
end

local function activateProximityPromptWithTimeout(prompt, timeout)
    local success = false
    local errorMessage = nil
    
    local thread = task.spawn(function()
        local result, err = pcall(function()
            if prompt:IsA("ProximityPrompt") then
                prompt:InputHoldBegin()
                local holdDuration = prompt.HoldDuration or 0.5
                task.wait(holdDuration)
                prompt:InputHoldEnd()
                
                local remoteEvent = prompt:FindFirstChildOfClass("RemoteEvent")
                if remoteEvent then
                    remoteEvent:FireServer()
                end
                success = true
            else
                error("Object is not a ProximityPrompt")
            end
        end)
        
        if not result then
            errorMessage = err
        end
    end)
    
    local startTime = tick()
    while not success and (tick() - startTime) < timeout do
        task.wait(0.1)
    end
    
    if not success then
        return false, "Timeout: Prompt not activated in " .. timeout .. " seconds"
    end
    
    return success, errorMessage
end

local function executeInstantSteal()
    if isRunning then
        Notifier.new({
            Title = "⚠️ Warning",
            Content = "Already running!",
            Duration = 2,
            Icon = "rbxassetid://7733964719"
        });
        return
    end

    isRunning = true

    local character = player.Character
    if not character then
        Notifier.new({
            Title = "❌ Error",
            Content = "Character not found!",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        });
        isRunning = false
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not humanoidRootPart then
        Notifier.new({
            Title = "❌ Error",
            Content = "Humanoid/HRP not found!",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        });
        isRunning = false
        return
    end

    local playerBase = findPlayerBase()
    if not playerBase then
        Notifier.new({
            Title = "❌ Error",
            Content = "Your base not found!",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        });
        isRunning = false
        return
    end

    local targetModel, targetBase = findTargetFemboy(playerBase)
    if not targetModel then
        Notifier.new({
            Title = "❌ Error",
            Content = "Target not found!",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        });
        isRunning = false
        return
    end

    local targetPart = getAnyBasePart(targetModel)
    if not targetPart then
        Notifier.new({
            Title = "❌ Error",
            Content = "Could not find target part",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        });
        isRunning = false
        return
    end

    local targetPosition = targetPart.Position + Vector3.new(0, 3, 0)

    local savedWalkSpeed = humanoid.WalkSpeed
    local savedJumpPower = humanoid.JumpPower
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    Notifier.new({
        Title = "✨ Info",
        Content = "Teleporting to target...",
        Duration = 2,
        Icon = "rbxassetid://7733960981"
    });

    if not teleportCharacterToPosition(targetPosition) then
        Notifier.new({
            Title = "❌ Error",
            Content = "Teleportation failed!",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        });
        humanoid.WalkSpeed = savedWalkSpeed
        humanoid.JumpPower = savedJumpPower
        isRunning = false
        return
    end

    task.wait(0.3)

    local prompt = findProximityPromptInModel(targetBase or targetModel, targetPosition, 25)

    local promptActivated = false
    if prompt then
        Notifier.new({
            Title = "⏳ Info",
            Content = "Activating prompt... (" .. promptTimeout .. "s timeout)",
            Duration = 2,
            Icon = "rbxassetid://7733960981"
        });
        
        local success, errorMessage = activateProximityPromptWithTimeout(prompt, promptTimeout)
        
        if success then
            promptActivated = true
            Notifier.new({
                Title = "✅ Success",
                Content = "Prompt activated!",
                Duration = 2,
                Icon = "rbxassetid://7733960981"
            });
            task.wait(1)
        else
            Notifier.new({
                Title = "⚠️ Warning",
                Content = errorMessage or "Prompt timeout!",
                Duration = 3,
                Icon = "rbxassetid://7733964719"
            });
        end
    else
        Notifier.new({
            Title = "⚠️ Warning",
            Content = "Prompt not found!",
            Duration = 2,
            Icon = "rbxassetid://7733964719"
        });
    end

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
            Notifier.new({
                Title = "🏠 Info",
                Content = "Returning to base...",
                Duration = 2,
                Icon = "rbxassetid://7733960981"
            });
            teleportCharacterToPosition(spawnPosition + Vector3.new(0, 3, 0))
            task.wait(0.3)
            Notifier.new({
                Title = "✅ Success",
                Content = "Returned successfully!",
                Duration = 2,
                Icon = "rbxassetid://7733960981"
            });
        end
    end

    humanoid.WalkSpeed = savedWalkSpeed
    humanoid.JumpPower = savedJumpPower
    isRunning = false
end

-- Creating Main Category
Window:DrawCategory({
    Name = "🌸 Femboy Stealer"
});

-- Main Tab
local MainTab = Window:DrawTab({
    Name = "Main Features",
    Icon = "target",
    EnableScrolling = true
});

-- Steal Section (Left)
local StealSection = MainTab:DrawSection({
    Name = "⚡ Instant Steal",
    Position = 'left'
});

StealSection:AddButton({
    Name = "⚡ Execute Instant Steal",
    Callback = function()
        task.spawn(function()
            local success, errorMessage = pcall(executeInstantSteal)
            if not success then
                Notifier.new({
                    Title = "❌ Error",
                    Content = "Error: " .. tostring(errorMessage),
                    Duration = 3,
                    Icon = "rbxassetid://7733964719"
                });
            end
        end)
    end
});

StealSection:AddParagraph({
    Title = "ℹ️ How it works",
    Content = "Teleports to Femboys etc., steals them and automatically returns to your base."
});

-- Bypass Section (Left)
local BypassSection = MainTab:DrawSection({
    Name = "🛡️ Anti-Cheat Bypass",
    Position = 'left'
});

BypassSection:AddButton({
    Name = "🛡️ Activate Bypass",
    Callback = function()
        SafeExecute()
    end
});

BypassSection:AddParagraph({
    Title = "⚠️ Important",
    Content = "Run it if you have problems with kicks and detection."
});

-- Auto Steal Section (Left)
local AutoSection = MainTab:DrawSection({
    Name = "🔄 Auto Steal",
    Position = 'left'
});

local AutoToggle = AutoSection:AddToggle({
    Name = "Enable Auto Steal",
    Flag = "AutoSteal",
    Default = false,
    Callback = function(value)
        autoStealEnabled = value
        if value then
            Notifier.new({
                Title = "✅ Auto Steal",
                Content = "Auto Steal Enabled!",
                Duration = 2,
                Icon = "rbxassetid://7733960981"
            });
            
            task.spawn(function()
                while autoStealEnabled do
                    if not isRunning then
                        executeInstantSteal()
                    end
                    task.wait(autoStealDelay)
                end
            end)
        else
            Notifier.new({
                Title = "❌ Auto Steal",
                Content = "Auto Steal Disabled!",
                Duration = 2,
                Icon = "rbxassetid://7733964719"
            });
        end
    end
});

AutoSection:AddSlider({
    Name = "Auto Steal Delay (seconds)",
    Min = 1,
    Max = 60,
    Default = 5,
    Round = 0,
    Flag = "AutoStealDelay",
    Callback = function(value)
        autoStealDelay = value
    end
});

-- Settings Section (Right)
local SettingsSection = MainTab:DrawSection({
    Name = "⚙️ Settings",
    Position = 'right'
});

SettingsSection:AddKeybind({
    Name = "Quick Steal Hotkey",
    Default = "F",
    Flag = "QuickStealKey",
    Callback = function(key)
        executeInstantSteal()
    end
});

SettingsSection:AddSlider({
    Name = "Prompt Timeout (seconds)",
    Min = 1,
    Max = 10,
    Default = 5,
    Round = 0,
    Flag = "PromptTimeout",
    Callback = function(value)
        promptTimeout = value
        Notifier.new({
            Title = "⚙️ Settings",
            Content = "Timeout set to " .. value .. "s",
            Duration = 2,
            Icon = "rbxassetid://7733960981"
        });
    end
});

-- Target Info Section (Right)
local TargetSection = MainTab:DrawSection({
    Name = "🎯 Target List",
    Position = 'right'
});

TargetSection:AddParagraph({
    Title = "🎯 Targets",
    Content = "• Any name with 'femboy'\n• Roommate\n• Casual Astolfo\n• Chihiro Fujisaki\n• Venti\n• Gasper\n• Saika\n• J*b Application\n• Mythical Lucky Block\n• Nagisa Shiota\n• Felix\n• Rimuru"
});

-- Info Section (Right)
local InfoSection = MainTab:DrawSection({
    Name = "ℹ️ Information",
    Position = 'right'
});

InfoSection:AddParagraph({
    Title = "💫 NovaAxis Hub",
    Content = "Version: 4.5\nGame: Steal A Femboy\nCreated by: NovaAxis"
});

InfoSection:AddButton({
    Name = "📋 Copy GitHub",
    Callback = function()
        setclipboard("github.com/NovaAxis")
        Notifier.new({
            Title = "✅ Copied",
            Content = "GitHub link copied to clipboard!",
            Duration = 3,
            Icon = "rbxassetid://7733960981"
        });
    end
});

-- Misc Category
Window:DrawCategory({
    Name = "⚙️ Settings"
});

-- UI Settings Tab
local SettingTab = Window:DrawTab({
    Icon = "settings",
    Name = "UI Settings",
    Type = "Single",
    EnableScrolling = true
});

local UISettings = SettingTab:DrawSection({
    Name = "🎨 UI Customization",
});

UISettings:AddToggle({
    Name = "Always Show Frame",
    Default = false,
    Flag = "AlwaysShowFrame",
    Callback = function(v)
        Window.AlwayShowTab = v;
    end,
});

UISettings:AddColorPicker({
    Name = "Highlight Color",
    Default = Compkiller.Colors.Highlight,
    Flag = "HighlightColor",
    Callback = function(v)
        Compkiller.Colors.Highlight = v;
        Compkiller:RefreshCurrentColor();
    end,
});

UISettings:AddColorPicker({
    Name = "Toggle Color",
    Default = Compkiller.Colors.Toggle,
    Flag = "ToggleColor",
    Callback = function(v)
        Compkiller.Colors.Toggle = v;
        Compkiller:RefreshCurrentColor(v);
    end,
});

UISettings:AddButton({
    Name = "Get Theme",
    Callback = function()
        print(Compkiller:GetTheme())
        
        Notifier.new({
            Title = "✅ Theme Copied",
            Content = "Theme color copied to clipboard!",
            Duration = 5,
            Icon = "rbxassetid://7733960981"
        });
    end,
});

-- Theme Tab
local ThemeTab = Window:DrawTab({
    Icon = "paintbrush",
    Name = "Themes",
    Type = "Single"
});

ThemeTab:DrawSection({
    Name = "🎨 UI Themes"
}):AddDropdown({
    Name = "Select Theme",
    Default = "Default",
    Flag = "Theme",
    Values = {
        "Default",
        "Dark Green",
        "Dark Blue",
        "Purple Rose",
        "Skeet"
    },
    Callback = function(v)
        Compkiller:SetTheme(v)
    end,
})

-- Config Tab
local ConfigUI = Window:DrawConfig({
    Name = "Config",
    Icon = "folder",
    Config = ConfigManager
});

ConfigUI:Init();

-- Initialization
print("✅ NovaAxis Hub loaded successfully!")
print("⌨️ Press Left Alt to toggle UI")
print("🌸 Game: Steal A Femboy")
