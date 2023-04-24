SetGlobalFloat("gDisasters_Temperature", 0)
SetGlobalFloat("gDisasters_Pressure", 0)
SetGlobalFloat("gDisasters_Humidity", 0)
SetGlobalFloat("gDisasters_Wind", 0)
SetGlobalFloat("gDisasters_BRadiation", 0)
SetGlobalFloat("gDisasters_Oxygen", 0)
SetGlobalVector("gDisasters_Wind_Direction", Vector(0,0,0))

function Atmosphere()
	local scale                                = (1/engine.TickInterval()) / 66
	GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = math.Clamp(GLOBAL_SYSTEM["Atmosphere"]["Temperature"],-273.3, 273.3)
	GLOBAL_SYSTEM["Atmosphere"]["Humidity"]    = math.Clamp(GLOBAL_SYSTEM["Atmosphere"]["Humidity"],0, 100)
	GLOBAL_SYSTEM["Atmosphere"]["BRadiation"]    = math.Clamp(GLOBAL_SYSTEM["Atmosphere"]["BRadiation"],0, 100)
	GLOBAL_SYSTEM["Atmosphere"]["Oxygen"]    = math.Clamp(GLOBAL_SYSTEM["Atmosphere"]["Oxygen"],0, 100)
	GLOBAL_SYSTEM["Atmosphere"]["Pressure"]    = math.Clamp(GLOBAL_SYSTEM["Atmosphere"]["Pressure"], 0, math.huge)
	


	Wind()
	Pressure()
	Humidity()
	AtmosphereFadeControl()
	BRadiation()
	stormfox2()
	spacebuild()
	Temperature()
	Oxygen()
	
end
hook.Add("Tick", "atmosphericLoop", Atmosphere)


