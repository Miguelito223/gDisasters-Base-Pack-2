AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Lightning Arc"

ENT.Material                         = "models/rendertarget"        
ENT.Mass                             =  100



function ENT:Initialize()	

	if (SERVER) then
		
		self:SetModel("models/props_junk/PopCan01a.mdl")

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		
		
		self:LightningType()
		self:SetNoDraw(true)

		
	end
end

function ENT:LightningType()
	if self.TargetPositions == nil then return end 
	
	self:PositionBolt()

end

function ENT:PositionBolt()
	
	local startpos = self.TargetPositions[1]
	self:SetPos(startpos)
	
	
	self:Smite()



end

function ENT:CreateTarget()
	local endpos = self.TargetPositions[2]
	
	local ent = ents.Create("gd_lightningarc_child")
	ent:SetPos(endpos)
	ent:Spawn()
	ent:Activate()

	
	

	
	return ent 
	
end


function ENT:Smite()


	
	
	local target = self:CreateTarget()
	target:SetNoDraw(true)

	timer.Simple(0.1, function()
		if !self:IsValid() then return end 
		net.Start("gd_lightning_bolt")
		net.WriteEntity(self)
		net.WriteEntity(target)
		net.WriteString(self.Particle)
		net.Broadcast()
		
		
		
	end)

	
	

	
	timer.Simple(0.5, function()
		if self:IsValid() then
			self:Remove()
		end
		if target:IsValid() then 
			target:Remove()
		end
	end)
	
		
	
end


function CreateLightningArc(startpos, endpos, effect)
	local ent = ents.Create("gd_lightningarc")
	ent:SetPos(Vector(0,0,0))
	ent.TargetPositions = {startpos, endpos}
	ent.Particle        = effect
	ent:Spawn()
	ent:Activate()
end


function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end


