function gDisasters_ProcessTemperature()

	local temp = GLOBAL_SYSTEM["Atmosphere"]["Temperature"]
	local compensation_max      = 10   -- degrees 
	local body_heat_genK        = engine.TickInterval() -- basically 1 degree Celsius per second
	local body_heat_genMAX      = 0.01/4
	local fire_heat_emission    = 50
	local plytbl                = player.GetAll()
	
	SetGlobalFloat("gDisasters_Temperature", temp)

	if GetConVar("gdisasters_hud_temp_enable"):GetInt() == 0 then return end
				
	local function updateVars()
	
		for k, v in pairs(plytbl) do
		
			local closest_vfire, distance  = FindNearestEntity(v, "vfire") -- find closest fire entity
			local closest_fire, distance_2 = FindNearestEntity(v, "entityflame")
			local closest_ice,  distance_3  = FindNearestEntity(v, "gd_equip_supercooledice") -- find closest ice entity
			
			local heatscale               = 0
			local coolscale               = 0
			
			if closest_vfire != nil then
				heatscale = math.Clamp(200/distance^2, 0,1)
			elseif closest_fire != nil then
				heatscale = math.Clamp(1000/distance_2^2, 0,1)
			end
			
			if closest_ice != nil then
				coolscale = math.Clamp(500/distance_3^2, 0,1) * -1 -- inverse square law
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
		
		if GetConVar("gdisasters_hud_temp_damage"):GetInt() == 0 then return end
		
		for k, v in pairs(plytbl) do
		
			--[[
														Purpose		
				This part basically calculates how much damage should be dealt to players 
				
			--]]
		
			local temp = GLOBAL_SYSTEM["Atmosphere"]["Temperature"]
			local humidity = GLOBAL_SYSTEM["Atmosphere"]["Humidity"]
			local tempbody            = v.gDisasters.Body.Temperature
			local outdoor           = isOutdoor(v)
			local alpha_hot  =  1-((44-math.Clamp(tempbody,39,44))/5)
			local alpha_cold =  ((35-math.Clamp(tempbody,24,35))/11)
			local wl = isinWater(v)	
			local lv = isinLava(v)	
			
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
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.1
				else
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.01	
				end
			elseif temp >= 100 then
				if outdoor then
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature + 0.1
				else
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature + 0.01			
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
			local temp = GLOBAL_SYSTEM["Atmosphere"]["Temperature"]
			local outdoor           = isOutdoor(v, true)
			local wl = isinWater(v)
			local lv = isinLava(v)
			
			
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
	subzero_Effect()
	updateVars()
	damagePlayersAndNpc()
end

function gDisasters_GlobalBreathingEffect()
	local temp = GLOBAL_SYSTEM["Atmosphere"]["Temperature"]
	
	if temp > 0 or GetConVar("gdisasters_hud_temp_breathing"):GetInt() == 0 then 
		if timer.Exists("Breathing") then
			timer.Destroy("Breathing")
		end
	end
	
end













