AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Shooting Star Shower"
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
		self:SetMaterial(self.Material)
		local phys = self:GetPhysicsObject()

		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 
		if IsMapRegistered() == true then
			self:SetPos(getMapCenterFloorPos())
		else
			self:Remove()
			for k, v in pairs(player.GetAll()) do 
				v:ChatPrint("This map is incompatible with this addon! Tell the addon owner about this as soon as possible and change to gm_flatgrass or construct.") 
			end 
		end		

		self:SetNoDraw(true)
		
		
	end
end

function ENT:CreateHail()

	if HitChance(24) then
	
		local bounds    = getMapSkyBox()
		local min       = bounds[1]
		local max       = bounds[2]

		if #ents.FindByClass("gd_d2_shootingstar") < 1 then 
		
		
			

			local star = ents.Create("gd_d2_shootingstar_ch")
			star:Spawn()
			star:Activate()	
			star:SetPos( Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,   max.z ) )
			star:GetPhysicsObject():EnableMotion(true)
			star:GetPhysicsObject():AddAngleVelocity( VectorRand() * 100 )
			
			timer.Simple( math.random(14,18), function()
				if star:IsValid() then star:Remove() end
				
			end)
			
		
		end
	
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


function ENT:Think()
	if (SERVER) then
		local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1
	
		if !self:IsValid() then return end
		self:CreateHail()
		self:NextThink(CurTime() + t)
		return true
	end
end



function ENT:OnRemove()
end

function ENT:Draw()



	self:DrawModel()
	
end




