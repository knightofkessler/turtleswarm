numSlots = 16
defaultX = 0
defaultY = 64
defaultZ = 0
defaultDirection = 0
x = defaultX
y = defaultY
z = defaultZ
direction = defaultDirection -- 0 is north, 1 is east, etc.

-- The ores this machine will collect if it sees them while mining
oresWanted = {["minecraft:iron_ore"]=true, ["minecraft:diamond_ore"]=true,
              ["minecraft:coal_ore"]=true, ["minecraft:redstone_ore"]=true,
              ["minecraft:gold_ore"]=true, ["mekanism:osmium_ore"]=true,
              ["mekanism:tin_ore"]=true, ["mekanism:fluorite_ore"]=true,
              ["mekanism:uranium_ore"]=true}

-- The items this machine will throw out when mining
itemsToTrash = {["minecraft:cobblestone"]=true, ["minecraft:diorite"]=true,
                 ["minecraft:granite"]=true, ["minecraft:andesite"]=true,
                 ["minecraft:dirt"]=true, ["minecraft:gravel"]=true,
                 ["minecraft:flint"]=true, ["minecraft:sand"]=true,
                 ["byg:rocky_stone"]=true, ["byg:soapstone"]=true,
                 ["byg:scoria_cobblestone"]=true}

-- File handle for writing to the log
logfilename = "log.txt"
log = fs.open(logfilename, "a")

-- State file used for persistence across program executions
statefilename = "state.txt"
oldstatefilename = "state_old.txt"

-- If this file doesn't exist, the turtle waits for user input before running
runningfilename = "running.txt"

function main()
    
    -- Waits for player input if this turtle wasn't already running
    if not fs.exists(runningfilename) then
        write("Press enter to begin mining.")
        read()
    end
    local running = fs.open(runningfilename, "w")
    running.close()
    
    printlog("Begin program execution")
    loadState()
    
    trashItems(itemsToTrash)
    
    while true do
        
        -- Goes down to mining level
        goTo(x, 9, z, direction, true)
        checkInventoryFull()
        
        -- Controlls the mining behavior
        miningDirection = true
        for j = 1, 10, 1 do
            
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
    
end

-- Prints the given message to the log file
function printlog(message)
    log.write(message)
    log.write("\n")
    log.flush()
end

-- Moves the turtle forward, refueling it if necessary
-- Return: Whether the turtle moved successfully
function forward()
    
    if turtle.getFuelLevel() <= 0 then
        refuel()
    end
    
    moved, reason = turtle.forward()
    
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
        
        saveState()
        
        printlog("Moved forward to (" .. x .. ", " .. y .. ", " .. z .. ")")
        
    else
        printlog("Failed to move forward, reason: " .. reason)
    end
    
    return moved
    
end

-- Moves the turtle backward, refueling it if necessary
-- Return: Whether the turtle moved successfully
function back()
    
    if turtle.getFuelLevel() <= 0 then
        refuel()
    end

    moved, reason = turtle.back()
    
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
        
        saveState()
        
        printlog("Moved back to (" .. x .. ", " .. y .. ", " .. z .. ")")
        
    else
        printlog("Failed to move back, reason: " .. reason)
    end
    
    return moved
    
end

-- Moves the turtle up, refueling it if necessary
-- Return: Whether the turtle moved successfully
function up()
    
    if turtle.getFuelLevel() <= 0 then
        refuel()
    end
    
    moved, reason = turtle.up()
    if moved then
        
        y = y + 1
        
        saveState()
        
        printlog("Moved up to (" .. x .. ", " .. y .. ", " .. z .. ")")
        
    else
        printlog("Failed to move up, reason: " .. reason)
    end
    
    return moved
    
end

-- Moves the turtle down, refueling it if necessary
-- Return: Whether the turtle moved successfully
function down()
    
    if turtle.getFuelLevel() <= 0 then
        refuel()
    end
    
    moved, reason = turtle.down()
    if moved then
        
        y = y - 1
        
        saveState()
        
        printlog("Moved down to (" .. x .. ", " .. y .. ", " .. z .. ")")
        
    else
        printlog("Failed to move down, reason: " .. reason)
    end
    
    return moved
    
end

-- Turns a turtle left
-- Return: Whether the turtle turned successfully
function turnLeft()
    
    turned, reason = turtle.turnLeft()
    
    if turned then
        
        direction = direction - 1
        if direction < 0 then
            direction = direction + 4
            assert(direction == 3)
        end
        
        saveState()
        
        printlog("Turned left to face " .. direction)
        
    else
        printlog("Failed to turn left, reason: ", reason)
    end
    
    return turned
    
end

