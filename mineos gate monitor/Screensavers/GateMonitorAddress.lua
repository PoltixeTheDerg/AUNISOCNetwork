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
local split = require("split")
local text = require("Text")
local number = require("Number")

local modem = component.modem

-------------------------------------------------------------------------------------

local currentlyDialing = false
local dialedGlyphs = 0

--BEGIN SCREEN SETUP
local backgroundColor = 0x0
local textColour = 0xFFFFFF
local dimmedTextColour = 0x444444
local oldBufferWidth, oldBufferHeight = screen.getResolution()
screen.setResolution(63, 100)
local newBufferWidth, newBufferHeight = screen.getResolution()
screen.clear(backgroundColor)
screen.update()
--END SCREEN SETUP

local ancient = {}
local glyphs = {}
ancient.ancientGlyphs = {}
local gateTypes = {}
local glyphConversion = {}

--Creates all the gate types
gateTypes.MILKYWAY = "MW"
gateTypes.PEGASUS = "PG"
gateTypes.UNIVERSE = "UN"

--Creates the tables where the glyph conversions are stored for each type
glyphConversion.MW = {}
glyphConversion.PG = {}
glyphConversion.UN = {}

--Same glyph conversion as the one devised by FlamePoint#8908
glyphConversion.MW["q"] = "Point of Origin"
glyphConversion.MW["w"] = "Crater"
glyphConversion.MW["e"] = "Virgo"
glyphConversion.MW["r"] = "Bootes"
glyphConversion.MW["t"] = "Centaurus"
glyphConversion.MW["y"] = "Libra"
glyphConversion.MW["u"] = "Serpens Caput"
glyphConversion.MW["i"] = "Norma"
glyphConversion.MW["o"] = "Scorpius"
glyphConversion.MW["p"] = "Corona Australis"
glyphConversion.MW["["] = "Scutum"
glyphConversion.MW["]"] = "Sagittarius"
glyphConversion.MW["\\"] = "Aquila"
glyphConversion.MW["a"] = "Microscopium"
glyphConversion.MW["s"] = "Capricornus"
glyphConversion.MW["d"] = "Piscis Austrinus"
glyphConversion.MW["f"] = "Equuleus"
glyphConversion.MW["g"] = "Aquarius"
glyphConversion.MW["h"] = "Pegasus"
glyphConversion.MW["j"] = "Sculptor"
glyphConversion.MW["k"] = "Pisces"
glyphConversion.MW["l"] = "Andromeda"
glyphConversion.MW[";"] = "Triangulum"
glyphConversion.MW["'"] = "Aries"
glyphConversion.MW["z"] = "Perseus"
glyphConversion.MW["x"] = "Cetus"
glyphConversion.MW["c"] = "Taurus"
glyphConversion.MW["v"] = "Auriga"
glyphConversion.MW["b"] = "Eridanus"
glyphConversion.MW["n"] = "Orion"
glyphConversion.MW["m"] = "Canis Minor"
glyphConversion.MW[","] = "Monoceros"
glyphConversion.MW["."] = "Gemini"
glyphConversion.MW["/"] = "Hydra"
glyphConversion.MW["1"] = "Lynx"
glyphConversion.MW["2"] = "Cancer"
glyphConversion.MW["3"] = "Sextans"
glyphConversion.MW["4"] = "Leo Minor"
glyphConversion.MW["5"] = "Leo"

--New pegasus glyph conversion devised by me
glyphConversion.PG["q"] = "Subido"
glyphConversion.PG["w"] = "Aaxel"
glyphConversion.PG["e"] = "Abrin"
glyphConversion.PG["r"] = "Acjesis"
glyphConversion.PG["t"] = "Aldeni"
glyphConversion.PG["y"] = "Alura"
glyphConversion.PG["u"] = "Amiwill"
glyphConversion.PG["i"] = "Arami"
glyphConversion.PG["o"] = "Avoniv"
glyphConversion.PG["p"] = "Baselai"
glyphConversion.PG["["] = "Bydo"
glyphConversion.PG["]"] = "Ca Po"
glyphConversion.PG["\\"] = "Danami"
glyphConversion.PG["a"] = "Dawnre"
glyphConversion.PG["s"] = "Ecrumig"
glyphConversion.PG["d"] = "Elenami"
glyphConversion.PG["f"] = "Gilltin"
glyphConversion.PG["g"] = "Hacemill"
glyphConversion.PG["h"] = "Hamlinto"
glyphConversion.PG["j"] = "Illume"
glyphConversion.PG["k"] = "Laylox"
glyphConversion.PG["l"] = "Lenchan"
glyphConversion.PG[";"] = "Olavii"
glyphConversion.PG["'"] = "Once el"
glyphConversion.PG["z"] = "Poco re"
glyphConversion.PG["x"] = "Ramnon"
glyphConversion.PG["c"] = "Recktic"
glyphConversion.PG["v"] = "Robandus"
glyphConversion.PG["b"] = "Roehi"
glyphConversion.PG["n"] = "Salma"
glyphConversion.PG["m"] = "Sandovi"
glyphConversion.PG[","] = "Setas"
glyphConversion.PG["."] = "Sibbron"
glyphConversion.PG["/"] = "Tahnan"
glyphConversion.PG["1"] = "Zamilloz"
glyphConversion.PG["2"] = "Zeo"

--New universe glyph conversion devised by me
glyphConversion.UN["q"] = 17
glyphConversion.UN["w"] = 1
glyphConversion.UN["e"] = 2
glyphConversion.UN["r"] = 3
glyphConversion.UN["t"] = 4
glyphConversion.UN["y"] = 5
glyphConversion.UN["u"] = 6
glyphConversion.UN["i"] = 7
glyphConversion.UN["o"] = 8
glyphConversion.UN["p"] = 9
glyphConversion.UN["["] = 10
glyphConversion.UN["]"] = 11
glyphConversion.UN["\\"] = 12
glyphConversion.UN["a"] = 13
glyphConversion.UN["s"] = 14
glyphConversion.UN["d"] = 15
glyphConversion.UN["f"] = 16
glyphConversion.UN["g"] = 18
glyphConversion.UN["h"] = 19
glyphConversion.UN["j"] = 20
glyphConversion.UN["k"] = 21
glyphConversion.UN["l"] = 22
glyphConversion.UN[";"] = 23
glyphConversion.UN["'"] = 24
glyphConversion.UN["z"] = 25
glyphConversion.UN["x"] = 26
glyphConversion.UN["c"] = 27
glyphConversion.UN["v"] = 28
glyphConversion.UN["b"] = 29
glyphConversion.UN["n"] = 30
glyphConversion.UN["m"] = 31
glyphConversion.UN[","] = 32
glyphConversion.UN["."] = 33
glyphConversion.UN["/"] = 34
glyphConversion.UN["1"] = 35
glyphConversion.UN["2"] = 36

ancient.ancientGlyphs["a"] = image.load("/ancient_text/a.pic")
ancient.ancientGlyphs["b"] = image.load("/ancient_text/b.pic")
ancient.ancientGlyphs["c"] = image.load("/ancient_text/c.pic")
ancient.ancientGlyphs["d"] = image.load("/ancient_text/d.pic")
ancient.ancientGlyphs["e"] = image.load("/ancient_text/e.pic")
ancient.ancientGlyphs["f"] = image.load("/ancient_text/f.pic")
ancient.ancientGlyphs["g"] = image.load("/ancient_text/g.pic")
ancient.ancientGlyphs["h"] = image.load("/ancient_text/h.pic")
ancient.ancientGlyphs["i"] = image.load("/ancient_text/i.pic")
ancient.ancientGlyphs["j"] = image.load("/ancient_text/j.pic")
ancient.ancientGlyphs["k"] = image.load("/ancient_text/k.pic")
ancient.ancientGlyphs["l"] = image.load("/ancient_text/l.pic")
ancient.ancientGlyphs["m"] = image.load("/ancient_text/m.pic")
ancient.ancientGlyphs["n"] = image.load("/ancient_text/n.pic")
ancient.ancientGlyphs["o"] = image.load("/ancient_text/o.pic")
ancient.ancientGlyphs["p"] = image.load("/ancient_text/p.pic")
ancient.ancientGlyphs["q"] = image.load("/ancient_text/q.pic")
ancient.ancientGlyphs["r"] = image.load("/ancient_text/r.pic")
ancient.ancientGlyphs["s"] = image.load("/ancient_text/s.pic")
ancient.ancientGlyphs["t"] = image.load("/ancient_text/t.pic")
ancient.ancientGlyphs["u"] = image.load("/ancient_text/u.pic")
ancient.ancientGlyphs["v"] = image.load("/ancient_text/v.pic")
ancient.ancientGlyphs["w"] = image.load("/ancient_text/w.pic")
ancient.ancientGlyphs["x"] = image.load("/ancient_text/x.pic")
ancient.ancientGlyphs["y"] = image.load("/ancient_text/y.pic")
ancient.ancientGlyphs["z"] = image.load("/ancient_text/z.pic")
ancient.ancientGlyphs["1"] = image.load("/ancient_text/1.pic")
ancient.ancientGlyphs["2"] = image.load("/ancient_text/2.pic")
ancient.ancientGlyphs["3"] = image.load("/ancient_text/3.pic")
ancient.ancientGlyphs["4"] = image.load("/ancient_text/4.pic")
ancient.ancientGlyphs["5"] = image.load("/ancient_text/5.pic")
ancient.ancientGlyphs["6"] = image.load("/ancient_text/6.pic")
ancient.ancientGlyphs["7"] = image.load("/ancient_text/7.pic")
ancient.ancientGlyphs["8"] = image.load("/ancient_text/8.pic")
ancient.ancientGlyphs["9"] = image.load("/ancient_text/9.pic")
ancient.ancientGlyphs["0"] = image.load("/ancient_text/0.pic")
ancient.ancientGlyphs["'"] = image.load("/ancient_text/apostraphy.pic")
ancient.ancientGlyphs["\\"] = image.load("/ancient_text/backwards_slash.pic")
ancient.ancientGlyphs["]"] = image.load("/ancient_text/close_square_bracket.pic")
ancient.ancientGlyphs[","] = image.load("/ancient_text/comma.pic")
ancient.ancientGlyphs["/"] = image.load("/ancient_text/forwards_slash.pic")
ancient.ancientGlyphs["["] = image.load("/ancient_text/open_square_bracket.pic")
ancient.ancientGlyphs["."] = image.load("/ancient_text/period.pic")
ancient.ancientGlyphs[";"] = image.load("/ancient_text/semi_colon.pic")

