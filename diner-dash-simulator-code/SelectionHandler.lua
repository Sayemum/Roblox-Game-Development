--// BrawlBattle
--// 12-28-22
--// Selection Handler
local UIS = game:GetService("UserInputService")
local CS = game:GetService("CollectionService")

local RS = game:GetService("ReplicatedStorage")
local RS_select = RS:WaitForChild("Select")
local RS_deselect = RS:WaitForChild("Deselect")
local RS_tipClicked = RS:WaitForChild("TipClicked")

local gameEvents = RS:WaitForChild("GameEvents")
local fetchDayInProgress = gameEvents:WaitForChild("FetchDayInProgress")

local plr = game.Players.LocalPlayer
local tempStats = plr:WaitForChild("TempStats")
local firstSelected = tempStats:WaitForChild("FirstSelected")
local secondSelected = tempStats:WaitForChild("SecondSelected")
local isHoldingFood = tempStats:WaitForChild("IsHoldingFood")

local mouse = plr:GetMouse()

local function CS_SelectableTag(object)
	local statsFolder = object:WaitForChild("Stats")
	local selected = statsFolder:WaitForChild("Selected")
	local selectable = statsFolder:WaitForChild("Selectable")
	
	local clickDetector = object:WaitForChild("ClickDetector")
	--local selectionBox = object:WaitForChild("SelectionBox")
	local selectionHighlight = object:WaitForChild("SelectionHighlight")
	if clickDetector and selectionHighlight then
		print('CLICK AND SELECTION')
		clickDetector.MouseHoverEnter:Connect(function()
			if selectable.Value == true and selected.Value == false then
				print('ENTER')
				selectionHighlight.Enabled = true
			end
		end)
		clickDetector.MouseHoverLeave:Connect(function()
			if selectable.Value == true and selected.Value == false then
				--print('LEAVE')
				selectionHighlight.Enabled = false
			end
		end)
		--Hide/Show click detector when it is selectable
		selectable.Changed:Connect(function()
			if selectable.Value == true then
				clickDetector.MaxActivationDistance = 32
			else
				clickDetector.MaxActivationDistance = 0
			end
		end)

		--Change how the selectable is clicked depending on what it is
		if statsFolder and selected and selectable then
			clickDetector.MouseClick:Connect(function()
				RS_select:InvokeServer(object)
			end)
		end
    
	end
end

local selectables = CS:GetTagged("Selectable")
for _,selectable in pairs(selectables) do
	CS_SelectableTag(selectable)
end
CS:GetInstanceAddedSignal("Selectable"):Connect(function(object)
	CS_SelectableTag(object)
end)

--Deselect
UIS.InputBegan:Connect(function(input, uiProcessed)
	if not fetchDayInProgress:InvokeServer() then return end
	if isHoldingFood.Value == true then return end
	
	if uiProcessed == false then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if mouse.Target then
				if not mouse.Target.Parent:FindFirstChild("ClickDetector") then
					--print('NOT CLICK DETECTOR')
					RS_deselect:InvokeServer()
				end
			end
		end
	end
end)


--//Handle the Tips left on each table
CS:GetInstanceAddedSignal("TableTip"):Connect(function(tipModel)
	print('TABLETIP ADDED')
	local statsFolder = tipModel:WaitForChild("Stats")
	local tipAmount = statsFolder:WaitForChild("TipAmount")
	local selected = statsFolder:WaitForChild("Selected")
	
	local clickDetector = tipModel:WaitForChild("ClickDetector")
	local selectionHighlight = tipModel:WaitForChild("SelectionHighlight")
	
	if clickDetector and selectionHighlight then
		print('CLICK AND SELECTION')
		clickDetector.MouseHoverEnter:Connect(function()
			selectionHighlight.Enabled = true
		end)
		clickDetector.MouseHoverLeave:Connect(function()
			selectionHighlight.Enabled = false
		end)
		
		if statsFolder and tipAmount and selected then
			clickDetector.MouseClick:Connect(function()
				if selected.Value == false then
					selected.Value = true
					RS_tipClicked:FireServer(tipModel, tipAmount.Value)
				end
			end)
		end
	end
end)
