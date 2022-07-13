AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "The Man In Gauze"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Material                         = "nature/ice"        
ENT.Mass                             =  100
ENT.Model                            =  "models/ramses/models/furniture/player.mdl"
ENT.AutomaticFrameAdvance            = true 

function ENT:Initialize()	

	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )

		local phys = self:GetPhysicsObject()

		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		
	
		self:SetAngles( Angle(0,math.random(1,180), 0))
		self:ResetSequence(self:LookupSequence("idle"))
		self:SetPlaybackRate( 4 )
		timer.Simple(8, function()
			if !self:IsValid() then return end
			gDisasters_CreateGlobalGFX("kingramses", self)
			self.KingRamses = true
		end)
		
		timer.Simple(40, function()
			if !self:IsValid() then return end
			self:Remove()
		end)
		
		CreateSoundWave("disasters/wtf/kingramses.mp3", self:GetPos(), "mono" ,340.29/2, {100,100}, 10)

		
	end
end



function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * -6    ) 
	ent:Spawn()
	ent:Activate()
	return ent
end



function ENT:PlayScratchingEffect()
	
	local pos = self:GetAttachment( 1 ).Pos + (self:GetUp() * -31) + ( self:GetRight() *  3)  + ( self:GetForward() *  1)
	ParticleEffect("king_ramses_player_scrape_sparks_main", pos, Angle(0,0,0), nil)
	

end

function ENT:KingRamsed()
	if !self.KingRamses then return end
	
	for k, v in pairs(player.GetAll()) do
	
		
		SetOffsetAngles(v, Angle(math.random(-10,10),math.random(-10,10),math.random(-10,10)))
	end
end

function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		self:KingRamsed()
		self:PlayScratchingEffect()
		self:NextThink(CurTime() + 0.1)
		return true
	end
end

function ENT:OnRemove()
end

function ENT:Draw()



	self:DrawModel()
	
end




