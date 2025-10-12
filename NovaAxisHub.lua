-- 🎮 UNIVERSAL LOADER SCRIPT FOR ROBLOX
print("🌀 Universal Loader started...")

-- 📍 Get current game ID
local CurrentPlaceId = game.PlaceId
print("📊 Current game ID:", CurrentPlaceId)

-- 🎯 Target game IDs
local TARGET_PLACE_1 = 77782632203916  -- Steal A Femboy
local TARGET_PLACE_2 = 129422765492183 -- 99 Nights In The Forest

-- 🧩 Script URLs
local URL_FEMBOY = "https://raw.githubusercontent.com/AMIRTIMCAT/Scripts/refs/heads/main/StealAFemboy.lua"
local URL_FOREST = "https://raw.githubusercontent.com/AMIRTIMCAT/Scripts/refs/heads/main/S99NightsInTheForest.lua"

-- ⚙️ Safe load & execute
local function LoadAndRun(url, name)
	print("🔄 Loading script:", name)
	
	local success, data = pcall(function()
		return game:HttpGet(url)
	end)

	if not success then
		warn("❌ Failed to fetch " .. name .. ": " .. tostring(data))
		return
	end

	local func, err = loadstring(data)
	if not func then
		warn("⚠️ Failed to compile " .. name .. ": " .. tostring(err))
		return
	end

	print("🚀 Executing:", name)
	local ok, result = pcall(func)
	if ok then
		print("✅ " .. name .. " loaded successfully!")
	else
		warn("💥 Error during " .. name .. " execution: " .. tostring(result))
	end
end

-- 🎯 MAIN LOGIC
if CurrentPlaceId == TARGET_PLACE_1 then
	print("🎯 Detected game: Steal A Femboy")
	LoadAndRun(URL_FEMBOY, "Steal A Femboy")

elseif CurrentPlaceId == TARGET_PLACE_2 then
	print("🎯 Detected game: 99 Nights In The Forest")
	LoadAndRun(URL_FOREST, "99 Nights In The Forest")

else
	print("❌ Unsupported game ID:", CurrentPlaceId)
	print("♀️ Expected:", TARGET_PLACE_1)
	print("🌲 Expected:", TARGET_PLACE_2)
end

print("🏁 Loader finished initialization")
