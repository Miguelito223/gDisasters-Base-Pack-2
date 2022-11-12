if (SERVER) then

    gdisasters_dnc_enabled = CreateConVar( "gdisasters_dnc_enabled", "1", bit.bor( FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED, FCVAR_NOTIFY ), "Day & Night enabled." );
    gdisasters_dnc_paused = CreateConVar( "gdisasters_dnc_paused", "0", bit.bor( FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED, FCVAR_NOTIFY ), "Day & Night time progression enabled." );
    gdisasters_dnc_realtime = CreateConVar( "gdisasters_dnc_realtime", "0", bit.bor( FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED, FCVAR_NOTIFY ), "Whether or not Day & Night progresses based on the servers time zone." );
    gdisasters_dnc_logging = CreateConVar( "gdisasters_dnc_log", "0", bit.bor( FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED, FCVAR_NOTIFY ), "Turn Day & Night logging to console on or off." );

    gdisasters_dnc_length_day = CreateConVar( "gdisasters_dnc_length_day", "3600", bit.bor( FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ), "The duration modifier of daytime in seconds." );
    gdisasters_dnc_length_night = CreateConVar( "gdisasters_dnc_length_night", "3600", bit.bor( FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ), "The duration modifier of nighttime in seconds." );

    gdisasters_dnc_version = 2.0;
    gdisasters_dnc_dev = false;

    gdisasters_dnc_HeightMin = 300;

    function gdisasters_dnc_log( ... )

        if ( gdisasters_dnc_logging:GetInt() < 1 ) then return end

        print( "[day and night] " .. string.format( ... ) .. "\n" );

    end

    function gdisasters_dnc_Outside( pos )

        if ( pos != nil ) then

            local trace = { };
            trace.start = pos;
            trace.endpos = trace.start + Vector( 0, 0, 32768 );
            trace.mask = MASK_BLOCKLOS;

            local tr = util.TraceLine( trace );

            gdisasters_dnc_HeightMin = ( tr.HitPos - trace.start ):Length();

            if ( tr.StartSolid ) then return false end
            if ( tr.HitSky ) then return true end

        end

        return false;

    end

    function gdisasters_dnc_outside( pos )

        return gdisasters_dnc_Outside( pos );

    end

    -- usergroup support
    local meta = FindMetaTable( "Player" )

    function meta:gdisasters_dncAdmin()

        return self:IsSuperAdmin() or self:IsAdmin();

    end

    local TIME_NOON	= 12;		-- 12:00pm
    local TIME_MIDNIGHT	= 0;		-- 12:00am
    local TIME_DAWN_START	= 4;		-- 4:00am
    local TIME_DAWN_END	= 6.5;		-- 6:30am
    local TIME_DUSK_START	= 19;		-- 7:00pm;
    local TIME_DUSK_END	= 20.5;		-- 8:30pm;

    local STYLE_LOW	= string.byte( 'a' );		-- style for night time
    local STYLE_HIGH = string.byte( 'm' );		-- style for day time

    local NIGHT	= 0;
    local DAWN = 1;
    local DAY = 2;
    local DUSK = 3;

    hook.Add( "Initialize", "gdisasters_dncInitFix", function()

        if ( gdisasters_dnc_enabled:GetInt() <= 0 ) then return end

        RunConsoleCommand( "sv_skyname", "painted" );

        if ( game.ConsoleCommand ) then

            game.ConsoleCommand( "sv_skyname painted\n" );

        end

    end );

    hook.Add( "InitPostEntity", "gdisasters_dncInitPostEvo", function()

        -- HACK: fixes the darkened sky effect on evocity
        local map = string.lower( game.GetMap() );

        if ( string.find( map, "evocity" ) != nil ) then

            for _, brush in pairs( ents.FindByName( "gdisasters_dnc_brush" ) ) do

                gdisasters_dnc_log( "removing gdisasters_dnc_brush " .. tostring( brush ) );

                brush:Remove();

            end

        end

        -- HACK: fixes cleanup removing env_skypaint, light_environment
        local oldCleanUpMap = game.CleanUpMap;

        game.CleanUpMap = function(dontSendToClients, ExtraFilters)
            dontSendToClients = (dontSendToClients != nil and dontSendToClients or false);

            if ( ExtraFilters != nil ) then
                table.insert(ExtraFilters, "env_skypaint");
                table.insert(ExtraFilters, "light_environment");
            else
                ExtraFilters = { "env_skypaint", "light_environment" };
            end

            oldCleanUpMap(dontSendToClients, ExtraFilters);
        end

    end );

    local SKYPAINT =
    {
        [DAWN] =
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
        },
        [DAY] =
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
        },
        [DUSK] =
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
        },
        [NIGHT] =
        {
            TopColor		= Vector( 0.00, 0.00, 0.00 ),
            BottomColor		= Vector( 0.00, 0.00, 0.0 ),
            FadeBias		= 0.1,
            HDRScale		= 0.19,
            StarScale		= 1.50,
            StarFade		= 5.0,	-- Do not change!
            StarSpeed 		= 0.01,
            DuskScale		= 0,
            DuskIntensity	= 0,
            DuskColor		= Vector( 0, 0, 0 ),
            SunColor		= Vector( 0.83, 0.45, 0.11 ),
            SunSize			= 0.0,
        }

    };

    local gdisasters_dnc =
    {
        m_InitEntities = false,
        m_OldSkyName = "unknown",
        m_Time = 6.5,
        m_LastPeriod = NIGHT,
        m_LastStyle = '.',
        m_Cloudy = false,
        m_Paused = false,

        -- to easily hook functions within our own object instance
        Hook = function( this, name )

            local func = this[name];
            local function Wrapper( ... )
                func( this, ... );
            end

            hook.Add( name, string.format( "gdisasters_dnc.%s", tostring( this ), name ), Wrapper );

        end,

        LightStyle = function( self, style, force )

            if ( tostring( self.m_LastStyle ) == tostring( style ) and (force == nil or force == false) ) then return end

            --gdisasters_dnc_log( "LightStyle set to " .. tostring(style) .. " " .. tostring(self.m_LastStyle) .. " " .. tostring(force) );

            if ( IsValid( self.m_LightEnvironment ) ) then

                self.m_LightEnvironment:Fire( "FadeToPattern", tostring( style ) );

            else

                engine.LightStyle( 0, style );

                timer.Simple( 0.1, function()

                    net.Start( "gdisasters_dnc_lightmaps" );
                    net.Broadcast();

                end );

            end

            self.m_LastStyle = style;

        end,

        Initialize = function( self )

            self.m_OldSkyName = GetConVar("sv_skyname"):GetString();

            self:Hook( "Think" );

            gdisasters_dnc_log( "Day & Night version %s initializing.", tostring( gdisasters_dnc_version ) );

        end,

        InitEntities = function( self )

            self.m_LightEnvironment = ents.FindByClass( "light_environment" )[1];
            self.m_EnvSun = ents.FindByClass( "env_sun" )[1];
            self.m_EnvSkyPaint = ents.FindByClass( "env_skypaint" )[1];
            self.m_RelayDawn = ents.FindByName( "dawn" )[1];
            self.m_RelayDusk = ents.FindByName( "dusk" )[1];
            self.m_RelayCloudy = ents.FindByName( "cloudy" )[1];

            -- put the sun on the horizon initially
            if ( IsValid( self.m_EnvSun ) ) then
                self.m_EnvSun:SetKeyValue( "sun_dir", "1 0 0" );
            end

            -- log found entities
            -- HACK: Fixes prop lighting since the first pattern change fails to update it.
            if ( IsValid( self.m_LightEnvironment ) ) then
                gdisasters_dnc_log( "Found light_environment" );

                self:LightStyle( "a", true );
            else
                gdisasters_dnc_log( "No light_environment, using engine.LightStyle instead." );

                -- a is too dark for use with engine.LightStyle, bugs out
                STYLE_LOW = string.byte( "b" );
                self:LightStyle( "b", true );
            end

            if ( IsValid( self.m_EnvSun ) ) then
                gdisasters_dnc_log( "Found env_sun" );
            end

            if ( IsValid( self.m_EnvSkyPaint ) ) then

                gdisasters_dnc_log( "Found env_skypaint" );

            else

                local skyPaint = ents.Create( "env_skypaint" );
                skyPaint:Spawn();
                skyPaint:Activate();

                self.m_EnvSkyPaint = skyPaint;

                gdisasters_dnc_log( "Created env_skypaint" );

            end

            self.m_EnvSkyPaint:SetStarTexture( "skybox/starfield" );

            self.m_InitEntities = true;

        end,

        Think = function( self )

            if ( gdisasters_dnc_enabled:GetInt() < 1 ) then return end
            if ( !self.m_InitEntities ) then self:InitEntities(); end

            local timeLen = 3600;
            if (self.m_Time > TIME_DUSK_START or self.m_Time < TIME_DAWN_END) then
                timeLen = gdisasters_dnc_length_night:GetInt();
            else
                timeLen = gdisasters_dnc_length_day:GetInt();
            end

            if ( !self.m_Paused and gdisasters_dnc_paused:GetInt() <= 0 ) then
                if ( gdisasters_dnc_realtime:GetInt() <= 0 ) then
                    self.m_Time = self.m_Time + ( 24 / timeLen ) * FrameTime();
                    if ( self.m_Time > 24 ) then
                        self.m_Time = 0;
                    end
                else
                    self.m_Time = self:GetRealTime();
                end
            end

            -- since our dawn/dusk periods last several hours find the mid point of them
            local dawnMidPoint = ( TIME_DAWN_END + TIME_DAWN_START ) / 2;
            local duskMidPoint = ( TIME_DUSK_END + TIME_DUSK_START ) / 2;

            -- dawn/dusk/night events
            if ( self.m_Time >= TIME_DUSK_END and IsValid( self.m_EnvSun ) ) then
                if ( self.m_LastPeriod != NIGHT ) then
                    self.m_EnvSun:Fire( "TurnOff", "", 0 );

                    self.m_LastPeriod = NIGHT;
                end

            elseif ( self.m_Time >= duskMidPoint ) then
                if ( self.m_LastPeriod != DUSK ) then
                    if ( IsValid( self.m_RelayDusk ) ) then
                        self.m_RelayDusk:Fire( "Trigger", "" );
                    end

                    -- disabled because the clouds at night look pretty awful..
                    --self.m_Cloudy = math.random() > 0.5;
                    self.m_Cloudy = false;

                    -- at dawn select if we should display clouds for night or not (50% chance)
                    if ( IsValid( self.m_EnvSkyPaint ) ) then
                        if ( self.m_Cloudy ) then
                            self.m_EnvSkyPaint:SetStarTexture( "skybox/clouds" );
                        else
                            self.m_EnvSkyPaint:SetStarTexture( "skybox/starfield" );
                        end
                    end

                    self.m_LastPeriod = DUSK;
                end

            elseif ( self.m_Time >= dawnMidPoint ) then
                if ( self.m_LastPeriod != DAWN ) then
                    if ( IsValid( self.m_RelayDawn ) ) then
                        self.m_RelayDawn:Fire( "Trigger", "" );
                    end

                    -- disabled because clouds during transitions looks pretty awful, too
                    --self.m_Cloudy = math.random() > 0.5;
                    self.m_Cloudy = false;

                    -- at dawn select if we should display clouds for day or not (50% chance)
                    if ( IsValid( self.m_EnvSkyPaint ) ) then
                        if ( self.m_Cloudy ) then
                            self.m_EnvSkyPaint:SetStarTexture( "skybox/clouds" );
                            SKYPAINT[DAY].StarFade = 1.5;
                        else
                            SKYPAINT[DAY].StarFade = 0;
                        end
                    end

                    self.m_LastPeriod = DAWN;
                end

            elseif ( self.m_Time >= TIME_DAWN_START and IsValid( self.m_EnvSun ) ) then
                if ( self.m_LastPeriod != DAY ) then

                    self.m_LastPeriod = DAY;
                end

            end

            -- light_environment
            local lightfrac = 0;

            if ( self.m_Time >= dawnMidPoint and self.m_Time < TIME_NOON ) then
                lightfrac = math.EaseInOut( ( self.m_Time - dawnMidPoint ) / ( TIME_NOON - dawnMidPoint ), 0, 1 );
            elseif ( self.m_Time >= TIME_NOON and self.m_Time < duskMidPoint ) then
                lightfrac = 1 - math.EaseInOut( ( self.m_Time - TIME_NOON ) / ( duskMidPoint - TIME_NOON ), 1, 0 );
            end

            local style = string.char( math.floor( Lerp( lightfrac, STYLE_LOW, STYLE_HIGH ) + 0.5 ) );

            self:LightStyle( style );

            -- env_sun
            if ( IsValid( self.m_EnvSun ) ) then
                if ( self.m_Time >= TIME_DAWN_START and self.m_Time <= TIME_DUSK_END ) then
                    local sunfrac = 1 - ( ( self.m_Time - TIME_DAWN_START ) / ( TIME_DUSK_END - TIME_DAWN_START ) );
                    local angle = Angle( -180 * sunfrac, 15, 0 );

                    self.m_EnvSun:SetKeyValue( "sun_dir", tostring( angle:Forward() ) );
                end
            end

            -- env_skypaint
            if ( IsValid( self.m_EnvSkyPaint ) ) then

                if ( IsValid( self.m_EnvSun ) ) then
                    self.m_EnvSkyPaint:SetSunNormal( self.m_EnvSun:GetInternalVariable( "m_vDirection" ) );
                end

                local cur = NIGHT;
                local next = NIGHT;
                local frac = 0;
                local ease = 0.3;

                if ( self.m_Time >= TIME_DAWN_START and self.m_Time < dawnMidPoint ) then
                    cur = NIGHT;
                    next = DAWN;
                    frac = math.EaseInOut( ( self.m_Time - TIME_DAWN_START ) / ( dawnMidPoint - TIME_DAWN_START ), ease, ease );
                elseif ( self.m_Time >= dawnMidPoint and self.m_Time < TIME_DAWN_END ) then
                    cur = DAWN;
                    next = DAY;
                    frac = math.EaseInOut( ( self.m_Time - dawnMidPoint ) / ( TIME_DAWN_END - dawnMidPoint ), ease, ease );
                elseif ( self.m_Time >= TIME_DUSK_START and self.m_Time < duskMidPoint ) then
                    cur = DAY;
                    next = DUSK;
                    frac = math.EaseInOut( ( self.m_Time - TIME_DUSK_START ) / ( duskMidPoint - TIME_DUSK_START ), ease, ease );
                elseif ( self.m_Time >= duskMidPoint and self.m_Time < TIME_DUSK_END ) then
                    cur = DUSK;
                    next = NIGHT;
                    frac = math.EaseInOut( ( self.m_Time - duskMidPoint ) / ( TIME_DUSK_END - duskMidPoint ), ease, ease );
                elseif ( self.m_Time >= TIME_DAWN_END and self.m_Time <= TIME_DUSK_END ) then
                    cur = DAY;
                    next = DAY;
                end

                self.m_EnvSkyPaint:SetTopColor( LerpVector( frac, SKYPAINT[cur].TopColor, SKYPAINT[next].TopColor ) );
                self.m_EnvSkyPaint:SetBottomColor( LerpVector( frac, SKYPAINT[cur].BottomColor, SKYPAINT[next].BottomColor ) );
                self.m_EnvSkyPaint:SetSunColor( LerpVector( frac, SKYPAINT[cur].SunColor, SKYPAINT[next].SunColor ) );
                self.m_EnvSkyPaint:SetDuskColor( LerpVector( frac, SKYPAINT[cur].DuskColor, SKYPAINT[next].DuskColor ) );
                self.m_EnvSkyPaint:SetFadeBias( Lerp( frac, SKYPAINT[cur].FadeBias, SKYPAINT[next].FadeBias ) );
                self.m_EnvSkyPaint:SetHDRScale( Lerp( frac, SKYPAINT[cur].HDRScale, SKYPAINT[next].HDRScale ) );
                self.m_EnvSkyPaint:SetDuskScale( Lerp( frac, SKYPAINT[cur].DuskScale, SKYPAINT[next].DuskScale ) );
                self.m_EnvSkyPaint:SetDuskIntensity( Lerp( frac, SKYPAINT[cur].DuskIntensity, SKYPAINT[next].DuskIntensity ) );
                self.m_EnvSkyPaint:SetSunSize( (Lerp( frac, SKYPAINT[cur].SunSize, SKYPAINT[next].SunSize )) );

                self.m_EnvSkyPaint:SetStarFade( SKYPAINT[next].StarFade );
                self.m_EnvSkyPaint:SetStarScale( SKYPAINT[next].StarScale );
                self.m_EnvSkyPaint:SetStarSpeed( SKYPAINT[next].StarSpeed );

            end

        end,

        TogglePause = function( self )

            self.m_Paused = !self.m_Paused;

        end,

        SetTime = function( self, time )

            self.m_Time = math.Clamp( time, 0, 24 );

            -- FIXME: we're bypassing the sun code
            if ( IsValid( self.m_EnvSun ) ) then
                self.m_EnvSun:SetKeyValue( "sun_dir", "1 0 0" );
            end

            -- FIXME: we're bypassing the dusk/dawn events
            if ( IsValid( self.m_EnvSkyPaint ) ) then
                self.m_EnvSkyPaint:SetStarTexture( "skybox/starfield" );
                SKYPAINT[DAY].StarFade = 0;
            end

        end,

        GetRealTime = function( self )

            local t = os.date( "*t" );

            return t.hour + (t.min / 60) + (t.sec / 3600);

        end,

        GetTime = function( self )

            return (gdisasters_dnc_realtime:GetInt() <= 0 and self.m_Time or self:GetRealTime());

        end,
    };

    -- global handle for debugging
    gdisasters_dncGlobal = gdisasters_dnc;

    hook.Add( "Initialize", "gdisasters_dncInit", function()

        gdisasters_dnc:Initialize();

    end );

    concommand.Add( "gdisasters_dnc_pause", function( pl, cmd, args )

        if ( !IsValid( pl ) or !pl:gdisasters_dncAdmin() ) then return end

        gdisasters_dnc:TogglePause();

        if ( IsValid( pl ) ) then

            pl:PrintMessage( HUD_PRINTCONSOLE, "DNC is " .. (gdisasters_dnc.m_Paused and "paused" or "no longer paused") );

        else

            print( "DNC is " .. (gdisasters_dnc.m_Paused and "paused" or "no longer paused") );

        end

    end );

    concommand.Add( "gdisasters_dnc_settime", function( pl, cmd, args )

        if ( !IsValid( pl ) or !pl:gdisasters_dncAdmin() ) then return end

        gdisasters_dnc:SetTime( tonumber( args[1] or "0" ) );

    end );

    concommand.Add( "gdisasters_dnc_time", function( pl, cmd, args )

        local time = gdisasters_dnc:GetTime();
        local hours = math.floor( time );
        local minutes = ( time - hours ) * 60;

        if ( IsValid( pl ) ) then

            pl:PrintMessage( HUD_PRINTCONSOLE, string.format( "The current time is %s", string.format( "%02i:%02i", hours, minutes ) ) );

        else

            print( string.format( "The current time is %s", string.format( "%02i:%02i", hours, minutes ) ) );

        end

    end );

    function gdisasters_dncMessage( pl, ... )

        net.Start( "gdisasters_dnc_message" );
            net.WriteTable( { ... } );
        net.Send( pl );

    end

    function gdisasters_dncMessageAll( ... )

        net.Start( "gdisasters_dnc_message" );
            net.WriteTable( { ... } );
        net.Broadcast();

    end

    -- Net
    util.AddNetworkString( "gdisasters_dnc_settings" );
    util.AddNetworkString( "gdisasters_dnc_lightmaps" );
    util.AddNetworkString( "gdisasters_dnc_message" );

    -- Hacky workaround to make it possible for admins to change server cvars on dedicated servers
    net.Receive( "gdisasters_dnc_settings", function( len, pl )

        if ( !IsValid( pl ) or !pl:gdisasters_dncAdmin() ) then return end

        local function safeVal( v )

            -- no lua injection plz
            v = tonumber( v );
            v = tostring( v );
            v = string.Replace( v, ":", "" );
            v = string.Replace( v, ";", "" );
            v = string.Replace( v, "'", "" );
            v = string.Replace( v, '"', "" );
            v = string.Replace( v, '(', "" );
            v = string.Replace( v, ')', "" );

            return v;

        end

        local tbl = net.ReadTable();

        local enabled = safeVal( tbl.enabled );
        local paused = safeVal( tbl.paused );
        local realtime = safeVal( tbl.realtime );
        local dnclength_day = safeVal( tbl.dnclength_day );
        local dnclength_night = safeVal( tbl.dnclength_night );

        game.ConsoleCommand( "gdisasters_dnc_enabled " .. enabled .. "\n" );
        game.ConsoleCommand( "gdisasters_dnc_paused " .. paused .. "\n" );
        game.ConsoleCommand( "gdisasters_dnc_realtime " .. realtime .. "\n" );
        game.ConsoleCommand( "gdisasters_dnc_length_day " .. dnclength_day .. "\n" );
        game.ConsoleCommand( "gdisasters_dnc_length_night " .. dnclength_night .. "\n" );

    end );

    concommand.Add( "gdisasters_dnc_reset", function( pl, cmd, args )

        if ( IsValid( pl ) and !pl:gdisasters_dncAdmin() ) then return end

        game.ConsoleCommand( "gdisasters_dnc_enabled 1\n" );
        game.ConsoleCommand( "gdisasters_dnc_paused 0\n" );
        game.ConsoleCommand( "gdisasters_dnc_realtime 0\n" );
        game.ConsoleCommand( "gdisasters_dnc_length_day 3600\n" );
        game.ConsoleCommand( "gdisasters_dnc_length_night 3600\n" );

        if ( IsValid( pl ) ) then

            pl:PrintMessage( HUD_PRINTCONSOLE, "Day & Night server settings reset." );

        else

            print( "Day & Night server settings reset." );

        end

    end );

    -- adds support for saving and restoring day & night values
    saverestore.AddSaveHook( "gdisasters_dncSave", function( save )
        local gdisasters_dncData = {
            gdisasters_dnc_time = gdisasters_dnc.m_Time
        }

        saverestore.WriteTable(gdisasters_dncData, save);

        print("Day & Night save hook called!\n");
    end);

    saverestore.AddRestoreHook( "gdisasters_dncRestore", function( save )
        local tbl = saverestore.ReadTable( save );

        if (tbl.gdisasters_dnc_time != nil) then
            gdisasters_dnc:SetTime(tbl.gdisasters_dnc_time);
        end

        print("Day & Night saverestore hook called!\n");
    end);

