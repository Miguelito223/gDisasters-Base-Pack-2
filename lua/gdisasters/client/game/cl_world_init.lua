hook.Add( "InitPostEntity", "gDisastersFirstJoinLightmaps", function()

	render.RedownloadAllLightmaps();

end )

hook.Add( "CalcView", "gdisastersCalcView", function( pl, pos, ang, fov, nearZ, farZ )
	
	gDisasters.DayNightSystem.CalcView(pl, pos, ang, fov, nearZ, farZ)
	
end );

hook.Add( "RenderScene", "gDisastersRenderScene", function( origin, angles, fov )

	gDisasters.DayNightSystem.RenderScene(origin, angles, fov)

end );

hook.Add( "PostDrawSkyBox", "gDisastersPostDrawSkyBox", function()

	gDisasters.DayNightSystem.RenderMoon()

end)