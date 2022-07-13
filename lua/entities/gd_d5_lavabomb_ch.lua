AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Lava Bomb"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Model                            = "models/ramses/models/nature/volcanic_rock_03_64.mdl"
ENT.Material                         = "space/models/lavabomb/main_diffuse"

function ENT:Initialize()	

	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )
		self:SetMaterial(self.Material)
		
		
		local phys = self:GetPhysicsObject()
		phys:Wake()
		
		if (phys:IsValid()) then
			phys:SetMass(math.random(20,30))
		end 		
		
		phys:EnableDrag( false )
		
		timer.Simple(14, function()
			if !self:IsValid() then return end
			self:Remove()
		end)
			
		timer.Simple(0.1, function()	
		ParticleEffectAttach("lavabomb_burnup_main", PATTACH_POINT_FOLLOW, self, 0)
		
		end)

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
		
		ParticleEffect("lavabomb_explosion_main", data.HitPos, Angle(0,0,0), nil)
		
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
	
	local sound = table.Random({"streams/event/explosion/explosion_light_k.mp3","streams/event/explosion/explosion_light_l.mp3","streams/event/explosion/explosion_light_a.mp3","streams/event/explosion/explosion_light_b.mp3","streams/event/explosion/explosion_light_m.mp3"})
	
	
	CreateSoundWave(sound, self:GetPos(), "stereo" ,340.29/2, {80,100}, 5)
	
	local pe = ents.Create( "env_physexplosion" );
	pe:SetPos( self:GetPos() );
	pe:SetKeyValue( "Magnitude", 50 );
	pe:SetKeyValue( "radius", 200 );
	pe:SetKeyValue( "spawnflags", 19 );
	pe:Spawn();
	pe:Activate();
	pe:Fire( "Explode", "", 0 );
	pe:Fire( "Kill", "", 0.5 );
	
	util.BlastDamage( self, self, self:GetPos()+Vector(0,0,12), 512, math.random( 10, 20 ) )		

		
	local models = { 
					 "models/ramses/models/nature/hail_02.mdl",
					 "models/ramses/models/nature/hail_03.mdl",
					 "models/ramses/models/nature/hail_04.mdl",
					 "models/ramses/models/nature/hail_05.mdl",
					 "models/ramses/models/nature/hail_02.mdl",
					 "models/ramses/models/nature/hail_03.mdl",
					 "models/ramses/models/nature/hail_04.mdl",
					 "models/ramses/models/nature/hail_05.mdl"
					 }

	self:Remove()

	for i=1, 8 do 
		local mod_vector = Vector( math.random(-1000,1000), math.random(-1000,1000), 0)
		local piece = ents.Create("prop_physics") 
		--piece:SetModelScale(0.4,0)
		piece:SetModel( models[i] ) 
		piece:SetMaterial(mat)
		local phys = piece:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetMass(math.random(50,80))
		end 	
		local mat = "space/models/lavabomb/main_diffuse"
		piece:SetPos(pos)
		piece:Spawn()
		piece:Activate()
		piece:GetPhysicsObject():SetVelocity(mod_vector)
		
		
		ParticleEffectAttach("megacryometeor_piece_steam", PATTACH_POINT_FOLLOW, piece, 0)
		timer.Simple(i + 12, function() if piece:IsValid() then piece:Remove() end end)
		
	end
		

end

function ENT:Think()
	if (SERVER) then
	if !self:IsValid() then return end
	local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1
	
	if self:WaterLevel() >= 1 then self:Remove() end
	
	for k,v in pairs(ents.GetAll()) do
	
	local dist = (self:GetPos() - v:GetPos()):Length() 
	
	if v:IsPlayer() or v:IsNPC() then
	
	if ( dist <= 400 ) and v:IsValid() and self:IsValid() then
	
	InflictDamage(v, self, "fire", math.random(2,4))
	
	
			end
	
		end
	
	if ( dist <= 400 ) and v:IsValid() and self:IsValid() and v != self and (v:GetClass() == "prop_physics") then v:Ignite() end
	
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




