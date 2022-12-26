-----
-- Tests the move modules's functions. When the test is run, there should be no blocks within 10
-- blocks of the turtle, except for one block behind the turtle.

package.path = "/modules/?.lua;" .. package.path
require "move"

local function assertEquals(x, y)
    if not (x == y) then
        io.write("Assertion failed: " .. x .. " == " .. y .. "\n")
    end
    assert(x == y)
end

-----
-- Tests move.initialize() and reading the position file
local function testInitialize()

    -- A default entry
    local x = 23
    local y = 50
    local z = -2938
    local direction = 2
    local positionfiletext = "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n"
    local file = fs.open("position.txt", "w")
    file.write(positionfiletext)
    file.close()

    -- Verifies the position file is read in properly
    move.initialize()
    assertEquals(x, move.getX())
    assertEquals(y, move.getY())
    assertEquals(z, move.getZ())
    assertEquals(direction, move.getDirection())

    -- A default entry preceeded by four default entries
    x = -3588
    y = 1
    z = 938
    direction = 0
    local priorEntries = "-----\n1\n2\n3\n4\n-----\n5\n6\n7\n0\n-----\n8\n9\n10\n1\n-----\n11\n12\n13\n2\n"
    positionfiletext = priorEntries .. "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n"
    file = fs.open("position.txt", "w")
    file.write(positionfiletext)
    file.close()

    -- Verifies the position file is read in properly
    move.initialize()
    assertEquals(x, move.getX())
    assertEquals(y, move.getY())
    assertEquals(z, move.getZ())
    assertEquals(direction, move.getDirection())

    -- A default entry preceeded by four assorted default/intent entries
    x = 374
    y = 17
    z = 9328
    direction = 1
    priorEntries = "-----\n1\n2\n3\n4\n-----\n5\n6\n7\n0\n-1 1\n-----\n8\n9\n10\n1\n-----\n11\n12\n13\n2\n-1 1\n"
    positionfiletext = priorEntries .. "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n"
    file = fs.open("position.txt", "w")
    file.write(positionfiletext)
    file.close()

    -- Verifies the position file is read in properly
    move.initialize()
    assertEquals(x, move.getX())
    assertEquals(y, move.getY())
    assertEquals(z, move.getZ())
    assertEquals(direction, move.getDirection())

    -- An intent entry with an intent not carried out (forward, west)
    x = 423
    y = 74
    z = -386
    direction = 3
    positionfiletext = "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n" .. turtle.getCommandID() .. " 1\n"
    file = fs.open("position.txt", "w")
    file.write(positionfiletext)
    file.close()

    -- Verifies the position file is read in properly
    move.initialize()
    assertEquals(x, move.getX())
    assertEquals(y, move.getY())
    assertEquals(z, move.getZ())
    assertEquals(direction, move.getDirection())

    -- An intent entry with an intent carried out (forward, west)
    x = 423
    y = 74
    z = -386
    direction = 3
    positionfiletext = "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n" .. (turtle.getCommandID() - 1) .. " 1\n"
    file = fs.open("position.txt", "w")
    file.write(positionfiletext)
    file.close()

    -- Verifies the position file is read in properly
    move.initialize()
    assertEquals(x - 1, move.getX())
    assertEquals(y, move.getY())
    assertEquals(z, move.getZ())
    assertEquals(direction, move.getDirection())

    -- An intent entry with an intent carried out (back, south)
    x = 423
    y = 74
    z = -386
    direction = 2
    positionfiletext = "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n" .. (turtle.getCommandID() - 1) .. " 2\n"
    file = fs.open("position.txt", "w")
    file.write(positionfiletext)
    file.close()

    -- Verifies the position file is read in properly
    move.initialize()
    assertEquals(x, move.getX())
    assertEquals(y, move.getY())
    assertEquals(z - 1, move.getZ())
    assertEquals(direction, move.getDirection())

    -- An intent entry with an intent carried out (up)
    x = 423
    y = 74
    z = -386
    direction = 2
    positionfiletext = "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n" .. (turtle.getCommandID() - 1) .. " 3\n"
    file = fs.open("position.txt", "w")
    file.write(positionfiletext)
    file.close()

    -- Verifies the position file is read in properly
    move.initialize()
    assertEquals(x, move.getX())
    assertEquals(y + 1, move.getY())
    assertEquals(z, move.getZ())
    assertEquals(direction, move.getDirection())

    -- An intent entry with an intent carried out (down)
    x = 423
    y = 74
    z = -386
    direction = 2
    positionfiletext = "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n" .. (turtle.getCommandID() - 1) .. " 4\n"
    file = fs.open("position.txt", "w")
    file.write(positionfiletext)
    file.close()

    -- Verifies the position file is read in properly
    move.initialize()
    assertEquals(x, move.getX())
    assertEquals(y - 1, move.getY())
    assertEquals(z, move.getZ())
    assertEquals(direction, move.getDirection())

    -- An intent entry with an intent carried out (turn left)
    x = 423
    y = 74
    z = -386
    direction = 0
    positionfiletext = "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n" .. (turtle.getCommandID() - 1) .. " 5\n"
    file = fs.open("position.txt", "w")
    file.write(positionfiletext)
    file.close()

    -- Verifies the position file is read in properly
    move.initialize()
    assertEquals(x, move.getX())
    assertEquals(y, move.getY())
    assertEquals(z, move.getZ())
    assertEquals(3, move.getDirection())

    -- An intent entry with an intent carried out (turn right)
    x = 423
    y = 74
    z = -386
    direction = 0
    positionfiletext = "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n" .. (turtle.getCommandID() - 1) .. " 6\n"
    file = fs.open("position.txt", "w")
    file.write(positionfiletext)
    file.close()

    -- Verifies the position file is read in properly
    move.initialize()
    assertEquals(x, move.getX())
    assertEquals(y, move.getY())
    assertEquals(z, move.getZ())
    assertEquals(1, move.getDirection())

    -- An intent entry with an intent carried out (up) preceeded by four assorted default/intent entries
    x = 423
    y = 74
    z = -386
    direction = 2
    priorEntries = "-----\n1\n2\n3\n4\n-1 1\n-----\n5\n6\n7\n0\n-----\n8\n9\n10\n1\n-1 1\n-----\n11\n12\n13\n2\n-1 1\n"
    positionfiletext = priorEntries .. "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n" .. (turtle.getCommandID() - 1) .. " 3\n"
    file = fs.open("position.txt", "w")
    file.write(positionfiletext)
    file.close()

    -- Verifies the position file is read in properly
    move.initialize()
    assertEquals(x, move.getX())
    assertEquals(y + 1, move.getY())
    assertEquals(z, move.getZ())
    assertEquals(direction, move.getDirection())

    -- An intent entry with multiple intents, only the last carried out (up), preceeded by four assorted default/intent entries
    x = 423
    y = 74
    z = -386
    direction = 2
    priorEntries = "-----\n1\n2\n3\n4\n-1 1\n-1 3\n-----\n5\n6\n7\n0\n-----\n8\n9\n10\n1\n-1 1\n-----\n11\n12\n13\n2\n-1 1\n"
    positionfiletext = priorEntries .. "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n" .. turtle.getCommandID() .. " 1\n" .. (turtle.getCommandID() - 1) .. " 3\n"
    file = fs.open("position.txt", "w")
    file.write(positionfiletext)
    file.close()

    -- Verifies the position file is read in properly
    move.initialize()
    assertEquals(x, move.getX())
    assertEquals(y + 1, move.getY())
    assertEquals(z, move.getZ())
    assertEquals(direction, move.getDirection())

