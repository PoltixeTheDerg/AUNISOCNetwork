--Sets all the requires and such idk what these are actually called
local event = require("event")
local os = require("os")
local serialization = require("serialization")
local component = require("component")
local modem = component.modem
local running = true
local dbUser = "root"
local dbPass = "password"
local currentGateType = ""
local stopDial = false
local db = require("db")
local sg = component.stargate
local split = require("split")

local function unknownEvent()
    -- do nothing
end

--Sets up tables to be filled
local ports = {}
local databases = {}
local eventIDs = {}
local gateTypes = {}
local glyphConversion = {}
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

--Sets up all network related things
local function mainSetup()
    --The main ports the dialing server uses
    ports.dial = 69
    ports.gateSignals = 70
    ports.DB = 126

    --The name of the address database
    databases.storedAddressesName = "sgAddresses"

    --Creates the table where the database is stored
    databases.storedAddresses = {}

    --Creates all the gate types
    gateTypes.MILKYWAY = "MW"
    gateTypes.PEGASUS = "PG"
    gateTypes.UNIVERSE = "UN"

    --Creates the tables where the glyph conversions are stored for each type
    glyphConversion.MW = {}
    glyphConversion.PG = {}
    glyphConversion.UN = {}

    --Same glyph conversion as the one devised by FlamePoint#8908
    glyphConversion.MW["q"] = "Point of Origin"
    glyphConversion.MW["w"] = "Crater"
    glyphConversion.MW["e"] = "Virgo"
    glyphConversion.MW["r"] = "Bootes"
    glyphConversion.MW["t"] = "Centaurus"
    glyphConversion.MW["y"] = "Libra"
    glyphConversion.MW["u"] = "Serpens Caput"
    glyphConversion.MW["i"] = "Norma"
    glyphConversion.MW["o"] = "Scorpius"
    glyphConversion.MW["p"] = "Corona Australis"
    glyphConversion.MW["["] = "Scutum"
    glyphConversion.MW["]"] = "Sagittarius"
    glyphConversion.MW["\\"] = "Aquila"
    glyphConversion.MW["a"] = "Microscopium"
    glyphConversion.MW["s"] = "Capricornus"
    glyphConversion.MW["d"] = "Piscis Austrinus"
    glyphConversion.MW["f"] = "Equuleus"
    glyphConversion.MW["g"] = "Aquarius"
    glyphConversion.MW["h"] = "Pegasus"
    glyphConversion.MW["j"] = "Sculptor"
    glyphConversion.MW["k"] = "Pisces"
    glyphConversion.MW["l"] = "Andromeda"
    glyphConversion.MW[";"] = "Triangulum"
    glyphConversion.MW["'"] = "Aries"
    glyphConversion.MW["z"] = "Perseus"
    glyphConversion.MW["x"] = "Cetus"
    glyphConversion.MW["c"] = "Taurus"
    glyphConversion.MW["v"] = "Auriga"
    glyphConversion.MW["b"] = "Eridanus"
    glyphConversion.MW["n"] = "Orion"
    glyphConversion.MW["m"] = "Canis Minor"
    glyphConversion.MW[","] = "Monoceros"
    glyphConversion.MW["."] = "Gemini"
    glyphConversion.MW["/"] = "Hydra"
    glyphConversion.MW["1"] = "Lynx"
    glyphConversion.MW["2"] = "Cancer"
    glyphConversion.MW["3"] = "Sextans"
    glyphConversion.MW["4"] = "Leo Minor"
    glyphConversion.MW["5"] = "Leo"

    --New pegasus glyph conversion devised by me
    glyphConversion.PG["q"] = "Subido"
    glyphConversion.PG["w"] = "Aaxel"
    glyphConversion.PG["e"] = "Abrin"
    glyphConversion.PG["r"] = "Acjesis"
    glyphConversion.PG["t"] = "Aldeni"
    glyphConversion.PG["y"] = "Alura"
    glyphConversion.PG["u"] = "Amiwill"
    glyphConversion.PG["i"] = "Arami"
    glyphConversion.PG["o"] = "Avoniv"
    glyphConversion.PG["p"] = "Baselai"
    glyphConversion.PG["["] = "Bydo"
    glyphConversion.PG["]"] = "Ca Po"
    glyphConversion.PG["\\"] = "Danami"
    glyphConversion.PG["a"] = "Dawnre"
    glyphConversion.PG["s"] = "Ecrumig"
    glyphConversion.PG["d"] = "Elenami"
    glyphConversion.PG["f"] = "Gilltin"
    glyphConversion.PG["g"] = "Hacemill"
    glyphConversion.PG["h"] = "Hamlinto"
    glyphConversion.PG["j"] = "Illume"
    glyphConversion.PG["k"] = "Laylox"
    glyphConversion.PG["l"] = "Lenchan"
    glyphConversion.PG[";"] = "Olavii"
    glyphConversion.PG["'"] = "Once el"
    glyphConversion.PG["z"] = "Poco re"
    glyphConversion.PG["x"] = "Ramnon"
    glyphConversion.PG["c"] = "Recktic"
    glyphConversion.PG["v"] = "Robandus"
    glyphConversion.PG["b"] = "Roehi"
    glyphConversion.PG["n"] = "Salma"
    glyphConversion.PG["m"] = "Sandovi"
    glyphConversion.PG[","] = "Setas"
    glyphConversion.PG["."] = "Sibbron"
    glyphConversion.PG["/"] = "Tahnan"
    glyphConversion.PG["1"] = "Zamilloz"
    glyphConversion.PG["2"] = "Zeo"

    --New universe glyph conversion devised by me
    glyphConversion.UN["q"] = 17
    glyphConversion.UN["w"] = 1
    glyphConversion.UN["e"] = 2
    glyphConversion.UN["r"] = 3
    glyphConversion.UN["t"] = 4
    glyphConversion.UN["y"] = 5
    glyphConversion.UN["u"] = 6
    glyphConversion.UN["i"] = 7
    glyphConversion.UN["o"] = 8
    glyphConversion.UN["p"] = 9
    glyphConversion.UN["["] = 10
    glyphConversion.UN["]"] = 11
    glyphConversion.UN["\\"] = 12
    glyphConversion.UN["a"] = 13
    glyphConversion.UN["s"] = 14
    glyphConversion.UN["d"] = 15
    glyphConversion.UN["f"] = 16
    glyphConversion.UN["g"] = 18
    glyphConversion.UN["h"] = 19
    glyphConversion.UN["j"] = 20
    glyphConversion.UN["k"] = 21
    glyphConversion.UN["l"] = 22
    glyphConversion.UN[";"] = 23
    glyphConversion.UN["'"] = 24
    glyphConversion.UN["z"] = 25
    glyphConversion.UN["x"] = 26
    glyphConversion.UN["c"] = 27
    glyphConversion.UN["v"] = 28
    glyphConversion.UN["b"] = 29
    glyphConversion.UN["n"] = 30
    glyphConversion.UN["m"] = 31
    glyphConversion.UN[","] = 32
    glyphConversion.UN["."] = 33
    glyphConversion.UN["/"] = 34
    glyphConversion.UN["1"] = 35
    glyphConversion.UN["2"] = 36

    --Gets the current gate type and sets currentGateType to the proper acronym for the gate
    currentGateType = gateTypes[sg.getGateType()]
    print("gate type is", currentGateType)

    --Opens all ports in the ports table
    for k, v in pairs(ports) do
        --Opens the ports
        modem.open(ports[k])
    end

    --Gets the address database from the database server
    local useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
        db.get_database(dbUser, dbPass, databases.storedAddressesName)

    print(requestdataRaw)

    --local requestData = serialization.unserialize(requestdataRaw)

    --Prints the data got back from the database server
    print(useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw)

    --Checks if the database does not exist
    if requesterror == "db_not_exist" then
        print("The database does not exist")

        --If it does not exist create it
        local useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
            db.create_database(dbUser, dbPass, databases.storedAddressesName)

        print("create_database", useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw)
    end

    --After making sure that the database exists and if not creating it, get the database to check for the sample address
    local useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
        db.get_database(dbUser, dbPass, databases.storedAddressesName)

    local requestData = serialization.unserialize(requestdataRaw)

    --Checks if the sample address does not exist
    if type(requestData.data.sample) == "nil" then
        print("The sample entry does not exist")

        --If not create it
        print(
            db.insert_entry(
                dbUser,
                dbPass,
                databases.storedAddressesName,
                "sample",
                {["MW"] = "wertyu", ["PG"] = "wertyu", ["UN"] = "wertyu"}
            )
        )

        print("insert_entry", useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw)
    end
