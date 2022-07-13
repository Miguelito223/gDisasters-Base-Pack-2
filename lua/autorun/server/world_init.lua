
AddCSLuaFile("autorun/server/world_init.lua") -- REMOVE THIS FILE AND YOU WILL DIE A HORRIBLE DEATH 

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


concommand.Add("smite", function(test, test2, test3)

	local bounds    = getMapSkyBox()
	local min       = bounds[1]
	local max       = bounds[2]
	
	
	
	local startpos  = Vector(  5000,5000 ,  max.z )
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



concommand.Add("freeze", function()

	for k, v in pairs(ents.GetAll()) do
		if v:GetPhysicsObject():IsValid() then v:GetPhysicsObject():EnableMotion(false)  end 
	end
end)


concommand.Add("temp", function(test, test2, test3)
	local speed = test3[1]
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = tonumber(speed)
end)



concommand.Add("wind", function(test, test2, test3)
	local speed = test3[1]
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"] = tonumber(speed)
end)


concommand.Add("body_temp", function(test, test2, test3)
	for k, v in pairs(player.GetAll()) do
	
		v.BodyTemperature = tonumber(test3[1])
	
	end
end)

concommand.Add("pressure", function(test, test2, test3)
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = tonumber(test3[1])
end)

concommand.Add("getmap", function(test, test2, test3)
	print(game.GetMap())
end)




hook.Add( "Initialize", "AtmosInitFix", function()

	if #ents.FindByClass("env_skypaint")<1 then
		local ent = ents.Create("env_skypaint")
		ent:SetPos(Vector(0,0,0))
		ent:Spawn()
	end

	RunConsoleCommand( "sv_skyname", "painted" )

	if ( game.ConsoleCommand ) then

		game.ConsoleCommand( "sv_skyname painted\n" )

	end

end )

hook.Add( "InitPostEntity", "gDisastersInitPostEvo", function()




	local oldCleanUpMap = game.CleanUpMap
	
	game.CleanUpMap = function(dontSendToClients, ExtraFilters)
		dontSendToClients = (dontSendToClients != nil and dontSendToClients or false)

		if ( ExtraFilters != nil ) then
			table.insert(ExtraFilters, "env_skypaint")
			table.insert(ExtraFilters, "light_environment")
		else
			ExtraFilters = { "env_skypaint", "light_environment" }
		end

		oldCleanUpMap(dontSendToClients, ExtraFilters)
	end

end )

























