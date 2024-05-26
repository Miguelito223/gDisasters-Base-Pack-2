--DNC System

gDisasters.DayNightSystem        = {}
gDisasters.DayNightSystem.InternalVars = {}

gDisasters.DayNightSystem.InternalVars.time = {}

gDisasters.DayNightSystem.InternalVars.time.Noon = 12
gDisasters.DayNightSystem.InternalVars.time.MidNight = 0
gDisasters.DayNightSystem.InternalVars.time.Dawn_Start = 4
gDisasters.DayNightSystem.InternalVars.time.Dawn_End = 6.5
gDisasters.DayNightSystem.InternalVars.time.Dusk_Start = 19
gDisasters.DayNightSystem.InternalVars.time.Dusk_End = 20.5

gDisasters.DayNightSystem.InternalVars.Style_Low	= string.byte( 'a' )
gDisasters.DayNightSystem.InternalVars.Style_High = string.byte( 'm' )

gDisasters.DayNightSystem.InternalVars.Night	= 0
gDisasters.DayNightSystem.InternalVars.Dawn = 1
gDisasters.DayNightSystem.InternalVars.Day = 2
gDisasters.DayNightSystem.InternalVars.Dusk = 3

gDisasters.DayNightSystem.InternalVars.SkyPaint = {}
gDisasters.DayNightSystem.InternalVars.SkyPaint.Day =
{		
	TopColor		= Vector( 0.2, 0.49, 1 ),
	BottomColor		= Vector( 0.8, 1, 1 ),
	FadeBias		= 1,
	HDRScale		= 0.26,
	StarScale 		= 1.84,
	StarFade		= 1.5,	-- Do not change!
	StarSpeed 		= 0.02,
	DuskScale		= 1,
	DuskIntensity	= 1,
	DuskColor		= Vector( 1, 0.2, 0 ),
	SunColor		= Vector( 0.83, 0.45, 0.11 ),
	SunSize			= 0.34,
}
gDisasters.DayNightSystem.InternalVars.SkyPaint.Dusk = 
{
	TopColor		= Vector( 0.24, 0.15, 0.08 ),
	BottomColor		= Vector( .4, 0.07, 0 ),
	FadeBias		= 1,
	HDRScale		= 0.36,
	StarScale		= 1.50,
	StarFade		= 5.0,	-- Do not change!
	StarSpeed 		= 0.01,
	DuskScale		= 1,
	DuskIntensity	= 1.94,
	DuskColor		= Vector( 0.69, 0.22, 0.02 ),
	SunColor		= Vector( 0.90, 0.30, 0.00 ),
	SunSize			= 0.44,
}
gDisasters.DayNightSystem.InternalVars.SkyPaint.Dawn = 
{
	TopColor		= Vector( 0.2, 0.5, 1 ),
	BottomColor		= Vector( 0.46, 0.65, 0.49 ),
	FadeBias		= 1,
	HDRScale		= 0.26,
	StarScale 		= 1.84,
	StarFade		= 0.0,	-- Do not change!
	StarSpeed 		= 0.02,
	DuskScale		= 1,
	DuskIntensity	= 1,
	DuskColor		= Vector( 1, 0.2, 0 ),
	SunColor		= Vector( 0.2, 0.1, 0 ),
	SunSize			= 2,
}
gDisasters.DayNightSystem.InternalVars.SkyPaint.Night = 
{
	TopColor		= Vector( 0.00, 0.00, 0.00 ),
	BottomColor		= Vector( 0.05, 0.05, 0.11 ),
	FadeBias		= 0.1,
	HDRScale		= 0.19,
	StarScale		= 1.50,
	StarFade		= 5.0,	-- Do not change!
	StarSpeed 		= 0.01,
	DuskScale		= 0,
	DuskIntensity	= 0,
	DuskColor		= Vector( 1, 0.36, 0 ),
	SunColor		= Vector( 0.83, 0.45, 0.11 ),
	SunSize			= 0.0,
}
gDisasters.DayNightSystem.InternalVars.Fog = {}

