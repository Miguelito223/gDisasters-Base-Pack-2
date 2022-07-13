AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Beaufort 9 Wind"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      
ENT.Mass                             =  100

function ENT:Initialize()		
	
	
	if (SERVER) then
	
		GLOBAL_SYSTEM_TARGET =  {["Atmosphere"] 	= {["Wind"]        = {["Speed"]=(88),["Direction"]=Vector(0,1,0)}, ["Pressure"]    = 103000, ["Temperature"] = math.random(25,38), ["Humidity"]    = math.random(10,25), ["BRadiation"]  = 0.1}}

			
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
		GLOBAL_SYSTEM_TARGET=GLOBAL_SYSTEM_ORIGINAL	
	end
	
	
	
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end






