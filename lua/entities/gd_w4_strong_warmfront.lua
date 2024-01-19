AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Strong Warm Front"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		

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
		next_state= "light_rain_fading" 
		self.State = next_state 
		self:StateProcessor()
	end)

	timer.Simple(40, function()
		next_state = "medium_wind"
		self.State = next_state 
		self:StateProcessor()
	end)

	timer.Simple(60, function()
		next_state = "heavy_wind" 
		self.State = next_state 
		self:StateProcessor()
	end)

	timer.Simple(90, function()
		next_state = "dead" 
		self.State = next_state 
		self:StateProcessor()
	end)
end

function ENT:StateProcessor()
	
	if self.State == "light_raining" then
		self:HighCloudy()
	elseif self.State == "light_rain_fading" then	
		self:PassageHigh()
	elseif self.State == "medium_wind" then
		self:PassageLow()
	elseif self.State == "heavy_wind" then 
		self:AfterFront()
	elseif self.State == "dead" then
		self:Remove()
	end
		
		
end

function ENT:HighCloudy()
	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(4,8),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 98000, ["Temperature"] = math.random(32,32), ["Humidity"]    = math.random(34,40), ["BRadiation"]  = 0.1, ["Oxygen"]  = 100}}
	
	setMapLight("g")
	
end




			
			
function ENT:PassageHigh()
	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(4,8),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 124000, ["Temperature"] = math.random(47,51), ["Humidity"]    = math.random(41,46), ["BRadiation"]  = 0.1, ["Oxygen"]  = 100}}

    setMapLight("d")

	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
			
			
			if math.random(1,7)==1 then
			    net.Start("gd_clParticles")
			    net.WriteString("localized_snow_effect", Angle(0,math.random(1,40),0))
			    net.Send(v)
				net.Start("gd_clParticles_ground")
				net.WriteString("snow_ground_effect")
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
				end
				
					
			end


		
			
		end
	end
	
	

end


function ENT:PassageLow()

	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(14,19),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 16000, ["Temperature"] = math.random(35,45), ["Humidity"]    = math.random(73,81), ["BRadiation"]  = 0.1, ["Oxygen"]  = 100}}
		
	
	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
				
	
				net.Start("gd_clParticles")
				net.WriteString("localized_light_rain_effect")
				net.Send(v)	
				
			else
				
		
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





function ENT:AfterFront()

    GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(2,3),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 3000, ["Temperature"] = math.random(5,13), ["Humidity"]    = math.random(87,92), ["BRadiation"]  = 0.1, ["Oxygen"]  = 100}}
	
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






