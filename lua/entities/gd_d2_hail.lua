AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Hail"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Material                         = "nature/ice"        
ENT.Mass                             =  100
ENT.Models                           =  {"models/props_debris/concrete_spawnplug001a.mdl"}
ENT.RENDERGROUP                      = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel(table.Random(self.Models))
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
	
	local endpos    = startpos + Vector(0,0,2000)
	
	local hail = ents.Create("gd_d1_hail")
			
	hail:SetPos( endpos )
	hail:Spawn()
	hail:Activate()
	hail:GetPhysicsObject():EnableMotion(true)
	hail:GetPhysicsObject():SetVelocity( Vector(0,0,-10000) )
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




