--[[
    💫 NovaAxis Hub - 99 Nights In The Forest
    Author: NovaAxis
    Version: 2.5
]]

local WindUI

do
    local ok, result = pcall(function()
        return require("./src/init")
    end)
    
    if ok then
        WindUI = result
    else 
        WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player
local player = Players.LocalPlayer

-- Variables
local claimAmount = 100

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis Hub",
    Author = "by NovaAxis",
    Folder = "NovaAxisHub",
    
    HideSearchBar = true,
    
    OpenButton = {
        Title = "Open NovaAxis Hub",
        CornerRadius = UDim.new(0, 8),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"), 
            Color3.fromHex("#e7ff2f")
        )
    }
})

-- Create Main Tab
local MainTab = Window:Tab({
    Title = "💰 Money Farm",
    Icon = "dollar-sign",
})

-- Claim Money Function
local function executeClaim(amount)
    if not amount or amount <= 0 then
        WindUI:Notify({
            Title = "❌ Error",
            Content = "Invalid amount entered!",
            Duration = 3
        })
        return
    end
    
    local success, result = pcall(function()
        local args = {
            "Money",
            amount
        }
        ReplicatedStorage:WaitForChild("ClaimReward"):FireServer(unpack(args))
    end)
    
    if success then
        WindUI:Notify({
            Title = "✅ Success",
            Content = "Claimed $" .. tostring(amount) .. "!",
            Duration = 3
        })
    else
        WindUI:Notify({
            Title = "❌ Error",
            Content = "Failed to claim money",
            Duration = 3
        })
    end
end

-- Claim Money Section
local ClaimSection = MainTab:Section({
    Title = "💵 Claim Money",
})

ClaimSection:Slider({
    Title = "Claim Amount",
    Step = 100,
    Value = {
        Min = 100,
        Max = 100000,
        Default = 100,
    },
    Callback = function(value)
        claimAmount = value
    end
})

ClaimSection:Space()

ClaimSection:Button({
    Title = "💰 Claim Money",
    Icon = "dollar-sign",
    Callback = function()
        executeClaim(claimAmount)
    end
})

ClaimSection:Space()

ClaimSection:Section({
    Title = "ℹ️ Info",
    TextSize = 16,
    TextTransparency = .35,
    FontWeight = Enum.FontWeight.Medium,
})

ClaimSection:Section({
    Title = "Use the slider to set the amount, then click the button to claim money.",
    TextSize = 14,
    TextTransparency = .5,
})

-- Information Section
local InfoSection = MainTab:Section({
    Title = "ℹ️ Information",
})

InfoSection:Section({
    Title = "💫 NovaAxis Hub",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold,
})

InfoSection:Section({
    Title = "Version: 2.5\nGame: 99 Nights In The Forest\nCreated by: NovaAxis",
    TextSize = 14,
    TextTransparency = .35,
})

InfoSection:Space()

InfoSection:Button({
    Title = "📋 Discord Server",
    Icon = "users",
    Callback = function()
        setclipboard("discord.gg/Eg98P4wf2V")
        WindUI:Notify({
            Title = "✅ Copied",
            Content = "Discord server link copied to clipboard!",
            Duration = 3
        })
    end
})

InfoSection:Space()

InfoSection:Section({
    Title = "Use slider to set amount and claim money",
    TextSize = 14,
    TextTransparency = .5,
})

-- Welcome Notification
task.wait(1)
WindUI:Notify({
    Title = "💫 NovaAxis Hub",
    Content = "Successfully loaded for 99 Nights In The Forest!",
    Duration = 5
})

-- Initialization
print("✅ NovaAxis Hub loaded successfully!")
print("💰 Game: 99 Nights In The Forest")
