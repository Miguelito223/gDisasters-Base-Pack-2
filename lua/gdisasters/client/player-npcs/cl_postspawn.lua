
function gDisasters_PostSpawnCL()
	
	LocalPlayer().gDisasters = {}
	
	local function gDisasters_SetupHUDMISC()
		LocalPlayer().gDisasters.HUD = {}
		LocalPlayer().gDisasters.HUD.NextWarningSoundTime = CurTime()
		LocalPlayer().gDisasters.HUD.NextHeartSoundTime   = CurTime()
		LocalPlayer().gDisasters.HUD.NextVomitTime        = CurTime()
		LocalPlayer().gDisasters.HUD.NextVomitBloodTime   = CurTime()
		LocalPlayer().gDisasters.HUD.VomitIntensity       = 0
		LocalPlayer().gDisasters.HUD.BloodVomitIntensity  = 0
		LocalPlayer().gDisasters.HUD.NextSneezeTime       = CurTime()
		LocalPlayer().gDisasters.HUD.NextSneezeBigTime  = CurTime()
		LocalPlayer().gDisasters.HUD.SneezeIntensity       = 0
		LocalPlayer().gDisasters.HUD.SneezeBigIntensity  = 0
	end
	
	local function gDisasters_SetupHUDConvars()
	
		--hud
		CreateConVar( "gdisasters_hud_enabled", 1, {FCVAR_ARCHIVE}	, "" )
		CreateConVar( "gdisasters_hud_type", 1, {FCVAR_ARCHIVE}	, "" )
		CreateConVar( "gdisasters_hud_windtype", "km/h", {FCVAR_ARCHIVE}	, "" )
		CreateConVar( "gdisasters_hud_temptype", "c", {FCVAR_ARCHIVE}	, "" )

		--graphics
		CreateConVar( "gdisasters_graphics_fog_quality", 4, {FCVAR_ARCHIVE}	, "" )
		CreateConVar( "gdisasters_graphics_water_quality", 2, {FCVAR_ARCHIVE}	, "" )
		CreateConVar( "gdisasters_graphics_dr_resolution", "48x48", {FCVAR_ARCHIVE}	, "")
		CreateConVar( "gdisasters_graphics_dr_monochromatic", "false", {FCVAR_ARCHIVE}	, "")
		CreateConVar( "gdisasters_graphics_dr_maxrenderdistance", 500, {FCVAR_ARCHIVE}	, "")
		CreateConVar( "gdisasters_graphics_dr_refreshrate", 2, {FCVAR_ARCHIVE}	, "")
		CreateConVar( "gdisasters_graphics_dr_updaterate", 2, {FCVAR_ARCHIVE}	, "")
		CreateConVar( "gdisasters_graphics_draw_ceiling_effects", 1, {FCVAR_ARCHIVE}	, "")
		CreateConVar( "gdisasters_graphics_enable_ground_particles", 1, {FCVAR_ARCHIVE}, "")
		CreateConVar( "gdisasters_graphics_enable_weather_particles", 1, {FCVAR_ARCHIVE}, "")
		CreateConVar( "gdisasters_graphics_enable_screen_particles", 1, {FCVAR_ARCHIVE}, "")
		CreateConVar( "gdisasters_graphics_enable_manual_number_of_screen_particles", 1, {FCVAR_ARCHIVE}, "")
		CreateConVar( "gdisasters_graphics_number_of_screen_particles", 1, {FCVAR_ARCHIVE}, "")
		CreateConVar( "gdisasters_graphics_shakescreen_enable", 1,{FCVAR_ARCHIVE}, "")
		CreateConVar( "gdisasters_graphics_experimental_overdraw", 1, {FCVAR_ARCHIVE}, "sexy " )

		--sounds
		CreateConVar( "gdisasters_volume_hud_heartbeat", 0.1, {FCVAR_ARCHIVE}	, "" )
		CreateConVar( "gdisasters_volume_hud_warning", 0.1, {FCVAR_ARCHIVE}	, "" )
		CreateConVar( "gdisasters_volume_soundwave", 1, {FCVAR_ARCHIVE}, " " )
		CreateConVar( "gdisasters_volume_Light_Wind", 1, {FCVAR_ARCHIVE}, " " )
		CreateConVar( "gdisasters_volume_Moderate_Wind", 1, {FCVAR_ARCHIVE}, " " )
		CreateConVar( "gdisasters_volume_Heavy_Wind", 1, {FCVAR_ARCHIVE}, " " )
	
	end

	local function gDisasters_SetupFOGVars()
		LocalPlayer().gDisasters.Fog = {}
		LocalPlayer().gDisasters.Fog.Data   = {}
		LocalPlayer().gDisasters.Fog.Parent = false
		LocalPlayer().gDisasters.Fog.OQ     = false
		LocalPlayer().gDisasters.Fog.Setup  = false
		LocalPlayer().gDisasters.Fog.NextEmitTime = CurTime()
		local data = {}
			data.Color = Color(0,0,0)
			data.DensityCurrent = 0
			data.DensityMax     = 0
			data.DensityMin     = 0
			data.EndMax         = 0
			data.EndMin         = 0
			data.EndMinCurrent  = 0
			data.EndMaxCurrent  = 0       		
		LocalPlayer().gDisasters.Fog.Data = data
		
	
	end
	
	local function gDisasters_SetupGFXVars()
		LocalPlayer().gDisasters.GFX = {}
		LocalPlayer().gDisasters.GFX.Effect = "none"
		LocalPlayer().gDisasters.GFX.Parent = false
	end
	
	local function gDisasters_SetupOutsideVars()
		LocalPlayer().gDisasters.Outside = {}
		LocalPlayer().gDisasters.Outside.IsOutside     = false
		LocalPlayer().gDisasters.Outside.OutsideFactor = 0
		
	
	
	end

	gDisasters_SetupOutsideVars()
	gDisasters_SetupHUDMISC()	
	gDisasters_SetupFOGVars()
	gDisasters_SetupHUDConvars()
	gDisasters_SetupGFXVars()
end
hook.Add( "InitPostEntity", "gDisasters_PostSpawnCL", gDisasters_PostSpawnCL )
