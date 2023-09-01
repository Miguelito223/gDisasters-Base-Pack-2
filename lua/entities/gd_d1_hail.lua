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
	
	local bounds    = getMapSkyBox()
	local min       = bounds[1]
	local max       = bounds[2]

	local startpos  = Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z )
	local endpos  = Vector(self:GetPos().x, self:GetPos().y, max.z )
	
	local tr = util.TraceLine( {
		start  =  startpos,
		endpos = endpos,
		mask = MASK_SOLID_BRUSHONLY
	} )
	
	local hail = ents.Create("gd_d1_hail_ch")
			
	hail:SetPos( tr.HitPos )
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




