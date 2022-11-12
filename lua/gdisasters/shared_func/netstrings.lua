if (SERVER) then

	util.AddNetworkString( "gd_isOutdoor" )
	util.AddNetworkString( "gd_clParticles" )
	util.AddNetworkString( "gd_clParticles_ground" )	
	util.AddNetworkString( "gd_screen_particles" )	
	util.AddNetworkString( "gd_maplight_cl")
	util.AddNetworkString( "gd_seteyeangles_cl")
	util.AddNetworkString( "gd_vomit")
	util.AddNetworkString( "gd_vomit_blood")
	util.AddNetworkString( "gd_sneeze")
	util.AddNetworkString( "gd_sneeze_big")
	util.AddNetworkString( "gd_lightning_bolt")
	util.AddNetworkString( "gd_sendsound"	)
	util.AddNetworkString( "gd_ambientlight"	)
	util.AddNetworkString( "gd_shakescreen"	)
	util.AddNetworkString( "gd_soundwave" )

	util.AddNetworkString( "gd_entity_exists_on_server" )
	
	util.AddNetworkString( "gd_createfog" )
	util.AddNetworkString( "gd_creategfx" )
	
	util.AddNetworkString( "gd_removegfxfog" )
	util.AddNetworkString( "gd_resetoutsidefactor" )

	net.Receive("gd_ambientlight", function()
		local ent = net.ReadEntity()
		local aLL = net.ReadVector()
		ent.AmbientLight = aLL
		
	
	end)

	net.Receive( "gd_entity_exists_on_server", function() 
		local string = net.ReadString()
		local ent = ents.Create(string)
		ent:Spawn()
		ent:Activate()
	end)

	net.Receive("gd_vomit_blood", function()
		
		local ent = net.ReadEntity()
		local mouth_attach = ent:LookupAttachment("mouth")
		ent:EmitSound("streams/disasters/player/vomitblood.wav", 80, 100)
		ParticleEffectAttach( "vomit_blood_main", PATTACH_POINT_FOLLOW, ent, mouth_attach )

	end)

	net.Receive("gd_vomit", function()
		
		local ent = net.ReadEntity()
		local mouth_attach = ent:LookupAttachment("mouth")
		ent:EmitSound("streams/disasters/player/vomit.wav", 80, 100)
		ParticleEffectAttach( "vomit_main", PATTACH_POINT_FOLLOW, ent, mouth_attach )

	end)

	net.Receive("gd_sneeze", function()
		
		local ent = net.ReadEntity()
		local mouth_attach = ent:LookupAttachment("mouth")
		ent:EmitSound("streams/disasters/player/vomit.wav", 80, 100)
		ParticleEffectAttach( "sneeze_main", PATTACH_POINT_FOLLOW, ent, mouth_attach )

	end)
	net.Receive("gd_sneeze_big", function()
		
		local ent = net.ReadEntity()
		local mouth_attach = ent:LookupAttachment("mouth")
		ent:EmitSound("streams/disasters/player/vomitblood.wav", 80, 100)
		ParticleEffectAttach( "sneeze_big_main", PATTACH_POINT_FOLLOW, ent, mouth_attach )

	end)


end
	
if (CLIENT) then

net.Receive("gd_ambientlight", function()
	
	local tr = util.TraceLine( {
		start = LocalPlayer():GetPos(),
		endpos = LocalPlayer():GetPos() - Vector(0,0,100),
		filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) then return true end end
	} )
	
	if tr.Entity:IsValid() then LocalPlayer().AmbientLight = Vector(0,0,0) return end 

	LocalPlayer().AmbientLight = render.ComputeLighting(  tr.HitPos, tr.HitNormal )

	net.Start("gd_ambientlight")
		net.WriteEntity(LocalPlayer())
		net.WriteVector(LocalPlayer().AmbientLight)
	net.SendToServer()
	
end)

net.Receive("gd_clParticles", function()
	if GetConVar("gdisasters_graphics_enable_weather_particles"):GetInt() <= 0 then return end

	local effect = net.ReadString()
	local angle  = net.ReadAngle()
	ParticleEffect( effect, LocalPlayer():GetPos(), angle, nil )
 
end)

net.Receive("gd_clParticles_ground", function()
	if GetConVar("gdisasters_graphics_enable_ground_particles"):GetInt() <= 0 then return end
	for k,v in pairs(player.GetAll()) do
		if !v:IsOnGround() then return end
	end

	local effect = net.ReadString()
	local angle  = net.ReadAngle()
	ParticleEffect( effect, LocalPlayer():GetPos(), angle, nil )
 
end)


net.Receive("gd_seteyeangles_cl", function()
	
	local offset = net.ReadAngle()
	local angle  = LocalPlayer():EyeAngles()
	x, y, z = offset.x, offset.y, offset.z 
	x2, y2, z2 = angle.x, angle.y, angle.z 
	
	
	LocalPlayer():SetEyeAngles( Angle(x+x2, y+y2, z+z2) )
	
	
 
end)

net.Receive("gd_screen_particles", function()

	if GetConVar("gdisasters_graphics_enable_screen_particles"):GetInt() <= 0 then return end

	if LocalPlayer().ScreenParticles == nil then LocalPlayer().ScreenParticles = {} end
	
	local texture  = net.ReadString()
	local size     = net.ReadFloat()
	local life     = net.ReadFloat() + CurTime()
	local number   = GetConVar("gdisasters_graphics_number_of_screen_particles"):GetInt()
	local vel      = net.ReadVector()
	
	
	for i=0, number do
		local pos      = Vector( math.random(0,ScrW()), math.random(0,ScrH()), 0) 
		local center   = pos - Vector(size/2,size/2,0)
		
		LocalPlayer().ScreenParticles[#LocalPlayer().ScreenParticles+1] = {["Texture"]=surface.GetTextureID(texture),
																		   ["Material"]=Material(texture),
																	       ["Size"]   = size, 
																	       ["Life"]   = life,
																	       ["Pos"]    = center,
																		   ["Velocity"] = vel
																	        }
		hook.Add( "RenderScreenspaceEffects", "Draw Particles", gfx_screenParticles)
	end	
	
end)

