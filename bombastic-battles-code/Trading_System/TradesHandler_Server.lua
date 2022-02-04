--// TradesHandler_Server
--// Scripted by: BrawlBattle
--// Desc: Handles the trading system on the server side. Mainly handles the trading interaction between both players during a trade.

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local DS2 = require(SS:WaitForChild("DataStore2"))

local resetInventory = RS:WaitForChild("ResetInventory")
local loadInventory = RS:WaitForChild("LoadInventory")

local tradeUi = SS:WaitForChild("Interfaces"):WaitForChild("Trades")
local tradeInbound = tradeUi:WaitForChild("TradeInbound")
local tradeOutbound = tradeUi:WaitForChild("TradeOutbound")
local tradePanel = tradeUi:WaitForChild("TradePanel")
local tradeCompleted = tradeUi:WaitForChild("TradeCompleted")

--Table of Booleans to determine which players can trade
local TradePerms = {}
local CanAcceptTrade = {}
local CurrentOffer = {}

local Signals = {} do 
	for _, Signal in pairs(script.signals:GetChildren()) do
		Signals[Signal.Name] = Signal.Value
	end
end

--Add player to tables upon joining the game
Players.PlayerAdded:Connect(function(plr)
	if not TradePerms[plr] then
		TradePerms[plr] = true
	end
	if not CanAcceptTrade[plr] then
		CanAcceptTrade[plr] = true
	end
	if not CurrentOffer[plr] then
		CurrentOffer[plr] = {}
	end
end)

--Remove player to tables upon joining the game
Players.PlayerRemoving:Connect(function(plr)
	if TradePerms[plr] then
		TradePerms[plr] = nil
	end
	if CanAcceptTrade[plr] then
		CanAcceptTrade[plr] = nil
	end
	if CurrentOffer[plr] then
		CurrentOffer[plr] = nil
	end
end)


--Fetch trading permissions from the server to the client
Signals.FetchTradePerms.OnServerInvoke = function(plr)
	return TradePerms
end

--Sending Trade Request has been made from the client (plr has requested to trade with plr2)
Signals.SendTradeRequest.OnServerInvoke = function(plr, plr2)
	if TradePerms[plr] == true and TradePerms[plr2] == true then
		local plrGui1 = plr:WaitForChild("PlayerGui"):WaitForChild("TemporaryGui")
		local plrGui2 = plr2:WaitForChild("PlayerGui"):WaitForChild("TemporaryGui")

		if plrGui1 and plrGui2 then
			local newOutbound = tradeOutbound:Clone()
			newOutbound.Player.Text = plr2.Name
			newOutbound.Parent = plrGui1
			newOutbound.Visible = true

			local newInbound = tradeInbound:Clone()
			newInbound.Player.Text = plr.Name
			newInbound.Parent = plrGui2
			newInbound.Visible = true
		end
		
		TradePerms[plr] = false
		TradePerms[plr2] = false
	end
	
end

--Trade request has been accepted and both players will now start the trading process
Signals.AcceptTradeRequest.OnServerEvent:Connect(function(plr2, plr)
	
	if TradePerms[plr] == false and TradePerms[plr2] == false then
		local plrGui1 = plr:WaitForChild("PlayerGui"):WaitForChild("TemporaryGui")
		local plrGui2 = plr2:WaitForChild("PlayerGui"):WaitForChild("TemporaryGui")

		if plrGui1 and plrGui2 then
			local outboundGui = plrGui1:FindFirstChild("TradeOutbound")
			local inboundGui = plrGui2:FindFirstChild("TradeInbound")
			
			if outboundGui and inboundGui then --Delete Inbound/Outbound Gui
				outboundGui:Destroy()
				inboundGui:Destroy()
			end
			
			--Give trade panels to both players
			local newPanel = tradePanel:Clone()
			newPanel.Title.Text = "Trading with "..plr2.Name
			newPanel.Trader.Value = plr2.Name
			newPanel.TradesLocalHandler.Disabled = false
			newPanel.Parent = plrGui1
			newPanel.Visible = true
			
			local newPanel2 = tradePanel:Clone()
			newPanel2.Title.Text = "Trading with "..plr.Name
			newPanel2.Trader.Value = plr.Name
			newPanel2.TradesLocalHandler.Disabled = false
			newPanel2.Parent = plrGui2
			newPanel2.Visible = true
			
		end
	end
	
end)

--Trade request has been rejected and the trading process has ended
Signals.RejectTradeRequest.OnServerEvent:Connect(function(plr2, plr)
	if TradePerms[plr] == false and TradePerms[plr2] == false then
		local plrGui1 = plr:WaitForChild("PlayerGui"):WaitForChild("TemporaryGui")
		local plrGui2 = plr2:WaitForChild("PlayerGui"):WaitForChild("TemporaryGui")
		
		if plrGui1 and plrGui2 then
			local outboundGui = plrGui1:FindFirstChild("TradeOutbound") or plrGui1:FindFirstChild("TradeInbound")
			local inboundGui = plrGui2:FindFirstChild("TradeInbound") or plrGui2:FindFirstChild("TradeOutbound")
			
			if outboundGui and inboundGui then --Delete Inbound/Outbound Gui
				outboundGui:Destroy()
				inboundGui:Destroy()
			end
		end
		
		TradePerms[plr] = true
		TradePerms[plr2] = true
	end
end)


