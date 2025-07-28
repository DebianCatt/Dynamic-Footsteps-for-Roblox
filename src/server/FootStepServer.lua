local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")


local FootstepEvent = ReplicatedStorage:WaitForChild("FootstepEvent")
local FootstepSounds = ReplicatedStorage:WaitForChild("FootstepSounds")

FootstepEvent.OnServerEvent:Connect(function(player, materialName, position)
	-- Validate input
	if typeof(position) ~= "Vector3" or typeof(materialName) ~= "string" then return end

	local soundTemplate = FootstepSounds:FindFirstChild(materialName) or FootstepSounds:FindFirstChild("Default")
	if not soundTemplate then return end

	-- Create invisible part at player's feet
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Name = "FootstepSoundPart"
	part.Parent = workspace

	-- Clone the sound into it
	local sound = soundTemplate:Clone()
	sound.Parent = part
	sound.PlaybackSpeed = math.random(50, 80) / 100  -- random between 0.9 and 1.1
	sound.Volume = math.random(10, 30) / 100 -- 0.9 to 1.0 volume
	sound:Play()

	-- Cleanup
	Debris:AddItem(part, 2)
end)
