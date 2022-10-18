AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Growing Storm"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100




function ENT:Initialize()		

    local recentTor = false

    self:Lightning()

	if (CLIENT) then
	
		if LocalPlayer().Sounds == nil then LocalPlayer().Sounds = {} end
		LocalPlayer().Sounds["Rainstorm_IDLE"]         = createLoopedSound(LocalPlayer(), "streams/disasters/nature/heavy_rain_loop.wav")
		LocalPlayer().Sounds["Rainstorm_muffled_IDLE"] = createLoopedSound(LocalPlayer(), "streams/disasters/nature/heavy_rain_loop_muffled.wav")
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
		self.State = "overcasting"
	elseif t_elapsed >= 30 and t_elapsed < 40 then
		self.State = "outflowing" 
	elseif t_elapsed >= 40 and t_elapsed < 60 then
		self.State = "starting"
	elseif t_elapsed >= 60 and t_elapsed < 175 then
		self.State = "tranisitioning" 
	elseif t_elapsed >= 175 and t_elapsed < 200 then
		self.State = "heavyraining"
	elseif t_elapsed >= 200 and t_elapsed < 400 then
	    self.State = "tornado"
	else
		self.State = "dead"
	end
	
	self:StateProcessor()
end

function ENT:StateProcessor()
	
	if self.State == "overcasting" then
		self:Cloudy()
	elseif self.State == "outflowing" then	
		self:Squall()
	elseif self.State == "starting" then
		self:LightRaining()
	elseif self.State == "tranisitioning" then 
		self:LRHRT()
	elseif self.State == "heavyraining" then
		self:HeavyRain()
    elseif self.State == "tornado" then
	    self:TornadoForm()
	elseif self.State == "dead" then
		self:Remove()
	end
		
		
end

function ENT:Cloudy()
	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(2,5),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 98000, ["Temperature"] = math.random(20,21), ["Humidity"]    = math.random(42,45), ["BRadiation"]  = 0.1}}

	
end





function ENT:HailFollowPlayer(ply)
	
	local bounds    = getMapSkyBox()
	local min       = bounds[1]
	local max       = bounds[2]
	local z         = max.z 
	local pos       = ply:GetPos()
	local hitchance = math.Clamp(25 / ( (#player.GetAll()) ),5,50)
	if HitChance( hitchance ) then
			
		if HitChance(99) then
		
			local x = pos.x + math.random(-2000,2000)
			local y = pos.y + math.random(-2000,2000)
			local z = pos.z + 1000
			local hail = ents.Create("gd_d1_hail")
			
			hail:SetPos( Vector(x, y, z ) )
			hail:Spawn()
			hail:Activate()
			hail:GetPhysicsObject():EnableMotion(true)
			hail:GetPhysicsObject():SetVelocity( Vector(0,0,-10000) )
			hail:GetPhysicsObject():AddAngleVelocity( VectorRand() * 100 )
		else
		
			local x = pos.x 
			local y = pos.y
			local z = pos.z + 1000
			local hail = ents.Create("gd_d1_hail")
			
			hail:SetPos( Vector(x, y, z ) )
			hail:Spawn()
			hail:Activate()
			hail:GetPhysicsObject():EnableMotion(true)
			hail:GetPhysicsObject():SetVelocity( Vector(0,0,-10000) )
		end
	end
	

end



			
			
function ENT:Squall()
	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(34,38),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 97000, ["Temperature"] = math.random(14,16), ["Humidity"]    = math.random(62,75), ["BRadiation"]  = 0.1}}

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

function ENT:LightRaining()

	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(34,38),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 96000, ["Temperature"] = math.random(13,16), ["Humidity"]    = math.random(72,76), ["BRadiation"]  = 0.1}}

 
	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
			
			if HitChance(50)  then
				
	
				net.Start("gd_clParticles")
				net.WriteString("localized_light_rain_effect")
				net.Send(v)	
				net.Start("gd_clParticles")
				net.WriteString("light_rain_splash_a")
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





