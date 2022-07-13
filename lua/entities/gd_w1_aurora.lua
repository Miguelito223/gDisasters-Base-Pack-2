AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Aurora Borealis"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100
ENT.MaxClouds                        =  25
ENT.CloudDecayTimes                  = {15, 40}

function ENT:Initialize()		
	

	if (SERVER) then
				
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 
		
		self.NextCloudCreation = CurTime()
		
		
	end
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:CreateClouds()

	if CurTime() < self.NextCloudCreation then return end 

	if #ents.FindByClass("gd_auroraborealis") > self.MaxClouds then return end 
	
	self.NextCloudCreation = CurTime() + 0.1
	
	local cloud = ents.Create("gd_auroraborealis")
	cloud:Spawn()
	cloud:Activate()
	
	timer.Simple(math.random(self.CloudDecayTimes[1], self.CloudDecayTimes[2]), function()
		if !cloud:IsValid() then return end
		cloud:Remove()
	end)
	
	
	
	
end



function ENT:Think()

	
	if (SERVER) then
		if !self:IsValid() then return end
		self:CreateClouds()
		self:NextThink(CurTime() + 0.01)
		return true
	end
end

function ENT:OnRemove()

	
	
	
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end






