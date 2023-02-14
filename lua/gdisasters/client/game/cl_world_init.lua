hook.Add( "InitPostEntity", "gDisastersFirstJoinLightmaps", function()

	render.RedownloadAllLightmaps();

end )

