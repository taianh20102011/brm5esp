-- ✅ ESP + AIMBOT + GUI HOẠT ĐỘNG TRONG BHRM5 + HỖ TRỢ VELOCITY EXECUTOR + SNAPLINE + TRIGGERBOT + PREDICTION MENU + CHAMS

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer or not LocalPlayer:FindFirstChild("PlayerGui") do
	task.wait()
	LocalPlayer = Players.LocalPlayer
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local AIM_PART = "Head"
local FOV_RADIUS = 120
local PREDICTION_TIME = 0.07
local AIMBOT_KEY = Enum.KeyCode.Q
local CAMERA_KEY = Enum.KeyCode.V
local SHOW_PLAYER_ESP = true
local SHOW_NPC_ESP = true
local SHOW_SNAPLINE = true
local velocityPrediction = true
local holdRightMouseToAim = true
local triggerBot = true

local aimbotEnabled = false
local thirdPerson = false
local rightMouseHeld = false

local gui = Instance.new("ScreenGui")
gui.Name = "AimbotESP_GUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local fovCircle = Instance.new("Frame", gui)
fovCircle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
local stroke = Instance.new("UIStroke", fovCircle)
stroke.Color = Color3.fromRGB(0, 255, 255)
stroke.Thickness = 2
stroke.Transparency = 0.4
local corner = Instance.new("UICorner", fovCircle)
corner.CornerRadius = UDim.new(1, 0)

local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 220, 0, 300)
panel.Position = UDim2.new(0, 20, 0, 20)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
panel.BorderColor3 = Color3.fromRGB(0, 255, 255)
panel.BorderSizePixel = 2
panel.Active = true

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "🎯 ESP & Aimbot GUI"
title.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local function addButton(y, text, callback)
	local btn = Instance.new("TextButton", panel)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.Size = UDim2.new(0, 200, 0, 30)
	btn.Text = text
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BorderSizePixel = 0
	btn.MouseButton1Click:Connect(callback)
end

addButton(30, "Toggle Aimbot (Q)", function()
	aimbotEnabled = not aimbotEnabled
end)
addButton(65, "Toggle POV (V)", function()
	thirdPerson = not thirdPerson
end)
addButton(100, "Player ESP", function()
	SHOW_PLAYER_ESP = not SHOW_PLAYER_ESP
end)
addButton(135, "NPC ESP", function()
	SHOW_NPC_ESP = not SHOW_NPC_ESP
end)
addButton(170, "Velocity Predict", function()
	velocityPrediction = not velocityPrediction
end)
addButton(205, "Hold RMB to Aim", function()
	holdRightMouseToAim = not holdRightMouseToAim
end)
addButton(240, "TriggerBot", function()
	triggerBot = not triggerBot
end)

local predSlider = Instance.new("TextBox", panel)
predSlider.Position = UDim2.new(0, 10, 0, 275)
predSlider.Size = UDim2.new(0, 200, 0, 20)
predSlider.Text = "Prediction Time: " .. tostring(PREDICTION_TIME)
predSlider.TextColor3 = Color3.fromRGB(255,255,255)
predSlider.BackgroundColor3 = Color3.fromRGB(40,40,60)
predSlider.FocusLost:Connect(function()
	local val = tonumber(predSlider.Text:match("%d+%.?%d*"))
	if val then
		PREDICTION_TIME = val
		predSlider.Text = "Prediction Time: " .. tostring(PREDICTION_TIME)
	end
end)

local highlightFolder = Instance.new("Folder", workspace)
highlightFolder.Name = "ESP_Highlights"
local lineFolder = Instance.new("Folder", gui)
lineFolder.Name = "ESP_Lines"

local function clearESP()
	highlightFolder:ClearAllChildren()
	lineFolder:ClearAllChildren()
end

local function getPredictedPosition(part)
	if not part or not part:IsA("BasePart") then return part.Position end
	local velocity = part.AssemblyLinearVelocity or part.Velocity
	return part.Position + velocity * PREDICTION_TIME
end