ancient.ancientGlyphs["A"] = image.load("/ancient_text/a.pic")
ancient.ancientGlyphs["B"] = image.load("/ancient_text/b.pic")
ancient.ancientGlyphs["C"] = image.load("/ancient_text/c.pic")
ancient.ancientGlyphs["D"] = image.load("/ancient_text/d.pic")
ancient.ancientGlyphs["E"] = image.load("/ancient_text/e.pic")
ancient.ancientGlyphs["F"] = image.load("/ancient_text/f.pic")
ancient.ancientGlyphs["G"] = image.load("/ancient_text/g.pic")
ancient.ancientGlyphs["H"] = image.load("/ancient_text/h.pic")
ancient.ancientGlyphs["I"] = image.load("/ancient_text/i.pic")
ancient.ancientGlyphs["J"] = image.load("/ancient_text/j.pic")
ancient.ancientGlyphs["K"] = image.load("/ancient_text/k.pic")
ancient.ancientGlyphs["L"] = image.load("/ancient_text/l.pic")
ancient.ancientGlyphs["M"] = image.load("/ancient_text/m.pic")
ancient.ancientGlyphs["N"] = image.load("/ancient_text/n.pic")
ancient.ancientGlyphs["O"] = image.load("/ancient_text/o.pic")
ancient.ancientGlyphs["P"] = image.load("/ancient_text/p.pic")
ancient.ancientGlyphs["Q"] = image.load("/ancient_text/q.pic")
ancient.ancientGlyphs["R"] = image.load("/ancient_text/r.pic")
ancient.ancientGlyphs["S"] = image.load("/ancient_text/s.pic")
ancient.ancientGlyphs["T"] = image.load("/ancient_text/t.pic")
ancient.ancientGlyphs["U"] = image.load("/ancient_text/u.pic")
ancient.ancientGlyphs["V"] = image.load("/ancient_text/v.pic")
ancient.ancientGlyphs["W"] = image.load("/ancient_text/w.pic")
ancient.ancientGlyphs["X"] = image.load("/ancient_text/x.pic")
ancient.ancientGlyphs["Y"] = image.load("/ancient_text/y.pic")
ancient.ancientGlyphs["Z"] = image.load("/ancient_text/z.pic")

--The point of origin
glyphs.blank = {
    ""
}

--The point of origin
glyphs.earthpoo = {
    "⠀⠀⠀⠀⠀⢀⣤⣴⣦⣤⡀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⣾⡏⠀⠀⢹⣷⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠻⣷⣄⣠⣾⠏⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠈⢉⡉⠁⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⣠⣾⣷⡄⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⣴⣿⠟⠻⣿⣦⠀⠀⠀⠀⠀",
    "⠀⠀⠀⣠⣾⡿⠋⠀⠀⠙⣿⣷⡄⠀⠀⠀",
    "⠀⠀⣴⣿⠟⠁⠀⠀⠀⠀⠈⢻⣿⣦⠀⠀",
    "⣠⣾⣿⣯⠀⠀⠀⠀⠀⠀⠀⠀⣽⣿⣷⡄"
}

--The Crater glyph
glyphs.crater = {
    "⠀⠀⠀⢠⣀⣀⣀⣀⣀⣀⡀⠀⠀⠀",
    "⠀⠀⠀⢸⣿⠛⠛⠛⠛⠛⣻⣿⠁⠀",
    "⠀⠀⠀⢸⣿⠀⠀⠀⠀⢠⣿⠃⠀⠀",
    "⠀⠀⠀⢸⣿⣶⣶⣶⣶⣾⠏⠀⠀⠀",
    "⠀⠀⢠⣿⡿⠛⠛⠛⢻⣿⣦⠀⠀⠀",
    "⠀⣴⣿⡿⠁⠀⠀⠀⠀⠻⣿⣧⡀⠀",
    "⠀⠘⣿⣿⠀⠀⠀⠀⠀⠀⢹⣿⡇⠀",
    "⠀⣠⣿⣿⡆⠀⠀⠀⠀⠀⣼⣿⣧⠀",
    "⠚⠛⠛⠛⠃⠀⠀⠀⠀⠈⠉⠉⠉⠁"
}

--The Virgo glyph
glyphs.virgo = {
    "⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⡀⠀⠀⣀⠀⠀",
    "⠀⠀⠀⢀⣤⣾⡿⢿⡿⠋⠀⢀⣤⣿⣦⡀",
    "⠀⠀⠐⣿⡁⡟⠀⠀⠀⣠⣶⡿⠛⠁⠀⠀",
    "⠀⠀⠀⢘⣿⣿⢶⣶⣾⠟⠋⠀⠀⠀⠀⠀",
    "⠀⠀⠀⣸⣿⡇⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⢀⣿⡿⣦⣾⣿⣧⣀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⣾⣿⠀⠀⠀⠈⠙⠻⣿⣶⣤⠀⠀⠀",
    "⢠⣾⣿⠃⠀⠀⠀⠀⠀⠀⠀⠙⠃⠀⠀⠀",
    "⠀⠀⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}

--The Boötes glyph
glyphs.bootes = {
    "⠀⠀⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⢀⣠⣴⣿⡿⠛⠁⠀⠀⠀⠀⠀⠀",
    "⣀⣤⣾⣿⠟⣋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠈⠛⠁⠐⠿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠈⠻⣿⣷⣄⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣷⣄⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣿⠛⢛⣶⠂",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡴⠋⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀"
}

--The Centaurus glyph ▄▀█
glyphs.centaurus = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣦⣤⣤",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡿⠁",
    "⠀⠀⠀⡀⠀⠀⠀⠀⢠⣿⡇⠀",
    "⠀⠀⢰⣿⣤⣀⣀⣀⣾⣿⠁⠀",
    "⠀⠀⠾⠛⠉⠛⠻⠿⣿⣿⠀⠀",
    "⠀⠀⠀⢀⣤⣾⠷⠀⢸⣿⡆⠀",
    "⣤⡤⣌⠻⠋⠁⠀⠀⠀⣿⣧⠀",
    "⠀⠓⢾⠀⠀⠀⠀⠀⠀⣿⠿⠗"
}

--The Libra glyph ▄▀█
glyphs.libra = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀",
    "⠀⠀⢀⣤⣤⣤⣤⣤⣤⣾⣿⡿⠋⠀",
    "⠀⢀⣾⣿⡟⠛⠛⠉⠉⠉⠁⠀⠀⠀",
    "⢀⣾⠟⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⣾⡟⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠹⣿⡄⣿⡇⠀⢀⣴⣾⣿⣿⡛⢻⡏",
    "⠀⠹⣿⣿⣧⣼⣿⡿⠋⠉⠉⠙⠛⠛",
    "⠀⠀⢹⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}

--The Serpens Caput glyph
glyphs.serpenscaput = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⠟⠁",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⠃⠀⠀",
    "⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⠀⣴⣿⠃⠀⠀⠀",
    "⠀⠀⠀⢀⣀⣤⣿⡏⢙⣻⣿⠿⠃⠀⠀⠀⠀",
    "⠀⠀⣾⡿⠿⠛⠿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀",
    "⠀⢰⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⢀⣾⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠉⠛⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}

--The Norma glyph
glyphs.norma = {
    --▄▀█
    "⢰⣤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠘⣿⠉⠛⢛⣷⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⣿⣤⣶⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠋⠻⢶⣤⡀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣧⣴⠟⠋⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⠋⠁⠀⠀⠀"
}

--The Scorpius glyph
glyphs.scorpius = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⣀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡿⠿⠿⠿⣿⣇",
    "⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⡇⠀⠀⣀⣿⣿",
    "⣀⣀⣀⣀⠀⠀⠀⠀⣸⣿⠃⠀⠺⣿⠟⠁",
    "⠈⣿⣿⠋⠀⠀⠀⣰⣿⡏⠀⠀⠀⠙⠀⠀",
    "⠀⣿⣿⣀⣠⣤⣾⡿⠋⠀⠀⠀⠀⠀⠀⠀",
    "⠀⣿⣿⠿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⣼⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠛⠛⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}

--The Corona Australis glyph
glyphs.coronaaustralis = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⡆⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⢠⣾⣃⣠⣷⣀⠀⠀ ",
    "⠀⠀⠀⠀⠀⠀⠘⠋⠛⠛⠿⣿⣷⡄",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿",
    "⠀⢀⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿",
    "⣠⠟⠙⣦⠀⠀⠀⠀⠀⠀⢀⣴⣿⠟",
    "⠛⠛⠛⠛⠀⢸⣿⣶⣾⣿⣿⡿⠋⠀",
    "⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠀⠀⠀⠀"
}

--The Scutum glyph
glyphs.scutum = {
    --▄▀█
    "⠀⢠⠀⠀⠀⠀⠀⠀⠀",
    "⠀⢸⡆⠀⠀⠀⠀⠀⠀",
    "⠀⣸⣿⠀⠀⠀⠀⠀⠀",
    "⠀⣿⢻⡆⢠⣶⡄⠀⠀",
    "⢠⣿⠈⣿⡀⢻⣧⠀⠀",
    "⠸⢷⣦⣾⣷⡈⠉⠁⠀",
    "⠀⠀⠀⠈⠻⣿⣆⠀⠀",
    "⠀⠀⠀⠀⠀⠈⢿⣿⡶",
    "⠀⠀⠀⠀⠀⠀⠘⠁⠀"
}

--The Sagittarius glyph
glyphs.sagittarius = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⢀⡄⠀⠀⠀⠀⢸⣿⣿⣿⣶⣄⠀",
    "⠀⢀⣴⢿⡇⠀⠀⠀⠀⠀⠀⠉⠉⣿⣿⠀",
    "⠀⣾⠁⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⠀",
    "⠀⣿⠀⢸⣇⣀⣠⣴⣶⣧⡀⠀⠀⢸⣿⡀",
    "⢀⣿⣠⡾⠟⠛⠻⣿⡟⠿⣿⣶⣶⣿⡿⠇",
    "⢸⠟⠋⠀⠀⠠⣤⣿⣧⣤⠈⠙⠉⠁⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠙⠻⣿⡆⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀"
}

--The   f   o   r   b   i   d   d   e   n
glyphs.aquila = {
    --▄▀█
    "⠸⣿⣿⠂⠀⠀⠀⠀⠀⠀",
    "⢸⣿⠇⠀⠀⠀⠀⠀⠀⠀",
    "⣼⣿⠀⠀⠀⠀⠀⠀⠀⠀",
    "⢿⣿⣶⣦⣄⡀⠀⠀⠀⠀",
    "⠀⠈⠉⠛⠿⢿⣷⣶⣾⡇",
    "⣀⠀⢀⣠⣴⣿⠿⠛⠻⠷",
    "⢹⣿⡿⠟⠋⠁⠀⠀⠀⠀",
    "⠀⠛⠀⠀⠀⠀⠀⠀⠀⠀"
}

