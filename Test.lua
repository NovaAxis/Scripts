--[[
  NovaAxis Hub - 99 Nights In The Forest (WindUI v2, corrected)
  Version: 3.1-fixed
  - Full rewrite to match WindUI v2 API (Window:Tab / Tab:Section / Section:Button/Slider/Toggle/etc)
  - Theme: Nova Neon (RGB 120,80,255)
  - All sections opened by default (Opened = true)
  - Config system: memory + optional file (writefile/readfile if available)
  - No usage of deprecated DrawCategory/DrawTab/AddButton etc.
  - Discord button present (copies invite).
  - No GitHub copy button.
  - Self-contained; loads WindUI from provided release URL.
--]]

-- Load WindUI (v2)
local successWind, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not successWind or not WindUI then
    warn("WindUI load failed. Aborting.")
    return
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Defaults and constants
local MIN_CLAIM_AMOUNT = 100
local MAX_CLAIM_AMOUNT = 100000
local DEFAULT_CLAIM_AMOUNT = 100
local DEFAULT_AUTO_DELAY = 5

-- State variables
local claimAmount = DEFAULT_CLAIM_AMOUNT
local autoClaim = false
local autoClaimDelay = DEFAULT_AUTO_DELAY
local autoClaimRunning = false

-- Movement / noclip placeholders (not used in this script per request)
-- local walkSpeedEnabled = false
-- local customWalkSpeed = 16
-- local noclipEnabled = false

-- Config store (in-memory)
local ConfigStore = {}

-- Helper: simple notify wrapper for WindUI
local function Notify(opts)
    -- opts = { Title = str, Content = str, Duration = number, Icon = str }
    pcall(function()
        WindUI:Notify({
            Title = opts.Title or "Notification",
            Content = opts.Content or "",
            Duration = opts.Duration or 3,
            Icon = opts.Icon or "activity"
        })
    end)
end

