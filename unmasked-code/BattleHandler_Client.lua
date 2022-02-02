--// BattleHandler_Client
--// Scripted by: BrawlBattle
--// Desc: Handles the whole battle on the client side.

local TS = game:GetService("TweenService")

local SoundService = game:GetService("SoundService")
local SFX = SoundService:WaitForChild("SFX")
local Music = SoundService:WaitForChild("Music")
local battleMusic1 = Music:WaitForChild("Battle7")
local punchSFX1 = SFX:WaitForChild("Punch1")
local healSFX1 = SFX:WaitForChild("Heal1")
local mouseHoverSFX1 = SFX:WaitForChild("MouseHover1")
local selectSFX1 = SFX:WaitForChild("Select1")

local RS = game:GetService("ReplicatedStorage")
local meleeAttack = RS:WaitForChild("MeleeAttack")
local magicAttack = RS:WaitForChild("MagicAttack")
local magicSupport = RS:WaitForChild("MagicSupport")
local fetchBattleStat = RS:WaitForChild("FetchBattleStat")
local prepareBattle = RS:WaitForChild("PrepareBattle")
local changePersona = RS:WaitForChild("ChangePersona")

local sharedModules = RS:WaitForChild("SharedModules")
local shakeEffectEvent = RS:WaitForChild("ShakeEffectEvent")
local cameraShaker = require(sharedModules:WaitForChild("CameraShaker"))
local shakerPresents = require(sharedModules:WaitForChild("CameraShaker"):WaitForChild("CameraShakePresets"))

local plr = game.Players.LocalPlayer
local character = plr.Character
local battleStats = plr:WaitForChild("BattleStats")
local currentPersona = battleStats:WaitForChild("CurrentPersona")
local currentHP = battleStats:WaitForChild("CurrentHP")
local currentSP = battleStats:WaitForChild("CurrentSP")
local maxHP = battleStats:WaitForChild("MaxHP")
local maxSP = battleStats:WaitForChild("MaxSP")

local camera = workspace.CurrentCamera
local camAngles = workspace:WaitForChild("CamAngles")
local mainBattleCam = camAngles.MainBattle

local currentPersonaFolder = workspace:WaitForChild("CurrentPersona")
local currentEnemiesFolder = workspace:WaitForChild("CurrentEnemies")

local battleUI = script.Parent
local optionsFrame = battleUI.Options
local skillsFrame = battleUI.Skills
local statsFrame = battleUI.Stats
local tempFrame = battleUI.Temporary

local templates = battleUI.Templates

local meleeButton = optionsFrame.Melee
local skillsButton = optionsFrame.Skills
local guardButton = optionsFrame.Guard

local playerAnimations = battleUI.PlayerAnimations

local battleMenuOpen = true
local yourTurn = true

local colorTypeTable = {
	["Ice"] = Color3.fromRGB(0, 170, 255);
	["Heal"] = Color3.fromRGB(255, 0, 127);
	["Physical"] = Color3.fromRGB(255, 85, 0);
}

local enemyMoveList = {
	"Melee";
	"Guard";
	"Dia"
}

--TEMP
local plrStatFrame = statsFrame:WaitForChild("Player1")

--Init
prepareBattle:InvokeServer(plr)

--Loads Current Persona Skills onto the Skills Tab
local function loadPlayerSkills()
	if currentPersona.Value ~= nil then
		local personaModel = currentPersonaFolder:FindFirstChild(currentPersona.Value)
		local skillsFolder = personaModel:FindFirstChild("Skills")
		
		if personaModel and skillsFolder then
			
			--Remove Old Skills from Frame
			for _,oldSkill in pairs(skillsFrame.List:GetChildren()) do
				if (oldSkill ~= nil) and (oldSkill:IsA("UIListLayout") == false) then
					oldSkill:Destroy()
				end
			end
			
			--Get each skill from model and add to frame
			for _,skill in pairs(skillsFolder:GetChildren()) do
				local skillButton = templates:WaitForChild("SkillName"):Clone()
				--Stats
				skillButton.Name = skill.Name
				skillButton.Cost.Value = skill.Cost.Value
				skillButton.CostLabel.Text = skill.Cost.Value.. " SP"
				skillButton.SkillType.Value = skill.SkillType.Value
				skillButton.SoundSFX.Value = skill.SoundSFX.Value
				
				--Graphic
				skillButton.Text = skill.Name
				skillButton.BackgroundColor3 = colorTypeTable[skill.SkillType.Value]
				
				skillButton.Parent = skillsFrame.List
				skillButton.Visible = true
				
				local skillStats = {
					["Name"] = skill.Name;
					["Cost"] = skill.Cost.Value;
					["Type"] = skill.SkillType.Value;
					["Level"] = skill.SkillLevel.Value;
					["SFX"] = skill.SoundSFX.Value
				}
				
				skillButton.MouseButton1Click:Connect(function()
					--Use Skill
					performNextPlayerMove(nil, skillStats)
					
					wait(5)
					
					performNextEnemyMove(nil, skillStats)
				end)
			end
			
		end
	end
