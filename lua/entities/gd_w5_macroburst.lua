AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Macroburst"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		

	if (CLIENT) then
	
		
		LocalPlayer().Sounds["Rainstorm_IDLE"]         = CreateLoopedSound(LocalPlayer(), "streams/disasters/nature/heavy_rain_loop.wav")
		LocalPlayer().Sounds["Rainstorm_muffled_IDLE"] = CreateLoopedSound(LocalPlayer(), "streams/disasters/nature/heavy_rain_loop_muffled.wav")
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
			for k, v in pairs(player.GetAll()) do 
				v:ChatPrint("This map is incompatible with this addon! Tell the addon owner about this as soon as possible and change to gm_flatgrass or construct.") 
			end 
		end
		
		self.Original_SkyData = {}
			self.Original_SkyData["TopColor"]    = Vector(0.1, 0.1, 0.1)
			self.Original_SkyData["BottomColor"] = Vector(0.1, 0.1, 0.1)
			self.Original_SkyData["DuskScale"]   = 0
			
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
		
		setMapLight("d")		
	
		self:SetNoDraw(true)

		local data = {}
			data.Color = Color(145,144,185)
			data.DensityCurrent = 0
			data.DensityMax     = 0.5
			data.DensityMin     = 0.1
			data.EndMax         = 10050
			data.EndMin         = 100
			data.EndMinCurrent  = 0
			data.EndMaxCurrent  = 0       

		gDisasters_CreateGlobalFog(self, data, true)	
		
		gDisasters_CreateGlobalGFX("heavyrain", self)

		self:SetupSequencedVars()
		
	end
end

function ENT:SetupSequencedVars()
	self.StartTime = CurTime()
	self.State     = "light_raining"
end

function ENT:GetTimeElapsed()
	return CurTime() - self.StartTime
end

function ENT:Phase()
	local t_elapsed = self:GetTimeElapsed()
	
	if t_elapsed >= 0 and t_elapsed < 30 then
		self.State = "light_raining"
	elseif t_elapsed >= 30 and t_elapsed < 40 then
		self.State = "transition_lrmr" 
	elseif t_elapsed >= 40 and t_elapsed < 60 then
		self.State = "moderate_raining"
	elseif t_elapsed >= 60 and t_elapsed < 120 then
		self.State = "heavy_raining" 
	else
		self.State = "dead"
	end
	
	self:StateProcessor()
end

function ENT:StateProcessor()
	
	if self.State == "light_raining" then
		self:LightRaining()
	elseif self.State == "transition_lrmr" then	
		self:LRMRTransition()
	elseif self.State == "moderate_raining" then
		self:ModerateRaining()
	elseif self.State == "heavy_raining" then 
		self:HeavyRaining()
	elseif self.State == "dead" then
		self:Remove()
	end
		
		
end

function ENT:LightRaining()
	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(8,10),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 98000, ["Temperature"] = math.random(18,20), ["Humidity"]    = math.random(42,45), ["BRadiation"]  = 0.1, ["Oxygen"]  = 100}}

	for k, v in pairs(player.GetAll()) do


		if v.gDisasters.Area.IsOutdoor then
			
			if HitChance(10) then
			
				net.Start("gd_clParticles")
				net.WriteString("hail_character_effect_01_main")
				net.Send(v)	
				
			else 
				if HitChance(2) then
					net.Start("gd_clParticles")
					net.WriteString("localized_snow_effect")
					net.Send(v)
					net.Start("gd_clParticles_ground")
					net.WriteString("snow_ground_effect")
					net.Send(v)	
				else
					if HitChance(10) then					
						net.Start("gd_clParticles")
						net.WriteString("downburst_light_rain_main")
						net.Send(v)
						net.Start("gd_clParticles_ground")
						net.WriteString("rain_splash_effect")
						net.Send(v)		
					end
				end
			end
			
			if HitChance(8) then
			
				if HitChance(10) then
				
					net.Start("gd_screen_particles")
					net.WriteString("hud/snow")
					net.WriteFloat(math.random(5,128))
					net.WriteFloat(math.random(0,100)/100)
					net.WriteFloat(math.random(0,1))
					net.WriteVector(Vector(0,2,0))
					net.Send(v)	
				else
					if HitChance(10) then
						net.Start("gd_screen_particles")
						net.WriteString("hud/warp_ripple3")
						net.WriteFloat(math.random(5,100))
						net.WriteFloat(math.random(0,100)/100)
						net.WriteFloat(math.random(0,1))
						net.WriteVector(Vector(0,math.random(0,200)/100,0))
						net.Send(v)	
					end
				end
			end		
		
			
		end
	end
	