local function DebugLog(...)
    local t = {}
    for i = 1, select("#", ...) do
        t[#t+1] = tostring(select(i, ...))
    end
    print("[NovaAxis DEBUG] " .. table.concat(t, " "))
end

-- Config manager with optional disk support
local ConfigManager = {}
ConfigManager.Directory = "NovaAxis-99Nights"
ConfigManager.DefaultName = "default"
ConfigManager.store = ConfigStore

local function executorSupportsFiles()
    return type(writefile) == "function" and type(readfile) == "function"
end

function ConfigManager:SaveToMemory(name)
    local n = name or self.DefaultName
    self.store[n] = {
        claimAmount = claimAmount,
        autoClaim = autoClaim,
        autoClaimDelay = autoClaimDelay
    }
    Notify({ Title = "Config", Content = "Saved to memory: "..n, Duration = 2, Icon = "save" })
    return true
end

function ConfigManager:LoadFromMemory(name)
    local n = name or self.DefaultName
    local c = self.store[n]
    if not c then
        Notify({ Title = "Config", Content = "No memory config: "..n, Duration = 2, Icon = "alert-circle" })
        return false
    end
    claimAmount = c.claimAmount or claimAmount
    autoClaim = c.autoClaim or autoClaim
    autoClaimDelay = c.autoClaimDelay or autoClaimDelay
    Notify({ Title = "Config", Content = "Loaded memory config: "..n, Duration = 2, Icon = "download" })
    return true
end

function ConfigManager:SaveToDisk(name)
    if not executorSupportsFiles() then
        Notify({ Title = "Config", Content = "Filesystem not available (writefile)", Duration = 3, Icon = "alert-circle" })
        return false
    end
    local n = name or self.DefaultName
    local path = self.Directory .. "/" .. n .. ".json"
    local ok, payload = pcall(function()
        return HttpService:JSONEncode({
            claimAmount = claimAmount,
            autoClaim = autoClaim,
            autoClaimDelay = autoClaimDelay
        })
    end)
    if not ok then
        Notify({ Title = "Config", Content = "Failed to encode config", Duration = 3, Icon = "alert-circle" })
        return false
    end
    pcall(function()
        -- try to create dir-trick: some executors ignore folders; just write file
        writefile(path, payload)
    end)
    Notify({ Title = "Config", Content = "Saved to disk: "..n, Duration = 2, Icon = "save" })
    return true
end

function ConfigManager:LoadFromDisk(name)
    if not executorSupportsFiles() then
        Notify({ Title = "Config", Content = "Filesystem not available (readfile)", Duration = 3, Icon = "alert-circle" })
        return false
    end
    local n = name or self.DefaultName
    local path = self.Directory .. "/" .. n .. ".json"
    local ok, content = pcall(function() return readfile(path) end)
    if not ok or not content then
        Notify({ Title = "Config", Content = "Config file not found: "..n, Duration = 3, Icon = "alert-circle" })
        return false
    end
    local ok2, decoded = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok2 then
        Notify({ Title = "Config", Content = "Failed parse config file: "..n, Duration = 3, Icon = "alert-circle" })
        return false
    end
    claimAmount = decoded.claimAmount or claimAmount
    autoClaim = decoded.autoClaim or autoClaim
    autoClaimDelay = decoded.autoClaimDelay or autoClaimDelay
    Notify({ Title = "Config", Content = "Loaded from disk: "..n, Duration = 2, Icon = "download" })
    return true
end

-- Core game logic: attempt to find ClaimReward remote and call it
local function findClaimRemote()
    local remote = ReplicatedStorage:FindFirstChild("ClaimReward")
    if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
        return remote
    end
    -- fallback search (descendants)
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d.Name == "ClaimReward" and (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) then
            return d
        end
    end
    return nil
end

local function executeClaim(amount)
    if type(amount) ~= "number" or amount <= 0 then
        Notify({ Title = "❌ Error", Content = "Invalid amount", Duration = 3, Icon = "x" })
        return false
    end

    local remote = findClaimRemote()
    if not remote then
        Notify({ Title = "❌ Error", Content = "ClaimReward remote not found", Duration = 4, Icon = "alert-circle" })
        return false
    end

    local ok, err = pcall(function()
        -- Many variants: try FireServer("Money", amount) first, then fallback to FireServer(amount)
        if remote:IsA("RemoteEvent") then
            local sOk, sErr = pcall(function() remote:FireServer("Money", amount) end)
            if not sOk then
                pcall(function() remote:FireServer(amount) end)
            end
        elseif remote:IsA("RemoteFunction") then
            -- If it's a function, use InvokeServer pattern
            local sOk, sRes = pcall(function() return remote:InvokeServer("Money", amount) end)
            if not sOk then
                pcall(function() remote:InvokeServer(amount) end)
            end
        end
    end)

    if ok then
        Notify({ Title = "✅ Claimed", Content = "Claim requested: $"..tostring(amount), Duration = 3, Icon = "check" })
        return true
    else
        Notify({ Title = "❌ Error", Content = "Remote call failed: "..tostring(err), Duration = 4, Icon = "alert-circle" })
        return false
    end
end

-- Background auto-claim worker
task.spawn(function()
    while true do
        task.wait(0.5)
        if autoClaim and not autoClaimRunning then
            autoClaimRunning = true
            -- try claim; if fails, still wait
            pcall(function() executeClaim(claimAmount) end)
            local elapsed = 0
            while autoClaim and elapsed < autoClaimDelay do
                task.wait(0.25); elapsed = elapsed + 0.25
            end
            autoClaimRunning = false
        end
    end
end)

-- UI: build via WindUI v2 API
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Author = "NovaAxis",
    Folder = ConfigManager.Directory,
    Size = UDim2.fromOffset(920, 640),
    MinSize = Vector2.new(700, 480),
    Transparent = true,
    Theme = "Nova Neon",
    Resizable = true,
    SideBarWidth = 240,
    BackgroundImageTransparency = 0.45
})

Window:SetToggleKey(Enum.KeyCode.LeftAlt)

