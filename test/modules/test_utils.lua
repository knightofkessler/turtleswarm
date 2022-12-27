-----
-- Tests the utils modules's functions. The computer will shut down if all tests pass.
--
-- @author Brenden Lech

package.path = "/modules/?.lua;" .. package.path
require "utils"

-----
-- Tests utils.initialize()
local function testInitialize()
    utils.initialize()
    assert(fs.exists("running.txt"))
end

-----
-- Tests utils.printlog()
local function testPrintlog()

    local emptylog = fs.open("log.txt", "w")
    emptylog.close()

    local message1 = "   This is a test log message."
    local message2 = "This is the second line!"

    utils.printlog(message1)
    utils.printlog(message2)

    local logreader = fs.open("log.txt", "r")
    local logtext = ""
    local character = logreader.read()
    while character do
        logtext = logtext .. character
        character = logreader.read()
    end

    local correctMessage = message1 .. "\n" .. message2 .. "\n"
    assert(correctMessage == logtext)

end

-----
-- Tests utils.shutdown()
local function testShutdown()
    utils.shutdown()
    assert(false)
end

-----
-- Runs all tests
local function runTests()
    testInitialize()
    testPrintlog()
    testShutdown()
end

runTests()