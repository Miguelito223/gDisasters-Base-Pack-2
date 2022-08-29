AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Landslide"

ENT.Mass                             =  100
ENT.Model                            =  "models/ramses/models/nature/landslide_mount.mdl"

function ENT:Initialize()
   	self:DrawShadow( false)
	
	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetUseType( ONOFF_USE )

		
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
			phys:EnableMotion(false)
			
		end

		self.IsGoingTolandslide = false
    end
end

function ENT:CreateLandsliderocks(num, lifetime)
    pos = self:GetPos() + Vector(math.random(0, 100), math.random(0, 100), 1995)
    models = {"models/ramses/models/nature/landmass_2.mdl", "models/ramses/models/nature/landmass_1.mdl", "models/ramses/models/nature/rock_1.mdl", "models/ramses/models/nature/rock_3.mdl"}
    for i=1, num do
        local rock = ents.Create("prop_physics")
        rock:SetModel(table.Random(models))
        rock:SetPos(pos)
        rock:Spawn()
        rock:Activate()

		rock:GetPhysicsObject():SetVelocity( Vector(math.random(-1100,1100), math.random(-1100, 1100), math.random(-2100,-5500)))

        timer.Simple(math.random(lifetime[1], lifetime[2]), function()
			if rock:IsValid() then rock:Remove() end 
		end)
    end
end

function ENT:LandslideAction()
	CreateSoundWave("streams/disasters/earthquake/earthquake_strong.wav", self:GetPos(), "stereo" ,340.29/2, {100,100}, 5)
	self:CreateLandsliderocks(20, {8, 10})
end

function ENT:Timer()
	timer.simple(math.random(100,500) function()
		if self.IsGoingTolandslide == false then
			self.IsGoingTolandslide = true
			timer.simple(math.random(10,20) function()
				self:LandslideAction()
				self.IsGoingTolandslide = false
			end)
		end
	end)
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 85  ) 
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Think()
    if (SERVER) then
        if !self:IsValid() then return end
		local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1

        self:SetPos(self:GetPos())
		self:GetPhysicsObject():EnableMotion(false)
		self:SetAngles(self:GetAngles())
		self:Timer()

        self:NextThink(CurTime() + t)
        return true	
    end
end

function ENT:OnRemove()
end

function ENT:Draw()

	self:DrawModel()


end