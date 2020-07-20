--Sets all the requires and such idk what these are actually called
local event = require("event")
local os = require("os")
local serialization = require("serialization")
local component = require("component")
local db = require("db")
local modem = component.modem

print(serialization.serialize(db.getDB("root", "password", "db1")))
