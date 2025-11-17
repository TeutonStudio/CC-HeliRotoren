local CFGV = require("libraries/config")
local KV = require("libraries/kommunikation")
local VR = require("libraries/vektor")
local RV = require("libraries/rotor")
local PID   = require("libraries/steuerung")

local cfg = CFGV.loadConfig()
print("[INFO] Starte Rotor-Steuerung mit Modem: " .. cfg.modem)
print("[INFO] Rotoren: " .. table.concat(cfg.rotoren, ", "))
KV.identifiziereModem(cfg)

local werte = {verbindung = false, quaternionHaupt = nil, quaternionHeck = nil, steuerung = { p=0, r=0, c=0, y=0 }}
-- local verbindung = false
-- local steuer = 
-- local quaternionHaupt, quaternionHeck


-- Non-blocking: Senden in separater Schleife
parallel.waitForAny(
    function() -- Sender
        while true do
            KV.sendeKommunikation(cfg, false)
            sleep(0.05)
        end
    end,
    function() -- Empfänger & Verarbeitung
        while true do
            local event, seite, channel, replyChannel, nachricht, distanz = os.pullEvent("modem_message")

            if channel == cfg.steuerung and nachricht then  -- Nur unser Kanal
                KV.interpretiereSteuerung(nachricht, werte) end
            if channel == cfg.channel and nachricht then  -- Nur unser Kanal
                KV.interpretiereKommunikation(nachricht, cfg, werte) end
        end
    end,
    function() -- Rotorsteuerung
        while true do
            if werte.quaternionHaupt and werte.quaternionHeck then
                RV.setzeRotoren(cfg,werte,RV.azimuth,VR.errechneSteurung) end
        end
    end
)
