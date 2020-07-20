-- Import libraries
local screen = require("Screen")
local image = require("Image")
local event = require("Event")
local component = require("component")
local GUI = require("GUI")
local color = require("Color")
local filesystem = require("Filesystem")
local system = require("System")
local paths = require("Paths")
local system = require("System")
local text = require("Text")
local number = require("Number")
local modem = component.modem
local dialServerAddress = "0be49cee-a198-4d52-9acf-8e263bee3dbd"

modem.open(69)

CurrentChartX = 2
MaxChartX = 60

---------------------------------------------------------------------------------

-- Add a new window to MineOS workspace
local workspace, window, menu = system.addWindow(GUI.titledWindow(1, 1, 140, 40, "Power Monitor", true))

-- Get localization table dependent of current system language
local localization = system.getCurrentScriptLocalization()

-- Add single cell layout to window
local layout = window:addChild(GUI.layout(1, 1, window.width, window.height, 1, 1))

--Add graph for showing current power levels
local chart =
  layout:addChild(
  GUI.chart(
    1,
    1,
    layout.width * (130 / 140),
    layout.height * 0.8,
    0xEEEEEE,
    0xAAAAAA,
    0x888888,
    0xFFDB40,
    0.25,
    0.25,
    "s",
    "mRF",
    true,
    {}
  )
)

table.insert(chart.values, {1, 0})

--add random data to graph
--for i = 1, 50 do
--table.insert(chart.values, {i, math.random(0, 100)})
--end

local progressBar =
  layout:addChild(
  GUI.progressBar(
    1,
    1,
    layout.width * (130 / 140),
    0x3366CC,
    0xAAAAAA,
    0xAAAAAA,
    0,
    true,
    true,
    localization.progressBarPowerLevel,
    "%"
  )
)

-- Add nice gray text object to layout
--layout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.greeting .. system.getUser()))

-- Create callback function with resizing rules when window changes its' size
window.onResize = function(newWidth, newHeight)
  window.backgroundPanel.width, window.backgroundPanel.height = newWidth, newHeight
  layout.width, layout.height = newWidth, newHeight

  window.titlePanel.width = newWidth
  a
end

window.onResizeFinished = function()
  --chart.width, chart.height = chart.width, layout.height * 0.75
  chart.width = layout.width * (130 / 140)
  --chart.height = layout.height * 0.8
  progressBar.width = window.width * (130 / 140)
end

---------------------------------------------------------------------------------

local modemHandler =
  event.addHandler(
  function(eventType, _, sendingAddress, port, distance, messageData)
    if eventType == "modem_message" and sendingAddress == dialServerAddress and port == 69 then
      --GUI.alert(e2 .. "      " .. e3 .. "      " .. port .. "      " .. distance .. "       " .. messageData)
      local powerData = text.deserialize(messageData)
      local currentPowerLevel = powerData[1]
      local maxPowerLevel = powerData[2]
      local capacitorsInstalled = powerData[3]

      local percentPowerLevel = currentPowerLevel / maxPowerLevel * 100

      progressBar.value = percentPowerLevel

      local mRFpowerLevel = currentPowerLevel / 1000000

      if CurrentChartX < MaxChartX then
        table.insert(chart.values, {CurrentChartX, mRFpowerLevel})
        CurrentChartX = CurrentChartX + 1
      else
        --for i = CurrentChartX - MaxChartX, 1, -1 do
        --if type(chart.values[i]) ~= "nil" then
        --table.remove(chart.values, i)
        --end
        --end
        table.insert(chart.values, {CurrentChartX, mRFpowerLevel})
        CurrentChartX = CurrentChartX + 1

        table.remove(chart.values, 1)
      end
    end
  end
)

local loopHandler =
  event.addHandler(
  function()
    modem.send(dialServerAddress, 69, "get_power_data")
  end,
  1
)

local close = window.actionButtons.close.onTouch
window.actionButtons.close.onTouch = function()
  event.removeHandler(modemHandler)
  event.removeHandler(loopHandler)
  close()
end

-- Draw changes on screen after customizing your window
workspace:draw()
workspace:start()

event.removeHandler(modemHandler)
event.removeHandler(loopHandler)
