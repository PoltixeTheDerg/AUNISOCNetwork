local component = require("component")
local gpu = component.gpu
gpu.setResolution(160,50)
local gui = require("gui")
local event = require("event")
local ser = require("serialization")

local prgName = "Visual Gui"
local version = "v0.1a"

gui.checkVersion(2, 5)

local guiVersion, guiMajor, guiMinor = gui.Version()

local buttonCounter = 0
local labelCounter = 0
local multiLabelCounter = 0
local textCounter = 0
local frameCounter = 0
local hlineCounter = 0
local checkboxCounter = 0
local radioCounter = 0
local hprogressCounter = 0
local vprogressCounter = 0
local listCounter = 0
local vsliderCounter = 0
local timelabelcounter = 0
local datelabelcounter = 0
--local chartCounter = 0

local dataTable = {}
dataTable["filename"] = "noname"
dataTable["topline"] = "noname"
dataTable["bottomline"] = "Made with Visual Gui " .. version .. " and Gui library v" .. guiVersion
dataTable["version"] = "1.0"
dataTable["counter"] = 0
dataTable["useExit"] = false


-- display a button in workspace
local function displayButton(id)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  local t = "[" .. dataTable[id].text .. "]"
  gpu.setBackground(0x0000FF)
  gpu.setForeground(0xFFFFFF)
  gpu.set(x, y, t)
end

-- display a label in workspace
local function displayLabel(id)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  local t = dataTable[id].text
  gpu.setBackground(0xCFCFCF)
  gpu.setForeground(0x000000)
  gpu.fill(x, y, dataTable[id].l, 1, " ")
  gpu.set(x, y, t)
end

-- display a time label in workspace
local function displayTimeLabel(id)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  local t = os.date("%H:%M", os.time())
  gpu.setBackground(0xCFCFCF)
  gpu.setForeground(0x000000)
  gpu.set(x, y, t)
end

-- display a date label in workspace
local function displayDateLabel(id)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  local t = ""
  if dataTable[id].frm == false then
    t = os.date("%d/%m/%Y")
  elseif dataTable[id].frm == true then
    t = os.date("%A %d. %B %Y")
  end
  gpu.setBackground(0xCFCFCF)
  gpu.setForeground(0x000000)
  gpu.set(x, y, t)
end

-- display a multi line label in workspace
local function displayMultiLine(id)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  local t = dataTable[id].text
  gpu.setBackground(0xCFCFCF)
  gpu.setForeground(0x000000)
--  gpu.set(x, y, t)
  gpu.fill(x, y, dataTable[id].w, dataTable[id].h, " ")
end

-- display a text in workspace
local function displayText(id)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  local t = dataTable[id].text
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(x, y, dataTable[id].l, 1, " ")
  gpu.set(x, y, t)
end

-- display a horizontal line in workspace
local function displayHLine(id)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  gpu.setBackground(0xC0C0C0)
  gpu.setForeground(0x000000)
  gpu.fill(x, y, dataTable[id].l, 1, "═")
end

-- display a checkbox in workspace
local function displayCheckbox(id)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  gpu.setBackground(0xC0C0C0)
  gpu.setForeground(0x000000)
  gpu.set(x, y, "[ ]")
end

-- display a radio button in workspace
local function displayRadio(id)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  gpu.setBackground(0xC0C0C0)
  gpu.setForeground(0x000000)
  gpu.set(x, y, "( )")
end

-- display a horizontal progressbar in workspace
local function displayHProgress(id)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  gpu.setBackground(0x000000)
  gpu.setForeground(0x000000)
  gpu.fill(x, y, dataTable[id].l, 1, " ")
  gpu.setBackground(0x00FF00)
  gpu.fill(x, y, dataTable[id].l/2, 1, " ")
  if dataTable[id].number == true then
    gpu.setBackground(0xC0C0C0)
    gpu.setForeground(0x000000)
    gpu.set(x + math.floor(dataTable[id].l/2) - 2, y - 1, "100%")
  end
end

-- display a vertical progressbar in workspace
local function displayVProgress(id)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  gpu.setBackground(0x00FF00)
  gpu.setForeground(0x000000)
  gpu.fill(x, y, dataTable[id].w, dataTable[id].l, " ")
  gpu.setBackground(0x000000)
  gpu.fill(x, y, dataTable[id].w, dataTable[id].l/2, " ")
end

-- display a vertical slider in workspace
local function displayVslider(id)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(x, y, dataTable[id].l, 1, " ")
  gpu.setBackground(0x0000FF)
  gpu.set(x, y, "-")
  gpu.set(x + dataTable[id].l, y, "+")
end

local function displayFrame(id)
  gpu.setBackground(0xC0C0C0)
  gpu.setForeground(0x000000)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  gpu.fill(x, y, 1, dataTable[id].h, "║")
  gpu.fill(x + dataTable[id].w - 1, y, 1, dataTable[id].h, "║")
  gpu.fill(x, y, dataTable[id].w, 1, "═")
  gpu.fill(x, y + dataTable[id].h - 1, dataTable[id].w, 1, "═")
  gpu.set(x, y, "╔")
  gpu.set(x + dataTable[id].w - 1 , y, "╗")
  gpu.set(x, y + dataTable[id].h - 1 , "╚")
  gpu.set(x + dataTable[id].w - 1 , y + dataTable[id].h - 1, "╝")
  if dataTable[id].textEnabled == true then
    gpu.set(x + math.floor((dataTable[id].w/2)) - math.floor((string.len(dataTable[id].text)/2)+1), y, "╡" .. dataTable[id].text .. "┝")
  end
end

-- display a list in workspace
local function displayList(id)
  local x = 80 + dataTable[id].x
  local y = 5 + dataTable[id].y
  local t = dataTable[id].text
  gpu.setBackground(0x0000FF)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(x, y, dataTable[id].w, dataTable[id].h, " ")
  gpu.fill(x, y, dataTable[id].w, 1, "═")
  gpu.fill(x, y + dataTable[id].h, dataTable[id].w, 1, "═")
  gpu.set(x, y + dataTable[id].h, "[<]")
  gpu.set(x + dataTable[id].w -3, y + dataTable[id].h, "[>]")
  if dataTable[id].textEnabled == true then
    gpu.set(x + math.floor((dataTable[id].w/2)) - math.floor((string.len(dataTable[id].text)/2)+1), y, "╡" .. dataTable[id].text .. "┝")
  end
