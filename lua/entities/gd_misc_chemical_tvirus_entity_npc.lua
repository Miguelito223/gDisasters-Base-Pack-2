AddCSLuaFile()

DEFINE_BASECLASS( "gd_misc_nuclear_fission_rad_base" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "T-Virus"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

sound.Add( {
	name = "tvirus",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {100, 100},
	sound = "streams/others/tvirus_infection/ply_infection.mp3"
} )

ZombieList={}
ZombieList[1]="npc_zombie"
ZombieList[2]="npc_fastzombie"
ZombieList[3]="npc_poisonzombie"

ZombieList2={}
ZombieList2[1]="npc_vj_nmrih_walkmalez"
ZombieList2[2]="npc_vj_nmrih_walkfemalez"
ZombieList2[3]="npc_vj_nmrih_runmalez"
ZombieList2[4]="npc_vj_nmrih_runfemalez"

function ENT:Initialize()
	 if (SERVER) then
		 self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
		 self:SetSolid( SOLID_NONE )
		 self:SetMoveType( MOVETYPE_NONE )
		 self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.infected = self:GetVar("infected")
		 self.R = 255
		 self.G = 255
		 self.B = 255	
		 self.playsound=1
		 
	 end
end


function ENT:Think()	
	if (SERVER) then
	if not self:IsValid() then return end
	if not self.infected:IsValid() then -- doesnt fucking work
		self:Remove()
	end
	if not self.infected:IsValid() then return end
	self.R = self.R-0.15
	self.G = self.G-0.2
	self.B = self.B-0.2
	self.infected:SetColor(Color(self.R,self.G,self.B,255))
	pos = string.Explode( " ", tostring(self.infected:GetPos()) )
	self:SetPos(Vector(pos[1],pos[2],pos[3]))
	self.Bursts = self.Bursts + 1
	for k, v in pairs(ents.FindInSphere(self:GetPos(),100)) do
		if v:IsPlayer() and v:Alive() and not v.isinfected then
			if v.gasmasked==false and v.hazsuited==false then
				local ent = ents.Create("gd_misc_chemical_tvirus_entity")
				ent:SetVar("infected", v)
				ent:SetPos( self:GetPos() ) 
				ent:Spawn()
				ent:Activate()
				v.isinfected = true
				ParticleEffectAttach("zombie_blood",PATTACH_ABSORIGIN_FOLLOW,v, 1) 
			end
		end
		if (v:IsNPC() and table.HasValue(npc_tvirus,v:GetClass()) and not v.isinfected) or (v.IsVJHuman==true and not v.isinfected) then
			if v.gasmasked==false or v.hazsuited==false then return end
			local ent = ents.Create("gd_misc_chemical_tvirus_entity_npc")
			ent:SetVar("infected", v)
			ent:SetPos( self:GetPos() ) 
			ent:Spawn()
			ent:Activate()
			v.isinfected = true
			ParticleEffectAttach("zombie_blood",PATTACH_ABSORIGIN_FOLLOW,v, 1) 
		end	
	end
	if (self.Bursts >= 1140) and (self.playsound==1) then 
		if not self:IsValid() then return end
		self.playsound=0
		self.infected:EmitSound("streams/others/tvirus_infection/ply_infection_final.mp3")
	end
	if (self.Bursts >= 1200) then -- Zombie time hehe
		if not self:IsValid() then return end
		if (file.Exists( "lua/autorun/vj_nmrih_autorun.lua", "GAME" )) and GetConVar("gd_nmrih_zombies"):GetInt()== 1 then
			local ent = ents.Create(table.Random(ZombieList2)) -- This creates our zombie entity
			ent:SetPos(self.infected:GetPos())
			ent:Spawn() 
			if GetConVar("gd_zombie_strength"):GetInt() == 0 then
				ent:SetHealth(500)
			elseif GetConVar("gd_zombie_strength"):GetInt() == 1 then
				ent:SetHealth(1000)
			elseif GetConVar("gd_zombie_strength"):GetInt() == 2 then
				ent:SetHealth(2000)
			elseif GetConVar("gd_zombie_strength"):GetInt() == -1 then
				ent:SetHealth(250)
			elseif GetConVar("gd_zombie_strength"):GetInt() == -2 then
				ent:SetHealth(175)
			else
				ent:SetHealth(500)
			end
			local z_ent = ents.Create("gd_misc_chemical_tvirus_entity_z")
			z_ent:SetVar("zombie", ent)
			z_ent:SetPos( ent:GetPos() ) 
			z_ent:Spawn()
			z_ent:Activate()
			
			self.infected:SetNWBool("Clear_HUD", true)
			self.infected:Kill()
			self:Remove()
		else
			local ent = ents.Create(table.Random(ZombieList)) -- This creates our zombie entity
			ent:SetPos(self.infected:GetPos())
			ent:Spawn() 
			if GetConVar("gd_zombie_strength"):GetInt() == 0 then
				ent:SetHealth(500)
			elseif GetConVar("gd_zombie_strength"):GetInt() == 1 then
				ent:SetHealth(1000)
			elseif GetConVar("gd_zombie_strength"):GetInt() == 2 then
				ent:SetHealth(2000)
			elseif GetConVar("gd_zombie_strength"):GetInt() == -1 then
				ent:SetHealth(250)
			elseif GetConVar("gd_zombie_strength"):GetInt() == -2 then
				ent:SetHealth(175)
			else
				ent:SetHealth(500)
			end
			local z_ent = ents.Create("gd_chemical_tvirus_entity_z")
			z_ent:SetVar("zombie", ent)
			z_ent:SetPos( ent:GetPos() ) 
			z_ent:Spawn()
			z_ent:Activate()
			
			self.infected:SetNWBool("Clear_HUD", true)
			self.infected:Remove()
			self:Remove()
		end
    end		
	self:NextThink(CurTime() + 0.1)
	return true
	end
end

if (SERVER) then
	function ENT:OnRemove()
		if not self.diedfromtime then
			if (file.Exists( "lua/autorun/vj_nmrih_autorun.lua", "GAME" )) and GetConVar("gd_nmrih_zombies"):GetInt()== 1 then
			local ent = ents.Create(table.Random(ZombieList2)) -- This creates our zombie entity
			ent:SetPos(self:GetPos())
			ent:Spawn() 
			if GetConVar("gd_zombie_strength"):GetInt() == 0 then
				ent:SetHealth(500)
			elseif GetConVar("gd_zombie_strength"):GetInt() == 1 then
				ent:SetHealth(1000)
			elseif GetConVar("gd_zombie_strength"):GetInt() == 2 then
				ent:SetHealth(2000)
			elseif GetConVar("gd_zombie_strength"):GetInt() == -1 then
				ent:SetHealth(250)
			elseif GetConVar("gd_zombie_strength"):GetInt() == -2 then
				ent:SetHealth(175)
			else
				ent:SetHealth(500)
			end
			local z_ent = ents.Create("gd_chemical_tvirus_entity_z")
			z_ent:SetVar("zombie", ent)
			z_ent:SetPos( ent:GetPos() ) 
			z_ent:Spawn()
			z_ent:Activate()
			
			self.infected:SetNWBool("Clear_HUD", true)
			self:Remove()
		else
			if math.random(1,25)~=25 then
				local ent = ents.Create(table.Random(ZombieList)) -- This creates our zombie entity
				ent:SetPos(self:GetPos())
				ent:Spawn() 
				if GetConVar("gd_zombie_strength"):GetInt() == 0 then
					ent:SetHealth(500)
				elseif GetConVar("gd_zombie_strength"):GetInt() == 1 then
					ent:SetHealth(1000)
				elseif GetConVar("gd_zombie_strength"):GetInt() == 2 then
					ent:SetHealth(2000)
				elseif GetConVar("gd_zombie_strength"):GetInt() == -1 then
					ent:SetHealth(250)
				elseif GetConVar("gd_zombie_strength"):GetInt() == -2 then
					ent:SetHealth(175)
				else
					ent:SetHealth(500)
				end
				local z_ent = ents.Create("gd_misc_chemical_tvirus_entity_z")
				z_ent:SetVar("zombie", ent)
				z_ent:SetPos( ent:GetPos() ) 
				z_ent:Spawn()
				z_ent:Activate()
				

				self:Remove()
			else
				for k, v in pairs(player.GetAll()) do
					v:ChatPrint("Rare zombie boss has spawned somewherenot ")
				end
				local ent = ents.Create(table.Random(ZombieList)) -- This creates our zombie entity
				ent:SetPos(self:GetPos())
				ent:Spawn() 
				ent:SetHealth(10000)
				ent:SetModelScale(ent:GetModelScale()*2)
				local z_ent = ents.Create("gd_misc_chemical_tvirus_entity_z")
				z_ent:SetVar("zombie", ent)
				z_ent:SetPos( ent:GetPos() ) 
				z_ent:Spawn()
				z_ent:Activate()
			end
			end
		end
		if not self.infected:IsValid() then return end
		local infected_player = self.infected
		infected_player:StopParticles()
	end
end

function ENT:Draw()
     return false
end

