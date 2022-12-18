AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Tsunami Lava"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"
ENT.Data                             = {}
ENT.WedgeSound                       = "streams/disasters/tsunami/idle.wav"
ENT.WedgeSound2                       = "streams/disasters/nature/volcano_idle.wav"

function ENT:Initialize()	

	self:SetupMiscVarsLava()
	if (CLIENT) then 

		if LocalPlayer().Sounds == nil then LocalPlayer().Sounds = {} end
		
		LocalPlayer().Sounds["Tsunamilava"]         = createLoopedSound(LocalPlayer(), self.WedgeSound)
		LocalPlayer().Sounds["lava"]         = createLoopedSound(LocalPlayer(), self.WedgeSound2)
		
		
	end
	if (SERVER) then
		
		self:SetModel(self.Model)

		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		
		self.NextPhysicsTime = CurTime()

		if IsMapRegistered()==false then self:Remove() end 
	
	end
end

function ENT:CreateLoop()


	local sound = Sound(self.WedgeSound)

	CSPatch = CreateSound(self, sound)
	CSPatch:SetSoundLevel( 100 )
	CSPatch:Play()
	CSPatch:ChangeVolume( 1 )

	self.Sound = CSPatch
	
end

function ENT:SetupMiscVarsLava()


	local bounds      = getMapSkyBox()
	local minp        = bounds[1]
	local maxp        = bounds[2]
	
	
	
	self.StartTime 		          = CurTime()
	self.CurrentDistanceTravelled = 1 
	self.CurrentHeight            = self.Data.StartHeight 
	self.CurrentWedge             = self.Data.StartWedge

	
	self.MaxDistance       = math.max(maxp.x, minp.x) - math.min(maxp.x, minp.x)
	self.Speed             = self.Data.Speed 
	
	
	if (SERVER) then 
		self.OriginalSpeed = self.Speed 
		
		self:SetNWFloat("Speed", self.Speed)
		self:SetNWFloat("CurrentHeight", self.CurrentHeight)
		self:SetNWFloat("CurrentWedge", self.CurrentWedge)
		
		self.NextErrorCheck = CurTime() 
	
	end 
	
	
	self:RebuildlavaVertices(self.CurrentDistanceTravelled, self:GetNWFloat("CurrentHeight"), self:GetNWFloat("CurrentWedge"))
	
end


function ENT:UpdateNetworkedVariablesLava()

	self:SetNWFloat("Speed", self.Speed)
	self:SetNWFloat("CurrentHeight", self.CurrentHeight)
	self:SetNWFloat("CurrentWedge", self.CurrentWedge)

	
	
end

if (SERVER) then 

	util.AddNetworkString("env_dynamiclava_b_errorcheck")

end 


net.Receive("env_dynamiclava_b_errorcheck", function()
	
	local CurrentDistanceTravelled = net.ReadFloat()
	local ent = ents.FindByClass("env_dynamiclava_b")[1] 
	ent.CurrentDistanceTravelled = CurrentDistanceTravelled
	



end)


function ENT:ErrorChecklava()

	if CurTime() >= self.NextErrorCheck then
	
		self.NextErrorCheck = CurTime() + 1 
		
		net.Start("env_dynamiclava_b_errorcheck")
		net.WriteFloat(self.CurrentDistanceTravelled)
		net.Broadcast()
		
	end
	
	
 
end
function ENT:Expandlava()
	if (CLIENT) then 
		
		if	LocalPlayer().Sounds["Tsunamilava"]!=nil then
			local pos    = LocalPlayer():GetPos()
			local alpha = 1 - math.Clamp( (math.abs(LocalPlayer():GetPos().x - self.Verts.wave_front[1].x) / 5000),0,1)
			LocalPlayer().Sounds["Tsunamilava"]:ChangeVolume( alpha,0,1)
			
			if HitChance(10) then 
			
			util.ScreenShake( Vector(self.Verts.wave_front[1].x, pos.y, pos.z), 0.2 *alpha , 0.5, math.random(), 1000 )
			
			end 
			
			
		end
		if FrameTime() != 0 then 
		
			local speed    = self:GetNWFloat("Speed") * FrameTime() 

			self:SetDistanceTravelled(self.CurrentDistanceTravelled + speed)
			self.CurrentDistanceTravelled = self.CurrentDistanceTravelled + speed  
	
		end
	else
	
		local speed    = self:GetNWFloat("Speed") * engine.TickInterval()
		local curdist  = self.CurrentDistanceTravelled
	
		self:SetDistanceTravelled(self.CurrentDistanceTravelled + speed)
		self.CurrentDistanceTravelled = self.CurrentDistanceTravelled + speed  

		
	end

