--[[ 
    💫 NovaAxis Hub - 99 Nights In The Forest (WindUI port)
    Author: NovaAxis (ported)
    Version: 2.5 -> WindUI port
    Toggle Key: LeftAlt
]]

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ========== Services & player ==========
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ========== State ==========
local claimAmount = 100
local autoClaim = false
local autoClaimActive = false
local autoClaimDelay = 5
local scriptVersion = "v2.5 (WindUI)"
local watermarkTimerHandle

-- ========== Utility Helpers ==========
local function SafeNotify(opts)
    pcall(function()
        if WindUI.Notify and type(WindUI.Notify) == "function" then
            WindUI:Notify(opts)
        else
            -- fallback print
            print("[Notify]", opts.Title or "", opts.Content or opts.Desc or "")
        end
    end)
end

local function SafeClipboard(text)
    if setclipboard then
        pcall(setclipboard, text)
        SafeNotify({ Title = "📋 Copied", Content = "Copied to clipboard!" })
        return true
    else
        SafeNotify({ Title = "⚠️ Clipboard", Content = "Clipboard unavailable" })
        return false
    end
end

local function SafeFireClaim(amount)
    local okf, err = pcall(function()
        local event = ReplicatedStorage:WaitForChild("ClaimReward", 5)
        if not event then
            error("ClaimReward remote not found")
        end
        -- old code used args = {"Money", amount}
        event:FireServer("Money", amount)
    end)
    return okf, err
end

-- ========== Create Window ==========
local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Author = "NovaAxis",
    Transparent = true,
    Theme = "Nova Neon",
    Resizable = true,
    SideBarWidth = 240,
    BackgroundImageTransparency = 0.45,
    Keybind = Enum.KeyCode.LeftAlt, -- optional if WindUI supports direct keybind
})

-- If WindUI doesn't accept Keybind in CreateWindow, set manual keybind:
if Window and not Window.ToggleKey and Window.SetToggleKey then
    pcall(function() Window:SetToggleKey(Enum.KeyCode.LeftAlt) end)
end

-- ========== Theme (Nova Neon) ==========
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

-- ========== Config Manager ==========
-- Prefer WindUI config manager if available, otherwise create a simple fallback
local ConfigManager
if Window and Window.ConfigManager then
    ConfigManager = Window.ConfigManager
