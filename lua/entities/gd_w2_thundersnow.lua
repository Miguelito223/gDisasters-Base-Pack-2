AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Thundersnow"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		

	
	if (SERVER) then
	
		GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(35,50),["Direction"]=Vector(1,0,0)}, ["Pressure"]    = 93500, ["Temperature"] = math.random(-8,-2), ["Humidity"]    = math.random(45,67), ["BRadiation"]  = 0.1}}

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
		
	self:CreateSnowDecals()
	self:Lightning()
	setMapLight("d")		
	
	self:SetNoDraw(true)

	local data = {}
		data.Color = Color(155,155,155)
		data.DensityCurrent = 0.3
		data.DensityMax     = 0.5
		data.DensityMin     = 0.1
		data.EndMax         = 2000
		data.EndMin         = 1000
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

			net.Start("gd_screen_particles")
			net.WriteString("hud/snow")
			net.WriteFloat(math.random(5,128))
			net.WriteFloat(math.random(0,100)/100)
			net.WriteFloat(math.random(0,1))
			net.WriteVector(Vector(0,2,0))
			net.Send(v)		
			
			if math.random(1,3) == 2 then
				net.Start("gd_clParticles")
				net.WriteString("localized_snow_effect", Angle(0,math.random(40,60),0))
				net.Send(v)	
			end
			
			net.Start("gd_clParticles")
			net.WriteString("localized_snow_effect", Angle(0,math.random(40,60),0))
			net.Send(v)	
			net.Start("gd_clParticles_ground")
			net.WriteString("heavy_snow_ground_effect", Angle(0,math.random(40,60),0))
			net.Send(v)	
            
			
		end
	end
	
end

function ENT:CreateSnowDecals()
	for k, v in pairs(player.GetAll()) do
		net.Start("gd_createdecals")
		net.WriteString("snow")
		net.WriteBool(self.CreatedDecals)
		net.Send(v)
	end
end

function ENT:Think()
	if (SERVER) then
		if !self:IsValid() then return end
		self:AffectPlayers()
		self:NextThink(CurTime() + 0.01)
		return true
	end
	if (CLIENT) then
	
		
		local muffled_volume = math.Clamp(1 - ( LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8), 0, 1) - 0.25
		local idle_volume = math.Clamp(( LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)-0.25, 0, 1)
		
		if   LocalPlayer().Sounds["Rainstorm_muffled_IDLE"]!=nil then
			 LocalPlayer().Sounds["Rainstorm_muffled_IDLE"]:ChangeVolume(muffled_volume, 0)
		end
		
		if   LocalPlayer().Sounds["Rainstorm_IDLE"]!=nil then
			 LocalPlayer().Sounds["Rainstorm_IDLE"]:ChangeVolume(idle_volume, 0)
		end
		
		if math.random(1,500)==1 then surface.PlaySound("streams/disasters/nature/thunder"..tostring(math.random(1,3))..".wav") end 
		
		
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






