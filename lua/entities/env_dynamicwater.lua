AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Flash Flood"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.MaxFloodLevel                    =  9000

function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel("models/props_junk/PopCan01a.mdl")

		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
				
		self.FloodHeight = 0
		self:SetNWFloat("FloodHeight", self.FloodHeight)
		
		if IsMapRegistered()==false then self:Remove() end 

			
		
	end
end

function ENT:EFire(pointer, arg) 
	
	if pointer == "EnableFHGain" then self.shouldFloodGainHeight = arg or true 
	elseif pointer == "Enable" then 
	elseif pointer == "MaxHeight" then self.MaxFloodLevel = arg or 600 
	elseif pointer == "Parent" then self.Parent = arg 
	elseif pointer == "Height" then self.FloodHeight = arg or 100 
	end
end

function createFlood(maxheight, parent)

	if IsMapRegistered() == true then
	
	for k, v in pairs(ents.FindByClass("env_dynamiclava", "env_dynamicwater")) do
		v:Remove()
	end
	
	local flood = ents.Create("env_dynamicwater")
	flood:SetPos(getMapCenterFloorPos())
	flood:Spawn()
	flood:Activate()

	flood:EFire("Parent", parent)
	flood:EFire("MaxHeight", maxheight)
	flood:EFire("Enable", true)
	
	return flood
	
	end
end

function floodExists()

	return #ents.FindByClass("env_dynamicwater")>0
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	
	
	ent:SetPos( getMapCenterFloorPos() )

	
	ent:Spawn()
	ent:Activate()
	

	return ent
end


function ENT:FloodHeightIncrement(scalar, t)


	local sim_quality     = GetConVar( "gdisasters_envdynamicwater_simquality" ):GetFloat() --  original water simulation is based on a value of 0.01 ( which is alright but not for big servers ) 
	local sim_quality_mod = sim_quality / 0.01
	local overall_mod     = sim_quality_mod * scalar
	
	
	self.FloodHeight = math.Clamp(self.FloodHeight + ( (1/6) * overall_mod), 0, self.MaxFloodLevel) 
	self:SetNWFloat("FloodHeight", self.FloodHeight)
end

local ignore_ents ={
["phys_constraintsystem"]=true,
["phys_constraint"]=true,
["logic_collision_pair"]=true,
["entityflame"]=true,
["worldspawn"]=true
}

function IsValidPhysicsEnt(ent)
	return !ignore_ents[ent:GetClass()]
end

function ENT:ProcessFlood(scalar, t)
	local zmax = self:GetPos().z + self.FloodHeight 
	local pos  = self:GetPos() - Vector(0,0,50)
	local wr   = 0.999               -- water friction
	local sim_quality     = GetConVar( "gdisasters_envdynamicwater_simquality" ):GetFloat() --  original water simulation is based on a value of 0.01 ( which is alright but not for big servers ) 
	local sim_quality_mod = sim_quality / 0.01
	
	local overall_mod     = sim_quality_mod * scalar 

	for k, v in pairs(ents.GetAll()) do
	
		local phys = v:GetPhysicsObject()
		
		if phys:IsValid()  and  IsValidPhysicsEnt(v) then 
			local vpos = v:GetPos()
	
			local diff = zmax-vpos.z 
			
			if v:IsPlayer() then
			
				local eye = v:EyePos()	
				
				if eye.z >= pos.z and eye.z <= zmax then
					v:SetNWBool("IsUnderwater", true)		
					v:SetNWInt("ZWaterDepth", diff)
					
					
					
				else

					if v:GetNWBool("IsUnderwater")==true then
						net.Start("gd_screen_particles")
						net.WriteString("hud/warp_ripple3")
						net.WriteFloat(math.random(10,58))
						net.WriteFloat(math.random(10,50)/10)
						net.WriteFloat(math.random(0,10))
						net.WriteVector(Vector(0,math.random(0,200)/100,0))
						net.Send(v)
						
					
						
					end
					
					v:SetNWBool("IsUnderwater", false)
				end
			end
	
	
	
			if (vpos.z >= pos.z and vpos.z <= zmax) and v.IsInWater!=true then
				v.IsInWater = true 
				
				if math.random(1,2)==1 then
					ParticleEffect( "splash_main", Vector(vpos.x, vpos.y, zmax), Angle(0,0,0), nil)
					v:EmitSound(table.Random({"ambient/water/water_splash1.wav","ambient/water/water_splash2.wav","ambient/water/water_splash3.wav"}), 80, 100)
				end
				
			end
			
			if (v:GetPos().z < pos.z or v:GetPos().z > zmax) and v.IsInWater == true then
				v.IsInWater = false
			end
			
			if v.IsInWater and v:IsPlayer() then
				
				v:SetVelocity( v:GetVelocity() * -0.5 + Vector(0,0,20) )
			
			elseif v.IsInWater and v:IsNPC() or v:IsNextBot() then
				v:SetVelocity( ((Vector(0,0,math.Clamp(diff,-100,50)/4) * 0.99)  * overall_mod) - (v:GetVelocity() * 0.05))
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
			
					local add_vel       = Vector(0,0, (math.Clamp(diff,-20,20)/8 * buoyancy)  * overall_mod)
					phys:AddVelocity( add_vel )
					
					local resultant_vel = v:GetVelocity() * friction
					local final_vel     = Vector(resultant_vel.x * wr,resultant_vel.y * wr, resultant_vel.z * friction)
		
					
					phys:SetVelocity( final_vel)
					
					if v:IsVehicle() and v:GetClass()!="prop_vehicle_airboat" then 
						v:Fire("TurnOff", 0.1, 0)
					end 

					if v:IsOnFire() or v:GetClass() == "vfire" or v:GetClass() == "entityflame" then
						v:Extinguish()
					end
					
					if (v.isWacAircraft) then
						v:setEngine(false)
						v.engineDead = true							 
					end
				end
			end

		end
	
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

