SWEP.Author = "Miguelito"
SWEP.Base = "weapon_base"
SWEP.PrintName = "Thermomether"
SWEP.ViewModel = "models/weapons/v_hands.mdl"
SWEP.UseHands = false

SWEP.Weight = 5
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

SWEP.Slot = 0

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 0
SWEP.Primary.Delay = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Distance = 75 

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Damage = 0
SWEP.Secondary.Delay = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Distance = 100


function SWEP:Initialize()
end

function SWEP:PrimaryAttack()
	if (CLIENT) then return end
	local ply = self:GetOwner()
	local pressure =  math.Round(GLOBAL_SYSTEM["Atmosphere"]["Pressure"])
	PrintMessage(HUD_PRINTCENTER,"Pressure is: " .. pressure .. "Pa")
end

function SWEP:SecondaryAttack()
	if (CLIENT) then return end
	local ply = self:GetOwner()
	local pressure = math.Round(GLOBAL_SYSTEM["Atmosphere"]["Pressure"])
	
	if pressure <= 100000 then
		PrintMessage(HUD_PRINTCENTER,"Is Partly Cloudy")
	elseif pressure <= 98000 then
		PrintMessage(HUD_PRINTCENTER,"Is Light Raining")
	elseif pressure => 102000 then
		PrintMessage(HUD_PRINTCENTER,"Is Very Sunny")
	elseif pressure <= 96000 then
		PrintMessage(HUD_PRINTCENTER,"Is Raining")
	elseif pressure <= 94000 then
		PrintMessage(HUD_PRINTCENTER,"Is Storm")
	elseif pressure => 104000 then
		PrintMessage(HUD_PRINTCENTER,"Is Heavy Sunny")
	elseif pressure => 106000 then
		PrintMessage(HUD_PRINTCENTER,"Is Extreme Heavy Sunny (Very Hot)")
	else
		PrintMessage(HUD_PRINTCENTER,"IDK")
	end
end

