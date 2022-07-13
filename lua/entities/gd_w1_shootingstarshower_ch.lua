AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Megacryometeor"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            = "odels/props_junk/PopCan01a.mdl"

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
			phys:SetMass(20)
		end 		
		self:SetMaterial(self.Material)
		timer.Simple(4, function()
			if !self:IsValid() then return end
			self:Remove()
		end)
		
		self.Move_vector = Vector(math.random(-14000,14000),math.random(-14000,14000),-500000)
		
		
		ParticleEffectAttach("shootingstar_burnup_main", PATTACH_POINT_FOLLOW, self, 0)

	end
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	if GetConVar("gdisasters_atmosphere"):GetInt() <= 0 then return end
	
	if #ents.FindByClass("gd_w*") >= 1 then return end
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
	

	self:Remove()

		
		
			

			

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




