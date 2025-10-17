--========================================================--
-- 💫 NovaAxis Hub - WindUI v2 (Stable Fixed)
--========================================================--
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success or not WindUI then
    warn("⚠️ WindUI failed to load! Check your internet or URL.")
    return
end

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

--// Variables
local claimAmount = 100
local autoClaim = false
local autoClaimDelay = 5
local autoClaimRunning = false

--// Notification Helper
local function Notify(title, content, icon)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = 3,
        Icon = icon or "bell"
    })
end

--// Config (Memory + Disk)
local Config = {}
Config.memory = {}
local function SaveConfig()
    Config.memory = {
        claimAmount = claimAmount,
        autoClaim = autoClaim,
        autoClaimDelay = autoClaimDelay
    }
    Notify("💾 Config", "Saved settings to memory.", "save")
end

local function LoadConfig()
    if not Config.memory or not Config.memory.claimAmount then
        Notify("⚠️ Config", "No config found in memory.", "alert-circle")
        return
    end
    claimAmount = Config.memory.claimAmount
    autoClaim = Config.memory.autoClaim
    autoClaimDelay = Config.memory.autoClaimDelay
    Notify("✅ Config", "Loaded settings from memory.", "download")
end

--// Claim Function
local function ClaimMoney(amount)
    local event = ReplicatedStorage:FindFirstChild("ClaimReward", true)
    if not event then
        Notify("❌ Error", "ClaimReward not found in ReplicatedStorage!", "x")
        return
    end
    pcall(function()
        event:FireServer("Money", amount)
    end)
    Notify("✅ Claimed", "Claimed $" .. tostring(amount), "check")
end

--// Auto Claim Thread
task.spawn(function()
    while task.wait(0.5) do
        if autoClaim and not autoClaimRunning then
            autoClaimRunning = true
            ClaimMoney(claimAmount)
            task.wait(autoClaimDelay)
            autoClaimRunning = false
        end
    end
end)

--========================================================--
-- UI Creation
--========================================================--
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Theme = "Dark", -- built-in theme to prevent nil 'Text'
    Size = UDim2.fromOffset(900, 600),
    SideBarWidth = 230,
    Resizable = true
})

-- Accent override (Nova Neon)
WindUI:SetAccent(Color3.fromRGB(120, 80, 255))

Window:SetToggleKey(Enum.KeyCode.LeftAlt)
Notify("💫 NovaAxis Hub", "Loaded successfully!", "sparkles")

--========================================================--
-- 📂 Main Tab
--========================================================--
local Main = Window:Tab({
    Title = "Main Features",
    Icon = "dollar-sign"
})

-- Claim Section
local ClaimSec = Main:Section({
    Title = "💵 Claim Money",
    Icon = "credit-card",
    Opened = true
})

ClaimSec:Slider({
    Title = "Claim Amount",
    Description = "Choose how much to claim",
    Min = 100,
    Max = 100000,
    Value = 100,
    Step = 1,
    Callback = function(val)
        claimAmount = val
    end
})

ClaimSec:Button({
    Title = "💰 Claim Money",
    Description = "Send money claim request",
    Callback = function()
        ClaimMoney(claimAmount)
    end
})

-- Auto Claim Section
local AutoSec = Main:Section({
    Title = "🔄 Auto Claim",
    Icon = "repeat",
    Opened = true
})

AutoSec:Toggle({
    Title = "Enable Auto Claim",
    Description = "Automatically claim every X seconds",
    Value = false,
    Callback = function(val)
        autoClaim = val
        if val then
            Notify("✅ Auto Claim", "Enabled", "play")
        else
            Notify("⏸ Auto Claim", "Disabled", "pause")
        end
    end
})

AutoSec:Slider({
    Title = "Auto Claim Delay",
    Description = "Time between claims (seconds)",
    Min = 1,
    Max = 60,
    Value = 5,
    Step = 1,
    Callback = function(v)
        autoClaimDelay = v
    end
})

-- Quick Claim
local QuickSec = Main:Section({
    Title = "⚡ Quick Claim",
    Icon = "zap",
    Opened = true
})

for _, amt in ipairs({100, 500, 1000, 5000, 10000, 50000, 100000}) do
    QuickSec:Button({
        Title = "💵 Claim $"..amt,
        Callback = function()
            ClaimMoney(amt)
        end
    })
end

--========================================================--
-- ⚙️ UI Settings Tab
--========================================================--
local Settings = Window:Tab({
    Title = "UI Settings",
    Icon = "settings"
})

local UIsec = Settings:Section({
    Title = "🎨 UI Customization",
    Icon = "paintbrush",
    Opened = true
})

UIsec:Colorpicker({
    Title = "Accent Color",
    Description = "Change UI accent color",
    Default = Color3.fromRGB(120,80,255),
    Callback = function(color)
        WindUI:SetAccent(color)
        Notify("🎨 Theme", "Accent color updated", "palette")
    end
})

UIsec:Button({
    Title = "Get Theme Name",
    Description = "Copy 'Nova Neon' to clipboard",
    Callback = function()
        pcall(function() setclipboard("Nova Neon") end)
        Notify("✅ Copied", "Theme name copied to clipboard", "clipboard")
    end
})

--========================================================--
-- 💾 Config Tab
--========================================================--
local ConfigTab = Window:Tab({
    Title = "Config",
    Icon = "folder"
})

local ConfSec = ConfigTab:Section({
    Title = "💾 Config Manager",
    Icon = "archive",
    Opened = true
})

ConfSec:Button({
    Title = "Save Config",
    Description = "Save settings in memory",
    Callback = SaveConfig
})

ConfSec:Button({
    Title = "Load Config",
    Description = "Load settings from memory",
    Callback = LoadConfig
})

--========================================================--
-- ℹ️ Information Tab
--========================================================--
local InfoTab = Window:Tab({
    Title = "Information",
    Icon = "info"
})

local InfoSec = InfoTab:Section({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Opened = true
})

InfoSec:Paragraph({
    Title = "About",
    Content = "NovaAxis Hub — WindUI v2\nVersion 3.2 Stable\nAuthor: NovaAxis"
})

InfoSec:Button({
    Title = "🌐 Discord Server",
    Description = "Copy invite to clipboard",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/Eg98P4wf2V") end)
        Notify("✅ Discord", "Invite copied to clipboard", "link")
    end
})

print("✅ NovaAxis Hub Loaded (Stable, WindUI v2)")
print("⌨️ Toggle key: Left Alt")
