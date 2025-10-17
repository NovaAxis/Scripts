--[[
    💫 NovaAxis Hub - 99 Nights In The Forest (WindUI rewrite, no Compkiller)
    Author: NovaAxis (ported to WindUI, Compkiller-free)
    Version: 2.5-windui
    Notes: This file intentionally does NOT import or reuse Compkiller code.
           WindUI is loaded separately (expected to be available via the provided URL).
           All core game logic from the original (ClaimReward usage) is preserved.
]]

-- ============================
-- Load WindUI
-- ============================
local successWind, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not successWind or not WindUI then
    warn("WindUI failed to load. Aborting UI creation.")
    return
end

-- ============================
-- Services
-- ============================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- ============================
-- Constants / Defaults
-- ============================
local DEFAULT_CLAIM_AMOUNT = 100
local MIN_CLAIM_AMOUNT = 100
local MAX_CLAIM_AMOUNT = 100000

-- ============================
-- State
-- ============================
local claimAmount = DEFAULT_CLAIM_AMOUNT
local autoClaim = false
local autoClaimActive = false
local autoClaimDelay = 5

-- UI theme (Nova Neon)
WindUI:AddTheme({
    Name = "Nova Neon",
    Accent = Color3.fromRGB(120, 80, 255),
    Dialog = Color3.fromRGB(18,18,20),
    Outline = Color3.fromRGB(255,255,255),
    Text = Color3.fromRGB(230,230,230),
    Placeholder = Color3.fromRGB(130,130,140),
    Background = Color3.fromRGB(8,8,10),
    Button = Color3.fromRGB(50,40,60),
    Icon = Color3.fromRGB(190,180,255)
})
WindUI:SetTheme("Nova Neon")

-- ============================
-- Local helpers
-- ============================
local function safe_pcall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

-- Simple Notifier wrapper using WindUI
local function NotifierNew(opts)
    -- opts: {Title, Content, Duration, Icon}
    WindUI:Notify({
        Title = opts.Title or "Notification",
        Content = opts.Content or "",
        Duration = opts.Duration or 3,
        Icon = opts.Icon or "activity"
    })
end

-- Simple ConfigManager placeholder (no file IO, just metadata)
local ConfigManager = {}
ConfigManager.Directory = "NovaAxis-99Nights"
ConfigManager.Config = "Default-Config"
ConfigManager.current = {}
function ConfigManager:Save(name)
    -- Placeholder: store current settings in memory; in future can write to file
    local n = name or self.Config
    self.current[n] = {
        claimAmount = claimAmount,
        autoClaim = autoClaim,
        autoClaimDelay = autoClaimDelay
    }
    NotifierNew({Title = "Config", Content = "Settings saved to memory (placeholder) ["..n.."]", Duration = 2, Icon = "save"})
end
function ConfigManager:Load(name)
    local n = name or self.Config
    local cfg = self.current[n]
    if cfg then
        claimAmount = cfg.claimAmount or claimAmount
        autoClaim = cfg.autoClaim or autoClaim
        autoClaimDelay = cfg.autoClaimDelay or autoClaimDelay
        NotifierNew({Title = "Config", Content = "Settings loaded from memory (placeholder) ["..n.."]", Duration = 2, Icon = "download"})
        return true
    else
        NotifierNew({Title = "Config", Content = "No saved config found for ["..n.."]", Duration = 2, Icon = "alert-circle"})
        return false
    end
end

-- ============================
-- Core game function: claim money
-- ============================
local function executeClaim(amount)
    if not amount or type(amount) ~= "number" or amount <= 0 then
        NotifierNew({Title = "❌ Error", Content = "Invalid amount entered!", Duration = 3, Icon = "x"})
        return false
    end

    -- Try to call the ClaimReward remote (replicating original script behavior)
    local ok, err = pcall(function()
        -- If the event exists, fire it
        local claimEvent = ReplicatedStorage:FindFirstChild("ClaimReward")
        if not claimEvent then
            error("ClaimReward remote not found in ReplicatedStorage")
        end
        -- Many games expect arguments in a specific order — original passed ("Money", amount)
        claimEvent:FireServer("Money", amount)
    end)

    if ok then
        NotifierNew({Title = "✅ Success", Content = "Claimed $" .. tostring(amount) .. "!", Duration = 3, Icon = "check"})
        return true
    else
        NotifierNew({Title = "❌ Error", Content = "Failed to claim money: " .. tostring(err), Duration = 4, Icon = "alert-circle"})
        return false
    end
