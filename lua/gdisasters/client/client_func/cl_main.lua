function CreateLoopedSound(client, sound)
	local sound = Sound(sound)

	CSPatch = CreateSound(client, sound)
	CSPatch:Play()
	return CSPatch
	
end

function StopLoopedSound(client, sound)
	CSPatch = CreateLoopedSound(client, sound)
	CSPatch:Stop()
	return CSPatch
	
end



function gfx_screenParticles()
	if LocalPlayer().ScreenParticles==nil then return end

	
	


	
	for k, v in pairs(LocalPlayer().ScreenParticles) do
	
		local t    = v["Life"]
		local size = v["Size"]
		local tex  = v["Texture"]
		local mat  = v["Material"]
		local isref = v["Refracting"]
		local pos   = v["Pos"]
		local pvel  = v["Velocity"]
		
		local vel   = LocalPlayer():GetVelocity()/50
		local velnrl= LocalPlayer():GetVelocity():GetNormalized()
		local dot   = (LocalPlayer():GetAimVector():Dot(LocalPlayer():GetVelocity())/10) -- dot product between aim vec and vel
		
		
		
		local fdir = (Vector(ScrW()/2, ScrH()/2, 0) - LocalPlayer().ScreenParticles[k]["Pos"]):GetNormalized() * (dot/25)
	
		if CurTime()<=t then 
			mat:SetFloat( "$refractamount", 0.4 )
			render.UpdateScreenEffectTexture()
		
			surface.SetTexture(tex)
			surface.SetDrawColor( 255, 255, 255, math.Clamp( (t - CurTime()), 0, 1 )*255 )
			surface.DrawTexturedRect( pos.x, pos.y,size, size )
			LocalPlayer().ScreenParticles[k]["Pos"] = LocalPlayer().ScreenParticles[k]["Pos"] - fdir + pvel + Vector(0,velnrl.z*8,0) 
			
		
		
			
		else
			LocalPlayer().ScreenParticles[k] = nil 
		end
		
		
	end
	

	
end

hook.Add("RenderScreenspaceEffects", "gfx_Underwater", function() 
	
	
	if isUnderWater(LocalPlayer()) then
		if LocalPlayer().LastIsUnderwater == false then
			LocalPlayer().Sounds["Underwater"] = CreateLoopedSound(LocalPlayer(), "ambient/water/underwater.wav")
			LocalPlayer().LastIsUnderwater = true
		end
		
		local flood  = ents.FindByClass("env_dynamicwater")[1] or  ents.FindByClass("env_dynamicwater_b")[1]
		
		if flood==nil then return end 
		
		if flood:IsValid() then 
		
		
		
			local z_diff = math.abs(LocalPlayer():GetNWInt("ZWaterDepth", 0))
			local alpha  =  math.Clamp( z_diff,0,800) / 800
			
			
		
			local tab = {}
				tab[ "$pp_colour_addr" ] = 0
				tab[ "$pp_colour_addg" ] = 0
				tab[ "$pp_colour_addb" ] = 0
				tab[ "$pp_colour_brightness" ] = 0 - ( alpha * 0.7 )
				tab[ "$pp_colour_contrast" ] = 1 - ( alpha * 0.25 )
				tab[ "$pp_colour_colour" ] = 1 - ( alpha * 0.25 )
				tab[ "$pp_colour_mulr" ] = 0
				tab[ "$pp_colour_mulg" ] = -1 * alpha
				tab[ "$pp_colour_mulb" ] = -1 * alpha
			
			DrawColorModify( tab )
		
			
			local mat_Overlay = Material("effects/water_warp01")
			render.UpdateScreenEffectTexture()
		
			mat_Overlay:SetFloat( "$envmap", 0 )
			mat_Overlay:SetFloat( "$envmaptint", 0 )
			mat_Overlay:SetFloat( "$refractamount", 0.1 )
			mat_Overlay:SetInt( "$ignorez", 1 )
		
			render.SetMaterial( mat_Overlay )
			render.DrawScreenQuad()
		end
	else
		if LocalPlayer().Sounds["Underwater"] !=nil then 
			LocalPlayer().Sounds["Underwater"]:Stop()
			LocalPlayer().Sounds["Underwater"] = nil 
		end
	end
	LocalPlayer().LastIsUnderwater = LocalPlayer():GetNWBool("IsUnderwater")

end)

