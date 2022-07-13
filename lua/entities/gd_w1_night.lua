AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Night"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/ramses/models/space/skysphere.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()	

if (CLIENT) then
		local scale = (2.5)
		self:SetMDScale(Vector(scale,scale,scale))
	
	end	
	
	
	if (SERVER) then
	
		GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=math.random(1,3),["Direction"]=Vector(0,0,0)}, ["Pressure"]    = 103000, ["Temperature"] = math.random(5,10), ["Humidity"]    = math.random(10,25), ["BRadiation"]  = 0.1}}

			
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
			self.Original_SkyData["TopColor"]    = Vector(0,0,0)
			self.Original_SkyData["BottomColor"] = Vector(0,0,0)
			self.Original_SkyData["SunSize"]     = 0.00
			self.Original_SkyData["OverlaySize"]  = 0.00
			self.Original_SkyData["DuskScale"]      = 0.00
			self.Original_SkyData["DuskIntensity"]      = 0.00
			self.Original_SkyData["SunColor"]       = Vector(1.00,1.00,1.00)
			
			
			
		self.Reset_SkyData    = {}
			self.Reset_SkyData["TopColor"]       = Vector(0.20,0.50,1.00)
			self.Reset_SkyData["BottomColor"]    = Vector(0.80,1.00,1.00)
			self.Reset_SkyData["DuskScale"]      = 1
			self.Reset_SkyData["SunColor"]       = Vector(0.20,0.10,0.00)
			
			setMapLight("g")		
		gDisasters_CreateGlobalGFX("heavyfog", self)
		

		
		for i=0, 100 do
			timer.Simple(i/100, function()
				if !self:IsValid() then return  end
				paintSky_Fade(self.Original_SkyData, 0.05)
			end)
		end

	end
end

function ENT:SetMDScale(scale)
	local mat = Matrix()
	mat:Scale(scale)
	self:EnableMatrix("RenderMultiply", mat)
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

function ENT:Think()

	if (CLIENT) then
		
	end
	
	if (SERVER) then
		if !self:IsValid() then return end
	
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






