--// BattleHandler_Server
--// Scripted by: BrawlBattle
--// Desc: Handles the whole battle system on the server side.

local RS = game:GetService("ReplicatedStorage")

local SS = game:GetService("ServerStorage")
local assets = SS:WaitForChild("Assets")
local personaModels = assets:WaitForChild("PersonaModels")

local currentPersonaFolder = workspace:WaitForChild("CurrentPersona")

local TS = game:GetService("TweenService")
local shakeEffectEvent = RS:WaitForChild("ShakeEffectEvent")

local Signals = {} do 
	for _, Signal in pairs(script.signals:GetChildren()) do
		Signals[Signal.Name] = Signal.Value
	end
end

--Fetch battle stats from server to client
Signals.FetchBattleStat.OnServerInvoke = function(plr, statName)
	local battleStats = plr:WaitForChild("BattleStats")
	
	local stat = battleStats:FindFirstChild(statName)
	if stat then
		return stat.Value
	end
end

--Prepares the battle from the server
Signals.PrepareBattle.OnServerInvoke = function(plr)
	local battleStats = plr:WaitForChild("BattleStats")
	local currentPersona = battleStats:FindFirstChild("CurrentPersona")
	local char = plr.Character
	
	if currentPersona then
		local personaModel = personaModels:FindFirstChild(currentPersona.Value)
		
		if personaModel then
			local clonedPersonaModel = personaModel:Clone()
			clonedPersonaModel.Parent = currentPersonaFolder
			clonedPersonaModel:SetPrimaryPartCFrame(char:GetPrimaryPartCFrame() * CFrame.new(10,0,-5))
		end
	end
end


local function changeCharColor(char, bColor)
	local origBodyColors = {}
	
	--Keep track of body colors and change
	for _,part in pairs(char:GetChildren()) do
		if (part:IsA("Part") or part:IsA("MeshPart")) and (part.Name ~= "HumanoidRootPart") then
			origBodyColors[part.Name] = part.BrickColor
			part.BrickColor = BrickColor.new(bColor)
		end
	end
	
	--Change colored shirt
	local shirt = char:FindFirstChildOfClass("Shirt")
	local pants = char:FindFirstChildOfClass("Pants")
	
	if shirt and pants then
		shirt.Color3 = Color3.fromRGB(255, 0, 0)
		pants.Color3 = Color3.fromRGB(255, 0, 0)
	end
	
	--Revert back
	delay(0.35, function()
		for i,partValue in pairs(origBodyColors) do
			local part = char:FindFirstChild(i)

			if part then
				part.BrickColor = partValue
			end
		end

		if shirt and pants then
			shirt.Color3 = Color3.fromRGB(255, 255, 255)
			pants.Color3 = Color3.fromRGB(255, 255, 255)
		end
	end)
end

local function showHealthChange(char, changeType, amount)
	local damageTakenGui = char:FindFirstChild("DamageTakenGui")
	
	if damageTakenGui then
		local label = damageTakenGui.HealthLabel
		
		if changeType == "Damaging" then

			if amount ~= "MISS" then
				label.Text = "-"..amount
			else
				label.Text = "MISS"
			end
			label.TextColor3 = Color3.fromRGB(255, 0, 0)
			
		
		elseif changeType == "Healing" then
			label.Text = "+"..amount
			label.TextColor3 = Color3.fromRGB(0, 255, 0)
		end
		
		label.Visible = true

		delay(1, function()
			label.Visible = false
		end)
	end
end

--Melee Attack on the server side
Signals.MeleeAttack.OnServerInvoke = function(plr, attacker, victim)
	print("PHYSICAL ATTACK")
	local gotHit = false
	
	local victimHum = victim:FindFirstChild("Humanoid")
	if victimHum then
		print("FOUND VICTIN")
		
		local battleStats = plr:WaitForChild("BattleStats")
		local currentHP = battleStats:WaitForChild("CurrentHP")
		
		local randomChance = math.random(1,10)
		if randomChance == 1 then
			print('RANDOM CHANCE')
			showHealthChange(victim, "Damaging", "MISS")
			return
				
		else
			local lowerTorso = victim:FindFirstChild("LowerTorso")
			if lowerTorso then
				local particleEffect = lowerTorso:FindFirstChild("Blood")
				if particleEffect then
					particleEffect.Enabled = true
					
					delay(0.05, function()
						particleEffect.Enabled = false
					end)
					
				end
			end
			
			changeCharColor(victim, "Really red")
			showHealthChange(victim, "Damaging", 25)
			victimHum.Health = victimHum.Health - 25
			shakeEffectEvent:FireClient(plr)
			gotHit = true
			
			if attacker:FindFirstChild("IsEnemy") then
				currentHP.Value = victimHum.Health
			end
		end
		
	end
	
	return gotHit
end