end


function ENT:SetDistanceTravelled(float)

	
	self:RebuildlavaVertices(float, self:GetNWFloat("CurrentHeight"), self:GetNWFloat("CurrentWedge"))

end

function ENT:ProcessEntitiesInLava()

	--[[
		self.Verts = {
		wave_front = {floor_v5 , floor_v6 , floor_v4 + Vector(0,0,height), floor_v3 + Vector(0,0,height)},
		wave_top   = {floor_v1 + Vector(0,0,height), floor_v2 + Vector(0,0,height), floor_v4 + Vector(0,0,height), floor_v3 + Vector(0,0,height)}
	
	}
	]]
	
	local scalar = GetPhysicsMultiplier()
	
	
	local sim_quality     = GetConVar( "gdisasters_envdynamicwater_simquality" ):GetFloat() --  original water simulation is based on a value of 0.01 ( which is alright but not for big servers ) 
	local sim_quality_mod = sim_quality / 0.01
	
	local overall_mod     = sim_quality_mod * scalar 
	local wr   = 0.999               
	

	local verts = 	self.Verts 
	local minz      = getMapCenterFloorPos().z
	local zrange    = self.CurrentHeight 
	local zmax      = minz + zrange 

	
	local max_y, min_y = math.max(verts.wave_top[1].y, verts.wave_top[2].y),  math.min(verts.wave_top[1].y, verts.wave_top[2].y)
	local max_x, min_x = math.max(verts.wave_top[1].x, verts.wave_top[3].x),  math.min(verts.wave_top[1].x, verts.wave_top[3].x)
	

	for k, v in pairs(ents.GetAll()) do 
		
		if self:IsValid() then
		
		local phys   = v:GetPhysicsObject()
		local vclass = v:GetClass()
		
		if phys:IsValid() and (vclass != "phys_constraintsystem" and vclass != "phys_constraint"  and vclass != "logic_collision_pair" and vclass != "entityflame") then
			
			local vpos = v:GetPos()
		
			if (vpos.x <= max_x and vpos.x >= min_x) and (vpos.y <= max_y and vpos.y >= min_y) and (vpos.z <= (zrange + minz) and vpos.z >= minz) then 
	
				
				local diff = (minz + zrange)-vpos.z 
		
				if v:IsPlayer() then
				
					local eye = v:EyePos()	
					if eye.z >= minz and eye.z <= zmax then
						v:SetNWBool("IsUnderlava", true)		
						v:SetNWFloat("ZlavaDepth",  math.Round(diff))
						
						--v:SetMoveType(MOVETYPE_WALK)
						
					end 
					
					

			
				end
		
		
		
				if (vpos.z >= minz and vpos.z <= zmax) and v.IsInlava!=true then
					v.IsInlava = true 
					
					self:OnLavaEntry(v)
				
					
				end
				
				
				--[[ 
					Purpose:
					
					Apply physics for players, npcs and other entities 
				--]]
				
			
					
				if v.IsInlava and v:IsPlayer() and self:IsValid() then
					
					v:SetVelocity( v:GetVelocity() * -0.9)
					v:Ignite(15)
					v:TakeDamage(10, self, self)

				elseif v.IsInlava and v:IsNPC() or v:IsNextBot() then
					v:SetVelocity( (v:GetVelocity() * -0.9) - (v:GetVelocity() * 0.05) - Vector(40,0,0))
					v:Ignite(15)
					v:TakeDamage(10, self, self)
				else
					if v.IsInlava then
						
						phys:SetVelocity( phys:GetVelocity() * 0.01)
						v:Ignite(15)
						
						
					end
				end	
	
			else 
				
	
				if v.IsInlava==true then
					v.IsInlava = false
					self:OnLavaExit(v)

				end
			
			end	
		end

		end
		
	end
	
end

