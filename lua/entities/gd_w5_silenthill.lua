AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Silent Hill"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		
	
	if (SERVER) then
	
		GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(2,5),["Direction"]=Vector(math.random(-1,1),math.random(-1,1),0)}, ["Pressure"]    = 97000, ["Temperature"] = math.random(5,15), ["Humidity"]    = math.random(20,45), ["BRadiation"]  = 0.1, ["Oxygen"]  = 100}}

		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(self.Mass)
		end 
		
		self.Original_SkyData = {}
			self.Original_SkyData["TopColor"]    = Vector(1, 1, 1)
			self.Original_SkyData["BottomColor"] = Vector(1, 1, 1)
			self.Original_SkyData["DuskScale"]   = 0

		self.Reset_SkyData    = {}
			self.Reset_SkyData["TopColor"]       = Vector(0.20,0.50,1.00)
			self.Reset_SkyData["BottomColor"]    = Vector(0.80,1.00,1.00)
			self.Reset_SkyData["DuskScale"]      = 1
			self.Reset_SkyData["SunColor"]       = Vector(0.20,0.10,0.00)		
		self.Darkness_SkyData    = {}
			self.Darkness_SkyData["TopColor"]       = Vector(0.02,0.02,0.02)
			self.Darkness_SkyData["BottomColor"]    = Vector(0.01,0.01,0.01)
			self.Darkness_SkyData["DuskScale"]      = 0
			self.Darkness_SkyData["SunColor"]       = Vector(0,0,0)
			
		for i=0, 100 do
			timer.Simple(i/100, function()
				if !self:IsValid() then return  end
				paintSky_Fade(self.Original_SkyData, 0.05)
			end)
		end
		
		self:SetNWBool("FogType", false)
		
		timer.Simple(25, function()
			if self:IsValid() then self:CreateDarkness(true) end 
		end)
		
		timer.Simple(240, function()
			if self:IsValid() then self:CreateDarkness(false)end 
		end)			
		
			


		local data = {}
			data.Color = Color(255,255,255)
			data.DensityCurrent = 0
			data.DensityMax     = 5000
			data.DensityMin     = 5000
			data.EndMax         = 100
			data.EndMin         = 0.90
			data.EndMinCurrent  = 0
			data.EndMaxCurrent  = 0       

		
		gDisasters_CreateGlobalFog(self, data, true)	
		
		
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
	
		local outdoor = isOutdoor(v)
		net.Start("gd_isOutdoor")
		net.WriteBool(outdoor)
		net.Send(v)
		
		if self:GetNWBool("FogType", false)==false then
		
			if outdoor then
				if math.random(1,40)==40 then
					net.Start("gd_screen_particles")
					net.WriteString("hud/snow")
					net.WriteFloat(math.random(5,428))
					net.WriteFloat(math.random(0,100)/100)
					net.WriteFloat(math.random(0,1))
					net.WriteVector(Vector(0,2,0))
					net.Broadcast(v)	
				end
				if math.random(1,3)==1 then
					net.Start("gd_clParticles")
					net.WriteString("localized_ash_effect", Angle(0,math.random(1,40),0))
					net.Send(v)		
				end
			end
		
		end
	end
end

function ENT:CreateDarkness(bool)

	if bool == true then
	
		for k, ply in pairs(player.GetAll()) do	
			clPlaySound(ply, "streams/disasters/silenthill/darkness_warning.mp3", 100, 1)
		end
		
		timer.Simple(20, function()
			if !self:IsValid() then return end

			
			for k, ply in pairs(player.GetAll()) do	
				clShakeScreen(ply, 10)
			end

					
				
			timer.Simple(8, function()
				if !self:IsValid() then return end
				
				setMapLight("a")
				self:SetNWBool("FogType", true)
								
		
				for i=0, 100 do
					timer.Simple(i/100, function()
						if !self:IsValid() then return  end
						paintSky_Fade(self.Darkness_SkyData, 0.05)
					end)
				end
			end)

		end)
		
		timer.Simple(31, function()
			if !self:IsValid() then return end
			for k, ply in pairs(player.GetAll()) do	
				net.Start("gd_clParticles")
				net.WriteString("darkness_arriving_main", Angle(0,math.random(0,1),0))
				net.Send(ply)	
				clPlaySound(ply, "streams/disasters/silenthill/darkness_arrival.mp3", 100, 1)
			end
			
			timer.Simple(23.3, function()
				if !self:IsValid() then return end
				net.Start("gd_darkness_stun")
				net.WriteFloat(4)
				net.WriteFloat(0.4)
				net.WriteFloat(0.5)
				net.Broadcast()
			end)
			
		end)
		

	else
		setMapLight("r")
		self:SetNWBool("FogType", false)

		for i=0, 100 do
			timer.Simple(i/100, function()
				if !self:IsValid() then return  end
				paintSky_Fade(self.Original_SkyData, 0.05)
			end)
		end
	end

	
