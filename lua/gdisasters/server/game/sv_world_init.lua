hook.Add( "Initialize", "gDisastersInitFix", function()
	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() >= 1 then 

		if #ents.FindByClass("env_skypaint")<1 then
			local ent = ents.Create("env_skypaint")
			ent:SetPos(Vector(0,0,0))
			ent:Spawn()
		end

		RunConsoleCommand( "sv_skyname", "painted" )

		if ( game.ConsoleCommand ) then

			game.ConsoleCommand( "sv_skyname painted\n" )

		end
	end
end )



hook.Add( "InitPostEntity", "gDisastersInitPostEvo", function()
	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() >= 1 then 

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
	end

end )






















































