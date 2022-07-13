AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )
ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 
ENT.PrintName		                 =  "env_earthquake"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"
ENT.FadeInMod                        =  engine.TickInterval()
ENT.Life                             =  {15,20}
function ENT:Initialize()	
	if (CLIENT) then
		if LocalPlayer().Sounds == nil then LocalPlayer().Sounds = {} end
		if LocalPlayer().Sounds["Earthquake"]==nil then
			LocalPlayer().Sounds["Earthquake"] = {  ["sound"] = createLoopedSound(LocalPlayer(), "streams/disasters/earthquake/earthquake.wav"), ["volume"] = 0 }
			LocalPlayer().Sounds["Earthquake"]["sound"]:ChangeVolume(0,0)
		end
	end
		
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
		self.MagnitudeModifier = 0
		self.NextPhysicsTime = CurTime()
		self.SpawnTime       = CurTime()
		self:SetNoDraw(true)
		self:PlayInitialSounds()
		timer.Simple(math.random(self.Life[1], self.Life[2]), function()
			 if !self:IsValid() then return end
			 self:EarthquakeDecay()
		end)
	end
end
function ENT:PlayInitialSounds()
	if self.Magnitude > 5 then
		CreateSoundWave("streams/disasters/earthquake/earthquake_strong.wav", self:GetPos(), "stereo" ,340.29/2, {90,110}, 5)
	else
		CreateSoundWave("streams/disasters/earthquake/earthquake_weak.wav", self:GetPos(), "stereo" ,340.29/2, {90,110}, 5)
	end	
end
function ENT:CreateEarthquakeWithParent()
	local earthquakes = {}
	earthquakes[1] = "gd_d1_rs1eq"
	earthquakes[2] = "gd_d2_rs2eq"
	earthquakes[3] = "gd_d3_rs3eq"
	earthquakes[4] = "gd_d4_rs4eq"
	earthquakes[5] = "gd_d5_rs5eq"
	earthquakes[6] = "gd_d6_rs6eq"
	earthquakes[7] = "gd_d7_rs7eq"
	earthquakes[8] = "gd_d8_rs8eq"
	earthquakes[9] = "gd_d9_rs9eq"
	earthquakes[10] = "gd_d10_rs10eq"
	local decider = math.random(1,math.floor(self.Magnitude * 2)) == 1
	if decider == false then
		if  math.floor(self.Magnitude) > 1 then
			CreateSoundWave("streams/disasters/earthquake/earthquake_aftershock.wav", self:GetPos(), "stereo" ,340.29/2, {40,100}, 10)
			local aftershock_magnitude = math.Clamp( math.floor(self.Magnitude) - math.random(1,3), 1, 10)
			local aftershock           = ents.Create( earthquakes[ aftershock_magnitude ] )
			aftershock.IsAfterShock    = true 
			aftershock:SetPos(Vector(0,0,0))
			aftershock:Spawn()
			aftershock:Activate()
			ParticleEffect("earthquake_swave_refract", self.Parent:GetPos() + Vector(0,0,10) , Angle(0,0,0), nil)
		end
	else
		CreateSoundWave("streams/disasters/earthquake/earthquake_aftershock.wav", self:GetPos(), "stereo" ,340.29/2, {120,130}, 20)
		CreateSoundWave("streams/disasters/earthquake/earthquake_aftershock.wav", self:GetPos(), "stereo" ,340.29/2.1, {120,130}, 20)
		local foreshock_magnitude = math.Clamp( math.floor(self.Magnitude) + math.random(1,2), 1, 10)
		local foreshock           = ents.Create( earthquakes[ foreshock_magnitude ] )
		foreshock.IsForeShock     = true
		foreshock:SetPos(self:GetPos())
		foreshock:Spawn()
		foreshock:Activate()
		ParticleEffect("earthquake_swave_main", self.Parent:GetPos() + Vector(0,0,10), Angle(0,0,0), nil)
	end
end
function ENT:EarthquakeDecay()
	if math.random(1,2)==1 then
		
		self:CreateEarthquakeWithParent()
	end
	self:Remove()		
end
function ENT:UpdateGlobalSeismicActivity()
	if self:GetRealMagnitude() == GetGlobalFloat("gd_seismic_activity") then
	else
		SetGlobalFloat( "gd_seismic_activity", self:GetRealMagnitude() )
	end
