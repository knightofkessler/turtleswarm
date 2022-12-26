-----
-- Module of various movement functions.
-- 
-- This module keeps track of the turtle's current position and maintains persistence
-- of this position tracking across program runs. If using this module, move the turtle only
-- with the functions provided in here, otherwise the position tracking will break. 
--
-- The position is saved to a file positions.txt. Each entry contains information in the
-- order: x y z direction. The optional fifth line includes information about the turtle's next
-- intended move, used for avoiding race conditions between saving position to a file and random
-- program execution cutoff.
-- 
-- @author Brenden Lech

package.path = "/modules/?.lua;" .. package.path
require "utils"

-- The module table
move = {}

local DEFAULT_X = 0
local DEFAULT_Y = 64
local DEFAULT_Z = 0
local DEFAULT_DIRECTION = 0
local x = DEFAULT_X
local y = DEFAULT_Y
local z = DEFAULT_Z
local direction = DEFAULT_DIRECTION -- 0 is north, 1 is east, 2 is south, and 3 is west

-- Position file used for persistence across program executions
local positionfilename = "position.txt"
local positionfile

-- The delimeter between entries in the position file
local POSITIONFILE_DELIMETER = "-----"

-- A standardized way of specifying intents
local INTENT = {["FORWARD"]=1, ["BACK"]=2, ["UP"]=3, ["DOWN"]=4, ["LEFT"]=5, ["RIGHT"]=6}

-- When the position file becomes larger than this size in bytes, it is deleted and overwritten
local POSITION_FILESIZE_CUTOFF = 6000

-----
-- Sets an intent for movement, saving it to the position file.
-- @tparam int intent the intent that was set, a map from "commandID" to the value of
-- turtle.getCommandID() when the intent was set and from "intent" to the
-- intent that was set (e.g. {["commandID"]=1, ["intent"]=1})
-- @treturn table the current command ID when this intent was set
local function setIntent(intent)

    positionfile.write(turtle.getCommandID() .. " " .. intent .. "\n")
    positionfile.flush()

    return {["commandID"]=turtle.getCommandID(), ["intent"]=intent}

end

-----
-- Processes the given intent, modifying the position variables if the intended
-- action was carried out.
-- @tparam table intent the intent to process, a map from "commandID" to the value of
-- turtle.getCommandID() when the intent was set and from "intent" to the
-- intent that was set (e.g. {["commandID"]=1, ["intent"]=1})
-- @treturn boolean whether the intent was processed and postion was changed
local function processIntent(intent)

    -- If the intent was carried out
    if turtle.getCommandID() > intent.commandID then

        if intent.intent == INTENT.FORWARD then
            if direction == 0 then
                z = z - 1
            end
            if direction == 1 then
                x = x + 1
            end
            if direction == 2 then
                z = z + 1
            end
            if direction == 3 then
                x = x - 1
            end

        elseif intent.intent == INTENT.BACK then
            if direction == 0 then
                z = z + 1
            end
            if direction == 1 then
                x = x - 1
            end
            if direction == 2 then
                z = z - 1
            end
            if direction == 3 then
                x = x + 1
            end

        elseif intent.intent == INTENT.UP then
            y = y + 1

        elseif intent.intent == INTENT.DOWN then
            y = y - 1

        elseif intent.intent == INTENT.LEFT then
            direction = direction - 1
            if direction < 0 then
                direction = direction + 4
                assert(direction == 3)
            end

        elseif intent.intent == INTENT.RIGHT then
            direction = direction + 1
            if direction > 3 then
                direction = direction - 4
                assert(direction == 0)
            end

        else
            return false
        end

        return true

    end

    return false

end

-----
-- Saves the turtle's position to a file.
-- @treturn bool whether the position file was successfully written to
local function savePosition()
    
    -- Deletes and overwrites the position file on the next write if it is
    -- over POSITION_FILESIZE_CUTOFF bytes
    if fs.exists(positionfilename) and (fs.getSize(positionfilename) > POSITION_FILESIZE_CUTOFF) then
        positionfile.close()
        positionfile = fs.open(positionfilename, "w")
    end

    -- Saves the position
    positionfile.write(POSITIONFILE_DELIMETER .. "\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n")
    positionfile.flush()
    utils.printlog("Saved position")
    return true

end

