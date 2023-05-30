AddCSLuaFile()

DEFINE_BASECLASS( "gd_base_advanced" )

local ExploSnds = {}
ExploSnds[1]                         =  "ambient/explosions/explode_1.wav"
ExploSnds[2]                         =  "ambient/explosions/explode_2.wav"
ExploSnds[3]                         =  "ambient/explosions/explode_3.wav"
ExploSnds[4]                         =  "ambient/explosions/explode_4.wav"
ExploSnds[5]                         =  "ambient/explosions/explode_5.wav"
ExploSnds[6]                         =  "npc/env_headcrabcanister/explosion.wav"

ENT.Spawnable		            	 =  false         
ENT.AdminSpawnable		             =  false 

ENT.PrintName		                 =  "T-Virus"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Chemical"

ENT.Model                            =  "models/ramses/models/thedoctor/t_virus.mdl"                      
ENT.Effect                           =  "vx_gas"                  
ENT.EffectAir                        =  "vx_gas_ground"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "streams/others/explosions/nuclear/blast_wave.mp3"
ENT.ArmSound                         =  ""            
ENT.ActivationSound                  =  ""     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  25
ENT.PhysForce                        =  600
ENT.ExplosionRadius                  =  1
ENT.SpecialRadius                    =  575
ENT.MaxIgnitionTime                  =  0 
ENT.Life                             =  20                                  
ENT.MaxDelay                         =  1                               
ENT.TraceLength                      =  300
ENT.ImpactSpeed                      =  200
ENT.Mass                             =  25
ENT.ArmDelay                         =  1   
ENT.Timer                            =  0

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:Initialize()
 if (SERVER) then
     self:LoadModel()
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) 
	 local phys = self:GetPhysicsObject()
	 local skincount = self:SkinCount()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end
	 if (skincount > 0) then
	     self:SetSkin(math.random(0,skincount))
	 end
	 self.Armed    = true
	 self.Exploded = false
	 self.Used     = false
	 self.Arming   = false
	  if not (WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
	end
end

function ENT:Explode()
	sound.Play("physics/glass/glass_bottle_break1.wav", self:GetPos(), 100, 100, 1)
	for k, v in pairs(ents.FindInSphere(self:GetPos(),100)) do
		if (v:IsPlayer() and v:Alive() and not v.isinfected) then
			if v.gasmasked==false and v.hazsuited==false then
				local ent = ents.Create("gd_misc_chemical_tvirus_entity")
				ent:SetVar("infected", v)
				ent:SetPos( self:GetPos() ) 
				ent:Spawn()
				ent:Activate()
				v.isinfected = true
				ParticleEffectAttach("zombie_blood",PATTACH_POINT_FOLLOW,v,0 ) 
			end
			
		end
		
		if (v:IsNPC() and table.HasValue(npc_tvirus,v:GetClass()) and not v.isinfected) or (v.IsVJHuman==true and not v.isinfected) then
			local ent = ents.Create("gd_misc_chemical_tvirus_entity_npc")
			ent:SetVar("infected", v)
			ent:SetPos( self:GetPos() ) 
			ent:Spawn()
			ent:Activate()
			v.isinfected = true
			ParticleEffectAttach("zombie_blood",PATTACH_ABSORIGIN_FOLLOW,v, 1) 
		end	
	end
	
	local ent = ents.Create("gd_misc_chemical_tvirus_field")
	ent:SetPos( self:GetPos() ) 
	ent:Spawn()
	ent:Activate()
	self:Remove()
end

function ENT:SpawnFunction( ply, tr )
     if ( not tr.Hit ) then return end
     local ent = ents.Create( self.ClassName )
     ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 26 ) 
     ent:Spawn()
     ent:Activate()
     return ent
end