local ignore_ents ={
["phys_constraintsystem"]=true,
["phys_constraint"]=true,
["logic_collision_pair"]=true,
["entityflame"]=true,
["worldspawn"]=true
}

function ENT:ProcessEntitiesInWedgeLava()

	--[[
		self.Verts = {
		wave_front = {floor_v5 , floor_v6 , floor_v4 + Vector(0,0,height), floor_v3 + Vector(0,0,height)},
		wave_top   = {floor_v1 + Vector(0,0,height), floor_v2 + Vector(0,0,height), floor_v4 + Vector(0,0,height), floor_v3 + Vector(0,0,height)}
	
	}
	]]
	
	local scalar = (66/ ( 1/engine.TickInterval()))
	
	local sim_quality     = GetConVar( "gdisasters_envdynamicwater_simquality" ):GetFloat() --  original water simulation is based on a value of 0.01 ( which is alright but not for big servers ) 
	local sim_quality_mod = sim_quality / 0.01
	
	local overall_mod     = sim_quality_mod * scalar 
	local wr   = 0.999               
	

	local verts = 	self.Verts 
	local minz      = getMapCenterFloorPos().z
	local zrange    = self.CurrentHeight 
	local zmax      = minz + zrange 

	
	local max_y, min_y = math.max(verts.wave_front[1].y, verts.wave_front[2].y),  math.min(verts.wave_front[1].y, verts.wave_front[2].y)
	local max_x, min_x = math.max(verts.wave_front[1].x, verts.wave_front[3].x),  math.min(verts.wave_front[1].x, verts.wave_front[3].x)
	
	for k, v in pairs(ents.GetAll()) do 
		
		
		local phys   = v:GetPhysicsObject()
		local vclass = v:GetClass()
		
		if phys:IsValid() and IsValidPhysicsEnt(v) and self:IsValid() then
			
			local vpos   = v:GetPos()
			
	
			local xalpha     = (vpos.x - min_x) /  (max_x - min_x)
			local zalpha_max = (xalpha * zrange) + minz
			
			if (vpos.x <= max_x and vpos.x >= min_x) and (vpos.y <= max_y and vpos.y >= min_y) and (vpos.z <= zalpha_max  and vpos.z >= minz) then 
	
		
	
			
	
			
				local diff = zalpha_max-vpos.z 
		
			if v:IsPlayer() then
				
					local eye = v:EyePos()	
					if eye.z >= minz and eye.z <= zmax then
						v:SetNWBool("IsUnderlava", true)		
						v:SetNWFloat("ZlavaDepth",  math.Round(diff))
						--self:PlayerOxygen(v, scalar, t)
						
						--v:SetMoveType(MOVETYPE_WALK)
						
					end 
					
					

			
				end
		
		
		
				--[[
				
					Purpose:
					
					It's kinda an event trigger for when entities exit / enter water 
				

				--]] 
				
				
				if (vpos.z >= minz and vpos.z <= zmax) and v.IsInlavaWedge!=true then
					v.IsInlavaWedge = true 
					
					self:OnWedgelavaEntry(v)
				end 
				
				

				if v.IsInlava and v:IsPlayer() then
					
					v:SetVelocity( v:GetVelocity() * -0.5 + Vector(0,0,10) )
					v:Ignite(15)
				elseif v.IsInlava and v:IsNPC() or v:IsNextBot() then
					v:SetVelocity( ((Vector(0,0,math.Clamp(diff,-100,50)/4) * 0.99)  * overall_mod) - (v:GetVelocity() * 0.05))
					v:Ignite(15)
				else
	
					local massmod       = math.Clamp((phys:GetMass()/25000),0,1)
					local buoyancy_mod  = GetBuoyancyMod(v)
					
					if v:GetModel()=="models/airboat.mdl" then   
						buoyancy_mod = 5 
						
					end 
					
					local buoyancy      = massmod + (buoyancy_mod*(1 + massmod))
					
					local friction      = (1-math.Clamp( (phys:GetVelocity():Length()*overall_mod)/50000,0,1)) 
					
					if buoyancy_mod <= 1 then 
						friction  = (1-math.Clamp( (phys:GetVelocity():Length()*overall_mod)/10000,0,1)) 
					end
			
					local add_vel       = Vector(0,0, (math.Clamp(diff,-20,20)/8 * buoyancy)  * overall_mod)
					phys:AddVelocity( add_vel )
					
					local resultant_vel = v:GetVelocity() * friction
					local final_vel     = Vector(resultant_vel.x * wr,resultant_vel.y * wr, resultant_vel.z * friction)
		
					
					v:Ignite(15)
					
						
					local r    = v:BoundingRadius()
					local vol  = 4/3 * math.pi * r^3 
					
					local m1 = vol * 1000 
					local m2 = phys:GetMass()
					
					local v1   = self.Speed  	
					
					local v2   = ((m1 / ( m1 + m2 )) * v1) * 0.8
				
				

				
					phys:SetVelocity(( final_vel + (v2 * ( 1 - (buoyancy_mod/ 6)) * Vector(-1,0,0)))*1.25)
									
	
					
					
					
						
						
						
						
						
				
				end
					
					
					
					
					
					
					
					
					
					
					
			else 
				
				
				if v.IsInlavaWedge ==true then
	
					v.IsInlavaWedge = false
					self:OnWedgelavaExit(v)

				end
			
			end	
		end 
	end
	
