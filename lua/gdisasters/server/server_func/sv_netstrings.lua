
util.AddNetworkString( "gd_clmenu_vars" )
util.AddNetworkString( "gd_isOutdoor" )
util.AddNetworkString( "gd_clParticles" )
util.AddNetworkString( "gd_clParticles_ground" )
util.AddNetworkString( "gd_CreateCeilingWaterDrops" )		
util.AddNetworkString( "gd_RemoveCeilingWaterDrops" )	
util.AddNetworkString( "gd_screen_particles" )	
util.AddNetworkString( "gd_maplight_cl")
util.AddNetworkString( "gd_seteyeangles_cl")
util.AddNetworkString( "gd_vomit")
util.AddNetworkString( "gd_vomit_blood")
util.AddNetworkString( "gd_sneeze")
util.AddNetworkString( "gd_sneeze_big")
util.AddNetworkString( "gd_lightning_bolt")
util.AddNetworkString( "gd_createdecals")
util.AddNetworkString( "gd_sendsound"	)
util.AddNetworkString( "gd_ambientlight"	)
util.AddNetworkString( "gd_shakescreen"	)
util.AddNetworkString( "gd_soundwave" )

util.AddNetworkString( "gd_entity_exists_on_server" )

util.AddNetworkString( "gd_createfog" )
util.AddNetworkString( "gd_creategfx" )

util.AddNetworkString( "gd_removegfxfog" )
util.AddNetworkString( "gd_resetoutsidefactor" )


net.Receive( "gd_clmenu_vars", function( len, pl )
	if !pl:IsAdmin() or !pl:IsSuperAdmin() then return end
	
	local cvar = net.ReadString();
	local val = net.ReadFloat();

	if( GetConVar( tostring( cvar ) ) == nil ) then return end
	if( GetConVar( tostring( cvar ) ):GetInt() == tonumber( val ) ) then return end

	game.ConsoleCommand( tostring( cvar ) .." ".. tostring( val ) .."\n" );
end)

net.Receive("gd_ambientlight", function()
	local ent = net.ReadEntity()
	local aLL = net.ReadVector()
	ent.AmbientLight = aLL
	

end)

net.Receive( "gd_entity_exists_on_server", function() 
	
	local string = net.ReadString()
	
	gDisasters.CachedExists[string] = ents.Create(string)
	gDisasters.CachedExists[string]:Spawn()
	gDisasters.CachedExists[string]:Activate()
end)

net.Receive("gd_vomit_blood", function()
	
	local ent = net.ReadEntity()
	local mouth_attach = ent:LookupAttachment("mouth")
	ent:EmitSound("streams/disasters/player/vomitblood.wav", 80, 100)
	ParticleEffectAttach( "vomit_blood_main", PATTACH_POINT_FOLLOW, ent, mouth_attach )

end)

net.Receive("gd_vomit", function()
	
	local ent = net.ReadEntity()
	local mouth_attach = ent:LookupAttachment("mouth")
	ent:EmitSound("streams/disasters/player/vomit.wav", 80, 100)
	ParticleEffectAttach( "vomit_main", PATTACH_POINT_FOLLOW, ent, mouth_attach )

end)

net.Receive("gd_sneeze", function()
	
	local ent = net.ReadEntity()
	local mouth_attach = ent:LookupAttachment("mouth")
	ent:EmitSound("streams/disasters/player/vomit.wav", 80, 100)
	ParticleEffectAttach( "sneeze_main", PATTACH_POINT_FOLLOW, ent, mouth_attach )

end)
net.Receive("gd_sneeze_big", function()
	
	local ent = net.ReadEntity()
	local mouth_attach = ent:LookupAttachment("mouth")
	ent:EmitSound("streams/disasters/player/vomitblood.wav", 80, 100)
	ParticleEffectAttach( "sneeze_big_main", PATTACH_POINT_FOLLOW, ent, mouth_attach )

end)
	
