-- made by haker999
-- V1.8

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character

local lines = {}

local LINE_LENGTH = 4
local START_WIDTH = 0.045
local END_WIDTH = 0.005
local START_TRANSPARENCY = 0.35
local END_TRANSPARENCY = 1

local function removeLines()
	for _, object in ipairs(lines) do
		if object then
			object:Destroy()
		end
	end

	table.clear(lines)
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
	beam.Width0 = START_WIDTH
	beam.Width1 = END_WIDTH
	beam.Color = ColorSequence.new(Color3.new(1, 1, 1))
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, START_TRANSPARENCY),
		NumberSequenceKeypoint.new(0.35, 0.55),
		NumberSequenceKeypoint.new(0.7, 0.8),
		NumberSequenceKeypoint.new(1, END_TRANSPARENCY)
	})
	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.Segments = 10
	beam.Parent = hand

	table.insert(lines, attachment0)
	table.insert(lines, attachment1)
	table.insert(lines, beam)
end

local function setupCharacter(newCharacter)
	removeLines()

	character = newCharacter

	local leftHand = character:WaitForChild("LeftHand", 5) or character:FindFirstChild("Left Arm")
	local rightHand = character:WaitForChild("RightHand", 5) or character:FindFirstChild("Right Arm")

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
