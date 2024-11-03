AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Ancient Volcano"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
    
ENT.Mass                             =  50000
ENT.Model                            =  "models/ramses/models/nature/volcano_big.mdl"
ENT.AutomaticFrameAdvance            = true 

function ENT:Initialize()	
	self:DrawShadow( false)
	
	if (SERVER) then
		
		self:SetAngles( Angle(0,math.random(-180, 180),0))
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetUseType( ONOFF_USE )

		
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
			phys:EnableMotion(false)
			
		end 

		
		self.LavaLevel  = 125  -- 125 units above the crater
		self.Pressure = 0 
		
		self.IsGoingToErupt    = false
		self.IsPressureLeaking = false

		self.NextBubblingSound = CurTime()
		
		self.OldEntitiesInsideLava = {}

		self.StartPos   = self:GetPos()
		
		self:ResetSequence(self:LookupSequence("idle"))

		if isUnderWater(self) or isinWater(self) then
			ParticleEffectAttach("sumerged_bigvolcano_main", PATTACH_POINT_FOLLOW, self, 0)
		end
		
	end
	
	self:CreateLoop()
end

function ENT:VolcanicLavaEffects()
	local pos = self:GetLavaLevelPosition()
	local effect = table.Random({"volcano_magma_heat_warp"})
	

	if HitChance(10) then ParticleEffect(effect, pos, Angle(0,0,0), nil) end
	
end

function ENT:PressureIncrement()
	
	if self.IsGoingToErupt==false and self.IsPressureLeaking == false then
		self.Pressure = math.Clamp(self.Pressure + GetConVar("gdisasters_volcano_pressure_increase"):GetFloat() ,0,100)
		
	elseif self.IsGoingToErupt == false and self.IsPressureLeaking == true then
		self.Pressure = math.Clamp(self.Pressure - GetConVar("gdisasters_volcano_pressure_decrease"):GetFloat() ,0,100)
		if self.Pressure == 0 then self.IsPressureLeaking = false end
	
	end
end

function ENT:CheckPressure()
	
	if self.Pressure >= 100 then
		if self.IsGoingToErupt==false then
			self.IsGoingToErupt = true
			
			if math.random(1,1)==1 then

				local earthquake = ents.Create(table.Random({"gd_d1_rs1eq","gd_d2_rs2eq"}))
				earthquake:SetPos(self:GetPos() - Vector(0,0,5000))
				earthquake:Spawn()
				earthquake:Activate()
				
			
			end
			timer.Simple(math.random(10,20), function()
				if self:IsValid() then
					
					self:Erupt()
					self.Pressure = 99
					self.IsGoingToErupt = false
					self.IsPressureLeaking = true
				
				end
			
			end)
		
		end
	end
end

function ENT:CreateLoop()

	local sound = Sound("streams/disasters/nature/volcano_idle.wav")

	CSPatch = CreateSound(self, sound)
	CSPatch:SetSoundLevel( 90 )
	CSPatch:Play()
	
	self.Sound = CSPatch
	
end

function ENT:GetLavaLevelPosition()
	local crater = self:GetAttachment(self:LookupAttachment("lava_lvl")).Pos
	local scale = self:GetModelScale()
	return Vector(crater.x, crater.y, crater.z) - Vector(0,0,100 * scale) - (self:GetForward() * -100)
end

function ENT:LavaControl()
	
	self:SetLavaLevel( (250/100) * self.Pressure )
	
end

function ENT:GetEntitiesInsideLava()


	local lents = {} 
	local lents2 = {}
	
	local lpos  = self:GetLavaLevelPosition()
	local scale = self:GetModelScale()


	for k, v in pairs(ents.FindInSphere(lpos, 1400 * scale)) do
	
		local pos = v:GetPos()
		local phys = v:GetPhysicsObject()
		
		if (pos.z <= lpos.z)  and v:GetClass()!="worldspawn" and v != self and phys:IsValid() then
			table.insert(lents, v)
			lents2[v] = true
			v.IsInlava = true
		else
			lents2[v] = false
			v.IsInlava = false	
		end
	
	
	end

	return lents, lents2
end


