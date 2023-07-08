print("loading decals...")

local root_folder_name = debug.getinfo(1).short_src:match("materials/decals")

local function RunFile(file_path)
	local file = file_path:match(".+/(.+)")
	local name = file_path:match(".+/(.+)%..+$")
	local file_path_fixed = file_path:match(".-/(.+)%..+$")

	if !file:EndsWith(".vmt") then return end

	print("loading file: " .. file_path_fixed )

	game.AddDecal( name, file_path_fixed )

	print("completed")
end

function LoadFiles(file_path)
	local files, folders = file.Find(file_path .. "/*", "THIRDPARTY")
	
	if !table.IsEmpty(folders) then
		for _, folder_name in next, folders do
			if folder_name == "." or folder_name == ".." then continue end
            
			local path = ("%s/%s"):format(file_path, folder_name)
			
			LoadFiles(path)
		end
	end
	
	if !table.IsEmpty(files) then
		for i = 1, #files do
			local file = files[i]
			
			RunFile(file_path .. "/" .. file)
		end
	end
end

LoadFiles(root_folder_name)

print("finish")