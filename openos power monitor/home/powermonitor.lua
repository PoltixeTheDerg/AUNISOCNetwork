local event = require("event")
local component = require("component")
local os = require("os")
local serialization = require("serialization")
local gui = require("gui")
local ancientCharacters = require("ancient")
local modem = component.modem

modem.open(69)

local graphs = {}
local glyphs = {}
local running = true
local dialServAddress = "0be49cee-a198-4d52-9acf-8e263bee3dbd"

graphs[1] = gui.createNewGraph(10, 6, 140, 40, "powergraph", "Time (x)", "Power (y)", 0x999999, 0xFFFFFF)

local function refresh()
    modem.send(dialServAddress, 69, "get_power_data")

    local _, _, _, _, _, requestdataRaw = event.pull("modem_message")

    local powerData = serialization.unserialize(requestdataRaw)

    local powerDataScaled = (powerData[1] / powerData[2]) * 100

    --print(tostring(powerDataScaled))

    gui.refreshGraph(graphs[1], powerDataScaled)
end

local function stopProgram()
    print("stopping program")
    running = false
end

event.listen("interrupted", stopProgram)
modem.open(69)
local refreshGraphTimer = event.timer(0.5, refresh, math.huge)

while running do
    gui.clearScreen(0x000000)
    gui.renderGraphs(graphs)
    gui.renderGlyphs(glyphs)
    os.sleep(0.1)
end

event.ignore("interrupted", stopProgram)
event.cancel(refreshGraphTimer)
modem.close(69)
