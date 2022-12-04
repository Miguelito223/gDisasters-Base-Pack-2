AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Tornado"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"


ENT.EnchancedFujitaScaleData         = { 
	["EF0"] = { Speed = math.random(105,137) },
	["EF1"] = { Speed = math.random(138,177) },
	["EF2"] = { Speed = math.random(178,217) },
	["EF3"] = { Speed = math.random(218,266) },
	["EF4"] = { Speed = math.random(267,322) },
	["EF5"] = { Speed = math.random(322,350) },
	["EF6"] = { Speed = math.random(500,600) },
	["Martian EF6"] = { Speed = math.random(600,800) },
	["EF7"] = { Speed = math.random(400,500) }
}	





function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel("models/props_junk/PopCan01a.mdl")

		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

		self:SetNoDraw(true)
		
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:SetMass(100)
		end 		
		
		self:RepositionMyself()
		self:Decay()
		self:AttachParticleEffect()
		self:SetGroundSpeed()
		self:PreCalculateVolume()
		self:SetupMoveType()
		self:PlayFadeinSound()
		self:SetupNWVars()
		self.InternalVers    = {Enabled = false}
		self.NextPhysicsTime = CurTime()
		self.StartTime       = CurTime()

		
	end
	timer.Simple(1, function()
		if !self:IsValid() then return end
		self:CreateLoop()
	end)
	
	
end

function ENT:SetupNWVars()
	local category = self.Data.EnhancedFujitaScale

	self:SetNWString("Category", category)
	
end

function ENT:PlayFadeinSound()
	local category         = self.Data.EnhancedFujitaScale
	
	if category == "EF0" or category == "EF1" or category == "EF2"then
	
		CreateSoundWave("streams/environment/wind_shared/ef0_fadein.mp3", self:GetPos(), "3d", 340/2, {80,120}, 10)
		
	elseif category == "EF3" then
	
		CreateSoundWave("streams/environment/wind_shared/ef3_fadein.mp3", self:GetPos(), "3d", 340/2, {80,120}, 10)

	elseif category == "EF4" then
	
		CreateSoundWave("streams/environment/wind_shared/ef4_fadein.mp3", self:GetPos(), "3d", 340/2, {80,120}, 10)

	elseif category == "EF5" then
	
		CreateSoundWave("streams/environment/wind_shared/ef5_fadein.mp3", self:GetPos(), "3d", 340/2, {80,120}, 10)
		
	elseif category == "EF6" then
	
		CreateSoundWave("streams/environment/wind_shared/ef5_fadein.mp3", self:GetPos(), "3d", 340/2, {80,120}, 10)

	elseif category == "Martian EF6" then
	
		CreateSoundWave("streams/environment/wind_shared/martian_tornado_fadein.mp3", self:GetPos(), "3d", 340/2, {80,120}, 10)

	elseif category == "EF7" then
	
		CreateSoundWave("streams/environment/wind_shared/martian_tornado_fadein.mp3", self:GetPos(), "3d", 340/2, {80,120}, 10)

	end

end


function ENT:PlayFadeoutSound()
	local category         = self.Data.EnhancedFujitaScale
	
	if category == "EF0" or category == "EF1" or category == "EF2"then
	
		CreateSoundWave("streams/environment/wind_shared/ef0_fadeout.mp3", self:GetPos(), "3d", 340/2, {80,120}, 10)
		
	elseif category == "EF4" then
	
		CreateSoundWave("streams/environment/wind_shared/ef4_fadeout.mp3", self:GetPos(), "3d", 340/2, {80,120}, 10)

	elseif category == "EF5" then
	
		CreateSoundWave("streams/environment/wind_shared/ef5_fadeout.mp3", self:GetPos(), "3d", 340/2, {80,120}, 10)

	elseif category == "EF6" then
	
		CreateSoundWave("streams/environment/wind_shared/ef5_fadeout.mp3", self:GetPos(), "3d", 340/2, {80,120}, 10)
	
	elseif category == "Martian EF6" then
	
		CreateSoundWave("streams/environment/wind_shared/martian_tornado_fadein.mp3", self:GetPos(), "3d", 340/2, {80,120}, 10)

	elseif category == "EF7" then
	
		CreateSoundWave("streams/environment/wind_shared/martian_tornado_fadein.mp3", self:GetPos(), "3d", 340/2, {80,120}, 10)

	end