end

-- refresh the workspace
local function refresh()
  gpu.setBackground(0xC0C0C0)
  gpu.fill(81, 6, 76, 21, " ")
  -- set the top and bottom
  gpu.setBackground(0x0000FF)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(79, 4, 79, 1, " ")
  gpu.fill(79, 28, 79, 1, " ")
  toptext = dataTable.topline
  local x = 117 - (string.len(toptext)/2)
  gpu.set(x, 4, toptext)
  local x = 117 - (string.len(dataTable.bottomline)/2)
  gpu.set(x, 28, dataTable.bottomline)
  if dataTable.useExit == true then
    gpu.set(152, 28, "[exit]")
  end
  
  for i = 1, dataTable.counter do
      if dataTable[i].type == "button" then
	displayButton(i)
      elseif dataTable[i].type == "label" then
	displayLabel(i)
      elseif dataTable[i].type == "timelabel" then
	displayTimeLabel(i)
      elseif dataTable[i].type == "datelabel" then
	displayDateLabel(i)
      elseif dataTable[i].type == "multilabel" then
	displayMultiLine(i)
      elseif dataTable[i].type == "text" then
	displayText(i)
      elseif dataTable[i].type == "frame" then
	displayFrame(i)
      elseif dataTable[i].type == "hline" then
	displayHLine(i)
      elseif dataTable[i].type == "checkbox" then
	displayCheckbox(i)
      elseif dataTable[i].type == "radio" then
	displayRadio(i)
      elseif dataTable[i].type == "hprogress" then
	displayHProgress(i)
      elseif dataTable[i].type == "vprogress" then
	displayVProgress(i)
      elseif dataTable[i].type == "list" then
	displayList(i)
      elseif dataTable[i].type == "vslider" then
	displayVslider(i)
--      elseif dataTable[i].type == "chart" then
      end
  end

end

local function disableAll()
  gui.setSize(myGui, valuesFrame, 41, 7,false)
  gui.setVisible(myGui, wLabel, false, false)
  gui.setVisible(myGui, wInput, false, false)
--  gui.setVisible(myGui, wSlider, false, false)
  gui.setVisible(myGui, hLabel, false, false)
  gui.setVisible(myGui, hInput, false, false)
--  gui.setVisible(myGui, hSlider, false, false)
  gui.setVisible(myGui, minLabel, false, false)
  gui.setVisible(myGui, minInput, false, false)
  gui.setVisible(myGui, maxLabel, false, false)
  gui.setVisible(myGui, maxInput, false, false)
  gui.setVisible(myGui, valueLabel, false, false)
  gui.setVisible(myGui, valueInput, false, false)
  gui.setVisible(myGui, textLabel, false, false)
  gui.setVisible(myGui, textInput, false, false)
  gui.setVisible(myGui, textEnable, false, false)
  gui.setVisible(myGui, textEnableLabel, false, false)
  gui.setVisible(myGui, funcLabel, false, false)
  gui.setVisible(myGui, funcInput, false, false)
  gui.setVisible(myGui, pwLabel, false, false)
  gui.setVisible(myGui, pwCheck, false, false)
  gui.setVisible(myGui, checkLabel, false, false)
  gui.setVisible(myGui, checkCheck, false, false)
  gui.setVisible(myGui, bgLabel, false, false)
  gui.setVisible(myGui, bgInput, false, false)
  gui.setVisible(myGui, fgLabel, false, false)
  gui.setVisible(myGui, fgInput, false, false)
  gui.setVisible(myGui, radioLabel, false, false)
  gui.setVisible(myGui, downCheck, false, false)
  gui.setVisible(myGui, numberLabel, false, false)
  gui.setVisible(myGui, numberCheck, false, false)
  gui.setVisible(myGui, lLabel, false, false)
  gui.setVisible(myGui, lInput, false, false)
--  gui.setVisible(myGui, lSlider, false, false)
  gui.setVisible(myGui, dataFrame, false, false)
  gui.setVisible(myGui, dataList, false, false)
  gui.setVisible(myGui, dataInsertText, false, false)
  gui.setVisible(myGui, dataInsertButton, false, false)
  gui.setVisible(myGui, dataRemoveButton, false, false)
  gui.setVisible(myGui, dateFormatLabel, false, false)
  gui.setVisible(myGui, dateFormatCheck, false, false)
  gui.setText(myGui, nameInput, "")
  gui.setText(myGui, xInput, "")
  gui.setText(myGui, yInput, "")
end

local function display(id, x, y)
  gui.setPosition(myGui, id, x, y,false)
  gui.setEnable(myGui, id, true, false)
  gui.setVisible(myGui, id, true, false)
end

