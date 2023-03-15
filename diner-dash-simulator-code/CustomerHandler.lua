--// BrawlBattle
--// 12-25-22
--// CustomerHandler Handler
local CustomerHandler = {}

local CS = game:GetService("CollectionService")

local mainMap = workspace:WaitForChild("MainMap")
local WS_customersFolder = workspace:WaitForChild('Customers')
local registerCounter = mainMap:WaitForChild("RegisterCounter")
local startLine = registerCounter:WaitForChild("StartLine")
local registerLines = registerCounter:WaitForChild("RegisterLines"):GetChildren()

local RS = game:GetService("ReplicatedStorage")
local dataValues = RS:WaitForChild("DataValues")
local timeValue = dataValues:WaitForChild('Time')
local dayValue = dataValues:WaitForChild('Day')

local RS_ToggleObjectSelectability = RS:WaitForChild("ToggleObjectSelectability")

local RS_mainData = RS:WaitForChild("MainData")
local RS_characterData = RS_mainData:WaitForChild("Characters")
local BubbleImageData = require(RS_characterData:WaitForChild("BubbleImageData"))
local CustomerStatusData = require(RS_characterData:WaitForChild("CustomerStatusData"))
local MenuData = require(RS_mainData:WaitForChild("Menu"):WaitForChild("MenuData"))


local SS = game:GetService("ServerStorage")
local SS_modules = SS:WaitForChild("GameModules")
local GameSettings = require(SS_modules:WaitForChild("GameSettings"))
local TimerModule = require(SS_modules:WaitForChild("Timer"))

local SS_assets = SS:WaitForChild("Assets")
local characterAssets = SS_assets:WaitForChild("Characters")
local customerAssets = characterAssets:WaitForChild("Customers")

local DayCycleHandler = require(script.Parent:WaitForChild("EventHandler_DayCycle"))
local TipHandler = require(script:WaitForChild("Customer_Tip"))
local PatienceHandler = require(script:WaitForChild("Customer_Patience"))

local Signals   = {} do 
	for _, Signal in pairs(script.signals:GetChildren()) do
		Signals[Signal.Name] = Signal.Value
	end
end

--[[ METHODS
	PlaceCustomerInLine(customer : Model)
	CreateCustomerFolder() : Folder
]]
--Sorts the registered lines by sequential numbers
table.sort(registerLines, function(a,b)
	return (tonumber(a.Name) < tonumber(b.Name))
end)

CustomerHandler.GetStatValueInStatsFolder = function(customer, statName)
	local fetchedVal = nil
	
	local statsFolder = customer:WaitForChild("Stats")
	local statVal = statsFolder:FindFirstChild(statName)
	if statsFolder and statVal then
		fetchedVal = statVal.Value
	end
	
	return fetchedVal
end
CustomerHandler.SetStatInStatsFolder = function(customer, statName, value)
	local statsFolder = customer:WaitForChild("Stats")
	local statVal = statsFolder:FindFirstChild(statName)
	if statsFolder and statVal then
		statVal.Value = value
	end
end

CustomerHandler.UpdateBubble = function(customer, toggle, action)
	local head = customer:FindFirstChild("Head")
	local chatBubble = head:FindFirstChild("ChatBubble")
	
	if head and chatBubble then
		chatBubble.Enabled = toggle
		--PatienceHandler.ResetPatience(customer)
		
		if action ~= nil then
			--If it is a generic action
			if type(action) == "string" then
				--Change the bubble to whatever menu item the customer has ELSE its an action from the moduleScript
				if action == "MENU_ITEM" then
					local itemImage = chatBubble:WaitForChild("Bubble"):WaitForChild("ItemImage")
					local statsFolder = customer:WaitForChild("Stats")
					local menuItem = statsFolder:WaitForChild("MenuItem")
					
					if itemImage and statsFolder and menuItem and menuItem.Value ~= nil then
						
						local bubbleImageId = MenuData.FetchImageIdByName(GameSettings.CurrentSchedule, menuItem.Value)
						--print("BUBBLE IMAGE ID: "..bubbleImageId)
						if bubbleImageId then
							itemImage.Image = "rbxassetid://"..bubbleImageId
						end
					end
				else
					local itemImage = chatBubble:WaitForChild("Bubble"):WaitForChild("ItemImage")
					local bubbleImageId = BubbleImageData[action]
					if bubbleImageId and itemImage then
						itemImage.Image = "rbxassetid://"..bubbleImageId
					end
				end
			
			--If is a menu item
			elseif type(action) == "number" then
				local itemImage = chatBubble:WaitForChild("Bubble"):WaitForChild("ItemImage")
				if itemImage then
					itemImage.Image = "rbxassetid://"..action
				end
			end
			
		end
	end