end
function ENT:EFire(pointer, arg) 
	if pointer == "Enable" then self.Enable = arg or false 
	elseif pointer == "Magnitude" then self.Magnitude = math.Clamp(arg, 0,9) or 0 
	elseif pointer == "Parent" then self.Parent = arg 
	end
end
function createEarthquake(magnitude, parent)
	for k, v in pairs(ents.FindByClass("env_earthquake")) do
		v:Remove()
	end
	local earthquake = ents.Create("env_earthquake")
	earthquake:EFire("Magnitude", magnitude)
	earthquake:SetPos(parent:GetPos())
	earthquake:Spawn()
	earthquake:Activate()
	earthquake:EFire("Enable", true)
	earthquake:EFire("Parent", parent)
	return earthquake
end
function ENT:MagnitudeModifierIncrement()
	self.MagnitudeModifier = math.Clamp(self.MagnitudeModifier + (engine.TickInterval() / 4 ), 0, 1)
end
function ENT:GetRealMagnitude()
	return self.Magnitude  * self.MagnitudeModifier
end
function ENT:ProcessMagnitude()
	local magmod    = self.MagnitudeModifier
	local mag       = self.Magnitude * magmod
	self:SetNWFloat("Magnitude", mag )
	
	if mag >= 0 and mag < 1 then 
	
	elseif mag >= 1 and mag < 2 then
		self:MagnitudeOne()
	elseif mag >= 2 and mag < 3 then
		self:MagnitudeTwo()
	elseif mag >= 3 and mag < 4 then
		self:MagnitudeThree()
	elseif mag >= 4 and mag < 5 then
		self:MagnitudeFour()
	elseif mag >= 5 and mag < 6 then
		self:MagnitudeFive()
	elseif mag >= 6 and mag < 7 then
		self:MagnitudeSix()
	elseif mag >= 7 and mag < 8 then
		self:MagnitudeSeven()
	elseif mag >= 8 and mag < 9 then
		self:MagnitudeEight()
	elseif mag >= 9 and mag < 10 then
		self:MagnitudeNine()
	elseif mag >= 10 and mag < 11 then
		self:MagnitudeTen()
	else

	end
end
function ENT:SendClientsideEffects( ply, offset_ang, amplitude )
	local magnitude = math.floor(self.Magnitude * self.MagnitudeModifier)
	if math.random(1,8) == 1 then
		net.Start("gd_shakescreen")
		net.WriteFloat(0.6)
		net.WriteFloat( amplitude * 2)
		net.WriteFloat(25)
		net.Send(ply)
	end
	if math.random(1, 11 - magnitude)==1 then
		net.Start("gd_clParticles")
		net.WriteString("earthquake_player_ground_rocks", Angle(0,math.random(1,40),0))
		net.Send(ply)
	end
	if magnitude >= 4 then
		if math.random(1, 21 - magnitude)==1 then
			net.Start("gd_clParticles")
			net.WriteString("earthquake_player_ground_dust", Angle(0,math.random(1,40),0))
			net.Send(ply)
		end	
	end
	SetOffsetAngles(ply, offset_ang)
end
function ENT:MagnitudeOne()
	local percentage = math.Clamp(self.Magnitude/1.99,0,1)
	local bxa, bya   = math.random(-5, 5)/100,   math.random(-5, 5)/100
	local mxa, mya   = (math.random(-4, 4)/100) * percentage,   (math.random(-4, 4)/100) * percentage
	local xa, ya     = bxa + mxa, bya +  mya
	for k, v in pairs(player.GetAll()) do
		if v:IsOnGround() then  self:SendClientsideEffects( v, Angle(xa,ya,0), 0.1) end
	end
end
function ENT:MagnitudeTwo()

	local percentage = math.Clamp(self.Magnitude/2.99,0,1)
	local bxa, bya   = math.random(-10,10)/100,math.random(-10,10)/100
	local mxa, mya   = (math.random(-5, 5)/100) * percentage,   (math.random(-5, 5)/100) * percentage
	local xa, ya     = bxa + mxa, bya +  mya
	for k, v in pairs(player.GetAll()) do
		if v:IsOnGround() then  self:SendClientsideEffects( v, Angle(xa,ya,0), 0.2) end
	end