-----
-- Helper function, reads the next entry from the given position file handle. The position file
-- read location must be at the start of the next entry to read. The end of an entry is defined
-- as the POSITIONFILE_DELIMETER or the end of the file.
-- @tparam table file the file handle for the position file, with its read location at the start
-- of the entry to read
-- @treturn table a table containing the position file entry in the format
-- {x, y, z, direction, intent}, where intent may or may not exist and is a table in the format
-- {commandID, intent}. Returns nil if it failed to read the complete entry.
-- @treturn boolean Whether the end of the file was reached
local function readEntry(file)

    local entry = {}

    -- Reads a token and determines whether the end of the file was reached
    local token = utils.nextToken(file)
    local reachedEOF = true
    if token then
        reachedEOF = false
    end

    -- Reads in x
    entry["x"] = tonumber(token)
    if not entry["x"] then
        return nil, reachedEOF
    end

    -- Reads a token and determines whether the end of the file was reached
    token = utils.nextToken(file)
    reachedEOF = true
    if token then
        reachedEOF = false
    end

    -- Reads in y
    entry["y"] = tonumber(token)
    if not entry["y"] then
        return nil, reachedEOF
    end

    -- Reads a token and determines whether the end of the file was reached
    token = utils.nextToken(file)
    reachedEOF = true
    if token then
        reachedEOF = false
    end

    -- Reads in z
    entry["z"] = tonumber(token)
    if not entry["z"] then
        return nil, reachedEOF
    end

    -- Reads a token and determines whether the end of the file was reached
    token = utils.nextToken(file)
    reachedEOF = true
    if token then
        reachedEOF = false
    end

    -- Reads in direction
    entry["direction"] = tonumber(token)
    if (not entry["direction"]) or direction < 0 or direction > 3 then
        return nil, reachedEOF
    end

    -- Reads a token and determines whether the end of the file was reached
    token = utils.nextToken(file)
    reachedEOF = true
    if token then
        reachedEOF = false
    end

    -- If there are intents with this entry, read the last one in
    local commandID = tonumber(token)
    while commandID do
        
        -- Reads a token and determines whether the end of the file was reached
        token = utils.nextToken(file)
        reachedEOF = true
        if token then
            reachedEOF = false
        end

        local intentName = tonumber(token)
        if intentName then
            local intent = {["commandID"]=commandID, ["intent"]=intentName}
            entry["intent"] = intent

            -- Reads a token and determines whether the end of the file was reached
            token = utils.nextToken(file)
            reachedEOF = true
            if token then
                reachedEOF = false
            end

            commandID = tonumber(token)

        else
            return nil, reachedEOF
        end

    end

    return entry, reachedEOF

end

-----
-- Helper function, parses data from position files into program variables.
-- @tparam table file file handle for the position file to read from
-- @treturn boolean whether data was read into the program successfully
local function parsePositionFile(file)

    -- Skips over the first entry, which is technically empty
    utils.nextToken(file)

    -- Reads to the last valid entry in the file and stores it in entry, skipping corrupted entries
    local entry, reachedEOF = readEntry(file)
    while not reachedEOF do
        potentialEntry, reachedEOF = readEntry(file)
        if potentialEntry then
            entry = potentialEntry
        end
    end

    -- Returns false if no entry was successfully read from the file
    if not entry then
        return false
    end

    -- Reads in data to program variables
    x = entry.x
    y = entry.y
    z = entry.z
    direction = entry.direction
    intent = entry.intent
    if intent then
        processIntent(intent)
    end
    return true

end

-----
-- Loads the turtle's position from a file.
-- @treturn bool whether the position was successfully loaded from file
local function loadPosition()
    
    -- Loads the position file
    utils.printlog("Reading position file")
    local positionfileReading = fs.open(positionfilename, "r")
    local successfullyLoadedFile = false
    if positionfileReading then
        successfullyLoadedFile = parsePositionFile(positionfileReading)
    end
    
    -- If failed, assume default position
    if not successfullyLoadedFile then
        
        x = DEFAULT_X
        y = DEFAULT_Y
        z = DEFAULT_Z
        direction = DEFAULT_DIRECTION
        utils.printlog("ERROR: Position file read failed, assuming defaults: (" .. x .. ", " .. y .. ", " .. z .. ") direction=" .. direction)
        
        -- Creates a new positionfile, as the previous one was corrupted or didn't exist
        if positionfile then
            positionfile.close()
        end
        positionfile = fs.open(positionfilename, "w")
        savePosition()
        utils.printlog("Created new position file")

        if positionfileReading then
            positionfileReading.close()
        end
        return false

    end
    
    utils.printlog("Position file read success: (" .. x .. ", " .. y .. ", " .. z .. ") direction=" .. direction)
    positionfileReading.close()
    return true
    
