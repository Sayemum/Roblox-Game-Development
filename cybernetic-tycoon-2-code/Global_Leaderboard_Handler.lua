--[[
Global_Leaderboard_Handler
Scripted By: BrawlBattle
Modified: 7/17/2020
Desc: Updates In-Game Global Leaderboards for Top Ranked Players (e.g. Most Coins, Most Kills, etc.)
--]]

local ServerStorage = game:GetService("ServerStorage")

local BindableEvents = ServerStorage.BindableEvents
local FirstDonatorChanged = BindableEvents.FirstDonatorChanged

local DSS = game:GetService("DataStoreService")
local rebootsLeaderboard = DSS:GetOrderedDataStore("RebootsLeaderboard1")
local killsLeaderboard = DSS:GetOrderedDataStore("KillsLeaderboard1")
local donationLeaderboard = DSS:GetOrderedDataStore("DonationsLeaderboard1")
local leaderboards = game.Workspace.MainMap.Leaderboards
local timer = leaderboards.Timer

--Updates Reboots Leaderboard
local function updateRebootsLeaderboard()
	local success, errorMessage = pcall(function()
		local Data = rebootsLeaderboard:GetSortedAsync(false, 100)
		local rebootsPage = Data:GetCurrentPage()
		for rank, data in ipairs(rebootsPage) do
			local userName = game.Players:GetNameFromUserIdAsync(tonumber(data.key))
			local name = userName
			local reboots = data.value
			local isOnLeaderboard = false
			for i,v in pairs(leaderboards.RebootLeaderboard.Screen.AllTimeGui.Holder:GetChildren()) do
				if v.Player.Text == name then
					isOnLeaderboard = true
					break
				end
			end
			
      --If player is top 15 and does not have a spot, create one and put on the board.
			if reboots > 0 and isOnLeaderboard == false then
				--print("New Lb Created!")
				local newLbFrame = script:WaitForChild("LeaderboardFrame"):Clone()
				newLbFrame.Player.Text = name
				newLbFrame.Reboots.Text = reboots
				newLbFrame.Rank.Text = "#"..rank
				newLbFrame.Position = UDim2.new(0, 0, newLbFrame.Position.Y.Scale + (.01 * #game.Workspace.MainMap.Leaderboards.RebootLeaderboard.Screen.AllTimeGui.Holder:GetChildren()), 0)
				newLbFrame.Parent = leaderboards.RebootLeaderboard.Screen.AllTimeGui.Holder
			end
		end
	end)
	
  --If it wasn't successful, throw an error
	if not success then
		warn(errorMessage)
	end
end

--Updates Kills Leaderboard
local function updateKillsLeaderboard()
	local success, errorMessage = pcall(function()
		local Data = killsLeaderboard:GetSortedAsync(false, 100)
		local killsPage = Data:GetCurrentPage()
		for rank, data in ipairs(killsPage) do
			local userName = game.Players:GetNameFromUserIdAsync(tonumber(data.key))
			local name = userName
			local kills = data.value
			local isOnLeaderboard = false
			for i,v in pairs(leaderboards.NPCKillsLeaderboard.Screen.AllTimeGui.Holder:GetChildren()) do
				if v.Player.Text == name then
					isOnLeaderboard = true
					break
				end
			end
			
       --If player is top 15 and does not have a spot, create one and put on the board.
			if kills > 0 and isOnLeaderboard == false then
				--print("New Kills Lb Created!")
				local newLbFrame = script:WaitForChild("LeaderboardFrame"):Clone()
				newLbFrame.Player.Text = name
				newLbFrame.Reboots.Text = kills
				newLbFrame.Rank.Text = "#"..rank
				newLbFrame.Position = UDim2.new(0, 0, newLbFrame.Position.Y.Scale + (0.01 * #game.Workspace.MainMap.Leaderboards.NPCKillsLeaderboard.Screen.AllTimeGui.Holder:GetChildren()), 0)
				newLbFrame.Parent = leaderboards.NPCKillsLeaderboard.Screen.AllTimeGui.Holder
			end
		end
	end)
	
  --If it wasn't successful, throw an error
	if not success then
		warn(errorMessage)
	end
end

--Updates Donations Leaderboard
local function updateDonationsLeaderboard()
	local success, errorMessage = pcall(function()
		local Data = donationLeaderboard:GetSortedAsync(false, 100)
		local donationsPage = Data:GetCurrentPage()
		for rank, data in ipairs(donationsPage) do
			local userName = game.Players:GetNameFromUserIdAsync(tonumber(data.key))
			local name = userName
			local donations = data.value
			local isOnLeaderboard = false
			
			for i, board in pairs(leaderboards:GetChildren()) do
				if board.Name == "DonationLeaderboard" then
					for i,v in pairs(board.Screen.AllTimeGui.Holder:GetChildren()) do
						if v.Player.Text == name then
							isOnLeaderboard = true
							break
						end
					end
				end
			end
			
      --If player is top 15 and does not have a spot, create one and put on the board.
			if donations > 0 and isOnLeaderboard == false then
				for i, board in pairs(game.Workspace.MainMap.Leaderboards:GetChildren()) do
					if board.Name == "DonationLeaderboard" then
						--print("New Donations Lb Created!")
						local newLbFrame = script:WaitForChild("LeaderboardFrame"):Clone()
						newLbFrame.Player.Text = name
						newLbFrame.Reboots.Text = donations
						newLbFrame.Rank.Text = "#"..rank
						newLbFrame.Position = UDim2.new(0, 0, newLbFrame.Position.Y.Scale + (0.01 * #board.Screen.AllTimeGui.Holder:GetChildren()), 0)
						newLbFrame.Parent = board.Screen.AllTimeGui.Holder
						
            --Do something special for the #1 spot
						if rank == 1 then
							FirstDonatorChanged:Fire(name)
						end
					end
				end
			end
		end
	end)
	
  --If it wasn't successful, throw an error
	if not success then
		warn(errorMessage)
	end
end

--Periodically update all leaderboards every 5 minutes
while true do
for _, player in pairs(game.Players:GetPlayers()) do
	rebootsLeaderboard:SetAsync(player.userId, player.leaderstats.Reboots.Value)
	wait(.1)
	killsLeaderboard:SetAsync(player.userId, player.leaderstats["NPC Kills"].Value)
	wait(.1)
	donationLeaderboard:SetAsync(player.userId, player.PlayerStats.Donations.Value)
end

for _, frame in pairs(leaderboards.RebootLeaderboard.Screen.AllTimeGui.Holder:GetChildren()) do
	frame:Destroy()
end
wait(.1)
for _, frame in pairs(leaderboards.NPCKillsLeaderboard.Screen.AllTimeGui.Holder:GetChildren()) do
	frame:Destroy()
end
wait(.1)
for i, board in pairs(leaderboards:GetChildren()) do
	if board.Name == "DonationLeaderboard" then
		for _, frame in pairs(board.Screen.AllTimeGui.Holder:GetChildren()) do
			frame:Destroy()
		end
	end
end

updateRebootsLeaderboard()
wait(.25)
updateKillsLeaderboard()
wait(.25)
updateDonationsLeaderboard()
print("Leaderboards Updated!")


for i = 1, timer.Value do
	wait(1)
	timer.Value = timer.Value - 1
	
	for i, board in pairs(leaderboards:GetChildren()) do
		if board:IsA("Model") then
			local timerText = board.Screen.AllTimeGui.TopBar.Timer
			timerText.Text = "⏰"..timer.Value
		end
	end
	
end

timer.Value = 300

end
