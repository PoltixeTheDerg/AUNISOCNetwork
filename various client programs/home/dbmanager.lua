--sets some stuff up? still don't know what these are called
local component = require("component")
local gpu = component.gpu
gpu.setResolution(80, 25)
local gui = require("gui")
local event = require("event")
local modem = component.modem
local serialization = require("serialization")

--Checks the vesion
gui.checkVersion(2, 5)

--Sets some variables up
local prgName = "dbmanager"
local version = "v1.0"
local currentlySelectedDatabase = ""
local currentlySelectedEntry = ""
local inputtedUsername = "root"
local inputtedPassword = "password"
local addDatabaseName = ""
local addEntryKey = "Entry Key"
local addEntryData = "Entry Data"
local currentDatabase = ""
local currentDatabaseData = {}
modem.open(126)

local function refreshLists()
   modem.broadcast(126, inputtedUsername, inputtedPassword, "get_all_databases")
   gui.setValue(mainGui, command_progress, 2)
   local _, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
      event.pull("modem_message")
   gui.setValue(mainGui, command_progress, 5)

   gui.clearList(mainGui, database_list)
   gui.setValue(mainGui, command_progress, 7)

   if requestdataRaw ~= nil then
      for k, v in pairs(serialization.unserialize(requestdataRaw)) do
         gui.insertList(mainGui, database_list, k)
         gui.setValue(mainGui, command_progress, 10)
      end
   end

   gui.setValue(mainGui, command_progress, 0)
end

-- Begin: Callbacks
local function command_progress_callback(guiID, hProgressID)
   -- Your code here
end

local function database_list_callback(guiID, listID, selected, text)
   currentDatabase = text
   modem.broadcast(126, inputtedUsername, inputtedPassword, "get_database", text)

   local _, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
      event.pull("modem_message")

   currentDatabaseData = serialization.unserialize(requestdataRaw)

   gui.clearList(guiID, loaded_database_list)

   if currentDatabaseData.data ~= nil then
      for k, v in pairs(currentDatabaseData.data) do
         gui.insertList(guiID, loaded_database_list, '["' .. tostring(k) .. '"] = ' .. tostring(v))
         gui.setValue(guiID, command_progress, 10)
      end
   end
   gui.setValue(guiID, command_progress, 0)

   currentlySelectedDatabase = text
end

local function button_deletedatabase_callback(guiID, buttonID)
   modem.broadcast(126, inputtedUsername, inputtedPassword, "delete_database", currentDatabase)

   local _, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
      event.pull("modem_message")

   refreshLists()
end

local function delete_entry_callback(guiID, buttonID)
   refreshLists()

   modem.broadcast(126, inputtedUsername, inputtedPassword, "remove_entry", currentDatabase, currentlySelectedEntry)

   local _, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
      event.pull("modem_message")

   refreshLists()
end

local function loaded_database_list_callback(guiID, listID, selected, text)
   currentlySelectedEntry = text
end

local function entry_key_input_callback(guiID, textID, text)
   addEntryKey = text
end

local function entry_data_input_callback(guiID, textID, text)
   addEntryData = text
end

local function entry_button_callback(guiID, buttonID)
   modem.broadcast(126, inputtedUsername, inputtedPassword, "insert_entry", currentDatabase, addEntryKey, addEntryData)

   local _, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
      event.pull("modem_message")

   refreshLists()
   refreshLists()
end

local function add_database_button_callback(guiID, buttonID)
   modem.broadcast(126, inputtedUsername, inputtedPassword, "create_database", addDatabaseName)
   gui.setValue(guiID, command_progress, 5)

   local _, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
      event.pull("modem_message")
   gui.setValue(guiID, command_progress, 10)

   refreshLists()
end

local function add_database_name_callback(guiID, textID, text)
   addDatabaseName = text
end

local function username_callback(guiID, textID, text)
   inputtedUsername = text
   -- Your code here
end

local function password_callback(guiID, textID, text)
   inputtedPassword = text
   -- Your code here
end

local function refresh_button_callback(guiID, buttonID)
   modem.broadcast(126, inputtedUsername, inputtedPassword, "get_all_databases")
   gui.setValue(guiID, command_progress, 2)
   local _, _, _, _, _, useraccepted, passaccepted, requestcompleted, requesterror, requestdataRaw =
      event.pull("modem_message")
   gui.setValue(guiID, command_progress, 5)

   gui.clearList(guiID, database_list)
   gui.setValue(guiID, command_progress, 7)

   local requestdata = serialization.unserialize(requestdataRaw)

   for k, v in pairs(requestdata) do
      gui.insertList(guiID, database_list, k)
      gui.setValue(guiID, command_progress, 10)
   end
   gui.setValue(guiID, command_progress, 0)
end

local function exitButtonCallback(guiID, id)
   local result = gui.getYesNo("", "Do you really want to exit?", "")
   if result == true then
      gui.exit()
   end
   gui.displayGui(mainGui)
end
-- End: Callbacks

-- Begin: Menu definitions
mainGui = gui.newGui(1, 2, 79, 23, true)
command_progress = gui.newProgress(mainGui, 1, 21, 16, 10, 0, command_progress_callback, false)
database_list = gui.newList(mainGui, 1, 2, 20, 10, {}, database_list_callback)
gui.insertList(mainGui, database_list, "No Database loaded")
timelabel = gui.newTimeLabel(mainGui, 61, 21, 0xc0c0c0, 0x0)
datelabel = gui.newDateLabel(mainGui, 67, 21, 0xc0c0c0, 0x0)
delete_database_button = gui.newButton(mainGui, 1, 13, "Delete Database", button_deletedatabase_callback)
delete_entry_button = gui.newButton(mainGui, 22, 13, "Delete Entry", delete_entry_callback)
loaded_database_list = gui.newList(mainGui, 22, 2, 20, 10, {}, loaded_database_list_callback)
gui.insertList(mainGui, loaded_database_list, "No Database loaded")
all_db_label = gui.newLabel(mainGui, 1, 1, "All Databases", 0xc0c0c0, 0x0, 7)
database_label = gui.newLabel(mainGui, 22, 1, "Database", 0xc0c0c0, 0x0, 7)
entry_key_input = gui.newText(mainGui, 43, 2, 50, "Entry key", entry_key_input_callback, 11, false)
entry_data_input = gui.newText(mainGui, 43, 3, 50, "Entry Data", entry_data_input_callback, 11, false)
add_entry_button = gui.newButton(mainGui, 43, 4, "Add entry", entry_button_callback)
add_database_button = gui.newButton(mainGui, 43, 7, "Add database", add_database_button_callback)
add_database_name = gui.newText(mainGui, 43, 6, 50, "Database Name", add_database_name_callback, 14, false)
username = gui.newText(mainGui, 18, 21, 10, "root", username_callback, 10, false)
password = gui.newText(mainGui, 29, 21, 10, "password", password_callback, 10, false)
refresh_button = gui.newButton(mainGui, 40, 21, "Refresh", refresh_button_callback)
exitButton = gui.newButton(mainGui, 73, 23, "exit", exitButtonCallback)
-- End: Menu definitions

gui.clearScreen()
gui.setTop("Database Manager")
gui.setBottom("Made by PoltixeTheDerg")

-- Main loop
while true do
   gui.runGui(mainGui)
end