end




function ENT:SetGroundSpeed()

	if GetConVar( "gdisasters_envtornado_manualspeed" ):GetInt() >= 1 then 
	
	self.GroundSpeed = GetConVar( "gdisasters_envtornado_speed" ):GetInt()
	
	else
	
	self.GroundSpeed = math.random(self.Data.GroundSpeed.Min,self.Data.GroundSpeed.Max)
	
	end
end


function ENT:PostShouldFollowPath()
	self.Path          =  getMapPath()

	self.NextPathIndex = 2

	self:SetPos( self.Path[math.Clamp(#self.Path, 1, 1)] + Vector(0,0,10) )
	
end




function ENT:PostRandomMovementType()
	
	self.PositionsCache     = {self:GetPos()}
	self.TargetPosition     = Vector(self.PositionsCache[1].x, self.PositionsCache.y, 0) + Vector(math.random(-500,500), math.random(-500,500), 0)
	

end

function ENT:AddToPositionsCache(pos)

	local old_v1 = self.PositionsCache[1];
	self.PositionsCache[1] = pos;
	self.PositionsCache[2] = old_v1;

	
end

function ENT:BounceFromWalls(dir)
	
	local selfpos = self:GetPos() 
	
	local tr = util.TraceLine( {
		start = self:GetPos() + ( dir * self.GroundSpeed),
		endpos = selfpos + (dir * 8 * self.GroundSpeed) ,
		mask   = MASK_WATER + MASK_SOLID_BRUSHONLY 
	} )
	
	if tr.Hit then 
		

		
		local new_target = tr.HitPos + ( dir - 2 * ( dir:Dot(tr.HitNormal)) * tr.HitNormal) * Vec2D(self:GetPos()):Distance(Vec2D(self.TargetPosition))
		self.TargetPosition = Vec2D(new_target)
		
	end

end


function ENT:RandomMove()

	local selfpos    = self:GetPos()
	local selfpos_2D = Vector(selfpos.x, selfpos.y, 0)
	
	local dist       = selfpos_2D:Distance(self.TargetPosition)
	local dir        = (self.TargetPosition - selfpos_2D):GetNormalized()
	
	

	if dist < 50 then 
		self:AddToPositionsCache(selfpos)
		self:PickRandomPositionBasedOnPreviousPositions()
		
	else
		self:SetPos( selfpos + (dir * self.GroundSpeed) )
		
		local tr = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos() - Vector(0,0,50000),
			mask   = MASK_WATER + MASK_SOLID_BRUSHONLY 
		} )
	
		self:SetPos( tr.HitPos + Vector(0,0,10) )
		
		
	
		
		self:BounceFromWalls(dir)
			
		
	
	end
	
	

	
end


function ENT:PickRandomPositionBasedOnPreviousPositions()

	local SWAY  = 30 
	local mindist, maxdist =  100, 700 
	
	local rangle  = math.random(-SWAY, SWAY) 
	local dir     = Vec2D(self.PositionsCache[1]) - Vec2D(self.PositionsCache[2])
	
	local new_dir = RotateVectorOnAxisGivenAngle(dir:GetNormalized(), Vector(0,0,1), math.random(-SWAY,SWAY))
	local new_targetpos = new_dir * math.random(mindist, maxdist)  + Vec2D(self:GetPos())
	
	
	self.TargetPosition = new_targetpos

	

end

function ENT:SetupMoveType()
	
	if self.Data.ShouldFollowPath == true then
		self.MType = "follow_path" 
		self:PostShouldFollowPath()
		
		if IsMapRegistered() == false then self:Remove() end 
		
	else
		self.MType = "random" 
		self:PostRandomMovementType()
	end
end

function ENT:PathedMove()
	
	if self.NextPathIndex > #self.Path then self:Remove() return end
	
	local next_point             = self.Path[self.NextPathIndex] + Vector(0,0,10)
	local dir                    = (next_point-self:GetPos()):GetNormalized()
	local distance_to_next_point = next_point:Distance(self:GetPos())

	local nextpos = self:GetPos() + (dir * self.GroundSpeed)

	self:SetPos(nextpos)
	
	

	if distance_to_next_point < 100 then self.NextPathIndex = self.NextPathIndex + 1 end 

end 

function ENT:Move()
	if self.Data.ShouldFollowPath == true and IsMapRegistered() then
		self:PathedMove()
	else
		self:RandomMove()
	end
end

function ENT:PreCalculateVolume()
	local vol = ((math.pi * (self.Data.MaxFunnel.Height - self.Data.MinFunnel.Height)) /  3 ) * ( (self.Data.MaxFunnel.Radius*self.Data.MinFunnel.Radius) + (self.Data.MaxFunnel.Radius^2) + (self.Data.MinFunnel.Radius^2))
	
	self.Volume = vol
	
end

function ENT:OverWater()

	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0,0,11),
		mask   = MASK_WATER
	})
	
	--print(self:GetPos())
	--print(tr.HitPos)

	return tr.HitWorld
	
