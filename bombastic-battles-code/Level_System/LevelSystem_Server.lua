--// LevelSystem_Server
--// Scripted by: BrawlBattle
--// Desc: Handles the level system on the server side.

local LevelSystem = {}

local SS = game:GetService("ServerStorage")

local DS2 = require(SS:WaitForChild("DataStore2"))
local shopAssets = SS:WaitForChild("Assets"):WaitForChild("ShopAssets")

local RS = game:GetService("ReplicatedStorage")
local updatePlayerList = RS:WaitForChild("UpdatePlayerList")
local showPrestigeButton = RS:WaitForChild("ShowPrestigeButton")

game.Players.PlayerAdded:Connect(function(plr)
	
	--Show Prestige Button if plr is Level 100
	local level = DS2("Level", plr):Get(0)
	local prestige = DS2("Prestige", plr):Get(0)
	
	if (level == 100) and (prestige < 10) then
		showPrestigeButton:FireClient(plr)
	end
end)

LevelSystem.CalculateLvlThreshold = function(level)
	local threshold = 0
	local nextLevel = level + 1

	if nextLevel >= 1 and nextLevel <= 10 then
		threshold = nextLevel * 20

	elseif nextLevel >= 11 and nextLevel <= 20 then
		threshold = nextLevel * 25

	elseif nextLevel >= 21 and nextLevel <= 30 then
		threshold = nextLevel * 30

	elseif nextLevel >= 31 and nextLevel <= 40 then
		threshold = nextLevel * 35

	elseif nextLevel >= 41 and nextLevel <= 50 then
		threshold = nextLevel * 40

	elseif nextLevel >= 51 and nextLevel <= 60 then
		threshold = nextLevel * 45

	elseif nextLevel >= 61 and nextLevel <= 101 then
		threshold = nextLevel * 50
	end

	return threshold
end

local Signals     = {} do 
	for _, Signal in pairs(script.signals:GetChildren()) do
		Signals[Signal.Name] = Signal.Value
	end
end

local function FetchLvlStatsLocal(plr)
	local prestige = DS2("Prestige", plr):Get(0)
	local level = DS2("Level", plr):Get(0)
	local rank = DS2("Rank", plr):Get(0)
	local levelExp = DS2("LevelExp", plr):Get(0)
	local currentExp = DS2("CurrentExp", plr):Get(0)
	local totalExp = DS2("TotalExp", plr):Get(0)

	return {LevelExp = levelExp, CurrentExp = currentExp, TotalExp = totalExp, Level = level, Rank = rank, Prestige = prestige}
end

function LevelSystem.FetchLvlStats(plr)
	return FetchLvlStatsLocal(plr)
end

Signals.FetchLvlStats.OnServerInvoke = function(plr)
	return FetchLvlStatsLocal(plr)
end

Signals.AddExp.Event:Connect(function(plr, exp)
	local levelExp = DS2("LevelExp", plr)
	local currentExp = DS2("CurrentExp", plr)
	local totalExp = DS2("TotalExp", plr)
	currentExp:Increment(exp)
	totalExp:Increment(exp)
	levelExp:Increment(exp)
	
	--Check if plr is level 100
	LevelSystem.CheckForPrestige(plr)
	
	local canLvlUp = LevelSystem.CheckExp(plr)
	if canLvlUp then
		LevelSystem.LevelUp(plr)
	end
end)

LevelSystem.CheckExp = function(plr)
	local canLvlUp = false
	
	local level = DS2("Level", plr):Get(0)
	local levelExp = DS2("LevelExp", plr):Get(0)
	local thresholdExp = LevelSystem.CalculateLvlThreshold(level)
	if (levelExp >= thresholdExp) and (level < 100) then
		canLvlUp = true
	end
	
	return canLvlUp
end

LevelSystem.LevelUp = function(plr)
	local level = DS2("Level", plr)
	local levelExp = DS2("LevelExp", plr)
	local currentExp = DS2("CurrentExp", plr)
	local totalExp = DS2("TotalExp", plr)
	
	local thresholdExp = LevelSystem.CalculateLvlThreshold(level:Get(0))
	
	--Calculate leftover exp
	local leftoverExp = (levelExp:Get(0) - thresholdExp)
	if leftoverExp > 0 then
		levelExp:Set(leftoverExp)
	else
		levelExp:Set(0)
	end
	
	level:Increment(1)
	
	updatePlayerList:Fire()
	
	--Check if plr is level 100
	LevelSystem.CheckForPrestige(plr)
	
	--Check if they need to level up again
	local canLvlUp = LevelSystem.CheckExp(plr)
	if canLvlUp then
		LevelSystem.LevelUp(plr)
	end
end

LevelSystem.CheckForPrestige = function(plr)
	local level = DS2("Level", plr):Get(0)
	local prestige = DS2("Prestige", plr):Get(0)
	local showPrestigeButton = RS:WaitForChild("ShowPrestigeButton")
	
	if (level == 100) and (prestige < 10) then
		showPrestigeButton:FireClient(plr)
	end
end

Signals.Prestige.OnServerInvoke = function(plr)
	local prestige = DS2("Prestige", plr)
	local level = DS2("Level", plr)
	local rank = DS2("Rank", plr)
	local levelExp = DS2("LevelExp", plr)
	local currentExp = DS2("CurrentExp", plr)

	prestige:Increment(1)
	level:Set(0)
	rank:Set(0)
	levelExp:Set(0)
	currentExp:Set(0)

	return true
end

return LevelSystem
