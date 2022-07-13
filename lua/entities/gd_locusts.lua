AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Just an ordinary swarm of bugs"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
     
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"


function ENT:Initialize()	


	
	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		
		local phys = self:GetPhysicsObject()
		

		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
			phys:Wake()
			phys:EnableGravity( false )
		end 		
		

		if self.TargetProp!=nil then
			ParticleEffectAttach(table.Random({"swarm_medium", "swarm_big"}),PATTACH_POINT_FOLLOW, self, 0)
		else
			ParticleEffectAttach("swarm_big",PATTACH_POINT_FOLLOW, self, 0)
		end
		
		
	end
	
	
	self:CreateLoop()
end

function ENT:CreateLoop()
	local sound = Sound("disasters/nature/bugsloop.wav")

	CSPatch = CreateSound(self, sound)
	CSPatch:Play()
	
	self.Sound = CSPatch
end



function ENT:Follow()
	if self.TargetEntity == nil or self.TargetEntity:IsValid()==false then return end 
	local phys = self:GetPhysicsObject()
	local dir = (self.TargetEntity:GetPos() - self:GetPos()):GetNormalized() * 500 
	phys:SetVelocity(dir + (self:GetRight() * (math.sin(CurTime()) * 500)) + (self:GetUp() * (math.cos(CurTime()) * 100)) )
	
	if self.TargetEntity:GetPos():Distance(self:GetPos()) < 200 then
		if math.random(1,25)==25 then
			self.TargetEntity:EmitSound( table.Random({"physics/flesh/flesh_squishy_impact_hard1.wav", "physics/flesh/flesh_squishy_impact_hard4.wav", "physics/body/body_medium_break2.wav"}) , 100, 100, 1)
			self.TargetEntity:TakeDamage(math.random(1,3), self, self)
		end
	end
end

function ENT:FollowEat()
	if self.TargetProp==nil then return end
	
	if self.TargetProp:IsValid()==false then self:Remove() return end
	
	local phys = self:GetPhysicsObject()
	local dir = (self.TargetProp:GetPos() - self:GetPos()):GetNormalized() * 1500 
	phys:SetVelocity(dir + (self:GetRight() * (math.sin(CurTime()) * 5000)))
	
	for k, v in pairs(ents.FindInSphere(self:GetPos(), 50)) do 
		if v==self.TargetProp then
			v:Remove()
			self:Remove()
		end
	end
		
end


function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate
		
		self:Follow()
		self:FollowEat()
		self:NextThink(CurTime() + t)
		return true
	end
end

function ENT:OnRemove()

	if self.Sound==nil then return end
	self.Sound:Stop()

	
end

function ENT:Draw()



	
end




