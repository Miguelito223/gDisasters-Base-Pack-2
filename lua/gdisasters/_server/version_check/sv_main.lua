-- Checks the workshop page for version number.
local function RunCheck()
    http.Fetch(gDisasters.WorkShopURL, function(code)
        local lV = tonumber(string.match(code, "Version:(.-)<"))
        if not lV then return end -- Unable to locate last version
        if gDisasters.Version >= lV then
            print("Version " .. lV .. " is out!")
        else 
            print("Version " .. lV .. " is the newest version")
        end
        cookie.Set("sf_nextv", lV)
    end)
end
local function RunLogic()
    -- Check if a newer version is out
    local lV = cookie.GetNumber("sf_nextv", gDisasters.Version)
    if cookie.GetNumber("sf_nextvcheck", 0) > os.time() then
        if lV > gDisasters.Version then
            print("Version " .. lV .. " is out!")
        else
            print("Version " .. lV .. " is the newest version")
        end
    else
        RunCheck()
        cookie.Set("sf_nextvcheck", os.time() + 129600) -- Check in 1½ day
    end
end
hook.Add("PlayerInitialSpawn", "gDisasters_checkversion", RunLogic)