--The Microscopium glyph
glyphs.microscopium = {
    --▄▀█
    "⠀⢸⣶⣦⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⢸⣿⣿⠁⠀⠀⠀⢀⣄⡀⠀⠀⠀⠀⠀",
    "⠀⣸⣿⡏⠀⠀⠀⠀⢸⣏⣛⣶⡄⠀⠀⠀",
    "⠀⣿⣿⡇⠀⠀⠀⠀⠘⠋⠉⠁⠀⠀⠀⠀",
    "⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣶⠀",
    "⢠⣿⣿⣶⣶⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⡄",
    "⢸⠿⠟⠛⠛⠋⠉⠉⠉⠀⠀⠀⠀⠀⠉⠁"
}

--The Capricornus glyph
glyphs.capricornus = {
    --▄▀█
    "⠀⠀⠀⠀⠀⣰⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⢠⣿⣿⣿⣷⣦⡀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⢀⣿⣿⠁⠀⠙⢿⣿⣦⡀⠀⠀⠀⠀⠀",
    "⠀⠀⢀⣾⣿⠃⠀⠀⠀⠀⠙⢿⣿⣦⡀⠀⠀⠀",
    "⠀⠀⣾⣿⡏⠀⠀⣀⣀⣀⣀⣤⣽⣿⣿⣦⣤⡄",
    "⠀⣼⣿⣿⣿⣿⣿⣿⡿⠿⠿⠿⠿⠿⠿⢿⣿⠁",
    "⠘⠻⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}

--The Piscis Austrinus glyph
glyphs.piscisaustrinus = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣤⣤⣤⠀⠀",
    "⠀⠀⣀⣠⣤⣶⣶⣶⣶⡿⠟⠛⠉⠀⣿⠘⢷⡀",
    "⠰⣾⡟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⢠⡾⠁",
    "⠀⠙⢿⣦⣤⣤⣄⣀⣀⠀⠀⠀⣀⣠⣿⡿⠁⠀",
    "⠀⠀⠀⠀⠈⠉⠉⠉⠛⠛⠿⠛⠛⠋⠉⠀⠀⠀"
}

--The Equuleus glyph
glyphs.equuleus = {
    --▄▀█
    "⢀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠈⣿⣿⣿⣿⣶⣦⣤⣾⡇⠀⠀",
    "⠀⢹⣿⣆⠀⠈⠉⠛⠻⣿⠀⠀",
    "⠀⠀⢻⣿⡄⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠘⣿⣷⡀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠸⣿⣧⠀⠀⠀⠀⣀⠀",
    "⠀⠀⠀⠀⢻⣿⣇⣤⣶⣿⣿⡄",
    "⠀⠀⠀⠀⠈⢿⣿⡿⠛⠛⠛⠃",
    "⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀"
}

--The Aquarius glyph
glyphs.aquarius = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⡀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠁⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⣿⡿⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⢿⣷⣄⣀⣀⣀",
    "⠀⠀⠀⢠⣾⣆⠀⠀⠀⠙⠿⣿⣿⠃",
    "⠀⠀⠀⠈⠙⢿⣷⣄⠀⠀⢀⣿⡟⠀",
    "⣀⠀⠀⠀⠀⠀⢹⣿⣶⣿⡿⠛⠀⠀",
    "⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⠀⠀⠀⠀",
    "⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}

--The Pegasus glyph
glyphs.pegasus = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡀⠀⠀⠀",
    "⠀⠀⢀⣤⣄⣠⣤⣄⣀⡀⠀⢀⣠⣶⡿⠟⠧⠀⠀⠀",
    "⠀⢰⣿⠏⠉⠉⠛⠛⠻⠿⢷⣿⠟⠉⠀⠀⠀⠀⠀⠀",
    "⠀⠀⣡⣤⣤⣤⣤⣄⣀⣀⡘⣿⡇⠀⠀⠀⠀⢠⣤⠄",
    "⣠⣼⡟⠉⠉⠉⠉⠉⠛⠛⠻⢿⣿⡶⠀⠀⠀⠈⠁⠀",
    "⠀⠙⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀"
}

--The Sculptor glyph
glyphs.sculptor = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠖",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠃⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⡟⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡿⠀⠀⠀",
    "⣤⣄⣀⡀⠀⠀⠀⠀⣾⣿⠃⠀⠀⠀",
    "⠙⣿⡉⠙⠛⠛⢿⣿⣿⡇⠀⠀⠀⠀",
    "⠀⠹⣷⣤⣴⠞⠛⠉⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}

--The Pisces glyph
glyphs.pisces = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀",
    "⢀⣤⣤⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣿⠃",
    "⠸⣿⣄⣿⣷⣶⣶⣦⣤⣤⣤⣶⣾⡿⢿⣿⡟⠀",
    "⠀⠈⠛⠋⠈⠉⠉⠉⠉⠙⠛⠋⠀⠀⣸⣿⠁⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡟⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣴⣿⠁⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⡀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠟⠁⠀⠀"
}

--The Andromeda glyph
glyphs.andromeda = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⢀⡀⠀⢀⡀",
    "⠀⠀⣀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⣿⣿⣿⡇",
    "⢴⣾⣿⣿⣿⣿⣶⣦⣤⣭⡉⠁⠀⠀⠈⠁⠀⠀⠀",
    "⠀⠀⠀⠀⠉⠉⠉⠉⠻⠿⠁⠀⠀⠀⠀⠀⠀⠀⠀"
}

--The Triangulum glyph
glyphs.triangulum = {
    --▄▀█
    "⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠈⣿⣷⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠘⣿⣟⠻⣿⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠹⣿⡄⠀⠉⠛⢿⣶⣦⣀⠀⠀⠀⠀",
    "⠀⠀⠀⢻⣿⡀⠀⠀⠀⠈⠙⠿⣿⣶⣄⡀",
    "⠀⠀⠀⠀⢻⣷⡀⠀⠀⠀⢀⣴⣿⡿⠛⠁",
    "⠀⠀⠀⠀⠈⢿⣧⡀⣠⣾⣿⠟⠉⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠘⣿⣿⠟⠋⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀"
}

--The Aries glyph
glyphs.aries = {
    --▄▀█
    "⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀",
    "⣿⠿⢿⣿⣷⣶⣦⣤⣤⣤⣴⣶⣶⣶⣶⣶⣿⣿",
    "⠀⠀⠀⠀⠉⠉⠙⠛⠟⠛⠛⠋⠉⠉⠉⠉⠉⠉"
}

--The Perseus glyph
glyphs.perseus = {
    --▄▀█
    "⢠⣾⣿⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠿⠛⠿⣿⣷⣦⣀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠙⠻⣿⣷⣄⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣷⣤⣄⠀",
    "⠀⢀⣤⣆⠀⠀⠀⠀⠀⠈⢿⡿⣿⠀",
    "⠀⠻⢿⣿⣷⣦⣤⣀⡀⠀⢸⡇⢸⡀",
    "⠀⠀⠀⠀⠉⠛⠻⠿⢿⣿⣿⣿⣿⡇"
}

--The Cetus glyph
glyphs.cetus = {
    --▄▀█
    "⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⣿⣿⣿⣿⣶⣄⡀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠙⠻⣿⣶⣤⣤⣤⣶⣶⠀",
    "⠀⠀⠀⠀⠀⠀⣿⡏⠉⠉⠉⠹⣿⠀",
    "⠀⠀⠀⠀⠀⢰⣿⠃⠀⠀⠀⠀⣿⣧",
    "⠀⠀⠀⠀⠀⣸⣿⣤⣶⣶⣿⠿⠿⠛",
    "⠀⠀⠀⠀⠀⠛⠛⠉⠁⠀⠀⠀⠀⠀"
}

--The Taurus glyph
glyphs.taurus = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀",
    "⣀⣀⣀⣀⣀⣠⣤⣤⣤⣴⣶⣶⣶⣶⣶⣶⣿⣷",
    "⣿⡿⠿⠿⠛⠛⠛⠻⢿⣿⣿⣍⣉⠉⠉⠉⠉⠉",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠿⠿⠿⢿⣷⣶",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉"
}

--The Auriga glyph
glyphs.auriga = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠸⠿⠧⠀⠀⠀⠀",
    "⠰⣶⣶⡄⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⢹⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠸⣿⡀⠀⠀⠀⠀⠀⣶⣶⠄",
    "⠀⢠⣿⡇⠀⠀⠀⠀⢠⣿⠃⠀",
    "⠀⣾⣿⣿⡀⠀⠀⠀⣾⡏⠀⠀",
    "⠀⠙⢿⣿⣿⣿⣿⣿⡿⠁⠀⠀",
    "⠀⠀⠀⠙⠁⠀⠀⠀⠀⠀⠀⠀"
}

--The Eridanus glyph
glyphs.eridanus = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⣰⣦⣤⣶⣶⣆⣿⣿⡿⠷",
    "⣀⣄⡀⠀⠀⠀⢀⣴⣿⠛⠻⢿⡿⠿⠿⠛⠀⠀",
    "⠛⠻⢿⣦⣤⣾⣿⡿⠿⠃⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠉⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}

--The Orion glyph
glyphs.orion = {
    --▄▀█
    "⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠘⣿⡷⣶⣦⣤⣶⡆",
    "⠀⠀⠀⠀⠀⢹⡇⠀⢠⡿⠁⠀",
    "⠀⠀⠀⠀⠀⣼⡇⢀⣿⠃⠀⠀",
    "⠀⠀⠀⠀⢠⣿⣵⣼⡇⠀⠀⠀",
    "⠀⠀⢀⣼⡗⠀⠉⣬⡅⠀⠀⠀",
    "⠠⣤⣾⣯⣄⣀⠀⢻⣇⠀⠀⠀",
    "⠀⠉⠈⠉⠛⠛⠻⠿⣿⡄⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀"
}

--The Canis Minor glyph
glyphs.canisminor = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⢀⣀⠀⠀⠀⠀⠀",
    "⠀⠀⣀⣤⣴⣶⡿⢿⡿⠀⠀⠀⠀⠀",
    "⠈⠻⣿⣿⣉⠀⢀⣿⡇⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠙⠻⣷⣾⣿⠁⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⢙⣿⣄⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⢸⣿⠻⢿⣦⣄⠀⠀",
    "⠀⠀⠀⠀⠀⠀⣾⡏⠀⠀⢉⣻⣿⣦",
    "⠀⠀⠀⠀⠀⢸⣿⣷⣾⠿⠛⠛⠉⠀",
    "⠀⠀⠀⠀⠀⠘⠉⠀⠀⠀⠀⠀⠀⠀"
}