end



function ENT:DolavaPhysics()
	if !self:IsValid() then return end
	if CurTime() >= self.NextPhysicsTime then 
	

		local sim_quality     = GetConVar( "gdisasters_envdynamicwater_simquality" ):GetFloat() --  original water simulation is based on a value of 0.01 ( which is alright but not for big servers ) 

	
		self:ProcessEntitiesInLava()
		self:ProcessEntitiesInWedgeLava()
		
		self.NextPhysicsTime = CurTime() +  sim_quality 
	
	end
	
end 
		



function ENT:StateHeightlavaGain(alpha)
	
	if (SERVER) then
		self.CurrentHeight =  self.Data.StartHeight + ( (self.Data.MiddleHeight - self.Data.StartHeight) * (alpha / 0.35))
	end
	
end



function ENT:PlayerOxygen(v, scalar, t)

	local sim_quality     = GetConVar( "gdisasters_envdynamicwater_simquality" ):GetFloat() --  original water simulation is based on a value of 0.01 ( which is alright but not for big servers ) 
	local sim_quality_mod = sim_quality / 0.01

	local overall_mod     = sim_quality_mod * scalar 
	
	if v.IsInlava then
		if v.Oxygen == nil then v.Oxygen = 5 end 
		
		
		v.Oxygen = math.Clamp(v.Oxygen - (engine.TickInterval() * overall_mod ), 0,10)
		
		
		
		if v.Oxygen <= 0 then

			if math.random(1,math.floor((100/overall_mod)))==1 then
				
				local dmg = DamageInfo()
				dmg:SetDamage( math.random(1,25) )
				dmg:SetAttacker( v )
				dmg:SetDamageType( DMG_DROWN  )

				v:TakeDamageInfo(  dmg)
			end
		
		end
	else
		v.Oxygen = 5
	end
end

function ENT:StateWedgelavaDecreaseMain(alpha)


	if (SERVER) then
	
	
		local modalpha = alpha / 0.75 

		
		self.CurrentWedge = self.Data.StartWedge + (self.Data.MiddleWedge - self.Data.StartWedge) * modalpha
		
		
	
	end
	

end

function ENT:StateHeightDecreaselava03(alpha)
	
	if (SERVER) then
		alpha = alpha - 0.75 
		
		self.CurrentWedge  =  self.Data.MiddleWedge + (self.Data.EndWedge - self.Data.MiddleWedge) * ( alpha / 0.25)
		
	end
	
end

function ENT:StateHeightDecreaseMainLava(alpha)
	
	if (SERVER) then
		alpha = alpha - 0.75
		
		self.CurrentHeight = self.Data.MiddleHeight + ( (self.Data.EndHeight - self.Data.MiddleHeight)  * (alpha / 0.25))
		
		
	end
	
end

function ENT:SpeedlavaDecrease(alpha)
	
	if (SERVER) then
	
	local alpha_mod = (alpha - 0.5) / 0.2
	
	local new_speed =  (1 - ( alpha_mod * 0.5)) * self.OriginalSpeed 
	
	self.Speed      = new_speed
	
	end

