--[[
    💫 NovaAxis Hub - 99 Nights In The Forest
    Author: NovaAxis
    Version: 2.5
    1
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
local claimAmount = "100"

-- Function to parse number with k/m/b suffixes
local function parseNumber(input)
    if not input or input == "" then
        return 0
    end
    
    input = tostring(input):lower():gsub(" ", "")
    
    -- Check for k/m/b suffixes
    if input:find("k") then
        local num = tonumber(input:gsub("k", "")) or 0
        return num * 1000
    elseif input:find("m") then
        local num = tonumber(input:gsub("m", "")) or 0
        return num * 1000000
    elseif input:find("b") then
        local num = tonumber(input:gsub("b", "")) or 0
        return num * 1000000000
    else
        return tonumber(input) or 0
    end
end

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis Hub",
    Author = "by NovaAxis",
    Folder = "NovaAxisHub",
    Window.Icon:SetAnonymous(true) -- true or false
    
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

-- Create Tabs
local MainTab = Window:Tab({
    Title = "💰 Money Farm",
    Icon = "dollar-sign",
})

local InfoTab = Window:Tab({
    Title = "ℹ️ Information",
    Icon = "info",
})

-- Claim Money Function
local function executeClaim(amountText)
    local parsedAmount = parseNumber(amountText)
    
    print("Input:", amountText)
    print("Parsed amount:", parsedAmount)
    
    if not parsedAmount or parsedAmount <= 0 then
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
            parsedAmount  -- Здесь уже число 1000, а не "1k"
        }
        print("Sending to server:", parsedAmount)
        game:GetService("ReplicatedStorage"):WaitForChild("ClaimReward"):FireServer(unpack(args))
    end)
    
    if success then
        WindUI:Notify({
            Title = "✅ Success",
            Content = "Claimed $" .. tostring(parsedAmount) .. "!",
            Duration = 3
        })
    else
        WindUI:Notify({
            Title = "❌ Error",
            Content = "Failed to claim money: " .. tostring(result),
            Duration = 3
        })
    end
end

-- Claim Money Section
local ClaimSection = MainTab:Section({
    Title = "💵 Claim Money",
})

local amountInput = ClaimSection:Input({
    Title = "Amount",
    Desc = "Enter amount (e.g., 1000, 1k, 5m, 2b)",
    Value = "100",
    InputIcon = "dollar-sign",
    Placeholder = "Enter amount...",
    Callback = function(input)
        claimAmount = input
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
    Title = "ℹ️ Quick Input Examples:",
    TextSize = 16,
    TextTransparency = .35,
    FontWeight = Enum.FontWeight.Medium,
})

ClaimSection:Section({
    Title = "• 1k = 1000\n• 5k = 5000\n• 10k = 10000\n• 1m = 1000000\n• 2.5m = 2500000\n• 1b = 1000000000",
    TextSize = 14,
    TextTransparency = .5,
})

-- Quick Buttons Section
local QuickSection = MainTab:Section({
    Title = "⚡ Quick Claim",
})

QuickSection:Button({
    Title = "💵 Claim 1k",
    Icon = "dollar-sign",
    Callback = function()
        amountInput:Set("1k")
        executeClaim("1k")
    end
})

QuickSection:Button({
    Title = "💰 Claim 10k",
    Icon = "dollar-sign",
    Callback = function()
        amountInput:Set("10k")
        executeClaim("10k")
    end
})

QuickSection:Button({
    Title = "💎 Claim 100k",
    Icon = "diamond",
    Callback = function()
        amountInput:Set("100k")
        executeClaim("100k")
    end
})

QuickSection:Button({
    Title = "💎 Claim 1m",
    Icon = "diamond",
    Callback = function()
        amountInput:Set("1m")
        executeClaim("1m")
    end
})

QuickSection:Button({
    Title = "👑 Claim 10m",
    Icon = "crown",
    Callback = function()
        amountInput:Set("10m")
        executeClaim("10m")
    end
})

-- Information Section
local InfoSection = InfoTab:Section({
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
    Title = "How to use:",
    TextSize = 16,
    FontWeight = Enum.FontWeight.Medium,
})

InfoSection:Section({
    Title = "1. Enter amount in textbox (supports k, m, b suffixes)\n2. Click 'Claim Money' or use quick buttons\n3. Use quick buttons for instant claims",
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