end

-- ============================
-- Auto-claim loop
-- ============================
task.spawn(function()
    while true do
        task.wait(0.5)
        if autoClaim and not autoClaimActive then
            autoClaimActive = true
            executeClaim(claimAmount)
            -- wait for configured delay (safeguard)
            local waited = 0
            while waited < autoClaimDelay do
                task.wait(0.25)
                waited = waited + 0.25
                if not autoClaim then break end
            end
            autoClaimActive = false
        end
    end
end)

-- ============================
-- Build WindUI window & layout
-- ============================
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Author = "NovaAxis",
    Folder = ConfigManager.Directory,
    Size = UDim2.fromOffset(880, 560),
    MinSize = Vector2.new(640, 420),
    Transparent = true,
    Theme = "Nova Neon",
    Resizable = true,
    SideBarWidth = 220
})

Window:SetToggleKey(Enum.KeyCode.LeftAlt)

-- Welcome notification
NotifierNew({Title = "💫 NovaAxis Hub", Content = "Successfully loaded for 99 Nights In The Forest!", Duration = 4, Icon = "sparkles"})

-- ----------------------------
-- Category: Money Farm (Main)
-- ----------------------------
Window:DrawCategory({ Name = "💰 Money Farm" })

local MainTab = Window:DrawTab({
    Name = "Main Features",
    Icon = "dollar-sign",
    EnableScrolling = true
})

-- Claim Section (left)
local ClaimSection = MainTab:DrawSection({
    Name = "💵 Claim Money",
    Position = 'left'
})

ClaimSection:AddSlider({
    Name = "Claim Amount",
    Min = MIN_CLAIM_AMOUNT,
    Max = MAX_CLAIM_AMOUNT,
    Default = DEFAULT_CLAIM_AMOUNT,
    Round = 0,
    Flag = "ClaimAmount",
    Callback = function(value)
        claimAmount = value
    end
})

ClaimSection:AddButton({
    Name = "💰 Claim Money",
    Callback = function()
        executeClaim(claimAmount)
    end
})

ClaimSection:AddParagraph({
    Title = "ℹ️ Info",
    Content = "Use the slider to set the amount, then click the button to claim money. Make sure the server has the 'ClaimReward' remote under ReplicatedStorage."
})

-- Auto Claim Section (left)
local AutoSection = MainTab:DrawSection({
    Name = "🔄 Auto Claim",
    Position = 'left'
})

AutoSection:AddToggle({
    Name = "Enable Auto Claim",
    Flag = "AutoClaim",
    Default = false,
    Callback = function(value)
        autoClaim = value
        if value then
            NotifierNew({Title = "✅ Enabled", Content = "Auto Claim is now active!", Duration = 3, Icon = "play"})
        else
            NotifierNew({Title = "⏸️ Disabled", Content = "Auto Claim has been stopped.", Duration = 3, Icon = "pause"})
        end
    end
})

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
})

AutoSection:AddParagraph({
    Title = "⚡ How it works",
    Content = "When enabled, the script will automatically claim the set amount every X seconds."
})

-- Quick Claim Section (right)
local QuickSection = MainTab:DrawSection({
    Name = "⚡ Quick Claim",
    Position = 'right'
})

local quickAmounts = {100, 500, 1000, 5000, 10000, 50000, 100000}
for _, amt in ipairs(quickAmounts) do
    QuickSection:AddButton({
        Name = "💵 Claim $" .. tostring(amt),
        Callback = (function(a) return function() executeClaim(a) end end)(amt)
    })
end

QuickSection:AddParagraph({
    Title = "📌 Quick Access",
    Content = "Use these buttons for instant claims of preset amounts."
})

-- Info Section (right)
local InfoSection = MainTab:DrawSection({
    Name = "ℹ️ Information",
    Position = 'right'
})

InfoSection:AddParagraph({
    Title = "💫 NovaAxis Hub",
    Content = "Version: 2.5\nGame: 99 Nights In The Forest\nCreated by: NovaAxis"
})

-- Removed "Copy GitHub (author)" per request — no external references added.

InfoSection:AddParagraph({
    Title = "⌨️ Controls",
    Content = "Press Left Alt to toggle UI.\nUse the slider or quick buttons to claim money.\nEnable Auto Claim to repeatedly claim automatically."
})

