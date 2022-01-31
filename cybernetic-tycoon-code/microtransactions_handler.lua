--[[ Note
	Read the wiki article that uses this code to learn more about it:
	http://wiki.roblox.com/index.php?title=Handling_multiple_developer_products
--]]

local MarketplaceService = game:GetService("MarketplaceService")
local PurchaseHistory = game:GetService("DataStoreService"):GetDataStore("PurchaseHistory")
--local Analytics = require(game.ReplicatedStorage.AnalyticsModule)

--[[
	This is how the table below has to be set up:
		[productId] = function(receipt,player) return allow end
			receipt is the receiptInfo, as called by ProcessReceipt
			player is the player that is doing the purchase
		If your function returns 'true', the purchase is approved.
		If your function doesn't return 'true', or errors, the purchase is cancelled.
--]]
local Products = {
	--[[
	-- productId 1111 for a heal up
	[1111] = function(receipt,player)
		-- Check if we can actual heal him
		if not player.Character then return end
		local human = player.Character:findFirstChild("Humanoid")
		if not human then return end
		-- Heal him, and return true, indicating the purchase is done
		human.Health = human.MaxHealth
		return true
	end;
--]]	
	---------------------- 10,000 Cash ----------------------
	[164323494] = function(receipt,player)
		-- again, do checks, this time for the cash value
		local cash = game.ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if not cash then return end -- no leaderstats, or "cash" in them
		cash.Value = cash.Value + 10000 -- give cash
		
		--Analytics.RecordTransaction(player, 15, "Credits:10000")
		--Analytics.RecordResource(player, 10000, "Source", "Credits", "ProductStore", "Credits:10K")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- tell them of our success
	end;
	---------------------- 25,000 Cash ----------------------
	[164323603] = function(receipt,player)
		-- same thing as above, but now for 200 cash
		local cash = game.ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if not cash then return end
		cash.Value = cash.Value + 25000
		
		--Analytics.RecordTransaction(player, 30, "Credits:25000")
		--Analytics.RecordResource(player, 25000, "Source", "Credits", "ProductStore", "Credits:25K")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 50,000 Cash ----------------------
	[164323752] = function(receipt,player)
		local cash = game.ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if not cash then return end
		cash.Value = cash.Value + 50000
		
		--Analytics.RecordTransaction(player, 60, "Credits:50000")
		--Analytics.RecordResource(player, 50000, "Source", "Credits", "ProductStore", "Credits:50K")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 100,000 Cash ----------------------
	[164323908] = function(receipt,player)
		local cash = game.ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if not cash then return end
		cash.Value = cash.Value + 100000
		
		--Analytics.RecordTransaction(player, 125, "Credits:100000")
		--Analytics.RecordResource(player, 100000, "Source", "Credits", "ProductStore", "Credits:100K")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 250,000 Cash ----------------------
	[164324022] = function(receipt,player)
		local cash = game.ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if not cash then return end
		cash.Value = cash.Value + 250000
		
		--Analytics.RecordTransaction(player, 300, "Credits:250000")
		--Analytics.RecordResource(player, 250000, "Source", "Credits", "ProductStore", "Credits:250K")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 500,000 Cash ----------------------
	[164324094] = function(receipt,player)
		local cash = game.ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if not cash then return end
		cash.Value = cash.Value + 500000
		
		--Analytics.RecordTransaction(player, 600, "Credits:500000")
		--Analytics.RecordResource(player, 500000, "Source", "Credits", "ProductStore", "Credits:500K")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 1,000,000 Cash ----------------------
	[164324177] = function(receipt,player)
		local cash = game.ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if not cash then return end
		cash.Value = cash.Value + 1000000
		
		--Analytics.RecordTransaction(player, 1250, "Credits:1000000")
		--Analytics.RecordResource(player, 1000000, "Source", "Credits", "ProductStore", "Credits:1M")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 50 Gems ----------------------
	[175295810] = function(receipt,player)
		local gems = player.leaderstats.Gems
		if not gems then return end
		gems.Value = gems.Value + 50
		
		--Analytics.RecordTransaction(player, 15, "Gems:50")
		--Analytics.RecordResource(player, 50, "Source", "Gems", "GemShop", "Gems:50")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 100 Gems ----------------------
	[175295952] = function(receipt,player)
		local gems = player.leaderstats.Gems
		if not gems then return end
		gems.Value = gems.Value + 100
		
		--Analytics.RecordTransaction(player, 25, "Gems:100")
		--Analytics.RecordResource(player, 100, "Source", "Gems", "GemShop", "Gems:100")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 250 Gems ----------------------
	[175296088] = function(receipt,player)
		local gems = player.leaderstats.Gems
		if not gems then return end
		gems.Value = gems.Value + 250
		
		--Analytics.RecordTransaction(player, 75, "Gems:250")
		--Analytics.RecordResource(player, 250, "Source", "Gems", "GemShop", "Gems:250")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 500 Gems ----------------------
	[175296207] = function(receipt,player)
		local gems = player.leaderstats.Gems
		if not gems then return end
		gems.Value = gems.Value + 500
		
		--Analytics.RecordTransaction(player, 125, "Gems:500")
		--Analytics.RecordResource(player, 500, "Source", "Gems", "GemShop", "Gems:500")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 1,000 Gems ----------------------
	[175296273] = function(receipt,player)
		local gems = player.leaderstats.Gems
		if not gems then return end
		gems.Value = gems.Value + 1000
		
		--Analytics.RecordTransaction(player, 250, "Gems:1000")
		--Analytics.RecordResource(player, 1000, "Source", "Gems", "GemShop", "Gems:1000")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 5,000 Gems ----------------------
	[175296425] = function(receipt,player)
		local gems = player.leaderstats.Gems
		if not gems then return end
		gems.Value = gems.Value + 5000
		
		--Analytics.RecordTransaction(player, 1250, "Gems:5000")
		--Analytics.RecordResource(player, 5000, "Source", "Gems", "GemShop", "Gems:5000")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 7,500 Gems ----------------------
	[311511578] = function(receipt,player)
		local gems = player.leaderstats.Gems
		if not gems then return end
		gems.Value = gems.Value + 7500
		
		--Analytics.RecordTransaction(player, 1750, "Gems:7500")
		--Analytics.RecordResource(player, 7500, "Source", "Gems", "GemShop", "Gems:7500")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 10,000 Gems ----------------------
	[311511790] = function(receipt,player)
		local gems = player.leaderstats.Gems
		if not gems then return end
		gems.Value = gems.Value + 10000
		
		--Analytics.RecordTransaction(player, 2500, "Gems:10000")
		--Analytics.RecordResource(player, 10000, "Source", "Gems", "GemShop", "Gems:10000")
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- 25,000 Gems ----------------------
	[311512621] = function(receipt,player)
		local gems = player.leaderstats.Gems
		if not gems then return end
		gems.Value = gems.Value + 25000
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	
	---------------------- Red Balloon ----------------------
	[164324320] = function(receipt,player)
		local balloon = game.Lighting.WeaponFolder.RedBalloon
		if not balloon then return end
		player.Tools['RedBallon'].Value = true
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- Pompous Cloud ----------------------
	[164324464] = function(receipt,player)
		local cloud = game.Lighting.WeaponFolder.PompousTheCloud
		if not cloud then return end
		player.Tools['Pompous Cloud'].Value = true
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
	---------------------- Magic Carpet ----------------------
	[164324758] = function(receipt,player)
		local carpet = game.Lighting.WeaponFolder.MagicCarpet
		if not carpet then return end
		player.Tools['MagicCarpet'].Value = true
		
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://1034765430"
		sound.Parent = player.PlayerGui
		sound.Volume = 1
		sound:Play()
		wait(2)
		sound:Destroy()
		return true -- We can call this a success
	end;
}