function ENT:InsideLavaEffect()
	local lents, lents2 = self:GetEntitiesInsideLava()
	local scale = self:GetModelScale()
	

	if self.OldEntitiesInsideLava != lents2 then
		for k, v in pairs(lents) do
			
			if self.OldEntitiesInsideLava[v]==true then
			
			else
				ParticleEffect("lava_splash_main", Vector(v:GetPos().x,v:GetPos().y,self:GetLavaLevelPosition().z - (200 * scale)), Angle(0,0,0), nil)
			end
		
		end
		self.OldEntitiesInsideLava = lents 
	end
	
	for k, v in pairs(lents) do
		local phys = v:GetPhysicsObject()

		
		if v:IsPlayer() or v:IsNPC() or v:IsNextBot() then
			v:SetVelocity( v:GetVelocity() * -0.9)
			
			if v:IsPlayer() then
			
				local eye = v:EyePos()
					
				if eye.z < self:GetLavaLevelPosition().z and v:Alive() and self:IsValid() then
					v:SendLua("LocalPlayer().LavaIntensity=LocalPlayer().LavaIntensity + (FrameTime()*8)")
					v.LavaIntensity=v.LavaIntensity + (FrameTime()*8)
				end
			end
			v:Ignite(15)
			v:TakeDamage(1, self, self)
		else
		
			phys:SetVelocity( phys:GetVelocity() * 0.01)
			v:Ignite(15)
			
		end
	end
	
	self.OldEntitiesInsideLava = lents2
end



function ENT:CreateRocks(num, lifetime)
	local pos = self:GetLavaLevelPosition()
	for i=0, num do

		local rock = ents.Create("gd_d6_volcanic_rock_ch")
		rock:SetPos( pos ) 
		rock:Spawn()
		rock:Activate()

		rock:GetPhysicsObject():SetVelocity( Vector(math.random(-1100,1100), math.random(-1100, 1100), math.random(2100,5500)))
	end
		
end
	
function ENT:Erupt()
	timer.Simple(2, function() -- we have a delay here because air is still expanding from heat
		if !self:IsValid() then return end
		CreateSoundWave("streams/disasters/nature/krakatoa_explosion.mp3", self:GetPos(), "3d" ,340.29/2, {100,100}, 5)
	end)

	local pos = Vector(self:GetPos().x,  self:GetPos().y,  getMapSkyBox()[2].z)

	local tr = util.TraceLine({
		start = pos,
		endpos = pos - Vector(0,0,50000),
		mask = MASK_WATER
	})

	if isUnderWater(self) or isinWater(self) then
		ParticleEffect("water_huge", tr.HitPos, Angle(0,0,0), nil)
		ParticleEffect("volcano_eruption_dusty_main", self:GetLavaLevelPosition(), Angle(0,0,0), nil)
	else
		ParticleEffect("volcano_eruption_dusty_main", self:GetLavaLevelPosition(), Angle(0,0,0), nil)
		self:CreateRocks(20, 20)
	end


	for k,v in pairs(ents.FindInSphere(self:GetLavaLevelPosition(), 1800)) do
		
		local dist = ( v:GetPos() - self:GetLavaLevelPosition() ):Length() 	
			
		if (  v != self && IsValid( v ) && IsValid( v:GetPhysicsObject() ) ) and (v:GetClass()!= "phys_constraintsystem" and v:GetClass()!= "phys_constraint"  and v:GetClass()!= "logic_collision_pair") then 

			if dist < 1800 then 

				if( !v.Destroy ) then
								
					constraint.RemoveAll( v )
					v:GetPhysicsObject():EnableMotion(true)
					v:GetPhysicsObject():Wake()
					v.Destroy = true
					
				end
								
			end
								
		end
						
	end

	local pe = ents.Create( "env_physexplosion" );
	pe:SetPos( self:GetLavaLevelPosition() );
	pe:SetKeyValue( "Magnitude", 1400 );
	pe:SetKeyValue( "radius", 2000 );
	pe:SetKeyValue( "spawnflags", 19 );
	pe:Spawn();
	pe:Activate();
	pe:Fire( "Explode", "", 0 );
	pe:Fire( "Kill", "", 0.5 );
	
	util.BlastDamage( self, self, self:GetLavaLevelPosition(), 1200, math.random( 10, 20 ) )	
	
	if GetConVar("gdisasters_volcano_weatherchange"):GetInt() <= 0 then return end
	
	timer.Simple(22, function()
		local ent = ents.Create("gd_w2_ashstorm")
		local ent2 = ents.Create("gd_d7_lavabombshower")
		local ent3 = ents.Create("gd_d8_volcanicrockhower")
		ent:Spawn()
		ent:Activate()
		ent2:Spawn()
		ent2:Activate()
		ent3:Spawn()
		ent3:Activate()

	end)
	
	timer.Simple(120, function()
		
		local ent2 = ents.FindByClass("gd_w2_ashstorm")[1]
		local ent3 = ents.FindByClass("gd_d7_lavabombshower")[1]
		local ent4 = ents.FindByClass("gd_d8_volcanicrockhower")[1]
		if !ent2:IsValid() or !ent3:IsValid() or !ent4:IsValid() then return end
		if ent2:IsValid() then ent2:Remove() end
		if ent3:IsValid() then ent3:Remove() end
		if ent4:IsValid() then ent4:Remove() end

		local ent = ents.Create("gd_w4_heavyacidrain")
		ent:Spawn()
		ent:Activate()
	
		
	end)
	timer.Simple(200, function()
		local ent = ents.FindByClass("gd_w4_heavyacidrain")[1]
		if !ent:IsValid() then return end
		if ent:IsValid() then ent:Remove() end
	end)
	
