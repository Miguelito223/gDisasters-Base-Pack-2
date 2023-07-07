AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Tsunami"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"
ENT.Data                             = {}
ENT.WedgeSound                       = "streams/disasters/tsunami/idle.wav"

function ENT:Initialize()	

	self:SetupMiscVars()
	if (CLIENT) then 

		
		
		LocalPlayer().Sounds["Tsunami"]         = CreateLoopedSound(LocalPlayer(), self.WedgeSound)
		
		
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

function ENT:SetupMiscVars()


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
	
	
	self:RebuildVertices(self.CurrentDistanceTravelled, self:GetNWFloat("CurrentHeight"), self:GetNWFloat("CurrentWedge"))
	
end


function ENT:UpdateNetworkedVariables()

	self:SetNWFloat("Speed", self.Speed)
	self:SetNWFloat("CurrentHeight", self.CurrentHeight)
	self:SetNWFloat("CurrentWedge", self.CurrentWedge)

	
	
end

if (SERVER) then 

	util.AddNetworkString("env_dynamicwater_b_errorcheck")

end 


net.Receive("env_dynamicwater_b_errorcheck", function()
	
	local CurrentDistanceTravelled = net.ReadFloat()
	local ent = ents.FindByClass("env_dynamicwater_b")[1] 
	ent.CurrentDistanceTravelled = CurrentDistanceTravelled
	



end)


function ENT:ErrorCheck()

	if CurTime() >= self.NextErrorCheck then
	
		self.NextErrorCheck = CurTime() + 1 
		
		net.Start("env_dynamicwater_b_errorcheck")
		net.WriteFloat(self.CurrentDistanceTravelled)
		net.Broadcast()
		
	end
	
	
 
end
function ENT:Expand()
	if (CLIENT) then 
		
		if	LocalPlayer().Sounds["Tsunami"]!=nil then
			local pos    = LocalPlayer():GetPos()
			local alpha = 1 - math.Clamp( (math.abs(LocalPlayer():GetPos().x - self.Verts.wave_front[1].x) / 5000),0,1)
			LocalPlayer().Sounds["Tsunami"]:ChangeVolume( alpha,0,1)
			
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

	
	self:RebuildVertices(float, self:GetNWFloat("CurrentHeight"), self:GetNWFloat("CurrentWedge"))

end

function ENT:ProcessEntitiesInWater()

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
						v:SetNWBool("IsUnderwater", true)		
						v:SetNWFloat("ZWaterDepth",  math.Round(diff))
						
						--v:SetMoveType(MOVETYPE_WALK)
						
					end 
					
					

			
				end
		
		
		
				if (vpos.z >= minz and vpos.z <= zmax) and v.IsInWater!=true then
					v.IsInWater = true 
					
					self:OnWaterEntry(v)
				
					
				end
				
				
				--[[ 
					Purpose:
					
					Apply physics for players, npcs and other entities 
				--]]
				
			
					
				if v.IsInWater and v:IsPlayer() and self:IsValid() then
					
					v:SetVelocity( v:GetVelocity() * -0.5 + Vector(0,0,10) - Vector(40,0,0) )
				
				elseif v.IsInWater and v:IsNPC() or v:IsNextBot() then
					v:SetVelocity( ((Vector(0,0,math.Clamp(diff,-100,50)/4) * 0.99)  * overall_mod) - (v:GetVelocity() * 0.05) - Vector(40,0,0))
					v:TakeDamage(1, self, self)
				else
					if v.IsInWater then

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
				
						local add_vel       = Vector(0,0, (math.Clamp(diff,-20,20)/8 * buoyancy)   * overall_mod) - Vector(40,0,0)
						phys:AddVelocity( add_vel )
						
						local resultant_vel = v:GetVelocity() * friction
						local final_vel     = Vector(resultant_vel.x * wr,resultant_vel.y * wr, resultant_vel.z * friction)

						if v:IsOnFire() or v:GetClass() == "vfire" or v:GetClass() == "entityflame" then
							v:Extinguish()
						end
			
						if #ents.FindByClass("gd_d2_minivolcano*") >= 1 then return end
						if #ents.FindByClass("gd_d8_ancientvolcano*") >= 1 then return end
						if #ents.FindByClass("gd_d4_youngvolcano*") >= 1 then return end
						if #ents.FindByClass("gd_d5_maturevolcano*") >= 1 then return end
			
						
						phys:SetVelocity( final_vel)
						
						
					end
				end	
	
			else 
				
	
				if v.IsInWater==true then
					v.IsInWater = false
					self:OnWaterExit(v)

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

