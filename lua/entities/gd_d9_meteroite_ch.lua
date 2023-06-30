AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Meteorite"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            = "models/ramses/models/nature/volcanic_rock_03_128.mdl"
ENT.Material                         = "ramses/models/space/madara_meteor/main_diffuse"

function ENT:Initialize()	

	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )
		self:SetMaterial(self.Material)

		
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetMass(700)
			phys:Wake()
		end 		
		
		phys:EnableDrag( false )
		
		timer.Simple(0.1, function()
			if !self:IsValid() then return end
			ParticleEffectAttach("meteorite_burnup_trail_main", PATTACH_POINT_FOLLOW, self, 2)
		end)
		
		
		
		timer.Simple(14, function()
			if !self:IsValid() then return end
			self:Remove()
		end)

	end
end



function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * -1.00  ) 
	ent:Spawn()
	ent:Activate()
	return ent
	
end


function ENT:PhysicsCollide( data, physobj )

	local tr,trace = {},{}
	tr.start = self:GetPos() + self:GetForward() * -200
	tr.endpos = tr.start + self:GetForward() * 500
	tr.filter = { self, physobj }
	trace = util.TraceLine( tr )
	
	if( trace.HitSky ) then
	
		self:Remove()
		
		return
		
	end
	
	if (data.Speed > 200 ) then 
	
		
		self:Explode()

		local h = data.HitPos + data.HitNormal
		local p = data.HitPos - data.HitNormal
		util.Decal("Scorch", h, p )
						 

	end


	
end

function ENT:Explode()

	if( !IsValid( self.Owner ) ) then
		
		self.Owner = self
		
	end
	
	local pos = self:GetPos()
	local mat = self.Material
	local vel = self.Move_vector 
	
	local metsound = table.Random( {"streams/event/explosion/explosion_large_a.mp3", "streams/event/explosion/explosion_large_b.mp3", "streams/event/explosion/explosion_large_c.mp3", "streams/event/explosion/explosion_large_d.mp3", "streams/event/explosion/explosion_large_e.mp3", "streams/event/explosion/explosion_large_f.mp3", "streams/event/explosion/explosion_large_g.mp3", "streams/event/explosion/explosion_large_h.mp3"})
	
	ParticleEffect("meteorite_explosion_main_ground", self:GetPos(), Angle(0,0,0), nil)
	
	CreateSoundWave(metsound, self:GetPos(), "3d" ,340.29, {100,110}, 5)
	
	for k,v in pairs(ents.FindInSphere(self:GetPos(), 3500)) do
		
	local dist = ( v:GetPos() - self:GetPos() ):Length() 	
		
	if (  v != self && IsValid( v ) && IsValid( v:GetPhysicsObject() ) ) and (v:GetClass()!= "phys_constraintsystem" and v:GetClass()!= "phys_constraint"  and v:GetClass()!= "logic_collision_pair") then 
	
	if dist < 2500 then 
	
	if( !v.Destroy ) then
						
			constraint.RemoveAll( v )
			v:GetPhysicsObject():EnableMotion(true)
			v:GetPhysicsObject():Wake()
			v.Destroy = true
			
						end
						
					end
						
			  end
				  
		end
	
	local pe = ents.Create( "env_physexplosion" );
	pe:SetPos( self:GetPos() );
	pe:SetKeyValue( "Magnitude", 5000 );
	pe:SetKeyValue( "radius", 4000 );
	pe:SetKeyValue( "spawnflags", 19 );
	pe:Spawn();
	pe:Activate();
	pe:Fire( "Explode", "", 0 );
	pe:Fire( "Kill", "", 0.5 );
	
	util.BlastDamage( self, self, self:GetPos()+Vector(0,0,12), 3200, math.random( 10000, 40000 ) )

	self:Remove()

		
end

function ENT:Think()

	local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1	
	
	self:SetModelScale( 2, 0 )
		
	if (SERVER) then

		

		if isinWater(self) then 
			self:Remove() 
		elseif isinLava(self) then
			self:Remove()
		end	
	
		self:NextThink(CurTime() + t)
		return true
	
	end
			
end


function ENT:OnRemove()

end

function ENT:Draw()



	self:DrawModel()
	
end




