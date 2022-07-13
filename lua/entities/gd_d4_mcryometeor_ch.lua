AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Megacryometeor"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            = "models/ramses/models/nature/megacryometeor.mdl"
ENT.Material                         = "nature/ice_clear"

function ENT:Initialize()	

	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )

		local phys = self:GetPhysicsObject()
		phys:Wake()
		
		if (phys:IsValid()) then
			phys:SetMass(math.random(10,50))
		end 		
		self:SetMaterial(self.Material)
		timer.Simple(14, function()
			if !self:IsValid() then return end
			self:Remove()
		end)
		
		self.Move_vector = Vector(math.random(-14000,14000),math.random(-14000,14000),-500000)
		
		
		ParticleEffectAttach("megacryometeor_smoke_trail", PATTACH_POINT_FOLLOW, self, 0)

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





function ENT:PhysicsCollide( data, phys )
	
	local pos = self:GetPos()
	local mat = self.Material
	local vel = self.Move_vector 
	
	CreateSoundWave("disasters/atmospheric/sonic_boom_01.mp3", self:GetPos(), "stereo" ,340.29/2, {100,100}, 5)

		
	local models = { "models/ramses/models/nature/megacryometeor_01.mdl",
					 "models/ramses/models/nature/megacryometeor_02.mdl",
					 "models/ramses/models/nature/megacryometeor_03.mdl",
					 "models/ramses/models/nature/megacryometeor_04.mdl",
				 	 "models/ramses/models/nature/megacryometeor_05.mdl",
				  	 "models/ramses/models/nature/megacryometeor_06.mdl",
				 	 "models/ramses/models/nature/megacryometeor_07.mdl",
					 "models/ramses/models/nature/megacryometeor_08.mdl",
					 "models/ramses/models/nature/megacryometeor_09.mdl",
					 "models/ramses/models/nature/megacryometeor_10.mdl"}
					 
	ParticleEffect("megacryometeor_explosion_main", self:GetPos(), Angle(0,0,0), nil)

	self:Remove()

	for i=1, 10 do 
		local mod_vector = Vector( math.random(-2000,2000), math.random(-2000,2000), 0)
		local piece = ents.Create("prop_physics") 
		piece:SetModel( models[i] )
		piece:SetPos(pos)
		piece:Spawn()
		piece:Activate()
		piece:SetMaterial(mat)
		piece:GetPhysicsObject():SetVelocity(mod_vector)

		
		ParticleEffectAttach("megacryometeor_piece_steam", PATTACH_POINT_FOLLOW, piece, 0)
		timer.Simple(i + 10, function() if piece:IsValid() then piece:Remove() end end)
		
	end
		
			

			

end

function ENT:Move()
	self:GetPhysicsObject():SetVelocity(  self.Move_vector  )
	self:SetPos( self:GetPos() - Vector(0,0,10))
end

function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		self:Move()
		
		self:NextThink(CurTime() + 0.01)
		return true
	end
end

function ENT:OnRemove()
end

function ENT:Draw()



	self:DrawModel()
	
end




