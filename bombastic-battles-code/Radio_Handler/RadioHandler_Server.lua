--// RadioHadler_Server
--// Scripted by: BrawlBattle
--// Desc: Handles the custom player radio when equipped.

local RS = game:GetService("ReplicatedStorage")

local skinsDictionary = require(RS:WaitForChild("DataModules"):WaitForChild("ShopData"):WaitForChild('SkinsDictionary'))

local SS = game:GetService("ServerStorage")

local DS2 = require(SS:WaitForChild("DataStore2"))
local shopAssets = SS:WaitForChild("Assets"):WaitForChild("ShopAssets")

local CS = game:GetService("CollectionService")

local radios = shopAssets:WaitForChild("Radios")

local Signals     = {} do 
	for _, Signal in pairs(script.signals:GetChildren()) do
		Signals[Signal.Name] = Signal.Value
	end
end

Signals.FetchSongList.OnServerInvoke = function(plr)
	local radioSongs = DS2("RadioSongs", plr):Get({})
	return radioSongs
end

Signals.FindAudio.OnServerInvoke = function(plr, audioId)
	local radioSongs = DS2("RadioSongs", plr):Get({})
	local foundAudio = false
	
	if table.find(radioSongs, audioId) then
		foundAudio = true
	end
	
	return foundAudio
end

Signals.AddAudio.OnServerEvent:Connect(function(plr, audioId)
	local radioSongs = DS2("RadioSongs", plr):Get({})
	
	table.insert(radioSongs, audioId)
	
	DS2("RadioSongs", plr):Set(radioSongs)
	
	return true
end)

Signals.GiveRadio.Event:Connect(function(plr, char, equippedRadioId)
	repeat wait() until char or plr.CharacterAdded:Wait()
	
	local radioName = skinsDictionary.FetchName(equippedRadioId)
	local radio = radios:FindFirstChild(radioName)
	
	if radioName and radio then
		local clonedRadio = radio:Clone()
		
		local radioHandle = clonedRadio:FindFirstChild("Handle")
		if radioHandle then
			CS:AddTag(clonedRadio, "Radios")
		end
		
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			hum:AddAccessory(clonedRadio)
		end
	end
end)

Signals.PlayAudio.OnServerEvent:Connect(function(plr, audioId)
	if plr.TeamColor ~= game.Teams:WaitForChild("Lobby").TeamColor then
	local char = plr.Character
	local equippedRadioId = plr:WaitForChild("EquippedStats"):WaitForChild("EquippedRadio")
	local radioName = skinsDictionary.FetchName(equippedRadioId.Value)
	local radio = char:FindFirstChild(radioName)
	
	if equippedRadioId and radioName and radio then
		local audio = radio.Handle.Audio
		audio.SoundId = "rbxassetid://"..audioId
		audio:Play()
	end
	end
end)

Signals.StopAudio.OnServerEvent:Connect(function(plr)
	local char = plr.Character
	local equippedRadioId = plr:WaitForChild("EquippedStats"):WaitForChild("EquippedRadio")
	local radioName = skinsDictionary.FetchName(equippedRadioId.Value)
	local radio = char:FindFirstChild(radioName)

	if equippedRadioId and radioName and radio then
		local audio = radio.Handle.Audio
		audio:Stop()
	end
end)

Signals.DeleteAudio.OnServerInvoke = function(plr, audioId)
	local deleteSuccessful = false
	
	local radioSongs = DS2("RadioSongs", plr):Get({})
	local foundAudioPos = table.find(radioSongs, audioId)
	
	if foundAudioPos then
		table.remove(radioSongs, foundAudioPos)
		deleteSuccessful = true
	end
	
	DS2("RadioSongs", plr):Set(radioSongs)
	
	return deleteSuccessful
end

return nil
