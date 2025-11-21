local CFGV = require("libraries/config")
local KV = require("libraries/kommunikation")
-- local VR = require("libraries/vektor")
local RV = require("libraries/rotor")
local PID   = require("libraries/steuerung") -- TODO

local cfg = CFGV.loadConfig()
KV.identifiziereModem(cfg)

local werte = {verbindung = false}
local delta = .02

-- Non-blocking: Senden in separater Schleife
parallel.waitForAny(
    function() KV.sendeKommunikation(cfg, delta) end,
    function() KV.empfangeKommunikation(cfg, werte) end,
    function() RV.aktualisiereRotoren(cfg, delta) end
)
