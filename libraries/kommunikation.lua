-- libraries/kommunikation.lua
local kommunikation = {}

local VR = require("libraries/vektor")
local RV = require("libraries/rotor")

local function keinModem(seite) return "[FEHLER] Kein Modem an '" .. seite .. "' gefunden!" end

-- Identifiziert ob das Modem an config.modem seite ist und schreibt das peripheral in die config
function kommunikation.identifiziereModem(config)
    print("[INFO] Starte Rotor-Steuerung auf Kanal: " .. config.channel)
    print("[INFO] Rotoren: " .. table.concat(config.rotoren, ", "))
    local modem = peripheral.wrap(config.modem)
    if not modem then error(keinModem(config.modem)) end
    if not modem.isOpen(config.channel) then
        modem.open(config.channel) end
    config.modem = modem
end

function kommunikation.interpretiereSteuerung(nachricht)
    if nachricht.sender == "steuerung" then
        print("Steuerungsbefehl empfangen")
        print(nachricht.pitch, nachricht.roll, nachricht.coll, nachricht.yaw)
        RV.steuern(nachricht.pitch or 0, nachricht.roll or 0, nachricht.coll or 0, nachricht.yaw or 0) end
end


-- Senden
local lastStatus = 0
function kommunikation.sendeKommunikation(config, delta)
    while true do
        if os.clock() - (lastStatus or 0) > delta then
            lastStatus = os.clock()
            config.modem.transmit(config.channel, config.channel, {
                sender = config.rolle.."-steuerung-info",
                position = ship.getWorldspacePosition(),
                linearGeschw = VR.lokaleLinearGeschwindigkeit(),
                winkelGeschw = VR.lokaleWinkelGeschwindigkeit()
            } ) end
        sleep(delta)
    end
end

local function verbindungsAusgabe(rolle,channel)
    local partner = ""
    if rolle == "primar" then partner = "Heckrotor" end
    if rolle == "sekundar" then partner = "Hauptrotor" end
    return "[VERBUNDEN] "..partner.." gefunden! (Kanal "..channel..")"
end

-- Empfangen
function kommunikation.empfangeKommunikation(config,status)
    while true do
        local event, seite, channel, replyChannel, nachricht, distanz = os.pullEvent("modem_message")
        if status.verbindung or nachricht.sender == config.rolle then
            -- TODO nix gibts
        else
            print(verbindungsAusgabe(config.rolle,config.channel))
            status.verbindung = true end
        if channel == config.channel and nachricht then
            -- kommunikation.interpretiereKommunikation(nachricht, config, status)
            kommunikation.interpretiereSteuerung(nachricht)
        end
    end
end

return kommunikation
