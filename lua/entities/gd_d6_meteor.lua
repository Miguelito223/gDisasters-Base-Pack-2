AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Meteor"
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
		self:SetMaterial(self.Material)
		local phys = self:GetPhysicsObject()

		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		

		self:CreateMeteor()
		self:SetNoDraw(true)
		
		
	end
end

function ENT:Physics( data, physobj )

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


		ParticleEffect("meteor_explosion_main_ground", self:GetPos(), Angle(0,0,0), nil)
	
		
		self:Explode()
						 

	end

	
end

function ENT:CreateMeteor()
	
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


	local moite = ents.Create("gd_d6_meteor_ch")
			
	moite:SetPos( tr.HitPos - Vector(0,0,1000) )
	moite:Spawn()
	moite:Activate()
	moite:GetPhysicsObject():EnableMotion(true)
	moite:GetPhysicsObject():SetVelocity( Vector(0,0,math.random(-5000,-10000))  )
	moite:GetPhysicsObject():AddAngleVelocity( VectorRand() * 100 )
	self:Remove()
	
	
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

function ENT:OnRemove()

end

function ENT:Draw()



	self:DrawModel()
	
end




