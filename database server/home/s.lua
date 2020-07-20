--Begin setting variables for use later in code
local event = require("event")
local os = require("os")
local serialization = require("serialization")
local component = require("component")
local modem = component.modem
local running = true
local ports = {}
local files = {}
local gateTypes = {}
local eventHandlers = {}
local eventIDs = {}
local errors = {}
--End setting variables for use later in code

--Empty function
local function unknownEvent()
    -- do nothing
end

--Sets up all network related things
local function networkSetup()
    --The main port the database server uses
    ports.DB = 126

    --Iterates through all ports in the ports table and opens them
    for k, v in pairs(ports) do
        --Opens the port
        modem.open(ports[k])
    end
end

--Checks if file exists
local function fileExist(name)
    --Opens the file
    local f = io.open(name, "r")

    --If the file exists close it and return true
    if f ~= nil then
        io.close(f)
        return true
    end

    --If the file does not exist then return false
    return false
end

--Writes to a file, takes the filename and the data as input
local function writeToFile(file, data)
    --Opens the file
    local openedFile = io.open(file, "wb")

    --Writes the data to the file
    openedFile:write(data)

    --Closes the file
    openedFile:close(openedFile)
end

--Reads the first like of a file
local function readFromFile(file)
    --Opens the file
    local file = io.open(file, "r")

    --Sets the default input to the file
    io.input(file)

    --Returns the first line
    return io.read()
end

local function fileSetup()
    --Sets the correct filenames for the users file and the database file
    files.users = "users.ocdbu"
    files.database = "database.ocdb"

    --Checks if the users file exists, if not, create a base one
    if not fileExist(files.users) then
        --Creates the base users table
        local baseUsers = {
            ["root"] = {["password"] = "password", ["perms"] = "w"},
            ["read"] = {["password"] = "password", ["perms"] = "r"}
        }

        --Writes the serialized baseUsers table to the users file
        writeToFile(files.users, serialization.serialize(baseUsers))
    end

    --Checks if the database file exists, if not, create a base one
    if not fileExist(files.database) then
        --Creates the base database table
        local baseDatabase = {
            ["db1"] = {["data"] = {["a"] = "1", ["b"] = "2", ["c"] = "3"}, ["lastaccessed"] = os.time()},
            ["db2"] = {["data"] = {["d"] = "4", ["e"] = "5", ["f"] = "6"}, ["lastaccessed"] = os.time()}
        }

        --Writes the serialized baseDatabase table to the database file
        writeToFile(files.database, serialization.serialize(baseDatabase))
    end

    --Unserializes the data and puts it into the correct tables
    files.userData = serialization.unserialize(readFromFile(files.users))
    files.databaseData = serialization.unserialize(readFromFile(files.database))
end

--This function sets the "lastaccessed" key inside of a database to the latest time
local function dbTime(dbname)
    --Sets the lastaccessed key inside the specified database to os.time(), which is the currect time
    files.databaseData[dbname].lastaccessed = os.time()
end

--This function overwrites a database with a new copy
local function overwriteDatabase(dbname, newdb)
    --Sets the database to the new database
    files.databaseData[dbname] = newdb
    --Corrects lastaccessed
    dbTime(dbname)
end

--This function checks whether the user is signed in
local function checkSignin(username, password)
    --Checks if the user exists
    if files.userData[username] ~= nil then
        --Checks if the password exists
        if password == files.userData[username].password then
            --Returns that the sign in was good and the perms
            return "good", files.userData[username].perms
        end
        --Returns that the password was wrong and nil perms
        return "wrong_password", nil
    end
    --Returns that the user does no exists and nil perms
    return "user_not_exist", nil
end

