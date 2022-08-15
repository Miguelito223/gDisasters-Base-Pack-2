CreateClientConVar( "gdisasters_autospawn_skybox", "0", true, false )

if GetConVar("gdisasters_autospawn_skybox"):GetInt() == 1 then
if not string.find(game.GetMap(), "night") then
	local skyscale = 16
	local fogstart = 0
	local fogend = 0
	hook.Add("SetupSkyboxFog","GDAutospawnGetSkyboxScale",function(scale)
		skyscale = 1/scale
		hook.Remove("SetupSkyboxFog","GDAutospawnGetSkyboxScale")
	end)
	hook.Add("SetupWorldFog","GDAutospawnMapFogGetter",function()
		fogstart,fogend = render.GetFogDistances()
		hook.Remove("SetupWorldFog","GDAutospawnMapFogGetter")
		return true
	end)
	hook.Add("SetupWorldFog","GDAutospawnMapFogOverrider",function()
		if fogstart == 0 and fogend == 0 then return end
		render.FogMode(1)
		render.FogColor(127,127,127)
		render.FogStart(fogstart*skyscale)
		render.FogEnd(fogend*skyscale)
		return true
	end)
	local ang = Angle(0,0,0)
	local vec_0_0_0 = Vector(0,0,0)
	local vec_0_0_n512 = Vector(0,0,-512)
	local vec_n512_n512_0 = Vector(-512,-512,0)
	local vec_512_512_0 = Vector(512,512,0)
	local vec_0_0_512 = Vector(0,0,512)
	local vec_0_n512_0 = Vector(0,-512,0)
	local vec_n512_0_n512 = Vector(-512,0,-512)
	local vec_0_512_0 = Vector(0,512,0)
	local vec_512_0_512 = Vector(512,0,512)
	local vec_512_0_0 = Vector(512,0,0)
	local vec_0_512_512 = Vector(0,512,512)
	local vec_0_n512_n512 = Vector(0,-512,-512)
	local vec_n512_0_0 = Vector(-512,0,0)
	hook.Add("PostDraw2DSkyBox","GDAutospawnSkyboxOverrider",function() -- Rendering space
		local fogmode = render.GetFogMode() -- If there's fog, save it
		render.FogColor(127,127,127)
		local fogcolorR,FogColorG,FogColorB = render.GetFogColor()
		local fogcolorC = Color(fogcolorR,FogColorG,FogColorB)
		render.OverrideDepthEnable(true,false)
		
		cam.Start3D(vec_0_0_0,RenderAngles()) -- Render space!
			render.FogMode(0) -- Turn off fog
			render.SetColorMaterial() -- Set the texture
			render.DrawBox(vec_0_0_n512,ang,vec_n512_n512_0,vec_512_512_0,fogcolorC,0)
			render.DrawBox(vec_0_0_512,ang,vec_512_512_0,vec_n512_n512_0,fogcolorC,0)
			render.DrawBox(vec_0_n512_0,ang,vec_n512_0_n512,vec_512_0_512,fogcolorC,0)
			render.DrawBox(vec_0_512_0,ang,vec_512_0_512,vec_n512_0_n512,fogcolorC,0)
			render.DrawBox(vec_512_0_0,ang,vec_0_512_512,vec_0_n512_n512,fogcolorC,0)
			render.DrawBox(vec_n512_0_0,ang,vec_0_n512_n512,vec_0_512_512,fogcolorC,0)
			render.FogMode(fogmode)
		cam.End3D()
		
		render.OverrideDepthEnable(false,false)
	end)
end
end