end





function ENT:ProcesslavaState()
	 
	local alpha = math.Clamp( self.CurrentDistanceTravelled / self.MaxDistance , 0, 1) 

	
	if alpha >= 0 and alpha < 0.35 then 
		self.State = "height_gain"
		self:StateHeightlavaGain(alpha)
		self:StateWedgelavaDecreaseMain(alpha)

		
	elseif alpha >= 0.35 and alpha < 0.5 then
		self.State = "height_decrease_01"
		self:StateWedgelavaDecreaseMain(alpha)

		
	elseif alpha >= 0.5 and alpha < 0.75 then
		self.State = "height_decrease_02"
		self:StateWedgelavaDecreaseMain(alpha)
		self:SpeedlavaDecrease(alpha)
		
	elseif alpha >= 0.75 and alpha < 1 then 
		self.State = "the_end"
		self:StateHeightDecreaselava03(alpha)
		self:StateHeightDecreaseMainLava(alpha)
		
	elseif alpha >= 1 then 
		if (SERVER) then 
			local lava = createlava(self.CurrentHeight, ents.GetAll()[1])
			lava:EFire("Height", self.CurrentHeight)
			
			timer.Simple(50, function()
				if lava:IsValid() then lava:Remove() end
			end)

			self:Remove()

		end 
		
	end
	
	self:Expandlava()



end



function ENT:Think()
	
	if (CLIENT) then
		self:ProcesslavaState()

		
	end
	if (SERVER) then
		local t = GetConVar( "gdisasters_envdynamicwater_simquality" ):GetFloat()-- tick dependant function that allows for constant think loop regardless of server tickrate
		
	
		
		self:IsParentValid()
		self:UpdateNetworkedVariablesLava()
		self:DolavaPhysics()
		
		self:ProcesslavaState()
		self:ErrorChecklava() 
		
		self:NextThink(CurTime() )
		return true
	end
	
end


	
function ENT:RebuildlavaVertices(distance_travelled, height, wedge_constant)


	local bounds    = getMapSkyBox();
	local min       = bounds[1];
	local max       = bounds[2];

	local minz      = getMapCenterFloorPos().z;
	local dir       = (Vector(max.x, 0, 0)-Vector(min.z,0,0)):GetNormalized().x ;
	local scale     = self.CurrentDistanceTravelled;
	local height    = self:GetNWFloat("CurrentHeight");
	local wedgec    = self:GetNWFloat("CurrentWedge");
	
	
	local floor_v1  = Vector(min.x, min.y, minz); -- starting vector 
	local floor_v2  = Vector(min.x, max.y, minz); -- starting vector

	local floor_v3  = floor_v1 + Vector(dir * scale, 0,0); -- ending vector where water currently reaches
	local floor_v4  = floor_v2 + Vector(dir * scale, 0,0); -- ending vector where water currently reaches
	
	local floor_v5   = floor_v1  + Vector(dir * scale, 0,0) + Vector(dir * wedgec * scale, 0,0);
	local floor_v6   = floor_v2  + Vector(dir * scale, 0,0) + Vector(dir * wedgec * scale, 0,0);
	

	
	self.Verts = {
		wave_front = {floor_v5 , floor_v6 , floor_v4 + Vector(0,0,height), floor_v3 + Vector(0,0,height)},
		wave_top   = {floor_v1 + Vector(0,0,height), floor_v2 + Vector(0,0,height), floor_v4 + Vector(0,0,height), floor_v3 + Vector(0,0,height)}
	
	}
	
	self.DirectionOfTravel = dir;
	


end


function ENT:OnRemove()
	if (CLIENT) then 
	
	
		if LocalPlayer().Sounds["Tsunamilava"]!=nil and LocalPlayer().Sounds["lava"]!=nil then 
			LocalPlayer().Sounds["Tsunamilava"]:Stop()
			LocalPlayer().Sounds["Tsunamilava"]=nil
			LocalPlayer().Sounds["lava"]:Stop()
			LocalPlayer().Sounds["lava"]=nil
		end
		
	end
	if (SERVER) then
	
		
		for k, v in pairs(player.GetAll()) do
		
		v.IsInlava = false 
		v:SetNWBool("IsUnderlava", false)
		
		end
	end
	self:StopParticles();