local function elementsListCallback(guiID, listID, selected, text)
  disableAll()
  for i = 1, dataTable.counter do
    if dataTable[i].name == text then
      gui.setText(myGui, nameInput, dataTable[i].name, false)
      gui.setText(myGui, xInput, tostring(dataTable[i].x), false)
      gui.setText(myGui, yInput, tostring(dataTable[i].y), false)
      if dataTable[i].type == "button" then
	frameheight = 11
	display(textLabel, 3, 34)
	display(textInput, 11, 34)
	display(funcLabel, 3, 36)
	display(funcInput, 11, 36)
	gui.setText(myGui, funcInput, dataTable[i].func, false)
	gui.setText(myGui, textInput, dataTable[i].text, false)
      elseif dataTable[i].type == "label" then
	frameheight = 15
	display(lLabel, 3, 34)
	display(lInput, 11, 34)
	display(textLabel, 3, 36)
	display(textInput, 11, 36)
	display(bgLabel, 3, 38)
	display(bgInput, 22, 38)
	display(fgLabel, 3, 40)
	display(fgInput, 22, 40)
	gui.setText(myGui, textInput, dataTable[i].text, false)
	gui.setText(myGui, lInput, tostring(dataTable[i].l), false)
	gui.setText(myGui, bgInput, string.format("%x",dataTable[i].bg), false)
	gui.setText(myGui, fgInput, string.format("%x",dataTable[i].fg), false)
      elseif dataTable[i].type == "timelabel" then
	frameheight = 11
	display(bgLabel, 3, 34)
	display(bgInput, 22, 34)
	display(fgLabel, 3, 36)
	display(fgInput, 22, 36)
	gui.setText(myGui, bgInput, string.format("%x",dataTable[i].bg), false)
	gui.setText(myGui, fgInput, string.format("%x",dataTable[i].fg), false)
      elseif dataTable[i].type == "datelabel" then
	frameheight = 13
	display(dateFormatLabel, 3, 34)
	display(dateFormatCheck, 15, 34)
	display(bgLabel, 3, 36)
	display(bgInput, 22, 36)
	display(fgLabel, 3, 38)
	display(fgInput, 22, 38)
	gui.setText(myGui, bgInput, string.format("%x",dataTable[i].bg), false)
	gui.setText(myGui, fgInput, string.format("%x",dataTable[i].fg), false)
	gui.setCheckbox(myGui, dateFormatCheck, dataTable[i].frm)
      elseif dataTable[i].type == "multilabel" then
	frameheight = 17
	display(wLabel, 3, 34)
	display(wInput, 11, 34)
	display(hLabel, 3, 36)
	display(hInput, 11, 36)
	display(textLabel, 3, 38)
	display(textInput, 11, 38)
	display(bgLabel, 3, 40)
	display(bgInput, 22, 40)
	display(fgLabel, 3, 42)
	display(fgInput, 22, 42)
	gui.setText(myGui, textInput, dataTable[i].text, false)
	gui.setText(myGui, wInput, tostring(dataTable[i].w), false)
	gui.setText(myGui, hInput, tostring(dataTable[i].h), false)
	gui.setText(myGui, bgInput, string.format("%x",dataTable[i].bg), false)
	gui.setText(myGui, fgInput, string.format("%x",dataTable[i].fg), false)
      elseif dataTable[i].type == "text" then
	frameheight = 17
	display(lLabel, 3, 34)
	display(lInput, 11, 34)
	display(textLabel, 3, 36)
	display(textInput, 11, 36)
	display(funcLabel, 3, 38)
	display(funcInput, 11, 38)
	display(maxLabel, 3, 40)
	display(maxInput, 11, 40)
	display(pwLabel, 3, 42)
	display(pwCheck, 12, 42)
	gui.setText(myGui, funcInput, dataTable[i].func, false)
	gui.setText(myGui, textInput, dataTable[i].text, false)
	gui.setText(myGui, lInput, tostring(dataTable[i].l), false)
	gui.setText(myGui, maxInput, tostring(dataTable[i].max), false)
	gui.setCheckbox(myGui, pwCheck, dataTable[i].pass)
      elseif dataTable[i].type == "frame" then
	frameheight = 15
	display(wLabel, 3, 34)
	display(wInput, 11, 34)
	display(hLabel, 3, 36)
	display(hInput, 11, 36)
	display(textLabel, 3, 38)
	display(textInput, 11, 38)
	display(textEnableLabel, 3, 40)
	display(textEnable, 17, 40)
	gui.setText(myGui, textInput, dataTable[i].text, false)
	gui.setText(myGui, wInput, tostring(dataTable[i].w), false)
	gui.setText(myGui, hInput, tostring(dataTable[i].h), false)
	gui.setCheckbox(myGui, textEnable, dataTable[i].enabled)
      elseif dataTable[i].type == "hline" then
	frameheight = 9
	display(lLabel, 3, 34)
	display(lInput, 11, 34)
	gui.setText(myGui, lInput, tostring(dataTable[i].l), false)
      elseif dataTable[i].type == "checkbox" then
	frameheight = 11
	display(funcLabel, 3, 34)
	display(funcInput, 11, 34)
	display(checkLabel, 3, 36)
	display(checkCheck, 11, 36)
	gui.setText(myGui, funcInput, dataTable[i].func, false)
	gui.setCheckbox(myGui, checkCheck, dataTable[i].checked)
      elseif dataTable[i].type == "radio" then
	frameheight = 9
	display(funcLabel, 3, 34)
	display(funcInput, 11, 34)
	gui.setText(myGui, funcInput, dataTable[i].func, false)
      elseif dataTable[i].type == "hprogress" then
	frameheight = 17
	display(lLabel, 3, 34)
	display(lInput, 11, 34)
	display(maxLabel, 3, 36)
	display(maxInput, 11, 36)
	display(valueLabel, 3, 38)
	display(valueInput, 11, 38)
	display(funcLabel, 3, 40)
	display(funcInput, 11, 40)
	display(numberLabel, 3, 42)
	display(numberCheck, 15, 42)
	gui.setText(myGui, funcInput, dataTable[i].func, false)
	gui.setText(myGui, lInput, tostring(dataTable[i].l), false)
	gui.setText(myGui, maxInput, tostring(dataTable[i].max), false)
	gui.setText(myGui, valueInput, tostring(dataTable[i].value), false)
	gui.setCheckbox(myGui, numberCheck, dataTable[i].number)
      elseif dataTable[i].type == "vprogress" then
	frameheight = 19
	display(lLabel, 3, 34)
	display(lInput, 11, 34)
	display(wLabel, 3, 36)
	display(wInput, 11, 36)
	display(maxLabel, 3, 38)
	display(maxInput, 11, 38)
	display(valueLabel, 3, 40)
	display(valueInput, 11, 40)
	display(funcLabel, 3, 42)
	display(funcInput, 11, 42)
	display(radioLabel, 3, 44)
	display(downCheck, 20, 44)
	gui.setText(myGui, funcInput, dataTable[i].func, false)
	gui.setText(myGui, wInput, tostring(dataTable[i].w), false)
	gui.setText(myGui, lInput, tostring(dataTable[i].l), false)
	gui.setText(myGui, maxInput, tostring(dataTable[i].max), false)
	gui.setText(myGui, valueInput, tostring(dataTable[i].value), false)
	gui.setCheckbox(myGui, downCheck, dataTable[i].direction)
      elseif dataTable[i].type == "list" then
	frameheight = 17
	display(wLabel, 3, 34)
	display(wInput, 11, 34)
	display(hLabel, 3, 36)
	display(hInput, 11, 36)
	display(funcLabel, 3, 38)
	display(funcInput, 11, 38)
	display(textLabel, 3, 40)
	display(textInput, 11, 40)
	display(textEnableLabel, 3, 42)
	display(textEnable, 17, 42)
	gui.setSize(myGui, dataList, 30, 15, false)
	display(dataFrame, 44, 24)
	display(dataList, 45, 25)
	display(dataInsertText, 44, 41)
	display(dataInsertButton, 44, 43)
	display(dataRemoveButton, 44, 45)
	gui.setText(myGui, funcInput, dataTable[i].func, false)
	gui.setText(myGui, textInput, dataTable[i].text, false)
	gui.setText(myGui, wInput, tostring(dataTable[i].w), false)
	gui.setText(myGui, hInput, tostring(dataTable[i].h), false)
	gui.setCheckbox(myGui, textEnable, dataTable[i].enabled)
	gui.clearList(myGui, dataList)
	for k,v in pairs(dataTable[i].data) do
	  gui.insertList(myGui, dataList, v)
	end
      elseif dataTable[i].type == "vslider" then
	frameheight = 17
	display(lLabel, 3, 34)
	display(lInput, 11, 34)
	display(minLabel, 3, 36)
	display(minInput, 11, 36)
	display(maxLabel, 3, 38)
	display(maxInput, 11, 38)
	display(valueLabel, 3, 40)
	display(valueInput, 11, 40)
	display(funcLabel, 3, 42)
	display(funcInput, 11, 42)
	gui.setText(myGui, funcInput, dataTable[i].func, false)
	gui.setText(myGui, lInput, tostring(dataTable[i].l), false)
	gui.setText(myGui, maxInput, tostring(dataTable[i].max), false)
	gui.setText(myGui, minInput, tostring(dataTable[i].min), false)
	gui.setText(myGui, valueInput, tostring(dataTable[i].value), false)
