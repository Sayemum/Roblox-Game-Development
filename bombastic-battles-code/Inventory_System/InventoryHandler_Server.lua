--// InventoryHandler_Server
--// Scripted by: BrawlBattle
--// Desc: Handles the player inventory on the server side.

local SS = game:GetService("ServerStorage")
local DS2 = require(SS:WaitForChild("DataStore2"))

local pets = SS:WaitForChild("Assets"):WaitForChild("ShopAssets"):WaitForChild("Pets")

local Signals = {} do 
	for _, Signal in pairs(script.signals:GetChildren()) do
		Signals[Signal.Name] = Signal.Value
	end
end

--Equip a pet from the player's inventory
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
			clonedPet.Body.FollowScript.Disabled = false
		end
		
	end
end

--Fetch Player Inventory Data or Return Nothing
Signals.FetchInventory.OnServerInvoke = function(plr)
	local inventory = DS2("Inventory", plr):Get({0,1,2,3})
	
	if inventory then
		return inventory
	else
		return nil
	end
end

--Equip the item from player inventory (e.g. bomb, skin, ability, pet)
Signals.EquipItem.OnServerEvent:Connect(function(plr, equipType, itemName)
	local equipStore = DS2("Equipped"..equipType, plr)
	local equippedStats = plr:WaitForChild("EquippedStats")
	local equipValue = equippedStats:FindFirstChild("Equipped"..equipType)
	
	if equippedStats and equipValue and equipStore then
		equipValue.Value = itemName
		equipStore:Set(itemName)
		
		--Equip Pet for Player
		if equipType == "Pet" then
			equipPet(plr, itemName)
		end
	end
end)

return nil
