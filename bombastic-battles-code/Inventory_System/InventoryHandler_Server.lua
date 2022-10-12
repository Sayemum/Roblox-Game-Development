--// InventoryHandler_Server
--// Scripted by: BrawlBattle
--// Desc: Handles the player inventory on the server side.

local MPS = game:GetService("MarketplaceService")

local RS = game:GetService("ReplicatedStorage")
local shopData = RS:WaitForChild("DataModules"):WaitForChild("ShopData")
local skinDictionary = require(shopData:WaitForChild("SkinsDictionary"))
local gamepasses = require(shopData:WaitForChild("Gamepasses"))

local giveRadio = RS:WaitForChild("GiveRadio")

local SS = game:GetService("ServerStorage")
local DS2 = require(SS:WaitForChild("DataStore2"))

local pets = SS:WaitForChild("Assets"):WaitForChild("ShopAssets"):WaitForChild("Pets")

local Signals     = {} do 
	for _, Signal in pairs(script.signals:GetChildren()) do
		Signals[Signal.Name] = Signal.Value
	end
end

local function equipPet(plr, petName)
	local char = plr.Character or plr.CharacterAdded:Wait()
	local tagFound = false
	
	if char then
		
		--Check if player has pet equipped
		for _,v in pairs(char:GetDescendants()) do
			if v:IsA("StringValue") and v.Name == "Tag" then
				tagFound = true
				v.Parent:Destroy()
				break
			end
		end
		
		--Give Pet or None
		local pet = pets:FindFirstChild(petName)
		
		if pet and petName ~= "None" then
			local clonedPet = pet:Clone()
			clonedPet.Parent = char
			clonedPet:PivotTo(char:GetPivot())
			clonedPet.Body.FollowScript.Disabled = false
		end
		
	end
end

local function equipEmote(plr, emoteId)
	local char = plr.Character or plr.CharacterAdded:Wait()
	
	if char then
		local hum = char.Humanoid
		local humDesc = hum.HumanoidDescription
		
		if hum and humDesc then
			local emoteInfo = skinDictionary[emoteId]
			local emoteName = emoteInfo.Name
			local catalogId = emoteInfo.CatalogId
			
			local emotesTable = {
				[emoteName] = catalogId
			}
			humDesc:SetEmotes(emotesTable)
		end
	end
end

local function equipRadio(plr, equippedRadioId)
	local char = plr.Character or plr.CharacterAdded:Wait()
	local playerHasRadio = MPS:UserOwnsGamePassAsync(plr.UserId, gamepasses["Radio"].GamepassId)

	if char and playerHasRadio then
		--Check for an existing radio and delete
		for _,prevRadio in pairs(char:GetChildren()) do
			if prevRadio:IsA("Accessory") and prevRadio:FindFirstChild("IsRadio") then
				prevRadio:Destroy()
			end
		end
		
		giveRadio:Fire(plr, char, equippedRadioId)
	end
end

Signals.FetchInventory.OnServerInvoke = function(plr)
	local inventory = DS2("Inventory", plr):Get({0,1,2,3,4,5})
	
	if inventory then
		return inventory
	else
		return nil
	end
end

Signals.PlayerOwnsInvId.OnServerInvoke = function(plr, id)
	local inventory = DS2("Inventory", plr):Get({0,1,2,3,4,5})
	local playerOwnsId = false
	
	if table.find(inventory, id) then
		playerOwnsId = true
	end
	
	return playerOwnsId
end

Signals.EquipItem.OnServerEvent:Connect(function(plr, equipType, itemName, itemId, condition)
	if condition == "OnlyEquip" then
		if equipType == "Pet" then
			equipPet(plr, itemName)
		elseif equipType == "Radio" then
			equipRadio(plr, itemId)
		elseif equipType == "Emote" then
			equipEmote(plr, itemId)
		end
	else
		
		local equipStore = DS2("Equipped"..equipType, plr)
		local equippedStats = plr:WaitForChild("EquippedStats")
		local equipValue = equippedStats:FindFirstChild("Equipped"..equipType)

		if equippedStats and equipValue and equipStore then
			equipValue.Value = itemId
			equipStore:Set(itemId)

			--Equip Pet for Player
			if equipType == "Pet" then
				equipPet(plr, itemName)
			end
			
			--Equip Emote for Player
			if equipType == "Emote" then
				equipEmote(plr, itemId)
			end
			
			--Equip Radio for Player
			if equipType == "Radio" then
				equipRadio(plr, itemId)
			end
		end
	end
	
end)

return nil
