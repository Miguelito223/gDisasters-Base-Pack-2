AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Geyser"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
    
ENT.Mass                             =  100
ENT.Models                           =  {"models/ramses/models/nature/geyser_16.mdl","models/ramses/models/nature/geyser_32.mdl","models/ramses/models/nature/geyser_64.mdl"}


function ENT:Initialize()	
	self:DrawShadow( false)
	
	if (SERVER) then
		
		self:SetModel(table.Random(self.Models))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetUseType( ONOFF_USE )

		
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
			phys:EnableMotion(false)
			
		end 
		self:Reposition()
		
		self.IsErupting = false
		
		self:SetAngles( Angle(0,math.random(-180, 180),0))
		self.StartPos   = self:GetPos()
		self.CurrentWaterLevel = 0
		ParticleEffectAttach("geyser_small_idle_main", PATTACH_POINT_FOLLOW, self, 1)


		
			
		
	end
	
	self:CreateLoop()
end

function ENT:Reposition()
	if self:GetModel()=="models/ramses/models/nature/geyser_16.mdl" then
		self:SetPos( self:GetPos() + Vector(0,0,5))
	elseif self:GetModel()=="models/ramses/models/nature/geyser_32.mdl" then
		self:SetPos( self:GetPos() + Vector(0,0,13))
	elseif self:GetModel()=="models/ramses/models/nature/geyser_64.mdl" then
		self:SetPos( self:GetPos() + Vector(0,0,8))
	end
end

function ENT:CreateLoop()
	local sound = Sound("disasters/nature/geyser_idle.wav")

	CSPatch = CreateSound(self, sound)
	CSPatch:Play()
	
	self.Sound = CSPatch
end

function ENT:PushEntities()
	if !self.IsErupting then return end 
	
	local maxz = 600
	if self:GetModel()=="models/ramses/models/nature/geyser_64.mdl" then
		maxz = 1200
	end
	

	local entities = ents.FindInBox( self:GetPos() - Vector(100, 100, 0), self:GetPos() + Vector(100,100, maxz ))
	
	for k, v in pairs(entities) do
		local phys = v:GetPhysicsObject()
		local dist = v:GetPos():Distance(self:GetPos())
		local force = 1 - (math.Clamp(dist / maxz,0,1))
		
		if phys:IsValid() then 
		
			phys:AddVelocity( Vector(0,0,force * 25 + math.random(-5,5)) )
		
		end
		
	end
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal   ) 
	ent:Spawn()
	ent:Activate()
	return ent
end





function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate
		
		self:StopMotion()
		self:WaterDetection()
		self:ProcessTime()
		self:PushEntities()
		if self:CanErupt()==true then self:Erupt() end
	
		self:NextThink(CurTime() + t)
		return true	
	end
	
end


function ENT:StopMotion()
	self:SetPos(self.StartPos)
	self:GetPhysicsObject():EnableMotion(false)

end

function ENT:Erupt()
	
	self.EruptionStartTime = CurTime()
	self.IsErupting = true
	self:StopParticles()
	

	if self:GetModel()=="models/ramses/models/nature/geyser_64.mdl" then ParticleEffectAttach("geyser_big_eruption_main", PATTACH_POINT_FOLLOW, self, 0) else ParticleEffectAttach("geyser_small_eruption_main", PATTACH_POINT_FOLLOW, self, 0) end
	

	self:EmitSound("disasters/nature/geyser_eruption.mp3")
	
end

function ENT:ProcessTime()
	if self.IsErupting==false then return end
	
	local water_level = 0
	local elapsed     = CurTime() - self.EruptionStartTime

	local increment   = 0.06
	
	if self:GetModel()=="models/ramses/models/nature/geyser_16.mdl" then
		increment = 0.06
	elseif self:GetModel()=="models/ramses/models/nature/geyser_32.mdl" then
		increment = 0.12
	elseif self:GetModel()=="models/ramses/models/nature/geyser_64.mdl" then
		increment = 0.24
	end
	
	if elapsed >=20 then self.IsErupting=false self:StopParticles() ParticleEffectAttach("geyser_small_idle_main", PATTACH_POINT_FOLLOW, self, 1) end 
	if elapsed>=0 and elapsed <= 5 then self.CurrentWaterLevel = self.CurrentWaterLevel - increment  end
	if elapsed>=15 and elapsed <= 20 then self.CurrentWaterLevel = self.CurrentWaterLevel + increment end
	if elapsed >= 20 then self.IsErupting = false end 
	
	

end







function ENT:CanErupt()
	if self.NextEruption == nil then self.NextEruption=CurTime() end
	
	if CurTime() >= self.NextEruption then
		self.NextEruption = CurTime() + math.random(30,120)
		return true
	else
		return false
	end
	
end


function ENT:WaterDetection()
	local pos    = self:GetAttachment(self:LookupAttachment("water_level")).Pos
	local radius = 50
	
	if self:GetModel()=="models/ramses/models/nature/geyser_16.mdl" then
		radius = 50
	elseif self:GetModel()=="models/ramses/models/nature/geyser_32.mdl" then
		radius = 100
	elseif self:GetModel()=="models/ramses/models/nature/geyser_64.mdl" then
		radius = 200
	end

	local ents   = ents.FindInSphere(pos, radius)
	
	local minz, maxz = self:GetPos().z, pos.z 
	
	for k, v in pairs(ents) do
		local vpos = v:GetPos()
		local phys = v:GetPhysicsObject()
		if vpos.z < maxz and vpos.z > minz and v:GetPhysicsObject():IsValid() then
			local diff = maxz-vpos.z 
			if v:IsPlayer() then
				v:TakeDamage(0.1, self, self)
				v:SetVelocity(Vector(0,0,diff/1.5))
			
			else
				phys:AddVelocity(Vector(0,0,diff*2.5))
			end
			
		
		end
	end
	self:ManipulateBonePosition( 1, Vector(0,0,(math.sin(CurTime())/2) + self.CurrentWaterLevel ))

end








function ENT:OnRemove()

	if self.Sound==nil then return end
	self.Sound:Stop()

	
	self:StopParticles()
end

function ENT:Draw()

	self:SetRenderBounds(Vector(-5000,-5000,-5000), Vector(5000,5000,5000))

	self:DrawModel()
	self:SetRenderBounds(Vector(-5000,-5000,-5000), Vector(5000,5000,5000))

end




