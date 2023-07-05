function gDisasters_PostSpawnSH()
    local function gDisasters_SetupConvars()
        --S37K map bounds

        CreateConVar( "gdisasters_mapbounds_S37K", "0", {FCVAR_ARCHIVE}, "" )

        --dnc

        gDisasters.DayNightSystem.InternalVars.Enabled = CreateConVar( "gdisasters_dnc_enabled", "0", {FCVAR_ARCHIVE}, "" )
        gDisasters.DayNightSystem.InternalVars.RealTime = CreateConVar( "gdisasters_dnc_realtime", "0", {FCVAR_ARCHIVE}, "" )
        gDisasters.DayNightSystem.InternalVars.Paused = CreateConVar( "gdisasters_dnc_paused", "0", {FCVAR_ARCHIVE}, "" )

        gDisasters.DayNightSystem.InternalVars.Length_Day = CreateConVar( "gDisasters_dnc_length_day", "600", {FCVAR_ARCHIVE}, "" )
        gDisasters.DayNightSystem.InternalVars.Length_Night = CreateConVar( "gDisasters_dnc_length_night", "600", {FCVAR_ARCHIVE}, "" )

        gDisasters.DayNightSystem.InternalVars.MoonSize = CreateConVar( "gdisasters_dnc_moon_size", "3000", {FCVAR_ARCHIVE}, "" )

        gDisasters.DayNightSystem.InternalVars.Createlight_environment = CreateConVar( "gdisasters_dnc_create_light_environment", "1", {FCVAR_ARCHIVE}, "" )

        --tvirus

        CreateConVar("gdisasters_easyuse", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
        CreateConVar("gdisasters_tvirus_zombie_strength", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
        CreateConVar("gdisasters_sound_speed", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
        CreateConVar("gdisasters_fragility", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
        CreateConVar("gdisasters_tvirus_nmrih_zombies", "0", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
    end
    gDisasters_SetupConvars()
end
hook.Add( "InitPostEntity", "gDisasters_PostSpawnSH", gDisasters_PostSpawnSH)