--The Monoceros glyph
glyphs.monoceros = {
    --▄▀█
    "⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣷⡀⠀⠀⠀",
    "⢻⣿⠿⠿⣿⣷⣶⣄⣀⠀⣠⣾⠿⠋⠻⣿⣦⡀⠀",
    "⠈⠁⠀⠀⠀⠉⠙⢻⣿⣿⠟⠁⠀⠀⠀⠈⢻⡿⠃",
    "⠀⠀⢀⣠⣤⡴⢾⣿⠟⠁⠀⠀⠀⠀⠀⠀⠈⠀⠀",
    "⠀⠀⠙⢿⣤⡴⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}

--The Gemini glyph
glyphs.gemini = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣾⣿⠗",
    "⠀⣀⣀⣀⣀⣀⣤⣤⣤⣤⣤⣤⣤⣿⣿⠀",
    "⢠⣿⡿⠿⠿⠛⠛⠛⠛⠛⠛⠛⠛⣿⣿⠀",
    "⢿⣿⣇⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣿⣿⠀",
    "⢀⣿⣿⣿⣿⣿⣿⡿⠿⠿⠿⠿⠿⢿⣿⡿",
    "⠀⠻⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀"
}

--The Hydra glyph
glyphs.hydra = {
    --▄▀█
    "⢠⣴⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⣿⣿⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠈⠙⠻⣶⣄⣀⠠⣶⡇⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠙⠿⠁⠘⠣⣦⢀⣤⣀⣀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠾⠛⠛⣿⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣶⣤⡀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠀"
}

--The Lynx glyph
glyphs.lynx = {
    --▄▀█
    "⣀⣠⣤⣶⣶⣶⣶⣶⣶⣶⣄⡀⠀⠀⠀⠀⠀⠀⣠⠀",
    "⠙⠿⠿⠛⠉⠉⠉⠉⠉⠛⠻⢿⣷⣦⣀⣠⣴⣶⡿⠷",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠿⠋⠉⠁⠀⠀"
}

--The Cancer glyph
glyphs.cancer = {
    --▄▀█
    "⢀⡀⠀⠀⠀⠀⠀⠀",
    "⠾⠷⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⢀⡀",
    "⠀⠀⠀⠀⢀⣴⣿⠧",
    "⠀⠀⠀⣠⡾⠋⠀⠀",
    "⠀⠀⢰⣿⠃⠀⠀⠀",
    "⠀⠀⣼⡏⠀⠀⠀⠀",
    "⠀⠀⣿⣧⠀⠀⠀⠀",
    "⠀⠘⠛⠛⠀⠀⠀⠀"
}

--The Sextans glyph
glyphs.sextans = {
    --▄▀█
    "⢀⣀⣀⡀⠀⠀",
    "⠈⢻⠏⠀⠀⠀",
    "⠀⢀⡀⠀⠀⠀",
    "⠀⣿⡇⠀⠀⠀",
    "⠀⢀⠀⠀⠀⠀",
    "⠾⣿⣄⠀⠀⠀",
    "⠀⠈⠻⣧⡀⠀",
    "⠀⠀⠀⠘⣿⣶",
    "⠀⠀⠀⠀⠘⠁"
}

--The Leo Minor glyph
glyphs.leominor = {
    --▄▀█
    "⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⢀⣴⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠉⠻⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠈⢿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠙⢿⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣷⣤⣀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢿⣿⣶⣤⣤⣤⣶",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠻⣿⡿",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁"
}

--The Leo glyph
glyphs.leo = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁",
    "⠀⠀⠀⠀⠀⢀⣼⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀",
    "⣴⣄⠀⠀⢠⣿⣿⠏⠻⣿⣦⠀⠀⠀⠀⠀⠀⠀",
    "⣿⣿⣷⣄⣸⣿⣇⠀⠀⠘⢿⣷⡀⠀⠀⠀⠀⠀",
    "⠀⠉⠻⠟⠋⠉⢻⣷⣄⠀⠈⠻⣿⣄⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠙⢿⣧⡀⠀⠙⣿⣦⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⡦⠀⠈⢿⣷⡀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠹⣿⡿",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀"
}

glyphs.glyph1 = {
    --▄▀█
    " ▀▄ ",
    " ▀▄ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▐▌ "
}

glyphs.glyph2 = {
    --▄▀█
    " ▄▄ ",
    " ▀▀ ",
    "▄▀▀▄",
    "▀▄▄▀",
    "  ▄ ",
    " ▀▄ ",
    " ▀  "
}

glyphs.glyph3 = {
    --▄▀█▐▌
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ ",
    " ██ ",
    " ▗▖ ",
    " ▝▘ "
}

glyphs.glyph4 = {
    --▄▀█▐▌
    " ▐▌ ",
    " ▐▌ ",
    " ▗▖ ",
    " ▝▘ ",
    " ▀▄ ",
    " ▀▄ "
}

glyphs.glyph5 = {
    --▄▀█▐▌
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ ",
    " ██ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▐▌ "
}

glyphs.glyph6 = {
    --▄▀█▐▌
    " ▐▌ ",
    " ▐▌ ",
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ ",
    "▄▀▀▄",
    "▀▄▄▀"
}

glyphs.glyph7 = {
    --▄▀█▐▌
    " ▀▄ ",
    " ▀▄ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ "
}

glyphs.glyph8 = {
    --▄▀█▐▌
    "▄▀▀▄",
    "▀▄▄▀",
    " ▗▖ ",
    " ▝▘ ",
    " ██ ",
    " ▗▖ ",
    " ▝▘ "
}

glyphs.glyph9 = {
    --▄▀█▐▌
    " ██ ",
    " ▄▄ ",
    " ▀▀ ",
    " ██ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▐▌ "
}

glyphs.glyph10 = {
    --▄▀█▐▌
    " ▐▌ ",
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ ",
    "▄▀▀▄",
    "▀▄▄▀"
}

glyphs.glyph11 = {
    --▄▀█▐▌
    " ▐▌ ",
    " ▐▌ ",
    " ▗▖ ",
    " ▗▖ ",
    " ▄▄ ",
    " ▀▀ "
}

glyphs.glyph12 = {
    --▄▀█▐▌
    " ▄▀ ",
    " ▄▀ ",
    " ▄▄ ",
    " ▀▀ ",
    " ██ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▐▌ "
}

glyphs.glyph13 = {
    --▄▀█▐▌
    "▄▀▀▄",
    "▀▄▄▀",
    " ▄▄ ",
    " ▀▀ ",
    " ██ ",
    " ▗▖ ",
    " ▝▘ "
}

glyphs.glyph14 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    "▄▀▀▄",
    "▀▄▄▀",
    " ▄▄ ",
    "█  █",
    " ▀▀ ",
    " ██ "
}

glyphs.glyph15 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ██ ",
    " ▄▄ ",
    " ▀▀ ",
    " ██ ",
    " ▗▖ ",
    " ▐▌ "
}

glyphs.glyph16 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    "▄▀▀▄",
    "▀▄▄▀",
    " ▗▖ ",
    " ▝▘ ",
    " ▐▌ ",
    " ▗▖ ",
    " ▝▘ "
}

glyphs.glyph17 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ ",
    " ██ ",
    " ▗▖ ",
    " ▝▘ "
}

glyphs.glyph18 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ▄▀ ",
    " ▄▀ ",
    " ▄▄ ",
    "█  █",
    " ▀▀ ",
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ "
}

glyphs.glyph19 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ██ ",
    " ▄▄ ",
    "█  █",
    " ▀▀ ",
    " ██ ",
    " ▄▄ ",
    "█  █",
    " ▀▀ ",
    " ██ "
}

glyphs.glyph20 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ▐▌ ",
    " ▐▌ ",
    " ▝▘",
    " ██ "
}

glyphs.glyph21 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ "
}

glyphs.glyph22 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▄▀ ",
    " ▄▀ "
}

glyphs.glyph23 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ██ ",
    " ▗▖ ",
    " ▄▄ ",
    "█  █",
    " ▀▀ ",
    " ▝▘ ",
    " ██ "
}

glyphs.glyph24 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ██ ",
    " ▗▖ ",
    " ▝▘ ",
    " ██ ",
    " ▗▖ ",
    " ▝▘ "
}

glyphs.glyph25 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ██ ",
    " ▄▄ ",
    "█  █",
    " ▀▀ ",
    " ▝▘ ",
    "▄▀▀▄",
    "▀▄▄▀",
    " ▄▄ ",
    " ▀▀ "
}

glyphs.glyph26 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ██ ",
    " ▗▖ ",
    " ▝▘ ",
    " ██ ",
    " ▗▖ ",
    " ▝▘ ",
    " ██ "
}

glyphs.glyph27 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ██ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▄▀ ",
    " ▄▀ ",
    " ▄▄ ",
    " ▀▀ "
}

glyphs.glyph28 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ ",
    "▄▀▀▄",
    "▀▄▄▀",
    " ▄▄ ",
    " ▀▀ ",
    " ▐▌ "
}

glyphs.glyph29 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ▐▌ ",
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ ",
    " ██ ",
    " ▗▖ ",
    " ▝▘ "
}

glyphs.glyph30 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ▐▌ ",
    " ▄▄ ",
    "█  █",
    " ▀▀ ",
    " ▐▌ "
}

glyphs.glyph31 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ▐▌ ",
    " ▄▄ ",
    "█  █",
    " ▀▀ ",
    " ▐▌ "
}

glyphs.glyph32 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ▐▌ ",
    " ▐▌ ",
    " ▗▖ ",
    " ▄▄ ",
    " ▀▀ "
}

glyphs.glyph33 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ██ ",
    " ▗▖ ",
    " ▄▄ ",
    " ▀▀ ",
    " ██ ",
    " ▗▖ ",
    " ▄▄ ",
    " ▀▀ "
}

glyphs.glyph34 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    "▄▀▀▄",
    "▀▄▄▀",
    " ▗▖ ",
    " ▐▌ ",
    " ▝▘ ",
    "▄▀▀▄",
    "▀▄▄▀"
}

glyphs.glyph35 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ██ ",
    " ▗▖ ",
    " ▝▘ ",
    " ██ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▝▘ "
}

