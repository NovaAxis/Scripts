--[[
    💫 NovaAxis Hub - 99 Nights In The Forest
    
    Author: NovaAxis
    Version: 2.5
]]

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/footagesus/WindUI/main/source.lua"))()

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
    Key = Enum.KeyCode.LeftAlt,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 500, 0, 400)
})

-- Create Tabs
local MainTab = Window:CreateTab("💰 Money Farm")

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

-- Main Tab Sections
local ClaimSection = MainTab:CreateSection("💵 Claim Money")
local InfoSection = MainTab:CreateSection("ℹ️ Information")

-- Claim Amount Slider
ClaimSection:AddSlider({
    Text = "Claim Amount",
    Default = 100,
    Minimum = 100,
    Maximum = 100000,
    Callback = function(value)
        claimAmount = value
    end
})

-- Main Claim Button
ClaimSection:AddButton({
    Text = "💰 Claim Money",
    Callback = function()
        executeClaim(claimAmount)
    end
})

ClaimSection:AddLabel("ℹ️ Info")
ClaimSection:AddLabel("Use the slider to set the amount, then click the button to claim money.")

-- Info Section
InfoSection:AddLabel("💫 NovaAxis Hub")
InfoSection:AddLabel("Version: 2.5\nGame: 99 Nights In The Forest\nCreated by: NovaAxis")

InfoSection:AddButton({
    Text = "📋 Discord Server",
    Callback = function()
        setclipboard("discord.gg/Eg98P4wf2V")
        WindUI:Notify({
            Title = "✅ Copied",
            Content = "Discord server link copied to clipboard!",
            Duration = 3
        })
    end
})

InfoSection:AddLabel("⌨️ Controls")
InfoSection:AddLabel("Use slider to set amount and claim money")

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

-- Initialize Window
Window:Init()
