-----
-- Library of utilities to do with logging, state saving, and program shutdown.
--
-- Programs should call utils.initialize() on startup and utils.shutdown() to end
-- program execution.
--
-- @author Brenden Lech

-- The library table
utils = {}

-- File handle for writing to the log
local logfilename = "log.txt"
local log = fs.open(logfilename, "a")

-- State file used for persistence across program executions
local statefilename = "state.txt"
local oldstatefilename = "state_old.txt"

-- If this file doesn't exist, the turtle waits for user input before running
local runningfilename = "running.txt"

-----
-- Prints the given message to the log file, followed by a new line
-- @tparam string message the message to print
function utils.printlog(message)
    log.write(message)
    log.write("\n")
    log.flush()
end

-----
--TODO
-- Adds a table to the list of state variables to save and load
-- @tparam tab variable the state variable to register to be saved/loaded
function utils.registerStateVariable(variable)
    io.write("ERROR: Function not implemented.")
    assert(false)
end

-----
-- TODO rewrite to use the new statefile architecture
-- Loads the state file
-- @treturn bool whether the file or backup file was successfully loaded
function utils.loadState()
    io.write("ERROR: Function not implemented.")
    assert(false)
end

-----
-- Returns the next token in a file, deliminated by " " and/or "\n"
-- @tparam tab file the file handle to read from
-- @treturn string the token, or nil if a token could not be read
function utils.nextToken(file)
    
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

-----
-- TODO rewrite to use the new statefile architecture
-- Saves the state to a file
-- @treturn bool whether the state was saved successfully
function utils.saveState()
    io.write("ERROR: Function not implemented.")
    assert(false)
end

-----
-- Waits for user input before executing the program. Useful for preventing the robot from
-- wandering off during initial setup. utils.initialize() should be called after this function.
-- If program execution last ended without calling utils.shutdown(), this function will do nothing.
-- @tparam string message the message to print to prompt the user for input
function utils.waitAtStartup(message)
    if not fs.exists(runningfilename) then
        write(message .. "\n")
        read()
    end
end

-----
-- All programs with persistence should call this on startup. If using utils.waitAtStartup(), this
-- function should be called after it. Creates an file that is deleted when the program ends with
-- utils.shutdown(). Allows the program to detect whether it was ended properly last time or was
-- interrupted.
function utils.initialize()
    local running = fs.open(runningfilename, "w")
    running.write("If this file exists, the program is either currently running or execution was ended improperly.")
    running.close()
end

-----
-- Ends program execution, closing open file handles
function utils.shutdown()
    utils.printlog("End program execution")
    log.close()
    fs.delete(runningfilename)
    os.shutdown()
end

return utils