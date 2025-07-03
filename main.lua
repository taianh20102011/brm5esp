-- ✅ ESP + AIMBOT + GUI HOẠT ĐỘNG TRONG STUDIO + HỖ TRỢ VELOCITY + CHẠY ĐƯỢC TRONG BHRM5 + TÊN + MÁU

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AIM_PART = "Head"
local FOV_RADIUS = 120
local AIMBOT_KEY = Enum.KeyCode.Q
local CAMERA_KEY = Enum.KeyCode.V
local SHOW_PLAYER_ESP = true
local SHOW_NPC_ESP = true
local SHOW_SNAPLINE = true

local aimbotEnabled = false
local thirdPerson = false
local dragging = false
local velocityPrediction = true

-- Create GUI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))

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
panel.Size = UDim2.new(0, 200, 0, 250)
panel.Position = UDim2.new(0, 20, 0, 20)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
panel.Draggable = true
panel.Active = true

local function addButton(y, text, callback)
	local btn = Instance.new("TextButton", panel)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.Size = UDim2.new(0, 180, 0, 30)
	btn.Text = text
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.MouseButton1Click:Connect(callback)
end

addButton(10, "Toggle Aimbot (Q)", function()
	aimbotEnabled = not aimbotEnabled
end)
addButton(45, "Toggle POV (V)", function()
	thirdPerson = not thirdPerson
end)
addButton(80, "Player ESP", function()
	SHOW_PLAYER_ESP = not SHOW_PLAYER_ESP
end)
addButton(115, "NPC ESP", function()
	SHOW_NPC_ESP = not SHOW_NPC_ESP
end)
addButton(150, "Velocity Predict", function()
	velocityPrediction = not velocityPrediction
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
sliderLabel.Position = UDim2.new(0, 10, 0, 185)
sliderLabel.Size = UDim2.new(0, 180, 0, 20)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextScaled = true
sliderLabel.TextColor3 = Color3.new(1,1,1)
sliderLabel.Text = "FOV Radius: " .. FOV_RADIUS

local slider = Instance.new("TextButton", panel)
slider.Position = UDim2.new(0, 10, 0, 210)
slider.Size = UDim2.new(0, 180, 0, 20)
slider.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
slider.Text = ""

local handle = Instance.new("Frame", slider)
handle.Size = UDim2.new(0, 10, 0, 20)
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

	if aimbotEnabled and closest then
		local predictPos = closest.Position
		if velocityPrediction then
			local char = closest.Parent
			if char and char:FindFirstChild("HumanoidRootPart") then
				local vel = char.HumanoidRootPart.Velocity
				predictPos = predictPos + vel * 0.07
			end
		end
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
end)
