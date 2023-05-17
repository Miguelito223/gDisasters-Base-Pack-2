SetGlobalFloat("gd_seismic_activity", 0)

--Global_System table

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
					
						["BRadiation"]  = 0.1,

						["Oxygen"]  = 100
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
					
						["BRadiation"]  = 0.1,

						["Oxygen"]  = 100
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
					
						["BRadiation"]  = 0.1,

						["Oxygen"]  = 100
				}
				}

--DNC System

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
	FogEnd = 55000.0,
	FogDensity = 0.1,
	FogColor = Vector( 1.00, 0.63, 0.00 )
}

gDisasters.DayNightSystem.InternalVars.Fog.Day = 
{
	FogStart = 0.0,
	FogEnd = 35000.0,
	FogDensity = 0.0,
	FogColor = Vector( 0.6, 0.7, 0.8 )
}

gDisasters.DayNightSystem.InternalVars.Fog.Dawn = 
{
	FogStart = 0.0,
	FogEnd = 25000.0,
	FogDensity = 0.3,
	FogColor = Vector( 1.00, 0.63, 0.00)
}

gDisasters.DayNightSystem.InternalVars.Fog.Night = 
{
	FogStart = 0.0,
	FogEnd = 45000.0,
	FogDensity = 0.1,
	FogColor = Vector( 0, 0, 0 )
}

gDisasters.DayNightSystem.Time = 6.5
gDisasters.DayNightSystem.OldSkyName = "unknown"
gDisasters.DayNightSystem.LastPeriod = gDisasters.DayNightSystem.InternalVars.Night
gDisasters.DayNightSystem.initEntities = false
gDisasters.DayNightSystem.Paused = false

gDisasters.DayNightSystem.Initialize = function()
	gDisasters.DayNightSystem.OldSkyName = GetConVar("sv_skyname"):GetString();

	hook.Add("Think", "think", gDisasters.DayNightSystem.Think)
