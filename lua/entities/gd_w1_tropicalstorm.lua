	AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Tropical Storm"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		
		
	if (CLIENT) then
		
		if LocalPlayer().Sounds == nil then LocalPlayer().Sounds = {} end
		LocalPlayer().Sounds["Rainstorm_IDLE"]         = createLoopedSound(LocalPlayer(), "disasters/nature/heavy_rain_loop.wav")
		LocalPlayer().Sounds["Rainstorm_muffled_IDLE"] = createLoopedSound(LocalPlayer(), "disasters/nature/heavy_rain_loop_muffled.wav")
	end
	
	if (SERVER) then
	
		GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(63,118),["Direction"]=Vector(-1,0,0)}, ["Pressure"]    = 95000, ["Temperature"] = math.random(10,15), ["Humidity"]    = math.random(40,85), ["BRadiation"]  = 0.1}}
		
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
			self.Original_SkyData["TopColor"]    = Vector(0.2, 0.2, 0.2)
			self.Original_SkyData["BottomColor"] = Vector(0.2, 0.2, 0.2)
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


function ENT:AffectPlayers()

	for k, v in pairs(player.GetAll()) do
	
		if v.gDisasters.Area.IsOutdoor then
		
			net.Start("gd_clParticles")
			net.WriteString("localized_rain_effect", Angle(0,math.random(1,40),0))
			net.Send(v)
			

			if math.random(1,2) == 1 then
				net.Start("gd_screen_particles")
				net.WriteString("hud/warp_ripple3")
				net.WriteFloat(math.random(5,228))
				net.WriteFloat(math.random(0,100)/100)
				net.WriteFloat(math.random(0,1))
				net.WriteVector(Vector(0,math.random(0,200)/100,0))
				net.Send(v)	
			end
			
		end
	end
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
		
		if math.random(1,2500)==1 then surface.PlaySound("disasters/nature/thunder"..tostring(math.random(1,3))..".wav") end 
		
		
	end
	if (SERVER) then
		if !self:IsValid() then return end
		self:AffectPlayers()
		
		local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate
		

		self:NextThink(CurTime() + t)
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






