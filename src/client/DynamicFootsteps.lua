local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local FootstepEvent = ReplicatedStorage:WaitForChild("FootstepEvent")
local soundFolder = ReplicatedStorage:WaitForChild("FootstepSounds")

local character, humanoid, root
local lastStepTime = 0
local STEP_INTERVAL_WALK = 0.25 --adjust according to how speed the player movement is "Match the steps"
local STEP_INTERVAL_RUN = 0.24 --adjust according to how speed the player movement is "Match the steps"

-- Get surface material under feet
local function getSurfaceMaterial()
	if not root then return "Default" end

	local rayOrigin = root.Position
	local rayDirection = Vector3.new(0, -5, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local ray = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	if ray and ray.Material then
		local matName = ray.Material.Name
		if soundFolder:FindFirstChild(matName) then
			return matName
		end
	end

	return "Default"
end

-- Trigger server to play footstep
local function playFootstep(materialName)
	if root then
		FootstepEvent:FireServer(materialName, root.Position)
	end
end

-- On spawn
local function onCharacterAdded(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

-- Step loop
RunService.RenderStepped:Connect(function()
	if not humanoid or humanoid.MoveDirection.Magnitude == 0 then return end
	if humanoid.FloorMaterial == Enum.Material.Air then return end --  Skip if airborne

	local now = tick()
	local isRunning = humanoid.WalkSpeed > 20
	local interval = isRunning and STEP_INTERVAL_RUN or STEP_INTERVAL_WALK

	if now - lastStepTime >= interval then
		local material = getSurfaceMaterial()
		playFootstep(material)
		lastStepTime = now
	end
end)
