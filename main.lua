-- ✅ ESP + AIMBOT + GUI HOẠT ĐỘNG TRONG BHRM5 + HỖ TRỢ VELOCITY EXECUTOR

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Wait for LocalPlayer & GUI
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer or not LocalPlayer:FindFirstChild("PlayerGui") do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- SETTINGS
local AIM_PART = "Head"
local FOV_RADIUS = 120
local AIMBOT_KEY = Enum.KeyCode.Q
local CAMERA_KEY = Enum.KeyCode.V
local SHOW_PLAYER_ESP = true
local SHOW_NPC_ESP = true
local SHOW_SNAPLINE = true
local velocityPrediction = true
local holdRightMouseToAim = true

-- STATE
local aimbotEnabled = false
local thirdPerson = false
local dragging = false
local rightMouseHeld = false

-- GUI
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
panel.Size = UDim2.new(0, 220, 0, 270)
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

-- ESP Storage
local highlightFolder = Instance.new("Folder", workspace)
highlightFolder.Name = "ESP_Highlights"

-- Billboard for name + HP
local function createBillboard(model, nameText, healthText)
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
	hpLabel.Text = healthText
	hpLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	hpLabel.TextScaled = true
	hpLabel.BackgroundTransparency = 1
	hpLabel.Font = Enum.Font.Gotham

	bb.Parent = highlightFolder
end

-- FOV Slider
local sliderLabel = Instance.new("TextLabel", panel)
sliderLabel.Position = UDim2.new(0, 10, 0, 240)
sliderLabel.Size = UDim2.new(0, 200, 0, 20)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextScaled = true
sliderLabel.TextColor3 = Color3.new(1,1,1)
sliderLabel.Text = "FOV Radius: " .. FOV_RADIUS

local slider = Instance.new("TextButton", panel)
slider.Position = UDim2.new(0, 10, 0, 260)
slider.Size = UDim2.new(0, 200, 0, 15)
slider.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
slider.Text = ""

local handle = Instance.new("Frame", slider)
handle.Size = UDim2.new(0, 10, 0, 15)
handle.Position = UDim2.new((FOV_RADIUS-30)/170, 0, 0, 0)
handle.BackgroundColor3 = Color3.fromRGB(0, 255, 255)

slider.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Clean Highlights
local function clearESP()
	for _, v in pairs(highlightFolder:GetChildren()) do
		v:Destroy()
	end
end

-- Prediction function
local function getPredictedPosition(part)
	if not part or not part:IsA("BasePart") then return part.Position end
	local velocity = part.Velocity
	local distance = (Camera.CFrame.Position - part.Position).Magnitude
	local bulletSpeed = 400
	local timeToTarget = distance / bulletSpeed
	return part.Position + velocity * timeToTarget
end

-- Render Loop
RunService.RenderStepped:Connect(function()
	local mouse = UserInputService:GetMouseLocation()
	fovCircle.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
	fovCircle.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
	fovCircle.Visible = aimbotEnabled

	if dragging then
		local pct = math.clamp((mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
		FOV_RADIUS = math.floor(30 + pct * 170)
		sliderLabel.Text = "FOV Radius: " .. FOV_RADIUS
		handle.Position = UDim2.new(pct, 0, 0, 0)
	end

	clearESP()
	local closest, shortest = nil, FOV_RADIUS

	for _, model in ipairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model:FindFirstChild(AIM_PART) and model:FindFirstChildOfClass("Humanoid") then
			local isPlayer = Players:GetPlayerFromCharacter(model)
			if isPlayer and not SHOW_PLAYER_ESP then continue end
			if not isPlayer and not SHOW_NPC_ESP then continue end
			if isPlayer == LocalPlayer then continue end

			local head = model[AIM_PART]
			local torso = model:FindFirstChild("HumanoidRootPart") or head
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if not onScreen then continue end

			local highlight = Instance.new("Highlight")
			highlight.Adornee = model
			highlight.FillColor = isPlayer and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,140,0)
			highlight.OutlineColor = Color3.fromRGB(255,255,255)
			highlight.FillTransparency = 0.3
			highlight.OutlineTransparency = 0
			highlight.Parent = highlightFolder

			local name = isPlayer and model.Name or (model.Name .. " [NPC]")
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			local hp = humanoid and math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth) or "?"
			createBillboard(model, name, "HP: " .. hp)

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
