AddCSLuaFile()

print("Downloading textures and sounds for client...")

local root_folder_name = debug.getinfo(1).short_src:match("materials")
local root_folder_name2 = debug.getinfo(1).short_src:match("sounds")

local function RunFile(file_path)
	local file = file_path:match(".+/(.+)")
	
	if !file:EndsWith(".mp3") and !file:EndsWith(".wav") and !file:EndsWith(".vtf") and !file:EndsWith(".vmt") then return end

	print("loading file: " .. file_path)
	
	resource.AddSingleFile(file_path)
	
	print("completed")
end

function LoadFiles(file_path)
	file_path = file_path or root_folder_name or root_folder_name2
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

LoadFiles("materials")
LoadFiles("sounds")

print("Finish")

