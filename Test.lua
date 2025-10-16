--[[
NOVAAXIS HUB KEY SYSTEM
Styled version for NovaAxis Hub
]]

Config = {
    api = "afa9b1d8-0284-47ee-a5a9-76b67f0ed99e", 
    service = "NovaAxis | Hub | Key System",
    provider = "NovaAxis|Hub|Providers"
}

local function main()
    -- script here
    print("NovaAxis Hub loaded successfully!")
end

if getgenv().NovaAxisKeySys then return end
getgenv().NovaAxisKeySys = true

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- NovaAxis Configuration
local KeySystemData = {
    Name = "NovaAxis Hub",
    Colors = {
        Background = Color3.fromRGB(15, 15, 20),
        SecondaryBg = Color3.fromRGB(20, 20, 28),
        Accent = Color3.fromRGB(120, 80, 255),
        AccentDark = Color3.fromRGB(90, 60, 200),
        AccentLight = Color3.fromRGB(150, 110, 255),
        Text = Color3.fromRGB(240, 240, 245),
        TextDim = Color3.fromRGB(160, 160, 170),
        Border = Color3.fromRGB(40, 40, 55),
        Success = Color3.fromRGB(100, 220, 120),
        Error = Color3.fromRGB(255, 80, 100),
        Warning = Color3.fromRGB(255, 180, 60)
    },
    DiscordInvite = "Eg98P4wf2V",
    FileName = "novaaxis/key.txt"
}

local function CreateObject(class, props)
    local obj = Instance.new(class)
    for prop, value in pairs(props) do 
        if prop ~= "Parent" then
            obj[prop] = value
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function SmoothTween(obj, time, properties)
    local tween = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

-- Main GUI
local ScreenGui = CreateObject("ScreenGui", {
    Name = "NovaAxisKeySystem", 
    Parent = CoreGui, 
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999
})

-- Blur effect background
local BlurFrame = CreateObject("Frame", {
    Name = "BlurBg",
    Parent = ScreenGui,
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.4,
    Size = UDim2.new(1, 0, 1, 0),
    BorderSizePixel = 0
})

-- Main Container
local MainFrame = CreateObject("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    BackgroundColor3 = KeySystemData.Colors.Background,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.new(0, 420, 0, 320),
    ClipsDescendants = true
})
CreateObject("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})

-- Outer glow effect
local OuterGlow = CreateObject("UIStroke", {
    Parent = MainFrame,
    Color = KeySystemData.Colors.Accent,
    Thickness = 2,
    Transparency = 0.7
})

-- Gradient overlay
local GradientOverlay = CreateObject("Frame", {
    Name = "Gradient",
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.95,
    Size = UDim2.new(1, 0, 1, 0),
    BorderSizePixel = 0
})
CreateObject("UICorner", {CornerRadius = UDim.new(0, 12), Parent = GradientOverlay})
local Gradient = CreateObject("UIGradient", {
    Parent = GradientOverlay,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, KeySystemData.Colors.Accent),
        ColorSequenceKeypoint.new(1, KeySystemData.Colors.AccentDark)
    }),
    Rotation = 45
})

-- Animated gradient
task.spawn(function()
    while true do
        SmoothTween(Gradient, 3, {Rotation = 225})
        task.wait(3)
        SmoothTween(Gradient, 3, {Rotation = 45})
        task.wait(3)
    end
end)

-- Title Bar
local TitleBar = CreateObject("Frame", {
    Name = "TitleBar",
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 60),
    BorderSizePixel = 0
})

