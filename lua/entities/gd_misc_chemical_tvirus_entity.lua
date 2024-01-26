AddCSLuaFile()

DEFINE_BASECLASS( "gd_nuclear_fission_rad_base" )

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
sound.Add( {
	name = "tvirus_symptom",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {100, 100},
	sound = "streams/others/tvirus_infection/ply_intro_infection.mp3"
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
		 self.Seconds=0



	 end
end



function ENT:MovePlayerSpeed()
	if not self.infected:Alive() then return end
	self.infected:SetRunSpeed( math.Clamp((500/137) * (137-self.Seconds),0,500))
	self.infected:SetWalkSpeed( math.Clamp((250/137) * (137-self.Seconds),0,250))
end

function ENT:FollowInfected()
	self:SetPos(self.infected:GetPos())
end

function ENT:Think()	

	if (SERVER) then
	if not self:IsValid() then return end
	if not self.infected:IsValid() then -- doesnt fucking work
		self:Remove()
	end
	
	self.Seconds = self.Seconds+1/(1/engine.TickInterval())
	
	self:MovePlayerSpeed()
	self:FollowInfected()
	
	net.Start("gd_net_tvirus")
	net.WriteTable({["IsDead"]=false,["Seconds"]=self.Seconds,["Infected"]=self.infected,["IsDead"]=false})
	net.Send(self.infected)
	
	for k, v in pairs(ents.FindInSphere(self:GetPos(),100)) do
		if v:IsPlayer() and v:Alive() and not v.isinfected then
			local ent = ents.Create("gd_misc_chemical_tvirus_entity")
			ent:SetVar("infected", v)
			ent:SetPos( self:GetPos() ) 
			ent:Spawn()
			ent:Activate()
			v.isinfected = true
			ParticleEffectAttach("zombie_blood",PATTACH_ABSORIGIN_FOLLOW,v, 1) 
		end
		if (v:IsNPC() and table.HasValue(npc_tvirus,v:GetClass()) and not v.isinfected) or (v.IsVJHuman==true and not v.isinfected) then
			if v.gasmasked==false and v.hazsuited==false then
				local ent = ents.Create("gd_misc_chemical_tvirus_entity_npc")
				ent:SetVar("infected", v)
				ent:SetPos( self:GetPos() ) 
				ent:Spawn()
				ent:Activate()
				v.isinfected = true
				ParticleEffectAttach("zombie_blood",PATTACH_ABSORIGIN_FOLLOW,v, 1) 
			end
		end	
	end
	if (self.Seconds >= 123) and (self.playsound==1) then 
		self.infected:EmitSound("streams/others/tvirus_infection/ply_infection_final.mp3")
	end
	if (self.Seconds >= 130) then -- Zombie time hehe
		if not self:IsValid() then return end
		if (file.Exists( "lua/autorun/vj_nmrih_autorun.lua", "GAME" )) and GetConVar("gdisasters_tvirus_nmrih_zombies"):GetInt()== 1 then
			local ent = ents.Create(table.Random(ZombieList2)) -- This creates our zombie entity
			ent:SetPos(self.infected:GetPos())
			ent:Spawn() 
			if GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == 0 then
				ent:SetHealth(500)
			elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == 1 then
				ent:SetHealth(1000)
			elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == 2 then
				ent:SetHealth(2000)
			elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == -1 then
				ent:SetHealth(250)
			elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == -2 then
				ent:SetHealth(175)
			else
				ent:SetHealth(500)
			end
			local z_ent = ents.Create("gd_misc_chemical_tvirus_entity_z")
			z_ent:SetVar("zombie", ent)
			z_ent:SetPos( ent:GetPos() ) 
			z_ent:Spawn()
			z_ent:Activate()
			

			self.infected:Kill()
			self:Remove()
		else
			if math.random(1,100)~=100 then
				local ent = ents.Create(table.Random(ZombieList)) -- This creates our zombie entity
				ent:SetPos(self.infected:GetPos())
				ent:Spawn() 
				if GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == 0 then
					ent:SetHealth(500)
				elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == 1 then
					ent:SetHealth(1000)
				elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == 2 then
					ent:SetHealth(2000)
				elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == -1 then
					ent:SetHealth(250)
				elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == -2 then
					ent:SetHealth(175)
				else
					ent:SetHealth(500)
				end
				local z_ent = ents.Create("gd_misc_chemical_tvirus_entity_z")
				z_ent:SetVar("zombie", ent)
				z_ent:SetPos( ent:GetPos() ) 
				z_ent:Spawn()
				z_ent:Activate()
				
				

				self.infected:Kill()
				self:Remove()
				
			else

			
				local ent = ents.Create(table.Random(ZombieList)) -- This creates our zombie entity
				ent:SetPos(self.infected:GetPos())
				ent:Spawn() 
				ent:SetHealth(10000)
				ent:SetModelScale(ent:GetModelScale()*4)
				local z_ent = ents.Create("gd_misc_chemical_tvirus_entity_z")
				z_ent:SetVar("zombie", ent)
				z_ent:SetPos( ent:GetPos() ) 
				z_ent:Spawn()
				z_ent:Activate()
				
				
	
				self.infected:Kill()
				self:Remove()			
			end
		end
    end		
		
	if not self.infected:Alive() or not self.infected:IsValid() then

		if (file.Exists( "lua/autorun/vj_nmrih_autorun.lua", "GAME" )) and GetConVar("gdisasters_tvirus_nmrih_zombies"):GetInt()== 1 then
			local ent = ents.Create(table.Random(ZombieList2)) -- This creates our zombie entity
			ent:SetPos(self.infected:GetPos())
			ent:Spawn() 
			if GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == 0 then
				ent:SetHealth(500)
			elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == 1 then
				ent:SetHealth(1000)
			elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == 2 then
				ent:SetHealth(2000)
			elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == -1 then
				ent:SetHealth(250)
			elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == -2 then
				ent:SetHealth(175)
			else
				ent:SetHealth(500)
			end
			local z_ent = ents.Create("gd_misc_chemical_tvirus_entity_z")
			z_ent:SetVar("zombie", ent)
			z_ent:SetPos( ent:GetPos() ) 
			z_ent:Spawn()
			z_ent:Activate()
			

			self.infected:Kill()
			self:Remove()
		else
			if math.random(1,25)~=25 then
			
				local ent = ents.Create(table.Random(ZombieList)) -- This creates our zombie entity
				ent:SetPos(self.infected:GetPos())
				ent:Spawn() 
				if GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == 0 then
					ent:SetHealth(500)
				elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == 1 then
					ent:SetHealth(1000)
				elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == 2 then
					ent:SetHealth(2000)
				elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == -1 then
					ent:SetHealth(250)
				elseif GetConVar("gdisasters_tvirus_zombie_strength"):GetInt() == -2 then
					ent:SetHealth(175)
				else
					ent:SetHealth(500)
				end
				local z_ent = ents.Create("gd_misc_chemical_tvirus_entity_z")
				z_ent:SetVar("zombie", ent)
				z_ent:SetPos( ent:GetPos() ) 
				z_ent:Spawn()
				z_ent:Activate()
				
				

				self.infected:Kill()
				self:Remove()
				
			else

				for k, v in pairs(player.GetAll()) do
					v:ChatPrint("Zombie boss has spawnednot ")
				end
				local ent = ents.Create(table.Random(ZombieList)) -- This creates our zombie entity
				ent:SetPos(self.infected:GetPos())
				ent:Spawn() 
				ent:SetHealth(10000)
				ent:SetModelScale(ent:GetModelScale()*2)
				ent.IsBoss=true
				
				local z_ent = ents.Create("gd_misc_chemical_tvirus_entity_z")
				z_ent:SetVar("zombie", ent)
				z_ent:SetPos( ent:GetPos() ) 
				z_ent:Spawn()
				z_ent:Activate()
				
				

				self.infected:Kill()
				self:Remove()			
			end
		end
	end
	
	self:NextThink(CurTime() + 0.01)
	return true
	end
end

if (SERVER) then
	function ENT:OnRemove()
		if not self.infected:IsValid() then return end
		local infected_player = self.infected
		infected_player.isinfected = false

		self.infected:SetRunSpeed(500)
		self.infected:SetWalkSpeed(250)
		infected_player:StopParticles()
		infected_player:SetColor(Color(255,255,255))
		
		net.Start("gd_net_tvirus")
		net.WriteTable({["IsDead"]=false,["Seconds"]=self.Seconds,["Infected"]=self.infected,["IsDead"]=true})
		net.Send(self.infected)
	end
end


if (CLIENT) then
	function ENT:OnRemove()
	end
end

function ENT:Draw()
     return false
end

