-----
-- Module of utilities to do with logging, state saving, and program shutdown.
--
-- Programs should call utils.initialize() on startup and utils.shutdown() to end
-- program execution.
--
-- @author Brenden Lech

-- The module table
utils = {}

-- File handle for writing to the log
local logfilename = "log.txt"
local log = fs.open(logfilename, "a")

-- State file used for persistence across program executions
local statefilename = "state.txt"
local oldstatefilename = "state_old.txt"

-- If this file doesn't exist, the turtle waits for user input before running
local runningfilename = "running.txt"

-- The list of tables to save and load data to from file
local stateTables = {}

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
-- @tparam table variable the state variable to register to be saved/loaded
-- @tparam string name the name of the state variable to register to be saved/loaded (must be
-- unique)
function utils.registerStateVariable(variable, name)
    io.write("ERROR: Function not implemented.")
    assert(false)
end

-----
-- TODO rewrite to use the new statefile architecture
-- Loads the state file
-- @treturn boolean whether the file or backup file was successfully loaded
function utils.loadState()
    io.write("ERROR: Function not implemented.")
    assert(false)
end

-----
-- Returns the next token in a file, deliminated by " " and/or "\n"
-- @tparam table file the file handle to read from
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
-- @treturn boolean whether the state was saved successfully
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

-- The table serialization code in the below do block
-- is from http://lua-users.org/wiki/SaveTableToFile
do
    --[[
        Save Table to File
        Load Table from File
        v 1.0
        
        Lua 5.2 compatible
        
        Only Saves Tables, Numbers and Strings
        Insides Table References are saved
        Does not save Userdata, Metatables, Functions and indices of these
        ----------------------------------------------------
        table.save( table , filename )
        
        on failure: returns an error msg
        
        ----------------------------------------------------
        table.load( filename or stringtable )
        
        Loads a table that has been saved via the table.save function
        
        on success: returns a previously saved table
        on failure: returns as second argument an error msg
        ----------------------------------------------------
        
        Licensed under the same terms as Lua itself.
    
        Author: ChillCode
    ]]--
	-- declare local variables
	--// exportstring( string )
	--// returns a "Lua" portable version of the string
	local function exportstring( s )
		return string.format("%q", s)
	end

	--// The Save Function
	function table.save(  tbl,filename )
		local charS,charE = "   ","\n"
		local file,err = io.open( filename, "wb" )
		if err then return err end

		-- initiate variables for save procedure
		local tables,lookup = { tbl },{ [tbl] = 1 }
		file:write( "return {"..charE )

		for idx,t in ipairs( tables ) do
			file:write( "-- Table: {"..idx.."}"..charE )
			file:write( "{"..charE )
			local thandled = {}

			for i,v in ipairs( t ) do
				thandled[i] = true
				local stype = type( v )
				-- only handle value
				if stype == "table" then
					if not lookup[v] then
						table.insert( tables, v )
						lookup[v] = #tables
					end
					file:write( charS.."{"..lookup[v].."},"..charE )
				elseif stype == "string" then
					file:write(  charS..exportstring( v )..","..charE )
				elseif stype == "number" then
					file:write(  charS..tostring( v )..","..charE )
				end
			end

			for i,v in pairs( t ) do
				-- escape handled values
				if (not thandled[i]) then
				
					local str = ""
					local stype = type( i )
					-- handle index
					if stype == "table" then
						if not lookup[i] then
							table.insert( tables,i )
							lookup[i] = #tables
						end
						str = charS.."[{"..lookup[i].."}]="
					elseif stype == "string" then
						str = charS.."["..exportstring( i ).."]="
					elseif stype == "number" then
						str = charS.."["..tostring( i ).."]="
					end
				
					if str ~= "" then
						stype = type( v )
						-- handle value
						if stype == "table" then
							if not lookup[v] then
								table.insert( tables,v )
								lookup[v] = #tables
							end
							file:write( str.."{"..lookup[v].."},"..charE )
						elseif stype == "string" then
							file:write( str..exportstring( v )..","..charE )
						elseif stype == "number" then
							file:write( str..tostring( v )..","..charE )
						end
					end
				end
			end
			file:write( "},"..charE )
		end
		file:write( "}" )
		file:close()
	end
	
	--// The Load Function
	function table.load( sfile )
		local ftables,err = loadfile( sfile )
		if err then return _,err end
		local tables = ftables()
		for idx = 1,#tables do
			local tolinki = {}
			for i,v in pairs( tables[idx] ) do
				if type( v ) == "table" then
					tables[idx][i] = tables[v[1]]
				end
				if type( i ) == "table" and tables[i[1]] then
					table.insert( tolinki,{ i,tables[i[1]] } )
				end
			end
			-- link indices
			for _,v in ipairs( tolinki ) do
				tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
			end
		end
		return tables[1]
	end

end

return utils