end
hook.Add("Initialize", "gDisastersinitialize", gDisasters.DayNightSystem.Initialize)

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

	if (CLIENT) then return end

	gDisasters.DayNightSystem.LightEnvironment = ents.FindByClass( "light_environment" )[1]
	gDisasters.DayNightSystem.EnvSun = ents.FindByClass( "env_sun" )[1]
	gDisasters.DayNightSystem.EnvSkyPaint = ents.FindByClass( "env_skypaint" )[1]
	gDisasters.DayNightSystem.EnvFogController = ents.FindByClass( "env_fog_controller" )[1]
	gDisasters.DayNightSystem.RelayDawn = ents.FindByName( "dawn" )[1]
	gDisasters.DayNightSystem.RelayDusk = ents.FindByName( "dusk" )[1]
	
	gDisasters.DayNightSystem.Fog = ents.Create("gd_fog")
	gDisasters.DayNightSystem.Fog:Spawn()
	gDisasters.DayNightSystem.Fog:Activate()

	if IsValid(gDisasters.DayNightSystem.EnvSun) then
		gDisasters.DayNightSystem.EnvSun:SetKeyValue( "sun_dir", "1 0 0" )
	else
		gDisasters.DayNightSystem.EnvSun = ents.Create("env_sun")
		gDisasters.DayNightSystem.EnvSun:Spawn()
		gDisasters.DayNightSystem.EnvSun:Activate()
	end

	if !IsValid(gDisasters.DayNightSystem.EnvFogController) then
		gDisasters.DayNightSystem.EnvFogController = ents.Create("env_fog_controller")
		gDisasters.DayNightSystem.EnvFogController:Spawn()
		gDisasters.DayNightSystem.EnvFogController:Activate()
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

	if  IsValid( gDisasters.DayNightSystem.EnvSkyPaint )  then
		gDisasters.DayNightSystem.EnvSkyPaint:SetStarTexture( "skybox/starfield" )
	else
		gDisasters.DayNightSystem.EnvSkyPaint =  ents.Create("env_skypaint")
		gDisasters.DayNightSystem.EnvSkyPaint:Spawn()
		gDisasters.DayNightSystem.EnvSkyPaint:Activate()
	end

	gDisasters.DayNightSystem.initEntities = true

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
			SetGlobalAngle("gdSunDir", -angle:Forward())

			gDisasters.DayNightSystem.EnvSun:SetKeyValue( "sun_dir", tostring(gDisasters_GetSunDir()) );
		end
	end

	-- env_skypaint
	if ( IsValid( gDisasters.DayNightSystem.EnvSkyPaint ) ) then

		if ( IsValid( gDisasters.DayNightSystem.EnvSun ) ) then
			gDisasters.DayNightSystem.EnvSkyPaint:SetSunNormal( gDisasters.DayNightSystem.EnvSun:GetInternalVariable( "m_vDirection" ) );
		end

		local cur = gDisasters.DayNightSystem.InternalVars.SkyPaint.Night;
		local next = gDisasters.DayNightSystem.InternalVars.SkyPaint.Night;
		local nextfog = gDisasters.DayNightSystem.InternalVars.Fog.Night
		local curfog = gDisasters.DayNightSystem.InternalVars.Fog.Night
		local frac = 0;
		local ease = 0.3;


		if ( gDisasters.DayNightSystem.Time >= gDisasters.DayNightSystem.InternalVars.time.Dawn_Start and gDisasters.DayNightSystem.Time < dawnMidPoint ) then
			cur = gDisasters.DayNightSystem.InternalVars.SkyPaint.Night;
			next = gDisasters.DayNightSystem.InternalVars.SkyPaint.Dawn;
			curfog = gDisasters.DayNightSystem.InternalVars.Fog.Night;
			nextfog = gDisasters.DayNightSystem.InternalVars.Fog.Dawn;
			frac = math.EaseInOut( ( gDisasters.DayNightSystem.Time - gDisasters.DayNightSystem.InternalVars.time.Dawn_Start ) / ( dawnMidPoint - gDisasters.DayNightSystem.InternalVars.time.Dawn_Start ), ease, ease );
		elseif ( gDisasters.DayNightSystem.Time >= dawnMidPoint and gDisasters.DayNightSystem.Time < gDisasters.DayNightSystem.InternalVars.time.Dawn_End ) then
			cur = gDisasters.DayNightSystem.InternalVars.SkyPaint.Dawn;
			next = gDisasters.DayNightSystem.InternalVars.SkyPaint.Day;
			curfog = gDisasters.DayNightSystem.InternalVars.Fog.Dawn;
			nextfog = gDisasters.DayNightSystem.InternalVars.Fog.Day;
			frac = math.EaseInOut( ( gDisasters.DayNightSystem.Time - dawnMidPoint ) / ( gDisasters.DayNightSystem.InternalVars.time.Dawn_End - dawnMidPoint ), ease, ease );
		elseif ( gDisasters.DayNightSystem.Time >= gDisasters.DayNightSystem.InternalVars.time.Dusk_Start and gDisasters.DayNightSystem.Time < duskMidPoint ) then
			cur = gDisasters.DayNightSystem.InternalVars.SkyPaint.Day;
			next = gDisasters.DayNightSystem.InternalVars.SkyPaint.Dusk;
			curfog = gDisasters.DayNightSystem.InternalVars.Fog.Day;
			nextfog = gDisasters.DayNightSystem.InternalVars.Fog.Dusk;
			frac = math.EaseInOut( ( gDisasters.DayNightSystem.Time - gDisasters.DayNightSystem.InternalVars.time.Dusk_Start ) / ( duskMidPoint - gDisasters.DayNightSystem.InternalVars.time.Dusk_Start ), ease, ease );
		elseif ( gDisasters.DayNightSystem.Time >= duskMidPoint and gDisasters.DayNightSystem.Time < gDisasters.DayNightSystem.InternalVars.time.Dusk_End ) then
			cur = gDisasters.DayNightSystem.InternalVars.SkyPaint.Dusk;
			next = gDisasters.DayNightSystem.InternalVars.SkyPaint.Night;
			curfog = gDisasters.DayNightSystem.InternalVars.Fog.Dusk;
			nextfog = gDisasters.DayNightSystem.InternalVars.Fog.Night;
			frac = math.EaseInOut( ( gDisasters.DayNightSystem.Time - duskMidPoint ) / ( gDisasters.DayNightSystem.InternalVars.time.Dusk_End - duskMidPoint ), ease, ease );
		elseif ( gDisasters.DayNightSystem.Time >= gDisasters.DayNightSystem.InternalVars.time.Dawn_End and gDisasters.DayNightSystem.Time <= gDisasters.DayNightSystem.InternalVars.time.Dusk_End ) then
			cur = gDisasters.DayNightSystem.InternalVars.SkyPaint.Day;
			next = gDisasters.DayNightSystem.InternalVars.SkyPaint.Day;
			curfog = gDisasters.DayNightSystem.InternalVars.Fog.Day;
			nextfog = gDisasters.DayNightSystem.InternalVars.Fog.Day;
		end

		if (CLIENT) then
			gDisasters.DayNightSystem.Fog:SetFogStart(Lerp(frac, curfog.FogStart, nextfog.FogStart))
			gDisasters.DayNightSystem.Fog:SetFogEnd(Lerp(frac, curfog.FogEnd, nextfog.FogEnd))
			gDisasters.DayNightSystem.Fog:SetFogDensity(Lerp(frac, curfog.FogDensity, nextfog.FogDensity))
			gDisasters.DayNightSystem.Fog:SetFogColor(LerpVector(frac, curfog.FogColor, nextfog.FogColor))

		end		
		if (SERVER) then

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
		SetGlobalAngle("gdMoonDir", angle:Forward() )

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