glyphs.glyph36 = {
    --|▄|▀|█|▐|▌|▗|▖|▝|▘
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ ",
    " ▐▌ ",
    " ▄▄ ",
    " ▀▀ "
}

--The aaxel glyph
glyphs.aaxel = {
    "⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⣀⠀⠀⢸⣿⠀⠀⣀⣀⣠⣤⣄⣀⡀⠀⠀⠀⠀",
    "⠛⠛⠿⢿⡇⠀⢸⣿⠉⠉⠁⠉⠛⢻⣷⠀⠀⠀",
    "⠀⠀⣀⣸⣿⠀⠸⠿⣶⣶⣄⡀⠀⠈⣿⡀⠀⠀",
    "⠐⢿⣿⡉⠁⠀⠀⠀⠀⢀⣽⡿⠆⠀⠉⠻⣶⣤",
    "⠀⠀⠙⠛⠻⠿⠿⠿⠿⠟⠉⠀⠀⠀⢠⣴⡿⠋",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀"
}

--The abrin glyph ▄▀█
glyphs.abrin = {
    "⠀⠀⠀⠀⣀⣤⣄⡀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀",
    "⠀⢀⣠⣾⠟⠉⠙⠻⢷⣦⣄⡀⠀⠀⣿⡄⠀⠀⠀⠀",
    "⠀⠘⠋⠀⠀⣠⣴⣶⠾⠟⠛⠃⠀⠀⠘⣿⡀⠀⠀⠀",
    "⠀⠀⢀⣴⡾⢻⣿⠀⠀⠀⠀⠀⠀⠀⢀⣿⢷⣄⠀⠀",
    "⢠⣴⠟⠉⠀⣸⡿⠀⠀⠘⢷⣦⣀⣠⡿⠃⠈⠻⣷⠄",
    "⠀⠁⠀⢀⣼⠟⠀⠀⠀⠀⣠⣼⣿⠿⠁⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠉⠀⠀⠀⠺⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀"
}

--The acjesis glyph ▄▀█
glyphs.acjesis = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣶⣄⡀⠀",
    "⠀⣀⣤⣴⣶⠆⠀⠀⠀⠀⠀⠀⠀⠀⣾⠏⠉⠻⠃",
    "⠈⢛⣿⣿⣁⠀⠀⢰⡆⠀⢰⡶⠀⢰⡿⠀⠀⠀⠀",
    "⣴⡟⠁⠈⠉⠀⢠⣿⣁⡀⣼⡇⠀⠈⠁⠀⠀⠀⠀",
    "⠉⠀⠀⠀⠀⠀⠀⠉⠙⠛⠿⠃⠀⠀⠀⠀⠀⠀⠀"
}

--The aldeni glyph ▄▀█
glyphs.aldeni = {
    --▄▀█
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⢠⣤⣄⣀⣀⣠⣴⠿⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠈⠉⠛⠛⠋⠀⠀⢀⣀⣤⣤⣀⡀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⣶⣾⠛⠋⠉⠈⠙⠛⠷⣶⡀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠈⠹⣷⣄⠀⠀⠀⠀⠀⢙⣷⡀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣷⣤⣴⠶⠿⠟⣿⡇",
    "⠀⠀⢀⣤⣶⣦⣤⡀⠀⠀⠀⠈⠉⠀⠀⠀⢀⣿⠀",
    "⠠⡿⠛⠉⠀⠀⠉⠛⠿⠿⠿⠛⠛⠿⠿⠷⣾⡟⠀"
}

glyphs.alura = {
    "⠀⠀⠀⠀⠀⠀⢠⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⣤⣄⣀⣰⡿⠀⢸⣿⢿⣦⡀⣀⣠⣤⠀⠀⠀⠀⠀",
    "⠀⠉⠛⠛⢿⣿⣿⠿⠀⠈⠛⠛⠉⠀⣀⣀⣤⣴⡄",
    "⠀⠀⠀⢾⣟⠋⠷⣶⣦⣄⠀⠀⣠⣾⡟⠉⠉⠁⠀",
    "⠀⠀⣤⡾⠿⠇⠀⢠⣾⠋⢠⣾⠋⣻⡇⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠛⠁⠀⠈⠻⣷⣌⠁⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠇⠀⠀⠀⠀"
}

glyphs.amiwill = {
    "⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀",
    "⠀⣠⣾⠛⣷⣄⠀⠀⠀⢺⡇⠀⠀⠀⣿⠀⢀⣠⡄",
    "⠸⠟⠁⠀⢈⣿⡦⠀⠀⢸⣧⠀⣀⣰⣿⠿⢛⣿⠁",
    "⠀⢀⣤⡾⠟⠉⠀⠀⠀⠘⣿⠾⠟⢹⣿⠀⠈⠉⠀",
    "⠀⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⡿⠋⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡿⠋⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢷⣤⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀"
}

glyphs.arami = {
    "⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⢻⣇⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣾⢿⣇⠀⠀",
    "⠈⣿⣄⣀⣀⠀⠀⠀⠀⠀⢸⡏⠀⠈⣿⠀⠀",
    "⠀⠈⢉⣿⠟⠁⠀⠀⠀⠀⣸⡇⠀⠀⠀⠀⠀",
    "⠀⢰⡿⠋⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢾⣷⣶⣶⣤⣤⣤⣄",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠿⠆⠀⠀⠀⠉⠉"
}

glyphs.avoniv = {
    "⠀⠀⠀⠀⠀⢠⣤⣀⣀⡀⠀⣀⣤⡶⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠈⠉⠛⢻⣿⠋⠁⠀⠀⠀⠀⠀⠀",
    "⣤⣤⣤⣤⠀⠀⠀⢀⠀⢸⣿⠀⠀⠀⣀⣀⠀⠀⠀",
    "⠉⢉⣿⣏⣤⣀⣠⣿⠁⠀⠉⠀⠶⠿⠛⣿⣄⣠⡶",
    "⠀⠿⠛⠋⠉⠙⠻⠃⠀⠀⠀⠀⠀⠀⠀⠘⠿⠋⠀"
}

glyphs.baselai = {
    "⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠘⠃⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⢀⣾⣷⡄⠀⠀⠀⠀⠀",
    "⠀⠀⠀⢀⣾⠏⠘⢿⣆⠀⠀⠀⠀",
    "⠀⠀⢀⣾⠏⠀⠀⠀⠻⣧⡀⠀⠀",
    "⠀⣠⡿⠃⠀⠀⠀⠀⠀⠙⢿⣄⠀",
    "⠈⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⠇"
}

glyphs.bydo = {
    "⠀⠀⠀⠀⠀⠀⣠⣶⣶⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⢀⣴⡾⠛⠁⠀⠈⣙⠛⣷⡆⠀⠀⠀⠀⠀⠀⠀",
    "⠀⣠⣶⠟⣿⡇⠀⠀⠀⢰⡿⠀⣿⣇⣀⣤⣤⣤⣶⣶⡶",
    "⠘⠋⠁⠀⠻⠃⠀⠀⠀⢾⣇⡀⠙⠉⠉⠉⠉⠁⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣆⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠂⠀⠀⠀⠀⠀⠀⠀"
}

glyphs.capo = {
    "⠀⠀⠀⠀⣠⡄⠀⠀⠀⠀⠀⠺⣿⡿⠛⠛⠛⠃",
    "⠀⠀⣴⡿⠋⠁⢀⡀⠀⠀⠀⠀⠹⣷⡀⠀⠀⠀",
    "⠀⠀⣿⣧⣴⠾⠟⠃⠀⠀⠀⠀⠀⠙⣷⡀⠀⠀",
    "⠀⣠⣿⣿⠁⠀⠀⠀⠀⣾⣷⣤⣄⠀⠹⣷⠀⠀",
    "⣰⡿⠁⠻⢷⣦⣄⠀⠀⣿⡇⠈⠉⠀⠀⢻⣧⠀",
    "⠉⠁⠀⣠⣤⣤⣷⡾⠟⠛⠁⠀⠀⠀⠀⠀⠉⠀",
    "⠀⠀⠀⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}

glyphs.danami = {
    "⠀⠀⠀⠀⠀⢶⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⢘⣿⣤⣶⠶⠶⠶⣶⣶⠀⠀⠀⠀⠀",
    "⠀⠀⣤⣶⣾⠛⠉⠁⠀⠀⠀⠀⣾⠏⠀⠀⠀⠀⠀",
    "⢀⣼⠟⠉⠛⢻⣷⠀⠀⠀⠀⣴⣿⣤⣶⣤⣀⠀⠀",
    "⡾⠃⠀⠀⠀⣼⠏⠀⠀⠀⠀⠉⠉⠁⠀⠈⠙⠻⠂"
}

glyphs.dawnre = {
    "⠀⠀⠀⣠⣾⢷⣦⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⣠⣾⠟⠀⠀⠀⠉⠛⣿⣦⡀⠀⠀⠀⠀⠀⠀",
    "⠸⠟⠁⠀⠀⠀⠀⠀⢸⣿⠈⠻⣷⣄⠀⢠⣿⠃",
    "⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⡀⠀⠀⠙⢿⣿⠃⠀",
    "⠀⠀⠀⠀⢀⣠⣶⠿⠋⠉⠻⢷⣄⠀⠀⠀⠀⠀",
    "⢠⣤⡶⠿⠛⠙⢿⣦⡀⠀⠀⠀⠙⢿⣦⣄⠀⠀",
    "⠀⠁⠀⠀⠀⠀⠀⠈⠻⠿⠛⠛⠛⠛⠛⠛⠁⠀"
}

glyphs.ecrumig = {
    "⠀⠀⠀⠀⣾⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⢠⣿⠀⠈⠛⢷⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠺⣯⠀⠀⠀⠀⠙⢷⡆⠀⠀⠀⠀⠀⣠⣾⡇",
    "⢠⣤⣤⣤⣽⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠋⣿⡇",
    "⠈⠉⠉⠉⠉⠉⠀⠀⠀⠀⢠⣴⡶⠿⠛⠋⠀⠀⠛⠀"
}

glyphs.elenami = {
    "⠀⠀⣴⣄⠀⢀⣴⣶⡄⠀⠀⠀⣀⣴⡆⠀",
    "⠀⠀⣈⣿⣶⠟⠋⠈⢻⣦⣶⠿⠛⠁⠀⠀",
    "⠶⠿⠛⠉⢻⣦⣀⣀⣼⡟⠀⠀⠀⠀⣿⠀",
    "⠀⠀⠀⠀⠀⠉⠉⠙⢻⣆⠀⠀⠀⠀⣿⡀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⡆⠀⠀⠀⠉⠁"
}

glyphs.gilltin = {
    "⠀⠀⢠⣄⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⣾⡇⠀⠀⢀⡀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀",
    "⠀⠀⣿⠃⣠⣶⠟⠁⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀",
    "⠀⢰⣿⡿⠋⠁⣀⡀⠀⠀⢸⣷⣶⣶⣶⠶⠶⠶",
    "⠀⠈⠉⠀⣠⣾⠟⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀",
    "⠀⢀⣤⡾⠛⠻⢶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠾⠟⠋⠀⠀⠀⠀⠈⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀"
}

glyphs.hacemill = {
    "⠀⠀⠀⠀⠀⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⢀⣀⣀⣰⣿⠀⠀⠀⠀⠀⠀⠀⠀⢀⣄⠀⠀⠀⠀",
    "⠀⣾⡏⠙⢻⣷⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⠀⠀⠀⠀",
    "⠀⣿⢷⣤⡈⠻⣶⣤⠀⠀⠀⣀⣴⡶⠶⠿⠂⠀⠀⠀",
    "⢰⣿⣤⣽⣿⠆⠀⠁⠀⠰⣾⣿⣧⣤⣤⣤⣤⡾⠟⠁",
    "⠈⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠁⠀⠀⠀"
}

glyphs.hamlinto = {
    "⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀",
    "⠀⣿⠿⢷⣤⣀⡀⠀⠀⠀⠀⠀⢿⣇⢀⣠⣶⠟⠃",
    "⢀⣿⠀⠀⠈⣹⡿⣦⣀⠀⠀⠀⢨⣿⠟⠉⠀⠀⠀",
    "⠀⠉⠀⠀⢀⣿⠀⠈⠻⢷⣤⣠⡿⠁⠀⠀⠀⠀⠀",
    "⠀⠐⠷⣦⣾⠏⠀⠀⢀⣤⡿⠟⠁⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠈⠉⠀⠀⠸⣿⡉⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠹⠗⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}

glyphs.illume = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⡶⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⢻⣦⠀⢀⣠⣾⠋⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠹⣷⠟⠋⣿⡀⠀⠀⠀⢀⡀",
    "⣀⠀⠀⠀⠀⠀⠀⣠⣤⣴⣿⣷⣦⣤⣶⠿⠋",
    "⠹⣧⠀⠀⠀⠀⠀⣿⡏⠁⣿⡇⠀⠉⠀⠀⠀",
    "⠀⠹⡷⠀⠀⠀⠀⠙⠃⠀⠻⣷⣄⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀"
}

glyphs.laylox = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⠟⠀⠀",
    "⠀⠀⠀⠀⠀⠀⢠⣄⠀⠀⠀⢀⣴⡿⣿⣤⡀⠀⠀",
    "⣤⣤⣤⣤⠀⠀⢸⣿⣀⣀⣴⡿⠋⢀⣴⡿⠁⠀⠀",
    "⢻⣏⣀⣤⣤⠀⢸⡟⠋⢹⣿⠀⠾⣿⣭⣀⣤⡾⠇",
    "⠀⠛⠋⠉⠀⠀⠙⠁⠀⠸⠿⠀⠀⠀⠉⠙⠉⠀⠀"
}

