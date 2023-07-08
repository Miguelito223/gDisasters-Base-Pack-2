local rootDirectory = "materials/decals"

local function AddFile( File, directory )
	local name = File:match("(.+)%..+$")

	game.AddDecal( name, directory .. name )
	print( "[GDISASTERS AUTOLOAD] ADDING: " .. File )
end

local function IncludeDir( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "THIRDPARTY" )

	for _, v in ipairs( files ) do

		AddFile( v, directory )

	end

	for _, v in ipairs( directories ) do
		print( "[GDISASTERS AUTOLOAD] Directory: " .. v )
		IncludeDir( directory .. v )
	end
end

IncludeDir( rootDirectory )