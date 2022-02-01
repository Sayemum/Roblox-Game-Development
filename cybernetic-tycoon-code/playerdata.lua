--// PlayerData
--// Scripted by: BrawlBattle
--// Desc: Saves and Loads Player Data when the player joins or leaves the game.

local DSS = game:GetService("DataStoreService"):GetDataStore("Leaderstats1") --Name of the DataStore

--Function runs when player joins the game
local function playerAdded(plr)
	repeat wait() until plr.Character
	local key = 'id-'..plr.userId --Key is the userId of the player
	
	local stats = plr:WaitForChild("leaderstats")
	local eventStats = plr:WaitForChild("EventStats")
	
	local cash = game.ServerStorage.PlayerMoney:FindFirstChild(plr.Name)
	local gems = stats:WaitForChild("Gems")
	local prestige = stats:WaitForChild("Reboots")
	local easterEggs = eventStats:WaitForChild("EasterEggs")
	
  --Fetch player data from DataStore with name and key
	local success, getSavedData = pcall(DSS.GetAsync, DSS, key)
	if success and getSavedData then
		cash.Value = getSavedData[1]
		gems.Value = getSavedData[2]
		prestige.Value = getSavedData[3]
		easterEggs.Value = getSavedData[4]
	else --Save data if it already doesn't exist
		local saving = {cash.Value, gems.Value, prestige.Value, easterEggs.Value}
		pcall(DSS.SetAsync, DSS, key, saving)
	end

end
game.Players.PlayerAdded:Connect(playerAdded)

--Save Player Data when game shuts down
game:BindToClose(function()
	if #game.Players:GetPlayers() > 1 then
		for i, plr in pairs(game.Players:GetPlayers()) do
			local key = 'id-'..plr.userId
			local save = {game.ServerStorage.PlayerMoney:FindFirstChild(plr.Name).Value, plr.leaderstats.Gems.Value, plr.leaderstats.Reboots.Value, plr.EventStats.EasterEggs.Value}
			pcall(DSS.SetAsync, DSS, key, save)
		end
	end
end)

--Save data when player leaves
local function playerRemoving(plr)
	local key = 'id-'..plr.userId
	local save = {game.ServerStorage.PlayerMoney:FindFirstChild(plr.Name).Value, plr.leaderstats.Gems.Value, plr.leaderstats.Reboots.Value, plr.EventStats.EasterEggs.Value}
	pcall(DSS.SetAsync, DSS, key, save)
end
game.Players.PlayerRemoving:Connect(playerRemoving)


--Periodically save player data every 6 minutes
while wait(360) do
	for i, plr in pairs(game.Players:GetPlayers()) do
		local key = 'id-'..plr.userId
		local save = {game.ServerStorage.PlayerMoney:FindFirstChild(plr.Name).Value, plr.leaderstats.Gems.Value, plr.leaderstats.Reboots.Value, plr.EventStats.EasterEggs.Value}
		pcall(DSS.SetAsync, DSS, key, save)
		print("Auto Saving "..plr.Name.."'s Leaderstats!")
	end
end
