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
	local plypos = ply:GetPos()
	for k, v in pairs(ents.GetAll()) do
		if plypos:Distance(v:GetPos()) <= self.Primary.Distance then
			if v != ply then
				if v:IsPlayer() then
					temp = math.Round(v.gDisasters.Body.Temperature,1)
					ply:PrintMessage(HUD_PRINTCENTER,"The Temp of player ".. v:GetName() .." Is: ".. temp .."°C")
				elseif v:IsNPC() or v:IsNextBot() then
					ply:PrintMessage(HUD_PRINTCENTER, "No Work With Npcs or Nextbot")
				end
			end
		end
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	local ply = self:GetOwner()
	local temp = math.Round(ply.gDisasters.Body.Temperature,1)
	local airtemp = math.Round(GLOBAL_SYSTEM["Atmosphere"]["Temperature"],1)
	ply:PrintMessage(HUD_PRINTCENTER,"your temp is: ".. temp .."°C / Air Temp Is: ".. airtemp .."°C")
end
