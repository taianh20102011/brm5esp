-- ✅ ESP CHỈ (Player + NPC + Snapline + Tên + Máu) - TỐI ƯU CHẠY TRONG STUDIO & BHRM5

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ⚙️ Cấu hình
local SHOW_PLAYER_ESP = true
local SHOW_NPC_ESP = true
local SHOW_SNAPLINE = true
local AIM_PART = "Head"

-- 🧱 Tạo vùng chứa ESP
local highlightFolder = Instance.new("Folder", workspace)
highlightFolder.Name = "ESP_Highlights"

local gui = Instance.new("ScreenGui")
gui.Name = "ESP_GUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local lineFolder = Instance.new("Folder", gui)
lineFolder.Name = "ESP_Lines"

-- 🧹 Xóa ESP cũ
local function clearESP()
	highlightFolder:ClearAllChildren()
	lineFolder:ClearAllChildren()
end

-- 🔫 Vẽ snapline
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

-- 🧾 Hiển thị Tên + Máu
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

-- 🔄 Vòng lặp ESP
RunService.RenderStepped:Connect(function()
	clearESP()

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

			if SHOW_SNAPLINE then
				drawSnapline(Vector2.new(screenPos.X, screenPos.Y))
			end
		end
	end
end)
