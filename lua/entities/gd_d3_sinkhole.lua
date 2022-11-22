AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Sinkhole (beta)"
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
		self:SetMaterial(self.Material)
		local phys = self:GetPhysicsObject()
		
		self:SetTrigger( true )

		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		
		self:SetModelScale( math.random(14,18) ) 
		self:SetAngles( Angle(0,math.random(1,180), 0))
		
		self:SetPos(self:GetPos() - Vector(0,0,125))
		
		
		
		
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
		
			entity:SetPos( entity:GetPos() - Vector(0,0,10))

			timer.Simple(5, function()
				local dmg = DamageInfo()
				dmg:SetDamage( 100 )
				dmg:SetAttacker( entity )
				dmg:SetDamageType( DMG_DROWN  )

				entity:TakeDamageInfo(  dmg)
			end)
		
		else

			entity:SetPos( entity:GetPos() - Vector(0,0,10))

			timer.Simple(5, function()
				local dmg = DamageInfo()
				dmg:SetDamage( 100 )
				dmg:SetAttacker( entity )
				dmg:SetDamageType( DMG_DROWN  )

				entity:TakeDamageInfo(  dmg)
			end)

		end
		
	
	else
		entity:SetPos( entity:GetPos() - Vector(0,0,10))

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




