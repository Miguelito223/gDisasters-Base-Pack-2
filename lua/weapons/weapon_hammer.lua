-----------------------------------------Updated 3.0 9/20/2014--------------------------------------------------|
--Buzzofwar-- Please do not steal or copy this! I  put much effort and time into perfecting it------------------|
----------------------------------------------------------------------------------------------------------------|
------------------------------// General Settings \\------------------------------------------------------------|
SWEP.Author 			= "Buzzofwar"                           -- Your name.
SWEP.Contact 			= "Buzzofwar"                     		-- How People could contact you.
SWEP.base 				= "weapon_base"							-- What base should the swep be based on.
SWEP.ViewModel 			= "models/weapons/v_crowbar.mdl" 									-- The viewModel, the model you see when you are holding it.
SWEP.WorldModel 		= "models/weapons/w_buzzhammer.mdl"   									-- The world model, The model you when it's down on the ground.
SWEP.HoldType 			= "melee"                            		-- How the swep is hold Pistol smg grenade melee.
SWEP.PrintName 			= "Hammer"                         			-- your sweps name.
SWEP.Category 			= "Buildables"                					-- Make your own category for the swep.
SWEP.Instructions 		= ""              						-- How do people use your swep.
SWEP.Purpose 			= ""          							-- What is the purpose with this.
SWEP.AdminSpawnable 	= false                         		-- Is the swep spawnable for admin.
SWEP.ViewModelFlip 		= true									-- If the model should be flipped when you see it.
SWEP.UseHands			= true									-- Weather the player model should use its hands.
SWEP.AutoSwitchTo 		= true                           		-- when someone walks over the swep, should it automatically change to your swep.
SWEP.Spawnable 			= false                              	-- Can everybody spawn this swep.
SWEP.AutoSwitchFrom 	= true                         			-- Does the weapon get changed by other sweps if you pick them up.
SWEP.FiresUnderwater 	= true                       			-- Does your swep fire under water.
SWEP.DrawCrosshair 		= true                           		-- Do you want it to have a crosshair.
SWEP.DrawAmmo 			= true                                 	-- Does the ammo show up when you are using it.
SWEP.ViewModelFOV 		= 0                            		-- How much of the weapon do you see.
SWEP.Weight 			= 0                                   	-- Chose the weight of the Swep.
SWEP.SlotPos 			= 0                                    	-- Decide which slot you want your swep do be in.
SWEP.Slot 				= 0                                     -- Decide which slot you want your swep do be in.
------------------------------\\ General Settings //------------------------------------------------------------|
----------------------------------------------------------------------------------------------------------------|
SWEP.Primary.Automatic 			= false     					-- Do We Have To Click Or Hold Down The Click
SWEP.Primary.Ammo 				= "none"  						-- What Ammo Does This SWEP Use (If Melee Then Use None)   
SWEP.Primary.Damage 			= 0                 			-- How Much Damage Does The SWEP Do                         
SWEP.Primary.Spread	 			= 0                 			-- How Much Of A Spread Is There (Should Be Zero)
SWEP.Primary.NumberofShots 		= 0                 			-- How Many Shots Come Out (should Be Zero)
SWEP.Primary.Recoil 			= 6                 			-- How Much Jump After An Attack        
SWEP.Primary.ClipSize			= 0                 			-- Size Of The Clip
SWEP.Primary.Delay 				= 1                 			-- How longer Till Our Next Attack       
SWEP.Primary.Force 				= 0                 			-- The Amount Of Impact We Do To The World 
SWEP.Primary.Distance 			= 75                			-- How far can we reach?
SWEP.SwingSound					= "weapons/iceaxe/iceaxe_swing1.wav"               				-- Sound we make when we swing
SWEP.WallSound 					= "weapons/crossbow/hit1.wav"            				-- Sound when we hit something
----------------------------------------------------------------------------------------------------------------|
SWEP.Secondary.Automatic 		= false     					-- Do We Have To Click Or Hold Down The Click
SWEP.Secondary.Ammo 			= "none"  						-- What Ammo Does This SWEP Use (If Melee Then Use None)   
SWEP.Secondary.Damage 			= 0                 			-- How Much Damage Does The SWEP Do                         
SWEP.Secondary.Spread	 		= 0                 			-- How Much Of A Spread Is There (Should Be Zero)
SWEP.Secondary.NumberofShots 	= 0                 			-- How Many Shots Come Out (should Be Zero)
SWEP.Secondary.Recoil 			= 6                 			-- How Much Jump After An Attack        
SWEP.Secondary.ClipSize			= 0                 			-- Size Of The Clip
SWEP.Secondary.Delay 			= 1                 			-- How longer Till Our Next Attack       
SWEP.Secondary.Force 			= 0                 			-- The Amount Of Impact We Do To The World 
SWEP.Secondary.Distance 		= 75                			-- How far can we reach?
SWEP.SecSwingSound				= ""               				-- Sound we make when we swing
SWEP.SecWallSound 				= ""            				-- Sound when we hit something 
----------------------------------------------------------------------------------------------------------------|
function SWEP:Initialize()
self:SetWeaponHoldType(self.HoldType)
	if ( SERVER ) then