--[[      elseif dataTable[i].type == "chart" then
	frameheight = 19
	display(minLabel, 3, 34)
	display(minInput, 11, 34)
	display(maxLabel, 3, 36)
	display(maxInput, 11, 36)
	display(lLabel, 3, 38)
	display(lInput, 11, 38)
	display(hLabel, 3, 40)
	display(hInput, 11, 40)
	display(bgLabel, 3, 42)
	display(bgInput, 22, 42)
	display(fgLabel, 3, 44)
	display(fgInput, 22, 44)
	gui.setSize(myGui, dataList, 30, 19, false)
	gui.setText(myGui, lInput, tostring(dataTable[i].l), false)
	gui.setText(myGui, maxInput, tostring(dataTable[i].max), false)
	gui.setText(myGui, minInput, tostring(dataTable[i].min), false)
	gui.setText(myGui, hInput, tostring(dataTable[i].h), false)
	display(dataList, 45, 25) ]]--
      end
      break
    end
  end
  gui.setSize(myGui, valuesFrame, 40, frameheight)
  refresh()
end


local function exitButtonCallback(guiID, id)
  local result = gui.getYesNo("", "Do you really want to exit?", "")
  if result == true then
    gui.exit()
  end
  gui.displayGui(myGui)
  refresh()
end

-- Any option changed
local function versionTextCallback(guiID, id)
  dataTable.version = gui.getText(guiID, id)
  refresh()
end
local function topLineTextCallback(guiID, id)
  dataTable.topline = gui.getText(guiID, id)
  refresh()
end
local function bottomLineTextCallback(guiID, id)
  dataTable.bottomline = gui.getText(guiID, id)
  refresh()
end

-- file handling
local function loadCallback(guiID, id)
  dataTable = gui.loadTable("/home/" .. dataTable.filename .. ".vdat")
  gui.setText(myGui, versionText, dataTable.version)
  gui.setText(myGui, topLineText, dataTable.topline)
  gui.setText(myGui, bottomLineText, dataTable.bottomline)
  gui.setCheckbox(myGui, setExitButtonCheckbox, dataTable.useExit)
  gui.clearList(guiID, elementsList)
  for i = 1, dataTable.counter do
    gui.insertList(guiID, elementsList, dataTable[i].name)
  end
  gui.setSelected(guiID, elementsList, 1)
  elementsListCallback(myGui, elementsList, 1, dataTable[1].name)
  refresh()
end
local function saveCallback(guiID, id)
  gui.saveTable(dataTable, dataTable.filename .. ".vdat")
  refresh()
end

local function writeCallbackEnd(file, t)
	file:write(t)
	file:write("   -- Your code here\n")
	file:write("end\n")
	file:write("\n")
end

local function writeCodeCallback(guiID, id)
  local lines = 28
  file,err = io.open(dataTable.filename .. ".lua" , "w" )

  file:write("local component = require(\"component\")\n")
  file:write("local gpu = component.gpu\n")
  file:write("gpu.setResolution(80,25)\n")
  file:write("local gui = require(\"gui\")\n")
  file:write("local event = require(\"event\")\n")
  file:write("\n")
  file:write("gui.checkVersion(" .. guiMajor .. "," .. guiMinor .. ")\n")
  file:write("\n")
  file:write("local prgName = \"" .. dataTable.filename .. "\"\n")
  file:write("local version = \"v" .. dataTable.version .. "\"\n")
  file:write("\n")
  file:write("-- Begin: Callbacks\n")
  
  for i = 1, dataTable.counter do
      local t = ""
      if dataTable[i].type == "button" then
	t = "local function " .. dataTable[i].func .. "(guiID, buttonID)\n"
	writeCallbackEnd(file, t)
	lines = lines + 4
      elseif dataTable[i].type == "text" then
	t = "local function " .. dataTable[i].func .. "(guiID, textID, text)\n"
	writeCallbackEnd(file, t)
	lines = lines + 4
      elseif dataTable[i].type == "checkbox" then
	t = "local function " .. dataTable[i].func .. "(guiID, checkboxID, status)\n"
	writeCallbackEnd(file, t)
	lines = lines + 4
      elseif dataTable[i].type == "radio" then
	t = "local function " .. dataTable[i].func .. "(guiID, radioID, status)\n"
	writeCallbackEnd(file, t)
	lines = lines + 4
      elseif dataTable[i].type == "hprogress" then
	t = "local function " .. dataTable[i].func .. "(guiID, hProgressID)\n"
	writeCallbackEnd(file, t)
	lines = lines + 4
      elseif dataTable[i].type == "vprogress" then
	t = "local function " .. dataTable[i].func .. "(guiID, vProgressID)\n"
	writeCallbackEnd(file, t)
	lines = lines + 4
      elseif dataTable[i].type == "list" then
	t = "local function " .. dataTable[i].func .. "(guiID, listID, selected, text)\n"
	writeCallbackEnd(file, t)
	lines = lines + 4
      elseif dataTable[i].type == "vslider" then
	t = "local function " .. dataTable[i].func .. "(guiID, vSliderID, value)\n"
	writeCallbackEnd(file, t)
	lines = lines + 4