end
CustomerHandler.ChangeBubbleColor = function(customer, color3)
	--GRAY: 181, 181, 181
	local head = customer:FindFirstChild("Head")
	local chatBubble = head:FindFirstChild("ChatBubble")
	local bubbleFrame = chatBubble:WaitForChild("Bubble")

	if head and chatBubble and bubbleFrame then
		bubbleFrame.ImageColor3 = color3
	end
end

CustomerHandler.UpdateStatus = function(customer, status)
	CustomerHandler.SetStatInStatsFolder(customer, "Status", status)
end
CustomerHandler.FetchStatus = function(customer) --Returns String
	return CustomerHandler.GetStatValueInStatsFolder(customer, "Status")
end

CustomerHandler.VacateRegisterLineFromCustomer = function(customer)
	print('VACATE CUSTOMER')
	local customerRegisterLine = CustomerHandler.GetStatValueInStatsFolder(customer, "RegisterLine")
	print(customerRegisterLine)
	if customerRegisterLine ~= nil and customerRegisterLine:GetAttribute("Occupied") then
		print('UNDO THE OCCUPIED')
		customerRegisterLine:SetAttribute("Occupied", false)
	end
end

CustomerHandler.AdjustRegisterLines = function()
	--Move all customers by 1 spot under
	for _,customerFolder in pairs(WS_customersFolder:GetChildren()) do
		local customer = customerFolder:FindFirstChildOfClass("Model") --TODO: CHANGE THIS LATER FOR WHEN YOU GET MULTIPLE CUSTOMERS PER BATCH
		local customerRegisterLine = CustomerHandler.GetStatValueInStatsFolder(customer, "RegisterLine")
		if customerRegisterLine ~= nil then
			local newCustRegisterLineNum = tonumber(customerRegisterLine.Name) - 1
			local newCustRegisterLine = registerLines[newCustRegisterLineNum]
			
			if newCustRegisterLineNum >= 1 and newCustRegisterLine then
				customerRegisterLine:SetAttribute("Occupied", false)
				spawn(function()
					CustomerHandler.PlaceCustomerInLine(customer, newCustRegisterLineNum)
				end)
				
			end
		end
	end
end

CustomerHandler.PlaceCustomerInLine = function(customer, specificSpotNum)
	--TODO: Make this for multiple customers instead of one
	
	--Move customer to start line area
	print('MOVETO CUSTOMER')
	
	local availableSpot = nil
	if specificSpotNum ~= nil then
		--Set the customer to go the specified line spot
		local registerLine = registerLines[specificSpotNum]
		local occupied = registerLine:GetAttribute("Occupied")
		if registerLine and occupied == false then
			availableSpot = registerLine
			print(availableSpot.Name)
			availableSpot:SetAttribute("Occupied", true)
			print('SET CUSTOMER REGISTER LINE STAT 1')
			CustomerHandler.SetStatInStatsFolder(customer, "RegisterLine", availableSpot)
		end
		
	else --Find the next closest spot
		customer:MoveTo(startLine.CFrame * Vector3.new(0,5,0))
		for i = 1,#registerLines do
			local occupied = registerLines[i]:GetAttribute("Occupied")
			if occupied == false then
				availableSpot = registerLines[i]
				print(availableSpot.Name)
				availableSpot:SetAttribute("Occupied", true)
				print('SET CUSTOMER REGISTER LINE STAT 2')
				CustomerHandler.SetStatInStatsFolder(customer, "RegisterLine", availableSpot)
				break
			end
		end
	end
	
	
	local hum = customer:FindFirstChild("Humanoid")
	if hum and availableSpot then
		print('MOVE CUST HUM')
		hum:MoveTo(availableSpot.Position)
		hum.MoveToFinished:Wait()
		
		--Only the first person in line gets to be selected
		print(CustomerHandler.GetStatValueInStatsFolder(customer, "RegisterLine").Name)
		if CustomerHandler.GetStatValueInStatsFolder(customer, "RegisterLine").Name == "1" then
			CustomerHandler.SetStatInStatsFolder(customer, "Selectable", true)
		end
		
		CustomerHandler.UpdateBubble(customer, true, "Reception")
		CustomerHandler.UpdateStatus(customer, "Reception")
		
		local registerLineVal = customer:WaitForChild("Stats"):WaitForChild("RegisterLine")
		if registerLineVal and registerLineVal:GetAttribute("StartedGettingInLine") == false then
			registerLineVal:SetAttribute("StartedGettingInLine", true)
			Signals.Patience_StartPatienceCountdown:Fire(customer)
		end
		
	end
