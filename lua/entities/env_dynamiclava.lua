AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Lava Flood"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.MaxlavaLevel                    =   9000
ENT.WedgeSound2							= "disasters/nature/volcano_idle.wav"

function ENT:Initialize()	
	if (CLIENT) then 
		if LocalPlayer().Sounds2 == nil then LocalPlayer().Sounds2 = {} end
		
		LocalPlayer().Sounds2["lava"]         = createLoopedSound(LocalPlayer(), self.WedgeSound2)
	
	end
	
	if (SERVER) then
		
		self:SetModel("models/props_junk/PopCan01a.mdl")

		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
				
		self.lavaHeight = 0
		self:SetNWFloat("lavaHeight", self.lavaHeight)
		
		if IsMapRegistered()==false then self:Remove() end 

		
		
	end
	
end

function ENT:CreateLoop()


	local sound = Sound(self.WedgeSound2)

	CSPatch = CreateSound(self, sound)
	CSPatch:SetSoundLevel( 100 )
	CSPatch:Play()
	CSPatch:ChangeVolume( 1 )

	self.Sound = CSPatch
	
end


function ENT:EFire(pointer, arg) 
	
	if pointer == "EnableFHGain" then self.shouldlavaGainHeight = arg or true 
	elseif pointer == "Enable" then 
	elseif pointer == "MaxHeight" then self.MaxlavaLevel = arg or 600 
	elseif pointer == "Parent" then self.Parent = arg 
	elseif pointer == "Height" then self.lavaHeight = arg or 100 
	end
end

function createlava(maxheight, parent)

	if IsMapRegistered() == true then
	
	for k, v in pairs(ents.FindByClass("env_dynamicwater")) do
		v:Remove()
	end
	for k, v in pairs(ents.FindByClass("env_dynamiclava")) do
		v:Remove()
	end
	
	local lava = ents.Create("env_dynamiclava")
	lava:SetPos(getMapCenterFloorPos())
	lava:Spawn()
	lava:Activate()

	lava:EFire("Parent", parent)
	lava:EFire("MaxHeight", maxheight)
	lava:EFire("Enable", true)
	
	return lava
	
	end
end

function lavaExists()

	return #ents.FindByClass("env_dynamiclava")>0
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


function ENT:lavaHeightIncrement(scalar, t)


	local sim_quality     = GetConVar( "gdisasters_envdynamicwater_simquality" ):GetFloat() --  original water simulation is based on a value of 0.01 ( which is alright but not for big servers ) 
	local sim_quality_mod = sim_quality / 0.01
	local overall_mod     = sim_quality_mod * scalar
	
	
	self.lavaHeight = math.Clamp(self.lavaHeight + ( (1/6) * overall_mod), 0, self.MaxlavaLevel) 
	self:SetNWFloat("lavaHeight", self.lavaHeight)
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

function ENT:Processlava(scalar, t)
	local zmax = self:GetPos().z + self.lavaHeight 
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
					v:SetNWBool("IsUnderlava", true)	
					v:SetNWInt("ZlavaDepth", diff)
					
					
					
				else
					
					v:SetNWBool("IsUnderlava", false)
				end
			end
	
	
	
			if (vpos.z >= pos.z and vpos.z <= zmax) and v.IsInlava!=true then
				v.IsInlava = true 
				
				if math.random(1,2)==1 then
					ParticleEffect( "lava_splash_main", Vector(vpos.x, vpos.y, zmax), Angle(0,0,0), nil)
				end
				
			end
			
			if (v:GetPos().z < pos.z or v:GetPos().z > zmax) and v.IsInlava==true then
				v.IsInlava = false
			end
			
			if v.IsInlava and v:IsPlayer() then
				v:SetVelocity( v:GetVelocity() * -0.9)
				v:Ignite(15)
				v:TakeDamage(10, self, self)
			
			elseif v.IsInlava and v:IsNPC() or v:IsNextBot() then
				v:SetVelocity( v:GetVelocity() * -0.9)
				v:Ignite(15)
				v:TakeDamage(10, self, self)
			else
				if v.IsInlava then
					phys:SetVelocity( phys:GetVelocity() * 0.01)
					v:Ignite(15)
					
					if v:IsVehicle() and v:GetClass()!="prop_vehicle_airboat" then 
						v:Fire("TurnOff", 0.1, 0)
						v:Ignite(15)
					end 
					
					if (v.isWacAircraft) then
						v:setEngine(false)
						v.engineDead = true	
						v:Ignite(15)						 
					end
				end
			end

		end
	
	end
end

function ENT:IsParentValid()

	if self.Parent:IsValid()==false or self.Parent==nil then self:Remove() end
	
end



function ENT:Think()
	if (SERVER) then
		local t = GetConVar( "gdisasters_envdynamicwater_simquality" ):GetFloat()-- tick dependant function that allows for constant think loop regardless of server tickrate
		
		local scalar = (66/ ( 1/engine.TickInterval()))
		self:Processlava(scalar, t)
		self:lavaHeightIncrement(scalar, t)
		self:IsParentValid()
		
		self:NextThink(CurTime() + t)
		return true
	end
	
end
function ENT:OnRemove()
	if (SERVER) then
		for k, v in pairs(player.GetAll()) do
		
			v:SetNWBool("IsUnderlava", false)
			v.IsInlava = false
		end
	end
	if (CLIENT) then
		if LocalPlayer().Sounds2["lava"]!=nil then 
			LocalPlayer().Sounds2["lava"]:Stop()
			LocalPlayer().Sounds2["lava"]=nil
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


function env_dynamiclava_Drawlava()

	local lava = ents.FindByClass("env_dynamiclava")[1]
	if !lava then return end
	

	local model = ClientsideModel("models/props_junk/PopCan01a.mdl", RENDERGROUP_OPAQUE)
	model:SetNoDraw(true)	
	
	local height =  lava:GetNWFloat("lavaHeight")
	local map_bounds = getMapBounds()
	local vmin, vmax =  Vector(map_bounds[1].x,map_bounds[1].y,0),  Vector(map_bounds[2].x,map_bounds[2].y,height)
	
	local water_texture =  water_textures[ math.Clamp(GetConVar( "gdisasters_graphics_water_quality" ):GetInt(), 1, 3)]
	local lava_texture = Material("nature/env_dynamiclava/base_lava")


	local function RenderFix()
	
	
		cam.Start3D()
		
			local mat = Matrix()
			mat:Scale(Vector(0, 0, 0))
			model:EnableMatrix("RenderMultiply", mat)
			model:SetPos(lava:GetPos())
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

	local function DrawLava()
	
		render.SetMaterial(lava_texture)
		render.SetBlend( 1 )
		
		local matrix = Matrix( );
		matrix:Translate( getMapCenterFloorPos() );
		matrix:Rotate( lava:GetAngles( ) );
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
	DrawLava()	
	
	model:Remove()	
end


if (CLIENT) then
	hook.Add("PreDrawTranslucentRenderables", "DRAWlava", function()
		if IsMapRegistered() then
			env_dynamiclava_Drawlava()
		end
		
	end)
	
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end


