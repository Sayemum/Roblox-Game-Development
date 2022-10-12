--// RadioHandler_Client
--// Scripted by: BrawlBattle
--// Desc: Handles the player radio when equipped on the client.

local RS = game:GetService("ReplicatedStorage")
local findAudio = RS:WaitForChild("FindAudio")
local addAudio = RS:WaitForChild("AddAudio")
local playAudio = RS:WaitForChild("PlayAudio")
local stopAudio = RS:WaitForChild("StopAudio")
local deleteAudio = RS:WaitForChild("DeleteAudio")
local fetchSongList = RS:WaitForChild("FetchSongList")

local MPS = game:GetService("MarketplaceService")

local mainFrame = script.Parent
local songPlaying = mainFrame.SongPlaying

local templates = mainFrame.Templates
local item = templates.Item

local addSong = mainFrame.AddSong
local songList = mainFrame.SongList.List

local addAudioButton = addSong.AddAudio
local textBox = addSong.TextBox

local function ValidateSong(songID) 
	if not songID or not tonumber(songID) then return false end

	local success, result = pcall(function()
		return MPS:GetProductInfo(songID)
	end)

	if success and result and result.AssetTypeId == 3 then
		return true
	else
		return false
	end
end

local function AddNewEntry(audioId)
	local audioInfo = MPS:GetProductInfo(audioId)
	local audioName = audioInfo.Name

	local newItem = item:Clone()
	newItem.Name = audioName
	newItem:FindFirstChild("Name").Text = audioName
	newItem.SongId.Value = audioId

	newItem.Parent = songList
	newItem.Visible = true
end

--Add Audio to the list based on audio id
addAudioButton.MouseButton1Click:Connect(function()
	--Get the audio id from the textbox
	local audioId = tonumber(textBox.Text)
	local validSongId = ValidateSong(audioId)
	
	if validSongId then
		--Check in the datastore if this audio id already exists
		local audioFound = findAudio:InvokeServer(audioId)
		
		if not audioFound then
			--If no exist, add it to the datastore and create a new entry for the song
			addAudio:FireServer(audioId)
			
			--Create new entry
			AddNewEntry(audioId)
		end
	end
	
end)

--When a new song gets added
songList.ChildAdded:Connect(function(song)
	
	if song:IsA("TextLabel") then
		local toggle = song.Toggle
		local delete = song.Delete
		local songId = song.SongId
		
		toggle.MouseButton1Click:Connect(function()
			
			if songPlaying.Value == false then
				songPlaying.Value = true
				
				playAudio:FireServer(songId.Value)
			else
				songPlaying.Value = false
				stopAudio:FireServer()
			end
		end)
		
		delete.MouseButton1Click:Connect(function()
			--Stop any audio from playing
			
			--Delete audio from list and remove datastore
			local audioDeleted = deleteAudio:InvokeServer(songId.Value)
			if audioDeleted then
				song:Destroy()
			end
		end)
	end
end)

--Load all the songs on to the list from DataStore
local fetchedRadioSongs = fetchSongList:InvokeServer()
if fetchedRadioSongs then
	for _,songId in pairs(fetchedRadioSongs) do
		AddNewEntry(songId)
	end
end