net.Receive("gd_lightning_bolt", function()
	
	local ent1   = net.ReadEntity()
	local ent2   = net.ReadEntity()
	local effect = net.ReadString()

	if !ent1:IsValid() or !ent2:IsValid() then return end

	
	local CPoint0 = {
		["entity"] = ent1,
		["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
	}
	local CPoint1 = {
		["entity"] =  ent2,
		["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
	}
	
	
	ent1:CreateParticleEffect(effect,{CPoint0,CPoint1})
	
 
end)

net.Receive("gd_soundwave", function()

	local s 	 = net.ReadString()
	local stype 	 = net.ReadString() -- "mono or stereo or 3d"
	local pos  		 = net.ReadVector() or LocalPlayer():GetPos() -- epicenter
	local pitchrange = net.ReadTable() or {100,100}
	
	if stype == "mono" then
		
		surface.PlaySound( s )
	
	elseif stype == "stereo" then
	
		LocalPlayer():EmitSound( s, 100, math.random(pitchrange[1], pitchrange[2]), 1 )

	elseif stype == "3d" then
		sound.Play( s,  pos, 150, math.random(pitchrange[1], pitchrange[2]), 1 )
	end
	
	
 
end)




net.Receive("gd_shakescreen", function()

	if GetConVar("gdisasters_shakescreen_enable"):GetInt() == 0 then return end
	
	local duration = net.ReadFloat()
	local a        = net.ReadFloat() or 25
	local f        = net.ReadFloat() or 25
	
	util.ScreenShake( LocalPlayer():GetPos(), a, f, duration, 10000 )

	
 
end)


net.Receive("gd_sendsound", function()
	
	local sound  = net.ReadString()
	local pitch  = net.ReadFloat() or 100
	local volume = net.ReadFloat() or 1
	LocalPlayer():EmitSound(sound, 100, pitch, volume)

	
 
end)

net.Receive("gd_isOutdoor", function()
	isOutside                = net.ReadBool()
	
	if LocalPlayer().gDisasters == nil then return end
	
	
	LocalPlayer().gDisasters.Outside.IsOutside     = isOutside
	
	
	
	
	if isOutside then

		LocalPlayer().gDisasters.Outside.OutsideFactor   = Lerp( 0.01, LocalPlayer().gDisasters.Outside.OutsideFactor, 100)

		LocalPlayer().gDisasters.Fog.Data.DensityCurrent =  Lerp( 0.02, LocalPlayer().gDisasters.Fog.Data.DensityCurrent, LocalPlayer().gDisasters.Fog.Data.DensityMax )
		LocalPlayer().gDisasters.Fog.Data.EndMinCurrent  =  Lerp( 0.02, LocalPlayer().gDisasters.Fog.Data.EndMinCurrent, LocalPlayer().gDisasters.Fog.Data.EndMin )
	else
		LocalPlayer().gDisasters.Outside.OutsideFactor   = Lerp( 0.01, LocalPlayer().gDisasters.Outside.OutsideFactor, 0)
		LocalPlayer().gDisasters.Fog.Data.DensityCurrent =  Lerp( 0.01, LocalPlayer().gDisasters.Fog.Data.DensityCurrent, LocalPlayer().gDisasters.Fog.Data.DensityMin )
		LocalPlayer().gDisasters.Fog.Data.EndMinCurrent  =  Lerp( 0.01, LocalPlayer().gDisasters.Fog.Data.EndMinCurrent, LocalPlayer().gDisasters.Fog.Data.EndMax )
	end
	
end)




net.Receive("gd_seteyeangles_cl", function()
	
	local offset = net.ReadAngle()
	local angle  = LocalPlayer():EyeAngles()
	x, y, z = offset.x, offset.y, offset.z 
	x2, y2, z2 = angle.x, angle.y, angle.z 
	
	
	LocalPlayer():SetEyeAngles( Angle(x+x2, y+y2, z+z2) )
	
	
 
end)


net.Receive("gd_screen_particles", function()
	
	if GetConVar("gdisasters_graphics_enable_screen_particles"):GetInt() <= 0 then return end

	if LocalPlayer().ScreenParticles == nil then LocalPlayer().ScreenParticles = {} end
	
	
	
	local texture  = net.ReadString()
	local size     = net.ReadFloat()
	local life     = net.ReadFloat() + CurTime()
	local number   = GetConVar("gdisasters_graphics_number_of_screen_particles"):GetFloat()
	local vel      = net.ReadVector()
	
	
	for i=0, number do
		local pos      = Vector( math.random(0,ScrW()), math.random(0,ScrH()), 0) 
		local center   = pos - Vector(size/2,size/2,0)
		
		LocalPlayer().ScreenParticles[#LocalPlayer().ScreenParticles+1] = {["Texture"]=surface.GetTextureID(texture),
																		   ["Material"]=Material(texture),
																	       ["Size"]   = size, 
																	       ["Life"]   = life,
																	       ["Pos"]    = center,
																		   ["Velocity"] = vel
																	        }
		hook.Add( "RenderScreenspaceEffects", "Draw Particles", gfx_screenParticles)
	end	
	
end)


	
net.Receive( "gd_maplight_cl", function( len, pl ) 
	timer.Simple(0.1, function()
		render.RedownloadAllLightmaps()
	end)


end )



end




	
	



-- shared





