end

function ENT:OverSolid()

	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0,0,11),
		mask   = MASK_SOLID_BRUSHONLY
	})
	
	--print(self:GetPos())
	--print(tr.HitPos)
	
	return tr.HitWorld
	
end

function ENT:RemoveWaterSpoutInSolid()
	local isOnWater    = self:OverWater()
	local entity = ents.FindByClass("gd_d2_waterspout")[1]
	ply = self.OWNER

	if !entity then return end

	if isOnWater == true then
	elseif isOnWater == false then
		if entity then entity:Remove() end
	end

end


function ENT:CalculateVolumeOfTornado()
	return self.Volume
end

function ENT:CalculateMass()
	local mass = self.Volume * 1.225 
end

function ENT:CreateLoop()
	
	local category = self:GetNWString("Category")
	
	local spath    = ""
	
	if category == "EF0" then
	
		spath      = table.Random( {"streams/environment/wind_shared/ef0_loop.wav", "streams/environment/wind_shared/ef0_loop2.wav"})
		
	elseif category == "EF1" or category == "EF2" then
	
		spath      = "streams/environment/wind_shared/ef1_loop.wav"
		
	elseif category == "EF3" then
				
		spath      = "streams/environment/wind_shared/ef3_loop.wav"	
		
	elseif category == "EF4" then
	
		spath      =  table.Random( {"streams/environment/wind_shared/ef4_loop.wav", "streams/environment/wind_shared/ef4_loop2.wav"})

	elseif category == "EF5" then
	
		spath      =  table.Random( {"streams/environment/wind_shared/ef5_loop.wav", "streams/environment/wind_shared/ef5_loop2.wav"})
		
		
	elseif category == "EF6" then
	
		spath      =  table.Random( {"streams/environment/wind_shared/ef5_loop.wav", "streams/environment/wind_shared/ef5_loop2.wav"})

	elseif category == "Martian EF6" then
	
		spath      =  ("streams/environment/wind_shared/martian_tornado_loop.wav")

	elseif category == "EF7" then
	
		spath      =  ("streams/environment/wind_shared/martian_tornado_loop.wav")

	end

	
	
	local sound = Sound(spath)

	CSPatch = CreateSound(self, sound)
	CSPatch:SetSoundLevel( 120 )
	CSPatch:Play()
	CSPatch:ChangeVolume( 1 )

	self.Sound = CSPatch
	
end

function IsVehicleVisible(parent, target)

	local min, max = target:OBBMins(), target:OBBMaxs()
	local center   = (max + min) * 0.5
	
	

	local trace = util.TraceLine( {
		start  = parent:GetPos(),
		endpos = target:GetPos() + center,
		filter = parent
			
	} )
	
	return trace.Hit


end

