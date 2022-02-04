--// Spectate
--// Scripted by: BrawlBattle
--// Desc: Handler for the spectate feature when player is waiting for the next game. In the meantime, they can spectate the players currently in the match.

local cam = workspace.CurrentCamera
local pos = 1

local plr = game.Players.LocalPlayer
local players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")

local RS = game:GetService("ReplicatedStorage")
local remote = RS.Events:WaitForChild("FetchActivePlayers")
local playerList = {}

local mainFrame = script.Parent.MainFrame
local leftButton = mainFrame.LeftButton
local rightButton = mainFrame.RightButton
local stopButton = mainFrame.StopButton
local playerText = mainFrame.PlayerText

local isOpen = script.Parent.IsOpen
local spectateButton = mainFrame.Parent.SpectateButton

--Update the table of active players
local function updateList()
	playerList = remote:InvokeServer()
end

--Flip the camera to a different player once they die
local function updateCamera(player)
	pcall(function()
		cam.CameraSubject = player.Character.Humanoid
		playerText.Text = player.Name
		
		cam.CameraSubject:GetPropertyChangedSignal("Health"):Connect(function()
			if cam.CameraSubject.Health == 0 then
				updateList()
				pos += 1

				if pos > #playerList then
					pos = 1
				end

				if isOpen.Value == true then
					isOpen.Value = false
					mainFrame.Visible = false
					spectateButton.Visible = true

					updateCamera(plr)
				end
			end
		end)
	end)
end

--Pressing the right button flips to the next active player currently in the match in order of the table
local function rightClick()
	updateList()
	pos += 1

	if playerList[pos] ~= nil then
		updateCamera(playerList[pos])
	end

	if playerList[pos] == nil then
		pos = 1
		updateCamera(playerList[pos])
	end
end
rightButton.MouseButton1Click:Connect(rightClick)

--Pressing the left button flips to the next active player currently in the match in order of the table
local function leftClick()
	updateList()
	pos -= 1

	if playerList[pos] ~= nil then
		updateCamera(playerList[pos])
	end

	if playerList[pos] == nil then
		pos = 1
		updateCamera(playerList[pos])
	end
end
leftButton.MouseButton1Click:Connect(leftClick)


--Action handler for flipping left or right
local function flipAction(actionName, inputState)
	if actionName == "FlipLeft" and inputState == Enum.UserInputState.Begin then
		leftClick()
	elseif actionName == "FlipRight" and inputState == Enum.UserInputState.Begin then
		rightClick()
	end
end

--Clicking on the spectate button changes player camera to the first active player on the table
spectateButton.MouseButton1Click:Connect(function()
	updateList()
	
	if #playerList ~= 0 then
		if plr.Team == game.Teams.Lobby then
			if isOpen.Value == false then
				isOpen.Value = true
				mainFrame.Visible = true
				spectateButton.Visible = false
				pos = 1
				updateCamera(playerList[pos])
				
				CAS:BindAction("FlipLeft", flipAction, false, Enum.KeyCode.Q)
				CAS:BindAction("FlipRight", flipAction, false, Enum.KeyCode.E)
			end
		end
	end
	
end)

--Stop spectating and move camera back to player
stopButton.MouseButton1Click:Connect(function()
	if isOpen.Value == true then
		isOpen.Value = false
		mainFrame.Visible = false
		spectateButton.Visible = true
		
		updateCamera(plr)
		
		CAS:UnbindAction("FlipLeft")
		CAS:UnbindAction("FlipRight")
	end
end)
