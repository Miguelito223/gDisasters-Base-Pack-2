AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Mini Volcano"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
    
ENT.Mass                             =  50000
ENT.Model                            =  "models/ramses/models/nature/volcano.mdl"
ENT.AutomaticFrameAdvance            = true 

function ENT:Initialize()	
	self:DrawShadow( false)
	
	if (SERVER) then
		self:SetModelScale(0.5,0)

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
		
		
		
		self.OldEntitiesInsideLava = {}

		self.StartPos   = self:GetPos()
		
		
		self:SetAngles( Angle(0,math.random(-180, 180),0))
		self:ResetSequence(self:LookupSequence("idle"))
		
		
		

		

		
			
		
	end
	
	self:CreateLoop()
end

function ENT:PressureIncrement()
	
	if self.IsGoingToErupt==false and self.IsPressureLeaking == false then
		self.Pressure = math.Clamp(self.Pressure + 0.1,0,100)
		
	elseif self.IsGoingToErupt == false and self.IsPressureLeaking == true then
		self.Pressure = math.Clamp(self.Pressure - 0.15,0,100)
		if self.Pressure == 0 then self.IsPressureLeaking = false end
	
	end
end

function ENT:CheckPressure()
	
	if self.Pressure >= 100 then
		if self.IsGoingToErupt==false then
			self.IsGoingToErupt = true
		

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
	CSPatch:Play()
	
	self.Sound = CSPatch
	
end


function ENT:GetLavaLevelPosition()
	local crater = self:GetAttachment(self:LookupAttachment("crater")).Pos
	return Vector(crater.x, crater.y, crater.z + self:GetNWFloat("LavaLevel"))
end

function ENT:LavaControl()
	
	self:SetLavaLevel( (250/100) * self.Pressure )
end

function ENT:GetEntitiesInsideLava()
	local lpos  = self:GetLavaLevelPosition()
	local lents = {} 
	for k, v in pairs(ents.FindInSphere(self:GetLavaLevelPosition() - Vector(0,0,200), 360)) do
		local pos = v:GetPos()
		local phys = v:GetPhysicsObject()
		if pos.z <= lpos.z and v:GetClass()!="worldspawn" and v != self and phys:IsValid() then
			
			
			table.insert(lents, v)
			
		
		end
	
	
	end

	return lents
end

function ENT:GetEntitiesInsideLava2()
	local lpos  = self:GetLavaLevelPosition()
	local lents = {} 
	for k, v in pairs(ents.FindInSphere(self:GetLavaLevelPosition() - Vector(0,0,200), 360)) do
		local pos = v:GetPos()
		local phys = v:GetPhysicsObject()
		if pos.z <= lpos.z and v:GetClass()!="worldspawn" and v != self and phys:IsValid() then
			
			lents[v] = true
			
			
		
		end
	
	
	end

	return lents
end


function ENT:InsideLavaEffect()
	local lents = self:GetEntitiesInsideLava()
	
	if self.OldEntitiesInsideLava != lents then
		for k, v in pairs(lents) do
			
			if self.OldEntitiesInsideLava[v]==true then
			
			else
				ParticleEffect("lava_splash_main", v:GetPos(), Angle(0,0,0), nil)
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
					
				if eye.z <= self:GetLavaLevelPosition().z then

					v:SendLua("LocalPlayer().LavaIntensity=LocalPlayer().LavaIntensity + (FrameTime()*8)")
				end
			end
			v:Ignite(15)
			v:TakeDamage(10, self, self)
		else
		
			phys:SetVelocity( phys:GetVelocity() * 0.01)
			v:Ignite(15)
		end
		
	end
	
	self.OldEntitiesInsideLava = self:GetEntitiesInsideLava2()
end



