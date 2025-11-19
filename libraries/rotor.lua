-- libraries/rotor.lua
local rotor = {}
local VR = require("libraries/vektor")

local function kreis(winkel)
    local x = math.cos(winkel)
    local y = math.sin(winkel)
    return vector.new(x,y,1)
end
-- Ermittelt die Rotorstellung nach dem azimuthWinkel und der steurung vec=(pitch,roll,collective)
local function rotorWinkel(azimuth,vec) return vec:dot(kreis(math.rad(azimuth))) end

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
function rotor.setzeRotor(seite,winkel)
    local inv = seite == "back" or seite == "right" or seite == "bottom"
    --local korWinkel = rotorWinkel(azimuth - 90*seitenIndex(seite),vec) * (inv and -1 or 1)
    local rotor = peripheral.wrap(seite)
    if rotor then
    	local rotorWinkelDef = rotor.setFlapAngle
    	if rotorWinkelDef then rotorWinkelDef(winkel) end
	else end
end

function rotor.setzeRotoren(config,winkel)
    for idx, seite in ipairs(config.rotoren) do
        rotor.setzeRotor(seite,winkel) end
end

function rotor.azimuth(qHaupt,qHeck)
    if not qHaupt or not qHeck then return nil end
    x1, y1, z1 = VR.erhalteVektorraum(qHaupt)
    x2, y2, z2 = VR.erhalteVektorraum(qHeck)
    local v = y1:cross(x2)
    return VR.orientierterWinkel(x1,v,y1)
end


function rotor.aktualisiereRotoren(config, werte, delta) -- Rotorsteuerung
    while true do
        local azimuth = rotor.azimuth(werte.quaternionHaupt, werte.quaternionHeck)
        if azimuth then
            if config.rolle == "primar" then 
                for idx, seite in ipairs(config.rotoren) do
                    local vec = vector.new(werte.steuerung.p, werte.steuerung.r, werte.steuerung.c)
                    local winkel = rotorWinkel(azimuth - 90*seitenIndex(seite), vec)
                    rotor.setzeRotor(seite,winkel) end
            end
            if config.rolle == "sekundar" then 
                rotor.setzeRotoren(config,werte.steuerung.y) end
        end
        sleep(delta) end 
end


return rotor