end

if (CLIENT) then
    -- lightmap stuff
    net.Receive( "gdisasters_dnc_lightmaps", function( len )

    	render.RedownloadAllLightmaps();

    end );

    -- precache
    hook.Add( "InitPostEntity", "gdisasters_dncFirstJoinLightmaps", function()

    	render.RedownloadAllLightmaps();

    end );

    net.Receive( "gdisasters_dnc_message", function( len )

    	local tab = net.ReadTable();

    	if ( #tab > 0 ) then

    		chat.AddText( unpack( tab ) );

    	end

    end );

    local function UpdateValues( CPanel )

    	if ( CPanel == nil ) then return end

    	if ( CPanel.enabled ) then

    		CPanel.enabled:SetValue( cvars.Number( "gdisasters_dnc_enabled" ) );

    	end

    	if ( CPanel.paused ) then

    		CPanel.paused:SetValue( cvars.Number( "gdisasters_dnc_paused" ) );

    	end

    	if ( CPanel.realtime ) then

    		CPanel.realtime:SetValue( cvars.Number( "gdisasters_dnc_realtime" ) );

    	end

    	if ( CPanel.length_day ) then

    		CPanel.length_day:SetValue( cvars.Number( "gdisasters_dnc_length_day" ) );

    	end

    	if ( CPanel.length_night ) then

    		CPanel.length_night:SetValue( cvars.Number( "gdisasters_dnc_length_night" ) );

    	end

    end
end