AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Blizzard"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		

	
	if (SERVER) then
	
	GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(26,76),["Direction"]=Vector(1,0,0)}, ["Pressure"]    = 97000, ["Temperature"] = math.random(-26,-5), ["Humidity"]    = math.random(20,45), ["BRadiation"]  = 0.1}}

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
	
	self.CreatedDecals = false

	local data = {}
		data.Color = Color(155,155,155)
		data.DensityCurrent = 0
		data.DensityMax     = 0.5
		data.DensityMin     = 0.1
		data.EndMax         = 2000
		data.EndMin         = 1000
		data.EndMinCurrent  = 0
		data.EndMaxCurrent  = 0       

	gDisasters_CreateGlobalFog(self, data, true)	
	
	--gDisasters_CreateGlobalGFX("heavyrain", self)						
		
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

			if HitChance(0.1) then
				net.Start("gd_screen_particles")
				net.WriteString("hud/snow")
				net.WriteFloat(math.random(5,128))
				net.WriteFloat(math.random(0,100)/100)
				net.WriteFloat(math.random(0,1))
				net.WriteVector(Vector(0,2,0))
				net.Send(v)	
			end
			
			net.Start("gd_clParticles")
			net.WriteString("localized_blizzard_effect")
			net.Send(v)			
		end
	end
end

function ENT:CreateSnowDecals()
	if self.CreatedDecals then return end
	self.CreatedDecals = true
	if GetConVar("gdisasters_experimental_overdraw"):GetInt() != 1 then return end

	for i=0, 25 do
	
		local bounds    = getMapSkyBox()
		local min       = bounds[1]
		local max       = bounds[2]
		
		local startpos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,  max.z )
		local tr = util.TraceLine( {
			start = startpos,
			endpos = startpos - Vector(0,0,50000),
		} )	
		
		
		util.Decal("snow", tr.HitPos + tr.HitNormal,  tr.HitPos - tr.HitNormal)
		
	end
end

function ENT:Think()
	if (SERVER) then
		if !self:IsValid() then return end
		self:AffectPlayers()
		self:CreateSnowDecals()
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
	
	
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end






