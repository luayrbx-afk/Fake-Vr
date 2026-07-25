-- made by haker999

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character

local lines = {}

local LINE_LENGTH = 2.5
local LINE_THICKNESS = 0.035
local LINE_TRANSPARENCY = 0.5

local function removeLines()
	for _, line in pairs(lines) do
		if line then
			line:Destroy()
		end
	end

	lines = {}
end

local function createLine(hand)
	local attachment0 = Instance.new("Attachment")
	attachment0.Name = "HandLineStart"
	attachment0.Position = Vector3.new(0, 0, -0.15)
	attachment0.Parent = hand

	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "HandLineEnd"
	attachment1.Position = Vector3.new(0, 0, -LINE_LENGTH)
	attachment1.Parent = hand

	local beam = Instance.new("Beam")
	beam.Name = "HandForwardLine"
	beam.Attachment0 = attachment0
	beam.Attachment1 = attachment1
	beam.Width0 = LINE_THICKNESS
	beam.Width1 = LINE_THICKNESS
	beam.Color = ColorSequence.new(Color3.new(1, 1, 1))
	beam.Transparency = NumberSequence.new(LINE_TRANSPARENCY)
	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.Parent = hand

	table.insert(lines, attachment0)
	table.insert(lines, attachment1)
	table.insert(lines, beam)
end

local function setupCharacter(newCharacter)
	removeLines()

	character = newCharacter

	local leftHand = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
	local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")

	if leftHand then
		createLine(leftHand)
	end

	if rightHand then
		createLine(rightHand)
	end
end

player.CharacterAdded:Connect(setupCharacter)

if player.Character then
	setupCharacter(player.Character)
end
