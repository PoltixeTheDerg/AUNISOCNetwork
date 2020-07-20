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
local split = require("split")

local modem = component.modem

local runWaitForResponse = true

-------------------------------------------------------------------------------------

local backgroundColor = 0x0
local textColour = 0xFFFFFF
local oldBufferWidth, oldBufferHeight = screen.getResolution()
screen.setResolution(63, 100)
local newBufferWidth, newBufferHeight = screen.getResolution()

local maxRandomWidth, maxRandomHeight = newBufferWidth - 3, newBufferHeight - 4

local gateType = "MW"

local glyphs = {}

glyphs["a"] = image.load("/ancient_text/a.pic")
glyphs["b"] = image.load("/ancient_text/b.pic")
glyphs["c"] = image.load("/ancient_text/c.pic")
glyphs["d"] = image.load("/ancient_text/d.pic")
glyphs["e"] = image.load("/ancient_text/e.pic")
glyphs["f"] = image.load("/ancient_text/f.pic")
glyphs["g"] = image.load("/ancient_text/g.pic")
glyphs["h"] = image.load("/ancient_text/h.pic")
glyphs["i"] = image.load("/ancient_text/i.pic")
glyphs["j"] = image.load("/ancient_text/j.pic")
glyphs["k"] = image.load("/ancient_text/k.pic")
glyphs["l"] = image.load("/ancient_text/l.pic")
glyphs["m"] = image.load("/ancient_text/m.pic")
glyphs["n"] = image.load("/ancient_text/n.pic")
glyphs["o"] = image.load("/ancient_text/o.pic")
glyphs["p"] = image.load("/ancient_text/p.pic")
glyphs["q"] = image.load("/ancient_text/q.pic")
glyphs["r"] = image.load("/ancient_text/r.pic")
glyphs["s"] = image.load("/ancient_text/s.pic")
glyphs["t"] = image.load("/ancient_text/t.pic")
glyphs["u"] = image.load("/ancient_text/u.pic")
glyphs["v"] = image.load("/ancient_text/v.pic")
glyphs["w"] = image.load("/ancient_text/w.pic")
glyphs["x"] = image.load("/ancient_text/x.pic")
glyphs["y"] = image.load("/ancient_text/y.pic")
glyphs["z"] = image.load("/ancient_text/z.pic")
glyphs["1"] = image.load("/ancient_text/1.pic")
glyphs["2"] = image.load("/ancient_text/2.pic")
glyphs["3"] = image.load("/ancient_text/3.pic")
glyphs["4"] = image.load("/ancient_text/4.pic")
glyphs["5"] = image.load("/ancient_text/5.pic")
glyphs["6"] = image.load("/ancient_text/6.pic")
glyphs["7"] = image.load("/ancient_text/7.pic")
glyphs["8"] = image.load("/ancient_text/8.pic")
glyphs["9"] = image.load("/ancient_text/9.pic")
glyphs["0"] = image.load("/ancient_text/0.pic")
glyphs["'"] = image.load("/ancient_text/apostraphy.pic")
glyphs["\\"] = image.load("/ancient_text/backwards_slash.pic")
glyphs["]"] = image.load("/ancient_text/close_square_bracket.pic")
glyphs[","] = image.load("/ancient_text/comma.pic")
glyphs["/"] = image.load("/ancient_text/forwards_slash.pic")
glyphs["["] = image.load("/ancient_text/open_square_bracket.pic")
glyphs["."] = image.load("/ancient_text/period.pic")
glyphs[";"] = image.load("/ancient_text/semi_colon.pic")

-------------------------------------------------------------------------------------

modem.open(69)

modem.send("0be49cee-a198-4d52-9acf-8e263bee3dbd", 69, "get_database")

local eventType1, e2, e3, e4, e5, e6, e7, e8, e9, e10 = "", "", "", "", "", "", "", "", "", ""

eventType1, e2, e3, e4, e5, e6 = event.pull()

local databaseData = text.deserialize(e6)
screen.clear(backgroundColor)
screen.update()

function NewScrollingText(text, offsetCoord, vertical)
    local self = {}

    self.text = text
    self.vertical = vertical

    self.textTable = split(self.text, "")
    if vertical then
        self.length = #self.textTable * 5
    else
        self.length = #self.textTable * 4
    end

    self.beginPos = self.length * -1
    self.currentPos = self.beginPos
    self.offsetCoord = offsetCoord
    self.scrollSpeed = 1

    return self
end

local scrollingTexts = {}
--scrollingTexts[1] = newScrollingText("scrolling vertical text", math.random(1, maxRandomWidth), true)
--scrollingTexts[2] = newScrollingText("scrolling horizontal text", math.random(1, maxRandomHeight), false)

local cyclingEntries = {}

