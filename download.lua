-- Computercraft update script

local function readVersion(path)
    local file = fs.open(path, "r")
    if not file then return nil end
    local line = file.readLine()
    file.close()
    if not line then return nil end
    return line:match("^%-%-%s*V?(.+)$") or line
end

if not fs.exists("/cache") then fs.makeDir("/cache") end
if fs.exists("/cache/init.lua") then fs.delete("/cache/init.lua") end

local currentVersion = readVersion("/init.lua") or "0.0.0"
local LINK =  "https://raw.githubusercontent.com/JonasOech/computercraft/refs/heads/main/init.lua"

-- local function download(url, path)
--     local res = http.get(url)
--     if not res then return false end
--     local file = fs.open(path, "w")
--     file.write(res.readAll())
--     file.close()
--     res.close()
--     return true
-- end

while true do
    if fs.exists("/cache/init.lua") then fs.delete("/cache/init.lua") end
    shell.execute("wget", LINK, "/cache/init.lua")

    local version = readVersion("/cache/init.lua")

    if version and version ~= currentVersion then
        print("Running update...")
        if fs.exists("/init.lua") then fs.delete("/init.lua") end
        fs.move("/cache/init.lua", "/init.lua")
        currentVersion = version
        print("Updated to " .. version)
        shell.run("/init.lua")
    end

    sleep(10)
end
