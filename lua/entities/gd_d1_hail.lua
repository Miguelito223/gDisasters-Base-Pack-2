AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Hailstone"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Material                         = "nature/ice"        
ENT.Models                           =  {"models/ramses/models/nature/hail_01.mdl","models/ramses/models/nature/hail_02.mdl","models/ramses/models/nature/hail_03.mdl","models/ramses/models/nature/hail_04.mdl","models/ramses/models/nature/hail_05.mdl"}  


function ENT:Initialize()	

	if (SERVER) then
		
		self:SetModel(table.Random(self.Models))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )

		local phys = self:GetPhysicsObject()
		phys:Wake()
		
		if (phys:IsValid()) then
			phys:SetMass(math.random(10,50))
		end 		

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
	ent:SetPos( tr.HitPos + tr.HitNormal * -0.7  ) 
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:PhysicsCollide( data, phys )
	
	if ( data.Speed > 500 ) then 
		
		if self:GetModel()=="models/ramses/models/nature/hail_01.mdl" then
		
			local p1 = ents.Create("prop_physics")
			p1:SetModel("models/ramses/models/nature/hail_01_piece_01.mdl") 
			p1:SetPos(data.HitPos + Vector(0,0,15))
			p1:Spawn()
			p1:Activate()
			
			
			local p2 = ents.Create("prop_physics")
			p2:SetModel("models/ramses/models/nature/hail_01_piece_02.mdl") 
			p2:SetPos(data.HitPos + Vector(0,0,15))
			p2:Spawn()
			p2:Activate()		
			
			p2:GetPhysicsObject():SetVelocity(self:GetVelocity())
			p1:GetPhysicsObject():SetVelocity(self:GetVelocity())
			p2:GetPhysicsObject():AddAngleVelocity( VectorRand() * 10000 )
			p1:GetPhysicsObject():AddAngleVelocity( VectorRand() * 10000 )
			
			self:Remove()
			
			timer.Simple(math.random(3,12), function()
				if p1:IsValid() then p1:Remove() end
				if p2:IsValid() then p2:Remove() end
			end)
		else
			
			ParticleEffect("hail_impact_effect_main", data.HitPos + Vector(0,0,1), Angle(0,0,0), nil)
			sound.Play(table.Random({"streams/event/break/ice_break_a.mp3","streams/event/break/ice_break_b.mp3","streams/event/break/ice_break_c.mp3"}), self:GetPos(), 80, {80,120}, 1)
			
			if HitChance(10) then
			else
			
				self:Remove()
			end
		end
			
	
	end
end


function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		self:NextThink(CurTime() + 1)
		return true
	end
end

function ENT:OnRemove()
end

function ENT:Draw()



	self:DrawModel()
	
end




