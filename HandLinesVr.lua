-- made by haker999
-- V2.0

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character

local linesFolder = workspace:FindFirstChild("HandLinesVr")

if not linesFolder then
	linesFolder = Instance.new("Folder")
	linesFolder.Name = "HandLinesVr"
	linesFolder.Parent = workspace
end

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
	attachment0.Parent = linesFolder

	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "HandLineEnd"
	attachment1.Parent = linesFolder

	local beam = Instance.new("Beam")
	beam.Name = "HandDownLine"
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
	beam.Parent = linesFolder

	table.insert(lines, attachment0)
	table.insert(lines, attachment1)
	table.insert(lines, beam)

	return {
		hand = hand,
		attachment0 = attachment0,
		attachment1 = attachment1
	}
end

local function setupCharacter(newCharacter)
	removeLines()

	character = newCharacter

	local leftHand = character:WaitForChild("LeftHand", 5) or character:FindFirstChild("Left Arm")
	local rightHand = character:WaitForChild("RightHand", 5) or character:FindFirstChild("Right Arm")

	if leftHand then
		table.insert(lines, createLine(leftHand))
	end

	if rightHand then
		table.insert(lines, createLine(rightHand))
	end
end

player.CharacterAdded:Connect(setupCharacter)

if player.Character then
	setupCharacter(player.Character)
end

RunService.RenderStepped:Connect(function()
	for _, lineData in ipairs(lines) do
		if typeof(lineData) == "table" and lineData.hand and lineData.hand.Parent then
			local hand = lineData.hand
			local attachment0 = lineData.attachment0
			local attachment1 = lineData.attachment1

			local handCFrame = hand.CFrame

			attachment0.WorldCFrame = handCFrame * CFrame.new(0, -0.15, 0)
			attachment1.WorldCFrame = handCFrame * CFrame.new(0, -LINE_LENGTH, 0)
		end
	end
end)
