local function Autospawn_Timer()
	local recent = false

	local function Autospawn()

		local map_bounds = getMapBounds()
		local map_skybox = getMapSkyBox()
		local map_center = getMapCenterPos()
		local map_floorcenter = getMapCenterFloorPos()

		local SkyPos = Vector(math.random(map_bounds[1].x,map_bounds[2].x),  math.random(map_bounds[1].y,map_bounds[2].y),  map_skybox[2].z)

		local tr = util.TraceLine({
			start = SkyPos,
			endpos = SkyPos - Vector(0,0,50000),
			mask = MASK_SOLID_BRUSHONLY
		})

		local FloorPos = tr.HitPos
		local FloodPos = map_floorcenter
		local CenterPos = map_center


		if GetConVar("gdisasters_autospawn_type"):GetString() == "Tornado" then
			recent = true
			local tornado = {
				"gd_d2_gustnado",
				"gd_d3_ef0", 
				"gd_d4_ef1",
				"gd_d4_landspout",
				"gd_d4_icenado",  
				"gd_d5_ef2", 
				"gd_d5_alien_tornado",
				"gd_d6_ef3", 
				"gd_d6_evolvingtornado",
				"gd_d7_ef4", 
				"gd_d7_ef4_small", 
				"gd_d8_ef5", 
				"gd_d8_ef5_small", 
				"gd_d9_ef6", 
				"gd_d10_ef7"
			}

			local EF = ents.Create(table.Random(tornado))
			if EF==nil then return end

			EF:Spawn()
			EF:SetPos(SkyPos)
			EF:Activate()

			for k, ply in pairs(player.GetAll()) do
				if GetConVar("gdisasters_autospawn_chat"):GetInt() <= 0 then return end
				ply:PrintMessage(HUD_PRINTTALK,"the disaster that is happening now: " .. EF.PrintName )
			end

		elseif GetConVar("gdisasters_autospawn_type"):GetString() == "Disasters" then
			recent = true
			local disasters = {}

			local function TableAdd()
				local files, directory = file.Find("entities/gd_d*.lua", "LUA")

				for k, v in ipairs(files) do
					local file = v:match("(.+)%..+$")
					table.insert(disasters, file)
				end
			end
			TableAdd()

			local dis = ents.Create(table.Random(disasters))
			if dis==nil then return end

			for k, v in pairs(ents.FindByClass("gd_d*")) do
				
				dis:SetPos(FloorPos)

			end
			for k, v in pairs(ents.FindByClass("env_tornado")) do

				dis:SetPos(SkyPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_ef*")) do

				dis:SetPos(SkyPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_*spout")) do

				dis:SetPos(SkyPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_*nado")) do

				dis:SetPos(SkyPos)

			end
			for k, v in pairs(ents.FindByClass("env_dynamicwater")) do

				dis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("env_dynamicwater_b")) do

				dis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("env_dynamiclava")) do

				dis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("env_dynamiclava_b")) do

				dis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_*tsunami")) do

				dis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_tsunami")) do

				dis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_*flood")) do

				dis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_flood")) do

				dis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_*hole")) do

				dis:SetPos(CenterPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_neutron_star")) do
				
				dis:SetPos(CenterPos)

			end

			dis:Spawn()
			dis:Activate()

			for k, ply in pairs(player.GetAll()) do
				if GetConVar("gdisasters_autospawn_chat"):GetInt() <= 0 then return end
				ply:PrintMessage(HUD_PRINTTALK,"the disaster that is happening now: " .. dis.PrintName .. ", Position: " .. tostring(dis:GetPos()) )
			end

			timer.Simple(GetConVar( "gdisasters_autospawn_remove_timer" ):GetInt(), function()
				if dis:IsValid() then dis:Remove() end
			end)
		
		elseif GetConVar("gdisasters_autospawn_type"):GetString() == "Weather" then
			recent = true
			local weather = {}

			local function TableAdd()
				local files, directory = file.Find("entities/gd_w*.lua", "LUA")

				for k, v in ipairs(files) do
					local file = v:match("(.+)%..+$")
					table.insert(weather, file)
				end
			end
			TableAdd()

			local wea = ents.Create(table.Random(weather))
			if wea==nil then return end

			wea:Spawn()
			wea:SetPos(SkyPos)
			wea:Activate()

			for k, ply in pairs(player.GetAll()) do
				if GetConVar("gdisasters_autospawn_chat"):GetInt() <= 0 then return end
				ply:PrintMessage(HUD_PRINTTALK,"the weather that is happening now: " .. wea.PrintName .. ", Position: " .. tostring(wea:GetPos()) )
			end

			timer.Simple(GetConVar( "gdisasters_autospawn_remove_timer" ):GetInt(), function()
				if wea:IsValid() then wea:Remove() end
			end)

		elseif GetConVar("gdisasters_autospawn_type"):GetString() == "Weather/Disasters" then
			recent = true
			local weadisas = {}

			local function TableAdd()
				local files, directory = file.Find("entities/gd_d*.lua", "LUA")
				local files2, directory2 = file.Find("entities/gd_w*.lua", "LUA")

				for k, v in ipairs(files) do
					local file = v:match("(.+)%..+$")
					table.insert(weadisas, file)
				end
				for k, v in ipairs(files2) do
					local file = v:match("(.+)%..+$")
					table.insert(weadisas, file)
				end
			end
			TableAdd()
			

			local weadis = ents.Create(table.Random(weadisas))
			if weadis==nil then return end

			for k, v in pairs(ents.FindByClass("gd_d*")) do

				weadis:SetPos(FloorPos)

			end
			for k, v in pairs(ents.FindByClass("gd_w*")) do
				
				weadis:SetPos(SkyPos)

			end
			for k, v in pairs(ents.FindByClass("env_tornado")) do

				weadis:SetPos(SkyPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_ef*")) do

				weadis:SetPos(SkyPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_*spout")) do

				weadis:SetPos(SkyPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_*nado")) do

				weadis:SetPos(SkyPos)

			end
			for k, v in pairs(ents.FindByClass("env_dynamicwater")) do

				weadis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("env_dynamicwater_b")) do

				weadis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("env_dynamiclava")) do

				weadis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("env_dynamiclava_b")) do

				weadis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_*tsunami")) do

				weadis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_tsunami")) do

				weadis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_*flood")) do

				weadis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_flood")) do

				weadis:SetPos(FloodPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_*hole")) do

				weadis:SetPos(CenterPos)

			end
			for k, v in pairs(ents.FindByClass("gd_d*_neutron_star")) do

				weadis:SetPos(CenterPos)

			end


			weadis:Spawn()
			weadis:Activate()

			for k, ply in pairs(player.GetAll()) do
				if GetConVar("gdisasters_autospawn_chat"):GetInt() <= 0 then return end
				ply:PrintMessage(HUD_PRINTTALK,"the weather or disaster that is happening now: " .. weadis.PrintName .. ", Position: " .. tostring(weadis:GetPos()))
			end

			timer.Simple(GetConVar( "gdisasters_autospawn_remove_timer" ):GetInt(), function()
				if weadis:IsValid() then weadis:Remove() end
			end)
		end
	end

	timer.Create( "Autospawn_Timer", GetConVar( "gdisasters_autospawn_spawn_timer" ):GetInt(), 0, function()
		if GetConVar("gdisasters_autospawn_enable"):GetInt() >= 1 then 
			if IsMapRegistered() == true then 
				if math.random(0,GetConVar( "gdisasters_autospawn_spawn_chance" ):GetInt()) == GetConVar( "gdisasters_autospawn_spawn_chance" ):GetInt() then
					if recent then recent = false return end
					Autospawn()
				end
			else
				gDisasters:Warning("This map is incompatible with this addon! Tell the addon owner about this as soon as possible and change to gm_flatgrass or construct.", true) 
				return 
			end
		end
	end
	)

end
hook.Add( "Initialize", "gDisasters_Autospawn", Autospawn_Timer)
Autospawn_Timer()

local function Removemaptornados()
	if GetConVar('gdisasters_autospawn_getridmaptor'):GetInt() == 1 then
		for k, v in pairs(ents.FindByClass("func_tracktrain", "func_tanktrain")) do
			v:Remove()
		end
		print("Removed all map tornados!!")
	end
end

hook.Add("InitPostEntity","gdisastersRemovemaptornados",function()
	Removemaptornados()
end)

hook.Add("PostCleanupMap","gdisastersReRemovemaptornados",function()
	Removemaptornados()
end)