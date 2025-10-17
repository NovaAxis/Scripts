--[[
    💫 NovaAxis Hub - 99 Nights In The Forest (WindUI v2 rewrite)
    Author: NovaAxis (ported to WindUI v2)
    Version: 3.0-full
    Notes:
      - Полная версия, совместимая с WindUI v2 API (Window:Tab, Tab:Section, Section:Button/Slider/Toggle/etc).
      - Тема: Nova Neon (RGB 120,80,255).
      - Секции открыты сразу (Opened = true) — как в старом проекте.
      - Вкладки: Main (Claim/AutoClaim/QuickClaim), UI Settings, Config, Information.
      - Убираем Utility (по твоему требованию).
      - Скрипт автономен, загружает WindUI автоматически.
--]]

-- ============================
-- Load WindUI (v2-compatible)
-- ============================
local successWind, WindUI = pcall(function()
    -- URL used previously; if your executor blocks github, replace with your local host/loadstring.
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not successWind or not WindUI then
    warn("WindUI failed to load. Aborting UI creation.")
    return
end

-- ============================
-- Services
-- ============================
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- ============================
-- Constants & Defaults
-- ============================
local DEFAULT_CLAIM_AMOUNT = 100
local MIN_CLAIM_AMOUNT = 100
local MAX_CLAIM_AMOUNT = 100000

-- ============================
-- State
-- ============================
local claimAmount = DEFAULT_CLAIM_AMOUNT
local autoClaim = false
local autoClaimDelay = 5
local autoClaimActive = false

-- Keep-in-memory config store
local ConfigStore = {}

-- ============================
-- Theme: Nova Neon (120,80,255)
-- ============================
WindUI:AddTheme({
    Name = "Nova Neon",
    Accent = Color3.fromRGB(120, 80, 255),
    Dialog = Color3.fromRGB(18, 18, 20),
    Outline = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(230, 230, 230),
    Placeholder = Color3.fromRGB(130, 130, 140),
    Background = Color3.fromRGB(8, 8, 10),
    Button = Color3.fromRGB(50, 40, 60),
    Icon = Color3.fromRGB(190, 180, 255)
})
WindUI:SetTheme("Nova Neon")

-- ============================
-- Helpers: Notifications & Debug
-- ============================
local function Notify(opts)
    -- {Title, Content, Duration, Icon}
    WindUI:Notify({
        Title = opts.Title or "Notification",
        Content = opts.Content or "",
        Duration = opts.Duration or 3,
        Icon = opts.Icon or "activity"
    })
end

local function Debug(msg)
    msg = tostring(msg)
    print("[NovaAxis DEBUG] "..msg)
end

-- ============================
-- Config Manager (in-memory; placeholders for file IO)
-- ============================
local ConfigManager = {}
ConfigManager.Directory = "NovaAxis-99Nights"
ConfigManager.Config = "Default-Config"

function ConfigManager:Save(name)
    local n = name or self.Config
    ConfigStore[n] = {
        claimAmount = claimAmount,
        autoClaim = autoClaim,
        autoClaimDelay = autoClaimDelay
    }
    Notify({Title = "Config", Content = "Settings saved to memory ("..n..")", Duration = 2, Icon = "save"})
    return true
end

function ConfigManager:Load(name)
    local n = name or self.Config
    local cfg = ConfigStore[n]
    if not cfg then
        Notify({Title = "Config", Content = "No saved config found ("..n..")", Duration = 2, Icon = "alert-circle"})
        return false
    end
    claimAmount = cfg.claimAmount or claimAmount
    autoClaim = cfg.autoClaim or autoClaim
    autoClaimDelay = cfg.autoClaimDelay or autoClaimDelay
    Notify({Title = "Config", Content = "Config loaded ("..n..")", Duration = 2, Icon = "download"})
    return true
end

-- Optionally implement writefile/readfile depending on executor
local function fileAvailable()
    return type(writefile) == "function" and type(readfile) == "function"
end

function ConfigManager:SaveToDisk(name)
    if not fileAvailable() then
        Notify({Title="Config", Content="Filesystem unavailable (writefile/readfile). Using memory only.", Duration=3})
        return false
    end
    local n = name or self.Config
    local payload = HttpService:JSONEncode({
        claimAmount = claimAmount,
        autoClaim = autoClaim,
        autoClaimDelay = autoClaimDelay
    })
    pcall(function() writefile(self.Directory.."/"..n..".json", payload) end)
    Notify({Title="Config", Content="Saved to disk: "..n, Duration=3})
    return true
end

function ConfigManager:LoadFromDisk(name)
    if not fileAvailable() then
        Notify({Title="Config", Content="Filesystem unavailable (writefile/readfile).", Duration=3})
        return false
    end
    local n = name or self.Config
    local path = self.Directory.."/"..n..".json"
    if not pcall(function() return readfile(path) end) then
        Notify({Title="Config", Content="Config file not found: "..n, Duration=3})
        return false
    end
    local content = readfile(path)
    local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok then
        Notify({Title="Config", Content="Failed to parse config file: "..n, Duration=3})
        return false
    end
    claimAmount = data.claimAmount or claimAmount
    autoClaim = data.autoClaim or autoClaim
    autoClaimDelay = data.autoClaimDelay or autoClaimDelay
    Notify({Title="Config", Content="Loaded from disk: "..n, Duration=3})
    return true
end

-- ============================
-- Core: Claim function
-- ============================
local function executeClaim(amount)
    if type(amount) ~= "number" or amount <= 0 then
        Notify({Title="❌ Error", Content="Invalid claim amount", Duration=3, Icon="x"})
        return false
    end

    -- Attempt to find ClaimReward Remote
    local claimRemote = ReplicatedStorage:FindFirstChild("ClaimReward")
    if not claimRemote then
        -- some games put remotes under other folders; try a safer search
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v.Name == "ClaimReward" and v:IsA("RemoteEvent") then
                claimRemote = v
                break
            end
        end
    end

    if not claimRemote then
        Notify({Title="❌ Error", Content="ClaimReward remote not found", Duration=4, Icon="alert-circle"})
        return false
    end

    local ok, err = pcall(function()
        -- original script fired: claimEvent:FireServer("Money", amount)
        -- some games expect different args — if that fails, fallback to amount-only
        local successCall, successErr = pcall(function() claimRemote:FireServer("Money", amount) end)
        if not successCall then
            -- fallback
            pcall(function() claimRemote:FireServer(amount) end)
        end
    end)

    if ok then
        Notify({Title="✅ Claimed", Content="Requested claim: $"..tostring(amount), Duration=3, Icon="check"})
        return true
    else
        Notify({Title="❌ Error", Content="Failed to fire remote: "..tostring(err), Duration=4, Icon="alert-circle"})
        return false
    end
end

-- ============================
-- Auto-claim loop (background)
-- ============================
task.spawn(function()
    while true do
        task.wait(0.5)
        if autoClaim and not autoClaimActive then
            autoClaimActive = true
            local ok = pcall(function() executeClaim(claimAmount) end)
            if not ok then
                Debug("AutoClaim: executeClaim pcall failed")
            end
            -- wait for configured delay
            local waited = 0
            while autoClaim and waited < autoClaimDelay do
                task.wait(0.25); waited = waited + 0.25
            end
            autoClaimActive = false
        end
    end
end)

-- ============================
-- Build WindUI interface (v2 API)
-- ============================
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
    -- animations and effects similar to old project
    -- (assumes WindUI supports such options; if not, it's harmless)
})