function ENT:CanBeSeenByTheWind(ent)
	
	local isOutside = nil

	
	local wind_dir  = self:GetPos():Cross(ent:GetPos()):GetNormalized() ;
	local hwind_dir = wind_dir * -1;
	local safespot_dir = hwind_dir * 300;
	

	local tr_wind = nil;
	local can_be_directly_seen = nil;
	
	if ent:IsVehicle() then 
	
		local min, max = ent:OBBMins(), ent:OBBMaxs()
		local center   = (max + min) * 0.5
	
		tr_wind = util.TraceLine( {
			start  = ent:GetPos() + center,
			endpos = ent:GetPos() + center + safespot_dir,
			filter = ent
				
		} )
		can_be_directly_seen = IsVehicleVisible(self, ent)
	
	else
	
		tr_wind = util.TraceLine( {
			start = ent:GetPos() + Vector(0,0,10),
			endpos = ent:GetPos() + Vector(0,0,10) + safespot_dir,
			filter = ent
				
		} )
		can_be_directly_seen = ent:Visible( self );
		
	end
	
	local can_be_seen_by_wind  = !tr_wind.Hit 

	
	
	
	if ent:IsPlayer() then
	
		isOutside = isOutdoor(ent);


		if (can_be_seen_by_wind or can_be_directly_seen) and isOutside then 
			return true;
		else
			return false;
		end
			
		
	else
		isOutside = isOutdoor(ent, true);
		
		return (can_be_seen_by_wind or can_be_directly_seen) and isOutside
	end
	
	


end

function ENT:ApplyPhysics(ent, vel)
	
	
	
	if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()then
	
		local vec = (8 * 25) * Vector(0,0,math.random(0,10)/10) + (Vector(10,10,0)*math.sin(CurTime()*4))

		ent:SetVelocity( vel + vec)
		if ent:IsPlayer() and !ent:InVehicle() then ent:SetVelocity( vec * 2 ) end
		
	else
		
		ent:GetPhysicsObject():AddVelocity( vel )
		self:TryRemoveConstraints(ent)
	end
end



function ENT:ApplyShaking()
	
	for k, v in pairs(player.GetAll()) do
		local d = v:GetPos():Distance(self:GetPos()) 
		local d_ratio = 1 - (math.Clamp(d,0,8000)/8000)
		
		if HitChance(50) then
			net.Start("gd_shakescreen")
			net.WriteFloat(1)
			net.WriteFloat( 1 * d_ratio )
			net.WriteFloat(1 * d_ratio)
			net.Send(v)
		end
	
	end



end

function ENT:TryRemoveConstraints(ent)

	if GetConVar( "gdisasters_envtornado_candamageconstraints" ):GetInt()!=1 then return end
	
	
	local chance = 0 
	
	local phys = ent:GetPhysicsObject()
	
	local mass = phys:GetMass()
	
	if mass <= 200 then
	
	if self.Data.EnhancedFujitaScale == "EF0" then
		chance = GetConVar( "gdisasters_envtornado_damage" ):GetInt()
		
	end

	elseif self.Data.EnhancedFujitaScale == "EF1" then
		chance = GetConVar( "gdisasters_envtornado_damage" ):GetInt()
	
	elseif self.Data.EnhancedFujitaScale == "EF2" then
		chance = GetConVar( "gdisasters_envtornado_damage" ):GetInt()
		
	elseif self.Data.EnhancedFujitaScale == "EF3" then
		chance = GetConVar( "gdisasters_envtornado_damage" ):GetInt()
	elseif self.Data.EnhancedFujitaScale == "EF4" then
		chance = GetConVar( "gdisasters_envtornado_damage" ):GetInt()
	elseif self.Data.EnhancedFujitaScale == "EF5" then
		chance = GetConVar( "gdisasters_envtornado_damage" ):GetInt()
	elseif self.Data.EnhancedFujitaScale == "EF6" then
		chance = GetConVar( "gdisasters_envtornado_damage" ):GetInt()
	elseif self.Data.EnhancedFujitaScale == "Martian EF6" then
		chance = GetConVar( "gdisasters_envtornado_damage" ):GetInt()
	elseif self.Data.EnhancedFujitaScale == "EF7" then
		chance = GetConVar( "gdisasters_envtornado_damage" ):GetInt()
	end

	
	if chance == 0 then return end
	
	
	if HitChance(chance) then
		local can_play_sound = false
		
		
		if #constraint.GetTable( ent ) != 0 then
			can_play_sound = true 
		elseif ent:GetPhysicsObject():IsMotionEnabled()==false then
			can_play_sound = true 
		end	
		
		if can_play_sound then
		
			local material_type = GetMaterialType(ent)
			
			if material_type == "wood" then 
				sound.Play(table.Random(Break_Sounds.Wood), ent:GetPos(), 80, math.random(90,110), 1)

			elseif material_type == "metal" then 
				sound.Play(table.Random(Break_Sounds.Metal), ent:GetPos(), 80, math.random(90,110), 1)

			elseif material_type == "plastic" then 
				sound.Play(table.Random(Break_Sounds.Plastic), ent:GetPos(), 80, math.random(90,110), 1)
				
			elseif material_type == "rock" then 
				sound.Play(table.Random(Break_Sounds.Rock), ent:GetPos(), 80, math.random(90,110), 1)
				
			elseif material_type == "glass" then 
				sound.Play(table.Random(Break_Sounds.Glass), ent:GetPos(), 80, math.random(90,110), 1)
				
			elseif material_type == "ice" then 
				sound.Play(table.Random(Break_Sounds.Ice), ent:GetPos(), 80, math.random(90,110), 1)
			
			else
				sound.Play(table.Random(Break_Sounds.Generic), ent:GetPos(), 80, math.random(90,110), 1)
		
			end
		
			
		
			constraint.RemoveAll( ent )
			ent:GetPhysicsObject():EnableMotion( true )
		end
	end
