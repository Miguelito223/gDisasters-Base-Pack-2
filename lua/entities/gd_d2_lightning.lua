AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Lightning Bolt"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Material                         = "nature/ice"        
ENT.Mass                             =  50000
ENT.Models                           =  {"models/props_debris/concrete_spawnplug001a.mdl"}


function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel(table.Random(self.Models))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:SetMaterial(self.Material)
		local phys = self:GetPhysicsObject()

		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		

		self:CreateBolt()
		self:SetNoDraw(true)
		
		
	end
end


function ENT:CreateBolt()
	
	local bounds    = getMapSkyBox()
	local min       = bounds[1]
	local max       = bounds[2]
	
	local startpos  = self:GetPos()
	
	local tr = util.TraceLine( {
		start = startpos,
		endpos = startpos + Vector(0,0,50000),
	} )
	
	local endpos = tr.HitPos
	
	CreateLightningBolt(endpos, startpos,  {"purple","blue"} ,  {"Grounded"} )

	self:Remove()
	
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	if IsMapRegistered() == true then


	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal    ) 
	ent:Spawn()
	ent:Activate()
	return ent
	
	end

end
 
 
function ENT:OnRemove()
end

function ENT:Draw()



	self:DrawModel()
	
end