function ENT:LRHRT()

	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(12,27),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 95000, ["Temperature"] = math.random(8,11), ["Humidity"]    = math.random(92,93), ["BRadiation"]  = 0.1}}

	
	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
			
			if math.random(1,2) == 2 then
				if HitChance(50) then
				
					net.Start("gd_clParticles")
					net.WriteString("hail_character_effect_01_main")
					net.Send(v)			
					
				else
					net.Start("gd_clParticles")
					net.WriteString("hail_character_effect_01_main")
					net.Send(v)			
				end
			end
			
			if HitChance(90)  then
				
	
				net.Start("gd_clParticles")
				net.WriteString("downburst_medium_rain_main")
				net.Send(v)	
				net.Start("gd_clParticles")
				net.WriteString("rain_splash_effect")
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


			self:HailFollowPlayer(v)
			
		end
	end
	
	
end


local function Tornadospawn()
	recentTor = true
	local tornado = {"gd_d3_ef0", "gd_d4_ef1", "gd_d5_ef2", "gd_d6_ef3", "gd_d7_ef4", "gd_d8_ef5" }
	EF = ents.Create( tornado[math.random( 1, #tornado )] .. "" )

	EF:SetPos(Vector(math.random(-10000,10000),math.random(-10000,10000),5000))

	EF:Spawn()
end

local function Removemaptornados()
	for k,v in pairs(ents.FindByClass("gd_d3_ef0", "gd_d4_ef1", "gd_d5_ef2", "gd_d6_ef3", "gd_d7_ef4", "gd_d8_ef5")) do
		v:Remove()
	end
end

hook.Add("InitPostEntity","Removemaptornados",function()
	Removemaptornados()
end)

hook.Add("PostCleanupMap","ReRemovemaptornados",function()
	Removemaptornados()
end)

function ENT:HeavyRain()



	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(27,30),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 90000, ["Temperature"] = math.random(10,13), ["Humidity"]    = math.random(82,85), ["BRadiation"]  = 0.1}}
    

	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
			
			if math.random(1,2) == 2 then
				if HitChance(50) then
				
					net.Start("gd_clParticles")
					net.WriteString("hail_character_effect_01_main")
					net.Send(v)			
					
				else
					net.Start("gd_clParticles")
					net.WriteString("hail_character_effect_01_main")
					net.Send(v)			
				end
			end
			
			if HitChance(100)  then
				
	
				net.Start("gd_clParticles")
				net.WriteString("downburst_heavy_rain_main")
				net.Send(v)	
				net.Start("gd_clParticles")
				net.WriteString("heavy_rain_splash_effect")
				net.Send(v)	
		
					
			end
			
			if HitChance(50)  then
				
	
				net.Start("gd_clParticles")
				net.WriteString("downburst_heavy_rain_main")
				net.Send(v)	
				net.Start("gd_clParticles")
				net.WriteString("heavy_rain_splash_effect")
				net.Send(v)	
		
					
			end

			if HitChance(3)  then
				
				
				net.Start("gd_screen_particles")
				net.WriteString("hud/warp_ripple3")
				net.WriteFloat(math.random(5,200))
				net.WriteFloat(math.random(0,100)/100)
				net.WriteFloat(math.random(0,1))
				net.WriteVector(Vector(0,math.random(0,200)/100,0))
				net.Send(v)	

					
			end


			self:HailFollowPlayer(v)
			self:HailFollowPlayer(v)
            self:HailFollowPlayer(v)
			
		end
	end
	


end

function ENT:TornadoForm()

    

	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(45,67),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 90000, ["Temperature"] = math.random(10,13), ["Humidity"]    = math.random(82,85), ["BRadiation"]  = 0.1}}
	if(!recentTor) then
	Tornadospawn()
	return end
	
	for k, v in pairs(player.GetAll()) do

		if v.gDisasters.Area.IsOutdoor then
			
			if HitChance(100)  then
				
	
				net.Start("gd_clParticles")
				net.WriteString("downburst_heavy_rain_main")
				net.Send(v)	
		
					
			end

			if HitChance(3)  then
				
				
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
		
		for k, v in pairs(ents.FindByClass("gd_w2_thunderstorm_cl")) do v:Remove() end
		
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
	
	Removemaptornados()
	
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end






