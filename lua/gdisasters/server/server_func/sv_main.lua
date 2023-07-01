
function setMapLight(light)
	local light_env = ents.FindByClass("light_environment")[1]

	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() <= 0 then return end

	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() >= 1 then 

	
		if light_env != nil then 
			light_env:Fire( 'FadeToPattern' , light , 0 )

		else
			if light == "a" then

				engine.LightStyle( 0, "b" )
				net.Start("gd_maplight_cl")
				net.Broadcast()
			else
				engine.LightStyle( 0, light )
				net.Start("gd_maplight_cl")
				net.Broadcast()

			end
		end
	end
end

function GetLightLevel(player)

	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() <= 0 then return end

	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() >= 1 then 

		net.Start("gd_ambientlight")
		net.Send(player)
		return player.AmbientLight
	
	end
end
-- --]]
function paintSky_Fade(data_to, fraction) -- fade from one skypaint setting to another

	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() <= 0 then return end

	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() >= 1 then 

		local self          = ents.FindByClass("env_skypaint")[1]

		if self==nil  then 
		
			local ent = ents.Create("env_skypaint")
			ent:SetPos(Vector(0,0,0))
			ent:Spawn()
			ent:Activate()
			self = ent

		end

		local TopColor      = LerpVector( fraction, self:GetTopColor()      ,data_to["TopColor"]      or Vector(0.20,0.50,1.00))
		local BottomColor   = LerpVector( fraction, self:GetBottomColor()   ,data_to["BottomColor"]   or Vector(0.80,1.00,1.00))
		local FadeBias      = Lerp(       fraction, self:GetFadeBias()      ,data_to["FadeBias"]      or 1.00)
		local HDRScale      = Lerp(       fraction, self:GetHDRScale()      ,data_to["HDRScale"]      or 0.66)


		local DrawStars     = true
		local StarTexture   = "skybox/starfield"
		local StarScale     = Lerp(       fraction, self:GetStarScale()     ,data_to["StarScale"]     or 0.50)
		local StarFade      = Lerp(       fraction, self:GetStarFade()      ,data_to["StarFade"]      or 1.50)
		local StarSpeed     = Lerp(       fraction, self:GetStarSpeed()     ,data_to["StarSpeed"]     or 0.01)

		local DuskIntensity = Lerp(       fraction, self:GetDuskIntensity() ,data_to["DuskIntensity"] or 0.5)
		local DuskScale     = Lerp(       fraction, self:GetDuskScale()     ,data_to["DuskScale"]     or 1.00)
		local DuskColor     = LerpVector( fraction, self:GetDuskColor()     ,data_to["DuskColor"]     or Vector(1.00,0.20,0.00))

		local SunSize       = Lerp(       fraction, self:GetSunSize()       ,data_to["SunSize"]       or 2.00)
		local SunColor      = LerpVector( fraction, self:GetSunColor()      ,data_to["SunColor"]      or Vector(0.20,0.10,0.00))

		if( IsValid( self ) ) then
			
			self:SetTopColor( TopColor )
			self:SetBottomColor( BottomColor )
			self:SetFadeBias( FadeBias )

			self:SetDrawStars( DrawStars )
			self:SetStarTexture( StarTexture )	
			
			self:SetStarSpeed( StarSpeed )
			self:SetStarScale( StarScale )
			self:SetStarFade( StarFade )

			self:SetDuskColor( DuskColor )
			self:SetDuskScale( DuskScale )
			self:SetDuskIntensity( DuskIntensity )
			
			self:SetSunColor( SunColor )
			self:SetSunSize( SunSize )


			self:SetHDRScale( HDRScale )

		end

	end

end