end
function ENT:MagnitudeThree()
	local percentage = math.Clamp(self.Magnitude/3.99,0,1)
	local bxa, bya   = math.random(-15,15)/100,math.random(-15,15)/100
	local mxa, mya   = (math.random(-5, 5)/100) * percentage,   (math.random(-5, 5)/100) * percentage
	local xa, ya     = bxa + mxa, bya +  mya
	for k, v in pairs(player.GetAll()) do
		if v:IsOnGround() then self:SendClientsideEffects( v, Angle(xa,ya,0), 0.3) end

	end
	self:DoPhysics()
end
function ENT:MagnitudeFour()
	local percentage = math.Clamp(self.Magnitude/4.99,0,1)
	local bxa, bya   = math.random(-25,25)/100,math.random(-25,25)/100
	local mxa, mya   = (math.random(-5, 5)/100) * percentage,   (math.random(-5, 5)/100) * percentage
	local xa, ya     = bxa + mxa, bya +  mya
	for k, v in pairs(player.GetAll()) do
		if v:IsOnGround() then self:SendClientsideEffects( v, Angle(xa,ya,0), 0.4) end
	end
	self:DoPhysics()
end
function ENT:MagnitudeFive()
	local percentage = math.Clamp(self.Magnitude/5.99,0,1)
	local bxa, bya   = math.random(-35,35)/100,math.random(-35,35)/100
	local mxa, mya   = (math.random(-5, 5)/100) * percentage,   (math.random(-5, 5)/100) * percentage
	local xa, ya     = bxa + mxa, bya +  mya
	for k, v in pairs(player.GetAll()) do
		if v:IsOnGround() then self:SendClientsideEffects( v, Angle(xa,ya,0), 0.5) end

	end
	self:DoPhysics()
end
function ENT:MagnitudeSix()

	local percentage = math.Clamp(self.Magnitude/6.99,0,1)
	local bxa, bya   = math.random(-40,40)/100,math.random(-40,40)/100
	local mxa, mya   = (math.random(-5, 5)/100) * percentage,   (math.random(-5, 5)/100) * percentage
	local xa, ya     = bxa + mxa, bya +  mya
	for k, v in pairs(player.GetAll()) do
		if v:IsOnGround() then self:SendClientsideEffects( v, Angle(xa,ya,0), 2) end

	end
	self:DoPhysics()
end
function ENT:MagnitudeSeven()

	local percentage = math.Clamp(self.Magnitude/7.99,0,1)
	local bxa, bya   = math.random(-60,60)/100,math.random(-60,60)/100
	local mxa, mya   = (math.random(-5, 5)/100) * percentage,   (math.random(-5, 5)/100) * percentage
	local xa, ya     = bxa + mxa, bya +  mya
	for k, v in pairs(player.GetAll()) do
		if v:IsOnGround() then self:SendClientsideEffects( v, Angle(xa,ya,0), 4) end

	end
	self:DoPhysics()
end
function ENT:MagnitudeEight()
	local percentage = math.Clamp(self.Magnitude/8.99,0,1)
	local bxa, bya   = math.random(-100,100)/100,math.random(-100,100)/100
	local mxa, mya   = (math.random(-5, 5)/100) * percentage,   (math.random(-5, 5)/100) * percentage
	local xa, ya     = bxa + mxa, bya +  mya

	for k, v in pairs(player.GetAll()) do
		if v:IsOnGround() then self:SendClientsideEffects( v, Angle(xa,ya,0), 8) end
	end
	self:DoPhysics()
end
function ENT:MagnitudeNine()
	local percentage = math.Clamp(self.Magnitude/9.99,0,1)
	local bxa, bya   = math.random(-150,150)/100,math.random(-150,150)/100
	local mxa, mya   = (math.random(-25, 25)/100) * percentage,   (math.random(-25, 25)/100) * percentage
	local xa, ya     = bxa + mxa, bya +  mya
	for k, v in pairs(player.GetAll()) do
		if v:IsOnGround() then self:SendClientsideEffects( v, Angle(xa,ya,0), 16) end
	end
	self:DoPhysics()
end
function ENT:MagnitudeTen()
	local percentage = math.Clamp(self.Magnitude/10,0,1)
	local bxa, bya   = math.random(-450,450)/100,math.random(-450,450)/100
	local mxa, mya   = (math.random(-25, 25)/100) * percentage,   (math.random(-25, 25)/100) * percentage
	local xa, ya     = bxa + mxa, bya +  mya
	for k, v in pairs(player.GetAll()) do
		if v:IsOnGround() then self:SendClientsideEffects( v, Angle(xa,ya,0), 38) end
	end
	self:DoPhysics()