end


function ENT:OnLavaExit(ent)


	if ent:IsPlayer() then 
	
		ent.Oxygen = 10
		
	
		net.Start("gd_screen_particles")
		net.WriteString("hud/warp_ripple3")
		net.WriteFloat(math.random(10,58))
		net.WriteFloat(math.random(10,50)/10)
		net.WriteFloat(math.random(0,10))
		net.WriteVector(Vector(0,math.random(0,200)/100,0))
		net.Send(ent)
		
	
		--ent:SetMoveType(MOVETYPE_WALK)
		
		ent:SetNWBool("IsUnderlava", false)
			

	end


end


function ENT:OnLavaEntry(ent) 
	
	local vpos = ent:GetPos()

	
	if math.random(1,2)==1 then
		ParticleEffect( "lava_splash_main", Vector(vpos.x, vpos.y, zmax), Angle(0,0,0), nil)
	end



end


function ENT:OnWedgelavaExit(ent)

	if ent:IsPlayer() then 
		--ent:SetMoveType(MOVETYPE_WALK)
		
		
		ent.Oxygen = 10
	
		net.Start("gd_screen_particles")
		net.WriteString("hud/warp_ripple3")
		net.WriteFloat(math.random(10,58))
		net.WriteFloat(math.random(10,50)/10)
		net.WriteFloat(math.random(0,10))
		net.WriteVector(Vector(0,math.random(0,200)/100,0))
		net.Send(ent)
		

		ent:SetNWBool("IsUnderlava", false)
			

	end
					
end

function ENT:OnWedgelavaEntry(ent) 
	
	if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then 
	
		ent:Ignite(15)
	
	else
		
		local phys = ent:GetPhysicsObject()
		local buoyancy_mod  = GetBuoyancyMod(ent)
		
		if !phys:IsValid() then return end 
			
		local r    = ent:BoundingRadius()
		local vol  = 4/3 * math.pi * r^3 
		
		local m1 = vol * 1000 
		local m2 = phys:GetMass()
		
		local v1   = self.Speed  	
		
		local v2   = (m1 / ( m1 + m2 )) * v1 
	
	
		if  GetConVar( "gdisasters_envdynamicwater_candamageconstraints" ):GetInt()>=1 then
			self:DamageEntity(ent, phys, buoyancy_mod, m2)
		end	
		
		if self:IsValid() then
	
		phys:SetVelocity( v2 * ( 1 - (buoyancy_mod/ 5)) * Vector(-1,0,0))
		
		end
		
		if r >= 0 and r < 50 then 
			if HitChance(10) then 
			ParticleEffect("lava_splash_main", ent:GetPos() - Vector(-1,0,0) * r * 0.8, Angle(0,0,0), nil)	
			end 
			
		elseif r >= 50 and r < 100 then 
			if HitChance(25) then 
			ParticleEffect("lava_splash_main", ent:GetPos() - Vector(-1,0,0) * r * 0.8, Angle(0,0,0), nil)
			end
		elseif r >= 100 and r < 150 then 
			if HitChance(35) then 
			ParticleEffect("lava_splash_main", ent:GetPos() - Vector(-1,0,0) * r * 0.8, Angle(0,0,0), nil)
			end
			
		elseif r >= 150 and r < 200 then 
			if HitChance(55) then 
			ParticleEffect("lava_splash_main", ent:GetPos() - Vector(-1,0,0) * r * 0.8, Angle(0,0,0), nil)
			end
		elseif r >= 200 then 
			ParticleEffect("lava_splash_main", ent:GetPos() - Vector(-1,0,0) * r * 0.8, Angle(0,0,0), nil)
		end
	
	
	
	end
end

function IsValidPhysicsEnt(ent)
	return !ignore_ents[ent:GetClass()]
end

function ENT:DamageEntity(ent, phys, buoyancy_mod, mass) 


	local chance = math.Clamp( 1 - (buoyancy_mod / 5),0,1) * 100

	
	if HitChance(chance) then
		
		
		phys:EnableMotion(true)
		phys:Wake()
		constraint.RemoveAll( ent )
		--ent:SetCollisionGroup(COLLISION_GROUP_WORLD)



	end 
	
end


