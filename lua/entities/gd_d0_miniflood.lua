AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Flash Flood"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.MaxFloodLevel                    =  {135,135}
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"


function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel(self.Model)

		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		

		self.Child = createFlood(math.random(self.MaxFloodLevel[1], self.MaxFloodLevel[2]), self)
		
			
		
	end
end



function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	
	if IsMapRegistered() == false then 
		self:Remove()
		print("current map isn't supported")
		ent:SetPos( tr.HitPos + tr.HitNormal * 1  )
	else 
		
		ent:SetPos( getMapCenterFloorPos() )
	end
	
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:IsLinkDestroyed()
	if self.Child == nil or self.Child:IsValid()==false then self:Remove() end

end

function ENT:Think()

	if (SERVER) then
		self:IsLinkDestroyed()
	end

end

function ENT:OnRemove()

end
	
function ENT:Draw()
			
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end


