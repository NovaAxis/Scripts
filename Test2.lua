local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis",
    Icon = "sparkles", -- lucide icon. optional
    Author = "NovaAxis", -- optional
    Window.Icon:Enable()
    User = true
})

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

local UISettingsTab = Window:Tab({ Icon = "settings", Title = "UI Settings", EnableScrolling = true })
local UISettingsSection = UISettingsTab:Section({ Title = "🎨 UI Customization", Icon = "paintbrush", Opened = true })
UISettingsSection:Paragraph({ Title = "Theme", Content = "Текущая тема: Nova Neon (Accent: RGB 120,80,255). Настройте акцентный цвет ниже." })
UISettingsSection:Toggle({
    Title = "Always Show Frame",
    Default = false,
    Callback = function(v)
        if v then Notify({ Title = "UI", Content = "Always Show Frame enabled (placeholder).", Duration = 2 }) 
        else Notify({ Title = "UI", Content = "Always Show Frame disabled (placeholder).", Duration = 2 }) end
    end
})
UISettingsSection:Colorpicker({
    Title = "Highlight Color",
    Default = Color3.fromRGB(120, 80, 255),
    Callback = function(v)
        WindUI:AddTheme({
            Name = "Nova Neon - Custom",
            Accent = v,
            Dialog = Color3.fromRGB(18, 18, 20),
            Outline = Color3.fromRGB(255, 255, 255),
            Text = Color3.fromRGB(230, 230, 230),
            Placeholder = Color3.fromRGB(130, 130, 140),
            Background = Color3.fromRGB(8, 8, 10),
            Button = Color3.fromRGB(50, 40, 60),
            Icon = Color3.fromRGB(190, 180, 255)
        })
        WindUI:SetTheme("Nova Neon - Custom")
    end
})
UISettingsSection:Button({
    Title = "Get Theme Name",
    Callback = function()
        pcall(function() setclipboard("Nova Neon") end)
        Notify({ Title = "✅ Theme Copied", Content = "Theme name copied to clipboard!", Duration = 3 })
    end
})