gDisasters.DayNightSystem.InternalVars.Fog.Dusk = 
{
	FogStart = 0.0,
	FogEnd = 35000.0,
	FogDensity = 0.3,
	FogColor = Vector( 1.00, 0.63, 0.00 )
}

gDisasters.DayNightSystem.InternalVars.Fog.Day = 
{
	FogStart = 0.0,
	FogEnd = 35000.0,
	FogDensity = 0.9,
	FogColor = Vector( 0.6, 0.7, 0.8 )
}

gDisasters.DayNightSystem.InternalVars.Fog.Dawn = 
{
	FogStart = 0.0,
	FogEnd = 35000.0,
	FogDensity = 0.3,
	FogColor = Vector( 1.00, 0.63, 0.00)
}

gDisasters.DayNightSystem.InternalVars.Fog.Night = 
{
	FogStart = 0.0,
	FogEnd = 35000.0,
	FogDensity = 0.9,
	FogColor = Vector( 0, 0, 0 )
}

gDisasters.DayNightSystem.Time = 6.5
gDisasters.DayNightSystem.OldSkyName = "unknown"
gDisasters.DayNightSystem.LastPeriod = gDisasters.DayNightSystem.InternalVars.Night
gDisasters.DayNightSystem.initEntities = false
gDisasters.DayNightSystem.Paused = false

gDisasters.DayNightSystem.Initialize = function()
	gDisasters.DayNightSystem.OldSkyName = GetConVar("sv_skyname"):GetString();

	if gDisasters_Is3DSkybox() then
		print("this have 3D skybox")
	else
		print("this don't have 3D skybox")
	end

	hook.Add("Think", "gDisasters_dnc_think", gDisasters.DayNightSystem.Think)
end
hook.Add("Initialize", "gDisasters_dnc_initialize", gDisasters.DayNightSystem.Initialize)

gDisasters.DayNightSystem.LightStyle = function(style, force)

	if (CLIENT) then return end

	if ( tostring( gDisasters.DayNightSystem.LastStyle ) == tostring( style ) and (force == nil or force == false) ) then return end

	if ( IsValid( gDisasters.DayNightSystem.LightEnvironment ) ) then

		gDisasters.DayNightSystem.LightEnvironment:Fire( "FadeToPattern", tostring( style ) )

	else
		
		engine.LightStyle( 0, style )
	
		timer.Simple( 0.1, function()
		
			net.Start( "gd_maplight_cl" )
			net.Broadcast()
		
		end )
		
	end

	gDisasters.DayNightSystem.LastStyle = style;

end

gDisasters.DayNightSystem.initEntities_Function = function()

	if (SERVER) then

		gDisasters.DayNightSystem.LightEnvironment = ents.FindByClass( "light_environment" )[1]
		gDisasters.DayNightSystem.EnvSun = ents.FindByClass( "env_sun" )[1]
		gDisasters.DayNightSystem.EnvSkyPaint = ents.FindByClass( "env_skypaint" )[1]
		gDisasters.DayNightSystem.EnvFogController = ents.FindByClass( "env_fog_controller" )[1]
		gDisasters.DayNightSystem.RelayDawn = ents.FindByName( "dawn" )[1]
		gDisasters.DayNightSystem.RelayDusk = ents.FindByName( "dusk" )[1]

		gDisasters.DayNightSystem.Fog = ents.Create("gd_fog")
		gDisasters.DayNightSystem.Fog:Spawn()
		gDisasters.DayNightSystem.Fog:Activate()

		if !IsValid(gDisasters.DayNightSystem.EnvFogController) then
			gDisasters.DayNightSystem.EnvFogController = ents.Create("env_fog_controller")
			gDisasters.DayNightSystem.EnvFogController:Spawn()
			gDisasters.DayNightSystem.EnvFogController:Activate()
		end

		if IsValid(gDisasters.DayNightSystem.EnvSun) then
			gDisasters.DayNightSystem.EnvSun:SetKeyValue( "sun_dir", "1 0 0" )
		else
			gDisasters.DayNightSystem.EnvSun = ents.Create("env_sun")
			gDisasters.DayNightSystem.EnvSun:Spawn()
			gDisasters.DayNightSystem.EnvSun:Activate()
		end

		if IsValid( gDisasters.DayNightSystem.LightEnvironment ) then
			gDisasters.DayNightSystem.LightStyle( "a", true )
		else
			if gDisasters.DayNightSystem.InternalVars.Createlight_environment:GetInt() <= 0 then
				gDisasters.DayNightSystem.InternalVars.Style_Low = string.byte( "b" )
				gDisasters.DayNightSystem.LightStyle( "b", true )
			else
				gDisasters.DayNightSystem.LightEnvironment = ents.Create("light_environment")
				gDisasters.DayNightSystem.LightEnvironment:Spawn()
				gDisasters.DayNightSystem.LightEnvironment:Activate()
			end
		end

		if IsValid( gDisasters.DayNightSystem.EnvSkyPaint )  then
			gDisasters.DayNightSystem.EnvSkyPaint:SetStarTexture( "skybox/starfield" )
		else
			gDisasters.DayNightSystem.EnvSkyPaint =  ents.Create("env_skypaint")
			gDisasters.DayNightSystem.EnvSkyPaint:Spawn()
			gDisasters.DayNightSystem.EnvSkyPaint:Activate()
		end

		gDisasters.DayNightSystem.initEntities = true
	end
	if (CLIENT) then
		gDisasters.DayNightSystem.Fog = g_Fog
	end