glyphs.lenchan = {
    "⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠐⢿⣦⡀⠀⣤⠀⠙⠻⢷⣦⣄⡀⠀⠀⣀⣴⡾⠃⠀",
    "⠀⠀⠙⢿⣦⣿⠀⠀⠀⠀⠀⣿⡇⠀⠺⣿⣅⡀⠀⠀",
    "⠀⠀⠀⠀⠙⠛⠀⢀⣤⣤⣤⣿⡇⠀⠀⠀⠙⠟⠀⠀",
    "⠀⠀⢀⣤⡀⠀⠀⣸⡟⠉⠉⠉⠀⠀⠀⢸⣿⠶⣦⣄",
    "⠀⢠⣿⠛⠻⡦⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⣿⠄⠈⠁",
    "⠀⠙⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}

glyphs.olavii = {
    "⠀⠀⠀⠀⢀⣤⠀⠀⢿⣦⡀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⢸⣿⠀⠀⠀⠙⠻⣦⣀⢀⣀⣠⣄⠀",
    "⠀⠀⠀⠀⣾⡇⠀⠀⠘⠿⠿⠿⣿⣿⣯⣉⠁⠀",
    "⠐⠶⠶⠶⣿⣄⠀⠀⠀⠀⠀⢠⡿⠀⠈⠙⠿⠆",
    "⠀⠀⠀⠀⠈⠙⢷⡄⠀⠀⠀⠺⠃⠀⠀⠀⠀⠀"
}

glyphs.onceel = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⡆⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣷⠀⠀⠀⠀⢀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠋⠀⠀⠀⣰⡿⠁",
    "⠻⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⡿⠁⠀",
    "⠀⠙⢿⡤⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣦⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠷⠀"
}

glyphs.pocore = {
    "⠀⠀⠀⠀⢸⣷⣦⣄⡀⠀⠀⣀⣤⣤",
    "⠀⠀⠀⠀⢸⡇⠀⠙⠛⠿⠟⠛⠉⠀",
    "⢀⣀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠉⠛⠻⠶⣾⣿⣤⣤⣤⣄⡀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠉⠉⠉⠉⠙⠿⣦⣀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⢀⣤⣴⡾⠟⠋⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠘⣿⡄⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠀⠀⠀⠀"
}

glyphs.ramnon = {
    "⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⣤⣄⣀⠀⠈⠻⢷⣤⡀⠀⠀⠀⠀⠀⠀⠀",
    "⢰⣿⠉⠛⠻⣷⡀⠀⠙⠻⣦⣄⣀⠀⠀⠀⠀",
    "⢸⣿⠀⠀⠀⠘⣷⡄⠀⠀⠀⠉⠛⠛⠷⣶⡀",
    "⢸⣿⠀⠀⠀⠀⠘⢿⣦⣀⠀⠀⠀⠀⠀⢹⡇",
    "⠈⠋⠀⠀⠀⠀⠀⠀⠈⠛⠷⠶⠶⢶⣶⣾⣿",
    "⠀⠀⠀⠀⠀⠀⠀⣤⣤⣄⣀⣠⣴⡾⠛⠉⠀",
    "⠀⠀⠀⠀⠀⠀⠀⢻⣿⡿⠟⠛⠛⠻⠿⢶⣶",
    "⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀"
}

glyphs.recktic = {
    "⠀⠀⠀⠀⠀⠙⠿⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⢀⣀⣀⣀⣀⠀⠈⠹⣷⡀⠀⠀⢀⣀⣀⠀⠀⠀",
    "⠀⠀⠀⠉⠉⠉⠻⢷⣤⠀⠙⢷⣄⣰⡿⠛⠋⠁⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⣸⡏⠀⠀⠈⣿⣿⡀⠀⠀⠀⢀⡀",
    "⠠⣶⣶⣶⣶⣶⠶⠿⠀⠀⢀⣾⠏⠉⠻⣦⣤⡾⠟⠁",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠈⠉⠀⠀⠀"
}

glyphs.robandus = {
    "⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡶",
    "⠛⢷⣦⣀⢀⣶⠀⠀⢀⣀⠀⠀⠀⠀⢰⣆⠀⣼⠇",
    "⠀⠀⠈⠻⢿⣿⡶⠾⠛⠋⠀⠀⠀⠀⠈⣿⣴⡿⠀",
    "⠀⠀⠀⠀⠀⢻⣆⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠀⠀",
    "⠀⠀⠀⠀⠀⠈⠉⣀⣀⣤⣤⡄⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠛⠛⠛⠋⠉⠉⢻⡆⠀⠀⠀⠀⠀⠀"
}

glyphs.roehi = {
    "⠀⠀⠀⠀⠀⣠⣴⡄⠀⠀⠀⢀⣤⣶⣶⣶⣶⣤⡄⠀",
    "⠀⠀⠀⢰⣿⠋⠙⣿⣄⣤⣶⠿⠋⠀⣀⡀⠀⠀⠀⠀",
    "⢠⣤⣤⣼⣿⠀⠀⠘⠛⠉⠀⠀⠀⢠⡿⢿⣦⡀⠀⠀",
    "⠈⠉⠉⠉⠁⠀⠀⣶⠆⠀⠀⠀⢀⣿⠃⠀⠙⢿⣄⠀",
    "⠀⠀⠀⠀⠀⠀⣸⡿⠀⠀⠀⠀⠘⠃⠀⠀⠀⣨⣿⠆",
    "⠀⠀⠀⠀⣴⣿⣯⣥⣄⣻⣿⡿⠿⠿⠿⠿⠿⠋⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠉⠉⠙⠛⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀"
}

glyphs.salma = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣦⡀⠀⠀⠀⠀",
    "⠀⠀⠀⢀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠙⣷⡄⠀⠀⠀",
    "⠀⠀⠀⢸⣿⠛⠿⠷⣶⣄⠀⠀⠀⠀⣿⣇⣤⣶⠄",
    "⠿⠿⠶⠾⠿⠀⠀⠀⠈⠙⠿⣶⠶⢿⣿⣉⣭⡄⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠋⠉⠀⠀"
}

glyphs.sandovi = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⠀⠀⠀",
    "⠈⠛⠛⠿⠿⠷⠀⠀⣀⠀⠀⠀⠀⣠⣶⠟⠋⠀⠀⠀",
    "⠀⠀⠀⠀⣴⡶⠾⢻⣿⠀⠀⠀⢸⡿⠻⠶⣶⡄⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⣿⠇⠀⢠⣿⠁⠀⠀",
    "⠀⠀⠿⠷⠶⣶⣤⣾⣏⠀⠀⠀⠉⠀⢀⣾⣷⣦⣤⡤",
    "⠀⠀⠀⠀⠀⠀⠀⠈⠙⠿⣦⣄⣀⣴⠟⠁⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠁⠀⠀⠀⠀⠀⠀"
}

glyphs.setas = {
    "⢠⣤⣤⣤⣤⣤⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀",
    "⠈⣿⡍⠁⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⠛⠿⠆",
    "⠀⠘⠷⠀⠀⠻⠃⠀⠀⣤⣴⣶⣶⠀⢀⣾⣿⢾⣆⠀",
    "⠀⠀⠀⠀⣀⣤⣴⣦⣤⣿⠃⠀⣿⠀⠈⢉⣀⣈⣻⣆",
    "⠀⠀⠀⠘⠛⠉⠀⠀⠉⠉⠀⠀⠛⠛⠛⠛⠛⠋⠉⠉"
}

