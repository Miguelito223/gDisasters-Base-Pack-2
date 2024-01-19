AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Strong Cold Front"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		

    local bool hasShelfCloud = false

    
	if (CLIENT) then
	
	end
	
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
		if IsMapRegistered() == false then
			self:Remove()
			gDisasters:Warning("This map is incompatible with this addon! Tell the addon owner about this as soon as possible and change to gm_flatgrass or construct.", true) 
		end
		
		self.Original_SkyData = {}
            self.Original_SkyData["TopColor"]    = Vector(0.20,0.50,1.00)
			self.Original_SkyData["BottomColor"] = Vector(0.80,1.00,1.00)
			self.Original_SkyData["DuskScale"]   = 0
			self.Original_SkyData["SunSize"]     = 30
			
		self.Reset_SkyData    = {}
			self.Reset_SkyData["TopColor"]       = Vector(0.20,0.50,1.00)
			self.Reset_SkyData["BottomColor"]    = Vector(0.80,1.00,1.00)
			self.Reset_SkyData["DuskScale"]      = 1
			self.Reset_SkyData["SunColor"]       = Vector(0.20,0.10,0.00)
		
		for i=0, 100 do
			timer.Simple(i/100, function()
				if !self:IsValid() then return  end
				paintSky_Fade(self.Original_SkyData, 0.05)
			end)
		end
		
		setMapLight("e")		
	
		self:Lightning()

		local data = {}
			data.Color = Color(145,144,165)
			data.DensityCurrent = 0
			data.DensityMax     = 0.3
			data.DensityMin     = 0.1
			data.EndMax         = 10050
			data.EndMin         = 100
			data.EndMinCurrent  = 0
			data.EndMaxCurrent  = 0       

		gDisasters_CreateGlobalFog(self, data, true)	
		
		gDisasters_CreateGlobalGFX("heavyrain", self)

		self:SetupSequencedVars()
		self:Phase()
		
		
	end
end

function ENT:SetupSequencedVars()
	self.StartTime = CurTime()
	self.State     = "light_raining"
end

function ENT:GetTimeElapsed()
	return CurTime() - self.StartTime
end

function ENT:Lightning()

	local pos = self:GetPos()
	
	timer.Simple(0.1, function()
	if !self:IsValid() then return end
		local ent = ents.Create("gd_w2_thunderstorm_cl")
		ent:SetPos(pos)
		ent:Spawn()
		ent:Activate()
		
	end)
end

function ENT:OnStateChange(next_state)
	if next_state == "light_rain_fading" then				
				
		local lol = {"e","f","g","h","i","j","k"}

		gDisasters_RemoveGlobalFog()
		gDisasters_RemoveGlobalGFX()
		for i=0, 100 do
			timer.Simple(i/10, function()
				if !self:IsValid() then return  end
				paintSky_Fade(self.Reset_SkyData, 0.05)
			end)
			
		end
		
		for i=1, 7 do 
			timer.Simple(i, function()
				if !self:IsValid() then return  end
				setMapLight(lol[i])
			end)
		end

	end
	
end

function ENT:Phase()
	local t_elapsed  = self:GetTimeElapsed()
	
	local next_state = ""
	timer.Simple(0, function()
		next_state = "light_raining"

		if self.State != next_state then self:OnStateChange(next_state) end

		self.State = next_state 
		self:StateProcessor()
	end)

	timer.Simple(30, function()
		next_state = "light_rain_fading" 

		if self.State != next_state then self:OnStateChange(next_state) end

		self.State = next_state 
		self:StateProcessor()
	end)

	timer.Simple(40, function()
		next_state = "medium_wind"

		if self.State != next_state then self:OnStateChange(next_state) end

		self.State = next_state 
		self:StateProcessor()
	end)

	timer.Simple(60, function()
		next_state = "heavy_wind"
		
		if self.State != next_state then self:OnStateChange(next_state) end

		self.State = next_state 
		self:StateProcessor()
	end)

	timer.Simple(90, function()
		next_state = "dead" 
		
		if self.State != next_state then self:OnStateChange(next_state) end

		self.State = next_state 
		self:StateProcessor()
	end)
end

function ENT:StateProcessor()
	
	if self.State == "light_raining" then
		self:ClearSky()
	elseif self.State == "light_rain_fading" then	
		self:Squall()
	elseif self.State == "medium_wind" then
		self:Passage()
	elseif self.State == "heavy_wind" then 
		self:AfterFront()
	elseif self.State == "dead" then
		self:Remove()
	end
		
		
end

function ENT:ClearSky()
	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(2,6),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 78000, ["Temperature"] = math.random(28,31), ["Humidity"]    = math.random(34,40), ["BRadiation"]  = 0.1, ["Oxygen"]  = 100}}
	
	setMapLight("z")
	
end





function ENT:SpawnDeath()
	
	if HitChance(5) then
		
		local bounds    = getMapSkyBox()
		local min       = bounds[1]
		local max       = bounds[2]
		
		local startpos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,   max.z )

			
		local tr = util.TraceLine( {
			start  = startpos,
			endpos    = startpos + Vector(0,0,50000),
		} )
		

		local moite = ents.Create("gd_d1_hail_ch")
		
		moite:SetPos( tr.HitPos - Vector(0,0,5000) )
		moite:Spawn()
		moite:Activate()
		moite:GetPhysicsObject():EnableMotion(true)
		moite:GetPhysicsObject():SetVelocity( Vector(0,0,math.random(-5000,-10000))  )
		moite:GetPhysicsObject():AddAngleVelocity( VectorRand() * 100 )
		
		timer.Simple( math.random(14,18), function()
			if moite:IsValid() then moite:Remove() end
			
		end)
			
	
	end
	

