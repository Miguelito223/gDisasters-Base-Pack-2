AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Mega Tsunami"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.MaxFloodLevel                    =  1000
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"

ENT.StartHeight                      =  1 
ENT.StartWedgeConstant               =  0.5

ENT.MiddleHeight                     =  6000
ENT.MiddleWedgeConstant              =  0.005 

ENT.EndHeight                        =  1000 
ENT.EndWedgeConstant                 =  0.1
ENT.Speed                            =  convert_MetoSU(math.random(15,60)) -- argument is in metres 





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
		
		local data = { 
		
					StartHeight  = self.StartHeight,
					StartWedge   = self.StartWedgeConstant,
					
					MiddleHeight = self.MiddleHeight,
					MiddleWedge  = self.MiddleWedgeConstant,
					
					EndHeight    = self.EndHeight,
					EndWedge     = self.EndWedgeConstant,
					Speed        = self.Speed
					
		}
					

		self.Child = createTsunami(self, data)
		
		
			
		
	end
end



function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	
	if IsMapRegistered() == false then 
		self:Remove()
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