--      elseif dataTable[i].type == "chart" then
      end
  end
  
  if dataTable.useExit == true then
    file:write("local function exitButtonCallback(guiID, id)\n")
    file:write("   local result = gui.getYesNo(\"\", \"Do you really want to exit?\", \"\")\n")
    file:write("   if result == true then\n")
    file:write("      gui.exit()\n")
    file:write("   end\n")
    file:write("   gui.displayGui(mainGui)\n")
    file:write("   refresh()\n")
    file:write("end\n")
    lines = lines + 8
  end
  
  file:write("-- End: Callbacks\n")
  file:write("\n")
  file:write("-- Begin: Menu definitions\n")
  file:write("mainGui = gui.newGui(1, 2, 79, 23, true)\n")
  
  for i = 1, dataTable.counter do
      local t = ""
      if dataTable[i].type == "button" then
	t = dataTable[i].name .. " = gui.newButton(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", \"" .. dataTable[i].text .. "\", " .. dataTable[i].func .. ")\n"
	file:write(t)
	lines = lines + 1
      elseif dataTable[i].type == "label" then
	t = dataTable[i].name .. " = gui.newLabel(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", \"" .. dataTable[i].text .. "\", " .. string.format("0x%x, 0x%x, ", dataTable[i].bg, dataTable[i].fg) .. dataTable[i].l .. ")\n"
	file:write(t)
	lines = lines + 1
      elseif dataTable[i].type == "timelabel" then
	t = dataTable[i].name .. " = gui.newTimeLabel(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. string.format("0x%x, 0x%x", dataTable[i].bg, dataTable[i].fg) .. ")\n"
	file:write(t)
	lines = lines + 1
      elseif dataTable[i].type == "datelabel" then
	if dataTable[i].frm == true then
	  t = dataTable[i].name .. " = gui.newDateLabel(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. string.format("0x%x, 0x%x, ", dataTable[i].bg, dataTable[i].fg) .. tostring(dataTable[i].frm) .. ")\n"
	else
	  t = dataTable[i].name .. " = gui.newDateLabel(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. string.format("0x%x, 0x%x", dataTable[i].bg, dataTable[i].fg) .. ")\n"
	end
	file:write(t)
	lines = lines + 1
      elseif dataTable[i].type == "multilabel" then
	t = dataTable[i].name .. " = gui.newMultiLineLabel(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. dataTable[i].w .. ", " .. dataTable[i].h .. ", \"" .. dataTable[i].text .. "\", " .. string.format("0x%x, 0x%x)\n", dataTable[i].bg, dataTable[i].fg) 
	file:write(t)
	lines = lines + 1
      elseif dataTable[i].type == "text" then
	t = dataTable[i].name .. " = gui.newText(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. dataTable[i].max .. ", \"" .. dataTable[i].text .. "\", " .. dataTable[i].func .. ", " .. dataTable[i].l .. ", " .. tostring(dataTable[i].pass) .. ")\n"
	file:write(t)
	lines = lines + 1
      elseif dataTable[i].type == "frame" then
	if dataTable[i].textEnabled == true then
	  t = dataTable[i].name .. " = gui.newFrame(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. dataTable[i].w .. ", " .. dataTable[i].h .. ", \"" .. dataTable[i].text .. "\")\n" 
	else
	  t = dataTable[i].name .. " = gui.newFrame(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. dataTable[i].w .. ", " .. dataTable[i].h .. ")\n" 
	end
	file:write(t)
	lines = lines + 1
      elseif dataTable[i].type == "hline" then
	t = dataTable[i].name .. " = gui.newHLine(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. dataTable[i].l .. ")\n"
	file:write(t)
	lines = lines + 1
      elseif dataTable[i].type == "checkbox" then
	t = dataTable[i].name .. " = gui.newCheckbox(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. tostring(dataTable[i].checked) .. ", " .. dataTable[i].func .. ")\n"
	file:write(t)
	lines = lines + 1
      elseif dataTable[i].type == "radio" then
	t = dataTable[i].name .. " = gui.newRadio(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. dataTable[i].func .. ")\n"
	file:write(t)
	lines = lines + 1
      elseif dataTable[i].type == "hprogress" then
	t = dataTable[i].name .. " = gui.newProgress(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. dataTable[i].l .. ", " .. dataTable[i].max .. ", " .. dataTable[i].value .. ", " .. dataTable[i].func .. ", " .. tostring(dataTable[i].number) .. ")\n"
	file:write(t)
	lines = lines + 1
      elseif dataTable[i].type == "vprogress" then
	t = dataTable[i].name .. " = gui.newVProgress(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. dataTable[i].l .. ", " .. dataTable[i].w .. ", " .. dataTable[i].max .. ", " .. dataTable[i].value .. ", " .. dataTable[i].func .. ", " .. tostring(dataTable[i].direction) .. ")\n"
	file:write(t)
	lines = lines + 1
      elseif dataTable[i].type == "list" then
	if dataTable[i].textEnabled == true then
	  t = dataTable[i].name .. " = gui.newList(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. dataTable[i].w .. ", " .. dataTable[i].h .. ", {}, " .. dataTable[i].func .. ", " .. dataTable[i].text .. ")\n"
	else
	  t = dataTable[i].name .. " = gui.newList(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. dataTable[i].w .. ", " .. dataTable[i].h .. ", {}, " .. dataTable[i].func .. ")\n"
	end
	file:write(t)
	lines = lines + 1
	for k,v in pairs(dataTable[i].data) do
	  file:write("gui.insertList(mainGui, ".. dataTable[i].name ..", \"" .. v .. "\")\n")
	  lines = lines + 1
	end
      elseif dataTable[i].type == "vslider" then
	t = dataTable[i].name .. " = gui.newVSlider(mainGui, " .. dataTable[i].x .. ", " .. dataTable[i].y .. ", " .. dataTable[i].l .. ", " ..dataTable[i].min .. ", " .. dataTable[i].max .. ", " .. dataTable[i].value .. ", " .. dataTable[i].func .. ")\n"
	file:write(t)
	lines = lines + 1
