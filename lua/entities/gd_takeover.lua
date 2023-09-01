AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Tree"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

    
ENT.Mass                             =  20000
ENT.Model                            =  {"models/props_foliage/tree_poplar_01.mdl","models/props_foliage/r_smallbush1.mdl","models/props_foliage/rd_bush04.mdl","models/props_foliage/tree_deciduous_02a.mdl","models/props_foliage/tree_deciduous_01a-lod.mdl","models/props_foliage/tree_deciduous_03b.mdl","models/props_foliage/ah_ash_tree002.mdl","models/props_foliage/ash03.mdl","models/props_foliage/oak_tree01.mdl"}

function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel(table.Random(self.Model))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		
		local phys = self:GetPhysicsObject()

		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
			phys:EnableMotion(false)
		end 		
		
	end
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


