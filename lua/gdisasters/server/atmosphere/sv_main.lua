SetGlobalFloat("gDisasters_Temperature", 0)
SetGlobalFloat("gDisasters_Pressure", 0)
SetGlobalFloat("gDisasters_Humidity", 0)
SetGlobalFloat("gDisasters_Wind", 0)
SetGlobalVector("gDisasters_Wind_Direction", Vector(0,0,0))

function Atmosphere()
	local scale                                = (1/engine.TickInterval()) / 66
	GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = math.Clamp(GLOBAL_SYSTEM["Atmosphere"]["Temperature"],-273.3, 273.3)
	GLOBAL_SYSTEM["Atmosphere"]["Humidity"]    = math.Clamp(GLOBAL_SYSTEM["Atmosphere"]["Humidity"],0, 100)
	GLOBAL_SYSTEM["Atmosphere"]["Pressure"]    = math.Clamp(GLOBAL_SYSTEM["Atmosphere"]["Pressure"], 0, math.huge)


	Wind()
	Pressure()
	Humidity()
	AtmosphereFadeControl()
	gDisasters_stormfox2()
	gDisasters_spacebuild()
	gDisasters_ProcessTemperature()
	gDisasters_ProcessOxygen()
	
end
hook.Add("Tick", "atmosphericLoop", Atmosphere)


function AtmosphereFadeControl()

	GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"]=Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"])
	GLOBAL_SYSTEM["Atmosphere"]["Pressure"]=Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["Pressure"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"])
	GLOBAL_SYSTEM["Atmosphere"]["Temperature"]=Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["Temperature"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"])
	GLOBAL_SYSTEM["Atmosphere"]["Humidity"]=Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["Humidity"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"])
	GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Direction"]=LerpVector(0.005, GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Direction"], GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"])

end

function Humidity()
	SetGlobalFloat("gDisasters_Humidity", GLOBAL_SYSTEM["Atmosphere"]["Humidity"])
end

function Pressure()
	SetGlobalFloat("gDisasters_Pressure", GLOBAL_SYSTEM["Atmosphere"]["Pressure"])
end

function gDisasters_stormfox2()
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

function gDisasters_spacebuild()
	if GetConVar("gdisasters_sb_enabled"):GetInt() <= 0 then return end
	if CAF or LS then  
		for k, v in pairs(player.GetAll()) do
			v.gDisasters.Body.Oxygen = v.suit.air
			v.gDisasters.Body.Energy = v.suit.energy
			v.gDisasters.Body.Coolant = v.suit.coolant
			v.gDisasters.Body.Temperature = 37

			v:SetNWFloat("BodyOxygen", v.gDisasters.Body.Oxygen)
			v:SetNWFloat("BodyTemperature", v.gDisasters.Body.Temperature)
			v:SetNWFloat("BodyEnergy", v.gDisasters.Body.Energy)
			v:SetNWFloat("BodyCoolant", v.gDisasters.Body.Coolant)

			GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = convert_KevintoCelcius(v.caf.custom.ls.temperature)
			
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
		
