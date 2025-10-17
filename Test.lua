--========================================================--
-- 💫 NovaAxis Hub - WindUI v2 (Pro Edition)
--========================================================--

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success or not WindUI then
    warn("⚠️ WindUI failed to load!")
    return
end

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

if not player then warn("❌ Player not found!"); return end

--// Variables
local claimAmount = 100
local autoClaim = false
local autoClaimDelay = 5
local autoClaimRunning = false
local quickClaimKey = "F"
local claimMode = "Single"

--// Notification Helper
local function Notify(title, content, icon)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = 3,
        Icon = icon or "bell"
    })
end

--// Config Manager (with File Save)
local ConfigManager = Window and Window.ConfigManager or {
    AllConfigs = function(self) return {} end,
    CreateConfig = function(self, name) 
        return {
            Save = function(self) return false end,
            Load = function(self) return false end
        }
    end
}

local function SaveConfig()
    local configData = {
        claimAmount = claimAmount,
        autoClaim = autoClaim,
        autoClaimDelay = autoClaimDelay,
        quickClaimKey = quickClaimKey,
        claimMode = claimMode
    }
    setclipboard(game:GetService("HttpService"):JSONEncode(configData))
    Notify("💾 Config", "Config copied to clipboard!", "save")
end

local function LoadConfig()
    local clipboard = getclipboard()
    local ok, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(clipboard)
    end)
    
    if ok and data then
        claimAmount = data.claimAmount or 100
        autoClaim = data.autoClaim or false
        autoClaimDelay = data.autoClaimDelay or 5
        quickClaimKey = data.quickClaimKey or "F"
        claimMode = data.claimMode or "Single"
        Notify("✅ Config", "Config loaded from clipboard!", "download")
    else
        Notify("⚠️ Config", "Invalid config in clipboard!", "alert-circle")
    end
end

--// Claim Function
local function ClaimMoney(amount)
    if not amount or amount <= 0 then
        Notify("❌ Error", "Invalid claim amount!", "x")
        return
    end

    local event = ReplicatedStorage:FindFirstChild("ClaimReward", true)
    if not event then
        Notify("❌ Error", "ClaimReward event not found!", "x")
        return
    end

    local success = pcall(function()
        if event:IsA("RemoteEvent") then
            event:FireServer("Money", amount)
        elseif event:IsA("RemoteFunction") then
            event:InvokeServer("Money", amount)
        end
    end)

    if success then
        Notify("✅ Claimed", "Claimed $" .. tostring(amount), "check")
    else
        Notify("❌ Error", "Failed to claim money!", "x")
    end
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

--// Quick Claim Hotkey
local quickClaimConnection
local function SetupQuickClaimHotkey(keyName)
    if quickClaimConnection then
        quickClaimConnection:Disconnect()
    end
    
    local ok, keyCode = pcall(function()
        return Enum.KeyCode[keyName]
    end)
    
    if ok and keyCode then
        quickClaimConnection = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == keyCode then
                ClaimMoney(claimAmount)
            end
        end)
        Notify("⌨️ Hotkey", "Quick claim set to " .. keyName, "keyboard")
    end
end

--========================================================--
-- UI Creation
--========================================================--
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Theme = "Dark",
    Size = UDim2.fromOffset(950, 650),
    SideBarWidth = 240,
    Resizable = true
})

pcall(function()
    WindUI:SetAccent(Color3.fromRGB(120, 80, 255))
end)

Window:SetToggleKey(Enum.KeyCode.LeftAlt)
Notify("💫 NovaAxis Hub", "Loaded successfully!", "sparkles")

--========================================================--
-- Main Tab
--========================================================--
local Main = Window:Tab({
    Title = "Main Features",
    Icon = "dollar-sign"
})

-- Claim Settings Section
local ClaimSec = Main:Section({
    Title = "💵 Claim Money",
    Icon = "credit-card",
    Opened = true
})

ClaimSec:Slider({
    Flag = "ClaimAmount",
    Title = "Claim Amount",
    Description = "Choose how much to claim",
    Min = 100,
    Max = 100000,
    Value = 100,
    Step = 100,
    Callback = function(val)
        claimAmount = val
    end
})

ClaimSec:Space()

ClaimSec:Dropdown({
    Flag = "ClaimMode",
    Title = "Claim Mode",
    Description = "Select claim mode",
    Values = {"Single", "Multiple", "Auto"},
    Value = "Single",
    Callback = function(val)
        claimMode = val
        Notify("🎯 Mode", "Claim mode set to " .. val, "target")
    end
})

ClaimSec:Space()

ClaimSec:Button({
    Title = "💰 Claim Money",
    Description = "Send money claim request",
    Icon = "zap",
    Callback = function()
        ClaimMoney(claimAmount)
    end
})

ClaimSec:Space()

ClaimSec:Button({
    Title = "💰 Claim x10",
    Description = "Claim 10 times",
    Icon = "repeat-2",
    Callback = function()
        for i = 1, 10 do
            ClaimMoney(claimAmount)
            task.wait(0.5)
        end
    end
})