end
function ENT:Unfreeze(phys, v, mag)
	if math.random(1,1024 - math.floor((25.6*self.Magnitude)))==1 then
		constraint.RemoveAll( v )
	end
	if math.random(1,512 - math.floor((25.6*self.Magnitude)))==1 and v:GetClass()!="worldspawn" then
		phys:EnableMotion(true)
		phys:Wake()
		constraint.RemoveAll( v )
		v:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
end
function ENT:DoPhysics()
	local t =  GetConVar( "gdisasters_envearthquake_simquality" ):GetFloat()-- tick dependant function that allows for constant think loop regardless of server tickrate
	local scale_velocity = 66/( 1/engine.TickInterval())
	local mag = self.Magnitude * self.MagnitudeModifier
	if !self:CanDoPhysics(t) or mag < 3 then return end -- if magnitude is less than 3 dont bother doing physics
	local mag_physmod    = mag-3 / 7
	local vec = (mag * 25) * Vector(math.random(-15,15)/10,0 ,math.random(-5,4)/10)
	local ang_vv =  (Vector( (math.random(-15,15)/10), 0,math.random(-5,4)/10) * (mag*8))
	if HitChance(2) then ang_vv = ang_vv * 20  end 
	for k, v in pairs(player.GetAll()) do
		if v:IsOnGround() then
			if mag >= 3 and mag <=3.9 then		
			elseif mag >= 4 and mag <= 4.9 then
			elseif mag >= 5 and mag <= 5.9 then
			elseif mag >= 6 and mag <= 6.9 then
			elseif mag >= 7 and mag <= 7.9 then
				v:SetVelocity( vec)
			elseif mag >= 8 and mag <= 8.9 then
				v:SetVelocity( vec * 1.125)
			elseif mag >= 9 and mag <= 9.9 then
				v:SetVelocity( vec * 1.5)
			elseif mag >= 10 and mag <= 11 then
				v:SetVelocity( vec * 2)
			end
		end
	end
	for k, v in pairs(ents.GetAll()) do
		local phys = v:GetPhysicsObject()
		if phys:IsValid()  and  (v:GetClass()!= "phys_constraintsystem" and v:GetClass()!= "phys_constraint"  and v:GetClass()!= "logic_collision_pair") then
			local mass  = phys:GetMass()
			local vel_mod  = 1 - math.Clamp((phys:GetVelocity():Length()/2000),0,1)
			local ang_v = ang_vv * vel_mod 
			self:DisruptElectricity(v) 
			if mag >= 3 and mag <=3.9 then
				if mass < 60 then
					if math.random(1, 2) == 1 then
						phys:AddAngleVelocity( ang_v )
						phys:AddVelocity( ang_v )
					end
				end
			elseif mag >= 4 and mag <= 4.9 then
				if mass < 400 then 
					if math.random(1, 2) == 1 then
						phys:AddAngleVelocity( ang_v )
						phys:AddVelocity( ang_v )
						self:Unfreeze(phys, v, mag)
					end
				end
				
			
			elseif mag >= 5 and mag <= 5.9 then
				if mass < 800 then 
					if math.random(1, 2) == 1 then
						phys:AddAngleVelocity( ang_v )
						phys:AddVelocity( ang_v )
						self:Unfreeze(phys, v, mag)
					end
				end
			elseif mag >= 6 and mag <= 6.9 then
				if mass < 1600 then 
					if math.random(1, 2) == 1 then
						phys:AddAngleVelocity( ang_v * 2 )
						phys:AddVelocity( ang_v  )
						self:Unfreeze(phys, v, mag)
					end
				end
			elseif mag >= 7 and mag <= 7.9 then
				if mass < 3400 then 
					if math.random(1, 2) == 1 then
						phys:AddAngleVelocity( ang_v * 4 )
						phys:AddVelocity( ang_v * 2 )
						self:Unfreeze(phys, v, mag)
					end
				end
			elseif mag >= 8 and mag <= 8.9 then
				if mass < 13600 then 
					if math.random(1, 2) == 1 then
						phys:AddAngleVelocity( ang_v * 8 )
						phys:AddVelocity( ang_v * 4 )
						self:Unfreeze(phys, v, mag)
					end
				end
			elseif mag >= 9 and mag <= 9.9 then
				if mass < 37200 then 
					if math.random(1, 2) == 1 then
						phys:AddAngleVelocity( ang_v * 12 )
						phys:AddVelocity( ang_v * 6 )
						self:Unfreeze(phys, v, mag)
					end
				end
			elseif mag >= 10 and mag <= 11 then
				if mass <= 50000 then 
					if math.random(1, 2) == 1 then
						phys:AddAngleVelocity( ang_v * 24 )
						phys:AddVelocity( ang_v * 12 )
						self:Unfreeze(phys, v, mag)
					end
				end				
			end
		end
	end
