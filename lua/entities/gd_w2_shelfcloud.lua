AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Shelf Cloud"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		

	if (CLIENT) then
	
	timer.Simple(15, function()
	if !self:IsValid() then return end
	
		if LocalPlayer().Sounds == nil then LocalPlayer().Sounds = {} end
		LocalPlayer().Sounds["Rainstorm_IDLE"]         = createLoopedSound(LocalPlayer(), "streams/disasters/nature/heavy_rain_loop.wav")
		LocalPlayer().Sounds["Rainstorm_muffled_IDLE"] = createLoopedSound(LocalPlayer(), "streams/disasters/nature/heavy_rain_loop_muffled.wav")
		
		end)
	end
	
	if (SERVER) then


		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:AttachParticleEffect()
		
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
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
		
		--setMapLight("d")		
	
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

		--gDisasters_CreateGlobalFog(self, data, true)	

		self:SetupSequencedVars()
		
	end
end

function ENT:SetupSequencedVars()
	self.StartTime = CurTime()
	self.State     = "cross"
end

function ENT:GetTimeElapsed()
	return CurTime() - self.StartTime
end

function ENT:Phase()
	local t_elapsed = self:GetTimeElapsed()
	
	if t_elapsed >= 0 and t_elapsed < 15 then
		self.State = "cross"
	elseif t_elapsed >= 15 and t_elapsed < 30 then
		self.State = "lightrain" 
	elseif t_elapsed >= 30 and t_elapsed < 120 then
		self.State = "moderate_raining"
	else
		self.State = "dead"
	end
	
	self:StateProcessor()
end

function ENT:StateProcessor()
	
	if self.State == "cross" then
		self:Cross()
	elseif self.State == "lightrain" then	
		self:LightRain()
	elseif self.State == "moderate_raining" then
		self:ModerateRaining()
	elseif self.State == "dead" then
		self:Remove()
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

function ENT:Cross()
	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(20,40),["Direction"]=Vector(-1,0,0)}, ["Pressure"]    = 98000, ["Temperature"] = math.random(15,16), ["Humidity"]    = math.random(42,45), ["BRadiation"]  = 0.1}}


	

end	
			
function ENT:LightRain()

	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(24,28),["Direction"]=Vector(-1,0,0)}, ["Pressure"]    = 96000, ["Temperature"] = 15, ["Humidity"]    = math.random(62,75), ["BRadiation"]  = 0.1}}

	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
			
			
				net.Start("gd_clParticles")
				net.WriteString("localized_light_rain_effect")
				net.Send(v)				
		
	
				if HitChance(2) then

					net.Start("gd_screen_particles")
					net.WriteString("hud/warp_ripple3")
					net.WriteFloat(math.random(5,80))
					net.WriteFloat(math.random(0,100)/100)
					net.WriteFloat(math.random(0,1))
					net.WriteVector(Vector(0,math.random(0,200)/100,0))
					net.Send(v)	
			
		
				end
				
					
			end
		
			
		end
end
	

function ENT:ModerateRaining()

	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(44,68),["Direction"]=Vector(-1,0,0)}, ["Pressure"]    = 96000, ["Temperature"] = math.random(14,15), ["Humidity"]    = math.random(82,85), ["BRadiation"]  = 0.1}}

	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
				
	
				net.Start("gd_clParticles")
				net.WriteString("downburst_medium_rain_main")
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


			
			
		end
	end
	
	
	
end



function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	if GetConVar("gdisasters_atmosphere"):GetInt() <= 0 then return end
	
	if #ents.FindByClass("gd_w*") >= 1 then return end

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
		
	end
	if (SERVER) then
		if !self:IsValid() then return end
		self:Phase()	

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
		
		self:StopParticles()
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