--Handles a modem message
function eventHandlers.modem_message(_, origin, port, _, user, password, requestType, ...)
    --Sets some variables for use
    local signInStatus, perms = checkSignin(user, password)

    --Creates 2 variables for storing functions, split into the read functions (rrequests) and the write functions (wrequests)
    local rrequests, wrequests =
        setmetatable(
            {},
            {
                __index = function()
                    return unknownEvent
                end
            }
        ),
        setmetatable(
            {},
            {
                __index = function()
                    return unknownEvent
                end
            }
        )

    --Creats the "already_exist" error messages
    errors.dbexists = "db_already_exist"
    errors.entryexists = "entry_already_exist"

    --Creates the "not_exist" error messages
    errors.dbnotexist = "db_not_exist"
    errors.entrynotexists = "entry_not_exist"

    --Creates a blank error
    errors.noerror = ""

    --The function for getting a database
    function rrequests.get_database(dbname)
        --Sets up some variables, dbData for the table that represents a database, and serializaedDBData which is just a serialized version of dbData
        local dbData = files.databaseData[dbname]
        local serializedDBData = serialization.serialize(dbData)

        --Checks if it exists, if not, output error "db_not_exist"
        if type(dbData) ~= "table" then
            return false, errors.dbnotexist, ""
        end

        --Sets the lastaccessed time to the current time
        dbTime(dbname)
        --Outputs how it succeeded, a blank error, and the serialized data
        return true, errors.noerror, serializedDBData
    end

    --The function for getting all databases
    function rrequests.get_all_databases()
        local serializedData = serialization.serialize(files.databaseData)

        --Outputs how it succeeded, a blank error, and the serialized data
        return true, errors.noerror, serializedData
    end

    --Deletes a database
    function wrequests.delete_database(dbname)
        --Gets the data for the database, only used for checking if it exists or not
        local dbData = files.databaseData[dbname]

        --Checks if it exists or not, if not than output error that it does not exist
        if type(dbData) ~= "table" then
            return false, errors.dbnotexist, ""
        end

        --Sets the database to nil, removing it
        files.databaseData[dbname] = nil
        --Outputs true for how it succeeded, blank error, and nothing
        return true, errors.noerror, ""
    end

    --Creates a database
    function wrequests.create_database(dbname)
        --Gets the data for the database, only used for checking if it exists or not
        local dbData = files.databaseData[dbname]

        --Checks if it exists already, if so output false for failed, dbexists for the database already exists, and blank
        if dbData == nil then
            --Creates the blank database with the specified name
            files.databaseData[dbname] = {}
            files.databaseData[dbname].data = {}
            files.databaseData[dbname].lastaccessed = os.time()

            --Returns true for it succeeding, a blank error, and a blank data
            return true, errors.noerror, ""
        end

        return false, errors.dbexists, ""
    end

    --Inserts an entry into a database
    function wrequests.insert_entry(dbname, entrykey, entrydata)
        --Gets the current data
        local dbData = files.databaseData[dbname].data

        --Checks if the db exists
        if type(dbData) == "table" then
            --Inserts the entry into the database
            dbData[entrykey] = serialization.unserialize(entrydata)

            --Overwrites the existing database with the new one
            files.databaseData[dbname].data = dbData
            --Fixes lastaccessed
            dbTime(files.databaseData[dbname])
            --Returns true for it succeeding, blank error, and no data
            return true, errors.noerror, ""
        end

        --Returns false for not succeeding, dbnotexist error, and blank data
        return false, errors.dbnotexist, ""
    end

    --Removes an entry from a database
    function wrequests.remove_entry(dbname, entryname)
        --Gets the data
        local dbData = files.databaseData[dbname].data

        --Checks if the database exists
        if type(dbData) == "table" then
            --Checks if the entry exists
            if type(dbData[entryname]) ~= "nil" then
                --Sets the entry to nil, removing it
                dbData[entryname] = nil

                --Overwrites the old database with the new one
                files.databaseData[dbname].data = dbData
                --Fixed lastaccessed
                dbTime(dbname)
                --Returns true for no error, blank error, and no data
                return true, errors.noerror, ""
            end

            --Returns false for error, entrynotexists error, and blank data
            return false, errors.entrynotexists, ""
        end

        --Returns false for error, dbnotexist error, and blank data
        return false, errors.dbnotexist, ""
    end

    --Sets some baseline variables
    local useraccepted, passwordaccepted, requestcompleted, requesterror, requestdata = false, false, false, "", ""

    --Checks if the sign in was good
    if signInStatus == "good" then
        --Checks if
        --Sets useraccepted and passwordaccepted to true
        useraccepted, passwordaccepted = true, true

        --Checks if the user has write perms
        if perms == "w" then
            --Sets the requestcompleted, requesterror, and requestdata to the output of the function inside of the wrequests table
            requestcompleted, requesterror, requestdata = wrequests[requestType](...)
        end
        --Checks if the user has read or write perms
        if (perms == "r") or (perms == "w") then
            --Sets the requestcompleted, requesterror, and requestdata to the output of the function inside of the rrequests table
            requestcompleted, requesterror, requestdata = rrequests[requestType](...)
        end
    elseif signInStatus == "user_not_exist" then
        --If the user does not exists, set useraccepted and passwordaccepted to false
        useraccepted, passwordaccepted = false, false
    elseif signInStatus == "wrong_password" then
        --If the user was correct but the password was not, set useraccepted to true and passwordaccepted to false
        useraccepted, passwordaccepted = true, false
    end

    --Prints the completed response to console
    print(requestType, origin, ports.DB, useraccepted, passwordaccepted, requestcompleted, requesterror, requestdata)
    --Sends the completed response back to the origin
    modem.send(origin, ports.DB, useraccepted, passwordaccepted, requestcompleted, requesterror, requestdata)

    writeToFile(files.database, serialization.serialize(files.databaseData))
end

--Stops the program if the interrupted event gets triggered
function eventHandlers.interrupted()
    print("Server stopped")
    running = false
end

-- The main event handler as function to separate eventID from the remaining arguments
local function handleEvent(eventID, ...)
    if (eventID) then -- can be nil if no event was pulled for some time
        eventHandlers[eventID](...) -- call the appropriate event handler with all remaining arguments
    end
end

--The main setup block
networkSetup()
fileSetup()

--Registers all the event listeners
eventIDs.interrupted = event.listen("interrupted", handleEvent)
eventIDs.modem_message = event.listen("modem_message", handleEvent)

--Prints to console that the server has successfully started
print("Server started")

--Continues looping until running == false, which only occurs after an interrupted event
while running do
    os.sleep(0.1)
end

--Cancells all event listeners
for k, v in pairs(eventIDs) do
    print("cancel " .. k, event.ignore(k, handleEvent))
end
