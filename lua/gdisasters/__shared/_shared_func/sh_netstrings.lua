net.Receive( "gd_net", function( len )

	local mask_on = net.ReadBit()
	if mask_on==1 then
		hook.Add( "RenderScreenspaceEffects", "GasMask", GasMask)
	else
		hook.Remove("RenderScreenspaceEffects", "GasMask", GasMask)
	end
end)

net.Receive( "gd_net_tvirus", function( len, pl )
	local tickrate   = 1/engine.TickInterval()
	local data_table = net.ReadTable()
	
	local seconds = math.Round(data_table["Seconds"],2)
	local ply  = data_table["Infected"]
	local isdead = data_table["IsDead"]
	-- Carefully timed events
	if (isdead) then	
		ply:StopSound("tvirus")
		ply:StopSound("tvirus_symptom")
		hook.Remove("RenderScreenspaceEffects", "T-Virus")
		hook.Remove("RenderScreenspaceEffects", "T-Virus_Phase_2")
		timepassed=0
	end
	
	local function Events(seconds)
		-- Event Random 
		if (seconds) > 10 and (seconds<110) then
			if math.random(1, 2500)==2500 then	
				LocalPlayer():EmitSound(table.Random({"ambient/voices/citizen_beaten3.wav","ambient/voices/playground_memory.wav","ambient/voices/m_scream1.wav","npc/zombie/zombie_voice_idle12.wav"}),100,100)

				hook.Add( "RenderScreenspaceEffects", "T-Virus", function()
					if scary_time == nil then 
						scary_time=0
					end
					
					scary_time=scary_time+1/(1/RealFrameTime()) -- making time a constant
					
					local tab = {}
					tab[ "$pp_colour_addr" ] = 0
					tab[ "$pp_colour_addg" ] = -1+((1/6)*scary_time)
					tab[ "$pp_colour_addb" ] = -1+((1/6)*scary_time)
					tab[ "$pp_colour_brightness" ] = 0
					tab[ "$pp_colour_contrast" ] = 0+((1/6)*scary_time)
					tab[ "$pp_colour_colour" ] = 1
					tab[ "$pp_colour_mulr" ] = 0
					tab[ "$pp_colour_mulg" ] = 0
					tab[ "$pp_colousr_mulb" ] = 0 
					DrawColorModify( tab )			

					DrawMotionBlur( 0.09, 1-((1/6)*scary_time), 0)
					
	
					if scary_time>=6 then
						scary_time=nil
						hook.Remove("RenderScreenspaceEffects", "T-Virus")
					end
					
					
				end )
			end
		end

		if seconds==0.02 then
			return 1
		elseif seconds==10 then
			return 2
		elseif seconds==216 then
			return 3
		end
	end
	local function EventHandler(event)
		if event == 1 then -- If Initial 
			ply:ChatPrint("You feel a sudden surge of nausea...")
			
			ply:EmitSound("tvirus_symptom")
			

			hook.Add( "RenderScreenspaceEffects", "T-Virus", function()
				if timepassed == nil then 
					timepassed=0
					
				end
				
				timepassed=timepassed+1/(1/RealFrameTime()) -- making time a constant
				
				local tab = {}
				tab[ "$pp_colour_addr" ] = 0
				tab[ "$pp_colour_addg" ] = 0
				tab[ "$pp_colour_addb" ] = 0
				tab[ "$pp_colour_brightness" ] = 0
				tab[ "$pp_colour_contrast" ] = math.Clamp(3-(2*(timepassed/10)),0,3)
				tab[ "$pp_colour_colour" ] = math.Clamp(0+(timepassed/10),0,1)
				tab[ "$pp_colour_mulr" ] = 0
				tab[ "$pp_colour_mulg" ] = 0
				tab[ "$pp_colousr_mulb" ] = 0 
				DrawColorModify( tab )			
				
				DrawMotionBlur( 0.09, 1.5-(2*(timepassed/10)), 0)
				
				
				if timepassed>=9.9 then
					timepassed=nil
					hook.Remove("RenderScreenspaceEffects", "T-Virus")
				end
				
				
			end )

		elseif event == 2 then 
			ply:EmitSound("tvirus")

			hook.Add( "RenderScreenspaceEffects", "T-Virus_Phase_2", function()
			
				if timepassed == nil then 
					timepassed=0
				end
				
				timepassed=timepassed+1/(1/RealFrameTime()) -- making time the constant for everything drawn
				-- Draw Veins and shit




				
				-- Colormods
				local tab = {}
				tab[ "$pp_colour_addr" ] = 0
				tab[ "$pp_colour_addg" ] = 0
				tab[ "$pp_colour_addb" ] = 0
				tab[ "$pp_colour_brightness" ] = 0
				tab[ "$pp_colour_contrast" ] = math.Clamp(1-((1/120)*(timepassed-10))*1.1,0,1)
				tab[ "$pp_colour_colour" ] = math.Clamp(1+((timepassed/217)*-8),0,1)
				tab[ "$pp_colour_mulr" ] = 0
				tab[ "$pp_colour_mulg" ] = 0
				tab[ "$pp_colousr_mulb" ] = 0 
				DrawColorModify( tab )			
				-- End
		
				local tex = surface.GetTextureID("hud/infection")
				surface.SetTexture(tex)
				surface.SetDrawColor( 255, 255, 255,(timepassed/255)*255 )
				surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
				
				DrawMotionBlur( 0.09, (  (1/137)*timepassed     ), 0)

				
				if timepassed>=207 then

					timepassed=nil
					hook.Remove("RenderScreenspaceEffects", "T-Virus_Phase_2")
				end
						
						
			end )
		end
	end
	
	EventHandler(Events(seconds))
	
	
	

	
	
end )