else
    -- fallback simple manager (saves to Roblox's HttpService Encode/Decode in globals)
    ConfigManager = {
        configs = {},
        CreateConfig = function(_, name)
            local cfg = {
                Name = name or "default",
                Save = function(self)
                    -- attempt to save to getgenv if exists
                    pcall(function()
                        if getgenv then
                            getgenv().NovaAxis_Config = getgenv().NovaAxis_Config or {}
                            getgenv().NovaAxis_Config[self.Name] = {
                                claimAmount = claimAmount,
                                autoClaim = autoClaim,
                                autoClaimDelay = autoClaimDelay
                            }
                        end
                    end)
                    return true
                end,
                Load = function(self)
                    pcall(function()
                        if getgenv and getgenv().NovaAxis_Config and getgenv().NovaAxis_Config[self.Name] then
                            local data = getgenv().NovaAxis_Config[self.Name]
                            claimAmount = data.claimAmount or claimAmount
                            autoClaim = data.autoClaim or autoClaim
                            autoClaimDelay = data.autoClaimDelay or autoClaimDelay
                        end
                    end)
                    return true
                end
            }
            return cfg
        end,
        AllConfigs = function() return {} end
    }
end

-- ========== Watermark ==========
local Watermark = Window:Watermark and Window:Watermark() or nil
if Watermark then
    Watermark:AddText({ Icon = "user", Text = "NovaAxis" })
    Watermark:AddText({ Icon = "activity", Text = scriptVersion })
    Watermark:AddText({ Icon = "clock", Text = WindUI:GetDate and WindUI:GetDate() or os.date("%x") })

    local TimeText = Watermark:AddText({ Icon = "timer", Text = "TIME" })
    watermarkTimerHandle = task.spawn(function()
        while Watermark and task.wait(1) do
            local t = (WindUI.GetTimeNow and WindUI:GetTimeNow()) or os.date("%X")
            pcall(function() TimeText:SetText(t) end)
        end
    end)
end

-- ========== Claim function ==========
local function executeClaim(amount)
    if not amount or type(amount) ~= "number" or amount <= 0 then
        SafeNotify({
            Title = "❌ Error",
            Content = "Invalid amount entered!"
        })
        return false
    end

    local ok, err = SafeFireClaim(amount)
    if ok then
        SafeNotify({
            Title = "✅ Success",
            Content = "Claimed $" .. tostring(amount) .. "!",
            Duration = 3
        })
        return true
    else
        SafeNotify({
            Title = "❌ Error",
            Content = "Failed to claim money (" .. tostring(err) .. ")",
            Duration = 4
        })
        return false
    end
end

-- ========== Auto claim loop ==========
task.spawn(function()
    while task.wait(0.5) do
        if autoClaim and not autoClaimActive then
            autoClaimActive = true
            executeClaim(claimAmount)
            local waited = 0
            local delay = (type(autoClaimDelay) == "number" and autoClaimDelay) or 5
            while waited < delay do
                task.wait(1)
                waited = waited + 1
                if not autoClaim then break end
            end
            autoClaimActive = false
        end
    end
end)

-- ========== UI Structure ==========
-- Main Category
Window:Tab({ Title = "Money Farm", Icon = "dollar-sign" })
local MainTab = Window:Tab({ Title = "Main Features", Icon = "zap", EnableScrolling = true })

-- Claim Section (left)
local ClaimSection = MainTab:Section({ Title = "💵 Claim Money", Side = "Left" })

ClaimSection:Slider({
    Title = "Claim Amount",
    Min = 100,
    Max = 100000,
    Default = claimAmount,
    Round = 0,
    Callback = function(value)
        claimAmount = value
    end
})

ClaimSection:Button({
    Title = "💰 Claim Money",
    Callback = function()
        executeClaim(claimAmount)
    end
})

ClaimSection:Paragraph({
    Title = "ℹ️ Info",
    Content = "Use the slider to set the amount, then click the button to claim money."
})

-- Auto Claim Section (left)
local AutoSection = MainTab:Section({ Title = "🔄 Auto Claim", Side = "Left" })

AutoSection:Toggle({
    Title = "Enable Auto Claim",
    Default = autoClaim,
    Callback = function(v)
        autoClaim = v
        SafeNotify({
            Title = v and "✅ Enabled" or "⏸️ Disabled",
            Content = v and "Auto Claim is now active!" or "Auto Claim has been stopped.",
            Duration = 3
        })
    end
})

AutoSection:Slider({
    Title = "Auto Claim Delay (seconds)",
    Min = 1,
    Max = 60,
    Default = autoClaimDelay,
    Round = 0,
    Callback = function(value)
        autoClaimDelay = value
    end
})

AutoSection:Paragraph({
    Title = "⚡ How it works",
    Content = "When enabled, this will attempt to claim the set amount every X seconds."
})

-- Quick Claim Section (right)
local QuickSection = MainTab:Section({ Title = "⚡ Quick Claim", Side = "Right" })

local quickAmounts = {100,500,1000,5000,10000,50000,100000}
for _, v in ipairs(quickAmounts) do
    QuickSection:Button({
        Title = ("Claim $%s"):format(tostring(v)),
        Callback = (function(amount) return function() executeClaim(amount) end end)(v)
    })
end

QuickSection:Paragraph({
    Title = "📌 Quick Access",
    Content = "Use these buttons for instant claims of preset amounts."
})

-- Info Section (right)
local InfoSection = MainTab:Section({ Title = "ℹ️ Information", Side = "Right" })

InfoSection:Paragraph({
    Title = "💫 NovaAxis Hub",
    Content = ("Version: %s\nGame: 99 Nights In The Forest\nCreated by: NovaAxis"):format(scriptVersion)
})

InfoSection:Button({
    Title = "📋 Copy GitHub",
    Callback = function()
        SafeClipboard("https://github.com/NovaAxis")
    end
})

InfoSection:Paragraph({
    Title = "⌨️ Controls",
    Content = "Press Left Alt to toggle UI\nUse slider or quick buttons to claim money"
})

-- ========== Settings Category ==========
Window:Tab({ Title = "Settings", Icon = "settings" })
local SettingTab = Window:Tab({ Title = "UI Settings", Icon = "palette", EnableScrolling = true })

local SettingsSection = SettingTab:Section({ Title = "🎨 UI Customization" })

SettingsSection:Toggle({
    Title = "Always Show Frame",
    Default = false,
    Callback = function(v)
        -- many WindUIs have a property to always show, fallback:
        pcall(function()
            if Window.AlwaysShowTab ~= nil then
                Window.AlwaysShowTab = v
            else
                -- attempt to set property if exists
                if Window.SetAlwaysShow then Window:SetAlwaysShow(v) end
            end
        end)
    end
})

-- Color pickers (safe: check Compkiller.Colors fallback)
local colors = {
    Highlight = Color3.fromRGB(120,80,255),
    Toggle = Color3.fromRGB(80,200,120),
    BG = Color3.fromRGB(8,8,10)
}

SettingsSection:Colorpicker({
    Title = "Highlight Color",
    Default = colors.Highlight,
    Callback = function(c)
        pcall(function() 
            if WindUI.SetAccentColor then
                WindUI:SetAccentColor(c)
            end
        end)
    end
})

SettingsSection:Colorpicker({
    Title = "Toggle Color",
    Default = colors.Toggle,
    Callback = function(c)
        -- no universal method: set accent again as a simple approach
        pcall(function() if WindUI.SetAccentColor then WindUI:SetAccentColor(c) end end)
    end
})

SettingsSection:Colorpicker({
    Title = "Background Color",
    Default = colors.BG,
    Callback = function(c)
        -- not all UIs support BG change live; attempt to set theme background if possible
        pcall(function()
            WindUI:AddTheme({
                Name = "Custom Background",
                Accent = WindUI:GetTheme and (WindUI:GetTheme().Accent or Color3.fromRGB(120,80,255)) or Color3.fromRGB(120,80,255),
                Dialog = c,
                Outline = Color3.fromRGB(255,255,255),
                Text = Color3.fromRGB(230,230,230),
                Placeholder = Color3.fromRGB(130,130,140),
                Background = c,
                Button = Color3.fromRGB(50,40,60),
                Icon = Color3.fromRGB(190,180,255)
            })
            WindUI:SetTheme("Custom Background")
        end)
    end
})

SettingsSection:Button({
    Title = "Get Theme (copy)",
    Callback = function()
        local theme = nil
        pcall(function() theme = WindUI:GetTheme() end)
        local json = "null"
        if theme then
            pcall(function() json = HttpService:JSONEncode({
                Name = theme.Name,
                Accent = {theme.Accent.R, theme.Accent.G, theme.Accent.B}
            }) end)
        end
        SafeClipboard(json)
        SafeNotify({ Title = "✅ Theme Copied", Content = "Theme settings copied to clipboard!", Duration = 3 })
    end
})

-- ========== Theme Tab ==========
local ThemeTab = Window:Tab({ Title = "Themes", Icon = "paintbrush" })
local ThemeSection = ThemeTab:Section({ Title = "🎨 UI Themes" })

local themeList = {"Nova Neon", "Default", "Dark Green", "Dark Blue", "Purple Rose", "Skeet"}
ThemeSection:Dropdown({
    Title = "Select Theme",
    Values = themeList,
    Value = "Nova Neon",
    Callback = function(v)
        pcall(function() WindUI:SetTheme(v) end)
    end
})

-- ========== Config Tab ==========
local ConfigTab = Window:Tab({ Title = "Config", Icon = "folder" })
if Window.ConfigManager then
    -- assume WindUI provides a config UI
    local UIConfig = Window:Config({
        Title = "Config Manager",
        Manager = Window.ConfigManager
    })
    if UIConfig and UIConfig.Init then
        pcall(function() UIConfig:Init() end)
    end
else
    -- fallback simple save/load
    ConfigTab:Button({
        Title = "Save Config (simple)",
        Callback = function()
            local cfg = ConfigManager:CreateConfig("default")
            cfg:Save()
            SafeNotify({ Title = "✅ Saved", Content = "Config saved (fallback)" })
        end
    })
    ConfigTab:Button({
        Title = "Load Config (simple)",
        Callback = function()
            local cfg = ConfigManager:CreateConfig("default")
            cfg:Load()
            SafeNotify({ Title = "🔄 Loaded", Content = "Config loaded (fallback)" })
        end
    })
end

-- ========== Final Notifications & prints ==========
SafeNotify({
    Title = "💫 NovaAxis Hub",
    Content = "Successfully loaded for 99 Nights In The Forest!",
    Duration = 5
})

print("✅ NovaAxis Hub (WindUI) loaded successfully!")
print("⌨️ Press Left Alt to toggle UI")
print("💰 Game: 99 Nights In The Forest")

-- End of script
