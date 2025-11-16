-- THEME TAB
local ThemeTab = Window:Tab({
    Title = "Theme",
    Icon = "app-window-mac",
})

-- THEME SECTION
local ThemeSection = ThemeTab:Section({ 
    Title = "Theme",
    Icon = "app-window-mac",
    Opened = true,
})

--==============--
--  THEME LIST  --
--==============--

local function Themes(WindUI)
    return {

        ---------------------------
        --        DARK
        ---------------------------
        Dark = {
            Name = "Dark",
            Accent = Color3.fromHex("#18181b"),
            Dialog = Color3.fromHex("#161616"),
            Outline = Color3.fromHex("#FFFFFF"),
            Text = Color3.fromHex("#FFFFFF"),
            Placeholder = Color3.fromHex("#7a7a7a"),
            Background = Color3.fromHex("#101010"),
            Button = Color3.fromHex("#52525b"),
            Icon = Color3.fromHex("#a1a1aa"),
            Toggle = Color3.fromHex("#33C759"),
            Checkbox = Color3.fromHex("#0091ff"),
        },

        ---------------------------
        --        LIGHT
        ---------------------------
        Light = {
            Name = "Light",
            Accent = Color3.fromHex("#e5e5e5"),
            Dialog = Color3.fromHex("#ffffff"),
            Outline = Color3.fromHex("#000000"),
            Text = Color3.fromHex("#212121"),
            Placeholder = Color3.fromHex("#767676"),
            Background = Color3.fromHex("#f5f5f5"),
            Button = Color3.fromHex("#d4d4d4"),
            Icon = Color3.fromHex("#525252"),
            Toggle = Color3.fromHex("#34C759"),
            Checkbox = Color3.fromHex("#0A84FF"),
        },

        ---------------------------
        --       ROSE
        ---------------------------
        Rose = {
            Name = "Rose",
            Accent = Color3.fromHex("#fb7185"),
            Dialog = Color3.fromHex("#fda4af"),
            Outline = Color3.fromHex("#881337"),
            Text = Color3.fromHex("#831843"),
            Placeholder = Color3.fromHex("#fbcfe8"),
            Background = Color3.fromHex("#ffe4e6"),
            Button = Color3.fromHex("#f43f5e"),
            Icon = Color3.fromHex("#be185d"),
            Toggle = Color3.fromHex("#e11d48"),
            Checkbox = Color3.fromHex("#9d174d"),
        },

        ---------------------------
        --        PLANT
        ---------------------------
        Plant = {
            Name = "Plant",
            Accent = Color3.fromHex("#15803d"),
            Dialog = Color3.fromHex("#166534"),
            Outline = Color3.fromHex("#052e16"),
            Text = Color3.fromHex("#14532d"),
            Placeholder = Color3.fromHex("#4ade80"),
            Background = Color3.fromHex("#dcfce7"),
            Button = Color3.fromHex("#22c55e"),
            Icon = Color3.fromHex("#16a34a"),
            Toggle = Color3.fromHex("#86efac"),
            Checkbox = Color3.fromHex("#22c55e"),
        },

        ---------------------------
        --        RED
        ---------------------------
        Red = {
            Name = "Red",
            Accent = Color3.fromHex("#ef4444"),
            Dialog = Color3.fromHex("#dc2626"),
            Outline = Color3.fromHex("#7f1d1d"),
            Text = Color3.fromHex("#b91c1c"),
            Placeholder = Color3.fromHex("#fecaca"),
            Background = Color3.fromHex("#fee2e2"),
            Button = Color3.fromHex("#f87171"),
            Icon = Color3.fromHex("#ef4444"),
            Toggle = Color3.fromHex("#dc2626"),
            Checkbox = Color3.fromHex("#b91c1c"),
        },

        ---------------------------
        --       INDIGO
        ---------------------------
        Indigo = {
            Name = "Indigo",
            Accent = Color3.fromHex("#6366f1"),
            Dialog = Color3.fromHex("#4f46e5"),
            Outline = Color3.fromHex("#3730a3"),
            Text = Color3.fromHex("#312e81"),
            Placeholder = Color3.fromHex("#a5b4fc"),
            Background = Color3.fromHex("#eef2ff"),
            Button = Color3.fromHex("#818cf8"),
            Icon = Color3.fromHex("#6366f1"),
            Toggle = Color3.fromHex("#4f46e5"),
            Checkbox = Color3.fromHex("#4338ca"),
        },

        ---------------------------
        --         SKY
        ---------------------------
        Sky = {
            Name = "Sky",
            Accent = Color3.fromHex("#0ea5e9"),
            Dialog = Color3.fromHex("#0284c7"),
            Outline = Color3.fromHex("#075985"),
            Text = Color3.fromHex("#0369a1"),
            Placeholder = Color3.fromHex("#7dd3fc"),
            Background = Color3.fromHex("#e0f2fe"),
            Button = Color3.fromHex("#38bdf8"),
            Icon = Color3.fromHex("#0ea5e9"),
            Toggle = Color3.fromHex("#0284c7"),
            Checkbox = Color3.fromHex("#0369a1"),
        },

        ---------------------------
        --       VIOLET
        ---------------------------
        Violet = {
            Name = "Violet",
            Accent = Color3.fromHex("#8b5cf6"),
            Dialog = Color3.fromHex("#7c3aed"),
            Outline = Color3.fromHex("#5b21b6"),
            Text = Color3.fromHex("#4c1d95"),
            Placeholder = Color3.fromHex("#c4b5fd"),
            Background = Color3.fromHex("#ede9fe"),
            Button = Color3.fromHex("#a78bfa"),
            Icon = Color3.fromHex("#8b5cf6"),
            Toggle = Color3.fromHex("#7c3aed"),
            Checkbox = Color3.fromHex("#6d28d9"),
        },

        ---------------------------
        --       AMBER
        ---------------------------
        Amber = {
            Name = "Amber",
            Accent = Color3.fromHex("#f59e0b"),
            Dialog = Color3.fromHex("#d97706"),
            Outline = Color3.fromHex("#78350f"),
            Text = Color3.fromHex("#92400e"),
            Placeholder = Color3.fromHex("#fcd34d"),
            Background = Color3.fromHex("#fef3c7"),
            Button = Color3.fromHex("#fbbf24"),
            Icon = Color3.fromHex("#f59e0b"),
            Toggle = Color3.fromHex("#d97706"),
            Checkbox = Color3.fromHex("#b45309"),
        },

        ---------------------------
        --      EMERALD
        ---------------------------
        Emerald = {
            Name = "Emerald",
            Accent = Color3.fromHex("#10b981"),
            Dialog = Color3.fromHex("#059669"),
            Outline = Color3.fromHex("#064e3b"),
            Text = Color3.fromHex("#047857"),
            Placeholder = Color3.fromHex("#6ee7b7"),
            Background = Color3.fromHex("#d1fae5"),
            Button = Color3.fromHex("#34d399"),
            Icon = Color3.fromHex("#10b981"),
            Toggle = Color3.fromHex("#059669"),
            Checkbox = Color3.fromHex("#047857"),
        },

        ---------------------------
        --      MIDNIGHT
        ---------------------------
        Midnight = {
            Name = "Midnight",
            Accent = Color3.fromHex("#0f172a"),
            Dialog = Color3.fromHex("#1e293b"),
            Outline = Color3.fromHex("#334155"),
            Text = Color3.fromHex("#f1f5f9"),
            Placeholder = Color3.fromHex("#94a3b8"),
            Background = Color3.fromHex("#020617"),
            Button = Color3.fromHex("#475569"),
            Icon = Color3.fromHex("#64748b"),
            Toggle = Color3.fromHex("#1e293b"),
            Checkbox = Color3.fromHex("#334155"),
        },

        ---------------------------
        --      CRIMSON
        ---------------------------
        Crimson = {
            Name = "Crimson",
            Accent = Color3.fromHex("#dc143c"),
            Dialog = Color3.fromHex("#b01030"),
            Outline = Color3.fromHex("#7a0a23"),
            Text = Color3.fromHex("#ffffff"),
            Placeholder = Color3.fromHex("#ffccd5"),
            Background = Color3.fromHex("#ffe6ea"),
            Button = Color3.fromHex("#ff4d6a"),
            Icon = Color3.fromHex("#dc143c"),
            Toggle = Color3.fromHex("#b01030"),
            Checkbox = Color3.fromHex("#7a0a23"),
        },

        ---------------------------
        --        MONOKAI
        ---------------------------
        MonokaiPro = {
            Name = "MonokaiPro",
            Accent = Color3.fromHex("#fc9867"),
            Dialog = Color3.fromHex("#222222"),
            Outline = Color3.fromHex("#75715e"),
            Text = Color3.fromHex("#f8f8f2"),
            Placeholder = Color3.fromHex("#75715e"),
            Background = Color3.fromHex("#1e1e1e"),
            Button = Color3.fromHex("#66d9ef"),
            Icon = Color3.fromHex("#ae81ff"),
            Toggle = Color3.fromHex("#a6e22e"),
            Checkbox = Color3.fromHex("#f92672"),
        },

        ---------------------------
        --     COTTON CANDY
        ---------------------------
        CottonCandy = {
            Name = "CottonCandy",
            Accent = Color3.fromHex("#ff9ae5"),
            Dialog = Color3.fromHex("#ff7ad1"),
            Outline = Color3.fromHex("#ff5cbc"),
            Text = Color3.fromHex("#6a1b4d"),
            Placeholder = Color3.fromHex("#ffc8ef"),
            Background = Color3.fromHex("#ffe4f7"),
            Button = Color3.fromHex("#ffb4e2"),
            Icon = Color3.fromHex("#ff6fcb"),
            Toggle = Color3.fromHex("#ff4ab8"),
            Checkbox = Color3.fromHex("#d61e8d"),
        },

        ---------------------------
        --        OCEAN
        ---------------------------
        Ocean = {
            Name = "Ocean",
            Accent = Color3.fromHex("#0077b6"),
            Dialog = Color3.fromHex("#023e8a"),
            Outline = Color3.fromHex("#03045e"),
            Text = Color3.fromHex("#caf0f8"),
            Placeholder = Color3.fromHex("#90e0ef"),
            Background = Color3.fromHex("#ade8f4"),
            Button = Color3.fromHex("#0096c7"),
            Icon = Color3.fromHex("#48cae4"),
            Toggle = Color3.fromHex("#0077b6"),
            Checkbox = Color3.fromHex("#023e8a"),
        },

        ---------------------------
        --         LAVA
        ---------------------------
        Lava = {
            Name = "Lava",
            Accent = Color3.fromHex("#ff5733"),
            Dialog = Color3.fromHex("#c70039"),
            Outline = Color3.fromHex("#900c3f"),
            Text = Color3.fromHex("#fce4ec"),
            Placeholder = Color3.fromHex("#ffb3b3"),
            Background = Color3.fromHex("#ffe6e6"),
            Button = Color3.fromHex("#ff7961"),
            Icon = Color3.fromHex("#ff1744"),
            Toggle = Color3.fromHex("#d50000"),
            Checkbox = Color3.fromHex("#9a0007"),
        },

        ---------------------------
        --      CYBERPUNK
        ---------------------------
        Cyberpunk = {
            Name = "Cyberpunk",
            Accent = Color3.fromHex("#ff009d"),
            Dialog = Color3.fromHex("#2b0057"),
            Outline = Color3.fromHex("#00eaff"),
            Text = Color3.fromHex("#ffea00"),
            Placeholder = Color3.fromHex("#ff9de2"),
            Background = Color3.fromHex("#0a001a"),
            Button = Color3.fromHex("#7a00cc"),
            Icon = Color3.fromHex("#00eaff"),
            Toggle = Color3.fromHex("#ff009d"),
            Checkbox = Color3.fromHex("#00eaff"),
        },

        ---------------------------
        --         NEON
        ---------------------------
        Neon = {
            Name = "Neon",
            Accent = Color3.fromHex("#39ff14"),
            Dialog = Color3.fromHex("#0d240a"),
            Outline = Color3.fromHex("#00ff9d"),
            Text = Color3.fromHex("#ccffcc"),
            Placeholder = Color3.fromHex("#99ff99"),
            Background = Color3.fromHex("#072f0a"),
            Button = Color3.fromHex("#1aff1a"),
            Icon = Color3.fromHex("#39ff14"),
            Toggle = Color3.fromHex("#00ff44"),
            Checkbox = Color3.fromHex("#00cc33"),
        },

        ---------------------------
        --          ICE
        ---------------------------
        Ice = {
            Name = "Ice",
            Accent = Color3.fromHex("#a8e6ff"),
            Dialog = Color3.fromHex("#e0f7ff"),
            Outline = Color3.fromHex("#6ecaff"),
            Text = Color3.fromHex("#003c5f"),
            Placeholder = Color3.fromHex("#b9eaff"),
            Background = Color3.fromHex("#f2fbff"),
            Button = Color3.fromHex("#82d9ff"),
            Icon = Color3.fromHex("#66ccff"),
            Toggle = Color3.fromHex("#4dc3ff"),
            Checkbox = Color3.fromHex("#009fe6"),
        },

        ---------------------------
        --        GALAXY
        ---------------------------
        Galaxy = {
            Name = "Galaxy",
            Accent = Color3.fromHex("#6a0dad"),
            Dialog = Color3.fromHex("#12002f"),
            Outline = Color3.fromHex("#ae00ff"),
            Text = Color3.fromHex("#e0b3ff"),
            Placeholder = Color3.fromHex("#d580ff"),
            Background = Color3.fromHex("#0a001a"),
            Button = Color3.fromHex("#8a2be2"),
            Icon = Color3.fromHex("#bf00ff"),
            Toggle = Color3.fromHex("#6a0dad"),
            Checkbox = Color3.fromHex("#ae00ff"),
        },

        ---------------------------
        --        SUNSET
        ---------------------------
        Sunset = {
            Name = "Sunset",
            Accent = Color3.fromHex("#ff5e62"),
            Dialog = Color3.fromHex("#fb6a4a"),
            Outline = Color3.fromHex("#ff3b30"),
            Text = Color3.fromHex("#7f1d1d"),
            Placeholder = Color3.fromHex("#ffc4b3"),
            Background = Color3.fromHex("#ffe0d6"),
            Button = Color3.fromHex("#ff7f50"),
            Icon = Color3.fromHex("#ff5e62"),
            Toggle = Color3.fromHex("#ff3b30"),
            Checkbox = Color3.fromHex("#b91c1c"),
        },

        ---------------------------
        --        TOXIC
        ---------------------------
        Toxic = {
            Name = "Toxic",
            Accent = Color3.fromHex("#39ff14"),
            Dialog = Color3.fromHex("#1b3b00"),
            Outline = Color3.fromHex("#5fff00"),
            Text = Color3.fromHex("#ccffcc"),
            Placeholder = Color3.fromHex("#b3ffb3"),
            Background = Color3.fromHex("#0f2600"),
            Button = Color3.fromHex("#66ff33"),
            Icon = Color3.fromHex("#39ff14"),
            Toggle = Color3.fromHex("#5fff00"),
            Checkbox = Color3.fromHex("#39cc14"),
        },

        ---------------------------
        --        STEEL
        ---------------------------
        Steel = {
            Name = "Steel",
            Accent = Color3.fromHex("#6c757d"),
            Dialog = Color3.fromHex("#495057"),
            Outline = Color3.fromHex("#adb5bd"),
            Text = Color3.fromHex("#e9ecef"),
            Placeholder = Color3.fromHex("#ced4da"),
            Background = Color3.fromHex("#212529"),
            Button = Color3.fromHex("#6c757d"),
            Icon = Color3.fromHex("#adb5bd"),
            Toggle = Color3.fromHex("#495057"),
            Checkbox = Color3.fromHex("#6c757d"),
        },

        ---------------------------
        --        PEACH
        ---------------------------
        Peach = {
            Name = "Peach",
            Accent = Color3.fromHex("#ffb084"),
            Dialog = Color3.fromHex("#ff9860"),
            Outline = Color3.fromHex("#e06a3b"),
            Text = Color3.fromHex("#7a3f25"),
            Placeholder = Color3.fromHex("#ffd1b5"),
            Background = Color3.fromHex("#ffeadf"),
            Button = Color3.fromHex("#ffb084"),
            Icon = Color3.fromHex("#ff9860"),
            Toggle = Color3.fromHex("#ff7b42"),
            Checkbox = Color3.fromHex("#e65e2d"),
        },

        ---------------------------
        --        ARCTIC
        ---------------------------
        Arctic = {
            Name = "Arctic",
            Accent = Color3.fromHex("#b3e6ff"),
            Dialog = Color3.fromHex("#ccefff"),
            Outline = Color3.fromHex("#7fd1ff"),
            Text = Color3.fromHex("#00334d"),
            Placeholder = Color3.fromHex("#d9f5ff"),
            Background = Color3.fromHex("#f2fbff"),
            Button = Color3.fromHex("#99ddff"),
            Icon = Color3.fromHex("#66ccff"),
            Toggle = Color3.fromHex("#55c1ff"),
            Checkbox = Color3.fromHex("#009fe6"),
        },

        ---------------------------
        --        COFFEE
        ---------------------------
        Coffee = {
            Name = "Coffee",
            Accent = Color3.fromHex("#6f4e37"),
            Dialog = Color3.fromHex("#4b2e22"),
            Outline = Color3.fromHex("#3c241b"),
            Text = Color3.fromHex("#f5e6d3"),
            Placeholder = Color3.fromHex("#d2b89c"),
            Background = Color3.fromHex("#f0e3d1"),
            Button = Color3.fromHex("#a67c52"),
            Icon = Color3.fromHex("#8c6239"),
            Toggle = Color3.fromHex("#6f4e37"),
            Checkbox = Color3.fromHex("#4b2e22"),
        },

        ---------------------------
        --        SAKURA
        ---------------------------
        Sakura = {
            Name = "Sakura",
            Accent = Color3.fromHex("#ffb7c5"),
            Dialog = Color3.fromHex("#ff9bb0"),
            Outline = Color3.fromHex("#d16a7d"),
            Text = Color3.fromHex("#6a2c3c"),
            Placeholder = Color3.fromHex("#ffd6df"),
            Background = Color3.fromHex("#ffeaf0"),
            Button = Color3.fromHex("#ffbfd4"),
            Icon = Color3.fromHex("#ff9bb0"),
            Toggle = Color3.fromHex("#ff819a"),
            Checkbox = Color3.fromHex("#d66780"),
        },

        ---------------------------
        --      ARCTIC NIGHT
        ---------------------------
        ArcticNight = {
            Name = "ArcticNight",
            Accent = Color3.fromHex("#1b263b"),
            Dialog = Color3.fromHex("#0d1b2a"),
            Outline = Color3.fromHex("#415a77"),
            Text = Color3.fromHex("#e0e1dd"),
            Placeholder = Color3.fromHex("#778da9"),
            Background = Color3.fromHex("#0d1b2a"),
            Button = Color3.fromHex("#415a77"),
            Icon = Color3.fromHex("#778da9"),
            Toggle = Color3.fromHex("#1b263b"),
            Checkbox = Color3.fromHex("#415a77"),
        },

        ---------------------------
        --        HACKER
        ---------------------------
        Hacker = {
            Name = "Hacker",
            Accent = Color3.fromHex("#00ff41"),
            Dialog = Color3.fromHex("#003b00"),
            Outline = Color3.fromHex("#00cc33"),
            Text = Color3.fromHex("#00ff41"),
            Placeholder = Color3.fromHex("#66ff99"),
            Background = Color3.fromHex("#001a00"),
            Button = Color3.fromHex("#00cc33"),
            Icon = Color3.fromHex("#00ff41"),
            Toggle = Color3.fromHex("#00992d"),
            Checkbox = Color3.fromHex("#00cc33"),
        },

        ---------------------------
        --        RAINBOW
        ---------------------------
        Rainbow = {
            Name = "Rainbow",

            Accent = WindUI:Gradient({
                ["0"]   = { Color = Color3.fromHex("#00ff41"), Transparency = 0 },
                ["33"]  = { Color = Color3.fromHex("#00ffff"), Transparency = 0 },
                ["66"]  = { Color = Color3.fromHex("#0080ff"), Transparency = 0 }, 
                ["100"] = { Color = Color3.fromHex("#8000ff"), Transparency = 0 },
            }, { Rotation = 45 }),

            Dialog = WindUI:Gradient({
                ["0"]   = { Color = Color3.fromHex("#ff0080"), Transparency = 0 }, 
                ["25"]  = { Color = Color3.fromHex("#8000ff"), Transparency = 0 },
                ["50"]  = { Color = Color3.fromHex("#0080ff"), Transparency = 0 },
                ["75"]  = { Color = Color3.fromHex("#00ff80"), Transparency = 0 },
                ["100"] = { Color = Color3.fromHex("#ff8000"), Transparency = 0 },
            }, { Rotation = 135 }),

            Outline = Color3.fromHex("#ffffff"),
            Text = Color3.fromHex("#ffffff"),
            Placeholder = Color3.fromHex("#00ff80"),

            Background = WindUI:Gradient({
                ["0"]   = { Color = Color3.fromHex("#ff0040"), Transparency = 0 },
                ["20"]  = { Color = Color3.fromHex("#ff4000"), Transparency = 0 },
                ["40"]  = { Color = Color3.fromHex("#ffff00"), Transparency = 0 },
                ["60"]  = { Color = Color3.fromHex("#00ff40"), Transparency = 0 },
                ["80"]  = { Color = Color3.fromHex("#0040ff"), Transparency = 0 },
                ["100"] = { Color = Color3.fromHex("#4000ff"), Transparency = 0 },
            }, { Rotation = 90 }),

            Button = WindUI:Gradient({
                ["0"]   = { Color = Color3.fromHex("#ff0080"), Transparency = 0 },
                ["25"]  = { Color = Color3.fromHex("#ff8000"), Transparency = 0 },
                ["50"]  = { Color = Color3.fromHex("#ffff00"), Transparency = 0 },
                ["75"]  = { Color = Color3.fromHex("#80ff00"), Transparency = 0 },
                ["100"] = { Color = Color3.fromHex("#00ffff"), Transparency = 0 },
            }, { Rotation = 60 }),

            Icon = Color3.fromHex("#ffffff"),
        },

    }
end

--================================--
--    APPLY THEME SYSTEM UI
--================================--

local ThemeList = Themes(WindUI)
local ThemeNames = {}

for name in pairs(ThemeList) do
    table.insert(ThemeNames, name)
end

table.sort(ThemeNames) -- сортировка по алфавиту

ThemeSection:Dropdown({
    Title = "Select Theme",
    Values = ThemeNames,
    Locked = false,
    Value = ThemeNames[1],
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        WindUI:SetTheme(option)
    end
})
