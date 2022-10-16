AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Ice"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"


ENT.Mass                             =  100
ENT.Model                           = "models/ramses/models/nature/blockofice.mdl"


function ENT:Initialize()	
	self.SpawnTime = CurTime()
	
	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:EnableMotion(true)
			
		end
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		
		ParticleEffectAttach("megacryometeor_piece_steam_2", PATTACH_POINT_FOLLOW, self, 0)
		
		timer.Simple(20, function() if !self:IsValid() then return end self:Remove() end)
		
	end
end

function ENT:SetMDScale(scale)
	local mat = Matrix()
	mat:Scale(scale)
	self:EnableMatrix("RenderMultiply", mat)
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal    ) 
	ent:Spawn()
	ent:Activate()
	return ent
end




function ENT:Shrink()
	self:SetMDScale(Vector(1,1,1) * math.Clamp( 1-( (CurTime() - self.SpawnTime)/20), 0,1))
	
end


function ENT:Think()
	if (CLIENT) then
		self:Shrink()
	end

	if (SERVER) then
		if !self:IsValid() then return end

		
		self:NextThink(CurTime() + 1)
		return true
	end
end

function ENT:OnRemove()
end

function ENT:Draw()



	self:DrawModel()
	
end




