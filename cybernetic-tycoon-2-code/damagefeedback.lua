--// DamageFeedback
--// Scripted By: BrawlBattle
--// Modified: 8/1/2020
--// Desc: Sends Haptic Feedback to controller when player takes damage. [XBOX USERS ONLY]

local HS = game:GetService("HapticService")
local UIS = game:GetService("UserInputService")
local isVibrateSupported = HS:IsVibrationSupported(Enum.UserInputType.Gamepad1)
local largeSupported = false

local char = script.Parent
local hum = char:FindFirstChild("Humanoid")
local currentHealth = hum.Health

if isVibrateSupported then
	largeSupported = HS:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large)
end


hum.Died:Connect(function()
	if UIS.GamepadEnabled and isVibrateSupported and largeSupported then
		HS:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, 0.5)
		wait(.35)
		HS:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, 0)
		return
	end
end)

hum.HealthChanged:Connect(function(health)
	if UIS.GamepadEnabled and isVibrateSupported and largeSupported then
	
		if currentHealth <= hum.MaxHealth and currentHealth > 0 and currentHealth > health then
			HS:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, 0.5)
			currentHealth = health
			wait(.25)
			HS:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, 0)
		end
		
	end
end)
