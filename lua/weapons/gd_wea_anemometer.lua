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

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Category 			= "gDisasters - Measurer"

SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 0
SWEP.Primary.Delay = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Distance = 100

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
	local local_wind_speed = math.Round(ply:GetNWFloat("LocalWind"),1)
	ply:PrintMessage(HUD_PRINTCENTER, "Your local wind velocity is: " .. local_wind_speed .. " Km/h, The global wind velocity is: " .. wind_speed .. " Km/h")
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	local ply = self:GetOwner()
	local plypos = ply:GetPos()
	for k, v in pairs(ents.GetAll()) do
		if plypos:Distance(v:GetPos()) <= self.Secondary.Distance then
			if v != ply then
				if v:IsPlayer() then
					local local_wind_speed = math.Round(v:GetNWFloat("LocalWind"),1)
					ply:PrintMessage(HUD_PRINTCENTER,"The Local Wind of player ".. v:GetName() .." Is: ".. local_wind_speed .." Km/h")
				elseif v:IsNPC() or v:IsNextBot() then
					ply:PrintMessage(HUD_PRINTCENTER, "No Work With Npcs or Nextbot")
				end
			end
		end
	end
end
