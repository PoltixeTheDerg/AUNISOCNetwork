local gui = {}
local component = require("component")
local split = require("split")
local gpu = component.gpu
local unicode = require("unicode")
local screenWidth, screenHeight = gpu.getResolution()

local function stringLenth(string)
    return unicode.len(string)
end

function gui.createNewGlyph(x, y, glyph, backgroundColour, foregroundColour)
    local tempTable = {}

    tempTable.x = x
    tempTable.y = y
    tempTable.data = glyph

    tempTable.backgroundColour = backgroundColour
    tempTable.foregroundColour = foregroundColour

    tempTable.length = stringLenth(tempTable.data[1])
    tempTable.height = #tempTable.data

    return tempTable
end

function gui.createNewGraph(x, y, w, h, identifier, labelx, labely, backgroundColour, foregroundColour)
    local tempTable = {}

    tempTable.x = x
    tempTable.y = y
    tempTable.width = w
    tempTable.height = h
    tempTable.identifier = identifier
    tempTable.labelx = labelx
    tempTable.labely = labely
    tempTable.backgroundColour = backgroundColour
    tempTable.foregroundColour = foregroundColour
    tempTable.data = {}

    for i = 1, w do
        tempTable.data[i] = 0
    end

    return tempTable
end

function gui.refreshGraph(graph, newData)
    graph.data[#graph.data] = newData

    for i = 1, #graph.data do
        if i > 1 then
            graph.data[i - 1] = graph.data[i]
        end
    end
end

function gui.clearScreen(backgroundColour)
    gpu.setBackground(backgroundColour)

    gpu.fill(1, 1, screenWidth, screenHeight, " ")
end

function gui.renderGraphs(graphs)
    for i = 1, #graphs do
        --print(i)
        local currentGraph = graphs[i]

        --print(tostring(currentGraph.foregroundColour))
        --print(tostring(currentGraph.backgroundColour))
        --print(tostring(currentGraph.x))
        --print(tostring(currentGraph.y))
        --print(tostring(currentGraph.width))
        --print(tostring(currentGraph.height))

        gpu.setForeground(currentGraph.foregroundColour)
        gpu.setBackground(currentGraph.backgroundColour)

        gpu.fill(currentGraph.x, currentGraph.y, currentGraph.width, currentGraph.height, " ")

        local reversedLabelY = string.reverse(currentGraph.labely)
        local splitReversedLabelY = split(reversedLabelY, "")

        gpu.set(
            currentGraph.x + math.floor((currentGraph.width / 2) + 0.5) - math.floor((#currentGraph.labelx / 2) + 0.5),
            currentGraph.y + currentGraph.height,
            currentGraph.labelx
        )
        for i1 = 1, #splitReversedLabelY do
            gpu.set(
                currentGraph.x - 1,
                (currentGraph.y + currentGraph.height - i1) - (math.floor((currentGraph.height / 2) + 0.5)) +
                    math.floor((#currentGraph.labely / 2) + 0.5),
                splitReversedLabelY[i1]
            )
        end

        local function round2(num, numDecimalPlaces)
            return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
        end

        local function isInt(n)
            return n == math.floor(n)
        end

        --はじめる render actual graph
        for i1 = 1, currentGraph.width do
            local currentData = currentGraph.data[i1]
            local endY = 0
            local cutScaleFactor = 50 / currentGraph.height
            local cutScaledData = currentData / cutScaleFactor
            local cutFlooredScaledData = round2(cutScaledData, 0) + 1

            local isCutInt = isInt(cutFlooredScaledData / 2)

            endY = math.floor(cutFlooredScaledData / 2)

            if endY >= 1 then
                endY = endY - 1
            end

            if not isCutInt then
                gpu.set(currentGraph.x + i1 - 1, currentGraph.y - endY + currentGraph.height - 1, "▀")
            else
                gpu.set(currentGraph.x + i1 - 1, currentGraph.y - endY + currentGraph.height - 1, "▄")
            end

            --print(flooredScaledData)
        end
        --end render or whatever
    end
end

function gui.renderGlyphs(glyphs)
    local function drawGlyph(x, y, glyphData)
        for i = 1, #glyphData do
            gpu.set(x, y + (i - 1), glyphData[i])
        end
    end

    --gpu.set(1, 1, tostring(#glyphs))

    for i = 1, #glyphs do
        local currentGlyph = glyphs[i]

        gpu.setForeground(currentGlyph.foregroundColour)
        gpu.setBackground(currentGlyph.backgroundColour)

        drawGlyph(currentGlyph.x, currentGlyph.y, currentGlyph.data)
    end
end

return gui
