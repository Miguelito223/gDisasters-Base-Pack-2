AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Black Ice Over"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"



function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel("models/props_debris/concrete_spawnplug001a.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

		self:SetNoDraw(true)
		


		self.TouchedEntities = {}
		self.TouchedVehicles = {} -- I love touchy touchy 
		
		self.NextTimeForMakeEntitiesSlide = CurTime() 
		
		self:RemoveOldIces()
		
		
		
	end
end

function ENT:RemoveOldIces()

	for k, v in pairs(ents.FindByClass("gd_d2_blackiceover")) do 
		if v!=self then 
			v:Remove()
		end
	end
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






function ENT:GetSkatingPlayers()
	
	for k, v in pairs(player.GetAll()) do 
		
		
		if self.TouchedEntities[v]==nil and v:IsOnGround() then
			self.TouchedEntities[v] = {v, v:GetVelocity(), CurTime()}
			
		elseif self.TouchedEntities[v]!=nil and v:IsOnGround() then
			
			self.TouchedEntities[v][3] = CurTime()
		end
	end
	
end

function ENT:PlayerIceSkating()
	local vel_mod = GetPhysicsMultiplier()
	local i       = 1

	for k, v in pairs(self.TouchedEntities) do
		if v[1]:IsValid() then
		
			local ent          = v[1] 
			local vel          = ent:GetVelocity() * 1.12
			local time_elapsed = CurTime() - v[3]
			local timeout      = time_elapsed > 0.05
			local vel_diff     =  (vel_mod * vel) - ent:GetVelocity() 
			
			
			if timeout then 
				
				self.TouchedEntities[ent] = nil 
				
			else
		
				ent:SetVelocity( vel_diff )
				
				
				
			
			end
		end
		i = i + 1
	end
	
end


function ENT:VehicleIceSkating()
	local vel_mod = GetPhysicsMultiplier()
	local i       = 1

	for k, v in pairs(self.TouchedVehicles) do
		if IsValid(v)  then
			
			local ent          = v[1] 
			local vel          = v[2] * 0.99
			local time_elapsed = CurTime() - v[3]
			local timeout      = time_elapsed > 0.05
			local vel_diff     =  (vel_mod * vel) - ent:GetVelocity() 
			
	
			if timeout then 
				
				self.TouchedVehicles[ent] = nil 
				
			else
				
				ent:GetPhysicsObject():SetVelocity( Vector(vel.x, vel.y, 0) )
				
				
			
			end
		end
		i = i + 1
	end
	
end



function ENT:MakeEntitiesSlide()
	if CurTime() >= self.NextTimeForMakeEntitiesSlide then 
		self.NextTimeForMakeEntitiesSlide = CurTime() + 1 
		
		for k, v in pairs(ents.GetAll()) do 
		
			if v:IsPlayer()==false and v:IsNPC() == false and v:GetPhysicsObject():IsValid() and v:IsVehicle() == false  then 
				if (v:GetClass()!= "phys_constraintsystem" and v:GetClass()!= "phys_constraint"  and v:GetClass()!= "logic_collision_pair" and v:GetClass()!= "entityflame") then 
					
					local phys = v:GetPhysicsObject()
				
					if phys:GetMaterial() != "gmod_ice" then 
						v.OldPhysMaterial = phys:GetMaterial() 
						
						phys:SetMaterial("gmod_ice")
					
					end
		
				end
			end
			
		end
		
		
	else
	
	end

		


end

function ENT:MakeVehiclesSlippery()
	for k, v in pairs(ents.GetAll())  do 
		if v:IsVehicle() then 
		
			local min, max = v:GetRotatedAABB( v:OBBMins(), v:OBBMaxs() )
			local pos      = v:GetPos()
			
			
			local trace = util.TraceLine({
				start 	   = pos + Vector(min.x, min.y, min.z * 0.5), -- hacky but it'll do
				endpos     = pos + min ,
				filter     = v,
			})
			
			if self.TouchedVehicles[v]==nil and trace.Hit and v:GetVelocity():Length() > 500 then
				self.TouchedVehicles[v] = {v, v:GetVelocity(), CurTime()}
				
			elseif self.TouchedVehicles[v]!=nil and trace.Hit then
				
				self.TouchedVehicles[v][3] = CurTime()
			end
			
			
			
			
		end
	end

end


function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		
		self:GetSkatingPlayers()
	
		self:PlayerIceSkating()
		self:MakeEntitiesSlide()
		self:MakeVehiclesSlippery()
		self:VehicleIceSkating()
		
		self:NextThink(CurTime() + 0.01)
		return true
	end
end

function ENT:RestorePhysicsMaterials()
	for k, v in pairs(ents.GetAll()) do 
		
		if v.OldPhysMaterial != nil then 
			v:GetPhysicsObject():SetMaterial(v.OldPhysMaterial) 
		end
	end
			

end

function ENT:OnRemove()
	if (SERVER) then 
	
		self:RestorePhysicsMaterials()
	
	
	
	
	end
end

function ENT:Draw()
	self:DrawModel()

	
		
	
	
	
	
	
	
end




