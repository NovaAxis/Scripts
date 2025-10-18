local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "💫 NovaAxis",
    Icon = "sparkles", -- lucide icon. optional
    Author = "NovaAxis", -- optional
    BackgroundImageTransparency = 0.45,
        User = {
        Enabled = true,
        Anonymous = false,
    },
})

Window:EditOpenButton({
    Title = "💫 NovaAxis",
    Icon = "sparkles",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new( -- gradient
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

local Tab = Window:Tab({
    Title = "Main",
    Icon = "sparkles", -- optional
    Locked = false,
})

local Slider = Tab:Slider({
    Title = "Money Amount",
    Desc = "Select amount",
    Step = 1000, -- Changed step to make sliding smoother
    Value = {
        Min = 100000,
        Max = 1000000000000,
        Default = 100000
    },
    Callback = function(value)
        print("Slider value: " .. tostring(value))
    end
})

local Button = Tab:Button({
    Title = "Claim Money",
    Desc = "Claim amount",
    Locked = false,
    Callback = function()
        local value = Slider.Value
        print("Button clicked, value: " .. tostring(value))
        if not value or value < 100000 or value > 1000000000000 then
            warn("Invalid value: " .. tostring(value))
            return
        end
        local args = {
            "Money",
            value
        }
        local success, err = pcall(function()
            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("ClaimReward")
            if not remote then
                error("ClaimReward RemoteEvent not found in ReplicatedStorage")
            end
            print("Sending to server: Money, " .. tostring(value))
            remote:FireServer(unpack(args))
        end)
        if success then
            print("Successfully sent to server: Money, " .. tostring(value))
        else
            warn("Failed to send to server: " .. tostring(err))
        end
    end
})
