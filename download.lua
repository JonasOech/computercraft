-- Computercraft update script

local args = {...}
local fileName = args[1] or "init.lua"

if not fs.exists("/cache") then fs.makeDir("/cache") end

-- File to store the last known commit SHA (per downloaded file)
local hashFile = "/cache/" .. fileName .. ".sha"
local cachePath = "/cache/" .. fileName

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
local API_LINK = "https://api.github.com/repos/JonasOech/computercraft/commits/main"
local filepath = "/disk/" .. fileName

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
                
                if fs.exists(cachePath) then fs.delete(cachePath) end

                -- Download using the exact commit SHA to bypass branch caching
                local exactUrl = "https://raw.githubusercontent.com/JonasOech/computercraft/" .. latestSha .. "/" .. fileName
                shell.execute("wget", exactUrl, cachePath)

                if fs.exists(cachePath) then
                    if fs.exists(filepath) then fs.delete(filepath) end
                    fs.move(cachePath, filepath)
                    
                    saveCurrentSha(latestSha)
                    currentSha = latestSha
                    print("Updated successfully.")
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
