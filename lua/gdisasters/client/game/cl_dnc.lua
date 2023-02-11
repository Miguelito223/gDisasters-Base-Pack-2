hook.Add( "InitPostEntity", "gDisastersFirstJoinLightmaps", function()

    render.RedownloadAllLightmaps()

end)

hook.Add("RenderScene", "gdisasters_dnc_RenderScene", function(origin, angles, fov) 

    gDisasters.DayNightSystem.Start:RenderScene(origin, angles, fov);

end)

hook.Add("CalcView", "gdisasters_dnc_CalcView", function(pl, pos, ang, fov, nearZ, farZ) 

    gDisasters.DayNightSystem.Start:CalcView(pl, pos, ang, fov, nearZ, farZ );

end)

hook.Add("PostDrawSkyBox", "gdisasters_dnc_DrawMoon", function() 

    gDisasters.DayNightSystem.Start:RenderMoon();

end)