--      elseif dataTable[i].type == "chart" then
      end
  end
  
  if dataTable.useExit == true then
    t = "exitButton = gui.newButton(mainGui, 73, 23, \"exit\", exitButtonCallback)\n"
    file:write(t)
    lines = lines + 1
  end
  
  file:write("-- End: Menu definitions\n")
  file:write("\n")
  file:write("gui.clearScreen()\n")
  file:write("gui.setTop(\"" .. dataTable.topline .. "\")\n")
  file:write("gui.setBottom(\"" .. dataTable.bottomline .. "\")\n")
  file:write("\n")
  file:write("-- Main loop\n")
  file:write("while true do\n")
  file:write("   gui.runGui(mainGui)\n")
  file:write("end\n\n\n")

  file:close()
  
  gui.showMsg("File ".. dataTable.filename .. ".lua saved", "", string.format("%d lines written", lines))
  
  refresh()
end


local function newButtonCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "button"
  tmpTable["name"] = string.format("button_%d", buttonCounter)
  buttonCounter = buttonCounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["text"] = tmpTable["name"]
  tmpTable["func"] = tmpTable["name"] .. "_callback"
  
  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end
--[[
local function newChartCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "chart"
  tmpTable["name"] = string.format("chart_%d", chartCounter)
  chartCounter = chartCounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["bg"] = 0x0000FF
  tmpTable["fg"] = 0xFFFFFF
  tmpTable["w"] = 10
  tmpTable["h"] = 10
  tmpTable["max"] = 1
  tmpTable["min"] = 1
  tmpTable["data"] = {}

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end
]]--
local function newCheckboxCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "checkbox"
  tmpTable["name"] = string.format("checkbox_%d", checkboxCounter)
  checkboxCounter = checkboxCounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["checked"] = false
  tmpTable["func"] = tmpTable["name"] .. "_callback"

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end

local function newFrameCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "frame"
  tmpTable["name"] = string.format("frame_%d", frameCounter)
  frameCounter = frameCounter +1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["text"] = tmpTable["name"]
  tmpTable["w"] = 20
  tmpTable["h"] = 10
  tmpTable["textEnabled"] = false

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end

local function newHLineCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "hline"
  tmpTable["name"] = string.format("hline_%d", hlineCounter)
  hlineCounter = hlineCounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["l"] = 10

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end

local function newHProgressCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "hprogress"
  tmpTable["name"] = string.format("hprogress_%d", hprogressCounter)
  hprogressCounter = hprogressCounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["l"] = 10
  tmpTable["func"] = tmpTable["name"] .. "_callback"
  tmpTable["max"] = 10
  tmpTable["value"] = 1
  tmpTable["number"] = false

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end

local function newLabelCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "label"
  tmpTable["name"] = string.format("label_%d", labelCounter)
  labelCounter = labelCounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["text"] = tmpTable["name"]
  tmpTable["l"] = string.len(tmpTable["text"])
  tmpTable["bg"] = 0xC0C0C0
  tmpTable["fg"] = 0x000000

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end

local function newTimeLabelCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "timelabel"
  tmpTable["name"] = string.format("timelabel_%d", timelabelcounter)
  timelabelcounter = timelabelcounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["bg"] = 0xC0C0C0
  tmpTable["fg"] = 0x000000

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end

local function newDateLabelCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "datelabel"
  tmpTable["name"] = string.format("datelabel_%d", datelabelcounter)
  datelabelcounter = datelabelcounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["bg"] = 0xC0C0C0
  tmpTable["fg"] = 0x000000
  tmpTable["frm"] = false

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end

local function newListCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "list"
  tmpTable["name"] = string.format("list_%d", listCounter)
  listCounter = listCounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["text"] = tmpTable["name"]
  tmpTable["func"] = tmpTable["name"] .. "_callback"
  tmpTable["w"] = 20
  tmpTable["h"] = 10
  tmpTable["data"] = {}
  tmpTable["textEnabled"] = false

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end

local function newMultiLabelCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "multilabel"
  tmpTable["name"] = string.format("multilabel_%d", multiLabelCounter)
  multiLabelCounter = multiLabelCounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["text"] = tmpTable["name"]
  tmpTable["bg"] = 0xC0C0C0
  tmpTable["fg"] = 0xFFFFFF
  tmpTable["w"] = 10
  tmpTable["h"] = 10

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end

local function newRadioButtonCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "radio"
  tmpTable["name"] = string.format("radiobutton_%d", radioCounter)
  radioCounter = radioCounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["func"] = tmpTable["name"] .. "_callback"

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end

local function newTextCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "text"
  tmpTable["name"] = string.format("text_%d", textCounter)
  textCounter = textCounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["l"] = 10
  tmpTable["text"] = tmpTable["name"]
  tmpTable["func"] = tmpTable["name"] .. "_callback"
  tmpTable["max"] = 10
  tmpTable["pass"] = false

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end

local function newVProgressCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "vprogress"
  tmpTable["name"] = string.format("vprogress_%d", vprogressCounter)
  vprogressCounter = vprogressCounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["func"] = tmpTable["name"] .. "_callback"
  tmpTable["w"] = 1
  tmpTable["l"] = 10
  tmpTable["max"] = 10
  tmpTable["value"] = 1
  tmpTable["direction"] = false

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end

local function newVSliderCallback(guiID, id)
  local tmpTable = {}
  tmpTable["type"] = "vslider"
  tmpTable["name"] = string.format("vslider_%d", vsliderCounter)
  vsliderCounter = vsliderCounter + 1
  tmpTable["x"] = 1
  tmpTable["y"] = 1
  tmpTable["l"] = 10
  tmpTable["func"] = tmpTable["name"] .. "_callback"
  tmpTable["max"] = 10
  tmpTable["min"] = 1
  tmpTable["value"] = 1

  dataTable.counter = dataTable.counter + 1
  table.insert(dataTable, tmpTable)
  gui.insertList(myGui, elementsList, tmpTable.name)
  gui.setSelected(myGui, elementsList, dataTable.counter)
  elementsListCallback(myGui, elementsList, dataTable.counter, tmpTable.name)
  refresh()