-- ----------------------------
-- Category: Settings (UI & Config)
-- ----------------------------
Window:DrawCategory({ Name = "⚙️ Settings" })

-- UI Settings Tab
local SettingTab = Window:DrawTab({
    Icon = "settings",
    Name = "UI Settings",
    Type = "Single",
    EnableScrolling = true
})

local UISettings = SettingTab:DrawSection({
    Name = "🎨 UI Customization",
})

UISettings:AddToggle({
    Name = "Always Show Frame",
    Default = false,
    Flag = "AlwaysShowFrame",
    Callback = function(v)
        -- WindUI behavior may differ; store as placeholder setting
        NotifierNew({Title = "UI", Content = "Always Show Frame set to: " .. tostring(v), Duration = 2})
    end,
})

UISettings:AddColorPicker({
    Name = "Highlight Color",
    Default = WindUI and Color3.fromRGB(120,80,255) or Color3.new(1,0,1),
    Flag = "HighlightColor",
    Callback = function(v)
        -- Apply theme update
        WindUI:AddTheme({
            Name = "Nova Neon - Custom",
            Accent = v,
            Dialog = Color3.fromRGB(18,18,20),
            Outline = Color3.fromRGB(255,255,255),
            Text = Color3.fromRGB(230,230,230),
            Placeholder = Color3.fromRGB(130,130,140),
            Background = Color3.fromRGB(8,8,10),
            Button = Color3.fromRGB(50,40,60),
            Icon = Color3.fromRGB(190,180,255)
        })
        WindUI:SetTheme("Nova Neon - Custom")
        NotifierNew({Title = "UI", Content = "Accent color updated", Duration = 2})
    end,
})

UISettings:AddButton({
    Name = "Get Theme",
    Callback = function()
        NotifierNew({Title = "Theme", Content = "Current theme: Nova Neon", Duration = 3})
    end
})

-- Theme Tab
local ThemeTab = Window:DrawTab({
    Icon = "paintbrush",
    Name = "Themes",
    Type = "Single"
})

ThemeTab:DrawSection({ Name = "🎨 UI Themes" }):AddDropdown({
    Name = "Select Theme",
    Default = "Nova Neon",
    Flag = "Theme",
    Values = {
        "Nova Neon",
        "Dark Green",
        "Dark Blue",
        "Purple Rose",
        "Skeet"
    },
    Callback = function(v)
        -- Map simple themes (Nova Neon is already applied)
        if v == "Nova Neon" then
            WindUI:SetTheme("Nova Neon")
            NotifierNew({Title = "Theme", Content = "Nova Neon applied", Duration = 2})
        else
            -- fallback: change accent roughly
            local palette = {
                ["Dark Green"] = Color3.fromRGB(0,150,80),
                ["Dark Blue"] = Color3.fromRGB(40,120,255),
                ["Purple Rose"] = Color3.fromRGB(180,60,200),
                ["Skeet"] = Color3.fromRGB(0,200,200),
            }
            local accent = palette[v] or Color3.fromRGB(120,80,255)
            WindUI:AddTheme({ Name = "CustomTheme_" .. v, Accent = accent })
            WindUI:SetTheme("CustomTheme_" .. v)
            NotifierNew({Title = "Theme", Content = v .. " applied", Duration = 2})
        end
    end
})

-- Config Tab (config manager)
local ConfigTab = Window:DrawTab({
    Icon = "folder",
    Name = "Config",
    Type = "Single",
    EnableScrolling = true
})

local ConfigSection = ConfigTab:DrawSection({
    Name = "Config Manager",
})

ConfigSection:AddParagraph({
    Title = "💾 Config",
    Content = "This section contains save/load placeholders for settings. Currently stored in session memory."
})

ConfigSection:AddButton({
    Name = "Save Current Settings",
    Callback = function()
        ConfigManager:Save()
    end
})

ConfigSection:AddButton({
    Name = "Load Settings",
    Callback = function()
        ConfigManager:Load()
    end
})

-- Initialization of ConfigManager store (optional)
ConfigManager.current = ConfigManager.current or {}

-- ----------------------------
-- Final prints and ready state
-- ----------------------------
print("✅ NovaAxis Hub (99 Nights) loaded successfully (WindUI, Compkiller-free).")
print("⌨️ Press Left Alt to toggle UI.")

-- End of file