Window:SetToggleKey(Enum.KeyCode.LeftAlt)

Notify({Title="💫 NovaAxis Hub", Content="Loaded — WindUI v2 interface ready", Duration=3, Icon="sparkles"})

-- ---------- Main Tab ----------
local MainTab = Window:Tab({ Title = "Main Features", Icon = "dollar-sign" })

-- Claim Section (left)
local ClaimSection = MainTab:Section({ Title = "💵 Claim Money", Icon = "credit-card", Opened = true })

ClaimSection:Slider({
    Title = "Claim Amount",
    Description = "Set amount to claim",
    Min = MIN_CLAIM_AMOUNT,
    Max = MAX_CLAIM_AMOUNT,
    Default = DEFAULT_CLAIM_AMOUNT,
    Round = 0,
    Value = DEFAULT_CLAIM_AMOUNT,
    Callback = function(value)
        claimAmount = value
    end
})

ClaimSection:Button({
    Title = "💰 Claim Money",
    Description = "Send claim request with selected amount",
    Callback = function()
        executeClaim(claimAmount)
    end
})

ClaimSection:Paragraph({
    Title = "ℹ️ Info",
    Content = "Use the slider to set amount and click Claim. If ClaimReward remote isn't found, the script will notify you."
})

-- Auto Claim Section (left)
local AutoSection = MainTab:Section({ Title = "🔄 Auto Claim", Icon = "repeat", Opened = true })

AutoSection:Toggle({
    Title = "Enable Auto Claim",
    Description = "Automatically claim every X seconds",
    Default = false,
    Callback = function(value)
        autoClaim = value
        if value then
            Notify({Title="✅ Auto Claim", Content="Auto Claim enabled", Duration=2, Icon="play"})
        else
            Notify({Title="⏸ Auto Claim", Content="Auto Claim disabled", Duration=2, Icon="pause"})
        end
    end
})

AutoSection:Slider({
    Title = "Auto Claim Delay (seconds)",
    Description = "Delay between automatic claims",
    Min = 1,
    Max = 60,
    Default = 5,
    Round = 0,
    Value = 5,
    Callback = function(value)
        autoClaimDelay = value
    end
})

AutoSection:Paragraph({
    Title = "⚡ How it works",
    Content = "When enabled, the script automatically triggers claim with configured amount every X seconds."
})

-- Quick Claim Section (right)
local QuickSection = MainTab:Section({ Title = "⚡ Quick Claim", Icon = "zap", Opened = true })