function ENT:ProcessEntitiesInWedge()

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
						v:SetNWBool("IsUnderwater", true)		
						v:SetNWFloat("ZWaterDepth",  math.Round(diff))
						--self:PlayerOxygen(v, scalar, t)
						
						--v:SetMoveType(MOVETYPE_WALK)
						
					end 
					
					

			
				end
		
		
		
				--[[
				
					Purpose:
					
					It's kinda an event trigger for when entities exit / enter water 
				

				--]] 
				
				
				if (vpos.z >= minz and vpos.z <= zmax) and v.IsInWaterWedge!=true then
					v.IsInWaterWedge = true 
					
					self:OnWedgeEntry(v)
				end 
				
				

				if v.IsInWater and v:IsPlayer() then
					
					v:SetVelocity( v:GetVelocity() * -0.5 + Vector(0,0,10) )
				
				elseif v.IsInWater and v:IsNPC() or v:IsNextBot() then
					v:SetVelocity( ((Vector(0,0,math.Clamp(diff,-100,50)/4) * 0.99)  * overall_mod) - (v:GetVelocity() * 0.05))
					v:TakeDamage(1, self, self)
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
		
					
	
					
						
					local r    = v:BoundingRadius()
					local vol  = 4/3 * math.pi * r^3 
					
					local m1 = vol * 1000 
					local m2 = phys:GetMass()
					
					local v1   = self.Speed  	
					
					local v2   = ((m1 / ( m1 + m2 )) * v1) * 0.8
				
				

				
					phys:SetVelocity(( final_vel + (v2 * ( 1 - (buoyancy_mod/ 6)) * Vector(-1,0,0)))*1.25)
									
	
					
					
					
						
						
						
						
						
				
				end
					
					
					
					
					
					
					
					
					
					
					
			else 
				
				
				if v.IsInWaterWedge ==true then
	
					v.IsInWaterWedge = false
					self:OnWedgeExit(v)

				end
			
			end	
		end 
	end
	
end



function ENT:DoPhysics()
	if !self:IsValid() then return end
	if CurTime() >= self.NextPhysicsTime then 
	

		local sim_quality     = GetConVar( "gdisasters_envdynamicwater_simquality" ):GetFloat() --  original water simulation is based on a value of 0.01 ( which is alright but not for big servers ) 

	
		self:ProcessEntitiesInWater()
		self:ProcessEntitiesInWedge()
		
		self.NextPhysicsTime = CurTime() +  sim_quality 
	
	end
	
end 
		



function ENT:StateHeightGain(alpha)
	
	if (SERVER) then
		self.CurrentHeight =  self.Data.StartHeight + ( (self.Data.MiddleHeight - self.Data.StartHeight) * (alpha / 0.35))
	end
	
end


function ENT:StateWedgeDecreaseMain(alpha)


	if (SERVER) then
	
	
		local modalpha = alpha / 0.75 

		
		self.CurrentWedge = self.Data.StartWedge + (self.Data.MiddleWedge - self.Data.StartWedge) * modalpha
		
		
	
	end
	

end

function ENT:StateHeightDecrease03(alpha)
	
	if (SERVER) then
		alpha = alpha - 0.75 
		
		self.CurrentWedge  =  self.Data.MiddleWedge + (self.Data.EndWedge - self.Data.MiddleWedge) * ( alpha / 0.25)
		
	end
	
end

function ENT:StateHeightDecreaseMain(alpha)
	
	if (SERVER) then
		alpha = alpha - 0.75
		
		self.CurrentHeight = self.Data.MiddleHeight + ( (self.Data.EndHeight - self.Data.MiddleHeight)  * (alpha / 0.25))
		
		
	end
	
end

function ENT:SpeedDecrease(alpha)
	
	if (SERVER) then
	
	local alpha_mod = (alpha - 0.5) / 0.2
	
	local new_speed =  (1 - ( alpha_mod * 0.5)) * self.OriginalSpeed 
	
	self.Speed      = new_speed
	
	end

