local component = require("component")
local gpu = component.gpu
gpu.setResolution(80, 25)
local gui = require("gui")
local event = require("event")
local modem = component.modem
local serialization = require("serialization")

gui.checkVersion(2, 5)

local prgName = "dialer"
local version = "v1.0"
local currentlySelectedAddress = ""
local manualDialText = ""
local addAddressName = ""
local addAddressMW = ""
local addAddressPG = ""
local addAddressUN = ""
local dialingAddressLength = 0
local currentDialedAmount = 0

-- Begin: Callbacks
local function list_database_callback(guiID, listID, selected, text)
   currentlySelectedAddress = text
end

local function button_refresh_database_callback(guiID, buttonID)
   modem.send("0be49cee-a198-4d52-9acf-8e263bee3dbd", 69, "get_database")

   local _, _, _, _, _, requestdataRaw = event.pull("modem_message")

   local databaseData = serialization.unserialize(requestdataRaw)

   gui.clearList(guiID, list_database)

   for k, v in pairs(databaseData.data) do
      if k ~= "lastaccessed" then
         gui.insertList(guiID, list_database, k)
      end
   end
end

local function button_dial_database(guiID, buttonID)
   modem.send("0be49cee-a198-4d52-9acf-8e263bee3dbd", 69, "dial_database", currentlySelectedAddress)
end

local function button_delete_database_callback(guiID, buttonID)
   modem.send("0be49cee-a198-4d52-9acf-8e263bee3dbd", 69, "remove_address", currentlySelectedAddress)
end

local function button_close_gate_callback(guiID, buttonID)
   modem.send("0be49cee-a198-4d52-9acf-8e263bee3dbd", 69, "close_gate")
end

local function button_end_dial_callback(guiID, buttonID)
   modem.send("0be49cee-a198-4d52-9acf-8e263bee3dbd", 69, "end_dial")
end

local function text_dial_manual(guiID, textID, text)
   manualDialText = text
end

local function text_add_address_name(guiID, textID, text)
   addAddressName = text
end

local function text_add_address_mw(guiID, textID, text)
   addAddressMW = text
end

local function text_add_address_pg(guiID, textID, text)
   addAddressPG = text
end

local function text_add_address_un(guiID, textID, text)
   addAddressUN = text
end

local function button_dial_manual_callback(guiID, buttonID)
   modem.send("0be49cee-a198-4d52-9acf-8e263bee3dbd", 69, "dial_address", manualDialText)
end

local function button_add_address_callback(guiID, buttonID)
   modem.send(
      "0be49cee-a198-4d52-9acf-8e263bee3dbd",
      69,
      "add_address",
      addAddressName,
      addAddressMW,
      addAddressPG,
      addAddressUN
   )
end

local function hprogress_dial_progress(guiID, hProgressID)
   -- Your code here
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
list_database = gui.newList(mainGui, 1, 1, 20, 10, {}, list_database_callback, "Database")
button_refresh_database = gui.newButton(mainGui, 2, 12, "Refresh Database", button_refresh_database_callback)
button_dial_database = gui.newButton(mainGui, 1, 13, "Dial from database", button_dial_database)
button_delete_database = gui.newButton(mainGui, 4, 14, "Delete entry", button_delete_database_callback)
button_close_gate = gui.newButton(mainGui, 5, 15, "Close Gate", button_close_gate_callback)
button_end_dial = gui.newButton(mainGui, 1, 16, "End dialing sequence", button_end_dial_callback)
text_dial_manual = gui.newText(mainGui, 1, 18, 8, "Manual Address Input", text_dial_manual, 20, false)
text_add_address_name = gui.newText(mainGui, 22, 4, 100, "Add Address Name", text_add_address_name, 20, false)
text_add_address_mw = gui.newText(mainGui, 22, 5, 8, "Add Address MW", text_add_address_mw, 20, false)
text_add_address_pg = gui.newText(mainGui, 22, 6, 8, "Add Address PG", text_add_address_pg, 20, false)
text_add_address_un = gui.newText(mainGui, 22, 7, 8, "Add Address UN", text_add_address_un, 20, false)
button_add_address = gui.newButton(mainGui, 22, 8, "Add address to database", button_add_address_callback)
button_dial_manual = gui.newButton(mainGui, 2, 19, "Dial from Manual", button_dial_manual_callback)
label_gate_type = gui.newLabel(mainGui, 1, 21, "type", 0xc0c0c0, 0x0, 7)
exitButton = gui.newButton(mainGui, 73, 23, "exit", exitButtonCallback)
-- End: Menu definitions

gui.clearScreen()
gui.setTop("Stargate Dialing")
gui.setBottom("Made by PoltixeTheDerg")

modem.open(69)
modem.open(70)

modem.send("0be49cee-a198-4d52-9acf-8e263bee3dbd", 69, "get_gate_type")

local _, _, _, _, _, requestdataRaw = event.pull("modem_message")

gui.setText(mainGui, label_gate_type, requestdataRaw, true)

-- Main loop
while true do
   gui.runGui(mainGui)
end
