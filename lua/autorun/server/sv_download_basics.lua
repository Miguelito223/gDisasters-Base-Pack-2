local rootDirectory = "materials"
local rootDirectory2 = "sounds"

local function AddFile( File, directory )
	resource.AddSingleFile( directory .. File )
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
IncludeDir( rootDirectory2 )

