AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Hailstorm"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		

	
	if (SERVER) then
	
		GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(0,0),["Direction"]=Vector(0,0,0)}, ["Pressure"]    = 10000, ["Temperature"] = math.random(15,15), ["Humidity"]    = math.random(0,0), ["BRadiation"]  = 0.1}}

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
	


	local data = {}
		data.Color = Color(115,115,185)
		data.DensityCurrent = 0
		data.DensityMax     = 0.2
		data.DensityMin     = 0.1
		data.EndMax         = 2000
		data.EndMin         = 1000
		data.EndMinCurrent  = 0
		data.EndMaxCurrent  = 0       

	--gDisasters_CreateGlobalFog(self, data, true)	
	
	--gDisasters_CreateGlobalGFX("coldwave", self)						
		
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
			if math.random(1,100)==100 then
				net.Start("gd_screen_particles")
				net.WriteString("hud/snow")
				net.WriteFloat(math.random(5,128))
				net.WriteFloat(math.random(0,100)/100)
				net.WriteFloat(math.random(0,1))
				net.WriteVector(Vector(0,2,0))
				net.Send(v)	
			end
			if math.random(1,100)==100 then
			
				net.Start("gd_clParticles")
				net.WriteString("localized_snow_effect")
				net.Send(v)			
			end
			
			self:HailFollowPlayer(v)
			
		end
	end
end

function ENT:HailFollowPlayer(ply)
	
	local bounds    = getMapSkyBox()
	local min       = bounds[1]
	local max       = bounds[2]
	local z         = max.z 
	local pos       = ply:GetPos()
	local hitchance = math.Clamp(50 / ( (#player.GetAll()) ),5,50)
	
	if HitChance( hitchance ) then
			
		if HitChance(95) then
		
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


function ENT:Think()
	if (SERVER) then
		if !self:IsValid() then return end
		self:AffectPlayers()

		
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






