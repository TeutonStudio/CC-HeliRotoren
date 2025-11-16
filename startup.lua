local CFGV = require("libraries/config")
local KV = require("libraries/kommunikation")
local VR = require("libraries/vektor")
local RV = require("libraries/rotor")

local cfg = CFGV.loadConfig()
local modem = peripheral.wrap(cfg.modem)
if not modem then error("Kein Modem an '" .. cfg.modem .. "' gefunden!") end

local rotorSeiten = cfg.rotors
local verbindung = false
local steuer = vector.new(0,0,0)
local quaternionHaupt, quaternionHeck

print("[INFO] Starte Rotor-Steuerung mit Modem: " .. cfg.modem)
print("[INFO] Rotoren: " .. table.concat(rotorSeiten, ", "))

modem.open(cfg.channel)

-- Non-blocking: Senden in separater Schleife
parallel.waitForAny(
    function() -- Sender
        while true do
            KV.sendeKommunikation(modem, cfg, false)
            sleep(0.05)
        end
    end,
    function() -- Empfänger & Verarbeitung
        while true do
            local event, side, channel, replyChannel, message, dist = os.pullEvent("modem_message")

            if channel == cfg.channel then  -- Nur unser Kanal
                -- Quaternion-Austausch
                local qH, qK = KV.interpretiereKommunikation(message, cfg.level, {verbindung = verbindung, channel = channel})
                if qH and qK then
                    quaternionHaupt, quaternionHeck = qH, qK
                    local azimuth = RV.azimuth(quaternionHaupt, quaternionHeck)
                    for _, seite in ipairs(rotorSeiten) do
                        RV.setzeRotor(seite, azimuth, steuer)
                    end
                end

                -- Steuerung
                local neueSteuer = KV.interpretiereSteuerung(message, cfg.level, {steurung = steuer})
                if neueSteuer then
                    steuer = neueSteuer
                end
            end
        end
    end
)