local quickAmounts = {100, 500, 1000, 5000, 10000, 50000, 100000}
for _, amt in ipairs(quickAmounts) do
    QuickSection:Button({
        Title = "💵 Claim $"..tostring(amt),
        Description = "Instant claim $"..tostring(amt),
        Callback = (function(a) return function() executeClaim(a) end end)(amt)
    })
end

QuickSection:Paragraph({
    Title = "📌 Quick Access",
    Content = "Use these buttons to immediately send a claim request for common amounts."
})

-- Info Section (right)
local InfoSection = MainTab:Section({ Title = "ℹ️ Information", Icon = "info", Opened = true })

InfoSection:Paragraph({
    Title = "💫 NovaAxis Hub",
    Content = "Version: 3.0-full\nGame: 99 Nights In The Forest\nAuthor: NovaAxis"
})

InfoSection:Paragraph({
    Title = "⌨️ Controls",
    Content = "Press Left Alt to toggle the UI. Use sliders/buttons to control claims."
})

-- ---------- UI Settings Tab ----------
local UISettingsTab = Window:Tab({ Title = "UI Settings", Icon = "settings" })
local UISettingsSection = UISettingsTab:Section({ Title = "🎨 UI Customization", Icon = "paintbrush", Opened = true })

UISettingsSection:Paragraph({
    Title = "Theme",
    Content = "Current theme: Nova Neon (RGB 120,80,255). Customize accent color below."
})

UISettingsSection:Toggle({
    Title = "Always Show Frame",
    Description = "Placeholder — show window always (if supported)",
    Default = false,
    Callback = function(v)
        -- Placeholder: WindUI may not expose this directly
        Notify({Title="UI Setting", Content="Always Show Frame set to: "..tostring(v), Duration=2})
    end
})

UISettingsSection:Colorpicker({
    Title = "Highlight Color",
    Description = "Change accent color",
    Default = Color3.fromRGB(120,80,255),
    Callback = function(color)
        WindUI:AddTheme({
            Name = "Nova Neon - Custom",
            Accent = color,
            Dialog = Color3.fromRGB(18, 18, 20),
            Outline = Color3.fromRGB(255,255,255),
            Text = Color3.fromRGB(230,230,230),
            Placeholder = Color3.fromRGB(130,130,140),
            Background = Color3.fromRGB(8,8,10),
            Button = Color3.fromRGB(50,40,60),
            Icon = Color3.fromRGB(190,180,255)
        })
        WindUI:SetTheme("Nova Neon - Custom")
        Notify({Title="Theme", Content="Accent updated", Duration=2})
    end
})

UISettingsSection:Button({
    Title = "Get Theme Name",
    Description = "Copy current theme name to clipboard",
    Callback = function()
        pcall(function() setclipboard("Nova Neon") end)
        Notify({Title="Theme", Content="Theme name copied", Duration=2})
    end
})

-- ---------- Config Tab ----------
local ConfigTab = Window:Tab({ Title = "Config", Icon = "folder" })
local ConfigSection = ConfigTab:Section({ Title = "Config Manager", Icon = "archive", Opened = true })

ConfigSection:Paragraph({
    Title = "💾 Config",
    Content = "Save/load your settings. Memory storage by default; file storage available if executor supports writefile/readfile."
})

ConfigSection:Button({
    Title = "Save (memory)",
    Description = "Save settings to memory store",
    Callback = function()
        ConfigManager:Save()
    end
})

ConfigSection:Button({
    Title = "Load (memory)",
    Description = "Load settings from memory store",
    Callback = function()
        ConfigManager:Load()
    end
})

ConfigSection:Button({
    Title = "Save to Disk (if supported)",
    Description = "Write JSON config to disk (writefile/readfile must be available)",
    Callback = function()
        ConfigManager:SaveToDisk()
    end
})

ConfigSection:Button({
    Title = "Load from Disk (if supported)",
    Description = "Load JSON config from disk",
    Callback = function()
        ConfigManager:LoadFromDisk()
    end
})

-- ---------- Information Tab ----------
local InfoTab = Window:Tab({ Title = "Information", Icon = "info" })
local InfoTabSection = InfoTab:Section({ Title = "💫 NovaAxis Hub", Icon = "sparkles", Opened = true })

InfoTabSection:Paragraph({
    Title = "About",
    Content = "NovaAxis Hub — WindUI v2 rewrite\nVersion: 3.0-full\nAuthor: NovaAxis"
})

InfoTabSection:Button({
    Title = "🌐 Discord Server",
    Description = "Copy invite to clipboard",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/Eg98P4wf2V") end)
        Notify({Title="Discord", Content="Discord invite copied", Duration=2})
    end
})

InfoTabSection:Paragraph({
    Title = "Notes",
    Content = "If the ClaimReward remote is missing or not working, check the game's ReplicatedStorage for remote names/structure."
})

-- ============================
-- Final messages
-- ============================
Debug("NovaAxis Hub v3.0 UI built (WindUI v2). Sections opened by default.")
print("✅ NovaAxis Hub (99 Nights) loaded successfully.")
print("⌨️ Press Left Alt to toggle UI")

-- End of script
