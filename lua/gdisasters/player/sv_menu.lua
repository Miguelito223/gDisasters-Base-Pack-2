
util.AddNetworkString("gdisasters_clmenu_vars")

net.Receive( "gdisasters_clmenu_vars", function( len, pl ) 
	if !pl:IsAdmin() or !pl:IsSuperAdmin() then return end
	
	local cvar = net.ReadString();
	local val = net.ReadFloat();

	if( GetConVar( tostring( cvar ) ) == nil ) then return end
	if( GetConVar( tostring( cvar ) ):GetInt() == tonumber( val ) ) then return end

	game.ConsoleCommand( tostring( cvar ) .." ".. tostring( val ) .."\n" );

end );
