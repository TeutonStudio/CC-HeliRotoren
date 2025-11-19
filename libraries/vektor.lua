-- libraries/vektor.lua
local vektor = {}

local GLOBAL = { x = vector.new(1,0,0), y = vector.new(0,1,0), z = vector.new(0,0,1)}


-- Ermittelt 3 Orthogonale Vektoren zu einer quaternion
function vektor.erhalteVektorraum(quat)
    local q = quat:normalize()
    return q * GLOBAL.x, q + GLOBAL.y, q * GLOBAL.z
end

local function sign(x) return (x<0 and -1 or 1) end

-- ermittelt den Winkel zwischen zwei Vektoren
function vektor.gerichteterWinkel(vec1,vec2)
    return math.deg(math.acos(vec1:normalize():dot(vec2:normalize())))
end

function vektor.orientierterWinkel(vec1, vec2, up)
    local v = vec1:normalize()
    local s = vec2:normalize()
    local o = up:normalize()
    return math.deg(math.atan2(v:cross(s):dot(o),v:dot(s)))
end

local function GlobalNachLokal(vel)
    return quaternion.fromShip():conjugate() * vector.new(vel.x,vel.y,vel.z)
end

function vektor.lokaleLinearGeschwindigkeit()
    return GlobalNachLokal(ship.getVelocity()) 
end

function vektor.lokaleWinkelGeschwindigkeit()
    return GlobalNachLokal(ship.getOmega()) 
end


function vektor.errechneSteurung(rolle,eingabe)
    local linearGeschwindigkeit = vektor.lokaleLinearGeschwindigkeit()
    local winkelGeschwindigkeit = vektor.lokaleWinkelGeschwindigkeit()
    local sollPitch,sollRoll,sollColl,sollYaw = eingabe.p,eingabe.r,eingabe.c,eingabe.y
    local pitch,roll,coll
    if rolle == "primar" then
        pitch = sollPitch - winkelGeschwindigkeit.x
        roll = sollRoll - winkelGeschwindigkeit.z
        coll = sollColl - linearGeschwindigkeit.y
    end
    if rolle == "sekundar" then 
        pitch = 0 -- winkelGeschwindigkeit.x
        roll = 0 -- winkelGeschwindigkeit.z
        coll = sollYaw - linearGeschwindigkeit.x
    end
    return vector.new(pitch,roll,coll)
end


return vektor