function AtmosphereFadeControl()

	GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"]=Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"])
	GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Direction"]=LerpVector(0.005, GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Direction"], GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"])
	GLOBAL_SYSTEM["Atmosphere"]["Pressure"]=Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["Pressure"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"])
	GLOBAL_SYSTEM["Atmosphere"]["Oxygen"]=Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["Oxygen"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["Oxygen"])
	GLOBAL_SYSTEM["Atmosphere"]["Temperature"]=Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["Temperature"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"])
	GLOBAL_SYSTEM["Atmosphere"]["Humidity"]=Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["Humidity"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"])
	GLOBAL_SYSTEM["Atmosphere"]["BRadiation"]    = Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["BRadiation"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["BRadiation"])

end

function Humidity()
	SetGlobalFloat("gDisasters_Humidity", GLOBAL_SYSTEM["Atmosphere"]["Humidity"])
end

function Pressure()
	SetGlobalFloat("gDisasters_Pressure", GLOBAL_SYSTEM["Atmosphere"]["Pressure"])
end

function BRadiation()
	local BRadiation = GLOBAL_SYSTEM["Atmosphere"]["BRadiation"]
	
	SetGlobalFloat("gDisasters_BRadiation", BRadiation)

	function DamagePlayer()
		for k, v in pairs(player.GetAll()) do
			if BRadiation >= 80 then
				if HitChance(0.5) then
					InflictDamage(v, v, "acid", 4)
				end
			end
		end
	end
	DamagePlayer()
end

function Temperature()

	local temp = GLOBAL_SYSTEM["Atmosphere"]["Temperature"]
	local humidity = GLOBAL_SYSTEM["Atmosphere"]["Humidity"]
	local compensation_max      = 10   -- degrees 
	local body_heat_genK        = engine.TickInterval() -- basically 1 degree Celsius per second
	local body_heat_genMAX      = 0.01/4
	local fire_heat_emission    = 50
	local plytbl                = player.GetAll()

	SetGlobalFloat("gDisasters_Temperature", temp)

	if GetConVar("gdisasters_hud_temp_enable"):GetInt() <= 0 then return end

	local function updateVars()

		if GetConVar("gdisasters_hud_temp_value"):GetInt() <= 0 then return end

		for k, v in pairs(plytbl) do
			local closest_vfire, distance  = FindNearestEntity(v, "vfire") -- find closest fire entity
			local closest_fire, distance_2 = FindNearestEntity(v, "entityflame")
			local closest_envfire, distance_3 = FindNearestEntity(v, "env_fire")
			local closest_ice,  distance_4  = FindNearestEntity(v, "gd_equip_supercooledice") -- find closest ice entity
			local closest_dryice,  distance_5  = FindNearestEntity(v, "gd_equip_dryice") -- find closest ice entity
			
			local heatscale               = 0
			local coolscale               = 0
			
			if closest_vfire != nil then
				heatscale = math.Clamp(200/distance^2, 0,1)
			end
			if closest_fire != nil then
				heatscale = math.Clamp(200/distance_2^2, 0,1)
			end
			if closest_envfire != nil then
				heatscale = math.Clamp(200/distance_3^2, 0,1)
			end
			if closest_ice != nil then
				coolscale = math.Clamp(500/distance_4^2, 0,1) * -1 -- inverse square law
			end
			if closest_dryice != nil then
				coolscale = math.Clamp(200/distance_5^2, 0,1) * -1 -- inverse square law
			end
			
			
			local core_equilibrium           =  math.Clamp((37 - v.gDisasters.Body.Temperature)*body_heat_genK, -body_heat_genMAX, body_heat_genMAX)
			local heatsource_equilibrium     =  math.Clamp((fire_heat_emission * (heatscale ))*body_heat_genK, 0, body_heat_genMAX * 1.3)  -- must be negative cause we wanna temperature difference to only be valid if player is colder than 
			local coldsource_equilibrium     =  math.Clamp((fire_heat_emission * ( coolscale))*body_heat_genK,body_heat_genMAX * -1.3, 0)  -- must be negative cause we wanna temperature difference to only be valid if player is colder than 
		
			local ambient_equilibrium        = math.Clamp(((temp - v.gDisasters.Body.Temperature)*body_heat_genK), -body_heat_genMAX*1.1, body_heat_genMAX * 1.1)
			
			if temp >= 5 and temp <= 37 then
				ambient_equilibrium          = 0
			end
			

			v.gDisasters.Body.Temperature = math.Clamp(v.gDisasters.Body.Temperature + core_equilibrium  + heatsource_equilibrium + coldsource_equilibrium + ambient_equilibrium, 24, 44)

			v:SetNWFloat("BodyTemperature", v.gDisasters.Body.Temperature)
			
		
			
		end
	end
	
	
	local function damagePlayersAndNpc()
		
		if GetConVar("gdisasters_hud_temp_damage"):GetInt() <= 0 then return end
		
		
		for k, v in pairs(plytbl) do

			if GetConVar("gdisasters_hud_temp_value"):GetInt() <= 0 then return end
		
			local wl = isinWater(v)	
			local lv = isinLava(v)
			local outdoor           = isOutdoor(v)
			local tempbody            = v.gDisasters.Body.Temperature
			local alpha_hot  =  1-((44-math.Clamp(tempbody,39,44))/5)
			local alpha_cold =  ((35-math.Clamp(tempbody,24,35))/11)
	
			
			if math.random(1,25) == 25 then
				if alpha_cold != 0 then
					
					InflictDamage(v, v, "cold", alpha_hot + alpha_cold)
					
					if GetConVar("gdisasters_hud_temp_player_speed"):GetInt() == 0 then return end
					
					v:SetWalkSpeed( v:GetWalkSpeed() - (alpha_cold + 1) )
					v:SetRunSpeed( v:GetRunSpeed() - (alpha_cold + 1)  )
				
					
				
				elseif alpha_hot != 0 then
					
					InflictDamage(v, v, "heat", alpha_hot + alpha_cold)
					
					if GetConVar("gdisasters_hud_temp_player_speed"):GetInt() == 0 then return end
					
					v:SetWalkSpeed( v:GetWalkSpeed() - (alpha_hot - 1) )
					v:SetRunSpeed( v:GetRunSpeed() - (alpha_hot - 1)  )
					
					
				else
					if GetConVar("gdisasters_hud_temp_player_speed"):GetInt() == 0 then return end
					
					v:SetWalkSpeed(400)
					v:SetRunSpeed(600)
				end
			end
			
			if temp <= -100 then
				if outdoor then
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.01
				else
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.001	
				end
			elseif temp >= 100 then
				if outdoor then
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature + 0.01
				else
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature + 0.001			
				end
			end
			if temp <= -500 then
				if outdoor then
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.1
				else
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.01	
				end
			elseif temp >= 500 then
				if outdoor then
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature + 0.1
				else
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature + 0.01			
				end
			end
			if temp <= -1000 then
				if outdoor then
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 1
				else
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.1	
				end
			elseif temp >= 1000 then
				if outdoor then
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature + 1
				else
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature + 0.1			
				end
			end
		
			if humidity >= 50 and temp >= 37 and temp >= 5 then
				v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature + 0.001
			elseif humidity >= 50 and temp >= -273.3 and temp <= 4 then
				v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.001
			end
			
			--[[
														Purpose		
				This part basically damages players more in water in addition to cold / heat damage	
				
			--]]
			
		
			if temp >= -273.3 and temp <= 4 then
				if wl==false then
				elseif lv==true then
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature + 0.004
				else
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.004
				end
			elseif temp >= 37 and  temp >= 5 then
				if wl==false then
				elseif lv==true then
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature + 0.004
				else
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.004
				end
			elseif temp < 37 and temp >= 5 then
				if wl==false then
				elseif lv==true then
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature + 0.004
				else
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.004
				end
			end
			
			--[[
														Purpose		
				This part basically kills players if their core temp == 44 or 24 
				
			--]]		
					
			if tempbody >= 44 or tempbody <= 24 then
				if v:Alive() then v:Kill() end
			end
		end
		for k, v in pairs(ents.FindByClass("npc_*")) do

			local outdoor           = isOutdoor(v, true)
			local wl = isinWater(v)
			local lv = isinLava(v)
			
			local closest_vfire, distance  = FindNearestEntity(v, "vfire") -- find closest fire entity
			local closest_fire, distance_2 = FindNearestEntity(v, "entityflame")
			local closest_ice,  distance_3  = FindNearestEntity(v, "gd_equip_supercooledice") -- find closest ice entity
			
			if closest_vfire != nil then
				if distance <= 100 and distance >= 30 then
					InflictDamage(v, v, "heat", 0.01)
				elseif distance <= 30 then
					InflictDamage(v, v, "fire", 0.1)
				end
			elseif closest_fire != nil then
				if distance_2 <= 100 and distance_2 >= 30 then
					InflictDamage(v, v, "heat", 0.01)
				elseif distance_2 <= 30 then
					InflictDamage(v, v, "fire", 0.1)
				end
			end
			if closest_ice != nil then
				if distance_3 <= 50 then
					InflictDamage(v, v, "cold", 0.01)
				end
			end

			if temp <= -100 then
				if outdoor then
					if math.random(1,25) == 25 then
						InflictDamage(v, v, "cold", 100)
					end
				else
					if math.random(1,25) == 25 then
						InflictDamage(v, v, "cold", 10)
					end				
				end
			elseif temp >= 100 then
				if outdoor then
					if math.random(1,25) == 25 then
						InflictDamage(v, v, "heat", 100)
					end
				else
					if math.random(1,25) == 25 then
						InflictDamage(v, v, "heat", 10)
					end				
				end
			end

		
			if temp >= -273.3 and temp <= 4 then
				if wl==true then
					if math.random(1,25) == 25 then
						InflictDamage(v, v, "cold", 7)
					end
				elseif lv==true then
					if math.random(1,25) == 25 then
						InflictDamage(v, v, "heat", 3)
					end
				elseif wl==false and outdoor then
					if math.random(1,25) == 25 then
						InflictDamage(v, v, "cold", 1)
					end
				end
				
			elseif temp >= 37 and  temp >= 5 then
				if wl==true then
					if math.random(1,25) == 25 then
						InflictDamage(v, v, "cold", 3)
					end
				elseif lv==true then
					if math.random(1,25) == 25 then
						InflictDamage(v, v, "heat", 7)
					end
				elseif wl==false and outdoor then
					if math.random(1,25) == 25 then
						InflictDamage(v, v, "heat", 1)
					end
				end
			elseif temp < 37 and temp >= 5 then
				if wl==true then
					if math.random(1,25) == 25 then
						InflictDamage(v, v, "cold", 5)
					end
				elseif lv==true then
					if math.random(1,25) == 25 then
						InflictDamage(v, v, "heat", 5)
					end
				elseif wl==false and outdoor then
				end
			end
		end
	end
	
	local function subzero_Effect()
		if GetConVar("gdisasters_hud_temp_breathing"):GetInt() == 0 then return end
		if temp <= 4 then -- low temperature sfx
			if timer.Exists("Breathing")==false then
				timer.Create( "Breathing", 4, 0, function()
					for k, v in pairs(player.GetAll()) do
						timer.Simple(math.random(0,20)/10, function()
							if !v:IsValid() or v:LookupAttachment("mouth") ==nil then return end
							local mouth_attach = v:LookupAttachment("mouth")
							ParticleEffectAttach( "exhale", PATTACH_POINT_FOLLOW, v, mouth_attach )
							v:EmitSound("streams/disasters/player/exhale.wav", 80, 100, 0.2)
						end)
					end
					for k, v in pairs(ents.FindByClass("npc_*")) do
						timer.Simple(math.random(0,20)/10, function()
							if !v:IsValid() or v:LookupAttachment("mouth") ==nil then return end
							local mouth_attach = v:LookupAttachment("mouth")
							ParticleEffectAttach( "exhale", PATTACH_POINT_FOLLOW, v, mouth_attach )
							v:EmitSound("streams/disasters/player/exhale.wav", 80, 100, 0.2)
						end)
					end
					
				end)
			end
		end
	end
	function GlobalBreathingEffect()
		if temp > 0 or GetConVar("gdisasters_hud_temp_breathing"):GetInt() == 0 then 
			if timer.Exists("Breathing") then
				timer.Destroy("Breathing")
			end
		end
	end
	subzero_Effect()
	GlobalBreathingEffect()
	updateVars()
	damagePlayersAndNpc()
end

function Oxygen()

	local oxygen = GLOBAL_SYSTEM["Atmosphere"]["Oxygen"]
	SetGlobalFloat("gDisasters_Oxygen", oxygen)

    if GetConVar("gdisasters_hud_oxygen_enable"):GetInt() <= 0 then return end

    for k, v in pairs(player.GetAll()) do
        if GetConVar("gdisasters_sb_enabled"):GetInt() >= 1 then return end

        if isUnderWater(v) or isUnderLava(v) then 
            v.gDisasters.Body.Oxygen = math.Clamp( v.gDisasters.Body.Oxygen - 0.05 ,0,100 ) 

            if v.gDisasters.Body.Oxygen <= 0 then
            
                if GetConVar("gdisasters_hud_oxygen_damage"):GetInt() == 0 then return end
            
                if math.random(1, 50)==1 then
                    local dmg = DamageInfo()
                    dmg:SetDamage( math.random(1,25) )
                    dmg:SetAttacker( v )
                    dmg:SetDamageType( DMG_DROWN  )
                
                    v:TakeDamageInfo(  dmg)
                end
            
            end
		elseif oxygen <= 20 then
			v.gDisasters.Body.Oxygen = math.Clamp( v.gDisasters.Body.Oxygen - 0.001 ,0,100 ) 
			
			if v.NextChokeOnAsh == nil then v.NextChokeOnAsh = CurTime() end
	
			if CurTime() >= v.NextChokeOnAsh then 
				local mouth_attach = v:LookupAttachment("mouth")
				ParticleEffectAttach( "cough_ash", PATTACH_POINT_FOLLOW, v, mouth_attach )
				v:TakeDamage( math.random(9,14), self, self)
				clPlaySound(v, "streams/disasters/player/cough.wav", math.random(80,120), 1)
		
				v.NextChokeOnAsh = CurTime() + math.random(3,8)
			end
			
            if v.gDisasters.Body.Oxygen <= 0 then    
                if v:Alive() then v:Kill() end
            end
        else
            v.gDisasters.Body.Oxygen = math.Clamp( v.gDisasters.Body.Oxygen + 0.5 , 0,100 )
        end

		v:SetNWFloat("BodyOxygen", v.gDisasters.Body.Oxygen)
    end
    for k, v in pairs(ents.FindByClass("npc_*")) do           
        if isinWater(v) or isinLava(v) then 
            timer.Simple(5, function()
                if GetConVar("gdisasters_hud_oxygen_damage"):GetInt() == 0 then return end
                
				if math.random(1, 50)==1 and v:IsValid() then
				    local dmg = DamageInfo()
				    dmg:SetDamage( math.random(1,25) )
				    dmg:SetAttacker( v )
				    dmg:SetDamageType( DMG_DROWN  )
                
				    v:TakeDamageInfo(  dmg)
                end
            end)
        
        end
    
    end
end

function WindUnweld(ent)

	local table_wind = GLOBAL_SYSTEM["Atmosphere"]["Wind"]
	local wind_mul   = (math.Clamp(table_wind["Speed"],200, 256) -200) / 10
	local phys = ent:GetPhysicsObject()
	

	if HitChance(0.01 + wind_mul ) then
		local can_play_sound = false
		
		
		if #constraint.GetTable( ent ) != 0 then
			can_play_sound = true 
		elseif phys:IsMotionEnabled()==false then
			can_play_sound = true 
		end	
		
		if can_play_sound then
		
			local windspeed  = table_wind["Speed"]
		
		
		
			if windspeed > 60 then 
			
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
				
				phys:EnableMotion(true)
				phys:Wake()
				constraint.RemoveAll( ent )

			
			end
		end
	end

end

function Wind()

	local table_wind = GLOBAL_SYSTEM["Atmosphere"]["Wind"]
	local windspeed  = table_wind["Speed"]
	local winddir    = table_wind["Direction"]
	local windphysics_enabled = GetConVar( "gdisasters_wind_physics_enabled" ):GetInt() == 1 
	local windconstraints_remove = GetConVar( "gdisasters_wind_candamageconstraints" ):GetInt() == 1

	
	SetGlobalFloat("gDisasters_Wind", windspeed)
	SetGlobalVector("gDisasters_Wind_Direction", winddir)
	

	
	local function performTrace(ply, direction)
	
		local tr = util.TraceLine( {
			start = ply:GetPos(),
			endpos = ply:GetPos() + direction * 60000,
			filter = function( ent ) if ent:IsWorld() then return true end end
		} )
	
	
		
		return tr.HitPos
	end
	

	
	for k, v in pairs(player.GetAll()) do
		
		local isOutdoor       = isOutdoor(v)
		local pos        	  = v:GetPos()
		local hitLeft   	  = performTrace(v, Vector(1,0,0))
		local hitRight   	  = performTrace(v, Vector(-1,0,0))
		
		local hitForward 	  = performTrace(v, Vector(0,1,0))
		local hitBehind       = performTrace(v, Vector(0,-1,0))		
		
		local area            = (0.5 *(hitLeft:Distance(hitRight) * pos:Distance(hitForward))) + (0.5 *(hitLeft:Distance(hitRight) * pos:Distance(hitBehind)))  
		local area_percentage = math.Clamp(area / 5000000, 0, 1)
		
		
		local local_wind      = area_percentage * windspeed
		if isOutdoor==false then local_wind = 0 end 
		
		v.gDisasters.Area.LocalWind = local_wind
		v:SetNWFloat("LocalWind", local_wind)
		
		--[[  now we calculate area  using this diagram 
		
		
		
		
		
						[ ]
						/	| \   area 2
					/   |   \
					/	|    \
					<----player-x
					\	|    /
						\	|  /  area 1
						\	| /
						|
						[ ]
						
						
						
		--]]
		
		-- frictional force has a maximum of 400 gmod units 
		-- 
		
		local windvel           = convert_MetoSU(convert_KMPHtoMe( ( math.Clamp((( math.Clamp(local_wind / 256, 0, 1) * 5)^2) * local_wind, 0, local_wind)  / 2.9225))) * winddir
		local frictional_scalar = math.Clamp(windvel:Length(),-400, 400)
		local frictional_velocity = frictional_scalar * -windvel:GetNormalized()
		local windvel_new         = ( windvel + frictional_velocity ) * 0.5
	
		
	
	
		
	
		if isOutdoor and  IsSomethingBlockingWind(v)==false  then
		
			if ((v:GetVelocity() - windvel_new) - v:GetVelocity()):Length()!=0 then
			
				v:SetVelocity( ((v:GetVelocity() - windvel_new) - v:GetVelocity()) * 0.3 )
			
			end
		
		
		
		end
			
			
		
		
	
	end
	
	if windphysics_enabled and windspeed >= 30 and CurTime() >= GLOBAL_SYSTEM["Atmosphere"]["Wind"]["NextThink"] then
		GLOBAL_SYSTEM["Atmosphere"]["Wind"]["NextThink"] = CurTime() + GetConVar( "gdisasters_wind_physics_simquality" ):GetFloat()
		
		for k, v in pairs(ents.GetAll()) do
			local phys = v:GetPhysicsObject()
			if phys:IsValid() and v:IsPlayer()==false and  (v:GetClass()!= "phys_constraintsystem" and v:GetClass()!= "phys_constraint"  and v:GetClass()!= "logic_collision_pair") then 
			
				local outdoor = isOutdoor(v, true) 
				local blocked = IsSomethingBlockingWind(v)
				
				if blocked==false and outdoor==true then
					
					if v:IsNPC() or v:IsNextBot() then
					
						local pos        	  = v:GetPos()
						local hitLeft   	  = performTrace(v, Vector(1,0,0))
						local hitRight   	  = performTrace(v, Vector(-1,0,0))

						local hitForward 	  = performTrace(v, Vector(0,1,0))
						local hitBehind       = performTrace(v, Vector(0,-1,0))		

						local area            = ((hitLeft:Distance(hitRight) * pos:Distance(hitForward))) + (0.5 *(hitLeft:Distance(hitRight) * pos:Distance(hitBehind)))  
						local area_percentage = math.Clamp(area / 5000000, 0, 1)
						local mass    = phys:GetMass()

						local wind 				=  area_percentage * windspeed

						local windvel           = (convert_MetoSU(convert_KMPHtoMe( ( (math.Clamp((( math.Clamp( wind / 256, 0, 1) * 5)^2) * wind , 0, wind ) ) / 2.9225))) ) * winddir 
						local frictional_scalar = math.Clamp(windvel:Length(),-400, 400) 
						local frictional_velocity = frictional_scalar * -windvel:GetNormalized()
						local windvel_new         = ( windvel  + frictional_velocity ) * 2

						local windvel_cap         = windvel_new:Length() - v:GetVelocity():Length() 

						if windvel_cap > 0 then
						
							if windspeed > 25 then 
							
								if mass < 80 then 
								
									v:SetVelocity( ((v:GetVelocity() - windvel_new) - v:GetVelocity()) * 5  )
								
								end

								if windspeed >= 80 then 	

									if mass > 80 and mass < 2000 then
									
										v:SetVelocity( ((v:GetVelocity() - windvel_new) - v:GetVelocity()) * 3 )
									
									elseif mass > 2000 then 
									
										v:SetVelocity( ((v:GetVelocity() - windvel_new) - v:GetVelocity()) )

									end


								end
							
							end
						
						end

					end

					local area    = Area(v)
					local mass    = phys:GetMass()

					local force_mul_area     = math.Clamp((area/680827),0,1) -- bigger the area >> higher the f multiplier is
					local friction_mul       = math.Clamp((mass/50000),0,1) -- lower the mass  >> lower frictional force 
					local avrg_mul           = (force_mul_area + friction_mul) / 2 

					local windvel           = convert_MetoSU(convert_KMPHtoMe(windspeed / 2.9225)) * winddir 
					local frictional_scalar = math.Clamp(windvel:Length(), 0, mass)
					local frictional_velocity = frictional_scalar * -windvel:GetNormalized()
					local windvel_new         = (windvel + frictional_velocity) * -1

					local windvel_cap         = windvel_new:Length() - v:GetVelocity():Length() 

					if windvel_cap > 0 then
						
						phys:AddVelocity(windvel_new )
					
					end
			

					if windconstraints_remove then 
						WindUnweld(v)
					
					end
				end
			end
		end
			
	end
end
		
function stormfox2()
	if GetConVar("gdisasters_graphics_stormfox"):GetInt() >= 1 then 
		
		if Stormfox then 
			GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = StormFox.GetTemperature()
			GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"] = convert_MetoKMPH(StormFox.GetNetworkData("Wind",0) * 0.75)
			GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Direction"] = Vector(-StormFox.GetWindVector().x, -StormFox.GetWindVector().y, 0)
			
			if !StormFox.IsRaining() then
				GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Humidity"]
				GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Pressure"]
			else
				GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 100
				GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = 96000
			end
		
			if StormFox.IsThunder() then
				local ent = ents.FindByClass("gd_d3_lightningstorm")[1]
				if !ent then return end
				if ent:IsValid() then ent:Remove() end
			end
		elseif StormFox2 then
			
			GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = StormFox2.Temperature.Get()
			GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"] = convert_MetoKMPH(StormFox2.Wind.GetForce())
			GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Direction"] = Vector(-StormFox2.Wind.GetVector().x, -StormFox2.Wind.GetVector().y, 0)
			
			if !StormFox2.Weather.IsRaining() and !StormFox2.Weather.IsSnowing() and StormFox2.Weather.GetRainAmount(0) then
				GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Humidity"]
				GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Pressure"]
			elseif StormFox2.Weather.IsRaining() and StormFox2.Weather.GetRainAmount(1) then
				GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 100
				GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = 96000
			elseif StormFox2.Weather.IsSnowing() and StormFox2.Weather.GetRainAmount(0) then
				GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 100
				GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = 96000
			else
				GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Humidity"]
				GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Pressure"]
			end
		
			if StormFox2.Thunder.IsThundering() then
				local ent = ents.FindByClass("gd_d3_lightningstorm")[1]
				if !ent then return end
				if ent:IsValid() then ent:Remove() end
			end
		end
	end
end

function spacebuild()
	if GetConVar("gdisasters_sb_enabled"):GetInt() <= 0 then return end
	if CAF or LS then  
		for k, v in pairs(player.GetAll()) do
			v.gDisasters.Body.Oxygen = v.suit.air
			v.gDisasters.Body.Energy = v.suit.energy
			v.gDisasters.Body.Coolant = v.suit.coolant

			v:SetNWFloat("BodyOxygen", v.gDisasters.Body.Oxygen)
			v:SetNWFloat("BodyTemperature", v.gDisasters.Body.Temperature)
			v:SetNWFloat("BodyEnergy", v.gDisasters.Body.Energy)
			v:SetNWFloat("BodyCoolant", v.gDisasters.Body.Coolant)

			GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = convert_KevintoCelcius(v.caf.custom.ls.temperature)
			
		end
	end
end