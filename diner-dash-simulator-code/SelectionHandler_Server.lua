--// BrawlBattle
--// 12-29-22
--// Selection Handler Server
local SelectionHandler = {}

local mainMap = workspace:WaitForChild("MainMap")
local WS_tables = mainMap:WaitForChild("Tables")
local WS_trashCan = mainMap:WaitForChild("TrashCan")

local RS = game:GetService("ReplicatedStorage")
local Patience_SetPatience = RS:WaitForChild("Patience_SetPatience")

local gameEvents = RS:WaitForChild("GameEvents")
local fetchGameSettingValue = gameEvents:WaitForChild("FetchGameSettingValue")

local CustomerHandler = require(script.Parent:WaitForChild("EventHandler_Customer"))
local KitchenHandler = require(script.Parent:WaitForChild("EventHandler_Kitchen"))
local FoodHandler = require(script.Parent:WaitForChild("EventHandler_Kitchen"):WaitForChild("Kitchen_FoodHandler"))
local Selection_Operations = require(script:WaitForChild("Selection_Operations"))

local Signals   = {} do 
	for _, Signal in pairs(script.signals:GetChildren()) do
		Signals[Signal.Name] = Signal.Value
	end
end

--[[ METHODS
	CanOperate(firstSelection : object, secondSelection : object) : boolean
		-Check combinations if first can combine with second
	Deselect()
		-Make selection of firstSelection and/or secondSelection nil
		-Get rid of selectionBox for both objects
]]
local function ModifyObjectToPlrSelection(operation, plr, object)
	print('MODIFY ITEMS')
	local tempStats = plr:WaitForChild("TempStats")
	local firstSelected = tempStats:WaitForChild("FirstSelected")
	local secondSelected = tempStats:WaitForChild("SecondSelected")
	local isHoldingFood = tempStats:WaitForChild("IsHoldingFood")

	if operation == "AddToSelection" then
		if firstSelected.Value == nil then
			print('SET FIRSTSELECTED')
			firstSelected.Value = object
			RS:WaitForChild("Sound_PlayLocalSound"):FireClient(plr, "SFX", "Click")
			
			--Set custom actions depending on status of customer
			if object:FindFirstChild("IsCustomer") then
				--Take the customer order, deselect them, change status for waiting order, and return
				if CustomerHandler.FetchStatus(object) == "ReadyToOrder" then
					CustomerHandler.UpdateStatus(object, "WaitingForFood")
					CustomerHandler.UpdateBubble(object, true, "MENU_ITEM")
					CustomerHandler.ChangeBubbleColor(object, Color3.fromRGB(181, 181, 181))
					--Patience_AssistedCustomer:Fire(object)
					Patience_SetPatience:Fire(object, fetchGameSettingValue:Invoke("StartingPatience") + fetchGameSettingValue:Invoke("CookTime")) --TODO: Change this to settings amount
					-->Prepare food
					KitchenHandler.GetMenuItemAndPrepareFood(object)
					Deselect(plr)
					ToggleObjectSelectability(object, false)
					return
					
				--Make all tables selectable if first object is a customer and is at reception
				elseif CustomerHandler.FetchStatus(object) == "Reception" then
					ToggleAllSelectableTables(true)
					return
				end
				
			--Make food go on player's hand
			elseif object:FindFirstChild("IsFood") and isHoldingFood and isHoldingFood.Value == false then
				--TODO: Make the food go into the player's hand
				isHoldingFood.Value = true
				FoodHandler.PutFoodInHand(plr, object)
				--Deselect(plr)
				ToggleObjectSelectability(object, false)
				ToggleObjectSelectability(WS_trashCan, true)
				return
			end
		else
			print('SET SECONDSELECTED')
			secondSelected.Value = object
		end

	elseif operation == "RemoveAll" then
		firstSelected.Value = nil
		secondSelected.Value = nil
	end

	--Perform an operation if both work out a combination
	if firstSelected.Value ~= nil and secondSelected.Value ~= nil then
		print(firstSelected.Value)
		print(secondSelected.Value)
		PerformOperation(plr, firstSelected.Value, secondSelected.Value)
	end
end

function DeselectObjectStatsAndHideBox(object)
	print('DESELECT OBJECT STATS AND HIDE BOX')
	--Hide selection box
	--local selectionBox = object:WaitForChild("SelectionBox")
	local selectionHighlight = object:WaitForChild("SelectionHighlight")
	if selectionHighlight then
		selectionHighlight.Enabled = false
	end

	--Deselect Object Stat Values
	local clickDetector = object:WaitForChild("ClickDetector")
	local statsFolder = object:WaitForChild("Stats")
	local selected = statsFolder:WaitForChild("Selected")
	local selectable = statsFolder:WaitForChild("Selectable")

	if statsFolder and selected and selectable then
		selected.Value = false
		selectable.Value = true
	end
end

