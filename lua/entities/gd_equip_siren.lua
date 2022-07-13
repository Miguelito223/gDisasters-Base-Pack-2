AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Siren"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"


ENT.Mass                             =  150


sound.Add( {
	name = "loudtornadosiren",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 110,
	pitch = { 90, 115 },
	sound = "streams/sirens/tornado_siren.mp3"
} )


function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel("models/tornado_siren.mdl")
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


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 10   ) 
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Alarm()
	self:EmitSound("loudtornadosiren")
	
end 



function ENT:Think()
	if (SERVER) then 
		for k, v in pairs(ents.FindByClass("env_tornado")) do 
			
			
			if v:IsValid() and CurTime() >= self.NextAvailableSoundEmission then 
				self.NextAvailableSoundEmission = CurTime() + 120
				
				timer.Simple(v:GetPos():Distance(self:GetPos())/6000, function()
					if !self:IsValid() then return end 
					self:Alarm()
				end)
		
			end 
			
		end 
	
	
	end 
end

function ENT:OnRemove()
	self:StopSound("loudtornadosiren")
end

function ENT:Draw()



	self:DrawModel()
	
end




