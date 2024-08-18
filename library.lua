game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = 9e9

for i, v in ipairs(game:GetDescendants()) do
	if v:IsA("RemoteEvent") then
		v:FireServer()
	elseif v:IsA("RemoteFunction") then
		v:InvokeServer()
	end
end
