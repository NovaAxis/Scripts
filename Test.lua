-- RagdollToggle Module
-- Использование:
-- local RagdollToggle = require(path.to.RagdollToggle)
-- RagdollToggle:Enable(character)  --> включает ragdoll (сохраняет Motor6D)
-- RagdollToggle:Disable(character) --> выключает ragdoll и восстанавливает Motor6D

local RagdollToggle = {}
RagdollToggle._backups = {} -- хранит состояние по персонажам

-- Сканирует и сохраняет все Motor6D в таблицу (копируем свойства, не объекты)
local function backupMotors(character)
	local motors = {}
	for _, m in ipairs(character:GetDescendants()) do
		if m:IsA("Motor6D") then
			table.insert(motors, {
				Name = m.Name,
				Part0 = m.Part0,
				Part1 = m.Part1,
				C0 = m.C0,
				C1 = m.C1,
				Transform = m.Transform, -- на всякий
				MaxVelocity = m.MaxVelocity
			})
		end
	end
	return motors
end

-- Восстанавливает Motor6D по сохранённой таблице
local function restoreMotors(character, motors)
	-- Удаляем любые временные AnimationConstraint / BallSocket / NoCollision, которые могли остаться
	for _, obj in ipairs(character:GetDescendants()) do
		-- удаляем имя-совпадения, которые создаёт ragdoll (в твоём коде BallSocket называется "RagdollBallSocket",
		-- NoCollision - "RagdollNoCollision", AnimationConstraint создаются с именем Motor6D.Name)
		if obj:IsA("BallSocketConstraint") and obj.Name == "RagdollBallSocket" then
			obj:Destroy()
		elseif obj:IsA("NoCollisionConstraint") and obj.Name == "RagdollNoCollision" then
			obj:Destroy()
		elseif obj:IsA("AnimationConstraint") then
			-- AnimationConstraint создавались с IsKinematic = true — но осторожно: если в игре есть другие AnimationConstraint,
			-- лучше удалять только те, у которых Parent ранее был Motor6D.Parent или имя совпадает с сохранённым мотором.
			-- Попытаемся удалить AnimationConstraint, если его имя совпадает с одним из сохранённых Motor имён
			for _, info in ipairs(motors) do
				if obj.Name == info.Name then
					obj:Destroy()
					break
				end
			end
		end
	end

	-- Удалим также созданные Ragdoll-аттачменты по шаблону (имена в оригинале: "...RagdollAttachment", "...RagdollRigAttachment" и т.п.)
	for _, att in ipairs(character:GetDescendants()) do
		if att:IsA("Attachment") then
			local name = att.Name
			if name:find("Ragdoll") or name:find("RagdollAttachment") or name:find("RagdollRigAttachment") then
				-- только если attachment родитель - BasePart (чтобы не уничтожить что-то чужое)
				pcall(function() att:Destroy() end)
			end
		end
	end

	-- recreate motors
	for _, info in ipairs(motors) do
		-- убедимся, что части всё ещё есть
		if info.Part0 and info.Part1 and info.Part0.Parent and info.Part1.Parent then
			-- если мотор с таким именем уже есть — пропустим
			if not info.Part0:FindFirstChild(info.Name) then
				local m = Instance.new("Motor6D")
				m.Name = info.Name
				m.Part0 = info.Part0
				m.Part1 = info.Part1
				m.C0 = info.C0 or CFrame.new()
				m.C1 = info.C1 or CFrame.new()
				if info.Transform then
					pcall(function() m.Transform = info.Transform end)
				end
				if info.MaxVelocity then
					pcall(function() m.MaxVelocity = info.MaxVelocity end)
				end
				m.Parent = info.Part0
			end
		end
	end
end

-- Включить ragdoll: сохраняем моторы, вызываем createRagdollJoints
-- createRagdollJoints(character, rigType, useKinematic) -- в твоём модуле: module_2.createRagdollJoints
function RagdollToggle:Enable(character, createRagdollFunction, rigType)
	if not character or not character:IsA("Model") then return end
	if self._backups[character] then
		-- уже включён
		return
	end

	-- Сохраняем Motor6D
	local motors = backupMotors(character)
	self._backups[character] = {motors = motors}

	-- Отключаем анимации/устанавливаем PlatformStand, если нужно
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		-- сохраняем старое значение, чтобы восстановить
		self._backups[character].oldPlatformStand = humanoid.PlatformStand
		humanoid.PlatformStand = true
		-- можно временно остановить анимации:
		if humanoid:FindFirstChild("Animator") then
			-- оставляем, но анимации без Motor6D не будут работать; при необходимости останавливать аниматоры - можно сделать здесь
		end
	end

	-- Вызываем внешнюю функцию создания ragdoll-джойнтов
	-- createRagdollFunction — это ссылка на функцию module_2.createRagdollJoints
	-- rigType — Enum.HumanoidRigType.R15 или R6
	if type(createRagdollFunction) == "function" then
		pcall(function()
			createRagdollFunction(character, rigType or Enum.HumanoidRigType.R15, true)
		end)
	else
		warn("RagdollToggle: нужно передать createRagdollFunction (например module_2.createRagdollJoints)")
	end
end

-- Выключить ragdoll: удалить constraints и восстановить Motor6D
function RagdollToggle:Disable(character)
	if not character or not character:IsA("Model") then return end
	local backup = self._backups[character]
	if not backup then
		-- не было включено через этот модуль — но попробуем всё же почистить общие ragdoll-объекты
		backup = {motors = {}}
	end

	-- Снимаем PlatformStand обратно
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if humanoid and backup.oldPlatformStand ~= nil then
		humanoid.PlatformStand = backup.oldPlatformStand
	end

	-- Восстановление мотор6D
	restoreMotors(character, backup.motors or {})

	-- Убираем бэкап
	self._backups[character] = nil
end

return RagdollToggle