local tsunami_water_textures = {}
tsunami_water_textures[1]    = Material("nature/env_dynamicwater/base_water_tsunami");
tsunami_water_textures[2]    = Material("nature/env_dynamicwater/base_water_03");


function ENT:Draw()
			
end

function ENT:EFire(pointer, arg) 
	
	if pointer == "Enable" then 
	elseif pointer == "Parent" then self.Parent = arg;
	end
end

function createTsunamilava(parent, data)
	if IsMapRegistered() == true then
		for k, v in pairs(ents.FindByClass( "env_dynamicwater_b","env_dynamiclava_b")) do
			v:Remove();
		end

		local tsunamilava = ents.Create("env_dynamiclava_b");
		tsunamilava.Data  = data;


		tsunamilava:SetPos(getMapCenterFloorPos());
		tsunamilava:Spawn();
		tsunamilava:Activate();

		tsunamilava:EFire("Parent", parent);
		tsunamilava:EFire("Enable", true);

		return tsunamilava;
	end
end

function ENT:IsParentValid()

	if self.Parent:IsValid()==false or self.Parent==nil then self:Remove(); end
	
end


function env_dynamiclava_b_DrawLava()

	local tsunamilava = ents.FindByClass("env_dynamiclava_b")[1];
	if !tsunamilava then return end
	
	local verts   = tsunamilava.Verts;

	local model = ClientsideModel("models/props_junk/PopCan01a.mdl", RENDERGROUP_OPAQUE);
	model:SetNoDraw(true);	
	
	local lava2_texture = Material("nature/env_dynamiclava/base_lava")
	
	local function RenderFix2()
	
	
		cam.Start3D();
		
			local mat = Matrix();
			mat:Scale(Vector(0, 0, 0));
			model:EnableMatrix("RenderMultiply", mat);
			model:SetPos(tsunamilava:GetPos());
			model:DrawModel();
		
			render.SuppressEngineLighting( true );

			
			render.SuppressEngineLighting( false );
		
		cam.End3D();
	
	end
	
	local function EasyVert( position, normal, u, v )
	
		mesh.Normal( normal );
		mesh.Position( position );
		mesh.TexCoord( 0, u, v );	
		mesh.AdvanceVertex( );
	 
	end
	
	local function DrawLava2()
	
		render.SetBlend( 1 )
		render.SetMaterial(lava2_texture)
		
		local matrix = Matrix( );
		matrix:Translate( getMapCenterFloorPos() );
		matrix:Rotate( tsunamilava:GetAngles( ) );
	
		matrix:Scale( Vector(1,1,1) )
		
		
		
		
			
		local a, b = verts.wave_front[2]-verts.wave_front[1], verts.wave_front[3] - verts.wave_front[1]
		
		local normal_front = a:Cross(b):GetNormalized() * -1 -- setting normals doesn't work...
		
		local size_constant = 0.0003
		
		local w, h     = verts.wave_top[1]:Distance(verts.wave_top[2]) * size_constant , verts.wave_top[2]:Distance(verts.wave_top[3]) * size_constant
		local w2, h2     = verts.wave_front[1]:Distance(verts.wave_front[2]) * size_constant , verts.wave_front[2]:Distance(verts.wave_front[3]) * size_constant
	
		
		mesh.Begin( MATERIAL_QUADS, 2 );

			EasyVert( verts.wave_top[1], vector_up, 0,0 )
			EasyVert( verts.wave_top[2], vector_up, 0, w )
			EasyVert( verts.wave_top[3], vector_up, h, w )
			EasyVert( verts.wave_top[4], vector_up, h,0 )
			
			

			EasyVert( verts.wave_front[4], vector_up, 0,0 )
			EasyVert( verts.wave_front[3], vector_up, 0,w2 )
			EasyVert( verts.wave_front[2], vector_up, h2,w2 )
			EasyVert( verts.wave_front[1], vector_up, h2,0 )

	
		mesh.End( );
		
		
	end
	
	RenderFix2()
	DrawLava2()
	model:Remove()	
end


if (CLIENT) then
	hook.Add("PostDrawTranslucentRenderables", "DrawTsunamiLava", function()
		
		if IsMapRegistered() then
		
			env_dynamiclava_b_DrawLava()
			
			
		end
		
	end)
	

	
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
