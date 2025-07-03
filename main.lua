-- ✅ ESP CHỈ (Player + NPC + Snapline + Tên + Máu) - TƯƠNG THÍCH MỌI MAP (BHRM5, VELOCITY, CUSTOM)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ⚙️ Cấu hình
local SHOW_PLAYER_ESP = true
local SHOW_NPC_ESP = true
local SHOW_SNAPLINE = true

-- 🧱 Tạo vùng chứa ESP
local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "ESP_Highlights"
highlightFolder.Parent = Camera

local gui = Instance.new("ScreenGui")
gui.Name = "ESP_GUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = CoreGui

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
	bb.Parent = Camera

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
end

-- 🔄 Vòng lặp ESP
RunService.RenderStepped:Connect(function()
	clearESP()
	local count = 0

	for _, model in ipairs(workspace:GetDescendants()) do
		if model:IsA("Model") then
			local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
			local head = model:FindFirstChild("Head") or root
			local humanoid = model:FindFirstChildOfClass("Humanoid") or model:FindFirstChildOfClass("AnimationController")

			if not (head and humanoid) then continue end

			local isPlayer = Players:GetPlayerFromCharacter(model)
			if isPlayer and not SHOW_PLAYER_ESP then continue end
			if not isPlayer and not SHOW_NPC_ESP then continue end
			if isPlayer == LocalPlayer then continue end

			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if not onScreen then continue end

			local hp = humanoid.Health or 0
			local maxhp = humanoid.MaxHealth or 100
			createBillboard(model, model.Name, math.floor(hp), math.floor(maxhp))

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

			count += 1
		end
	end

	if count == 0 then
		print("⚠️ Không tìm thấy NPC hoặc Player nào có thể ESP")
	else
		print("✅ ESP hiển thị cho " .. count .. " đối tượng")
	end
end)
