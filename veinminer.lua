
local veinBlock = nil
local toMineStack = { } -- blocks weve seen but not mined yet
local basePosition = vector.new(0, 0, 0)
local position = vector.new(0, 0, 0)


local function checkSurroundings()
    local hasblock, data
    for i = 0, 3 do --check in all 4 directions
        hasblock, data= turtle.inspect(i)
        if hasblock and data.name == veinBlock then
            table.insert(toMineStack, position + vector.new(0, 0, 1):rotate(i * math.pi / 2))
            print("Found block at " .. tostring(position + vector.new(0, 0, 1):rotate(i * math.pi / 2)))
        end
        turtle.turnRight()
    end

    -- check up and down
    hasblock, data = turtle.inspectUp()
    if hasblock and data.name == veinBlock then
        table.insert(toMineStack, position + vector.new(0, 1, 0))
        print("Found block at " .. tostring(position + vector.new(0, 1, 0)))
    end
    hasblock, data = turtle.inspectDown()
    if hasblock and data.name == veinBlock then
        table.insert(toMineStack, position + vector.new(0, -1, 0))
        print("Found block at " .. tostring(position + vector.new(0, -1, 0)))
    end
end

local function mineVeinBestFirstSearch(veinBlock)
    veinBlock = veinBlock
    checkSurroundings() --push all blocks around us to the stack
    --sort the stack by manhattan distance to the base position
    table.sort(toMineStack, function(a, b) return (a - basePosition).length() < (b - basePosition).length() end) 

    while #toMineStack > 0 do
        local nextBlock = table.remove(toMineStack, 1) --get the closest block
        --move to the block
        local moveVector = nextBlock - position
        if moveVector.y > 0 then turtle.up() position.y = position.y + 1 end
        if moveVector.y < 0 then turtle.down() position.y = position.y - 1 end
        if moveVector.x > 0 then turtle.forward() position.x = position.x + 1 end
        if moveVector.x < 0 then turtle.back() position.x = position.x - 1 end
        if moveVector.z > 0 then turtle.forward() position.z = position.z + 1 end
        if moveVector.z < 0 then turtle.back() position.z = position.z - 1 end

        --mine the block
        turtle.dig()

        --check surroundings of the new block and add them to the stack
        checkSurroundings()

        --sort the stack again by distance to the base
        table.sort(toMineStack, function(a, b) return (a - basePosition).length() < (b - basePosition).length() end) 
    end
    
end

mineVeinBestFirstSearch("minecraft:coal_ore") --example usage, replace with desired block name