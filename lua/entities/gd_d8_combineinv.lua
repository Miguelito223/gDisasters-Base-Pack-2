AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Combine Invasion"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

    
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"

function ENT:Initialize()	

	if (SERVER) then
		
		self.Combines = {}
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		if IsMapRegistered() == true then
			self:SetPos(getMapCenterFloorPos())
		else
			self:Remove()
			for k, v in pairs(player.GetAll()) do 
				v:ChatPrint("This map is incompatible with this addon! Tell the addon owner about this as soon as possible and change to gm_flatgrass or construct.") 
			end 
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
			
	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() >= 1 and #ents.FindByClass("gd_w*") == 0 then 
	
		
		self.Original_SkyData = {}
			self.Original_SkyData["TopColor"]    = Vector(0.45,0.447,0.274)
			self.Original_SkyData["BottomColor"] = Vector(0.243,0.223,0.137)
			self.Original_SkyData["DuskScale"]      = 0.0
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

function ENT:SpawnCombine()

	if HitChance(8) then
	
		local bounds    = getMapSkyBox()
		local min       = bounds[1]
		local max       = bounds[2]
		
		local startpos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,   max.z )

			
		local tr = util.TraceLine( {
			start  = startpos,
			endpos    = startpos - Vector(0,0,50000),
		} )
		
	
		local com = ents.Create( table.Random({"npc_combine_s","npc_clawscanner","npc_cscanner","npc_strider","npc_combinegunship","npc_helicopter","npc_metropolice"}) )
		if ( !IsValid( self ) )  then return end
		com:Spawn()
		com:SetPos( tr.HitPos + Vector(0,0,456) )
		com:SetSchedule( SCHED_AISCRIPT )
		table.insert(self.Combines, com)
			
		
		
	end
	
	for k, v in pairs(ents.GetAll()) do
	
		if v:IsNPC() or v:IsNextBot() then 
			if !IsValid( v ) or ( !IsValid( self ) ) or (v:GetClass()== "npc_combine_s" or v:GetClass()== "npc_metropolice" or v:GetClass()== "npc_strider" or v:GetClass()== "npc_clawscanner") then return end
			
			local npcpos = v:GetPos()
			local com = ents.Create( table.Random({"npc_combine_s","npc_metropolice"}) )
			
			if ( !IsValid( v ) ) then return end

			local ang = v:GetAngles()
			v:Remove()
			com:Spawn()
			com:SetPos ( npcpos + Vector(0,0,456) )
			com:SetAngles(ang)
			com:SetSchedule( SCHED_AISCRIPT )
		
		end
	end

end

function ENT:FogSpawn()

	local ent = ents.Create("edit_fog")

	ent:SetPos(Vector(0,0,-100000))
	ent:Spawn()
	ent:Activate()
	ent:SetNoDraw(true)

	local FogColor = Vector(0.374,0.5,0.584)	
	local FogDensity = 0.74
	
	ent:SetFogColor( FogColor )
	ent:SetDensity( FogDensity )
	table.insert(self.Combines, ent)

end


function ENT:Think()
	if (SERVER) then
	local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1
	
		if #ents.FindByClass("gd_w*") >= 1 then 

		self:Remove()
	
		end
	
		if !self:IsValid() then return end
		self:GetPhysicsObject():EnableMotion(false)
		self:SpawnCombine()
		
		self:NextThink(CurTime() + t)
		
		return true
	end
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	if #ents.FindByClass("gd_d8_combineinv") >= 1 then return end

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
		
	for k, v in pairs(self.Combines) do
	if IsValid( v ) then v:Remove() end 
	
		end
		
	for k, v in pairs( ents.FindByClass( "env_sun" ) ) do
	v:Fire( "TurnOn", "", 0 )
		
	end		
		
	if GetConVar("gdisasters_graphics_atmosphere"):GetInt() >= 1 and #ents.FindByClass("gd_w*") == 0 then 
		
		
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


