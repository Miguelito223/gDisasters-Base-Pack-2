
if (SERVER) then


	function gDisasters_CreateFog(ply, parent_entity, fogdata, override_quality)
			
			net.Start("gd_createfog")
			net.WriteEntity(parent_entity)
			net.WriteBool(override_quality)
			net.WriteTable(fogdata)
			net.Send(ply)

	end
	
	function gDisasters_CreateGlobalFog(parent_entity, data, override_quality)
		for k, v in pairs(player.GetAll()) do
			gDisasters_CreateFog(v, parent_entity, data, override_quality)
			
		end
	
	end
	
	function gDisasters_ResetOutsideFactor(ply) 
		
		net.Start("gd_resetoutsidefactor")
		net.Send(ply)
	
	end
	
	function gDisasters_ResetGlobalOutsideFactor()
		for k, v in pairs(player.GetAll()) do
			gDisasters_ResetOutsideFactor(v)
		end
		
	
	end
	
	function gDisasters_RemoveGlobalFog()
	
		net.Start("gd_removegfxfog")
		net.WriteBool(true)
		net.WriteBool(false)
		net.Broadcast()

			
	end
	
	function gDisasters_RemoveGlobalGFX()
	
		net.Start("gd_removegfxfog")
		net.WriteBool(false)
		net.WriteBool(true)
		net.Broadcast()

		
	
	end
	
	
	
	function gDisasters_CreateGFX(ply, parent_entity, effect)
	
		net.Start("gd_creategfx")
		net.WriteEntity(parent_entity)
		net.WriteString(effect)
		net.Send(ply)
			
			
	end
	
	function gDisasters_CreateGlobalGFX(effect, parent_entity)
		for k, v in pairs(player.GetAll()) do
			gDisasters_CreateGFX(v, parent_entity, effect)
		
		end
	
	end

	
	

	
end