end

gDisasters.DayNightSystem.Think = function()
	if gDisasters.DayNightSystem.InternalVars.Enabled:GetInt() < 1 then return end
	if ( !gDisasters.DayNightSystem.initEntities ) then gDisasters.DayNightSystem.initEntities_Function() end

	local timeLen = 3600;
	if (gDisasters.DayNightSystem.Time > gDisasters.DayNightSystem.InternalVars.time.Dusk_Start or gDisasters.DayNightSystem.Time < gDisasters.DayNightSystem.InternalVars.time.Dawn_End) then
		timeLen = gDisasters.DayNightSystem.InternalVars.Length_Night:GetInt();
	else
		timeLen = gDisasters.DayNightSystem.InternalVars.Length_Day:GetInt();
	end

	if ( !gDisasters.DayNightSystem.Paused and gDisasters.DayNightSystem.InternalVars.Paused:GetInt() <= 0 ) then
		if ( gDisasters.DayNightSystem.InternalVars.RealTime:GetInt() <= 0 ) then
			gDisasters.DayNightSystem.Time = gDisasters.DayNightSystem.Time + ( 24 / timeLen ) * FrameTime();
			if ( gDisasters.DayNightSystem.Time > 24 ) then
				gDisasters.DayNightSystem.Time = 0;
			end
		else
			gDisasters.DayNightSystem.Time = gDisasters.DayNightSystem.GetRealTime();
		end
	end

	-- since our dawn/dusk periods last several hours find the mid point of them
	local dawnMidPoint = ( gDisasters.DayNightSystem.InternalVars.time.Dawn_End + gDisasters.DayNightSystem.InternalVars.time.Dawn_Start ) / 2;
	local duskMidPoint = ( gDisasters.DayNightSystem.InternalVars.time.Dusk_End + gDisasters.DayNightSystem.InternalVars.time.Dusk_Start ) / 2;

	-- dawn/dusk/night events
	if ( gDisasters.DayNightSystem.Time >= gDisasters.DayNightSystem.InternalVars.time.Dusk_End and IsValid( gDisasters.DayNightSystem.EnvSun ) ) then
		if ( gDisasters.DayNightSystem.LastPeriod != gDisasters.DayNightSystem.InternalVars.Night ) then
			gDisasters.DayNightSystem.EnvSun:Fire( "TurnOff", "", 0 );
			gDisasters.DayNightSystem.LastPeriod = gDisasters.DayNightSystem.InternalVars.Night;
		end

	elseif ( gDisasters.DayNightSystem.Time >= duskMidPoint ) then
		if ( gDisasters.DayNightSystem.LastPeriod != gDisasters.DayNightSystem.InternalVars.Dusk ) then
			if ( IsValid( gDisasters.DayNightSystem.RelayDusk ) ) then
				gDisasters.DayNightSystem.RelayDusk:Fire( "Trigger", "" );
			end
			if ( IsValid( gDisasters.DayNightSystem.EnvSkyPaint ) ) then
				gDisasters.DayNightSystem.EnvSkyPaint:SetStarTexture( "skybox/starfield" );	
			end
			gDisasters.DayNightSystem.LastPeriod = gDisasters.DayNightSystem.InternalVars.Dusk;
		end

	elseif ( gDisasters.DayNightSystem.Time >= dawnMidPoint ) then
		if ( gDisasters.DayNightSystem.LastPeriod != gDisasters.DayNightSystem.InternalVars.Dawn ) then
			if ( IsValid( gDisasters.DayNightSystem.RelayDawn ) ) then
				gDisasters.DayNightSystem.RelayDawn:Fire( "Trigger", "" );
			end
			if ( IsValid( gDisasters.DayNightSystem.EnvSkyPaint ) ) then
				gDisasters.DayNightSystem.InternalVars.SkyPaint.Day.StarFade = 0;
			end
			gDisasters.DayNightSystem.LastPeriod = gDisasters.DayNightSystem.InternalVars.Dawn;
		end

	elseif ( gDisasters.DayNightSystem.Time >= gDisasters.DayNightSystem.InternalVars.time.Dawn_Start and IsValid( gDisasters.DayNightSystem.EnvSun ) ) then
		if ( gDisasters.DayNightSystem.LastPeriod != gDisasters.DayNightSystem.InternalVars.Day ) then
			gDisasters.DayNightSystem.EnvSun:Fire( "TurnOn", "", 0 );
			gDisasters.DayNightSystem.LastPeriod = gDisasters.DayNightSystem.InternalVars.Day;
		end

	end

	-- light_environment
	local lightfrac = 0;

	if ( gDisasters.DayNightSystem.Time >= dawnMidPoint and gDisasters.DayNightSystem.Time < gDisasters.DayNightSystem.InternalVars.time.Noon ) then
		lightfrac = math.EaseInOut( ( gDisasters.DayNightSystem.Time - dawnMidPoint ) / ( gDisasters.DayNightSystem.InternalVars.time.Noon - dawnMidPoint ), 0, 1 );
	elseif ( gDisasters.DayNightSystem.Time >= gDisasters.DayNightSystem.InternalVars.time.Noon and gDisasters.DayNightSystem.Time < duskMidPoint ) then
		lightfrac = 1 - math.EaseInOut( ( gDisasters.DayNightSystem.Time - gDisasters.DayNightSystem.InternalVars.time.Noon ) / ( duskMidPoint - gDisasters.DayNightSystem.InternalVars.time.Noon ), 1, 0 );
	end

	local style = string.char( math.floor( Lerp( lightfrac, gDisasters.DayNightSystem.InternalVars.Style_Low, gDisasters.DayNightSystem.InternalVars.Style_High ) + 0.5 ) );

	gDisasters.DayNightSystem.LightStyle( style );

	-- env_sun
	if ( IsValid( gDisasters.DayNightSystem.EnvSun ) ) then
		if ( gDisasters.DayNightSystem.Time >= gDisasters.DayNightSystem.InternalVars.time.Dawn_Start and gDisasters.DayNightSystem.Time <= gDisasters.DayNightSystem.InternalVars.time.Dusk_End ) then
			local sunfrac = 1 - ( ( gDisasters.DayNightSystem.Time - gDisasters.DayNightSystem.InternalVars.time.Dawn_Start ) / ( gDisasters.DayNightSystem.InternalVars.time.Dusk_End - gDisasters.DayNightSystem.InternalVars.time.Dawn_Start ) );
			local angle = Angle( 180 * sunfrac, 15, 0 );
			gDisasters_SetSunDir(convert_AngleToVector(-angle))

			gDisasters.DayNightSystem.EnvSun:SetKeyValue( "sun_dir", tostring(gDisasters_GetSunDir()) );
		end
	end

	--gd_fog

	

	if ( IsValid( gDisasters.DayNightSystem.Fog ) ) then
		if (CLIENT) then
			local cur = gDisasters.DayNightSystem.InternalVars.Fog.Night;
			local next = gDisasters.DayNightSystem.InternalVars.Fog.Night;
			local frac = 0;
			local ease = 0.3;

			if ( gDisasters.DayNightSystem.Time >= gDisasters.DayNightSystem.InternalVars.time.Dawn_Start and gDisasters.DayNightSystem.Time < dawnMidPoint ) then
				cur = gDisasters.DayNightSystem.InternalVars.Fog.Night;
				next = gDisasters.DayNightSystem.InternalVars.Fog.Dawn;
				frac = math.EaseInOut( ( gDisasters.DayNightSystem.Time - gDisasters.DayNightSystem.InternalVars.time.Dawn_Start ) / ( dawnMidPoint - gDisasters.DayNightSystem.InternalVars.time.Dawn_Start ), ease, ease );
			elseif ( gDisasters.DayNightSystem.Time >= dawnMidPoint and gDisasters.DayNightSystem.Time < gDisasters.DayNightSystem.InternalVars.time.Dawn_End ) then
				cur = gDisasters.DayNightSystem.InternalVars.Fog.Dawn;
				next = gDisasters.DayNightSystem.InternalVars.Fog.Day;
				frac = math.EaseInOut( ( gDisasters.DayNightSystem.Time - dawnMidPoint ) / ( gDisasters.DayNightSystem.InternalVars.time.Dawn_End - dawnMidPoint ), ease, ease );
			elseif ( gDisasters.DayNightSystem.Time >= gDisasters.DayNightSystem.InternalVars.time.Dusk_Start and gDisasters.DayNightSystem.Time < duskMidPoint ) then
				cur = gDisasters.DayNightSystem.InternalVars.Fog.Day;
				next = gDisasters.DayNightSystem.InternalVars.Fog.Dusk;
				frac = math.EaseInOut( ( gDisasters.DayNightSystem.Time - gDisasters.DayNightSystem.InternalVars.time.Dusk_Start ) / ( duskMidPoint - gDisasters.DayNightSystem.InternalVars.time.Dusk_Start ), ease, ease );
			elseif ( gDisasters.DayNightSystem.Time >= duskMidPoint and gDisasters.DayNightSystem.Time < gDisasters.DayNightSystem.InternalVars.time.Dusk_End ) then
				cur = gDisasters.DayNightSystem.InternalVars.Fog.Dusk;
				next = gDisasters.DayNightSystem.InternalVars.Fog.Night;
				frac = math.EaseInOut( ( gDisasters.DayNightSystem.Time - duskMidPoint ) / ( gDisasters.DayNightSystem.InternalVars.time.Dusk_End - duskMidPoint ), ease, ease );
			elseif ( gDisasters.DayNightSystem.Time >= gDisasters.DayNightSystem.InternalVars.time.Dawn_End and gDisasters.DayNightSystem.Time <= gDisasters.DayNightSystem.InternalVars.time.Dusk_End ) then
				cur = gDisasters.DayNightSystem.InternalVars.Fog.Day;
				next = gDisasters.DayNightSystem.InternalVars.Fog.Day;
			end

			gDisasters.DayNightSystem.Fog:SetFogStart(Lerp( frac, cur.FogStart, next.FogStart ))
			gDisasters.DayNightSystem.Fog:SetFogEnd(Lerp( frac, cur.FogEnd, next.FogEnd ))
			gDisasters.DayNightSystem.Fog:SetFogDensity(Lerp( frac, cur.FogDensity, next.FogDensity ))
			gDisasters.DayNightSystem.Fog:SetFogColor(LerpVector( frac, cur.FogColor, next.FogColor ))
    		
		end	
	end

	-- env_skypaint
	if ( IsValid( gDisasters.DayNightSystem.EnvSkyPaint ) ) then

		if ( IsValid( gDisasters.DayNightSystem.EnvSun ) ) then
			gDisasters.DayNightSystem.EnvSkyPaint:SetSunNormal( gDisasters.DayNightSystem.EnvSun:GetInternalVariable( "m_vDirection" ) );
		end

		if (SERVER) then

			local cur = gDisasters.DayNightSystem.InternalVars.SkyPaint.Night;
			local next = gDisasters.DayNightSystem.InternalVars.SkyPaint.Night;
			local frac = 0;
			local ease = 0.3;

			if ( gDisasters.DayNightSystem.Time >= gDisasters.DayNightSystem.InternalVars.time.Dawn_Start and gDisasters.DayNightSystem.Time < dawnMidPoint ) then
				cur = gDisasters.DayNightSystem.InternalVars.SkyPaint.Night;
				next = gDisasters.DayNightSystem.InternalVars.SkyPaint.Dawn;
				frac = math.EaseInOut( ( gDisasters.DayNightSystem.Time - gDisasters.DayNightSystem.InternalVars.time.Dawn_Start ) / ( dawnMidPoint - gDisasters.DayNightSystem.InternalVars.time.Dawn_Start ), ease, ease );
			elseif ( gDisasters.DayNightSystem.Time >= dawnMidPoint and gDisasters.DayNightSystem.Time < gDisasters.DayNightSystem.InternalVars.time.Dawn_End ) then
				cur = gDisasters.DayNightSystem.InternalVars.SkyPaint.Dawn;
				next = gDisasters.DayNightSystem.InternalVars.SkyPaint.Day;
				frac = math.EaseInOut( ( gDisasters.DayNightSystem.Time - dawnMidPoint ) / ( gDisasters.DayNightSystem.InternalVars.time.Dawn_End - dawnMidPoint ), ease, ease );
			elseif ( gDisasters.DayNightSystem.Time >= gDisasters.DayNightSystem.InternalVars.time.Dusk_Start and gDisasters.DayNightSystem.Time < duskMidPoint ) then
				cur = gDisasters.DayNightSystem.InternalVars.SkyPaint.Day;
				next = gDisasters.DayNightSystem.InternalVars.SkyPaint.Dusk;
				frac = math.EaseInOut( ( gDisasters.DayNightSystem.Time - gDisasters.DayNightSystem.InternalVars.time.Dusk_Start ) / ( duskMidPoint - gDisasters.DayNightSystem.InternalVars.time.Dusk_Start ), ease, ease );
			elseif ( gDisasters.DayNightSystem.Time >= duskMidPoint and gDisasters.DayNightSystem.Time < gDisasters.DayNightSystem.InternalVars.time.Dusk_End ) then
				cur = gDisasters.DayNightSystem.InternalVars.SkyPaint.Dusk;
				next = gDisasters.DayNightSystem.InternalVars.SkyPaint.Night;
				frac = math.EaseInOut( ( gDisasters.DayNightSystem.Time - duskMidPoint ) / ( gDisasters.DayNightSystem.InternalVars.time.Dusk_End - duskMidPoint ), ease, ease );
			elseif ( gDisasters.DayNightSystem.Time >= gDisasters.DayNightSystem.InternalVars.time.Dawn_End and gDisasters.DayNightSystem.Time <= gDisasters.DayNightSystem.InternalVars.time.Dusk_End ) then
				cur = gDisasters.DayNightSystem.InternalVars.SkyPaint.Day;
				next = gDisasters.DayNightSystem.InternalVars.SkyPaint.Day;
			end

			gDisasters.DayNightSystem.EnvSkyPaint:SetTopColor( LerpVector( frac, cur.TopColor, next.TopColor ) );
			gDisasters.DayNightSystem.EnvSkyPaint:SetBottomColor( LerpVector( frac, cur.BottomColor, next.BottomColor ) );
			gDisasters.DayNightSystem.EnvSkyPaint:SetSunColor( LerpVector( frac, cur.SunColor, next.SunColor ) );
			gDisasters.DayNightSystem.EnvSkyPaint:SetDuskColor( LerpVector( frac, cur.DuskColor, next.DuskColor ) );
			gDisasters.DayNightSystem.EnvSkyPaint:SetFadeBias( Lerp( frac, cur.FadeBias, next.FadeBias ) );
			gDisasters.DayNightSystem.EnvSkyPaint:SetHDRScale( Lerp( frac, cur.HDRScale, next.HDRScale ) );
			gDisasters.DayNightSystem.EnvSkyPaint:SetDuskScale( Lerp( frac, cur.DuskScale, next.DuskScale ) );
			gDisasters.DayNightSystem.EnvSkyPaint:SetDuskIntensity( Lerp( frac, cur.DuskIntensity, next.DuskIntensity ) );
			gDisasters.DayNightSystem.EnvSkyPaint:SetSunSize( (Lerp( frac, cur.SunSize, next.SunSize )) );

			gDisasters.DayNightSystem.EnvSkyPaint:SetStarFade( next.StarFade );
			gDisasters.DayNightSystem.EnvSkyPaint:SetStarScale( next.StarScale );
			gDisasters.DayNightSystem.EnvSkyPaint:SetStarSpeed( next.StarSpeed );
		end
	end