-- Auto Claim Section
Main:Space({Columns = 2})

local AutoSec = Main:Section({
    Title = "🔄 Auto Claim",
    Icon = "repeat",
    Opened = true
})

AutoSec:Toggle({
    Flag = "AutoClaimEnabled",
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

AutoSec:Space()

AutoSec:Slider({
    Flag = "AutoClaimDelay",
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

-- Quick Claim Section
Main:Space({Columns = 2})

local QuickSec = Main:Section({
    Title = "⚡ Quick Claim",
    Icon = "zap",
    Opened = true
})

QuickSec:Keybind({
    Flag = "QuickClaimKey",
    Title = "Quick Claim Hotkey",
    Description = "Press this key to claim instantly",
    Value = "F",
    Callback = function(v)
        quickClaimKey = v
        SetupQuickClaimHotkey(v)
    end
})

QuickSec:Space()

for _, amt in ipairs({100, 500, 1000, 5000, 10000, 50000, 100000}) do
    QuickSec:Button({
        Title = "💵 Claim $" .. amt,
        Callback = function()
            ClaimMoney(amt)
        end
    })
end

--========================================================--
-- Advanced Tab
--========================================================--
local Advanced = Window:Tab({
    Title = "Advanced",
    Icon = "sliders"
})

local AdvSec = Advanced:Section({
    Title = "⚙️ Advanced Settings",
    Icon = "settings",
    Opened = true
})

AdvSec:Input({
    Flag = "CustomAmount",
    Title = "Custom Claim Amount",
    Description = "Enter custom amount",
    Value = "1000",
    Icon = "dollar-sign",
    Placeholder = "Enter amount...",
    Callback = function(value)
        local amount = tonumber(value)
        if amount and amount > 0 then
            claimAmount = amount
            Notify("✅ Amount", "Set to $" .. tostring(amount), "check")
        else
            Notify("❌ Error", "Invalid amount!", "x")
        end
    end
})

AdvSec:Space()

AdvSec:Input({
    Flag = "APIEndpoint",
    Title = "API Endpoint",
    Description = "Custom server endpoint",
    Value = "ClaimReward",
    Icon = "link",
    Type = "Input",
    Placeholder = "e.g., ClaimReward",
    Callback = function(value)
        if value and value ~= "" then
            Notify("🔗 API", "Endpoint set to " .. value, "link")
        end
    end
})

--========================================================--
-- UI Settings Tab
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
    Flag = "AccentColor",
    Title = "Accent Color",
    Description = "Change UI accent color",
    Default = Color3.fromRGB(120, 80, 255),
    Callback = function(color)
        pcall(function()
            WindUI:SetAccent(color)
            Notify("🎨 Theme", "Accent updated!", "palette")
        end)
    end
})

UIsec:Space()

UIsec:Toggle({
    Flag = "DarkMode",
    Title = "Dark Mode",
    Description = "Enable dark theme",
    Value = true,
    Callback = function(val)
        Notify("🌙 Theme", val and "Dark mode enabled" or "Light mode enabled", "moon")
    end
})

UIsec:Space()

UIsec:Button({
    Title = "Copy Theme Name",
    Description = "Copy 'Nova Neon' to clipboard",
    Icon = "clipboard",
    Callback = function()
        pcall(function() setclipboard("Nova Neon") end)
        Notify("✅ Copied", "Theme name copied!", "clipboard")
    end
})

--========================================================--
-- Config Tab
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

ConfSec:Paragraph({
    Title = "Configuration",
    Content = "Save and load your settings. Configs are stored in clipboard as JSON."
})

ConfSec:Space()

ConfSec:Button({
    Title = "Save Config",
    Description = "Save to clipboard",
    Icon = "save",
    Callback = SaveConfig
})

ConfSec:Space()

ConfSec:Button({
    Title = "Load Config",
    Description = "Load from clipboard",
    Icon = "download",
    Callback = LoadConfig
})

ConfSec:Space()

local ConfigNameInput = ConfSec:Input({
    Title = "Config Name",
    Description = "Name for your config",
    Value = "Default",
    Icon = "file",
    Placeholder = "Enter config name...",
})

--========================================================--
-- Information Tab
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
    Content = "NovaAxis Hub — WindUI v2\nVersion 4.0 Pro Edition\nAuthor: NovaAxis\n\nFeatures:\n• Full config save/load\n• Keybind support\n• Multiple claim modes\n• Advanced settings\n• Custom UI themes"
})

InfoSec:Space()

InfoSec:Button({
    Title = "🌐 Discord Server",
    Description = "Copy invite to clipboard",
    Icon = "link",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/Eg98P4wf2V") end)
        Notify("✅ Discord", "Invite copied!", "copy")
    end
})

-- Initialize hotkey
SetupQuickClaimHotkey(quickClaimKey)

print("✅ NovaAxis Hub Pro Edition Loaded")
print("⌨️ Toggle UI: Left Alt | Quick Claim: " .. quickClaimKey)
