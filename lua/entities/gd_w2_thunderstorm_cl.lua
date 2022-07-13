AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Lightning Storm"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
    
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"


function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		self:SetNoDraw(true)
		
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
			
		if IsMapRegistered() == false then
			for k, v in pairs(player.GetAll()) do 
				v:ChatPrint("This map is incompatible with this addon! Tell the addon owner about this as soon as possible and change to gm_flatgrass or construct.") 
			end  
		end
	end
end



function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	if IsMapRegistered() == true then
	
	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * -0.7  ) 
	ent:Spawn()

	return ent
	
	end
end

function ENT:CreateBolts()
	
	local bounds    = getMapSkyBox()
	local min       = bounds[1]
	local max       = bounds[2]
	
	local startpos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,  max.z )
	local tr = util.TraceLine( {
		start = startpos,
		endpos = startpos - Vector(0,0,50000),
	} )

	local endpos   = tr.HitPos
	
	if HitChance(1) then
	
	
	
	
		if HitChance(2) then
			local sprite_pos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,  max.z )

			ParticleEffect( table.Random( { "sprite_lightning_main_01", "sprite_lightning_main_02", "sprite_lightning_main_03" } ), sprite_pos - Vector(0,0,math.random(0,2000)), Angle(0,0,0), nil)
		end
		
		if HitChance(1) then
			local elves_pos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,  max.z )

			ParticleEffect( table.Random({"elves_main_01","elves_main_02"}), elves_pos - Vector(0,0,math.random(0,2000)), Angle(0,0,0), nil)
		end		
		
	
		if HitChance(0.1) then
			local blue_jet_pos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,  max.z )

			ParticleEffect( "blue_jet_lightning_01_main", blue_jet_pos - Vector(0,0,math.random(2000,4000)), Angle(0,0,0), nil)
		end			
		CreateLightningBolt(startpos - Vector(0,0,4000), endpos,  {"purple","blue"} ,  {"Grounded","NotGrounded"} )
	end
	
	

end


function ENT:Think()
	if (SERVER) then
		if !self:IsValid() then return end
		local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1

		self:CreateBolts()
		self:NextThink(CurTime() + t)
		return true
		
	end
end

function ENT:OnRemove()
	self:StopParticles()
end

function ENT:Draw()
end




