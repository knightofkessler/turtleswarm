numSlots = 16
startingY = 64
x = 0
y = startingY
z = 0
direction = 0 -- 0 is north, 1 is east, etc.

-- The ores this machine will collect if it sees them while mining
oresWanted = {["minecraft:iron_ore"]=true, ["minecraft:diamond_ore"]=true,
              ["minecraft:coal_ore"]=true, ["minecraft:redstone_ore"]=true}

function main()
    
    while true do
        
        -- Goes down to mining level
        goTo(x, 9, z, direction, true)
        checkInventoryFull()
        
        -- Controlls the mining behavior
        miningDirection = true
        while true do
            
            local squareRadius = 30
            for i = 1, 30, 1 do
                mineForward()
                refuelOrHome()
                checkInventoryFull()
            end
            
            if miningDirection then
                turnRight()
            else
                turnLeft()
            end
            for i = 1, 4, 1 do
                mineForward()
                refuelOrHome()
                checkInventoryFull()
            end
            if miningDirection then
                turnRight()
            else
                turnLeft()
            end
            miningDirection = not miningDirection
            
        end
        
    end
    
    -- Unused code from early test
    while true do
        
        for i = 0, 19, 1
        do
            
            -- Moves over terrain
            local temp, block = turtle.inspect()
            while block["name"] == "minecraft:grass_block" or block["name"] == "minecraft:dirt"
            do
                assert(up())
                temp, block = turtle.inspect()
            end
            
            -- Digs out other blocks in front
            if turtle.detect()
            then
                turtle.dig("right")
            end
            
            -- Moves forward
            assert(forward())
            
            -- Falls down
            while not turtle.detectDown()
            do
                assert(down())
            end
            
        end
        
        -- Turns around
        turnRight()
        turnRight()
        
    end
    
end

-- Moves the turtle forward
function forward()
    
    moved = turtle.forward()
    
    if moved then
        if direction == 0
        then
            z = z - 1
        end
        if direction == 1
        then
            x = x + 1
        end
        if direction == 2
        then
            z = z + 1
        end
        if direction == 3
        then
            x = x - 1
        end
    end
    
    return moved
    
end

-- Moves the turtle backward
function back()

    moved = turtle.back()
    
    if moved then
        if direction == 0
        then
            z = z + 1
        end
        if direction == 1
        then
            x = x - 1
        end
        if direction == 2
        then
            z = z - 1
        end
        if direction == 3
        then
            x = x + 1
        end
    end
    
    return moved
    
end

-- Moves the turtle up
function up()
    
    moved = turtle.up()
    if moved then
        y = y + 1
    end
    return moved
    
end

-- Moves the turtle down
function down()
    
    moved = turtle.down()
    if moved then
        y = y - 1
    end
    return moved
    
end

-- Turns a turtle left
function turnLeft()
    
    turned = turtle.turnLeft()
    
    if turned then
        direction = direction - 1
        if direction < 0 then
            direction = direction + 4
            assert(direction == 3)
        end
    end
    
    return turned
    
end

-- Turns a turtle right
function turnRight()
    
    turned = turtle.turnRight()
    
    if turned then
        direction = direction + 1
        if direction > 3 then
            direction = direction - 4
            assert(direction == 0)
        end
    end
    
    return turned
    
end

-- Faces a turtle north
function faceNorth()
    if direction == 3 then
        turnRight()
    end
    while direction < 0 do
        turnLeft()
    end
end

-- Faces a turtle east
function faceEast()
    while direction < 1 do
        turnRight()
    end
    while direction > 1 do
        turnLeft()
    end
end

-- Faces a turtle south
function faceSouth()
    while direction < 2 do
        turnRight()
    end
    while direction > 2 do
        turnLeft()
    end
end

-- Faces a turtle west
function faceWest()
    if direction == 0 then
        turnLeft()
    end
    while direction < 3 do
        turnRight()
    end
end

-- Goes to the given coordinates and direction, breaking blocks to get there
-- checkLowFuel: true if the turtle should check for low fuel after each movement then react accordingly
function goTo(returnX, returnY, returnZ, returnDirection, checkLowFuel)
    
    -- Moves north as needed
    if returnZ < z then
        faceNorth()
    end
    while returnZ < z do
        assert(digMoveForward())
        if checkLowFuel then
            refuelOrHome()
        end
    end
    
    -- Moves east as needed
    if returnX > x then
        faceEast()
    end
    while returnX > x do
        assert(digMoveForward())
        if checkLowFuel then
            refuelOrHome()
        end
    end
    
    -- Moves south as needed
    if returnZ > z then
        faceSouth()
    end
    while returnZ > z do
        assert(digMoveForward())
        if checkLowFuel then
            refuelOrHome()
        end
    end
    
    -- Moves west as needed
    if returnX < x then
        faceWest()
    end
    while returnX < x do
        assert(digMoveForward())
        if checkLowFuel then
            refuelOrHome()
        end
    end
    
    -- Moves up as needed
    while returnY > y do
        assert(digMoveUp())
        if checkLowFuel then
            refuelOrHome()
        end
    end
    
    -- Moves down as needed
    while returnY < y do
        assert(digMoveDown())
        if checkLowFuel then
            refuelOrHome()
        end
    end
    
    -- Faces the direction needed
    if returnDirection == 0 then
        faceNorth()
    end
    if returnDirection == 1 then
        faceEast()
    end
    if returnDirection == 2 then
        faceSouth()
    end
    if returnDirection == 3 then
        faceWest()
    end
    
