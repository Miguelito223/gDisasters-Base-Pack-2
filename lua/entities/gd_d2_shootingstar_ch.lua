AddCSLuaFile()
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Shooting Star"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            = "models/ramses/models/nature/volcanic_rock_01_64.mdl"
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
			phys:SetMass(math.random(20,60))
		end 		
		
		phys:EnableDrag( false )
		
		self:SetMaterial(self.Material)
		
		timer.Simple(math.random(3,4), function()
			if !self:IsValid() then return end
			self:Remove()
		end)
		
	
		ParticleEffectAttach("shootingstar_burnup_main", PATTACH_POINT_FOLLOW, self, 0)    

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


function ENT:PhysicsCollide( data, physobj )

	local tr,trace = {},{}
	tr.start = self:GetPos() + self:GetForward() * -200
	tr.endpos = tr.start + self:GetForward() * 500
	tr.filter = { self, physobj }
	trace = util.TraceLine( tr )
	
	if( trace.HitSky ) then
	
		self:Remove()
		
		return
		
	end
	
	if (data.Speed > 50 ) then 


	self:Remove()
						 

	end

	
end

function ENT:Think()
		local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1

		self:SetVelocity( self:GetForward() * 12000 )

		self:NextThink(CurTime() + t)
		return true
end


function ENT:OnRemove()



end

function ENT:Draw()



	self:DrawModel()
	
end