-- set MarketplaceService.ProcessReceipt to this function
-- (this is the same as doing: MarketplaceService.ProcessReceipt = function(recei... )
function MarketplaceService.ProcessReceipt(receiptInfo) 
    local playerProductKey = receiptInfo.PlayerId .. ":" .. receiptInfo.PurchaseId
    if PurchaseHistory:GetAsync(playerProductKey) then
        return Enum.ProductPurchaseDecision.PurchaseGranted --We already granted it.
    end
    -- find the player based on the PlayerId in receiptInfo
	local player,handler -- handler is used a few lines lower
    for k,v in ipairs(game:GetService("Players"):GetPlayers()) do
        if v.userId == receiptInfo.PlayerId then
			player = v break -- we found him, no need to search further
        end	
    end
 
	-- player left? not sure if it can happen, but to be sure, don't process it
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
 
	for productId,func in pairs(Products) do
		if productId == receiptInfo.ProductId then
			handler = func break -- found our handler
		end
	end
 
	-- apparently it's not our responsibility to handle this purchase
	-- if this happens, you should probably check your productIds etc
	-- let's just assume this is ment behavior, and let the purchase go through
	if not handler then return Enum.ProductPurchaseDecision.PurchaseGranted end
 
	-- call it safely with pcall, to catch any error
	local suc,err = pcall(handler,receiptInfo,player)
	if not suc then
		warn("An error occured while processing a product purchase")
		print("\t ProductId:",receiptInfo.ProductId,"\n","Player:",player)
		print("\t Error message:",err) -- log it to the output
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
 
	-- if the function didn't error, 'err' will be whatever the function returned
	-- if our handler didn't return anything (or it returned false/nil), it means
	-- that the purchase failed for some reason, so we have to cancel it
	if not err then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
 
    -- record the transaction in a Data Store
    suc,err = pcall(function()
        PurchaseHistory:SetAsync(playerProductKey, true)
    end)
    if not suc then
        print("An error occured while saving a product purchase")
		print("\t ProductId:",receiptInfo.ProductId,"\n","Player:",player)
		print("\t Error message:",err) -- log it to the output
    end
    -- tell ROBLOX that we have successfully handled the transaction (required)
    return Enum.ProductPurchaseDecision.PurchaseGranted		
end
