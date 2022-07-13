AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Lightning Bolt"

ENT.Material                         = "models/rendertarget"        
ENT.Mass                             =  100
ENT.Models                           =  {"models/props_junk/PopCan01a.mdl"}  


function ENT:Initialize()	

	if (SERVER) then
		
		self:SetModel(table.Random(self.Models))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetPersistent(true)
		
		self.Effects = {}
		self.Effects["blue"]={}
		self.Effects["purple"]={}
		self.Effects["blue"]["Grounded"] = {"LIGHTNING_STRIKE_BLUE_1", "LIGHTNING_STRIKE_BLUE_2", "LIGHTNING_STRIKE_BLUE_3"}
		self.Effects["blue"]["NotGrounded"] = {"LIGHTNING_STRIKE_BLUE_1_NON_GROUNDED", "LIGHTNING_STRIKE_BLUE_2_NON_GROUNDED", "LIGHTNING_STRIKE_BLUE_3_NON_GROUNDED"}

		self.Effects["purple"]["Grounded"] = {"LIGHTNING_STRIKE_PURPLE_1", "LIGHTNING_STRIKE_PURPLE_2", "LIGHTNING_STRIKE_PURPLE_3"}
		self.Effects["purple"]["NotGrounded"] = {"LIGHTNING_STRIKE_PURPLE_1_NON_GROUNDED", "LIGHTNING_STRIKE_PURPLE_2_NON_GROUNDED", "LIGHTNING_STRIKE_PURPLE_3_NON_GROUNDED"}
		

		
		self:LightningType()


		
	end
end

function ENT:LightningType()
	if self.TargetPositions == nil then return end 
	
	self:PositionBolt()

end

function ENT:PositionBolt()
	
	local startpos = self.TargetPositions[1]
	self:SetPos(startpos)
	
	
	self:Smite()



end

function ENT:CreateTarget()
	local endpos = self.TargetPositions[2]
	
	local ent = ents.Create("prop_physics")
	ent:SetModel("models/props_junk/PopCan01a.mdl")

	ent:SetPos(endpos)
	ent:Spawn()
	ent:Activate()

	
	

	
	return ent 
	
end


function ENT:Smite()


	
	
	local target = self:CreateTarget()
	
	local particle  = ""
	local explosion = ""
	local color     = table.Random(self.ParticleData["Color"])
	local grounded  = table.Random(self.ParticleData["IsGrounded"])
	local sounds = {"disasters/nature/closethunder02.mp3","disasters/nature/closethunder03.mp3","disasters/nature/closethunder04.mp3","disasters/nature/closethunder05.mp3"}

	particle =  table.Random(self.Effects[color][grounded])
	
	if grounded == "Grounded" then
		if color =="blue" then
			explosion = table.Random({"LIGHTNING_STRIKE_EXPLOSION_MAIN", "LIGHTNING_STRIKE_EXPLOSION_MAIN_2","LIGHTNING_STRIKE_EXPLOSION_MAIN_3","LIGHTNING_STRIKE_EXPLOSION_MAIN_4", "LIGHTNING_STRIKE_EXPLOSION_MAIN_5"})
		elseif color == "purple" then
			explosion = table.Random({"LIGHTNING_STRIKE_EXPLOSION_MAIN", "LIGHTNING_STRIKE_EXPLOSION_MAIN_6","LIGHTNING_STRIKE_EXPLOSION_MAIN_7"})

		end
	end
	
	timer.Simple(0.05, function()

		net.Start("gd_lightning_bolt")
		net.WriteEntity(self)
		net.WriteEntity(target)
		net.WriteString(particle)
		
		net.Broadcast()
		
		if explosion != "" then ParticleEffect(explosion, target:GetPos(), Angle(0,0,0), nil) end 
		
		
		CreateSoundWave(table.Random(sounds), target:GetPos(), "stereo" ,340.29/2, {70,120}, 0.5)
		
	end)

	
	

	
	timer.Simple(0.5, function()
		if self:IsValid() then
			self:Remove()
		end
		if target:IsValid() then 
			target:Remove()
		end
	end)
	
		
	
end


function CreateLightningBolt(startpos, endpos, color, grounded)
	local ent = ents.Create("gd_lightningbolt")
	ent:SetPos(Vector(0,0,0))
	ent.TargetPositions = {startpos, endpos}
	ent.ParticleData = { ["Color"] = color, ["IsGrounded"] = grounded}	
	ent:Spawn()
	ent:Activate()
end

function ENT:Explode()
	local pe = ents.Create( "env_physexplosion" );
	pe:SetPos(self:GetPos());
	pe:SetKeyValue( "Magnitude", 5000 );
	pe:SetKeyValue( "radius", 4000 );
	pe:SetKeyValue( "spawnflags", 19 );
	pe:Spawn();
	pe:Activate();
	pe:Fire( "Explode", "", 0 );
	pe:Fire( "Kill", "", 0.5 );
	
	util.BlastDamage( self, self, self:GetPos()+Vector(0,0,12), 3200, math.random( 1, 8 ) )
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end


