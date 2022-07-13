AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Storm Shelter Door"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"


ENT.Mass                             =  50000

function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel("models/ramses/models/misc/buildings/storm_shelter_door.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		

		local phys = self:GetPhysicsObject()
		


		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
			phys:Wake()
			phys:EnableMotion(true)
		end 		


		
		
		
	end
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 20   ) 
	ent:Spawn()
	ent:Activate()
	ent:SetAngles(Angle(90,0,0))
	return ent
end





function ENT:Draw()



	self:DrawModel()
	
end