local function makePersonaVisible(personaChar)
	
	for _,part in pairs(personaChar:GetChildren()) do
		--Make Invisible parts
		if (part:IsA("MeshPart") or part:IsA("Part")) and (part.Name ~= "HumanoidRootPart") then
			
			--Make face invisible
			if part.Name == "Head" then
				local face = part:FindFirstChild("face")
				if face then
					face.Transparency = 0
				end
			end
			
			spawn(function()
				TS:Create(part, TweenInfo.new(0.25), {Transparency = 0}):Play()
			end)
		end
	end
	
	delay(2, function()
		for _,part in pairs(personaChar:GetChildren()) do
			--Make Invisible parts
			if (part:IsA("MeshPart") or part:IsA("Part")) and (part.Name ~= "HumanoidRootPart") then

				--Make face invisible
				if part.Name == "Head" then
					local face = part:FindFirstChild("face")
					if face then
						face.Transparency = 1
					end
				end

				spawn(function()
					TS:Create(part, TweenInfo.new(0.25), {Transparency = 1}):Play()
				end)
			end
		end
	end)
	
end

--Magic Attack on the server side
Signals.MagicAttack.OnServerInvoke = function(plr, attacker, victim, magicType, magicLevel, cost, effect)
	print("PHYSICAL ATTACK")
	local gotHit = false
	
	local victimHum = victim:FindFirstChild("Humanoid")
	if victimHum then
		print("FOUND VICTIN")
		
		local battleStats = plr:WaitForChild("BattleStats")
		local currentHP = battleStats:WaitForChild("CurrentHP")
		
		--Drain SP and Make Persona Visible
		if not attacker:FindFirstChild("IsEnemy") then
			print('DRAIN SP')
			local currentSP = battleStats:WaitForChild("CurrentSP")
			currentSP.Value -= cost
			
			makePersonaVisible(attacker)
		end
		
		--Create Effect
		local lowerTorso = victim:FindFirstChild("LowerTorso")
		if lowerTorso then
			
			local particleEffect = lowerTorso:FindFirstChild(effect)
			if particleEffect then
				wait(0.5)
				particleEffect.Enabled = true
				wait(1.5)
				particleEffect.Enabled = false
			end
		end
		
		--Miss Chance
		local randomChance = math.random(1,10)
		if randomChance == 1 then
			print('RANDOM CHANCE')
			showHealthChange(victim, "Damaging", "MISS")
		else --Take Damage
			local calculatedDamage
			if magicLevel == "Low" then
				calculatedDamage = math.floor(victimHum.MaxHealth / 3.5)
			elseif magicLevel == "Med" then
				calculatedDamage = math.floor(victimHum.MaxHealth / 3)
			elseif magicLevel == "High" then
				calculatedDamage = math.floor(victimHum.MaxHealth / 2)
			end
			
			changeCharColor(victim, "Cyan")
			showHealthChange(victim, "Damaging", calculatedDamage)
			victimHum.Health = victimHum.Health - calculatedDamage
			shakeEffectEvent:FireClient(plr)
			gotHit = true
			
			if not victim:FindFirstChild("IsEnemy") then
				currentHP.Value = victimHum.Health
			end
		end

	end
	
	return gotHit
end

--Melee Support on the server side
Signals.MagicSupport.OnServerInvoke = function(plr, supporter, magicType, magicLevel, cost, effect)
	local gotHealed = false
	local char = plr.Character
	
	local victimHum
	if supporter:FindFirstChild("IsEnemy") then
		victimHum = supporter:FindFirstChild("Humanoid")
	else
		victimHum = char:FindFirstChild("Humanoid")
	end
	
	if victimHum then
		
		local battleStats = plr:WaitForChild("BattleStats")
		local currentHP = battleStats:WaitForChild("CurrentHP")
		
		--Drain SP and Make Persona Visible
		if not supporter:FindFirstChild("IsEnemy") then
			print('DRAIN SP')
			local currentSP = battleStats:WaitForChild("CurrentSP")
			currentSP.Value -= cost

			makePersonaVisible(supporter)
		end
		
		--Create Effect
		local lowerTorso
		if supporter:FindFirstChild("IsEnemy") then
			lowerTorso = supporter:FindFirstChild("LowerTorso")
		else
			lowerTorso = char:FindFirstChild("LowerTorso")
		end
		
		if lowerTorso then

			local particleEffect = lowerTorso:FindFirstChild(effect)
			if particleEffect then
				wait(0.5)
				particleEffect.Enabled = true
				wait(1.5)
				particleEffect.Enabled = false
			end
		end
		
		local calculatedHealth
		if magicLevel == "Low" then
			calculatedHealth = math.floor(victimHum.MaxHealth / 3.5)
		elseif magicLevel == "Med" then
			calculatedHealth = math.floor(victimHum.MaxHealth / 3)
		elseif magicLevel == "High" then
			calculatedHealth = math.floor(victimHum.MaxHealth / 2)
		end
		
		showHealthChange(victimHum.Parent, "Healing", calculatedHealth)
		victimHum.Health = victimHum.Health + calculatedHealth
		gotHealed = true

		if not supporter:FindFirstChild("IsEnemy") then
			currentHP.Value = victimHum.Health
		end
		
	end
	
	return gotHealed
end

return nil
