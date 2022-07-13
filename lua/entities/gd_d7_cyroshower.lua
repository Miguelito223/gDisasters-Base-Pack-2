AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Megacryometeor Shower"
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
		if IsMapRegistered() == true then
		self:SetPos(getMapCenterFloorPos())
		end
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:SetMaterial(self.Material)
		local phys = self:GetPhysicsObject()

		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		

		self:SetNoDraw(true)
		
		
	end
end


function ENT:SpawnCyro()

	if HitChance(2) then
	
		local bounds    = getMapSkyBox()
		local min       = bounds[1]
		local max       = bounds[2]
		
		local startpos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,   max.z )

			
		local tr = util.TraceLine( {
		start  = startpos,
		endpos    = startpos + Vector(0,0,50000),
		} )
		

			local hail = ents.Create("gd_d4_mcryometeor_ch")
			
			hail:SetPos( tr.HitPos - Vector(0,0,1000) )
			hail:Spawn()
			hail:Activate()
			hail:GetPhysicsObject():EnableMotion(true)
			hail:GetPhysicsObject():SetVelocity( Vector(0,0,-5000)  )
			hail:GetPhysicsObject():AddAngleVelocity( VectorRand() * 100 )
			
			timer.Simple( math.random(14,18), function()
				if hail:IsValid() then hail:Remove() end
				
			end)
			
	
	end

	
	
end

function ENT:Think()
	if (SERVER) then
		if !self:IsValid() then return end
		local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1
		
		self:SpawnCyro()
		self:NextThink(CurTime() + t)
		return true
	end
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

function ENT:OnRemove()

end

function ENT:Draw()



	self:DrawModel()
	
end