end


local function nameInputCallback(guiID, id)
  dataTable[gui.getSelected(guiID, elementsList)].name = gui.getText(guiID, id)
  gui.renameList(guiID, elementsList, gui.getSelected(guiID, elementsList) , gui.getText(guiID, id))
  refresh()
end

local function xInputCallback(guiID, id)
  dataTable[gui.getSelected(guiID, elementsList)].x = tonumber(gui.getText(guiID, id))
  refresh()
end

local function yInputCallback(guiID, id)
  dataTable[gui.getSelected(guiID, elementsList)].y = tonumber(gui.getText(guiID, id))
  refresh()
end

local function wInputCallback(guiID, id)
  dataTable[gui.getSelected(guiID, elementsList)].w = tonumber(gui.getText(guiID, id))
  refresh()
end

local function hInputCallback(guiID, id)
  dataTable[gui.getSelected(guiID, elementsList)].h = tonumber(gui.getText(guiID, id))
  refresh()
end

local function lInputCallback(guiID, id)
  dataTable[gui.getSelected(guiID, elementsList)].l = tonumber(gui.getText(guiID, id))
  refresh()
end

local function bgInputCallback(guiID, id)
  dataTable[gui.getSelected(guiID, elementsList)].bg = tonumber(gui.getText(guiID, id),16)
  refresh()
end

local function fgInputCallback(guiID, id)
  dataTable[gui.getSelected(guiID, elementsList)].fg = tonumber(gui.getText(guiID, id),16)
  refresh()
end

local function funcInputCallback(guiID, id)
  dataTable[gui.getSelected(guiID, elementsList)].func = gui.getText(guiID, id)
  refresh()
end

local function textInputCallback(guiID, id)
  dataTable[gui.getSelected(guiID, elementsList)].text = gui.getText(guiID, id)
  refresh()
end

local function minInputCallback(guiID, id)
  dataTable[gui.getSelected(guiID, elementsList)].min = tonumber(gui.getText(guiID, id))
  refresh()
end

local function maxInputCallback(guiID, id)
  dataTable[gui.getSelected(guiID, elementsList)].max = tonumber(gui.getText(guiID, id))
  refresh()
end

local function valueInputCallback(guiID, id)
  dataTable[gui.getSelected(guiID, elementsList)].value = tonumber(gui.getText(guiID, id))
  refresh()
end

local function fileNameTextCallback(guiID, id)
  dataTable.filename = gui.getText(guiID, id)
  refresh()
end

local function deleteButtonCallback(guiID, id)
  if gui.getSelected(guiID, elementsList) > 0 then
    table.remove(dataTable, gui.getSelected(guiID, elementsList))
    gui.removeList(guiID, elementsList, gui.getSelected(guiID, elementsList))
    dataTable.counter = dataTable.counter - 1
    if dataTable.counter > 0 then
      gui.setSelected(guiID, elementsList, 1)
      elementsListCallback(myGui, elementsList, 1, dataTable[1].name)
    else
      disableAll()
      gui.setSize(myGui, valuesFrame, 40, 7)
    end
  end
  refresh()
end

local function dataRemoveButtonCallback(guiID, id)
  gui.removeList(guiID, dataList, gui.getSelected(guiID, dataList))
  refresh()
end

local function dataInsertButtonCallback(guiID, id)
  if string.len(gui.getText(guiID, dataInsertText)) > 0 then
    table.insert(dataTable[gui.getSelected(guiID, elementsList)].data, gui.getText(guiID, dataInsertText))
    gui.insertList(guiID, dataList, gui.getText(guiID, dataInsertText))
    gui.setText(guiID, dataInsertText, "")
    refresh()
  end
end

local function setExitButtonCallback(guiID, id, status)
  dataTable.useExit = status
  refresh()
end

local function pwCheckCallback(guiID, id, status)
  dataTable[gui.getSelected(guiID, elementsList)].pass = status
  refresh()
end

local function checkCheckCallback(guiID, id, status)
  dataTable[gui.getSelected(guiID, elementsList)].checked = status
  refresh()
end

local function numCheckCallback(guiID, id, status)
  dataTable[gui.getSelected(guiID, elementsList)].number = status
  refresh()
end

local function downCheckCallback(guiID, id, status)
  dataTable[gui.getSelected(guiID, elementsList)].direction = status
  refresh()
end

local function dateFormatCheckCallback(guiID, id, status)
  dataTable[gui.getSelected(guiID, elementsList)].frm = status
  refresh()
end

local function textEnableCallback(guiID, id, status)
  dataTable[gui.getSelected(guiID, elementsList)].textEnabled = status
  refresh()
end

-- main gui setup
myGui = gui.newGui(1, 2, 159, 48, true)

-- work area
gui.newFrame(myGui, 77, 1, 81, 27)
gui.newFrame(myGui, 78, 3, 79, 23)

-- file menu on bottom line
gui.newLabel(myGui, 2, 48, "File name :", 0x0000FF, 0xFFFFFF)
fileNameText = gui.newText(myGui, 14, 48, 10, dataTable.filename, fileNameTextCallback, 10)
loadButton = gui.newButton(myGui, 25, 48, "load", loadCallback)
saveButton = gui.newButton(myGui, 32, 48, "save", saveCallback)
writeCodeButton = gui.newButton(myGui, 39, 48, "write code", writeCodeCallback)

-- program options
gui.newFrame(myGui, 118, 28, 40, 11, "Options")
gui.newLabel(myGui, 119, 30, "Version  :")
versionText = gui.newText(myGui, 134, 30, 80, dataTable.version, versionTextCallback, 22)
gui.newLabel(myGui, 119, 32, "Top line :")
topLineText = gui.newText(myGui, 134, 32, 80, dataTable.topline, topLineTextCallback, 22)
gui.newLabel(myGui, 119, 34, "Bottom line :")
bottomLineText = gui.newText(myGui, 134, 34, 80, dataTable.bottomline, bottomLineTextCallback, 22)
gui.newLabel(myGui, 119, 36, "Insert exit button :")
setExitButtonCheckbox = gui.newCheckbox(myGui, 140, 36, false, setExitButtonCallback)