end

--This function dials an address
local function dialAddress(address)
    --Broadcasts on the gateSignals port that a dialing sequence has begun
    modem.broadcast(ports.gateSignals, "begin_dial_sequence", serialization.serialize(address), #address)

    stopDial = false

    for i = 1, #address do
        if stopDial then
            modem.broadcast(ports.gateSignals, "dial_ended")
            break
        end
        --Engages the symbol
        local engageOutput = sg.engageSymbol(address[i])
        modem.broadcast(ports.gateSignals, "dialing_symbol", i, #address)
        if engageOutput == "stargate_spin" then
            local _, _, _, symbolCount, lock, symbolName = event.pull("stargate_spin_chevron_engaged")

            --Broadcast on the gateSignals port that another symbol was dialed
            modem.broadcast(ports.gateSignals, "symbol_dialed", i, #address)

            print(symbolCount, lock, symbolName)
        else
            modem.broadcast(ports.gateSignals, "dial_ended")
        end
    end

    --After dialing engage the gate
    print(sg.engageGate())
end

--Handles modem messages
function eventHandlers.modem_message(_, origin, port, _, requestType, ...)
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

    --Creates a blank error
    errors.noerror = ""

    --The function for getting the address database
    function requests.get_database()
        print("getting database")
        local useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
            db.get_database(dbUser, dbPass, databases.storedAddressesName)

        print("database got", useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw)

        return useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw
    end

    --The function for closing the gate
    function requests.close_gate()
        print("closing gate")
        sg.disengageGate()
    end

    --The function for ending a dial sequence
    function requests.end_dial()
        print("ending dial")
        stopDial = true
    end

    --The function for dialing the gate from a manual address
    function requests.dial_address(address)
        local useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw = true, true, true, true, false

        --convert address to the correct format
        local convertedAddress = split(address, "")

        table.insert(convertedAddress, "q")

        for i = 1, #convertedAddress do
            convertedAddress[i] = glyphConversion[currentGateType][convertedAddress[i]]
        end
        --end convert

        dialAddress(convertedAddress)

        return useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw
    end

    --The function for dialing the gate from the database
    function requests.dial_database(addressName)
        addressName = addressName:gsub("%s+", "")

        print("getting database")
        local useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
            db.get_database(dbUser, dbPass, databases.storedAddressesName)

        print("database got", useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw)

        local databaseData = serialization.unserialize(requestdataRaw).data

        print(requestdataRaw, addressName)

        print(serialization.serialize(databaseData[addressName]))

        if type(databaseData[addressName]) ~= "nil" then
            --convert address to the correct format
            local convertedAddress = split(databaseData[addressName][currentGateType], "")

            table.insert(convertedAddress, "q")

            for i = 1, #convertedAddress do
                convertedAddress[i] = glyphConversion[currentGateType][convertedAddress[i]]
            end
            --end convert

            --Dials address
            dialAddress(convertedAddress)
        end
    end

    --The function for adding an address to the database
    function requests.add_address(addressName, addressMW, addressPG, addressUN)
        print("adding entry to database", addressName, addressMW, addressPG, addressUN)

        addressName = addressName:gsub("%s+", "")

        local useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
            db.insert_entry(
            dbUser,
            dbPass,
            databases.storedAddressesName,
            addressName,
            {["MW"] = addressMW, ["PG"] = addressPG, ["UN"] = addressUN}
        )

        print("inserted got", useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw)

        return useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw
    end

    --The function for removing an address from the database
    function requests.remove_address(addressName)
        print("removing entry from database")

        addressName = addressName:gsub("%s+", "")

        local useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
            db.remove_entry(dbUser, dbPass, databases.storedAddressesName, addressName)

        print("removed", useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw)

        return useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw
    end

    --The function for getting the power data from the gate
    function requests.get_power_data()
        local storedEnergy = sg.getEnergyStored()
        local maxEnergy = sg.getMaxEnergyStored()
        local capacitorsInstalled = sg.getCapacitorsInstalled()

        print(storedEnergy, maxEnergy, capacitorsInstalled)

        return true, true, true, false, serialization.serialize({storedEnergy, maxEnergy, capacitorsInstalled})
    end

    function requests.get_gate_address()
        return true, true, true, false, serialization.serialize(sg.stargateAddress)
    end

    function requests.get_gate_status()
        return sg.getGateStatus()
    end

    --The function for getting the gate type
    function requests.get_gate_type()
        return true, true, true, false, sg.getGateType()
    end

    --Runs the correct function and gets the correct output
    local userAccepted, passAccepted, requestCompleted, requestError, requestDataOutput = requests[requestType](...)

    --Prints the completed response to console
    print(requestType, origin, ports.dial, requestDataOutput)
    --Sends the completed response back to the origin
    modem.send(origin, ports.dial, requestDataOutput)
end

--Stops the program if the interrupted event gets triggered
function eventHandlers.interrupted()
    print("Server stopped")
    running = false
end

--Broadcasts on the gateSignals port that a chevron was engaged
function eventHandlers.stargate_spin_chevron_engaged(_, _, symbolCount, lock, symbolName)
    modem.broadcast(ports.gateSignals, "stargate_spin_chevron_engaged", symbolCount, lock, symbolName)
end

--Broadcasts on the gateSignals port that there is an incoming wormhole
function eventHandlers.stargate_incoming_wormhole(_, _, dialedAddressSize)
    modem.broadcast(ports.gateSignals, "stargate_incoming_wormhole", dialedAddressSize)
end

--Broadcasts on the gateSignals port that the gate is opening
function eventHandlers.stargate_open(_, _, isInitiating)
    modem.broadcast(ports.gateSignals, "stargate_open", isInitiating)
end

--Broadcasts on the gateSignals port that the gate closed
function eventHandlers.stargate_close(_, _)
    modem.broadcast(ports.gateSignals, "stargate_close")
end

--Broadcasts on the gateSignals port that the gate failed
function eventHandlers.stargate_failed(_, _)
    modem.broadcast(ports.gateSignals, "stargate_failed")
end

--Broadcasts on the gateSignals port that there is a traveler
function eventHandlers.stargate_traveler(_, _, inbound, player)
    modem.broadcast(ports.gateSignals, "stargate_traveler", inbound, player)
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
eventIDs.stargate_spin_chevron_engaged = event.listen("stargate_spin_chevron_engaged", handleEvent)
eventIDs.stargate_dhd_chevron_engaged =
    event.listen("stargate_dhd_chevron_engaged", eventHandlers.stargate_spin_chevron_engaged)
eventIDs.stargate_incoming_wormhole = event.listen("stargate_incoming_wormhole", handleEvent)
eventIDs.stargate_open = event.listen("stargate_open", handleEvent)
eventIDs.stargate_close = event.listen("stargate_close", handleEvent)
eventIDs.stargate_failed = event.listen("stargate_failed", handleEvent)
eventIDs.stargate_traveler = event.listen("stargate_traveler", handleEvent)

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
