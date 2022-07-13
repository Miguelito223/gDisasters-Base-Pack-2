AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Rainbow"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
    
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"


function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		
		ParticleEffectAttach("rainbow_main", PATTACH_POINT_FOLLOW, self, 0)
		self:SetAngles(Angle(255,90,255))
		if math.random(1,3) == 1 then
			ParticleEffectAttach("rainbow_larger", PATTACH_POINT_FOLLOW, self, 0)
		end
		for k, v in pairs(player.GetAll()) do
			clPlaySound(v, "disasters/nature/harp.mp3")
		end
		
			
		
	end
end



function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * -0.7  ) 
	ent:Spawn()
	ent:Activate()
	return ent
end





function ENT:OnRemove()
	self:StopParticles()
end

function ENT:Draw()
end




