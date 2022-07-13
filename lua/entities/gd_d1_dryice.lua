AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Dry Ice (beta)"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"


ENT.Mass                             =  100
ENT.Model                           = "models/ramses/models/nature/blockofice.mdl"

    

function ENT:Initialize()	
    
	local bool self.isNotSubmerged = true
    local bool self.isFeetSubmerged = false
	local bool self.isWaistSubmerged = false
	local bool self.isCompletlySubmerged = false
	
	local bool self.hasActivatedLowFog = false
	local bool self.hasActivatedMedFog = false
	local bool self.hasActivatedExplosion = false
	
	self.SpawnTime = CurTime()
	
	game.AddParticles("particles/dry_ice.pcf");
	PrecacheParticleSystem( "dryice_lowfog_crawler" )
	PrecacheParticleSystem( "dryice_medfog_crawler" )
	PrecacheParticleSystem( "dryice_deepfog_crawler" )
	PrecacheParticleSystem( "dryice_fog_explosion" )
	
	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:EnableMotion(true)
			
		end
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		
		timer.Simple(120, function() if !self:IsValid() then return end self:Remove() end)
		
	end
end

function ENT:SetMDScale(scale)
	local mat = Matrix()
	mat:Scale(scale)
	self:EnableMatrix("RenderMultiply", mat)
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal    ) 
	ent:Spawn()
	ent:Activate()
	return ent
end




function ENT:Shrink()
	self:SetMDScale(Vector(1,1,1) * math.Clamp( 0.5-( (CurTime() - self.SpawnTime)/120), 0,1))
	
end


function ENT:Think()
	if (CLIENT) then
		self:Shrink()
	end

	if (SERVER) then
		if !self:IsValid() then return end

		
		self:NextThink(CurTime() + 1)
		return true
	end
	
	-- Water Detection Stuff
	if(self:WaterLevel() == 0) then -- if not submerged 
	self.isNotSubmerged = true;
	self.isCompletlySubmerged = false;
	self.isWaistSubmerged = false;
	self.isFeetSubmerged = false;
	end
	
	if(self:WaterLevel() == 1) then --if feet submerged 
	self.isNotSubmerged = false;
	self.isCompletlySubmerged = false;
	self.isWaistSubmerged = false;
	self.isFeetSubmerged = true;
	end
	
	if(self:WaterLevel() == 2) then --if waist submerged 
	self.isNotSubmerged = false;
	self.isCompletlySubmerged = false;
	self.isWaistSubmerged = true;
	self.isFeetSubmerged = false;
	end
	
	if(self:WaterLevel() == 3) then --if completly submerged 
	self.isNotSubmerged = false;
	self.isCompletlySubmerged = true;
	self.isWaistSubmerged = false;
	self.isFeetSubmerged = false;
	end
	
	
	-- Particle Stuff
	if(self.isFeetSubmerged && !self.hasActivatedLowFog) then  --spawn low fog
	ParticleEffectAttach("dryice_lowfog_crawler", PATTACH_POINT_FOLLOW, self, 2)
	self:StopParticlesNamed("dryice_medfog_crawler")
	self:StopParticlesNamed("dryice_deepfog_crawler")
	self:StopParticlesNamed("dryice_fog_explosion")
	self.hasActivatedLowFog = true
	end
	
	if(self.isWaistSubmerged && !self.hasActivatedMedFog) then --spawn medium fog
	ParticleEffectAttach("dryice_medfog_crawler", PATTACH_POINT_FOLLOW, self, 2)
	self:StopParticlesNamed("dryice_lowfog_crawler")
	self:StopParticlesNamed("dryice_deepfog_crawler")
	self:StopParticlesNamed("dryice_fog_explosion")
	self.hasActivatedMedFog = true
	end
	
	if(self.isCompletlySubmerged && !self.hasActivatedExplosion) then --explode
	ParticleEffectAttach("dryice_deepfog_crawler", PATTACH_POINT_FOLLOW, self, 2)
	ParticleEffectAttach("dryice_fog_explosion", PATTACH_POINT_FOLLOW, self, 2)
	self:StopParticlesNamed("dryice_medfog_crawler")
	self:StopParticlesNamed("dryice_lowfog_crawler")
	self.hasActivatedExplosion = true
	
	end
	
end

function ENT:OnRemove()
end

function ENT:Draw()



	self:DrawModel()
	
end




