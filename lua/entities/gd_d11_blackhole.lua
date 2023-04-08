AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.PrintName = "Black Hole"

ENT.Mass = 100
ENT.RealMass = 5*(10^16)

ENT.Model = "models/hunter/misc/sphere375x375.mdl"
ENT.Material = "space/models/black_hole/main"

function ENT:Initialize()
	if (SERVER) then

    	self:SetModel(self.Model)
		self:SetMaterial(self.Material)
    	self:SetColor(Color(0, 0, 0))
    	self:PhysicsInit( SOLID_VPHYSICS )
    	self:SetSolid( SOLID_VPHYSICS )
    	self:SetMoveType( MOVETYPE_NONE )
		self:DrawShadow(false)

    
    	local phys = self:GetPhysicsObject()

    	if (phys:IsValid()) then
			self:SetTrigger(true)
        	phys:SetMass(self.Mass)
        	phys:EnableMotion(true)
        	phys:Wake()
    	end
    
    	self:SoundLoop()
    	self:LockPosition()

		ParticleEffectAttach("micro_blackhole_effect", PATTACH_POINT_FOLLOW, self, 0)
	end
end

function ENT:SpawnFunction(ply, tr, ClassName)
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 100  ) 
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Touch(entity)
    if entity:IsPlayer() then
        entity:Kill()
        entity:Remove()
    elseif entity ~= self then
		entity:Remove()
    end

end

function ENT:LockPosition()
	self.LockedPosition = self:GetPos()
end

function ENT:SoundLoop()
    local sound = Sound("streams/disasters/space/neutron_star/idle.wav")

	CSPatch = CreateSound(self, sound)
	CSPatch:SetSoundLevel( 140 )
	CSPatch:Play()
	CSPatch:ChangeVolume( 1 )
	self.Sound = CSPatch

end


function CalculateNewtonianForce(M1, M2, r) 
	
	local G = 6.67*(10^-11)
	local F = (G*(M1*M2))/ (r^2)
	
	
	
	return F

end

function EnableGlobalGravity(bool)
	for k, v in pairs(ents.GetAll()) do 
	
		if v:IsPlayer() and bool==false then
			v:SetMoveType(MOVETYPE_FLY)
		elseif v:IsPlayer() and bool==true then
			v:SetMoveType(MOVETYPE_WALK)
		end
		
		if v:GetPhysicsObject():IsValid() then
			v:GetPhysicsObject():EnableGravity(bool)
		end 
	end
end

function ENT:NewtonianGravity()
	for k, v in pairs(ents.GetAll()) do
		local phys = v:GetPhysicsObject()
		if phys:IsValid() and v:GetClass()!=self:GetClass() and  (v:GetClass()!= "phys_constraintsystem" and v:GetClass()!= "phys_constraint"  and v:GetClass()!= "logic_collision_pair") then
			local M1  = self.RealMass
			local M2  = phys:GetMass()
			
			local p1, p2 = self:GetPos(), v:GetPos()
			
			local r = p1:Distance(p2)
			
			local dir = (p1-p2):GetNormalized()
			local Fr  = (dir * -1*10^9) / ((r+1000)^2)
			local Fg  = CalculateNewtonianForce(M1, M2, r) * dir 
			 
			if v:IsPlayer() or v:IsNPC() or v:IsNextBot() then
				v:SetVelocity(Fg)
				v:SetMoveType( MOVETYPE_FLY )
			else
				if r <= 10000 and v:IsValid() then
					phys:Wake()
					phys:EnableMotion(true)
					constraint.RemoveAll( v )
				end
				phys:AddVelocity( Fg )
			end

		end
	end
end



function ENT:Rotate()
	self:SetAngles( self:GetAngles() - Angle(-0.5,-1,1) )

end

function ENT:OnRemove()
	if (SERVER) then
		EnableGlobalGravity(true)
	end
	if self.Sound==nil then return end
	self.Sound:Stop()

	self:StopParticles()
end

function ENT:Think()
	if (SERVER) then
		if !self:IsValid() then return end
		self:Rotate()
    	self:NewtonianGravity()
		self:NextThink(CurTime() + 0.01)
    	return true	
	end
end

function ENT:Draw()
    self:DrawModel()
end