-->>Trade Action Event<<--
--Adds item the requester wants to trade, update both screens
local function addItem(requester, otherPlr, itemDesc)
	
	--Check if plr owns this item
	local inventory = DS2("Inventory", requester):Get({0,1,2,3})
	print("fire clients")
	
	--Adds item to offer table
	table.insert(CurrentOffer[requester], itemDesc.ItemId)
	
	Signals.TradeAction:FireClient(requester, "Requester", "AddItem", itemDesc)
	Signals.TradeAction:FireClient(otherPlr, "OtherPlr", "AddItem", itemDesc)
end

--Removes item the requester wants to not trade, update both screens
local function removeItem(requester, otherPlr, itemDesc)
	
	--Remove item from offer table
	for i,id in pairs(CurrentOffer[requester]) do
		if id == itemDesc.ItemId then
			CurrentOffer[requester][i] = nil
		end
	end
	
	Signals.TradeAction:FireClient(requester, nil, "RemoveItem", itemDesc)
	Signals.TradeAction:FireClient(otherPlr, nil, "RemoveItem", itemDesc)
end

Signals.TradeAction.OnServerEvent:Connect(function(requester, otherPlr, action, itemDesc)
	if action == "AddItem" then
		print("added")
		addItem(requester, otherPlr, itemDesc)
		
	elseif action == "RemoveItem" then
		print("removed")
		removeItem(requester, otherPlr, itemDesc)
	end
end)



--Show that the trade has been successful
local function showCompletedTrade(plr, trader)
	local clonedCompletedGui = tradeCompleted:Clone()
	clonedCompletedGui.Player.Text = trader.Name
	clonedCompletedGui.Parent = plr:WaitForChild("PlayerGui"):WaitForChild("TemporaryGui")
	clonedCompletedGui.Visible = true
end

--Close the trades and update both screens
local function closeTrades(plr, plr2)
	local plrGui1 = plr:WaitForChild("PlayerGui"):WaitForChild("TemporaryGui")
	local plrGui2 = plr2:WaitForChild("PlayerGui"):WaitForChild("TemporaryGui")

	if plrGui1 and plrGui2 then
		local tradePanel1 = plrGui1:FindFirstChild("TradePanel")
		local tradePanel2 = plrGui2:FindFirstChild("TradePanel")

		if tradePanel1 and tradePanel2 then --Delete Trade Panel Gui
			tradePanel1:Destroy()
			tradePanel2:Destroy()
		end
		
		showCompletedTrade(plr, plr2)
		showCompletedTrade(plr2, plr)
	end
	
	--Removes all items from player offer
	CurrentOffer[plr] = {}
	CurrentOffer[plr2] = {}

	TradePerms[plr] = true
	TradePerms[plr2] = true
end

--Update both players inventory after trade has been successful
local function addItemsToInventory(plr, plr2)
	local inventory = DS2("Inventory", plr):Get({0,1,2,3})
	
	for i,id in pairs(CurrentOffer[plr2]) do
		table.insert(inventory, id)
	end
	
	DS2("Inventory", plr):Set(inventory)
end

local function removeItemsFromInventory(plr)
	local inventory = DS2("Inventory", plr):Get({0,1,2,3})
	
	--Remove items from offer table
	for i,id in pairs(CurrentOffer[plr]) do
		print(inventory[id])
		inventory[id] = nil
	end
	
	resetInventory:FireClient(plr)
	loadInventory:FireClient(plr, inventory)
	DS2("Inventory", plr):Set(inventory)
end

--Trade for both players have been accepted
Signals.AcceptTrade.OnServerInvoke = function(plr, plr2)
	print("accept")
	CanAcceptTrade[plr] = false
	
	--Let plr2 see that plr1 pressed accept
	if CanAcceptTrade[plr] == false and CanAcceptTrade[plr2] == true then
		Signals.PlayerAccepted:FireClient(plr2)
	end
	
	--Process the Trade Transaction
	if CanAcceptTrade[plr] == false and CanAcceptTrade[plr2] == false then
		
		addItemsToInventory(plr, plr2)
		addItemsToInventory(plr2, plr)
		removeItemsFromInventory(plr)
		removeItemsFromInventory(plr2)
		
		closeTrades(plr, plr2)
		print("TRADES ACCEPTED")
		
		CanAcceptTrade[plr] = true
		CanAcceptTrade[plr2] = true
	end
	
	
	return CanAcceptTrade[plr]
end

--One player has rejected the trade, trade ends.
Signals.RejectTrade.OnServerInvoke = function(plr, plr2)
	if TradePerms[plr] == false and TradePerms[plr2] == false then
		closeTrades(plr, plr2)
	end
end

return nil
