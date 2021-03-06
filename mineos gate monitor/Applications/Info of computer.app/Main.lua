
-- Import libraries
local GUI = require("GUI")
local system = require("System")
local paths = require("Paths")
local fs = require("filesystem")
local component = require("component")
local image = require("Image")
local EFI = component.eeprom
local totalMemory = math.modf(computer.totalMemory() / 1024)
local freeMemory = math.modf(computer.freeMemory() / 1024)
local address = computer.address()
local cache = fs.path(system.getCurrentScript())
local lvlenergy = math.modf(computer.energy())
local maxenergy = math.modf(computer.maxEnergy())
local uptime = math.modf(computer.uptime())
local efiname = EFI.getLabel()
local boot = EFI.getData()

---------------------------------------------------------------------------------

-- Add a new window to MineOS workspace
local workspace, window, menu = system.addWindow(GUI.filledWindow(1, 1, 113, 43, 0xE1E1E1))

-- Get localization table dependent of current system language

-- Add single cell layout to window
local layout = window:addChild(GUI.layout(1, 1, window.width, window.height, 1, 1))

-- Add nice gray text object to layout
layout:addChild(GUI.image(1, 1, image.load(cache .. "/Icon.pic")))
layout:addChild(GUI.text(2, 2, 0x4B4B4B, "Привет, ".. system.getUser()))
layout:addChild(GUI.text(3, 3, 0x4B4B4B, totalMemory .." КБ оперативной памяти у Вас всего"))
layout:addChild(GUI.text(4, 4, 0x4B4B4B, freeMemory .. " КБ оперативной памяти у Вас свободно"))
layout:addChild(GUI.text(5, 5, 0x4B4B4B, lvlenergy .. " зафиксированная энергия на компьютере(".. maxenergy .." максимальная энергия)"))
layout:addChild(GUI.text(6, 6, 0x4B4B4B, uptime .. " секунд работает компьютер"))
layout:addChild(GUI.text(7, 7, 0x4B4B4B, efiname .. " - название EFI"))
layout:addChild(GUI.text(8, 8, 0x4B4B4B, boot .. " - адрес диска, с которого запущена операционная система"))
if component.isAvailable("robot") then
layout:addChild(GUI.text(9, 9, 0x4B4B4B, "Это устройство является роботом"))
else
layout:addChild(GUI.text(9, 9, 0x4B4B4B, "Это устройство не является роботом"))
end
layout:addChild(GUI.text(10, 10, 0x4B4B4B, address .." - адрес устройства"))
if computer.users() == "" then
layout:addChild(GUI.text(11, 11, 0x4B4B4B, "Список пользователей устройства:".. computer.users()))
end
if component.isAvailable("robot") then
local robot = require("robot")
local rl = "N/A"
if component.isAvailable("experience") then
local rl = math.modf(component.experience.level())
end
local rn = robot.name()
local ri = math.modf(robot.inventorySize())
layout:addChild(GUI.text(12, 12, 0x4B4B4B, "Уровень у Вашего робота:" .. rl))
layout:addChild(GUI.text(13, 13, 0x4B4B4B, "Имя Вашего робота:" .. rn))
layout:addChild(GUI.text(14, 14, 0x4B4B4B, "Объём инвентаря Вашего робота:" .. ri))
end
layout:addChild(GUI.text(15, 15, 0x33DB40, "Функции будут добавляться"))
layout:addChild(GUI.text(16, 16, 0x0049FF, "Разработано на проекте Hilarious(hil.su)"))



-- Customize MineOS menu for this application by your will
--local contextMenu = menu:addContextMenuItem("File")
--end

-- You can also add items without context menu
menu:addItem("exit").onTouch = function()
  window:remove()
end

-- Create callback function with resizing rules when window changes its' size
window.onResize = function(newWidth, newHeight)
  window.backgroundPanel.width, window.backgroundPanel.height = newWidth, newHeight
  layout.width, layout.height = newWidth, newHeight
end

---------------------------------------------------------------------------------

-- Draw changes on screen after customizing your window
workspace:draw()