end

gDisasters.DayNightSystem.TogglePause = function()
	gDisasters.DayNightSystem.Paused = !gDisasters.DayNightSystem.Paused
end

gDisasters.DayNightSystem.SetTime = function(time)
	gDisasters.DayNightSystem.Time = math.Clamp( time, 0, 24 );

	if ( IsValid( gDisasters.DayNightSystem.EnvSun ) ) then
		gDisasters.DayNightSystem.EnvSun:SetKeyValue( "sun_dir", "1 0 0" );
	end

	if ( IsValid( gDisasters.DayNightSystem.EnvSkyPaint ) ) then
		gDisasters.DayNightSystem.EnvSkyPaint:SetStarTexture( "skybox/starfield" );
		gDisasters.DayNightSystem.InternalVars.SkyPaint.Day.StarFade = 0;
	end
end

gDisasters.DayNightSystem.GetRealTime = function()

	local t = os.date( "*t" );

	return t.hour + (t.min / 60) + (t.sec / 3600);

end

gDisasters.DayNightSystem.GetTime = function()

	return (gDisasters.DayNightSystem.InternalVars.RealTime:GetInt() <= 0 and gDisasters.DayNightSystem.Time or gDisasters.DayNightSystem.GetRealTime());

end

gDisasters.DayNightSystem.CalcView = function(pl, pos, ang, fov, nearZ, farZ)
	LastNearZ = nearZ;
	LastFarZ = farZ;
