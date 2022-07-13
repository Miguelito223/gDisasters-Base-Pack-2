AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Ice"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Material                         = "nature/ice"        
ENT.Mass                             =  100
ENT.Models                           =  {"models/props_debris/concrete_spawnplug001a.mdl"}
ENT.RENDERGROUP                      = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()	
	if (CLIENT) then
		self:SetMDScale(Vector(1,1,0))
	end
	
	if (SERVER) then
		
		self:SetModel(table.Random(self.Models))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:SetMaterial(self.Material)
		local phys = self:GetPhysicsObject()
		
		self:SetTrigger( true )

		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		
		self:SetModelScale( math.random(1,2) ) 
		self:SetAngles( Angle(0,math.random(1,180), 0))

		self.TouchedEntities = {}

		
		
		
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
	ent:SetPos( tr.HitPos + tr.HitNormal    ) 
	ent:Spawn()
	ent:Activate()
	return ent
end






function ENT:Touch( entity )
	
	if self.TouchedEntities[entity]==nil then

		self.TouchedEntities[entity] = {entity, entity:GetVelocity(), CurTime()}
	else 

		self.TouchedEntities[entity][3] = CurTime()
	end
	
end

function ENT:DoIceSkating()
	local vel_mod = 66.66666 / (1/engine.TickInterval())
	local i       = 1

	for k, v in pairs(self.TouchedEntities) do
		if v[1]:IsValid() then
		
			local ent          = v[1] 
			local vel          = v[2]
			local time_elapsed = CurTime() - v[3]
			local timeout      = time_elapsed > 0.2
			local vel_diff     =  (vel_mod * vel) - ent:GetVelocity() 
			

			if timeout then 
				
				self.TouchedEntities[ent] = nil 
				
			else
				if ent:IsPlayer() or ent:IsNPC() then
					
					ent:SetVelocity( vel_diff )
				else
					if ent:GetPhysicsObject():IsValid() then
					
						ent:GetPhysicsObject():SetVelocity( vel ) 
					
					
					end
					
				end
				
				
			
			end
		end
		i = i + 1
	end
	
end

function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		self:DoIceSkating()
		
		self:NextThink(CurTime() + 0.01)
		return true
	end
end

function ENT:OnRemove()
end

function ENT:Draw()
	self:DrawModel()

	
		
	
	
	
	
	
	
end