glyphs.sibbron = {
    "⠿⣶⣤⣤⣀⡀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠉⠙⠛⠻⣷⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⣿⡆⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⢹⡇⠀⠀",
    "⠀⠀⠀⠀⠀⢀⣴⣿⡇⠀⠀",
    "⠀⠀⠀⠀⣠⡾⠋⢸⡇⠀⠀",
    "⠀⠀⠀⠘⠋⠀⠀⠸⣷⣄⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛"
}

glyphs.subido = {
    "⣤⡀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀",
    "⣿⡇⠀⢀⣴⡾⠛⠛⠛⠻⠿⠷⣶⣦",
    "⢸⣷⠀⠀⠁⠀⠀⠀⠀⠀⣤⡀⢀⣿",
    "⠀⣿⡄⠀⠀⠀⠀⠀⠀⠀⠉⢿⣾⣿",
    "⠀⠘⣿⡾⠟⠀⢀⣤⣶⡿⠿⠛⠛⠉",
    "⠀⠀⠙⢿⡄⠸⠟⢩⣿⠁⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠘⠃⠀⠀⠀⠀⠀"
}

glyphs.tahnan = {
    "⠀⠀⠀⠀⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⢻⣆⠀⠀⣀⣀⡀⠀⠀⠀⠀⠀",
    "⢀⠀⠀⠀⣸⡿⠿⠛⢻⡿⠛⠻⠷⢶⠄⠀",
    "⠛⠿⣶⣾⣟⠀⠀⠀⣸⡇⠀⠀⠀⠀⠀⠀",
    "⠀⣴⣟⢩⣿⠃⠀⠀⠛⠃⠀⠀⢀⣴⣶⠀",
    "⠀⠈⠙⠿⠃⠀⠀⠀⠀⢀⣠⣾⠟⠉⢻⣇",
    "⠀⠀⠀⠀⠀⠀⠀⢠⣴⡟⠋⠀⠀⠀⠈⠿",
    "⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀"
}

