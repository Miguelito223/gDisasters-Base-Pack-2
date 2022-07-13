AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "CLOUD"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.Models                           =  {"models/ramses/models/clouds/cumulus_a.mdl","models/ramses/models/clouds/cumulus_c.mdl"}

ENT.Rendergroup                     = RENDERGROUP_BOTH

ENT.FadeInTime                       = 0.40 
ENT.FadeOutTime                      = 0.40 
ENT.FadeInBias                       = 1 
ENT.LifeMin                          = 10 
ENT.LifeMax                          = 20 
ENT.AlphaMax                         = 100
ENT.LightningLightFadeTime           = 1 

function ENT:Initialize()	

	self.StartTime = CurTime()
	
	if (CLIENT) then
	
		local w_l = math.Clamp(math.random() * 2,1,2)
		local h   = math.Clamp(math.random() * 2,1,2)
		self:SetMDScale(Vector(w_l,w_l ,h  ))
		

	
	end
	
	
	if (SERVER) then
		
		self.Life = math.random(self.LifeMin, self.LifeMax)	
		
	if math.random(1,8) == 1 then	
		self:SetModelScale(math.random(0.5,1), 0)
		self:SetModel(table.Random(self.Models))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

		self:SetAngles( Angle(0,math.random(1,180), 0))
		self:SetColor(self.DefaultColor)
		
		self:AtmosphericReposition()
		
		--self:SetNoDraw(true)
		
		end
	end
end

function ENT:FadeInOutControler()

	local t        = CurTime() - self.StartTime

	local alpha_in  = math.Clamp(  t / (self.FadeInTime  * self.Life), 0,1)^self.FadeInBias
	local alpha_out = math.Clamp( (t - (self.Life - (self.FadeOutTime * self.Life))) / (self.FadeOutTime * self.Life), 0,1)^self.FadeInBias
	
	
	local color = self:GetColor() 
	self:SetColor(Color(color.r, color.g, color.b,  (alpha_in - alpha_out) * self.AlphaMax)) 
end

function ENT:AddLightningLight(color)
	self.StartTime_LightningLight = CurTime()

end

function ENT:LightningLightColorController()
	
	if !self.StartTime_LightningLight then return end 
	
	local t     = CurTime() - self.StartTime_LightningLight
	local alpha = 1 - math.Clamp(t / self.LightningLightFadeTime, 0,1) ^ 2 
	local new_color = Vector(self.AddColor.x * alpha, self.AddColor.y * alpha, self.AddColor.z * alpha, 255 ) 
	self.AddColor = new_color 
	

end

function ENT:AtmosphericReposition()
	local max_height_below_ceiling, min_height_below_ceiling = 20000, 15000
	
	local ceiling_multiplier = math.abs(   getMapBounds()[2].z -  getMapBounds()[1].z ) / 27625 

	local height = math.random(min_height_below_ceiling * ceiling_multiplier, max_height_below_ceiling * ceiling_multiplier)
	
	local bounds    = getMapSkyBox()
	local min       = bounds[1]
	local max       = bounds[2]
	
	local spawnpos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,  max.z - height )

		
	self:SetPos( spawnpos * -0.7 )
	
	

end


function ENT:SetMDScale(scale)
	local mat = Matrix()
	mat:Scale(scale)
	self:EnableMatrix("RenderMultiply", mat)
end

function ENT:MoveCloud()
	local wind_speed, wind_dir = GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"], GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Direction"]
	local next_pos = self:GetPos() + (wind_dir * (wind_speed/10))
	self:SetPos(next_pos)
end


function ENT:Think()
	if (CLIENT) then 
		self:LightningLightColorController()
	end
	
	if (SERVER) then
		if !self:IsValid() then return end
		
		
		self:FadeInOutControler()
		self:MoveCloud()
		self:NextThink(CurTime() + 0.01)
		return true
	end
end

function ENT:OnRemove()
end

function ENT:Draw()

	self:DrawModel()	

end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end


