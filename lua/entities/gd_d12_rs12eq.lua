AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Earthquake Magnitude 12.0"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Material                         = "models/rendertarget"        
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
		local phys = self:GetPhysicsObject()
		

		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		

		self.Child = createEarthquake(12, self)
				
		
		self:Explode()
		
		
	end
end

function ENT:Explode()
	CreateSoundWave("streams/disasters/earthquake/earthquake_aftershock.wav", self:GetPos(), "3d" ,340.29/2, {70,130}, 20)
	CreateSoundWave("streams/disasters/earthquake/earthquake_aftershock.wav", self:GetPos(), "3d" ,340.29/2.1, {80,130}, 20)
	
			
	ParticleEffect("earthquake_swave_main", self:GetPos() + Vector(0,0, 10), Angle(0,0,0), nil)
	for k, v in pairs(ents.GetAll()) do 
	
		local phys = v:GetPhysicsObject()
		local dis  = v:GetPos():Distance(self:GetPos())
		local t    = dis  / convert_MetoSU( 340.29 / 2 )
		
		if phys:IsValid()  and  (v:GetClass()!= "phys_constraintsystem" and v:GetClass()!= "phys_constraint"  and v:GetClass()!= "logic_collision_pair") then
			
			timer.Simple(t, function()
				
				if !v:IsValid() then return end 
				
				if v:IsNPC() or v:IsPlayer() or v:IsNextBot() then 
					v:SetVelocity( Vector(0,0,1200)) 
				else
					phys:AddVelocity( Vector(0,0,1000) )
				end
			
			end)
		end
		
	end
	
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * -0.2  ) 
	ent:Spawn()
	ent:Activate()
	return ent
end



function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate
		

		self:NextThink(CurTime() + t)
		return true
	end
end

function ENT:OnRemove()
end

function ENT:Draw()



	self:DrawModel()
	
end