end
loadPlayerSkills() --Load skills at the start of battle

local function playAnimation(char, animName, priority, speed)
	local hum = char:FindFirstChild("Humanoid")
	if hum then
		local anim = hum:LoadAnimation(playerAnimations[animName])
		anim.Priority = Enum.AnimationPriority[priority]
		anim:Play()
		anim.Looped = false
		anim:AdjustSpeed(speed or 1)
	end
end

local function displayMoveName(moveName)
	local label = tempFrame.MoveName
	label.Text = moveName
	label.Visible = true
	
	delay(3, function()
		label.Visible = false
	end)
end

--//Init
plrStatFrame.NameLabel.Text = plr.Name
battleMusic1:Play()

for _,button in pairs(script.Parent:GetDescendants()) do
	if button:IsA("TextButton") or button:IsA("ImageButton") then
		button.MouseEnter:Connect(function()
			mouseHoverSFX1:Play()
		end)
		
		button.MouseButton1Click:Connect(function()
			selectSFX1:Play()
		end)
	end
end

--//Shaker Effects
local function shakeCamera(shakeCf)
	camera.CFrame = camera.CFrame * shakeCf
end

shakeEffectEvent.OnClientEvent:Connect(function()
	local renderPriority = Enum.RenderPriority.Camera.Value + 1
	local camShake = cameraShaker.new(renderPriority, shakeCamera)
	camShake:Start()

	camShake:ShakeOnce(2, 10, 0.1, 0.1)
	camera.CFrame = mainBattleCam.CFrame
end)


--Pans the camera when a move is made
local function panCamera(angles, speed, waitForComplete)
	
	for i,angle in pairs(angles) do
		local angleCam = camAngles:FindFirstChild(angle)
		
		if angleCam then
			local tween = TS:Create(camera, TweenInfo.new(speed or 2), {CFrame = angleCam.CFrame})
			tween:Play()
			
			if waitForComplete then
				tween.Completed:Wait()
			end
			
		end
	end
	
	camera.CFrame = mainBattleCam.CFrame
end


--Performs the next move that the player makes
function performNextPlayerMove(moveType, moveStats)
	local personaChar = currentPersonaFolder:FindFirstChild(currentPersona.Value)
	local targetChar = currentEnemiesFolder:FindFirstChild("Enemy1")
	local char = plr.Character
	
	if moveType == "Melee" then
		if personaChar and targetChar then
			optionsFrame.Visible = false
			displayMoveName("Melee")

			local char = plr.Character
			local cameraAngles = {"Character"}
			panCamera(cameraAngles, 2, true)
			
			panCamera({"Enemy"}, 1, false)
			
			--Move Player to Player
			local hum = char:FindFirstChild("Humanoid")
			local targetTorso = targetChar:FindFirstChild("UpperTorso")
			if hum and targetTorso then
				hum.WalkSpeed = 36
				hum:MoveTo(targetTorso.Position * Vector3.new(0.85,0,0))
				hum.MoveToFinished:Wait(1)
			end
			
			playAnimation(char, "Melee", "Action", 1.5)
			
			delay(0.25, function()
				local gotHit = meleeAttack:InvokeServer(char, targetChar)
				if gotHit then
					playAnimation(targetChar, "Hit", "Action")
					punchSFX1:Play()
				end
			end)
			
			delay(1, function()
				char:SetPrimaryPartCFrame(game.Workspace.SpawnLocation.CFrame * CFrame.new(0,4,0))
				hum.WalkSpeed = 0
				camera.CFrame = mainBattleCam.CFrame
			end)
			
		end
	
	elseif moveType == "Guard" then
		print("GUARD")
		playAnimation(char, "Guard", "Action")
		
	else --If NOT Melee or Guard

		if moveStats["Type"] == "Heal" then
			local char = plr.Character

			if char then
				skillsFrame.Visible = false
				displayMoveName(moveStats["Name"])
				local cameraAngles = {"Character", "CharSupport"}
				panCamera(cameraAngles, 2, true)
				playAnimation(personaChar, "Godlike", "Action")

				local gotHealed = magicSupport:InvokeServer(personaChar, moveStats["Type"], moveStats["Level"], moveStats["Cost"], moveStats["Type"])
				if gotHealed then
					healSFX1:Play()
				end
			end

		else --Fire / Ice / Wind / Grass
			print("NORMAL MAGIC")
			skillsFrame.Visible = false
			displayMoveName(moveStats["Name"])

			local char = plr.Character
			local cameraAngles = {"Character"}
			panCamera(cameraAngles, 2, true)

			playAnimation(personaChar, "Point", "Action")
			local gotHit = magicAttack:InvokeServer(personaChar, targetChar, moveStats["Type"], moveStats["Level"], moveStats["Cost"], moveStats["Type"])

			if gotHit then
				playAnimation(targetChar, "Hit", "Action")
				punchSFX1:Play()
			end
			
		end
		
	end
