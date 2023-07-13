AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Geyser"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
    
ENT.Mass                             =  100
ENT.Models                           =  "models/ramses/models/nature/geyser_lava_64.mdl"


function ENT:Initialize()
	
	self:DrawShadow( false)
	
	if (SERVER) then
		
		self:SetModel(self.Models)
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
		self.CurrentlavaLevel = 0
		ParticleEffectAttach("geyser_small_idle_main", PATTACH_POINT_FOLLOW, self, 1)

			
		
	end
	
	self:CreateLoop()
end

function ENT:PerpVectorCW(ent1, ent2)
	local ent1_pos = ent1:GetPos()
	local ent2_pos = ent2:GetPos()
	
	local dir      = (ent2_pos - ent1_pos):GetNormalized()
	local perp     = Vector(-dir.y, dir.x, 0)
	
	return perp

end

function ENT:Reposition()
	if self:GetModel()==self.Models then
		self:SetPos( self:GetPos() + Vector(0,0,8))
	end
end

function ENT:CreateLoop()
	local sound = Sound("streams/disasters/nature/geyser_idle.wav")

	CSPatch = CreateSound(self, sound)
	CSPatch:Play()
	
	self.Sound = CSPatch
end

function ENT:PushEntities()
	if !self.IsErupting then return end 
	
	local maxz = 600
	if self:GetModel()==self.Models then
		maxz = 1200
	end
	

	local entities = ents.FindInBox( self:GetPos() - Vector(100, 100, 0), self:GetPos() + Vector(100,100, maxz ))
	
	for k, v in pairs(entities) do
		local phys = v:GetPhysicsObject()
		local dist = v:GetPos():Distance(self:GetPos())
		local force = 1 - (math.Clamp(dist / maxz,0,1))
		
		if v:IsPlayer() or v:IsNPC() or v:IsNextBot() then
		
		if v:IsOnGround() and ( v:IsPlayer() and !v:InVehicle() ) then v:SetPos( v:GetPos() + Vector(0,0,1))  end 
		
		if self:GetModel()==self.Models then
		
			v:SetVelocity(Vector(0,0,50))
		
		
		end
		
	end
		
		if phys:IsValid() then 
		
		local mass = v:GetPhysicsObject():GetMass()
		
			if mass < 10000 then
			
			if self:GetModel()==self.Models then
		
				phys:AddVelocity( Vector(0,0,force * 25 + math.random(-5,5)) )
						
			end
		
		end
	
		
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
		self:lavaDetection()
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
	

	if self:GetModel()==self.Models then ParticleEffectAttach("geyser_big_eruption_main", PATTACH_POINT_FOLLOW, self, 0) end

	if !self:IsValid() then return end
	
	self:EmitSound("eruption")
	
end

function ENT:ProcessTime()
	if self.IsErupting==false then return end
	
	local lava_level = 0
	local elapsed     = CurTime() - self.EruptionStartTime

	local increment   = 0.06
	
	if self:GetModel()==self.Models then
		increment = 0.06
	end
	
	if elapsed >=20 then self.IsErupting=false self:StopParticles() ParticleEffectAttach("geyser_small_idle_main", PATTACH_POINT_FOLLOW, self, 1) end 
	if elapsed>=0 and elapsed <= 5 then self.CurrentlavaLevel = self.CurrentlavaLevel - increment  end
	if elapsed>=15 and elapsed <= 20 then self.CurrentlavaLevel = self.CurrentlavaLevel + increment end
	if elapsed >= 20 then self.IsErupting = false end 
	
	

end


function ENT:CanErupt()
	if self.NextEruption == nil then self.NextEruption=CurTime() end
	
	if CurTime() >= self.NextEruption then
		self.NextEruption = CurTime() + math.random(30,80)
		return true
	else
		return false
	end
	
end

function ENT:GetlavaLevelPosition()
	local crater = self:GetAttachment(self:LookupAttachment("lava_level")).Pos
	return Vector(crater.x, crater.y, crater.z + self.CurrentlavaLevel )
end


function ENT:lavaDetection()
	local pos    = self:GetlavaLevelPosition()
	local radius = 50
	


	if self:GetModel()==self.Models then
		radius = 200
	end

	local ents   = ents.FindInSphere(pos, radius)
	
	for k, v in pairs(ents) do
		local vpos = v:GetPos()
		local phys = v:GetPhysicsObject()
		local eye = v:EyePos()
		if vpos.z <= pos.z and v:GetClass()!="worldspawn" and v != self and phys:IsValid() then
			local diff = pos.z-vpos.z 
			if v:IsPlayer() or v:IsNPC() or v:IsNextBot() then
				v.isinLava = true
				v:Ignite(15)
				v:TakeDamage(10, self, self)
				if v:IsOnGround() and ( v:IsPlayer() and !v:InVehicle() ) then v:SetPos( v:GetPos() + Vector(0,0,1))  end 
				if self:GetModel()==self.Models then
					v:SetVelocity(Vector(0,0,diff * math.random(0.3,0.5) ))
				end
			
			else
			
			end
		end
		if v:IsPlayer() then
			if eye.z < pos.z and v:Alive() and self:IsValid() then
				v:SendLua("LocalPlayer().LavaIntensity=LocalPlayer().LavaIntensity + (FrameTime()*8)")
				v.LavaIntensity=v.LavaIntensity + (FrameTime()*8)
			end
		end
	end
	self:ManipulateBonePosition( 1, Vector(0,0,(math.sin(CurTime())/2) + self.CurrentlavaLevel ))

end


sound.Add( {
	name = "eruption",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = math.random(70,90),
	pitch = 100,
	sound = "streams/disasters/nature/geyser_eruption.mp3"
} )


function ENT:OnRemove()
	if (SERVER) then

	
	self:StopParticles()
	
	if self.Sound==nil then return end
	self.Sound:Stop()
	
	self:StopSound("eruption")
	
	end
end

function ENT:Draw()

	self:SetRenderBounds(Vector(-5000,-5000,-5000), Vector(5000,5000,5000))
	self:DrawModel()


end




