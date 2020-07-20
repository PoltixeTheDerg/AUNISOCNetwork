local db = {}
local c = require("component")
local m = c.modem
local e = require("event")
local s = require("serialization")

m.open(126)

function db.get_database(user, pass, dbname)
    m.broadcast(126, user, pass, "get_database", dbname)

    local _, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
        e.pull("modem_message")

    return useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw
end

function db.get_all_databases(user, pass)
    m.broadcast(126, user, pass, "get_all_databases")

    local _, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
        e.pull("modem_message")

    return useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw
end

function db.delete_database(user, pass, dbname)
    m.broadcast(126, user, pass, "delete_database", dbname)

    local _, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
        e.pull("modem_message")

    return useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw
end

function db.create_database(user, pass, dbname)
    m.broadcast(126, user, pass, "create_database", dbname)

    local _, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
        e.pull("modem_message")

    return useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw
end

function db.insert_entry(user, pass, dbname, entrykey, entrydata)
    print("test")
    m.broadcast(126, user, pass, "insert_entry", dbname, entrykey, s.serialize(entrydata))

    local _, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
        e.pull("modem_message")

    return useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw
end

function db.remove_entry(user, pass, dbname, entryname)
    m.broadcast(126, user, pass, "remove_entry", dbname, entryname)

    print("broadcasted the damn message")

    local _, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
        e.pull("modem_message")

    print("received or whatever")

    return useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw
end

return db