function paintSky(data)

	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() <= 0 then return end


	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() >= 1 then 

	
	
		local self          = ents.FindByClass("env_skypaint")[1]

		local TopColor      = data["TopColor"]      or Vector(0.20,0.50,1.00)
		local BottomColor   = data["BottomColor"]   or Vector(0.80,1.00,1.00)
		local FadeBias      = data["FadeBias"]      or 1.00
		local HDRScale      = data["HDRScale"]      or 0.66

		local DrawStars     = data["DrawStars"]     or true
		local StarTexture   = data["StarTexture"]   or "skybox/starfield"
		local StarScale     = data["StarScale"]     or 0.50
		local StarFade      = data["StarFade"]      or 1.50
		local StarSpeed     = data["StarSpeed"]     or 0.01

		local DuskIntensity = data["DuskIntensity"] or 0.5
		local DuskScale     = data["DuskScale"]     or 1.00
		local DuskColor     = data["DuskColor"]     or Vector(1.00,0.20,0.00)

		local SunSize       = data["SunSize"]       or 2.00
		local SunColor      = data["SunColor"]      or Vector(0.20,0.10,0.00)
		local SunNormal     = data["SunNormal"]     or Vector( 0.0, 0.0, 0.00 )		


		self:SetTopColor( TopColor )
		self:SetBottomColor( BottomColor )
		self:SetFadeBias( FadeBias )

		self:SetDrawStars( DrawStars )
		self:SetStarSpeed( StarSpeed )
		self:SetStarScale( StarScale )
		self:SetStarFade( StarFade )

		self:SetStarTexture( StarTexture )		
		self:SetDuskColor( DuskColor )
		self:SetDuskScale( DuskScale )
		self:SetDuskIntensity( DuskIntensity )

		self:SetSunNormal( SunNormal )
		self:SetSunColor( SunColor )
		self:SetSunSize( SunSize )



		self:SetHDRScale( HDRScale )	

	
	end

end

function skyPaint_Reset()

	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() <= 0 then return end

	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() >= 1 then 
	
		local self          = ents.FindByClass("env_skypaint")[1]
		local TopColor      = Vector(0.20,0.50,1.00)
		local BottomColor   = Vector(0.80,1.00,1.00)
		local FadeBias      = 1.00
		local HDRScale      = 0.66
		
		local DrawStars     = true
		local StarTexture   = "skybox/starfield"
		local StarScale     = 0.50
		local StarFade      = 1.50
		local StarSpeed     = 0.01
		
		local DuskIntensity = 0.5
		local DuskScale     = 1.00
		local DuskColor     = Vector(1.00,0.20,0.00)
		
		local SunSize       = 2.00
		local SunColor      = Vector(0.20,0.10,0.00)
		local SunNormal     = Vector( 0.0, 0.0, 0.00 )
		
		self:SetTopColor( TopColor )
		self:SetBottomColor( BottomColor )
		self:SetFadeBias( FadeBias )
		
		self:SetDrawStars( DrawStars )
		self:SetStarSpeed( StarSpeed )
		self:SetStarScale( StarScale )
		self:SetStarFade( StarFade )
		
		self:SetStarTexture( StarTexture )		
		self:SetDuskColor( DuskColor )
		self:SetDuskScale( DuskScale )
		self:SetDuskIntensity( DuskIntensity )
		
		self:SetSunNormal( SunNormal )
		self:SetSunColor( SunColor )
		self:SetSunSize( SunSize )
		
		
		
		self:SetHDRScale( HDRScale )
	
	end

end
-- ]]--
function GetMaterialType(ent)

	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then 
		return Material_Types[phys:GetMaterial()] or "generic"
	else
		return "generic"
	end
end



function CreateSoundWave(soundpath, epicenter, soundtype, speed, pitchrange, shakeduration) -- SPEED MUST BE IN MS^-1


	for k, v in pairs(player.GetAll()) do
		local distance = v:GetPos():Distance(epicenter) -- distance from player and epicenter
		local t        = distance / convert_MetoSU(speed)  -- speed of sound = 340.29 m/s
		timer.Simple(t, function()
			if v:IsValid() then
			
				net.Start("gd_soundwave")
				net.WriteString(soundpath)
				net.WriteString(soundtype)
				net.WriteVector(epicenter)
				net.WriteTable(pitchrange)
				net.Send(v)			

				if shakeduration > 0 then

					net.Start("gd_shakescreen")
					net.WriteFloat(shakeduration)
					net.Send(v)
				
				end
			end
		end)
	end
end
function StopSoundWave(soundpath, soundtype) -- SPEED MUST BE IN MS^-1
	for k, v in pairs(player.GetAll()) do

		if v:IsValid() then
			net.Start("gd_soundwave_stop")
			net.WriteString(soundpath)
			net.WriteString(soundtype)
			net.Send(v)			
		end

	end
end



--[[

Function Name: 		 FindInCone
Function Purpose:    Find entities in a cone
Function parameters: 

					[1] Starting position
					[2] Max height gain      (          local to starting position             )
					[3] Min height gain      (          local to starting position              )
					[4] Radius at max height (       radius at max height will be this         )
					[5] Radius at min height (       radius at min height will be this         )
					[6] Physics ents only    ( filters out non-physics entities if true (bool) )


Function notes:
	Cone always is vertical 

--]]


