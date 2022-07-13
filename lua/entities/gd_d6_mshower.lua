AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Megacryometeor"
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

		self:CreateHail()
		self:SetNoDraw(true)
		
		
	end
end

function ENT:CreateHail()



	
	local startpos  = self:GetPos()
	
	local endpos    = startpos + Vector(0,0,50000)
	
		
	local tr = util.TraceLine( {
		start  = startpos,
		endpos = endpos,

	} )


	local hail = ents.Create("gd_d6_mshower_ch")
			
	hail:SetPos( tr.HitPos - Vector(0,0,1000) )
	hail:Spawn()
	hail:Activate()
	hail:GetPhysicsObject():EnableMotion(true)
	hail:GetPhysicsObject():SetVelocity( Vector(0,0,-10000)  )
	hail:GetPhysicsObject():AddAngleVelocity( VectorRand() * 100 )
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




