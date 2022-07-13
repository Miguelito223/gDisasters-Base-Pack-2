AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Heavy Smog"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		
	
	if (SERVER) then
	
		GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=0,["Direction"]=Vector(0,0,0)}, ["Pressure"]    = 96000, ["Temperature"] = math.random(5,10), ["Humidity"]    = math.random(25,45), ["BRadiation"]  = 0.1}}

				
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
			self.Original_SkyData["TopColor"]    = Vector(1, 1, 1)
			self.Original_SkyData["BottomColor"] = Vector(1, 1, 1)
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
		
		setMapLight("g")		
		
		self:SetNoDraw(true)
		
		gDisasters_CreateGlobalGFX("heavyfog", self)
		
		gDisasters_CreateGlobalGFX("heavyfog", self)


		local data = {}
			data.Color = Color(100,100,100)
			data.DensityCurrent = 0.5
			data.DensityMax     = 1
			data.DensityMin     = 0.5
			data.EndMax         = 100050
			data.EndMin         = 0
			data.EndMinCurrent  = 0
			data.EndMaxCurrent  = 0       

		gDisasters_CreateGlobalFog(self, data, false)	
		
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


function ENT:AffectPlayers()
	for k, v in pairs(player.GetAll()) do
	
		
		if v.gDisasters.Area.IsOutdoor then
			if math.random(1,15)==15 then
				net.Start("gd_screen_particles")
				net.WriteString("hud/warp_ripple3")
				net.WriteFloat(math.random(5,128))
				net.WriteFloat(math.random(0,100)/100)
				net.WriteFloat(math.random(0,1))
				net.WriteVector(Vector(0,2,0))
				net.Send(v)	
			end
			
			if v.gDisasters.Area.IsOutdoor then
			
			if math.random(1,2000)== 1 then
			
				InflictDamage(v, self, "cold", math.random	(1,3))
				
				sound.Play( "streams/disasters/player/cough.wav", v:GetPos(), 70 )
			
			end
			
		end
			
		end
	end
end

function ENT:AffectNpcs()
	for k, v in pairs(ents.GetAll()) do
		if v:IsNPC() then 
			if math.random(1,2000)== 1 then
			
				InflictDamage(v, self, "cold", math.random	(1,3))
			
			end
		end
	end	
end
			





function ENT:Think()
	if (SERVER) then
		if !self:IsValid() then return end
		self:AffectPlayers()
		self:AffectNpcs()
			
		self:NextThink(CurTime() + 0.01)
		return true
	end
end

function ENT:OnRemove()

	if (SERVER) then		
		local resetdata = self.Reset_SkyData
		for i=0, 40 do
			timer.Simple(i/100, function()
				paintSky_Fade(resetdata,0.05)
			end)
		end
		GLOBAL_SYSTEM_TARGET=GLOBAL_SYSTEM_ORIGINAL
		setMapLight("t")	
	end
	
	
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end






