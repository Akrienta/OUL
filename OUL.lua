local Players = game:GetService("Players") 
local KICK_MESSAGE = "OUL Is Currently Down Please Wait Whilst We Fix The Issue"  
Players.PlayerAdded:Connect(function(player) 	
		player:Kick(KICK_MESSAGE) end)  _, 
player in ipairs(Players:GetPlayers()) do 	
	player:Kick(KICK_MESSAGE) end