end





function ENT:SpawnDeath()
	
	if HitChance(math.Clamp(25 / ( (#player.GetAll()) ),5,50)) then
		
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



			
			
function ENT:LRMRTransition()
	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(24,28),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 97000, ["Temperature"] = math.random(14,16), ["Humidity"]    = math.random(62,75), ["BRadiation"]  = 0.1, ["Oxygen"]  = 100}}

	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
			

				
			

			if HitChance(50) then
			
				net.Start("gd_clParticles")
				net.WriteString("downburst_light_rain_main")
				net.Send(v)				
			
			else
				
				net.Start("gd_clParticles")
				net.WriteString("downburst_medium_rain_main")
				net.Send(v)	
			end

			
	

			if math.random(1,6) == 1 then
				
				if HitChance(50) then

					net.Start("gd_screen_particles")
					net.WriteString("hud/warp_ripple3")
					net.WriteFloat(math.random(5,50))
					net.WriteFloat(math.random(0,100)/100)
					net.WriteFloat(math.random(0,1))
					net.WriteVector(Vector(0,math.random(0,200)/100,0))
					net.Send(v)	
				
				else	
					
					
					net.Start("gd_screen_particles")
					net.WriteString("hud/warp_ripple3")
					net.WriteFloat(math.random(5,200))
					net.WriteFloat(math.random(0,100)/100)
					net.WriteFloat(math.random(0,1))
					net.WriteVector(Vector(0,math.random(0,200)/100,0))
					net.Send(v)	
		
				end
				
					
			end


		
			
		end
	end
	
	

end

function ENT:ModerateRaining()

	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(44,68),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 96000, ["Temperature"] = math.random(10,13), ["Humidity"]    = math.random(82,85), ["BRadiation"]  = 0.1, ["Oxygen"]  = 100}}

	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
			
			if HitChance(50)  then
				
	
				net.Start("gd_clParticles")
				net.WriteString("downburst_medium_rain_main")
				net.Send(v)	
		
					
			end

			if HitChance(1)  then
				
				
				net.Start("gd_screen_particles")
				net.WriteString("hud/warp_ripple3")
				net.WriteFloat(math.random(5,200))
				net.WriteFloat(math.random(0,100)/100)
				net.WriteFloat(math.random(0,1))
				net.WriteVector(Vector(0,math.random(0,200)/100,0))
				net.Send(v)	

					
			end


			
			
		end
	end
	
	
	
end





function ENT:HeavyRaining()

	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(210,257),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 45000, ["Temperature"] = math.random(4,8), ["Humidity"]    = math.random(97,99), ["BRadiation"]  = 0.1, ["Oxygen"]  = 100}}

	
	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
			
			if HitChance(90)  then
				
	
				net.Start("gd_clParticles")
				net.WriteString("downburst_heavy_rain_main")
				net.Send(v)	
				
		
					
			end

			if HitChance(2)  then
				
				
				net.Start("gd_screen_particles")
				net.WriteString("hud/warp_ripple3")
				net.WriteFloat(math.random(5,600))
				net.WriteFloat(math.random(0,100)/100)
				net.WriteFloat(math.random(0,1))
				net.WriteVector(Vector(0,math.random(0,200)/100,0))
				net.Send(v)	

					
			end


			
			
		end
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
			util.ScreenShake( LocalPlayer():GetPos(), 0.4, 5, 0.2, 500 )
		end
		
		
		
	end
	if (SERVER) then
		if !self:IsValid() then return end
		self:Phase()	
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