hook.Add("RenderScreenspaceEffects", "gfx_Underlava", function() 
	LocalPlayer().LavaIntensity = math.Clamp(LocalPlayer().LavaIntensity - (FrameTime()/4), 0, 1)
	local intensity = LocalPlayer().LavaIntensity 

	if isUnderLava(LocalPlayer()) then	
		if LocalPlayer().LastIsUnderlava == false then
			LocalPlayer().Sounds["Underlava"] = CreateLoopedSound(LocalPlayer(), "ambient/water/underwater.wav")
			LocalPlayer().LastIsUnderwater = true
		end

		local tab2 = {}
			tab2[ "$pp_colour_addr" ] = intensity * 4
			tab2[ "$pp_colour_addg" ] = intensity * 2
			tab2[ "$pp_colour_addb" ] = -intensity
			tab2[ "$pp_colour_brightness" ] = 0
			tab2[ "$pp_colour_contrast" ] = 1
			tab2[ "$pp_colour_colour" ] = 1
			tab2[ "$pp_colour_mulr" ] = intensity
			tab2[ "$pp_colour_mulg" ] = -intensity
			tab2[ "$pp_colour_mulb" ] = -intensity
		DrawColorModify( tab2 )

		local mat_Overlay = Material("effects/water_warp01")
		render.UpdateScreenEffectTexture()
		
		mat_Overlay:SetFloat( "$envmap", 0 )
		mat_Overlay:SetFloat( "$envmaptint", 0 )
		mat_Overlay:SetFloat( "$refractamount", intensity )
		mat_Overlay:SetInt( "$ignorez", 1 )
		
		render.SetMaterial( mat_Overlay )
		render.DrawScreenQuad()
		
		local flood2  = ents.FindByClass("env_dynamiclava")[1] or ents.FindByClass("env_dynamiclava_b")[1]
		
		if flood2==nil then return end 
		
		if flood2:IsValid() then

			local z_diff2 = math.abs(LocalPlayer():GetNWInt("ZlavaDepth", 0))
			local alpha2  =  math.Clamp( z_diff2,0,800) / 800
		
			local tab = {}
				tab[ "$pp_colour_addr" ] = alpha2 * 4
				tab[ "$pp_colour_addg" ] = alpha2 * 2
				tab[ "$pp_colour_addb" ] = -alpha2
				tab[ "$pp_colour_brightness" ] = 0
				tab[ "$pp_colour_contrast" ] = 1
				tab[ "$pp_colour_colour" ] = 1
				tab[ "$pp_colour_mulr" ] = alpha2
				tab[ "$pp_colour_mulg" ] = -alpha2
				tab[ "$pp_colour_mulb" ] = -alpha2
			DrawColorModify( tab )


			
			local mat_Overlay = Material("effects/water_warp01")
			render.UpdateScreenEffectTexture()
		
			mat_Overlay:SetFloat( "$envmap", 0 )
			mat_Overlay:SetFloat( "$envmaptint", 0 )
			mat_Overlay:SetFloat( "$refractamount", alpha2 )
			mat_Overlay:SetInt( "$ignorez", 1 )
		
			render.SetMaterial( mat_Overlay )
			render.DrawScreenQuad()


		end
	else
		if LocalPlayer().Sounds["Underlava"] !=nil then 
			LocalPlayer().Sounds["Underlava"]:Stop()
			LocalPlayer().Sounds["Underlava"] = nil 
		end
		
	end
	LocalPlayer().LastIsUnderlava = LocalPlayer():GetNWBool("IsUnderlava")




end)

	
hook.Add("RenderScreenspaceEffects", "gfx_TempEffect", function()

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


end)
	
	
	
	
	
	
	
	
	
--[[

Function Name: 		 FindInCylinder
Function Purpose:    Find entities in a vertical cylinder
Function parameters: 
					
					[1] Starting position
					[2] Radius of the cylinder (                 constant                        )
					[3] Max height gain        (         local to starting position              )
					[4] Min height gain        (         local to starting position              )
					[5] Physics ents only      ( filters out non-physics entities if true (bool) )

					
Function notes:
	Cylinder always is vertical 

--]]


