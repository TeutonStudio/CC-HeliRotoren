local CFGV = require("libraries/config")
local KV = require("libraries/kommunikation")
local VR = require("libraries/vektor")
local RV = require("libraries/rotor")
local PID   = require("libraries/steuerung")

local cfg = CFGV.loadConfig()
print("[INFO] Starte Rotor-Steuerung mit Modem: " .. cfg.modem)
print("[INFO] Rotoren: " .. table.concat(cfg.rotoren, ", "))
KV.identifiziereModem(cfg)


local verbindung = false
local steuer = { p=0, r=0, c=0, y=0 }
local quaternionHaupt, quaternionHeck


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

            if channel == cfg.channel and nachricht then  -- Nur unser Kanal
                -- Quaternion-Austausch
                local qH, qK
                local werte = {verbindung = verbindung, quaternionHaupt = qH, quaternionHeck = qK, steuerung = steuer}
                KV.interpretiereKommunikation(nachricht, cfg, werte)
                KV.interpretiereSteuerung(nachricht, werte)
                
                if qH and qK then
                    quaternionHaupt, quaternionHeck = qH, qK
                    local azimuth = RV.azimuth(quaternionHaupt, quaternionHeck)
                    RV.setzeRotoren(cfg, azimuth, VR.errechneSteurung(cfg.rolle,steuer)) end
                
            end
        end
    end
)
