--// InventoryHandler_Client
--// Scripted by: BrawlBattle
--// Desc: Handles the player inventory on the client side (deals with loading data on the client, displaying UI, etc.)

local RS = game:GetService("ReplicatedStorage")

local loadInventory = RS:WaitForChild("LoadInventory")
local resetInventory = RS:WaitForChild("ResetInventory")
local loadEquipped = RS:WaitForChild("LoadEquipped")
local addCellEvent = RS:WaitForChild("AddCell")
local equipItemEvent = RS:WaitForChild("EquipItem")

local plr = game.Players.LocalPlayer
local equippedStats = plr:WaitForChild("EquippedStats")
local plrGui = plr:WaitForChild("PlayerGui")

local shopData = RS:WaitForChild("DataModules"):WaitForChild("ShopData")
local contentsModule = shopData:WaitForChild("SpinnerContents")
local contents = require(contentsModule)
local itemTypes = contents:GetItemTypes()
local cratesData = contents:GetCratesData()

local skinsDictionary = require(shopData:WaitForChild("SkinsDictionary"))

local inventoryGui = plrGui:WaitForChild("GameHUD"):WaitForChild("Inventory")
local mainFrame = inventoryGui:WaitForChild("MainFrame")
local templates = mainFrame:WaitForChild("Templates")
local item = templates:WaitForChild("Item")

local equippedItems = mainFrame:WaitForChild("EquippedItems")

local sortOrder = {
	["Sacred"] = 1;
	["Legendary"] = 2;
	["Rare"] = 3;
	["Uncommon"] = 4;
	["Common"] = 5;
	["Default"] = 6
}

--Finds what type of frame associates with the crate type (Weapons, Pets, Effects, Perks)
local function findCorrectFrame(crateType)
	local frame

	if crateType == "Weapon" then
		frame = "WeaponsFrame"
	elseif crateType == "Pet" then
		frame = "PetsFrame"
	elseif crateType == "Effect" then
		frame = "EffectsFrame"
	elseif crateType == "Perk" then
		frame = "PerksFrame"
	end

	return frame
end

--Finds what type of equip frame associates with the item type (Weapons, Pets, Effects, Perks)
local function findCorrectEquipFrame(itemType)
	local equipFrame
	
	if itemType == "Weapon" then
		equipFrame = equippedItems.WeaponsFrame
	elseif itemType == "Pet" then
		equipFrame = equippedItems.PetsFrame
	elseif itemType == "Effect" then
		equipFrame = equippedItems.EffectsFrame
	elseif itemType == "Perk" then
		equipFrame = equippedItems.PerksFrame
	end
	
	return equipFrame
end

--Fetch rarity color of the id of the item
local function getRarityColor(itemId)
	local itemInfo = skinsDictionary[itemId]
	local itemRarity = itemInfo.Rarity
	local color
	
	if itemRarity == "Common" or itemRarity == "Default" then
		color = Color3.fromRGB(132, 132, 132)
	elseif itemRarity == "Uncommon" then
		color = Color3.fromRGB(43, 125, 43)
	elseif itemRarity == "Rare" then
		color = Color3.fromRGB(85, 0, 127)
	elseif itemRarity == "Legendary" then
		color = Color3.fromRGB(170, 0, 0)
	elseif itemRarity == "Sacred" then
		color = Color3.fromRGB(255, 255, 0)
	end
	
	return color
end


