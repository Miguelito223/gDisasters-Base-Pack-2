AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Sinkhole"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Material                         = "nature/sand"        
ENT.Mass                             =  100
ENT.Models                           =  {"models/props_debris/concrete_spawnplug001a.mdl"}  


function ENT:Initialize()	
	if (CLIENT) then
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
		
		self:SetModelScale( math.random(20,24) ) 
		self:SetAngles( Angle(0,math.random(1,180), 0))
		self:SetPos(self:GetPos() - Vector(0,0,125))
		
		
		
		
	end
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * -0.7  ) 
	ent:Spawn()
	ent:Activate()
	return ent
end






function ENT:Touch( entity )
	
	local vlength = entity:GetVelocity():Length()
	
	if vlength > 100 then return end 
	
	if entity:IsNPC() or entity:IsPlayer() or entity:IsNextBot() then
		
		
		if entity:IsPlayer() then
			entity:SetPos( entity:GetPos() - Vector(0,0,5))
		else
			entity:SetPos( entity:GetPos() - Vector(0,0,166))
		end
		
	
	else
		entity:SetPos( entity:GetPos() - Vector(0,0,5))
	end
	
end

function ENT:Think()
	if (SERVER) then
		if !self:IsValid() then return end
		local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate
		
		for k, v in pairs(player.GetAll()) do
			if v:EyePos().z < getMapCenterFloorPos().z then
				v:SetNWBool("IsUnderGround", true)
			else
				v:SetNWBool("IsUnderGround", false)
			end
		end

		self:NextThink(CurTime() + t)
		return true
	end
end

function ENT:OnRemove()
	for k, v in pairs(player.GetAll()) do
		v:SetNWBool("IsUnderGround", false)
	end
end

function ENT:Draw()



	self:DrawModel()
	
end