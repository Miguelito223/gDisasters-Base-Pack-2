AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Tar Pit"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Material                         = "models/rendertarget"        
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
		local phys = self:GetPhysicsObject()
		
		ParticleEffectAttach("tar_pit_onmodel_main", PATTACH_POINT_FOLLOW, self, 0)
		self:SetTrigger( true )
		self.NextBubblingSound = CurTime()
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		
		self:SetModelScale( math.random(1,10) ) 
		self:SetAngles( Angle(0,math.random(1,180), 0))
		
		
		
		
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



function ENT:BubblingSound()

	if math.random(1,100)==1 and self:CanPlayBubblingSound() then
		self:EmitSound("streams/tarpit.mp3")

	end
end

function ENT:CanPlayBubblingSound()

	if CurTime() >= self.NextBubblingSound then 
		self.NextBubblingSound = CurTime() + 8
		return true
	else 
		return false
	end
	
end



function ENT:Touch( entity )
	
	local vlength = entity:GetVelocity():Length()
	local zdiff   = math.abs(math.Clamp(entity:GetPos().z - self:GetPos().z, -50,0))
	
	if vlength > 300 then return end 
	
	if entity:IsNPC() or entity:IsPlayer() or entity:IsNextBot() then
		if math.random(1,25)==1 then
		
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( math.random(1,2) + (zdiff/2) )
			dmginfo:SetDamageType( DMG_BURN ) 
			dmginfo:SetAttacker( entity ) 
			entity:TakeDamageInfo(dmginfo)
			
		 
		end
		
		if entity:IsPlayer() then
			local r, g, b  = entity:GetColor().r, entity:GetColor().g, entity:GetColor().b
			entity:SetColor( Color( math.Clamp(r-1,0,255),  math.Clamp(g-1,0,255),  math.Clamp(b-1,0,255) ) )
			entity:SetPos( entity:GetPos() - Vector(0,0,0.6))
			
			timer.Simple(2, function()
				if self:IsValid() and entity:GetPos():Distance(self:GetPos()) <= 500 then 
					local dmg = DamageInfo()
					dmg:SetDamage( 100 )
					dmg:SetAttacker( entity )
					dmg:SetDamageType( DMG_BURN  )
					
					entity:TakeDamageInfo(  dmg)
				end
			end)
		
		else
			entity:Ignite(60, 0)
			entity:SetPos( entity:GetPos() - Vector(0,0,20))
			
			timer.Simple(2, function()
				if self:IsValid() and entity:GetPos():Distance(self:GetPos()) <= 500 then 
					local dmg = DamageInfo()
					dmg:SetDamage( 100 )
					dmg:SetAttacker( entity )
					dmg:SetDamageType( DMG_BURN  )
					
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
		
		self:BubblingSound()
		self:NextThink(CurTime() + t)
		return true
	end
end

function ENT:OnRemove()
end

function ENT:Draw()



	self:DrawModel()
	
end




