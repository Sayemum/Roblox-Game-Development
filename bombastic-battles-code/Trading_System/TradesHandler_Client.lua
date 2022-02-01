--// TradesHandler_Client
--// Scripted by: BrawlBattle
--// Desc: Handles the player trades menu on the client side + trade window when the player trades with another player.

--Services--
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local localPlr = Players.LocalPlayer

--Local Variables--
local mainFrame = script.Parent
local tradeButton = mainFrame.Parent.TradesButton
local isOpen = mainFrame.Parent.IsOpen

local items = mainFrame.Items
local templates = mainFrame.Templates
local tradeItem = templates.TradeItem

local sendTradeRequest = RS:WaitForChild("SendTradeRequest")
local fetchTradePerms = RS:WaitForChild("FetchTradePerms")

--Create an entry of the player in the trades menu so that other players can trade you
local function createList()
	for _,plr in pairs(Players:GetPlayers()) do
		
		if plr ~= localPlr then
			local newPlrTrade = tradeItem:Clone()
			newPlrTrade.Parent = items
			newPlrTrade.Visible = true
			newPlrTrade.PlayerText.Text = plr.Name

			local plrImage = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			newPlrTrade.PlayerIcon.Image = plrImage

			newPlrTrade.TradeButton.MouseButton1Click:Connect(function()
				sendTradeRequest:InvokeServer(plr)
				
			end)
		end
		
	end
end

--Removes all players from trades menu if it needs to be updated
local function removeAllFromList()
	for _,v in pairs(items:GetChildren()) do
		if not v:IsA("UIListLayout") then
			v:Destroy()
		end
	end
end


--Local Functions--
local function tradeButtonClicked()
	if isOpen.Value == false then
		isOpen.Value = true
		mainFrame.Visible = true
		createList()
		
	elseif isOpen.Value == true then
		isOpen.Value = false
		mainFrame.Visible = false
		removeAllFromList()
	end
end


--Events Initialized--
tradeButton.MouseButton1Click:Connect(tradeButtonClicked)