-- Turns a turtle right
-- Return: Whether the turtle turned successfully
function turnRight()
    
    turned, reason = turtle.turnRight()
    
    if turned then
        
        direction = direction + 1
        if direction > 3 then
            direction = direction - 4
            assert(direction == 0)
        end
        
        saveState()
        
        printlog("Turned right to face " .. direction)
        
    else
        printlog("Failed to turn right, reason: ", reason)
    end
    
    return turned
    
end

-- Faces a turtle north
-- Return: Whether the turtle faced north successfully
function faceNorth()
    printlog("Turning to face North")
    if direction == 3 then
        if not turnRight() then
            return false
        end
    end
    while direction > 0 do
        if not turnLeft() then
            return false
        end
    end
    return true
end

-- Faces a turtle east
-- Return: Whether the turtle faced east successfully
function faceEast()
    printlog("Turning to face East")
    while direction < 1 do
        if not turnRight() then
            return false
        end
    end
    while direction > 1 do
        if not turnLeft() then
            return false
        end
    end
    return true
end

-- Faces a turtle south
-- Return: Whether the turtle faced south successfully
function faceSouth()
    printlog("Turning to face South")
    while direction < 2 do
        if not turnRight() then
            return false
        end
    end
    while direction > 2 do
        if not turnLeft() then
            return false
        end
    end
    return true
end

-- Faces a turtle west
-- Return: Whether the turtle faced west successfully
function faceWest()
    printlog("Turning to face West")
    if direction == 0 then
        if not turnLeft() then
            return false
        end
    end
    while direction < 3 do
        if not turnRight() then
            return false
        end
    end
    return true
end

-- Goes to the given coordinates and direction, breaking blocks to get there
-- destinationX: The x-coordinate of the location to go to
-- destinationY: The y-coordinate of the location to go to
-- destinationZ: The z-coordinate of the location to go to
-- destinationDirection: The direction to face when it gets to its location
-- checkLowFuel: true if the turtle should check for low fuel after each movement then react accordingly
function goTo(destinationX, destinationY, destinationZ, destinationDirection, checkLowFuel)
    
    printlog("Going to coordinates (" .. destinationX .. ", " .. destinationY .. ", " ..
             destinationZ .. "), direction=" .. destinationDirection)
    
    -- Moves north as needed
    if destinationZ < z then
        faceNorth()
    end
    while destinationZ < z do
        assert(digMoveForward())
        if checkLowFuel then
            refuelOrHome()
        end
    end
    
    -- Moves east as needed
    if destinationX > x then
        faceEast()
    end
    while destinationX > x do
        assert(digMoveForward())
        if checkLowFuel then
            refuelOrHome()
        end
    end
    
    -- Moves south as needed
    if destinationZ > z then
        faceSouth()
    end
    while destinationZ > z do
        assert(digMoveForward())
        if checkLowFuel then
            refuelOrHome()
        end
    end
    
    -- Moves west as needed
    if destinationX < x then
        faceWest()
    end
    while destinationX < x do
        assert(digMoveForward())
        if checkLowFuel then
            refuelOrHome()
        end
    end
    
    -- Moves up as needed
    while destinationY > y do
        assert(digMoveUp())
        if checkLowFuel then
            refuelOrHome()
        end
    end
    
    -- Moves down as needed
    while destinationY < y do
        assert(digMoveDown())
        if checkLowFuel then
            refuelOrHome()
        end
    end
    
    -- Faces the direction needed
    if destinationDirection == 0 then
        assert(faceNorth())
    end
    if destinationDirection == 1 then
        assert(faceEast())
    end
    if destinationDirection == 2 then
        assert(faceSouth())
    end
    if destinationDirection == 3 then
        assert(faceWest())
    end
    
    printlog("Reached target coordinates (" .. destinationX .. ", " .. destinationY .. ", " ..
             destinationZ .. "), direction=" .. destinationDirection)
    printlog("Current coordinates (" .. x .. ", " .. y .. ", " .. z .. "), direction=" .. direction)
    
    assert(x == destinationX)
    assert(y == destinationY)
    assert(z == destinationZ)
    assert(direction == destinationDirection)
    
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
    local returnX = x
    local returnY = y
    local returnZ = z
    local returnDirection = direction
    
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
    
    digMoveForward()
    
end

-- If the turtle needs to be refueled, then it refuels the turtle or brings it back home to 0, 64, 0 and stops program execution
function refuelOrHome()
    
    -- Extra fuel to have when getting home; must be at least 1
    safetyBuffer = 50
    
    distanceFromHome = math.abs(x) + math.abs(y - defaultY) + math.abs(z)
    -- If the turtle needs more fuel
    if distanceFromHome + safetyBuffer > turtle.getFuelLevel() then
        
        -- Attempts to refuel the turtle
        refuel()
        
        -- If the turtle could not refuel itself enough, it returns home
        if distanceFromHome + safetyBuffer > turtle.getFuelLevel() then
            printlog("Fuel low, returning home")
            goTo(defaultX, defaultY, defaultZ, defaultDirection, false)
            shutdown()
        end
        
    end
    
