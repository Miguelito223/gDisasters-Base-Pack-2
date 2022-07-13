AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Radio"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"


ENT.Mass                             =  30


sound.Add( {
	name = "radarwarning",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 70,
	pitch = { 100, 102 },
        sound = {"streams/eas.mp3","streams/easthree.mp3","streams/eastwo.mp3"}
} )


function ENT:Initialize()	
	if (SERVER) then
		
		self:SetModel("models/props_lab/reciever01d.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)	


		local phys = self:GetPhysicsObject()
		
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
			phys:Wake()
			phys:EnableMotion(true)
		end 		
		
		self.NextAvailableSoundEmission = CurTime()
	end
end

function ENT:Alarm()
	self:EmitSound("radarwarning")
	
end 



function ENT:Think()
	if (CLIENT) then
	
	for k, v in pairs(ents.FindByClass("env_tornado")) do 	

	local function Light()

				local dlight = DynamicLight( self:EntIndex() )
					if ( dlight ) then
						dlight.pos = self:LocalToWorld(Vector(0,0,0))
						dlight.r = 255
						dlight.g = 0
						dlight.b = 0
						dlight.brightness = 6
						dlight.Decay = 5
						dlight.Size = 40
						dlight.DieTime = CurTime() + 0.1
					end
	
			end

if v:IsValid() then
	Light()
	end
	
	
	end
	
end	
	if (SERVER) then 


	for k, v in pairs(ents.FindByClass("env_tornado")) do 	
	
	if v:IsValid() and CurTime() >= self.NextAvailableSoundEmission then 
				self.NextAvailableSoundEmission = CurTime() + 80
				
				timer.Simple(v:GetPos():Distance(self:GetPos())/4000, function()
					if !self:IsValid() then return end 
					self:Alarm()
				end)
		
			end

			
			end
		
	
	end 
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end

function ENT:OnRemove()
	self:StopSound("radarwarning")
end

function ENT:Draw()

	self:DrawModel()
	
end




