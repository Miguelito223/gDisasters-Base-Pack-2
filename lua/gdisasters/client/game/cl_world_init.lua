hook.Add( "InitPostEntity", "gDisastersFirstJoinLightmaps", function()

	render.RedownloadAllLightmaps();

end )

hook.Add( "RenderScene", "AtmosRenderScene", function( origin, angles, fov )

	LastSceneOrigin = origin;
	LastSceneAngles = angles;

end );

hook.Add( "CalcView", "AtmosCalcView", function( pl, pos, ang, fov, nearZ, farZ )

	LastNearZ = nearZ;
	LastFarZ = farZ;

end );

gDisasters.DayNightSystem.RenderMoon = function()
	local moonAlpha = 0;
	local moonMat = Material( "atmosphere/moon/9" );
	moonMat:SetInt( "$additive", 0 );
	moonMat:SetInt( "$translucent", 0 );

	time = gDisasters.DayNightSystem.Time
	night = time < 4 or time > 20.5
	
	
	if ( night ) then

		local mul;

		if ( time > 20 ) then

			mul = 1 - ( time + 4 ) / 8;

		else

			mul = 1 - ( time - 4 ) / 8;

		end

		local pos = gDisasters_GetMoonDir() * ( LastFarZ * 0.900 );
		local normal = ( vector_origin - pos ):GetNormal();

		moonAlpha = Lerp( FrameTime() * 1, moonAlpha, 255 );

		local moonSize = GetConVar("gdisasters_dnc_Moon_Size"):GetFloat()

		cam.Start3D( vector_origin, LastSceneAngles );
			render.OverrideDepthEnable( true, false );
			render.SetMaterial( moonMat );
			render.DrawQuadEasy( pos, normal, moonSize, moonSize, Color( 255, 255, 255, moonAlpha ), -180 );
			render.OverrideDepthEnable( false, false );
		cam.End3D();

	else

		if ( moonAlpha != 0 ) then

			moonAlpha = 0;

		end

	end
end


hook.Add( "PostDrawSkyBox", "AtmosPostDrawSkyBox", function()

	gDisasters.DayNightSystem.RenderMoon()

end );