end

-- Refuels the turtle using all combustible items in its inventory
function refuel()
    printlog("Refueling")
    for i = 1, numSlots, 1 do
        turtle.select(i)
        turtle.refuel()
    end
end

-- Returns whether the machine's inventory is full
function isInventoryFull()
    
    for i = 1, numSlots, 1 do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end
    
    return true
    
end

-- Throws out items on the given list
-- trashList: The table of item types to throw out; each entry should be formatted as ["namespace:item"]=true
function trashItems(trashList)
    
    printlog("Trashing items")
    
    for i = 1, numSlots, 1 do
        
        local itemInfo = turtle.getItemDetail(i)
        
        if not (itemInfo == nil) then
            if trashList[itemInfo["name"]] then
                turtle.select(i)
                assert(turtle.drop())
            end
        end
        
    end
    
end

-- If the turtle's inventory is full, then it empties its inventory. If it can't empty any items,
-- it returns home to 0, 64, 0 then stops program execution
function checkInventoryFull()
    
    if isInventoryFull() then
        trashItems(itemsToTrash)
    end
    
    if isInventoryFull() then
        printlog("Inventory full, returning home")
            goTo(defaultX, defaultY, defaultZ, defaultDirection, false)
        shutdown()
    end
    
end

-- Loads the state file
-- Return: Whether the file or backup file was successfully loaded
function loadState()
    
    -- Load state file
    printlog("Reading main state file")
    local state = fs.open(statefilename, "r")
    local successfullyLoadedFile = false
    if state then
        successfullyLoadedFile = parseStateFile(state)
    end
    
    -- If failed, load old state file
    if not successfullyLoadedFile then
        printlog("Main state file read failed\nReading backup state file")
        state = fs.open(oldstatefilename, "r")
        if state then
            successfullyLoadedFile = parseStateFile(state)
        end
        
        -- Main state file is corrupted, but backup is fine
        if successfullyLoadedFile then
            -- Replace main state file with backup file
            if fs.exists(oldstatefilename) then
                fs.delete(statefilename)
                fs.copy(oldstatefilename, statefilename)
            end
        end
    end
    
    -- If failed, assume default state
    if not successfullyLoadedFile then
        
        x = defaultX
        y = defaultY
        z = defaultZ
        direction = defaultDirection
        printlog("Statefile read failed, assuming defaults: (" .. x .. ", " .. y .. ", " .. z .. ") direction=" .. direction)
        
        -- Deletes corrupted state files if they exist
        if fs.exists(statefilename) then
            fs.delete(statefilename)
        end
        if fs.exists(oldstatefilename) then
            fs.delete(oldstatefilename)
        end
        
        if state then
            state.close()
        end
        return false
    end
    
    printlog("Statefile read success: (" .. x .. ", " .. y .. ", " .. z .. ") direction=" .. direction)
    state.close()
    return true
    
end

-- Helper function, parses data from state files into program variables
-- file: file handle for the state file to read from
-- Return: whether data was read to the program successfully
function parseStateFile(file)
    
    local readX = tonumber(nextToken(file))
    local readY = tonumber(nextToken(file))
    local readZ = tonumber(nextToken(file))
    local readDirection = tonumber(nextToken(file))
    
    if readX and readY and readZ and readDirection then
        x = readX
        y = readY
        z = readZ
        direction = readDirection
        return true
    end
    
    return false
    
end

-- Helper function for reading files; returns the next token, deliminated by " " or "\n"
-- file: the file handle to read from
-- Return: the token, or nil if a token could not be read
function nextToken(file)
    
    local token = ""
    
    -- Skips whitespace at the beginning
    local character = file.read()
    while character == " " or character == "\n" do
        character = file.read()
    end
    
    -- Reads the token
    while not (character == " " or character == "\n") and character do
        token = token .. character
        character = file.read()
    end
    
    if token == "" then
        return nil
    else
        return token
    end
    
end

-- Saves the state to a file
-- Returns: whether the state was saved successfully
function saveState()
    
    printlog("Saving state")
    
    -- Copies to a backup file in case saving is interrupted
    if fs.exists(statefilename) then
        fs.delete(oldstatefilename)
        fs.copy(statefilename, oldstatefilename)
    end
    
    -- Saves the state
    local state = fs.open(statefilename, "w")
    if state then
        state.write(x .. "\n" .. y .. "\n" .. z .. "\n" .. direction)
        state.close()
        printlog("State saved")
        return true
    
    else
        printlog("Could not write to state file\nState saving failed")
        return false
    end
    
end

-- Ends program execution, closing open file handles
function shutdown()
    printlog("End program execution")
    log.close()
    fs.delete(runningfilename)
    os.shutdown()
end

main()