-- selection list for elements and guis
--gui.newFrame(myGui, 1, 1, 75, 46)
elementsList = gui.newList(myGui, 2, 2, 40, 20, {}, elementsListCallback, "Selection")
gui.newLabel(myGui, 2, 22, "", 0x0000FF, 0xFFFFFF, 40)
deleteButton = gui.newButton(myGui, 16, 22, "remove", deleteButtonCallback) 
gui.newFrame(myGui, 44, 2, 30, 20, "Insert new")
gui.newButton(myGui, 45, 3,  "Button                    ", newButtonCallback)
gui.newButton(myGui, 45, 4,  "Label                     ", newLabelCallback)
gui.newButton(myGui, 45, 5,  "Multi line label          ", newMultiLabelCallback)
gui.newButton(myGui, 45, 6,  "Text field                ", newTextCallback)
gui.newButton(myGui, 45, 7,  "Frame                     ", newFrameCallback)
gui.newButton(myGui, 45, 8,  "Horizontal line           ", newHLineCallback)
gui.newButton(myGui, 45, 9,  "Checkbox                  ", newCheckboxCallback)
gui.newButton(myGui, 45, 10, "Radio button              ", newRadioButtonCallback)
gui.newButton(myGui, 45, 11, "Horiontal progress bar    ", newHProgressCallback)
gui.newButton(myGui, 45, 12, "Vertical progress bar     ", newVProgressCallback)
gui.newButton(myGui, 45, 13, "List                      ", newListCallback)
gui.newButton(myGui, 45, 14, "Horizontal slider         ", newVSliderCallback)
gui.newButton(myGui, 45, 15, "Time label                ", newTimeLabelCallback)
gui.newButton(myGui, 45, 16, "Date label                ", newDateLabelCallback)
--gui.newButton(myGui, 45, 15, "Chart                     ", newChartCallback)

-- element values
valuesFrame = gui.newFrame(myGui, 2, 25, 40, 7, "Element values")
nameLabel = gui.newLabel(myGui, 3, 26, "Name :")
nameInput = gui.newText(myGui, 10, 26, 100, "", nameInputCallback, 30)

xLabel = gui.newLabel(myGui, 3, 28, "X :")
xInput = gui.newText(myGui, 7, 28, 5, "", xInputCallback, 5)
--xSlider = gui.newVSlider(myGui, 14, 27, 24, 0, 80, 0, func)

yLabel = gui.newLabel(myGui, 3, 30, "Y :")
yInput = gui.newText(myGui, 7, 30, 5, "", yInputCallback, 5)
--ySlider = gui.newVSlider(myGui, 14, 29, 24, 0, 80, 0, func)

wLabel = gui.newLabel(myGui, 3, 30, "W :")
wInput = gui.newText(myGui, 7, 30, 5, "", wInputCallback, 5)
--wSlider = gui.newVSlider(myGui, 14, 30, 24, 0, 80, 0, func)

hLabel = gui.newLabel(myGui, 3, 31, "H :")
hInput = gui.newText(myGui, 7, 31, 5, "", hInputCallback, 5)
--hSlider = gui.newVSlider(myGui, 14, 31, 24, 0, 80, 0, func)

minLabel = gui.newLabel(myGui, 3, 32, "Min   :")
minInput = gui.newText(myGui, 11, 32, 5, "", minInputCallback, 5)

maxLabel = gui.newLabel(myGui, 3, 33, "Max   :")
maxInput = gui.newText(myGui, 11, 33, 5, "", maxInputCallback, 5)

valueLabel = gui.newLabel(myGui, 3, 34, "Value :")
valueInput = gui.newText(myGui, 11, 34, 5, "", valueInputCallback, 5)

textLabel = gui.newLabel(myGui, 3, 35, "Text  :")
textInput = gui.newText(myGui, 11, 35, 78, "", textInputCallback, 25)

textEnableLabel = gui.newLabel(myGui, 3, 35, "Enable text :")
textEnable = gui.newCheckbox(myGui, 17, 37, false, textEnableCallback)

funcLabel = gui.newLabel(myGui, 3, 36, "Func  :")
funcInput = gui.newText(myGui, 11, 36, 100, "", funcInputCallback, 29)

pwLabel = gui.newLabel(myGui, 3, 37, "Password")
pwCheck = gui.newCheckbox(myGui, 12, 37, false, pwCheckCallback)

checkLabel = gui.newLabel(myGui, 3, 38, "Checked")
checkCheck = gui.newCheckbox(myGui, 11, 38, false,checkCheckCallback)

bgLabel = gui.newLabel(myGui, 3, 39, "Background color :")
bgInput = gui.newText(myGui, 22, 39, 8, "", bgInputCallback, 8)

fgLabel = gui.newLabel(myGui, 3, 40, "Foreground color :")
fgInput = gui.newText(myGui, 22, 40, 8, "", fgInputCallback, 8)

radioLabel = gui.newLabel(myGui, 3, 41, "Direction down :")
downCheck = gui.newCheckbox(myGui, 20, 41, false, downCheckCallback)

numberLabel = gui.newLabel(myGui, 3, 42, "Show number")
numberCheck = gui.newCheckbox(myGui, 15, 42, false, numCheckCallback)

dateFormatLabel = gui.newLabel(myGui, 3, 42, "Long format")
dateFormatCheck = gui.newCheckbox(myGui, 15, 42, false, dateFormatCheckCallback)

lLabel = gui.newLabel(myGui, 3, 43, "l :")
lInput = gui.newText(myGui, 7, 43, 5, "", lInputCallback, 5)
--lSlider = gui.newVSlider(myGui, 14, 43, 24, 0, 80, 0, func)


dataFrame = gui.newFrame(myGui, 43, 22, 32, 23)
dataList = gui.newList(myGui, 44, 23, 30, 20, {}, nil, "Element data")
dataInsertText = gui.newText(myGui, 44, 39, 100, "", nil, 30)
dataInsertButton = gui.newButton(myGui, 44, 41, "           Insert           ", dataInsertButtonCallback)
dataRemoveButton = gui.newButton(myGui, 44, 43, "           Remove           ", dataRemoveButtonCallback)

exitButton = gui.newButton(myGui, 153, 48, "exit", exitButtonCallback)


disableAll()

gui.clearScreen()
gui.setTop(prgName .. " " .. version)
gui.setBottom("(c)2017 by S.Kempa")

gui.runGui(myGui)
refresh()

while true do
  gui.runGui(myGui)
end