-- libraries/rotor.lua
local rotor = {}
-- local VR = require("libraries/vektor")

-- Zustand der Rotoren
-- local quaternionHaupt = quaternion.new(vector.new(),1)
-- local quaternionHeck = quaternion.new(vector.new(),1)
local pitch = 0
local roll = 0
local coll = 0
local yaw = 0

function rotor.steuern(p,r,c,y)
    pitch = p
    roll = r
    coll = c
    yaw = y
end

local function kreis(winkel)
    local x = math.cos(winkel)
    local y = math.sin(winkel)
    return vector.new(x,y,1)
end

-- Ermittelt die Rotorstellung nach dem azimuthWinkel und der steurung vec=(pitch,roll,collective)
local function rotorWinkel(azimuth,vec) return vec:dot(kreis(azimuth)) end

-- Setzt die Rotorstellung nach einer Seite, des azimuthWinkel und steuerung vec=(pitch,roll,collective)
function rotor.setzeRotor(seite,winkel)
    local inv = seite == "front" or seite == "right" or seite == "bottom"
    local rotor = peripheral.wrap(seite)
    if rotor then
    	local rotorWinkelDef = rotor.setFlapAngle
    	if rotorWinkelDef then rotorWinkelDef(winkel * (inv and -1 or 1)) end
	else end
end

function rotor.setzeRotoren(config,winkel)
    for idx, seite in ipairs(config.rotoren) do
        local w = 0
        if winkel == nil then
            local x,y,z = quaternion.fromShip():toEuler()
            local st = vector.new(pitch,roll,coll)
            local azimuth = x + math.rad(90) * config.rotoren.find(seite)
            -- print(math.deg(azimuth))
            w = rotorWinkel(azimuth,st)
        else w = winkel end
        rotor.setzeRotor(seite,w) end
end

function rotor.aktualisiereRotoren(config, delta) -- Rotorsteuerung
    while true do
        if config.rolle == "sekundar" then 
            rotor.setzeRotoren(config,yaw) end
        if config.rolle == "primar" then
            rotor.setzeRotoren(config,nil) end
        sleep(delta) end
end


return rotor