local function drawSnapline(screenPos)
	local line = Instance.new("Frame")
	line.Size = UDim2.new(0, 2, 0, (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude)
	line.AnchorPoint = Vector2.new(0.5, 0)
	line.Position = UDim2.new(0, Camera.ViewportSize.X/2, 0, Camera.ViewportSize.Y/2)
	line.Rotation = math.deg(math.atan2(screenPos.Y - Camera.ViewportSize.Y/2, screenPos.X - Camera.ViewportSize.X/2)) - 90
	line.BackgroundColor3 = Color3.fromRGB(255,255,0)
	line.BorderSizePixel = 0
	line.Parent = lineFolder
end

local function createBillboard(model, nameText, health, maxHealth)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 200, 0, 40)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.AlwaysOnTop = true
	bb.Name = "ESP_Billboard"
	bb.Adornee = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")

	local nameLabel = Instance.new("TextLabel", bb)
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.Text = nameText
	nameLabel.TextColor3 = Color3.new(1,1,1)
	nameLabel.TextScaled = true
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold

	local hpLabel = Instance.new("TextLabel", bb)
	hpLabel.Position = UDim2.new(0, 0, 0.5, 0)
	hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
	hpLabel.Text = "HP: " .. health .. "/" .. maxHealth
	hpLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	hpLabel.TextScaled = true
	hpLabel.BackgroundTransparency = 1
	hpLabel.Font = Enum.Font.Gotham

	bb.Parent = highlightFolder
end

local function triggerAction(target)
	print("TriggerBot target: ", target and target.Parent and target.Parent.Name or "Unknown")
end

RunService.RenderStepped:Connect(function()
	local mouse = UserInputService:GetMouseLocation()
	fovCircle.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
	fovCircle.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
	fovCircle.Visible = aimbotEnabled

	clearESP()
	local closest, shortest = nil, FOV_RADIUS

	for _, model in ipairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model:FindFirstChild(AIM_PART) and model:FindFirstChildOfClass("Humanoid") then
			local isPlayer = Players:GetPlayerFromCharacter(model)
			if isPlayer and not SHOW_PLAYER_ESP then continue end
			if not isPlayer and not SHOW_NPC_ESP then continue end
			if isPlayer == LocalPlayer then continue end

			local head = model[AIM_PART]
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if not onScreen then continue end

			local humanoid = model:FindFirstChildOfClass("Humanoid")
			local hp = math.floor(humanoid.Health)
			local maxhp = math.floor(humanoid.MaxHealth)
			createBillboard(model, model.Name, hp, maxhp)

			local highlight = Instance.new("Highlight")
			highlight.Adornee = model
			highlight.FillColor = Color3.fromRGB(255, math.clamp(255 - hp/maxhp * 255, 0, 255), 0)
			highlight.OutlineColor = Color3.fromRGB(255,255,255)
			highlight.FillTransparency = 0.3
			highlight.OutlineTransparency = 0
			highlight.Parent = highlightFolder

			if SHOW_SNAPLINE then drawSnapline(Vector2.new(screenPos.X, screenPos.Y)) end

			local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
			if dist < shortest then
				shortest = dist
				closest = head
			end
		end
	end

	if aimbotEnabled and closest and (not holdRightMouseToAim or rightMouseHeld) then
		local predictPos = velocityPrediction and getPredictedPosition(closest) or closest.Position
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, predictPos)
		if triggerBot then triggerAction(closest) end
	elseif thirdPerson and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local root = LocalPlayer.Character.HumanoidRootPart
		Camera.CFrame = CFrame.new(root.Position - root.CFrame.LookVector * 6 + Vector3.new(0, 2, 0), root.Position)
	end
end)

UserInputService.InputBegan:Connect(function(i, gpe)
	if gpe then return end
	if i.KeyCode == AIMBOT_KEY then aimbotEnabled = not aimbotEnabled end
	if i.KeyCode == CAMERA_KEY then thirdPerson = not thirdPerson end
	if i.UserInputType == Enum.UserInputType.MouseButton2 then rightMouseHeld = true end
end)

UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2 then rightMouseHeld = false end
end)