end

-----
-- Initializes the position tracking, loading informaton from file as needed. This function is
-- called automatically upon module load. Calling this function manually will only reinitialize
-- the turtle's position tracking from its file.
function move.initialize()
    positionfile = fs.open(positionfilename, "a")
    loadPosition()
end

-----
-- Returns the x position of the turtle in the turtle's local coordinate system.
-- @treturn int the x position of the turtle in the turtle's local coordinate system
function move.getX()
    return x
end

-----
-- Returns the y position of the turtle in the turtle's local coordinate system.
-- @treturn int the y position of the turtle in the turtle's local coordinate system
function move.getY()
    return y
end

-----
-- Returns the z position of the turtle in the turtle's local coordinate system.
-- @treturn int the z position of the turtle in the turtle's local coordinate system
function move.getZ()
    return z
end

-----
-- Returns the cardinal direction the turtle is facing in the turtle's local coordinate system.
-- @treturn int the cardinal direction the turtle is facing in the turtle's local coordinate
-- system (0=north, 1=east, 2=south, and 3=west)
function move.getDirection()
    return direction
end

-----
-- Attempts to move the turtle forward
-- @treturn bool whether the turtle moved successfully
function move.forward()
    
    local intent = setIntent(INTENT.FORWARD)
    local moved, reason = turtle.forward()
    if moved then
        processIntent(intent)
        savePosition()
        utils.printlog("Moved forward to (" .. x .. ", " .. y .. ", " .. z .. ")")
    else
        utils.printlog("Failed to move forward, reason: " .. reason)
    end

    return moved
    
end

-----
-- Attempts to move the turtle backward
-- @treturn bool whether the turtle moved successfully
function move.back()
    
    local intent = setIntent(INTENT.BACK)
    local moved, reason = turtle.back()
    if moved then
        processIntent(intent)
        savePosition()
        utils.printlog("Moved back to (" .. x .. ", " .. y .. ", " .. z .. ")")
    else
        utils.printlog("Failed to move back, reason: " .. reason)
    end

    return moved
    
end

-----
-- Attempts to move the turtle up
-- @treturn bool whether the turtle moved successfully
function move.up()
    
    local intent = setIntent(INTENT.UP)
    local moved, reason = turtle.up()
    if moved then
        processIntent(intent)
        savePosition()
        utils.printlog("Moved up to (" .. x .. ", " .. y .. ", " .. z .. ")")
    else
        utils.printlog("Failed to move up, reason: " .. reason)
    end

    return moved
    
end

-----
-- Attempts to move the turtle down
-- @treturn bool whether the turtle moved successfully
function move.down()
    
    local intent = setIntent(INTENT.DOWN)
    local moved, reason = turtle.down()
    if moved then
        processIntent(intent)
        savePosition()
        utils.printlog("Moved down to (" .. x .. ", " .. y .. ", " .. z .. ")")
    else
        utils.printlog("Failed to move down, reason: " .. reason)
    end

    return moved
    
end

-----
-- Turns the turtle left.
-- @treturn bool whether the turtle turned successfully
function move.turnLeft()
    
    local intent = setIntent(INTENT.LEFT)
    local turned, reason = turtle.turnLeft()
    if turned then
        processIntent(intent)
        savePosition()
        utils.printlog("Turned left to face " .. direction)
    else
        utils.printlog("Failed to turn left, reason: " .. reason)
    end

    return turned
    
end

-----
-- Turns the turtle right.
-- @treturn bool whether the turtle turned successfully
function move.turnRight()
    
    local intent = setIntent(INTENT.RIGHT)
    local turned, reason = turtle.turnRight()
    if turned then
        processIntent(intent)
        savePosition()
        utils.printlog("Turned right to face " .. direction)
    else
        utils.printlog("Failed to turn right, reason: " .. reason)
    end

    return turned
    
end

-----
-- Faces the turtle north.
-- @treturn bool whether the turtle faced north successfully
function move.faceNorth()
    utils.printlog("Turning to face North")
    if direction == 3 then
        if not move.turnRight() then
            return false
        end
    end
    while direction > 0 do
        if not move.turnLeft() then
            return false
        end
    end
    return true
end

