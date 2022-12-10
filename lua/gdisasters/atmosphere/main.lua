	
if (SERVER) then
	SetGlobalFloat("gDisasters_Temperature", 0)
	SetGlobalFloat("gDisasters_Pressure", 0)
	SetGlobalFloat("gDisasters_Humidity", 0)
	SetGlobalFloat("gDisasters_Wind", 0)

	function Atmosphere()
		local scale                                = (1/engine.TickInterval()) / 66
		GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = math.Clamp(GLOBAL_SYSTEM["Atmosphere"]["Temperature"],-273.3, 273.3)
		GLOBAL_SYSTEM["Atmosphere"]["Humidity"]    = math.Clamp(GLOBAL_SYSTEM["Atmosphere"]["Humidity"],0, 100)
	

		Wind()
		Pressure()
		Humidity()
		AtmosphereFadeControl()
		stormfox2()
		gDisasters_GlobalBreathingEffect()
		gDisasters_ProcessTemperature()
		gDisasters_ProcessOxygen()
		
	
	
	

	end
	hook.Add("Tick", "atmosphericLoop", Atmosphere)
	
	
	function AtmosphereFadeControl()
	
		GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"]=Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"])
		GLOBAL_SYSTEM["Atmosphere"]["Pressure"]=Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["Pressure"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"])
		GLOBAL_SYSTEM["Atmosphere"]["Temperature"]=Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["Temperature"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"])
		GLOBAL_SYSTEM["Atmosphere"]["Humidity"]=Lerp(0.005, GLOBAL_SYSTEM["Atmosphere"]["Humidity"],GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"])
		GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Direction"] = GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"]
	
	end
	
	function stormfox2()
	
	    if GetConVar("gdisasters_stormfox_enable"):GetInt() >= 1 then 
	   		if Stormfox and StormFox.Version < 2 then 
				    for k, v in pairs(player.GetAll()) do 
				    	v:ChatPrint("StormFox 1 is no compatible with gDisasters. Please install stormfox 2")
				    end
	   		    return
	   		end
	
	   		local temp = StormFox2.Temperature.Get()
	   		local wind = StormFox2.Wind.GetForce()
	
	   		GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = temp
			GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"] = wind
	   		GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Direction"] = Vector(1,0,0)
	
	
	   		if !StormFox2.Weather.IsRaining() and !StormFox2.Weather.IsSnowing() and StormFox2.Weather.GetRainAmount(0) then
	   		    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 0
	   		    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = 102000
	   		elseif StormFox2.Weather.IsRaining() and StormFox2.Weather.GetRainAmount(1) then
	   		    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 100
	   		    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = 96000
	   		elseif StormFox2.Weather.IsSnowing() and StormFox2.Weather.GetRainAmount(0)then
	   		    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 100
	   		    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = 96000
	   		else
	   		    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 0
	   		    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = 102000
	   		end
	
	   		if StormFox2.Thunder.IsThundering() then
	   		    local ent = ents.FindByClass("gd_d3_lightningstorm")[1]
	   		    if !ent then return end
	   		    if ent:IsValid() then ent:Remove() end
	   		end
		else
			GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Humidity"]
			GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Pressure"]
		end
	end
	
	
	function Humidity()
	
		SetGlobalFloat("gDisasters_Humidity", GLOBAL_SYSTEM["Atmosphere"]["Humidity"])
	end
	
	
	function Pressure()
		GLOBAL_SYSTEM["Atmosphere"]["Pressure"] = math.Clamp(GLOBAL_SYSTEM["Atmosphere"]["Pressure"], 0, math.huge)
		local pressure = GLOBAL_SYSTEM["Atmosphere"]["Pressure"]
		SetGlobalFloat("gDisasters_Pressure", pressure)
		
		
	end
	
	function WindUnweld(ent)
	
		local table_wind = GLOBAL_SYSTEM["Atmosphere"]["Wind"]
		local wind_mul   = (math.Clamp(table_wind["Speed"],200, 256) -200) / 10
		
	
		if HitChance(0.01 + wind_mul ) then
			local can_play_sound = false
			
			
			if #constraint.GetTable( ent ) != 0 then
				can_play_sound = true 
			elseif ent:GetPhysicsObject():IsMotionEnabled()==false then
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
				
				constraint.RemoveAll( ent )
				ent:GetPhysicsObject():EnableMotion( true )
				
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
							
						end	
							
						if windspeed >= 80 then 	
							
						if mass > 80 and mass < 2000 then
						
						v:SetVelocity( ((v:GetVelocity() - windvel_new) - v:GetVelocity()) * 3 )
						
						else
						
						if mass > 2000 then 
						
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
						
						phys:AddVelocity(  windvel_new )
						
						end
					
						
						if windconstraints_remove then 
							WindUnweld(v)
						
						end
					
					end
				end
				
			end
		end
		
end




end


if (CLIENT) then

	function Atmosphere()
		
		gDisasters_WindControl()
		
		
		

	end
	hook.Add("Tick", "atmosphericLoop", Atmosphere)

	function gDisasters_WindControl()
		if LocalPlayer().gDisasters == nil then return end
		if LocalPlayer().Sounds == nil then LocalPlayer().Sounds = {} end
		
		local local_wind    = LocalPlayer():GetNWFloat("LocalWind")
		local outside_fac   = LocalPlayer().gDisasters.Outside.OutsideFactor/100 
		local wind_weak_vol = math.Clamp( ( (math.Clamp((( math.Clamp(local_wind / 20, 0, 1) * 5)^2) * local_wind, 0, local_wind)) / 20), 0, GetConVar("gdisasters_sound_Light_Wind"):GetFloat()) 
		
		
		if LocalPlayer().gDisasters.Outside.IsOutside then
			wind_weak_vol   = wind_weak_vol * math.Clamp(outside_fac , 0, 1) 
		else
			wind_weak_vol   = wind_weak_vol * math.Clamp(outside_fac , 0.1, 1)
		end
		
		local wind_mod_vol  = math.Clamp( ( (local_wind-20) / 60), 0, GetConVar("gdisasters_sound_Moderate_Wind"):GetFloat()) * outside_fac 		
		local wind_str_vol  = math.Clamp( ( (local_wind-80) / 120), 0, GetConVar("gdisasters_sound_Heavy_Wind"):GetFloat()) * outside_fac 	
		
		if LocalPlayer().Sounds["Wind_Heavy"] == nil then
			
			
			LocalPlayer().Sounds["Wind_Light"]         = createLoopedSound(LocalPlayer(), "streams/disasters/nature/wind_weak.wav")
			LocalPlayer().Sounds["Wind_Moderate"]      = createLoopedSound(LocalPlayer(), "streams/disasters/nature/wind_moderate.wav")
			LocalPlayer().Sounds["Wind_Heavy"]         = createLoopedSound(LocalPlayer(), "streams/disasters/nature/wind_heavy.wav")
			
			LocalPlayer().Sounds["Wind_Light"]:ChangeVolume(0, 0)
			LocalPlayer().Sounds["Wind_Moderate"]:ChangeVolume(0, 0)
			LocalPlayer().Sounds["Wind_Heavy"]:ChangeVolume(0, 0)
						 
		end

		LocalPlayer().Sounds["Wind_Light"]:ChangeVolume(wind_weak_vol, 0)
		LocalPlayer().Sounds["Wind_Moderate"]:ChangeVolume(wind_mod_vol, 0)
		LocalPlayer().Sounds["Wind_Heavy"]:ChangeVolume(wind_str_vol, 0)		
		
		
	end
	
	
end