end

CustomerHandler.ChoosingOrder = function(customer)
	Signals.Patience_SetPatience:Fire(customer, GameSettings.StartingPatience + GameSettings.ChoosingOrderSpeed)
	wait(GameSettings.ChoosingOrderSpeed)
	
	--Choose a random order
	local currentScheduleMenu = MenuData[GameSettings.CurrentSchedule]
	local randomNum = math.random(1, #currentScheduleMenu)
	local menuItemData = currentScheduleMenu[randomNum]
	
	CustomerHandler.SetStatInStatsFolder(customer, "MenuItem", menuItemData.Name)

	CustomerHandler.UpdateBubble(customer, true, "ReadyToOrder")
	CustomerHandler.UpdateStatus(customer, "ReadyToOrder")
	RS_ToggleObjectSelectability:Fire(customer, true)
end

CustomerHandler.StartEating = function(customer, food)
	CustomerHandler.UpdateBubble(customer, false, nil)
	CustomerHandler.UpdateStatus(customer, "CurrentlyEating")
	Signals.Patience_SetPatience:Fire(customer, 999999)
	
	wait(GameSettings.EatingTime)
	
	RS:WaitForChild("SpawnTip"):Fire(customer)
	
	
	CustomerHandler.RemoveCustomerAndFolder(customer)
	food:Destroy()
end



CustomerHandler.CreateNewCustomerFolder = function()
	--Update current customers
	GameSettings.TotalCustomersForToday += 1
	GameSettings.CurrentCustomerCount += 1
	
	--Pick a random number of 1 to 4 characters in the same folder
	
	local newCustomerFolder = Instance.new("Folder", WS_customersFolder)
	newCustomerFolder.Name = GameSettings.TotalCustomersForToday
	
	local randomNum = math.random(1, #customerAssets:GetChildren())
	local randomChar = customerAssets:GetChildren()[randomNum]:Clone()
	
	CS:AddTag(randomChar, "Selectable")
	randomChar.Parent = newCustomerFolder
	
	--Place the customer in the line
	spawn(function()
		CustomerHandler.PlaceCustomerInLine(randomChar, nil)
	end)
end

CustomerHandler.RemoveCustomerAndFolder = function(customer)
	local customerFolder = customer.Parent
	if customerFolder:IsA("Folder") then
		customerFolder:Destroy()
	end
end

CustomerHandler.RefreshCustomersFolder = function()
	for _,folder in pairs(WS_customersFolder:GetChildren()) do
		folder:Destroy()
	end
	GameSettings.CurrentCustomerCount = 0
	GameSettings.TotalCustomersForToday = 0
end

CustomerHandler.StartCustomerCycle = function()
	local timer = DayCycleHandler.FetchTimer()
	
	spawn(function()
		while timer:isRunning() do
			CustomerHandler.CreateNewCustomerFolder()
			wait(GameSettings.NewCustomerSpeed)
		end
	end)
end


return CustomerHandler