end


hook.Add( "Tick", "gDisasters_EnvWaterMovement", function(  )
	if !SERVER then return end 
	
	for k, ply in pairs(player.GetAll()) do 
	
		if ply.IsInWater then
	
			if ply:KeyDown( IN_JUMP) then 
				if ply:GetVelocity():Dot(Vector(0,0,30)) < 500 then 
					ply:SetVelocity(  Vector( 0, 0, 30 ) )
				end
			elseif ply:KeyDown( IN_FORWARD) then
				if ply:GetVelocity():Dot(ply:GetAimVector() * 100) < 10000 then 
					ply:SetVelocity(  ply:GetAimVector() * 100 )
				end
			end
		end
	end
	
end )


function ENT:ProcessState()
	 
	local alpha = math.Clamp( self.CurrentDistanceTravelled / self.MaxDistance , 0, 1) 

	
	if alpha >= 0 and alpha < 0.35 then 
		self.State = "height_gain"
		self:StateHeightGain(alpha)
		self:StateWedgeDecreaseMain(alpha)

		
	elseif alpha >= 0.35 and alpha < 0.5 then
		self.State = "height_decrease_01"
		self:StateWedgeDecreaseMain(alpha)

		
	elseif alpha >= 0.5 and alpha < 0.75 then
		self.State = "height_decrease_02"
		self:StateWedgeDecreaseMain(alpha)
		self:SpeedDecrease(alpha)
		
	elseif alpha >= 0.75 and alpha < 1 then 
		self.State = "the_end"
		self:StateHeightDecrease03(alpha)
		self:StateHeightDecreaseMain(alpha)
		
	elseif alpha >= 1 then 
		if (SERVER) then 
			local flood = createFlood(self.CurrentHeight, ents.GetAll()[1])
			flood:EFire("Height", self.CurrentHeight)

			timer.Simple(50, function()
				if flood:IsValid() then flood:Remove() end
			end)
			
			self:Remove()

		end 
		
	end
	
	self:Expand()



end



function ENT:Think()
	
	if (CLIENT) then
		self:ProcessState()

		
	end
	if (SERVER) then
		local t = GetConVar( "gdisasters_envdynamicwater_simquality" ):GetFloat()-- tick dependant function that allows for constant think loop regardless of server tickrate
		
	
		
		self:IsParentValid()
		self:UpdateNetworkedVariables()
		self:DoPhysics()
		
		self:ProcessState()
		self:ErrorCheck() 
		
		self:NextThink(CurTime() )
		return true
	end
	
end


	
function ENT:RebuildVertices(distance_travelled, height, wedge_constant)


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
	
	
		if LocalPlayer().Sounds["Tsunami"]!=nil then 
			LocalPlayer().Sounds["Tsunami"]:Stop()
			LocalPlayer().Sounds["Tsunami"]=nil
		end
		
	end
	if (SERVER) then
	
		
		for k, v in pairs(player.GetAll()) do
		
		v.IsInWater = false 
		v:SetNWBool("IsUnderwater", false)
		
		end
	end
	self:StopParticles();
end


function ENT:OnWaterExit(ent)


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
		
		ent:SetNWBool("IsUnderwater", false)
			

	end


end


function ENT:OnWaterEntry(ent) 
	
	local vpos = ent:GetPos()

	
	if math.random(1,2)==1 then
		ParticleEffect( "splash_main", Vector(vpos.x, vpos.y, zmax), Angle(0,0,0), nil)
		ent:EmitSound(table.Random({"ambient/water/water_splash1.wav","ambient/water/water_splash2.wav","ambient/water/water_splash3.wav"}), 80, 100)
	end



end


function ENT:OnWedgeExit(ent)

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
		

		ent:SetNWBool("IsUnderwater", false)
			

	end
					
end

