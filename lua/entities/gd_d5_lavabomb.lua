AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Lava Bomb"
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

		self:Createlava()
		self:SetNoDraw(true)
		
		
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


	local lava = ents.Create("gd_d5_lavabomb_ch")
			
	lava:SetPos( tr.HitPos - Vector(0,0,1000) )
	lava:Spawn()
	lava:Activate()
	lava:GetPhysicsObject():EnableMotion(true)
	lava:GetPhysicsObject():SetVelocity( Vector(0,0,-3000)  )
	lava:GetPhysicsObject():AddAngleVelocity( VectorRand() * 100 )
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




