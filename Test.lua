-- ============================
-- Anti-Cheat Bypass (запускается перед UI)
-- ============================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

local function SetupKickProtection()
    local mt = getrawmetatable(game)
    if not mt then return end
    local oldNamecall = mt.__namecall
    if setreadonly then
        pcall(function() setreadonly(mt, false) end)
    end
    if oldNamecall then
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" then
                return nil
            end
            return oldNamecall(self, ...)
        end)
    end
end

local function DisconnectAllConnections(object, signalName)
    if not object then return end
    local ok, signal = pcall(function() return
