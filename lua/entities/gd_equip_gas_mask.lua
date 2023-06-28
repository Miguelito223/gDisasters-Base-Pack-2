AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Gas Mask"
ENT.Author		= ""
ENT.Information		= ""
ENT.Category		= "GB5: Protection"

ENT.Editable		= false
ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.Contact			                 =  ""  

sound.Add( {
	name = "breathing",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 50,
	pitch = {90, 100},
	sound = "player/breathe1.wav"
})

function ENT:SpawnFunction( ply, tr )
	if ( not tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create( "gd_equip_gas_mask" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

if SERVER then
	function ENT:Initialize()
		self.Entity:SetModel("models/Items/item_item_crate.mdl")
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then	
			phys:Wake()
		end	
		local ent = ents.Create( "prop_physics" )
		ent:SetModel("models/barneyhelmet_faceplate.mdl")
		ent:SetPos( Vector(self:GetPos().x,self:GetPos().y,self:GetPos().z+30 ))
		ent:Spawn()
		ent:Activate()
		ent:SetParent( self ) 
		
		local ent = ents.Create( "prop_physics" )
		ent:SetModel("models/barneyhelmet.mdl")
		ent:SetPos( Vector(self:GetPos().x,self:GetPos().y,self:GetPos().z+30 ))
		ent:Spawn()
		ent:Activate()
		ent:SetParent( self ) 
	end
end

if SERVER then
	function ENT:Use( activator, caller )
		if activator.gasmasked==true or activator.hazsuited==true then
			activator:EmitSound("items/suitchargeno1.wav", 50, 100)
		else		
			activator:EmitSound("streams/others/protection_used.wav",50,100)
			activator.gasmasked=true
			activator:EmitSound("breathing")
			net.Start( "gd_net" )        
			net.WriteBit( true )
			net.Send(activator)
			
			self:Remove()
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()

		local squad = self:GetNetworkedString( 12 )
		if ( LocalPlayer():GetEyeTrace().Entity == self.Entity and EyePos():Distance( self.Entity:GetPos() ) < 256 ) then
		AddWorldTip( self.Entity:EntIndex(), ( "Gas Mask" ), 0.5, self.Entity:GetPos(), self.Entity  )
		end
	end

	language.Add( 'Gas Mask', 'Gas Mask' )
end