end

function ENT:Physics()
	local phys_scalar = GetConVar( "gdisasters_envtornado_simquality" ):GetFloat() / 0.01
	if !(CurTime() >= self.NextPhysicsTime) then return end

	local category         = self.Data.EnhancedFujitaScale

	if category == "EF6" then

	if !self:IsValid() then return end
	self:FunnelPhysics(phys_scalar)
	self:GroundFunnelPhysics(phys_scalar)
	self:ApplyShaking()

	else

	timer.Simple(8, function()
	if !self:IsValid() then return end
	self:FunnelPhysics(phys_scalar)
	self:GroundFunnelPhysics(phys_scalar)
	self:ApplyShaking()

	end)
end
	
	self.NextPhysicsTime = CurTime() + GetConVar( "gdisasters_envtornado_simquality" ):GetFloat()
end

function ENT:ApplyPlayerNPCPhysics(ent, radius, physics_scalar, force_mul)

	
	local pos                 = self:GetPos()
	local entpos              = ent:GetPos()
	local wind_speed_mod      = (self.EnchancedFujitaScaleData[self.Data.EnhancedFujitaScale].Speed / 323) * 5
	
	local suctional_dir       = (Vector(pos.x, pos.y, entpos.z + self.Data.MaxGroundFunnel.Height) - entpos):GetNormalized()
	local tangential_dir      = self:PerpVectorCW(self, ent)
	
	local suctional_force     = suctional_dir * 50 * wind_speed_mod
	local tangential_force    = tangential_dir * 50 * wind_speed_mod
	local updraft_force       = Vector(0,0, (wind_speed_mod / 5 * 110 ))
	
	local main_force          = suctional_force + Vector(tangential_force.x,tangential_force.y,0) + updraft_force
	
	if self:IsValid() then
	
	if ent:IsOnGround() and ent:IsPlayer() and !ent:InVehicle() then ent:SetPos( ent:GetPos() + Vector(0,0,1))  end 

	ent:SetVelocity(main_force * force_mul)
			
	end
	
end


function ENT:ResolveVehicles(ent)

	local phys = ent:GetPhysicsObject() 

	if phys:IsMotionEnabled() then 
	
		ent:SetPos(ent:GetPos() + Vector(0,0,1))
	
	
	end
end

function ENT:GetRidOfSounds()
	if self.Sound==nil then return end
	self.Sound:Stop()

end