function ENT:CreateRocks(num, lifetime)
	local pos = self:GetLavaLevelPosition()
	local models = {"models/ramses/models/nature/volcanic_rock_03_64.mdl", "models/ramses/models/nature/volcanic_rock_02_64.mdl", "models/ramses/models/nature/volcanic_rock_01_64.mdl"}
	for i=0, num do

		local rock = ents.Create("prop_physics")
		rock:SetModel( table.Random(models) ) 
		rock:SetPos( pos ) 
		rock:Spawn()
		rock:Activate()

		rock:GetPhysicsObject():SetVelocity( Vector(math.random(-1100,1100), math.random(-1100, 1100), math.random(2100,5500)))

			
	
		
		timer.Simple(math.random(lifetime[1], lifetime[2]), function()
			if rock:IsValid() then rock:Remove() end 
		end)
	end
		
	
	
end
	

function ENT:Erupt()
	
	timer.Simple(2, function() -- we have a delay here because air is still expanding from heat
		if !self:IsValid() then return end
		CreateSoundWave("streams/disasters/nature/explosion_light_fiery_b.mp3", self:GetPos(), "3d" ,340.29/2, {100,100}, 5)
	end)
	self:CreateRocks( 20, {8,10} )

	ParticleEffect("minivolcano_eruption_dusty_main", self:GetLavaLevelPosition(), Angle(0,0,0), nil)
end



function ENT:LavaGlow()

	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		dlight.pos = self:GetLavaLevelPosition() + Vector(0,0,35)
		dlight.r = 255
		dlight.g = 67
		dlight.b = 0
		dlight.brightness = 8
		dlight.Decay = 1000
		dlight.Size = 270
		dlight.DieTime = CurTime() + 1
	end
	
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 85  ) 
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:SetLavaLevel(lvl)
	local lava_lvl  = math.Clamp(lvl, 0,250)
	local lava_level_main         = self:LookupBone("lava_level")
	local lava_level_extension    = self:LookupBone("lava_level_extension")
	local lava_level_extension2   = self:LookupBone("lava_level_extension_02")
	
	
	
	if lava_lvl <=100 then
		self:ManipulateBonePosition( lava_level_main, Vector(0,0, lava_lvl  ))
		
		self:ManipulateBonePosition( lava_level_extension, Vector(0,0, 0  ))
		self:ManipulateBonePosition( lava_level_extension2, Vector(0,0, 0  ))
		
	elseif lava_lvl>100 and lava_lvl<200 then
		local diff = lava_lvl - 100
		
		self:ManipulateBonePosition( lava_level_main, Vector(0,0, 100  ))
		self:ManipulateBonePosition( lava_level_extension, Vector(0,diff, 0  ))
		self:ManipulateBonePosition( lava_level_extension2, Vector(0,0, 0  ))
	elseif lava_lvl>=200 and lava_lvl<=300 then
		local diff = lava_lvl - 200
		
		self:ManipulateBonePosition( lava_level_main, Vector(0,0, 100  ))
		self:ManipulateBonePosition( lava_level_extension, Vector(0,100, 0  ))
		self:ManipulateBonePosition( lava_level_extension2, Vector(0,diff, 0  ))

	end
	
	self.LavaLevel  = lava_lvl 
	self:SetNWFloat("LavaLevel", lava_lvl)
end

local water_textures = {}
water_textures[1]    = Material("nature/env_dynamicwater/base_water_01")
water_textures[2]    = Material("nature/env_dynamicwater/base_water_02")
water_textures[3]    = Material("nature/env_dynamicwater/base_water_03")


local water_shader   = {}
water_shader[1]    = Material("nature/env_dynamicwater/water_expensive_02")
water_shader[2]    = Material("nature/env_dynamicwater/water_expensive_01")

local tsunami_water_textures = {}
tsunami_water_textures[1]    = Material("nature/env_dynamicwater/base_water_tsunami");
tsunami_water_textures[2]    = Material("nature/env_dynamicwater/base_water_03");


function ENT:VFire()

	if not vFireInstalled then return end

	for k, v in pairs(ents.GetAll()) do
		if (v:GetClass() == "vfire") then do
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
		self:LavaControl()
		self:CheckPressure()
		self:PressureIncrement()
		self:InsideLavaEffect()
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