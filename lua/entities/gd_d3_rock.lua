AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Rock"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            = {"models/ramses/models/nature/landmass_1.mdl", "models/ramses/models/nature/landmass_2.mdl"}

function ENT:Initialize()	

	if (SERVER) then
		
		self:SetModel(table.Random(self.Model))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )

		
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetMass(700)
			phys:Wake()
		end 		
		
		phys:EnableDrag( false )
		
		timer.Simple(14, function()
			if !self:IsValid() then return end
			self:Remove()
		end)

	end
end



function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * -1.00  ) 
	ent:Spawn()
	ent:Activate()
	return ent
	
end


function ENT:PhysicsCollide( data, phys )
	
	if ( data.Speed > 500 ) then 
		sound.Play(table.Random({"streams/event/break/rock_break_a.mp3","streams/event/break/rock_break_b.mp3","streams/event/break/rock_break_c.mp3"}), self:GetPos(), 80, {80,120}, 1)
		
		local p1 = ents.Create("prop_physics")
		p1:SetModel("models/ramses/models/nature/rock_1.mdl") 
		p1:SetPos(data.HitPos + Vector(0,0,15))
		p1:Spawn()
		p1:Activate()
		
		
		local p2 = ents.Create("prop_physics")
		p2:SetModel("models/ramses/models/nature/rock_2.mdl") 
		p2:SetPos(data.HitPos + Vector(0,0,15))
		p2:Spawn()
		p2:Activate()	

		local p3 = ents.Create("prop_physics")
		p3:SetModel("models/ramses/models/nature/rock_3.mdl") 
		p3:SetPos(data.HitPos + Vector(0,0,15))
		p3:Spawn()
		p3:Activate()		
		
		p3:GetPhysicsObject():SetVelocity(self:GetVelocity())
		p2:GetPhysicsObject():SetVelocity(self:GetVelocity())
		p1:GetPhysicsObject():SetVelocity(self:GetVelocity())
		p3:GetPhysicsObject():AddAngleVelocity( VectorRand() * 10000 )
		p2:GetPhysicsObject():AddAngleVelocity( VectorRand() * 10000 )
		p1:GetPhysicsObject():AddAngleVelocity( VectorRand() * 10000 )
		

		self:Remove()
		
		
		timer.Simple(math.random(3,12), function()
			if p1:IsValid() then p1:Remove() end
			if p2:IsValid() then p2:Remove() end
			if p3:IsValid() then p3:Remove() end
		end)




	
	end
end


function ENT:Think()

	local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1	
		
	if (SERVER) then
	
		self:NextThink(CurTime() + t)
		return true
	
	end
			
end


function ENT:OnRemove()

end

function ENT:Draw()



	self:DrawModel()
	
end




