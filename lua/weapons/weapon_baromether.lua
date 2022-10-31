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

end

function SWEP:CanSecondaryAttack()
	return false
end

