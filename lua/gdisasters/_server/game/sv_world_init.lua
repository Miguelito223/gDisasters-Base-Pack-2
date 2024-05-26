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
		gDisasters:Msg("removed entitys env_skypaint and light_environment")
	
	end

end )

hook.Add( "PostInit", "gDisastersInitFix", function()
	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() >= 1 or gDisasters.DayNightSystem.InternalVars.Enabled:GetInt() >= 1 then 

		if #ents.FindByClass("env_skypaint")<1 then
			local ent = ents.Create("env_skypaint")
			ent:SetPos(Vector(0,0,0))
			ent:Spawn()
			gDisasters:Msg("created env_skypaint")
		end

		RunConsoleCommand( "sv_skyname", "painted" )
		gDisasters:Msg("Changing sv_skyname to painted")

		if ( game.ConsoleCommand ) then
			game.ConsoleCommand( "sv_skyname painted\n" )
			gDisasters:Msg("finish Changing sv_skyname to painted")
		end

		gDisasters:Msg("changed sv_skyname to painted")

		gDisasters:Msg("Setting global var gdsundir")
		local env_sun = ents.FindByClass("env_sun")[1]
		if env_sun then
			local sunDir = env_sun:GetInternalVariable("sun_dir")
			gDisasters_SetSunDir(sunDir)
		end
		gDisasters:Msg("Finish")
	end
end)




















