-----
-- Faces the turtle east.
-- @treturn bool whether the turtle faced east successfully
function move.faceEast()
    utils.printlog("Turning to face East")
    while direction < 1 do
        if not move.turnRight() then
            return false
        end
    end
    while direction > 1 do
        if not move.turnLeft() then
            return false
        end
    end
    return true
end

-----
-- Faces the turtle south.
-- @treturn bool whether the turtle faced south successfully
function move.faceSouth()
    utils.printlog("Turning to face South")
    while direction < 2 do
        if not move.turnRight() then
            return false
        end
    end
    while direction > 2 do
        if not move.turnLeft() then
            return false
        end
    end
    return true
end

-----
-- Faces the turtle west.
-- @treturn bool whether the turtle faced west successfully
function move.faceWest()
    utils.printlog("Turning to face West")
    if direction == 0 then
        if not move.turnLeft() then
            return false
        end
    end
    while direction < 3 do
        if not move.turnRight() then
            return false
        end
    end
    return true
end

-----
-- Goes to the given position and direction, breaking blocks to get there.
-- @tparam int destX the x-coordinate of the location to go to
-- @tparam int destY the y-coordinate of the location to go to
-- @tparam int destZ the z-coordinate of the location to go to
-- @tparam int destDirection the direction to face when it gets to its location
-- @tparam[opt=0] int fuelSafetyBuffer optional safety buffer for determining whether there is
-- enough fuel to reach the destination
function move.goTo(destX, destY, destZ, destDirection, fuelSafetyBuffer)
    
    local fuelSafetyBuffer = fuelSafetyBuffer or 0
    
    -- Returns false if the turtle doesn't have enough fuel
    local distance = math.abs(x - destX) + math.abs(y - destY) + math.abs(z - destZ)
    if distance + safetyBuffer > turtle.getFuelLevel() then
        return false
    end
    
    utils.printlog("Going to coordinates (" .. destX .. ", " .. destY .. ", " ..
             destZ .. "), direction=" .. destDirection)
    
    -- Moves north as needed
    if destZ < z then
        move.faceNorth()
    end
    while destZ < z do
        assert(move.digMoveForward())
    end
    
    -- Moves east as needed
    if destX > x then
        move.faceEast()
    end
    while destX > x do
        assert(move.digMoveForward())
    end
    
    -- Moves south as needed
    if destZ > z then
        move.faceSouth()
    end
    while destZ > z do
        assert(move.digMoveForward())
    end
    
    -- Moves west as needed
    if destX < x then
        move.faceWest()
    end
    while destX < x do
        assert(move.digMoveForward())
    end
    
    -- Moves up as needed
    while destY > y do
        assert(move.digMoveUp())
    end
    
    -- Moves down as needed
    while destY < y do
        assert(move.digMoveDown())
    end
    
    -- Faces the direction needed
    if destDirection == 0 then
        assert(move.faceNorth())
    end
    if destDirection == 1 then
        assert(move.faceEast())
    end
    if destDirection == 2 then
        assert(move.faceSouth())
    end
    if destDirection == 3 then
        assert(move.faceWest())
    end
    
    utils.printlog("Reached target coordinates (" .. destX .. ", " .. destY .. ", " ..
             destZ .. "), direction=" .. destDirection)
    utils.printlog("Current coordinates (" .. x .. ", " .. y .. ", " .. z .. "), direction=" .. direction)
    
    assert(x == destX)
    assert(y == destY)
    assert(z == destZ)
    assert(direction == destDirection)
    
    return true
    
end

-----
-- Digs one block forward, repeatedly breaking the block until it can do so unless it cannot
-- break the block.
-- @treturn bool whether it could break the block and move forward
function move.digMoveForward()
    
    while not move.forward() do
        if not turtle.dig() then
            return false
        end
    end
    
    return true
    
end

-----
-- Digs one block down, repeatedly breaking the block until it can do so unless it cannot
-- break the block.
-- @treturn bool whether it could break the block and move down
function move.digMoveDown()
    
    while not move.down() do
        if not turtle.digDown() then
            return false
        end
    end
    
    return true
    
end

-----
-- Digs one block up, repeatedly breaking the block until it can do so unless it cannot
-- break the block.
-- @treturn bool whether it could break the block and move up
function move.digMoveUp()
    
    while not move.up() do
        if not turtle.digUp() then
            return false
        end
    end
    
    return true
    
end

move.initialize()

return move