--concommands

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

concommand.Add("gdisasters_setbdadiation", function(cmd, args, BRadiation)
	local BR =  BRadiation[1]
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["BRadiation"] = tonumber(BR)
end)
concommand.Add("gdisasters_setoxygen", function(cmd, args, Oxygen)
	local Ox = Oxygen[1]
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Oxygen"] = tonumber(Ox)
end)

concommand.Add("getmap", function()
	print(game.GetMap())
end)

concommand.Add( "gdisasters_dnc_pause", function( pl, cmd, args )

	if ( !IsValid( pl ) or !pl:IsAdmin() and !IsSuperAdmin() ) then return end

	gDisasters.DayNightSystem.TogglePause()

	if ( IsValid( pl ) ) then

		pl:PrintMessage( HUD_PRINTCONSOLE, "DNC is " .. (gDisasters.DayNightSystem.Paused and "paused" or "no longer paused") );

	else

		print( "DNC is " .. (gDisasters.DayNightSystem.Paused and "paused" or "no longer paused") );

	end

end );

concommand.Add( "gdisasters_dnc_settime", function( pl, cmd, args )

	if ( !IsValid( pl ) or !pl:IsAdmin() and !IsSuperAdmin() ) then return end

	gDisasters.DayNightSystem.SetTime( tonumber( args[1] or "0" ) );

end );

concommand.Add( "gdisasters_dnc_gettime", function( pl, cmd, args )

	local time = gDisasters.DayNightSystem.GetTime();
	local hours = math.floor( time );
	local minutes = ( time - hours ) * 60;

	if ( IsValid( pl ) ) then

		pl:PrintMessage( HUD_PRINTCONSOLE, string.format( "The current time is %s", string.format( "%02i:%02i", hours, minutes ) ) );

	else

		print( string.format( "The current time is %s", string.format( "%02i:%02i", hours, minutes ) ) );

	end

end );

