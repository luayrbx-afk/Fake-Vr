-- made by haker999
-- V2.3

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character
local humanoid

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

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end)

local function removeLines()
	for _, object in ipairs(lines) do
		if object and object.Parent then
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

	return {
		hand = hand,
		attachment0 = attachment0,
		attachment1 = attachment1,
		beam = beam
	}
end

local function setupCharacter(newCharacter)
	removeLines()

	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")

	local leftHand = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
	local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")

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
		if lineData.hand and lineData.hand.Parent then
			local handCFrame = lineData.hand.CFrame

			lineData.attachment0.WorldCFrame = handCFrame * CFrame.new(0, -0.15, 0)
			lineData.attachment1.WorldCFrame = handCFrame * CFrame.new(0, -LINE_LENGTH, 0)
		end
	end
end)
