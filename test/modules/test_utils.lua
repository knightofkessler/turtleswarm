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
    assert(fs.exists("running"))
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
-- Tests loading and saving states
local function  testStateSaving()

    if fs.exists("state.txt") then
        fs.delete("state.txt")
    end
    if fs.exists("state_backup.txt") then
        fs.delete("state_backup.txt")
    end
    if fs.exists("saving_state") then
        fs.delete("saving_state")
    end

    local firstVar = {}
    firstVar[3] = 3
    firstVar[1] = "one"
    firstVar["two"] = 2
    local secondVar = {"hello", "world", {["log"]="minecraft:oak_log",["planks"]=10}}
    utils.registerStateVariable("firstVar", firstVar)
    utils.registerStateVariable("secondVar", secondVar)
    
    utils.saveState()
    assert(not fs.exists("saving_state"))
    
    firstVar[3] = nil
    firstVar[4] = "four"
    secondVar = {}
    utils.registerStateVariable("secondVar", secondVar)

    assert(utils.loadState())
    assert(firstVar[3] == 3)
    assert(firstVar[1] == "one")
    assert(firstVar["two"] == 2)
    assert(firstVar[4] == nil)
    assert(secondVar[1] == "hello")
    assert(secondVar[2] == "world")
    assert(secondVar[3]["log"] == "minecraft:oak_log")
    assert(secondVar[3]["planks"] == 10)
    
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
    testStateSaving()
    testShutdown()
end

runTests()