end



			
			
function ENT:Squall()
	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(75,89),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 49000, ["Temperature"] = math.random(7,12), ["Humidity"]    = math.random(45,49), ["BRadiation"]  = 0.1, ["Oxygen"]  = 100}}

    setMapLight("d")
	
	if(!hasShelfCloud) then
	self:AttachParticleEffect()
	hasShelfCloud = true
	end

	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
			
			
	

			if math.random(1,6) == 1 then
				
				if HitChance(50) then

					net.Start("gd_screen_particles")
					net.WriteString("hud/warp_ripple3")
					net.WriteFloat(math.random(5,50))
					net.WriteFloat(math.random(0,100)/100)
					net.WriteFloat(math.random(0,1))
					net.WriteVector(Vector(0,math.random(0,200)/100,0))
					net.Send(v)	
				end
				
					
			end


		
			
		end
	end
	
	

end

function ENT:AttachParticleEffect()
	timer.Simple(0.1, function()
	if !self:IsValid() then return end
	
	ParticleEffectAttach("t_shelfcloud", PATTACH_POINT_FOLLOW, self, 0)
	
	end)
	
	
	timer.Simple(1000, function()
	if !self:IsValid() then return end
	
	self:StopParticles()
	
	end)
end

function ENT:Passage()

	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(130,148),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 26000, ["Temperature"] = math.random(2,5), ["Humidity"]    = math.random(95,97), ["BRadiation"]  = 0.1, ["Oxygen"]  = 100}}

	self.Reset_SkyData["TopColor"]       = Vector(0.20,0.50,1.00)
			self.Reset_SkyData["BottomColor"]    = Vector(0.80,1.00,1.00)
			self.Reset_SkyData["DuskScale"]      = 1
			self.Reset_SkyData["SunColor"]       = Vector(0.20,0.10,0.00)
		
	
	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
				
	
			net.Start("gd_clParticles")
			net.WriteString("localized_extreme_rain_effect")
			net.Send(v)	
			net.Start("gd_clParticles_ground")
			net.WriteString("extreme_rain_splash_effect")
			net.Send(v)	

			
				
		
			if HitChance(1)  then
				
				
				net.Start("gd_screen_particles")
				net.WriteString("hud/warp_ripple3")
				net.WriteFloat(math.random(5,200))
				net.WriteFloat(math.random(0,100)/100)
				net.WriteFloat(math.random(0,1))
				net.WriteVector(Vector(0,math.random(0,200)/100,0))
				net.Send(v)	

					
			end


			
			
		
		
			
		else
			
		end
	end
	
end





function ENT:AfterFront()

    GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(45,67),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 126000, ["Temperature"] = math.random(3,5), ["Humidity"]    = math.random(67,89), ["BRadiation"]  = 0.1, ["Oxygen"]  = 100}}
	
    setMapLight("z")
	
	
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





function ENT:Think()
	if (CLIENT) then

		
		local muffled_volume = math.Clamp(1 - ( LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8), 0, 1) - 0.25
		local idle_volume = math.Clamp(( LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)-0.25, 0, 1)
		
		if   LocalPlayer().Sounds["Rainstorm_muffled_IDLE"]!=nil then
			 LocalPlayer().Sounds["Rainstorm_muffled_IDLE"]:ChangeVolume(muffled_volume, 0)
		end
		
		if   LocalPlayer().Sounds["Rainstorm_IDLE"]!=nil then
			 LocalPlayer().Sounds["Rainstorm_IDLE"]:ChangeVolume(idle_volume, 0)
		end
		
		if math.random(1, 2) == 1 then
			local x, y, z = LocalPlayer():EyeAngles().x, LocalPlayer():EyeAngles().y, LocalPlayer():EyeAngles().z
			LocalPlayer():SetEyeAngles( Angle(x + (math.random(-100,100)/500), y + (math.random(-100,100)/500), z) )
		end
		
		
		
	end
	if (SERVER) then
		if !self:IsValid() then return end	
		self:SpawnDeath()
		self:NextThink(CurTime() + 0.01)
		return true
	end
end

function ENT:OnRemove()

	if (SERVER) then		
		local resetdata = self.Reset_SkyData
		GLOBAL_SYSTEM_TARGET=GLOBAL_SYSTEM_ORIGINAL

		for i=0, 40 do
			timer.Simple(i/100, function()
				paintSky_Fade(resetdata,0.05)
			end)
		end
		
		setMapLight("t")
		
		for k, v in pairs(ents.FindByClass("gd_w2_thunderstorm_cl")) do v:Remove() end
		
	end
	
	if (CLIENT) then


		

		if LocalPlayer().Sounds["Rainstorm_IDLE"]!=nil then 
			LocalPlayer().Sounds["Rainstorm_IDLE"]:Stop()
			LocalPlayer().Sounds["Rainstorm_IDLE"]=nil
		end
		
		if LocalPlayer().Sounds["Rainstorm_muffled_IDLE"]!=nil then 
			LocalPlayer().Sounds["Rainstorm_muffled_IDLE"]:Stop()
			LocalPlayer().Sounds["Rainstorm_muffled_IDLE"]=nil
		end
		
		
		
	end
	
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end






