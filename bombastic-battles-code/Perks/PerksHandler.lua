--// PerksHandler
--// Scripted by: BrawlBattle
--// Desc: Handles player perks when thrown into a match.

local TS = game:GetService("TweenService")

local RS = game:GetService("ReplicatedStorage")

local skinsDictionary = require(RS:WaitForChild("DataModules"):WaitForChild("ShopData"):WaitForChild('SkinsDictionary'))

local SS = game:GetService("ServerStorage")

local DS2 = require(SS:WaitForChild("DataStore2"))
local shopAssets = SS:WaitForChild("Assets"):WaitForChild("ShopAssets")

local perks = shopAssets:WaitForChild("Perks")

local Signals     = {} do 
	for _, Signal in pairs(script.signals:GetChildren()) do
		Signals[Signal.Name] = Signal.Value
	end
end

Signals.CheckPlayerOwnsPerk.OnInvoke = function(plr, id)
	local ownsPerk = false

	local equippedStats = plr:WaitForChild("EquippedStats")
	local skinValue = equippedStats:WaitForChild("EquippedPerk")
	local inventory = DS2("Inventory", plr):Get({0,1,2,3,4,5})
	
	if (skinValue.Value == id) and (table.find(inventory, skinValue.Value)) then
	--if (skinValue.Value == id) then
		ownsPerk = true
	end

	return ownsPerk
end

Signals.PlaceTrap.OnServerEvent:Connect(function(plr, char)
	local trap = perks:FindFirstChild("Trap")
	if trap then
		local clonedTrap = trap:Clone()
		clonedTrap.Trap.Placer.Value = plr
		clonedTrap.Parent = workspace.CurrentMap
		
		--Position it in front of player
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local newCFrame = hrp.CFrame * CFrame.new(0,-2.1,0)
			clonedTrap:SetPrimaryPartCFrame(newCFrame)
		end
		
		clonedTrap.Trap.Attack.Disabled = false
	end
end)


--Hyper Bomb Perk
Signals.HyperThrow.Event:Connect(function(Char, Bomb, TargetPos)
	--Get direct player mouse and position the bomb at the mouse
	local origPos = Bomb.Position
	local distance = (TargetPos - origPos).unit * 1000
	local result = workspace:Raycast(origPos, distance)
	
	--Create a laser from bomb to player mouse pos
	local laser = perks.Laser
	local clonedLaser = laser:Clone()
	clonedLaser.Parent = workspace.CurrentMap
	
	--Position and Scale the cloned laser accordingly
	local midPoint = origPos + distance/2
	clonedLaser.CFrame = CFrame.new(midPoint, origPos)
	clonedLaser.Size = Vector3.new(.5, .5, distance.magnitude)
	
	--Play laser sound
	local throwSound = Bomb.HyperThrow:Clone()
	throwSound.Parent = Char.UpperTorso
	throwSound:Play()
	game.Debris:AddItem(throwSound, 1.1)
	
	Bomb.CFrame = CFrame.new(TargetPos)
	
	--Fade laser away
	wait(1)
	local tween = TS:Create(clonedLaser, TweenInfo.new(1), {Transparency = 1})
	tween:Play()
	tween.Completed:Wait()
	clonedLaser:Destroy()
end)

return nil
