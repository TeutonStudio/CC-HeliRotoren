local CFGV = require("libraries/config")
local KV = require("libraries/kommunikation")
local VR = require("libraries/vektor")
local RV = require("libraries/rotor")
local PID   = require("libraries/steuerung")

local cfg = CFGV.loadConfig()
print("[INFO] Starte Rotor-Steuerung auf Kanal: " .. cfg.channel)
print("[INFO] Rotoren: " .. table.concat(cfg.rotoren, ", "))
KV.identifiziereModem(cfg)

local werte = {verbindung = false, quaternionHaupt = nil, quaternionHeck = nil, steuerung = { p=0, r=0, c=0, y=0 }}

-- Non-blocking: Senden in separater Schleife
parallel.waitForAny(
    function() KV.empfangeKommunikation(cfg, werte) end,
    function() KV.sendeKommunikation(cfg, false, 0.02) end,
    function() RV.aktualisiereRotoren(cfg, werte, 0.02) end
)
