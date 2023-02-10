function gfx_temperatureEffects()
	
	if GetConVar("gdisasters_hud_temp_enable_cl"):GetInt() == 0 then return end

	local temp            = LocalPlayer():GetNWFloat("BodyTemperature")
	local blur_alpha_hot  =  1-((44-math.Clamp(temp,39,44))/5)
	local blur_alpha_cold =  ((35-math.Clamp(temp,24,35))/11)
	local iangle          = LocalPlayer():EyeAngles()

	local shivering_intensity =  ((((math.Clamp(36-temp, 0, 4)/2) - 1)^2) * -1) + 1   -- y = -x^2 + 1 curve ( you can check online )
	
	local cm_hot = {}
		cm_hot[ "$pp_colour_addr" ]        = 0 + (blur_alpha_hot)	
		cm_hot[ "$pp_colour_addg" ]        = 0
		cm_hot[ "$pp_colour_addb" ]        = 0
		cm_hot[ "$pp_colour_brightness" ]  = 0
		cm_hot[ "$pp_colour_contrast" ]    = 1 - (blur_alpha_hot^2)
		cm_hot[ "$pp_colour_colour" ]      = 1
		cm_hot[ "$pp_colour_mulr" ]        = 0
		cm_hot[ "$pp_colour_mulg" ]        = 0
		cm_hot[ "$pp_colour_mulb" ]        = 0

	local cm_cold = {}
		cm_cold[ "$pp_colour_addr" ]        = 0 + (blur_alpha_cold)	
		cm_cold[ "$pp_colour_addg" ]        = 0
		cm_cold[ "$pp_colour_addb" ]        = 0 + (blur_alpha_cold)	
		cm_cold[ "$pp_colour_brightness" ]  = 0
		cm_cold[ "$pp_colour_contrast" ]    = 1 - (blur_alpha_cold^2)
		cm_cold[ "$pp_colour_colour" ]      = 1 - (blur_alpha_cold^2)
		cm_cold[ "$pp_colour_mulr" ]        = 0 - (blur_alpha_cold^2)
		cm_cold[ "$pp_colour_mulg" ]        = 0 - (blur_alpha_cold^2)
		cm_cold[ "$pp_colour_mulb" ]        = 0 + (blur_alpha_cold)	



	if temp > 39 and math.random(1,400)==1 then
		if GetConVar("gdisasters_hud_temp_vomit"):GetInt() == 0 then return end
		if temp >= 42 then
			
			hud_gDisastersVomitBlood()
	
		else
		
			hud_gDisastersVomit()
		end
	end
	if temp < 35 and math.random(1,400)==1 then
		if GetConVar("gdisasters_hud_temp_sneeze"):GetInt() == 0 then return end
		if temp <= 32 then
			
			hud_gDisastersSneezeBig()
	
		else
		
			hud_gDisastersSneeze()
		end
	end

	LocalPlayer():SetEyeAngles( Angle(iangle.x + (math.random(-200 * shivering_intensity,200 * shivering_intensity)/100), iangle.y + (math.random(-100 * shivering_intensity,100 * shivering_intensity)/100) , 0))
	DrawColorModify( cm_hot )
	DrawColorModify( cm_cold )
	DrawMotionBlur( 0.1, blur_alpha_hot, 0.05)
	DrawMotionBlur( 0.1, blur_alpha_cold, 0.05)
		
	
	

end
	
	
hook.Add("RenderScreenspaceEffects", "Temperature Effects", gfx_temperatureEffects)
	
	



