--Sets all the requires and such idk what these are actually called
local event = require("event")
local os = require("os")
local serialization = require("serialization")
local component = require("component")
local modem = component.modem
local running = true
local dbUser = "root"
local dbPass = "password"
local db = require("db")
local split = require("split")

local function unknownEvent()
    -- do nothing
end

--Sets up tables to be filled
local ports = {}
local databases = {}
local eventIDs = {}
local errors = {}
local eventHandlers =
    setmetatable(
    {},
    {
        __index = function()
            return unknownEvent
        end
    }
)

--Sets up all things
local function mainSetup()
    --The main ports the dialing server uses
    ports.DB = 126
    ports.personnelFiles = 11769

    --The name of the address database
    databases.personnelFilesName = "personnelFiles"

    --Creats the "already_exist" error messages
    errors.dbexists = "db_already_exist"
    errors.entryexists = "entry_already_exist"

    --Creates the "not_exist" error messages
    errors.dbnotexist = "db_not_exist"
    errors.entrynotexists = "entry_not_exist"

    --Creates a blank error
    errors.noerror = ""

    --Opens all ports in the ports table
    for k, v in pairs(ports) do
        --Opens the ports
        modem.open(ports[k])
    end

    --Gets the address database from the database server
    local userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw =
        db.get_database(dbUser, dbPass, databases.personnelFilesName)

    print(requestDataRaw)

    --Prints the data got back from the database server
    print(userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw)

    --Checks if the database does not exist
    if requestError == errors.dbnotexist then
        print("The database does not exist")

        --If it does not exist create it
        local userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw =
            db.create_database(dbUser, dbPass, databases.personnelFilesName)

        print("create_database", userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw)
    end

    --After making sure that the database exists and if not creating it, get the database to check for the sample address
    local userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw =
        db.get_database(dbUser, dbPass, databases.personnelFilesName)

    local dbData = serialization.unserialize(requestDataRaw)

    --Checks if the sample address does not exist
    if type(dbData.data["e1a2192c87204eb2854215d2e7632a72"]) == "nil" then
        print("The sample entry does not exist")

        --If not create it
        print(
            "test1 " ..
                db.insert_entry(
                    dbUser,
                    dbPass,
                    databases.personnelFilesName,
                    "e1a2192c87204eb2854215d2e7632a72",
                    {
                        ["lastknownlocation"] = "wertyuio",
                        ["position"] = "Programmer",
                        ["description"] = "tried to make this system plug and play, run and done"
                    }
                )
        )

        print("insert_entry", userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw)
    end
end

--Handles modem messages
function eventHandlers.modem_message(_, origin, port, _, requestType, user, password, ...)
    print(origin, port, requestType, ...)
    --Creates a table for storing functions
    local requests =
        setmetatable(
        {},
        {
            __index = function()
                return unknownEvent
            end
        }
    )

    --The function for getting the address database

    function requests.get_database()
        print("getting database")
        local userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw =
            db.get_database(dbUser, dbPass, databases.personnelFilesName)

        print("database got", userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw)

        return userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw
    end

    --The function for adding an address to the database
    function requests.add_entry(playerUUID, lastknownlocation, position, description)
        print("adding entry to database", playerUUID, lastknownlocation, position, description)

        local userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw =
            db.insert_entry(
            user,
            password,
            databases.personnelFilesName,
            playerUUID,
            {["lastknownlocation"] = lastknownlocation, ["position"] = position, ["description"] = description}
        )

        print("inserted got", userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw)

        return userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw
    end

    --The function for removing an address from the database
    function requests.remove_entry(playerUUID)
        print("removing entry from database")

        local userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw =
            db.remove_entry(user, password, databases.personnelFilesName, playerUUID)

        print("removed", userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw)

        return userAccepted, passAccepted, requestCompleted, requestError, requestDataRaw
    end

    --Runs the correct function and gets the correct output
    local userAccepted, passAccepted, requestCompleted, requestError, requestDataOutput = requests[requestType](...)

    --Prints the completed response to console
    print(requestType, origin, ports.personnelFiles, requestDataOutput)
    --Sends the completed response back to the origin
    modem.send(
        origin,
        ports.personnelFiles,
        userAccepted,
        passAccepted,
        requestCompleted,
        requestError,
        requestDataOutput
    )
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

--Sets up a lot of things
mainSetup()

--Registers all the event listeners
eventIDs.interrupted = event.listen("interrupted", handleEvent)
eventIDs.modem_message = event.listen("modem_message", handleEvent)
--Prints to console that the server has successfully started
print("Server started")

--Continues looping until running == false, which only occurs after an interrupted event
while running do
    os.sleep(0.1)
end