end

function ENT:CanPlayBubblingSound()

	if CurTime() >= self.NextBubblingSound then 
		self.NextBubblingSound = CurTime() + 8
		return true
	else 
		return false
	end
	
end

function ENT:IfUnderWater()

	if isUnderWater(self) or isinWater(self) then
		if (math.random(1,100) == 1) and self:CanPlayBubblingSound() then
			self:EmitSound("streams/tarpit.mp3")
		end
	end
	
end

function ENT:LavaGlow()
	
	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		dlight.pos = self:GetLavaLevelPosition() + Vector(0,0,255)
		dlight.r = 255
		dlight.g = 37
		dlight.b = 0
		dlight.brightness = 8
		dlight.Decay = 100
		dlight.Size = 1800
		dlight.DieTime = CurTime() + 1
	end
	
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * (920 * 1)  ) 
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:SetLavaLevel(lvl)
	local lava_lvl  = math.Clamp(lvl, 0,600)
	local lava_level_main         = self:LookupBone("volcano_lava_level_extension_01")
	local lava_level_extension    = self:LookupBone("volcano_lava_level_extension_02")
	local lava_level_extension2   = self:LookupBone("volcano_lava_level_extension_03")
	local lava_level_extension3   = self:LookupBone("volcano_lava_level_extension_04")
	local lava_level_extension4   = self:LookupBone("volcano_lava_level_extension_05")
	local lava_level_extension5   = self:LookupBone("volcano_lava_level_extension_06")	
	
	if lava_lvl <=100 then
		self:ManipulateBonePosition( lava_level_main, Vector(0,0, lava_lvl  ))
		
		self:ManipulateBonePosition( lava_level_extension, Vector(0,0, 0  ))
		self:ManipulateBonePosition( lava_level_extension2, Vector(0,0, 0  ))
		self:ManipulateBonePosition( lava_level_extension3, Vector(0,0, 0  ))
		self:ManipulateBonePosition( lava_level_extension4, Vector(0,0, 0  ))
		self:ManipulateBonePosition( lava_level_extension5, Vector(0,0, 0  ))
	elseif lava_lvl>100 and lava_lvl<200 then
		local diff = lava_lvl - 100
		
		self:ManipulateBonePosition( lava_level_main, Vector(0,0, 100  ))
		self:ManipulateBonePosition( lava_level_extension, Vector(0,diff, 0  ))
		self:ManipulateBonePosition( lava_level_extension2, Vector(0,0, 0  ))
		self:ManipulateBonePosition( lava_level_extension3, Vector(0,0, 0  ))
		self:ManipulateBonePosition( lava_level_extension4, Vector(0,0, 0  ))
		self:ManipulateBonePosition( lava_level_extension5, Vector(0,0, 0  ))
		
	elseif lava_lvl>=200 and lava_lvl<=300 then
		local diff = lava_lvl - 200
		
		self:ManipulateBonePosition( lava_level_main, Vector(0,0, 100  ))
		self:ManipulateBonePosition( lava_level_extension, Vector(0,100, 0  ))
		self:ManipulateBonePosition( lava_level_extension2, Vector(0,diff, 0  ))
		self:ManipulateBonePosition( lava_level_extension3, Vector(0,0, 0  ))
		self:ManipulateBonePosition( lava_level_extension4, Vector(0,0, 0  ))
		self:ManipulateBonePosition( lava_level_extension5, Vector(0,0, 0  ))
	elseif lava_lvl>=300 and lava_lvl<=400 then
		local diff = lava_lvl - 300
		
		self:ManipulateBonePosition( lava_level_main, Vector(0,0, 100  ))
		self:ManipulateBonePosition( lava_level_extension, Vector(0,100, 0  ))
		self:ManipulateBonePosition( lava_level_extension2, Vector(0,100, 0  ))
		self:ManipulateBonePosition( lava_level_extension3, Vector(0,diff, 0  ))
		self:ManipulateBonePosition( lava_level_extension4, Vector(0,0, 0  ))
		self:ManipulateBonePosition( lava_level_extension5, Vector(0,0, 0  ))
	elseif lava_lvl>=400 and lava_lvl<=500 then
		local diff = lava_lvl - 300
		
		self:ManipulateBonePosition( lava_level_main, Vector(0,0, 100  ))
		self:ManipulateBonePosition( lava_level_extension, Vector(0,100, 0  ))
		self:ManipulateBonePosition( lava_level_extension2, Vector(0,100, 0  ))
		self:ManipulateBonePosition( lava_level_extension3, Vector(0,100, 0  ))
		self:ManipulateBonePosition( lava_level_extension4, Vector(0,diff, 0  ))
		self:ManipulateBonePosition( lava_level_extension5, Vector(0,0, 0  ))
		
	elseif lava_lvl>=500 and lava_lvl<=600 then
		local diff = lava_lvl - 300
		
		self:ManipulateBonePosition( lava_level_main, Vector(0,0, 100  ))
		self:ManipulateBonePosition( lava_level_extension, Vector(0,70, 0  ))
		self:ManipulateBonePosition( lava_level_extension2, Vector(0,200, 0  ))
		self:ManipulateBonePosition( lava_level_extension3, Vector(0,100, 0  ))
		self:ManipulateBonePosition( lava_level_extension4, Vector(0,100, 0  ))
		self:ManipulateBonePosition( lava_level_extension5, Vector(0,diff, 0  ))
	end
	
	self.LavaLevel  = lava_lvl 
	self:SetNWFloat("LavaLevel", lava_lvl)
end

function ENT:VFire()

	if !vFireInstalled then return end

	for k, v in pairs(ents.GetAll()) do
		if (v:GetClass() == "vfire") then
			if !self:IsValid() then return end
			if v:IsValid() then 
				if (v:GetParent() == self) then
					v:SoftExtinguish(1)
				end
			end
		end
	end
end

function ENT:Think()
	if (CLIENT) then
		self:LavaGlow()
	end
	if (SERVER) then
		if !self:IsValid() then return end
		local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1-- tick dependant function that allows for constant think loop regardless of server tickrate
		

		self:SetPos(self.StartPos)
		self:GetPhysicsObject():EnableMotion(false)
		self:SetAngles(self:GetAngles())
		
		self:VFire()
		self:CheckPressure()
		self:PressureIncrement()
		self:IfUnderWater()
		self:VolcanicLavaEffects()
		self:InsideLavaEffect()
		self:SetLavaLevel(600)
		
		
		self:NextThink(CurTime() + t)
		return true	
	end
	
end

function ENT:OnRemove()

	if self.Sound==nil then return end
	self.Sound:Stop()

	
	self:StopParticles()
end

function ENT:Draw()

	self:DrawModel()


end