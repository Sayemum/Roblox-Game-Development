--// BrawlBattle
--// 12-24-22
--// Day Cycle Handler
local DayCycle = {}

local RS = game:GetService("ReplicatedStorage")
local dataValues = RS:WaitForChild("DataValues")
local timeValue = dataValues:WaitForChild('Time')
local dayValue = dataValues:WaitForChild('Day')
local scheduleValue = dataValues:WaitForChild('Schedule')

local SS = game:GetService("ServerStorage")
local SS_events = SS:WaitForChild("Events")
local SS_closeShop = SS_events:WaitForChild("CloseShop")

local SS_modules = SS:WaitForChild("GameModules")
local GameSettings = require(SS_modules:WaitForChild("GameSettings"))

local TimerModule = require(SS_modules:WaitForChild("Timer"))
local timer = TimerModule.new()

local Signals   = {} do 
	for _, Signal in pairs(script.signals:GetChildren()) do
		Signals[Signal.Name] = Signal.Value
	end
end

DayCycle.FetchTimer = function()
	return timer
end

local function TimeUpForClose()
	timer:stop()
	GameSettings.ShopClosed = true
	SS_closeShop:Fire()
end

--Start the timer so the time goes from 12PM to 9PM
local function StartTimerTillClose()
	
	--Total Time = The total time when including 100s instead of 60s SUBTRACTED by How many total hours multiplied by 60
	--(2100-1200) - ((900/100)*60)
	--DayCycle.UpdateTime(GameSettings.StartDayTime)
	local totalTimeIncl100 = GameSettings.CloseShopTime - GameSettings.StartDayTime
	--local totalTime = totalTimeIncl100 - ((totalTimeIncl100 / 100) * 60)
	local totalTime = (totalTimeIncl100 / 100) * 60
	
	timer:start(totalTime)
	timer.finished:Connect(TimeUpForClose)

	local thread = coroutine.create(function()
		while timer:isRunning() do
			-- Adding +1 makes sure the timer display ends at 1 instead of 0.
			
			-- By not setting the time for wait, it offers more accurate looping
			wait(1)
			DayCycle.UpdateTime(timeValue.Value + 1)
		end
	end)
	coroutine.resume(thread)
end

--Resets the lighting to start at 12PM and adds 1 day
DayCycle.ResetDayCycle = function()
	--Play little animation from sunset to sunrise
	for i = timeValue.Value, GameSettings.StartDayTime do
		wait(0.01)
		DayCycle.UpdateTime(timeValue.Value + 1)
	end
	
	--timeValue.Value = 1200
	dayValue.Value += 1
	GameSettings.ShopClosed = false
	--GameSettings.DayEnded = false
	GameSettings.DayInProgress = true
	StartTimerTillClose()
end

--Update Value Functions
DayCycle.UpdateTime = function(newTime)
	timeValue.Value = newTime
	
	--Once the minutes reach 60, add another 40 to balance the time with the standard 60min/1hr
	if string.sub(tostring(timeValue.Value),3,4) == "60" then
		timeValue.Value += 40
	end
	
	--Check if the time has reached Lunch or Dinner time to change schedule
	if timeValue.Value == GameSettings.LunchTime then
		DayCycle.UpdateSchedule("Lunch")
	elseif timeValue.Value == GameSettings.DinnerTime then
		DayCycle.UpdateSchedule("Dinner")
	end
end
DayCycle.UpdateDay = function(newDay)
	dayValue.Value = newDay
end
DayCycle.UpdateSchedule = function(newSchedule)
	scheduleValue.Value = newSchedule
end


return DayCycle
