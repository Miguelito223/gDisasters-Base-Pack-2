SetGlobalFloat("gd_seismic_activity", 0)

GLOBAL_SYSTEM = {
				["Atmosphere"] 	= {
						["Wind"]        = {
											["Speed"]=0,
											["Direction"]=Vector(1,0,0),
											["NextThink"]=CurTime()
										   },
										
					
						["Pressure"]    = 100000,
						
						["Temperature"] = 23,
						
						["Humidity"]    = 25,
					
						["BRadiation"]  = 0.1
				}
				}
				
GLOBAL_SYSTEM_TARGET = {
				["Atmosphere"] 	= {
						["Wind"]        = {
											["Speed"]=0,
											["Direction"]=Vector(1,0,0)
										   },
					
						["Pressure"]    = 100000,
						
						["Temperature"] = 23,
						
						["Humidity"]    = 25,
					
						["BRadiation"]  = 0.1
				}
				}
				
GLOBAL_SYSTEM_ORIGINAL = {
				["Atmosphere"] 	= {
						["Wind"]        = {
											["Speed"]=0,
											["Direction"]=Vector(1,0,0)
										   },
					
						["Pressure"]    = 100000,
						
						["Temperature"] = 23,
						
						["Humidity"]    = 25,
					
						["BRadiation"]  = 0.1
				}
				}


concommand.Add("gdisasters_smite", function()

	local bounds    = getMapSkyBox()
	local min       = bounds[1]
	local max       = bounds[2]
	
	
	
	local startpos  = Vector(math.random(min.x, max.x), math.random(min.y, max.y), max.z)
	local tr = util.TraceLine( {
		start = startpos,
		endpos = startpos - Vector(0,0,50000),
	} )
	
	local endpos = tr.HitPos
	
	
	local color = table.Random({"blue", "purple"})
	local grounded = table.Random({"NotGrounded","Grounded"})
	
	CreateLightningBolt(startpos, endpos,  {"purple","blue"} ,  {"Grounded","NotGrounded"} )


end)

concommand.Add("setlight", function(ply, cmd, args)
	setMapLight(args[1])
end)

concommand.Add("setposme", function(ply, cmd, args)
	ply:SetPos(ply:GetEyeTrace().HitPos)
end)


concommand.Add("tickrate", function(ply, cmd, args)
	print( 1 / engine.TickInterval())
end)

concommand.Add("unfreeze", function()

	for k, v in pairs(ents.GetAll()) do
		if v:GetPhysicsObject():IsValid() then v:GetPhysicsObject():EnableMotion(true) v:GetPhysicsObject():Wake() end 
	end
end)


concommand.Add("getpropnum", function()

	print(#ents.FindByClass("prop_physics"))
end)

concommand.Add("ent_getinfo", function(ply)

	local ent = ply:GetEyeTrace().Entity
	PrintTable(ent:GetTable())
end)

concommand.Add("ent_getall", function()
	for k, v in pairs(ents.GetAll()) do
		print(v)
	end
end)

concommand.Add("freeze", function()

	for k, v in pairs(ents.GetAll()) do
		if v:GetPhysicsObject():IsValid() then v:GetPhysicsObject():EnableMotion(false)  end 
	end
end)


concommand.Add("gdisasters_settemp", function(cmd, args, temp)
	local temperature = temp[1]
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = tonumber(temperature)
end)



concommand.Add("gdisasters_setwind", function(cmd, args, wind)
	local speed = wind[1]
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"] = tonumber(speed)
end)

concommand.Add("gdisasters_setwind_direction", function(cmd, args, wind)
	local direction = Vector(tonumber(wind[1]), tonumber(wind[2]), tonumber(wind[3]))
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = direction
end)


concommand.Add("gdisasters_setbody_temp", function(cmd, args, temp)
	for k, v in pairs(player.GetAll()) do
		local temperature = temp[1]
		v.gDisasters.Body.Temperature = tonumber(temperature)
	
	end
end)

concommand.Add("gdisasters_setbody_oxygen", function(cmd, args, O2)
	for k, v in pairs(player.GetAll()) do
		local Oxygen = O2[1]
		v.gDisasters.Body.Oxygen = tonumber(Oxygen)
	
	end
end)

concommand.Add("gdisasters_dnc_getsundir", function(cmd, args, O2)
	print(gDisasters_GetSunDir())
end)

concommand.Add("gdisasters_dnc_getmoondir", function(cmd, args, O2)
	print(gDisasters_GetMoonDir())
end)

concommand.Add("gdisasters_dnc_getmoondirindegrees", function(cmd, args, O2)
	print(gDisasters_GetMoonAngleInDegs())
end)

concommand.Add("gdisasters_dnc_getsundirindegrees", function(cmd, args, O2)
	print(gDisasters_GetSunAngleInDegs())
end)

concommand.Add("gdisasters_setpressure", function(cmd, args, pressure)
	local press = pressure[1]
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = tonumber(press)
end)

concommand.Add("gdisasters_sethumidity", function(cmd, args, humidity)
	local humi =  humidity[1]
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = tonumber(humi)
end)

concommand.Add("getmap", function()
	print(game.GetMap())
end)