glyphs.zamilloz = {
    "⠀⠀⠀⠀⣀⣴⣾⣧⡀⠀⠀⠀⠀⣶⣶⣤⣤⣤",
    "⠀⠀⠀⠀⣿⠁⠀⠙⠷⠀⠀⠀⠀⠹⣷⠀⣼⠏",
    "⠀⠀⣠⣾⠟⠿⢶⣦⡀⠀⣤⣶⣶⠶⣿⡿⠟⠀",
    "⠀⣾⠟⠁⠀⠀⣼⣿⣀⡀⠁⠀⠀⠀⢸⣷⠀⠀",
    "⣾⠏⠀⠀⠀⠀⠈⠉⠙⠛⠀⠀⠀⠀⠀⠿⠀⠀",
    "⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}

glyphs.zeo = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣆⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⣀⠀⠀⣰⡿⠛⢷⡦",
    "⠐⣶⣶⠶⠶⢶⣦⣠⣿⠃⠀⣰⡟⠀⣴⡟⠀⠀⠀⠀",
    "⠀⠈⠻⣧⡀⠀⠉⠻⠃⠀⢰⡿⠁⠀⠉⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}
-------------------------------------------------------------------------------------

--SLEEP TO PREVENT CROSSTALK? idk BUT SLEEP
event.sleep(0.5)

--BEGIN NETWORK SETUP
modem.open(69)

--END NETWORK SETUP

--BEGIN GET GATE ADDRESSES
modem.send("0be49cee-a198-4d52-9acf-8e263bee3dbd", 69, "get_gate_address")

local _, _, _, _, _, requestData = event.pull()

local gateAddresses = text.deserialize(requestData)
--END GET GATE ADDRESSES

--SLEEP TO PREVENT CROSSTALK? idk BUT SLEEP
event.sleep(0.5)

--BEGIN GET GATE TYPE
modem.send("0be49cee-a198-4d52-9acf-8e263bee3dbd", 69, "get_gate_type")

_, _, _, _, _, requestData = event.pull()

local gateType = requestData
--END GET GATE TYPE

--BEGIN DEV FORCE GATE TYPE
--gateType = "MILKYWAY"
--gateType = "PEGASUS"
--gateType = "UNIVERSE"
--END DEV FORCE GATE TYPE

--GET RIGHT ADDRESS FROM TYPE
local gateAddress = gateAddresses[gateType]
--END GET RIGHT ADDRESS FROM TYPE

local function convertAddress(address)
    for i = 1, #address do
        address[i] = string.lower(address[i]:gsub("%s+", ""))
    end

    return address
end

--GET THE CONVERTED ADDRESS AND STORE IT IN THE CORRECT FORMAT FOR RENDERING
local addressToRender = convertAddress(gateAddress)

--SAVE THE LOCAL GATES ADDRESS FOR EASY ACCESS
local localGateAddress = addressToRender

--DRAWS AN ANCIENT TEXT USING THE x, y, splitText, vertical PROVIDED
function ancient.drawAncientText(x, y, splitText, vertical)
    if vertical then
        for i1 = 1, #splitText do
            if type(ancient.ancientGlyphs[splitText[i1]]) ~= "nil" then
                screen.drawImage(x, y + ((i1 - 1) * 5), ancient.ancientGlyphs[splitText[i1]])
            end
        end
    else
        for i = 1, #splitText do
            if type(ancient.ancientGlyphs[splitText[i]]) ~= "nil" then
                screen.drawImage(x + ((i - 1) * 4), y, ancient.ancientGlyphs[splitText[i]])
            end
        end
    end
end

--CREATES A NEW ANCIENT TEXT
function ancient.newAncientText(x, y, text, vertical)
    --TABLE TO STORE THE TEMPORARY DATA
    local self = {}

    --DEFINES THE POSITION VARIABLES
    self.x = 0
    self.y = 0

    --DEFINES THE VARIABLES THAT CONTAINS THE TEXT THAT WILL BE RENDERED
    self.textString = ""
    self.textTable = {}

    --DEFINES THE VARIABLE THAT CONTAINS WHETHER OR NOT THE TEXT IS VERTICAL OR NOT
    self.vertical = false

    --DEFINES THE VARIABLES THAT CONTAIN THE TRUE LENGTH IN PIXELS AND THE LENGTH OF THE TEXT
    self.trueLength = 0
    self.textLength = 0

    --SETS THE POSITION BY THE ARGUMENTS PASSED
    self.x = x
    self.y = y

    --SETS THE RAW STRINGS TO THE ARGUMENTS PASSED
    self.textString = text
    self.originalText = text

    --SETS THE VERTICAL TO THE ARGUMENT PASSED
    self.vertical = vertical

    --SETS TEXTTABLE BY CONVERTING textString
    self.textTable = split(self.textString, "")

    --SETS textLength BY CONVERTING FROM THE textString
    self.textLength = unicode.len(self.textString)

    --CALCULATES trueLength FROM THE TEXTLENGTH AND VERTICAL
    if self.vertical then
        self.trueLength = self.textLength * 5
    else
        self.trueLength = self.textLength * 4
    end

    --RETURNS THE COMPLETED TABLE
    return self
end

--CENTRES THE TEXT ALONG THE VERTICLE OR HORIZONTAL AXIS
function ancient.centreText(self, verticalCentre)
    if verticalCentre then
        self.y = math.floor((newBufferHeight / 2) - (self.trueLength / 2))
    else
        self.x = math.floor((newBufferWidth / 2) - (self.trueLength / 2))
    end

    return self
end

--RENDERES THE ancientTexts FROM THE TABLE PROVIDIED
function ancient.renderAncientTexts(internalTextsTable)
    for textName, textData in pairs(internalTextsTable) do
        ancient.drawAncientText(textData.x, textData.y, textData.textTable, textData.vertical)
    end
end

--RECALCULATES THE LENGTHS OF THE AncientTexts
function ancient.recaclculateText(self)
    self.textTable = split(self.textString, "")
    self.textLength = unicode.len(self.textString)

    if self.vertical then
        self.trueLength = self.textLength * 5
    else
        self.trueLength = self.textLength * 4
    end

    return self
end

--CReATES THE TABLE THAT STORES THE ancientTexts
local ancientTexts = {}

--BEGIN ancientText CREATION

--CREATES THE ancientText THAT SHOWS THE GATE STATUS
ancientTexts.status = ancient.newAncientText(math.floor(newBufferWidth / 6), 1, "idle", true)

--CENTRES THE STATUS ancientText
ancientTexts.status = ancient.centreText(ancientTexts.status, true)

--CREATES THE ancientText THAT SHOWS THE ADDRESS BEING DIALED
ancientTexts.address = ancient.newAncientText(math.floor((newBufferWidth / 6) * 5), 1, "|", true)

--CENTRES THE ADDRESS ancientText
ancientTexts.address = ancient.centreText(ancientTexts.address, true)

--END ancientText CREATION

--CONVERTS AN ADDRESS FROM THE STANDARD TABLE FORMAT TO PROPRIETARY SHORT STRING FORMAT
local function convertAddressToString(addressTable)
    local tempString = ""

    for i = 1, #addressTable do
        for k, v in pairs(glyphConversion[gateTypes[gateType]]) do
            if v == addressTable[i] then
                tempString = tempString .. k
            end
        end
    end

    return tempString
end

modem.open(70)

--CREATE EVENT HANDLER TO HANDLE ALL THE MODEM MESSAGES PROPERLY
local modemHandler =
    event.addHandler(
    function(eventType, _, sendingAddress, port, distance, eventName, arg1, arg2, arg3, arg4, arg5, arg6)
        --IF THE EVENT IS A modem_message AND THE PORT IS FROM THE DIAL SERVER GATE SIGNALS PORT
        if eventType == "modem_message" and port == 70 then
            --CHECKS WHICH SIGNAL FROM THE GATE IS BEING RELAYED BACK AND RUNS ACCORDING CODE
            if eventName == "begin_dial_sequence" then
                --CONVERTS THE ADDRESS PASSED FROM THE DIAL SERVER INTO THE CORRECT FORMAT,
                --THEN COPIES IT TO addressToRender
                addressToRender = convertAddress(text.deserialize(arg1))

                --REMOVES THE POINT OF ORIGIN FROM THE TABLE
                addressToRender[#addressToRender] = nil

                --CHECKS IF THE 7TH OR 8TH GLYPHS DONT EXIST, IF NOT,
                --SET 7 AND 8 TO BLACK GLYPH
                if type(addressToRender[8]) == "nil" then
                    addressToRender[8] = "blank"
                end
                if type(addressToRender[7]) == "nil" then
                    addressToRender[7] = "blank"
                end

                --SETS currentlyDialing TO TRUE, SAYING THAT DIALING HAS STARTED
                currentlyDialing = true
                --RESETS THE CURRENT DIALED GLYPHS AMOUNT TO 0
                dialedGlyphs = 0

                --BEGIN UPDATE ANCIENT TEXTS

                --UPDATES THE ADDRESS AncientText
                ancientTexts.address.textString = convertAddressToString(text.deserialize(arg1))
                ancientTexts.address = ancient.recaclculateText(ancientTexts.address)
                ancientTexts.address = ancient.centreText(ancientTexts.address, true)

                --UPDATES THE STATUS AncientText
                ancientTexts.status.textString = "dialing"
                ancientTexts.status = ancient.recaclculateText(ancientTexts.status)
                ancientTexts.status = ancient.centreText(ancientTexts.status, true) --END UPDATE ANCIENT TEXTS
            elseif eventName == "dial_ended" then
                --RESETS addressToRender TO THE GATES LOCAL ADDRESS
                addressToRender = localGateAddress

                --SETS currentlyDialing to false
                currentlyDialing = false

                --BEGIN UPDATE ANCIENT TEXTS

                --UPDATES THE ADDRESS AncientText
                ancientTexts.address.textString = "|"
                ancientTexts.address = ancient.recaclculateText(ancientTexts.address)
                ancientTexts.address = ancient.centreText(ancientTexts.address, true)

                --UPDATES THE STATUS AncientText
                ancientTexts.status.textString = "idle"
                ancientTexts.status = ancient.recaclculateText(ancientTexts.status)
                ancientTexts.status = ancient.centreText(ancientTexts.status, true) --END UPDATE ANCIENT TEXTS
            elseif eventName == "symbol_dialed" then
                --SETS THE CURRENTLY DIALED GLYPH AMOUNTS TO WHAT IS PASSED FROM THE DIAL SERVER
                dialedGlyphs = arg1

                --JUST TO MAKE SURE IT SETS currentlyDialing TO TRUE
                currentlyDialing = true
            elseif eventName == "stargate_close" then
                --RESETS addressToRender TO THE LOCAL GATES ADDRESS
                addressToRender = localGateAddress

                --SETS currentlyDialing TO FALSE
                currentlyDialing = false

                --BEGIN UPDATE ANCIENT TEXTS

                --UPDATES THE ADDRESS AncientText
                ancientTexts.address.textString = "|"
                ancientTexts.address = ancient.recaclculateText(ancientTexts.address)
                ancientTexts.address = ancient.centreText(ancientTexts.address, true)

                --UPDATES THE STATUS AncientText
                ancientTexts.status.textString = "idle"
                ancientTexts.status = ancient.recaclculateText(ancientTexts.status)
                ancientTexts.status = ancient.centreText(ancientTexts.status, true) --END UPDATE ANCIENT TEXTS
            elseif eventName == "stargate_failed" then
                --SETS addressToRender TO THE LOCAL GATES ADDRESS
                addressToRender = localGateAddress

                --SETS currentlyDialing TO FALSE
                currentlyDialing = false

                --BEGIN UPDATE ANCIENT TEXTS

                --UPDATES THE ADDRESS AncientText
                ancientTexts.address.textString = "|"
                ancientTexts.address = ancient.recaclculateText(ancientTexts.address)
                ancientTexts.address = ancient.centreText(ancientTexts.address, true)

                --UPDATES THE STATUS AncientText
                ancientTexts.status.textString = "idle"
                ancientTexts.status = ancient.recaclculateText(ancientTexts.status)
                ancientTexts.status = ancient.centreText(ancientTexts.status, true) --END UPDATE ANCIENT TEXTS
            elseif eventName == "stargate_open" then
                --SETS currentlyDialing TO FALSE
                currentlyDialing = false

                --UPDATES THE STATUS AncientText
                ancientTexts.status.textString = "gate open"
                ancientTexts.status = ancient.recaclculateText(ancientTexts.status)
                ancientTexts.status = ancient.centreText(ancientTexts.status, true)
            elseif eventName == "stargate_incoming_wormhole" then
                --SETS currentlyDialing TO FALSE
                currentlyDialing = false

                --UPDATES THE STATUS AncientText
                ancientTexts.status.textString = "incoming wormhole"
                ancientTexts.status = ancient.recaclculateText(ancientTexts.status)
                ancientTexts.status = ancient.centreText(ancientTexts.status, true)
            end
        end
    end
)

--BEGIN MAIN RENDER LOOP
while true do
    local eventType = event.pull(0.0001)
    if eventType == "touch" or eventType == "key_down" then
        --BEGIN CLEANUP CODE

        --CLOSE MODEM PORTS
        modem.close(69)
        modem.close(70)

        --REMOVE EVENT HANDLER
        event.removeHandler(modemHandler)

        --RESET THE RESOLUTION
        screen.setResolution(oldBufferWidth, oldBufferHeight)

        --END CLEANUP CODE
        break
    end

    --CLEAR SCREEN BEFORE RENDERING
    screen.clear(backgroundColor)

    --FUNCTION FOR RENDERING GLYPHS IN MY STUPID ASS RENDERING FORMAT
    local function renderGlyph(x, y, colour, glyph)
        --ITERATE THROUGH ALL THE STRINGS IN glyph
        for i = 1, #glyph do
            --RENDER THE GLYPH LINE BY LINE
            screen.drawText(x, y + i - 1, colour, tostring(glyph[i]), 0)
        end
    end

    --RENDER ALL THE GLYPHS ACCORDING TO HOW BIG THE ADDRESS IS
    for i = 1, #addressToRender do
        --BEGIN SETUP BEFORE RENDERING

        --GET THE CORRECT GLYPH NAME
        local currentGlyphName = addressToRender[i]
        --GET THE GLYPH FROM THE NAME
        local glyph = glyphs[currentGlyphName]

        --BEGIN CALCULATE POSITIONS

        --CALCULATES X BY GETTING THE MIDDLE OF THE SCREEN MINUS THE WIDTH OF THE GLYPH,
        --CENTERING IT, THE FLOORS IT BECAUSE MINEOS HATES DECIMAL POSITION VALUES
        local mathedOutX = math.floor((newBufferWidth / 2) - (unicode.len(glyph[1]) / 2))
        --CALCULATES Y BY DIVIDING BY 9 AND MULTIPLYING BY i WHICH IS WHAT GLYPH WE ARE ON,
        --ESSENTIALLY SPLITTING SCREEN INTO MULTIPLE ROWS, THE FLOORS IT BECAUSE MINEOS HATES
        --DECIMAL POSITION VALUES
        local mathedOutY = math.floor(((newBufferHeight / 9) * (i - 1)) + 2)

        --END CALCULATE POSITIONS

        --SETS finalColour TO THE DEFAULT VALUE, IF NOT SET BY FOLLOWING CODE, STAY AT textColour
        local finalColour = textColour

        --BEGIN COLOUR SETUP

        --CHECKS IF CURRENTLY DIALING
        if currentlyDialing then
            --IF SO CHECKS IF THE CURRENT GLYPH HAS BEEN DIALED
            if i <= dialedGlyphs then
                --IF YES, SET TO textColour
                finalColour = textColour
            else
                --IF NOT, SET TO THE DIMMED COLOUR
                finalColour = dimmedTextColour
            end
        end

        --END COLOUR SETUP

        --END SETUP BEFORE RENDERING

        --RENDER GLYPH USING THE CALCULATES X AND Y, THE PROPER COLOUR,
        --AND THE GLYPH DATA ITSELF
        renderGlyph(mathedOutX, mathedOutY, finalColour, glyph)
    end

    --BEGIN RENDER PoO FOR PROPER GLYPH TYPE
    if gateType == "MILKYWAY" then
        --BEGIN COLOUR SETUP

        --SETS THE finalColour VARIABLE WHICH IS WHERE THE FINAL COLOUR WILL BE STORED
        local finalColour = textColour

        if currentlyDialing then
            if dialedGlyphs <= #addressToRender then
                finalColour = dimmedTextColour
            else
                finalColour = textColour
            end
        end

        --END COLOUR SETUP

        --RFNDER GLYPH USING THE POSITION WHICH IS DEPENDENT ON THE SIDE,
        --AND SUCH OF THE GLYPH ITSELF
        renderGlyph(
            math.floor((newBufferWidth / 2) - (unicode.len(glyphs.earthpoo[1]) / 2)),
            math.floor(newBufferHeight - #glyphs.earthpoo),
            finalColour,
            glyphs.earthpoo
        )
    elseif gateType == "UNIVERSE" then
        --BEGIN COLOUR SETUP

        --SETS THE finalColour VARIABLE WHICH IS WHERE THE FINAL COLOUR WILL BE STORED
        local finalColour = textColour

        if currentlyDialing then
            if dialedGlyphs <= #addressToRender then
                finalColour = dimmedTextColour
            else
                finalColour = textColour
            end
        end

        --END COLOUR SETUP

        --RFNDER GLYPH USING THE POSITION WHICH IS DEPENDENT ON THE SIDE,
        --AND SUCH OF THE GLYPH ITSELF
        renderGlyph(
            math.floor((newBufferWidth / 2) - (unicode.len(glyphs.glyph17[1]) / 2)),
            math.floor(newBufferHeight - #glyphs.glyph17),
            finalColour,
            glyphs.glyph17
        )
    else
        --BEGIN COLOUR SETUP

        --SETS THE finalColour VARIABLE WHICH IS WHERE THE FINAL COLOUR WILL BE STORED
        local finalColour = textColour

        if currentlyDialing then
            if dialedGlyphs <= #addressToRender then
                finalColour = dimmedTextColour
            else
                finalColour = textColour
            end
        end

        --END COLOUR SETUP

        --RFNDER GLYPH USING THE POSITION WHICH IS DEPENDENT ON THE SIDE,
        --AND SUCH OF THE GLYPH ITSELF
        renderGlyph(
            math.floor((newBufferWidth / 2) - (unicode.len(glyphs.subido[1]) / 2)),
            math.floor(newBufferHeight - #glyphs.subido),
            finalColour,
            glyphs.subido
        )
    end
    --END RENDER PoO FOR PROPER GLYPH TYPE

    --DRAWS THE ANCIENT TEXTS TO THE SCREEN
    ancient.renderAncientTexts(ancientTexts)

    --RUNS screen.update() WHICH TELLS MINEOS TO RENDER THE SCREEN ACCORDING TO THE VARIOUS CODE ABOVE
    screen.update()
end
--END MAIN RENDER LOOP
