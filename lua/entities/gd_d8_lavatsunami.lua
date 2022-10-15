AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Lava Tsunami"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.MaxFloodLevel                    =  300
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"

ENT.StartWedgeConstant               =  0.5
ENT.MiddleWedgeConstant              =  0.005 
ENT.EndWedgeConstant                 =  0.1




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
					StartHeight  = GetConVar("gdisasters_envdynamicwater_b_startlevel"):GetInt(),
					StartWedge   = self.StartWedgeConstant,
					
					MiddleHeight = GetConVar("gdisasters_envdynamicwater_b_middellevel"):GetInt(),
					MiddleWedge  = self.MiddleWedgeConstant,
					
					EndHeight    = GetConVar("gdisasters_envdynamicwater_b_endlevel"):GetInt(),
					EndWedge     = self.EndWedgeConstant,
					Speed        = convert_MetoSU(GetConVar("gdisasters_envdynamicwater_b_speed"):GetInt())
					}
					

		self.Child = createTsunamilava(self, data)
		
		
			
		
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


