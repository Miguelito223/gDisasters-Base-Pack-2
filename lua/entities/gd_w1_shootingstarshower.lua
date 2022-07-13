AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Shooting Star Shower"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

    
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"

function ENT:Initialize()	

	if (SERVER) then

			
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		self:SetModelScale(2.5, 0)		
		
		
		for k, v in pairs( ents.FindByClass( "env_sun" ) ) do
		v:Fire( "TurnOff", "", 0 )
		
		end
		
		local phys = self:GetPhysicsObject()
		
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 
		
		self:SetNoDraw(true)
		
		self.Original_SkyData = {}
			self.Original_SkyData["TopColor"]    = Vector(0,0,0)
			self.Original_SkyData["BottomColor"] = Vector(0,0,0)
			self.Original_SkyData["SunSize"]     = 0.00
			self.Original_SkyData["DuskScale"]      = 0.00
			self.Original_SkyData["DuskIntensity"]   = 0.00
			self.Original_SkyData["SunColor"]       = Vector(0,0,0)
			self.Original_SkyData["StarScale"]       = 1
			self.Original_SkyData["StarFade"]        = 2

			
			
			
		self.Reset_SkyData    = {}
			self.Reset_SkyData["TopColor"]       = Vector(0.20,0.50,1.00)
			self.Reset_SkyData["BottomColor"]    = Vector(0.80,1.00,1.00)
			self.Reset_SkyData["SunSize"]     	 = 2
			self.Reset_SkyData["DuskScale"]      = 1
			self.Reset_SkyData["DuskIntensity"]  = 1
			self.Reset_SkyData["SunColor"]       = Vector(0.20,0.10,0.00)
			self.Reset_SkyData["StarScale"]      = 0.5
			self.Reset_SkyData["StarFade"]       = 1.5
			
			
			setMapLight("g")		
			
		
		for i=0, 100 do
			timer.Simple(i/100, function()
				if !self:IsValid() then return  end
				paintSky_Fade(self.Original_SkyData, 0.05)
			end)
		end

		local data = {}
			data.Color = Color(0,0,0)
			data.DensityCurrent = 0.7
			data.DensityMax     = 0.7
			data.DensityMin     = 0.7
			data.EndMax         = 0
			data.EndMin         = 0
			data.EndMinCurrent  = 0
			data.EndMaxCurrent  = 0       

		gDisasters_CreateGlobalFog(self, data, true)	
		
		--self.Night = {}
		
		--self:FogSpawn()
		
	end
end


function ENT:SpawnStar()

	if HitChance(24) then
	
		local bounds    = getMapSkyBox()
		local min       = bounds[1]
		local max       = bounds[2]
		
		local startpos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,   max.z )

			
		local tr = util.TraceLine( {
		start  = startpos,
		endpos    = startpos + Vector(0,0,50000),
		} )

		if #ents.FindByClass("gd_d2_shootingstar") < 1 then 
		
		
			

			local star = ents.Create("gd_d2_shootingstar_ch")
			star:Spawn()
			star:Activate()	
			star:SetPos( tr.HitPos )
			star:GetPhysicsObject():EnableMotion(true)
			star:GetPhysicsObject():AddAngleVelocity( VectorRand() * 100 )
			
			timer.Simple( math.random(14,18), function()
				if star:IsValid() then star:Remove() end
				
			end)
			
		
		end
	
	end

	
	
end

function ENT:Think()
	if (SERVER) then
		local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1
	
		if !self:IsValid() then return end
		self:SpawnStar()
		self:NextThink(CurTime() + t)
		return true
	end
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	if GetConVar("gdisasters_atmosphere"):GetInt() <= 0 then return end
	
	if #ents.FindByClass("gd_w*") >= 1 then return end
	
	if #ents.FindByClass("gd_d2_shootingstarshower") >= 1 then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal    ) 
	ent:Spawn()
	ent:Activate()
	return ent
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
		
		for k, v in pairs( ents.FindByClass( "env_sun" ) ) do
		v:Fire( "TurnOn", "", 0 )
		
		end
		
		setMapLight("t")	
	end

end

function ENT:Draw()



	self:DrawModel()
	
end


