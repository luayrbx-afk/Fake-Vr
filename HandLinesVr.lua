-- made by haker999
-- V2.5

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

local handData = {
	left = nil,
	right = nil
}

local LINE_LENGTH = 4
local START_WIDTH = 0.045
local END_WIDTH = 0.005
local START_TRANSPARENCY = 0.35
local END_TRANSPARENCY = 1
local CONTROLLER_SCALE = Vector3.new(0.06, 0.06, 0.06)

task.spawn(function()
	while task.wait(0.5) do
		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
		end)
		
		if not linesFolder or not linesFolder.Parent then
			linesFolder = Instance.new("Folder")
			linesFolder.Name = "HandLinesVr"
			linesFolder.Parent = workspace
		end
	end
end)

local function cleanupHand(side)
	if handData[side] then
		local data = handData[side]
		if data.attachment0 then data.attachment0:Destroy() end
		if data.attachment1 then data.attachment1:Destroy() end
		if data.beam then data.beam:Destroy() end
		if data.controller then data.controller:Destroy() end
		handData[side] = nil
	end
end

local function createHandVisuals(hand, isRight)
	local side = isRight and "right" or "left"
	cleanupHand(side)

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
	beam.Parent = linesFolder

	local controllerPart = Instance.new("Part")
	controllerPart.Name = hand.Name .. "Controller"
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

	local isR6 = hand.Name == "Left Arm" or hand.Name == "Right Arm"
	local yOffset = isR6 and -1 or 0
	local offsetCFrame = CFrame.new(0, yOffset, 0)

	handData[side] = {
		hand = hand,
		attachment0 = attachment0,
		attachment1 = attachment1,
		beam = beam,
		controller = controllerPart,
		offset = offsetCFrame
	}
end

RunService.RenderStepped:Connect(function()
	local character = player.Character
	local expectedLeft = character and (character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm"))
	local expectedRight = character and (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"))

	if expectedLeft and (not handData.left or handData.left.hand ~= expectedLeft or not handData.left.hand.Parent) then
		createHandVisuals(expectedLeft, false)
	elseif not expectedLeft and handData.left then
		cleanupHand("left")
	end

	if expectedRight and (not handData.right or handData.right.hand ~= expectedRight or not handData.right.hand.Parent) then
		createHandVisuals(expectedRight, true)
	elseif not expectedRight and handData.right then
		cleanupHand("right")
	end

	local destroyHeight = workspace.FallenPartsDestroyHeight + 2

	for side, data in pairs(handData) do
		if data.hand and data.hand.Parent and data.controller and data.controller.Parent and data.beam and data.beam.Parent then
			local handCFrame = data.hand.CFrame
			
			data.controller.CFrame = handCFrame * data.offset
			
			local startPos = (handCFrame * data.offset).Position
			local endPos = (handCFrame * data.offset * CFrame.new(0, -LINE_LENGTH, 0)).Position
			
			if startPos.Y < destroyHeight then
				startPos = Vector3.new(startPos.X, destroyHeight, startPos.Z)
			end
			
			if endPos.Y < destroyHeight then
				endPos = Vector3.new(endPos.X, destroyHeight, endPos.Z)
			end

			data.attachment0.WorldPosition = startPos
			data.attachment1.WorldPosition = endPos
		else
			cleanupHand(side)
		end
	end
end)