local i = 1
local vertical = false
for k, v in pairs(databaseData.data) do
    if vertical then
        vertical = false
    else
        vertical = true
    end

    --scrollingTexts[i] = newScrollingText(string.lower(k) .. "; " .. string.lower(v[gateType]), math.random(1, maxRandomWidth), vertical)

    cyclingEntries[i] = string.lower(k) .. "; " .. string.lower(v[gateType])

    i = i + 1
end

if #cyclingEntries <= 3 then
    for i = 1, #cyclingEntries do
        scrollingTexts[i] = NewScrollingText(cyclingEntries[i], math.random(1, maxRandomWidth), false)
    end
else
    scrollingTexts[1] =
        NewScrollingText(cyclingEntries[math.random(1, #cyclingEntries)], math.random(1, maxRandomWidth), false)
    scrollingTexts[2] =
        NewScrollingText(cyclingEntries[math.random(1, #cyclingEntries)], math.random(1, maxRandomWidth), false)
    scrollingTexts[3] =
        NewScrollingText(cyclingEntries[math.random(1, #cyclingEntries)], math.random(1, maxRandomWidth), false)
end

while true do
    local eventType = event.pull(0.0001)
    if eventType == "touch" or eventType == "key_down" then
        modem.close(69)
        break
    end

    screen.clear(backgroundColor)

    local function drawAncientText(x, y, splitText, vertical)
        if vertical then
            for i1 = 1, #splitText do
                if type(glyphs[splitText[i1]]) ~= "nil" then
                    screen.drawImage(x, y + ((i1 - 1) * 5), glyphs[splitText[i1]])
                end
            end
        else
            for i = 1, #splitText do
                if type(glyphs[splitText[i]]) ~= "nil" then
                    screen.drawImage(x + ((i - 1) * 4), y, glyphs[splitText[i]])
                end
            end
        end
    end

    local function renderScrollingText()
        for i1 = 1, #scrollingTexts do
            if scrollingTexts[i1].vertical then
                drawAncientText(
                    scrollingTexts[i1].offsetCoord,
                    scrollingTexts[i1].currentPos,
                    scrollingTexts[i1].textTable,
                    scrollingTexts[i1].vertical
                )

                if scrollingTexts[i1].currentPos <= newBufferHeight then
                    scrollingTexts[i1].currentPos = scrollingTexts[i1].currentPos + scrollingTexts[i1].scrollSpeed
                else
                    scrollingTexts[i1].text = cyclingEntries[math.random(1, #cyclingEntries)]

                    local newVertical = math.random(1, 2)
                    if newVertical == 1 then
                        scrollingTexts[i1].vertical = false
                        scrollingTexts[i1].scrollSpeed = math.random(1, 2)
                    else
                        scrollingTexts[i1].vertical = true
                        scrollingTexts[i1].scrollSpeed = 1
                    end

                    scrollingTexts[i1].text = cyclingEntries[math.random(1, #cyclingEntries)]

                    if scrollingTexts[i1].vertical then
                        scrollingTexts[i1].length = #scrollingTexts[i1].textTable * 5
                    else
                        scrollingTexts[i1].length = #scrollingTexts[i1].textTable * 4
                    end

                    scrollingTexts[i1].beginPos = scrollingTexts[i1].length * -1

                    scrollingTexts[i1].currentPos = scrollingTexts[i1].beginPos
                    scrollingTexts[i1].offsetCoord = math.random(1, maxRandomWidth)
                end
            else
                drawAncientText(
                    scrollingTexts[i1].currentPos,
                    scrollingTexts[i1].offsetCoord,
                    scrollingTexts[i1].textTable,
                    scrollingTexts[i1].vertical
                )

                if scrollingTexts[i1].currentPos <= newBufferWidth then
                    scrollingTexts[i1].currentPos = scrollingTexts[i1].currentPos + scrollingTexts[i1].scrollSpeed
                else
                    scrollingTexts[i1].text = cyclingEntries[math.random(1, #cyclingEntries)]

                    local newVertical = math.random(1, 2)
                    if newVertical == 1 then
                        scrollingTexts[i1].vertical = false
                        scrollingTexts[i1].scrollSpeed = math.random(1, 2)
                    else
                        scrollingTexts[i1].vertical = true
                        scrollingTexts[i1].scrollSpeed = 1
                    end

                    if scrollingTexts[i1].vertical then
                        scrollingTexts[i1].length = #scrollingTexts[i1].textTable * 5
                    else
                        scrollingTexts[i1].length = #scrollingTexts[i1].textTable * 4
                    end

                    scrollingTexts[i1].beginPos = scrollingTexts[i1].length * -1

                    scrollingTexts[i1].currentPos = scrollingTexts[i1].beginPos
                    scrollingTexts[i1].offsetCoord = math.random(1, maxRandomHeight)
                end
            end
        end
    end

    renderScrollingText()

    screen.update()
end