end

-----
-- Tests move.forward() and writing to the position file
local function testForward()

    -- Creates the position file for this test
    local x = 0
    local y = 50
    local z = 0
    local direction = 0
    local positionfiletext = "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. direction .. "\n"
    local file = fs.open("position.txt", "w")
    file.write(positionfiletext)
    file.close()
    local baseCommandID = turtle.getCommandID()

    -- Verifies the position file is read in properly
    move.initialize()
    assertEquals(x, move.getX())
    assertEquals(y, move.getY())
    assertEquals(z, move.getZ())
    assertEquals(direction, move.getDirection())

    -- Verifies forward movement records position variable updates correctly
    assert(move.forward())
    assertEquals(x, move.getX())
    assertEquals(y, move.getY())
    assertEquals(z - 1, move.getZ())
    assertEquals(direction, move.getDirection())

    assert(move.turnRight())
    assert(move.turnRight())
    assert(move.forward())
    assertEquals(x, move.getX())
    assertEquals(y, move.getY())
    assertEquals(z, move.getZ())
    assertEquals(2, move.getDirection())

    assert(not move.forward())
    assertEquals(x, move.getX())
    assertEquals(y, move.getY())
    assertEquals(z, move.getZ())
    assert(move.turnRight())
    assert(move.turnRight())
    assertEquals(direction, move.getDirection())

    -- Verifies the movement history was recorded to file correctly
    local entryText = {}
    entryText[1] = "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. 0 .. "\n" .. baseCommandID .. " " .. "1\n"
    entryText[2] = "-----\n" .. x .. "\n" .. y .. "\n" .. (z - 1) .. "\n" .. 0 .. "\n" .. (baseCommandID + 1) .. " " .. "6\n"
    entryText[3] = "-----\n" .. x .. "\n" .. y .. "\n" .. (z - 1) .. "\n" .. 1 .. "\n" .. (baseCommandID + 2) .. " " .. "6\n"
    entryText[4] = "-----\n" .. x .. "\n" .. y .. "\n" .. (z - 1) .. "\n" .. 2 .. "\n" .. (baseCommandID + 3) .. " " .. "1\n"
    entryText[5] = "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. 2 .. "\n" .. (baseCommandID + 4) .. " " .. "1\n"
    entryText[6] = (baseCommandID + 4) .. " " .. "6\n"
    entryText[7] = "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. 3 .. "\n" .. (baseCommandID + 5) .. " " .. "6\n"
    entryText[8] = "-----\n" .. x .. "\n" .. y .. "\n" .. z .. "\n" .. 0 .. "\n"
    local expectedOutput = ""
    for i = 1, #entryText, 1 do
        expectedOutput = expectedOutput .. entryText[i]
    end

    local actualOutput = ""
    file = fs.open("position.txt", "r")
    local character = file.read()
    while character do
        actualOutput = actualOutput .. character
        character = file.read()
    end

    assert(expectedOutput == actualOutput)

end

-----
-- Runs all tests
local function runTests()
    io.write("Please ensure there is a solid block behind this turtle, there are no other nearby blocks it can run into, and it has sufficient fuel.\n")
    io.write("Press enter to run the movement tests.\n")
    io.read()
    testInitialize()
    testForward()
    io.write("All tests passed!")
end

runTests()