-- Logo/Icon
local LogoFrame = CreateObject("Frame", {
    Name = "Logo",
    Parent = TitleBar,
    BackgroundColor3 = KeySystemData.Colors.Accent,
    Position = UDim2.new(0, 20, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    Size = UDim2.new(0, 36, 0, 36)
})
CreateObject("UICorner", {CornerRadius = UDim.new(0, 8), Parent = LogoFrame})
local LogoText = CreateObject("TextLabel", {
    Parent = LogoFrame,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Text = "N",
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 20
})

-- Title
local Title = CreateObject("TextLabel", {
    Name = "Title",
    Parent = TitleBar,
    BackgroundTransparency = 1,
    Text = "NovaAxis Hub",
    Position = UDim2.new(0, 65, 0.35, 0),
    Size = UDim2.new(0, 200, 0, 20),
    Font = Enum.Font.GothamBold,
    TextColor3 = KeySystemData.Colors.Text,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left
})

local Subtitle = CreateObject("TextLabel", {
    Name = "Subtitle",
    Parent = TitleBar,
    BackgroundTransparency = 1,
    Text = "Key System Verification",
    Position = UDim2.new(0, 65, 0.65, 0),
    Size = UDim2.new(0, 200, 0, 15),
    Font = Enum.Font.Gotham,
    TextColor3 = KeySystemData.Colors.TextDim,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Close Button
local CloseButton = CreateObject("TextButton", {
    Name = "CloseBtn",
    Parent = TitleBar,
    BackgroundColor3 = KeySystemData.Colors.SecondaryBg,
    Position = UDim2.new(1, -45, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    Size = UDim2.new(0, 32, 0, 32),
    Text = "✕",
    Font = Enum.Font.GothamBold,
    TextColor3 = KeySystemData.Colors.TextDim,
    TextSize = 16,
    AutoButtonColor = false
})
CreateObject("UICorner", {CornerRadius = UDim.new(0, 6), Parent = CloseButton})

-- Content Container
local ContentFrame = CreateObject("Frame", {
    Name = "Content",
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 70),
    Size = UDim2.new(1, 0, 1, -70)
})

-- Key Input Label
local InputLabel = CreateObject("TextLabel", {
    Parent = ContentFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 30, 0, 10),
    Size = UDim2.new(1, -60, 0, 20),
    Text = "Enter License Key",
    Font = Enum.Font.GothamSemibold,
    TextColor3 = KeySystemData.Colors.Text,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Key Input Field
local KeyInputBg = CreateObject("Frame", {
    Name = "InputBg",
    Parent = ContentFrame,
    BackgroundColor3 = KeySystemData.Colors.SecondaryBg,
    Position = UDim2.new(0, 30, 0, 38),
    Size = UDim2.new(1, -60, 0, 42)
})
CreateObject("UICorner", {CornerRadius = UDim.new(0, 8), Parent = KeyInputBg})
local InputStroke = CreateObject("UIStroke", {
    Parent = KeyInputBg,
    Color = KeySystemData.Colors.Border,
    Thickness = 1.5,
    Transparency = 0.5
})

local KeyInput = CreateObject("TextBox", {
    Name = "KeyInput",
    Parent = KeyInputBg,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 15, 0, 0),
    Size = UDim2.new(1, -30, 1, 0),
    Text = "",
    PlaceholderText = "XXXX-XXXX-XXXX-XXXX",
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextColor3 = KeySystemData.Colors.Text,
    PlaceholderColor3 = KeySystemData.Colors.TextDim,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false
})

-- Buttons Container
local ButtonsFrame = CreateObject("Frame", {
    Name = "Buttons",
    Parent = ContentFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 30, 0, 95),
    Size = UDim2.new(1, -60, 0, 42)
})

-- Verify Button
local VerifyButton = CreateObject("TextButton", {
    Name = "VerifyBtn",
    Parent = ButtonsFrame,
    BackgroundColor3 = KeySystemData.Colors.Accent,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(0.48, 0, 1, 0),
    Text = "",
    AutoButtonColor = false
})
CreateObject("UICorner", {CornerRadius = UDim.new(0, 8), Parent = VerifyButton})
local VerifyLabel = CreateObject("TextLabel", {
    Parent = VerifyButton,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Text = "✓  Verify Key",
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14
})

-- Get Key Button
local GetKeyButton = CreateObject("TextButton", {
    Name = "GetKeyBtn",
    Parent = ButtonsFrame,
    BackgroundColor3 = KeySystemData.Colors.SecondaryBg,
    Position = UDim2.new(0.52, 0, 0, 0),
    Size = UDim2.new(0.48, 0, 1, 0),
    Text = "",
    AutoButtonColor = false
})
CreateObject("UICorner", {CornerRadius = UDim.new(0, 8), Parent = GetKeyButton})
CreateObject("UIStroke", {
    Parent = GetKeyButton,
    Color = KeySystemData.Colors.Accent,
    Thickness = 1.5
})
local GetKeyLabel = CreateObject("TextLabel", {
    Parent = GetKeyButton,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Text = "🔑  Get Key",
    Font = Enum.Font.GothamBold,
    TextColor3 = KeySystemData.Colors.Accent,
    TextSize = 14
})

-- Discord Button
local DiscordButton = CreateObject("TextButton", {
    Name = "DiscordBtn",
    Parent = ContentFrame,
    BackgroundColor3 = Color3.fromRGB(88, 101, 242),
    Position = UDim2.new(0, 30, 0, 150),
    Size = UDim2.new(1, -60, 0, 42),
    Text = "",
    AutoButtonColor = false
})
CreateObject("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DiscordButton})
local DiscordLabel = CreateObject("TextLabel", {
    Parent = DiscordButton,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Text = "💬  Join Discord Server",
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14
})

-- Status Label
local StatusLabel = CreateObject("TextLabel", {
    Name = "Status",
    Parent = ContentFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 30, 1, -25),
    Size = UDim2.new(1, -60, 0, 20),
    Font = Enum.Font.GothamMedium,
    Text = "",
    TextColor3 = KeySystemData.Colors.TextDim,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextTransparency = 1
})

-- Functions
local function ShowStatus(text, color, duration)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color
    SmoothTween(StatusLabel, 0.3, {TextTransparency = 0})
    
    task.spawn(function()
        task.wait(duration or 3)
        if StatusLabel.Text == text then
            SmoothTween(StatusLabel, 0.5, {TextTransparency = 1})
        end
    end)
end

local function AddButtonHover(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        SmoothTween(button, 0.2, {BackgroundColor3 = hoverColor})
    end)
    button.MouseLeave:Connect(function()
        SmoothTween(button, 0.2, {BackgroundColor3 = normalColor})
    end)
end

AddButtonHover(VerifyButton, KeySystemData.Colors.Accent, KeySystemData.Colors.AccentLight)
AddButtonHover(GetKeyButton, KeySystemData.Colors.SecondaryBg, KeySystemData.Colors.Border)
AddButtonHover(DiscordButton, Color3.fromRGB(88, 101, 242), Color3.fromRGB(103, 116, 255))
AddButtonHover(CloseButton, KeySystemData.Colors.SecondaryBg, Color3.fromRGB(255, 80, 100))

-- Input focus effects
KeyInput.Focused:Connect(function()
    SmoothTween(InputStroke, 0.2, {
        Color = KeySystemData.Colors.Accent,
        Transparency = 0
    })
end)

KeyInput.FocusLost:Connect(function(enterPressed)
    SmoothTween(InputStroke, 0.2, {
        Color = KeySystemData.Colors.Border,
        Transparency = 0.5
    })
    if enterPressed then
        VerifyButton.MouseButton1Click:Fire()
    end
end)

-- Get Key Function
local function openGetKey()
    local success, JunkieKeySystem = pcall(function()
        return loadstring(game:HttpGet("https://junkie-development.de/sdk/JunkieKeySystem.lua"))()
    end)
    
    if not success then
        ShowStatus("❌ Failed to load key system", KeySystemData.Colors.Error)
        return
    end
    
    local link = JunkieKeySystem.getLink(Config.api, Config.provider, Config.service)
    if link then
        if setclipboard then
            setclipboard(link)
            ShowStatus("✓ Key link copied to clipboard!", KeySystemData.Colors.Success, 2)
        else
            ShowStatus("Link: " .. link, KeySystemData.Colors.Warning, 5)
        end
    else
        ShowStatus("❌ Failed to generate key link", KeySystemData.Colors.Error)
    end
end

-- Validate Key Function
local function validateKey()
    local userKey = KeyInput.Text:gsub("%s+", "")
    if not userKey or userKey == "" then
        ShowStatus("⚠ Please enter a valid key", KeySystemData.Colors.Warning)
        return
    end

    ShowStatus("⏳ Validating key...", KeySystemData.Colors.Warning, 10)
    
    local success, JunkieKeySystem = pcall(function()
        return loadstring(game:HttpGet("https://junkie-development.de/sdk/JunkieKeySystem.lua"))()
    end)
    
    if not success then
        ShowStatus("❌ Connection failed", KeySystemData.Colors.Error)
        return
    end
    
    local isValid = JunkieKeySystem.verifyKey(Config.api, userKey, Config.service)
    
    if isValid then
        ShowStatus("✓ Access granted! Loading...", KeySystemData.Colors.Success, 2)
        
        SmoothTween(MainFrame, 0.4, {Size = UDim2.new(0, 420, 0, 0)})
        SmoothTween(BlurFrame, 0.4, {BackgroundTransparency = 1})
        
        task.wait(0.5)
        ScreenGui:Destroy()
        main()
    else
        ShowStatus("❌ Invalid key. Please try again", KeySystemData.Colors.Error)
        KeyInput.Text = ""
    end
end

-- Button Connections
VerifyButton.MouseButton1Click:Connect(validateKey)
GetKeyButton.MouseButton1Click:Connect(openGetKey)

DiscordButton.MouseButton1Click:Connect(function()
    local discordUrl = "https://discord.gg/" .. KeySystemData.DiscordInvite
    if setclipboard then
        setclipboard(discordUrl)
        ShowStatus("✓ Discord invite copied!", Color3.fromRGB(88, 101, 242), 2)
    else
        ShowStatus("Join: " .. discordUrl, Color3.fromRGB(88, 101, 242), 5)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    SmoothTween(MainFrame, 0.3, {Size = UDim2.new(0, 420, 0, 0)})
    SmoothTween(BlurFrame, 0.3, {BackgroundTransparency = 1})
    task.wait(0.3)
    ScreenGui:Destroy()
end)

-- Dragging
local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Entry Animation
MainFrame.Size = UDim2.new(0, 420, 0, 0)
BlurFrame.BackgroundTransparency = 1

SmoothTween(MainFrame, 0.5, {Size = UDim2.new(0, 420, 0, 320)})
SmoothTween(BlurFrame, 0.5, {BackgroundTransparency = 0.4})
