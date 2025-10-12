-- Load NOTHING UI Library
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()
local Notification = NothingLibrary.Notification()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player
local player = Players.LocalPlayer

-- Variables
local claimAmount = 100
local autoClaim = false
local autoClaimDelay = 5

-- Show initial notification
Notification.new({
    Title = "Money Claim",
    Description = "UI Loaded Successfully!",
    Duration = 3,
    Icon = "rbxassetid://7733960981"
})

-- Claim Money Function
local function executeClaim(amount)
    if not amount or amount <= 0 then
        Notification.new({
            Title = "❌ Error",
            Description = "Invalid amount entered!",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
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
        Notification.new({
            Title = "✅ Success",
            Description = "Claimed $" .. amount .. "!",
            Duration = 3,
            Icon = "rbxassetid://7733960981"
        })
    else
        Notification.new({
            Title = "❌ Error",
            Description = "Failed to claim money",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        })
    end
end

-- Create Main Window
local Windows = NothingLibrary.new({
    Title = "Money Claim",
    Description = "99 Nights In The Forest",
    Keybind = Enum.KeyCode.RightShift,
    Logo = '',
    BrandText = "NovaAxis | HUB"
})

-- Create Main Tab
local MainTab = Windows:NewTab({
    Title = "🏠 Main",
    Description = "Money Claim Functions",
    Icon = "rbxassetid://7733960981"
})

-- Create Claim Section
local ClaimSection = MainTab:NewSection({
    Title = "💵 Claim Money",
    Icon = "rbxassetid://7733960981",
    Position = "Left"
})

-- Amount Slider
ClaimSection:NewSlider({
    Title = "Claim Amount",
    Min = 100,
    Max = 100000,
    Default = 100,
    Callback = function(value)
        claimAmount = value
    end
})

-- Claim Button
ClaimSection:NewButton({
    Title = "Claim Money",
    Callback = function()
        executeClaim(claimAmount)
    end
})

-- Quick Claim Section
local QuickSection = MainTab:NewSection({
    Title = "Quick Claim",
    Icon = "rbxassetid://7733779610",
    Position = "Left"
})

-- Quick claim buttons
local quickAmounts = {
    {name = "💵 Claim $100", amount = 100},
    {name = "💵 Claim $500", amount = 500},
    {name = "💰 Claim $1,000", amount = 1000},
    {name = "💰 Claim $5,000", amount = 5000},
    {name = "💎 Claim $10,000", amount = 10000}
}

for _, data in ipairs(quickAmounts) do
    QuickSection:NewButton({
        Title = data.name,
        Callback = function()
            executeClaim(data.amount)
        end
    })
end

-- Info Tab
local InfoTab = Windows:NewTab({
    Title = "Info",
    Description = "Information & Credits",
    Icon = "rbxassetid://7733764088"
})

local InfoSection = InfoTab:NewSection({
    Title = "Information",
    Icon = "rbxassetid://7733764088",
    Position = "Left"
})

InfoSection:NewTitle('Money Claim Script')
InfoSection:NewTitle('Version: 2.0')
InfoSection:NewTitle('Game: 99 Nights In The Forest')
InfoSection:NewTitle('')
InfoSection:NewTitle('Created by AMIRTIMCAT')

InfoSection:NewButton({
    Title = "GitHub",
    Callback = function()
        setclipboard("github.com/AMIRTIMCAT")
        Notification.new({
            Title = "Copied",
            Description = "GitHub link copied to clipboard",
            Duration = 3,
            Icon = "rbxassetid://7733960981"
        })
    end
})

local HelpSection = InfoTab:NewSection({
    Title = "How to Use",
    Icon = "rbxassetid://7743869054",
    Position = "Right"
})

HelpSection:NewTitle('1. Set amount with slider')
HelpSection:NewTitle('2. Click Claim Money')
HelpSection:NewTitle('3. Or use Quick Claim buttons')
HelpSection:NewTitle('')
HelpSection:NewTitle('Press Right Shift to toggle UI')

-- Initialization
print("✅ Money Claim UI loaded successfully!")
print("⌨️ Press Right Shift to toggle UI")
