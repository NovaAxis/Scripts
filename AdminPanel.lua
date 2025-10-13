-- Admin Panel for executor
-- Создаёт GUI, переключение вкладок, и вызывает RemoteEvents:
-- ReplicatedStorage.Events.RemoteEvent:FireServer()
-- ReplicatedStorage.APEvents.Mod.BanPlayer/KickPlayer/UnbanPlayer/BanChatMessage:FireServer(arg)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

-- Parent (try PlayerGui first, then CoreGui)
local parentGui
if localPlayer and localPlayer:FindFirstChild("PlayerGui") then
	parentGui = localPlayer:FindFirstChild("PlayerGui")
else
	parentGui = game:GetService("CoreGui")
end

-- Utility: safe find remote
local function getRemote(pathParts)
	local cur = ReplicatedStorage
	for _,part in ipairs(pathParts) do
		if cur and cur:FindFirstChild(part) then
			cur = cur[part]
		else
			return nil
		end
	end
	return cur
end

-- Debounce wrapper
local function safeFire(remote, ...)
	local ok, err = pcall(function()
		remote:FireServer(...)
	end)
	return ok, err
end

-- Build GUI
local function createGui()
	-- remove old if exists
	local existing = parentGui:FindFirstChild("ZoraxAdminPanel")
	if existing then existing:Destroy() end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ZoraxAdminPanel"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = parentGui

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 680, 0, 420)
	Main.Position = UDim2.new(0.5, -340, 0.5, -210)
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.BackgroundColor3 = Color3.fromRGB(30,30,30)
	Main.BorderSizePixel = 0
	Main.Parent = ScreenGui

	-- draggable
	local uicorner = Instance.new("UICorner", Main); uicorner.CornerRadius = UDim.new(0,8)
	local title = Instance.new("TextLabel", Main)
	title.Size = UDim2.new(1,0,0,36)
	title.Position = UDim2.new(0,0,0,0)
	title.Text = "Admin Panel (executor)"
	title.TextScaled = true
	title.TextColor3 = Color3.fromRGB(230,230,230)
	title.BackgroundTransparency = 1

	local left = Instance.new("Frame", Main)
	left.Size = UDim2.new(0,150,1,-10)
	left.Position = UDim2.new(0,10,0,46)
	left.BackgroundTransparency = 1

	-- Tab buttons container
	local tabNames = {"Home","Event","Safety","Other"}
	local tabButtons = {}
	for i,name in ipairs(tabNames) do
		local btn = Instance.new("TextButton", left)
		btn.Name = name.."Btn"
		btn.Size = UDim2.new(1, -4, 0, 40)
		btn.Position = UDim2.new(0,2,0, (i-1)*46)
		btn.Text = name
		btn.Font = Enum.Font.SourceSansSemibold
		btn.TextSize = 18
		btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
		btn.TextColor3 = Color3.fromRGB(230,230,230)
		btn.AutoButtonColor = true
		btn.BorderSizePixel = 0
		local c = Instance.new("UICorner", btn)
		c.CornerRadius = UDim.new(0,6)
		tabButtons[name] = btn
	end

	-- Right content area
	local content = Instance.new("Frame", Main)
	content.Size = UDim2.new(1, -180, 1, -56)
	content.Position = UDim2.new(0,170,0,46)
	content.BackgroundTransparency = 1

	-- create pages
	local pages = {}

	-- Home page
	local home = Instance.new("Frame", content)
	home.Size = UDim2.new(1,0,1,0)
	home.BackgroundTransparency = 1
	local homeLabel = Instance.new("TextLabel", home)
	homeLabel.Size = UDim2.new(1,0,0,30)
	homeLabel.Position = UDim2.new(0,0,0,0)
	homeLabel.BackgroundTransparency = 1
	homeLabel.Text = "Welcome! Press P to toggle panel."
	homeLabel.TextScaled = true
	homeLabel.TextColor3 = Color3.fromRGB(200,200,200)
	pages["Home"] = home

	-- Event page
	local eventPage = Instance.new("Frame", content)
	eventPage.Size = UDim2.new(1,0,1,0)
	eventPage.BackgroundTransparency = 1
	eventPage.Visible = false
	local eventLabel = Instance.new("TextLabel", eventPage)
	eventLabel.Size = UDim2.new(1,0,0,30)
	eventLabel.Position = UDim2.new(0,0,0,0)
	eventLabel.BackgroundTransparency = 1
	eventLabel.Text = "Event Controls"
	eventLabel.TextScaled = true
	eventLabel.TextColor3 = Color3.fromRGB(200,200,200)

	local eventBtn = Instance.new("TextButton", eventPage)
	eventBtn.Size = UDim2.new(0,200,0,42)
	eventBtn.Position = UDim2.new(0,0,0,50)
	eventBtn.Text = "Run Remote Event (ReplicatedStorage.Events.RemoteEvent)"
	eventBtn.TextWrapped = true
	eventBtn.TextColor3 = Color3.fromRGB(230,230,230)
	eventBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
	local ecorner = Instance.new("UICorner", eventBtn); ecorner.CornerRadius = UDim.new(0,6)

	local eventStatus = Instance.new("TextLabel", eventPage)
	eventStatus.Size = UDim2.new(1,0,0,22)
	eventStatus.Position = UDim2.new(0,0,0,100)
	eventStatus.BackgroundTransparency = 1
	eventStatus.TextColor3 = Color3.fromRGB(180,180,180)
	eventStatus.Text = "Status: idle"
	pages["Event"] = eventPage

	-- Safety page
	local safety = Instance.new("Frame", content)
	safety.Size = UDim2.new(1,0,1,0)
	safety.BackgroundTransparency = 1
	safety.Visible = false

	local safetyTitle = Instance.new("TextLabel", safety)
	safetyTitle.Size = UDim2.new(1,0,0,30)
	safetyTitle.Position = UDim2.new(0,0,0,0)
	safetyTitle.Text = "Safety (Mod) - ReplicatedStorage.APEvents.Mod"
	safetyTitle.BackgroundTransparency = 1
	safetyTitle.TextScaled = true
	safetyTitle.TextColor3 = Color3.fromRGB(200,200,200)

	local nameBox = Instance.new("TextBox", safety)
	nameBox.Size = UDim2.new(0,300,0,36)
	nameBox.Position = UDim2.new(0,0,0,50)
	nameBox.PlaceholderText = "Player name (exact)"
	nameBox.Text = ""
	nameBox.TextColor3 = Color3.fromRGB(220,220,220)
	nameBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
	local nbCorner = Instance.new("UICorner", nameBox); nbCorner.CornerRadius = UDim.new(0,6)

	local btnNames = {
		{"Ban Player", "BanPlayer"},
		{"Kick Player", "KickPlayer"},
		{"Unban Player", "UnbanPlayer"},
		{"Ban Chat Message", "BanChatMessage"}
	}

	local y = 100
	local actionStatus = Instance.new("TextLabel", safety)
	actionStatus.Size = UDim2.new(1,0,0,20)
	actionStatus.Position = UDim2.new(0,0,0,80)
	actionStatus.BackgroundTransparency = 1
	actionStatus.Text = "Awaiting action..."
	actionStatus.TextColor3 = Color3.fromRGB(180,180,180)

	for _,pair in ipairs(btnNames) do
		local text, remoteName = pair[1], pair[2]
		local btn = Instance.new("TextButton", safety)
		btn.Size = UDim2.new(0,160,0,36)
		btn.Position = UDim2.new(0, (y-100)/2 * 0, 0, y)
		-- layout them in two columns:
		local col = (_%2==1) and 0 or 1
		local row = math.floor((_) / 2)
		btn.Position = UDim2.new(0, (col*170), 0, 100 + row*46)
		btn.Text = text
		btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
		btn.TextColor3 = Color3.fromRGB(235,235,235)
		btn.AutoButtonColor = true
		local bcorner = Instance.new("UICorner", btn); bcorner.CornerRadius = UDim.new(0,6)

		btn.MouseButton1Click:Connect(function()
			local playerName = nameBox.Text or ""
			playerName = tostring(playerName):gsub("^%s*(.-)%s*$","%1")
			if playerName == "" then
				actionStatus.Text = "Введите ник игрока в поле выше."
				return
			end

			local modFolder = ReplicatedStorage:FindFirstChild("APEvents")
			if not modFolder then
				-- try nested path
				modFolder = ReplicatedStorage:FindFirstChild("APEvents") or getRemote({"APEvents"})
			end
			if not modFolder then
				actionStatus.Text = "ReplicatedStorage.APEvents не найден."
				return
			end

			local mod = modFolder:FindFirstChild("Mod")
			if not mod then
				actionStatus.Text = "ReplicatedStorage.APEvents.Mod не найден."
				return
			end

			local remote = mod:FindFirstChild(remoteName)
			if not remote then
				actionStatus.Text = "Remote "..remoteName.." не найден в ReplicatedStorage.APEvents.Mod"
				return
			end

			-- Fire remote with playerName (and attempt to also give userId if possible)
			actionStatus.Text = "Calling "..remoteName.." for "..playerName.."..."
			-- Try to resolve userid (best-effort)
			local successUserId, userIdOrErr = pcall(function()
				return Players:GetUserIdFromNameAsync(playerName)
			end)

			local firedOk, fireErr
			if successUserId and type(userIdOrErr) == "number" then
				-- try both: first userId then name (server may expect one or another)
				firedOk, fireErr = pcall(function()
					remote:FireServer(userIdOrErr)
				end)
				if not firedOk then
					-- fallback to name
					firedOk, fireErr = pcall(function()
						remote:FireServer(playerName)
					end)
				end
			else
				firedOk, fireErr = pcall(function()
					remote:FireServer(playerName)
				end)
			end

			if firedOk then
				actionStatus.Text = text.." sent for "..playerName
			else
				actionStatus.Text = "Ошибка отправки: "..tostring(fireErr)
			end
		end)
	end

	pages["Safety"] = safety

	-- Other page (placeholder)
	local other = Instance.new("Frame", content)
	other.Size = UDim2.new(1,0,1,0)
	other.BackgroundTransparency = 1
	other.Visible = false
	local otherLabel = Instance.new("TextLabel", other)
	otherLabel.Size = UDim2.new(1,0,0,30)
	otherLabel.Position = UDim2.new(0,0,0,0)
	otherLabel.BackgroundTransparency = 1
	otherLabel.Text = "Other (placeholder)"
	otherLabel.TextScaled = true
	otherLabel.TextColor3 = Color3.fromRGB(200,200,200)
	pages["Other"] = other

	-- tab switching function
	local function switchTo(name)
		for k,v in pairs(pages) do
			if k == name then
				v.Visible = true
			else
				v.Visible = false
			end
		end
		-- highlight active button
		for k,btn in pairs(tabButtons) do
			if k == name then
				btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
			else
				btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
			end
		end
	end

	-- connect tab buttons
	for name,btn in pairs(tabButtons) do
		btn.MouseButton1Click:Connect(function()
			switchTo(name)
		end)
	end

	-- Event button logic
	eventBtn.MouseButton1Click:Connect(function()
		local remote = getRemote({"Events", "RemoteEvent"}) or ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("RemoteEvent")
		if not remote then
			eventStatus.Text = "RemoteEvent не найден в ReplicatedStorage.Events"
			return
		end
		local ok, err = pcall(function() remote:FireServer() end)
		if ok then
			eventStatus.Text = "RemoteEvent:FireServer() отправлен"
		else
			eventStatus.Text = "Ошибка вызова RemoteEvent: "..tostring(err)
		end
	end)

	-- toggle visibility with P
	local isVisible = true
	local function setVisible(v)
		isVisible = v
		Main.Visible = v
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.P then
			setVisible(not isVisible)
		end
	end)

	-- initial tab
	switchTo("Home")

	return ScreenGui
end

-- create gui
local ok, err = pcall(createGui)
if not ok then
	warn("Failed to create admin panel: "..tostring(err))
else
	print("Admin panel created. Press P to toggle.")
end
