-- Import libraries and such
local GUI = require("GUI")
local system = require("System")
local component = require("component")
local event = require("Event")
local image = require("Image")
local internet = require("Internet")
local text = require("Text")
local screen = require("Screen")
local filesystem = require("Filesystem")
local modem = component.modem
--local split = require("split")
--local json = require("json")

modem.open(70)

local currentlyDialing = false
local currentlyDialingAddress = {}
local currentlyDialingAddressLength = 0

local glyphImages = {}

---------------------------------------------------------------------------------

-- Get localization table dependent of current system language
local localization = system.getCurrentScriptLocalization()

local resources = filesystem.path(system.getCurrentScript())

local blankGlyph = image.load(resources .. "crater.pic")

-- Add a new window to MineOS workspace
local workspace, window, menu = system.addWindow(GUI.filledWindow(1, 1, 155, 47, 0x1E1E1E))

-- Add single cell layout to window
local rootLayout = window:addChild(GUI.layout(1, 1, window.width, window.height, 2, 1))

-- Add nice gray text object to layout
--layout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.greeting .. system.getUser()))

rootLayout:setColumnWidth(1, GUI.SIZE_POLICY_RELATIVE, 0.4)

rootLayout.defaultColumn = 1
local chevLayout = rootLayout:addChild(GUI.layout(1, 1, rootLayout.width * 0.4 - 4, rootLayout.height - 4, 1, 9))

local chevronText = {}

chevLayout.defaultColumn = 1

chevLayout.defaultRow = 1
chevLayout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.chevron .. localization.one))
glyphImages[1] = chevLayout:addChild(GUI.image(1, 1, image.load(resources .. "Point of origin.pic")))

chevLayout.defaultRow = 2
chevLayout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.chevron .. localization.two))
glyphImages[2] = chevLayout:addChild(GUI.image(1, 1, image.load(resources .. "Point of origin.pic")))

chevLayout.defaultRow = 3
chevLayout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.chevron .. localization.three))
glyphImages[3] = chevLayout:addChild(GUI.image(1, 1, image.load(resources .. "Point of origin.pic")))

chevLayout.defaultRow = 4
chevLayout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.chevron .. localization.four))
glyphImages[4] = chevLayout:addChild(GUI.image(1, 1, image.load(resources .. "Point of origin.pic")))

chevLayout.defaultRow = 5
chevLayout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.chevron .. localization.five))
glyphImages[5] = chevLayout:addChild(GUI.image(1, 1, image.load(resources .. "Point of origin.pic")))

chevLayout.defaultRow = 6
chevLayout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.chevron .. localization.six))
glyphImages[6] = chevLayout:addChild(GUI.image(1, 1, image.load(resources .. "Point of origin.pic")))

chevLayout.defaultRow = 7
chevLayout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.chevron .. localization.seven))
glyphImages[7] = chevLayout:addChild(GUI.image(1, 1, image.load(resources .. "Point of origin.pic")))

chevLayout.defaultRow = 8
chevLayout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.chevron .. localization.eight))
glyphImages[8] = chevLayout:addChild(GUI.image(1, 1, image.load(resources .. "Point of origin.pic")))

chevLayout.defaultRow = 9
chevLayout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.chevron .. localization.nine))
glyphImages[9] = chevLayout:addChild(GUI.image(1, 1, image.load(resources .. "Point of origin.pic")))

for i = 1, 9 do
  chevLayout:setAlignment(1, i, GUI.ALIGNMENT_HORIZONTAL_LEFT, GUI.ALIGNMENT_VERTICAL_CENTER)
  chevLayout:setMargin(1, i, 2, 1)
end

rootLayout.defaultColumn = 2
local gateImage = rootLayout:addChild(GUI.image(1, 1, image.load(resources .. "OffOff.pic")))

--chevLayout.showGrid = true

-- You can also add items without context menu
--menu:addItem("Example item").onTouch = function()
--GUI.alert("It works!")
--end

-- Create callback function with resizing rules when window changes its' size
window.onResize = function(newWidth, newHeight)
  window.backgroundPanel.width, window.backgroundPanel.height = newWidth, newHeight
  rootLayout.width, rootLayout.height = newWidth, newHeight

  chevLayout.height = newHeight - 2
end

---------------------------------------------------------------------------------

local function refreshGlyphs()
  if currentlyDialingAddressLength > 0 then
    for i = 1, currentlyDialingAddressLength do
      glyphImages[i] = chevLayout:addChild(GUI.image(1, 1, image.load(resources .. "crater.pic")))
    end
  else
    for i = 1, #glyphImages do
      glyphImages[i].image = image.load(resources .. "glyphs/blank.pic")
    end
  end
end

local modemHandler =
  event.addHandler(
  function(eventType, _, sendingAddress, port, distance, eventName, arg1, arg2, arg3, arg4, arg5, arg6)
    if eventType == "modem_message" and port == 70 then
      if eventName == "begin_dial_sequence" then
        currentlyDialing = true
        currentlyDialingAddress = text.deserialize(arg1)
        currentlyDialingAddressLength = arg2

        refreshGlyphs()
      end
      if eventType == "dial_cancelled" then
        currentlyDialing = true
        currentlyDialingAddress = {}
        currentlyDialingAddressLength = 0

        refreshGlyphs()
      end
    end
  end
)

---------------------------------------------------------------------------------

-- Draw changes on screen after customizing your window
workspace:draw()