function ENT:GroundFunnelPhysics(physics_scalar)
	local pos         = self:GetPos() 
	local zoffset     = -100
	
	local funnel_ents = FindInCone(pos, self.Data.MaxGroundFunnel.Height, self.Data.MinGroundFunnel.Height + zoffset, self.Data.MaxGroundFunnel.Radius, self.Data.MinGroundFunnel.Radius, true )
	
	local category         = self.Data.EnhancedFujitaScale
	local wind_speed       = self.EnchancedFujitaScaleData[category].Speed

	local gf_radius        = self.Data.MinGroundFunnel.Radius 
	
	
	for k, v in pairs(funnel_ents) do
		
		
		local radius =         v[2]
		local ent              = v[1] 
		local entpos 		   = ent:GetPos()
		local angular_speed    = ((math.pi * 2) / (radius / convert_MetoSU(convert_KMPHtoMe(wind_speed)) ))  
		
		local force_mul        =  1 - (math.Clamp( Vec2D(ent:GetPos()):Distance(Vec2D(self:GetPos())) / radius , 0, 1)^2.718281828459)


		if ent:IsValid() and self:CanBeSeenByTheWind(ent) then 
			
			
			local phys = ent:GetPhysicsObject()
			local mass = phys:GetMass()
						
			local suctional_dir       = (Vector(pos.x, pos.y, entpos.z + self.Data.MaxGroundFunnel.Height) - entpos):GetNormalized()
			local tangential_dir      = self:PerpVectorCW(self, ent)

			local upwards_vec         = Vector(0,0,1)
			local upwards_force 	  = (upwards_vec * 10) 
	
			local suctional_force     = suctional_dir  * 4
			
			local tangential_force    = tangential_dir * (angular_speed * 2)
			
		
			local main_force          = (suctional_force + tangential_force + upwards_force)
			if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
				self:ApplyPlayerNPCPhysics(ent, radius, physics_scalar, force_mul)
			
			else 
				
				
				
				if category == "EF0" then
					
					if mass <= 250 then	
					
						self:ApplyPhysics(ent, main_force * physics_scalar )
		
					else
						if mass > 250 and mass < 750 then
							self:ApplyPhysics(ent, main_force *  (1 - ((mass - 250) / 550)) * physics_scalar)
						end
					end
					
				elseif category == "EF1" then
					if mass <= 750 then	
						self:ApplyPhysics(ent, main_force * physics_scalar )

					else
						if mass > 750 and mass < 2000 then
							self:ApplyPhysics(ent,main_force * (1 - ((mass - 750) / 1250)) * physics_scalar)
						end
					end			
				elseif category == "EF2" then
					if mass <= 2000 then	
						self:ApplyPhysics(ent, main_force * physics_scalar )

					else
						if mass > 2000 and mass < 4000 then
							self:ApplyPhysics(ent,main_force * (1 - ((mass - 2000) / 2000))* physics_scalar)
						end
					end			
				elseif category == "EF3" then
					if mass <= 4000 then	
						self:ApplyPhysics(ent, (main_force * 4) * physics_scalar )

					else
						if mass > 4000 and mass < 6000 then
							self:ApplyPhysics(ent, main_force * 4 * (1 - ((mass - 4000) / 2000)) * physics_scalar)
						end
					end									
				elseif category == "EF4" then
					if mass <= 6000 then	
						self:ApplyPhysics(ent,(main_force * 6) * physics_scalar )

					else
						if mass > 6000 and mass < 30000 then
							self:ApplyPhysics(ent, main_force * 6 * (1 - ((mass - 6000) / 4000)) * physics_scalar)
						end
					end		
				elseif category == "EF5" then
					if mass <= 30000 then	
						self:ApplyPhysics(ent, (main_force * 8) * physics_scalar )

					else
						if mass > 30000 and mass < 50000 then
							self:ApplyPhysics(ent, main_force * 8 * (1 - ((mass - 10000) / 40000)) * physics_scalar)
						end
					end
				elseif category == "EF6" then
					if mass <= 10000 then	
						self:ApplyPhysics(ent, (main_force * 10) * physics_scalar )

					else
						if mass > 10000 then
							self:ApplyPhysics(ent, main_force * 10 * (1 - ((mass - 10000) / 40000)) * physics_scalar)
						end
					end
				elseif category == "Martian EF6" then
					if mass <= 10000 then	
						self:ApplyPhysics(ent, (main_force * 10) * physics_scalar )

					else
						if mass > 10000 then
							self:ApplyPhysics(ent, main_force * 10 * (1 - ((mass - 10000) / 40000)) * physics_scalar)
						end
					end
				elseif category == "EF7" then
					if mass <= 100000 then	
						self:ApplyPhysics(ent, (main_force * 10) * physics_scalar )

					else
						if mass > 100000 then
							self:ApplyPhysics(ent, main_force * 10 * (1 - ((mass - 100000) / 40000)) * physics_scalar)
						end
					end
				end
				
			end

		end
	end
	
	
