if (CLIENT) then

	function gfx_temperatureEffects()
		
		if GetConVar("gdisasters_hud_temp_cl"):GetInt() == 0 then return end

		local temp            = LocalPlayer():GetNWFloat("BodyTemperature")
		local blur_alpha_hot  =  1-((44-math.Clamp(temp,39,44))/5)
		local blur_alpha_cold =  ((35-math.Clamp(temp,24,35))/11)
		local iangle          = LocalPlayer():EyeAngles()

		local shivering_intensity =  ((((math.Clamp(36-temp, 0, 4)/2) - 1)^2) * -1) + 1   -- y = -x^2 + 1 curve ( you can check online )
		
		local cm_hot = {}
			cm_hot[ "$pp_colour_addr" ]        = 0 + (blur_alpha_hot)	
			cm_hot[ "$pp_colour_addg" ]        = 0
			cm_hot[ "$pp_colour_addb" ]        = 0
			cm_hot[ "$pp_colour_brightness" ]  = 0
			cm_hot[ "$pp_colour_contrast" ]    = 1 - (blur_alpha_hot^2)
			cm_hot[ "$pp_colour_colour" ]      = 1
			cm_hot[ "$pp_colour_mulr" ]        = 0
			cm_hot[ "$pp_colour_mulg" ]        = 0
			cm_hot[ "$pp_colour_mulb" ]        = 0

		local cm_cold = {}
			cm_cold[ "$pp_colour_addr" ]        = 0 + (blur_alpha_cold)	
			cm_cold[ "$pp_colour_addg" ]        = 0
			cm_cold[ "$pp_colour_addb" ]        = 0 + (blur_alpha_cold)	
			cm_cold[ "$pp_colour_brightness" ]  = 0
			cm_cold[ "$pp_colour_contrast" ]    = 1 - (blur_alpha_cold^2)
			cm_cold[ "$pp_colour_colour" ]      = 1 - (blur_alpha_cold^2)
			cm_cold[ "$pp_colour_mulr" ]        = 0 - (blur_alpha_cold^2)
			cm_cold[ "$pp_colour_mulg" ]        = 0 - (blur_alpha_cold^2)
			cm_cold[ "$pp_colour_mulb" ]        = 0 + (blur_alpha_cold)	
	

	
		if temp > 39 and math.random(1,400)==1 then
			if GetConVar("gdisasters_hud_temp_vomit"):GetInt() == 0 then return end
			if temp >= 42 then
				
				hud_gDisastersVomitBlood()
		
			else
			
				hud_gDisastersVomit()
			end
		end
		if temp < 35 and math.random(1,400)==1 then
			if GetConVar("gdisasters_hud_temp_sneeze"):GetInt() == 0 then return end
			if temp <= 32 then
				
				hud_gDisastersSneezeBig()
		
			else
			
				hud_gDisastersSneeze()
			end
		end

		LocalPlayer():SetEyeAngles( Angle(iangle.x + (math.random(-200 * shivering_intensity,200 * shivering_intensity)/100), iangle.y + (math.random(-100 * shivering_intensity,100 * shivering_intensity)/100) , 0))
		DrawColorModify( cm_hot )
		DrawColorModify( cm_cold )
		DrawMotionBlur( 0.1, blur_alpha_hot, 0.05)
		DrawMotionBlur( 0.1, blur_alpha_cold, 0.05)
			
		
		
	
	end
		
		
	hook.Add("RenderScreenspaceEffects", "Temperature Effects", gfx_temperatureEffects)
	
	

end


if (SERVER) then


