print("[GDISASTERS AUTOLOAD] LOADING DECALS...")

local root_Directory = debug.getinfo(1).short_src:match("(addons/.-)/")

local function AddFile( File, directory )
	local name = File:match("(.+)%..+$")
	local directory_fixed = directory:match("materials/(.-)/")

	game.AddDecal( name, directory_fixed .. "/" .. name )
	print( "[GDISASTERS AUTOLOAD] ADDING: " .. File )
end

local function loadfiles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "game" )

	for _, v in ipairs( files ) do

		AddFile( v, directory )

	end

	for _, v in ipairs( directories ) do
		print( "[GDISASTERS AUTOLOAD] Directory: " .. v )
		loadfiles( directory .. v )
	end
end

loadfiles( root_Directory .. "/materials/decals" )

print("[GDISASTERS AUTOLOAD] FINISH")