end



function ENT:FunnelPhysics(physics_scalar)
	local pos         = self:GetPos() + Vector(0,0,self.Data.MaxGroundFunnel.Height)
	local funnel_ents = FindInCone(pos, self.Data.MaxFunnel.Height, self.Data.MinFunnel.Height, self.Data.MaxFunnel.Radius, self.Data.MinFunnel.Radius, true )
	
	local category         = self.Data.EnhancedFujitaScale
	local wind_speed       = self.EnchancedFujitaScaleData[category].Speed

	local angular_speed_mul = (wind_speed / 232) + 1
	for k, v in pairs(funnel_ents) do
		
		local radius =         v[2]
		local ent              = v[1] 
		local entpos 		   = ent:GetPos()
		local angular_speed    = ((math.pi * 2) / (radius / convert_MetoSU(convert_KMPHtoMe(wind_speed)) )) 
		
		local height              =  self.Data.MaxFunnel.Height - ((self:GetPos().z + self.Data.MaxFunnel.Height) - ent:GetPos().z)


		if ent:IsValid() and self:CanBeSeenByTheWind(ent) then 
			
			local phys = ent:GetPhysicsObject()
			local mass = phys:GetMass()
			
		
			
			local upwards_vec         = Vector(0,0,1)
			local tangential_vec      = self:PerpVectorCW(self, ent)
			local suctional_vec       = (Vector(pos.x, pos.y, entpos.z) - entpos):GetNormalized()
			
			local upwards_force 	  = (upwards_vec * 15) 
			local tangential_force    = (tangential_vec * angular_speed) * angular_speed_mul
			local suctional_force     = (suctional_vec * 5)
			local main_force          = (tangential_force + suctional_force + upwards_force) 
			local force_mul        =  1 - (math.Clamp( Vec2D(ent:GetPos()):Distance(Vec2D(self:GetPos())) / radius , 0, 1)^2.718281828459)


			if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
				self:ApplyPlayerNPCPhysics(ent, radius, physics_scalar, force_mul)
			
			else 
				
				if category == "EF0" then
					
					if mass <= 250 then	
					
						self:ApplyPhysics(ent, main_force * physics_scalar )
		
					else
						if mass > 259 and mass < 750 then
							self:ApplyPhysics(ent, main_force * math.random(-500,500)/1000 * physics_scalar)
						end
					end
				elseif category == "EF1" then
					if mass <= 750 then	
						self:ApplyPhysics(ent, main_force * physics_scalar )

					else
						if mass > 750 and mass < 2000 then
							self:ApplyPhysics(ent, main_force * math.random(-500,500)/1000 * physics_scalar)
						end
					end			
				elseif category == "EF2" then
					if mass <= 2000 then	
						self:ApplyPhysics(ent, main_force * physics_scalar )

					else
						if mass > 2000 and mass < 4000 then
							self:ApplyPhysics(ent,main_force * math.random(-500,500)/1000 * physics_scalar)
						end
					end			
				elseif category == "EF3" then
					if mass <= 4000 then	
						self:ApplyPhysics(ent,main_force * physics_scalar )

					else
						if mass > 4000 and mass < 6000 then
							self:ApplyPhysics(ent, main_force * math.random(-500,500)/1000 * physics_scalar)
						end
					end									
				elseif category == "EF4" then
					if mass <= 6000 then	
						self:ApplyPhysics(ent, main_force * physics_scalar )

					else
						if mass > 6000 and mass < 30000 then
							self:ApplyPhysics(ent, main_force * math.random(-1500,1500)/1000 * physics_scalar)
						end
					end		
				elseif category == "EF5" then
					if mass <= 30000 then	
						self:ApplyPhysics(ent, main_force * physics_scalar )

					else
						if mass > 30000 and mass < 50000 then
							self:ApplyPhysics(ent, main_force * math.random(-1500,1500)/1000 * physics_scalar)
						end
					end
				elseif category == "EF6" then
					if mass <= 10000 then	
						self:ApplyPhysics(ent, main_force * physics_scalar )

					else
						if mass > 10000 then
							self:ApplyPhysics(ent, main_force * math.random(-2000,2000)/1000 * physics_scalar)
						end
					end
				elseif category == "Martian EF6" then
					if mass <= 10000 then	
						self:ApplyPhysics(ent, main_force * physics_scalar )

					else
						if mass > 10000 then
							self:ApplyPhysics(ent, main_force * math.random(-2000,2000)/1000 * physics_scalar)
						end
					end
				elseif category == "EF7" then
					if mass <= 100000 then	
						self:ApplyPhysics(ent, main_force * physics_scalar )

					else
						if mass > 100000 then
							self:ApplyPhysics(ent, main_force * math.random(-2000,2000)/1000 * physics_scalar)
						end
					end
				end

				
			end

		end
	end
	
	
