

for i=10, 50 do 

	surface.CreateFont( "gDisastersFont_"..tostring(i), {
		font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		extended = false,
		size = i,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )
end

local function drawPercentageBox( edger, ox, oy, w, l, minv, maxv, current_value, color)

	local xscale, yscale, scale        = ScrW()/1920, ScrH()/1080, (ScrH() + ScrW())/ 3000	
	local percentage                   = 0
	if minv < 0 then
		percentage = math.Clamp((current_value + ((maxv - minv) * 0.5)) / (maxv - minv), 0, 1)
		
	else
		percentage = math.Clamp((current_value-minv)  / (maxv - minv), 0, 1)
	end
	
	local height                       = l * percentage
	local my                           = oy - height
	
	draw.RoundedBox( edger, ox * xscale, my * yscale, w * xscale, height * yscale, color ) -- body temp


end

function hud_gDisastersINFO()
	if GetConVar( "gdisasters_hud_enabled" ):GetInt()!=1 then return end
	 
	if GetConVar( "gdisasters_hud_type" ):GetInt()==1 then 

		hud_DrawBasicINFO()

	elseif GetConVar( "gdisasters_hud_type" ):GetInt()==2 then
	
		hud_DrawBarometer()

	elseif GetConVar( "gdisasters_hud_type" ):GetInt()==3 then
	
		hud_DrawSeismoGraph()
	elseif GetConVar( "gdisasters_hud_type" ):GetInt()==4 and GetConVar("gdisasters_spacebuild_enabled"):GetInt() >= 1 then
		
		hud_DrawSpacebuildINFO()
	end
end
hook.Add("HUDPaint", "gDisastersINFO", hud_gDisastersINFO)



function hud_gDisastersAlarm()
	
	if CurTime() >= LocalPlayer().gDisasters.HUD.NextWarningSoundTime then
	
		LocalPlayer():EmitSound( "streams/disasters/player/hud_warning.wav", 100, 100, math.Clamp(GetConVar( "gdisasters_volume_hud_warning" ):GetFloat(),0,1) )
		LocalPlayer().gDisasters.HUD.NextWarningSoundTime = CurTime() + 1
	else
	end
end

function hud_gDisastersHeart(nexttime, pitch)
	if CurTime() >= LocalPlayer().gDisasters.HUD.NextHeartSoundTime then
		LocalPlayer():EmitSound( "streams/disasters/player/heartbeat.wav", 100, pitch, math.Clamp(GetConVar( "gdisasters_volume_hud_heartbeat" ):GetFloat(),0,1))
		LocalPlayer().gDisasters.HUD.NextHeartSoundTime = CurTime() + nexttime
	else
	end
end


function hud_gDisastersVomit()

	if CurTime() >= LocalPlayer().gDisasters.HUD.NextVomitTime then
		LocalPlayer().gDisasters.HUD.VomitIntensity = 1
		net.Start("gd_vomit")
		net.WriteEntity(LocalPlayer())
		net.SendToServer()
		
		LocalPlayer().gDisasters.HUD.NextVomitTime = CurTime() + math.random(1,19)
	else
	end
end

function hud_gDisastersVomitBlood()

	
	if CurTime() >= LocalPlayer().gDisasters.HUD.NextVomitBloodTime  then
		LocalPlayer().gDisasters.HUD.BloodVomitIntensity   = 1
		net.Start("gd_vomit_blood")
		net.WriteEntity(LocalPlayer())
		net.SendToServer()
		
		LocalPlayer().gDisasters.HUD.NextVomitBloodTime  = CurTime() + math.random(1,19)
	else
	end
end	

function hud_gDisastersSneeze()


	if CurTime() >= LocalPlayer().gDisasters.HUD.NextSneezeTime  then
		LocalPlayer().gDisasters.HUD.SneezeIntensity   = 1
		net.Start("gd_sneeze")
		net.WriteEntity(LocalPlayer())
		net.SendToServer()
		
		LocalPlayer().gDisasters.HUD.NextSneezeTime  = CurTime() + math.random(1,20)
	else
	end
end

function hud_gDisastersSneezeBig()

	
	if CurTime() >= LocalPlayer().gDisasters.HUD.NextSneezeBigTime  then
		LocalPlayer().gDisasters.HUD.SneezeBigIntensity   = 1
		net.Start("gd_sneeze_big")
		net.WriteEntity(LocalPlayer())
		net.SendToServer()
		
		LocalPlayer().gDisasters.HUD.NextSneezeBigTime  = CurTime() + math.random(1,24)
	else
	end
end

function hud_DrawBarometer()

	local xscale, yscale, scale        = ScrW()/1920, ScrH()/1080, (ScrH() + ScrW())/ 3000	
		
	local function drawFrame()
		draw.RoundedBox( 12 * scale, 270 * xscale, 885 * yscale, 560 * xscale, 200 * yscale, Color( 30, 30, 30, 150 ) ) -- main box
		draw.RoundedBox( 12 * scale, 280 * xscale, 895 * yscale, 540 * xscale, 180 * yscale, Color( 255, 255, 255, 150 ) ) -- main box
	end
	
	local function drawBarometerOverlay()
		surface.SetDrawColor( 255, 255,255, 255 )

		
		local barometer     = surface.GetTextureID( "hud/barometer" )

		local scale  = 1 
		local w, h   = 540 * scale, 180 * scale
		local x, y   = 550 - (w/2), 985  - (h/2)
		
		surface.SetTexture( barometer )
		surface.DrawTexturedRect(  x * xscale, y * yscale, w * xscale, h * yscale )
		
		
		
	end
	
	local function drawBarometerArrow()
		surface.SetDrawColor( 255, 255, 255, 255 )
		
		local pressure                     = GetGlobalFloat("gDisasters_Pressure")
		local clockhead                    = surface.GetTextureID( "hud/clockhead" )
		local angle                        = math.Clamp((((106000-math.Clamp(pressure,94000,106000))/ 12000) * 180),20,160)
		
		local x0, y0                       = -90 , 0
		
		local c = math.cos( math.rad( angle ) )
		local s = math.sin( math.rad( angle ) )

		local newx = y0 * s - x0 * c
		local newy = y0 * c + x0 * s
		
		
		surface.SetTexture( clockhead )
		surface.DrawTexturedRectRotated( 540 + newx, 1130 + newy, 219, 39, angle )

		

	end
	


	drawFrame()
	drawBarometerOverlay()
	drawBarometerArrow()
end


function hud_DrawSpacebuildINFO()
	local xscale, yscale, scale        = ScrW()/1920, ScrH()/1080, (ScrH() + ScrW())/ 3000

	local pos_air_temperature      	   = Vector(280 * xscale, 860 * yscale, 0) 
	local pos_body_oxygen        	  = Vector(280 * xscale, 890 * yscale, 0)
	local pos_body_energy       	  = Vector(280 * xscale, 920 * yscale, 0)
	local pos_body_coolant       	  = Vector(280 * xscale, 950 * yscale, 0)

	local air_tmp   = math.Round(GetGlobalFloat("gDisasters_Temperature"),1)
	local body_oxygen = math.Round(LocalPlayer():GetNWFloat("BodyOxygen"))
	local body_energy = math.Round(LocalPlayer():GetNWFloat("BodyEnergy"))
	local body_Coolant = math.Round(LocalPlayer():GetNWFloat("BodyCoolant"))

	local air_temp = tostring(air_tmp)
	local body_o2 = tostring(body_oxygen)
	local body_ener =  tostring(body_energy)
	local body_cool =  tostring(body_Coolant)

	local function drawFrame()
	
		draw.RoundedBox( 12 * scale, 270 * xscale, 855 * yscale, 560 * xscale, 220 * yscale, Color( 30, 30, 30, 100 ) ) -- main box
		draw.RoundedBox( 6 * scale, 565 * xscale, 865 * yscale, 255 * xscale, 180 * yscale, Color( 30, 30, 30, 100 ) ) -- main box right

	end
	local function drawText()

		if GetConVar("gdisasters_hud_temptype"):GetString() == "°C" then
			draw.DrawText( "Air Temperature: "..air_temp.."°C", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_air_temperature.x , pos_air_temperature.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		elseif GetConVar("gdisasters_hud_temptype"):GetString() == "°F" then
			draw.DrawText( "Air Temperature: "..convert_CelciustoFahrenheit(air_temp).."°F", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_air_temperature.x , pos_air_temperature.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		elseif GetConVar("gdisasters_hud_temptype"):GetString() == "°K" then
			draw.DrawText( "Air Temperature: "..convert_CelciustoKelvin(air_temp).."°K", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_air_temperature.x , pos_air_temperature.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		end
		
		draw.DrawText( "Body Oxygen: "..body_o2.."%", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_body_oxygen.x , pos_body_oxygen.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		draw.DrawText( "Body Energy: "..body_ener.."%", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_body_energy.x , pos_body_energy.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		draw.DrawText( "Body Coolant: "..body_cool.."%", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_body_coolant.x , pos_body_coolant.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
	end
	local function drawBars()
		local oxygen_min, oxygen_max   = 100,   200
		local energy_min, energy_max   = 100,   200
		local coolant_min, coolant_max   = 100,   200

		
		local r, g, b                   = 0, 0, 0
		local r2, g2, b2                = 0, 0, 0
		local r3, g3, b3               = 0, 0, 0
		local r4, g4, b4              = 0, 0, 0

		local function drawAirBar()
			if air_tmp >= -273.3 and air_tmp <= 0 then 
				
				if air_tmp <= -136.65 then
					local p = (air_tmp+273.3) / 136.65
					r = 0
					g = 255 * p
					b = 255
				else 
					local p = (air_tmp+136.65) / 136.65
					
					r = 0
					g = 255 
					b = 255 * (1 - p)
				end
				
			elseif air_tmp > 5 and air_tmp < 38 then
				r = 0
				g = 255 
				b = 0
			elseif air_tmp >= 38 and air_tmp <= 273.3 then 
			
				if air_tmp <= 136.65 then

					local p = (air_tmp-38) / 98.65
					r = 255 * p
					g = 255 
					b = 0
				else 
					local p = (air_tmp-136.65) / 136.65
	
					r = 255
					g = 255 * (1 - p)
					b = 0
				end
			end
			
			drawPercentageBox( 0, 600, 1020, 22, 150, -1000, 1000, air_tmp, Color( r, g, b, 200))

		end
		local function drawEnergyBar()
			if body_energy >= energy_max then
				r2 = 243 
				g2 = 255
				b2 = 0
			elseif body_energy < energy_max and body_energy >= energy_min then 
				r2 = 106
				g2 = 133
				b2 = 0
			elseif body_energy < energy_min then
				r2 = 106
				g2 = 133
				b2 = 0
			end
			
			drawPercentageBox( 0, 624, 1020, 22, 150, 0, 200, body_ener, Color( r2, g2, b2, 200))

		end
		local function drawCoolentBar()
			if body_Coolant >= coolant_max then
				r3 = 0
				g3 = 255
				b3 = 255
			elseif body_Coolant < coolant_max and body_Coolant >= coolant_min then 
				r3 = 0
				g3 = 205
				b3 = 205
			elseif body_Coolant < coolant_min then
				r3 = 0
				g3 = 148
				b3 = 148
			end
			
			drawPercentageBox( 0, 648, 1020, 22, 150, 0, 200, body_cool, Color( r3, g3, b3, 200))

		end
		local function drawOxygenBar()
			if body_oxygen >= oxygen_max then
				r4 = 0
				g4 = 139
				b4 = 255
			elseif body_oxygen < oxygen_max and body_oxygen >= oxygen_min then 
				r4 = 0
				g4 = 139
				b4 = 205
			elseif body_oxygen < oxygen_min then
				r4 = 0
				g4 = 139
				b4 = 148
			end
			
			drawPercentageBox( 0, 577, 1020, 22, 150, 0, 200, body_o2, Color( r4, g4, b4, 200))

		end
		drawAirBar()
		drawEnergyBar()
		drawCoolentBar()
		drawOxygenBar()
	end
	local function drawIcons()
		surface.SetDrawColor( 255, 255,255, 255 )
		local oxygen     = surface.GetTextureID( "icons/oxygen" )
		local coolent    = surface.GetTextureID( "icons/ice" )
		local energy    = surface.GetTextureID( "icons/lighting")
		local airtemp      = surface.GetTextureID( "icons/airtemp" )
		local w, h   = 16 * scale, 16 * scale
		
		local x, y   = 605, 1025
		surface.SetTexture( airtemp )
		surface.DrawTexturedRect(  x * xscale, y * yscale, w * xscale, h * yscale )

		local x, y   = 580, 1025
		surface.SetTexture( oxygen )
		surface.DrawTexturedRect(  x * xscale, y * yscale, w * xscale, h * yscale )
		
		local x, y   = 624, 1025
		surface.SetTexture( energy )
		surface.DrawTexturedRect(  x * xscale, y * yscale, w * xscale, h * yscale )
	
		local x, y   = 650, 1025
		surface.SetTexture( coolent )
		surface.DrawTexturedRect(  x * xscale, y * yscale, w * xscale, h * yscale )
	end
	drawFrame()
	drawBars()
	drawIcons()
	drawText()
	
end

function hud_DrawBasicINFO()
	local xscale, yscale, scale        = ScrW()/1920, ScrH()/1080, (ScrH() + ScrW())/ 3000
		
	local pos_air_temperature      	   = Vector(280 * xscale, 860 * yscale, 0)
	local pos_body_temperature         = Vector(280 * xscale, 890 * yscale, 0)
	local pos_body_oxygen        	  = Vector(280 * xscale, 920 * yscale, 0)
	local pos_humidity                 = Vector(280 * xscale, 950 * yscale , 0)
	local pos_windspeed                = Vector(280 * xscale, 980 * yscale , 0)
	local pos_lwindspeed                = Vector(280 * xscale, 1013 * yscale , 0)
	local pos_winddir               = Vector(280 * xscale, 1045 * yscale , 0)
	
	local air_tmp   = math.Round(GetGlobalFloat("gDisasters_Temperature"),1)
	local body_tmp  = math.Round(LocalPlayer():GetNWFloat("BodyTemperature"),1)
	local body_Oxygen  = math.Round(LocalPlayer():GetNWFloat("BodyOxygen"))
	local hm        = math.Round(GetGlobalFloat("gDisasters_Humidity"))
	local windspd   = math.Round(GetGlobalFloat("gDisasters_Wind"),1)
	local winddir   = GetGlobalVector("gDisasters_Wind_Direction")
	local lwindspd  = math.Round(LocalPlayer():GetNWFloat("LocalWind"),1)

	local air_temp   =  tostring( air_tmp )
	local body_temp  =  tostring( body_tmp )
	local body_Oxy  =  tostring( body_Oxygen )
	local humidity   =  tostring( hm)
	local Wind_Direction   =  convert_AngleYawToDegrees(convert_VectorToAngle(winddir))
	
	local function windspeed_Format(speed)
		local strspeed = tostring(speed)
		local chr1, chr2, chr3, chr4 = strspeed[1], strspeed[2], strspeed[3], strspeed[4]
		
		if chr1 == "" or chr1==nil  then chr1 = "" end
		if chr2 == "" or chr2==nil  then chr2 = "" end
		if chr3 == "" or chr3==nil  then chr3 = "" end
		if chr4 == "" or chr4==nil  then chr4 = "" end
		
		if speed <= 256 and GetConVar("gdisasters_hud_windtype"):GetString() == "km/h" then 
			strspeed = chr1..chr2..chr3..chr4.." km/h"
		elseif speed > 256 and GetConVar("gdisasters_hud_windtype"):GetString() == "km/h" then
			strspeed = table.Random({chr1..chr2..chr3..chr4.." km/h", "ERROR"})
		elseif speed <= 256 and GetConVar("gdisasters_hud_windtype"):GetString() == "mph" then
			strspeed = convert_KMPHtoMPH(chr1..chr2..chr3..chr4).." mph"
		elseif speed > 256 and GetConVar("gdisasters_hud_windtype"):GetString() == "mph" then
			strspeed = table.Random({convert_KMPHtoMPH(chr1..chr2..chr3..chr4).." mph", "ERROR"})
		end
		
		return strspeed
		
		
	end

	local wind_speed   =  tostring(windspeed_Format(windspd))
	local local_wspeed =  tostring(windspeed_Format(lwindspd))
	

	local function drawFrame()
	
		draw.RoundedBox( 12 * scale, 270 * xscale, 855 * yscale, 560 * xscale, 220 * yscale, Color( 30, 30, 30, 100 ) ) -- main box
		draw.RoundedBox( 6 * scale, 565 * xscale, 865 * yscale, 255 * xscale, 180 * yscale, Color( 30, 30, 30, 100 ) ) -- main box right
		draw.RoundedBox( 6 * scale, 680 * xscale, 890 * yscale, 128 * xscale, 128 * yscale, Color( 30, 30, 30, 150 + (math.sin(CurTime()) * 50) ) ) 
		
	end
	
	local function drawText()

		if GetConVar("gdisasters_hud_temptype"):GetString() == "°C" then
			draw.DrawText( language.GetPhrase("gd_hud_air_temperature")..air_temp.."°C", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_air_temperature.x , pos_air_temperature.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
			draw.DrawText( language.GetPhrase("gd_hud_body_temperature")..body_temp.."°C", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_body_temperature.x , pos_body_temperature.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		elseif GetConVar("gdisasters_hud_temptype"):GetString() == "°F" then
			draw.DrawText( language.GetPhrase("gd_hud_air_temperature")..convert_CelciustoFahrenheit(air_temp).."°F", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_air_temperature.x , pos_air_temperature.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
			draw.DrawText( language.GetPhrase("gd_hud_body_temperature")..convert_CelciustoFahrenheit(body_temp).."°F", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_body_temperature.x , pos_body_temperature.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		elseif GetConVar("gdisasters_hud_temptype"):GetString() == "°K" then
			draw.DrawText( language.GetPhrase("gd_hud_air_temperature")..convert_CelciustoKelvin(air_temp).."°K", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_air_temperature.x , pos_air_temperature.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
			draw.DrawText( language.GetPhrase("gd_hud_body_temperature")..convert_CelciustoKelvin(body_temp).."°K", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_body_temperature.x , pos_body_temperature.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		end
		
		draw.DrawText( language.GetPhrase("gd_hud_body_oxygen")..body_Oxy.."%", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_body_oxygen.x , pos_body_oxygen.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		draw.DrawText( language.GetPhrase("gd_hud_humidity")..humidity.."%", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_humidity.x , pos_humidity.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		

		local color  = Color(255,255,255,255)
		local color2  = Color(255,255,255,255)
	
		if windspd > 256 then
			color    = Color(math.random(0,255), 0, 0, 255)
			color2    = Color(math.random(0,255), 0, 0, 255)
		end
		
		draw.DrawText( language.GetPhrase("gd_hud_wind_speed")..wind_speed, "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_windspeed.x , pos_windspeed.y, color, TEXT_ALIGN_LEFT )
		draw.DrawText( language.GetPhrase("gd_hud_local_wind_speed")..local_wspeed, "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_lwindspeed.x , pos_lwindspeed.y, color2, TEXT_ALIGN_LEFT )
		draw.DrawText( language.GetPhrase("gd_hud_wind_drection")..Wind_Direction.."°", "gDisastersFont_"..tostring(math.Round(scale * 25)), pos_winddir.x , pos_winddir.y, color, TEXT_ALIGN_LEFT )
		
	end
	
	local function drawBars()
	
		local hypo_min, hypo_max     = 24,   36.5
		local safe_c_min, safe_c_max = 35.5, 38
		local hyper_min, hyper_max   = 38,   44
		local oxygen_min, oxygen_max   = 10,   50
		
		local r, g, b                   = 0, 0, 0
		local r2, g2, b2                = 0, 0, 0
		local r3, g3, b3               = 0, 0, 0
		
		local function drawCoreBar()
			if body_tmp >= hypo_min and body_tmp <= hypo_max then 
				
				if body_tmp <= ((hypo_min+hypo_max)/2) then
					local p = (body_tmp-24) / 6.25
					r = 0
					g = 255 * p
					b = 255
				else 
					local p = (body_tmp-30.25) / 6.25
					
					r = 0
					g = 255 
					b = 255 * (1 - p)
				end
				
			elseif body_tmp > safe_c_min and body_tmp < safe_c_max then
				r = 0
				g = 255 
				b = 0
			elseif body_tmp >= hyper_min and body_tmp <= hyper_max then 
			
				if body_tmp <= ((hyper_min+hyper_max)/2) then

					local p = (body_tmp-38) / 3
					r = 255 * p
					g = 255 
					b = 0
				else 
					local p = (body_tmp-41) / 3
					
					r = 255
					g = 255 * (1 - p)
					b = 0
				end
			end
			
			if body_tmp < 26 or body_tmp > 40 then 
				
				if math.Round(CurTime())%2 == 0 then
					hud_gDisastersAlarm()
					drawPercentageBox( 0, 624, 1020, 22, 150, 24, 44, body_tmp, Color( r, g, b, 255 ))
				else
					drawPercentageBox( 0, 624, 1020, 22, 150, 24, 44, body_tmp, Color( 0, 0, 0, 255 ))
				end
			else
				drawPercentageBox( 0, 624, 1020, 22, 150, 24, 44, body_tmp, Color( r, g, b, 200 ))
			end
		end
		
		local function drawAirBar()
			if air_tmp >= -273.3 and air_tmp <= 0 then 
				
				if air_tmp <= -136.65 then
					local p = (air_tmp+273.3) / 136.65
					r2 = 0
					g2 = 255 * p
					b2 = 255
				else 
					local p = (air_tmp+136.65) / 136.65
					
					r2 = 0
					g2 = 255 
					b2 = 255 * (1 - p)
				end
				
			elseif air_tmp > 5 and air_tmp < 38 then
				r2 = 0
				g2 = 255 
				b2 = 0
			elseif air_tmp >= 38 and air_tmp <= 273.3 then 
			
				if air_tmp <= 136.65 then

					local p = (air_tmp-38) / 98.65
					r2 = 255 * p
					g2 = 255 
					b2 = 0
				else 
					local p = (air_tmp-136.65) / 136.65
	
					r2 = 255
					g2 = 255 * (1 - p)
					b2 = 0
				end
			end
			
			drawPercentageBox( 0, 600, 1020, 22, 150, -273, 273, air_tmp, Color( r2, g2, b2, 200))

		end
		
		local function drawHumidityBar()
			drawPercentageBox( 0, 648, 1020, 22, 150, 0, 100, hm, Color( 155, 155, 155, 200))
		end

		local function drawOxygenBar()

			if body_Oxygen <= oxygen_min and body_Oxygen > 5 then
				r3 = 34
				g3 = 113
				b3 = 179
			elseif body_Oxygen > oxygen_min then
				r3 = 0
				g3 = 170
				b3 = 228
			elseif body_Oxygen <= 5 then
				r3 = 37
				g3 = 40
				b3 = 80
			elseif body_Oxygen >= oxygen_max then
				r3 = 221
				g3 = 224
				b3 = 245
			end
			drawPercentageBox( 0, 577, 1020, 22, 150, 0, 100, body_Oxygen, Color( r3, g3, b3, 200))
		end
		drawHumidityBar()
		drawOxygenBar()	
		drawAirBar()
		drawCoreBar()
	end
	local function drawHeart()
		
		surface.SetDrawColor( 255, 255, 255, 255)
		local heart     = surface.GetTextureID( "hud/heart" )
		local freq      = math.Clamp((1-((44-math.Round(body_tmp))/20)) * (180/60), 0.5, 20)
		if LocalPlayer():Alive()==false then freq = 0.05 end 
		

		local scale  = 1 + (math.sin( CurTime() * ((2*math.pi) * freq) ) * 0.1)
		local w, h   = 110 * scale, 110 * scale
		local x, y   = 750 - (w/2), 955  - (h/2)
		
		surface.SetTexture( heart )
		surface.DrawTexturedRect(  x * xscale, y * yscale, w * xscale, h * yscale )
		hud_gDisastersHeart( 1/freq , 100 )
		
	end
	
	local function drawIcons()
		surface.SetDrawColor( 255, 255,255, 255 )
		
		local airtemp      = surface.GetTextureID( "icons/airtemp" )
		local bodytemp     = surface.GetTextureID( "icons/bodytemp" )
		local humidity     = surface.GetTextureID( "icons/humidity" )
		local oxygen     = surface.GetTextureID( "icons/oxygen" )
		local w, h   = 16 * scale, 16 * scale
		
		local x, y   = 605, 1025
		surface.SetTexture( airtemp )
		surface.DrawTexturedRect(  x * xscale, y * yscale, w * xscale, h * yscale )
		


		local x, y   = 629, 1025
		surface.SetTexture( bodytemp )
		surface.DrawTexturedRect(  x * xscale, y * yscale, w * xscale, h * yscale )
		
		local x, y   = 651, 1025
		surface.SetTexture( humidity )
		surface.DrawTexturedRect(  x * xscale, y * yscale, w * xscale, h * yscale )

		local x, y   = 577, 1025
		surface.SetTexture( oxygen )
		surface.DrawTexturedRect(  x * xscale, y * yscale, w * xscale, h * yscale )
		
	end
	
	
	
	
	
	
	
	
	drawFrame()
	drawText()
	drawBars()
	drawHeart()
	drawIcons()

end

function hud_DrawSeismoGraph()
	
	local xscale, yscale, scale        = ScrW()/1920, ScrH()/1080, (ScrH() + ScrW())/ 3000	
	local xmin, xmax = 290  * yscale , (269+540) * yscale 
	local ymin, ymax = 900  * yscale , (890+180) * yscale 	
	
	local function drawFrame()
		draw.RoundedBox( 12 * scale, 270 * xscale, 885 * yscale, 620 * xscale, 200 * yscale, Color( 30, 30, 30, 150 ) ) -- main box
		draw.RoundedBox( 12 * scale, 280 * xscale, 895 * yscale, 610 * xscale, 180 * yscale, Color( 0, 0, 0, 255 ) ) -- main box
	end
	
	local function drawGrid()		
		local xjump      = math.floor(xmax-xmin)
		local yjump      = math.floor(ymax-ymin)
		
		local xdensity   = 16
		local ydensity   = 10
	
		surface.SetDrawColor( 0, 55, 0, 255 )
		
		for i=0, xdensity do
			local nxmin = ((i/xdensity) * (xjump) + xmin)
			surface.DrawLine( nxmin, ymin, nxmin, ymax )
		end
		
		for i=0, ydensity do
		
			local nymin = ((i/ydensity) * (yjump) + ymin)

			surface.DrawLine( xmin, nymin, xmax, nymin )
		end
		
	end
	

	local function recordTremors()
	
		local sample_interval = math.Clamp( ((1/FrameTime())/66.666) * 0.01, 0.01, 1)
		local max_sample_points = 500
		
		if LocalPlayer().SeismoGraph_SampleIntervalNextTime == nil then LocalPlayer().SeismoGraph_SampleIntervalNextTime = CurTime() end
		if LocalPlayer().SeismoGraph_SamplePoints == nil then LocalPlayer().SeismoGraph_SamplePoints = {} end
		
		if #LocalPlayer().SeismoGraph_SamplePoints > max_sample_points then
			table.remove(LocalPlayer().SeismoGraph_SamplePoints, max_sample_points + 1 )
		end
		
		if CurTime() >= LocalPlayer().SeismoGraph_SampleIntervalNextTime then  -- here we add sample points 
			
			local M  =  -1+( GetGlobalFloat("gd_seismic_activity")/12)
			local IP =  (-(M-0.25)^2 - (2/(M-0.25))) / 8
		
			local ygain = (( 0.5 * (ymax - ymin) + math.random(0,10) ) * (math.sin( (2 * math.pi * math.random(14,16)) * CurTime()))) * (math.Clamp((IP),0.01, 1))
	
			LocalPlayer().SeismoGraph_SampleIntervalNextTime = CurTime() + sample_interval
			table.insert(LocalPlayer().SeismoGraph_SamplePoints, { ["A"]= IP, ["Pos"]=Vector(xmax, ( (ymax + ymin) / 2) + ygain)   }   ) 
			
		
		end
		
	
	end	
	
	local function drawTremors()
		surface.SetDrawColor( 0, 255, 0, 255 )
		
		local vel  = 66.666/(1/FrameTime())
		local max_a = 0
		for k, v in pairs(LocalPlayer().SeismoGraph_SamplePoints) do
			
			v["Pos"] = v["Pos"] - Vector(vel,0,0)
			if v["Pos"].x <= xmin then table.remove(LocalPlayer().SeismoGraph_SamplePoints, k) end -- remove out of bounds stuff
			
			if LocalPlayer().SeismoGraph_SamplePoints[k-1] != nil then
				local olpos = LocalPlayer().SeismoGraph_SamplePoints[k-1]["Pos"]
				local amp   = LocalPlayer().SeismoGraph_SamplePoints[k-1]["A"]
				
				surface.SetDrawColor( 0, 255, 0, 255 )
				surface.DrawLine( olpos.x, olpos.y, v["Pos"].x, v["Pos"].y )
				surface.SetDrawColor( 255, 0, 0, 255 * ((v["A"]+amp) * 0.5) )
				surface.DrawLine( olpos.x, (amp  * (-0.5 * (ymax - ymin)))+ (0.5 * (ymax + ymin)), v["Pos"].x, (v["A"] * (-0.5 * (ymax - ymin))) + (0.5 * (ymax + ymin))  )
				surface.DrawLine( olpos.x, (amp  * (0.5 * (ymax - ymin)))+ (0.5 * (ymax + ymin)), v["Pos"].x, (v["A"] * (0.5 * (ymax - ymin))) + (0.5 * (ymax + ymin))  )
				
				if max_a < v["A"] then 
					max_a_x =  v["Pos"].x
					max_a   =  v["A"] 
				end
				
			end
			
		end
		
		local peak_x_min, peak_x_max =  809 * xscale, 828 * xscale 
		--±0.4
		surface.SetDrawColor( 255, 255, 255 , 255 )
		surface.DrawLine( peak_x_min, (max_a  * (-0.5 * (ymax - ymin)))+ (0.5 * (ymax + ymin)), peak_x_max, (max_a  * (-0.5 * (ymax - ymin)))+ (0.5 * (ymax + ymin)) )
		draw.DrawText( " Richter Scale \n     ≈  "..math.Round(GetGlobalFloat("gd_seismic_activity"),1), "gDisastersFont_"..tostring(math.Round(scale * 15)), peak_x_min , (max_a  * (-0.5 * (ymax - ymin)))+ (0.5 * (ymax + ymin)) , Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )

	end	
	recordTremors()
	
	drawFrame()
	drawGrid()
	drawTremors()
	

end
	
	
	

	
	
	
	
	
	
	