end

gDisasters.DayNightSystem.RenderScene = function(origin, angles, fov)
	LastSceneOrigin = origin;
	LastSceneAngles = angles;
end

local moonAlpha = 0;
local moonMat = Material( "atmosphere/moon/9" );
moonMat:SetInt( "$additive", 0 );
moonMat:SetInt( "$translucent", 0 );

gDisasters.DayNightSystem.RenderMoon = function()

	if gDisasters.DayNightSystem.InternalVars.Enabled:GetInt() < 1 then return end

	time = gDisasters.DayNightSystem.Time
	night = time < 4 or time > 20.5
	
	if ( night ) then

		local mul;

		if ( time > 20.5 ) then

			mul = 1 - ( time + 4 ) / 8;

		else

			mul = 1 - ( time - 4 ) / 8;

		end

		local angle = Angle( 180 * mul, 15, 0 );
		gDisasters_SetMoonDir(convert_AngleToVector(angle))

        local moonPos = gDisasters_GetMoonDir() * ( LastFarZ * 0.900 );
        local moonNormal = ( vector_origin - moonPos ):GetNormal();

        moonAlpha = Lerp( FrameTime() * 1, moonAlpha, 255 );
	
        local moonSize = gDisasters.DayNightSystem.InternalVars.MoonSize:GetFloat();

        cam.Start3D(vector_origin, LastSceneAngles);
            render.OverrideDepthEnable( true, false );
            render.SetMaterial( moonMat );
            render.DrawQuadEasy( moonPos, moonNormal, moonSize, moonSize, Color( 255, 255, 255, moonAlpha ), -180 );
            render.OverrideDepthEnable( false, false );
        cam.End3D();

	else

		if ( moonAlpha != 0 ) then

			moonAlpha = 0;

		end

	end
end