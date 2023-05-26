AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Quicksand"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Material                         = "nature/sand"        
ENT.Mass                             =  100
ENT.Models                           =  {"models/props_debris/concrete_spawnplug001a.mdl"}  


function ENT:Initialize()	
	if (CLIENT) then
		SetMDScale(self, Vector(1,1,0.05))
	end
	
	if (SERVER) then
		
		self:SetModel(table.Random(self.Models))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:SetMaterial(self.Material)
		
		self:SetTrigger( true )

		self:SetModelScale( math.random(1,4) ) 
		self:SetAngles( Angle(0,math.random(1,180), 0))

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
	ent:SetPos( tr.HitPos + tr.HitNormal * -0.7  ) 
	ent:Spawn()
	ent:Activate()
	return ent
end






function ENT:Touch( entity )

	local vlength = entity:GetVelocity():Length()
	
	if vlength > 100 then return end 
	
	if entity:IsNPC() or entity:IsPlayer() or entity:IsNextBot()then
		
		
		if entity:IsPlayer() then
		
			entity:SetPos( entity:GetPos() - Vector(0,0,0.6))

			timer.Simple(5, function()
				if self:IsValid() and entity:GetPos():Distance(self:GetPos()) <= 500 then 
					local dmg = DamageInfo()
					dmg:SetDamage( 100 )
					dmg:SetAttacker( entity )
					dmg:SetDamageType( DMG_DROWN  )
					
					entity:TakeDamageInfo(  dmg)
				end
			end)
		
		else

			entity:SetPos( entity:GetPos() - Vector(0,0,20))

			timer.Simple(5, function()
				if self:IsValid() and entity:GetPos():Distance(self:GetPos()) <= 500 then 
					local dmg = DamageInfo()
					dmg:SetDamage( 100 )
					dmg:SetAttacker( entity )
					dmg:SetDamageType( DMG_DROWN  )
					
					entity:TakeDamageInfo(  dmg)
				end
			end)

		end
		
	
	else
		entity:SetPos( entity:GetPos() - Vector(0,0,0.6))

	end
	
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