function PerformOperation(plr, firstSelected, secondSelected)
	print('PERFORM OPERATION')
	print(firstSelected)
	print(secondSelected)
	if firstSelected:FindFirstChild("IsCustomer") and secondSelected:FindFirstChild("IsTable") then
		--Do action
		print('PERFORM CUSTOMER TO TABLE')
		local tableOccupied = secondSelected:WaitForChild("Stats"):WaitForChild("Occupied")
		if tableOccupied and tableOccupied.Value == false then
			Selection_Operations.CustomerToTable(firstSelected, secondSelected)
		end
		ToggleAllSelectableTables(false)
		
		--Remove stats
		print('DESELECT FROM PERFORMPOERATION')
		Deselect(plr)
		ToggleObjectSelectability(firstSelected, false)
		ToggleObjectSelectability(secondSelected, false)
	
	--Give the food to the customer
	elseif firstSelected:FindFirstChild("IsFood") and secondSelected:FindFirstChild("IsCustomer") then
		if (FoodHandler.HasMatchingFoodOrder(plr, secondSelected)) then
			print('PERFORM FOOD TO CUSTOMER')
			Selection_Operations.FoodToCustomer(plr, firstSelected, secondSelected)
			RS:WaitForChild("Sound_PlaySound"):Fire("SFX", "FoodOnTable")
			
			local tempStats = plr:WaitForChild("TempStats")
			local isHoldingFood = tempStats:WaitForChild("IsHoldingFood")
			isHoldingFood.Value = false
		end
		
		Deselect(plr)
		ToggleObjectSelectability(firstSelected, false)
		ToggleObjectSelectability(secondSelected, false)
		
	--Throw the food at hand into the trash can
	elseif firstSelected:FindFirstChild("IsFood") and secondSelected:FindFirstChild("IsTrashCan") then
		print("PERFORM FOOD TO TRASH CAN")
		Selection_Operations.FoodToTrashCan(plr, firstSelected)
		
		local tempStats = plr:WaitForChild("TempStats")
		local isHoldingFood = tempStats:WaitForChild("IsHoldingFood")
		isHoldingFood.Value = false
		
		Deselect(plr)
		ToggleObjectSelectability(firstSelected, false)
		ToggleObjectSelectability(secondSelected, false)
		
	else
		return
	end
end

function Deselect(plr)
	print('DESELECT')
	local tempStats = plr:WaitForChild("TempStats")
	local firstSelected = tempStats:WaitForChild("FirstSelected")
	local secondSelected = tempStats:WaitForChild("SecondSelected")
	print(firstSelected.Value)
	print(secondSelected.Value)

	if firstSelected.Value ~= nil then
		DeselectObjectStatsAndHideBox(firstSelected.Value)
	end
	if secondSelected.Value ~= nil then
		DeselectObjectStatsAndHideBox(secondSelected.Value)
	end


	ModifyObjectToPlrSelection("RemoveAll", plr, nil)
end
Signals.Deselect.OnServerInvoke = function(plr)
	Deselect(plr)
end

--This is for when a customer at register is clicked and has to choose a table
function ToggleAllSelectableTables(toggle)
	for _,tabl in pairs(WS_tables:GetChildren()) do
		local tableStats = tabl:WaitForChild("Stats")
		local clickDetector = tabl:WaitForChild("ClickDetector")
		
		--if tableStats.Occupied.Value == false then
		if tableStats.Occupied.Value == false and toggle == true then
			clickDetector.MaxActivationDistance = 32
			tabl.SelectionHighlight.Enabled = true
			tableStats.Selectable.Value = true
			--tableStats.Selected.Value = false
		else
			clickDetector.MaxActivationDistance = 0
			tabl.SelectionHighlight.Enabled = false
			tableStats.Selectable.Value = false
			--tableStats.Selected.Value = true
		end
	end
end

--This is for when the player CAN or CANNOT select an object
function ToggleObjectSelectability(object, toggle)
	local statsFolder = object:WaitForChild("Stats")
	local selectableVal = statsFolder:WaitForChild("Selectable")
	local selectedVal = statsFolder:WaitForChild("Selected")
	if statsFolder and selectableVal and selectedVal then
		selectableVal.Value = toggle
		
		if toggle == true then
			selectedVal.Value = false
		end
	end
end
Signals.ToggleObjectSelectability.Event:Connect(function(object, toggle)
	ToggleObjectSelectability(object, toggle)
end)

Signals.Select.OnServerInvoke = function(plr, object)
	print('SELECT SERVER INVOKE')
	local tempStats = plr:WaitForChild("TempStats")
	local firstSelected = tempStats:WaitForChild("FirstSelected")
	local secondSelected = tempStats:WaitForChild("SecondSelected")

	local statsFolder = object:WaitForChild("Stats")
	local selected = statsFolder:WaitForChild("Selected")
	local selectable = statsFolder:WaitForChild("Selectable")
	--local selectionBox = object:WaitForChild("SelectionBox")
	local selectionHighlight = object:WaitForChild("SelectionHighlight")

	--if objectType == "Customer" then
	print('SELECTABLE OBJECT')
	if statsFolder and selected and selectable and firstSelected and secondSelected and selectionHighlight then
		print('HAS EVERYTHING')
		if (selectable.Value == true) and (selected.Value == false) then
			print('CHANGE VALUES')
			selectable.Value = false
			selected.Value = true
			selectionHighlight.Enabled = true
			ModifyObjectToPlrSelection("AddToSelection", plr, object)

		end
	end
end


return SelectionHandler