end

--Performs the next move that the enemy makes
function performNextEnemyMove(moveType, moveStats)
	local personaChar = currentPersonaFolder:FindFirstChild(currentPersona.Value)
	local targetChar = currentEnemiesFolder:FindFirstChild("Enemy1")
	
	--Adds current enemy skills to possible moves table
	local possibleMoves = {}
	for _,move in pairs(targetChar.Moves:GetChildren()) do
		if move:IsA("StringValue") then
			table.insert(possibleMoves, move)
		end
	end
	
	--Pick random move
	local randomPos = math.random(1, #possibleMoves)
	local randomMove = possibleMoves[randomPos]
	local moveStats = {
		["Name"] = randomMove.Value;
		["Type"] = randomMove.MoveType.Value;
		["Level"] = randomMove.MoveLevel.Value;
		["SFX"] = randomMove.SoundSFX.Value
	}
	
	if moveStats["Type"] == "Melee" then
		local personaChar = currentPersonaFolder:FindFirstChild(currentPersona.Value)
		local targetChar = currentEnemiesFolder:FindFirstChild("Enemy1")

		if personaChar and targetChar then
			local char = plr.Character
			
			displayMoveName("Melee")
			
			local cameraAngles = {"Enemy"}
			panCamera(cameraAngles, 2, true)
			
			playAnimation(targetChar, "Melee", "Action", 1.5)

			local gotHit = meleeAttack:InvokeServer(targetChar, char)
			if gotHit then
				playAnimation(char, "Hit", "Action")
				punchSFX1:Play()
			end
		end
	
	else --If NOT Melee
		
		if moveStats["Type"] == "Heal" then
			local char = plr.Character

			if char then
				displayMoveName(moveStats["Name"])
				local cameraAngles = {"Enemy"}
				panCamera(cameraAngles, 2, true)
				playAnimation(targetChar, "Godlike", "Action")

				local gotHealed = magicSupport:InvokeServer(targetChar, moveStats["Type"], moveStats["Level"], nil, moveStats["Type"])
				if gotHealed then
					healSFX1:Play()
				end
			end

		else --Fire / Ice / Wind / Grass
			print("NORMAL MAGIC")
			displayMoveName(moveStats["Name"])

			local char = plr.Character
			local cameraAngles = {"Enemy"}
			panCamera(cameraAngles, 2, true)

			playAnimation(targetChar, "Point", "Action")
			local gotHit = magicAttack:InvokeServer(targetChar, char, moveStats["Type"], moveStats["Level"], nil, moveStats["Type"])

			if gotHit then
				playAnimation(char, "Hit", "Action")
				punchSFX1:Play()
			end

		end
		
	end
	
	optionsFrame.Visible = true
	battleMenuOpen = true
	yourTurn = true
end

--Performs the next melee move that the player makes
meleeButton.MouseButton1Click:Connect(function()
	if battleMenuOpen == true and yourTurn == true then
		battleMenuOpen = false
		yourTurn = false
		
		performNextPlayerMove("Melee", nil)
		
		wait(5)
		
		performNextEnemyMove(nil, nil)
		
		optionsFrame.Visible = true
		battleMenuOpen = true
		yourTurn = true
	end
end)

--Performs the next guard move that the player makes
guardButton.MouseButton1Click:Connect(function()
	if battleMenuOpen == true and yourTurn == true then
		battleMenuOpen = false
		yourTurn = false
		
		local personaChar = currentPersonaFolder:FindFirstChild(currentPersona.Value)
		local targetChar = currentEnemiesFolder:FindFirstChild("Enemy1")

		if personaChar and targetChar then
			optionsFrame.Visible = false
			displayMoveName("Guard")
			performNextPlayerMove("Guard", nil)
			
			wait(3)
			
			performNextEnemyMove(nil, nil)
		end

		optionsFrame.Visible = true
		battleMenuOpen = true
		yourTurn = true
	end
end)

--Opens up the "skills" tab
skillsButton.MouseButton1Click:Connect(function()
	if battleMenuOpen == true then
		battleMenuOpen = false
		
		optionsFrame.Visible = false
		skillsFrame.Visible = true
	end
end)

--Closes the "skills" tab
skillsFrame.Cancel.MouseButton1Click:Connect(function()
	if battleMenuOpen == false then
		battleMenuOpen = true
		optionsFrame.Visible = true
		skillsFrame.Visible = false
	end
end)


--Update Stats Functions
currentHP.Changed:Connect(function(newVal)
	plrStatFrame.HPCounter.Text = newVal
	TS:Create(plrStatFrame.HPBar, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(newVal / maxHP.Value,0,0.15,0)}):Play()
end)

currentSP.Changed:Connect(function(newVal)
	plrStatFrame.SPCounter.Text = newVal
	TS:Create(plrStatFrame.SPBar, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(newVal / maxSP.Value,0,0.15,0)}):Play()
end)