end

-- Digs one block forward, repeatedly breaking the block until it can do so unless it cannot break the block
-- Returns whether it could break the block and move forward
function digMoveForward()
    
    while not forward() do
        if not turtle.dig() then
            return false
        end
    end
    
    return true
    
end

-- Digs one block down, repeatedly breaking the block until it can do so unless it cannot break the block
-- Returns whether it could break the block and move down
function digMoveDown()
    
    while not down() do
        if not turtle.digDown() then
            return false
        end
    end
    
    return true
    
end

-- Digs one block up, repeatedly breaking the block until it can do so unless it cannot break the block
-- Returns whether it could break the block and move up
function digMoveUp()
    
    while not up() do
        if not turtle.digUp() then
            return false
        end
    end
    
    return true
    
end

-- Makes this machine mine ores it wants beside it until it can't find any more, then returns to
-- its original position. There should already be an ore it wants in front of it
function mineOre()
    
    -- Exits this function if no wanted ore is in front of this machine
    local blockDetected, blockInfo = turtle.inspect()
    if not oresWanted[blockInfo["name"]] then
        return
    end
    
    -- Remembers where to return to when done mining
    returnX = x
    returnY = y
    returnZ = z
    returnDirection = direction
    
    while oresWanted[blockInfo["name"]] do
    
        digMoveForward()
        
        blockDetected, blockInfo = turtle.inspectDown()
        if oresWanted[blockInfo["name"]] then
            turtle.digDown()
        end
        
        blockDetected, blockInfo = turtle.inspectUp()
        if oresWanted[blockInfo["name"]] then
            turtle.digUp()
        end
        
        blockDetected, blockInfo = turtle.inspect()
    end
    
    goTo(returnX, returnY, returnZ, returnDirection, true)
    
end

-- Mines one block forward while collecting any nearby ores, may deviate from path to get ores but then return
function mineForward()

    turnLeft()
    local blockDetected, blockInfo = turtle.inspect()
    if oresWanted[blockInfo["name"]] then
        mineOre()
    end
    
    turnRight()
    turnRight()
    local blockDetected, blockInfo = turtle.inspect()
    if oresWanted[blockInfo["name"]] then
        mineOre()
    end
    
    turnLeft()
    local blockDetected, blockInfo = turtle.inspectUp()
    if oresWanted[blockInfo["name"]] then
        turtle.digUp()
    end
    
    local blockDetected, blockInfo = turtle.inspectDown()
    if oresWanted[blockInfo["name"]] then
        turtle.digDown()
    end
    
    local blockDetected, blockInfo = turtle.inspect()
    if blockDetected then
        turtle.dig()
    end
    assert(forward())
    
end

-- If the turtle needs to be refueled, then it refuels the turtle or brings it back home to 0, 64, 0 and stops program execution
function refuelOrHome()
    
    -- Extra fuel to have when getting home; must be at least 1
    safetyBuffer = 50
    
    distanceFromHome = math.abs(x) + math.abs(y - startingY) + math.abs(z)
    -- If the turtle needs more fuel
    if distanceFromHome + safetyBuffer > turtle.getFuelLevel() then
        
        -- Attempts to refuel the turtle
        for i = 1, numSlots, 1 do
            turtle.select(i)
            turtle.refuel()
        end
        
        -- If the turtle could not refuel itself enough, it returns home
        if distanceFromHome + safetyBuffer > turtle.getFuelLevel() then
            goTo(0, startingY, 0, 0, false)
            os.shutdown()
        end
        
    end
    
end

-- If the turtle's inventory is full, then it returns home to 0, 64, 0 then stops program execution
function checkInventoryFull()
    
    numNonEmptySlots = 0
    for i = 1, numSlots, 1 do
        if turtle.getItemCount(i) > 0 then
            numNonEmptySlots = numNonEmptySlots + 1
        end
    end
    
    if numNonEmptySlots == numSlots then
        goTo(0, startingY, 0, 0, false)
        os.shutdown()
    end
    
end

main()