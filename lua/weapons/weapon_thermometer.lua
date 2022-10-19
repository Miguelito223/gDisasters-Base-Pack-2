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
SWEP.Secondary.Distance = 75 


function SWEP:Initialize()
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	ply = self:GetOwner()
	plypos = ply:GetPos()
	for k, v in pairs(ents.GetAll()) do
		if plypos:Distance(v:GetPos()) <= self.Primary.Distance then
			if v:IsPlayer() and !ply then
				temp = v.gDisasters.Body.Temperature
				ply:ChatPrint("The Temp of player: ".. v:GetName() .." Is: ".. temp)
			elseif v:IsNPC() or v:IsNextBot() then
				ply:ChatPrint("No Work With Npcs or Nextbot")
			end
		end
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	ply = self:GetOwner()
	temp = ply.gDisasters.Body.Temperature
	airtemp = GLOBAL_SYSTEM["Atmosphere"]["Temperature"]
	ply:ChatPrint("your temp is: ".. temp .."... Air Temp Is: ".. airtemp)
end

function SWEP:CanSecondaryAttack()
	return false
end