function FindInCylinder(pos, radius, top, bottom)

	local entities = {}
	local selfpos_normalized = Vector(pos.x, pos.y, 0)
	
	local z_max, z_min = pos.z + top, pos.z + bottom 
	
	for k, v in pairs(ents.GetAll()) do
	
		local vpos            = v:GetPos() 
		local vpos_normalized = Vector(vpos.x, vpos.y, 0)
		
		local dist            = vpos_normalized:Distance(selfpos_normalized)
		local zdiff           = vpos.z - pos.z 
		
		
		
		if dist <= radius then 
				
			if zdiff > 0 then -- v is higher than me 
				if zdiff <= top then
					table.insert(entities, v)
				end
				
			elseif zdiff == 0 then -- same position
				table.insert(entities, v)
				
			elseif zdiff < 0 then -- v is below us
			
				if zdiff >= bottom then
					table.insert(entities, v)
				end
			
			end
			
		
		end
			
				
	
	
	end
	
	return entities 
end


function CreateSoundWave(soundpath, epicenter, soundtype, speed, pitchrange, shakeduration) -- SPEED MUST BE IN MS^-1


	local distance = LocalPlayer():GetPos():Distance(epicenter) -- distance from player and epicenter
	local t        = distance / convert_MetoSU(speed)  -- speed of sound = 340.29 m/s

	timer.Simple(t, function()
		if LocalPlayer():IsValid() then
		
			if shakeduration > 0 then
			
				util.ScreenShake( LocalPlayer():GetPos(), 1, 15, 1, 10000 )
			
			end
		
			if soundtype == "mono" then
				surface.PlaySound( soundpath )
			elseif soundtype == "stereo" then
				LocalPlayer():EmitSound( soundpath, 100, math.random(pitchrange[1], pitchrange[2]), GetConVar("gdisasters_volume_soundwave"):GetFloat() )
			elseif soundtype == "3d" then
				sound.Play( soundpath,  epicenter, 170, math.random(pitchrange[1], pitchrange[2]), GetConVar("gdisasters_volume_soundwave"):GetFloat() )
			end		
		end
	end)

end

function StopSoundWave(soundpath) -- SPEED MUST BE IN MS^-1

	if LocalPlayer():IsValid() then
		LocalPlayer():StopSound(soundpath)
	end
	
end

function AddCeilingWaterDrops(effect_nm, ieffect_nm, delay, offset_range, angle)

	if GetConVar("gdisasters_graphics_draw_ceiling_effects"):GetInt() <= 0 then return end 

	local offset = Vector(math.random(-1 * offset_range,1  * offset_range),math.random(-1 * offset_range,1  * offset_range), 0)
	local fallback_angle = Angle(0,0,0)	

	local fromGroundToCeiling_TR = util.TraceLine( {
		start  = LocalPlayer():GetPos() + offset,
		endpos = LocalPlayer():GetPos() + offset + Vector(0,0,8000) ,
		filter = LocalPlayer()
	} )
	
	local fromCeilingToGround_TR = util.TraceLine( {
		start  = fromGroundToCeiling_TR.HitPos,
		endpos = fromGroundToCeiling_TR.HitPos - Vector(0,0,8000),
		filter = LocalPlayer()
	} )

	local d = fromGroundToCeiling_TR.HitPos:Distance(fromCeilingToGround_TR.HitPos)
	local t = d / 500 

	if not(fromGroundToCeiling_TR.Hit or fromCeilingToGround_TR.Hit) then return end 


	ParticleEffect(effect_nm or "nil", fromGroundToCeiling_TR.HitPos, angle or fallback_angle ,nil)

	timer.Simple(delay + t, function()

		ParticleEffect(ieffect_nm or "nil", fromCeilingToGround_TR.HitPos, angle or fallback_angle ,nil)

	end)


end


function ENT:SetMDScale(ent, scale)
	local mat = Matrix()
	mat:Scale(scale)
	ent:EnableMatrix("RenderMultiply", mat)
end

function ENT:SetParticleScale(particle, scale)
	local mat = Matrix()
	mat:Scale(scale)
	particle:EnableMatrix("RenderMultiply", mat)
end