end



function ENT:EFire(pointer, arg) 
	if pointer == "Enable" then 
		--self.InternalVars.Enable = arg
	end
	
end

function ENT:Think()
	if (SERVER) then
		if !self:IsValid() then return end
		
		
		self:Move()
		self:Physics()
		self:IsParentValid()
		self:RemoveWaterSpoutInSolid()
		

		self:NextThink(CurTime() + 0.025)
		
		return true
	
	end
end
	
function createTornado(data)
	

	
	local tornado = ents.Create("env_tornado")
	tornado.Data  = data
	tornado:Spawn()
	tornado:Activate()
	
	tornado:EFire("Enable", true)
	
	return tornado

end

function ENT:RepositionMyself()
	self:SetPos(self.Data.Parent:GetPos())
end

function ENT:PerpVectorCW(ent1, ent2)
	local ent1_pos = ent1:GetPos()
	local ent2_pos = ent2:GetPos()
	
	local dir      = (ent2_pos - ent1_pos):GetNormalized()
	local perp     = Vector(-dir.y, dir.x, 0)
	
	return perp

end



function ENT:PerpVectorCCW(ent1, ent2)
	local ent1_pos = ent1:GetPos()
	local ent2_pos = ent2:GetPos()
	
	local dir      = (ent2_pos - ent1_pos):GetNormalized()
	local perp     = Vector(dir.y, -dir.x, 0)
	
	return perp

end


function ENT:AttachParticleEffect()
	self.Data.Effect = table.Random(self.Data.Effect)
	timer.Simple(0.1, function()
	
	ParticleEffectAttach(self.Data.Effect, PATTACH_POINT_FOLLOW, self, 0)
	end)
end

function ENT:Decay()
	timer.Simple(math.random(GetConVar("gdisasters_envtornado_lifetime_min"):GetInt(), GetConVar("gdisasters_envtornado_lifetime_max"):GetInt()), function()
		if !self:IsValid() then return end
		self:Remove()
	end)
end



function ENT:IsParentValid()

	if self.Data.Parent:IsValid()==false or self.Data.Parent==nil then self:Remove() end
	
end


function ENT:OnRemove()
	if (SERVER) then
		self:PlayFadeoutSound()
		if self.Data.Parent:IsValid() then 
			self.Data.Parent:Remove()
		end
	end
	self:StopParticles()
	if self.Sound==nil then return end
	self.Sound:Stop()
end


	
--[[hook.Add( "PreDrawOpaqueRenderables", "test", function()

	render.SetColorMaterial()

	local Path          =  getMapPath()
	
	local NextPathIndex = 8
	
	if NextPathIndex > #Path then return end
	for k, v in pairs(ents.FindByClass( "env_tornado" ) ) do



	render.DrawLine( Path[1], Path[NextPathIndex], Color( 0, 225, 0, 255 ), false )
	end

	
end )--]]

	
function ENT:Draw()	

	self:DrawModel()

	
	
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end


