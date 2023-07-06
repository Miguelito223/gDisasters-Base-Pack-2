hook.Add( "InitPostEntity", "gDisastersInitPostEvo", function()
	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() >= 1 or gDisasters.DayNightSystem.InternalVars.Enabled:GetInt() >= 1 then 

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
		print("removed entitys env_skypaint and light_environment")
	end

end )

hook.Add( "PostInit", "gDisastersInitFix", function()
	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() >= 1 or gDisasters.DayNightSystem.InternalVars.Enabled:GetInt() >= 1 then 

		if #ents.FindByClass("env_skypaint")<1 then
			local ent = ents.Create("env_skypaint")
			ent:SetPos(Vector(0,0,0))
			ent:Spawn()
			print("created env_skypaint")
		end

		RunConsoleCommand( "sv_skyname", "painted" )
		print("Changing sv_skyname to painted")

		if ( game.ConsoleCommand ) then
			game.ConsoleCommand( "sv_skyname painted\n" )
			print("finish Changing sv_skyname to painted")
		end

		print("changed sv_skyname to painted")
		
	end
end)



















































