AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Dust Devil"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100
ENT.Effects                          = {"dust_devil_1_main", "dust_devil_2_main", "dust_devil_3_main","dust_devil_4_main", "dust_devil_5_main"}
ENT.MaxSpeed                         = 1
function ENT:Initialize()		
	
	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		self:SetNoDraw(true)
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		
		self.SpeedBoost = 0
		
		self.MovementVector = Vector(math.random(-100,100)/100,math.random(-100,100)/100,0)
		
		local effect  = table.Random(self.Effects)
		self.OriginalEffect = effect
		self.CurrentParticleEffect = effect
		
		ParticleEffectAttach(self.CurrentParticleEffect, PATTACH_POINT_FOLLOW, self, 0)
		
	end
	
	timer.Simple(0.5, function()
		if !self:IsValid() then return end
		local sound = Sound("disasters/nature/tornado/dust_devil_loop.wav")

		CSPatch = CreateSound(self, sound)
		CSPatch:SetSoundLevel( 90 )
		CSPatch:Play()
		CSPatch:ChangeVolume( 1 )
		self.Sound = CSPatch
	end)
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


function ENT:Vortex()
	for k, v in pairs(player.GetAll()) do 
		local dist = v:GetPos():Distance(self:GetPos())
		if dist < 300 then
		
						
			if math.random(1,math.Round(math.Round(dist)/2))==1 then
				
				net.Start("gd_screen_particles")
				net.WriteString(table.Random({"hud/sand_1","hud/sand_2","hud/sand_3"}))
				net.WriteFloat(math.random(50, 300 - dist ))
				net.WriteFloat(math.random(50,200)/100)
				net.WriteFloat(math.random(0,1))
				net.WriteVector(Vector(0,0.5,0))
				net.Send(v)
					
				
				
			end
		
		end
		
	end

end

function ENT:SpeedBoostDecay()
	self.SpeedBoost = math.Clamp(self.SpeedBoost - 0.01,0,3)

end

function ENT:OverWater()

	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0,0,11),
		mask   = MASK_WATER 
	} )
	
	return tr.HitWorld
	
end

function ENT:PlayParticleEffect()
	local isOnWater    = self:OverWater()
	local water_effect = self.OriginalEffect.."_water"
	local org_effect   = self.OriginalEffect

	
	if isOnWater==true and self.CurrentParticleEffect != water_effect then
		self.CurrentParticleEffect = water_effect
		self:StopParticles()
		ParticleEffectAttach(self.CurrentParticleEffect, PATTACH_POINT_FOLLOW, self, 0)

	elseif isOnWater==false and  self.CurrentParticleEffect != self.OriginalEffect then
		self.CurrentParticleEffect = org_effect
		self:StopParticles()
		ParticleEffectAttach(self.CurrentParticleEffect, PATTACH_POINT_FOLLOW, self, 0)	
	end
	


end


function ENT:Movement()

	local vector = self.MovementVector + ((Vector((math.random(-10,10)/100) * math.sin(CurTime()),(math.random(-10,10)/100) * math.sin(CurTime()), 0) ))
	self.MovementVector = Vector(math.Clamp(vector.x,-(self.MaxSpeed),(self.MaxSpeed)), math.Clamp(vector.y,-(self.MaxSpeed),(self.MaxSpeed)), 0) * (1+self.SpeedBoost)
	
	if math.random(1,500)==500  then self.SpeedBoost = math.random(120,220)/100 end
	
	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0,0,50000),
		mask   = MASK_WATER + MASK_SOLID_BRUSHONLY 
	} )
	
	self:SetPos( tr.HitPos + Vector(0,0,10) + vector ) 

	
end

function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		
		local t =   (66/ ( 1/engine.TickInterval())) * 0.01	
		
		self:Vortex()
		self:SpeedBoostDecay()
		self:Movement()
		self:PlayParticleEffect()
		
		self:NextThink(CurTime() + t)
		return true
	end
end

function ENT:OnRemove()

	if (SERVER) then		
		self:StopParticles()
	end
	
	
	self.Sound:Stop()
end