--Add each item the player owns as an entry into the inventory
local function addCell(itemId, duplicate, count)
	local itemInfo = skinsDictionary[itemId]
	local correctFrameName = findCorrectFrame(itemInfo.Type)
	local sectionFrame = mainFrame:FindFirstChild(correctFrameName)
	local gridLayout = sectionFrame:FindFirstChild("UIGridLayout")
	
	local rarityColor = getRarityColor(itemId)
	
	if duplicate == true and sectionFrame then --If Duplicate in inventory found
		local existingItem = sectionFrame:FindFirstChild(itemInfo.Name)
		if existingItem then --If existing after a spin crate
			local duplicateText = existingItem.Duplicate
			duplicateText.Text = "x"..count
			
		else --If player just joined the game
			gridLayout.SortOrder = Enum.SortOrder.Name
			gridLayout:ApplyLayout()
			
			local newItem = item:Clone()
			newItem.Type.Value = itemInfo.Type
			newItem.Name = itemInfo.Name
			newItem:FindFirstChild("Name").Text = itemInfo.Name
			newItem:FindFirstChild("Name").BackgroundColor3 = rarityColor
			newItem.Rarity.Value = itemInfo.Rarity
			newItem.LayoutOrder = sortOrder[newItem.Rarity.Value]
			newItem:FindFirstChild("Image").Image = "rbxassetid://"..itemInfo.ImageId
			newItem.Duplicate.Text = "x"..count
			
			--Equip Function
			newItem.MouseButton1Click:Connect(function()
				local itemType = newItem.Type
				local correctEquipFrame = findCorrectEquipFrame(itemType.Value)
				local nameColor = getRarityColor(itemId)
				
				if correctEquipFrame then
					local name = correctEquipFrame:FindFirstChild("Name")
					local image = correctEquipFrame.Image
					
					name.Text = itemInfo.Name
					name.BackgroundColor3 = nameColor
					image.Image = "rbxassetid://"..itemInfo.ImageId
					
					equipItemEvent:FireServer(correctEquipFrame.Type.Value, name.Text)
				end
			end)
			
			

			newItem.Parent = sectionFrame
			newItem.Visible = true
			
			gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
			gridLayout:ApplyLayout()
		end
		
	else --Create new Cell
		gridLayout.SortOrder = Enum.SortOrder.Name
		gridLayout:ApplyLayout()
		
		local newItem = item:Clone()
		newItem.Type.Value = itemInfo.Type
		newItem.Name = itemInfo.Name
		newItem:FindFirstChild("Name").Text = itemInfo.Name
		newItem:FindFirstChild("Name").BackgroundColor3 = rarityColor
		newItem.Rarity.Value = itemInfo.Rarity
		newItem.LayoutOrder = sortOrder[newItem.Rarity.Value]
		newItem:FindFirstChild("Image").Image = "rbxassetid://"..itemInfo.ImageId
		
		--Equip Function
		newItem.MouseButton1Click:Connect(function()
			local itemType = newItem.Type
			local correctEquipFrame = findCorrectEquipFrame(itemType.Value)
			local nameColor = getRarityColor(itemId)

			if correctEquipFrame then
				local name = correctEquipFrame:FindFirstChild("Name")
				local image = correctEquipFrame.Image

				name.Text = itemInfo.Name
				name.BackgroundColor3 = nameColor
				image.Image = "rbxassetid://"..itemInfo.ImageId

				equipItemEvent:FireServer(correctEquipFrame.Type.Value, name.Text)
			end
		end)
		
		newItem.Parent = sectionFrame
		newItem.Visible = true
		
		gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		gridLayout:ApplyLayout()
	end
end

--Loads inventory upon player join
loadInventory.OnClientEvent:Connect(function(inventory)
	if inventory and mainFrame then
		
		--Add the items into inventory
		for invIndex,id in pairs(inventory) do
			
			local count = 0
			for i,dupId in pairs(inventory) do
				if dupId == id then
					count += 1
				end
			end
			
			if count > 1 then --If more than one item
				addCell(id, true, count)
			else
				addCell(id, false, nil)
			end
			
		end

	end
	
end)

--Reset player inventory if needed to update
resetInventory.OnClientEvent:Connect(function()
	if mainFrame then
		
		--Removing all items from all 4 tabs of inventory
		for i,frame in pairs(mainFrame:GetChildren()) do
			if frame:IsA("ScrollingFrame") then
				
				for i,item in pairs(frame:GetChildren()) do
					if item:IsA("ImageButton") then
						item:Destroy()
					end
				end
				
			end
		end
		
	end
end)

addCellEvent.OnClientEvent:Connect(function(winningId, duplicate, count)
	addCell(winningId, duplicate, count)
end)