self:SetWeaponHoldType(self.HoldType)
	end
end
SWEP.Offset = {
Pos = {Up = -5, Right = 1, Forward = 3, },
Ang = {Up = 0, Right = 0, Forward = 90,}
}
function SWEP:DrawWorldModel( )
local hand, offset, rotate
local pl = self:GetOwner()
    if IsValid( pl ) then
local boneIndex = pl:LookupBone( "ValveBiped.Bip01_R_Hand" )
    if boneIndex then
local pos, ang = pl:GetBonePosition( boneIndex )
      pos = pos + ang:Forward() * 		 	self.Offset.Pos.Forward + ang:Right() * self.Offset.Pos.Right + ang:Up() * self.Offset.Pos.Up
      ang:RotateAroundAxis( ang:Up(),    	self.Offset.Ang.Up)
      ang:RotateAroundAxis( ang:Right(), 	self.Offset.Ang.Right )
      ang:RotateAroundAxis( ang:Forward(),  self.Offset.Ang.Forward )
    self:SetRenderOrigin( pos )
    self:SetRenderAngles( ang )
    self:DrawModel()
end
else
    self:SetRenderOrigin( nil )
    self:SetRenderAngles( nil )
    self:DrawModel()
end
end
----------------------------------------------------------------------------------------------------------------|
function SWEP:OnRemove()
return true 
end
----------------------------------------------------------------------------------------------------------------|
function SWEP:Deploy()
self.Owner:DrawViewModel(true)
self.Weapon:EmitSound ""
self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end
----------------------------------------------------------------------------------------------------------------|
function SWEP:OnDrop()
return true 
end
----------------------------------------------------------------------------------------------------------------|
function SWEP:Holster()
self.Weapon:EmitSound ""
return true
end
----------------------------------------------------------------------------------------------------------------|
function SWEP:PrimaryAttack()
local trace = self.Owner:GetEyeTrace()
self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
if trace.HitPos:Distance(self.Owner:GetShootPos()) <= (self.Primary.Distance) then
if ( trace.Hit ) then
self.Weapon:EmitSound(self.WallSound,100,math.random(90,120))
util.Decal("ManhackCut", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
	bullet = {}
	bullet.Num    = 1
	bullet.Src    = self.Owner:GetShootPos()
	bullet.Dir    = self.Owner:GetAimVector()
	bullet.Spread = Vector(0, 0, 0)
	bullet.Tracer = 0
	bullet.Force  = 0
	bullet.Damage = 0
	self.Owner:FireBullets(bullet)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.26 )
	local rnda = self.Primary.Recoil * -1 
	local rndb = self.Primary.Recoil * math.random(-1, 2) 
	self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) ) 
		
else
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
end
else
	self.Weapon:EmitSound(self.SwingSound,100,math.random(90,120))
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	local rnda = self.Primary.Recoil * -1 
	local rndb = self.Primary.Recoil * math.random(-1, 2) 
	self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) ) 
end





// Bail if we hit world or a player
	if (  !trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end
	
	// If there's no physics object then we can't constraint it!
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	local tr = {}
		tr.start = trace.HitPos
		tr.endpos = trace.HitPos + (self:GetOwner():GetAimVector() * 16.0)
		tr.filter = { self:GetOwner(), trace.Entity }
	local trTwo = util.TraceLine( tr )
	
	if ( trTwo.Hit && !trTwo.Entity:IsPlayer() ) then


		// Client can bail now
		if ( CLIENT ) then return true end

		local vOrigin = trace.HitPos - (self:GetOwner():GetAimVector() * 8.0)
		local vDirection = self:GetOwner():GetAimVector():Angle()

		vOrigin = trace.Entity:WorldToLocal( vOrigin )

		// Weld them!
		local constraint, nail = MakeNail( trace.Entity, trTwo.Entity, trace.PhysicsBone, trTwo.PhysicsBone, forcelimit, vOrigin, vDirection )
		if !constraint:IsValid() then return end

		undo.Create("Nail")
		undo.AddEntity( constraint )
		undo.AddEntity( nail )
		undo.SetPlayer( self:GetOwner() )
		undo.Finish()

		self:GetOwner():AddCleanup( "nails", constraint )		
		self:GetOwner():AddCleanup( "nails", nail )

		return true

	end


end

----------------------------------------------------------------------------------------------------------------|
function MakeNail( Ent1, Ent2, Bone1, Bone2, forcelimit, Pos, Ang )

	local constraint = constraint.Weld( Ent1, Ent2, Bone1, Bone2, forcelimit, false )
	
	constraint.Type = "Nail"
	constraint.Pos = Pos
	constraint.Ang = Ang

	Pos = Ent1:LocalToWorld( Pos )

	local nail = ents.Create( "gmod_nail" )
		nail:SetPos( Pos )
		nail:SetAngles( Ang )
		nail:SetParentPhysNum( Bone1 )
		nail:SetParent( Ent1 )

	nail:Spawn()
	nail:Activate()

	constraint:DeleteOnRemove( nail )

	return constraint, nail
end

duplicator.RegisterConstraint( "Nail", MakeNail, "Ent1", "Ent2", "Bone1", "Bone2", "forcelimit", "Pos", "Ang" )




