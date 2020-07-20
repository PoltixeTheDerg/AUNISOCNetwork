local c = require("component")
local m = c.modem
local e = require("event")
local s = require("serialization")
local db = {}

m.open(126)

function db.getDB(user, pass, dbname)
    m.broadcast(126, user, pass, "get_database", dbname)

    local function handle(_, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdata)
        if (useraccepted == true) and (passaccepted == true) and (requestcompleted == true) then
            return s.unserialize(requestdata)
        elseif (useraccepted == true) and (passaccepted == true) and (requestcompleted == false) then
            return requesterror
        end
        if passaccepted == false then
            return "bad_password"
        end
        return "bad_username"
    end

    return handle(e.pull("modem_message"))
end

return db
