local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis Hub",
    Icon = "sparkles",
    Author = "NovaAxis",
    Transparent = true,
    Theme = "Nova Neon",
    Resizable = true,
    SideBarWidth = 240,
    BackgroundImageTransparency = 0.45,
    -- other WindUI-specific options can be added if supported
})

-- ============================
-- Theme: Nova Neon (RGB 120,80,255)
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


local MainTab = Window:Tab({
    Title = "Main",
    Icon = "zap", -- optional
    Locked = false,
})
        pcall(function() setclipboard("https://discord.gg/Eg98P4wf2V") end)
        Notify({ Title = "✅ Copied", Content = "Discord invite copied to clipboard!", Duration = 3, Icon = "copy" })
    end
})
