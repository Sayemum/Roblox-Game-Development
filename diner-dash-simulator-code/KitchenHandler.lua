--// BrawlBattle
--// 12-24-22
--// Kitchen Handler
local KitchenHandler = {}

local CS = game:GetService("CollectionService")

local mainMap = workspace:WaitForChild("MainMap")
local kitchenCounter = mainMap:WaitForChild("KitchenCounter")
local counterSpots = kitchenCounter:WaitForChild("CounterSpots"):GetChildren()

local RS = game:GetService("ReplicatedStorage")
local RS_ToggleObjectSelectability = RS:WaitForChild("ToggleObjectSelectability")

local SS = game:GetService("ServerStorage")
local SS_modules = SS:WaitForChild("GameModules")
local GameSettings = require(SS_modules:WaitForChild("GameSettings"))
local TimerModule = require(SS_modules:WaitForChild("Timer"))

local SS_assets = SS:WaitForChild("Assets")
local menuAssets = SS_assets:WaitForChild("Menu")

local FoodHandler = require(script:WaitForChild("Kitchen_FoodHandler"))

local Signals   = {} do 
	for _, Signal in pairs(script.signals:GetChildren()) do
		Signals[Signal.Name] = Signal.Value
	end
end

--[[ METHODS
	PrepareFood(menuItemName : String)
	GetMenuItemAndPrepareFood(customer : Model)
	PutFoodOnCounter(food : Model)
]]

--Sorts the kitchen counter spots by sequential numbers
table.sort(counterSpots, function(a,b)
	return (tonumber(a.Name) < tonumber(b.Name))
end)
--KitchenHandler.VacateKitchenCounterSpotFromFood = function(food)
Signals.Kitchen_VacateCounterSpot.Event:Connect(function(food)
	print('VACATE KITCHEN SPOT')
	local foodKitchenSpot = FoodHandler.GetStatValueInStatsFolder(food, "CounterSpot")
	print(foodKitchenSpot)
	if foodKitchenSpot ~= nil and foodKitchenSpot:GetAttribute("Occupied") then
		print('UNDO THE OCCUPIED')
		foodKitchenSpot:SetAttribute("Occupied", false)
	end
end)

local function PrepareFood(customer, menuItemName)
	wait(GameSettings.CookTime)
	
	local menuFolder = menuAssets:FindFirstChild(GameSettings.CurrentSchedule)
	local foodModel = menuFolder:FindFirstChild(menuItemName)
	if menuFolder and foodModel then
		local clonedFood = foodModel:Clone()
		CS:AddTag(clonedFood, "Selectable")
		
		--Set the customer who ordered the food into the food customer value
		local foodStats = clonedFood:WaitForChild("Stats")
		local customerVal = foodStats:WaitForChild("Customer")
		if customerVal then
			customerVal.Value = customer
			RS_ToggleObjectSelectability:Fire(customer, true)
		end
		
		local availableSpot = nil
		for i = 1,#counterSpots do
			local occupied = counterSpots[i]:GetAttribute("Occupied")
			if occupied == false then
				availableSpot = counterSpots[i]
				print(availableSpot.Name)
				counterSpots[i]:SetAttribute("Occupied", true)
				break
			end
		end
		
		--TODO: If there is no available spot, place the prepared food in a waitlist
		
		local counterSpotVal = foodStats:WaitForChild("CounterSpot")
		if clonedFood and availableSpot and counterSpotVal then
			--Move the food position to the next available spot and change the counterspot value
			counterSpotVal.Value = availableSpot
			clonedFood.Parent = workspace:WaitForChild("Food")
			clonedFood:SetPrimaryPartCFrame(availableSpot.CFrame)
		end
	end
end

KitchenHandler.GetMenuItemAndPrepareFood = function(customer)
	local statsFolder = customer:WaitForChild("Stats")
	local menuItem = statsFolder:WaitForChild("MenuItem")
	
	if statsFolder and menuItem and menuItem.Value ~= nil then
		spawn(function()
			PrepareFood(customer, menuItem.Value)
		end)
	end
end


return KitchenHandler
