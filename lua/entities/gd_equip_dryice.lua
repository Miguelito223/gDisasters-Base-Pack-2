AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Dry Ice"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"


ENT.Mass                             =  10
ENT.Model                           = "models/ramses/models/nature/blockofice.mdl"

    

function ENT:Initialize()	
    
	local bool self.isnotinwater = true
    local bool self.isinwater = false
	local bool self.isunderwater = false
	
	self.SpawnTime = CurTime()
	
	game.AddParticles("particles/dry_ice.pcf");
	PrecacheParticleSystem( "dryice_lowfog_crawler" )
	PrecacheParticleSystem( "dryice_medfog_crawler" )
	PrecacheParticleSystem( "dryice_deepfog_crawler" )
	PrecacheParticleSystem( "dryice_fog_explosion" )
	PrecacheParticleSystem( "dryice_melting" )
	
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
			phys:SetBuoyancyRatio(100)
			
		end
		
		ParticleEffectAttach("dryice_melting", PATTACH_POINT_FOLLOW, self, 0)
		
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

function ENT:vfire()
	for k, v in pairs(ents.GetAll()) do
		
		local p1, p2 = self:GetPos(), v:GetPos()
		local r = p1:Distance(p2)
		
		if vFireInstalled then
			if v:IsOnFire() and r <= 10 and v:IsValid() then
				v:Extinguish()
			end
		else
			if v:IsOnFire() and r <= 10 and v:IsValid() then
				v:Extinguish()
			end
		end
	end
end


function ENT:Shrink()
	self:SetModelScale(1 * math.Clamp( 0.5-( (CurTime() - self.SpawnTime)/120), 0,1))
	
end


function ENT:Think()
	self:Shrink()

	if (SERVER) then
		if !self:IsValid() then return end
		self:vfire()
		
		self:NextThink(CurTime() + 1)
		return true
	end
	
	if isinWater(self) == nil then return end

	if isinWater(self) == false then
		self.isnotinwater = true;
		self.isinwater = false;
		self.isunderwater = false;
	end
	
	if isinWater(self) == true then 
		self.isnotinwater = false;
		self.isinwater = true;
		self.isunderwater = false;
	end

	if isUnderWater(self) == true then 
		self.isnotinwater = false;
		self.isinwater = true;
		self.isunderwater = true;
	end
	
	
	-- Particle Stuff
	if (self.isinwater && !self.hasActivatedLowFog) then  --spawn low fog
		ParticleEffectAttach("dryice_lowfog_crawler", PATTACH_POINT_FOLLOW, self, 2)
		self:StopParticlesNamed("dryice_medfog_crawler")
		self:StopParticlesNamed("dryice_deepfog_crawler")
		self:StopParticlesNamed("dryice_fog_explosion")
		self.hasActivatedLowFog = true
	end
	
	if (self.isinwater  && !self.hasActivatedMedFog) then --spawn medium fog
		ParticleEffectAttach("dryice_medfog_crawler", PATTACH_POINT_FOLLOW, self, 2)
		self:StopParticlesNamed("dryice_lowfog_crawler")
		self:StopParticlesNamed("dryice_deepfog_crawler")
		self:StopParticlesNamed("dryice_fog_explosion")
		self.hasActivatedMedFog = true
	end
	
	if (self.isunderwater && !self.hasActivatedExplosion) then --explode
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




