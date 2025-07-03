local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local PLAYER_COLOR = Color3.fromRGB(0, 170, 255)
local NPC_COLOR = Color3.fromRGB(255, 85, 85)

-- Create BillboardGui nametag
local function createNameTag(character, nameText, textColor)
	if not character:FindFirstChild("Head") then return end
	if character.Head:FindFirstChild("NameTag") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameTag"
	billboard.Size = UDim2.new(0, 100, 0, 30)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.Adornee = character.Head
	billboard.AlwaysOnTop = true
	billboard.Parent = character.Head

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = nameText
	textLabel.TextColor3 = textColor
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextScaled = true
	textLabel.Parent = billboard
end

-- Add highlight
local function addHighlight(character, color)
	if character:FindFirstChild("Highlight") then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "Highlight"
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0
	highlight.OutlineColor = color
	highlight.Adornee = character
	highlight.Parent = character
end

-- Handle character (Player or NPC)
local function handleCharacter(char)
	if not char:FindFirstChild("Humanoid") then return end

	local isPlayer = Players:GetPlayerFromCharacter(char)
	if isPlayer then
		createNameTag(char, isPlayer.DisplayName or isPlayer.Name, PLAYER_COLOR)
		addHighlight(char, PLAYER_COLOR)
	else
		createNameTag(char, char.Name, NPC_COLOR)
		addHighlight(char, NPC_COLOR)
	end
end

-- Listen to new characters/NPCs added
Workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") then
		handleCharacter(descendant)
	end
end)

-- Handle all existing ones in workspace
for _, model in ipairs(Workspace:GetDescendants()) do
	if model:IsA("Model") and model:FindFirstChild("Humanoid") then
		handleCharacter(model)
	end
end

-- Handle new player joins
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		handleCharacter(character)
	end)
end)
