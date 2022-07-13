AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Ball Lightning"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100
ENT.MaxSpeed                         =  1.5
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
		
		self.SpeedBoost = 0
		self.NextExplosionTime = CurTime() + math.random(4,12)
		self.MovementVector = Vector(math.random(-100,100)/100,math.random(-100,100)/100,0)
		self:SetNoDraw(true)
	
		
		ParticleEffectAttach("ball_lightning_main", PATTACH_POINT_FOLLOW, self, 0)
		
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


function ENT:SpeedBoostDecay()
	self.SpeedBoost = math.Clamp(self.SpeedBoost - 0.01,0,3)

end




function ENT:Movement()

	local vector = self.MovementVector + ((Vector((math.random(-10,10)/100) * math.sin(CurTime()),(math.random(-10,10)/100) * math.sin(CurTime()), 0) ))
	self.MovementVector = Vector(math.Clamp(vector.x,-(self.MaxSpeed),(self.MaxSpeed)), math.Clamp(vector.y,-(self.MaxSpeed),(self.MaxSpeed)), 0) * (1+self.SpeedBoost)
	
	if math.random(1,500)==500  then self.SpeedBoost = math.random(220,620)/100 end
	
	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0,0,50000),
		mask   = MASK_WATER + MASK_SOLID_BRUSHONLY 
	} )
	
	self:SetPos( tr.HitPos + (Vector(0,0,100) + (Vector(0,0,10)* math.sin(CurTime() * 2)) + vector ))

	
end


function ENT:RandomArcs()
	
	local dir = Vector(math.random(-1000,1000)/1000,math.random(-1000,1000)/1000,math.random(-1000,1000)/1000)
	
	local tr  = util.TraceLine( {
		start  = self:GetPos() + (dir * 15) ,
		endpos = self:GetPos() + (dir * 600),
		
	} )
	
	
	if tr.Hit and (tr.HitEntity != "gd_d3_ball_lightning" and tr.HitEntity != "gd_lightningarc" and tr.HitEntity != "gd_lightningarc_child") then
		if math.random(1,8)==1 then
			InflictDamageInSphere(tr.HitPos, 100, self, "electrical", 10)

			CreateLightningArc(self:GetPos() + dir * 90, tr.HitPos, table.Random({"ball_lightning_arc_main","ball_lightning_arc_main"}))
			sound.Play("ambient/energy/newspark"..tostring(0)..math.random(1,9)..".wav", tr.HitPos, 70, math.random(70,120), 1)
		end
		

		self:Explode()


	
	end
	
	
	
end

function ENT:Explode()
	if CurTime() < self.NextExplosionTime then return end
	
	sound.Play("ambient/energy/whiteflash.wav", self:GetPos(), 80, 100, 1)
	

	
	for i=0, 20 do
	
		timer.Simple(i/2, function()
			if !self:IsValid() then return end 
			
			local dir = Vector(math.random(-1000,1000)/1000,math.random(-1000,1000)/1000,math.random(-1000,1000)/1000)

			local tr  = util.TraceLine( {
				start  = self:GetPos() + (dir * 15) ,
				endpos = self:GetPos() + (dir * 1200),
				
			} )
			
		
			InflictDamageInSphere(tr.HitPos, 900, self, "electrical", 10)

			CreateLightningArc(self:GetPos() + dir * 90, tr.HitPos, table.Random({"ball_lightning_arc_main","ball_lightning_arc_main"}))
			sound.Play("ambient/energy/newspark"..tostring(0)..math.random(1,9)..".wav", tr.HitPos, 70, math.random(70,120), 1)	
		end)
	
	end
	self.NextExplosionTime = CurTime() + math.random(8,14)
	
end

function ENT:DrawLight()

	local dlight = DynamicLight( self:EntIndex() )

	if ( dlight ) then
		dlight.pos = self:GetPos()
		dlight.r = 255
		dlight.g = 25
		dlight.b = 255
		dlight.brightness = 10
		dlight.Decay = 10
		dlight.Size = 512
		dlight.DieTime = CurTime() + 1
	end
	
end

function ENT:ElectrolizeShell()
	if HitChance(20) then
		InflictDamageInSphere(self:GetPos(), 100, self, "electrical", 15)
	
	end
end

function ENT:Think()
	if (CLIENT) then
		self:DrawLight()
	end
	if (SERVER) then
		if !self:IsValid() then return end
		
		self:SpeedBoostDecay()
		self:Movement()
		self:RandomArcs()
		self:ElectrolizeShell()
		
		self:NextThink(CurTime() + 0.01)
		return true
	end
end

function ENT:OnRemove()

	if (SERVER) then		
		self:StopParticles()
	end
	
	
	
end








