-- made by haker999
-- V2.6

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

local linesFolder = workspace:FindFirstChild("HandLinesVr")

if not linesFolder then
	linesFolder = Instance.new("Folder")
	linesFolder.Name = "HandLinesVr"
	linesFolder.Parent = workspace
end

local LINE_LENGTH = 4
local START_WIDTH = 0.045
local END_WIDTH = 0.005
local START_TRANSPARENCY = 0.35
local END_TRANSPARENCY = 1
local CONTROLLER_SCALE = Vector3.new(0.075, 0.075, 0.075)

task.spawn(function()
	while task.wait(0.5) do
		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
		end)
	end
end)

local function createVisuals(isRight)
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
	
	if isRight then
		beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
	else
		beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	end
	
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, START_TRANSPARENCY),
		NumberSequenceKeypoint.new(0.35, 0.55),
		NumberSequenceKeypoint.new(0.7, 0.8),
		NumberSequenceKeypoint.new(1, END_TRANSPARENCY)
	})
	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.Segments = 10
	beam.Enabled = false
	beam.Parent = linesFolder

	local controllerPart = Instance.new("Part")
	controllerPart.Name = (isRight and "Right" or "Left") .. "Controller"
	controllerPart.Size = Vector3.new(0.1, 0.1, 0.1)
	controllerPart.CanCollide = false
	controllerPart.Massless = true
	controllerPart.Transparency = 1
	controllerPart.Anchored = true
	controllerPart.Parent = linesFolder

	local meshId = isRight and "rbxassetid://9399420123" or "rbxassetid://9399420068"
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = meshId
	mesh.Scale = CONTROLLER_SCALE
	mesh.Parent = controllerPart

	return {
		attachment0 = attachment0,
		attachment1 = attachment1,
		beam = beam,
		controller = controllerPart
	}
end

local leftVisuals = createVisuals(false)
local rightVisuals = createVisuals(true)

local function updateVisuals(visuals, handPart)
	if not handPart or not handPart.Parent then
		visuals.beam.Enabled = false
		visuals.controller.Transparency = 1
		return
	end

	visuals.beam.Enabled = true
	visuals.controller.Transparency = 0

	local isR6 = handPart.Name == "Left Arm" or handPart.Name == "Right Arm"
	local yOffset = isR6 and -1 or 0
	local offsetCFrame = CFrame.new(0, yOffset, 0)
	
	local handCFrame = handPart.CFrame
	local finalCFrame = handCFrame * offsetCFrame
	
	visuals.controller.CFrame = finalCFrame

	local startPos = finalCFrame.Position
	local endPos = (finalCFrame * CFrame.new(0, -LINE_LENGTH, 0)).Position

	local destroyHeight = workspace.FallenPartsDestroyHeight + 2

	if startPos.Y < destroyHeight then
		startPos = Vector3.new(startPos.X, destroyHeight, startPos.Z)
	end
	
	if endPos.Y < destroyHeight then
		endPos = Vector3.new(endPos.X, destroyHeight, endPos.Z)
	end

	visuals.attachment0.WorldPosition = startPos
	visuals.attachment1.WorldPosition = endPos
end

RunService.RenderStepped:Connect(function()
	local character = player.Character
	
	local leftHand = character and (character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm"))
	local rightHand = character and (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"))

	updateVisuals(leftVisuals, leftHand)
	updateVisuals(rightVisuals, rightHand)
end)
