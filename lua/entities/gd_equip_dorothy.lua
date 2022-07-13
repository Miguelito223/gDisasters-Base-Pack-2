AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Dorothy IV"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.Mass                             =  2000

ENT.AutomaticFrameAdvance            = true 

function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel("models/ramses/models/equipment/dorothy.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		

		local phys = self:GetPhysicsObject()
		


		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
			phys:Wake()
			phys:EnableMotion(true)
		end 		


		self:ResetSequence(self:LookupSequence("idle"))
		self:SetPlaybackRate( 3 )	
		self.Roll = 0
	
		
		
	end
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 100   ) 
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:TurnProp()
	local rate = engine.TickInterval()
	local bone = self:LookupBone("prop")
	local pos, ang = self:GetBonePosition( bone )
	
	local ms_windspeed = convert_SUtoMe(self:GetVelocity():Length())
	local radius       = 0.1 -- radius of prop
	local circum       = math.pi * radius 
	local t            = circum / ms_windspeed 
	
	local ang_vel      = (math.deg((math.pi * 2) / t ) * rate) * 0.05 
	
	self.Roll = self.Roll + ang_vel
	
	self:ManipulateBoneAngles( bone, Angle(self.Roll, 0,0))
	
end

function ENT:Think()
	
	if (SERVER) then
		if !self:IsValid() then return end
	

		self:TurnProp()
		self:NextThink( CurTime() )
		return true
	end
end

if (SERVER) then 


	concommand.Add("grass", function(ply)
	

		
		local pos = ply:GetPos()
		
		local models = {"models/props_foliage/grass_02_detailmodel.mdl", "models/props_foliage/grass_02_cluster01.mdl", "models/props_foliage/grass_02_cluster01.mdl"}
		
		for x=-25, 25 do
			
			for y=-25, 25 do
				local prop = ents.Create("prop_dynamic")
				prop:SetModel(table.Random(models) )
				prop:SetPos( Vector(x * 150, y * 150, 0) + pos + ( Vector(VectorRand().x, VectorRand().y, 0) * math.random(1,300)) )
				prop:Spawn()
				prop:SetModelScale( prop:GetModelScale() * (math.random(10,20)/10))
				prop:DrawShadow( false )
				prop:SetAngles( Angle(0,math.random(0,360),0))
			end
		
		end
		
	
	
	end)
end



function ENT:Draw()



	self:DrawModel()
	
end




