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
		
		
		CreateSoundWave(table.Random({"streams/event/break/rock_break_a.mp3","streams/event/break/rock_break_b.mp3","streams/event/break/rock_break_c.mp3"}), self:GetPos(), "3d", 320.29/2, {80,120}, 5)
		

		local models = { 
			"models/ramses/models/nature/rock_1.mdl",		
			"models/ramses/models/nature/rock_2.mdl",	    
			"models/ramses/models/nature/rock_3.mdl"
		}

		for i=1, math.random(3, 5) do
			local piece = ents.Create("prop_physics") 
			piece:SetModel( table.Random(models) )
			piece:SetPos(data.HitPos + Vector(0,0,15))
			piece:Spawn()
			piece:Activate()
			piece:GetPhysicsObject():SetVelocity(self:GetVelocity())
			piece:GetPhysicsObject():AddAngleVelocity( VectorRand() * 10000 )

			timer.Simple(math.random(3,12), function()
				if piece:IsValid() then piece:Remove() end
			end)
			
		end

		self:Remove()
	
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




