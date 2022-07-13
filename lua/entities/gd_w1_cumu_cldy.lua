AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Cumulus Cloudy"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		
	
	
	if (SERVER) then
	
		GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(1,3),["Direction"]=Vector(0,0,0)}, ["Pressure"]    = 103000, ["Temperature"] = math.random(15,20), ["Humidity"]    = math.random(10,25), ["BRadiation"]  = 0.1}}

			
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
			self.Original_SkyData["StarTexture"] = "skybox/clouds"
			
		self.Reset_SkyData    = {}
			self.Reset_SkyData["TopColor"]       = Vector(0.20,0.50,1.00)
			self.Reset_SkyData["BottomColor"]    = Vector(0.80,1.00,1.00)
			self.Reset_SkyData["DuskScale"]      = 1
			self.Reset_SkyData["SunColor"]       = Vector(0.20,0.10,0.00) --self.Reset_Skydata["StarTexture"] = "skybox/stars"
			self.Reset_SkyData["StarTexture"] = "skybox/clouds"
		
		for i=0, 100 do
			timer.Simple(i/100, function()
				if !self:IsValid() then return  end
				paintSky_Fade(self.Original_SkyData, 0.05)
			end)
		end
		
		self.NextCloudCreation = CurTime()
		
		self.Cloud = {}

		setMapLight("g")		
		gDisasters_CreateGlobalGFX("heavyfog", self)

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

function ENT:CreateClouds()

	if CurTime() < self.NextCloudCreation then return end 
	
	self.NextCloudCreation = CurTime() + 0.1
	
	local cloud = ents.Create("gd_cloud_cumulus")
	cloud:Spawn()
	cloud:Activate()
	table.insert(self.Cloud, cloud)

	
end	

function ENT:Think()

	if (CLIENT) then
		
	end
	
	if (SERVER) then
		if !self:IsValid() then return end
		self:CreateClouds()
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
		
		for k, v in pairs(self.Cloud) do
			if v:IsValid() then v:Remove() end
		end
	end
	
	
	
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end