function Entity_Create(entity)
	local ent = ents.Create(entity)
	ent:Spawn()
	ent:Activate()
end


function FindInCone(pos, max_z_gain, min_z_loss, radius_at_max_z, radius_at_min_z, phys_only )



	local function RadiusAtHeight(current_height, max_height, min_height, max_radius, min_radius)

		local diff_radius = max_radius - min_radius
		local diff_height = max_height - min_height

		local current_height_ratio = (max_height - current_height) / diff_height 

		local radius = 0


		if max_radius > min_radius then

			radius = min_radius + (  (1 - current_height_ratio) * diff_radius) 

		else
			radius = max_radius - (   current_height_ratio * diff_radius )
		end

		return radius
	end



	local entities   = {}
	local pos_self   = pos
	local pos_self2d = Vector(pos.x, pos.y, 0)



	for k, v in pairs(ents.GetAll()) do
		local is_physics = v:GetPhysicsObject():IsValid() and (v:GetClass()!= "phys_constraintsystem" and v:GetClass()!= "phys_constraint"  and v:GetClass()!= "logic_collision_pair" and v:GetClass()!= "entityflame")
	
		if phys_only and is_physics then

			local pos_v   = v:GetPos()
			local pos_v2d = Vector(pos_v.x, pos_v.y, 0)
			local dist    = pos_v2d:Distance(pos_self2d)

			local height_v = pos_v.z - pos_self.z 
		
			local radius = RadiusAtHeight(height_v, max_z_gain, min_z_loss, radius_at_max_z, radius_at_min_z)
		

			if dist <= radius and (height_v <= max_z_gain and height_v >= min_z_loss) then
			
				table.insert(entities, {v, radius})
			end


		elseif phys_only == false then
		
		
			local pos_v   = v:GetPos()
			local pos_v2d = Vector(pos_v.x, pos_v.y, 0)
			local dist    = pos_v2d:Distance(pos_self2d)

			local height_v = pos_v.z - pos_self.z 

			local radius = RadiusAtHeight(height_v, max_z_gain, min_z_loss, radius_at_max_z, radius_at_min_z)
		
			if dist <= radius and (height_v <= max_z_gain and height_v >= min_z_loss)  then
				table.insert(entities,  {v, radius})
			end
		
		
		end


	
	end
	return entities
end


--[[

Function Name: 		 FindInCylinder
Function Purpose:    Find entities in a vertical cylinder
Function parameters: 

					[1] Starting position
					[2] Radius of the cylinder (                 constant                        )
					[3] Max height gain        (         local to starting position              )
					[4] Min height gain        (         local to starting position              )
					[5] Physics ents only      ( filters out non-physics entities if true (bool) )


Function notes:
	Cylinder always is vertical 

--]]


function FindInCylinder(pos, radius, top, bottom, physonly)

	local entities = {}
	local selfpos_normalized = Vector(pos.x, pos.y, 0)

	local z_max, z_min = pos.z + top, pos.z + bottom 

	for k, v in pairs(ents.GetAll()) do
		local is_physics = v:GetPhysicsObject():IsValid() and (v:GetClass()!= "phys_constraintsystem" and v:GetClass()!= "phys_constraint"  and v:GetClass()!= "logic_collision_pair" and v:GetClass()!= "entityflame")

		local vpos            = v:GetPos() 
		local vpos_normalized = Vector(vpos.x, vpos.y, 0)

		local dist            = vpos_normalized:Distance(selfpos_normalized)
		local zdiff           = vpos.z - pos.z 

		if phys_only then 
			if is_physics then

				if dist <= radius then 

					if zdiff > 0 then -- v is higher than me 
						if zdiff <= top then
							table.insert(entities, v)
						end

					elseif zdiff == 0 then -- same position
						table.insert(entities, v)

					elseif zdiff < 0 then -- v is below us
					
						if zdiff >= bottom then
							table.insert(entities, v)
						end
					
					end

				
				end
			end
		else
		
			if dist <= radius then 

				if zdiff > 0 then -- v is higher than me 
					if zdiff <= top then
						table.insert(entities, v)
					end

				elseif zdiff == 0 then -- same position
					table.insert(entities, v)

				elseif zdiff < 0 then -- v is below us
				
					if zdiff >= bottom then
						table.insert(entities, v)
					end
				
				end

			
			end


		end
	
	end

	return entities 
end