Notify({ Title = "💫 NovaAxis Hub", Content = "WindUI v2 interface loaded", Duration = 3, Icon = "sparkles" })

-- -----------------------
-- Main Tab (Claim UI)
-- -----------------------
local MainTab = Window:Tab({
    Title = "Main Features",
    Icon = "dollar-sign"
})

-- Claim section (left)
local ClaimSection = MainTab:Section({
    Title = "💵 Claim Money",
    Icon = "credit-card",
    Opened = true
})

ClaimSection:Slider({
    Title = "Claim Amount",
    Description = "Set amount to claim",
    Min = MIN_CLAIM_AMOUNT,
    Max = MAX_CLAIM_AMOUNT,
    Value = DEFAULT_CLAIM_AMOUNT,   -- correct property for WindUI v2
    Step = 1,
    Callback = function(val)
        claimAmount = val
    end
})

ClaimSection:Button({
    Title = "💰 Claim Money",
    Description = "Send claim request with the selected amount",
    Callback = function()
        executeClaim(claimAmount)
    end
})

ClaimSection:Paragraph({
    Title = "ℹ️ Info",
    Content = "Use the slider to choose an amount and click Claim. Script will search for a 'ClaimReward' remote in ReplicatedStorage."
})

-- Auto Claim section (left)
local AutoSection = MainTab:Section({
    Title = "🔄 Auto Claim",
    Icon = "repeat",
    Opened = true
})

AutoSection:Toggle({
    Title = "Enable Auto Claim",
    Description = "Automatically claim every X seconds",
    Value = false,
    Callback = function(v)
        autoClaim = v
        if v then
            Notify({ Title = "✅ Auto Claim", Content = "Auto Claim enabled", Duration = 2, Icon = "play" })
        else
            Notify({ Title = "⏸ Auto Claim", Content = "Auto Claim disabled", Duration = 2, Icon = "pause" })
        end
    end
})

AutoSection:Slider({
    Title = "Auto Claim Delay (seconds)",
    Description = "Delay between automatic claims",
    Min = 1,
    Max = 60,
    Value = DEFAULT_AUTO_DELAY,
    Step = 1,
    Callback = function(v)
        autoClaimDelay = v
    end
})

AutoSection:Paragraph({
    Title = "⚡ How it works",
    Content = "When enabled, the script will request a claim every configured number of seconds."
})

-- Quick claim section (right)
local QuickSection = MainTab:Section({
    Title = "⚡ Quick Claim",
    Icon = "zap",
    Opened = true
})

local quickAmounts = {100, 500, 1000, 5000, 10000, 50000, 100000}
for _, a in ipairs(quickAmounts) do
    QuickSection:Button({
        Title = "💵 Claim $"..tostring(a),
        Description = "Instant claim $"..tostring(a),
        Callback = (function(amount)
            return function()
                executeClaim(amount)
            end
        end)(a)
    })
end

QuickSection:Paragraph({
    Title = "📌 Quick Access",
    Content = "Use these buttons to quickly request common amounts."
})

-- Info section (right)
local InfoSection = MainTab:Section({
    Title = "ℹ️ Information",
    Icon = "info",
    Opened = true
})

InfoSection:Paragraph({
    Title = "💫 NovaAxis Hub",
    Content = "Version: 3.1-fixed\nGame: 99 Nights In The Forest\nAuthor: NovaAxis"
})

InfoSection:Paragraph({
    Title = "⌨️ Controls",
    Content = "Press Left Alt to toggle the UI. If the game changed remote names/locations, adjust accordingly."
})

-- -----------------------
-- UI Settings Tab
-- -----------------------
local UISettingsTab = Window:Tab({
    Title = "UI Settings",
    Icon = "settings"
})

local UISettingsSection = UISettingsTab:Section({
    Title = "🎨 UI Customization",
    Icon = "paintbrush",
    Opened = true
})

UISettingsSection:Paragraph({
    Title = "Theme",
    Content = "Current theme: Nova Neon (RGB 120,80,255). Change accent color below."
})

