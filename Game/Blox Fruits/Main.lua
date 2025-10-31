-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Global variables

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

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
        Color3.fromHex("beb4ff"), 
        Color3.fromHex("7c3aed")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

WindUI:AddTheme({
    Name = "Nova Neon",
    
    Accent = WindUI:Gradient({                                                  
        ["0"]   = { Color = Color3.fromHex("#beb4ff"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#7c3aed"), Transparency = 0 },
    }, {                                                                        
        Rotation = 90,
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

-- Server Join Tab
local ServerTab = Window:Tab({
    Title = "Server Join",
    Icon = "server",
    Locked = false,
})

local ServerSection = ServerTab:Section({
    Title = "Server Hop",
    Icon = "server",
    Opened = true
})

ServerSection:Button({
    Title = "Rejoin Server",
    Desc = "Rejoin the current server",
    Icon = "share",
    Callback = function()
        WindUI:Notify({
            Title = "🔄 Rejoining...",
            Content = "Rejoining server in progress...",
            Duration = 3,
            Icon = "loader"
        })
        
        task.wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
    end
})

ServerSection:Button({
    Title = "Hop to Low-Pop Server",
    Desc = "Teleport to server with 1-4 players",
    Icon = "users",
    Callback = function()
        WindUI:Notify({
            Title = "🔍 Searching...",
            Content = "Looking for low-population server...",
            Duration = 2,
            Icon = "loader"
        })
        
        task.spawn(function()
            local placeId = game.PlaceId
            local currentJobId = game.JobId
            local found = false
            
            local success, result = pcall(function()
                local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
                
                for _, server in pairs(servers.data) do
                    if server.playing >= 1 and server.playing <= 4 and server.id ~= currentJobId then
                        WindUI:Notify({
                            Title = "✅ Server Found",
                            Content = "Found server with " .. server.playing .. " players!",
                            Duration = 2,
                            Icon = "check"
                        })
                        
                        task.wait(0.5)
                        TeleportService:TeleportToPlaceInstance(placeId, server.id, Player)
                        found = true
                        return
                    end
                end
            end)
            
            if not success then
                WindUI:Notify({
                    Title = "⚠️ Error",
                    Content = "Failed to search servers! Joining random server...",
                    Duration = 3,
                    Icon = "alert-triangle"
                })
            elseif not found then
                WindUI:Notify({
                    Title = "⚠️ No Server Found",
                    Content = "No low-pop servers available! Joining random server...",
                    Duration = 3,
                    Icon = "alert-triangle"
                })
            end
            
            task.wait(0.5)
            TeleportService:Teleport(placeId, Player)
        end)
    end
})

ServerSection:Button({
    Title = "Hop to Friends Server",
    Desc = "Teleport to server where your friends are",
    Icon = "users",
    Callback = function()
        WindUI:Notify({
            Title = "🔍 Searching...",
            Content = "Looking for server with friends...",
            Duration = 2,
            Icon = "loader"
        })
        
        task.spawn(function()
            local placeId = game.PlaceId
            local found = false
            
            local success, result = pcall(function()
                local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/VIP?sortOrder=Asc&limit=100"))
                
                for _, server in pairs(servers.data) do
                    if server.playing > 0 then
                        WindUI:Notify({
                            Title = "✅ Joining Friends Server",
                            Content = "Joining server with " .. server.playing .. " players!",
                            Duration = 2,
                            Icon = "check"
                        })
                        
                        task.wait(0.5)
                        TeleportService:TeleportToPlaceInstance(placeId, server.id, Player)
                        found = true
                        return
                    end
                end
            end)
            
            if not success then
                WindUI:Notify({
                    Title = "⚠️ Error",
                    Content = "Failed to search servers!",
                    Duration = 3,
                    Icon = "alert-triangle"
                })
            elseif not found then
                WindUI:Notify({
                    Title = "⚠️ No Server Found",
                    Content = "No friends servers available!",
                    Duration = 3,
                    Icon = "alert-triangle"
                })
            end
        end)
    end
})

-- Teleport Tab
local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "rocket",
    Locked = false,
})

local TeleportSection = TeleportTab:Section({
    Title = "Teleport",
    Icon = "rocket",
    Opened = true
})

local selectedIsland = nil
local tweenSpeed = 100
local isTeleporting = false
local currentTween = nil

local mapFolder = workspace:FindFirstChild("Map")
local islandNames = {}

if mapFolder then
    for _, item in pairs(mapFolder:GetChildren()) do
        if item:IsA("Model") then
            table.insert(islandNames, item.Name)
        end
    end
end

if #islandNames == 0 then
    islandNames = {"No islands available"}
end

local TeleportDropdown = TeleportSection:Dropdown({
    Title = "Islands",
    Desc = "Select island to teleport",
    Values = islandNames,
    Value = islandNames[1],
    Callback = function(option)
        selectedIsland = option
        print("Island selected: " .. option)
    end
})

TeleportSection:Slider({
    Title = "Tween Speed",
    Desc = "Adjust teleport speed",
    Step = 10,
    Value = {
        Min = 100,
        Max = 300,
        Default = 100
    },
    Callback = function(value)
        tweenSpeed = value
        print("Tween speed set to: " .. value)
    end
})

local TeleportToggle = TeleportSection:Toggle({
    Title = "Teleport to Island",
    Icon = "rocket",
    Default = false,
    Callback = function(state)
        isTeleporting = state

        local character = Player.Character
        if not character then
            TeleportToggle:Set(false)
            return
        end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            TeleportToggle:Set(false)
            return
        end

        if state then
            if not selectedIsland or selectedIsland == "No islands available" then
                WindUI:Notify({
                    Title = "⚠️ Error",
                    Content = "Please select a valid island first!",
                    Duration = 3,
                    Icon = "alert-triangle"
                })
                TeleportToggle:Set(false)
                return
            end

            local selectedModel = mapFolder:FindFirstChild(selectedIsland)
            if not selectedModel then
                WindUI:Notify({
                    Title = "⚠️ Error",
                    Content = "Island not found!",
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

            isTeleporting = true

            -- Поднимаем на +50Y сначала
            local liftPosition = humanoidRootPart.Position + Vector3.new(0, 50, 0)
            local liftTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local liftTween = TweenService:Create(humanoidRootPart, liftTweenInfo, {CFrame = CFrame.new(liftPosition)})
            liftTween:Play()
            liftTween.Completed:Wait()

            -- Двигаем к острову, сохраняя +50Y
            local finalPosition = Vector3.new(teleportPosition.X, teleportPosition.Y + 50, teleportPosition.Z)
            local distance = (finalPosition - humanoidRootPart.Position).Magnitude
            local duration = distance / tweenSpeed

            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
            currentTween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(finalPosition)})
            currentTween:Play()

            WindUI:Notify({
                Title = "🌀 Teleporting",
                Content = "Flying to " .. selectedIsland,
                Duration = 3,
                Icon = "send"
            })

            currentTween.Completed:Connect(function()
                WindUI:Notify({
                    Title = "✅ Arrived",
                    Content = "Successfully reached " .. selectedIsland,
                    Duration = 3,
                    Icon = "check"
                })
                TeleportToggle:Set(false) -- Авто-выключение
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
    end
})


local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "cog",
    Locked = false,
})

-- Local Player variables
local currentWalkSpeed = 52
local noclip = false
local noclipConnection
local infiniteJump = false
local userInputService = game:GetService("UserInputService")
local waterWalking = false
local waterWalkingPart
local waterWalkingConnection

-- WalkSpeed Bypass - keep WalkSpeed after respawn
Player.CharacterAdded:Connect(function(character)
    task.wait(0.1)
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = currentWalkSpeed
    end
end)

-- WalkSpeed Bypass via RunService (more reliable)
RunService.RenderStepped:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        if Player.Character.Humanoid.WalkSpeed ~= currentWalkSpeed then
            Player.Character.Humanoid.WalkSpeed = currentWalkSpeed
        end
    end
end)

-- Infinite Jump connection
userInputService.JumpRequest:Connect(function()
    if infiniteJump then
        if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

local LocalPlayerSection = MiscTab:Section({
    Title = "Local Player",
    Icon = "user",
    Opened = true
})

LocalPlayerSection:Slider({
    Title = "WalkSpeed",
    Icon = "activity",
    Value = {
        Min = 52,
        Max = 300,
        Default = 52,
    },
    Callback = function(value)
        currentWalkSpeed = value
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = value
        end
    end
})

LocalPlayerSection:Toggle({
    Title = "Noclip",
    Icon = "box",
    Default = false,
    Callback = function(state)
        noclip = state
        local char = Player.Character
        if not char then return end

        if noclip then
            noclipConnection = RunService.Stepped:Connect(function()
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
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
})

LocalPlayerSection:Toggle({
    Title = "Infinite Jump",
    Icon = "arrow-up",
    Default = false,
    Callback = function(state)
        infiniteJump = state
    end
})

LocalPlayerSection:Toggle({
    Title = "Walk On Water (Ice)",
    Icon = "droplet",
    Default = false,
    Callback = function(state)
        waterWalking = state
        
        if state then
            local char = workspace.Characters:FindFirstChild(Player.Name)
            if not char then
                char = Player.Character
            end
            
            if char and char:FindFirstChild("HumanoidRootPart") then
                waterWalkingPart = Instance.new("Part")
                waterWalkingPart.Name = "WaterWalkingPart"
                waterWalkingPart.Size = Vector3.new(10, 1, 10)
                waterWalkingPart.Material = Enum.Material.Ice
                waterWalkingPart.Transparency = 0.5
                waterWalkingPart.Anchored = true
                waterWalkingPart.CanCollide = false
                waterWalkingPart.Parent = workspace
                
                waterWalkingConnection = RunService.RenderStepped:Connect(function()
                    if waterWalking and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        local char = workspace.Characters:FindFirstChild(Player.Name) or Player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local rootPart = char.HumanoidRootPart
                            waterWalkingPart.CFrame = CFrame.new(rootPart.Position.X, rootPart.Position.Y - 4, rootPart.Position.Z)
                        end
                    end
                end)
                
                WindUI:Notify({
                    Title = "✅ Walk On Water ON",
                    Content = "You can now walk on water!",
                    Duration = 2,
                    Icon = "droplet"
                })
            end
        else
            if waterWalkingConnection then
                waterWalkingConnection:Disconnect()
                waterWalkingConnection = nil
            end
            if waterWalkingPart then
                waterWalkingPart:Destroy()
                waterWalkingPart = nil
            end
            
            WindUI:Notify({
                Title = "⏸️ Walk On Water OFF",
                Content = "Walk On Water disabled",
                Duration = 2,
                Icon = "droplet"
            })
        end
    end
})

LocalPlayerSection:Button({
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

local MiscSection = MiscTab:Section({
    Title = "Code",
    Icon = "gift",
    Opened = true
})

-- Centralized list of codes
local ALL_CODES = {
    "LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","NOMOREHACK","BANEXPLOIT","krazydares","TRIPLEABUSE","24NOADMIN","REWARDFUN","Chandler","NEWTROLL","KITT_RESET","Sub2CaptainMaui","kittgaming","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK","Starcodeheo","Bluxxy","fudd10_v2","SUB2GAMERROBOT_EXP1","Sub2NoobMaster123","Sub2UncleKizaru","Sub2Daigrock","Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie","Fudd10","Bignews","TheGreatAce","SECRET_ADMIN","SUB2GAMERROBOT_RESET1","SUB2OFFICIALNOOBIE","AXIORE","BIGNEWS","BLUXXY","CHANDLER","ENYU_IS_PRO","FUDD10","FUDD10_V2","KITTGAMING","MAGICBUS","STARCODEHEO","STRAWHATMAINE","SUB2CAPTAINMAUI","SUB2DAIGROCK","SUB2FER999","SUB2NOOBMASTER123","SUB2UNCLEKIZARU","TANTAIGAMING","THEGREATACE"
}

-- Services helper
local Services = {
    Network = {}
}

-- Find CommF remote
local function findCommF()
    local rs = game:GetService("ReplicatedStorage")
    local candidates = {"CommF_", "CommF", "Comm", "RemoteFunction", "RF"}
    
    for _, name in ipairs(candidates) do
        local remote = rs:FindFirstChild(name)
        if remote and remote:IsA("RemoteFunction") then
            return remote
        end
    end
    
    -- Deep search
    for _, inst in ipairs(rs:GetDescendants()) do
        if inst:IsA("RemoteFunction") then
            local name = inst.Name:lower()
            if name:find("comm") or name:find("remote") then
                return inst
            end
        end
    end
    
    return nil
end

-- Initialize CommF
local commF = findCommF()

function Services.Network.InvokeCommF(...)
    if commF then
        return commF:InvokeServer(...)
    end
    return false, "CommF not found"
end

-- Redeem code function
local function RedeemCode(code)
    local ok, res = pcall(function()
        return Services.Network.InvokeCommF("Redeem", code)
    end)
    return ok, res
end

local selectedCode = ALL_CODES[1]

local CodeDropdown = MiscSection:Dropdown({
    Title = "Code",
    Desc = "Select code to redeem",
    Values = ALL_CODES,
    Value = ALL_CODES[1],
    Callback = function(option) 
        selectedCode = option
        print("Code selected: " .. option)
        
        WindUI:Notify({
            Title = "✅ Code Selected",
            Content = "Code '" .. option .. "' is ready to redeem!",
            Duration = 2,
            Icon = "gift"
        })
    end
})

MiscSection:Button({
    Title = "Redeem Code",
    Icon = "gift",
    Callback = function()
        local ok, res = RedeemCode(selectedCode)
        
        if ok then
            WindUI:Notify({
                Title = "✅ Code Redeemed",
                Content = "Code '" .. selectedCode .. "' redeemed successfully!",
                Duration = 3,
                Icon = "check"
            })
        else
            WindUI:Notify({
                Title = "⚠️ Redeem Failed",
                Content = "Failed to redeem '" .. selectedCode .. "': " .. tostring(res),
                Duration = 3,
                Icon = "alert-triangle"
            })
        end
    end
})

-- Redeem all codes with one button
MiscSection:Button({
    Title = "Redeem All Codes",
    Desc = "Redeem all codes from the list",
    Icon = "gift",
    Callback = function()
        task.spawn(function()
            local total = #ALL_CODES
            local okCount, failCount = 0, 0
            
            WindUI:Notify({
                Title = "▶️ Redeeming...",
                Content = "Processing " .. tostring(total) .. " codes",
                Duration = 2,
                Icon = "loader"
            })
            
            for _, code in ipairs(ALL_CODES) do
                local ok, res = RedeemCode(code)
                if ok then 
                    okCount = okCount + 1
                    print("✅ Redeemed: " .. code)
                else 
                    failCount = failCount + 1
                    print("❌ Failed: " .. code .. " - " .. tostring(res))
                end
                task.wait(0.35)
            end
            
            WindUI:Notify({
                Title = "✅ Done",
                Content = "Success: " .. okCount .. ", Failed: " .. failCount,
                Duration = 4,
                Icon = "check"
            })
        end)
    end
})

-- Information Tab
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
            setclipboard("https://discord.gg/wAwgJatMMt")
        end)
        WindUI:Notify({
            Title = "✅ Copied",
            Content = "Discord invite copied to clipboard!",
            Duration = 3,
            Icon = "copy"
        })
    end
})

local InfoSection2 = InfoTab:Section({
    Title = "UI Library (Author)",
    Icon = "palette",
    Opened = true
})

InfoSection2:Button({
    Title = "🎨 GitHub Author",
    Desc = "Click to copy GitHub author link",
    Icon = "palette",
    Callback = function()
        pcall(function()
            setclipboard("https://github.com/Footagesus")
        end)
        WindUI:Notify({
            Title = "✅ Copied",
            Content = "GitHub author link copied to clipboard!",
            Duration = 3,
            Icon = "copy"
        })
    end
})

-- Initialize notification
WindUI:Notify({
    Title = "💫 NovaAxis Hub Loaded",
    Content = "Hub ready! Press RightShift to toggle menu.",
    Duration = 5,
    Icon = "sparkles"
})

print("NovaAxis Hub loaded successfully!")
