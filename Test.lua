--[[
    💫 NovaAxis Hub - 99 Nights In The Forest
    
    Author: NovaAxis
    Version: 2.5
    
    Press Left Alt to open / close
]]

local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player
local player = Players.LocalPlayer

-- Variables
local claimAmount = 100
local autoClaim = false
local autoClaimActive = false
local autoClaimDelay = 5

-- Create Notification
local Notifier = Compkiller.newNotify();

-- Create Config Manager
local ConfigManager = Compkiller:ConfigManager({
    Directory = "NovaAxis-99Nights",
    Config = "Default-Config"
});

-- Loading UI
Compkiller:Loader("rbxassetid://7733960981", 2.5).yield();

-- Creating Window
local Window = Compkiller.new({
    Name = "💫 NOVAAXIS HUB",
    Keybind = "LeftAlt",
    Logo = "rbxassetid://7733960981",
    Scale = Compkiller.Scale.Window,
    TextSize = 15,
});

-- Welcome Notification
Notifier.new({
    Title = "💫 NovaAxis Hub",
    Content = "Successfully loaded for 99 Nights In The Forest!",
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
    Text = "v2.5",
});

-- Claim Money Function
local function executeClaim(amount)
    if not amount or amount <= 0 then
        Notifier.new({
            Title = "❌ Error",
            Content = "Invalid amount entered!",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        });
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
        Notifier.new({
            Title = "✅ Success",
            Content = "Claimed $" .. tostring(amount) .. "!",
            Duration = 3,
            Icon = "rbxassetid://7733960981"
        });
    else
        Notifier.new({
            Title = "❌ Error",
            Content = "Failed to claim money",
            Duration = 3,
            Icon = "rbxassetid://7733964719"
        });
    end
end

-- Auto Claim Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if autoClaim and not autoClaimActive then
            autoClaimActive = true
            executeClaim(claimAmount)
            task.wait(autoClaimDelay)
            autoClaimActive = false
        end
    end
end)

-- Creating Main Category
Window:DrawCategory({
    Name = "💰 Money Farm"
});

-- Main Tab
local MainTab = Window:DrawTab({
    Name = "Main Features",
    Icon = "dollar-sign",
    EnableScrolling = true
});

-- Claim Section (Left)
local ClaimSection = MainTab:DrawSection({
    Name = "💵 Claim Money",
    Position = 'left'
});

-- Claim Amount Slider
ClaimSection:AddSlider({
    Name = "Claim Amount",
    Min = 100,
    Max = 100000,
    Default = 100,
    Round = 0,
    Flag = "ClaimAmount",
    Callback = function(value)
        claimAmount = value
    end
});

-- Main Claim Button
ClaimSection:AddButton({
    Name = "💰 Claim Money",
    Callback = function()
        executeClaim(claimAmount)
    end
});

ClaimSection:AddParagraph({
    Title = "ℹ️ Info",
    Content = "Use the slider to set the amount, then click the button to claim money."
});

-- Auto Claim Section (Left)
local AutoSection = MainTab:DrawSection({
    Name = "🔄 Auto Claim",
    Position = 'left'
});

local AutoToggle = AutoSection:AddToggle({
    Name = "Enable Auto Claim",
    Flag = "AutoClaim",
    Default = false,
    Callback = function(value)
        autoClaim = value
        if value then
            Notifier.new({
                Title = "✅ Enabled",
                Content = "Auto Claim is now active!",
                Duration = 3,
                Icon = "rbxassetid://7733960981"
            });
        else
            Notifier.new({
                Title = "⏸️ Disabled",
                Content = "Auto Claim has been stopped.",
                Duration = 3,
                Icon = "rbxassetid://7733779610"
            });
        end
    end
});

AutoSection:AddSlider({
    Name = "Auto Claim Delay (seconds)",
    Min = 1,
    Max = 30,
    Default = 5,
    Round = 0,
    Flag = "AutoClaimDelay",
    Callback = function(value)
        autoClaimDelay = value
    end
});

AutoSection:AddParagraph({
    Title = "⚡ How it works",
    Content = "When enabled, the script will automatically claim the set amount every X seconds."
});

-- Quick Claim Section (Right)
local QuickSection = MainTab:DrawSection({
    Name = "⚡ Quick Claim",
    Position = 'right'
});

QuickSection:AddButton({
    Name = "💵 Claim $100",
    Callback = function()
        executeClaim(100)
    end
});

QuickSection:AddButton({
    Name = "💵 Claim $500",
    Callback = function()
        executeClaim(500)
    end
});

QuickSection:AddButton({
    Name = "💰 Claim $1,000",
    Callback = function()
        executeClaim(1000)
    end
});

QuickSection:AddButton({
    Name = "💰 Claim $5,000",
    Callback = function()
        executeClaim(5000)
    end
});

QuickSection:AddButton({
    Name = "💎 Claim $10,000",
    Callback = function()
        executeClaim(10000)
    end
});

QuickSection:AddButton({
    Name = "💎 Claim $50,000",
    Callback = function()
        executeClaim(50000)
    end
});

QuickSection:AddButton({
    Name = "💎 Claim $100,000",
    Callback = function()
        executeClaim(100000)
    end
});

QuickSection:AddParagraph({
    Title = "📌 Quick Access",
    Content = "Use these buttons for instant claims of preset amounts."
});

-- Info Section (Right)
local InfoSection = MainTab:DrawSection({
    Name = "ℹ️ Information",
    Position = 'right'
});

InfoSection:AddParagraph({
    Title = "💫 NovaAxis Hub",
    Content = "Version: 2.5\nGame: 99 Nights In The Forest\nCreated by: NovaAxis"
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

InfoSection:AddParagraph({
    Title = "⌨️ Controls",
    Content = "Press Left Alt to toggle UI\nUse slider or quick buttons to claim money"
});

-- Misc Category
Window:DrawCategory({
    Name = "⚙️ Settings"
});

-- Settings Tab
local SettingTab = Window:DrawTab({
    Icon = "settings",
    Name = "UI Settings",
    Type = "Single",
    EnableScrolling = true
});

local Settings = SettingTab:DrawSection({
    Name = "🎨 UI Customization",
});

Settings:AddToggle({
    Name = "Always Show Frame",
    Default = false,
    Flag = "AlwaysShowFrame",
    Callback = function(v)
        Window.AlwayShowTab = v;
    end,
});

Settings:AddColorPicker({
    Name = "Highlight Color",
    Default = Compkiller.Colors.Highlight,
    Flag = "HighlightColor",
    Callback = function(v)
        Compkiller.Colors.Highlight = v;
        Compkiller:RefreshCurrentColor();
    end,
});

Settings:AddColorPicker({
    Name = "Toggle Color",
    Default = Compkiller.Colors.Toggle,
    Flag = "ToggleColor",
    Callback = function(v)
        Compkiller.Colors.Toggle = v;
        Compkiller:RefreshCurrentColor(v);
    end,
});

Settings:AddColorPicker({
    Name = "Background Color",
    Default = Compkiller.Colors.BGDBColor,
    Flag = "BackgroundColor",
    Callback = function(v)
        Compkiller.Colors.BGDBColor = v;
        Compkiller:RefreshCurrentColor(v);
    end,
});

Settings:AddButton({
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
print("💰 Game: 99 Nights In The Forest")
