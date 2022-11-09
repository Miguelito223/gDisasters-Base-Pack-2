SWEP.Author = "Miguelito"
SWEP.Base = "weapon_base"
SWEP.PrintName = "Anemometer"
SWEP.ViewModel = "models/weapons/v_hands.mdl"
SWEP.UseHands = false

SWEP.Weight = 5
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

SWEP.Slot = 0

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Category 			= "gDisasters - Measurer"

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
	if CLIENT then return end
	local ply = self:GetOwner()
	local wind_speed = math.Round(GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"],1)
	ply:PrintMessage(HUD_PRINTCENTER,"The global wind velocity is: " .. wind_speed .. " Km/h")
end

function SWEP:SecondaryAttack()
	local ply = self:GetOwner()
	local local_wind_speed = math.Round(ply:GetNWFloat("LocalWind"),1)
	ply:PrintMessage(HUD_PRINTCENTER,"The local wind velocity is: " .. local_wind_speed .. " Km/h")
end
