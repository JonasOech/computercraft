-- Computercraft update script

if not fs.exists("/cache") then fs.makeDir("/cache") end

-- File to store the last known commit SHA
local hashFile = "/cache/commit.sha"

local function readCurrentSha()
    local file = fs.open(hashFile, "r")
    if not file then return "none" end
    local sha = file.readAll()
    file.close()
    return sha
end

local function saveCurrentSha(sha)
    local file = fs.open(hashFile, "w")
    file.write(sha)
    file.close()
end

local currentSha = readCurrentSha()
local LINK = "https://raw.githubusercontent.com/JonasOech/computercraft/refs/heads/main/init.lua"
local API_LINK = "https://api.github.com/repos/JonasOech/computercraft/commits/main"

while true do
    -- Fetch the latest commit info from GitHub API
    local response = http.get(API_LINK, {["User-Agent"] = "ComputerCraft-Updater"})
    if response then
        local body = response.readAll()
        response.close()
        
        local data = textutils.unserializeJSON(body)
        if data and data.sha then
            local latestSha = data.sha
            
            if latestSha ~= currentSha then
                print("New commit detected: " .. latestSha:sub(1, 7))
                print("Running update...")
                
                if fs.exists("/cache/init.lua") then fs.delete("/cache/init.lua") end
                shell.execute("wget", LINK .. "?t=" .. os.epoch("utc"), "/cache/init.lua")
                
                if fs.exists("/cache/init.lua") then
                    if fs.exists("/init.lua") then fs.delete("/init.lua") end
                    fs.move("/cache/init.lua", "/init.lua")
                    
                    saveCurrentSha(latestSha)
                    currentSha = latestSha
                    print("Updated successfully.")
                    shell.run("/init.lua")
                else
                    print("Update check failed: could not download file")
                end
            end
        end
    else
        print("Update check failed: could not reach GitHub API")
    end

    sleep(10)
end
