-- ✅ ESP CHỈ (Player + NPC + Snapline + Tên + Máu) - TƯƠNG THÍCH MỌI MAP (BHRM5, VELOCITY, CUSTOM) - CODE MỚI TOÀN BỘ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ⚙️ Cấu hình
local SHOW_PLAYER_ESP = true
local SHOW_NPC_ESP = true
local SHOW_SNAPLINE = true

-- 🗃️ Tạo vùng chứa ESP
local espFolder = Instance.new("Folder")
espFolder.Name = "ESP_Container"
espFolder.Parent = Camera

local gui = Instance.new("ScreenGui")
gui.Name = "ESP_GUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = CoreGui

local snaplineFolder = Instance.new("Folder")
snaplineFolder.Name = "Snaplines"
snaplineFolder.Parent = gui

-- 🧹 Xóa ESP cũ
local function clearESP()
	espFolder:ClearAllChildren()
	snaplineFolder:ClearAllChildren()
end

-- 🔫 Vẽ Snapline
local function drawSnapline(screenPos)
	local line = Instance.new("Frame")
	line.Size = UDim2.new(0, 2, 0, (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude)
	line.AnchorPoint = Vector2.new(0.5, 0)
	line.Position = UDim2.new(0, Camera.ViewportSize.X/2, 0, Camera.ViewportSize.Y/2)
	line.Rotation = math.deg(math.atan2(screenPos.Y - Camera.ViewportSize.Y/2, screenPos.X - Camera.ViewportSize.X/2)) - 90
	line.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
	line.BorderSizePixel = 0
	line.Name = "Snapline"
	line.Parent = snaplineFolder
end

-- 🧾 Hiển thị Tên và Máu
local function createBillboard(model, nameText, healthText)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 200, 0, 40)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.AlwaysOnTop = true
	bb.Name = "ESP_Billboard"
	bb.Adornee = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	bb.Parent = espFolder

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = nameText
	nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = bb

	local hpLabel = Instance.new("TextLabel")
	hpLabel.Position = UDim2.new(0, 0, 0.5, 0)
	hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
	hpLabel.BackgroundTransparency = 1
	hpLabel.Text = healthText
	hpLabel.TextColor3 = Color3.fromRGB(255,100,100)
	hpLabel.TextScaled = true
	hpLabel.Font = Enum.Font.Gotham
	hpLabel.Parent = bb
end

-- 🔄 Vòng lặp
RunService.RenderStepped:Connect(function()
	clearESP()

	for _, model in ipairs(workspace:GetDescendants()) do
		if model:IsA("Model") then
			local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
			local head = model:FindFirstChild("Head") or root
			local humanoid = model:FindFirstChildOfClass("Humanoid")

			if not (head and humanoid) then continue end

			local isPlayer = Players:GetPlayerFromCharacter(model)
			if isPlayer == LocalPlayer then continue end
			if isPlayer and not SHOW_PLAYER_ESP then continue end
			if not isPlayer and not SHOW_NPC_ESP then continue end

			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if not onScreen then continue end

			local hp = math.floor(humanoid.Health)
			local maxhp = math.floor(humanoid.MaxHealth)

			createBillboard(model, model.Name, "HP: " .. hp .. "/" .. maxhp)

			local highlight = Instance.new("Highlight")
			highlight.Adornee = model
			highlight.FillColor = Color3.fromRGB(255, math.clamp(255 - hp/maxhp * 255, 0, 255), 0)
			highlight.OutlineColor = Color3.new(1,1,1)
			highlight.FillTransparency = 0.3
			highlight.OutlineTransparency = 0
			highlight.Parent = espFolder

			if SHOW_SNAPLINE then
				drawSnapline(Vector2.new(screenPos.X, screenPos.Y))
			end
		end
	end
end)
