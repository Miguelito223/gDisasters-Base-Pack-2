gDisasters.VolumetricCloud = {}

gDisasters.VolumetricCloud.cloud_rts = {}
gDisasters.VolumetricCloud.cloud_mats = {}

gDisasters.VolumetricCloud.cloud_layer = 10

gDisasters.VolumetricCloud.CloudCoro = coroutine.create(function()
	for i = 1, gDisasters.VolumetricCloud.cloud_layer do
		gDisasters.VolumetricCloud.cloud_rts[i] = GetRenderTarget("infmap_clouds" .. i, 512, 512)
		gDisasters.VolumetricCloud.cloud_mats[i] = CreateMaterial("infmap_clouds" .. i, "UnlitGeneric", {
			["$basetexture"] = gDisasters.VolumetricCloud.cloud_rts[i]:GetName(),
			["$model"] = "1",
			["$nocull"] = "1",
			["$translucent"] = "1",
		})
		render.ClearRenderTarget(gDisasters.VolumetricCloud.cloud_rts[i], Color(127, 127, 127, 0))	// make gray so clouds have nice gray sides
	end

	for y = 0, 511 do
		for i = 1, gDisasters.VolumetricCloud.cloud_layer do
			render.PushRenderTarget(gDisasters.VolumetricCloud.cloud_rts[i]) cam.Start2D()
				for x = 0, 511 do
					local x1 = x// % (512 / 2)	//loop clouds in grid of 2x2 (since res is 512)
					local y1 = y// % (512 / 2)

					local col = (Noise.simplex3D(x1 / 30, y1 / 30, i / 50) - i * 0.015) * 1024 + (Noise.simplex3D(x1 / 7, y1 / 7) + 1) * 128

					surface.SetDrawColor(255, 255, 255, col)
					surface.DrawRect(x, y, 1, 1)
				end
			cam.End2D() render.PopRenderTarget()
		end

		coroutine.yield()
	end
end)


gDisasters.VolumetricCloud.gDisastersVolumetricCloud = function(_, sky)
    if sky then return end	// dont render in skybox
	local offset = LocalPlayer():GetViewOffset()	// copy vector, dont use original memory
	offset[1] = ((offset[1] + 250 + CurTime() * 0.1) % 500) - 250
	offset[2] = ((offset[2] + 250 + CurTime() * 0.1) % 500) - 250
	offset[3] = offset[3] - 10

	if coroutine.status(gDisasters.VolumetricCloud.CloudCoro) == "suspended" then
		coroutine.resume(gDisasters.VolumetricCloud.CloudCoro)
	end

	// render cloud planes
	if offset[3] > 1 then
		for i = 1, gDisasters.VolumetricCloud.cloud_layer do	// overlay 10 planes to give amazing 3d look
			render.SetMaterial(gDisasters.VolumetricCloud.cloud_mats[i])
			render.DrawQuadEasy((unlocalize_vector(Vector(0, 0, (i - 1) * 10000), -offset)), Vector(0, 0, 1), 20000000, 20000000)
		end
	else
		for i = gDisasters.VolumetricCloud.cloud_layer, 1, -1 do	// do same thing but render in reverse since we are under clouds
			render.SetMaterial(gDisasters.VolumetricCloud.cloud_mats[i])
			render.DrawQuadEasy(unlocalize_vector(Vector(0, 0, (i - 1) * 10000), -offset), Vector(0, 0, 1), 20000000, 20000000)
		end
	end
end

hook.Add("PreDrawTranslucentRenderables", "gdisasters_volumetric_clouds", gDisasters.VolumetricCloud.gDisastersVolumetricCloud)