end
function ENT:DisruptElectricity(ent)
	if !light_entities[ent:GetClass()] then return end
	if !ent:IsConstrained() then return end
	if self:GetRealMagnitude() <= 2 then return end
	local mag     = self:GetRealMagnitude()
	local freq_to = math.random(3,40 - math.floor(mag))==3
	if freq_to==true then
		ent:SetOn(math.random(1,2)==1)
		sound.Play("ambient/energy/newspark11.wav", ent:GetPos(), 70, 100, 1)
	end
end
function ENT:IsParentValid()
	if self.Parent:IsValid()==false or self.Parent==nil then self:Remove() end
end
function ENT:CanDoPhysics(nexttime)
	if CurTime() >= self.NextPhysicsTime then
		if HitChance(1) then
			self.NextPhysicsTime = CurTime() + (math.random(0,250)/100)
		else
			self.NextPhysicsTime = CurTime() + nexttime 
		end
		return true
	else
		return false
	end
end
function ENT:MagnitudeModulateSound()
	local volume = self:GetNWFloat("Magnitude") 
	local volmod = (volume / 10) ^ 3
	local distance_mod = 0
	local tr = util.TraceLine( {
		start = LocalPlayer():GetPos(),
		endpos = LocalPlayer():GetPos()-Vector(0,0,3000),
		filter = LocalPlayer()
	} )
	if tr.Hit then 
		distance_mod = 1 - (tr.HitPos:Distance(LocalPlayer():GetPos())/3000)
	end
	volmod = volmod * distance_mod
	if LocalPlayer().Sounds == nil then LocalPlayer().Sounds = {} end
	if LocalPlayer().Sounds["Earthquake"]==nil then
		LocalPlayer().Sounds["Earthquake"] = {  ["sound"] = createLoopedSound(LocalPlayer(), "streams/disasters/earthquake/earthquake.wav"), ["volume"] = 0 }
		LocalPlayer().Sounds["Earthquake"]["sound"]:ChangeVolume(volmod,0)
	else
		LocalPlayer().Sounds["Earthquake"]["sound"]:ChangeVolume(volmod,0)
	end	
end
function ENT:Think()
	if (CLIENT) then
		self:MagnitudeModulateSound()
	end
	if (SERVER) then
		self:IsParentValid()
		self:ProcessMagnitude()
		self:MagnitudeModifierIncrement()
		self:UpdateGlobalSeismicActivity()
		self:NextThink(CurTime())
		return true
	end
end
function ENT:OnRemove()
	if (CLIENT) then
		if LocalPlayer().Sounds == nil then LocalPlayer().Sounds = {} end
		if LocalPlayer().Sounds["Earthquake"]==nil then
			LocalPlayer().Sounds["Earthquake"] = {  ["sound"] = createLoopedSound(LocalPlayer(), "streams/disasters/earthquake/earthquake.wav"), ["volume"] = 0 }
			LocalPlayer().Sounds["Earthquake"]["sound"]:ChangeVolume(0,0)
		else
			LocalPlayer().Sounds["Earthquake"]["sound"]:ChangeVolume(0,0)
		end
	end
	if (SERVER) then
		SetGlobalFloat( "gd_seismic_activity", 0 )
	end
	self:StopParticles()
end
function ENT:Draw()	
end
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
function richter_AmplifyMagnitudeByIntensity( magnitude, scale)
	if magnitude == nil or scale == nil then return 0 end 
	return math.log10(scale) + magnitude
end
function richter_AmplifyMagnitudeByIntensity( magnitude, scale)
	if magnitude == nil or scale == nil then return 0 end 
	return math.log10(scale) + magnitude
end
light_entities = {["gmod_light"]=true, ["gmod_lamp"]=true}