AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Zombie Apocalypse"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

    
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"

function ENT:Initialize()	

	if (SERVER) then
		
		self.Zombies = {}
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		if IsMapRegistered() == true then
		self:SetPos(getMapCenterFloorPos())
		else
		end
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		local phys = self:GetPhysicsObject()

		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		
		for k, v in pairs( ents.FindByClass( "env_sun" ) ) do
		if IsValid( v ) then 
		v:Fire( "TurnOff", "", 0 )
		
			end

		end	
			
	if GetConVar("gdisasters_atmosphere"):GetInt() >= 1 and #ents.FindByClass("gd_w*") == 0 then 
	
		
		self.Original_SkyData = {}
			self.Original_SkyData["TopColor"]    = Vector(1,0,0)
			self.Original_SkyData["BottomColor"] = Vector(0.5,0.1,0.1)
			self.Original_SkyData["DuskScale"]      = 0.2
			self.Original_SkyData["DuskIntensity"]   = 0.00
			
			
			
		self.Reset_SkyData    = {}
			self.Reset_SkyData["TopColor"]       = Vector(0.20,0.50,1.00)
			self.Reset_SkyData["BottomColor"]    = Vector(0.80,1.00,1.00)
			self.Reset_SkyData["DuskScale"]      = 1
			self.Reset_SkyData["DuskIntensity"]      = 1

		
		for i=0, 100 do
			timer.Simple(i/100, function()
				if !self:IsValid() then return  end
				paintSky_Fade(self.Original_SkyData, 0.05)
			end)
		end
		
		
		setMapLight("g")	
		
		self:FogSpawn()
		
		self:SetNoDraw(true)
		
		end
	end
end

function ENT:SpawnZombies()

	if HitChance(8) then
	
		local bounds    = getMapSkyBox()
		local min       = bounds[1]
		local max       = bounds[2]
		
		local startpos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,   max.z )

			
		local tr = util.TraceLine( {
		start  = startpos,
		endpos    = startpos - Vector(0,0,50000),
		} )
		
	
			local zom = ents.Create( table.Random({"npc_zombie","npc_fastzombie","npc_zombie_torso","npc_fastzombie_torso"}) )
			if ( !IsValid( self ) )  then return end
			zom:Spawn()
			zom:SetPos( tr.HitPos + Vector(0,0,2) )
			zom:SetSchedule( SCHED_AISCRIPT )
			table.insert(self.Zombies, zom)
			
		
		
		end
	
	for k, v in pairs(ents.GetAll()) do
	
		if v:IsNPC() then 
		if !IsValid( v ) or ( !IsValid( self ) ) or (v:GetClass()== "npc_zombie" or v:GetClass()== "npc_fastzombie" or v:GetClass()== "npc_zombie_torso" or v:GetClass()== "npc_fastzombie_torso") then return end
		
		local npcpos = v:GetPos()
		local zom = ents.Create( table.Random({"npc_zombie","npc_fastzombie"}) )
		if ( !IsValid( v ) ) then return end
		local ang = v:GetAngles()
		v:Remove()
		zom:Spawn()
		zom:SetPos ( npcpos + Vector(0,0,2) )
		zom:SetAngles(ang)
		zom:SetSchedule( SCHED_AISCRIPT )
		
						end
			end

end

function ENT:FogSpawn()

	local ent = ents.Create("edit_fog")
		ent:SetPos(Vector(0,0,-100000))
		ent:Spawn()
		ent:Activate()
		ent:SetNoDraw(true)
		local FogColor = Vector(0.25,0.05,0.05)	
		local FogDensity = 0.56
		ent:SetFogColor( FogColor )
		ent:SetDensity( FogDensity )
		table.insert(self.Zombies, ent)

end


function ENT:Think()
	if (SERVER) then
	local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1
	
		if #ents.FindByClass("gd_w*") >= 1 then 

		self:Remove()
	
		end
	
		if !self:IsValid() then return end
		self:GetPhysicsObject():EnableMotion(false)
		self:SpawnZombies()
		
		self:NextThink(CurTime() + t)
		
		return true
	end
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	if #ents.FindByClass("gd_d6_zombieapoc") >= 1 then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal    ) 
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:OnRemove()

	if (SERVER) then	
		
	for k, v in pairs(self.Zombies) do
	if IsValid( v ) then v:Remove() end 
	
		end
		
	for k, v in pairs( ents.FindByClass( "env_sun" ) ) do
	v:Fire( "TurnOn", "", 0 )
		
	end		
		
	if GetConVar("gdisasters_atmosphere"):GetInt() >= 1 and #ents.FindByClass("gd_w*") == 0 then 
		
		
	local resetdata = self.Reset_SkyData
	GLOBAL_SYSTEM_TARGET=GLOBAL_SYSTEM_ORIGINAL

	for i=0, 40 do
		timer.Simple(i/100, function()
			paintSky_Fade(resetdata,0.05)
			end)
			
		end
		
		setMapLight("t")		
		
		end
			
		
	end

end

function ENT:Draw()



	self:DrawModel()
	
end


