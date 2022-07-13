AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Doppler Radar"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.RenderGroup = RENDERGROUP_BOTH


cloud_intensity_to_weather_ent = {

	["gd_w1_lightrain"] = 0.25,
	["gd_w1_aurora"] = 0,
	["gd_w1_catonehurricane"] = 0.4,
	["gd_w2_cattwohurricane"] = 0.6,
	["gd_w3_cattheehurricane"] = 0.7,
	["gd_w4_catfourhurricane"] = 0.8,
	["gd_w5_catfivehurricane"] = 0.9,
	["gd_w6_catsixhurricane"] = 1,
	["env_tornado"] = 0.5,
	["gd_w1_sandstorm"] = 0.8,
	["gd_w1_duststorm"] = 1,
	
	["gd_w1_heavyfog"] = 0.3,
	["gd_w2_heavyrain"] = 0.7,
	
	["gd_w1_snow"] = 0.6,
	["gd_w1_sunny"] = 0,
	
	["gd_w1_cldy_irid"] = 0.5,
	["gd_w1_sleet"] = 0.5,
	
	["gd_w1_smog"] = 0.4, 
	
	["gd_w1_cumu_cldy"] = 0.25, 
	["gd_w1_tropicalstorm"] = 0, 
	
	["gd_w2_heavysnow"] = 0.5, 
	["gd_w3_extremeheavyrain"] = 0.8,
	
	["gd_w2_acidrain"] = 0.5, 
	["gd_w2_modbreeze"] = 0,

	["gd_w2_heatwave"] = 0.2,
	["gd_w3_blizzard"] = 0.8,
	["gd_w3_icestorm"] = 0.8, 
	["gd_w3_heatburst"] = 1,
	["gd_w2_coldwave"] = 0.1,
	["gd_w3_hailstorm"] = 0.9,
	["gd_w2_thunderstorm"] = 0.9, 
	["gd_w3_strongbreeze"] = 0,
	["gd_w2_shelfcloud"] = 1,
	["gd_w4_intensebreeze"] = 0, 
	["gd_w6_downburst"] = 1,
	["gd_w6_solarray"] = 0.5, 



}

function ENT:Use()
	if CurTime() >= self.NextUseTime then 
		self.IsOn = !self.IsOn 
		self:SetNWBool("IsOn", self.IsOn)
		
		if self.IsOn == false then 
			self:EmitSound("buttons/button10.wav", 60, 100, 1)
		
		
		elseif self.IsOn == true then 
			self:EmitSound("buttons/button1.wav", 60, 100, 1)
		
		end
		self.NextUseTime = CurTime() + 1
	end

end

function ENT:IsThisShitOn()

	return self:GetNWBool("IsOn", false)
end

function ENT:ShouldNotRender()	
	return not(self:IsThisShitOn()) or (self:GetPos():Distance(LocalPlayer():GetPos()) >= GetConVar("gdisasters_graphics_dr_maxrenderdistance"):GetInt())
end



