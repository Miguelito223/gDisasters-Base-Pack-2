print("[GDISASTERS AUTOLOAD] INCLUDING LUA FILES...")

local rootDirectory = "gdisasters"

local function AddFile( File, directory )
	if string.StartWith(File, "_sv_") or string.StartWith(File, "sv_") then
		if SERVER then
			include( directory .. File )
			print( "[GDISASTERS AUTOLOAD] SERVER INCLUDE: " .. File )
		end
	elseif string.StartWith(File, "_sh_") or string.StartWith(File, "sh_") then
		if SERVER then
			AddCSLuaFile( directory .. File )
			print( "[GDISASTERS AUTOLOAD] SHARED ADDCS: " .. File )
		end
		include( directory .. File )
		print( "[GDISASTERS AUTOLOAD] SHARED INCLUDE: " .. File )
	elseif string.StartWith(File, "_cl_") or string.StartWith(File, "cl_") then
		if SERVER then
			AddCSLuaFile( directory .. File )
			print( "[GDISASTERS AUTOLOAD] CLIENT ADDCS: " .. File )
		elseif CLIENT then
			include( directory .. File )
			print( "[GDISASTERS AUTOLOAD] CLIENT INCLUDE: " .. File )
		end
	end
end

local function loadfiles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "LUA" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".lua" ) then
			AddFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		print( "[GDISASTERS AUTOLOAD] Directory: " .. v )
		loadfiles( directory .. v )
	end
end

loadfiles( rootDirectory )

print("[GDISASTERS AUTOLOAD] FINISH")