end

function ENT:SwitchFog()
	
	local fogtype = self:GetNWBool("FogType", false)

	if fogtype != self.LastFogType then 
		
		if fogtype == true then -- darkness
		
			LocalPlayer().isOutside = false
	
			
			timer.Simple(1, function()
			

				LocalPlayer().gDisasters.Fog.Data.Color = Color(25,25,25)
				LocalPlayer().gDisasters.Fog.Data.DensityCurrent = 0
				LocalPlayer().gDisasters.Fog.Data.DensityMax     = 5000
				LocalPlayer().gDisasters.Fog.Data.DensityMin     = 5000
				LocalPlayer().gDisasters.Fog.Data.EndMax         = 100
				LocalPlayer().gDisasters.Fog.Data.EndMin         = 0.9
				LocalPlayer().gDisasters.Fog.Data.EndMinCurrent  = 0
				LocalPlayer().gDisasters.Fog.Data.EndMaxCurrent  = 0       
				
			end)
			
		else
		
			LocalPlayer().isOutside = false



			timer.Simple(1, function()
				
				LocalPlayer().gDisasters.Fog.Data.Color = Color(255,255,255)
				LocalPlayer().gDisasters.Fog.Data.DensityCurrent = 0
				LocalPlayer().gDisasters.Fog.Data.DensityMax     = 5000
				LocalPlayer().gDisasters.Fog.Data.DensityMin     = 5000
				LocalPlayer().gDisasters.Fog.Data.EndMax         = 100
				LocalPlayer().gDisasters.Fog.Data.EndMin         = 0.97
				LocalPlayer().gDisasters.Fog.Data.EndMinCurrent  = 0
				LocalPlayer().gDisasters.Fog.Data.EndMaxCurrent  = 0       
			
			end)

			
		end
		
		
		
	end
	
	
	self.LastFogType = self:GetNWBool("FogType", false)
end


function ENT:CreateEnemies()
	if self:GetNWBool("FogType")!=true then return end
	
	if math.random(1,1000)==1000 then
		
		for k, v in pairs(player.GetAll()) do
		
			local vec = Vector(VectorRand()[1],VectorRand()[2], 0) * math.random(200,2500)
			
			local tr = util.TraceLine( {
				start = v:GetPos() + vec + Vector(0,0,100),
				endpos = v:GetPos() + vec - Vector(0,0,500),
				filter = v 
			} )
			
		
			if tr.Hit then 
				local nurse = ents.Create("gd_npc_nurse")
				nurse:SetPos(tr.HitPos)
				nurse:Spawn()
				nurse:Activate()
			
				
			else
			
			end
			
		end
		
		
	end

end




function ENT:Think()
	if (CLIENT) then
		self:SwitchFog()
		
	end
	if (SERVER) then
		if !self:IsValid() then return end
		self:AffectPlayers()
		self:CreateEnemies()
		
		local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate
		

		self:NextThink(CurTime() + t)
		return true
	end
end

function ENT:OnRemove()

	if (SERVER) then		
		local resetdata = self.Reset_SkyData
		GLOBAL_SYSTEM_TARGET=GLOBAL_SYSTEM_ORIGINAL
		setMapLight("r")
		for i=0, 40 do
			timer.Simple(i/100, function()
				paintSky_Fade(resetdata,0.05)
			end)
		end
	end
	
	if (CLIENT) then
		
		
		timer.Simple(0.5, function()
			if !LocalPlayer():IsValid() then return end
		end)

	end
	
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end


