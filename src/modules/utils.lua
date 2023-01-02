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
local oldstatefilename = "state_backup.txt"
-- If this file exists, the state file is currently being saved. Used to detect when program
-- execution was cut off while saving the state
local savingstatefilename = "saving_state"

-- If this file doesn't exist, the turtle waits for user input before running
local runningfilename = "running"

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
-- Adds the given table to the list of state variables to save and load. If you set your state
-- variable equal to a new table after registering (such as with myStateVariable = {}), you must
-- re-register the state variable.
-- @tparam string name the name of the state variable to register to be saved/loaded (must be
-- unique)
-- @tparam table variable the state variable to register to be saved/loaded. Must be a table or
-- state loading will throw an error.
function utils.registerStateVariable(name, variable)
	stateTables[name] = variable
end

-----
-- Loads the state file data into the registered state variables
-- @treturn boolean whether the file or backup file was successfully loaded
function utils.loadState()

	-- Loads the backup state file instead if the current save file wasn't saved properly and may
	-- be corrupted
	local filetoload = statefilename
	local previousSaveCorrupted = fs.exists(savingstatefilename)
	if previousSaveCorrupted then

		filetoload = oldstatefilename

		if fs.exists(statefilename) then
			fs.delete(statefilename)
		end
		if fs.exists(savingstatefilename) then
			fs.delete(savingstatefilename)
		end

	end

	-- Loads the data from the state file
	local loadedTables = table.load(filetoload)
	if loadedTables then

		-- Clears each state table then fills it with the loaded data
		for tableName, stateTable in pairs(stateTables) do

			local loadedTable = loadedTables[tableName]

			if loadedTable then
				for k, v in pairs(stateTable) do
					stateTable[k] = nil
				end

				for k, v in pairs(loadedTable) do
					stateTable[k] = loadedTable[k]
				end
			end

		end

		return true

	end

	return false
end

-----
-- Saves the registered state variables to a file
function utils.saveState()

	-- Makes a backup of the current state file if it's not corrupted
	local previousSaveCorrupted = fs.exists(savingstatefilename)
	if not previousSaveCorrupted and fs.exists(statefilename) then
		if fs.exists(oldstatefilename) then
			fs.delete(oldstatefilename)
		end
		fs.copy(statefilename, oldstatefilename)
	end

	-- Saves the state tables to the state file
	local savingstatefile = fs.open(savingstatefilename, "w")
	savingstatefile.close()
	table.save(stateTables, statefilename)
	fs.delete(savingstatefilename)

	-- Deletes the backup
	if fs.exists(oldstatefilename) then
		fs.delete(oldstatefilename)
	end

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