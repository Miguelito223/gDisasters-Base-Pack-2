SWEP.Author = "Miguelito"
SWEP.Base = "weapon_base"
SWEP.PrintName = "Baromemether"
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
	local ply = self:GetOwner()
	local pressure =  math.Round(GLOBAL_SYSTEM["Atmosphere"]["Pressure"])
	ply:PrintMessage(HUD_PRINTCENTER,"Pressure is: " .. pressure .. "Pa")
end

function SWEP:SecondaryAttack()
	local ply = self:GetOwner()
	local pressure = math.Round(GLOBAL_SYSTEM["Atmosphere"]["Pressure"])
	
	if pressure <= 100000 and pressure > 98000 then
		ply:PrintMessage(HUD_PRINTCENTER,"Is Partly Cloudy")
	elseif pressure <= 98000 and pressure > 96000 then
		ply:PrintMessage(HUD_PRINTCENTER,"Is Light Rain/Snow")
	elseif pressure <= 96000 and pressure > 94000 then
		ply:PrintMessage(HUD_PRINTCENTER,"Is Heavy Rain/Snow")
	elseif pressure <= 94000 and pressure > 92000 then
		ply:PrintMessage(HUD_PRINTCENTER,"Is Extreme Rain/Snow")
	elseif pressure <= 92000 then
		ply:PrintMessage(HUD_PRINTCENTER,"Is Thunder Storm")
	elseif pressure >= 100001 and pressure < 102000 then
		ply:PrintMessage(HUD_PRINTCENTER,"Is Sunny")
	elseif pressure >= 102000 and pressure < 104000 then
		ply:PrintMessage(HUD_PRINTCENTER,"Is Very Sunny")
	elseif pressure >= 104000 and pressure < 106000 then
		ply:PrintMessage(HUD_PRINTCENTER,"Is Heavy Sunny")
	elseif pressure >= 106000 then
		ply:PrintMessage(HUD_PRINTCENTER,"Is Extreme Heavy Sunny (Very Hot)")
	else
		ply:PrintMessage(HUD_PRINTCENTER,"IDK")
	end
end