function clShakeScreen(ply, duration)


	net.Start("gd_shakescreen")
	net.WriteFloat(duration)
	net.Send(ply)

end


function clPlaySound(ply, sound, pitch, volume)

	net.Start("gd_sendsound")
	net.WriteString(sound or "")
	net.WriteFloat(pitch or 100)
	net.WriteFloat(volume or 1)
	net.Send(ply)
end

function clStopSound(ply, sound)

	net.Start("gd_stopsound")
	net.WriteString(sound or "")
	net.Send(ply)
end

function SetOffsetAngles(player, offset)
	net.Start("gd_seteyeangles_cl")
	net.WriteAngle(offset)
	net.Send(player)

end


function FindEntitiesByModels(models)
	local filtered = {}
	for k, v in pairs(ents.GetAll()) do
		if models[v:GetModel()]==true then

			table.insert(filtered, v)
		end
	end

	return filtered
end

function FindNearestEntityByModels(self, models)


	if FindEntitiesByModels(models)[1] == nil then return nil end

	local current_target          = FindEntitiesByModels(models)[1]


	for k, v in pairs(FindEntitiesByModels(models)) do

		local dis   = current_target:GetPos():Distance(self:GetPos()) -- from current target to self
		local dis2  = v:GetPos():Distance(self:GetPos()) -- from new target to self 


		if dis2 <= dis then
			current_target = v


		end
	
	end

	return current_target, self:GetPos():Distance(current_target:GetPos())

end

function isOutdoor(ply, isprop)



	local function performTrace(ply, direction)

		local tr = util.TraceLine( {
			start = ply:GetPos(),
			endpos = ply:GetPos() + direction * 1000,
			filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) then return true end end
		} )
	


		return tr.HitWorld
	end

	local function isBelowSky(ply)

		local tr, trace={},{}

		tr.start = ply:GetPos()
		tr.endpos = tr.start + Vector(0,0,48000)
		tr.filter = { ply }
		tr.mask = MASK_SOLID
		trace = util.TraceLine( tr )
		return trace.HitSky

	end


	local hitLeft    = performTrace(ply, Vector(1,0,0))
	local hitRight   = performTrace(ply, Vector(-1,0,0))

	local hitForward = performTrace(ply, Vector(0,1,0))
	local hitBehind  = performTrace(ply, Vector(0,-1,0))

	local hitBelow   = performTrace(ply, Vector(0,0,-1))
	local inTunnel = ((hitLeft and hitRight) and ( (hitForward and hitBehind) == false)) or (((hitLeft and hitRight)==false) and ( (hitForward and hitBehind) == true))
	
	local hitSky     = isBelowSky(ply)
	
	if isUnderWater(ply) or isUnderLava(ply) then
		if isprop == nil then
			net.Start("gd_isOutdoor")
			net.WriteBool(false)
			net.Send(ply)
			ply.gDisasters.Area.IsOutdoor = false
		else
			ply.IsOutdoor = false
		end
		return false
	else
		if isprop == nil then
			net.Start("gd_isOutdoor")
			net.WriteBool(hitSky)
			net.Send(ply)
			ply.gDisasters.Area.IsOutdoor = hitSky
		else
			ply.IsOutdoor = hitSky
		end
		return hitSky
	end
end



function windPressure(windspeed)
	return (windspeed*windspeed)*0.00256
end

function windLoad(entity, windSpeed) -- entity and wp = wind pressure
	local bounding_radius = entity:BoundingRadius()
	local area            = (2*math.pi)*(bounding_radius*bounding_radius)
	local F               = area * windPressure(windSpeed) * 0.0035
	return F
end

function Area(entity) -- entity and wp = wind pressure
	if entity.boundingRadiusArea == nil then
	
		local bounding_radius = entity:BoundingRadius()
		local area            = (2*math.pi)*(bounding_radius*bounding_radius)

		entity.boundingRadiusArea = area
		return area
	else
		return entity.boundingRadiusArea 
	end

end


function IsSomethingBlockingWind(entity)


	local tr = util.TraceLine( {
		start = entity:GetPos() + Vector(0,0,10),
		endpos = entity:GetPos() + Vector(0,0,10) + (GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Direction"] * 300),
		filter = entity

	} )



	return tr.Hit
end

hook.Add("Think", "LavaVolcano", function()
	for k, v in pairs(player.GetAll()) do
		v.LavaIntensity = math.Clamp(v.LavaIntensity - (FrameTime()/4), 0, 1)
	end
end)