function gDisasters_ProcessTemperature()

	if GetConVar("gdisasters_hud_temp_sv"):GetInt() == 0 then return end

	local temp = GLOBAL_SYSTEM["Atmosphere"]["Temperature"]
	local compensation_max      = 10   -- degrees 
	local body_heat_genK        = engine.TickInterval() -- basically 1 degree Celsius per second
	local body_heat_genMAX      = 0.01/4
	local fire_heat_emission    = 50
	local plytbl                = player.GetAll()
	SetGlobalFloat("gDisasters_Temperature", temp)
				
	local function updateVars()

		if GetConVar("gdisasters_hud_temp_updatevars"):GetInt() == 0 then return end

		for k, v in pairs(plytbl) do
		
			local closest_vfire, distance  = FindNearestEntity(v, "vfire") -- find closest fire entity
			local closest_ice,  distance_2  = FindNearestEntity(v, "gd_equip_supercooledice") -- find closest ice entity
			local closest_fire, distance_3 = FindNearestEntity(v, "entityflame")
			
			local heatscale               = 0
			local coolscale               = 0
			
			if closest_vfire != nil then
				if not vFireInstalled then heatscale = math.Clamp(1000/distance^2, 0,1) else heatscale = math.Clamp(200/distance^2, 0,1) end
			end
			
			if closest_fire != nil then
				heatscale = math.Clamp(200/distance_3^2, 0,1)
			end

			if closest_ice != nil then
				coolscale = math.Clamp(500/distance_2^2, 0,1) * -1 -- inverse square law
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
	
	
	local function damagePlayers()
		
		if GetConVar("gdisasters_hud_temp_damage"):GetInt() == 0 then return end
		
		for k, v in pairs(plytbl) do
		
			--[[
					                                  Purpose		
				This part basically calculates how much damage should be dealt to players 
				
			--]]
			
			local temp            = v.gDisasters.Body.Temperature
			local outdoor           = v.gDisasters.Area.IsOutdoor
			local alpha_hot  =  1-((44-math.Clamp(temp,39,44))/5)
			local alpha_cold =  ((35-math.Clamp(temp,24,35))/11)	
			
			if math.random(1,25) == 25 then
				if alpha_cold != 0 then
					v:SetWalkSpeed( v:GetWalkSpeed() - (alpha_cold + 1) )
					v:SetRunSpeed( v:GetRunSpeed() - (alpha_cold + 1)  )

					InflictDamage(v, v, "cold", alpha_hot + alpha_cold)

				elseif alpha_hot != 0 then
					v:SetWalkSpeed( v:GetWalkSpeed() - (alpha_hot - 1) )
					v:SetRunSpeed( v:GetRunSpeed() - (alpha_hot - 1)  )
					
					InflictDamage(v, v, "heat", alpha_hot + alpha_cold)
				else
					v:SetWalkSpeed(400)
					v:SetRunSpeed(600)
				end
			end
			
			
			
			if  GLOBAL_SYSTEM["Atmosphere"]["Temperature"] <= -100 and outdoor or GLOBAL_SYSTEM["Atmosphere"]["Temperature"] >= 250 and outdoor then
				if v:Alive() then v:Kill() end
			end

			if GLOBAL_SYSTEM["Atmosphere"]["Humidity"] >= 30 and GLOBAL_SYSTEM["Atmosphere"]["Temperature"] >= 37 and GLOBAL_SYSTEM["Atmosphere"]["Temperature"] >= 5 then
				v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature + 0.001
			end

			if GLOBAL_SYSTEM["Atmosphere"]["Humidity"] >= 30 and GLOBAL_SYSTEM["Atmosphere"]["Temperature"] >= -273.3 and GLOBAL_SYSTEM["Atmosphere"]["Temperature"] <= 4 then
				v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.001
			end
			
			--[[
					                                  Purpose		
				This part basically damages players more in water in addition to cold / heat damage	
				
			--]]
			

			if  GLOBAL_SYSTEM["Atmosphere"]["Temperature"] >= -273.3 and  GLOBAL_SYSTEM["Atmosphere"]["Temperature"] <= 4 then
				local wl = v:WaterLevel()
				if wl==0 then
				elseif wl==1 then
				
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.001
					

				elseif wl==2 then
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.002
				elseif wl==3 then
				
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.004
		
				end
			end

			if  GLOBAL_SYSTEM["Atmosphere"]["Temperature"] >= 37 and  GLOBAL_SYSTEM["Atmosphere"]["Temperature"] >= 5 then
				local wl = v:WaterLevel()
				if wl==0 then
				elseif wl==1 then
				
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.001
					

				elseif wl==2 then
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.002
				elseif wl==3 then
				
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.004
		
				end
			end
			if  GLOBAL_SYSTEM["Atmosphere"]["Temperature"] < 37 and  GLOBAL_SYSTEM["Atmosphere"]["Temperature"] >= 5 then
				local wl = v:WaterLevel()
				if wl==0 then
				elseif wl==1 then
				
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.001
					

				elseif wl==2 then
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.002
				elseif wl==3 then
				
					v.gDisasters.Body.Temperature = v.gDisasters.Body.Temperature - 0.004
		
				end
			end
			
			--[[
					                                  Purpose		
				This part basically kills players if their core temp == 44 or 24 
				
			--]]		
					
			if temp >= 44 or temp <= 24 then
				if v:Alive() then v:Kill() end

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
	damagePlayers()
end

function gDisasters_GlobalBreathingEffect()
	if GetConVar("gdisasters_hud_temp_breathing"):GetInt() == 0 then return end
	
	local temp = GLOBAL_SYSTEM["Atmosphere"]["Temperature"]
	
	if temp > 0 then 
		if timer.Exists("Breathing") then
			timer.Destroy("Breathing")
		end
	end
	
end














end