gDisasters.VolumetricCloud = {}

gDisasters.VolumetricCloud.cloud_rts = {}
gDisasters.VolumetricCloud.cloud_mats = {}

gDisasters.VolumetricCloud.cloud_layer = 30

-- Coroutine for generating the cloud textures
gDisasters.VolumetricCloud.CloudCoro = coroutine.create(function()
    for i = 1, gDisasters.VolumetricCloud.cloud_layer do
        gDisasters.VolumetricCloud.cloud_rts[i] = GetRenderTarget("gdisasters_volumetric_clouds" .. i, 512, 512)
        gDisasters.VolumetricCloud.cloud_mats[i] = CreateMaterial("gdisasters_volumetric_clouds" .. i, "UnlitGeneric", {
            ["$basetexture"] = gDisasters.VolumetricCloud.cloud_rts[i]:GetName(),
            ["$model"] = "1",
            ["$nocull"] = "1",
            ["$translucent"] = "1",
        })
        render.ClearRenderTarget(gDisasters.VolumetricCloud.cloud_rts[i], Color(127, 127, 127, 0)) -- make gray so clouds have nice gray sides
    end

    for y = 0, 511 do
        for i = 1, gDisasters.VolumetricCloud.cloud_layer do
            render.PushRenderTarget(gDisasters.VolumetricCloud.cloud_rts[i])
            cam.Start2D()
                for x = 0, 511 do
                    local x1 = x -- % (512 / 2) -- loop clouds in grid of 2x2 (since res is 512)
                    local y1 = y -- % (512 / 2)

                    local col = (Noise.simplex3D(x1 / 30, y1 / 30, i / 50) - i * 0.015) * 1024 + (Noise.simplex2D(x1 / 7, y1 / 7) + 1) * 128

                    surface.SetDrawColor(255, 255, 255, col)
                    surface.DrawRect(x, y, 1, 1)
                end
            cam.End2D()
            render.PopRenderTarget()
        end

        coroutine.yield()
    end
end)

-- Function to render the volumetric clouds
gDisasters.VolumetricCloud.gDisastersVolumetricCloud = function(_, sky)
    if GetConVar("gdisasters_volumetric_clouds_enabled"):GetInt() < 1 then return end
    if sky then return end -- don't render in skybox

    if coroutine.status(gDisasters.VolumetricCloud.CloudCoro) == "suspended" then
        coroutine.resume(gDisasters.VolumetricCloud.CloudCoro)
    end

    for i = 1, gDisasters.VolumetricCloud.cloud_layer do
        render.SetMaterial(gDisasters.VolumetricCloud.cloud_mats[i])
        render.DrawQuadEasy(Vector(0, 0, (i - 1) * 50), Vector(0, 0, 1), 200000, 200000)
    end
end

hook.Add("PreDrawTranslucentRenderables", "gdisasters_volumetric_clouds", gDisasters.VolumetricCloud.gDisastersVolumetricCloud)