function ENT:IsParentValid()

	if self.Parent:IsValid()==false or self.Parent==nil then self:Remove() end
	
end

function ENT:Think()
	if (SERVER) then
		local t = GetConVar( "gdisasters_envdynamicwater_simquality" ):GetFloat()-- tick dependant function that allows for constant think loop regardless of server tickrate
		
		local scalar = (66/ ( 1/engine.TickInterval()))
		self:ProcessFlood(scalar, t)
		self:FloodHeightIncrement(scalar, t)
		self:IsParentValid()
		
		self:NextThink(CurTime() + t)
		return true
	end
	
end
function ENT:OnRemove()
	if (SERVER) then
		for k, v in pairs(player.GetAll()) do
		
			v:SetNWBool("IsUnderwater", false)
			v.IsInWater = false
		end
	end
	self:StopParticles()
end

local water_textures = {}
water_textures[1]    = Material("nature/env_dynamicwater/base_water_01")
water_textures[2]    = Material("nature/env_dynamicwater/base_water_02")
water_textures[3]    = Material("nature/env_dynamicwater/base_water_03")


local water_shader   = {}
water_shader[1]    = Material("nature/env_dynamicwater/water_expensive_02")
water_shader[2]    = Material("nature/env_dynamicwater/water_expensive_01")


	
function ENT:Draw()
			
end


function env_dynamicwater_DrawWater()

	local flood = ents.FindByClass("env_dynamicwater")[1]
	if !flood then return end
	

	local model = ClientsideModel("models/props_junk/PopCan01a.mdl", RENDERGROUP_OPAQUE)
	model:SetNoDraw(true)	
	
	local height =  flood:GetNWFloat("FloodHeight")
	local map_bounds = getMapBounds()
	local vmin, vmax =  Vector(map_bounds[1].x,map_bounds[1].y,0),  Vector(map_bounds[2].x,map_bounds[2].y,height)
	
	local water_texture =  water_textures[ math.Clamp(GetConVar( "gdisasters_graphics_water_quality" ):GetInt(), 1, 3)]
	local water_shaders =  water_shader[ math.Clamp(GetConVar( "gdisasters_graphics_water_shader_quality" ):GetInt(), 1, 2)]

	local function RenderFix()
	
	
		cam.Start3D()
		
			local mat = Matrix()
			mat:Scale(Vector(0, 0, 0))
			model:EnableMatrix("RenderMultiply", mat)
			model:SetPos(flood:GetPos())
			model:DrawModel()
		
			render.SuppressEngineLighting( true ) 
		
			
			render.SuppressEngineLighting( false ) 
		cam.End3D()
	
	end
	local function EasyVert( position, normal, u, v )

		mesh.Position( position );
		mesh.Normal( normal );
		mesh.TexCoord( 0, u, v );

		mesh.AdvanceVertex( );
	 
	end
	
		
	local function DrawHQWater()
		
		render.SetBlend( 1 )
		render.SetMaterial(water_shaders)
		
		local matrix = Matrix( );
		matrix:Translate( getMapCenterFloorPos() );
		matrix:Rotate( flood:GetAngles( ) );
	
		matrix:Scale( Vector(1,1,1) )
		
		cam.PushModelMatrix( matrix );

			mesh.Begin( MATERIAL_QUADS, 1 );

			EasyVert( Vector(map_bounds[1].x,map_bounds[1].y,height), vector_up, 0,0 );
			EasyVert( Vector(map_bounds[1].x,map_bounds[2].y,height), vector_up, 0,100 );
			EasyVert( Vector(map_bounds[2].x,map_bounds[2].y,height), vector_up, 100,100 );
			EasyVert( Vector(map_bounds[2].x,map_bounds[1].y,height), vector_up, 100,0 );
		
			mesh.End( );
			 
		cam.PopModelMatrix( );	
		render.SuppressEngineLighting( false ) 
	
	end

	local function DrawLQWater()
	
		render.SetMaterial(water_texture)
		render.SetBlend( 1 )
		
		local matrix = Matrix( );
		matrix:Translate( getMapCenterFloorPos() );
		matrix:Rotate( flood:GetAngles( ) );
		matrix:Scale( Vector(1,1,1) )
		
		local hmod = height -1 
		
		cam.PushModelMatrix( matrix );

			mesh.Begin( MATERIAL_QUADS, 1 );

			EasyVert( Vector(map_bounds[1].x,map_bounds[1].y,hmod), vector_up, 0,0 );
			EasyVert( Vector(map_bounds[1].x,map_bounds[2].y,hmod), vector_up, 0,25 );
			EasyVert( Vector(map_bounds[2].x,map_bounds[2].y,hmod), vector_up, 25,25 );
			EasyVert( Vector(map_bounds[2].x,map_bounds[1].y,hmod), vector_up, 25,0 );
		
			mesh.End( );
			 
		cam.PopModelMatrix( );	
				
	
	end
	
	
	RenderFix()
	if GetConVar( "gdisasters_graphics_water_quality" ):GetInt() > 3 then DrawHQWater() else DrawLQWater()	end
	model:Remove()	
end


if (CLIENT) then
	hook.Add("PreDrawTranslucentRenderables", "DRAWFLOOD", function()
	

		if IsMapRegistered() == true then
		
			env_dynamicwater_DrawWater()


		end

	end)
	
	
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end