if (CLIENT) then
	
	gDisasters_Effects = {}
	
	gDisasters_Effects["sunny"] = function()
	
		hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX")
		
		local function RenderEffect()
		
			local cm = {}
			cm[ "$pp_colour_addr" ] = 0
			cm[ "$pp_colour_addg" ] = 0
			cm[ "$pp_colour_addb" ] = 0
			cm[ "$pp_colour_brightness" ] = 0 
			cm[ "$pp_colour_contrast" ] = 1 + (LocalPlayer().gDisasters.Outside.OutsideFactor/160)
			cm[ "$pp_colour_colour" ] = 1 + (LocalPlayer().gDisasters.Outside.OutsideFactor/320)
			cm[ "$pp_colour_mulr" ] = 0
			cm[ "$pp_colour_mulg" ] = 0
			cm[ "$pp_colour_mulb" ] = 0
			
			DrawColorModify( cm )
			
			if LocalPlayer().gDisasters.GFX.Parent:IsValid() == false then hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX") LocalPlayer().gDisasters.GFX.Effect = "none" LocalPlayer().gDisasters.GFX.Parent = false end 
			
		end
		hook.Add("RenderScreenspaceEffects", "gDisasters_GFX", RenderEffect )

	end
	
	gDisasters_Effects["heatwave"] = function()
	
		hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX")
		
		local function RenderEffect()
		
			local cm = {}
			cm[ "$pp_colour_addr" ] = 0 + (LocalPlayer().gDisasters.Outside.OutsideFactor/700)
			cm[ "$pp_colour_addg" ] = 0
			cm[ "$pp_colour_addb" ] = 0
			cm[ "$pp_colour_brightness" ] = 0 
			cm[ "$pp_colour_contrast" ] = 1 + (LocalPlayer().gDisasters.Outside.OutsideFactor/160)
			cm[ "$pp_colour_colour" ] = 1 + (LocalPlayer().gDisasters.Outside.OutsideFactor/320)
			cm[ "$pp_colour_mulr" ] = 0
			cm[ "$pp_colour_mulg" ] = 0
			cm[ "$pp_colour_mulb" ] = 0
			
			DrawColorModify( cm )
			
			if LocalPlayer().gDisasters.GFX.Parent:IsValid() == false then hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX") LocalPlayer().gDisasters.GFX.Effect = "none" LocalPlayer().gDisasters.GFX.Parent = false end 
			
		end
		hook.Add("RenderScreenspaceEffects", "gDisasters_GFX", RenderEffect )

	end	
	gDisasters_Effects["coldwave"] = function()
	
		hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX")
		
		local function RenderEffect()
		
			local cm = {}
			cm[ "$pp_colour_addr" ] =  0
			cm[ "$pp_colour_addg" ] = 0
			cm[ "$pp_colour_addb" ] = (LocalPlayer().gDisasters.Outside.OutsideFactor/1240)
			cm[ "$pp_colour_brightness" ] = 0 
			cm[ "$pp_colour_contrast" ] = 1 + (LocalPlayer().gDisasters.Outside.OutsideFactor/320)
			cm[ "$pp_colour_colour" ] = 1 + (LocalPlayer().gDisasters.Outside.OutsideFactor/320)
			cm[ "$pp_colour_mulr" ] = 0
			cm[ "$pp_colour_mulg" ] = 0
			cm[ "$pp_colour_mulb" ] = 0
			
			DrawColorModify( cm )
			
			if LocalPlayer().gDisasters.GFX.Parent:IsValid() == false then hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX") LocalPlayer().gDisasters.GFX.Effect = "none" LocalPlayer().gDisasters.GFX.Parent = false end 
			
		end
		hook.Add("RenderScreenspaceEffects", "gDisasters_GFX", RenderEffect )

	end	
	gDisasters_Effects["sandstormy"] = function()
	
		hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX")
		
		local function RenderEffect()
		
		

			
			
			local cm = {}
			cm[ "$pp_colour_addr" ] = 0.2 * (LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)
			cm[ "$pp_colour_addg" ] = 0.05 * (LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)
			cm[ "$pp_colour_addb" ] = -0.25 * (LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)
			cm[ "$pp_colour_brightness" ] = 0
			cm[ "$pp_colour_contrast" ] = 1 - ((LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)/2)
			cm[ "$pp_colour_colour" ] = 1
			cm[ "$pp_colour_mulr" ] = 0.05 * (LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)
			cm[ "$pp_colour_mulg" ] = 0
			cm[ "$pp_colour_mulb" ] =  -0.25 * (LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)
			
			DrawColorModify( cm )
			
			if LocalPlayer().gDisasters.GFX.Parent:IsValid() == false then hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX") LocalPlayer().gDisasters.GFX.Effect = "none" LocalPlayer().gDisasters.GFX.Parent = false end 
			
		end
		hook.Add("RenderScreenspaceEffects", "gDisasters_GFX", RenderEffect )

	end
	
	
	gDisasters_Effects["heavyrain"] = function()
	
		hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX")
		
		local function RenderEffect()
		
		

			
			
			local cm = {}
			cm[ "$pp_colour_addr" ] = 0
			cm[ "$pp_colour_addg" ] = 0
			cm[ "$pp_colour_addb" ] =  0
			cm[ "$pp_colour_brightness" ] = 0
			cm[ "$pp_colour_contrast" ] = 1 
			cm[ "$pp_colour_colour" ] = 1
			cm[ "$pp_colour_mulr" ] = 0
			cm[ "$pp_colour_mulg" ] = 0
			cm[ "$pp_colour_mulb" ] = 0
			
			DrawColorModify( cm )
			
			if LocalPlayer().gDisasters.GFX.Parent:IsValid() == false then hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX") LocalPlayer().gDisasters.GFX.Effect = "none" LocalPlayer().gDisasters.GFX.Parent = false end 
			
		end
		hook.Add("RenderScreenspaceEffects", "gDisasters_GFX", RenderEffect )

	end
	
	gDisasters_Effects["kingramses"] = function()
	
		hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX")
		
		local function RenderEffect()
		
		

			
			local cm = {}
			cm[ "$pp_colour_addr" ] = math.random(-1000,1000)/1000
			cm[ "$pp_colour_addg" ] = math.random(-1000,1000)/1000
			cm[ "$pp_colour_addb" ] = math.random(-1000,1000)/1000
			cm[ "$pp_colour_brightness" ] = math.random(-1000,1000)/1000
			cm[ "$pp_colour_contrast" ] = math.random(-1000,1000)/1000 
			cm[ "$pp_colour_colour" ] = math.random(-1000,1000)/1000
			cm[ "$pp_colour_mulr" ] = math.random(-1000,1000)/1000
			cm[ "$pp_colour_mulg" ] = math.random(-1000,1000)/1000
			cm[ "$pp_colour_mulb" ] = math.random(-1000,1000)/1000
			
			
			DrawColorModify( cm )
			
			
			
			surface.SetTexture(surface.GetTextureID(table.Random({"hud/king_ramses_02", "hud/king_ramses_01", "hud/king_ramses_03"})))
			surface.SetDrawColor( 255, 255, 255, math.random(1,256))
			surface.DrawTexturedRect( 0, 0,ScrW(), ScrH() )
			
			if math.random(1,16)==1 then surface.PlaySound( table.Random({"ambient/voices/f_scream1.wav","ambient/voices/m_scream1.wav","ambient/voices/squeal1.wav"})) end

			if LocalPlayer().gDisasters.GFX.Parent:IsValid() == false then hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX") LocalPlayer().gDisasters.GFX.Effect = "none" LocalPlayer().gDisasters.GFX.Parent = false end 
			
		end
		hook.Add("RenderScreenspaceEffects", "gDisasters_GFX", RenderEffect )

	end
	
	
	gDisasters_Effects["heavyfog"] = function()
	
		hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX")
		
		local function RenderEffect()
		
		

			
			local cm = {}
			cm[ "$pp_colour_addr" ] = 0
			cm[ "$pp_colour_addg" ] = 0
			cm[ "$pp_colour_addb" ] = 0
			cm[ "$pp_colour_brightness" ] = 0
			cm[ "$pp_colour_contrast" ] = 1 - ((LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)/2)
			cm[ "$pp_colour_colour" ] = 1 - ((LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)/8)
			cm[ "$pp_colour_mulr" ] = 0
			cm[ "$pp_colour_mulg" ] = 0
			cm[ "$pp_colour_mulb" ] = 0
			
			
			DrawColorModify( cm )
			
			if LocalPlayer().gDisasters.GFX.Parent:IsValid() == false then hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX") LocalPlayer().gDisasters.GFX.Effect = "none" LocalPlayer().gDisasters.GFX.Parent = false end 
			
		end
		hook.Add("RenderScreenspaceEffects", "gDisasters_GFX", RenderEffect )

	end
	
	gDisasters_Effects["night"] = function()
	
		hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX")
		
		local function RenderEffect()
		
		

			
			local cm = {}
			cm[ "$pp_colour_addr" ] = 0
			cm[ "$pp_colour_addg" ] = 0
			cm[ "$pp_colour_addb" ] = 0
			cm[ "$pp_colour_brightness" ] = -0.2
			cm[ "$pp_colour_contrast" ] = 1 - ((LocalPlayer().gDisasters.Fog.Data.DensityCurrent/0.8)/2)
			cm[ "$pp_colour_colour" ] = 0.5 - (LocalPlayer().gDisasters.Outside.OutsideFactor/320)
			cm[ "$pp_colour_mulr" ] = 0.2
			cm[ "$pp_colour_mulg" ] = 0.05
			cm[ "$pp_colour_mulb" ] = 0.05
			
			
			DrawColorModify( cm )
			
			if LocalPlayer().gDisasters.GFX.Parent:IsValid() == false then hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX") LocalPlayer().gDisasters.GFX.Effect = "none" LocalPlayer().gDisasters.GFX.Parent = false end 
			
		end
		hook.Add("RenderScreenspaceEffects", "gDisasters_GFX", RenderEffect )

	end
	
	gDisasters_Effects["RENDERFOG"] = function()
	
		hook.Remove("RenderScreenspaceEffects", "gDisasters_RenderFog")

		hook.Remove("SetupSkyboxFog", "gd_RenderFogSkybox")
		hook.Remove("SetupWorldFog", "gd_RenderFog")
		

		local function gd_RenderFogWorld()
			
			local isOutside         = LocalPlayer().isOutside 
			local fogColor          = LocalPlayer().gDisasters.Fog.Data.Color
			
			
			render.FogMode( MATERIAL_FOG_LINEAR	 ) 
			render.FogStart( 0 ) 
			render.FogEnd( LocalPlayer().gDisasters.Fog.Data.EndMinCurrent )
			render.FogMaxDensity(LocalPlayer().gDisasters.Fog.Data.DensityCurrent) 
			render.FogColor(fogColor.r,fogColor.g,fogColor.b)
			
			return true
		end

		local function gd_RenderFogSkybox()
			local isOutside         = LocalPlayer().isOutside 
			local fogColor          = LocalPlayer().gDisasters.Fog.Data.Color
	
			render.FogMode( MATERIAL_FOG_LINEAR	 ) 
			render.FogStart( 0 ) 
			render.FogEnd( 0 )
			render.FogMaxDensity(LocalPlayer().gDisasters.Fog.Data.DensityCurrent) 
			render.FogColor(fogColor.r,fogColor.g,fogColor.b)
		
			return true
		end
							
							
		local function RenderFog()
			
			if LocalPlayer().gDisasters.Fog.OQ == true then
			
			else 
				
				if GetConVar( "gdisasters_graphics_fog_quality" ):GetInt() <= 4 then
					if CurTime() >= LocalPlayer().gDisasters.Fog.NextEmitTime then 
						
						if math.random(1, 2 * ( ( GetConVar( "gdisasters_graphics_fog_quality" ):GetInt() + 1 ) * 2)  )==1 and LocalPlayer().gDisasters.Outside.IsOutside then
								
							ParticleEffect( "renderfog_main_HQ", LocalPlayer():GetPos(), Angle(0,0,0), nil )
						
						end
						
						LocalPlayer().gDisasters.Fog.NextEmitTime = CurTime() + 0.01
					else
					end
				
				end
			end
			if LocalPlayer().gDisasters.Fog.Parent:IsValid()==false then
				
				hook.Remove("RenderScreenspaceEffects", "gDisasters_RenderFog")
				hook.Remove("SetupSkyboxFog", "gd_RenderFogSkybox")
				hook.Remove("SetupWorldFog", "gd_RenderFogWorld")
				LocalPlayer().gDisasters.Fog.Parent = "none"
				
				
			end
	
			
		
		end
		
		if LocalPlayer().gDisasters.Fog.OQ == true then 
			hook.Add("SetupSkyboxFog", "gd_RenderFogSkybox", gd_RenderFogSkybox)
			hook.Add("SetupWorldFog", "gd_RenderFogWorld", gd_RenderFogWorld) 		
			hook.Add("RenderScreenspaceEffects", "gDisasters_RenderFog", RenderFog )
		else
			hook.Add("SetupSkyboxFog", "gd_RenderFogSkybox", gd_RenderFogSkybox)
			hook.Add("SetupWorldFog", "gd_RenderFogWorld", gd_RenderFogWorld) 		
			hook.Add("RenderScreenspaceEffects", "gDisasters_RenderFog", RenderFog )
			LocalPlayer().gDisasters.Fog.Data.DensityMax = (LocalPlayer().gDisasters.Fog.Data.DensityMax/5) * (2 + GetConVar( "gdisasters_graphics_fog_quality" ):GetInt())

		end

	end
	
	
	
	
	net.Receive("gd_removegfxfog", function()
		
		local remove_fog = net.ReadBool()
		local remove_gfx = net.ReadBool()
		
		if remove_fog then
		
			hook.Remove("RenderScreenspaceEffects", "gDisasters_RenderFog")
			hook.Remove("SetupSkyboxFog", "gd_RenderFogSkybox")
			hook.Remove("SetupWorldFog", "gd_RenderFogWorld")
			LocalPlayer().gDisasters.Fog.Parent = "none"	
			
		elseif remove_gfx then
		
			hook.Remove("RenderScreenspaceEffects", "gDisasters_GFX") 
			LocalPlayer().gDisasters.GFX.Effect = "none" 
			LocalPlayer().gDisasters.GFX.Parent = false 
	
		
		end
		
	end)
			
	net.Receive("gd_resetoutsidefactor", function()
		
		LocalPlayer().gDisasters.Outside.OutsideFactor = 0 
		
	end)	
	

	net.Receive("gd_createfog", function()
		
		local entity = net.ReadEntity()
		local oq     = net.ReadBool()
		local info   = net.ReadTable()
		
		LocalPlayer().gDisasters.Fog.Data   = info
		LocalPlayer().gDisasters.Fog.Parent = entity
		LocalPlayer().gDisasters.Fog.OQ     = oq
		
		gDisasters_Effects["RENDERFOG"]()
		
	end)
		
		

	net.Receive("gd_creategfx", function()
		
		local entity = net.ReadEntity()
		local effect  = net.ReadString()
		
		LocalPlayer().gDisasters.GFX.Parent = entity
		LocalPlayer().gDisasters.GFX.Effect = effect
		
		gDisasters_Effects[effect]()

		

		
	end)
end