function ENT:Initialize()	

	self:PreCachePixels()

	
	
	if (CLIENT) then 
		
		self.NextDisplayUpdateTime  = CurTime()	
		self.NextDisplayRefreshTime = CurTime()
	
		self.StartTime             = CurTime()
		self.ScreenMaterial        = Material("models/gd_weather_radar")
		self.RenderTarget          = GetRenderTarget("RadarRT", 512, 512, false)
		self.texture = GetRenderTarget('wradarframe'..os.time(), 512, 512, false)
		self.mat = CreateMaterial("wradarframe"..os.time(),"UnlitGeneric",{
			["$basetexture"] = self.texture,
			["$model"]       = 1,
		});
		
		self.PosOffset = Vector(0,0,0)
	
		
	end
	
	if (SERVER) then
		
		self:SetModel("models/props_lab/monitor01b.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		
		local phys = self:GetPhysicsObject()

		
		if (phys:IsValid()) then
			phys:SetMass(25)
			phys:Wake()
			phys:EnableMotion(true)
		end 		

		self.NextUseTime            = CurTime()
		self.IsOn                  = false 
		
		
		
	end
end



function ENT:AddGlobalClouds() 

	local function ReturnIntensity()
		local i = 0
		local t1, t2 = ents.FindByClass("gd_w*"), ents.FindByClass("env_*")
		
		local function mergethem(x,y)
			for index, item in pairs(y) do 
				table.insert(t1, item )
			end
		end
		
		mergethem(t1,t2)
		
		for k, v in pairs(t1)  do
			
			
			local ni = cloud_intensity_to_weather_ent[v:GetClass()] or 0 
		
			if ni != 0 then end 
			if ni > i then 
				i = ni
			end
			
			
		end
		
		return i 
		
	
	end
	
	local resolution = self.Display.resolution 
	local cloud_intensity = ReturnIntensity()	
	
	local res   = FetchConVarResolution()
	local scale = 128/res 
	local bias  = 1

	self.PosOffset = self.PosOffset

	for k, _ in pairs(self.Pixels) do 
		local x, y   = (k%resolution[1]) * scale, math.floor(k/resolution[2]) * scale
				
		local i1    = (Noise.perlin3D( x * 0.05 + self.PosOffset[1], y * 0.05 + self.PosOffset[2], CurTime() * 0.05)  * cloud_intensity)^bias 
	
		if i1 <= math.Clamp(cloud_intensity / 2.5,0.1,0.2) then i1 = 0  end
		
		

		
		self.Pixels[k].intensity = math.Clamp(BlendValues(self.Pixels[k].intensity,i1 , "Add") ,0,1) 

	end

	
end

function ENT:Noise(noise_chance, intensity, blendingmode) 
	for k, v in pairs(self.Pixels) do 
		
		if math.random() < noise_chance then 
			self.Pixels[k].intensity = math.Clamp( BlendValues(self.Pixels[k].intensity , intensity, blendingmode),0,1)
		end
	
	end

end

function ENT:SetScreenwideIntensity(intensity) 
	for k, v in pairs(self.Pixels) do 
		self.Pixels[k].intensity = math.Clamp(intensity,0,1)
	end
end 

function ENT:ClearScreen()

	self:SetScreenwideIntensity(0)
	self:AddGlobalClouds() 
end


function ENT:AddPixelIntensityInRadius(ox,oy,radius, intensity, noise, falloff_exponent, blendingmode, cx, cy)
	
	local res   = FetchConVarResolution()
	local scale = res/48 

	ox, oy, radius = math.Round( ((ox-cx) * scale)+ cx ), math.Round( ((oy-cy) * scale)+ cy ), math.Round(radius * scale)
	

	
	
	local resolution = self.Display.resolution 
	local pixels    = {}
	local maxpixels = 0 

	if( (radius * 2) % 2 == 0 ) then
		maxpixels = math.ceil(radius - 0.5) * 2 + 1
	else 
		maxpixels = math.ceil(radius) * 2
	end 

	
	for y = -maxpixels / 2 + 1, maxpixels / 2 - 1 do 
		for x = -maxpixels / 2 + 1, maxpixels / 2 - 1 do 
		
		
			local offset     = ( math.Round((y+oy)) * (resolution[1])) + math.Round(x+ox) 
			
			if not(self.Pixels[offset]) or (x^2+y^2>radius^2) then 
			
			else
				if math.random() < noise then 
					
					self.Pixels[offset].intensity = math.Clamp( BlendValues(self.Pixels[offset].intensity, intensity * (1 - ((math.sqrt( x^2 + y^2 )/radius)^falloff_exponent)), blendingmode),0,1)
					table.insert(pixels, offset)
					
				end
			end
			
			
		end
	end
	
	return pixels

end





function ENT:UpdateDisplay()
	if not(CurTime() >= self.NextDisplayUpdateTime) then return end 
	self:ClearScreen()
	self:CheckForChangeInResolution()
	
	self.NextDisplayUpdateTime = CurTime() + ((1 / GetConVar("gdisasters_graphics_dr_updaterate"):GetFloat() ) or 1)
	
	local res        = self.Display.resolution
	
	
	
	local function ConvertVectorToScreenSpace(vector)
		local map_bounds = getMapBounds()
		local map_center = Vec2D( (map_bounds[1]+map_bounds[2]) * 0.5)
		local new_vec    = vector + Vector(16384, 16384,0)
		
		
		return { ( new_vec.x/32768)*res[1],(new_vec.y/32768)*res[2]}

	end
	
	local function GenerateHeatMapForTornado(x,y)
		
		
		local cx, cy = (8*x+1)/8  , (8*y-15)/8 
	
				
		self:AddPixelIntensityInRadius(x,y,6,0.4,0.95,1, "Add", cx, cy) -- tornado center x y radius intensity noise exponent
		
		
		self:AddPixelIntensityInRadius(x+5,y-2,6,0.4,0.97,1, "Add", cx, cy) -- echo hook
		self:AddPixelIntensityInRadius(x+6,y-8,6,0.4,0.96,1, "Add", cx, cy) -- echo hook
		self:AddPixelIntensityInRadius(x+5,y-12,6,0.4,0.95,1, "Add", cx, cy) -- echo hook
		
		self:AddPixelIntensityInRadius(x,y-20,13,0.4,0.95,1, "Add", cx, cy) -- echo hook
		self:AddPixelIntensityInRadius(x-15,y-30,15,0.4,0.96,1, "Add", cx, cy) -- echo hook
		
		self:AddPixelIntensityInRadius(x-15,y-10,5,0.4,0.9,1, "Add", cx, cy) -- clouds
		self:AddPixelIntensityInRadius(x+15,y-10,15,0.4,0.9,1, "Add", cx, cy) -- clouds
		
		
	end

	local function UpdateForTornado()
		local targets = ents.FindByClass("env_tornado")
		
		for k, v in pairs(targets) do 
			local pos = ConvertVectorToScreenSpace(v:GetPos() * Vector(-1,1,1))

			
			GenerateHeatMapForTornado(pos[1], pos[2])
		
		end
		
	
		
	end

	local function UpdateForWeather()
	
	end
	
	UpdateForTornado()

end

function gDisasters.RenderRadarPixels(self)
	
	if not(self.Pixels) or self:ShouldNotRender() then return end 

	
	local ang   = self:GetAngles() 
	ang:RotateAroundAxis( self:GetForward(), 255 )
	local pos   = self:GetPos() + self:GetForward() * 6.50 + self:GetUp() * 4.9 + self:GetRight() * -3.3
	
	local size        = self.Display.size 
	local aspect      = self.Display.aspect
	local resolution  = self.Display.resolution 
	
	local pixel_pos   = {size[1]/(resolution[1]) ,size[2]/(resolution[2])}
	local pixel_size  = {pixel_pos[1] * aspect[1] * size[1],pixel_pos[2] * aspect[2]* size[2]}

	
	if (CurTime() >= self.NextDisplayRefreshTime)  then 
	
		self.NextDisplayRefreshTime = self.NextDisplayRefreshTime + ((1 / GetConVar("gdisasters_graphics_dr_refreshrate"):GetFloat() ) or 1)
		
		local monochromatic_mode = GetConVar("gdisasters_graphics_dr_monochromatic"):GetString()=="true"
		

		
		local minimum_res = 512
		local scale       = minimum_res/resolution[1]
		local w, h        = ScrW(), ScrH()
		
		render.PushRenderTarget(self.texture)
		
		render.SetViewPort( 0, 0, minimum_res, minimum_res )
		render.Clear( 0, 0, 0, 255, false, true )
		cam.Start2D()
			for k, v in pairs(self.Pixels) do 
				
				local x, y = (k%resolution[1]), math.floor(k/resolution[2])	
				local color = self:Gradient(v.intensity, true)
				
				if monochromatic_mode then 
					local r, g, b = color.r, color.g, color.b 
					local mean    = ( r + g + b ) / 3 
					color          = Color(mean, mean, mean)
				end
				
				surface.SetDrawColor( color )	
				surface.DrawRect( x *scale,y* scale, pixel_size[1]* scale,pixel_size[2]* scale )
				
			end	
		cam.End2D()
		render.SetViewPort( 0,0, w, h)

		render.PopRenderTarget()
		
		self.mat:SetTexture("$basetexture", self.texture)
		
		
	
	
	

		
	else
		
	
		cam.Start3D()
	
	
		--local alpha = math.Clamp(self:GetPos():Distance(LocalPlayer():GetPos()) / GetConVar("gdisasters_graphics_dr_maxrenderdistance"):GetInt(),0, GetConVar("gdisasters_graphics_dr_maxrenderdistance"):GetInt()) ^ 0.5  setblend doesn't work
		
		
		local function DrawBackground()
			draw.RoundedBox( 0, 0, 0, size[1] , size[2] , color_black)
		end
	
		
		local function DrawTexture() 
		
			
			
			local v1, v2, v3, v4 = pos, pos + self:GetUp() * -size[2] , pos + self:GetRight() * size[1] + self:GetUp() * -size[2], pos + self:GetRight() * size[1]
			render.SetMaterial( self.mat )
			render.DrawQuad( v4 , v1 , v2 , v3 , color_black )
			

			
		end
	
		DrawBackground()
		
		DrawTexture()
		
		
	
		

		
		cam.End3D()
		
	
	end


	
end

hook.Add("PostDrawOpaqueRenderables", "gd_equip_wradar.draw.pixelscreen",function() 

	local radars = ents.FindByClass("gd_equip_wradar")
		
	
	local max_render_distance    = 5000
	local falloff_alpha_exponent = 0.5

	for k, v in pairs(radars) do 
		
		local dist_to_player         = LocalPlayer():GetPos():Distance(v:GetPos())
		if dist_to_player <= max_render_distance then 
	
			gDisasters.RenderRadarPixels(v)
		end
	
	end
end)


local avrg_time = {}

local function sum(t)
   local s = 0
   
   for k,v in pairs(t) do
        s = s + v
   end
   
   return s
end



function ENT:Draw()

	
	local t = SysTime()
	self:DrawModel()
	self:UpdateDisplay()
	
	if #avrg_time < 1024 then table.insert(avrg_time, SysTime()-t) else print("t ", sum(avrg_time)/1024) avrg_time = {} end
	
end

function ENT:DrawTranslucent()
	
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end


local color_gradient = 
{
	 {73,233,83},
	 {2,191,37},
	 {24,151,8},
	 {1,103,4},
	 {0,86,0},
	 {0,65,1},
	 {241,214,0},
	 {247,165,1},
	 {255,95,1},
	 {240,17,0},
	 {183,9,2},
	 {80,2,0},
	 {255,9,145},
	 {140,3,207},
	 {168,99,205}
	 
	 
}






function ENT:Gradient(alpha, interpolate)
	
	local max_color = color_gradient[math.ceil(alpha * 15)] or {0,0,0}
	local min_color = color_gradient[math.floor(alpha * 15)] or {0,0,0}
	
	local alpha_interp = alpha * 15 - ( math.floor(alpha*15))
	
	
	
	if interpolate then 
	
		local r, g, b = (1 - alpha_interp) * min_color[1] + alpha_interp * max_color[1], (1 - alpha_interp) * min_color[2] + alpha_interp * max_color[2], (1 - alpha_interp) * min_color[3] + alpha_interp * max_color[3]
		r, g, b = math.Round(r), math.Round(g), math.Round(b)
		
		return Color(r,g,b,255)

		
	else
		return Color(color_gradient[math.Round(alpha*15) + 1][1],color_gradient[math.Round(alpha*15) + 1][2],color_gradient[math.Round(alpha*15) + 1][3])
	end
	
	
end








function ENT:AddPixelIntensity(x,y,intensity)
	
	local resolution = self.Display.resolution 
	local offset     = (y * (resolution[1])) + x 
	
	if not(self.Pixels[offset]) then 
	
	else
		self.Pixels[offset].intensity = math.Clamp(self.Pixels[offset].intensity + intensity,0,1)
	end
	
end

function FetchConVarResolution()
	local cords = string.Explode("x",GetConVar("gdisasters_graphics_dr_resolution"):GetString() or "16x16")
	local mean = ( cords[1] + cords[2] ) * 0.5
	return mean
end 
	
function ENT:PreCachePixels()
	
	function SetupDisplay(data)
		
		return table.Copy(data)
		
	end

	local function CreatePixels(resolution)
	
		local pixels = {}
		
		for x=0, resolution.x - 1 do 
			for y=0, resolution.y - 1 do 
				table.insert(pixels, { xp=x, yp=y, intensity = 0})
			end
		end
	
		return pixels 
	end
	

	local xp, yp = FetchConVarResolution(), FetchConVarResolution()

	
	self.Display = SetupDisplay( {resolution = {xp,yp}, size       = {8.90, 8.90}, aspect     = {1.00, 1.00}})
	self.Pixels  = CreatePixels({x=xp,y=yp})

end

function ENT:CheckForChangeInResolution()
	if not(self.LastResolution) then self.LastResolution = self.Display.resolution.xp end 
	if self.LastResolution != FetchConVarResolution() then 
		self.LastResolution = FetchConVarResolution()
		self:PreCachePixels()
		
	else
	
	end
		
	

end


function ENT:ReturnPixelsInRadius(ox,oy,radius,noise)

	
	local resolution = self.Display.resolution 
	local pixels    = {}
	local maxpixels = 0 

	if( (radius * 2) % 2 == 0 ) then
		maxpixels = math.ceil(radius - 0.5) * 2 + 1
	else 
		maxpixels = math.ceil(radius) * 2
	end 

	
	for y = -maxpixels / 2 + 1, maxpixels / 2 - 1 do 
		for x = -maxpixels / 2 + 1, maxpixels / 2 - 1 do 
		
			local offset     = ( math.Round((y+oy)) * (resolution[1])) + math.Round(x+ox) 
			
			if not(self.Pixels[offset]) or (x^2+y^2>radius^2) then 
			
			else
				table.insert(pixels, offset)
			end
			
		
		end
	end
	
	return pixels

end
