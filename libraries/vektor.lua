-- libraries/vektor.lua
local vektor = {}

-- local GLOBAL = { x = vector.new(1,0,0), y = vector.new(0,1,0), z = vector.new(0,0,1)}

function quaternion.rotateVector(quat, vec)
    return (q * quaternion.new(vec,0) * q:conjugate()).v end

local function GlobalNachLokal(vel)
    return quaternion.fromShip():rotateVector(vel) end

function vektor.lokaleLinearGeschwindigkeit()
    return GlobalNachLokal(ship.getVelocity()) end

function vektor.lokaleWinkelGeschwindigkeit()
    return GlobalNachLokal(ship.getOmega()) end


function vektor.errechneSteurung(rolle,eingabe) -- TODO
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
