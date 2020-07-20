local event = require("event")
local component = require("component")
local gpu = component.gpu
local split = require("split")
local os = require("os")
local serialization = require("serialization")

local modem = component.modem

local running = true

-------------------------------------------------------------------------------------

local backgroundColor = 0x000000
local textColour = 0xFFFFFF
local oldBufferWidth, oldBufferHeight = gpu.getResolution()
gpu.setResolution(63, 100)
local newBufferWidth, newBufferHeight = gpu.getResolution()

local maxRandomWidth, maxRandomHeight = newBufferWidth - 3, newBufferHeight - 4

local gateType = "MW"

local glyphs = {}

glyphs["a"] = {
    "███",
    "  █",
    "███",
    "  █"
}
glyphs["b"] = {
    "███",
    " ██",
    "  █",
    "███"
}
glyphs["c"] = {
    "███",
    "█ █",
    "█ █",
    "█ █"
}
glyphs["d"] = {
    "███",
    " █ ",
    "███",
    "███"
}
glyphs["e"] = {
    "█ █",
    "█  ",
    "███",
    "█ █"
}
glyphs["f"] = {
    "███",
    "  █",
    "  █",
    "  █"
}
glyphs["g"] = {
    "█ █",
    "█ █",
    "█  ",
    "███"
}
glyphs["h"] = {
    "███",
    "  █",
    "███",
    "█ █"
}
glyphs["i"] = {
    "███",
    "   ",
    " █ ",
    "███"
}
glyphs["j"] = {
    "███",
    "█ █",
    "   ",
    "███"
}
glyphs["k"] = {
    "██",
    "██",
    " █",
    "██"
}
glyphs["l"] = {
    " ██",
    "██ ",
    " ██",
    "██ "
}
glyphs["m"] = {
    "█ █",
    "█ █",
    " █ ",
    "███"
}
glyphs["n"] = {
    " █ ",
    " ██",
    "███",
    "█ █"
}
glyphs["o"] = {
    "█ █",
    "██ ",
    " ██",
    "█ █"
}
glyphs["p"] = {
    "█ █",
    "█  ",
    "█  ",
    "█ █"
}
glyphs["q"] = {
    " █ ",
    "███",
    " █ ",
    "█ █"
}
glyphs["r"] = {
    "███",
    "   ",
    "█ █",
    "███"
}
glyphs["s"] = {
    "█ █",
    "███",
    "█ █",
    "█  "
}
glyphs["t"] = {
    "█ █",
    "   ",
    "███",
    "█ █"
}
glyphs["u"] = {
    "███",
    "  █",
    "  █",
    "  █"
}
glyphs["v"] = {
    "███",
    " ██",
    " ██",
    "███"
}
glyphs["w"] = {
    "█ █",
    "███",
    " ██",
    "█ █"
}
glyphs["x"] = {
    "█ █",
    "█ █",
    "███",
    "█ █"
}
glyphs["y"] = {
    "███",
    "█ █",
    "█  ",
    "██ "
}
glyphs["z"] = {
    "███",
    " █ ",
    "██ ",
    "█ █"
}
glyphs["0"] = {
    "███",
    "█ █",
    "█ █",
    "▀█▀"
}
glyphs["1"] = {
    "█  ",
    "   ",
    "   ",
    "▀█▀"
}
glyphs["2"] = {
    "██ ",
    "   ",
    "   ",
    "▀█▀"
}
glyphs["3"] = {
    "███",
    "   ",
    "   ",
    "▀█▀"
}
glyphs["4"] = {
    "███",
    "█  ",
    "   ",
    "▀█▀"
}
glyphs["5"] = {
    "███",
    "██ ",
    "   ",
    "▀█▀"
}
glyphs["6"] = {
    "███",
    "███",
    "   ",
    "▀█▀"
}
glyphs["7"] = {
    "███",
    "███",
    "█  ",
    "▀█▀"
}
glyphs["8"] = {
    "███",
    "███",
    "██ ",
    "▀█▀"
}
glyphs["9"] = {
    "███",
    "███",
    "███",
    "▀█▀"
}

--[[glyphs["b"] = image.load("/ancient_text/b.pic")
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
glyphs[";"] = image.load("/ancient_text/semi_colon.pic")]]
-------------------------------------------------------------------------------------

modem.open(69)

modem.send("0be49cee-a198-4d52-9acf-8e263bee3dbd", 69, "get_database")

--local _, _, _, _, _, messageData = event.pull("modem_message")

--local databaseData = serialization.unserialize(messageData)
gpu.fill(1, 1, newBufferWidth, newBufferHeight, " ")
--screen.update()

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
--[[for k, v in pairs(databaseData.data) do
    if vertical then
        vertical = false
    else
        vertical = true
    end

    --scrollingTexts[i] = newScrollingText(string.lower(k) .. "; " .. string.lower(v[gateType]), math.random(1, maxRandomWidth), vertical)

    cyclingEntries[i] = string.lower(k) .. "; " .. string.lower(v[gateType])

    i = i + 1
end]]
cyclingEntries[1] = "test1"
cyclingEntries[2] = "test2"
cyclingEntries[3] = "test3"

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

while running do
    --local eventType = event.pull()
    --if eventType == "touch" or eventType == "key_down" then
    --modem.close(69)
    --os.exit()
    --end

    local function drawGlyph(x, y, glyph)
        for i1 = 1, #glyph do
            gpu.set(x, y + i1, glyph[i1])
        end
    end

    local function drawAncientText(x, y, splitText, vertical)
        if vertical then
            for i1 = 1, #splitText do
                if type(glyphs[splitText[i1]]) ~= "nil" then
                    drawGlyph(x, y + ((i1 - 1) * 5), glyphs[splitText[i1]])
                end
            end
        else
            for i = 1, #splitText do
                if type(glyphs[splitText[i]]) ~= "nil" then
                    drawGlyph(x + ((i - 1) * 4), y, glyphs[splitText[i]])
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

    gpu.fill(1, 1, newBufferWidth, newBufferHeight, " ")
    renderScrollingText()
end

gpu.setResolution(oldBufferWidth, oldBufferHeight)