function ENT:OnWedgeEntry(ent) 
	
	if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then 
	
		InflictDamage(ent, self, "cold", 10)
	
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
			ParticleEffect("tsunami_splash_effect_r200", ent:GetPos() - Vector(-1,0,0) * r * 0.8, Angle(0,0,0), nil)	
			end 
			
		elseif r >= 50 and r < 100 then 
			if HitChance(25) then 
			ParticleEffect("tsunami_splash_effect_r200", ent:GetPos() - Vector(-1,0,0) * r * 0.8, Angle(0,0,0), nil)
			end
		elseif r >= 100 and r < 150 then 
			if HitChance(35) then 
			ParticleEffect("tsunami_splash_effect_r300", ent:GetPos() - Vector(-1,0,0) * r * 0.8, Angle(0,0,0), nil)
			end
			
		elseif r >= 150 and r < 200 then 
			if HitChance(55) then 
			ent:EmitSound("streams/disasters/tsunami/splash_big.mp3", 100, 100, 1)
			ParticleEffect("tsunami_splash_effect_r400", ent:GetPos() - Vector(-1,0,0) * r * 0.8, Angle(0,0,0), nil)
			end
		elseif r >= 200 then 
			ent:EmitSound("streams/disasters/tsunami/splash_big.mp3", 100, 100, 1)
			ParticleEffect("tsunami_splash_effect_r500", ent:GetPos() - Vector(-1,0,0) * r * 0.8, Angle(0,0,0), nil)
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

function ENT:Draw()
			
end

function ENT:EFire(pointer, arg) 
	
	if pointer == "Enable" then 
	elseif pointer == "Parent" then self.Parent = arg;
	end
end

function createTsunami(parent, data)
	
	for k, v in pairs(ents.FindByClass( "env_dynamiclava_b", "env_dynamicwater_b")) do
		v:Remove();
	end
	
	local tsunami = ents.Create("env_dynamicwater_b");
	tsunami.Data  = data;

	
	tsunami:SetPos(getMapCenterFloorPos());
	tsunami:Spawn();
	tsunami:Activate();

	tsunami:EFire("Parent", parent);
	tsunami:EFire("Enable", true);
	
	return tsunami;

end

function ENT:IsParentValid()

	if self.Parent:IsValid()==false or self.Parent==nil then self:Remove(); end
	
end

local water_textures = {}
water_textures[1]    = Material("nature/env_dynamicwater/base_water_01")
water_textures[2]    = Material("nature/env_dynamicwater/base_water_02")
water_textures[3]    = Material("nature/env_dynamicwater/base_water_03")


local water_shader   = {}
water_shader[1]    = Material("nature/env_dynamicwater/water_expensive_02")
water_shader[2]    = Material("nature/env_dynamicwater/water_expensive_01")


function env_dynamicwater_b_DrawWater()

	local tsunami = ents.FindByClass("env_dynamicwater_b")[1];
	if !tsunami then return end
	
	local verts   = tsunami.Verts;

	local model = ClientsideModel("models/props_junk/PopCan01a.mdl", RENDERGROUP_OPAQUE);
	model:SetNoDraw(true);	
	
	local water_texture =  water_textures[ math.Clamp(GetConVar( "gdisasters_graphics_water_quality" ):GetInt(), 1, 3)]
	local water_shaders =  water_shader[ math.Clamp(GetConVar( "gdisasters_graphics_water_shader_quality" ):GetInt(), 1, 2)]

	local function RenderFix()
	
	
		cam.Start3D();
		
			local mat = Matrix();
			mat:Scale(Vector(0, 0, 0));
			model:EnableMatrix("RenderMultiply", mat);
			model:SetPos(tsunami:GetPos());
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
	
	
	
	local function DrawHQWater()
	
	
		render.SetBlend( 1 )
		render.SetMaterial(water_shaders)
		render.SuppressEngineLighting( true ) 
		
		local matrix = Matrix( );
		matrix:Translate( getMapCenterFloorPos() );
		matrix:Rotate( tsunami:GetAngles( ) );
	
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
	
	local function DrawLQWater()
	
		render.SetBlend( 1 )
		render.SetMaterial(water_texture)
		
		local matrix = Matrix( );
		matrix:Translate( getMapCenterFloorPos() );
		matrix:Rotate( tsunami:GetAngles( ) );
	
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
	
	RenderFix()
	if GetConVar( "gdisasters_graphics_water_quality" ):GetInt() > 3 then DrawHQWater() else DrawLQWater()	end 
	model:Remove()	
end


if (CLIENT) then
	hook.Add("PostDrawTranslucentRenderables", "DrawTsunami", function()
	

		if IsMapRegistered() == true then
		
			env_dynamicwater_b_DrawWater()
			
			
		end
		
	end)
	

	
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
