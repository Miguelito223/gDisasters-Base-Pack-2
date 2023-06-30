AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Rock"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            = {"models/ramses/models/nature/volcanic_rock_03_128.mdl","models/ramses/models/nature/volcanic_rock_02_128.mdl","models/ramses/models/nature/volcanic_rock_01_128.mdl", "models/ramses/models/nature/volcanic_rock_03_64.mdl", "models/ramses/models/nature/volcanic_rock_02_64.mdl", "models/ramses/models/nature/volcanic_rock_01_64.mdl"}

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
	local tr,trace = {},{}
	tr.start = self:GetPos() + self:GetForward() * -200
	tr.endpos = tr.start + self:GetForward() * 500
	tr.filter = { self, physobj }
	trace = util.TraceLine( tr )

	if( trace.HitSky ) then
	
		self:Remove()
		
		return
		
	end

	if ( data.Speed > 500 ) then 
			
		self:Explode()	
	
	end
end

function ENT:Createlava()


	local bounds    = getMapSkyBox()
	local min       = bounds[1]
	local max       = bounds[2]
		
	local startpos  = Vector(   self:GetPos().x     ,  self:GetPos().y ,   max.z )

	local startpos  = startpos
	
	local endpos    = self:GetPos()
	
		
	local tr = util.TraceLine( {
		start  = startpos,
		endpos = endpos + Vector(0,0,50000),

	} )


	local lava = ents.Create("gd_d6_volcanic_rock_ch")
			
	lava:SetPos( tr.HitPos - Vector(0,0,1000) )
	lava:Spawn()
	lava:Activate()
	lava:GetPhysicsObject():EnableMotion(true)
	lava:GetPhysicsObject():SetVelocity( Vector(0,0,-3000)  )
	lava:GetPhysicsObject():AddAngleVelocity( VectorRand() * 100 )
	self:Remove()
	
	
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




