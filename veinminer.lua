-- Veinminer implementation using best-first search. This is more efficient than a breadth-first search
local veinBlock = nil
local toMineStack = {}
local basePosition = vector.new(0, 0, 0)
local position = vector.new(0, 0, 0)
local heading = 0

-- DIRS is internally consistent with turnRight incrementing heading.
-- The turtle's true world facing is irrelevant; positions are tracked relative to start.
local DIRS = {
    [0] = vector.new(0, 0, 1),
    [1] = vector.new(1, 0, 0),
    [2] = vector.new(0, 0, -1),
    [3] = vector.new(-1, 0, 0),
}

-- 20 diagonal offsets (12 edge + 8 corner). Used to probe ores connected only by
-- diagonal adjacency, which the turtle can't see via inspect without first moving.
local DIAGONALS = {}
for dx = -1, 1 do
    for dy = -1, 1 do
        for dz = -1, 1 do
            local sum = math.abs(dx) + math.abs(dy) + math.abs(dz)
            if sum == 2 or sum == 3 then
                table.insert(DIAGONALS, vector.new(dx, dy, dz))
            end
        end
    end
end

local seen = {}

local function posKey(p)
    return p.x .. "," .. p.y .. "," .. p.z
end

local function turnRight()
    turtle.turnRight()
    heading = (heading + 1) % 4
end

local function turnLeft()
    turtle.turnLeft()
    heading = (heading - 1) % 4
end

local function turnTo(target)
    target = target % 4
    while heading ~= target do
        local diff = (target - heading) % 4
        if diff == 3 then turnLeft() else turnRight() end
    end
end

local function queueProbe(p)
    local key = posKey(p)
    if seen[key] then return end
    seen[key] = true
    table.insert(toMineStack, p)
end

local function tryAdd(p)
    local key = posKey(p)
    if seen[key] then return end
    seen[key] = true
    table.insert(toMineStack, p)
    print("Found block at " .. tostring(p) .. " Fuel level: " .. turtle.getFuelLevel())
    -- Probe diagonals: turtle.inspect can't see them, so we dig through to a vantage and rescan.
    for _, d in ipairs(DIAGONALS) do
        queueProbe(p + d)
    end
end

local function checkSurroundings()
    for _ = 0, 3 do
        local hasblock, data = turtle.inspect()
        if hasblock and data.name == veinBlock then
            tryAdd(position + DIRS[heading])
        end
        turnRight()
    end

    local hasblock, data = turtle.inspectUp()
    if hasblock and data.name == veinBlock then
        tryAdd(position + vector.new(0, 1, 0))
    end
    hasblock, data = turtle.inspectDown()
    if hasblock and data.name == veinBlock then
        tryAdd(position + vector.new(0, -1, 0))
    end
end

local function moveForward()
    while not turtle.forward() do
        if not turtle.dig() then return false end
    end
    position = position + DIRS[heading]
    return true
end

local function moveUp()
    while not turtle.up() do
        if not turtle.digUp() then return false end
    end
    position = position + vector.new(0, 1, 0)
    return true
end

local function moveDown()
    while not turtle.down() do
        if not turtle.digDown() then return false end
    end
    position = position + vector.new(0, -1, 0)
    return true
end

local function manhattandist(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y) + math.abs(a.z - b.z)
end

local function refueler(num)
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            if turtle.refuel(0) then
                turtle.refuel(num)
                return true
            end
        end
    end
    return false
end

local function moveTo(target)
    -- Refuel if we're getting low. We add a small buffer to avoid running out mid-vein.
    if turtle.getFuelLevel() <= manhattandist(target, position) + manhattandist(target, basePosition) then
        if not refueler(4) then
            -- look for comsu
            print("Out of fuel! Stopping veinminer.")
            return false
        end
    end

    while target.y > position.y do moveUp() end
    while target.y < position.y do moveDown() end

    if target.x > position.x then
        turnTo(1)
        while position.x < target.x do moveForward() end
    elseif target.x < position.x then
        turnTo(3)
        while position.x > target.x do moveForward() end
    end

    if target.z > position.z then
        turnTo(0)
        while position.z < target.z do moveForward() end
    elseif target.z < position.z then
        turnTo(2)
        while position.z > target.z do moveForward() end
    end

    return true

end

local function distSq(a, b)
    local dx, dy, dz = a.x - b.x, a.y - b.y, a.z - b.z
    return dx * dx + dy * dy + dz * dz
end


local function sortStack()
    table.sort(toMineStack, function(a, b)
        return distSq(a, basePosition) < distSq(b, basePosition)
    end)
end


local function mineVeinBestFirstSearch(block)
    veinBlock = block
    refueler(1) -- ensure we have fuel to start with
    checkSurroundings()
    sortStack()

    while #toMineStack > 0 do
        local nextBlock = table.remove(toMineStack, 1)
        if not moveTo(nextBlock) then
            break
        end
        checkSurroundings()
        sortStack()

    end

    moveTo(basePosition)
    turnTo(0)
end

local args = {...}
local ore = args[1] or "minecraft:coal_ore"
mineVeinBestFirstSearch(ore)
