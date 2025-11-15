-- libraries/rotor.lua
local rotor = {}
local VR = require("libraries/vektor")

local function kreis(winkel)
    local x = math.cos(winkel)
    local y = math.sin(winkel)
    return vector.new(x,y,1)
end
-- Ermittelt die Rotorstellung nach dem azimuthWinkel und der steurung vec=(pitch,roll,collective)
local function rotorWinkel(azimuth,vec) return vec:dot(kreis(math.rad(azimuth))) end --kreis(math.rad(azimuth + 180)):dot(vec) end

-- Indexiert die eingabe Seiten des Rechners (Kompatibel für Vertikal & Horizontal)
local function seitenIndex(seite) -- TODO auf vierlistiges Argument umprogrammieren, dass einem find() -> int entspricht
    if seite == "front"  then return 0 end
    if seite == "top"    then return 0 end
    if seite == "right"  then return 1 end
    if seite == "back"   then return 2 end
    if seite == "bottom" then return 2 end 
    if seite == "left"   then return 3 end
end

-- Setzt die Rotorstellung nach einer Seite, des azimuthWinkel und steuerung vec=(pitch,roll,collective)
function rotor.setzeRotor(seite,azimuth,vec)
    local inv = seite == "back" or seite == "right" or seite == "bottom"
    local korWinkel = rotorWinkel(azimuth - 90*seitenIndex(seite),vec) * (inv and -1 or 1)
    local rotor = peripheral.wrap(seite)
    if rotor then
    	local rotorWinkelDef = rotor.setFlapAngle
    	if rotorWinkelDef then rotorWinkelDef(korWinkel) end
	else end
end

function rotor.azimuth(q1,q2)
    x1, y1, z1 = VR.erhalteVektorraum(q1)
    x2, y2, z2 = VR.erhalteVektorraum(q2)
    return VR.orientierterWinkel(x1,x2,y1)
end

return rotor