UISettingsSection:Toggle({
    Title = "Always Show Frame",
    Description = "Placeholder option (depends on WindUI features)",
    Value = false,
    Callback = function(v)
        Notify({ Title = "UI", Content = "Always Show Frame set to: "..tostring(v), Duration = 2 })
    end
})

-- Colorpicker: docs mention Colorpicker or Colorpicker spelled 'Colorpicker' in v2 — use that
UISettingsSection:Colorpicker({
    Title = "Highlight Color",
    Description = "Pick UI accent color",
    Default = Color3.fromRGB(120, 80, 255),
    Callback = function(color)
        WindUI:AddTheme({
            Name = "Nova Neon - Custom",
            Accent = color,
            Dialog = Color3.fromRGB(18, 18, 20),
            Outline = Color3.fromRGB(255, 255, 255),
            Text = Color3.fromRGB(230, 230, 230),
            Placeholder = Color3.fromRGB(130, 130, 140),
            Background = Color3.fromRGB(8, 8, 10),
            Button = Color3.fromRGB(50, 40, 60),
            Icon = Color3.fromRGB(190, 180, 255)
        })
        WindUI:SetTheme("Nova Neon - Custom")
        Notify({ Title = "Theme", Content = "Accent updated", Duration = 2 })
    end
})

UISettingsSection:Button({
    Title = "Get Theme Name",
    Description = "Copy current theme name to clipboard",
    Callback = function()
        pcall(function() setclipboard("Nova Neon") end)
        Notify({ Title = "Theme", Content = "Theme name copied", Duration = 2 })
    end
})

-- -----------------------
-- Config Tab
-- -----------------------
local ConfigTab = Window:Tab({
    Title = "Config",
    Icon = "folder"
})

local ConfigSection = ConfigTab:Section({
    Title = "Config Manager",
    Icon = "archive",
    Opened = true
})

ConfigSection:Paragraph({
    Title = "💾 Config",
    Content = "Save/load settings. Memory by default; file save/load available if your executor supports writefile/readfile."
})

ConfigSection:Button({
    Title = "Save to Memory",
    Description = "Save current settings into memory store",
    Callback = function()
        ConfigManager:SaveToMemory()
    end
})

ConfigSection:Button({
    Title = "Load from Memory",
    Description = "Load settings from the in-memory store",
    Callback = function()
        ConfigManager:LoadFromMemory()
    end
})

ConfigSection:Button({
    Title = "Save to Disk (if supported)",
    Description = "Write JSON config to disk using writefile",
    Callback = function()
        ConfigManager:SaveToDisk()
    end
})

ConfigSection:Button({
    Title = "Load from Disk (if supported)",
    Description = "Load JSON config from disk using readfile",
    Callback = function()
        ConfigManager:LoadFromDisk()
    end
})

-- -----------------------
-- Information Tab
-- -----------------------
local InfoTab = Window:Tab({
    Title = "Information",
    Icon = "info"
})

local InfoTabSection = InfoTab:Section({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Opened = true
})

InfoTabSection:Paragraph({
    Title = "About",
    Content = "NovaAxis Hub — WindUI v2 rewrite\nVersion: 3.1-fixed\nAuthor: NovaAxis"
})

InfoTabSection:Button({
    Title = "🌐 Discord Server",
    Description = "Copy invite to clipboard",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/Eg98P4wf2V") end)
        Notify({ Title = "Discord", Content = "Invite copied", Duration = 2 })
    end
})

InfoTabSection:Paragraph({
    Title = "Notes",
    Content = "If claims don't work, the game may have renamed/moved the remote. Search ReplicatedStorage for relevant remotes."
})

-- ========================
-- Final
-- ========================
DebugLog("NovaAxis Hub v3.1-fixed (WindUI v2) loaded.")
print("✅ NovaAxis Hub loaded — WindUI v2 (fixed).")
print("⌨️ Press Left Alt to toggle UI.")

-- End of script
